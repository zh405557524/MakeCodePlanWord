# T-33 字幕候选应用与两端本机合成复检

2026-10-17。修复 T-33-APPLY-01：候选应用等待期间的新声音或校对稿可能被旧识别结果覆盖。App 仅修改 `LocalSubtitleService.apply` 的应用前检查，沿用既有任务、存储、接口及原生引擎；后台没有改动。T-33 整项保持进行中。

## 问题与修复

原实现只在异步可用性查询、命令身份写盘之前核对输入，等待结束后直接用最新 revision 保存旧结果。候选恢复时可以出现新的本机编辑，服务也可能已释放。

应用前再次检查服务/会话、声音指纹和字幕 revision：声音或校对变化时标记 STALE，保留完整最新工程；服务释放后不写工程。同声音下仅新增画面文字仍正常应用字幕并保留文字，不用整个工程 revision 变化误拒绝。原任务编号和幂等键不变，不重复抽音、上传或提交。

四条确定性回归在修复前为三失败、一通过，修复后全通过。正向对照是仅新增画面文字；原有三十条字幕用例继续通过。测试暂停的是已保存、非活动候选恢复中的一次真实可用性查询，没有放开处理中不可关闭弹框的编辑限制。

## 实际结果

| 检测 | 结果与证据 |
|---|---|
| 修复前复现 | 4 条，3 失败/1 对照通过，退出 1；[原日志](before-fix.jsonl)、[摘要](before-fix-summary.json)、[来源说明](before-fix-sources.json) |
| 字幕专项 | 34 条通过，0 失败/跳过；[日志](focused.jsonl) |
| 全套 App | 1189 条通过，0 失败/跳过；[日志](full.jsonl)；不叠加专项重复计数 |
| 静态与格式 | analyze 无问题，5 份 Dart 格式检查 0 改动；[分析](analyze.log)、[格式](format.log) |
| iOS 原生 | 自有 iPhone 15 Pro Max / iOS 26.4 模拟器，1 条完整方法通过；[驱动日志](ios-drive.log)、[严格报告](ios/ios-subtitle-flow-result.json) |
| Android 原生 | 自有 Catdrama_T17_QA_20261015 / API 37 模拟器，1 条完整方法通过；[驱动日志](android-drive.log)、[严格报告](android/android-subtitle-flow-result.json) |
| 实际媒体 | 两端共 2 WAV + 2 MP4，长度/SHA、完整解码、混音及时窗通过；[iOS 独立核对](ios/media-verification.json)、[Android 独立核对](android/media-verification.json) |
| 图像 | 十张系统图及六张成片帧均已查看；[总览](contact-sheet.png)、[逐图观察](visual-review.json) |
| 边界 | 五份编译源码冻结，十二份产品/设计/技术等受保护文件不变，186 条正式用例正文不变、47 项任务保持；[综合复核](verification.json)、[终态退出码](terminal-results.json) |

实际流程检查主动确认、不可关闭等待、丢查询回执后恢复同键同 Job（仅 1 次提交/1 次 PUT）、手工校对后本机保存，以及断开业务请求后直接原生烧录。WAV 均为真实当前混音，16 kHz/单声道/PCM16/4 秒/128044 字节：首片静音，独立音轨从 250ms 开始，第二片原声半音量。成片为 H.264/AAC、320×180，iOS 4.000 秒、Android 4.027211 秒；这是夹具的实际规格，不限制正式模型输出。

校对后的第一句位于全局 500–1250ms，跨镜头第二句位于 1800–3500ms。实际预览停在 750ms；成片 0.25 秒无字幕、0.75 秒有校对文字、2.5 秒有跨镜头字幕。蓝色竖片适配横画布并留黑边。完整解码及字幕窗检查独立于截图，AAC 混音对比显式平均原声道后与 WAV 核对，活动窗 RMS 比值误差小于 5%。[宿主测量说明](host-check-notes.json)保留初次缺 numpy 与默认立体声折叠增益的检查问题，未因此改变 App 或重做媒体。

## 复现

在 App 仓库运行既有检测：

```sh
flutter test test/editor/subtitle_test.dart test/editor/subtitle_task_recovery_test.dart --reporter=json
flutter test test --reporter=json
flutter analyze
dart format --output=none --set-exit-if-changed lib/services/local_subtitles.dart test/editor/subtitle_test.dart test/support/editing_fixture.dart integration_test/local_subtitle_flow_test.dart test_driver/catdrama_business_driver.dart
```

本轮 iOS 使用 `E33B4820-6860-419F-8B17-B6A8FA94EA77`；Android 使用 `emulator-5554`，宿主 53517 转发到访客 19165。将 `TASK_EVIDENCE` 设置为本目录绝对路径，在已启动的自有 QA 模拟器上分别运行截图采集与 drive：

```sh
adb -s emulator-5554 forward tcp:53517 tcp:19165
python3 test_driver/capture_native.py 53517 emulator-5554 android "$TASK_EVIDENCE/android" 5
CATDRAMA_BUSINESS_EVIDENCE_DIR="$TASK_EVIDENCE/android" CATDRAMA_TEST_PLATFORM=android CATDRAMA_TEST_SLICE=subtitle-flow flutter drive --no-pub --driver=test_driver/catdrama_business_driver.dart --target=integration_test/local_subtitle_flow_test.dart -d emulator-5554 --dart-define=CATDRAMA_CAPTURE_PORT=19165
```

截图采集与 drive 需在两个终端同时运行。iOS 不需要 adb 转发；采集端口及 Dart 参数均为 19166，并将平台、设备和产物目录换成 iOS 对应值。未设置截图端口时仍支持 SDK 默认采集，但本轮最终证据使用系统截图，保留原生 Texture。

使用带 Pillow/numpy 的现有 Python 运行 [verify.py](verify.py)，本机运行时为 `/Users/soul/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3`。独立解码使用工作站 FFmpeg/ffprobe；App 仍使用 Media3/AVFoundation。originals 及工作区原状态只作本机备份，不纳入交付；跨文档基线检查需这些本机原始材料。

## 验收边界

ASR/OSS 为显式协议夹具，原生混音、Hive、预览字层和 MP4 为实际实现。日志中故意注入的 queryOffline 和清单不可用是受控场景，不是生产事故，也没有调用真实识别服务。校对文字使用 `tester.enterText`，不记为真实输入法验收。

本轮直接使用既有原生渲染计划生成 MP4，没有走 T-34 成片结果页或 T-35 相册保存；最后一张图仍为时间轴。真实 ASR/OSS、物理设备/系统中断、最新 Figma 和完整结果/相册链路仍待验；本轮 Figma 通道 rq4owed6 返回未连接。

[逐项记录](case-results.json)只补现有用例的部分证据，不改正式 186 条定义与状态（9 通过/172 部分/5 未执行）。47 项仍为 7 完成/38 进行中/2 待外部；[路径检查](guard-check.log)通过，只有五份进度文件回写。后台、API、DDL、依赖及原生媒体引擎保持原状，未推送或部署。

两个自有模拟器与 Android 转发已关闭，系统相册权限和照片未改；[清理记录](cleanup.json)区分实际 drive/capture 退出 0 和已失效的模拟器进程句柄，不推断后者退出码。[汇总](result.json)与[交付文件清单](delivery-manifest.json)记录最终范围。
