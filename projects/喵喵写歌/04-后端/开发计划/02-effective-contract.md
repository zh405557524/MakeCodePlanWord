# B002 有效能力契约与模型目录

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `done`（编码依据）；`T-B002-S=in_progress`、`T-B002-R=pending`。依赖[Provider B001](01-provider-capabilities.md)、[Flutter F001](../../03-前端/开发计划/01-contract-and-fixture.md)、[Admin W001](../../03-前端/开发计划/06-admin-capabilities.md)。

## 骨架阶段 / `T-B002-S`

- **代码落点**：现有 `core/ai/aiconfig/service/AiSceneModelMappingService`、`vo/AiMusicContractResponse` 与 `app/catsinger/voicecover/service/VoiceCoverConfigService`、`vo/VoiceModelOptionResponse`。在现有服务中新增单一有效能力合成步骤，不造第二套目录/报价服务。
- **调用链**：Controller 读取场景模型 → Service 解析真实 provider/model → B001 描述操作能力 → 合成后台子集 → 构造现有包络与增量 `musicContract`；集中 Fixture 只在 local/test 给固定版本、原因、有效参数和媒体约束。`TODO(REAL-IMPLEMENTATION)` 对应 B002-R 的真实映射、子集、版本与权限。
- **目标响应**：保留现有 `operationType/status/parameters`，追加 `contractVersion`、`effectiveParameters[]`（`key/supported/editable/reasonCode/reasonText/constraints/effectiveDefault`）和 `mediaConstraints`；声音模型增同义 `musicContract`，旧 `capabilityLimits` 暂留兼容。`contractVersion` 与现有 `pricingVersion` 独立。新增字段是同版本技术方案的**待实现契约**，不能在骨架测试外假称生产已返回。
- **骨架完成**：模型查询支持、未知/停用/缺价及旧响应的结构测试通过；响应不含私有 token、厂家原始字段/模型文件 URL；生产不返回 Fixture；Controller 不访问新增表或冻结积分。

## 真实实现阶段 / `T-B002-R`

1. 按当前 `X-App-Code` 和 `sceneCode` 解析启用映射，取 B001 的精确模型/操作声明；与固定业务字段目录及 Admin 允许的展示/启用/枚举/范围/默认值取**交集**。后台只能收窄；配置扩大、未知键、下界高于上界或默认越界时保存拒绝，旧不合法配置读出标冲突而不是扩容执行。
2. 合成稳定 `contractVersion`，同一有效配置重复读取不变，厂家声明或后台收窄变化后变；空/过期版本的请求仍服务端重验。`NOT_DECLARED` 时所有可选参数禁用；业务基础输入只有另有证据证明操作可执行时才可最小提交。
3. 训练/源音频硬媒体限制与已确认平台安全限制作交集；未知厂家上限用 `null`，不当无限制开放高级设置，也不因效果建议阻断基础训练。音色按精确绑定而非同厂推断兼容。
4. 保持既有响应包络、公开 `modelOptionId` 和价格字段；旧客户端未读新增字段也必须在创建时经 B003～B005 重验。跨 App、停用模型、删后台配置时缓存失效且新任务看新版本；历史任务快照不改。

## HTTP 契约、数据与错误

| 方法/路径 | 请求 | 响应 | 鉴权/失败 |
|-----------|------|------|-----------|
| `GET /api/ai-model-options?sceneCode=song.generate|song.cover.generate` | 合法场景码，`X-App-Code` | 现有模型选项数组，含扩展的 `musicContract`、原价格/版本 | 旧鉴权策略不变；场景不合法按 `BAD_REQUEST`，跨 App 拒绝 |
| `GET /api/song-config/models?sceneCode=song.voice.train|song.voice.cover.generate` | 训练或克隆场景码，`X-App-Code: catsinger` | `VoiceModelOptionResponse[]`，追加同义 `musicContract`，保留旧 `capabilityLimits` | 当前 `SongVoiceConfigController` 非允许场景抛 `BAD_REQUEST`；跨 App 拒绝 |
| Admin 现有 `/api/admin/ai-scene-model-mappings` | 当前 App/管理块、映射及能力子集 | 厂家只读能力与有效子集，保存仍用原包络 | 越界/旧版本拒绝保存，403 表示越权，不伪装登录失效 |

复用现有 `ai_scene_model_mappings.metadata_json`、模型/计费配置；**无新表和迁移**，骨架期更不访问真实库。Admin 的 `metadataJson` 需解析命名空间且保留图标/排序旧字段；数据库 schema routing 与管理块二次授权由现有层承担。测试：四场景正常/空/禁用/跨 App、厂家与后台范围交集、稳定版本、公开响应脱敏、旧客户端与 Admin 越界/权限拒绝；每个查询含成功和错误路径。

## 2026-09-14 骨架恢复点

`AiMusicContractResponse` 已兼容追加 `contractVersion/effectiveParameters/mediaConstraints`，`VoiceModelOptionResponse` 已兼容追加 `musicContract`；旧构造器序列化不增加空字段。集中 Fixture 已能构造四场景确定响应，但尚未接入 `AiSceneModelMappingService`/`VoiceCoverConfigService` 的显式 local/test 查询，因此 B002-S **未完成**。接入前须保证四条创建路径在骨架模式下不会执行真实数据库、积分或厂家调用。
