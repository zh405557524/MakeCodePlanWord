# Java 模块 03：用户接口、提现冻结与九态状态机

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B007`、`T-B008`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

提供 Flutter 需要的全部用户端 OpenAPI，并实现资格、银行卡、quote、每日一次、原子冻结、人工审核、`CS+ULID` requestId、outbox 与九态。不在数据库事务内调工猫，不接受客户端姓名/完整卡号/比例。

## 2. Controller / Service / Mapper / Entity 清单

- Controller：升级 `app/growth/invite/controller/InviteController`，保留原路径，只做参数、CurrentUser/AppContext 和 `ApiResponse`。
- Service：`InviteQueryService`、`InviteIdentityApplicationService`、`InviteWithdrawalApplicationService`、`InviteWithdrawalStateMachine`、`InviteOutboxService`。
- Entity/Repository：identity/bank/quote/withdrawal/event/outbox/account/ledger 及条件 Mapper。
- Flutter 对应：[00-invite-contract-routing.md](../../03-前端/开发计划/00-invite-contract-routing.md)、[03-invite-withdrawal-auth.md](../../03-前端/开发计划/03-invite-withdrawal-auth.md)。

## 3. 接口合同

Flutter 对应：[契约与路由](../../03-前端/开发计划/00-invite-contract-routing.md)、[认证与提现申请](../../03-前端/开发计划/03-invite-withdrawal-auth.md)、[提现记录与结果](../../03-前端/开发计划/04-invite-withdrawal-results-web.md)。

所有接口需用户 JWT + 明确 App Code，金额均为整数分。

| 方法与路径 | 请求 | 响应重点 |
|------------|------|----------|
| `GET /api/invite/overview` | 无 | capability、有效人数、比例、两段进度、余额、入口 URL |
| `GET /api/invite/materials` | 无 | 服务端专属链接、二维码/海报资源 |
| `GET /api/invite/records` | `memberStatus,page,pageSize` | 脱敏用户、绑定时间、会员状态 |
| `GET /api/invite/earnings/summary` | 无 | 累计、可提现、冻结、负余额 |
| `GET /api/invite/earnings/ledgers` | `status,page,pageSize` | 直接奖励/退款冲正 |
| `GET /api/invite/withdrawal-eligibility` | 无 | 余额、最低额、今日限制、实名/合同/卡、阻断码 |
| `POST /api/invite/identity-sessions` | 姓名、身份证、手机、银行卡、协议版本/同意 | `sessionId,h5Url,expiresAt` |
| `POST /api/invite/identity-sessions/{sessionId}/confirm` | 无 | 合同状态、卡结果、下一动作 |
| `GET /api/invite/bank-accounts` | 无 | ID、银行、脱敏卡、默认 |
| `PUT /api/invite/bank-accounts/{id}/default` | 无 | 幂等设默认 |
| `DELETE /api/invite/bank-accounts/{id}` | 无 | 软停用；非终态引用拒绝 |
| `POST /api/invite/withdrawal-quotes` | `bankAccountId,amountCents` | 税费、服务费、预计到账、`quoteToken/expiresAt` |
| `POST /api/invite/withdrawals` | Header `Idempotency-Key`；`bankAccountId,amountCents,quoteToken,agreementConfirmed` | 提现 ID/编号/`PENDING_REVIEW` |
| `GET /api/invite/withdrawals` | `status,page,pageSize` | 用户态、脱敏卡、金额 |
| `GET /api/invite/withdrawals/{id}` | ID | 金额、税费/服务费/到账、时间线、安全原因、返还结果 |

稳定错误至少：`INVITE_CAPABILITY_DISABLED`、`INVITE_IDENTITY_REQUIRED`、`INVITE_BANK_INVALID`、`INVITE_NEGATIVE_BALANCE`、`INVITE_MIN_AMOUNT_NOT_MET`、`INVITE_DAILY_LIMIT_REACHED`、`INVITE_QUOTE_EXPIRED`、`INVITE_BALANCE_CHANGED`、`INVITE_WITHDRAWAL_STATE_CONFLICT`、`WITHDRAWAL_IDEMPOTENCY_CONFLICT`、`GONGMALL_RESULT_UNKNOWN`。

## 4. 数据表与迁移

数据库改动：有，使用模块 00 的表与迁移。

- `invite_withdrawal_quotes`：quote token 只存 hash，金额/卡/费用/配置版本/过期/使用时间。
- `invite_withdrawals`：`withdrawal_no`、业务日、金额/税费/服务费/到账、状态/version、requestId、工猫流水/安全原因、审核/查单/终态时间。
- 唯一 `(user_id,business_date)` 实现 Asia/Shanghai 每日成功创建一单；requestId 非空部分唯一。
- `invite_withdrawal_events`、`invite_outbox_tasks`：时间线和可恢复任务幂等。

## 5. 业务规则与状态流转

### 5.1 创建提现

同一本地事务内：校验 capability/负余额/最低额/可用余额、身份/合同 2/3/卡归属、quote 未过期未使用且参数一致、业务日唯一；账户 CAS 增加 frozen，消费 quote，插入 `PENDING_REVIEW` 事件。同幂等键同参数返原单，不同参数返冲突。

最低提现额复用当前 App 的版本化 `minWithdrawCents`，默认 100 分。资格/试算显示当前值；创建前重新读当前版本和门槛，不信任前端缓存或旧 quote 的较低门槛。低于最新门槛拒绝且不冻结、不占每日额度。与配置保存并发时按配置行锁确定生效顺序，成功创建后保存门槛/配置版本快照；提高门槛不追溯已有申请，也不在审核/派发阶段因此拒绝旧单。幂等原单命中应早于新申请门槛校验。

### 5.2 审核通过与派发

- 审核事务重新校验账户/冻结、身份/合同/卡、capability 与 BANK 门禁。
- `PENDING_REVIEW -> APPROVED`，服务端生成并持久化唯一 `CS+ULID` requestId（≤32），同事务写 platform 路由和 outbox。
- 上述跨 schema 原子写仅用于当前同一 PostgreSQL 实例，以限定 schema 表名使用同一连接，不能在事务中途切换路由连接；若未来拆库，则按技术方案使用 `ROUTE_PENDING` 任务两阶段确认，平台路由持久化前禁止派发。
- Worker 在同一本地事务内完成最后一次账户/冻结复核和 `APPROVED -> SUBMITTING` CAS。仍为 `APPROVED` 且能证明从未派发时，余额不足转 `FAILED`、取消未执行任务并释放冻结；进入 `SUBMITTING` 后不可仅凭退款或 Worker 崩溃推断未打款。
- Worker 事务外调工猫：`APPROVED -> SUBMITTING -> PROCESSING/RECONCILING`。网络超时/5xx/无法解析/未知都进 `RECONCILING`，不换 ID 重发。

### 5.3 终态资金动作

- `SUCCEEDED`：原子减 settled 与 frozen，写 `WITHDRAWAL_DEBIT`。
- `REJECTED/FAILED`：只释放 frozen，幂等且不新增奖励。
- `SUCCEEDED -> RETURNED`：写 `WITHDRAWAL_RETURN` 增 settled，不再释放 frozen。

## 6. 异常处理与日志

- 外部 HTTP 不进本地事务；异常 catch 不得假定未打款。
- 状态冲突使用 CAS 返稳定错误，重复事件返幂等成功。
- 日志仅用 withdrawalNo/requestId/traceId 和脱敏摘要，不记姓名/证件/完整卡。

## 7. 依赖前置

- 依赖 T-B002～T-B007 和工猫测试环境。
- Admin 审核合同见 [05-invite-admin-security.md](./05-invite-admin-security.md)；回调/查单收敛见 [04-gongmall-callback-reconcile.md](./04-gongmall-callback-reconcile.md)。

## 8. 建议实现步骤

1. 写状态机所有合法边/非法边、冻结不变量和每日唯一测试。
2. 实现 DTO/VO/OpenAPI 和用户查询。
3. 实现 quote、幂等创建、账户 CAS 冻结与事件。
4. 实现审核复核、requestId、路由/outbox 与派发 Worker。
5. 对接统一终态迁移与资金动作。

## 9. 详细编码任务清单

- [x] `T-B007-01` 完成全部用户 API、DTO/VO、OpenAPI 和稳定错误。
- [x] `T-B007-02` 完成资格、银行卡、quote 和幂等创建。
- [x] `T-B008-01` 完成账户冻结、每日唯一和九态 CAS。
- [x] `T-B008-02` 完成审核复核、`CS+ULID`、平台路由、outbox 和派发。

## 10. 测试要求

- 单元：资格阻断、quote 匹配/过期、九态合法边、requestId 格式。
- 集成：并发两次提现、每日一次、幂等冲突、审核时退款、派发占位前后退款竞态、驳回释放、提交超时。
- 动态最低额：调高/调低、旧页面/旧 quote、新配置与创建并发、原单幂等重试、审核旧单和跨 App 不受影响。
- 契约：每个核心接口正常+至少一个错误码，`/v3/api-docs` 可见。

## 11. 验收标准

1. 并发申请最多成功创建一单，不超冻；负余额禁止新单。
2. 创建请求只有四个安全字段，提现 ID 与工猫 requestId 分离。
3. 超时进 `RECONCILING`，不换 requestId 重发。
4. 审核驳回、明确失败、成功和退票的冻结/账本动作均只执行一次。

## 12. 编码注意事项

编码时对齐 Flutter 契约，不在模块内发明额外字段。账户/状态条件 SQL 放 Mapper，Service 不拼裸 SQL，Controller 不写业务逻辑。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。

## catseller 邀请链接修复记录（2026-08-28）

### 根因与修改范围

`PublicUrlService` 的邀请页目录只支持 catsinger，导致 catseller 在构造公网 URL 前直接返回空字符串。此次仅在邀请路径解析中增加 `catseller → /miaomiao-commerce`，注册页与下载页共用该映射；不修改 Flutter 页面、Admin 配置、接口或响应字段。

- 注册路径：`/miaomiao-commerce/invite/register.html?appCode=catseller&inviteCode=<邀请码>`。
- 下载路径：`/miaomiao-commerce/invite/download.html?appCode=catseller&inviteCode=<邀请码>`；无邀请码时继续省略下载 URL 的 `inviteCode` 参数。
- 继续沿用公网域名配置、当前请求域名回退、URL 编码及邀请码去空白逻辑，不硬编码环境域名。
- `LEGACY` 模式返回生成的下载页；`DIRECT_BANK_GONGMALL` 模式继续原样返回后台 `landingDownloadUrl`，包括空值，不自动补地址或启用资金。
- catsinger 的邀请与歌曲分享链接保持原样；catseller 歌曲分享仍返回空链接，其他未开放 App 的邀请链接仍为空。

代码范围为 `framework/util/PublicUrlService.java`、现有 `BackendWorkflowIntegrationTests.java` 和新增的 `framework/util/PublicUrlServiceTests.java`。保留既有未提交改动。

### 数据库改动

无。不修改迁移、业务数据、后台配置或资金开关。直邀模式测试仅在 H2 测试库创建临时配置，并在 `finally` 中清理。

### 验证结果

| 检查 | 结果 |
|------|------|
| 修复前完整 `./gradlew test --console=plain` | 1300 项通过，3 项跳过，0 失败 |
| 新增回归用例在旧实现运行 | 18 项中 8 项失败，均复现 catseller 注册链接为空；10 项原有行为保护用例通过 |
| 修复后定向测试 | 18 项全部通过 |
| 修复后完整 `./gradlew test --console=plain` | 1316 项通过，3 项既有跳过，0 失败 |
| `git diff --check` | 通过 |

集成测试携带 `X-App-Code: catseller` 与测试登录态，覆盖 `GET /api/invite/overview` 的 `inviteLink`、`GET /api/invite/materials` 的 `inviteLink / landingDownloadUrl`、`GET /api/invite/getInviteUrl` 的 `visitUrl / downloadUrl`。普通与直邀模式均验证相同邀请码的注册链接；直邀同时验证已配置和空下载地址。工具单测补充公网域名规范化、请求域名回退、URL 编码、空邀请码及其他 App / 歌曲分享边界。

### 部署后验收

本次未部署，未验证线上手机效果。后续在明确授权部署后，手机刷新邀请页，确认链接出现、复制出的 URL 带正确的 `appCode / inviteCode`，并扫码核对海报二维码指向同一注册链接、落地页可访问。原有邀请提现主流程继续保持 `waiting_review`，不推进真实 H5、工猫、银行或设备验收状态。
