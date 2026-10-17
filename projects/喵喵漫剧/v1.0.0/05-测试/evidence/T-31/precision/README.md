# T-31 毫秒区间与窄宽显示复检

2026-10-17，App `dev` 提交 `fde44764327c1767ddd646e888566985ec02319f`。T-27/T-31-UI-01已修复；T-31整项仍待真实渠道及物理设备验收，保持开发阶段。

## 修改与依据

已批准的数据契约使用整数毫秒，原界面却用整秒格式，600ms会显示00:00，合法的500ms区间两端甚至显示相同。[旧源码](originals/app)、[原3宽回归](red-test.dart)、[3条有效红灯](before-fix.log)保留。

- AppStrings.editorPreciseTime用于裁剪、换版、音频起点/影响、提音选段、片段时长与编辑播放位置。三位毫秒来自原整数值，滑块显示与返回都使用同一次round；一般列表时长及时间轴刻度仍沿原格式。
- 计时器和输出规格在宽度不足时换行，不裁掉精确数值。扩大回归发现375宽、默认测试字体下右侧溢出1.5px，见[首次相关结果](attempts/01-counter-overflow/related.jsonl)；原导出取消/等待/局部稿断言没有放宽。
- 沿现有组件补齐l10n及显示调用，配套T-27换版和T-46提音；原T-30/T-46用例只更新精确文字并增加实际500ms定位断言。存储、Clip阈值、混音/编码、接口、数据库、路由和依赖均保持，没有修改后端。

## 实际检测

| 层次 | 结果 | 范围 |
|---|---|---|
| 修正前 | 3/3行为失败 | 320/375/430宽，旧界面没有明确毫秒区间；不是编译失败 |
| 新增界面 | 4/4通过 | 三宽分别覆盖裁剪/换版/音频；499ms拒绝、舍入后500ms显示与返回一致 |
| 边界组合 | 23通过 | [日志](boundaries.log)；取消保输入、旧会话/路由和90秒后的提音原断言保留 |
| 相关回归 | 312通过，0失败/跳过 | [事件](related.jsonl)，53个隐藏生命周期事件排除；包含上述23条及溢出的原导出用例 |
| 全套App | 1178通过，0失败/跳过 | [事件](full.jsonl)，193个隐藏事件排除 |
| 静态/格式 | 无问题，11文件0改动 | [analyze](analyze.log)、[格式](format.log)；最后原生测试辅助改动后已重跑静态检查 |
| Android模拟器 | 1个完整原生方法、5系统图通过 | [报告](android/android-timeline-precision-result.json)、[日志](android-drive.log) |
| iOS模拟器 | 1个完整原生方法、5系统图通过 | [报告](ios/ios-timeline-precision-result.json)、[日志](ios-drive.log) |

Widget使用实际组件与明确的滑块回调；1234–1734ms及250–750ms这类精确选择通过回调注入，确认/取消仍真实点击，不把它称为手指精确拖到了某一毫秒。三宽可见范围、500ms保存返回、取消不改原输入均有断言。

原生方法使用真实自建H.264/AAC文件、实际字体/组合预览、Hive和本机音轨。界面展示1234–1734ms后点击取消，整份工程不变；音轨起点显示250ms且取消不改工程。实际本机播放器定位500ms，真实点击分割后保存的首片段为500ms；删除音轨锚点时先取消，再明确改绑并撤销，恢复完整前态。原文件移动后私有音频仍可用，字层/音轨仍进入同一原生计划，持续播放位置实际超过1000ms。

此方法独立于后台；联网版本核对因未注册HttpService记录可见失败并保留固定版本，未用于证明在线核对。字幕样式为自建文字层，非真实ASR；本轮没有重新执行成片导出或相册验收。显示/保存的毫秒值一致不等于编码具有1ms帧精度，视频处理仍沿原设备及源帧率能力。

## 图片与复现

10张Widget图及10张最终系统图已总览：[Widget三宽](widget-contact.jpg)、[Android](android-contact.jpg)、[iOS](ios-contact.jpg)。详看375宽600ms换版、Android裁剪和iOS音轨250ms页面。自建红/蓝视频只用于确定实际本机画面，不代表漫剧模型质量。最新Figma未连接，[记录](figma-connection.json)，本轮未宣称精确对稿。

在App仓库使用工程Flutter：

```sh
flutter test --no-pub test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart
flutter test --no-pub --reporter json test
flutter analyze --no-pub
```

原生目标 `integration_test/timeline_preview_test.dart`，驱动 `test_driver/catdrama_business_driver.dart`，切片 `CATDRAMA_TEST_SLICE=timeline-precision`；证据目录为 `CATDRAMA_BUSINESS_EVIDENCE_DIR`，平台为 `CATDRAMA_TEST_PLATFORM=android`/`ios`。系统采集设置 `CATDRAMA_CAPTURE_PORT=19159`/`19160`，`test_driver/capture_native.py`预期每端5张；Android本次访客19159映射宿主63530。

[源冻结](source-freeze.json)为11份Dart文件。全套完成后仅修正原生测试的工具栏选择；生产、单元及驱动摘要不变。最终两端使用冻结源码。[verify.py](verify.py)核实原始终态、截图、精确数据、存储/引擎等不改边界、186条原定义和无关工作区状态；[结果](verification.json)。

## 失败记录与剩余验收

- `attempts/01-counter-overflow`保存新增毫秒显示后的3条真实溢出失败；已用有界Wrap修复，不以缩小字体、裁掉时间或删除断言掩盖。
- `attempts/02-patch-parse`保存一次补丁匹配错误导致的语法错误；检测主动停止130，不计通过。恢复自己的上一快照后精确替换目标区块，未回退其它已完成修复。
- `attempts/03-native-tool-mode`为首轮Android在选中片段工具栏内寻找裁剪，缺少“全部工具”步骤；驱动拒绝该报告，采集停止130，1张图独立留存。现真实点击工具切换、重新选片，再执行原音量/分割/删除场景，业务断言保留。

原型、产品/设计/技术/当前产品/上线基线保持。正式186条仍为9通过/172部分/5未执行，47项仍7完成/38进行中/2待外部；真实Provider/私有OSS、最新Figma、物理设备及完整制作链仍待。没有推送、部署或生产操作。自有模拟器已停止，未删除设备；[3条本次ADB映射清理](android-cleanup.json)、[最终状态](runtimes-final.json)。
