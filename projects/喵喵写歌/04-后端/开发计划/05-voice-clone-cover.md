# B005 翻唱声音克隆

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `waiting_review`；`T-B005-S/R` 均 `pending`。依据[当前 PRD](../../01-需求/v2.1-model-driven-params/requirements.md)、[Java 技术文档](../java-tech.md)、[B001](01-provider-capabilities.md)、[B002](02-effective-contract.md)及[Flutter F004](../../03-前端/开发计划/04-voice-train-and-clone.md)。

## 骨架阶段 / `T-B005-S`

- **现有入口**：`app/catsinger/voicecover/controller/SongVoiceCoverController` 的 `POST /api/song-voice-covers`、`GET /{id}`、`GET /active`，`dto/CreateSongVoiceCoverRequest`、`service/SongVoiceCoverService`。不得改用 `/api/song-covers`；后者是现有歌曲改编。
- **调用图**：Controller 鉴权与 DTO → Service 校验来源二选一、歌曲权利与本人声音授权 → 读取所选具体厂家模型的 B002 契约 → 检查本人/官方音色及精确厂家绑定 → 校验可选设置和媒体硬约束 → B006 重取报价 → 原任务流程入口 → VO。公开请求不带 `mode`，服务端固定 `VOICE_COVER`。
- **骨架行为**：只在 local/test 用集中 Fixture 返回确定的模型、音色、价格及演示任务状态；高层方法保持正式名称与调用顺序，未实现处标 `TODO(REAL-IMPLEMENTATION)`。生产默认禁用新增未完成功能；不能让现有线上翻唱/改编路径返回伪成功。
- **完成**：编译与 Controller/Service 契约测试通过，证明不读写数据库、不冻结积分、不上传/送审、不调用厂家、不保存作品，也不修改旧 `COVER` 任务类型。

## 真实实现阶段 / `T-B005-R`

1. 来源只允许 `sourceWorkId` 或 `sourceAudioAssetId` 二选一；来源属本人且资源可用，整曲时长/格式/大小按所选模型**明确声明**的硬条件和既有平台安全规则判断。沿当前站内资源/审核逻辑，不另建一套素材通道。
2. 只允许已验证的本人音色或已发布官方音色。绑定到精确厂家模型/版本；算道训练音色不推断可跨厂家使用。音色暂不可用时禁止新任务，但历史可用试听及作品保持原规则。
3. 所选模型决定 `coverSettings` 中可设置的键、选项、范围和默认值。服务端在报价/冻结前对有效契约重新校验；不支持、越界、互斥或能力未知的可选键返回字段级错误。仅提交用户实际填写且有效的最小参数；不能由 `normalized()` 把默认值误认成客户端请求，默认值由服务端契约独立应用并入不可变快照。
4. 重新读取 `contractVersion`、`pricingVersion`、会员与积分，再按已有幂等、冻结、排队、厂家、失败释放、资源持久化、审核、作品链路执行。厂家已受理后的超时按已有提供商阶段规则，不把平台排队计入厂家 10 分钟处理窗口。
5. 成功只在最终资源已转存、审核且真实可播放后成立。旧 AI 改编仍走原 `COVER` 流程，不能改型、迁移或共享翻唱声音克隆的音色选择语义。

## 接口、数据、失败与测试

| 接口 | 正式请求/响应 | 关键错误与权限 |
|------|---------------|----------------|
| `GET /api/song-config/models?sceneCode=song.voice.cover.generate` | 模型、真实 `provider/model`、`musicContract`、价格 | `X-App-Code: catsinger`；无能力时可选设置 `NOT_DECLARED` |
| `POST /api/song-voice-covers` | `sourceWorkId? / sourceAudioAssetId? / voiceModelVersionId / provider / model / modelOptionId / pricingVersion / coverSettings / songRightsConfirmed / voiceConsentConfirmed / idempotencyKey`；如增加 `contractVersion`，先更新本版公共契约 | 用户 JWT；来源、授权、音色/模型、报价及幂等分别返回现有错误类别；`VOICE_ROUTE_MISMATCH` 不可降级选其他模型 |
| `GET /api/song-voice-covers/{id}`、`/active` | 原有翻唱任务详情/活动任务；成功时关联作品 ID | 仅本人，跨 App、跨用户不可查询 |

复用现有 `catsinger_song_voice_model_versions`、`catsinger_song_voice_provider_bindings`、声音克隆任务、歌曲作品、积分/审核/资源表。骨架无迁移；真实实现优先不加表，快照缺口仅按[B006](06-pricing-snapshot.md)证据处理。定向测试至少覆盖来源二选一、无权/未审核、授权缺失、同厂兼容与跨厂不兼容、禁用/越界参数、默认值与最小请求、报价过期、幂等、失败退款、旧改编不改型及最终作品可播放；设备播放留第 15 步。
