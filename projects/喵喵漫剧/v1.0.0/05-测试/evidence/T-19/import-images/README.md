# T-19 导入图片的加载、就绪和固定版本恢复

2026-10-17，本切片通过；App dev `cbb5818f0ed76cb26fe7934ba098e933045dde8e`，未推送。T-19整项保持未完成，阶段仍为开发。工作区路径检查脚本已在前轮恢复，本轮复跑5项自检及当前工作区审计通过。

两项Widget负例在修改生产代码前复现：Controller已收到两份文件，但卡片的file仍为空；图片下载期间未显示加载状态。原因是网格在延迟构建回调中读取文件，外层Obx未订阅这些读取。原AssetMedia外补局部Obx，并由原Controller按resourceId统一文件与加载状态。重复取图共用原下载，同作用域刷新沿原捕获作用域接收结果；失败结束加载，可主动刷新重试。账号/环境/后台变化仍由原DramaAssetService和ResourceService隔离。

| 检查 | 实际结果与范围 |
|---|---|
| 自动检查 | 5项新增回归、33项素材清单/导入专项、1235项全套App通过，0失败/跳过；完整analyze及5个Dart文件格式通过 |
| 下载状态 | 实际页面先显示加载动画；两个文件交付后，不选择素材也自动显示图片；未选择时确认仍禁用 |
| 失败与刷新 | Widget验证下载失败结束加载并显示不可读提示，刷新后可恢复；同作用域刷新不重复提交取图，不丢弃原下载；旧账号文件不回填新账号 |
| Android/iOS | 各1条完整原生方法通过，各6张系统截图，使用真实路由、Dio回环HTTP、本机文件及公共GetStorage；账号及服务端协议受控 |
| 固定版本 | 通过实际页面选择历史312，随后受控服务端将来源应用图改成315；导入仍传312，保留源resourceId、成功时间和截止，不复制媒体或续期 |
| 未知回执 | 服务端已受理首个请求后返回503，页面保留原请求；点击“继续原操作”后以同键同正文恢复，只产生1条引用并返回原作品/集 |
| 写入边界 | 每端2个导入POST（同一请求首次与恢复）、2个资源签名POST，实际图片下载2次；没有图片生成、图片应用、计费或其他业务写入 |
| 图片核对 | 12张系统图已总览，Android就绪图和iOS历史选择图详检；系统PID与截图握手已核对。随包图片作为受控内容，不代验真实图像生成或不同版本的画面质量 |
| 环境保护 | Android19份、iOS42份既有视频逐文件摘要及权限保持，亦与前轮T-16相册摘要一致；未卸载App、未清相册，自有模拟器和采集端口已停止 |
| 尚待 | 正式OSS/Provider、真实Java后端本轮联验、物理设备与最新Figma视觉验收；后台本轮未改未跑，不将模拟器协议测试算成真实业务验收 |

初检记录保留：第一次全套机器日志的最终success为true，但宿主把非对象JSON行当事件解析而失败，未记录子进程退出码，不计最终通过；修正解析后完整复跑1235项。新增原生测试首轮静态检查发现可空transport及缺少大括号，修正后静态检查与两端构建通过。首次Android前置相册清单未通过路径检查，尚未执行任何业务方法，原始清单当时未保存，不能断言原因；仅补诊断后重新检查通过。首次不足的记录不删除、不冒充业务失败或通过。

范围：仅修改原AssetImportController、AssetImportPage与素材测试；为本切片增加独立原生测试，并在原严格driver中校验报告。保持既有选择、固定引用、原键恢复及公共存储规则；无后台、接口、DDL、依赖、媒体引擎或布局变更。产品/设计/技术/上线文档及186条正式用例正文保持；47项仍7完成/38进行中/2待外部，186条仍9通过/172部分/5未执行。

[检查汇总](checks.json)、[全套测试](app-tests.json)、[专项](material-tests.json)、[负例](reproduction.json)、[原生Android](android/android-asset-import-images-result.json)、[原生iOS](ios/ios-asset-import-images-result.json)、[源码摘要](source.json)、[截图清单](screenshot-inventory.json)、[视觉检查](visual-review.json)、[清理](cleanup-recheck.json)、[路径门禁](guard-result.json)。

[Android总览](android-contact.png)、[iOS总览](ios-contact.png)。日志以gzip无损压缩，公开日志去除凭证/认证字段；原始日志与初始工作区状态仅存本机`originals/`。运行`python3 verify.py`只读复核结果、摘要及范围，不启动设备。[日志清单](log-archives.json)、[公有清单](manifest.json)、[复核结果](verify-result.json)。

复现入口：App中`flutter test --no-pub test/assets/material_list_test.dart`。原生入口为`integration_test/asset_import_reactivity_test.dart`，沿既有`test_driver/catdrama_business_driver.dart`，切片为`asset-import-images`。`run_devices.py`只面向登记的自有Android/iOS模拟器，先保护相册与权限；证据目录已存在时拒绝覆盖。真实渠道及真机前置不足时继续记录未完成。
