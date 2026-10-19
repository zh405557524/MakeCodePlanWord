# T-18 普通 iOS 与真实定时调度联验

2026-10-19。普通 App 使用默认 main.dart，经实际界面创建“调度联验雨伞店”、核对两集、手改第二集后确认并开始分析。后台启用生产 `@Scheduled DramaJobWorker.poll` 自动领取；没有手动调用 Worker/Handler。实际 DeepSeek Flash 四次 HTTP 200 / stop，剧本、全剧素材、两集镜头共四个任务均成功。

## 已核对结果

- 两集原标题及正文保留；第二集补充“林夏抬头看向车站门外的天空。”，正式作品、父任务、对应子任务及重进页面逐字一致。
- 先冻结五个全剧身份（两角色、两场景、一道具），再分析两集，各五镜头；两集复用同一林夏资产身份。手机显示角色均关联两集。
- 实际终止再启动普通 App，经作品列表重进两集镜头、剧本及素材；仍只有原四任务/四次真实调用，无重复创建和重算。**终止前任务已经全成功，不作为活动任务中断证据。**
- 确认稿和作品截止时间保持；30可用/0冻结/0扣费订单。仅免费文本任务，无新图片、视频、字幕或 OSS 调用。
- 一项真实 Servlet/JWT/PG/自动调度/Provider 后台联验方法通过，0失败/错误/跳过；普通 iOS Debug 模拟器构建成功，四个安装文件摘要与构建一致。

## 范围与剩余验收

视频接入仍按用户决定暂缓。联验使用显式标注“联验参数目录（未接视频）”的能力夹具，以进入制作设置；未提供真实视频能力。模型选择器受控，文本请求经真实公共 AI facade/DeepSeek Provider/HTTPS；公共短信为测试 mock，不扩张登录验收。

重复保护结论限持久任务数和实际模型调用数，本轮未计量全部HTTP POST。原控机记录中的“无重复提交”按此范围理解。

本次 TC-10-01 只覆盖正常分析和成功后重进；未注入第二集失败、未测仅重试失败集，也未在处理中终止 App。控机 `phone_status=blocked`、原用例 `not_assessed`；正式文档仍为部分验证。Android既有受控恢复证据独立保留，不拼成此次普通iOS完整通过。更多样例、已发布模板、物理设备与完整恢复矩阵仍待。47任务保持7整项完成/40未完成；186条仍12通过/171部分/3未执行。

## 构建、源码及失败准备

- 后台生产基线 `bc15958894d51867f32b29524e1e94091019c208`；本次仅新增环境门控联验测试，dev 提交 `eb6bd18f85bddf5262ff990f7165748abb798b2f`，未推送。
- 普通 App 基线 `2dbf40bba4f40c998b3802e9f8ef6eb618f9b64d`，iOS模拟器1.0.0+1。只在自有源码快照构建，未带入其他对话的脏工作；本轮无前端源码修改。
- 三次准备失败如实保留：[准备结果](preparation-results.json)。一次测试编译错误、一次缺limits、一次上下文缺失，均无模型调用/业务任务；没有重交旧未知任务。
- 实际构建参数为 `CATDRAMA_ENV=1`、自有loopback服务56200、默认main.dart；只在测试快照生效。构建摘要与[安装核对](installed-app-check.json)一致。

## 数据库与服务

数据库结构改动：无。仅新建自有loopback PostgreSQL，按既有迁移准备随机schema；结束后活动任务0、自有schema已清理、自有PG停止，数据目录保留。共享8080仍为原PID6313，未重启共享服务、未修改公共配置/正式数据。专用模拟器控机会话已关闭，其他设备/Appium会话保持。

## 证据

| 项目 | 文件 |
|---|---|
| 后台实际方法与断言 | [方法结果](backend-tests.json)、[终态](backend-result.json)、[测试源码](source/CatdramaScheduledAnalysisDeviceTests.java)、[JUnit投影](junit-projection.xml) |
| 实际Provider及任务链 | [四次调用](provider-calls.json)、[任务/输入/输出投影](tasks-projection.json)、[原始Markdown](model-markdown/response-1.md)（同目录2–4为素材及两集镜头） |
| 确认稿及时间 | [分析前](project-before-analysis.json)、[分析后](project-final.json)、[手改稿](final-episode-two.txt) |
| 手机观察 | [普通创建](phone/O00044.png)、[确认手改](phone/O00055.png)、[分析中](phone/O00059.png)、[实际终止](phone/O00061.png)、[作品重进](phone/O00066.png)、[第一集镜头](phone/O00070.png)、[第二集镜头](phone/O00072.png)、[手改原文重进](phone/O00074.png)、[共享角色](phone/O00079.png) |
| 控机范围及清理 | [控机结果](phone/result.json)、[核心结果](ui-core-result.json)、[停止前状态](before-app-stop.json)、[schema清理](database-state.json)、[PG停止](support-state.json) |

PNG/XML原字节保留；观察JSON只将文件路径改为相对路径，任务和JUnit为明确白名单投影。未公开凭证、登录响应、完整控制状态或含敏感项的后端日志。摘要见[来源](artifact-origins.json)与[清单](manifest.json)。没有新增或修改产品、设计、接口、业务、迁移或规则文档。
