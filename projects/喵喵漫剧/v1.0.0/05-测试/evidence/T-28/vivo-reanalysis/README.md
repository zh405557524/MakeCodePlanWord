# T-28 Android真机重新分析与原镜头恢复

2026-10-18，vivo V1981A / Android12 / API31。前端dev `1ccd0b9`仅更新README，后台dev `db1f5e19`只扩展既有测试入口的独立目录/单Android开关；均已提交未推送。生产实现、App源码、原生引擎、业务接口、迁移及依赖保持。

## 同一作品的实际结果

沿既有完整旅程先取得同一作品的两张图片和一个有声视频，下载到手机，制作文字和主动字幕校对、本机导出并保存相册。前半段沿既有Service/API及实际页面准备；重新分析在实际本集剧本页输入、保存、核对、确认，包含取消后重开同一候选和找回原镜头确认框。TextField输入不等于系统输入法验收。

| 操作 | 新增/保留/移出 | 数据核对 |
|---|---|---|
| 开头插入钟声 | 1/1/0 | 原镜头及视频保持，新片头无旧视频；取消后重开同候选，没有另一次分析 |
| 改写原剧情 | 1/1/1 | 改写段新增，原镜头/视频留在移出历史 |
| 还原原文 | 1/1/1 | 不自动借回旧视频；明确找回后恢复同shotId/videoVersionId |
| 纯重排 | 0/2/0 | 两个稳定镜头ID保持，只调整制作列表顺序 |

四次操作逐次核对完整Hive序列化快照及撤销/重做序列，均与原快照相同；原成片SHA保持，再经有效作品入口打开同一工程，原文字和已校对字幕仍可预览。[实际手机报告](android/android-server-journey-result.json)、[独立数据复检](observations-check.json)。

[后端结果](backend-result.json)核对每账号只有最初2图/1视频/1字幕识别调用；四次重新分析复用冻结素材注册4次。文本步骤10次，逐集剧本1次，无新增视频或图片任务。测试资金10000，原两图/视频结算后8560，两项成长领取后8580，冻结0；重新分析与找回不收费。使用真实Servlet/JWT/PostgreSQL、Worker、资源和公共账务，AI/ASR/私有对象边界受控，不代表真实Provider验收。

## 手机、媒体与检测

最终1条完整手机方法和严格driver、1条真实后端旅程通过；30项相关App通过。19项既有后端差异测试在首轮已实际通过，源代码未变，保留并复用，不能把首轮整体说成通过。[最终后端方法](backend-tests.json)、[首轮19项](attempts/01-debug-discovery/backend-tests.json)、[App](focused-tests.json)、[构建来源](build.json)、[源码摘要](source-freeze.json)。App源码没有修改，analyze和1273全套沿此前有效基线，本轮未重复跑。

[19张实时系统图](android/system-captures.json)及3个实际成片帧已查看，4张系统总览和媒体总览留存，另详看改写候选、恢复确认、重排候选原图。[视觉记录](visual-review.json)。[独立媒体核验](media-result.json)确认1280×720、24fps、10秒H.264/AAC完整解码；实际混音为16kHz单声道16bit WAV，440Hz声音和文字/校对字幕时窗保持；相册副本与原MP4逐字节相同。FFmpeg仅在宿主做QA。

首轮未取得手动启动的VM连接，0条手机业务方法执行；没有据此判定产品恢复失败。误写的不存在App测试路径导致检查命令退出1，也已保留。改用现有Flutter二进制启动，vivo更新安装要求确认勾选，按新鲜系统XML处理后继续同一条drive，未重新启动业务。[失败说明](attempts/01-debug-discovery/README.md)。

仅本轮新建loopback临时PG按既有迁移准备；schema已清理、PG/Servlet/Worker/对象桥停止，数据目录保留。相册只查询本次精确名称及owner，核对原字节后只删除这一份测试视频；只移除摘要匹配的自装App，设备锁、桌面及原转发恢复，未读取其他私人相册条目。[相册核对](gallery-verification.json)、[精确清理](album-cleanup.json)、[手机清理](phone-cleanup.json)、[数据库清理](database-cleanup.json)、[PG停止](support-cleanup.json)。

真实AI/ASR/OSS、重复同句/歧义及跨设备的完整真机场景、iOS真机/更多机型和最新Figma仍待；T-28继续进行中。5条正式用例只追加证据，原步骤/预期/状态保持，186条10通过/173部分/3未执行；47项7完成/38进行中/2外部。[正式用例记录](formal-case-updates.json)、[最终结果](result.json)、[只读复检](verify-result.json)。原始凭据、APK、私密启动日志、KV/源码备份及临时签名材料只保留在本机忽略的originals。

数据库改动：无。本轮用量未取得，未额外查询。
