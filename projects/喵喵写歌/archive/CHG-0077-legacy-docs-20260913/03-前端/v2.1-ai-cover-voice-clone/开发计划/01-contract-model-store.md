# 01 契约、模型、API 与 Store

> 任务族：`T-F001`
> 骨架任务：`T-F001-S`
> 真实任务：`T-F001-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Java 对应：`04-后端/.../开发计划/01-contract-types-errors.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-F001-S`
- 本阶段交付：建立正式 DTO/VO、枚举、Store、错误映射和 `SongVoiceCoverAPI` 方法；所有方法使用本文确认的真实接口路径，并能解析 Java Skeleton Fixture 的确定性响应。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-F001-R`
- 本阶段交付：接入真实鉴权、分页、资源状态、任务状态和服务端数据刷新，移除骨架响应依赖。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

为翻唱声音克隆建立独立 Flutter 数据层，统一承载配置、模型选项、音色、素材、训练任务和翻唱任务。该模块不绘制业务页面，不修改现有 `SongAPI` 的 AI 写歌/AI 改编契约。

## 2. 影响文件

建议新增：

- `lib/apis/song_voice_cover.dart`
- `lib/models/data/song_voice_cover.dart`
- `lib/models/params/song_voice_cover_params.dart`
- `lib/store/song_voice_cover.dart`
- `lib/pages/song_voice_cover/domain/voice_cover_error_mapper.dart`

参考并复用：

- `lib/apis/song.dart`
- `lib/models/data/song.dart`
- `lib/store/song.dart`
- `lib/core/http_service.dart` 或当前 Dio 包装
- `lib/models/params/resource_direct_upload_params.dart`

## 3. 接口契约

| 方法 | 请求 | 主要响应 |
|------|------|----------|
| `fetchConfig` | `GET /api/song-config/voice-cover` | 开关、维护文案、格式/时长/容量、授权版本、轮询参数、设置范围 |
| `fetchModels` | `GET /api/song-config/models?sceneCode=...` | `modelOptionId/providerCode/modelCode/displayName/pricePoints/pricingVersion/enabled/capabilityLimits` |
| `fetchVoices` | `GET /api/song-voices?scope=MY|OFFICIAL` | 音色摘要列表 |
| `fetchVoice` | `GET /api/song-voices/{id}` | 资料版本、素材统计、训练状态、渠道可用性 |
| `create/update/deleteVoice` | `POST/PATCH/DELETE /api/song-voices/**` | 最新资料、revision 或删除结果 |
| `bindVoiceMaterial` | `POST /api/song-assets/voice-materials` | 素材 asset 与审核状态 |
| `bindCoverSource` | `POST /api/song-assets/voice-cover-sources` | 源歌曲 asset 与审核状态 |
| `fetch/retryAsset` | `GET /api/song-assets/{id}`、`POST /api/song-assets/{id}/moderation/retry` | 技术状态、审核状态、错误与重试能力 |
| `create/fetchTraining` | `POST/GET /api/song-voice-training-tasks/**` | 训练任务及产出版本 |
| `create/fetch/activeCover` | `POST/GET /api/song-voice-covers/**` | 翻唱任务、时间点与 workId |

## 4. 核心模型

- `SongVoiceCoverConfig`：`enabled`、`maintenanceMessage`、格式/容量/时长限制、授权版本、轮询区间、设置范围。
- `SongVoiceProfileSummary/Detail`：平台 ID、ownerType、资料版本、模型版本、状态、头像/试听资源、不可用原因、revision。
- `SongVoiceMaterial`：assetId、来源、截取范围、真实时长/大小、质量、审核状态、保留时间。
- `SongVoiceModelVersion`：平台版本、可用性、试听资源；不得暴露厂家模型文件 URL。
- `SongVoiceTrainingTask`：任务状态、阶段、进度、价格、错误、产出版本。
- `SongVoiceCoverTask`：状态、阶段、进度、`queueEnteredAt/providerAcceptedAt/deadlineAt`、workId、路由/价格快照。
- `SongVoiceCoverSettings`：只包含配置允许的 pitch、vocalVolume、accompanimentVolume。

未知枚举必须保留 rawValue 并按不可用/错误态展示，禁止默认映射为 PASS、AVAILABLE 或 SUCCEEDED。

## 5. 创建参数规则

`CreateSongVoiceCoverParams` 必须包含真实 `provider/model`、`voiceModelVersionId`、settings、授权版本、pricingVersion、idempotencyKey；`sourceWorkId/sourceAudioAssetId` 二选一；不得输出 `mode`。

`CreateSongVoiceTrainingParams` 包含 voiceId、modelOptionId、真实 provider/model、pricingVersion、质量告警确认、授权版本和 idempotencyKey。字段最终以 Java 契约为准，变动先回卷技术文档。

## 6. Store 职责

- 缓存功能配置、两个场景模型选项和当前账号的活动任务 ID。
- 不缓存签名 URL、厂家模型 ID/文件地址或音频二进制。
- 账号/App 切换后清空缓存，并以请求 epoch 丢弃旧响应。
- 任务终态后刷新音色、积分或作品 Store，再清除活动 ID。
- 页面局部状态由 Controller 持有，Store 不替代完整表单状态机。

## 7. 实现步骤

1. 对照 Java DTO 固定 JSON key、可空性和枚举降级。
2. 新建 API 类并复用现有 Header、鉴权、错误包装和 AppCode。
3. 实现参数序列化测试，重点断言不发送 `mode` 和来源 XOR。
4. 实现响应兼容解析和未知枚举测试。
5. 建立 Store 缓存、epoch 与账号清理钩子。
6. 为后续页面提供稳定的加载、刷新和任务恢复方法。

## 8. 定向测试

- 每个 DTO 正常、缺字段、未知枚举和错误类型解析。
- 创建翻唱 JSON 不含 `mode`，并原样提交真实 provider/model。
- sourceWorkId/sourceAudioAssetId 同空或同时存在时客户端阻断。
- 重复请求沿用同一 idempotencyKey；关键输入改变后生成新键。
- App/账号切换时旧响应不污染新 Store。

## 9. 验收标准

- 页面层无需拼 URL、JSON 或错误字符串。
- API 与 Java 技术文档逐项一致，不发明训练 active 接口。
- 所有签名资源只交给现有资源服务，不落长期 Store。
- 现有 `SongAPI`、AI 写歌和 AI 改编测试无行为变化。

## 10. 编码注意事项

继续使用当前项目序列化和错误处理方式；若项目没有代码生成，不为本模块单独引入一套生成框架。公共模型仅在确实共用时扩展，避免把声音克隆字段塞进旧改编 DTO。
