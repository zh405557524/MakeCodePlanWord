# Java 模块 01：首单佣金、退款冲正与账户

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B003`、`T-B004`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 2026-09-02 双关系佣金等级增量

- 本节覆盖下方“不发二级佣金”和固定 10%/20%/30% 的旧范围。系统最多结算两层关系；一级、二级关系各有独立 1/2/3 佣金等级和当前 App 三档全局比例，共六档。
- 一级等级按有效直邀首单人数 10/20 门槛只升不降；二级等级只由后台团长活动配置。团长身份不参与结算，二级关系是否结算仍由独立用户资格开关决定。
- 一级转化与二级待结算事件保存关系层级、佣金等级、比例、金额、人数及配置版本快照；配置/等级/开关变化只作用于新付款，历史结算和退款继续用原快照。
- 数据库增量合并到明确未发布的 common V4.5；不新建 V4.6，不执行线上 SQL、业务 DML、回填或删除。

## 1. 功能定位与边界

将现有邀请结算升级为“每名受邀人仅首笔成功会员订单给直接邀请人奖励”，并在退款终态写负向冲正。账户结算余额可为负，后续奖励先抵扣；不发二级/团队佣金，不追回已到账资金。

## 2. Controller / Service / Mapper / Entity 清单

- 事件入口：`core/order/service/PaymentOrderCallbackService`，新增确定的会员退款终态调用点。
- 服务：`InviteCommissionService`、`InviteAccountService`、`InviteQueryService`；现有 `InviteService` 作兼容门面或拆分。
- Entity/Repository：`InviteMemberConversionEntity`、`InviteAccountEntity`、`InviteWalletLedgerEntity` 及对应 Repository/Mapper。
- 查询入口：`InviteController` 的 records、earnings summary、ledgers 兼容升级。

## 3. 接口合同

| 方法与路径 | 请求 | 响应 | 鉴权/错误 |
|------------|------|------|-----------|
| `GET /api/invite/records` | `memberStatus,page,pageSize` | 脱敏用户、绑定时间、会员状态 | 用户 JWT + App Code |
| `GET /api/invite/earnings/summary` | 无 | 累计、已入账、可提现、冻结、负余额提示 | 同上 |
| `GET /api/invite/earnings/ledgers` | `status,page,pageSize` | 直接奖励/退款冲正、有符号金额、订单与比例快照 | 同上 |

内部入口：`settleFirstMembershipCommission(appCode, orderNo, paidAmountCents, paymentEventId)` 和 `reverseMembershipCommission(appCode, orderNo, refundEventNo, refundAmountCents)`；最终方法签名以订单/退款领域对象为准，但必须携带不可变事件键。

Flutter 对应：[邀请首页](../../03-前端/开发计划/01-invite-overview-materials.md)、[邀请记录与佣金明细](../../03-前端/开发计划/02-invite-records-ledgers.md)；Admin 对应：[邀请与佣金查询](./admin/01-admin-invite-commission.md)。

## 4. 数据表与迁移

数据库改动：有，使用 [00-invite-capability-migrations.md](./00-invite-capability-migrations.md) 的 common 迁移。

- `invite_member_conversions`：当前 App 内 `invitee_user_id` 唯一，保存首单、实付分、人数/比例/配置版本快照和正反账本 ID。
- `invite_wallet_ledgers`：append-only、有符号分值，核心事件 `DIRECT_REWARD/REFUND_REVERSAL`，唯一 `(business_mode,business_event_id,event_type)`。
- `invite_accounts`：用户唯一，`settled_balance_cents` 可负，`frozen_cents >= 0`，`version` CAS。
- 本批追加 `common/V4.6__invite_commission_settlement.sql`：转化表保存结算时间、累计退款/冲正；增加会员支付事实、退款 Inbox 与 App 内串行锁。仅隔离测试库验证，部署时由 Flyway 执行；不回填旧资金、不启用模式、不更改历史迁移。

## 5. 业务规则与状态流转

### 5.1 正向结算

1. 会员订单最终支付成功，以 App Code 进正确 schema。
2. 查受邀人唯一直接关系，用转化唯一约束抢占首单资格。
3. 按本笔转化前邀请人有效人数取 10%/20%/30%，保存快照；升级只影响后续订单。奖励分 = `floor(实付分 × 比例基点 / 10000)`；不足 1 分向下取整。
4. 同一事务保存首单事实及配置版本、`settlementDelayDays`（默认 0）、`paidAt`、`expectedSettleAt = paidAt + N 天`。N 为整数天，按北京时间付款成功时间起算；后台按 App 修改，只影响新支付订单，不重排已有佣金。
5. N 大于 0 时保留 PENDING 待结算事实，不增加可提现账户；定时任务按到期索引分页，在当前 App 独立事务内复核、一次性转入账户。N 为 0 时同事务结算。
6. 结算前退款只扣减待结算净额，全额退款 CANCELLED；部分退款到期时在同一事务保留原奖励和已确认退款的正反流水，净额才进入可提现余额。结算后退款按差额扣已结算余额，可形成负数。
7. 结算任务中断可重跑，多实例依靠数据库锁及业务唯一键不重复入账；活动暂停不取消已有应付佣金。首单与退款事件按当前 App 串行化短事务处理，不包含外部网络请求；账户同时保留行锁与版本校验。

### 5.2 退款冲正

- 退款终态按 `refundEventNo` 幂等，写负数账本并减 settled，可变负。
- 支付/退款乱序时先记事实/待重试，不无来源造负账本。
- 部分退款累计应冲正分 = `floor(原奖励分 × 累计退款分 / 原实付分)`，仅补记与已冲正分的差额；全额退款补齐原奖励未冲正部分。内部事件传递可信累计退款快照，不将每条通知金额重复相加；旧快照乱序到达不回退，零差额也保存事实，禁止累计退款超过实付。
- 成功提现后退款不改提现单，只形成负余额。

## 6. 异常处理与日志

- 重复支付/退款不记告警，但记幂等指标；不同参数命中同事件键必须告警。
- 找不到正向账本的退款进入可重试状态，记 appCode/orderNo/refundEventNo/traceId，不记敏感值。
- 账户不变量破坏立即中止事务并告警。

## 7. 依赖前置

- 依赖 T-B001/T-B002；返佣金额舍入与部分退款口径已于 2026-08-27 获用户确认。
- 提现冻结与返还调用同一账户服务，见 [03-invite-user-api-withdrawal.md](./03-invite-user-api-withdrawal.md)。

## 8. 建议实现步骤

1. 先写比例边界、首单幂等、退款乱序与负余额测试。
2. 实现账户和账本 Repository/Mapper，用数据库唯一约束/CAS 保护。
3. 替换支付成功结算，删除新模式间接奖励。
4. 接入确定的会员退款终态，实现乱序重试。
5. 升级用户/Admin 只读查询。

## 9. 详细编码任务清单

- [x] `T-B003-01` 实现转化唯一、档位快照和正向账本；增加 N 天快照及到期幂等结算。
- [x] `T-B003-02` 实现账户快照与 overview/summary/ledgers 查询。
- [ ] `T-B004-01` 资金服务及 Apple REFUND 精确交易/比例已实现；其他真实渠道终态和异常金额受控核对待补齐。
- [x] `T-B004-02` 退款/到期结算、提现原子冻结及派发前后退款并发、负余额已在隔离集成测试验证；真实资金另验。

## 10. 测试要求

- 单元：1/9/10/19/20 人、舍入、只直邀、升级不回溯。
- 集成：重复支付/退款、一人首单、全额/部分、乱序、成功提现后退款。
- 动态结算：0/N 天、到期前后边界、配置变更不追溯、等待期间部分/全额退款、任务重跑、到期与退款并发、暂停后历史到期义务与多 App 隔离。
- Mapper：唯一冲突、CAS、账户序号和负余额 SQL 行为。

## 11. 验收标准

1. 每个受邀人在当前 App 最多一次首单奖励，重复通知不重记。
2. 无二级/团队奖励，比例快照不被后续档位升级改写。
3. 退款冲正可使余额为负，后续奖励自然抵扣，不追回已到账资金。
4. 查询为服务端分页且只返回脱敏数据。

## 12. 编码注意事项

不用“先查再插”作唯一幂等边界，不通过扫描全量旧流水计算实时余额。Controller 只做参数、当前用户和 `ApiResponse` 封装。

## 13. 本批实现边界（2026-08-27）

内部方法实际为 `recordPayment(InviteMembershipPayment)`、`recordRefund(InviteMembershipRefund)` 和 `settleDue(id,now)`，由兼容门面及到期任务调用；不开放伪造支付/退款的 HTTP 入口。App 上下文必须在事务前已确定。缺退款金额或超额退款进入待核对，未结算订单置 REQUIRES_REVIEW，禁止自动发放；尚无 Admin 修复入口，不可直接改账。

用户/Admin 查询仍受旧接口模式门禁保护，不能直接用新模式调用旧汇总。绑定、查询、移动页面、其他退款渠道和提现冻结按后续模块完成后才能启用，实际验证见 [编码恢复点](../../implementation-progress.md)。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。

## 佣金来源好友脱敏手机号增量（2026-09-02）

- 共享账本 VO 新增可空 `sourcePhoneMasked`，从当前请求 App 的用户表按本页来源用户 ID 批量生成；不增加 App 名单或分支，不跨库扫描。
- 无来源用户、未绑定/异常手机号返回空；响应和日志均不出现完整手机号。数据库改动：无。
- `InviteBankWithdrawalIntegrationTests` 64 项通过，覆盖 Catseller/Catsinger 隔离、空来源、原文不泄漏和 OpenAPI。全量 1088 项仅无关歌曲生命周期类因 JVM OOM 连锁失败 7 项，该类随后单独 7 项通过。

## 邀请记录好友脱敏手机号增量（2026-09-02）

- 共享 `InviteRecordItem` 新增可空 `inviteePhoneMasked`，从当前请求 App 的用户表按当前页 `inviteeUserId` 批量生成；不增加 App 名单或分支，不跨库扫描。
- 用户缺失、未绑定或异常手机号返回空，原 `inviteeName` 继续作为客户端兜底；响应和日志均不出现完整手机号。数据库改动：无。
- `InviteBankWithdrawalIntegrationTests` 69 项通过，覆盖 Catseller/Catsinger 隔离、空手机号/用户缺失、原文不泄漏和 OpenAPI。完整测试仍在无关歌曲生命周期类触发 JVM OOM 并连带 XML 写出失败，该类单独 7 项通过。
