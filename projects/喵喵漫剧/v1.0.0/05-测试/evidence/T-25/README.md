# T-25 批量补图与失败项检测

当前功能已实现，代码仓库dev各单独提交；完整任务的真实渠道、Figma与两端联验仍待补，继续开发T-26。

新增13项后端、14项App；相关100项后端及172项App通过，0失败/跳过。setup/load/teardown的30个隐藏事件与重复截图复检不计方法。analyze无问题，6文件格式检查0变更。详情：[结果](result.json)、[后台](backend-summary.json)、[App](flutter-summary.json)、[逐用例](case-results.json)、[源码提交](source-manifest.json)。

后台为实际Spring/JWT/独占本机PG、原Worker、公共积分与实际PNG解码/入库，模型/OSS为受控边界。App为真实Controller/Widget/沙盒文件与协议HTTP，不是两端或已部署服务。[Gradle原输出](backend-test.log)、[Flutter事件](flutter-test.jsonl)、[静态检查](flutter-analyze.log)、[格式](dart-format.log)。日志只去行尾空白，不改变结果。

父任务按已消费原报价集合核实完整子项及原订单；SUCCEEDED/PARTIAL_FAILED/FAILED有实际子状态依据，未知/保存中/缺项继续原任务。父FREE且不生图或新增收费。叶图片及自动入库复用T-23/T-24，共享去重、手改保护、候选竞态、恢复和并发均有断言。正常受理继续T-22报价接口，无新HTTP/表/队列。

素材页逐页核对真实历史，排除已用、候选、活动/保存中及归档项，历史失败不猜缺图。确认仍用原三件套；原请求使用GenerationQuoteService与唯一DramaJobService，子项沿现有children分页。两个失败项中只选一个重新报价有实际Widget链路；成功与未知项不被加入。超限提示不截项且刷新后保留；归档视图禁止新补图。

[选择页](screenshots/batch-selection-375.png)、[批量确认](screenshots/batch-confirm-375.png)均已查看，使用受控名称、余额、模型名及测试图片；无后期编辑。[图片范围](image-evidence.json)说明默认未归档分支不受后续归档提示影响。当前Figma通道5hl12w7y返回Not connected，不宣称最新对稿或设备验收。

BUG-T25-001为超限提示被刷新清空，已修正并复检。初次PG启动未带测试端口，[环境失败](attempts/backend-port-not-configured.log)保留；仅停止/重启本次自有集群并显式-h 127.0.0.1 -p 56284。原测试误写报价错误码，[断言失败](attempts/backend-quote-error-code-assertion.log)保留，现使用既有枚举。首轮[前端失败](attempts/flutter-before-notice-fix.jsonl)与修复后172项结果分别留证；没有将失败算通过。补丁误插入的语法错误在格式/编译中检出并纠正，最终分析与测试通过。Widget异步必须等UI/KV真实就绪，失败收尾也释放页面/队列。

数据库改动：无结构、迁移、索引或生产数据修改，仅既有任务正常推进/公共账务Service。独占随机schema清理后0，自有PG已停止；未推送、部署或更改其他App代码，原未跟踪文件保留。
