# 喵喵写歌 Java 后端技术文档

> 文档版本：v1.0-design-mvp
> 当前状态：active
> 最近更新：2026-06-11
> 当前阶段：8 后端 Java 技术文档
> 关联 PRD：`../01-需求/requirements.md`
> 关联技术方案：`../02-技术方案/tech-plan.md`
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 基础包名：`com.lxwx.narrateservice`
> 技术栈：Java 21 + Spring Boot 3.3.0 + Gradle + MyBatis-Plus + PostgreSQL + Redis

---

## 1. 文档目标

本文档用于把 CHG-0010 后的喵喵写歌真功能范围同步到后端实现口径，作为后续 Java 总体开发计划、模块开发文档和 Java 编码的唯一后端技术依据。

当前版本重点不是重新搭一个服务，而是在现有 `lxwxservice` 中补齐 `catsinger` 独立业务模块：

- `appCode=catsinger` 与 schema routing 保持隔离。
- 用户端接口继续走 `X-App-Code: catsinger`。
- 后台接口支持 App 切换，读取服务端全部 appCode 配置。
- 歌曲生成接 MiniMax，预留 provider/model 扩展。
- 生成结果必须转存到自有资源，本地或云存储都由后端控制。
- 积分按“生成前冻结、成功扣减、失败退款”处理。
- 歌词支持逐句时间轴，Provider 无时间轴时可估算或后台手工。

## 2. 当前工程事实

现有后端已经具备：

| 能力 | 当前状态 | 后续处理 |
|------|----------|----------|
| 多 App schema routing | 已有 `narrate`、`catsinger`、`catcomic` 映射 | 保持 `common + {appCode}` 迁移规则 |
| catsinger Flyway | 已有 `catsinger/V13__catsinger_song.sql`、`V14__song_inspiration_config.sql` | 需新增或扩展表字段，补齐 v1 真功能 |
| catsinger 基础包 | 已有 `app/catsinger/song` Controller / Service / Entity / Repository / VO / DTO | 继续拆分 Service，不让一个 `SongService` 承担所有复杂链路 |
| 用户端配置与作品骨架 | 已有模型、情景、示例、灵感、生成、作品、专辑基础接口 | 需补案例、上传、AI 帮写、进度、分享、重新生成、收藏、资源字段 |
| Admin 歌曲配置骨架 | 已有 `AdminSongConfigController` / `AdminSongConfigService` | 需补任务、作品、专辑、权限、商品、灵感配置可视化接口 |
| 积分/会员/支付 | 既有公共模块 | catsinger 必须按 appCode/schema 过滤，不串 narrate |

## 3. 后端模块结构

建议在现有目录上演进，不做大面积搬家。

```text
src/main/java/com/lxwx/narrateservice/
├── app/catsinger/song/
│   ├── controller/
│   │   ├── SongConfigController.java
│   │   ├── SongCaseController.java
│   │   ├── SongAssetController.java
│   │   ├── SongLyricsController.java
│   │   ├── SongGenerationController.java
│   │   ├── SongWorkController.java
│   │   └── SongAlbumController.java
│   ├── dto/
│   ├── entity/
│   ├── repository/
│   ├── provider/
│   │   ├── SongGenerationProvider.java
│   │   ├── SongProviderFactory.java
│   │   └── minimax/
│   ├── storage/
│   │   ├── SongResourceStorageService.java
│   │   ├── ResourceStorageProvider.java
│   │   ├── LocalResourceStorageProvider.java
│   │   └── CloudObjectStorageProvider.java
│   ├── service/
│   │   ├── SongConfigService.java
│   │   ├── SongCaseService.java
│   │   ├── SongAssetService.java
│   │   ├── SongLyricAssistService.java
│   │   ├── SongGenerationService.java
│   │   ├── SongWorkService.java
│   │   ├── SongAlbumService.java
│   │   ├── SongShareService.java
│   │   └── LyricTimelineService.java
│   └── vo/
├── admin/
│   ├── controller/
│   │   ├── AdminAppController.java
│   │   ├── AdminSongConfigController.java
│   │   ├── AdminSongGenerationController.java
│   │   ├── AdminSongWorkController.java
│   │   ├── AdminSongAlbumController.java
│   │   ├── AdminProductController.java
│   │   └── AdminRolePermissionController.java
│   └── service/
└── common/
```

分层约束：

- Controller 只做参数解析、鉴权用户读取、调用 Service、返回 `ApiResponse`。
- Service 承担业务规则、事务、积分、Provider 调用、资源保存。
- Repository/Mapper 只做数据库访问，复杂查询留在 Mapper 层。
- 多表写、积分冻结/扣减/退款、作品创建必须用 `@Transactional(rollbackFor = Exception.class)`。
- 新增 public 类和 public 方法写中文 Javadoc。

## 4. 配置设计

### 4.1 appCode 与 schema

```yaml
app:
  schema-routing:
    mappings:
      catsinger: ${CATSINGER_DB_SCHEMA:catsinger}
```

要求：

- `X-App-Code` 缺失、非法、不存在映射时拒绝。
- JWT 中 appCode 与请求头不一致时拒绝。
- `catsinger_song_*` 只存在 catsinger schema，不进入 narrate schema。
- 公共表继续按 `db/migration/common` 创建。

### 4.2 MiniMax Provider

```yaml
song:
  providers:
    minimax:
      enabled: ${MINIMAX_ENABLED:false}
      api-key: ${MINIMAX_API_KEY:}
      group-id: ${MINIMAX_GROUP_ID:}
      base-url: ${MINIMAX_BASE_URL:https://api.minimax.io}
      connect-timeout-ms: ${MINIMAX_CONNECT_TIMEOUT_MS:10000}
      read-timeout-ms: ${MINIMAX_READ_TIMEOUT_MS:120000}
```

说明：

- 真实密钥等代码完成后按既有阿里云短信配置方案添加。
- 请求日志只记录 provider、model、traceId、耗时、状态，不记录密钥和完整歌词。
- provider 抽象必须支持后续新增其他平台。

### 4.3 资源持久化

```yaml
song:
  storage:
    provider: ${SONG_STORAGE_PROVIDER:LOCAL}
    local-dir: ${SONG_STORAGE_LOCAL_DIR:./uploads/song}
    public-base-url: ${SONG_STORAGE_PUBLIC_BASE_URL:}
    bucket: ${SONG_STORAGE_BUCKET:}
    region: ${SONG_STORAGE_REGION:}
    cdn-host: ${SONG_STORAGE_CDN_HOST:}
```

v1 可先实现 `LOCAL`，生产若接 OSS/COS/S3，只替换 `ResourceStorageProvider`，用户端接口不变。

## 5. 数据库与迁移

### 5.1 迁移目录

| 目录 | 表归属 | 说明 |
|------|--------|------|
| `db/migration/common` | 公共表 | users、admin、积分、支付、商品、权益、配置等 |
| `db/migration/narrate` | 剧说专属表 | `narrate_*`、`home_case_*`、任务中心规则 |
| `db/migration/catsinger` | 喵喵写歌专属表 | `catsinger_song_*`、歌曲默认配置 |

后续新增字段必须新增迁移，不再改已发布迁移。开发期若清库验证，可按当前项目约定重建 schema。

### 5.2 v1 表清单

| 表 | 当前状态 | v1 处理 |
|----|----------|---------|
| `catsinger_song_model_configs` | 已有 | 补后台配置字段、默认价格 100、排序、配置 JSON |
| `catsinger_song_scenarios` | 已有 | 保持情景启停和排序 |
| `catsinger_song_scenario_questions` | 已有 | 保持问题、标签 JSON、必填、排序 |
| `catsinger_song_examples` | 已有 | 补封面/音频资源归属、歌词时间轴手工录入 |
| `catsinger_song_cases` | 待新增 | 首页热门案例、案例详情、模板回填 |
| `catsinger_song_assets` | 待新增 | 图片写歌、参考音频、示例素材、专辑封面上传资源 |
| `catsinger_song_generation_tasks` | 已有但需扩展 | 补进度、阶段、剩余时间、图片/音频资源、AI 帮写元数据 |
| `catsinger_song_works` | 已有但需扩展 | 补资源持久化、下载、分享、收藏、时间轴来源 |
| `catsinger_song_albums` | 已有 | 补简介、封面、隐藏、排序 |
| `catsinger_song_album_items` | 已有 | 保持唯一关系和排序 |
| `catsinger_song_share_records` | 待新增 | 分享记录、分享渠道、分享 URL |
| `catsinger_song_operation_logs` | 待新增 | 后台隐藏、上下架、配置变更审计 |
| `admin_role_permission` | 待确认/扩展 | 超级管理员给角色分配管理块 |

### 5.3 关键索引

| 表 | 索引 |
|----|------|
| `catsinger_song_generation_tasks` | `(user_id, idempotency_key)` unique、`(user_id, created_at desc)`、`(provider, provider_task_id)` |
| `catsinger_song_works` | `(user_id, created_at desc)`、`generation_task_id`、`status` |
| `catsinger_song_album_items` | `(album_id, work_id)` unique、`(album_id, sort_order, id)` |
| `catsinger_song_assets` | `(user_id, asset_type, created_at desc)`、`resource_key` |
| `catsinger_song_cases` | `(enabled, sort_order, id)` |
| `catsinger_song_share_records` | `(work_id, created_at desc)` |

## 6. 用户端 API

所有用户端接口：

- 请求头：`X-App-Code: catsinger`
- 鉴权：Bearer JWT，除非后续明确允许游客浏览示例。
- 响应：沿用现有 `ApiResponse<T>`。

| 模块 | 方法 | 路径 | Service | 说明 |
|------|------|------|---------|------|
| 配置 | GET | `/api/song-config/models` | `SongConfigService` | 模型、价格、默认模型 |
| 配置 | GET | `/api/song-config/scenarios` | `SongConfigService` | 情景模板和问题 |
| 配置 | GET | `/api/song-config/examples` | `SongConfigService` | 首页示例歌曲 |
| 配置 | GET | `/api/song-config/inspiration` | `SongConfigService` | 灵感速递 |
| 案例 | GET | `/api/song-cases` | `SongCaseService` | 热门案例列表 |
| 案例 | GET | `/api/song-cases/{id}` | `SongCaseService` | 案例详情 |
| 作品 | GET | `/api/song-works/recent` | `SongWorkService` | 首页最近作品 |
| 资源 | POST | `/api/song-assets/images` | `SongAssetService` | 图片写歌上传 |
| 资源 | POST | `/api/song-assets/reference-audios` | `SongAssetService` | 参考音频上传 |
| 作词 | POST | `/api/song-lyrics/assist` | `SongLyricAssistService` | AI 帮写歌词 |
| 生成 | POST | `/api/song-generations` | `SongGenerationService` | 创建歌曲任务 |
| 生成 | GET | `/api/song-generations/{id}` | `SongGenerationService` | 查询任务进度 |
| 作品 | GET | `/api/song-works` | `SongWorkService` | 作品列表 |
| 作品 | GET | `/api/song-works/{id}` | `SongWorkService` | 作品详情 |
| 作品 | POST | `/api/song-works/{id}/download-url` | `SongWorkService` | 下载地址 |
| 作品 | POST | `/api/song-works/{id}/share` | `SongShareService` | 分享 |
| 作品 | POST | `/api/song-works/{id}/regenerate` | `SongGenerationService` | 重新生成 |
| 作品 | POST | `/api/song-works/{id}/favorite` | `SongWorkService` | 收藏切换 |
| 作品 | POST | `/api/song-works/disable` | `SongWorkService` | 用户隐藏/删除 |
| 专辑 | GET | `/api/song-albums` | `SongAlbumService` | 专辑列表 |
| 专辑 | POST | `/api/song-albums` | `SongAlbumService` | 创建专辑 |
| 专辑 | GET | `/api/song-albums/{id}` | `SongAlbumService` | 专辑详情 |
| 专辑 | POST | `/api/song-albums/{id}/songs` | `SongAlbumService` | 添加歌曲 |
| 专辑 | DELETE | `/api/song-albums/{id}/songs/{songId}` | `SongAlbumService` | 移出歌曲 |

## 7. 核心请求与响应

### 7.1 `CreateSongGenerationRequest`

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `mode` | string | 是 | `simple`、`custom`、`scenario`、`image`、`instrumental` |
| `provider` | string | 否 | 默认 `minimax` |
| `model` | string | 否 | 默认后端配置模型 |
| `prompt` | string | 条件 | 灵感创作、情景、图片描述 |
| `lyrics` | string | 条件 | 高级创作或 AI 帮写结果 |
| `title` | string | 否 | 歌曲名 |
| `styleTags` | array | 否 | 曲风标签 |
| `instrumental` | boolean | 否 | 纯音乐 |
| `lyricsOptimizer` | boolean | 否 | 是否让 Provider 优化歌词 |
| `sceneCode` | string | 否 | 情景编码 |
| `sceneAnswers` | object | 否 | 情景问答 |
| `imageAssetId` | long | 否 | 图片写歌上传资源 |
| `referenceAudioAssetId` | long | 否 | 参考音频资源 |
| `idempotencyKey` | string | 是 | 防重复提交 |

### 7.2 `SongGenerationTaskResponse`

必须包含：

- `id`
- `status`
- `progressPercent`
- `stageText`
- `estimatedRemainingSeconds`
- `provider`
- `model`
- `costPoints`
- `workId`
- `failureReason`
- `createdAt`

### 7.3 `SongWorkDetailResponse`

必须包含：

- `id`
- `title`
- `coverUrl`
- `audioUrl`
- `downloadable`
- `durationMs`
- `lyrics`
- `lyricTimeline`
- `timelineSource`
- `prompt`
- `styleTags`
- `creationParameters`：作品创建参数快照的可复用视图，包含原始风格/场景/对象、纯音乐、人声、语言、时长和所有者可见的参考音频。快照存在时 `musicStyleTags` 不得与作品结果 `styleTags` 合并；历史空快照才从结构化“音乐风格”引导词和结果标签降级。
- `provider`
- `model`
- `costPoints`
- `favorite`
- `albumIds`
- `createdAt`

## 8. 后台 API

后台接口：

- 后台请求携带 `X-App-Code` 表示当前选中 App。
- `/api/admin/apps` 从服务端 schema routing 配置读取全部 appCode，不依赖当前 schema。
- 超级管理员可给角色分配管理块；普通角色只能看到授权模块。

| 模块 | 方法 | 路径 | 说明 |
|------|------|------|------|
| App | GET | `/api/admin/apps` | 获取服务端全部 appCode |
| 权限 | GET | `/api/admin/roles` | 角色列表 |
| 权限 | POST | `/api/admin/roles/{id}/permissions` | 设置管理块 |
| 模型 | GET/POST | `/api/admin/song/models` | 模型价格配置 |
| 模型 | POST | `/api/admin/song/models/{id}/status` | 模型上下架 |
| 案例 | GET/POST | `/api/admin/song/cases` | 热门案例配置 |
| 案例 | POST | `/api/admin/song/cases/{id}/status` | 案例上下架 |
| 情景 | GET/POST | `/api/admin/song/scenarios` | 情景模板配置 |
| 示例 | GET/POST | `/api/admin/song/examples` | 歌曲示例配置 |
| 示例 | POST | `/api/admin/song/examples/{id}/status` | 示例上下架 |
| 灵感 | GET/POST | `/api/admin/song/inspirations` | 灵感文案数组 |
| 任务 | GET | `/api/admin/song/generations` | 生成任务列表 |
| 任务 | GET | `/api/admin/song/generations/{id}` | 任务详情 |
| 作品 | GET | `/api/admin/song/works` | 作品列表 |
| 作品 | POST | `/api/admin/song/works/{id}/hide` | 后台隐藏作品 |
| 专辑 | GET | `/api/admin/song/albums` | 专辑列表 |
| 专辑 | GET | `/api/admin/song/albums/{id}` | 专辑详情 |
| 商品 | GET/POST | `/api/admin/products` | catsinger 会员/积分商品 |

## 9. 生成状态机

| 状态 | progress 建议 | `stageText` | 说明 |
|------|---------------|-------------|------|
| `CREATED` | 0 | 准备创作 | 请求已接收 |
| `POINTS_FROZEN` | 10 | 已冻结积分 | 不重复扣费 |
| `PROMPT_PREPARING` | 20 | 正在理解灵感 | AI 帮写/图片描述/情景合成 |
| `LYRICS_GENERATING` | 35 | 正在编写歌词 | 非纯音乐时 |
| `MUSIC_GENERATING` | 60 | 正在生成旋律 | 调音乐 Provider |
| `RESOURCE_SAVING` | 85 | 正在保存作品 | 解码/下载/上传自有资源 |
| `SUCCEEDED` | 100 | 已完成 | 已创建作品并扣减积分 |
| `FAILED` | 当前进度 | 生成失败 | 待退款或已退款 |
| `REFUNDED` | 当前进度 | 已退回积分 | 积分已回滚 |

规则：

- 重复 `idempotencyKey` 返回已有任务。
- Provider 成功但资源保存失败，任务失败并退款。
- 成功扣减必须发生在自有资源保存成功之后。
- 用户端不展示敏感 Provider 错误；后台可查看 trace 和失败摘要。

## 10. Provider 与资源持久化

`SongGenerationProvider` 输出统一结构：

| 字段 | 说明 |
|------|------|
| `outputType` | `HEX`、`TEMP_URL`、`DIRECT_BINARY` |
| `bytes` | 二进制内容，可空 |
| `temporaryUrl` | 第三方临时 URL，仅任务内短暂使用 |
| `contentType` | 音频类型 |
| `format` | mp3/wav/m4a |
| `durationMs` | 时长 |
| `providerTraceId` | 第三方 trace |

资源保存流程：

1. `HEX` 解码或 `TEMP_URL` 服务端下载。
2. 校验 content-type、大小、最小时长、文件头。
3. 写入 `SongResourceStorageService`。
4. 获得自有 `resourceKey`、`audioUrl`、下载 URL 或 CDN URL。
5. 写入 `catsinger_song_works`。

禁止事项：

- 禁止把 MiniMax 临时 URL 保存成最终 `audio_url`。
- 禁止 App 直接访问第三方生成 URL。
- 禁止将密钥、完整歌词、第三方原始错误堆栈直接写入用户可见响应。

## 11. 歌词时间轴

`LyricTimelineService` 三层来源：

| 来源 | 说明 |
|------|------|
| `PROVIDER` | Provider 返回逐句时间轴时清洗保存 |
| `ESTIMATED` | 按歌词有效行与歌曲时长估算 |
| `MANUAL` | 后台示例歌曲手工录入 |

估算规则：

- 忽略空行和 `[verse]`、`[chorus]` 等结构标签。
- 每行至少 1200ms。
- 总时长按歌曲 `durationMs` 均分并保留开头/结尾缓冲。
- 无时长时返回静态歌词，前端降级展示。

## 12. 错误码

| 错误码 | 场景 |
|--------|------|
| `SONG_MODEL_NOT_FOUND` | 模型不存在 |
| `SONG_MODEL_DISABLED` | 模型已下架 |
| `SONG_ASSET_INVALID` | 上传资源不可用或不属于当前用户 |
| `SONG_GENERATION_IN_PROGRESS` | 用户已有生成中任务且策略不允许并发 |
| `SONG_GENERATION_FAILED` | 生成失败 |
| `POINTS_NOT_ENOUGH` | 积分不足 |
| `PROVIDER_UNAVAILABLE` | 第三方服务不可用 |
| `SONG_RESOURCE_SAVE_FAILED` | 资源保存失败 |
| `SONG_WORK_NOT_FOUND` | 作品不存在或无权访问 |
| `SONG_ALBUM_NOT_FOUND` | 专辑不存在或无权访问 |
| `ADMIN_PERMISSION_DENIED` | 后台角色无管理块权限 |

编码时映射到现有错误码体系，接口响应仍保持统一结构。

## 13. 测试要求

必须补的测试：

- schema routing：catsinger schema 有 common + catsinger 表，没有 narrate 专属表。
- 配置：模型、情景、示例、灵感、案例配置读取。
- 上传：图片、参考音频格式、大小、归属校验。
- AI 帮写：Provider mock 成功和失败。
- 生成：幂等、积分冻结、成功扣减、失败退款。
- MiniMax：歌词和音乐请求映射、异常映射、trace。
- 资源：HEX、TEMP_URL、本地存储、云存储 mock、下载地址。
- 时间轴：PROVIDER、ESTIMATED、MANUAL。
- 作品：列表、详情、下载、分享、收藏、重新生成、隐藏。
- 专辑：创建、详情、添加/移除歌曲。
- Admin：App 切换、权限、模型/案例/示例/任务/作品/专辑管理。
- 回归：旧 narrate 登录、积分、作品和任务中心不受影响。

## 14. 编码前门禁

进入 Java 编码前必须满足：

- 本文档状态为 `active`。
- `java-dev-plan.md` 与 `04-后端/开发计划/*.md` 已同步到 `v1.0-design-mvp`。
- `CURRENT.md` 不再把后端 Java 标记为 `needs-sync`。
- 若要先实现局部模块，必须在对应模块文档中明确本轮边界和不做范围。

## 15. 路径恢复补充实现轨迹

2026-07-31 恢复的商品、首页歌曲编排、AI 提示词、运营账号和音乐工厂 Java 技术增量位于 `recovered-engineering-track-20260731/java-tech.md`。该轨迹使用 CHG-0015～CHG-0040，不取代当前 v1.1 技术基线。
