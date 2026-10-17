# T-27 未保存候选预览与换版拒绝反馈

2026-10-17，App `dev` 提交 `8288dee2338770b50b0794cd59ad51c795f2d0be`。按已审核T-27、R-15执行，保持开发阶段；整项仍未完成。

## 实现与复现

原代码把候选时间轴交给EditorTimeline，却仍传持久工程的sources。新版尚未提交时，sources没有新版ID，预览会触发空值报错。[原源码](originals/app)、[原回归源码](red-test.dart)、[有效红灯](before-fix.log)保留。新版已经下载，不能靠提前修改工程来绕过这个问题。

- EditorController.displaySources以原工程为基线，仅从候选片段明确绑定的本机媒体/版本/镜头补齐展示。取消预览不写sources、head、历史或导出指纹；添加原镜头的候选同样适用。
- 确认时当前应用已变化，原保存校验会正确拒绝；但恢复旧预览清除了错误提示。[首次完整页面检测](attempts/03-rejection-feedback/test.log)为4通过/1失败。现恢复预览后保留操作失败提示，预览自身的新错误优先。
- 原LocalEditorStore、VideoApplicationService、EditorFileRefs相关持久定义及本机模型保持；接口、数据库、依赖、原生引擎没有改动。本轮没有修改或重跑后端，原后台证据继续保留。

## 已执行检测

| 检查 | 结果 | 证据边界 |
|---|---|---|
| 新增实际页面回归 | 5/5通过 | [日志](page-flow.log)：未保存来源、短版取消、选择性更新/撤销、最终应用变化拒绝、添加原镜头候选 |
| 剪辑相关 | 308通过，0失败/跳过 | [原事件](related.jsonl)，50个隐藏生命周期事件不计业务方法 |
| 全套App | 1174通过，0失败/跳过 | [原事件](full.jsonl)，190个隐藏生命周期事件排除 |
| 静态/格式 | analyze无问题，5文件0格式变化 | [analyze](analyze.log)、[格式](format.log) |
| Android模拟器 | 1个完整原生方法通过，5系统图 | [严格驱动结果](android/android-video-replace-media-result.json)、[日志](android-drive.log) |
| iOS模拟器 | 1个完整原生方法通过，5系统图 | [严格驱动结果](ios/ios-video-replace-media-result.json)、[日志](ios-drive.log) |
| 实际成片独立核对 | 两端完整解码、H.264/AAC、30000/1001 | [Android](android/media-verification.json)、[iOS](ios/media-verification.json)；12.038095秒/12.012秒，均与实际时间轴误差小于60ms |

Widget挂载生产EditorPage并使用真实Hive/私有文件；原生通道与源字节为受控夹具。页面按钮覆盖取消越界选择、预览后取消、分割后只更新一片、一次提交、实际撤销/重做、确认前应用版本变化拒绝。读取与核对不生成、不扣费。

两端模拟器使用真实自建H.264/AAC文件及原生引擎，原视频10秒，选中两个已裁剪片段；新版4.004秒。每段先明确重置全段，再预览、取消，核对旧head、来源表及旧成片仍有效；再次打开后明确保存，一次历史记录、字幕标待核对，真实点击撤销/重做。随后通过现有LocalExportService重新导出，在实际ExportPage预览。导出调用是Service执行，未在本方法中点击导出规格按钮或写相册，不把这部分扩大成完整用户链路验收。

后台清单使用只读协议夹具，每端6次核对、0次写请求；新版使用已完整缓存的真实源文件，不冒充真实OSS下载。输出经宿主实读SHA-256/大小、ffprobe和完整解码核对；0.1/0.75/3.0秒的字幕白色像素为Android `[0,37,0]`、iOS `[0,27,0]`，同时实读合成音RMS验证声音存在。仅证明自建样片的实际声音/字幕烧录时窗，不代表真实ASR、对白完整性或模型质量。宿主FFmpeg只作独立检测，App继续使用既有原生方案。

## 配图与复现

6张Widget图、10张最终系统图已总览：[Widget](widget-contact.jpg)、[Android](android-contact.jpg)、[iOS](ios-contact.jpg)。另详看最终两端换版页面、亚秒范围Widget及两份0.75秒实际成片帧。Widget原生区域为受控空纹理，不能证明真实画面；设备红横/绿竖样片不代表漫剧成片质量。最新Figma连接返回未连接，[记录](figma-connection.json)，本轮未做精确对稿。

在App仓库运行：

```sh
flutter test --no-pub test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart
flutter test --no-pub --reporter json test
flutter analyze --no-pub
```

原生目标沿 `integration_test/video_replace_test.dart`，驱动沿 `test_driver/catdrama_business_driver.dart`，`CATDRAMA_TEST_SLICE=video-replace-media`，平台取 `android`/`ios`，证据目录用 `CATDRAMA_BUSINESS_EVIDENCE_DIR`。`CATDRAMA_CAPTURE_PORT`分别19157/19158，宿主采集 `test_driver/capture_native.py` 预期5图；Android访客19157对应本次宿主50486。

[源冻结](source-freeze.json)覆盖5份代码/检测源；全套通过后仅修正原生检测的Tooltip定位，生产、单元与驱动源码摘要不变；最终两端沿冻结源码执行。最终analyze已重跑。[verify.py](verify.py)核对原始终态、来源摘要、独立媒体、正式186条原定义、受保护文档及无关工作区状态；[复核结果](verification.json)保留当前实际提交号。

## 尝试记录与待办

- `attempts/01-helper-compile`是新测试引用非公开DramaJson的编译错误，改用明确Map解析，不算业务复现。
- `attempts/02-modal-transition`为测试在弹层进入动画完成前点击；改为等待目标实际可点击，保留真实点击与原状态断言。
- `attempts/03-rejection-feedback`保留提示被恢复预览清除的有效失败，现已修复。
- `attempts/04-analyze-style`为两条if括号提示，已修正。
- `attempts/05-native-tooltip`为首次Android方法在撤销前把RawTooltip强转IconButton，严格驱动已拒绝、采集主动停止130；该轮4张图独立留存，不计最终通过。现按IconButton.tooltip定位，仍实际点击并核对revision/完整文档。
- `attempts/06-verification-order`记录宿主复核先于最终analyze结束；等待同一实际进程终态后重检。`07-verifier-contract`记录宿主字段名、FFmpeg时间参数与ADB空行处理修正；均未改App实现或放宽验收阈值。

新观察T-27/T-31-UI-01：范围小于1秒时现有整秒格式会显示00:00，[600ms现状](widget/shorter-range-required.png)已记录，尚未修复。下一轮片段工具需补精确范围展示；本轮不宣称此项通过。

真实Provider/私有OSS、物理设备、最新Figma与完整生成/相册链路仍待。正式186条保持9通过/172部分/5未执行，47项保持7完成/38进行中/2待外部。只更新5份进度文档和本任务证据；产品、设计、技术、当前产品和上线基线保持。没有推送、部署或生产操作。自有Android AVD与iOS模拟器均已停止，未删除设备；本次3条ADB映射已移除，[记录](android-cleanup.json)、[最终运行状态](runtimes-final.json)。
