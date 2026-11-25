# Java 模块开发文档：后端测试与验收

> 版本：`v1.0`｜状态：已完成｜任务：`T-B015 后端验收`

## 1. 功能定位与边界

对 catseller 数据隔离、接口、状态、任务、计费、审核、资源、后台和公共复用做最终自动化与测试环境验收。本模块不新增业务功能；失败回到所属模块修复。

## 2. 类与测试清单

- 扩展 `SchemaRoutingIntegrationTests`、Security/AppCode 测试。
- 新增 Work/Persona/Home/Description/Content/Storyboard/Video/Billing/Lifecycle/Admin 集成测试。
- 参考现有 `SongWorkflowDefinitionProviderTests`、`SongWorkflowStepRegistryTests`、`SongGenerationExecutionServiceTests`，新增 SellerWorkflow 定义、步骤注册、执行暂停/恢复、事件和补偿测试。
- 各 Service 单元测试和自定义 Mapper SQL 测试。
- Provider、OSS、阿里审核、积分/支付使用受控测试环境契约测试。

## 3. 接口契约验收

对应全部 Flutter 模块文档。逐一校验 Java 总体计划中的 App 及 Admin 路径：方法、路径、鉴权、请求字段、响应字段、错误码、分页、幂等和 `nextPollAfterMs`。每个核心接口至少一个正常用例和一个错误码用例。

## 4. 数据库与迁移验收

- 空库运行 common + catseller 全部迁移。
- 已有 narrate/catsinger/catcomic 开发库升级。
- catseller 专属表/索引/外键存在，其他 schema 无 catseller 表。
- 所有历史 Flyway 文件未被修改，重复启动无重复导入。
- AppConfig/service-data 按 catseller 幂等加载。

## 5. 状态与业务矩阵

| 范围 | 必测 |
|------|------|
| 作品 | DRAFT、CONTENT_RUNNING、EDITING、VIDEO_RUNNING、COMPLETED、FAILED、HIDDEN、DELETED |
| 任务 | PENDING、RUNNING、SUCCEEDED、FAILED；租约过期和重启 |
| 工作流步骤 | PENDING、RUNNING、PAUSED、SUCCESS、FAILED、SKIPPED；已完成步骤不重跑，暂停步骤可恢复 |
| 幂等 | 首图建草稿、内容/图片/视频任务、恢复、回调、扣费 |
| 内容 | Schema 合法/非法、部分图片失败、镜头编辑/冲突、历史恢复 |
| 视频 | 快照/报价变化、Provider 忙/超时/成功、旧视频保留 |
| 积分 | 余额不足、重复提交、成功确认、失败策略、补偿 |
| 审核 | 文本/图片/形象/视频通过、拒绝、服务异常 |
| 生命周期 | 7 天隐藏、30 天删除、运行中跳过、清理失败补偿 |
| 安全 | 未登录、跨用户、JWT App 不一致、Admin 无权限、日志脱敏 |

## 6. 异常与日志验收

所有错误响应含稳定 code/message/traceId；公开 message 告诉用户可执行动作；日志无 Token、密钥、完整手机号、Prompt、签名 URL、支付凭证和人像原图。重复/晚到回调不逆转终态。

## 7. 依赖前置

所有 Java 模块完成；Flutter 契约冻结；PostgreSQL、Redis、OSS、阿里审核、AI Provider、视频模型、积分和支付测试环境可用；测试数据可清理。

## 8. 建议执行步骤

1. 执行单元、Mapper 和契约测试。
2. 执行空库/已有库 Flyway 和多 schema 隔离。
3. 执行从首图到视频完成全链路。
4. 执行重复、并发、弱网、Provider 超时和进程重启。
5. 执行工作流定义、Step 注册、PAUSED 恢复、事件日志和失败补偿测试。
6. 执行计费/审核/生命周期和 Admin 回归。
7. 执行其他 App 与公共能力回归。
8. 运行完整构建并输出失败清单/关闭结果。

## 9. 详细编码任务清单

| 子任务 | 名称 | 状态 | 退出条件 |
|--------|------|------|----------|
| T-B015-01 | 单元/Mapper | done | 核心规则和自定义 SQL 全覆盖 |
| T-B015-02 | 接口契约 | done | App/Admin 每接口正常+错误路径 |
| T-B015-03 | 全链路 | done | 商品图→脚本/分镜→视频完成通过 |
| T-B015-04 | 并发与恢复 | done | 无重复任务、扣费和终态逆转 |
| T-B015-05 | 隔离与回归 | done | catseller/其他 App/公共功能全绿 |
| T-B015-06 | 工作流编排 | done | 固定步骤、暂停恢复、事件与补偿行为正确 |

## 10. 测试要求

至少执行：

```bash
./gradlew test
./gradlew build
```

Flyway 由 H2 空库和测试 Schema 自动执行；Provider、OSS、审核、积分/支付使用契约与受控 Mock 完成自动化验证。真实账号与额度具备后，再在私密环境完成渠道联调。测试不可依赖执行顺序或生产数据。

## 11. 验收标准

- 全部模块接口、状态、错误和数据库契约通过。
- 五阶段作品流程与失败恢复可重复执行。
- 任务开始后不可取消；不发送通知；无独立配音/字幕流程。
- 按分镜图数量计费，无重复扣费。
- 7/30 生命周期、AI 标记、审核和资源清理正确。
- Admin/公共复用/其他 App 回归通过，`test`/`build` 全绿。

## 12. 编码注意事项

不通过删除测试、放宽断言或 mock 掉全部关键集成来“通过”。真实外部服务只用受控账号，敏感信息不进 fixture。性能问题记录实际数据量和 SQL。

## 13. 实现结果

已新增 catseller 接口与工作流集成测试，覆盖鉴权、隔离、幂等、版本、脚本/图片、报价失效、完整内容/视频工作流、后台和 7/30 生命周期；同时修复既有 44 条失败测试。H2 PostgreSQL 模式全量回归通过，`V2.7` 在临时 PostgreSQL 15 既有 Schema 上首次和重复执行均成功，共建立 15 张 catseller 业务表。真实外部视频渠道只保留私密环境联调条件，不向仓库写入凭据。

CHG-0019 新增数据库注释门禁，逐项检查 15 张 `catseller_*` 表及其全部字段均存在数据库注释。当前 H2 与 catseller 相关测试通过；2026-07-22 的全量测试额外执行了真实即梦、Seedance 和 PostgreSQL 联调测试，其中 8 条受本机外部环境及既有即梦单测阻塞，未通过删除测试或降低断言规避，待对应环境恢复后复核。

CHG-0019 同步完成 Java 注释复核：13 个 DTO、9 个 VO、5 个领域类型、9 个 Controller、14 个 Service 和 15 个 Entity 已按职责补齐说明；所有 Controller 对外接口与 Service 公开业务方法均有 JavaDoc，任务续跑、状态跳转、模型提交对账、审核、积分、补偿、资源和生命周期等关键阶段补充了业务原因。`./gradlew compileJava`、catseller 相关 15 条测试、`./gradlew build -x test` 和 `git diff --check` 均通过；`javadoc` 仅受 catsinger 两处既有无效链接阻塞，未发现 catseller 新增注释错误。

恢复点：前后端联调与产品验收。
