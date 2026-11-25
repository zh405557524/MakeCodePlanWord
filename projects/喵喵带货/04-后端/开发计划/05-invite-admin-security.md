# Java 模块 05：Admin 邀请接口、审核、对账与敏感查看

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B010`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

在现有 `AdminInviteController` 增量提供 capability、规则、邀请/佣金查询、九态提现详情、审核、原 ID 对账、敏感字段短时查看和审计。复用现有 Admin 页面/导航/App 切换；新模式拒绝人工 `mark-paid/mark-failed` 和代理等级修改，不仅靠前端隐藏。

## 2. Controller / Service / Mapper / Entity 清单

- Controller：`admin/invite/controller/AdminInviteController`，扩展 DTO/VO 且保持薄控制层。
- Service：`AdminInviteApplicationService`、`InviteSensitiveViewService`、`InviteAdminAuditService`，复用 withdrawal/commission/capability 领域服务。
- Entity/Repository：`InviteAdminOperationLog`、platform `GongmallSensitiveViewFailure`，以及邀请/提现只读 Repository。
- Admin 对应：[admin/00-admin-capability-rules.md](./admin/00-admin-capability-rules.md)、[admin/01-admin-invite-commission.md](./admin/01-admin-invite-commission.md)、[admin/02-admin-withdrawal-security.md](./admin/02-admin-withdrawal-security.md)。

## 3. 接口合同

| 方法与路径 | 请求/响应重点 | 权限 | 错误 |
|------------|----------------|------|------|
| `GET /api/admin/invite/capabilities` | 模式、页签、`availableActions` | `INVITE_VIEW` + App 范围 | `ADMIN_APP_FORBIDDEN` |
| `GET/PUT /api/admin/invite/rules` | 新模式固定档位只读；只改最低额/URL/协议版本 | 查看/`INVITE_CONFIG_EDIT` | 参数/版本冲突 |
| `GET /api/admin/invite/users` | 关系、有效人数、首单转化、比例、脱敏用户 | `INVITE_VIEW` | 跨 App 拒绝 |
| `GET /api/admin/invite/commissions` | 订单、比例/人数快照、正向/冲正 | `INVITE_VIEW` | 同上 |
| `GET /api/admin/invite/withdrawals[/{id}]` | 九态列表；详情含余额/冻结/认证/脱敏卡/quote/工猫/查单时间线 | `INVITE_VIEW` | 记录不属当前 App 拒绝 |
| `POST /api/admin/invite/withdrawals/{id}/approve` | 仅 `PENDING_REVIEW`；复核后异步提交 | `INVITE_WITHDRAW_REVIEW` | `INVITE_WITHDRAWAL_STATE_CONFLICT` |
| `POST /api/admin/invite/withdrawals/{id}/reject` | 必填安全原因，原子释放冻结 | 同上 | 状态/参数冲突 |
| `POST /api/admin/invite/withdrawals/{id}/reconcile` | 非终态异常单，只创建原 requestId 查单任务 | `INVITE_WITHDRAW_RECONCILE` | 终态/无 requestId 拒绝 |
| `POST /api/admin/invite/withdrawals/{id}/sensitive-view-grants` | `password,reason,fields`；只返当前记录所选明文+最长 5 分钟结果 | `INVITE_SENSITIVE_VIEW` + App 范围 | `SENSITIVE_VIEW_PASSWORD_INVALID`、`SENSITIVE_VIEW_LOCKED` |
| `GET /api/admin/invite/audit-events` | 审核/配置/对账/敏感查看审计，无明文 | `INVITE_AUDIT_VIEW` | `ADMIN_APP_FORBIDDEN` |

## 4. 数据表与迁移

数据库改动：有，使用模块 00 迁移。

- App `invite_admin_operation_logs`：App Code、admin、动作、对象、原因、结果、IP/UA 摘要、traceId、时间；不存密码/明文。
- platform `gongmall_sensitive_view_failures`：admin/来源失败时间与锁定至；连续 5 次失败锁 30 分钟。
- 平台查看密码只存强哈希/密钥系统，不落 App 配置。

## 5. 业务规则与状态流转

1. 每个请求同时检查功能权限与当前 App 范围，不以已登录 Admin 代替资金权限。
2. 审核通过/驳回使用提现状态 CAS，二次提交幂等；通过时复核所有资格。
3. 主动对账不直改状态，只建查单任务，查单结果走统一迁移服务。
4. 敏感查看：权限→App 范围→锁定→密码→reason/fields 最小集合→只解密当前记录→审计。
5. grant 不授予列表/批量/导出权限；返回的明文不写缓存/日志/审计。

## 6. 异常处理与日志要求

- 密码错误不泄露剩余次数/哈希细节；锁定时间完全以服务端为准。
- 审计记成功/失败/拒绝，但不得记密码、完整姓名/证件/手机/卡。
- 新模式调旧 `mark-paid/mark-failed` 或代理更新时，服务端返明确模式/动作拒绝。

## 7. 依赖前置

- 依赖 T-B001～T-B009，以 capability/availableActions 对 Admin 暴露动作。
- 需确认权限码、App 范围授权模型、平台密码托管/轮换和审计保留期。

## 8. 建议实现步骤

1. 先写权限/App 范围、状态冲突、密码锁定和无明文审计测试。
2. 实现 capability/rules/users/commissions/withdrawals 查询 API。
3. 实现 approve/reject/reconcile 与操作审计。
4. 实现密码失败锁定、字段白名单、当前记录解密和短时返回。
5. 补 OpenAPI、限流、安全日志和跨 App 负向用例。

## 9. 详细编码任务清单

- [x] `T-B010-01` 完成 Admin capability、规则、邀请/佣金和提现查询。
- [x] `T-B010-02` 完成审核通过/驳回、原 ID 对账与操作审计。
- [x] `T-B010-03` 完成专用权限、平台密码、5 次/30 分钟、5 分钟结果和字段最小化。
- [x] `T-B010-04` 完成 LEGACY 兼容与新模式旧动作服务端拒绝。

## 10. 测试要求

- 单元：availableActions、权限交集、密码锁定、grant 过期、字段白名单。
- 集成：跨 App 越权、重复审核、审核时退款、对账不改终态、5 次失败/30 分钟、审计无明文。
- 契约：每个 Admin 核心接口正常+错误路径，OpenAPI 示例只有虚构脱敏值。

## 11. 验收标准

1. 页面隐藏与服务端授权一致，直调被隐藏动作仍会拒绝。
2. 审核/对账均有操作人、App、原因、结果和 traceId 审计。
3. 只有专用权限+正确密码+原因+所选字段才能解密当前记录。
4. 普通列表、日志、错误、审计、导出和 OpenAPI 无敏感明文。

## 12. 编码注意事项

前端禁复制只是误操作降低手段，服务端小记录/小字段/短时间/审计才是安全边界。密码与 secret 不写文档或普通配置。

## 13. 2026-08-27 编码结果（CHG-0068）

仅完成 AdminInviteApplicationService / InviteAdminPermissionService 的能力查询、规则查询/保存、显式 App 范围授权和版本审计；token 新增可信 loginAppCode。新模式当前只开放 VIEW/CONFIG_EDIT，旧代理/审核/人工打款端点拒绝新模式。查询、九态审核/对账、敏感查看授权/密码锁定/审计查询未实现，因此 T-B010 各完整子任务不提前勾选。

当前代码、文件范围、验证与下一步统一见 [三端编码恢复点](../../implementation-progress.md)。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
