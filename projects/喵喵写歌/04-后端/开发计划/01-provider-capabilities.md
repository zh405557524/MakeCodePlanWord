# B001 Provider 精确模型能力

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `done`（编码依据）；`T-B001-S=done`、`T-B001-R=pending`。依据[Java 技术文档 §2～3](../java-tech.md)、[前端 F001](../../03-前端/开发计划/01-contract-and-fixture.md)与[当前方案](../../02-技术方案/v2.1-model-driven-params/tech-plan.md)。

## 骨架阶段 / `T-B001-S`

- **定位/文件**：现有 `thirdparty/aimodel/music/service/IMusicModelService`、`dto/MusicOperationContract`、`MusicOperationType`、`MusicParameterDefinition/Constraints` 只提供厂家能力标准化描述与协议适配，不拥有 Catsinger 任务/积分。保留 `MUSIC_GENERATION`、`MUSIC_COVER`，拟补音色训练和克隆翻唱各自操作；具体 enum 名称先与 B002/F001 对齐。
- **方法调用**：`describe(provider, exactModel, operation) → MusicOperationContract(status, stableOrderedParameters)`；在 local/test 中由集中 Skeleton Fixture 返回可重复的支持、部分不支持、`NOT_DECLARED` 三种结果。真实厂家请求、模型文件和用户数据一律不接入。`TODO(REAL-IMPLEMENTATION)` 映射 B001-R 的证据表、参数校验及 Provider 映射。
- **接口边界**：本模块无直接 HTTP Controller；B002 的 `GET /api/ai-model-options?sceneCode=...` 和 `GET /api/song-config/models?sceneCode=...` 消费该描述。公开响应不泄漏厂家 token、原始协议参数或声音模型文件 URL。
- **骨架验证**：编译和操作分发测试覆盖四操作、未知精确模型、空参数与稳定顺序；生产配置不会返回 Fixture 支持状态；不访问数据库、积分、审核、资源或 Provider。`T-B001-S` 完成不表示任何算道真实模型已支持。

## 真实实现阶段 / `T-B001-R`

1. 从算道文档与可复现响应为**精确 `provider/model + operation`** 建能力清单；本期仅声明有依据的算道模型，SoVITS 训练/翻唱和 Suno 写歌不能因同厂推断音色互通。未知模型返回 `NOT_DECLARED`，明确不支持返回 `UNSUPPORTED`。
2. 标准键仅覆盖 PRD 真正用到的输入和设置；Provider 内部将标准毫秒/字节/半音/倍率转换为厂家字段。可选项范围、枚举和媒体硬约束必须来自厂家证据；效果建议（如训练累计较长效果更好）不是硬门槛，未知上限不得编成固定数。
3. Provider 提交前逐键白名单复核：未知、未声明、互斥或越界参数在发厂家前拒绝，不能默默丢弃再返回成功；厂家返回临时 URL 仍交已有资源/工作流处理，不在本模块持久化。
4. 定向测试覆盖有证据模型、`NOT_DECLARED`、`UNSUPPORTED`、范围边界、非业务字段注入、SoVITS/Suno 错配与生产/测试配置隔离。跨模型能力变化需使 B002 有效版本更新。

## 数据、异常与依赖

本模块**无新表、无 Mapper/Entity/Flyway**；能力证据可按现有 Provider 配置方式维护，不能把后台 `metadataJson` 当厂家真源。若厂家资料与现有适配器执行参数不同，先记录证据并回卷技术文档，不把旧兼容执行能力冒充已声明可配置能力。异常沿现有 `ApiResponse/ErrorCode` 在 B002/创建 Service 转译；厂家超时和契约未知分开，日志只记录 appCode、scene、脱敏模型标识、操作和 traceId。

前置 B001-S 与[后端索引](00-module-index.md)第 1 项；B001-R 必须等待三端 `skeleton_review` 明确通过。实际接口由[有效契约模块](02-effective-contract.md)承接，不能在 Provider 层新建公开 URL。

## 2026-09-14 骨架记录

已在 `MusicOperationType`、`IMusicModelService`、`AbstractMusicModelProvider`、`MusicModelService` 补齐四操作分发；未核实的训练/声音克隆模型仍 `NOT_DECLARED`。`CatsingerModelSkeletonFixture` 仅在 `local/test` 且显式属性开启时注册，当前尚未接入公开模型查询；不会触生产数据或厂家。`MusicContractSkeletonTests` 与原 `MusicModelContractTests` 定向通过。B001-R 的精确厂家证据、参数映射及 Provider 真实验证均未开始。
