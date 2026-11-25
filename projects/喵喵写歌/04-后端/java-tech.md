# 喵喵写歌 V2.1 Java 后端技术文档

## 2026-09-15 音色卡片契约修复增量

本增量已获用户明确授权直接实施。`GET /api/song-voices` 过滤无训练任务、无模型版本的个人临时资料；详情仍供验证与素材流程使用，不批量删除历史记录。`VoiceProfileResponse` 新增可空 `latestTrainingTaskId/latestTrainingStatus/latestTrainingStage/latestTrainingProgressPercent/latestTrainingFailureReason`；`currentTrainingTaskId` 继续表示活动任务。活动状态补齐 `AWAITING_READ/SUBMIT_UNKNOWN`，删除保护与列表任务 ID 一致。失败终态仍投影最新任务；旧模型可用时不覆盖场景可选性。重训复用原创建接口、报价和幂等，不新增重试接口。

数据库改动：无表结构、迁移或批量数据清理；用户确认丢弃/删除继续调用现有软删除。后端先更新，再发布 App；当前运行服务仍需重启加载代码。MockMvc 与 OpenAPI 契约测试属于本地验证，不代表真实 Provider 训练或试听已验收。

> 文档版本：`v2.1-model-driven-params` · CHG-0076 原文 `done` / CHG-0078 首页增量 `waiting_review` · 阶段 08 · 更新：2026-09-14
> 依据：[当前 PRD](../01-需求/requirements.md)、[技术方案](../02-技术方案/tech-plan.md)、[增量工时](../02-技术方案/effort-estimate.md)、[Flutter/Web 技术文档](../03-前端/flutter-tech.md)。旧 CHG-0073 Java 计划已在[归档](../archive/CHG-0077-legacy-docs-20260913/README.md)，不能用其完成状态推动本版编码。
> 实施状态：本文件只定义当前版本**目标设计与代码差距**。本步不修改 Java、Flyway、配置、数据库或线上环境；`skeleton_first` 门禁继续有效。

## 1. 工程结构与既有能力

后端仍是 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 的 Java 21 / Spring Boot 3 / Gradle / MyBatis-Plus / PostgreSQL 模块化单体，包名 `com.lxwx.narrateservice`。`X-App-Code: catsinger` 进入现有 `AppContext` 与 schema routing；不能在 narrate schema 创建 Catsinger 业务表。沿用 `ApiResponse`、现有错误处理、鉴权、审计、积分、审核、资源、歌曲工作流及作品链路，不按通用模板新建一套 Controller/Service/Mapper 层。

| 现有目录/类 | 当前事实 | 本版职责 |
|-------------|----------|----------|
| `thirdparty/aimodel/music/`：`IMusicModelService`、`MusicOperationContract`、`MusicParameterDefinition/Constraints` | 已声明 `MUSIC_GENERATION`、`MUSIC_COVER` 两项查询，精确模型可能为 `NOT_DECLARED` | 增加训练和**声音克隆翻唱**两项独立操作声明；提供厂家硬限制，不承载 App 业务、价格或后台展示 |
| `core/ai/aiconfig/service/AiSceneModelMappingService` | `/api/ai-model-options` 已可为写歌/改编附 `musicContract`，其他场景返回 `null` | 在现有场景映射上合成 Provider 与后台子集，返回统一有效契约 |
| `app/catsinger/voicecover/service/VoiceCoverConfigService` | `/api/song-config/models` 以映射 `metadata` 作为 `capabilityLimits` | 训练/克隆场景也读同一合成服务；旧字段只为兼容，不作厂家能力真源 |
| `app/catsinger/generation/`、`cover/`、`voicecover/` | 三项业务有各自公开创建入口；声音训练是克隆独立步骤 | 各自 Service 在报价冻结和异步提交**之前**复核模型能力与请求；绝不改写旧改编任务类型 |
| `admin/aimodel/`、`admin/song/` | 场景映射含 `metadataJson`，已有模型、价格与歌曲配置 | Admin 对能力只读、对子集合法编辑；App/角色/版本/审计由现有后台链路保障 |

当前 `AiMusicContractResponse` 只有 `operationType/status/parameters`；当前声音模型响应没有同语义 `musicContract`。`VoiceCoverSettings.normalized()` 会给未填可选值补默认；训练业务还有固定分钟门槛和效果风险确认。这些都是本版**待调整点**，不能表述成已完成。

## 2. 业务与操作边界

| 业务 | 场景码 | 提交接口 | Provider 操作声明 | 不可混用项 |
|------|--------|----------|-------------------|------------|
| AI 写歌 | `song.generate` | `POST /api/song-generations` | `MUSIC_GENERATION` | 无源歌曲时不走改编/克隆任务 |
| 歌曲改编 | `song.cover.generate` | `POST /api/song-covers` | `MUSIC_COVER` | 旧 `COVER` 任务/作品保持改编含义 |
| 本人音色训练 | `song.voice.train` | `POST /api/song-voice-training-tasks` | 拟增 `VOICE_TRAINING` | 不把训练状态伪装为歌曲作品 |
| 翻唱声音克隆 | `song.voice.cover.generate` | `POST /api/song-voice-covers` | 拟增 `VOICE_COVER_GENERATION` | 不接收旧改编的 `mode`；服务端固定 `VOICE_COVER` |

同一 `provider/model` 在四种操作下的支持情况互不推导。同厂 SoVITS 音色到 Suno 写歌未被证明，保持不兼容；本期只为实际有依据的算道精确模型声明支持，其余 `NOT_DECLARED`。厂家描述是**能力上限**，后台配置只可缩小，不可扩大。`generation-options` 的 App 级标签绝不能替代模型契约。

## 3. 统一有效能力与接口契约

### 3.1 Provider 声明

保留 `MusicOperationContract(target,operationType,status,parameters)` 的厂家标准能力语义，在 `IMusicModelService` 增加训练和克隆翻唱的描述方法，或在现有查询抽象中按操作分发；实施时以**一个**能力接口为准，不并存两套同义服务。新增的标准键只覆盖需求实际出现的训练媒体、克隆源歌曲、移调、人声/伴奏音量、输出格式及模型明确支持的选项。数值统一使用标准单位（毫秒、字节、半音、倍率），在 Provider adapter 中转换成厂家字段。

`SUPPORTED` 仅表示有证据的精确模型/操作；明确不支持为 `UNSUPPORTED`，无可信声明为 `NOT_DECLARED`。未声明上限使用 `null`，不能按“无限制”开放设置，也不把厂家效果建议如“干声累计超过 5 分钟效果较佳”提升为训练阻断规则。Provider 实际请求前还要做一次标准参数白名单校验，防止业务层漏检。

### 3.2 有效契约合成

建议在现有 `core/ai/aiconfig` 下增加单一合成服务，签名表达为 `resolve(appCode, sceneCode, modelOptionId)`：

1. 在当前 App/schema 下解析启用的场景映射和真实 `provider/model`，取得 Provider 对该**操作**的声明。
2. 与固定业务字段目录、后台允许的展示/启用/选项/范围/默认子集求交集；校验下界不大于上界、默认值位于交集、枚举值属于厂家集合。没有交集则禁用该字段并给机器可读原因。
3. 合成 `effectiveParameters` 与独立 `mediaConstraints`，对源音频再交叉平台已确认的整曲 10 分钟上限和既有上传安全限制；区分“平台上传限制”与“所选模型限制”。
4. 生成与输入内容、Provider 声明版本、后台配置版本相关的稳定 `contractVersion`；不得用当前时间伪造版本。同一配置重复读取版本不变；后台或厂家能力变化后版本变化。
5. `VoiceProviderBinding` 按**精确兼容关系**筛音色；厂家同名不等于模型兼容。无法证明的绑定返回禁用原因，不用 App 猜。

`NOT_DECLARED` 时所有可选项均不可编辑。若现有路由/适配器另有独立证据证明业务最小输入可执行，才允许仅业务必需字段的最小提交；业务操作本身无证据或已下架，直接禁用。实现时应把这份最小白名单写成按操作的显式规则，不在 `metadataJson` 中任意开启。

### 3.3 公共响应的增量字段

与[Flutter 技术文档](../03-前端/flutter-tech.md)约定同一 wire shape。现有 `AiMusicContractResponse.operationType/status/parameters` 保持含义，并**追加**可选 `contractVersion`、`effectiveParameters[]`、`mediaConstraints`；`VoiceModelOptionResponse` 追加同一 `musicContract`，原 `capabilityLimits` 暂保留兼容，但不参与权威判定。对外字段只包含标准键、布尔状态、原因码/安全文案、有效范围/选项/默认、必要媒体限制；不含密钥、内部计费编码或声音模型文件 URL。

`effectiveParameters[]` 每项至少有 `key/supported/editable/reasonCode/reasonText/constraints/effectiveDefault`。`supported` 表示厂家该操作支持，`editable` 还取决于后台启用；UI 的“纯音乐开启”“缺参考音频”等瞬时互斥由客户端叠加，服务端提交仍复核。旧响应不带新增字段时新客户端可选项禁用；旧客户端无 `contractVersion` 时服务端仍重验请求，不静默信任旧值。公开请求 DTO 仅**增补可选** `contractVersion`，不改已有字段的意义；正式修改前逐 Controller/DTO 校对并补 `/v3/api-docs` 契约测试。

### 3.4 后台配置

继续使用现有 `GET/POST/PUT /api/admin/ai-scene-model-mappings` 与模型/计费管理入口。`AdminAiSceneModelMappingRequest.metadataJson` 目前是字符串，不能以“浏览器结构化表单”替代服务端安全校验：在现有保存 Service 中解析预留命名空间（拟 `musicCapabilityOverrides`），按标准键白名单及 Provider 交集验证；只保存合法的可见性、启用、范围和默认，拒绝未知键/越界/过期 `contractVersion`。既有非能力元数据原样保留，避免破坏图标、排序或其他 App 配置。

Admin 读取可返回厂家只读能力和当前有效子集；如需新增只读接口，也须沿现有 `/api/admin/ai-model-options` 或场景映射体系扩展，不建立第二套配置表。超级管理员和普通角色按现有管理块授权；保存、发布与下架均按 App、场景、模型记录操作者和版本。切 App 后所有读写必须重新用当前 `X-App-Code` 路由，不能仅靠 Web 前端隐藏菜单防越权。

## 4. 创建任务前的服务调用链

```text
各业务现有 Controller
  -> 读取当前 App/用户/场景和请求 DTO
  -> 解析本次模型选项与真实厂家模型
  -> 重取有效契约 + 价格版本，比较 contractVersion/pricingVersion
  -> 校验业务必需字段、每个已提交可选参数、互斥与媒体/音色兼容
  -> 校验资源所属/审核事实、版权授权、会员和幂等
  -> 调用现有报价/冻结及任务创建服务
  -> 委托既有 songworkflow/训练工作流与 Provider adapter
  -> 既有资源持久化、成品审核、真实可播放验证、结算或失败释放
```

“提交前校验”必须在积分冻结和厂家调用之前，并在服务端完成；前端置灰和浏览器禁用只提高可用性。校验必须遍历请求中**实际出现**的每个可选键；不支持/越界/未知/业务互斥字段一律返回有参数键与原因的业务错误，不能忽略后继续生成。幂等键仍沿现有创建链路，重复请求不得重复冻结或创建任务。任务一旦创建，模型路由、有效请求与报价快照不可随后台配置变化重写。

### 4.1 各业务差异

- **写歌**：简易/专业共同使用 `song.generate` 能力；纯音乐开启时本期人声和歌词互斥，服务端拒绝新请求里仍携带的互斥值。专业写歌指定音色已延期至下版，V2.1 客户端不展示或提交该参数；既有后端兼容校验不因本轮文档调整而删除。
- **改编**：仅 `song.cover.generate`；“保留原歌词”关闭时不暗送来源旧词，输入新歌词或明确的 AI 补词结果。指定音色入口同样延期；源音频引用及审核事实沿现有改编逻辑，不新增另一条审核/任务流水。
- **训练**：仍走 `voicecover/` 的本人音色资料、素材与任务。检查厂家明确的格式、总大小、至少一条有效素材等硬限制以及现有平台上传安全限制；移除无厂家依据的单段 1～5 分钟、累计 1～10 分钟硬门槛和小于 5 分钟强制 `qualityWarningConfirmed` 门槛。效果提醒可以展示，不决定能否提交。
- **声音克隆翻唱**：仍走 `voicecover/` 的独立创建接口。`VoiceCoverSettings.normalized()` 不得把未选择的移调/音量默认值注入“已提交可选参数”；可在 Provider 内部按其缺省执行，但任务快照只记录实际有效请求。固定 DTO 注解不能替代精确模型范围校验；源歌曲整曲 ≤ 平台 10 分钟与模型更严上限，音色必须与模型真实兼容。

厂家接单后的 10 分钟处理时限与平台排队边界沿现有工作流；本版参数调整不改时钟起点。厂家临时 URL 必须先按现有资源抽象转存并确认实际 MIME/时长与可播放、完成审核后才能成功结算；Provider 返回 200 或任务状态成功不是交付成功。

## 5. 数据库改动

**本技术文档阶段：无数据库改动；不得提前创建迁移、Entity 或 Repository。** 真实实现优先复用现有 `ai_scene_model_mappings.metadata_json`、计费目录、`normalizedRequestJson`、声音资料版本/绑定、资源台账及任务快照。Admin 配置不另建表，所有用户数据仍由 catsinger schema 隔离。

实施前必须核实训练任务现有字段是否可无歧义地保留有效请求/能力版本快照。若不能，先在第 10/12 步模块计划中写出证据、旧数据兼容与查询路径，再只在 `db/migration/catsinger/` 新增**最小不可变快照字段**的增量迁移，并同步 Entity/Repository/测试；若现有字段足够，取消 SQL 工作。不得改已发布 V1/V12，不在 `common` 或 `narrate` 建声音克隆表。模型/配置变动只影响新任务，历史账务和作品不重算。

## 6. 错误、鉴权与安全

| 条件 | 客户端可见结果 | 后端处理 |
|------|----------------|----------|
| 参数不支持/越界/互斥 | 指向字段的说明并保留可恢复草稿 | 拒绝创建；不冻结积分、不调用厂家 |
| `contractVersion` 或价格版本过期 | “设置或价格已变化，请重新确认” | 重取当前能力/报价；不得按旧价扣费 |
| 模型已下架/能力未声明且基础操作无证据 | “当前模型暂不可用” | 禁止创建；不靠调用厂家试探 |
| 音色不兼容/未就绪或资源审核未过 | 告知可重新选音色/资源 | 保持本人/官方、当前 App、审核与模型绑定校验 |
| Admin 越权或跨 App | 403 或明确的 App 不匹配 | Service 再校验角色、管理块及 `AppContext`，记录审计 |
| 已创建任务的 Provider/转存/审核失败 | 真实任务失败与可定位原因 | 沿现有补偿释放积分，不写伪成功作品 |

继续使用 JWT 与独立 Admin token、`X-App-Code` schema routing、现有敏感日志脱敏和权限机制。公开模型目录只返回标准能力，不公开厂家原始请求、token、私有音频/模型文件地址。管理端保存记录操作者、App、业务场景、模型、变更前后有效版本；任何图片、音频和可展示文字仍按现有资源安全审核事实使用。

## 7. 项目专属实施规则与任务

- **继承**工作台 Java 01～10：现有模块化单体、Controller → Service → Mapper 分层、事务/审计/鉴权、Flyway 只追加迁移、Provider 适配器边界；裁剪通用新项目初始化模板，不重新生成用户/登录/积分表。
- **跨端契约门禁**：新增 wire 字段先同步本文件与 Flutter 文档。`AiMusicContractResponse` 是现有基础响应，不另建同义公共响应；扩展时保留旧字段和值含义，并覆盖 `/v3/api-docs` 与旧客户端解析。
- **骨架阶段**：CHG-0076 `skeletonTargets=flutter,java,web`，先做第 9～12 步模块文档与 `-S/-R` 分解。骨架可编译，但只能 local/test 固定数据、生产禁用；不触库、积分、审核、上传、Provider、迁移或作品。整体进入 `skeleton_review` 后停下，必须得到用户明确骨架确认才可做真实实现。
- **真实实现阶段**：先 Provider 精确声明/有效能力合成，再 Admin 合法收窄和四业务创建前校验，最后页面联调。对线上 Bug 的独立修复不被本版骨架门禁阻塞，但不能顺便改动本版业务代码。

| 任务 | 目标代码域 | 核对点 |
|------|------------|--------|
| T-B001 | `thirdparty/aimodel/music/` | 四操作、标准键、精确模型声明、未知不伪称支持 |
| T-B002 | `core/ai/aiconfig/`、`voicecover/vo` | 同一有效能力合成、版本、脱敏、旧响应兼容 |
| T-B003 | `app/catsinger/generation/`、`cover/` | 写歌/改编请求逐参数校验与互斥，旧业务类型不变 |
| T-B004 | `app/catsinger/voicecover/` 训练 | 厂家硬媒体边界与效果建议分离 |
| T-B005 | `app/catsinger/voicecover/` 翻唱 | 音色兼容、整曲、缺省值与真实请求分离 |
| T-B006 | 模型/计费/快照及必要时 catsinger 迁移 | 过期版本、冻结前拒绝、任务快照不变、无重复扣费 |

## 8. 验证计划与待核验项

文档阶段只核对路径、两端字段和计划一致性，不把未运行的测试写成通过。后续真实编码按受影响范围运行定向 Gradle 测试，公共能力变更扩到四场景/跨 App 回归；无需因纯文档阶段执行 Gradle。

| 验证层 | 必须证明的行为 |
|--------|----------------|
| Provider/合成 | 算道已证实模型、未知模型 `NOT_DECLARED`、`UNSUPPORTED`、参数范围/默认交集、合同版本稳定且变更后刷新 |
| Controller/Service | 四场景接口各守业务边界；缺 `X-App-Code`/错误 App 被拒；禁用、越界、旧字段、旧版本在冻结前失败；幂等无二次扣费 |
| Admin | 同 App/跨 App 权限、越界保存拒绝、旧配置因厂家收缩标冲突、价格和音色切换只影响新任务 |
| 工作流 | 训练短素材符合硬条件可提交；源资源审核、音色绑定、厂家失败释放、持久化和实际可播放验收 |
| 联调 | Android+iOS 三业务/训练/后台改配置用户流；旧改编、历史作品和 narrate schema 不串；iOS 真机优先、模拟器兜底，均不可用则双平台验收不通过 |

待核验：算道 SoVITS 音色与具体 Suno 写歌模型是否兼容；各精确模型的厂家硬媒体限制及实际响应；非模型设置是否影响计费。缺证据时相应可选设置继续禁用，不让产品负责人凭猜测提供数值，也不把未验证能力写成生产已开放。

## 9. CHG-0078 首页、建号赠额与新人礼技术增量

### 9.1 已有链路和实现范围

仍沿用 `X-App-Code: catsinger` 的 `AppContext` / schema routing、`app_configs`、现有 Spring Controller → Service → Mapper、资源审核、管理块授权及积分记账。`UserService.createUser` 已在建号后调用 `grantDefaultPointsForNewUser`，游客与首次手机号新建账户走同一调用链，`bindGuestPhone` 保留原 `userId` 不重发，`PointsService.grantPermanent` 以 `NEW_USER:{userId}` 幂等。CHG-0078 仅对 **catsinger 的赠额读取**做增量，不重新定义注册时点或重发历史；其他 App 保留当前行为。现有 `PublicAppConfigController` 没有本节读接口，`AdminConfigService.upsert` 通用写入口尚无本节三个 key 的统一校验，均为待实现而非既有能力。

### 9.2 配置与内容发布

| key / 归属 | 存储载体和建议 JSON 字段 | 后端规则 |
|------------|--------------------------|----------|
| `song.home.banners` | catsinger 的 `app_configs`，`items[{id, resourceId, sortOrder, enabled, targetCode?}]` | 保存**整份文档**时在事务内校验稳定 ID/顺序/目标白名单/素材已审核可访问，至少一张启用有效；并发发布用配置版本比较，禁止两请求各自删停最后一张 |
| `song.new_user_points` | 同 schema，`{points}`，Catsinger 的 `service-data/apps/catsinger/app-configs.json` 初始值 30 | 正整数/后端上限校验；读取缺失、禁用或内容无效回退 30 并告警；数据库连接或发积分故障不伪装成配置无效 |
| `song.new_user_gift` | 同 schema，`{enabled, imageResourceId, textResourceId?, targetCode, audience, frequency, eligibilityStartAt, version}` | 图片/文字先沿用资源审核再发布；`audience` 限会员/非会员/全体，`frequency` 限 `ONCE/DAILY/PER_OPEN`；目标限现有签到/任务路由；上线资格起点首次确定后不得通过改配置后移或回滚历史资格 |

现有 `AppConfigStoreService` 优先数据库覆盖并能读应用默认值；它的 JSON 解析错误会抛错，不能假定其自动回退 30。Catsinger 专用赠额规则服务只捕获内容缺失/校验失败，不能吞数据库或积分调用异常。默认海报须先上传并审核两张图片，缺素材时不以硬编码外链伪造有效配置；运行时图片失效返回不可点占位并告警，案例接口独立工作。`SongCaseEntity.bannerUrl` 是案例素材，不得混作运营海报。

为防止后台绕过页面字段校验，专用 `GET/PUT /api/admin/song/home-banners`、`/new-user-points`、`/new-user-gift` 与现有通用 `PUT /api/admin/configs/{configKey}`（仅针对上述三个 key）统一委托同一个 Catsinger 配置验证/发布服务。写入检查 `AppContext= catsinger`、后台 `song_config` 权限、资源状态、目标白名单、字段上下界与配置版本；操作审计记录操作者/App/差异/发布时间。禁用最后有效海报也属于发布失败。公开 API 只输出已审核可展示的投影，不返回原始 JSON 或私有资源地址。

### 9.3 用户端与 Admin 接口契约（待实现）

保留现有 `ApiResponse` 包络、登录鉴权、错误处理和设备上下文。下面为新接口**建议 DTO/VO 语义**，正式字段名称由本版前后端模块计划定稿并保持一致；不得把这些接口误记为已发布。

| 方法和路径 | 请求 / 数据字段 | 业务保证 |
|-----------|-----------------|----------|
| `GET /api/song-config/home-banners` | `items: [{id, imageUrl, targetCode?}]` 有序 | `targetCode=null` 是静态图；配置故障给明确安全降级，不透内部存储地址 |
| `GET /api/song-config/new-user-gift`（登录态） | 可选本次冷启动 `openId`；数据 `shouldShow, impressionToken?, imageUrl?, text?, targetCode?, configVersion?` | 以建号时间、账号状态、人群、领取态及频次判定；不符合返回 `shouldShow=false`；服务端故障不挡首页 |
| `POST /api/song-config/new-user-gift/impressions` | `{impressionToken, openId?}` | **实际渲染后**确认一次曝光；同令牌重复提交不重复计数，尚未显示不占用额度 |
| `POST /api/song-config/new-user-gift/dismiss` | `{impressionToken}` | 只撤销**该令牌**占用，不写领取态、不赠积分；重复关闭不影响其他曝光 |
| `POST /api/song-config/new-user-gift/claim` | `{impressionToken}`；数据 `claimed, targetCode?` | 原子且幂等写 `claimedAt`，领取资格永久结束；只返回签到/任务目标，**不调用** `PointsService` |
| `GET/PUT /api/admin/song/home-banners`、`/new-user-points`、`/new-user-gift` | 带配置版本的结构化 DTO，读返回可编辑值/审核状态 | 仅 catsinger + `song_config`；配置冲突拒绝覆盖并留审计；通用写入口同验 |

`impressionToken` 是服务器签发的不可猜测一次性标识，绑定 userId、配置版本、有效期和本次弹窗；不要信任前端传来的用户 ID/会员身份。`openId` 只区分一次 App 冷启动，不是新用户身份或跨设备资格依据。首页海报可以按现有公开读取方式读取；新人礼查询/曝光/关闭/领取必须登录。进入创作页面仅导航，不增加新的写歌、改编或翻唱任务接口，也不在首页冻结积分。

### 9.4 资格表、频次和事务

真实实现仅在 `db/migration/catsinger/` **追加**轻量资格状态迁移（不得改历史 V1/V12、common、narrate）。建议按 `user_id` 唯一保存 `claimed_at`、`last_impression_token_hash`、`impression_at`、`impression_day`、`last_open_id_hash`、`impression_config_version`、`impression_active`，并记录必要创建/更新时间；不存积分余额或海报配置。确切字段/索引/表名在第 10/12 步核实既有迁移号与用户键类型后确定。未出现弹窗的用户可不存在状态行，不为历史账号回填。

资格判断：账号 `createdAt` 不早于固定上线资格起点、账号有效、配置启用且人群匹配、`claimedAt == null`。资格起点用 UTC 时间戳持久化且一经上线冻结；`DAILY` 自然日统一按 `Asia/Shanghai` 计算（服务端显式时区，不依赖容器默认时区），`PER_OPEN` 比较本次 `openId`，`ONCE` 在未领取期间只限制已确认的未撤销曝光。默认首次登录展示；后台变更频次只影响后续判断，永不清除 `claimedAt`。不另建跨设备专用身份体系，同一 userId 是唯一资格键。

写操作在 Service 事务内对账号资格行原子创建/锁定并校验配置版本：同账号并发请求最多有一个当前有效曝光；相同令牌确认幂等，不同令牌不能顶掉有效令牌；`dismiss` 只撤销当前匹配令牌，撤销后视为**未消耗**对应频次，其他账号/令牌不受影响；`claim` 在行锁下只置一次 `claimedAt`，先领取后关闭不能清除领取。`GET` 签发或重用仍有效的同账号令牌但不计曝光，进程重启重新查询；过期令牌不能用于领取新资格。客户端「稍后」后本次页面会话抑制立即重弹，下一次符合规则的触发仍可显示。若用户领取后目标失效，资格不重开，返回可读提示。

建号赠额另走现有建号事务和 `NEW_USER:{userId}` 去重键，所用配置金额由 catsinger 规则服务获取；新金额仅影响之后按原代码路径创建的账号，游客绑定与历史账号不重发。配置业务错值降级 30 要打非敏感告警和审计，数据库/积分事务失败按现有错误补偿处理，不当作成功赠送。弹窗领取、曝光、关闭均不可触发新用户赠额、签到或任务奖励。

### 9.5 分层、安全门禁与任务

沿用现有 `app/catsinger/config/` 用户端接口/配置服务、`admin/song/` Admin 接口和 `core/user/service/UserService` 的最小接入点；具体包/类名在模块计划核实。用户端 Controller 只做鉴权/DTO/响应，配置验证、受控 URL 映射、资格原子操作放 Service；持久化通过 catsinger Mapper。图片、可展示文字沿用已有上传/审核流程，审核未过前不发布；不把管理员输入当作前端路由或图片远程地址。日志和审计脱敏令牌/userId，必要的安全排障由受限日志承载。

| 任务 | 骨架 `-S`：仅 local/test 固定响应 | 真实 `-R`：整体骨架获明确确认后 |
|------|-----------------------------------|-----------------------------------|
| T-B007 | 首页海报/后台配置 Controller→Service→集中 fixture；生产禁用 | `app_configs`、资源审核投影、原子发布及通用 Admin 写入口校验 |
| T-B008 | 建号赠额读取接口和校验方法骨架；不改线上建号发放 | 替换 catsinger 固定 30 读取、非法回退/故障区分、保留原流水幂等 |
| T-B009 | 弹窗资格/频次/曝光/关闭/领取方法及 DTO 骨架；不创建资格表 | catsinger 迁移、事务/锁、令牌幂等、真实权限与 App 用户态 |

第 10/12 步仍须按任务拆总体与模块计划，并明确字段、失败码、包路径和调用顺序；原 T-B001～006 进度保留。CHG-0078 文档阶段**不运行迁移、不创建实体或改生产配置**。骨架不得访问 DB、积分、上传、审核或资源服务，固定返回值只放受控 fixture、生产默认关闭；原 CHG-0076 骨架 `skeleton_coding` 进度不受此次回卷影响。合并三端骨架并通过评审前，“继续/下一步”不授权 `-R`。

后续验证：定向测试新账号/游客绑定/重复建号键、正负/非法配置与真正数据库故障、两张到一张/并发删最后图、审核/资源失效、登录/权限/跨 App、单/双设备并发曝光、稍后撤销每日额度、时区边界、领取并发及任务页不重发；必要时对 Catsinger/narrate 路由回归。第 15 步用 Android/iOS 和真实新账号核验到账流水；本节是技术设计，未声称任何代码或设备测试已通过。

## 2026-09-16 本人音色流程实施补充

本节对应用户确认后直接实施的个人音色流程，不改变首页等其他变更的骨架评审状态。个人音色属于平台用户，写歌、改编、翻唱共用 `/api/song-voices`；可用范围仍由同厂商及模型绑定校验，不以同厂商替代模型能力检查，也不直接展示厂商共用账号的音色列表。

新流程：资料独立审核 → 录制/上传本人素材 → `POST /api/song-voice-training-tasks/prepare`（不扣积分）→ 用户主动请求 `/{id}/read-phrase` → 本人录制短句 → `GET /{id}/creation-quote` → 非零费用确认 → 上传并审核朗读 → `POST /{id}/read` → 原任务查询和模型绑定。最终提交携带 `assetId/readRevision/pricingVersion/idempotencyKey`；后端锁任务检查归属、素材审核和当前版本，原子冻结。刷新短句使旧录音失效；重复提交不重复扣费。取消价格确认不上传朗读，不创建正式任务。

新增 `creation-models` 提供可创建模型；旧自建本人验证仅兼容旧任务，不阻挡新录音流程。正式提交前任务返回 `creationPending=true`，不进入公共音色/活动任务列表。用户退出经确认调用 `/{id}/discard`，再按原临时资料清理机制处理，不提供正式任务取消。不修改 AI 翻唱已有歌曲/参数草稿恢复。

数据库开发脚本收口（2026-09-16）：训练任务 `deferred_charge/read_revision/read_submission_key` 直接纳入 catsinger V4.9 建表，默认 false；统一审核任务表纳入 common V4.8，移除本轮冗余 V4.12/V4.11。依据正式发布记录与留存包 `45f0fd2e` 不含这两份基础脚本、首次加入提交为后续 `a4f189d9`，按未正式执行脚本处理。仅修改文件，不执行现有库 DDL、清库或 repair，本地/测试旧库的结构同步另行确认。后端先于 App 发布。自动化验证覆盖免费/收费、准备不计费、价格变化、旧短句拒绝、用户隔离、并发幂等和厂商适配器调用顺序；不代表真实厂商验证、PostgreSQL 部署或真机验收完成。准确测试命令与最终结果以本轮交付及后端 README 为准。

本轮验证记录：后端 `VoiceCoverBusinessIntegrationTests/SuandaoVoiceCloneAdapterTest/VoiceCoverWorkflowServiceTests/SongVoiceCoverParameterGuardTests/ContentModerationTaskIntegrationTests` 共 29 项通过；Flutter 六个独立音色测试文件共 47 项通过，含 375×812 长短句滚动与退出确认；`flutter analyze --no-pub`、Android debug APK 构建、两仓差异检查通过。Flutter 全量执行为 314 项通过、138 项失败，不能认定全量验收通过。单独复现首例 `widget_test.dart:1035` 查找字面量 `????`，该断言在 HEAD 已存在；其余失败尚未逐项归因，不覆盖已有测试改动。本轮未部署，也未用真实用户朗读完成厂商端到端验证。
