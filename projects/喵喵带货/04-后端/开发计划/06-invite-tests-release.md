# Java 模块 06：资金、安全、OpenAPI 与发布验证

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B013`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

为 T-B001～T-B012 建立单元、集成、并发、迁移、多 App、安全、OpenAPI 和运维门禁。真实工猫 BANK 联调、人工验收、法务财务确认和银行到账等待单列，不混入 AI 纯执行工时。

## 2. 涉及测试与工具清单

- `src/test/java/com/lxwx/narrateservice/app/growth/invite/`：领域、事务、状态机、账户和查询测试。
- `src/test/java/com/lxwx/narrateservice/admin/invite/`：权限、App 范围、敏感查看和审计。
- `src/test/java/com/lxwx/narrateservice/thirdparty/gongmall/`（最终按实际适配包对齐）：官方向量、签名、RSA、超时和状态映射。
- H2/PostgreSQL Flyway 与注释/索引/唯一约束门禁。

## 3. 接口契约验证

`/v3/api-docs` 必须暴露用户、Admin 和回调全部路径，请求/响应字段与当前 [java-tech.md](../java-tech.md) 及 [03-invite-user-api-withdrawal.md](./03-invite-user-api-withdrawal.md) 一致。

- 每个核心接口至少一个正常+一个错误路径。
- DTO/VO/Entity/公开 Service 方法有完整业务注释。
- 幂等 Header、分页、九态、稳定错误码、脱敏示例不缺失。

三端契约回归对应 [Flutter 测试模块](../../03-前端/开发计划/05-invite-flutter-tests.md) 与 [Admin/Web 测试模块](./admin/03-activity-rules-web-tests.md)。本模块不新增 API，也不另设 DTO 字段。

## 4. 数据表与迁移验证

本模块不新增业务表；验证模块 00 的全部 App/platform 增量迁移。

数据库改动：本模块无新增结构或业务数据变更；仅在隔离测试环境验证其他模块声明的迁移，不操作共享或生产数据库。

- H2 与 PostgreSQL 都要通过，检查表/字段注释、索引、部分唯一和条件 SQL。
- dry-run 不写数据；checksum 可重复；迁移不重复累计旧余额。
- 不修改已执行迁移，回退保留资金事件与继续查单能力。

## 5. 资金与状态测试矩阵

| 场景 | 必须断言 |
|------|------------|
| 重复支付/一人多单 | 首单奖励只一次，无二级 |
| 比例升级 | 历史快照不变，只影响后续订单 |
| 重复/乱序/部分退款 | 最终冲正一致，不超原奖励 |
| 成功提现后退款 | 形成负余额，不追回到账款 |
| 并发提现/每日限制 | 最多成功一单，不超冻 |
| 审核时退款/驳回 | 复核与释放正确，重复操作不重复解冻 |
| 提交超时/5xx/未知 | `RECONCILING`，原 requestId 查单 |
| 重复回调/查单并发 | 终态资金动作一次 |
| 成功后退票 | `SUCCEEDED -> RETURNED`，返还一次 |

## 6. 安全与多 App 测试

- 同 userId 在不同 App 的关系/账户/身份/卡/提现隔离。
- 共享工猫连接不影响回调路由；未知路由不默认 App 兜底。
- Admin 功能权限+App 范围双校验；5 次失败锁 30 分钟；grant 最长 5 分钟。
- 日志、错误、OpenAPI、列表、审计、导出无密码/敏感明文/密钥。
- LEGACY 原代理/人工打款不变；新模式直调旧动作仍拒绝。

## 7. 依赖前置

依赖 T-B001～T-B012 代码完成；本地测试使用可控 Gateway fixture，真实工猫使用独立测试商户/BANK/余额/主体/合同模板/回调域名。

## 8. 建议实现步骤

1. 先补单元/集成/并发测试，再跑全量测试。
2. 执行 H2/PostgreSQL 迁移和资金 checksum 验证。
3. 对 `/v3/api-docs` 做合同断言，同步 Flutter/Admin fixture。
4. 验证指标/告警/死信处置，补运维说明。
5. 按 App 灰度启用，回退演练保留非终态对账。

## 9. 详细编码任务清单

- [x] `T-B013-01` 完成领域/事务/并发/回调测试。
- [x] `T-B013-02` 完成多 App、LEGACY、Admin 权限/敏感查看和日志安全测试。
- [x] `T-B013-03` 完成 Flyway、索引/注释、OpenAPI 和三端契约验证。
- [x] `T-B013-04` 完成运维、发布、回退、告警与外部验收说明。

## 10. 命令门禁

- Java/配置/测试修改后至少 `./gradlew test`。
- 全部收口执行 `./gradlew build`。
- PostgreSQL Flyway 验证、`/v3/api-docs` 契约检查。
- `git diff --check`。

## 11. 验收标准

1. 核心资金、并发、乱序、退票和安全用例全部通过。
2. H2/PostgreSQL 迁移、注释/索引和 OpenAPI 通过。
3. 本地 Mock 结论与真实工猫结论分开记录，无未执行却标记通过的用例。
4. 已提交单在 capability 关闭后仍可对账至终态。

## 12. 编码注意事项

保留用户未提交代码；对既有无关测试失败提供可复现证据，不静默忽略。不在本模块生成或修改无关业务的发布内容。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
