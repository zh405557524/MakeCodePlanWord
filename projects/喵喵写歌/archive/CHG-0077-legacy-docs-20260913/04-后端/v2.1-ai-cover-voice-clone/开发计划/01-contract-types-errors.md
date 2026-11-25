# 01 契约、业务类型与错误码

> 任务族：`T-B001`
> 骨架任务：`T-B001-S`
> 真实任务：`T-B001-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`03-前端/.../开发计划/01-contract-model-store.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B001-S`
- 本阶段交付：建立正式 Request/Response、枚举、错误契约、公开路径和 OpenAPI 形状；Controller 调用 Service 后从集中 Fixture 返回确定性数据。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B001-R`
- 本阶段交付：补齐真实领域校验、错误映射和与持久化/配置联动的契约行为。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

冻结 V2.1 用户端/Admin 接口、DTO/VO、内部类型和错误语义，作为后续模块共同输入。本模块不实现业务流程、不建表、不调用厂家。

## 2. 目标代码

在 `app/catsinger/voicecover/` 新增：

- `domain/VoiceCoverConstants`、状态常量和能力枚举；
- `dto/CreateVoiceProfileRequest`、`CreateVoiceTrainingRequest`、`CreateSongVoiceCoverRequest`、`VoiceCoverSettings`；
- `dto/VoiceCoverCreateCommand` 等内部命令；
- `vo/` 下配置、音色、素材、训练和翻唱响应；
- 专属错误码映射。

复用现有统一响应、异常、校验和 OpenAPI 机制。

## 3. 业务与接口隔离

| 业务 | 创建接口 | 内部类型 | 场景 |
|------|----------|----------|------|
| AI 写歌 | `/api/song-generations` | 现状 | 现状 |
| AI 改编 | `/api/song-covers` | `COVER_SONG` | `song.cover.generate` |
| 翻唱声音克隆 | `/api/song-voice-covers` | `VOICE_COVER` | `song.voice.cover.generate` |

新请求不定义 `mode`，也不继承 `CreateSongGenerationRequest`。`provider/model/modelOptionId/pricingVersion` 必须同时表达真实路由和报价快照。

## 4. 用户端接口清单

- `GET /api/song-config/voice-cover`
- `GET /api/song-config/models?sceneCode=song.voice.train|song.voice.cover.generate`
- `GET/POST/PATCH/DELETE /api/song-voices/**`
- `POST /api/song-assets/voice-materials`
- `POST /api/song-assets/voice-cover-sources`
- `GET /api/song-assets/{id}`
- `POST /api/song-assets/{id}/moderation/retry`
- `POST/GET /api/song-voice-training-tasks/**`
- `POST/GET /api/song-voice-covers/**`
- 作品继续复用 `/api/song-works/**`

## 5. 关键请求

`CreateSongVoiceCoverRequest`：sourceWorkId/sourceAudioAssetId、voiceModelVersionId、provider、model、modelOptionId、pricingVersion、coverSettings、songRightsConfirmed、voiceConsentConfirmed、idempotencyKey。来源必须 XOR，授权必须显式 true。

`CreateVoiceTrainingRequest`：voiceProfileId、materialAssetIds、provider、model、modelOptionId、pricingVersion、rightsConfirmed、riskConsentConfirmed、qualityWarningConfirmed、idempotencyKey。

## 6. 响应约束

所有任务响应提供平台 id、status、stageText、progressPercent、failureCode/message、价格/路由快照和时间。翻唱额外返回 queueEnteredAt、providerAcceptedAt、deadlineAt、workId；音色响应不暴露厂家模型 URL、配置 URL或长期试听 URL。

## 7. 错误分类

至少区分：参数错误、来源 XOR、无权资源、授权缺失、审核未通过、质量阻断、会员限制、积分不足、报价过期、模型停用、音色不可用、渠道不匹配、幂等冲突、任务不存在、状态冲突、厂家提交未知、厂家失败、平台持久化/探测/审核失败。

错误响应使用现有全局格式，提供稳定 code、可读 message 和必要字段定位；不得要求 Flutter 解析中文字符串。

## 8. 实现步骤

1. 对账当前统一错误、校验注解、ID 类型和时间格式。
2. 定义专属请求/响应，不复用旧 Cover DTO。
3. 固定 JSON 名称、可空性、枚举 raw 值和 OpenAPI 示例。
4. 与 Flutter 参数类逐字段交叉检查。
5. 建立契约测试，确认无 mode、来源 XOR 和未知字段策略。

## 9. 测试要求

- JSON 序列化/反序列化和 Bean Validation。
- CreateSongVoiceCoverRequest 不接受 mode，来源同空/同填失败。
- provider/model 空或填业务类型失败。
- 错误 code 稳定并可被前端映射。
- OpenAPI 中三个业务入口互不混用。

## 10. 验收标准

- 后续模块无需自行发明字段或错误码。
- 用户端、Admin、Flutter 和 Java 技术文档名称一致。
- 旧 `/api/song-generations`、`/api/song-covers` 契约未变。

## 11. 编码注意事项

内部 `VoiceCoverCreateCommand` 可包含服务端固定的 creationMode，但公开 DTO 不包含。DTO/VO 不与 Entity 混用，厂家私有字段只存在 Provider 层。
