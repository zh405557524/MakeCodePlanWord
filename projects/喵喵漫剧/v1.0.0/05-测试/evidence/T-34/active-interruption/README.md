# T-34 活跃编码被终止后的本机恢复

2026-10-17。App `dev` 提交 `7b7041a`；工作区仍处于开发阶段。补齐双端模拟器“编码尚未结束时实际终止进程”的证据，T-34 整项继续未完成。

本轮只扩展既有 `local_export_test.dart`、`ExportNativeFixture` 和业务驱动；生产业务、原生 Media3/AVFoundation、接口、数据库及依赖均未改。App 未引入 FFmpeg，工作站 FFmpeg 仅做独立媒体检查。

## 实际结果

| 检查 | Android | iOS |
|---|---|---|
| 平台 | 自有 API 37 模拟器 `Catdrama_T17_QA_20261015` | 自有 iPhone 15 Pro Max / iOS 26.4 模拟器 |
| 终止前原生状态 | RUNNING / 39%，425812 字节 staging | RUNNING / 10%，136979 字节 staging |
| 系统操作 | `am force-stop com.lxwx.catdrama`，核对实际 PID 消失 | 核对该模拟器 App Bundle 路径及 PID 后 SIGKILL，确认进程消失 |
| 恢复 | 只读原 Hive、作品租约和源文件；原生操作 UNKNOWN_OPERATION | 同左 |
| 页面 | 先显示中断；900ms 观察期间不自动编码；实际点击重试后才开始 | 同左 |
| 固定身份 | 同一导出 ID，attempt 由 1 到 2；新原生编号，固定输入/工程正文/源摘要不变 | 同左 |
| 当前页等待 | 重试时禁止编辑和离开，保留真实进度弹框 | 同左 |
| 结果 | 严格驱动 1 条完整恢复方法通过 | 严格驱动 1 条完整恢复方法通过 |
| 实际 MP4 | 320×180 / 24fps，H264/AAC，60.033696 秒 | 320×180 / 24fps，H264/AAC，60 秒 |

每端恢复前对活动账本执行真实闲置清理，源文件及非空临时编码文件仍受保护。恢复后首次成功导出事实只有 1 条，任务只有 1 条；本轮没有保存相册、生成/付费或上传成片。

两份 MP4 均完整解码；实际内嵌封面与 PNG 摘要完全相同。文字仅在首片段指定时段出现，字幕跨第一个切点；后续重复片段无重复字层。导入轨起点为 250ms，首段和末尾对应静音保持，原声 50% 与导入轨 100% 的 RMS 比约 0.50；采样频率峰值为夹具的 880Hz。混合画幅保持完整居中黑边。8 张系统截图逐张查看，12 帧及 2 封面按原像素联系图检查。

这些是自建红/绿低分辨率样片、合成音和受控模型能力，不能代替真实模型、ASR、OSS、物理设备或长片性能验收。现有 T-07-COLOR-01 色彩解释观察继续开放；本轮只核对镜头身份、黑边和字层时段，不宣称跨引擎色彩保真。

## 测试及真实终态

- `flutter analyze --no-pub` 通过；3 个 Dart 文件格式复核通过。
- 4 份既有导出/相册单元与 Widget 文件共 64 项通过，0 跳过。本轮没有新增单元方法。
- 双端各 1 条真实原生恢复方法及 1 份 MP4/1 份封面通过。`tearDownAll` 不计业务方法。
- 两端最终 `seed-active` 均退出 1：App 被宿主终止导致驱动断开，这是准备阶段，不计通过；两端 `recover-active` 均退出 0，严格报告与实际文件检查才计通过。
- 宿主强杀保护 18 项自检通过，仅为工具检查，不计业务验收。最终原生测试期间，3 个 Dart 检测文件摘要未改变。
- 1196 项全套 App 为上一轮 `ac70a07b` 基线，本轮没有重跑，不重复计数。

[终态记录](terminal-results.json)、[Android 原日志](android-recover-drive.log)、[iOS 原日志](ios-recover-drive.log)、[逐条范围](case-results.json)、[综合复核](verification.json)。

原始 `.log` / `.jsonl` 按工具输出保留，包括上游进度行及编解码器输出的行尾空白；不为通过空白检查而改写证据。排除这些原始日志后，进度文档、脚本及生成数据通过 `git diff --cached --check`；App 提交的 5 个文件亦通过空白检查。5 份 Python 脚本可编译，私有备份和 `__pycache__` 未纳入提交。

## 重现方法

在 `/Users/soul/code/lxwx/catdrama` 使用现有 Flutter SDK，所有 Flutter 命令带 `--no-pub`。先运行 4 份 `test/editor/local_export*_test.dart` 中本轮记录的文件；精确命令为：

```sh
flutter test --no-pub test/editor/local_export_test.dart test/editor/local_export_widget_test.dart test/editor/local_export_album_test.dart test/editor/local_export_album_widget_test.dart --reporter=json
flutter analyze --no-pub
```

原生目标为 `integration_test/local_export_test.dart`，驱动为 `test_driver/catdrama_business_driver.dart`。必须带 **`--keep-app-running`**，保留安装及沙盒；先用 `CATDRAMA_EXPORT_PHASE=seed-active` 构建/执行，宿主运行 [interrupt_export.py](interrupt_export.py) 核实实时任务、临时文件及进程归属后终止。明确确认原进程消失及 seed 驱动退出后，再构建 `CATDRAMA_EXPORT_PHASE=recover-active`，不可把 seed 包直接当恢复包启动。

恢复驱动设置 `CATDRAMA_TEST_SLICE=export-active`、对应 `CATDRAMA_TEST_PLATFORM` 和证据目录。另起 `test_driver/capture_native.py`，采集数量 3；强杀前系统图另由宿主中断脚本采集。严格驱动核对实际 phase、原任务/固定输入/第 2 次尝试、一次事实和真实媒体 SHA，旧包或缺失报告不能通过。

本轮 Android 访客端口 19171，宿主转发 61201；iOS 端口 19172，[端口记录](ports.json)。重现时重新创建 `adb forward tcp:0 tcp:19171`，将返回端口传给宿主脚本，不能假设宿主等于访客。iOS 先补既有 CocoaPods 路径 `/Users/soul/.gem/ruby/2.6.0/bin`，分别成功执行 seed/recover 的 `flutter build ios --simulator --debug --no-pub --target=integration_test/local_export_test.dart` 和相应两个 dart-define，再执行带相同参数的 `flutter drive --no-build --keep-app-running`。构建摘要见两份 `ios-*-artifact.json`；两相 Dart 入口摘要不同。

[verify_media.py](verify_media.py) 使用现有带 Pillow/numpy 的 Python；[verify.py](verify.py) 核对已提交源、保护文档、任务/用例、路径守卫及无关改动。源文件冻结与提交后检查分别见 [source-freeze.json](source-freeze.json) 和 [verification.json](verification.json)。

## 保留的尝试与范围

初次 analyze 的括号风格提示已在最终冻结前修正。Android 两次准备尝试独立留在 `attempts/`，均不计通过：第一次宿主用墙钟新鲜度判断，模拟器慢约 18 秒导致误拒绝，原任务随后明确成功；改为同次 HTTP 往返及接收后的单调时钟。第二次虽然在 40% 强杀，但驱动未带保留安装参数，随后卸载了沙盒，不能证明恢复；补齐参数后重新准备并在 39% 完成最终链路。原尝试日志、严格报告及原因均保留。

iOS 恢复启动曾等待 Flutter SDK 自身 `git fetch --tags`，期间没有新的 App 导出任务或重新提交。两端联网核对源版本在夹具内缺少 HttpService 而记录离线提示，符合固定本机文件恢复范围；不作为 Java/真实 OSS 查询通过。

五份工作区进度文档的路径检查及 audit 通过，产品/设计/技术等 12 份保护文件与正式 186 条正文保持；47 项仍为 7 完成/38 进行中/2 待外部，正式用例仍 9 通过/172 部分/5 未执行。本轮只补部分证据，不推进测试或上线阶段。自有模拟器和转发清理见 [cleanup.json](cleanup.json)，交付文件摘要见 [delivery-manifest.json](delivery-manifest.json)。
