# T-43 三入口与分集矩阵补验

2026-10-17。App dev `3b06d7b`、后台 dev `00ae91bb`，未推送/部署。保持开发阶段，47项仍7完成/38进行中/2待外部；186条正式用例仍9通过/172部分/5未执行。

本轮12条场景在限定范围内通过：真实本机Servlet/PostgreSQL、公共资源/账务、手机Hive与原生媒体处理贯通。灵感/小说核对并手改梗概及分集方向，现成剧本跳过故事页；核对逐集稿后才创建正式作品，制作参数不重新拆分，最终确认稿原样进入分析。

| 内容入口 | AI拆分（受控返回1集） | 自定义2集 |
|---|---|---|
| 一句灵感 | [双端图](idea-auto-overview.png) | [双端图](idea-custom-overview.png) |
| 小说节选 | [双端图](novel-auto-overview.png) | [双端图](novel-custom-overview.png) |
| 现成剧本 | [双端图](script-auto-overview.png) | [双端图](script-custom-overview.png) |

每端6条完整集成方法，另有1条实际后台矩阵方法。12个独立合成账号各创建1个作品，合计18集剧本和逐集镜头分析。自定义场景只生成、剪辑并导出第1集；第2集保留无视频状态，因此不宣称全剧成片。AI返回1集是外部替身数据，不证明真实AI剧情评估质量。

## 实际检测

- 24次图片、12次视频与12次字幕任务；生成资源后台转存36次，没有重复转存。后台最终SQL检查48行资源、12个唯一作品、18集、最终手改稿、来源/拆分方式及故事确认版本。
- 每账号注入10000测试积分，真实公共账务扣240图片＋1200视频，两个成长奖励各10且重复领取不重复记账，最终8580可用/0冻结。不涉及真实充值。
- 当前时间轴源下载到手机，主动获取字幕使用真实混音；校对后显示“字幕已校对”，手改文字、校对字幕、视频与音轨使用原生引擎导出。未上传剪辑工程或成片到业务接口。
- 12份实际MP4与12份实际WAV摘要一致。独立读取H.264/AAC、1280×720、24fps、约10秒；完整解码、16000Hz单声道16位10秒混音、440Hz音轨及文字/字幕出现时间检查通过。固色画面、合成音和受控字幕不证明模型质量或ASR准确率。
- 12个真实系统相册副本在每次正常退出后核对，并在全部App安装/运行结束后再次复读，大小与SHA-256均等于对应本机成片。保持App安装，不卸载或清相册。[最终相册复读](final-album-check.json)。
- 92张原始系统图已制作6张总览并全部查看；详看4张关键系统图和2张实际成片帧。总览不等于92图逐张或最新Figma验收。[查看范围](visual-review.json)。
- 本轮全工程`flutter analyze`、2个Dart文件格式及提交范围空白检查通过。1205全套Flutter结果沿用前轮生产基线，本轮没有重跑或重复计数。后台1条矩阵方法含全部真实DB/账务断言通过；此前183项回归保留，未声称本轮重跑。[终端结果](terminal-results.json)、[后台JUnit](backend-junit.xml)、[独立媒体](media-result.json)。

![实际成片1秒帧](script-custom/ios/frame-1.png)

## 首轮失败与修正

首轮双端自定义2集已完成相册保存，最终测试仍按`episodes.single`读取项目，报“Too many elements”。这属于扩展测试时残留的单集断言，未观察到对应业务失败；没有据此修改产品实现。

已改为先核对集数，再读取第1集最终稿。保留[失败记录](attempt-01/failure.json)、[iOS断言](attempt-01/ios-assertion.log)、[Android断言](attempt-01/android-assertion.log)和[主动终止的后台JUnit](attempt-01/backend-junit.xml)。原文件全部移到忽略目录`originals/attempt-01/`，以[摘要](attempt-01/raw-artifact-digests.json)追溯。首轮后台通过显式空完成清单让最终断言失败，再正常清理自有schema；随后使用全新随机schema、合成账号和新二进制重跑全部12场景，首轮不计入最终通过数。

## 改动、复跑与边界

App只扩展原`integration_test/support/mobile_backend_journey.dart`、严格driver和两份项目说明；后台只扩展原`CatdramaMobileJourneyIntegrationTests`。外部替身按实际prompt业务类型/上下文区分故事、分集、全剧素材和各集镜头，核对手改内容真正进入后续输入。没有改业务、原生引擎、接口、数据库结构或依赖；手机继续Media3/AVFoundation，宿主FFmpeg/FFprobe只用于测试数据与独立QA。

后台显式启用`CATDRAMA_MOBILE_JOURNEY=true`、`CATDRAMA_MOBILE_MATRIX=true`，指定独立`CATDRAMA_TEST_POSTGRES_URL`及本目录的绝对`CATDRAMA_MOBILE_JOURNEY_EVIDENCE`后，执行`./gradlew test --tests '*CatdramaMobileJourneyIntegrationTests'`。不设置启用环境时，该手机联调测试不运行。只使用本机测试库和随机schema。

等待`server-ready.json`后，按其中桥接端口分别构建`integration_test/catdrama_end_to_end_test.dart`：`CATDRAMA_E2E_SLICE=server-journey`，`CATDRAMA_JOURNEY_BRIDGE_PORT`为该端口，两端分别`CATDRAMA_CAPTURE_PORT=54351/54352`。Android只反向映射本轮API/桥接端口；iOS在启动App前配置自有模拟器添加相册权限。

[串行场景脚本](run_matrix.py)每端使用`--platform`、`--device`、`--binary`显式定位，内部保留`--keep-app-running`，原报告存在时拒绝覆盖；严格driver核对`CATDRAMA_TEST_CASE`、来源、方式、集数和故事步骤。不可直接对本证据目录重跑覆盖；应先保存旧证据，再为新运行准备隔离数据。

两端退出0后先运行`python3 verify_matrix_media.py`、`python3 verify_album.py`，核实全部报告与实际文件后才提交`originals/finish.json`中的12条场景给后台执行最终SQL和资源/账务断言。[图像总览脚本](contact_sheets.py)使用宿主Pillow。只读归档复检为`python3 verify.py`，摘要重建显式加`--write-manifest`。

真实Provider/私有OSS/ASR、SIM/商店、物理设备、最新Figma、TXT完整导入及各工作台逐按钮联验仍待；生成/应用的部分步骤由集成脚本调用实际API服务编排，不冒充所有按钮验收。T-42的3个旧公共夹具失败本轮未重跑。原T43-SUBTITLE-01已经前轮修复，本轮复验；T43-PREVIEW-01按前轮结论是滚动取证裁剪误判。音乐启动图标仍未修复，已有漫剧页面品牌图来源记录在[pending-brand](pending-brand/finding.json)，后续独立处理。

[自审](review.json)、[逐场景范围](case-results.json)、[范围及源冻结](baseline.json)、[代码提交](commits.json)。产品/设计/技术/上线保护文档、正式用例正文及其他后台未提交内容保持。自有schema剩余0、PG及两个自有模拟器已停止，添加相册权限恢复为本轮前空记录，未删相册或卸载App。[清理](cleanup.json)、[最终复检](verification.json)、[发布摘要](manifest.json)。原始日志/旧尝试仅存于Git忽略的`originals/`，发布日志已脱敏并记录[来源摘要](raw-log-provenance.json)。
