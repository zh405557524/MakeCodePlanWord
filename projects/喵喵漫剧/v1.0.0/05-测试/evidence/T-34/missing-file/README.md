# T-34 临时成片清理后的恢复与重导

2026-10-17。修复 T-34-RETRY-01；整项仍在开发中，未推送。只改既有本机导出服务和结果页，后台、接口、数据库、依赖及原生媒体引擎均未改。

旧实现根据 SUCCEEDED 直接结束重试，未核对文件是否仍然可用；结果页也只提供预览重试或禁用的相册按钮。临时成片被清缓存后，无法从这个结果页直接恢复。

现在区分文件失效与播放器暂时失败：文件失效显示真实提示及“重试此版导出”，播放器暂时失败仍只重试预览。已有可用成片直接复用；完整原始 MP4 尚在时只补封装；确实丢失/损坏且用户主动重导时，以原固定输入创建新导出记录，保留旧任务、相册回执及一次成长事实。新手改不被旧快照覆盖，不生成 AI 视频或收费。相册记录补存仍优先，不因文件缺失重做已知系统保存。

## 已验证范围

| 范围 | 结果与证据 |
|---|---|
| 修复前 | 七条回归：六条未通过，一条可用成片对照通过，退出 1；[原日志](before-fix.jsonl)、[方法摘要](before-fix-summary.json)、[来源摘要](before-fix-sources.json) |
| 字段/页面回归 | 新增 4 条服务 + 3 条实际结果页用例；64 条导出/相册专项通过，0 失败/跳过；[日志](focused.jsonl)。三种旧相册状态为受控系统回执，未写系统相册 |
| 全套 App | 1196 条通过，0 失败/跳过；[日志](full.jsonl)，包含上述专项，不重复累计 |
| 静态/格式 | analyze 无问题，8 份 Dart 格式检查 0 改动；[分析](analyze.log)、[格式](format.log) |
| Android | 自有 API 37 模拟器，1 条完整原生方法通过；[严格报告](android/android-export-missing-result.json)、[原日志](android-drive.log) |
| iOS | 自有 iPhone 15 Pro Max / iOS 26.4 模拟器，1 条完整原生方法通过；先完成本轮目标构建，再安装执行；[构建](ios-build.log)、[构建摘要](ios-build-artifact.json)、[严格报告](ios/ios-export-missing-result.json)、[原日志](ios-drive.log) |
| 实际媒体 | 共 4 MP4 + 4 PNG 封面，长度/SHA、完整解码、混音、文字/字幕时窗、横竖适配及内嵌封面原字节核对通过；[Android](android/media-verification.json)、[iOS](ios/media-verification.json) |
| 视觉 | 6 张系统图、16 张实际成片帧和 4 张实际封面已查看；[页面总览](contact-sheet.png)、[媒体总览](media-contact.png)、[逐图记录](visual-review.json) |

原生方法实际执行：导出和 750ms 预览 → 返回剪辑释放成片占用 → 调用真实闲置清理 → 核实原始/封装成片已删除且工程源仍在 → 打开缺失结果页 → 实际点击重导 → 新任务完成并重新预览。清理本身不触发编码；旧任务完整保留，固定输入和当前工程正文不变，两个导出记录仍只有一条首次导出事实。原生本轮只覆盖 NOT_SAVED；FAILED/SAVED 的旧回执保护由 Widget 方法核对。

四个 MP4 均为本机实际 H.264/AAC、320×180/24fps，逻辑时长 4 秒，源规格是自建样片能力，不是正式产品的固定档位。首片静音，独立音轨从 250ms 开始，第二片半音量原声参与混音；静音窗及两个有声窗实际检测通过。同平台重导前后声音 RMS、四个抽帧一致性通过；0.25 秒无字，0.75 秒有画面文字，2.5 秒有跨镜头字幕及绿色竖片黑边，3.75 秒字幕已结束。成片附带实际选定 PNG 封面，未把封面插成视频首帧。

## 仍未验收与独立观察

T-07-COLOR-01 保持待核对：该竖片未标注色域/矩阵/传递函数，宿主解码参考为 RGB(19,117,66)，Android 输出为 (19,117,68)，iOS 输出为 (38,127,75)。差异在首次导出就存在，同平台重导没有改变；[来源与观察](color-observation.json)。本轮不据此判断哪个解码器正确，不宣称跨引擎色彩保真通过；后续需明确无色彩标记源的解释并核对预览/真机。原生引擎没有为本次观察改动。

最新 Figma 通道 rq4owed6 未连接，本轮复用已保存布局和原切图，仅补已有重试动作。活跃编码中系统强杀、物理设备/长片性能、真实模型/OSS、更多规格和最新对稿继续待验。没有本轮真实 ASR、系统相册写入或真实 Provider 制作全链路证据。

初轮工具问题与原日志保留在 [attempts](attempts/) 和 [宿主说明](host-check-notes.json)：自动 pub 解析曾改动锁文件，已恢复 HEAD 原字节并按原镜像 enforce-lockfile，后续使用 --no-pub；回调断言改用 expectSync，保留全部校验；真实 Hive/Skia 的 Widget 导航从 runAsync 发起，按钮仍真实点击。iOS 首轮 CocoaPods 未找到、驱动连到旧 T-33 包，严格报告已拒绝且不计通过；显式使用现有 CocoaPods 路径构建成功后重跑，没有安装工具或修改项目依赖。工作站色彩/任务标题计数检查的修正也分别留证，不改业务测试断言或原始媒体。

## 复现与状态

在 `/Users/soul/code/lxwx/catdrama` 使用现有 SDK：

```sh
flutter test --no-pub test/editor/local_export_test.dart test/editor/local_export_widget_test.dart test/editor/local_export_album_test.dart test/editor/local_export_album_widget_test.dart --reporter=json
flutter test --no-pub test --reporter=json
flutter analyze --no-pub
```

原生目标均为 `integration_test/local_export_test.dart`，`CATDRAMA_EXPORT_PHASE=missing-result`；驱动为 `test_driver/catdrama_business_driver.dart`，设置 `CATDRAMA_TEST_SLICE=export-missing`、对应平台和 `CATDRAMA_BUSINESS_EVIDENCE_DIR`。截图使用现有 `test_driver/capture_native.py`，采集数量 3；在另一个终端与 drive 同时运行。

Android 本轮宿主 49540 转发到访客 19167；Dart 参数为 `--dart-define=CATDRAMA_CAPTURE_PORT=19167`。iOS 采集与 Dart 端口均为 19168；显式补现有 `/Users/soul/.gem/ruby/2.6.0/bin` 到 PATH，先 `flutter build ios --simulator --debug --no-pub --target=integration_test/local_export_test.dart --dart-define=CATDRAMA_EXPORT_PHASE=missing-result --dart-define=CATDRAMA_CAPTURE_PORT=19168`，确认成功后 `flutter drive --no-pub --no-build ...`。严格驱动核对实际阶段、清理/重导不变量及媒体 SHA，不凭 SDK 退出码接受旧包。

使用带 Pillow/numpy 的既有 Python 执行 [verify.py](verify.py)；本机路径为 `/Users/soul/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3`。FFmpeg/ffprobe 仅用于工作站独立检测，App 继续使用 Media3/AVFoundation。本地 originals 和原工作区状态用于保护性复核，不在交付中复制。[综合复核](verification.json)、[终态](terminal-results.json)、[逐项范围](case-results.json)。

五份进度文档的 [路径检查](guard-check.log)通过；十二份产品/设计/技术等受保护文件、正式 186 条正文与 47 个任务 ID 保持。整项仍 7 完成/38 进行中/2 待外部，正式用例仍 9 通过/172 部分/5 未执行，只补部分证据。

两个自有模拟器及 Android 转发已关闭；模拟器进程在 emu kill 成功后退出 134 单独记录，不混同于原生测试退出 0。权限与系统相册没有改动。[清理](cleanup.json)、[汇总](result.json)、[交付清单](delivery-manifest.json)。
