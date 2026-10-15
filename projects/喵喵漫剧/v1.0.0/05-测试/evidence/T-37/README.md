# T-37 公共账户、流水和订单检测

用户于2026-10-15确认“补齐只读字段（推荐）”。字段、授权与边界见[确认记录](interface-proposal.json)及[结果](result.json)。本任务功能已实现，本机检测通过；整体状态仍为未完成。

| 项目 | 最终证据 |
|---|---|
| App | `app-fields-complete.jsonl`，106项通过（本任务新增34项）；[逐方法](flutter-summary.json) |
| 后端 | `backend-fields-complete.log`，74项通过（相对T-36新增20项）；[逐方法](backend-summary.json) |
| 静态/格式 | `analyze-fields-complete.log`无问题；`format-fields-complete.log`13文件无变化 |
| 代码 | 前端dev `8664450`、后端dev `c97a55cb`；[摘要/哈希](source-manifest.json) |
| 数据库 | [独占PG及清理](database-cleanup.json)，随机schema剩余0，PG停止，无结构/迁移改动 |
| 用例 | [逐用例](case-results.json)，仍部分验证，不把方法数折算为整条验收 |

读侧检查点是`78ef171`/`783cdeb3`。只计最后一次完整执行；旧失败、路径错误、重复及中断运行仅供追溯。XML的gzip为原始字节，XML文本为便于审阅的行尾空白规范版；原字节哈希见后端摘要。analyze日志同样仅规范行尾空白，原字节保存在同名gzip及analyze-raw-sha256.json。

![真实账户与冻结流水](ledger-account.png)
![订单六状态列表](orders-states.png)
![关闭订单原购买快照](order-closed-detail.png)
![320宽错误状态不伪造余额](ledger-error-320.png)

以上4张来自实际Widget和受控HTTP数据，已查看；使用随包中文测试字体。参考已保存P-26/P-27（Figma节点5:8363、5:8487）；当前通道未连接，不作为最新Frame精确还原或用户视觉批准。

后台为真实Spring/JWT、独占PG及公共账务；渠道和App网络为受控替身。目录变化是隔离测试库故障注入，不是修改生产权益。跨设备原单不创建第二笔订单；缺旧快照不猜积分，元数据不冒充渠道参数。真实商店/商户/协议、两端成功/取消/中断/迟到仍需后补；T-40另核历史待付规模。没有推送、部署或真实付费。
