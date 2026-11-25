# 多 App 邀请好友与银行卡提现 Java 总体开发计划

> 2026-08-27 实现回写：三端核心代码、共享工猫私有配置、Admin 增量与 App 22图对稿已完成本地检查，当前 waiting_review。最新真实进度以 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md) 和 [验证报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md) 为准；未自动启用/部署，真实 H5/银行及未勾选任务待验收。下文为已确认技术/任务基线，不用历史“待实现”描述覆盖最新记录。


> 版本：`v1.0.0`
> 日期：2026-08-27
> 状态：`done`
> Java 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 需求基线：[requirements.md](../01-需求/requirements.md) v1.0.3
> Java 技术文档：[java-tech.md](./java-tech.md) v1.0.0
> Flutter 技术文档：[flutter-tech.md](../03-前端/flutter-tech.md) v1.0.0
> Admin/Web 计划：[admin-web-dev-plan.md](./admin-web-dev-plan.md) v1.0.0
> 工时基线：[effort-estimate.md](../02-技术方案/effort-estimate.md) v1.0.1

---

## 1. 文档用途与范围

本文把当前 Java 技术方案拆成可执行、可暂停、可恢复的总体开发计划，供下一阶段生成 Java 模块开发文档并执行后端编码。

范围只包括：

- 多 App capability、App schema 隔离和平台共享工猫连接。
- 直接邀请人首笔会员订单返佣、退款冲正、有符号账本和账户快照。
- 实名、电签、银行卡、税费试算、每日提现、人工审核和九态状态机。
- 工猫员工同步、H5、电签确认、BANK 提现、原 requestId 查单、回调 Inbox 和退票。
- Admin 所需 capability、规则、查询、审核、对账、敏感查看和审计 API。
- 数据迁移、OpenAPI、定时任务、指标、告警、测试、启用和回滚。

Admin Flutter Web 页面与活动规则静态页面的详细执行任务单独见 [admin-web-dev-plan.md](./admin-web-dev-plan.md)。本文只维护其后端接口依赖，不把 Admin 页面代码混进 Java 任务。

本文的规划阶段已结束；当前按已确认模块实施，具体代码及验证结果见编码恢复点。

## 2. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `14 Java 编码` |
| 当前任务 | `基础与首单/动态结算/累计退款本地实现；下一步查询与绑定` |
| 当前状态 | `in_progress`（总体计划已确认，首批已编码） |
| 当前恢复点 | 能力/配置版本/迁移、Admin 动态规则、首单/到期结算/累计退款已实施；查询/绑定、其他退款渠道、提现/工猫和模式切换待完成；详见 `../implementation-progress.md` |
| 下一步默认动作 | 按 Java 01/03 查询与绑定 → Flutter 邀请/记录 → Admin 查询继续，不重复计划评审 |

编码门禁：当前 Java 技术文档、总体计划、模块文档、工猫正式协议映射和数据库迁移版本均确认前，禁止进入 Java 编码。

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 尚未开始 |
| `in_progress` | 正在执行，已记录恢复点 |
| `waiting_review` | 产物完成，等待审核、联调或环境验证 |
| `done` | 实现、测试、迁移和接口门禁通过 |
| `blocked` | 被协议、数据、密钥、权限、环境或外部系统阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

1. 开始任务前将状态设为 `in_progress`，记录迁移版本、修改文件、已执行测试和下一步。
2. 数据库、接口或状态机只完成一部分时不得把整个 T-B 任务标为 `done`。
3. 工猫 Mock 通过但真实商户未验证时，代码任务可记录本地完成，真实渠道里程碑保持 `waiting_review`。
4. 每完成一个任务同步任务表、API 表、模块文档和执行记录。
5. 发现正式工猫字段、签名或状态与技术方案冲突时，先回卷 `java-tech.md`，不得在代码中保留两套猜测协议。

## 4. 总体开发策略

按“基础设施 → 鉴权/安全 → 数据库 → 领域与业务接口 → 外部集成 → 测试与部署”推进：

1. 先实现 capability、平台共享 secret 配置骨架、Admin 权限编码和 App 路由门禁，默认不启用新模式。
2. 再提交 common/platform Flyway，补齐 Entity、Repository、索引、注释和数据预检。
3. 建立账户、有符号账本和首单/退款事件，替换当前间接佣金和全量扫描汇总。
4. 建立身份、合同、银行卡、quote 和可逆加密能力。
5. 实现用户 API、原子冻结、每日唯一、审核和九态状态机。
6. 接入工猫、outbox、回调 Inbox、原 requestId 查单、退票和多 App 调度。
7. 补齐 Admin API、敏感查看、审计、指标、告警、迁移/启用/回滚工具。
8. 最后统一执行单元、集成、并发、安全、OpenAPI、PostgreSQL 和全量回归。

### 4.1 实现不变量

- capability 只判断 `LEGACY` 或 `DIRECT_BANK_GONGMALL` 等能力值，不判断 App 产品名称。
- App 业务账户、账本、身份、卡、提现在各 App schema；工猫 secret 和回调路由在平台层。
- 正向/负向资金事件 append-only；账户快照只能由事务内事件更新。
- 本地数据库事务不包外部 HTTP；网络未知只进入 `RECONCILING` 并用原 requestId 查单。
- 回调只触发查单，不直接确认资金终态。
- 普通响应/日志始终脱敏；明文只通过专用权限、密码、原因和短时当前记录授权返回。

## 5. 阶段、工时与里程碑

引用已确认排期，不重新扩大：第一个执行日约 `0.50` 个 AI 工作日完成 Java 初稿；Admin/Web 另占约 `0.25` 日；第二个执行日统一完成三端构建、主要测试和集中修复。

| 阶段 | 计划窗口 | 任务 | 退出条件 |
|------|----------|------|----------|
| B1 能力、安全与迁移 | 第 1 日 | T-B001、T-B002、T-B005 基础 | capability 默认关闭；迁移、加密接口和路由约束可用 |
| B2 返佣与账户 | 第 1 日 | T-B003、T-B004 | 首单、比例快照、退款冲正、负余额和并发账户通过定向测试 |
| B3 用户提现闭环 | 第 1 日 | T-B005～T-B008 | 身份/卡/quote/API/冻结/审核/requestId/outbox 贯通 |
| B4 回调与运维 | 第 1 日 | T-B009～T-B012 | 回调路由、原 ID 查单、退票、Admin API、调度和启用工具可用 |
| B5 验证与修复 | 第 2 日 | T-B013 | 全量测试、OpenAPI、迁移校验、安全扫描和集中修复完成 |

| 里程碑 | Java 交付结果 |
|--------|---------------|
| 三端代码初稿 | 2026-08-27：Java 数据、API、工猫、回调、Admin 后端依赖已实现 |
| 本地验证版本 | 2026-08-28：Gradle 测试、迁移、OpenAPI、并发、安全和多 App 回归通过主要门禁 |
| 工猫真实环境验收 | 环境就绪后：核身、电签、提现、查单、回调和退票使用真实商户验证 |

## 6. 后端详细任务清单

任务 ID 与 `tech-plan.md` 的 T-B001～T-B013 一一对应。

| 任务 ID | 业务任务 | 依赖 | 主要实现 | 状态 | 完成标准 |
|---------|----------|------|----------|------|----------|
| T-B001 | App 能力配置、版本与非启用兼容 | 无 | capability、配置版本、App 门禁 | `waiting_review` | `LEGACY/DIRECT_BANK_GONGMALL` 行为明确；未启用 App 不变；无 Catseller 硬编码 |
| T-B002 | common/platform Flyway 增量迁移 | T-B001 | 账户、账本、身份、卡、quote、提现、任务、路由、审计表 | `waiting_review` | 使用未占用版本；约束/索引/注释齐全；H2/PostgreSQL 通过 |
| T-B003 | 首单转化、阶梯比例与正向账本 | T-B002 | conversion、账户、支付回调及 N 天结算 | `in_progress` | 每受邀人仅首单；1/10/20 档快照；重复支付只记一次；无二级佣金 |
| T-B004 | 退款冲正、乱序事件与余额并发 | T-B003 | Apple 退款终态、负账本、账户 CAS；其他渠道/提现并发待补 | `in_progress` | 重复/乱序/部分或全额口径正确；余额可负；成功提现不追回 |
| T-B005 | 可逆数据加密、身份、合同和银行卡 | T-B002 | AES-GCM/HMAC、profile/session/card | `pending` | 密文可受控解密；普通接口脱敏；身份锁定；银行卡归属和软删除正确 |
| T-B006 | 共享工猫适配器与协议安全 | T-B005 | 表单 POST、大写 MD5、RSA、Gateway、key version | `pending` | 员工同步、H5、电签、试算、提现和查单 DTO 与正式协议一致；无敏感日志 |
| T-B007 | 用户资格、认证、银行卡、试算、提现 API | T-B003～T-B006 | Controller/DTO/VO/Application Service/OpenAPI | `pending` | Flutter 所需接口、字段、错误码和脱敏响应冻结；越权/跨 App 被拒绝 |
| T-B008 | 提现状态机、冻结、requestId 与 outbox | T-B002、T-B006、T-B007 | 账户条件更新、九态、审核、CS+ULID、派发任务 | `pending` | 并发不超冻；每日一单；审核事务不含 HTTP；未知结果不重复打款 |
| T-B009 | platform 回调路由、Inbox、查单与退票 | T-B006、T-B008 | platform route/inbox、callback controller、reconcile | `pending` | 不扫描全部 schema；重复回调幂等；最终状态查单确认；退票返还一次 |
| T-B010 | Admin 权限/API/敏感查看/审计 | T-B001～T-B009 | Admin Controller/Service、grant、失败锁定、审计 | `in_progress` | 当前 App 范围；5 分钟；5 次失败锁 30 分钟；普通响应无明文 |
| T-B011 | 定时任务、指标、告警和死信处置 | T-B008、T-B009 | submit/query worker、scheduler、metrics、alerts | `pending` | 多 App 公平扫描；租约/退避/死信可恢复；异常状态可告警 |
| T-B012 | 旧模式兼容、数据预检和启用迁移工具 | T-B001～T-B011 | dry-run、checksum、初始化、capability 切换/回退 | `pending` | 旧关系/流水不重复入账；新模式按 App 启用；已提交单继续对账 |
| T-B013 | Java 全量测试、OpenAPI 和运维说明 | T-B001～T-B012 | 单元/集成/并发/安全/迁移/文档 | `pending` | `./gradlew test`、OpenAPI、数据库和 diff 门禁通过；外部未验证项明确 |

## 7. API 接口任务表

### 7.1 用户接口

| 任务 ID | 接口 | 方法 | 路径 | 依赖表 | Service | 状态 |
|---------|------|------|------|--------|---------|------|
| T-B007 | 邀请首页 | GET | `/api/invite/overview` | account、conversion、config | `InviteQueryService` | `pending` |
| T-B007 | 邀请素材 | GET | `/api/invite/materials` | invite relation/config | `InviteQueryService` | `pending` |
| T-B007 | 邀请记录 | GET | `/api/invite/records` | invite relation/conversion | `InviteQueryService` | `pending` |
| T-B007 | 佣金汇总 | GET | `/api/invite/earnings/summary` | account、ledger | `InviteQueryService` | `pending` |
| T-B007 | 佣金流水 | GET | `/api/invite/earnings/ledgers` | ledger | `InviteQueryService` | `pending` |
| T-B007 | 提现资格 | GET | `/api/invite/withdrawal-eligibility` | account、identity、card、withdrawal | `InviteWithdrawalApplicationService` | `pending` |
| T-B007 | 创建认证会话 | POST | `/api/invite/identity-sessions` | identity profile/session、card、route binding | `InviteIdentityApplicationService` | `pending` |
| T-B007 | 确认认证会话 | POST | `/api/invite/identity-sessions/{sessionId}/confirm` | identity session/profile、card | `InviteIdentityApplicationService` | `pending` |
| T-B007 | 银行卡列表 | GET | `/api/invite/bank-accounts` | bank account | `InviteIdentityApplicationService` | `pending` |
| T-B007 | 设置默认卡 | PUT | `/api/invite/bank-accounts/{id}/default` | bank account | `InviteIdentityApplicationService` | `pending` |
| T-B007 | 删除银行卡 | DELETE | `/api/invite/bank-accounts/{id}` | bank account、withdrawal | `InviteIdentityApplicationService` | `pending` |
| T-B007 | 税费试算 | POST | `/api/invite/withdrawal-quotes` | account、bank account、quote | `InviteWithdrawalApplicationService` | `pending` |
| T-B008 | 创建提现 | POST | `/api/invite/withdrawals` | account、quote、withdrawal/event | `InviteWithdrawalApplicationService` | `pending` |
| T-B007 | 提现列表 | GET | `/api/invite/withdrawals` | withdrawal | `InviteQueryService` | `pending` |
| T-B007 | 提现详情 | GET | `/api/invite/withdrawals/{id}` | withdrawal/event | `InviteQueryService` | `pending` |

### 7.2 Admin 接口

| 任务 ID | 接口 | 方法 | 路径 | 依赖表 | Service | 状态 |
|---------|------|------|------|--------|---------|------|
| T-B010 | 能力查询 | GET | `/api/admin/invite/capabilities` | config | `AdminInviteApplicationService` | `waiting_review` |
| T-B010 | 规则查询 | GET | `/api/admin/invite/rules` | config/version | `AdminInviteApplicationService` | `waiting_review` |
| T-B010 | 规则保存 | PUT | `/api/admin/invite/rules` | config/version/audit | `AdminInviteApplicationService` | `waiting_review` |
| T-B010 | 邀请用户查询 | GET | `/api/admin/invite/users` | relation/conversion/account | `AdminInviteApplicationService` | `pending` |
| T-B010 | 佣金查询 | GET | `/api/admin/invite/commissions` | ledger/conversion | `AdminInviteApplicationService` | `pending` |
| T-B010 | 提现列表 | GET | `/api/admin/invite/withdrawals` | withdrawal | `AdminInviteApplicationService` | `pending` |
| T-B010 | 提现详情 | GET | `/api/admin/invite/withdrawals/{id}` | account/identity/card/quote/withdrawal/event | `AdminInviteApplicationService` | `pending` |
| T-B010 | 审核通过 | POST | `/api/admin/invite/withdrawals/{id}/approve` | account/withdrawal/event/outbox | `AdminInviteApplicationService` | `pending` |
| T-B010 | 审核驳回 | POST | `/api/admin/invite/withdrawals/{id}/reject` | account/withdrawal/event | `AdminInviteApplicationService` | `pending` |
| T-B010 | 主动对账 | POST | `/api/admin/invite/withdrawals/{id}/reconcile` | withdrawal/outbox/audit | `AdminInviteApplicationService` | `pending` |
| T-B010 | 敏感查看授权 | POST | `/api/admin/invite/withdrawals/{id}/sensitive-view-grants` | identity/card/failure/audit | `InviteSensitiveViewService` | `pending` |
| T-B010 | 审计查询 | GET | `/api/admin/invite/audit-events` | admin audit | `AdminInviteApplicationService` | `pending` |

### 7.3 工猫回调

| 任务 ID | 接口 | 方法 | 路径 | 依赖表 | Service | 状态 |
|---------|------|------|------|--------|---------|------|
| T-B009 | 合同回调 | POST | `/api/callbacks/gongmall/contracts` | route binding/callback inbox | `GongmallCallbackApplicationService` | `pending` |
| T-B009 | 提现结果回调 | POST | `/api/callbacks/gongmall/withdrawals` | route binding/callback inbox | `GongmallCallbackApplicationService` | `pending` |
| T-B009 | 银行退票回调 | POST | `/api/callbacks/gongmall/refunds` | route binding/callback inbox | `GongmallCallbackApplicationService` | `pending` |

旧 `mark-paid/mark-failed` 和代理修改接口只对 `LEGACY` capability 保留。新模式下即使直接请求也由服务端拒绝，不能只依赖 Admin 隐藏按钮。

## 8. 数据库与迁移顺序

### 8.1 数据库改动

有。计划新增/升级 App schema 与 platform schema 数据结构。编码前重新确认未占用 Flyway 版本；当前新增为 common `V4.5/V4.6`、platform `V4.1`，不能修改已执行迁移。

### 8.2 顺序

1. platform route binding、callback inbox、敏感查看失败锁定。
2. App capability 配置版本、账户、首单转化和有符号账本。
3. 身份 profile/session、银行卡和 quote。
4. 提现主单、状态事件、outbox、provider event 和 Admin audit。
5. 从旧邀请关系/正向流水/提现记录 dry-run 计算期初账户；输出 checksum，不直接启用。
6. Entity/Repository/测试与迁移同批提交，禁止先上线代码再补表。

关键约束：首单/退款事件唯一、用户+业务日唯一提现、非空 requestId 部分唯一、回调/状态事件/outbox 唯一、银行卡 hash 活跃唯一、账户 version/CAS。

## 9. Admin/Web 依赖摘要

后台独立计划使用 T-A001～T-A007，Java 需按顺序提供：

| Admin 任务 | Java 前置 |
|------------|-----------|
| T-A001 capability 与 App 切换 | T-B001、T-B010 capability API |
| T-A002 规则配置 | T-B010 rules API/config version |
| T-A003 邀请与佣金查询 | T-B003、T-B004、T-B010 查询 API |
| T-A004 提现审核/详情/对账 | T-B008～T-B010 |
| T-A005 敏感查看与审计 | T-B005、T-B010 |
| T-A006 活动规则 Web | T-B001 当前 App URL 配置 |
| T-A007 自动化与模式回归 | T-B013 OpenAPI 与测试数据 |

接口未完成时 Admin 可使用契约 Fixture 开发，但不得在 Admin 工程自造不同字段或状态。

## 10. 模块开发文档列表

旧综合 Java 模块文档已原样移入 CHG-0063 归档；以下 7 份当前模块文档已获用户确认，文档状态为 `done`；实际编码按任务表和模块复选框记录：

| 顺序 | 计划路径 | 覆盖任务 | 状态 |
|------|----------|----------|------|
| 1 | `04-后端/开发计划/00-invite-capability-migrations.md` | T-B001、T-B002、T-B012 | `done` |
| 2 | `04-后端/开发计划/01-invite-commission-account.md` | T-B003、T-B004 | `done` |
| 3 | `04-后端/开发计划/02-invite-identity-gongmall.md` | T-B005、T-B006 | `done` |
| 4 | `04-后端/开发计划/03-invite-user-api-withdrawal.md` | T-B007、T-B008 | `done` |
| 5 | `04-后端/开发计划/04-gongmall-callback-reconcile.md` | T-B009、T-B011 | `done` |
| 6 | `04-后端/开发计划/05-invite-admin-security.md` | T-B010 | `done` |
| 7 | `04-后端/开发计划/06-invite-tests-release.md` | T-B013 | `done` |

每份模块文档必须明确 Controller、DTO/VO、Application/Domain Service、Entity、Repository、Migration、事务、幂等、安全、测试和恢复点。

## 11. 编码约束

1. 编码前重新读取 Java 编码索引，以及逻辑调整、新接口、数据库、安全、密钥和第三方接入规则。
2. Controller 只做参数、鉴权上下文和 ApiResponse；资金与状态逻辑在 Service。
3. Repository/Mapper 承担条件更新和必要 SQL；Service 不拼裸 SQL。
4. 查业务 schema 前必须有明确 AppContext；回调先 platform 解路由，不默认 App、不遍历 schema。
5. 本地事务不含工猫 HTTP；outbox 和终态迁移均可幂等恢复。
6. secret/KEK/pepper 只通过环境或密钥系统注入；文档、代码和普通业务配置不出现真实值。
7. 姓名、证件、手机号、银行卡密文可受控解密；普通日志、接口、审计和导出禁止明文。
8. 保留用户未提交改动；不顺带修改邀请提现以外模块。
9. 新接口和 DTO/VO/Entity/公开 Service 方法按工程规则补完整业务注释和 OpenAPI。

## 12. 验证与完成标准

### 12.1 自动化

- 单元：比例边界、金额舍入、状态机合法边、签名/RSA、错误码映射。
- 集成：重复支付/退款、乱序、负余额、并发提现、每日唯一、审核并发、超时查单、重复回调、退票。
- 多 App：同 userId 隔离、capability 新旧模式、共享 Provider 路由、未知回调不兜底。
- 安全：脱敏、日志扫描、越权、密码失败锁定、5 分钟 grant、审计无明文。
- 迁移：H2 与 PostgreSQL、注释、索引、唯一约束、dry-run/checksum。
- 契约：`/v3/api-docs` 包含全部用户/Admin/回调接口和稳定错误码。

### 12.2 命令门禁

- `./gradlew test`
- 必要时 `./gradlew build`
- PostgreSQL Flyway 迁移验证
- `/v3/api-docs` 契约检查
- `git diff --check`

真实工猫未就绪时，Mock/契约测试通过不等于真实渠道验收完成；需在执行记录单列。

## 13. 风险与编码前门禁

- 返佣舍入、累计部分退款、N 天结算与最低额动态配置已确认；历史期初余额与切换日仍须在 T-B012 前确认。
- 工猫正式签名串、RSA 编码、合同/提现/查单/回调/退票字段和状态映射必须在 T-B006 前核准。
- 测试商户 BANK、余额、主体、合同模板、回调域名和允许 IP 在真实验收前就绪。
- Admin 权限编码、平台查看密码托管/轮换和审计期限在 T-B010 前确认。
- 已审核通过或已提交工猫的单据即使 capability 回退也必须继续查单到终态。

## 14. 执行记录

| 日期 | 阶段/任务 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-08-27 | 10 Java 总体开发计划 | 用户通过“继续下一步”确认 Java 技术文档；统一 capability 枚举为 `DIRECT_BANK_GONGMALL`，归档旧综合 Java 总体计划，生成 T-B001～T-B013、用户/Admin/回调 API 与模块文档清单 | 用户已确认，`done`；未修改 Java、数据库或 Admin 代码 |
| 2026-08-27 | CHG-0068 首批编码 | 能力/配置版本/迁移与 Admin capability/rules 权限完成；资金、工猫和模式切换待实现 | test/build 成功；1187 项，0 失败，3 跳过；PostgreSQL 16 隔离重放 5 App+platform SQL 通过 |
| 2026-08-27 | CHG-0068 佣金资金批次 | 首单、N 天结算、累计退款/负余额、Apple REFUND、动态规则及 V4.6；查询、绑定、其他渠道和提现待后续 | 默认 test/build 成功；1217 项，0 失败、3 跳过；隔离 PostgreSQL 重放通过，无业务库/启用操作 |

## 15. 下一步

总体/模块文档已确认，失效规则引用已修复。本批实际完成项见任务表，其余功能保持 pending。下一佣金模块需用户确认金额舍入及部分退款口径；准确代码、验证和恢复顺序见 [implementation-progress.md](../implementation-progress.md)，不以文档 done 代替实现完成。
