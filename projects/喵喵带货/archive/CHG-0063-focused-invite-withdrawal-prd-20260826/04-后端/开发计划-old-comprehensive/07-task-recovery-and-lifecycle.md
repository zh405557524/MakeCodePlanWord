# Java 模块开发文档：任务恢复与作品生命周期

> 版本：`v1.0`｜状态：已完成｜任务：`T-B011 任务进度与失败恢复`、`T-B012 作品隐藏与删除`

## 1. 功能定位与边界

统一描述、形象、内容、分镜图片和视频任务的租约、幂等、回调/轮询竞争、失败恢复，并实现完成作品 7 天隐藏、30 天删除。首版不发通知，不提供任务取消。

## 2. 类清单

Service/Task：`SellerGenerationExecutionScheduler`、`SellerGenerationExecutionService`、`SellerWorkflowEngine`、`SellerWorkflowStepService`、`SellerTaskEventLogService`、`SellerGenerationCompensationService`、`CatsellerTaskRecoveryService`、`CatsellerLifecycleService`、`CatsellerResourceCleanupService`。Mapper/Entity：GenerationTasks、GenerationTaskSteps、GenerationTaskEvents、GenerationCompensations、Works、Videos、资源引用。无新增用户取消 Controller；进度通过已有详情/任务查询返回。

## 3. 接口契约

对应 Flutter：`05-works-and-state-routing.md`、`06-content-and-script.md`、`07-video-and-watermark.md`。

- 不新增取消接口、通知接口或 WebSocket。
- 作品聚合详情统一返回 taskType、status、currentStep、可空 progress、errorCode/message、failedStage、resumeState、actions、nextPollAfterMs。
- 现有重试接口只在失败且 actions 允许时受理；相同幂等键返回原任务。
- 隐藏/删除作品详情返回 `RESOURCE_HIDDEN`/`RESOURCE_DELETED` 稳定语义。

## 4. 数据表与迁移

- `catseller_generation_tasks`：状态、currentStep、progress、leaseUntil、retryCount、nextRunAt、providerTaskId、幂等键/摘要、错误、时间。
- `catseller_generation_task_steps`：步骤状态 `PENDING/RUNNING/PAUSED/SUCCESS/FAILED/SKIPPED`、顺序、重试、请求/结果摘要和起止时间。
- `catseller_generation_task_events`：任务与步骤事件；`catseller_generation_compensations`：积分、资源和作品状态的幂等补偿。
- `catseller_works`：lastUsedAt、hiddenAt、deleteAt、状态、failedStage、resumeState。
- 资源/视频表保存有效期和清理状态；清理操作具备幂等标识。
- 索引：可领取任务、过期租约、下一次执行、到期隐藏/删除；活动任务部分唯一索引。

## 5. 业务规则与状态流转

- Worker 用租约领取任务，状态 CAS；进程重启后仅回收过期租约。
- 执行结构参考 SongWorkflow：调度器显式设置 AppContext，执行器扫描可运行/暂停任务，Pipeline 创建上下文，Engine 顺序推进 Step。
- 已成功/跳过步骤不重复执行；`PAUSED` 步骤重新检查 Provider/审核；长时间 `RUNNING` 的外部调用先对账，不能直接重提。
- Provider 回调和轮询都写同一任务状态机；先成功终态后忽略晚到失败，终态不可逆。
- 失败保存已成功内容和最小恢复入口；重试新建任务或按明确规则续跑，不修改旧失败记录。
- 运行中不可取消、删除、隐藏或清理。
- 完成作品以最后使用/完成时间计算 7 天隐藏、30 天删除；后台配置可调整，但历史执行有审计。
- 隐藏从默认列表消失；删除清理业务引用和资源，状态不可恢复。首版不发到期通知。
- 调度器遍历 App 时显式设置 `AppContext=catseller` 并 finally 清理。

## 6. 异常与日志

租约抢占失败正常跳过；补偿/清理失败记录 retryCount/nextRunAt 和脱敏原因。每次终态、重试、隐藏、删除记录 traceId/内部 ID/旧新状态。不得因客户端断网写失败。

## 7. 依赖前置

依赖所有生成任务、作品聚合、资源服务、Provider 状态查询和配置。QA 需能缩短保留期在测试环境验证。

## 8. 建议实现步骤

1. 参考 SongWorkflow 建立定义、步骤实例、执行器、事件日志和补偿骨架。
2. 完成统一任务租约和状态 CAS 工具。
3. 统一 PAUSED 恢复、回调/轮询/幂等和终态保护。
4. 实现失败阶段、resumeState 和 actions 计算。
5. 实现隐藏/删除调度与资源清理补偿。
6. 完成进程重启、竞争、晚到回调和跨 App 定时任务测试。

## 9. 编码任务

| 任务 | 名称 | 状态 | 退出条件 |
|------|------|------|----------|
| T-B011-01 | 任务租约/幂等 | done | 重启、重复请求和竞争不重复执行 |
| T-B011-02 | 失败恢复 | done | 保留成功内容并返回最小恢复动作 |
| T-B011-03 | 进度契约 | done | 真实进度/可空进度和轮询间隔稳定 |
| T-B012-01 | 7 天隐藏 | done | 到期从列表隐藏，运行中跳过 |
| T-B012-02 | 30 天删除 | done | 幂等清理、失败补偿、不可恢复 |

## 10. 测试要求

单元：租约、CAS、终态、actions、日期边界。集成：进程重启、回调/轮询竞争、重复重试、运行中清理跳过、7/30 到期、资源失败补偿、跨 App 调度。Flutter 契约：断网不假失败且重进恢复。

## 11. 验收标准

任务开始后无取消；服务重启可恢复；重复请求/回调不重复扣费或生成；失败入口准确；7 天隐藏、30 天删除生效；不发送通知；其他 App 不受调度影响。

## 12. 编码注意事项

不要 blocking sleep；不要依赖内存 Timer 保存任务；不要把 Provider 状态直接当作品状态；不要在运行中清理；不要新增通知链路；不要让 catseller 直接读写 catsinger 的工作流表。

## 13. 实现结果

已完成任务租约、状态比较更新、暂停/恢复、事件日志、幂等补偿和 Provider 对账；已完成作品第 7 天隐藏、第 30 天删除及运行任务跳过清理，不提供取消或通知接口。

恢复点：前后端联调和测试环境定时任务验收。
