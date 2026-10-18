# T-43 Android12 真机主流程复检

2026-10-18，vivo V1981A / Android12 / API31，设备 `e2b8595a`。最终同一作品的完整 App 方法、严格 driver 和本机 Java/PG 方法各1条通过，24张系统状态图已核对。三入口全矩阵及双端模拟器旧证据独立保留；本次只补小说TXT＋AI拆分的1集正常路径。

前端 dev `f399154`，含先行原生修复 `a0041e9`；后端仅测试 dev `0efa2fdb`。均未推送、部署。T-43整项仍未完成，47项7完成/38进行中/2待外部及正式186条9通过/172部分/5未执行保持。

## 实际验证范围

手机通过真实系统选择器导入自建UTF-8 BOM/CRLF TXT，编辑故事和分集后创建唯一作品，保存制作设置并按最终稿分析。逐按钮确认图片报价，生成角色、场景图片，核对作品名称分类、个人图片历史和应用影响范围；随后确认视频报价，首次视频自动应用，核对当前视频历史。

作品进入剪辑前实际下载固定版本、校验原件。进入后没有自动获取字幕；用户点击后手机生成真实16kHz单声道WAV，沿公共私有直传交付本机后台字幕任务，只提交识别输入。受控ASR返回后在手机校对，实际烧录文字、字幕并合成H264/AAC成片，先预览再保存相册。两项成长各领取一次，账务由本机真实服务和数据库核对。

真实运行的是 Android 页面、Media3、Hive、HTTP/Servlet、JWT、资源对象、积分账务及本机随机测试schema。AI、ASR、OSS为受控边界；样片是自建纯色和440Hz音调，字幕为受控时间戳，不能证明真实语音识别或模型内容质量。未执行真实SIM认证、商店或购买测试。

## 两个运行问题与修复

| 问题 | 证据 | 改动及结果 |
|---|---|---|
| T07-DURATION-01：已下载10秒MP4被API31误读为10023ms，准备页拒绝 | [同文件修前](metadata-before/android-device-result.json)、[修后](metadata-after/android-device-result.json)、[BMFF时钟](bmff-timing-diagnosis.json) | Android探测使用BMFF movie呈现时钟，原AAC track保留1024采样补偿；不改文件、摘要、帧率或下载校验阈值。18项Kotlin边界、23插件和28下载准备测试通过，同一原件前后原生检测及最终真机主流程通过。 |
| T33-UPLOAD-TIME-01：旧公共上传票据被按设备时区判断过期 | [既有Provider依据及检查](upload-time-checks.json)、[失败03](attempts/03-subtitle-ticket-time/attempt-result.json) | 已核实阿里云旧LocalDateTime使用Asia/Shanghai，仅该票据按此解析；显式Z/偏移保持原瞬间，过期和无效值继续拒绝。8项时间测试、86上传/字幕专项及1269全套通过。测试端时钟对齐既有Provider，字幕共享夹具改用显式UTC，不改公共后端运行代码或接口。 |

其他公共时间格式不在此次修改范围。非有效BMFF呈现时钟仍沿既有轨道探测兜底，SHA/规格校验与不统一预转码的规则保持。客户端改动仅原生探测及票据模型、上传校验；FFmpeg仅在电脑上独立检测媒体。

## 执行记录

| 轮次 | 实际结果 | 处理 |
|---|---|---|
| [01](attempts/01-background-picker/) | 失败：App进入系统TXT选择器后，后台观察服务暂不可读 | 保留失败和原退出码；先交接待选状态，读取不到App观察端时继续已知的系统选择动作。只选择自建的精确文件名。 |
| [02](attempts/02-presentation-duration/) | 失败：10023ms与原版本10000ms不符 | 固定文件摘要，先只读对照实际原生探测，再修复呈现时长。CLI探测虽退出0但无报告，未计为通过，见[诊断边界](diagnostic-boundaries.json)。 |
| [03](attempts/03-subtitle-ticket-time/) | 失败：手机已提取音频，但上传准备未完成，未提交ASR | 对齐既有Provider的票据时钟并修复客户端时区读取。错误测试路径的加载失败及旧字幕夹具35项失败另行保留，修正后86项和1269项全部通过。 |
| [04](attempts/04-review-button-wait/) | 失败：上传和ASR已完成，校对按钮点击早于预览/工具收尾 | 仅收紧测试等待条件，等真实canEdit、原生预览和启用的TextButton，不改业务按钮条件或旧断言。 |
| [最终](outcome.json) | 通过：App/严格driver1条、本机后台1条；24系统图 | 从新建测试作品完整复跑至相册和成长；没有改写旧失败退出码，未把不同作品拼接为成功路径。 |

每次失败使用独立本机schema，结束后剩余0并停止自有PG；失败包核对摘要后移除并释放设备锁，再开始下一次独立测试。未在处理中重报同一用户任务，最终ASR只提交一次。

## 媒体和账务独立核验

- [实际MP4](android/android-same-project.mp4)：728069字节，1280×720、24fps、10秒、H264＋AAC，完整解码通过。
- [真实手机混音](android/android-actual-mix.wav)：PCM16、16kHz、单声道、160000帧；440Hz音调在混音和成片中均保留。
- [实际1秒编码帧](android/frame-1.png)含手写“同一作品联测”和校对“本机校对：天亮了”；0.25/1/2秒独立像素窗口核对字幕时段。
- [系统相册副本](android/android-system-album.mp4)通过精确自建文件名及owner_package定位，字节与本机成片一致；SHA为`cdd65f87f91c63c9edcf35b1c0640e59ee70d2a85ba763f563da2c4fedb8565f`。
- 隔离账户初始10000为测试准备数据；角色、场景各120，10秒视频1200，生成后8560/冻结0；两项奖励各10，最终8580/冻结0。公共新账号30积分规则没有修改，也没有真实付费。
- [原始报告](android/android-ui-journey-result.json)、[媒体结果](media-result.json)、[精确相册回读](gallery-verification.json)、[后台终态](backend-stop.json)分别留证。剪辑工程和成片没有上传后台。

## 图片与观察

[总览1](overview-1.png)、[总览2](overview-2.png)、[总览3](overview-3.png)覆盖24张实际系统状态图；另详看报价、校对、相册成功、余额、成长5张原图和实际1秒编码帧。失败03/04的关键原图也已查看，[查看范围](visual-review.json)。系统TXT选择器可能包含手机其他文件名，XML/截图仅保存在忽略的originals中。

长视频版本编号折行仍作为既有可读性观察保留，未自行改布局。最新Figma通道实际返回未连接，[状态](figma-status.json)；本轮未声称精确视觉对稿通过。

## 测试与复核

App实际执行：`flutter analyze --no-pub`、变更文件格式检查、`flutter test --no-pub --reporter expanded`（1269项），上传/字幕专项86项；既有插件23项、下载/准备28项及实际Kotlin解析18项分别记录，不与全套相加。后端使用本机临时库执行`./gradlew test --offline --no-daemon --console=plain --tests '*CatdramaMobileJourneyIntegrationTests'`；真实媒体构建和运行参数见[构建](build.json)与[驱动](native-command.json)。

`run_vivo.py`只允许显式物理设备、目标App原未安装、桌面前台且无其他PG使用；使用单次安装和官方`--use-existing-app`，每张系统截图核对实际PID。脚本会操作已授权的测试手机，不能当只读检查执行。`verify.py`仅检查本轮证据/源码摘要、既有改动保护、链接和统计，不操作手机、数据库或Git状态。

日志脱敏压缩于`logs/`，原始摘要见[清单](raw-log-digests.json)；私钥、原始会话/VM地址、APK、Hive和原始日志均留在忽略目录。首轮系统文件选择器截图及旧原始JUnit转存到忽略目录，原失败回执不改，路径和摘要见[归档映射](artifact-relocations.json)。闭环读取可运行`python3 verify.py`；`verify_media.py`会在本证据目录重新生成媒体检测结果和抽帧，不修改App或手机。

## 清理与待验

[清理结果](phone-cleanup.json)通过：仅删除本轮精确自建相册副本、自建TXT和摘要匹配的测试包；相册主机副本保留。不枚举私有相册，不清用户App数据。读取权限始终拒绝，原转发两条保持，新增转发/设备锁已恢复，手机回到桌面；自有随机schema剩余0、PG停止。

真实AI/ASR/OSS、iOS真机及更多Android机型、三入口真实模型全矩阵、多镜头/长片性能、磁盘/生命周期和最新Figma仍待。只对既有用例追加部分证据，未调整正式186条正文、预期或原结论；产品/设计/技术文档、当前基线及上线文档保持。公共业务、Catsinger和其他App改动未触碰。

数据库改动：无；仅创建并清理自有本机测试schema，未改DDL/迁移文件或生产数据库。

本轮用量未取得，未额外查询。
