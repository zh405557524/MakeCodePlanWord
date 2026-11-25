# B004 本人音色训练媒体与能力校验

## 2026-09-17 任务落库后异步审核（当前结论）

- `POST /api/song-voice-training-tasks` 与 `/prepare` 扩展可选 `materialResources`；旧 `materialAssetIds` 保留兼容。两种输入必须且只能提供一种，混用、空输入或重复资源在扣费和 Provider 调用前拒绝。资源项包含 `resourceId/originalFilename/durationMs`。
- `POST /api/song-voice-training-tasks/{id}/read` 扩展可选 `readResource`，旧 `assetId` 保留兼容。服务端校验资源归属、App、音频类型、READY 上传状态、模型契约及短句版本，不相信客户端审核状态。
- 原始资源只经过 `/api/resources/exists → direct-upload/prepare → OSS → direct-upload/complete` 确保传输完成；该链路不触发内容审核。创建任务事务内将资源绑定为 `SongAsset`、创建 `PENDING_REVIEW` 的 `VoiceMaterial`、固化幂等输入并冻结克隆训练积分，随后返回 `QUEUED`。事务内不调用审核或训练 Provider。
- 资源是否可复用只由服务端本次查询决定，App 缓存的 `resourceId` 不构成成功凭证。`/api/resources/exists` 按当前 App schema、当前用户、资源用途、媒体类型、MD5、大小、READY 状态及物理 OSS 对象存在性查询；任务创建时再次校验资源归属、App、用途、OWNER 访问域和 READY 状态。客户端每次重试都须重新查询；命中才跳过 OSS，未命中才上传。
- 后台执行器领取任务后执行 `QUEUED → REVIEWING_MATERIAL`，幂等提交/查询审核。审核通过后才将素材置为 READY 并提交训练；内容拒绝进入 `REJECTED`、释放冻结积分且不调用训练 Provider；审核服务异常进入 `FAILED`。Voice 初始样本通过后进入 `AWAITING_READ`，最终朗读提交后也由执行器审核再创建 Voice 音色。
- `REVIEWING_MATERIAL`、`REJECTED` 已加入活动任务、租约调度、列表最新任务映射和 Admin 中文筛选。现有 `status/stage/progressPercent/failureReason` 继续承载状态，不新增数据库表、字段或 Flyway/SQL。
- 后端 `VoiceCoverBusinessIntegrationTests` 全类通过，新增覆盖原始资源异步审核拒绝、审核异常、积分释放及训练 Provider 未被错误调用。未执行正式环境 SQL、部署或真实付费 Provider 任务。

## 2026-09-16 任务场景与音色库纠偏（当前结论）

- 训练任务 App/Admin 响应新增可空 `sceneCode`，仅返回 `song.voice.create` 或 `song.voice.train`。服务端根据已保存业务事实统一推导；新客户端和后台不再根据中文名称、路由缺省值或厂商模型名称决定业务跳转。
- 历史任务仅在证据唯一时兼容推导：Voice 创建模型和克隆训练模型冲突时返回未知，不允许跨库使用。Admin 训练列表按响应场景展示“Voice 音色创建”或“AI 声音克隆－训练”；`song.voice.cover.generate` 仍属于歌曲生成任务。
- `/api/song-voices` 继续按场景、产物类型和精确模型兼容性过滤 Voice/克隆音色；阶段为“已丢弃定制”的临时记录始终隐藏，避免客户端清理重试期间重新出现在列表。
- Voice 链路保持 `creation-models → prepare → read-phrase → creation-quote → read`，克隆链路保持 `song.voice.train → training task → song.voice.cover.generate`；现有 `song.cover.generate` AI 翻唱不被 `sovits_cover` 替换。
- 错误能力、模型或产物仍须在扣费和 Provider 调用前拒绝。Voice 最终朗读、克隆训练和克隆使用分别使用各自报价与幂等控制，准备样本、短句获取和查询不新增收费。
- 本轮没有新增数据库字段、表或 SQL；工作区原有迁移改动原样保留。后端业务、目录与映射三个定向测试套件通过，未部署或执行真实付费厂商任务。

## 2026-09-16 能力分类调整

- 后端/后台统一四项：AI 翻唱 `song.cover.generate`、AI 声音克隆－训练 `song.voice.train`、AI 声音克隆－使用 `song.voice.cover.generate`、Voice 音色创建 `song.voice.create`。
- Voice 创建从克隆训练目录独立，保留分步短句流程与最终朗读计费。克隆训练提交干声、不要求旧自建验证；克隆使用仅接受有效克隆产物。配置、请求与产物类型均需匹配，不能只校验厂商。
- 旧映射仅只读兼容，已有配置和价格不自动重写；新配置经后台显式保存。后台任务新增能力筛选，音色绑定显示业务类型并拒绝跨类型混绑。
- 当前无需新表/用途字段/SQL；保留历史数据、迁移和订单。若后续发现持久化依赖须先披露方案，禁止直接执行正式库。
- 本节覆盖历史混用表述，完整验证及边界见 [三端交付记录](../../05-联调与测试/20260916-ai-music-capability-split.md)。

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `waiting_review`；`T-B004-S/R` 均 `pending`。对齐[PRD P08～P10](../../01-需求/v2.1-model-driven-params/requirements.md)、[Flutter F004](../../03-前端/开发计划/04-voice-train-and-clone.md)、[B001](01-provider-capabilities.md)、[B002](02-effective-contract.md)。

## 骨架阶段 / `T-B004-S`

- **现有类**：`app/catsinger/voicecover/controller/SongVoiceTrainingController`、`dto/CreateVoiceTrainingRequest`、`service/SongVoiceTrainingService`，继续 `POST /api/song-voice-training-tasks`、`GET /{id}`、`GET /active`；本人音色资料/素材按 `SongVoiceProfileService` 与现有资源入口管理。
- **方法调用**：校验 user/App/本人资料 → B002 当前训练模型/能力 → 逐条素材硬媒体约束与审核事实 → 权利/风险确认 → B006 报价 → 旧训练任务服务。骨架只建立清楚的步骤方法与正式 DTO/VO，固定训练模型/媒体结果由 local/test 集中 Fixture 返回；`TODO(REAL-IMPLEMENTATION)` 对应 B004-R。
- **现状缺口**：当前 DTO 的 `materialAssetIds` 有 `@Size(max=20)`、`qualityWarningConfirmed` 字段，现有逻辑还有分钟门槛。骨架须明确这些是**待对账的旧限制**，不能把固定 20 段、1～5/1～10 分钟或“5 分钟效果建议”当作本版厂家硬规则。先保留旧生产行为，不在骨架中真实改训练/上传。
- **完成**：编译、Controller 正常/权利缺失/非法场景、Service 步骤顺序与生产 Fixture 禁用测试通过；无新增 Flyway/Entity/Repository，无真实数据库、审核、积分或 Provider 请求。

## 真实实现阶段 / `T-B004-R`

1. 从 B001 精确 `song.voice.train` 模型取明确媒体硬条件：至少一条可用素材、厂家支持格式/大小等；同时保留已确认的平台资源安全/审核约束。厂家未声明单段/累计时长或片段数时不得继续把旧固定限制当“厂家规则”；逐条核实 `@Size(max=20)` 是否另有平台安全依据，无依据则经现有请求兼容与风险测试后移除/调整。
2. 素材时长/格式/大小以已审核资源台账事实为准，不信客户端显示或请求声称；仅本人音色可训练，图片/音频/文字安全审核及所有者权限沿原资源链路。效果建议可以给 UI 提示，但不足建议长度不要求 `qualityWarningConfirmed` 才能提交。
3. 训练创建前重取 `contractVersion/pricingVersion`、会员/权益和积分，幂等后走旧任务、排队、Provider、资源保存及失败释放。`NOT_DECLARED` 可选设置置灰，基础训练只有厂家可执行证据存在时可用；音色模型文件生命周期按原声音克隆链路，不新建第二套。
4. 成功后音色只在精确兼容的厂家模型可选；失败/超时/资源保存失败准确反映并释放原冻结。旧音色与历史作品不因新配置变化被删除。

## 接口、数据、错误与测试

| 方法/路径 | 请求 / 响应 | 鉴权与失败 |
|-----------|-------------|------------|
| `GET /api/song-config/models?sceneCode=song.voice.train` | 训练模型选项、价格和目标 `musicContract.mediaConstraints` | `X-App-Code: catsinger`；非法场景 `BAD_REQUEST` |
| `POST /api/song-voice-training-tasks` | `CreateVoiceTrainingRequest`：旧 `materialAssetIds` 或新 `materialResources` 二选一，并携带 `voiceProfileId/provider/model/modelOptionId/pricingVersion/rightsConfirmed/riskConsentConfirmed/idempotencyKey`；旧 `qualityWarningConfirmed` 兼容 | 用户 JWT；资料无效 `VOICE_PROFILE_NOT_FOUND`，资源/素材无效 `VOICE_MATERIAL_INVALID`，权利 `VOICE_CONSENT_REQUIRED`，过期价 `VOICE_QUOTE_EXPIRED` |
| `GET /api/song-voice-training-tasks/{id}`、`/active` | 现有 `VoiceTrainingTaskResponse` / 列表 | 仅本人；不存在 `VOICE_TRAINING_NOT_FOUND` |
| `POST /api/song-voice-training-tasks/{id}/read` | 旧 `assetId` 或新 `readResource` 二选一；成功后返回已入库异步任务状态 | 仅本人；校验场景、短句版本、资源归属/App/类型/READY 状态 |

复用 `catsinger_song_voice_profiles`、`catsinger_song_voice_materials`、`catsinger_song_voice_training_tasks` 及现有资源/积分表；**骨架不碰数据库**，真实阶段优先不加迁移，必要的不可变快照只按[B006 证据门禁](06-pricing-snapshot.md)处理。测试含短但合法素材、格式/大小边界、未知上限、旧 `@Size` 兼容、审核未过、授权缺失、模型下架、报价过期、幂等/退款、跨 App 与旧音色可用性；每接口含成功与错误路径。
