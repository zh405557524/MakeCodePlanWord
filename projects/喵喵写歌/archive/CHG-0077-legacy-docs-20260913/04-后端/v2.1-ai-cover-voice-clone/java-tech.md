# 喵喵写歌 V2.1 翻唱声音克隆 Java 后端技术文档

> 文档版本：`v2.1-ai-cover-voice-clone`
> 变更编号：`CHG-0073`
> 状态：`done`
> 创建日期：2026-09-09
> 需求真源：`../../01-需求/v2.1-ai-cover-voice-clone/requirements.md`
> 技术方案：`../../02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md`
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 基础包名：`com.lxwx.narrateservice`
> 数据隔离：请求头 `X-App-Code: catsinger`，业务数据进入 `catsinger` schema

---

## 0. 文档结论与编码门禁

### 0.1 本轮结论

1. `生成歌曲`、`AI 改编`、`翻唱声音克隆`是三个独立业务。
2. 翻唱声音克隆新增独立公开接口 `/api/song-voice-covers` 和独立业务目录 `app/catsinger/voicecover/`。
3. 公开请求不接受 `mode`；服务端在应用服务内固定内部业务类型 `VOICE_COVER`。
4. 请求中的 `provider/model` 必须是真实厂家与模型编码，不允许使用 `voice_cover`、中文展示名或移动端兼容别名代替厂家模型。
5. 新业务复用现有模型路由、容量控制、歌曲任务、工作流、积分、资源、审核、作品和 Admin 基础设施，不新建第二套通用体系。
6. 现有 `/api/song-generations` 与 `/api/song-covers` 的接口、业务含义和数据保持不变；V2.1 不重命名、不迁移、不顺手重构 AI 改编。
7. 本文完成第 8 步 Java 技术设计，不表示可以直接编码。必须在本文评审通过并生成当前版本 Java 总体开发计划、模块开发文档后，才能进入 Java 编码。

### 0.2 当前代码基线差异

- 当前 Catsinger 已有 `asset/config/cover/generation/homecase/resource/songworkflow/works` 等目录。
- 当前 `SongCoverController` 固定旧 `cover` 模式并委托共享 `SongGenerationService`，它只属于现有 AI 改编。
- 当前 `CreateSongGenerationRequest` 已包含大量写歌和改编字段。翻唱声音克隆不得继承或直接复用该 HTTP DTO，避免客户端修改内部业务类型，也避免三个业务持续互相污染参数。
- 当前歌曲任务表已经具备源作品、源音频、厂家、模型、模型选项、标准化请求快照、改编参数等通用事实；数据库只补音色版本、渠道绑定、授权和厂家接单时间等缺失引用。
- 当前公共资源、审核、积分、模型路由、AI 调用台账和歌曲工作流均已存在。本轮只能扩展，不得复制。
- 当前 Catsinger Flyway 版本最高观察到 `V4.6`，common 最高观察到 `V4.7`。本文暂定 Catsinger `V4.8`、common `V4.9`；编码前必须重新扫描真实分支，若版本已被占用则顺延，禁止覆盖历史迁移。

---

## 1. 技术栈与运行边界

| 范围 | 当前实现 | V2.1 使用方式 |
|------|----------|---------------|
| Java | Java 21 | 不降级，不引入并行运行时 |
| Web | Spring Boot 3.3、Spring MVC、Bean Validation | 新增独立 Controller/DTO，统一返回和异常处理继续复用 |
| 鉴权 | Spring Security、JWT、`X-App-Code` 过滤 | 用户接口继续校验 Token 中 appCode 与请求头一致 |
| 数据访问 | MyBatis-Plus、PostgreSQL | 专属实体与 Mapper 放 `voicecover/`，通用表继续走既有 Repository |
| 迁移 | Flyway、`common + {appCode}` locations | 专属表只放 `db/migration/catsinger`，人工复核公共字段放 `common` |
| 调度 | Spring Scheduler、数据库状态、Redis 锁/限流 | 数据库是任务状态真源，Redis 只做调度协助 |
| 模型路由 | AI Provider、模型、场景映射、模型选项、容量配置 | 新增训练和声音翻唱场景，不新增第二套路由表 |
| 计费 | 报价、积分冻结、成功结算、失败释放 | 训练与翻唱分别计费，价格和版本由服务端返回 |
| 资源 | 本地/OSS、资源台账、受控访问 URL | 原始素材、模型、配置、试听和结果均转存平台存储 |
| 内容安全 | 阿里云内容安全与现有审核记录 | 图片、音频和可展示文字都沿用现有审核流程 |
| API 文档 | springdoc/OpenAPI | DTO 和状态枚举需要生成可读 schema |

### 1.1 App 路由

- 用户端 `/api/**` 请求必须带 `X-App-Code: catsinger`。
- `AppCodeFilter` 继续校验支持的 appCode、客户端头和 Token 归属。
- `SchemaRoutingDataSourceConfig` 对 catsinger schema 执行 `common + catsinger` 迁移。
- V2.1 专属表禁止进入 `common`，也不能出现在 narrate、catcomic、catseller schema。
- Admin 先选择 App，再携带对应 appCode；只有 catsinger 展示翻唱声音克隆专属管理块。

---

## 2. 领域与代码结构

### 2.1 目标目录

```text
src/main/java/com/lxwx/narrateservice/
├── app/catsinger/
│   ├── cover/                         # 现有 AI 改编，保持原样
│   ├── voicecover/                    # V2.1 翻唱声音克隆
│   │   ├── controller/
│   │   │   ├── SongVoiceController.java
│   │   │   ├── SongVoiceTrainingController.java
│   │   │   └── SongVoiceCoverController.java
│   │   ├── domain/
│   │   │   ├── VoiceProfileStatuses.java
│   │   │   ├── VoiceModelStatuses.java
│   │   │   ├── VoiceTrainingStatuses.java
│   │   │   └── VoiceCoverConstants.java
│   │   ├── dto/
│   │   │   ├── CreateVoiceProfileRequest.java
│   │   │   ├── CreateVoiceTrainingRequest.java
│   │   │   ├── CreateSongVoiceCoverRequest.java
│   │   │   ├── VoiceCoverCreateCommand.java
│   │   │   └── VoiceCoverSettings.java
│   │   ├── entity/
│   │   ├── repository/
│   │   ├── service/
│   │   │   ├── SongVoiceProfileService.java
│   │   │   ├── SongVoiceTrainingService.java
│   │   │   ├── VoiceProviderBindingService.java
│   │   │   └── VoiceCoverApplicationService.java
│   │   ├── vo/
│   │   └── workflow/step/
│   ├── generation/                    # 通用歌曲任务创建、冻结与启动
│   ├── songworkflow/                  # 通用歌曲工作流、调度、补偿
│   ├── asset/                         # 扩展素材类型与上传策略
│   └── works/                         # 扩展 VOICE_COVER 查询和操作
├── thirdparty/aimodel/music/voiceclone/
│   ├── channel/IVoiceCloneModelProvider.java
│   ├── dto/
│   ├── service/VoiceCloneModelService.java
│   └── channel/suandao/
└── admin/
    ├── aimodel/
    ├── aioperations/
    ├── song/
    ├── resource/
    └── role/
```

### 2.2 所有权规则

| 模块 | 拥有内容 | 不允许拥有 |
|------|----------|------------|
| `voicecover` | 音色资料、素材关系、声音模型版本、渠道绑定、训练任务、授权事实、翻唱声音克隆专属校验与应用编排 | 通用积分账户、通用资源状态、通用作品表、第二套歌曲任务状态机 |
| `generation` | 通用歌曲任务落库、报价快照、积分冻结、工作流启动 | 本人声音授权和模型绑定的领域规则 |
| `songworkflow` | 步骤、租约、事件、调度、失败补偿 | 厂家 HTTP 字段和用户端 DTO |
| `works` | 作品生命周期、列表、详情、播放、下载、收藏、删除 | 训练素材和厂家模型生命周期 |
| `voiceclone provider` | 厂家请求映射、提交、查询、状态归一化、响应解析 | Repository、积分、审核、作品创建或 App 状态 |
| `admin` | 配置和运营操作入口 | 绕过用户端相同的业务校验和审计 |

### 2.3 三业务隔离

| 业务 | 公开创建接口 | 服务端内部类型 | 场景 |
|------|--------------|----------------|------|
| 生成歌曲 | `POST /api/song-generations` | 保持现有 | `song.generate` 等现有场景 |
| AI 改编 | `POST /api/song-covers` | `COVER_SONG` | `song.cover.generate` |
| 翻唱声音克隆 | `POST /api/song-voice-covers` | `VOICE_COVER` | `song.voice.cover.generate` |

`SongVoiceCoverController` 不调用 `SongCoverController`，`voicecover` 不引用 `SongCoverVoiceEntity`，也不使用 `coverVoiceCode` 表达本人克隆音色。

---

## 3. 用户端公开接口

### 3.1 配置与模型

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/song-config/voice-cover` | 页面规则、支持格式、时长、容量、功能开关和说明文案 |
| GET | `/api/song-config/models?sceneCode=song.voice.train` | 返回可选训练厂家模型与实时报价 |
| GET | `/api/song-config/models?sceneCode=song.voice.cover.generate` | 返回可选翻唱厂家模型与实时报价 |

模型响应必须至少包含：

- `modelOptionId`
- `providerCode`
- `modelCode`
- `displayName`
- `pricePoints`
- `pricingVersion`
- `enabled`
- `capabilityLimits`

`providerCode/modelCode` 是真实调用目标；`modelOptionId` 是后台公开选项和快照引用，不能替代真实厂家模型。

### 3.2 音色资料

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/song-voices` | 查询我的音色和可选择的官方音色 |
| POST | `/api/song-voices` | 创建本人音色资料草稿 |
| GET | `/api/song-voices/{id}` | 查询音色资料、版本和可用性 |
| PATCH | `/api/song-voices/{id}` | 按 `revision` 修改资料并创建新的资料版本 |
| DELETE | `/api/song-voices/{id}` | 软删除并禁止新任务，历史作品不受影响 |
| GET | `/api/song-voices/{id}/materials` | 查询用户自己的训练素材 |
| POST | `/api/song-voices/{id}/materials` | 将审核通过的素材和截取范围绑定到音色资料 |
| DELETE | `/api/song-voices/{id}/materials/{materialId}` | 删除尚未用于运行中训练的素材 |

列表查询只返回：

- 当前用户自己的音色；
- 后台已审核、已发布且当前渠道可用的官方音色；
- 已持久化且允许访问的试听资源。

“厂家模型失效”不直接展示给用户，统一返回 `availability=UNAVAILABLE` 与“音色暂不可用”。

### 3.3 资源上传与审核

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/song-assets/voice-materials` | 上传录音、本地音频或视频提取后的训练音频 |
| POST | `/api/song-assets/voice-cover-sources` | 上传完整翻唱源歌曲 |
| GET | `/api/song-assets/{id}` | 查询资源技术状态和审核状态 |
| POST | `/api/song-assets/{id}/moderation/retry` | 对允许重试的审核异常重新送审 |

统一规则：

- 训练单段 1–5 分钟，累计 1–10 分钟，总量不超过 100MB；累计不足 5 分钟允许继续，但返回效果风险提示。
- 翻唱源歌曲支持 `MP3/WAV/M4A/FLAC/OGG/AAC`，单文件不超过 100MB，时长不超过 10 分钟。
- 后端必须根据文件签名、MIME 和探测结果联合判断格式；不能只信扩展名和客户端 `durationMs`。
- 上传完成先建立平台资源和审核记录。`ResourceStatus=READY` 只表示对象可读取，不表示内容可用于训练或翻唱。
- 审核未通过前不能进入训练或翻唱报价/冻结/厂家调用。
- 与现有 AI 改编体系一致：已通过上传阶段审核的站内 `assetId`、用户有权使用的 `sourceWorkId` 在任务阶段不重复提交第三方源音频审核；外部 URL 不作为 V2.1 公开输入。
- 图片、音频和可展示文字均按内容类型送审；修改内容或重新截取必须产生新的资源或送审快照，不能复用旧结论。

### 3.4 音色训练

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/song-voice-training-tasks` | 创建音色训练任务 |
| GET | `/api/song-voice-training-tasks/{id}` | 查询训练阶段、错误和可用音色版本 |

App 通过本地保存的最近训练任务 ID 轮询详情；本地 ID 丢失时由音色详情返回当前关联训练状态。本版本不新增未经技术方案确认的 `/api/song-voice-training-tasks/active`。

创建训练请求：

```json
{
  "voiceProfileId": "vp_123",
  "materialAssetIds": ["asset_1", "asset_2"],
  "provider": "suandao",
  "model": "sovits_train",
  "modelOptionId": "option_123",
  "pricingVersion": "2026-09-01T00:00:00Z",
  "rightsConfirmed": true,
  "riskConsentConfirmed": true,
  "idempotencyKey": "uuid"
}
```

服务端校验：

1. 音色属于当前用户，或操作人具备官方音色管理权限。
2. 素材全部属于该音色当前资料版本，技术状态和审核状态均可用。
3. 时长、总量和格式满足当前模型能力。
4. 本次训练拥有独立授权记录；旧任务的勾选不能沿用为新任务授权。
5. `provider/model/modelOptionId/pricingVersion` 能解析到同一启用配置。
6. 幂等键在当前用户和训练业务内唯一。

### 3.5 翻唱声音克隆

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/song-voice-covers` | 创建翻唱声音克隆任务 |
| GET | `/api/song-voice-covers/{id}` | 查询任务状态、阶段、倒计时、错误和成功作品 |
| GET | `/api/song-voice-covers/active` | 恢复当前用户未完成任务 |

`CreateSongVoiceCoverRequest`：

```json
{
  "sourceWorkId": "work_123",
  "sourceAudioAssetId": null,
  "voiceModelVersionId": "vmv_123",
  "provider": "suandao",
  "model": "sovits_cover",
  "modelOptionId": "option_456",
  "pricingVersion": "2026-09-01T00:00:00Z",
  "coverSettings": {
    "transpose": 0,
    "vocalGain": 1.0,
    "accompanimentGain": 1.0
  },
  "songRightsConfirmed": true,
  "voiceConsentConfirmed": true,
  "idempotencyKey": "uuid"
}
```

DTO 固定规则：

- 不定义 `mode` 字段。
- `sourceWorkId/sourceAudioAssetId` 必须且只能填写一个。
- `voiceModelVersionId` 必须是可用本人版本或已发布官方音色版本。
- `provider/model` 必填，并与该音色版本的有效渠道绑定和当前模型选项一致。
- `model` 必须是厂家真实翻唱模型，例如后台配置的 `sovits_cover`；不得填 `VOICE_COVER`。
- 两项授权必须为 true，并在本次提交创建不可变授权事实。
- 设置项以厂家能力和后台配置白名单为准，未知字段拒绝或由专属 DTO 显式忽略，不能直接把任意 JSON 透传厂家。

内部命令：

```java
public record VoiceCoverCreateCommand(
        Long userId,
        String sourceWorkId,
        String sourceAudioAssetId,
        String voiceProfileVersionId,
        String voiceModelVersionId,
        String voiceProviderBindingId,
        String consentRecordId,
        String provider,
        String model,
        String modelOptionId,
        String pricingVersion,
        VoiceCoverSettings settings,
        String idempotencyKey,
        SongCreationMode creationMode
) {}
```

`VoiceCoverApplicationService` 只能在服务端构造该命令，并固定 `creationMode=VOICE_COVER`。完成音色、来源、授权、模型和报价校验后，再调用共享歌曲任务编排创建 `catsinger_song_generation_tasks`、冻结积分并启动工作流。

### 3.6 作品接口复用

翻唱成功仍进入现有作品接口，不新建 `/api/song-voice-cover-works`：

- `GET /api/song-works`
- `GET /api/song-works/{id}`
- 现有播放、下载、分享、收藏、删除接口

作品响应新增或确保返回：

- `songType=VOICE_COVER`
- `voiceProfileVersionId`
- `voiceModelVersionId`
- 音色展示快照
- 源作品/源资源引用
- 实际 `audioMimeType/fileExtension/fileSize/durationMs`
- 当前可播放的受控资源地址

播放器仍由现有 App 页面消费；后端不得假设输出一定是 MP3。

---

## 4. 状态机与共享工作流

### 4.1 音色资料和模型

```text
DRAFT -> REVIEWING -> READY_TO_TRAIN -> QUEUED -> TRAINING
      -> SAVING_MODEL -> REVIEWING_AUDITION -> AVAILABLE
      -> FAILED / SUBMIT_UNKNOWN / TIMED_OUT

AVAILABLE -> UNAVAILABLE -> AVAILABLE 或创建新训练版本
非运行中状态 -> DELETED
```

- `AVAILABLE` 必须同时满足：模型文件和配置已持久化、至少一个有效渠道绑定、试听资源可播放且审核通过。
- 厂家模型 ID 失效但平台资产仍存在时先置 `UNAVAILABLE`，后台尝试恢复；不能把未经验证的“重新导入”当作厂家已支持能力。
- 新训练任务创建新模型版本，不能覆盖历史成功版本。

### 4.2 翻唱任务

```text
CREATED
  -> VALIDATING_INPUT
  -> QUEUED
  -> SUBMITTING
  -> PROVIDER_QUEUED
  -> GENERATING
  -> PERSISTING_OUTPUT
  -> PROBING_OUTPUT
  -> REVIEWING_OUTPUT
  -> CREATING_WORK
  -> SETTLING
  -> SUCCEEDED

任一步骤 -> FAILED / SUBMIT_UNKNOWN / TIMED_OUT
```

共用流程中的专属步骤建议：

| 步骤 | 所属实现 | 说明 |
|------|----------|------|
| `VOICE_COVER_VALIDATE` | `voicecover/workflow/step` | 验证来源、音色版本、渠道绑定、授权和请求快照 |
| `VOICE_COVER_ROUTE` | 现有模型路由 + 专属约束 | 选择请求指定的真实厂家模型并获取容量 |
| `VOICE_COVER_SUBMIT` | `VoiceCloneModelService` | 向厂家提交，保存调用台账 |
| `VOICE_COVER_POLL` | 共享调度 + Provider | 主动轮询并归一化状态 |
| `VOICE_COVER_PERSIST` | 现有资源服务 | 下载临时结果，转存平台资源并探测属性 |
| `VOICE_COVER_MODERATE` | 现有审核服务 | 对最终输出送审并等待结论 |
| `VOICE_COVER_CREATE_WORK` | 现有作品服务 | 创建 `VOICE_COVER` 作品 |
| `VOICE_COVER_SETTLE` | 现有积分服务 | 确认扣减；失败统一释放冻结 |

### 4.3 10 分钟规则

- 平台任务创建、参数校验和平台容量排队不计入 10 分钟。
- 只有在厂家确认接单并返回可查询任务 ID 后，才写 `providerAcceptedAt`。
- 同一事务或原子更新中写 `deadlineAt = providerAcceptedAt + 10 分钟`。
- 厂家内部排队、生成、平台下载持久化、媒体探测、输出审核和作品创建均计入这 10 分钟。
- 截止时还没有“已持久化、已审核、已探测可播放并创建作品”的结果，任务进入 `TIMED_OUT` 并释放冻结积分。
- 页面在 `providerAcceptedAt` 为空时只显示“排队中”，不能显示虚假倒计时。
- V2.1 不提供取消任务接口；用户离开页面不停止服务端任务。

### 4.4 异常语义

| 类型 | 处理 |
|------|------|
| 参数或授权失败 | 创建任务前返回 4xx，不冻结积分 |
| 内容审核不通过 | 不报价、不冻结、不调用厂家；返回可理解原因 |
| 厂家明确拒绝 | 任务失败，释放冻结积分 |
| 提交超时且无法确认是否接单 | `SUBMIT_UNKNOWN`，禁止自动重复提交；进入人工/运维处理 |
| 厂家查询失败 | 在截止时间和退避策略内重试；超过规则失败 |
| 临时资源下载失败 | 在剩余时限内重试，仍失败则释放积分 |
| 输出不可解码/不可播放 | 任务失败，不创建作品，释放积分 |
| 输出审核拒绝或异常 | 不展示、不播放、不创建可见作品；按现有补偿规则释放积分 |
| 结算失败 | 进入现有结算补偿，不重复生成作品 |

---

## 5. Provider 与多渠道设计

### 5.1 供应商无关接口

```java
public interface IVoiceCloneModelProvider {
    String providerCode();

    VoiceTrainingSubmitResult submitTraining(VoiceTrainingCommand command);

    VoiceCoverSubmitResult submitCover(VoiceCoverCommand command);

    VoiceProviderTaskResult queryTask(VoiceProviderTaskQuery query);
}
```

`VoiceCloneModelService` 职责：

1. 根据 `provider/model` 获取已启用 Provider。
2. 校验模型是否支持 `TRAIN` 或 `VOICE_COVER` 能力。
3. 使用现有调用台账保存请求摘要、厂家任务 ID、耗时、状态和错误。
4. 归一化厂家状态，但不改变 Catsinger 业务状态。
5. 不直接访问作品、积分和用户 Controller。

### 5.2 算道首期适配

按当前资料首期映射：

- 训练模型能力：`sovits_train`。
- 翻唱模型能力：后台配置的算道真实模型编码，例如 `sovits_cover`。
- 提交：`/api/queue/music_tool`。
- 查询：`/api/midjourney/drawInfo4?id={providerTaskId}`。
- 采用主动轮询，不依赖回调。

适配器必须处理：

- 请求中的真实输入资源短期受控 URL；
- 训练参数和翻唱参数显式映射；
- 厂家 `request_id/task_id` 等标识的统一提取；
- 模型 URL、配置 URL、试听 URL、输出 URL 的分类；
- 厂家错误码到内部可重试/不可重试错误的映射；
- 响应缺字段、未知状态、临时 URL 失效和提交结果不确定。

算道不能把平台持久化的模型文件重新导入时，渠道模型 ID 失效后应将绑定标为不可用。后续新增厂家只增加新 Provider 和绑定，不修改用户音色主数据，也不让前端理解各厂家私有字段。

### 5.3 多渠道切换

- 场景映射决定可公开选择的模型，平台容量策略决定当前是否可接单。
- 本人音色模型不是跨厂家通用。每个 `voiceModelVersion` 可以有多个 `providerBinding`，但创建任务时必须存在与精确 `provider/model` 匹配且可用的绑定。
- 后台切换默认商家不会自动迁移用户音色。没有新渠道绑定时，该音色在新模型下不可选择。
- 官方音色也使用同样的版本和绑定关系；展示名称、头像由平台管理，试听内容使用厂家结果转存后的平台资源。
- 任务创建后保存完整路由和价格快照，后台切换默认模型不能改变运行中任务。

---

## 6. 资源、审核与可播放门禁

### 6.1 资源生命周期

```text
上传或厂家返回
  -> 平台资源登记
  -> 文件持久化
  -> MIME/扩展名/大小/时长探测
  -> 内容审核
  -> 业务可用
```

- `READY` 只代表资源对象可访问。
- 训练素材、源歌曲、模型、配置和未发布试听使用 `OWNER/INTERNAL`，不能生成公开永久地址。
- 厂家临时地址不能直接写入最终作品并返回 App。
- 下载厂家输出时限制重定向、协议、域名/IP、最大体积、连接/读取超时，防止 SSRF 和无界下载。
- 保存后以实际文件头和媒体探测结果记录 MIME、后缀、大小、时长，不根据请求参数猜测。
- 作品成功前必须执行服务端可读取、音频可解码、时长合理的探测；只有 HTTP 200 不算可播放。

### 6.2 内容审核

| 内容 | 时机 | 未通过行为 |
|------|------|------------|
| 音色名称、简介等展示文字 | 创建或更新版本后 | 不展示，不训练 |
| 用户头像/官方音色头像 | 上传后 | 不展示，不发布 |
| 训练音频 | 上传完成后 | 不训练 |
| 翻唱源歌曲 | 上传完成后 | 不报价，不冻结，不提交 |
| 厂家试听 | 平台转存后 | 音色不能 `AVAILABLE` |
| 翻唱输出 | 平台转存、探测后 | 不创建可见作品，释放积分 |

`REVIEW` 需要后台人工处理；本轮在公共审核记录补充人工结论、处理人、原因、时间和乐观锁版本，避免把人工事实放入音色或歌曲专属表。

### 6.3 保留与清理

- 训练原始素材最长保留 30 天，清理由现有资源生命周期任务按业务引用和保留策略执行。
- 本人音色及平台持久化模型保留到用户主动删除；删除先停止新任务并解除可用绑定，再按引用和合规策略异步清理。
- 翻唱作品第 15 天后不再展示，第 30 天物理清理；播放器和下载接口均需按生命周期拒绝失效作品。
- 历史作品不因音色后续不可用而立即失效，仍按作品自己的保留规则处理。

---

## 7. 报价、积分与幂等

### 7.1 报价

- 训练场景 `song.voice.train` 默认 100 积分。
- 翻唱场景 `song.voice.cover.generate` 默认 200 积分。
- 默认值只用于后台初始配置；前端永远显示服务端当前报价。
- 未配置价格、模型未启用、容量关闭或音色无绑定时返回“暂未开放”，不得以默认数字直接创建任务。
- 报价响应包含 `modelOptionId + provider + model + pricePoints + pricingVersion + expiresAt`。

### 7.2 冻结与结算

```text
输入与审核通过
  -> 校验报价快照
  -> 幂等创建业务任务
  -> 冻结积分
  -> 启动工作流
  -> 成功作品可播放后确认扣减
  -> 任一最终失败释放冻结
```

- 训练和翻唱使用不同计费场景、不同业务引用和不同幂等作用域。
- 积分流水继续写现有账户与流水表，不新建声音克隆积分表。
- `idempotencyKey` 重复时返回原任务和原报价快照，不重复冻结。
- 同一厂家结果、资源持久化、作品创建和结算均需要业务唯一键，防止调度重入造成重复作品或重复扣费。
- `SUBMIT_UNKNOWN` 不得自动再次调用厂家。冻结积分如何最终处理沿用运维补偿规则，只有确认厂家未执行或任务最终失败后才能释放。

---

## 8. 数据库设计

### 8.1 迁移目录

```text
src/main/resources/db/migration/catsinger/
└── V4.8__catsinger_voice_clone_cover.sql

src/main/resources/db/migration/common/
└── V4.9__content_moderation_manual_review.sql
```

版本号是当前设计占位。编码前执行 `rg --files src/main/resources/db/migration` 并按真实最大版本顺延。

### 8.2 Catsinger 新表

| 表 | 用途 | 为什么现有表不能替代 |
|----|------|----------------------|
| `catsinger_song_voice_profiles` | 用户/官方音色的稳定身份、所有者、展示状态和删除状态 | 作品与旧改编音色预设不能表达用户拥有的可迭代声音身份 |
| `catsinger_song_voice_profile_versions` | 名称、头像、简介、发布和审核对应的不可变资料版本 | 修改资料后必须区分新旧审核事实和历史任务快照 |
| `catsinger_song_voice_materials` | 音色版本与多个训练素材的关系、顺序和使用状态 | 通用 asset 只描述文件，不描述属于哪个音色版本和训练组合 |
| `catsinger_song_voice_model_versions` | 一次成功训练形成的平台音色模型版本 | 用户音色资料与厂家执行模型生命周期不同，失败重训不能覆盖历史成功版本 |
| `catsinger_song_voice_provider_bindings` | 平台模型版本与厂家、真实模型、厂家模型 ID/资源的绑定 | 同一音色可能对应多个渠道，且厂家 ID 不能污染用户主数据 |
| `catsinger_song_voice_training_tasks` | 训练业务状态、报价快照、厂家接单、错误和产出模型版本 | 通用歌曲生成任务以作品为结果，无法可靠表达训练产物和训练状态 |
| `catsinger_song_voice_consent_records` | 每次训练/翻唱的声音权利、歌曲权利和风险授权快照 | 勾选是不可变合规事实，不能只存在请求 JSON 或用户当前资料中 |

所有新表必须包含项目统一的主键、创建/更新时间、软删除或状态字段，并为表和列写 SQL 注释。所有 Entity 持久化字段必须逐字段写 JavaDoc 或清晰行注释；SQL 中不重复写业务过程说明，但数据库注释必须完整。

### 8.3 现有 Catsinger 表最小扩展

`catsinger_song_generation_tasks` 只新增：

| 字段 | 用途 |
|------|------|
| `voice_profile_version_id` | 保存创建任务时使用的音色展示版本 |
| `voice_model_version_id` | 保存实际演唱模型版本 |
| `voice_provider_binding_id` | 保存精确厂家绑定，支持路由审计 |
| `consent_record_id` | 关联本次不可变授权事实 |
| `provider_accepted_at` | 厂家确认接单并返回可查询任务 ID 的时间 |
| `deadline_at` | 由接单时间计算的 10 分钟截止时间 |

`catsinger_song_works` 只新增：

| 字段 | 用途 |
|------|------|
| `voice_profile_version_id` | 展示历史音色名称/头像版本 |
| `voice_model_version_id` | 追溯实际使用的训练模型版本 |

以下已有事实继续复用，不新增重复字段：

- 源作品、源音频 asset 和源 URL；
- `provider/model/model_option_id`；
- 标准化请求与设置 JSON；
- 作品类型、音频 URL、MIME、后缀、大小、时长；
- 任务状态、失败原因、创建完成时间；
- 资源存储状态与生命周期；
- 积分冻结、流水和结算事实。

`catsinger_song_assets` 不增加音色关系、审核状态或业务状态字段。素材与音色的关系放专属关系表，审核事实继续放公共审核记录。

### 8.4 公共审核表最小扩展

`content_moderation_records` 仅新增：

- `manual_result`
- `manual_reviewer_id`
- `manual_reason`
- `manual_reviewed_at`
- `revision`

它们服务所有 App 的人工复核和并发更新，因此属于 `common`。不得在 Catsinger 音色表再保存另一份人工审核结论真源。

### 8.5 唯一性与索引

至少建立：

- 用户音色列表：`owner_user_id + status + deleted_at`；
- 官方音色列表：`voice_type + publish_status + sort_order`；
- 当前资料版本：`voice_profile_id + version_no` 唯一；
- 渠道绑定：`voice_model_version_id + provider_code + model_code` 唯一；
- 厂家模型 ID：`provider_code + provider_model_id` 条件唯一；
- 训练幂等：`user_id + idempotency_key` 唯一；
- 授权记录：`business_type + business_id`；
- 活动训练任务：`user_id + status + updated_at`；
- 活动翻唱任务复用歌曲任务现有用户/状态索引，并按需要补 `creation_mode + status` 联合索引。

### 8.6 数据库变更声明

本版本需要数据库变更，原因只有三类：

1. 用户音色是可迭代、可删除、可多渠道绑定的独立资产，现有歌曲或改编音色预设无法表达。
2. 音色训练产出模型版本而不是歌曲作品，需要独立训练任务和模型生命周期。
3. 10 分钟从厂家接单开始计时、每次授权不可变留痕以及人工复核审计，现有字段不足。

本版本不新增通用歌曲任务表、作品表、资源表、积分表、模型配置表或审核表。

---

## 9. Admin 后端接口

Admin 继续使用现有 App 切换、角色、审计、模型、计费、资源和 AI 运维体系，不新增 `/api/admin/voice-cover/**` 大而全入口。按现有模块所有权扩展：

### 9.1 模型与价格

- `/api/admin/model-providers`
- `/api/admin/ai-models`
- `/api/admin/ai-scene-model-mappings`
- `/api/admin/ai-model-options`

新增或配置场景：

- `song.voice.train`
- `song.voice.cover.generate`

后台保存真实厂家 `provider/model`、能力限制、默认价格、公开状态、容量和超时策略。

### 9.2 音色管理

建议在现有 `/api/admin/song` 域下新增：

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/song/voice-profiles` | 筛选本人/官方音色、状态和厂家 |
| POST | `/api/admin/song/voice-profiles/official` | 创建官方音色资料 |
| PUT | `/api/admin/song/voice-profiles/{id}` | 修改资料并创建新资料版本 |
| POST | `/api/admin/song/voice-profiles/{id}/publish` | 审核条件满足后发布 |
| POST | `/api/admin/song/voice-profiles/{id}/disable` | 停止新任务 |
| GET | `/api/admin/song/voice-training-tasks` | 查询训练任务 |
| POST | `/api/admin/song/voice-training-tasks/{id}/retry` | 仅对明确可重试状态重试 |
| POST | `/api/admin/song/voice-provider-bindings/{id}/recover` | 尝试恢复渠道绑定 |

试听由厂家生成并由平台转存；名称和头像由平台运营配置。发布前必须满足资料审核、试听审核、模型持久化和有效渠道绑定。

### 9.3 任务、作品和资源

- AI 运营列表增加 `businessType=VOICE_TRAINING/VOICE_COVER` 筛选。
- 歌曲任务和作品增加 `songType=VOICE_COVER` 筛选，展示来源、音色版本、真实模型、积分和状态。
- 资源管理可按训练素材、模型、配置、试听、翻唱源歌曲和成品分类筛选。
- `SUBMIT_UNKNOWN`、持久化失败、审核复核和结算补偿继续进入现有运维视图。

### 9.4 权限

沿用超级管理员和角色管理块：

- `song.voice.profile.read/write`
- `song.voice.training.read/operate`
- `song.voice.cover.read/operate`
- `song.voice.official.publish`
- `song.voice.provider.recover`
- `content.moderation.manual-review`

权限码在编码前需和当前权限注册方式对账；不能只在前端隐藏按钮，后端每个写接口都必须校验。

---

## 10. 安全、事务与并发

### 10.1 安全

- 所有用户资源按 owner 校验，不能仅凭 ID 访问。
- 官方音色写操作只允许对应后台权限。
- 私有音频、模型和配置只返回短期受控 URL。
- 日志不记录完整授权文本、临时签名 URL、用户原始音频内容或厂家密钥。
- 厂家密钥继续由配置和环境变量管理，不写数据库业务表或请求快照。
- 厂家下载执行 URL 安全校验、体积限制和内容探测。

### 10.2 事务边界

- 创建任务、保存报价快照、保存授权和冻结积分需要可恢复的一致性边界。
- 外部厂家调用不得放在数据库长事务内。
- 工作流步骤采用“读取当前状态 -> 外部动作 -> 幂等落结果”的短事务。
- 资源转存、审核、作品创建和结算分别记录步骤事实，进程重启后从数据库恢复。

### 10.3 并发

- 同一用户/业务幂等键唯一。
- 调度器使用现有租约或锁机制，只有持有者可执行步骤。
- 状态更新带 expected status 或版本字段，禁止过期执行器覆盖新状态。
- 同一音色删除、训练、发布和绑定恢复操作需做状态 CAS。
- 平台容量排队没有翻唱倒计时；取得容量并确认厂家接单后才开始 deadline。

---

## 11. 可观测性与运维

### 11.1 必记字段

- `appCode`
- `businessType`
- 平台任务 ID、工作流 ID、步骤 ID
- 用户 ID 的脱敏标识
- `provider/model/modelOptionId/pricingVersion`
- 厂家任务 ID
- 音色资料版本、模型版本、渠道绑定 ID
- `queuedAt/providerAcceptedAt/deadlineAt/completedAt`
- 输入审核、输出审核、持久化、探测、结算状态
- 错误类别、厂家错误码、是否可重试

### 11.2 指标

- 平台排队时长与厂家处理时长分开统计。
- 训练/翻唱提交成功率、完成率、超时率和 `SUBMIT_UNKNOWN` 数量。
- 各厂家/模型平均处理时长和容量占用。
- 模型、配置、试听和翻唱成品转存失败率。
- 输出不可播放率、内容审核拒绝率和人工复核积压。
- 冻结未结算、补偿重试和重复任务拦截数量。

### 11.3 告警

- 同一厂家连续提交或查询异常。
- `SUBMIT_UNKNOWN` 出现即告警。
- 任务过 deadline 未收敛。
- 成功厂家任务未能持久化或探测。
- 成功作品无法通过受控地址播放。
- 积分冻结长期未结算或释放。
- 资源清理失败和过期资源仍可访问。

---

## 12. 测试技术方案

### 12.1 测试层级

| 层级 | 重点 |
|------|------|
| Controller | 路径、鉴权、请求字段、无 `mode`、错误码和响应状态 |
| Service | 来源 XOR、owner、授权、音色可用性、真实模型一致性、幂等和状态机 |
| Repository/Flyway | Catsinger 专属建表、common 人工审核字段、唯一约束和 schema 隔离 |
| Provider Mock | 算道提交/查询映射、未知响应、临时 URL、格式和错误归一化 |
| Workflow | 排队不计时、接单起算、重启恢复、超时、持久化、审核、作品和补偿 |
| Billing | 报价过期、余额不足、重复请求、成功结算、失败释放、未知提交 |
| Resource | 格式、大小、时长、私有访问、转存、探测、不可播放和清理 |
| Admin | App 切换、角色权限、模型价格、官方音色、任务、作品和资源操作 |

### 12.2 核心用例

1. `/api/song-voice-covers` 请求即使包含未知 `mode` 也不能改变内部类型；严格 DTO 策略下应拒绝未知字段。
2. `sourceWorkId/sourceAudioAssetId` 未填或同时填写均拒绝，且不冻结积分。
3. 请求真实 `provider/model` 与模型选项或音色绑定不一致时拒绝。
4. 已失效音色、未审核素材、非本人资源、未确认授权均拒绝。
5. 同一幂等键重复提交只返回同一任务，冻结流水只有一笔。
6. 平台排队超过 10 分钟但尚未调用厂家时不超时，`providerAcceptedAt/deadlineAt` 为空。
7. 厂家接单后正确起算 10 分钟，超过 deadline 且未形成可播放作品时失败并释放积分。
8. 厂家返回 WAV/FLAC 等格式时保存真实格式，不能强写 MP3。
9. 厂家返回 200 但文件损坏时不能成功、不能创建作品、不能结算。
10. 输出持久化成功但审核拒绝时用户不可见且积分释放。
11. 进程在提交、轮询、持久化、审核、作品创建或结算阶段重启后不会重复调用或重复扣费。
12. `SUBMIT_UNKNOWN` 不自动重提，并可在 Admin 中定位。
13. 音色厂家绑定失效后禁止新任务，已持久化试听和历史作品按各自规则继续可用。
14. `narrate` schema 不出现声音克隆专属表，catsinger schema 同时具备 common 和 V2.1 表。
15. 旧 `/api/song-generations` 与 `/api/song-covers` 回归通过，旧 AI 改编的 `COVER` 数据和计费不变。

### 12.3 执行命令

编码阶段按风险先跑定向测试，再跑全量：

```bash
./gradlew test --tests '*VoiceCover*'
./gradlew test --tests '*VoiceTraining*'
./gradlew test --tests '*SchemaRouting*'
./gradlew test
./gradlew build
git diff --check
```

真实厂家联调必须使用测试账号、测试积分和可授权素材；离线 Mock 只证明内部映射，不代表算道生产契约或真实可播放闭环通过。

---

## 13. Java 开发任务拆分

| 编号 | 模块 | 主要交付 | 依赖 |
|------|------|----------|------|
| `T-B001` | 契约与类型 | 独立 DTO/VO、`VOICE_COVER`、错误码和 OpenAPI | 技术文档通过 |
| `T-B002` | 数据迁移 | 7 张专属表、任务/作品最小字段、人工复核字段 | T-B001 |
| `T-B003` | 音色资料 | 本人/官方音色、资料版本、删除和列表 | T-B002 |
| `T-B004` | 素材与审核 | 训练素材、源歌曲、探测、审核门禁和保留策略 | T-B002 |
| `T-B005` | 训练业务 | 授权、报价、冻结、训练任务和模型版本 | T-B003、T-B004 |
| `T-B006` | Provider 抽象 | 独立声音克隆 Provider、路由服务和调用台账 | T-B001 |
| `T-B007` | 算道训练 | `sovits_train` 提交、查询、转存和试听 | T-B005、T-B006 |
| `T-B008` | 翻唱创建 | `/api/song-voice-covers`、专属校验和共享任务委托 | T-B003、T-B004、T-B006 |
| `T-B009` | 翻唱工作流 | 提交、轮询、10 分钟、重启恢复和补偿 | T-B008 |
| `T-B010` | 成品闭环 | 转存、探测、审核、作品、结算和真实格式 | T-B009 |
| `T-B011` | 作品扩展 | `VOICE_COVER` 查询、详情、播放、下载和清理 | T-B010 |
| `T-B012` | Admin API | 模型价格、音色、训练、任务、作品、资源和权限 | T-B003–T-B011 |
| `T-B013` | 自动化测试 | 定向测试、旧业务回归、schema 隔离 | T-B001–T-B012 |
| `T-B014` | 厂家联调 | 测试环境真实提交、持久化、审核和播放证据 | T-B013、配置就绪 |

模块开发文档阶段必须把每个任务继续拆成目标、输入输出、影响文件、实现步骤、异常、验证命令和完成定义；本文不能代替模块计划直接编码。

---

## 14. 编码规范继承与本版本特例

### 14.1 继承当前工程

- Controller 只做协议层工作，业务规则放 Service。
- Entity 与表一一对应，持久化字段逐字段写注释。
- DTO/VO 不与 Entity 混用。
- SQL 只进入 Mapper/Repository；禁止业务 Service 拼接 SQL。
- 使用构造器注入、统一异常和统一返回格式。
- 外部请求设置连接、读取和总超时；敏感信息禁止输出日志。
- 多步骤外部流程必须可恢复、可幂等、可观察。
- 修改历史 Flyway 禁止；只能新增迁移。

### 14.2 本版本特例

- `CreateSongVoiceCoverRequest` 不含 `mode`，也不继承 `CreateSongGenerationRequest`。
- `VOICE_COVER` 是内部业务类型，不是厂家模型。
- `cover/` 是 AI 改编边界，V2.1 不在该目录增加任何声音克隆代码。
- 平台排队时间不进入翻唱 10 分钟 deadline。
- 任务成功定义包含平台持久化、实际格式探测、内容审核、作品创建和服务端可播放验证。
- 本站已审核的 asset/work 来源在任务阶段不重复源审核，但上传阶段审核不可跳过。

---

## 15. 评审清单

- [ ] 三个业务的公开接口、内部类型、场景和作品类型没有混用。
- [ ] 新 HTTP 请求没有 `mode`，且 `provider/model` 是真实厂家值。
- [ ] `voicecover/` 独立业务目录没有复制任务、工作流、计费、资源、审核和作品体系。
- [ ] 10 分钟从 `providerAcceptedAt` 开始，平台排队不计入。
- [ ] 数据库仅包含 7 张声音资产/训练专属表和现有表最小字段。
- [ ] 输出格式未写死，临时 URL 不作为最终资源。
- [ ] 所有图片、音频和可展示文字都经过现有审核体系。
- [ ] 训练与翻唱价格均由后台配置，幂等和失败释放规则明确。
- [ ] Admin 管理、权限、审计、资源和运维入口完整。
- [ ] 旧 AI 写歌和 AI 改编明确零迁移、零语义修改并列入回归。
- [ ] 真实厂家联调以可播放作品为成功，不以 Mock 或厂家成功字段替代。

本技术文档已完成评审并标记为 `done`，当前进入第 10 步 Java 总体开发计划评审。总体计划通过后再生成第 12 步模块开发文档；模块文档通过前不进入 Java 编码。
