# Java 模块 04：工猫回调路由、原 ID 查单与可观测性

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B009`、`T-B011`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

提供平台回调入口、Inbox、App 路由、原 requestId 查单、退票确认、定时对账、死信和监控。回调只作为主动查询触发器，不直接把资金置成功/失败/退票。禁止扫所有 App schema 猜归属或默认路由到某 App。

## 2. Controller / Service / Mapper / Entity 清单

- Controller：`callback/gongmall/GongmallCallbackController`，无登录，不信任 `X-App-Code`。
- Service：`GongmallCallbackApplicationService`、`InviteWithdrawalReconcileService`、`InviteWithdrawalStateTransitionService`、`InviteReconcileScheduler`、`InviteOutboxWorker`。
- Entity/Repository：platform `GongmallRouteBinding/CallbackInbox/SensitiveViewFailure`；App `InviteProviderEvent/OutboxTask/Withdrawal/Event/Account/Ledger`。
- Gateway：复用 `GongmallWithdrawalGateway.queryByOriginalRequestId`。

## 3. 接口合同

| 方法与路径 | 路由键 | 处理 | 鉴权/限制 |
|------------|--------|------|-----------|
| `POST /api/callbacks/gongmall/contracts` | state/session/合同流程标识 | 写 Inbox，触发合同主动查询 | 无 JWT；content-type/body 大小/频率/可用验签/IP 校验 |
| `POST /api/callbacks/gongmall/withdrawals` | requestId | 写 Inbox，用原 ID 查单 | 同上 |
| `POST /api/callbacks/gongmall/refunds` | requestId/工猫流水 | 写 Inbox，触发退票确认 | 同上 |

解析成功后快速 ACK；重复 callback key 幂等 ACK。原始 body 默认不持久化，只存字段白名单和 SHA-256 digest；如合规必需，加密且短保留。

这些回调不供 App/Admin 直接调用。查询结果经 [Flutter 提现记录与结果](../../03-前端/开发计划/04-invite-withdrawal-results-web.md) 和 [Admin 提现管理](./admin/02-admin-withdrawal-security.md) 的只读 API 展示，不由页面解析工猫报文。

## 4. 数据表与迁移

数据库改动：有，使用模块 00 的 platform/App 迁移。

- `platform.gongmall_route_bindings`：`(route_type,external_key)` 唯一，显式 App Code/业务 ID。
- `platform.gongmall_callback_inbox`：`event_key` 唯一，类型、digest、路由结果、状态、次数和时间。
- `invite_provider_events`：provider event 唯一，作为查单/回调/退票的 App 内幂等边界。
- `invite_outbox_tasks`：租约、尝试、下次执行、最后安全错误码，payload 只存 ID/非敏感摘要。

## 5. 业务规则与状态流转

1. Callback Controller 在 platform schema 写 Inbox，根据路由表找 App；未找到则隔离、告警、等待人工处理。
2. 显式设置 AppContext 进业务 schema，`finally` 清理；不得在第一次业务查库后才设 App。
3. 所有结果都用提现单已持久化的原 requestId 查单；工猫查询 10→`PROCESSING`、20→`SUCCEEDED`、30→`FAILED`，未知→`RECONCILING`+告警。
4. 回调、定时、Admin 主动对账都创建同类查单任务，最终调同一 `applyProviderResult(expectedVersion,eventKey)`。
5. `SUCCEEDED -> RETURNED` 只在退票查询/确认后转移，返还账本与余额一次。

## 6. 异常处理与日志要求

- HTTP 超时/5xx/无法解析/未知状态均保持非终态并指数退避，不解冻。
- Worker 使用租约/CAS，崩溃可再抢占；submit 任务重试前先查单，不盲目重提。
- 日志使用 appCode、requestId、withdrawalNo、eventKey、traceId 和安全错误码，不记 callback 明文/密钥/卡。

## 7. 依赖前置

- T-B006 查单 Gateway、T-B008 稳定 requestId/状态机/outbox。
- Admin 主动对账见 [05-invite-admin-security.md](./05-invite-admin-security.md)。

## 8. 建议实现步骤

1. 先写 callback 路由、未知路由、重复、乱序、查单/回调并发测试。
2. 实现 platform Inbox/路由 Controller 和快速 ACK。
3. 实现查单 Worker、统一迁移服务和退票返还。
4. 实现多 App 公平定时扫描、租约、退避、死信和人工处置入口。
5. 补指标、告警、运维查询和安全日志。

## 9. 详细编码任务清单

- [x] `T-B009-01` 完成三类回调、Inbox、路由和重复 ACK。
- [x] `T-B009-02` 完成原 ID 查单、统一终态迁移和退票返还。
- [ ] `T-B011-01` 完成定时扫描、租约、退避、死信和多 App 公平调度。
- [x] `T-B011-02` 完成指标、告警、积压/长时间非终态处置说明。

## 10. 测试要求

- 单元：provider 状态映射、退避、合法/非法迁移、退票幂等。
- 集成：重复回调、回调与查单并发、未知 App 不兜底、AppContext 清理、Worker 崩溃再抢占。
- 契约：content-type/body 大小/频率/签名可用性边界和快速 ACK。

## 11. 验收标准

1. 任何回调都不直接改最终资金状态，最终结果必须经查单确认。
2. 无路由回调隔离并告警，不进默认 App/遍历 schema。
3. 重复/并发事件的资金动作只执行一次，退票只返还一次。
4. 提交未知率、状态停留、查单次数、Inbox/outbox 积压和死信可观测。

## 12. 编码注意事项

回调 Controller 不触发长事务/外部查询。定时任务按 App Code 逐个设置与清理上下文，禁止跨 App 共用当前 schema 连接。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
