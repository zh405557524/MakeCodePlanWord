# Flutter 模块 00：邀请接口合同与路由骨架

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F001`
> 工程：`/Users/soul/code/lxwx/catseller`
> 总体计划：[flutter-dev-plan.md](../flutter-dev-plan.md)
> 技术基线：[flutter-tech.md](../flutter-tech.md)

## 1. 功能定位与边界

本模块先统一邀请、返佣、实名、银行卡和提现的 API、Model、枚举、错误映射与路由，为后续页面提供唯一数据合同。不实现具体视觉，不计算佣金、税费、余额或终态。

- capability 只识别 `legacy/directBankGongmall/disabled`，不按 App Code 写分支。
- 金额一律使用整数分；未知状态不得映射为成功或失败。
- 数据库改动：无。本模块不得持久化身份证、完整卡号、`quoteToken` 或工猫 URL 查询串。

## 2. 入口、路由与页面文件

| 路由 | 处理 |
|------|------|
| `/invite` | 复用 P01 |
| `/invite/materials` | 复用 P02，标题统一为“邀请好友” |
| `/invite/records` | 复用 P03 |
| `/invite/ledgers` | 复用 P04 |
| `/invite/withdrawal` | 复用 P05，替换支付宝表单 |
| `/invite/withdrawal-auth` | 新增 P06 |
| `/invite/withdrawals` | 复用 P07 |
| `/invite/withdrawals/:id` | 新增 P08，只传非敏感提现 ID |
| `/invite/rules` | 复用 P09 入口，改受控 WebView |

修改 `lib/routes/name.dart`、`lib/routes/router.dart`；不重建全局路由，不改登录门禁。

## 3. 依赖前置

- Java `T-B007` 冻结 OpenAPI 路径、分页参数、错误码和 `displayStatus/displayMessage/availableActions` 字段。
- 现有 Dio、JWT、`X-App-Code`、`ApiResponse` 和统一错误封装保持不变。
- 与 Java 模块 [03-invite-user-api-withdrawal.md](../../04-后端/开发计划/03-invite-user-api-withdrawal.md) 对齐。

## 4. 视觉参考与设计稿分析

本模块不产出页面，但 Model 必须覆盖 [figma-design-plan.md](../../01-需求/figma-design-plan.md) 第 4、7 节对 P01～P09、D01～D03 规定的所有主状态与 PRD 补充状态。Figma 中的示例金额、人数、卡号和日期均不能写死。

## 5. 涉及模块与类

- 复用/升级：`lib/apis/invite.dart`、`lib/models/data/invite_*.dart`。
- 新增 data model：`invite_withdrawal_eligibility.dart`、`invite_identity_session.dart`、`invite_bank_account.dart`、`invite_withdrawal_quote.dart`、`invite_withdrawal_detail.dart`。
- 新增 params：`create_identity_session_params.dart`、`create_withdrawal_quote_params.dart`、`create_withdrawal_params.dart`。
- 建议将枚举和安全映射放在邀请 model 内聚文件，不在各 Controller 重复实现。

## 6. API 合同与数据流

下表省略的路径统一以 `/api/invite` 为前缀；默认卡/删除中的 `{id}` 完整路径为 `/api/invite/bank-accounts/{id}`，提现详情为 `/api/invite/withdrawals/{id}`。普通请求沿用现有 JWT 与 `X-App-Code`，禁止把 App Code 放入业务 body。

| 能力 | 方法与路径 | 请求 | 响应真值 |
|------|------------|------|------------|
| 首页/素材 | `GET /api/invite/overview` 、`/materials` | 无 | capability、人数进度、余额、入口 URL；链接/二维码/海报 |
| 邀请/佣金 | `GET /records`、`/earnings/summary`、`/earnings/ledgers` | `memberStatus/status/page/pageSize` | 服务端分页、正向奖励、退款冲正 |
| 资格 | `GET /withdrawal-eligibility` | 无 | 最低额、今日限制、身份/合同/卡、阻断码 |
| 实名 | `POST /identity-sessions` | 姓名、身份证、手机、银行卡、协议版本/同意 | `sessionId/h5Url/expiresAt` |
| 确认 | `POST /identity-sessions/{sessionId}/confirm` | 无 | 合同状态、银行卡结果、下一动作 |
| 银行卡 | `GET /bank-accounts`、`PUT /{id}/default`、`DELETE /{id}` | 无 | 只有脱敏卡资料 |
| 试算 | `POST /withdrawal-quotes` | `bankAccountId,amountCents` | 税费、服务费、预计到账、`quoteToken/expiresAt` |
| 提现 | `POST /withdrawals` | Header `Idempotency-Key`；`bankAccountId,amountCents,quoteToken,agreementConfirmed` | 提现 ID/编号/状态 |
| 记录/详情 | `GET /withdrawals`、`/{id}` | `status/page/pageSize` | 九态、脱敏卡、金额、费用、时间线 |

## 7. 核心类型与本地规则

2026-08-27 实际 OpenAPI 校准：`InviteFoundationIntegrationTests.headersAndPublishedOpenApiAreVerified` 通过。首页模式字段为 `mode`，有效人数为 `effectiveInviteeCount`；资格返回 `bankAccounts/blockingReasons/pendingSessionId/agreementVersion`。实名会话返回 `allowedHosts/returnUrl/contractStatus/ready/bankAccount`，H5 URL 不持久化。提现列表和详情共用 `InviteWithdrawalItem`，新增 `displayStatus/displayMessage/availableActions`（后端生成）、`actualTaxCents/actualServiceFeeCents/actualNetAmountCents`（查单确认前为空）及事件 `timeline(status,message,occurredAt)`；不在客户端推算实际税费。列表筛选全部时省略 status，处理中使用 `IN_PROGRESS`，失败组使用 `UNSUCCESSFUL`，到账使用 `SUCCEEDED`；后端同时接受九个精确状态。分页固定 `page/pageSize`，不在客户端过滤已加载数据。

- `InviteWithdrawalStatus`：`pendingReview/rejected/approved/submitting/processing/reconciling/succeeded/failed/returned`。
- `InviteContractStatus`：`notSynced/pendingSignature/generating/completed`。
- `InviteLedgerKind`：`directReward/membershipRefundReversal`。
- 金额字符串最多两位小数，确定性转分，禁止 `double * 100`。
- 同一提交尝试重复点击或网络超时复用同一 `Idempotency-Key`；工猫 `requestId` 完全由服务端管理。

现有工程参考点：沿用 Catseller `InviteAPI`、平铺 `lib/models/data/` 与 `lib/models/params/`、`lib/pages/invite/{index,controller,view}.dart` 和当前路由方式；其他 App 参考工程只对照风格，不复制其业务字段。

## 8. 建议实现步骤

1. 对现有 model/API 做兼容影响检查，先写 JSON fixture 契约测试。
2. 新增安全枚举解析和未知值兜底，升级七类现有 model。
3. 扩展 `InviteAPI`，保持统一 Dio 封装，不新建第二个客户端。
4. 新增 P06/P08 路由并保留原路由兼容。
5. 补错误码映射、请求取消与敏感数据断言。

## 9. 详细编码任务清单

- [x] `T-F001-01` 完成 API/params/data model 调整。
- [x] `T-F001-02` 完成 capability、九态、合同和账本枚举映射。
- [x] `T-F001-03` 新增 P06/P08 路由和非敏感参数门禁。
- [x] `T-F001-04` 补齐 fixture、未知态、金额与错误码测试。

## 10. 验收标准

1. 所有 API 均经 `InviteAPI`，请求字段与 Java OpenAPI 一致。
2. 未知 capability/提现/合同状态不被误判为可操作或成功。
3. 路由不携带姓名、身份证、卡号和 token。
4. 契约测试覆盖正常、空字段、未知枚举、负金额和错误响应。

## 11. 编码注意事项

保持 GetX、Dio、go_router 现有架构；不引入新依赖。实际编码前以 `/v3/api-docs` 做最后字段校准，如合同发生变化，先回卷技术文档，不在本文档独立发明字段。

## 12. 2026-08-27 编码结果（CHG-0068）

T-F001-02 已实现；T-F001-04 仅完成未知值/金额 fixture，错误响应与 API fixture 未完成。新增 invite_contract_types.dart、invite_money.dart，修改 data/index.dart 和旧 invite_withdrawal 状态映射，保留旧 PAID/PAY_FAILED/APPROVED 文案。定向 6 项与 analyze 通过，App 全量 11 项非邀请失败见编码恢复点。API/params/银行卡 Model/路由仍待后端用户合同，不创建空接口冒充完成。

当前代码、文件范围、验证与下一步统一见 [三端编码恢复点](../../implementation-progress.md)。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
