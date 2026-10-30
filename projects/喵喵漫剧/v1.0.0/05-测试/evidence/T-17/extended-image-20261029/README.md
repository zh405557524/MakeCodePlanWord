# T-17 全 App extended_image 接入验证（2026-10-29）

App 提交：`b68d463`（dev，未推送）。用户已批准三批实施；三批开发检查完成，待用户验收。无后端、数据库、迁移或部署改动。沿用原交互、布局和保存原图逻辑。

## 三批结果

1. 直接锁定 `extended_image: 10.1.0`；新增 `AppImage.file/memory`，`AppCachedNetworkImage` 保持参数兼容。ResourceService 获取缓存文件，插件只负责读取、解码和展示，网络兜底不启用第二份磁盘缓存。批次一最初14项检查通过。
2. 独立缩略图 LRU 为64 MiB/200项，按布局/DPR及原图比例解码，不上采样。原图预览另用零驻留缓存，退出释放；关闭原始字节缓存，删除原尺寸 ui.Image 重复缓存。内存告警清理可回收项；会话变化撤下旧图，文件失效移除全部解码尺寸。批次二最初22项检查通过。
3. 迁移所有业务图片展示入口，包括素材/历史/工作台、项目/案例/风格/头像、上传和原图预览、视频封面及时间轴。保留此前未提交的每批4并发修复、完成即显示、请求去重及旧结果拦截。视频解码/导出渲染和内置图标不变。

日志仅规范化行尾空白，测试内容与结果保持原样。

## 自动检查与构建

| 检查 | 实际结果 | 证据 |
| --- | --- | --- |
| Dart format（32个变更 Dart 文件）、diff check | 0改动，无空白错误 | `format-check.log` |
| 静态分析 | 0问题 | `analyze.log` |
| 最终图片/资源/业务定向回归 | 228通过 | `targeted-tests.log` |
| 会话生命周期及素材列表扩展回归 | 54通过 | `lifecycle-tests.log` |
| 全量回归 | 1753通过、1跳过、14失败 | `full-tests.log` |
| 未修改 HEAD 隔离基线对照 | 相同14项失败（对照子集103通过） | `baseline-tests.log`、`baseline-comparison.json` |
| iOS simulator debug构建 | 通过 | `ios-build.log` |
| Android debug APK构建 | 通过 | `android-build.log` |

基线为 `0c5fb87d91e9e548575c889ca8ebea09d8c7d297`。14项失败逐项按路径和名称比对一致：声音报价类型转换1项、小屏批量弹框1项、媒体原生元数据1项、源音频布局5项、视频历史1项、替换预览3项、编辑会话切换2项。没有将这些失败记为通过，也没有修改其业务代码。全量回归后仅补充1项坏图恢复测试和整理两个导入顺序；最终228项定向回归和静态检查再次通过，构建时的产品逻辑与最终提交一致。

测试覆盖：首张阻塞、失败释放槽、分页承接旧排队项、切分类/账号隔离、工作台去重；同资源签名刷新及跨页面文件复用、不同资源/账号/后端隔离；已删除/截断文件重新下载；同路径坏图修复后重新解码；迟到坏图不抛未捕获异常；contain/cover实际解码比例、禁止上采样；所有尺寸失效；内存告警；24张大缩略图实际解码触发LRU且不越64 MiB。坏图恢复不代表插件自动修复服务端持续返回的坏文件。

构建及运行使用普通 `lib/main.dart`，参数为 `CATDRAMA_ENV=1`、`CATDRAMA_LOCAL_BASE_URL=http://127.0.0.1:19087`。这是本机受控接口，不是线上包或部署验收。

## 桌面控机补充用例

固定池领取并复用 iPhone SE3（iOS26.5，UDID `8C69C1E5-6606-4FA6-89C9-A4EFBDF8D3EF`）和 Pixel5（Android37/17，AVD `Solfeggio_Store_Phone_20261019`，serial `emulator-5554`，无Play商店）。iOS经Appium/WDA，Android经ADB；由工作区 `phone-ui/phone_test.py` 保存逐步截图、UI树、定位和动作记录。未新建/克隆/重置设备。调试进程已停止、设备已关闭、两端租约均归还。

夹具 `http_fixture.py` 提供8张、后扩展16张4096×3072 PNG及合成账号数据；前四张可独立阻塞/释放。Android短信登录为本机接口模拟，没有发送真实短信、调用真实Provider或消耗额度。服务分三次启动，事件追加于 `http-events.jsonl`；最后一次运行 `--resource-offset 20000 --asset-count 16 --release-all`，资源37311～37326。脚本和配置只用于开发检测。

| 用例 | 可读步骤与预期 | 观察与结论 |
| --- | --- | --- |
| IMG-01 首张阻塞独立出图 | iOS打开资产列表；同时阻塞前四张，只释放第二张；首张仍等待时第二张应显示并继续补后续任务 | `four-concurrent.json`记录4个并发；`second-first.json`及`ios/observations/O00005.png`证明首张等待、第二张可见。通过 |
| IMG-02 列表与缓存复用 | 释放全部，查看列表；扩展至16张，向下2次、向上2次，核对图片和标签 | 两端正常显示、滚动无串图，缓存字节及条目不因往返增加。`scroll_images.py`、`ios/observations/O00071.png`、`android/observations/O00065.png`、`memory.jsonl`。通过 |
| IMG-03 原图关闭释放 | 进入资产详情，连续4次打开/关闭原图，每步读取缓存及进程内存 | 两端预览 live 每次1→0，预览bytes/entries始终0；`repeat_preview.py`、`repeat_android_preview.py`、`memory.jsonl`。Android已目视核对 `android/observations/O00073.png` 的完整4:3原图；缩放控件保持原InteractiveViewer。通过 |
| IMG-04 原页面表现 | 核对资产列表、详情、原图的图片比例/原有标题/按钮及占位；不增添UI元素 | 已目视检查两端相关截图，列表cover、预览contain行为符合原入口定义；未进行所有迁移页面的同视口Figma像素验收。上述页面检查通过，完整视觉验收未完成 |

手机运行器借用原 `TC-03-01` 记录入口，但本轮未评估该案例的完整作品分类/来源/上传业务预期；两份运行记录明确保持 `original_case_status=not_assessed`，以blocked结束完整原案例，不增加正式测试通过计数。本表IMG补充检查与原案例分开判断。

## 内存观测

`metrics.py`读取debug VM扩展 `ext.catdrama.imageCache`、Dart heap/external，以及iOS进程RSS或Android dumpsys；采样前请求Dart GC。完整数据含采样时间保存在 `memory.jsonl`。live为插件命名ImageCache的存活条目数，不能代替所有GPU/原生位图数量。缓存预算不等于App进程总内存，显示中的图片可超出可回收LRU部分。

| 场景 | 缩略图bytes / entries / live | 原图live | 进程RSS（KiB，按顺序） |
| --- | --- | --- | --- |
| iOS 16图列表4次滚动 | 固定8,967,808 / 17 / 16（含先前详情尺寸） | 0 | 481296、480304、489952、498880 |
| Android 16图列表4次滚动 | 固定13,585,152 / 16 / 16 | 0 | 465712、438320、439120、448608 |
| iOS 4次关闭原图后 | 固定5,688,128 / 9 / 1（8图阶段） | 每次0 | 484560、457696、454880、467600 |
| Android 4次关闭原图后 | 固定18,583,904 / 17 / 17（16图阶段，底层列表仍存活） | 每次0 | 424208、403952、326048、282528 |

观测范围内，重复操作没有造成命名缓存或原图存活项持续累积；RSS存在波动，iOS滚动末尾较起始高约17 MiB，不能据此宣称整个进程无泄漏或64 MiB内存封顶。这里是debug模拟器、合成图片和短时采样；实体低内存设备、长时压力、真实网络/OSS/账号切换及全App视觉验收仍待补充。
