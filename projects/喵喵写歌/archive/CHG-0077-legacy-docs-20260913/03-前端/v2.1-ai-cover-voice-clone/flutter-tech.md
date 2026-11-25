# 喵喵写歌 V2.1 翻唱声音克隆 Flutter 技术文档

> 文档版本：`v2.1-ai-cover-voice-clone`
> 变更编号：`CHG-0073`
> 状态：`done`
> 生成日期：2026-09-09
> 需求真源：`../../01-需求/v2.1-ai-cover-voice-clone/requirements.md`
> 技术方案：`../../02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md`
> 工时评估：`../../02-技术方案/v2.1-ai-cover-voice-clone/effort-estimate.md`
> 移动端工程：`/Users/soul/code/lxwx/catsinger`
> Web/Admin 工程：`/Users/soul/code/lxwx/lxwx_admin`

---

## 0. 文档结论与执行边界

### 0.1 本版本要做什么

V2.1 在现有 App 中新增独立产品能力「翻唱声音克隆」：用户上传完整歌曲，选择本人训练音色或后台发布的官方音色，提交异步翻唱，最终在现有作品体系和播放器中播放成品。

本版本同时扩展 Flutter Web/Admin，使运营人员能够在 `catsinger` App 下配置真实厂家模型、价格、官方音色、审核、任务、作品和权限。

### 0.2 三个业务必须隔离

| 产品业务 | 当前 Flutter 模块 | 用户端创建接口 | 本期处理 |
|----------|------------------|----------------|----------|
| AI 写歌 | `pages/song_create/` | `POST /api/song-generations` | 保持原样 |
| AI 改编 | `pages/song_cover/` | `POST /api/song-covers` | 保持原样；历史代码中的 `cover` 仍指该业务 |
| 翻唱声音克隆 | 新增 `pages/song_voice_cover/` | `POST /api/song-voice-covers` | V2.1 新增 |

强约束：

- 新功能不得复用 `SongCoverController`、`SongCoverVoiceConfig`、`coverVoiceCode` 或 `/api/song-covers` 表达克隆音色。
- 新功能创建请求不传 `mode`；App 只提交模型列表返回的真实 `provider/model`。
- 可以复用上传、缓存、播放器、会员、积分和错误处理基础能力，但不能把两个产品流程合并成同一页面 Controller。
- P12 不新增结果页，不重做播放器 UI；成功后用后端返回的 `workId` 打开现有 `SongPlayerPage`。

### 0.3 当前代码基线事实

| 工程 | 当前事实 | V2.1 处理 |
|------|----------|-----------|
| App | `pubspec.yaml` 当前为 `1.2.0+120`，工作区基线名称为 `v1.2.0+121-as-built` | 编码开始前冻结分支、commit、dirty diff 和实际构建号；本文不擅自改版本号 |
| App | GetX 管状态、go_router 管导航、Dio 管网络、ScreenUtil 基准 `375x812` | 沿用 |
| App | 已有 `MediaAudioConverter`、`record`、相册资源选择、OSS 直传、私有资源换签缓存、全局播放服务 | 优先复用并按新资源类型扩展 |
| App | `/song/cover` 和 `pages/song_cover/` 已实现 AI 改编 | 完全保留，不作为新功能容器 |
| Admin | Flutter Web，页面通过 `AdminRepository` 调用 `ApiClient`；已有 App 切换、模型、计费、AI 任务、资源、角色、歌曲配置页 | 在现有页面增加类型/场景筛选和声音克隆子页，不建设第二套后台 |
| Admin | 当前 `pubspec.yaml` 已包含 `file_picker`、`video_player` | 后台上传继续复用现有依赖 |

---

## 1. 最终 Flutter 技术路线

### 1.1 移动 App

| 层级 | 采用方案 | 说明 |
|------|----------|------|
| UI | Flutter Material/Cupertino 混合现有实现 | 按 38 个定稿 Frame 对稿，不引入平行设计系统 |
| 屏幕适配 | `flutter_screenutil`，`designSize: Size(375, 812)` | 375x812 主验收；高度 878 的 Frame 视为滚动页面 |
| 状态管理 | GetX Controller + Store | 页面瞬时状态放 Controller；跨页面草稿与活动任务放 Store |
| 路由 | `go_router` + `RouteName` | 新路由统一写入 `lib/routes/`，受现有登录守卫保护 |
| 网络 | Dio + `HttpService` + `SongAPI`/新增 API 文件 | 自动带 `X-App-Code: catsinger`、版本、系统和 Token |
| 本地存储 | `GetStorage`；敏感凭据仍由现有安全存储负责 | 只保存草稿标识、任务 ID 和页面恢复信息，不保存签名 URL 或声音模型地址 |
| 音频 | `audioplayers` + 现有 `MusicPlayService`/试听播放器 | 试听与主播放器互斥；离页释放页面试听 |
| 录音 | `record` | 沿用权限申请和本地临时文件策略 |
| 视频提取/截取 | 现有 `MediaAudioConverter` 与 `catsinger/media_audio` MethodChannel | Android/iOS 已有 `extractAacAudio`、`exportAudioSegment` |
| 上传 | 现有 `/api/resources/direct-upload/prepare` + OSS + `/complete` | 100MB 文件不经过业务服务中转 |
| 私有资源 | 现有 `ResourceService` | 通过资源 ID换取短期地址并按用户会话隔离缓存 |

### 1.2 Web/Admin

| 层级 | 采用方案 | 说明 |
|------|----------|------|
| UI | 现有 Flutter Web 后台组件 | 以表格、筛选、状态标签、详情面板和确认弹窗为主 |
| 数据调用 | 页面 -> `AdminRepository` -> `ApiClient` | 页面不得直接拼接口 URL |
| App 隔离 | 现有服务端 App 列表和 `selectedAppCode` | 只有 `catsinger` 展示声音克隆管理入口 |
| 权限 | 现有角色权限返回和后端 403 | 菜单、按钮、接口三层均校验；前端隐藏不替代后端授权 |
| 模型/计费 | 复用现有 AI 模型选项与计费页 | 增加 `song.voice.train`、`song.voice.cover.generate` 场景 |
| 任务/资源 | 复用现有 AI Operations 和 Resources 页 | 通过任务类型、场景和资源类型筛选 |

---

## 2. 依赖策略

### 2.1 App 已有且直接复用

- `get`：Controller、Store 与依赖注入。
- `go_router`：页面导航和登录守卫。
- `dio`：业务 API。
- `get_storage`、`hive`、`flutter_secure_storage`：草稿、缓存和登录态。
- `flutter_screenutil`：375x812 适配。
- `record`：本人声音录制。
- `audioplayers`：素材/音色试听与作品播放。
- `wechat_assets_picker`、`image_picker`：相册视频、头像等系统媒体选择。
- `permission_handler`、`device_info_plus`：麦克风、相册和平台权限。
- `path_provider`：录音、提取和截取临时文件。
- `mime`：客户端预检；最终 MIME 以后端探测结果为准。
- `flutter_cache_manager`：受控资源缓存。

### 2.2 App 建议新增

| 依赖 | 用途 | 引入条件 |
|------|------|----------|
| `file_picker` | 从 Android/iOS 系统文件选择器选择 MP3/WAV/M4A/FLAC/OGG/AAC | 当前 App `pubspec.yaml` 尚未包含；V2.1 本地文件入口必须覆盖六种格式时引入 |

不为波形单独引入重量级 SDK。设计稿波形可使用服务端/本地解析得到的采样数据；首期若没有真实采样，使用固定尺寸的只读柱状可视化承载截取滑块，不伪装为精确声学波形。

### 2.3 Admin 依赖

Admin 当前已有 `dio`、`file_picker`、`video_player` 和 `intl`，V2.1 默认不新增包。音频预览优先使用浏览器原生能力或现有受控下载入口；若编码对账确认没有统一音频播放器，再在模块计划中单独评估，不在技术文档阶段预装依赖。

---

## 3. 启动、全局初始化与鉴权

### 3.1 App 启动

继续使用当前顺序：

1. `WidgetsFlutterBinding.ensureInitialized()`。
2. 安装隐私同意流程并固定竖屏。
3. `Global.init()` 注册基础 Store、HTTP、用户和资源服务。
4. 用户同意隐私后再初始化录音、缓存、支付、播放、登录恢复等受保护能力。
5. `ScreenUtilInit(designSize: Size(375, 812))` 启动页面。

V2.1 不在 App 启动时预加载全部音色或恢复全部任务。进入翻唱声音克隆入口后才加载功能配置、模型和音色；用户已有活动训练/翻唱任务时，仅恢复当前用户任务 ID 和必要摘要。

### 3.2 请求头与登录守卫

- 用户接口继续由 `HttpService` 自动携带 `X-App-Code: catsinger`。
- 登录后携带 Bearer Token；Token 失效沿用现有 401 处理。
- 所有声音资料、训练、翻唱和作品页面加入现有 session-required 路由集合。
- 创建本人音色、训练和翻唱是会员能力；会员判断以服务端结果为准，前端预判只减少无效操作。
- Admin 使用后台 Token，不能复用移动端用户 Token；403 显示权限不足，不能误跳登录。

---

## 4. App 目录与模块结构

新增复杂业务容器，保持每个独立页面拥有 `index.dart/controller.dart/view.dart`：

```text
lib/
├── apis/
│   ├── song.dart                         # 现有写歌、AI 改编、作品接口保持
│   └── song_voice_cover.dart             # V2.1 音色、训练、声音翻唱专属接口
├── models/
│   ├── data/
│   │   ├── song.dart                     # 作品增加 VOICE_COVER 兼容解析
│   │   └── song_voice_cover.dart         # 配置、音色、素材、训练/翻唱任务
│   └── params/
│       └── song_voice_cover_params.dart  # 专属请求，不继承写歌请求
├── pages/
│   ├── home/                             # 只增加第三个入口
│   ├── song_cover/                       # 现有 AI 改编，禁止改造成声音克隆
│   ├── song_voice_cover/
│   │   ├── index.dart
│   │   ├── controller.dart               # P02 业务编排与草稿摘要
│   │   ├── view.dart
│   │   ├── settings/                     # P03
│   │   ├── profile/                      # P04
│   │   ├── source/                       # P05
│   │   ├── recording/                    # P06
│   │   ├── trim/                         # P07
│   │   ├── materials/                    # P08
│   │   ├── training/                     # P09
│   │   ├── generating/                   # P10
│   │   └── widgets/                      # 音色卡、状态标签、素材行、固定按钮
│   └── song_works/                       # P11 类型筛选；P12 复用 player/
├── routes/
├── services/
│   └── media_audio_converter.dart        # 扩展必要的元数据读取，不复制新转换器
└── store/
    └── song_voice_cover.dart             # 跨页草稿、活动任务和恢复
```

### 4.1 Controller 职责

- 页面 Controller 负责加载、表单状态、按钮状态、用户交互和导航。
- `SongVoiceCoverStore` 负责当前草稿、选中来源、选中音色版本、模型选项、活动训练/翻唱任务 ID及回跳信息。
- `SongVoiceCoverAPI` 负责接口路径和返回解析。
- `ResourceService` 负责私有试听资源换签和缓存。
- 页面不直接操作 Dio、不保存 Provider URL、不自行计算最终价格。

### 4.2 不允许的结构

- 不把新功能继续堆入已超过千行的 `pages/song_cover/controller.dart`。
- 不在 `SongConfigStore` 中混入本人声音训练状态。
- 不创建第二套主播放器、支付页、资源缓存或登录守卫。
- 不用一个超大 Controller 同时持有 P02 至 P10 的所有生命周期；每个异步任务页面自行轮询，Store 只保存恢复锚点。

---

## 5. 路由设计

### 5.1 新增路由

| RouteName 建议 | 路径 | 页面 | 关键参数 |
|----------------|------|------|----------|
| `songVoiceCover` | `/song/voice-cover` | P02 翻唱主页 | `SongVoiceCoverEntryArgs?` |
| `songVoiceCoverSettings` | `/song/voice-cover/settings` | P03 设置 | 草稿由 Store 读取，返回保存结果 |
| `songVoiceProfile` | `/song/voices/new` 或 `/song/voices/:id/edit` | P04 音色资料 | `voiceId?` |
| `songVoiceSource` | `/song/voices/:id/source` | P05 来源选择 | `voiceId` |
| `songVoiceRecording` | `/song/voices/:id/recording` | P06 录音 | `voiceId` |
| `songVoiceTrim` | `/song/voices/:id/materials/:assetId/trim` | P07 截取 | `voiceId`、`assetId`、本地临时文件信息 |
| `songVoiceMaterials` | `/song/voices/:id/materials` | P08 素材与训练提交 | `voiceId` |
| `songVoiceTraining` | `/song/voice-training-tasks/:id` | P09 训练状态 | `taskId` |
| `songVoiceCoverGenerating` | `/song/voice-covers/:id/progress` | P10 翻唱状态 | `taskId` |

所有路由名集中加入 `RouteName`，页面注册到 `CustomRouter.config`，并加入 `_sessionRequiredRouteNames`。路由路径中的 `cover` 不能与现有 `/song/cover` 冲突。

### 5.2 入口参数

```dart
final class SongVoiceCoverEntryArgs {
  const SongVoiceCoverEntryArgs({
    this.sourceWorkId,
    this.preferredVoiceModelVersionId,
    this.from = 'home',
  });

  final String? sourceWorkId;
  final String? preferredVoiceModelVersionId;
  final String from;
}
```

- 首页进入：空草稿。
- P11/P12 重新翻唱：带原作品可追溯来源；Controller 必须重新确认源作品仍可读、音色仍可用。
- 会员或积分页回跳：从 Store 恢复草稿并重新读取模型价格。
- P10 成功：使用服务端目标 `workId` 进入现有 `RouteName.songPlayer`，不能使用全局当前播放歌曲替代。

### 5.3 返回规则

- P03 保存后回 P02；未保存返回时放弃当前编辑副本，不污染已保存草稿。
- P04/P08 有未保存变化时显示定稿离开确认弹窗。
- P09/P10 返回只停止当前页面轮询，不调用取消接口；服务端任务继续执行。
- 系统返回、顶部返回与设计稿关闭按钮行为一致。

---

## 6. Flutter 数据契约

### 6.1 配置与模型

`SongVoiceCoverConfig` 至少解析：

- `enabled`、`maintenanceMessage`。
- 歌曲格式、最大 100MB、最大 10 分钟。
- 训练单段 1至5分钟、累计 1至10分钟、累计最大 100MB。
- `voiceConsentVersion`、`songConsentVersion`。
- 轮询首间隔、最大间隔和页面刷新建议。
- pitch、人声、伴奏等参数范围。

`SongModelConfig` 继续使用现有模型结构，但声音翻唱按 `sceneCode=song.voice.cover.generate` 单独加载：

- UI 显示 `displayName/providerName/pricePoints`。
- 请求原样提交 `id/provider/model/pricingVersion`。
- 不把 `VOICE_COVER`、`voice_cover`、路由名或展示名写入 `model`。

### 6.2 音色与素材

建议模型：

- `SongVoiceProfileSummary`：平台 `id`、`ownerType`、显示版本、当前模型版本、状态、头像资源 ID、试听资源 ID、不可用原因。
- `SongVoiceProfileDetail`：资料修订、授权状态、素材统计、训练任务和可用渠道摘要。
- `SongVoiceMaterial`：素材 ID、资源 ID、来源、截取范围、时长、大小、质量结论、审核状态、保留时间。
- `SongVoiceModelVersion`：平台版本 ID、状态、试听资源、可用性、不可用原因；不解析或展示厂家模型 URL。
- `SongVoiceOption`：用于 P02 卡片的只读视图模型，将本人/官方音色统一展示，但保留 `ownerType`。

审核状态至少安全解析 `PENDING/PASS/REVIEW/REJECT/ERROR`。未知状态按不可用处理并保留原值用于日志，不能默认放行。

### 6.3 训练请求与响应

```dart
final class CreateSongVoiceTrainingParams {
  final String voiceId;
  final String modelOptionId;
  final int pricingVersion;
  final bool qualityWarningConfirmed;
  final String consentVersion;
  final String idempotencyKey;
}
```

`SongVoiceTrainingTask` 解析任务 ID、状态、阶段、进度、错误码/文案、价格、模型选项、可用音色版本 ID、创建/更新时间。页面不得根据本地计时自行把任务改为成功或失败。

### 6.4 翻唱创建请求

```dart
final class CreateSongVoiceCoverParams {
  final String provider;
  final String model;
  final String? sourceAudioAssetId;
  final String? sourceWorkId;
  final String voiceModelVersionId;
  final SongVoiceCoverSettings settings;
  final bool songRightsConfirmed;
  final String consentVersion;
  final String? modelOptionId;
  final int pricingVersion;
  final String idempotencyKey;
}
```

`toJson()` 规则：

- 不输出 `mode`。
- `sourceAudioAssetId/sourceWorkId` 必须二选一。
- `provider/model` 必须来自当前所选模型项。
- settings 固定为 `pitch/vocalVolume/accompanimentVolume`。
- 空字符串不发送；布尔确认必须显式为 `true`。
- 同一次用户提交重试复用原 `idempotencyKey`；用户返回修改输入后生成新键。

### 6.5 翻唱任务与作品

`SongVoiceCoverTask` 至少解析：

- `id/status/stageText/progressPercent/failureCode/failureMessage/workId`。
- `queueEnteredAt/providerAcceptedAt/deadlineAt`。
- 源歌曲、音色显示快照、真实 `provider/model` 展示摘要和价格快照。

倒计时规则：

- `providerAcceptedAt` 或 `deadlineAt` 为空：只显示“排队中”，不得启动 10 分钟倒计时。
- 两者有值：按服务端 `deadlineAt` 计算剩余时间，不用本地开始点击时间。
- 时间到仍以服务端终态为准；页面立即刷新，不自行退款或创建作品。

作品模型扩展：

- `songType=VOICE_COVER` 显示「翻唱声音克隆」。
- 继续解析现有 `audioResourceId/audioUrl/lyrics/timeline/favorite` 等播放器字段。
- 新增 `voiceProfileVersionId/voiceModelVersionId/voiceDisplayName` 等展示摘要时均做缺字段降级。
- `COVER` 继续显示 AI 改编，不因新类型改名或迁移。

---

## 7. API 封装

新增 `SongVoiceCoverAPI`，统一通过 `HttpService`：

| 方法 | 接口 | 用途 |
|------|------|------|
| `fetchConfig()` | `GET /api/song-config/voice-cover` | 功能开关、限制、授权版本 |
| `fetchModels(sceneCode)` | `GET /api/song-config/models` | 训练或翻唱真实模型选项；可复用现有通用方法 |
| `fetchVoices(scope)` | `GET /api/song-voices?scope=...` | 我的/官方音色 |
| `fetchVoice(id)` | `GET /api/song-voices/{id}` | 音色详情 |
| `createVoice(params)` | `POST /api/song-voices` | 新建本人音色资料 |
| `updateVoice(id, params)` | `PATCH /api/song-voices/{id}` | 按 revision 更新资料 |
| `deleteVoice(id, confirmation)` | `DELETE /api/song-voices/{id}` | 二次确认删除 |
| `bindVoiceMaterial(params)` | `POST /api/song-assets/voice-materials` | 资源绑定为训练素材并启动审核 |
| `bindCoverSource(params)` | `POST /api/song-assets/voice-cover-sources` | 资源绑定为源歌曲并启动审核 |
| `fetchAsset(id)` | `GET /api/song-assets/{id}` | 上传、探测与审核状态 |
| `retryAssetModeration(id)` | `POST /api/song-assets/{id}/moderation/retry` | 只重试 ERROR 审核 |
| `addMaterial(voiceId, params)` | `POST /api/song-voices/{id}/materials` | 绑定审核通过素材/截取范围 |
| `removeMaterial(voiceId, materialId)` | `DELETE /api/song-voices/{id}/materials/{materialId}` | 移除未被运行任务锁定的素材 |
| `createTraining(params)` | `POST /api/song-voice-training-tasks` | 创建训练任务 |
| `fetchTraining(id)` | `GET /api/song-voice-training-tasks/{id}` | 训练轮询 |
| `createVoiceCover(params)` | `POST /api/song-voice-covers` | 创建声音翻唱任务 |
| `fetchVoiceCover(id)` | `GET /api/song-voice-covers/{id}` | 翻唱轮询 |
| `fetchActiveVoiceCovers()` | `GET /api/song-voice-covers/active` | 恢复未完成翻唱任务 |

资源文件仍先调用现有 `ResourceAPI.prepareDirectUpload/uploadDirectFile/completeDirectUpload`，再绑定为具体歌曲素材。上传准备与业务绑定是两个阶段，前者成功不代表内容审核通过。

错误码统一映射到现有 `ApiException`，Controller 只根据类型执行：字段定位、toast、会员页、充值页、刷新模型、重新选择音色或进入审核状态。不得通过字符串包含关系判断业务状态。

---

## 8. App 状态与数据流

### 8.1 P02 翻唱主流程

```text
进入页面
  -> 并行加载功能配置、翻唱模型、我的音色、官方音色、活动任务
  -> 选择/上传源歌曲
  -> 等待资源探测与上传审核
  -> 选择当前模型组合下可用音色
  -> 确认歌曲权利
  -> 获取/显示模型实时报价
  -> POST /api/song-voice-covers
  -> 保存 taskId 并进入 P10
  -> 成功取得 workId
  -> 打开现有 SongPlayerPage
```

P02 首次加载允许局部分区失败：模型失败阻断提交；音色列表失败可单独重试；作品源失败不影响本地上传；活动任务失败只影响恢复入口。

### 8.2 训练流程

```text
P04 保存资料
  -> P05 选择录音/文件/相册视频
  -> P06 或 P07 生成本地可上传音频
  -> 公共 OSS 直传
  -> 绑定训练素材并等待审核
  -> P08 累计审核通过素材
  -> 质量阻断/告警确认
  -> 实时报价和会员积分确认
  -> 创建训练任务并进入 P09
  -> 模型、配置、试听均持久化且试听可播放
  -> 音色 AVAILABLE
```

### 8.3 任务轮询

- Controller 使用可取消 `Timer` 或循环 Future，并持有 epoch，离页后旧响应不得覆盖新页面。
- 轮询间隔优先使用配置，失败后有限退避；切前后台时暂停/恢复。
- 同一任务禁止多个页面并行轮询；Store 只登记活动 ID，具体 Controller 获得页面所有权。
- 终态后停止轮询并刷新积分、音色或作品 Store。
- 不调用取消接口；页面上的“退出等待”只是导航。

### 8.4 按钮并发

- 上传、保存资料、提交训练、提交翻唱分别使用独立 busy 状态。
- 按钮点击后同步置 busy，防止双击窗口。
- 业务失败保留草稿和同一次请求幂等键；用户修改关键字段后重建幂等键。
- 后端返回原任务时直接恢复该任务，不提示重复扣费。

---

## 9. 媒体、上传、试听与安全审核

### 9.1 客户端预检

| 类型 | App 预检 | 后端最终判定 |
|------|-----------|--------------|
| 翻唱源歌曲 | MP3/WAV/M4A/FLAC/OGG/AAC、<=100MB、<=10分钟 | 文件魔数、解码、音轨、真实 MIME/大小/时长、内容审核 |
| 训练素材 | 单段 1至5分钟；累计 1至10分钟、<=100MB | 同上并执行质量检测和安全审核 |
| 头像 | 设计允许的图片格式和尺寸提示 | 实际 MIME、大小、图片解码与审核 |
| 显示文字 | 长度、空白和字符基本校验 | 文本安全审核 |

客户端校验只用于快速反馈，不能把本地读取值当作平台事实。

### 9.2 文件与相册

- 本地音频使用系统文件选择器；不申请整盘文件权限。
- 相册视频继续使用现有资源选择器，取本地路径后调用 `MediaAudioConverter.extractAacM4aFromMp4`。
- 截取继续调用 `exportAudioSegmentM4a`，输出 M4A 只是客户端上传中间格式，不等于厂家最终成品格式。
- 录音中断、来电或权限撤回时保留已经落盘且可读的本地片段，并提示用户确认重录或继续。

### 9.3 OSS 直传

1. 使用业务资源类型请求 `prepare`。
2. 通过现有上传器把单文件上传到签发对象。
3. 调用 `complete`，后端 HEAD 校验后返回资源 ID。
4. 调用素材绑定接口创建 Catsinger 业务素材并启动审核。
5. 轮询素材状态，只有 `PASS` 才计入训练或翻唱可用输入。

不得在日志、Store 或路由参数中持久化 OSS 签名 URL。失败重试需要重新获取票据；完成回调不可复用到另一个文件。

### 9.4 试听互斥

- 页面内只有一个轻量试听播放器。
- 点击新音色/素材先停止上一条。
- 开始主播放器作品播放前停止页面试听。
- 离开 P02、P06、P07、P08 时释放页面播放器。
- 私有试听优先通过 `ResourceService.localFile(resourceId: ..., mediaType: audio)`；回退 URL 只兼容旧响应。

---

## 10. 页面技术摘要与设计映射

设计真源：`../../01-需求/references/images/v2.1/ai-cover-voice-clone/`。38 个 Frame 均需在模块计划和截图验收矩阵中落点。

### 10.1 P01 首页入口

- 基于当前 `pages/home/` 增加第三张「翻唱声音克隆 NEW」卡。
- 现有 `AI写歌` 与 `改编歌曲` 文案、回调和路由不变。
- `HomePage` 增加独立 `onVoiceCoverCreate` 回调，主壳调用 `context.pushNamed(RouteName.songVoiceCover)`。
- 后端开关关闭时保留入口但禁用，展示维护文案；配置失败不影响热门案例。
- 对稿：`39-114-9333-home.png`。

### 10.2 P02 翻唱声音克隆主页

- 独立模块，不使用现有三步 `SongCoverPage`。
- 页面区块：标题、源歌曲卡、翻唱设置摘要、我的/官方音色 Tab、音色列表、定制音色入口、歌曲权利确认、实时报价、固定提交按钮。
- 源歌曲支持作品库和本地上传；解析/审核中显示状态，失败保留其他草稿。
- 音色按当前所选 `provider/model` 校验绑定；模型切换导致音色不可用时清空选择并说明原因。
- 对稿：01至15、08 使用协议状态图。

### 10.3 P03 翻唱设置

- 编辑副本包含 `pitch`、`vocalVolume`、`accompanimentVolume`。
- 数值范围从配置读取，不在 Widget 写死；本地先限制，后端最终校验。
- 保存后更新 P02 摘要；返回不保存。
- 对稿：`16-114-5767-cover-settings.png`。

### 10.4 P04 本人音色资料

- 默认头像和默认名称允许直接继续；自定义头像、名称和简介触发审核状态。
- 资料模型必须带 `revision`，保存冲突提示刷新后重新编辑。
- 每次新训练都需要重新确认本人声音权利和风险授权。
- 对稿：26至31、27版权、28离开提醒。

### 10.5 P05 训练来源选择

- 三个动作：立即录音、本地上传、相册视频。
- 权限按点击申请；拒绝后展示系统设置入口。
- 相册视频先提取音频再进入 P07，不直接把视频发给训练 Provider。
- 对稿：17、23、24。

### 10.6 P06 录音采集

- 使用 `record` 创建临时 M4A；显示计时、视觉波形、示例文本、开始/停止/试听/重录。
- 1 分钟前不能完成，最多 5 分钟自动停止并提示。
- 保存后走公共直传和素材审核，不把本地路径长期保存为业务素材。
- 对稿：32至36。

### 10.7 P07 上传与截取

- 展示文件名、大小、总时长、播放进度、截取起止点、截取时长和重新上传。
- 选区 1至5分钟；确认时导出新片段并作为独立资源上传。
- 解码、提取、范围或上传失败时保留音色资料草稿。
- 对稿：25及相关上传失败状态。

### 10.8 P08 训练素材与提交

- 素材行展示来源、时长、大小、质量、审核状态、试听和删除。
- 只累计审核通过且质量可用的素材；低置信度告警需用户明确确认。
- 达到规则后加载训练模型和价格，提交前再次校验会员、授权、价格版本。
- 对稿：18至22。

### 10.9 P09 音色训练状态

- 展示平台排队、厂家排队、训练、保存模型/配置、试听审核、可用、失败和暂不可用。
- 成功按钮只有在试听资源可实际播放时启用。
- 失败释放积分由后端处理；页面刷新积分并显示归一化原因。
- 不提供取消；重新训练回到 P04/P08 创建新任务。

### 10.10 P10 翻唱生成状态

- 平台排队时不显示 10 分钟倒计时。
- 厂商接单并返回 `deadlineAt` 后显示服务端截止时间倒计时。
- 保存、探测、成品审核均作为真实阶段展示；任何阶段失败不得打开作品。
- 离开等待不取消；活动任务可从 P02/P11 恢复。
- 成功后按本次任务 `workId` 打开现有播放器。

### 10.11 P11 我的作品

- 在现有 `pages/song_works/` 增加 `VOICE_COVER` 类型筛选与「翻唱声音克隆」标签。
- 生成中/审核中项进入 P10；失败项显示原因和重新提交；完成项进入现有播放器。
- 15 天展示提示和 30 天清理由后端决定，前端不自行删除记录。
- 对稿：`37-114-7618-works.png`。

### 10.12 P12 播放器

- 直接复用 `pages/song_works/player/` 的 `SongPlayerPage`、`SongPlayerController`、播放队列、歌词、下载、分享、收藏和删除行为。
- 仅补 `VOICE_COVER` 数据标签、音色摘要和「重新翻唱」动作。
- 不创建 `song_voice_cover/result/`，不更改播放器布局。
- 测试通过条件：目标作品真实开始播放，播放进度连续增长，不接受“任务成功”替代播放验证。

---

## 11. Web/Admin 技术设计

### 11.1 目录落点

```text
lib/
├── core/api_client.dart
├── data/admin_repository.dart
├── models/
│   ├── admin_models.dart
│   └── song_voice_cover_admin.dart       # 新增声音资料、训练、审核视图模型
├── pages/
│   ├── shell_page.dart
│   ├── app/catsinger/
│   │   ├── song_config_page.dart         # 增加声音克隆入口/标签
│   │   └── song_voice_profiles_page.dart # 官方/本人音色资料与发布
│   └── common/
│       ├── ai_model_options_page.dart     # 两个新场景
│       ├── ai_billing_page.dart           # 100/200 默认计费项
│       ├── ai_operations_page.dart        # 训练/翻唱任务筛选和详情
│       ├── resources_page.dart            # 新资源类型、受控预览、保存重试
│       └── system_page.dart               # 新权限点
```

后台不按 W01至W12 每项复制一页。W01 可作为导航快捷入口，把用户带到已有页面的预设筛选；W02/W03/W07至W12 主要扩展现有通用页面，W04至W06 是 Catsinger 歌曲配置中的主要新页面。

### 11.2 App 切换

- App 列表继续读取服务端，不在前端写死完整列表。
- `selectedAppCode` 切换后清空上一 App 列表、表单草稿、选择项和请求结果，再加载目标 App。
- `catsinger` 才展示声音克隆导航；其他 App 即使手工构造页面状态也必须被后端拒绝。
- 每个异步请求记录请求发起时 AppCode，响应回来时不一致则丢弃，沿用模型选项页现有防串 App 方式。

### 11.3 W01至W12 技术映射

| 后台需求 | Flutter Web 落点 | 核心交互 |
|----------|------------------|----------|
| W01 总览 | Shell 快捷入口 + AI Operations 预设筛选 | 告警、积压、失败、跳转 |
| W02 模型路由 | `AiModelOptionsPage`、`AiBillingPage` | 真实 providerCode/modelCode、两个新 sceneCode、启停和默认 |
| W03 价格 | `AiBillingPage` | 训练/翻唱分别配置，价格版本变化明确提示 |
| W04 官方音色列表 | 新 `SongVoiceProfilesPage` 官方 Tab | 筛选、状态、试听、创建、编辑、发布/下架 |
| W05 官方音色编辑 | 同页详情/对话框或独立编辑页 | 资料修订、权利、素材、训练、绑定、发布门禁 |
| W06 本人音色 | 同页本人 Tab | 脱敏查询、版本、渠道绑定、暂不可用和任务跳转 |
| W07 安全审核 | 扩展 AI Operations/审核视图 | 受控预览、机器重试、人工复核和原因 |
| W08 训练任务 | `AiOperationsPage` | `VOICE_TRAINING` 筛选、状态、积分、资源保存重试 |
| W09 翻唱任务 | `AiOperationsPage` | `VOICE_COVER` 筛选、平台/厂家时间、作品、审核 |
| W10 作品资源 | 现有歌曲作品 + `ResourcesPage` | VOICE_COVER 筛选、隐藏/恢复、真实格式与生命周期 |
| W11 权限 | `SystemPage` | 角色分配最小权限点 |
| W12 审计 | 现有审计入口/任务详情 | 筛选业务类型，展示操作人、原因和前后版本 |

### 11.4 Admin 页面规则

- 所有列表有加载、空、错误、查询中和分页状态。
- 发布、下架、人工复核、隐藏/恢复、资源重试必须二次确认并展示后端结果。
- 禁止提供取消训练/翻唱、强制成功、修改厂家状态或重新调用厂家按钮。
- 已发布官方音色编辑产生新草稿；旧发布版本继续可用，不在列表乐观替换。
- 人工复核弹窗必须填写原因并携带 `revision`，409/冲突时保留输入并要求刷新。
- 模型编码与展示名分栏显示，避免运营把 `VOICE_COVER` 填进厂家模型字段。

---

## 12. 草稿、本地存储与恢复

### 12.1 草稿内容

允许保存：

- 源作品 ID或已完成上传的业务素材 ID。
- 音色平台 ID和模型版本 ID。
- 设置值、所选模型项 ID、授权版本、来源页面。
- 活动训练/翻唱任务 ID。

禁止保存：

- OSS/Provider 签名 URL、厂家模型文件地址、厂家音色 ID。
- 原始声音二进制或长期本地路径作为业务真源。
- 用户 Token、支付信息或后台权限信息。

### 12.2 恢复规则

- 恢复时重新查询素材、音色、模型和价格；本地只作为定位线索。
- 资源已删除、审核拒绝、音色不可用或模型停用时清除对应选择，不静默替换。
- 会员/充值回跳保留页面输入，但必须重新报价。
- App 进程重启后优先恢复活动任务；任务已终态则刷新作品/音色后清除活动 ID。
- 用户退出登录或撤回隐私同意时清空 V2.1 草稿和页面试听缓存引用。

---

## 13. UI 与屏幕适配规则

### 13.1 尺寸

- App 继续以 375x812 为布局基准，Figma 中 375x812 Frame 可直接按 `.w/.h/.sp/.r` 映射。
- 375x878 Frame 表示可滚动内容，不把 878 当成新的 ScreenUtil 高度。
- 390x844、414x896 抽查安全区、长文件名、弹窗、键盘和固定按钮。
- 页面使用 `SafeArea` 和可滚动主体；固定提交按钮使用底部安全区，并避让键盘、底部导航和迷你播放器。

### 13.2 组件

- 返回、播放、删除、重试、上传等使用现有图标体系，熟悉动作不做文字胶囊替代。
- 音色卡、素材行和任务状态抽成同业务 widgets；不把页面区块全部做成独立卡片嵌套。
- 开关、滑杆、分段 Tab、复选框按语义使用，不用普通按钮模拟。
- 文案不能写死积分、限制和厂家模型名；由后端配置和模型选项返回。

### 13.3 状态完整性

每个异步分区至少有 `loading/empty/content/error/retry`。按钮禁用时页面应能看到首个阻断原因，例如“歌曲审核中”“请选择可用音色”“价格暂未配置”，不能只让按钮无反应。

---

## 14. 错误与异常处理

| 后端错误 | Flutter 处理 |
|----------|--------------|
| `MEMBERSHIP_REQUIRED` | 保存草稿，进入会员页，返回后重载配置和报价 |
| `INSUFFICIENT_POINTS` | 保存草稿，进入充值页，返回后刷新积分并重新报价 |
| `CONSENT_REQUIRED` | 打开对应协议页，不自动勾选 |
| `CONTENT_REVIEW_PENDING` | 显示审核中，禁用训练/翻唱 |
| `CONTENT_REJECTED` | 定位头像、文字或素材，允许修改/重传 |
| `CONTENT_REVIEW_UNAVAILABLE` | 保持不可用并提供原目标审核重试 |
| `MEDIA_*` | 显示格式、大小、时长或解码具体问题，不清空其他草稿 |
| `VOICE_NOT_READY` | 清除失效音色选择，跳音色列表或训练状态 |
| `VOICE_PROVIDER_BINDING_MISSING` | 不自动跨渠道，提示音色暂不可用 |
| `MODEL_SELECTION_REQUIRED/MODEL_ROUTE_MISMATCH/MODEL_NOT_AVAILABLE` | 刷新模型并要求重新选择 |
| `QUOTE_EXPIRED` | 展示新价格并再次确认 |
| `DUPLICATE_REQUEST` | 使用后端返回原任务继续，不重复提示扣费 |
| `PROVIDER_BUSY` | 保留草稿，稍后重试 |
| `PROVIDER_BALANCE_ERROR` | 显示平台服务异常，不跳用户充值 |
| `GENERATION_TIMEOUT` | 进入失败态，刷新积分，允许保参重试 |

所有错误页/弹窗保留 `traceId` 的复制入口或诊断摘要，但不展示 Token、签名 URL和厂家完整响应。

---

## 15. 测试与自动化规则

### 15.1 代码验证

移动 App：

- `dart format` 仅格式化本次修改文件。
- `flutter analyze`。
- `flutter test`，重点覆盖参数序列化、Controller 状态、草稿恢复、路由和播放器目标作品锁定。

Web/Admin：

- `dart format` 仅格式化本次修改文件。
- `flutter analyze`。
- `flutter test`，覆盖 App 切换、权限、模型编码、发布门禁和并发编辑。

### 15.2 移动端用户测试

- 375x812 完整验收 P01至P11；390x844、414x896 抽查。
- Android 真机和 iOS 真机优先；iOS 无真机时使用模拟器，真机和模拟器都没有则 iOS 不通过。
- 系统文件选择器、麦克风、相册视频、权限拒绝、后台恢复必须实测。
- 本人音色训练成功只有在平台试听真实可播放时通过。
- 翻唱成功只有在目标 `workId` 的作品真实开始播放且进度连续增长时通过。
- 任务状态成功、接口 200、文件下载成功或 Mock 成功都不能替代可播放验收。

### 15.3 Python 自动化

测试工程继续使用 `/Users/soul/code/lxwx/test/catsinger`：

- Android 用 ADB，iOS 用 Appium/XCUITest。
- 自动化用例 ID 必须映射 V2.1 测试文档，不以脚本代替测试用例。
- 付费训练、翻唱、删除音色/作品使用独立安全开关。
- 每条记录截图和页面树；失败额外采集日志。
- 需要等待异步成品的用例必须轮询到可播放或明确失败/超时，不能在提交后提前 PASS。

---

## 16. 开发任务清单

### 16.1 Flutter App

| ID | 模块 | 主要代码落点 | 完成口径 |
|----|------|--------------|----------|
| T-F001 | 契约与数据层 | `apis/song_voice_cover.dart`、模型、参数、Store | 独立 API，无 `mode`，真实 provider/model |
| T-F002 | 首页入口 | `pages/home/`、`routes/` | 三业务入口独立，旧入口无变化 |
| T-F003 | P02/P03 | `pages/song_voice_cover/`、`settings/` | 上传、音色、设置、授权、报价闭环 |
| T-F004 | P04/P05 | `profile/`、`source/` | 资料、审核状态和三种采集入口 |
| T-F005 | P06/P07/P08 | `recording/`、`trim/`、`materials/` | 录音、提取、截取、上传、审核、质量限制 |
| T-F006 | P09 | `training/` | 训练轮询、模型保存、试听门禁和重训 |
| T-F007 | P10 | `generating/` | 平台排队与厂商接单后倒计时准确 |
| T-F008 | P11/P12 | `song_works/`、现有 `player/` | 类型、恢复、重新翻唱和真实播放 |
| T-F009 | 会员/积分/草稿 | Store、会员/充值回跳 | 重新报价、幂等和进程恢复 |
| T-F010 | 验证 | `test/`、真机与截图 | 命令、双平台、三尺寸和可播放门禁通过 |

### 16.2 Web/Admin

| ID | 模块 | 主要代码落点 | 完成口径 |
|----|------|--------------|----------|
| T-W001 | 导航/App权限 | `shell_page.dart` | catsinger 可见，其他 App 不串数据 |
| T-W002 | 模型/价格 | `ai_model_options_page.dart`、`ai_billing_page.dart` | 两个新场景、真实模型、100/200 可配置 |
| T-W003 | 官方音色 | Catsinger 声音资料页 | 草稿、训练、绑定、试听、发布/下架 |
| T-W004 | 本人音色 | Catsinger 声音资料页 | 脱敏查询、版本、不可用和任务跳转 |
| T-W005 | 审核 | AI Operations/审核视图 | 重试、人工复核、原因和 revision |
| T-W006 | 任务 | `ai_operations_page.dart` | 训练/VOICE_COVER 筛选和资源恢复 |
| T-W007 | 作品/资源/审计 | 现有歌曲、资源和审计页 | 类型、隐藏/恢复、生命周期和日志 |
| T-W008 | 验证 | `test/` + 浏览器操作 | App 切换、权限、表单和契约通过 |

每个任务在后续总体开发计划中继续拆为可恢复步骤；本文状态通过前不得进入编码。

---

## 17. 项目专属规则

### 17.1 继承规则

- 继承 App 工程现有 GetX、go_router、Dio、`index.dart + part`、Store、主题、资源缓存和测试模式。
- 继承 Admin 工程 `core/data/models/pages` 分层、App 切换和 Repository 边界。
- 继承 375x812 适配、隐私同意后初始化受保护能力、私有资源换签和会话缓存隔离。

### 17.2 裁剪规则

- 不新建 V2.1 Figma 设计计划，直接以已定稿 38 个 Frame 为视觉真源。
- 不新建翻唱结果页；P12 复用现有播放器。
- 不给 App 暴露厂家模型文件、配置文件或长期试听 URL。
- 不在前端复制积分冻结、审核结论、超时或作品生命周期判定。

### 17.3 特化规则

- 展示名固定为「翻唱声音克隆」；`AI 改编` 保持现有名称。
- 新模块名使用 `song_voice_cover`，禁止使用已占用的 `song_cover`。
- 业务类型 `VOICE_COVER` 与厂家 `provider/model` 是不同概念。
- 平台排队不倒计时；厂商接单后才按 `deadlineAt` 展示 10 分钟。
- 所有上传图片、音频和可展示文字都必须展示审核状态和业务门禁。

---

## 18. 数据库与配置改动披露

- **Flutter 数据库改动：无。** App 与 Admin 均不直接创建或迁移服务端表。
- **客户端本地数据改动：有。** 新增 V2.1 草稿和活动任务恢复键；必须带版本前缀并在退出登录/隐私撤回时清理。
- **后台数据配置影响：有。** Admin 将维护两个 AI 场景、真实厂家模型、价格、官方音色、渠道绑定和权限，但最终写入及校验由 Java 后端负责。

---

## 19. 评审门禁与下一步

本技术文档已完成评审并标记为 `done`。当前已进入：

1. 第 9 步 Flutter 总体开发计划评审。
2. 总体计划通过后进入第 11 步 Flutter/App 与 Web/Admin 模块开发文档。
3. 模块文档通过后才按模块顺序进入编码。

编码前必须重新确认移动端实际构建号、三端分支/commit/dirty diff、后端最终 API DTO、算道真实模型编码和测试环境配置。任何改变用户流程、价格、安全规则或三业务边界的结果都必须新建 CHG 并回卷需求，不能在编码中静默调整。
