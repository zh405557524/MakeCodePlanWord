# Java 模块 00：邀请能力、数据迁移与旧模式切换

> 2026-08-28 调整：双模式设计被用户确认的[共享统一执行计划](./07-invite-unified-manual-payout.md)替代；本文保留旧实施追溯，不再作为新增模式分流的依据。数据库策略同步改为：确认未正式执行的开发 SQL 可直接调整/合并，任一正式 schema 已执行的文件冻结，状态未知先不修改。

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B001`、`T-B002`、`T-B012`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 总体计划：[java-dev-plan.md](../java-dev-plan.md)

## 1. 功能定位与边界

为多 App 提供 `DISABLED/LEGACY/DIRECT_BANK_GONGMALL` capability、版本化业务配置、App/platform schema 增量迁移、旧数据预检与可回退启用门禁。工猫商户连接平台共享，但账户、账本、身份、卡和提现必须按 App schema 隔离。

不在启动时自动迁移资金，不默认把其他 App 切到新模式，不删除旧表/列/接口。

## 2. Controller / Service / Repository / Entity 清单

- 复用：`core/config/service/AppConfigService`、`AppContext`、`SchemaRoutingDataSource`、`admin/invite/controller/AdminInviteController`。
- 新增/拆分：`InviteCapabilityService`、`InviteConfigVersionService`、`InviteMigrationPrecheckService`、`InviteModeActivationService`。
- Entity/Repository：第 4 节列出的 App schema 与 platform schema 表；现有 legacy Entity/Repository 保留。
- 迁移：编码前重新查未占用 Flyway 版本；当前候选 common `V4.5__invite_direct_bank_withdrawal.sql`、platform `V4.1__gongmall_callback_routing.sql`。

## 3. 接口合同

| 方法与路径 | 请求 | 响应 | 鉴权/错误 |
|------------|------|------|-----------|
| `GET /api/admin/invite/capabilities` | 无 | `mode`、可见页签、`availableActions`、活动规则 URL 能力 | Admin JWT + `INVITE_VIEW` + App 范围；`ADMIN_APP_FORBIDDEN` |
| `GET /api/admin/invite/rules` | 无 | 当前配置与版本；新模式档位只读 | 同上 |
| `PUT /api/admin/invite/rules` | 最低额、落地页、活动规则 URL、协议展示版本等允许项 | 新配置版本与 digest | `INVITE_CONFIG_EDIT`；固定档位修改返参数错误 |
| `GET /api/invite/overview` | 无 | capability、人数/比例/两段进度、余额和入口 URL | 用户 JWT + App Code；`INVITE_CAPABILITY_DISABLED` |

新模式固定规则是 1～9 人 10%、10～19 人 20%、20+ 人 30%，不允许 Admin 修改。详细 Admin 契约引用 [admin/00-admin-capability-rules.md](./admin/00-admin-capability-rules.md)。

Flutter 对应：[契约与路由](../../03-前端/开发计划/00-invite-contract-routing.md)、[邀请首页](../../03-前端/开发计划/01-invite-overview-materials.md)。

## 4. 数据表与迁移

数据库改动：有。

| schema | 表/变更 | 核心约束 |
|--------|---------|----------|
| App | `invite_accounts`、`invite_config_versions`、`invite_member_conversions`、`invite_wallet_ledgers` | 用户账户唯一、配置版本唯一、事件/序号唯一 |
| App | `invite_identity_profiles`、`invite_identity_sessions`、`invite_bank_accounts`、`invite_withdrawal_quotes` | 用户实名唯一、卡 HMAC 活跃唯一、quote 一次消费 |
| App | `invite_withdrawals`、`invite_withdrawal_events`、`invite_outbox_tasks`、`invite_provider_events`、`invite_admin_operation_logs` | 用户+业务日唯一、requestId 非空唯一、事件/任务幂等 |
| platform | `gongmall_route_bindings`、`gongmall_callback_inbox`、`gongmall_sensitive_view_failures`、`invite_admin_app_permissions` | `(route_type,external_key)` 唯一、`event_key` 唯一、失败锁定、管理员来源/目标 App/权限唯一 |

- common 迁移在所有 App schema 执行，必须兼容 H2/PostgreSQL 并含表、字段注释。
- `app_configs(invite.shared_withdrawal)` 保存当前配置；密钥、KEK、pepper 不进入 App 配置或快照。
- 旧正向流水/已打款记录只通过 dry-run 形成期初余额与 checksum，不在普通启动中回填。

## 5. 业务规则与状态流转

1. `DISABLED` 不开放邀请提现；`LEGACY` 保留当前代理/人工打款；`DIRECT_BANK_GONGMALL` 走新账本与九态。
2. 启用顺序：`precheck -> dry-run -> balance checksum -> freeze legacy writes -> enable capability`。
3. 各 App 显式启用，一个 App 的失败不影响其他 App；缓存 key 和调度任务必须带 App Code。
4. capability 回退可停止新申请/审核，但已提交工猫单必须继续查单至终态。

## 6. 异常处理与日志

- 工猫配置缺失、BANK 不可用、时钟偏移超限时 capability 自检不通过，不允许资金派发。
- 迁移预检输出行数、金额 checksum、重复/非法数据摘要，不输出明文账号和身份信息。
- 每次配置变更记录 App、版本、操作人、digest 和 traceId。

## 7. 依赖前置

- 需使用现有 App schema 路由、App 配置和 Admin 权限体系。
- 与 [01-invite-commission-account.md](./01-invite-commission-account.md)、[02-invite-identity-gongmall.md](./02-invite-identity-gongmall.md)、[03-invite-user-api-withdrawal.md](./03-invite-user-api-withdrawal.md) 共用迁移。

## 8. 建议实现步骤

1. 重查 Flyway 版本和旧表真实结构，锁定增量 DDL。
2. 实现 capability/config version 与模式兼容测试。
3. 提交 App/platform 迁移、Entity、Repository 和注释门禁。
4. 实现 precheck/dry-run/checksum/启用/回退命令，默认不启用。

## 9. 详细编码任务清单

- [x] `T-B001-01` 实现三模式 capability 与配置版本。
- [x] `T-B002-01` 新增 common/platform 迁移、Entity、Repository、索引和注释。
- [x] `T-B012-01` 实现旧数据预检、dry-run、checksum 与切换日锁定。
- [x] `T-B012-02` 验证 LEGACY 不变、新模式显式启用、回退不丢对账。

## 10. 测试要求

- 单元：capability、固定档位、配置版本与 URL 校验。
- 集成：多 App 同 userId 隔离、LEGACY/新模式、缓存隔离、H2/PostgreSQL Flyway。
- 迁移：dry-run 不写数据，checksum 稳定，重复执行幂等。

## 11. 验收标准

1. 非启用 App 行为不变，无 Catseller 名称硬编码。
2. 所有资金表有唯一约束/索引/注释，H2 与 PostgreSQL 迁移通过。
3. 启用前必须通过预检和 checksum，不存在启动自动资金迁移。
4. 关闭 capability 不会中断已提交单对账。

## 12. 编码注意事项

不修改正式环境已执行或尚未核实执行状态的迁移；确认仅用于本地/隔离测试的开发 SQL 可直接调整、合并，实际结构同步与测试须单独验证，不自动清库或以 repair 代替结构迁移。不在 Service 拼 SQL。账户 CAS、部分唯一和条件迁移可使用少量明确 Mapper SQL；编码时同步 Entity/Repository/测试。

## 13. 2026-08-27 编码结果（CHG-0068）

T-B001/T-B002 已完成本地实现：三模式/配置版本、common V4.5、platform V4.1、16 张新表 Entity/Repository、原提现增量及约束/注释。平台表额外增加 invite_admin_app_permissions，可信登录来源 + 目标 App + 专用权限显式匹配；不默认授权。H2、全量 test/build 和 PostgreSQL 16 隔离 SQL 重放通过。T-B012 的预检、dry-run、checksum、启用/回退尚未实现，不得启用新模式；用户新 overview 也由后续模块提供。

当前代码、文件范围、验证与下一步统一见 [三端编码恢复点](../../implementation-progress.md)。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
