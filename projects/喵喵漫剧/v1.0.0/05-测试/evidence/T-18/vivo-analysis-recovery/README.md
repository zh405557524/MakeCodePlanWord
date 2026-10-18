# T-18 Android 真机全剧分析与失败集恢复

2026-10-18；vivo V1981A / Android12 / API31。前端 dev `42d5539`、后台 dev `644add2d`，已分别提交未推送。仅新增手机测试、严格driver、隔离后端检测入口及进度记录；业务/原生/接口/迁移/依赖未改。T-18整项继续未完成，真实AI质量和其他平台仍待验。

## 实际链路

同一APK仅安装一次；初始项目由真实Servlet/JWT/PG预置，确认稿为2集、制作参数已保存。手机通过实际作品详情打开制作设置，点击开始整理素材，后台真实领取器和Handler先冻结全剧素材身份，再执行两集镜头分析。文本结果与能力目录受控，第二集故意返回不完整文本以触发正式校验失败。

| 阶段/系统图 | 实际PID | 观察 |
|---|---|---|
| analysis-parent-queued | 3891 | 用户从实际详情进入制作设置并提交一次全剧分析，父任务QUEUED |
| analysis-partial-parent | 3891 | 全剧3身份冻结后创建2个子任务；第一集应用成功，第二集明确失败，父任务PARTIAL_FAILED |
| analysis-failed-episode | 3891 | 返回原详情，第一集保留原分析和镜头，只有第二集有可点击的重试入口 |
| retry-unknown | 3891 | 第二集实际受理一次重试，代理丢弃成功回执并阻断任务GET；本机保留原幂等键，宿主核对APK/PID/KV后实际终止进程 |
| retry-restored | 4540 | 原安全会话和原KV恢复，查询同一个已受理Job，继续处理中，未再次POST |
| analysis-retry-complete | 4540 | 原重试执行成功并清除本机待处理动作，两集均有当前分析；第一集分析ID/版本/镜头/引用保持 |

最终只计 **1条完整手机恢复方法及严格driver**；第一进程预期终止而退出1仅是恢复前置。最终后端实际旅程1条、另10项既有分析测试通过，总11项。原父任务历史仍为PARTIAL_FAILED，第二集独立重试为SUCCEEDED，当前作品两集均已分析；没有改写失败历史来表示恢复成功。

## 独立核对

- [实际请求](network-events.json)：仅1次全剧分析POST、1次失败集POST；后者真实成功后才丢回执。重启阶段只有GET，没有重新创建、拆分、保存或提交生成。
- [六阶段原文件复检](observations-check.json)：未知和重启时原分集动作逐项一致、同key且dispatched=true；成功后原动作清除。会话使用原生安全存储，原token只比较摘要。
- [首次部分失败](initial-result.json)、[原重试成功](retry-result.json)、[后端最终结果](backend-result.json)：3素材身份、5分集绑定、2镜头、2已应用分析；角色和场景跨集复用同一身份。第一集完整episode/analysis/shot/ref数据库快照逐字相同，确认正文与保留期限保持。
- 总任务5条：预置逐集剧本1、全剧父1、首次分集2、失败集重试1。文本调用共5次：预置1、素材1、首次镜头2、重试镜头1；成功第一集没有再次分析。积分30、冻结0、扣费订单0。
- [完整手机报告](android/analysis-recover-result.json)、[两进程结果](outcome.json)、[系统截图](android/system-captures.json)、[图片复核](visual-review.json)、[总览](visual-contact.png)。6张原始系统图均经总览查看，失败单集和最终完成两张另看原图。素材制作0/2与0/3是后续缺图状态，不代表分析仍未完成。

## 验证与边界

41项相关App测试、11项实际后端测试、analyze、格式和Android debug构建通过。[App检查](checks-final.json)、[后端方法](backend-tests.json)、[构建来源](build.json)、[源码摘要](source-freeze.json)。1273项App全套沿`fe63893`有效生产基线，本轮仅新增测试/说明，没有重复跑。准备阶段新测试的括号编译错误和3条格式规范问题已修正并[保留记录](attempts/01-compile-preparation/README.md)，当时没有启动手机或执行后端业务方法；完整手机运行首轮即通过。

真实执行Servlet、JWT、PG、生产路由、公共存储及分析Service/Handler。调度计时器关闭，由检测信号按手机阶段驱动真实数据库领取和Handler；**不计生产定时调度恢复、真实模型文本质量或真实Provider/OSS验收**。未生成图片或视频，未验证iOS真机、更多机型、人工拆分独立关系、最新Figma或完整制作/成片链。3条正式用例仅追加实际证据，保持原步骤、预期和状态；186条仍10通过/173部分/3未执行，47项仍7完成/38进行中/2外部。

新建loopback测试PG执行既有迁移与合成账号，随机schema已清理，PG/Servlet/代理停止，数据目录保留。仅移除本轮自装且摘要一致的测试包，释放自有设备锁与转发，原传输映射及桌面恢复，未访问相册。[手机清理](phone-cleanup.json)、[数据库清理](database-cleanup.json)、[支持进程清理](support-cleanup.json)。六处后端原有改动及12份受保护文档按摘要保持。

原始凭据、APK、KV、日志、源码和文档备份保留在本机忽略的`originals/`；公开日志为脱敏gzip。[正式用例记录](formal-case-updates.json)、[最终结果](result.json)、[只读复检](verify-result.json)。

数据库改动：无。本轮用量未取得，未额外查询。
