# 喵喵写歌 Java 总体开发计划

> 文档版本：v1.0-design-mvp
> 当前状态：active
> 最近更新：2026-06-11
> 当前阶段：14 Java 编码已完成
> 关联技术文档：`java-tech.md`
> 关联技术方案：`../02-技术方案/tech-plan.md`
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 技术栈：Java 21 + Spring Boot 3.3.0 + Gradle + MyBatis-Plus + PostgreSQL + Redis

---

## 1. 文档用途

本文档把喵喵写歌后端 v1.0 需求拆成可编码、可恢复、可验证的总体开发计划。后续 Java 编码必须从本文档和 `04-后端/开发计划/*.md` 读取恢复点，不能继续执行 `legacy-20260610` 的旧计划。

## 2. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `14 Java 编码` |
| 当前版本 | `v1.0-design-mvp` |
| 当前任务状态 | `done` |
| 当前恢复点 | `T-B001 至 T-B014 已完成编码与验证，./gradlew test 和 ./gradlew build 均通过` |
| 下一步默认动作 | `回到 Flutter 编码对齐设计稿，或进入 15 联调与测试 QA 做三端联调验收` |

当前后端已有 catsinger 基础接口和表结构，但只是第一批骨架。CHG-0010 后必须继续补齐：热门案例、图片/参考音频上传、AI 帮写、生成进度、真实 Provider、资源自有存储、分享、重新生成、收藏、会员积分商品、后台任务/作品/专辑和权限。

## 3. 状态枚举

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 已有部分骨架或正在同步 |
| `done` | 当前版本完整完成并验证 |
| `blocked` | 被外部配置或方案阻塞 |
| `skipped` | 用户明确跳过 |

## 4. 总体开发策略

后端按 5 条主线推进：

1. **数据和配置先行**：先补齐 catsinger 表、字段、索引、默认配置和 App 切换上下文。
2. **创作输入闭环**：模型、案例、情景、示例、灵感、图片、参考音频、AI 帮写先可提交任务。
3. **生成核心闭环**：幂等、积分、MiniMax、资源持久化、歌词时间轴、进度状态。
4. **作品管理闭环**：作品、专辑、播放、下载、分享、重新生成、收藏、删除/隐藏。
5. **后台运营与回归**：Admin 配置、任务、作品、专辑、会员积分商品、权限、旧 narrate 回归。

编码顺序默认：Migration/Entity/Repository -> Service -> DTO/VO -> Controller -> Test。复杂链路必须先模块文档，再代码。

## 5. 后端阶段划分

| 阶段 | 范围 | 目标 | 关联任务 |
|------|------|------|----------|
| B1 数据与基础配置 | schema、表、字段、默认配置、App/权限基础 | Java 编码不再缺表缺字段 | T-B001, T-B012 |
| B2 配置和创作输入 | 模型、情景、示例、热门案例、灵感、上传、AI 帮写 | App 能把所有创作入口提交成任务参数 | T-B002, T-B003, T-B004 |
| B3 生成与资源 | 任务、积分、MiniMax、资源、时间轴 | 真实或 Mock 生成闭环跑通 | T-B005, T-B006, T-B007, T-B008 |
| B4 作品和专辑 | 作品、下载、分享、收藏、重新生成、专辑 | App 作品页和播放器可联调 | T-B009, T-B010 |
| B5 后台和商品 | Admin Song API、会员积分商品、权限 | 运营可配置，可查任务作品 | T-B011, T-B013 |
| B6 测试回归 | 新接口、Provider mock、旧 narrate 回归 | 可进入联调 QA | T-B014 |

## 6. 详细任务清单

| 任务 ID | 名称 | 当前状态 | 依赖 | 模块文档 | 关键交付 |
|---------|------|----------|------|----------|----------|
| T-B001 | catsinger schema 与迁移补强 | `done` | 无 | `01-schema-and-migration.md` | 补 `cases/assets/share_records/operation_logs`、生成/作品扩展字段及 CHG-0056 作品创作参数快照 |
| T-B002 | 歌曲配置与热门案例接口 | `done` | T-B001 | `02-song-config-and-cases.md` | models/scenarios/examples/inspiration/cases/recent |
| T-B003 | 资源上传接口 | `done` | T-B001 | `03-song-assets.md` | 图片、参考音频、封面、示例素材上传和校验 |
| T-B004 | AI 帮写与图片描述 | `done` | T-B002,T-B003 | `04-lyrics-and-image-prompt.md` | lyrics assist、image prompt provider 抽象 |
| T-B005 | 生成任务核心 | `done` | T-B001,T-B002 | `05-generation-core.md` | 创建任务、幂等、积分冻结、状态机、进度 |
| T-B006 | MiniMax Provider | `done` | T-B005 | `06-minimax-provider.md` | 歌词生成、音乐生成、异常映射、trace |
| T-B007 | 资源持久化与下载 | `done` | T-B006 | `07-resource-storage.md` | HEX/URL、音频校验、本地/云存储、下载地址 |
| T-B008 | 歌词逐句时间轴 | `done` | T-B006,T-B007 | `08-lyric-timeline.md` | PROVIDER/ESTIMATED/MANUAL |
| T-B009 | 作品接口 | `done` | T-B005,T-B007,T-B008 | `09-song-works.md` | 最近作品、列表、详情、生成同款参数、下载、分享、收藏、重新生成、隐藏 |
| T-B010 | 专辑接口 | `done` | T-B009 | `10-song-albums.md` | 创建、列表、详情、添加/移除歌曲 |
| T-B011 | 会员积分商品适配 | `done` | T-B001,T-B012 | `11-member-points-products.md` | catsinger 商品、会员、积分、订单过滤和回归 |
| T-B012 | Admin App 与权限 | `done` | T-B001 | `12-admin-app-permission.md` | App 列表、selectedAppCode、角色管理块权限 |
| T-B013 | Admin Song API | `done` | T-B002,T-B009,T-B010,T-B012 | `13-admin-song-api.md` | 模型、案例、情景、示例、灵感、任务、作品、专辑 |
| T-B014 | 后端测试与回归 | `done` | T-B001-T-B013 | `14-backend-tests.md` | schema、Provider、上传、积分、权限、旧 narrate 回归 |

## 7. API 接口任务表

| 任务 ID | 方法 | 路径 | Service | 状态 |
|---------|------|------|---------|------|
| T-B002 | GET | `/api/song-config/models` | `SongConfigService` | `done` |
| T-B002 | GET | `/api/song-config/scenarios` | `SongConfigService` | `done` |
| T-B002 | GET | `/api/song-config/examples` | `SongConfigService` | `done` |
| T-B002 | GET | `/api/song-config/inspiration` | `SongConfigService` | `done` |
| T-B002 | GET | `/api/song-cases` | `SongCaseService` | `done` |
| T-B002 | GET | `/api/song-cases/{id}` | `SongCaseService` | `done` |
| T-B002 | GET | `/api/song-works/recent` | `SongWorkService` | `done` |
| T-B003 | POST | `/api/song-assets/images` | `SongAssetService` | `done` |
| T-B003 | POST | `/api/song-assets/reference-audios` | `SongAssetService` | `done` |
| T-B004 | POST | `/api/song-lyrics/assist` | `SongLyricAssistService` | `done` |
| T-B005 | POST | `/api/song-generations` | `SongGenerationService` | `done` |
| T-B005 | GET | `/api/song-generations/{id}` | `SongGenerationService` | `done` |
| T-B009 | GET | `/api/song-works` | `SongWorkService` | `done` |
| T-B009 | GET | `/api/song-works/{id}` | `SongWorkService` | `done` |
| T-B009 | POST | `/api/song-works/{id}/download-url` | `SongWorkService` | `done` |
| T-B009 | POST | `/api/song-works/{id}/share` | `SongShareService` | `done` |
| T-B009 | POST | `/api/song-works/{id}/regenerate` | `SongGenerationService` | `done` |
| T-B009 | POST | `/api/song-works/{id}/cover-regeneration-tasks` | `SongCoverRegenerationTaskService` | `done` |
| T-B009 | GET | `/api/song-works/{id}/cover-regeneration-tasks/latest` | `SongCoverRegenerationTaskService` | `done` |
| T-B009 | GET | `/api/song-works/cover-regeneration-tasks/{taskId}` | `SongCoverRegenerationTaskService` | `done` |
| T-B009 | POST | `/api/song-works/{id}/favorite` | `SongWorkService` | `done` |
| T-B009 | POST | `/api/song-works/disable` | `SongWorkService` | `done` |
| T-B010 | GET | `/api/song-albums` | `SongAlbumService` | `done` |
| T-B010 | POST | `/api/song-albums` | `SongAlbumService` | `done` |
| T-B010 | GET | `/api/song-albums/{id}` | `SongAlbumService` | `done` |
| T-B010 | POST | `/api/song-albums/{id}/songs` | `SongAlbumService` | `done` |
| T-B010 | DELETE | `/api/song-albums/{id}/songs/{songId}` | `SongAlbumService` | `done` |
| T-B012 | GET | `/api/admin/apps` | `AdminAppService` | `done` |
| T-B012 | GET | `/api/admin/roles` | `AdminRolePermissionService` | `done` |
| T-B012 | POST | `/api/admin/roles/{id}/permissions` | `AdminRolePermissionService` | `done` |
| T-B013 | GET/POST | `/api/admin/song/models` | `AdminSongConfigService` | `done` |
| T-B013 | GET/POST | `/api/admin/song/cases` | `AdminSongConfigService` | `done` |
| T-B013 | GET/POST | `/api/admin/song/scenarios` | `AdminSongConfigService` | `done` |
| T-B013 | GET/POST | `/api/admin/song/examples` | `AdminSongConfigService` | `done` |
| T-B013 | GET/POST | `/api/admin/song/inspirations` | `AdminSongConfigService` | `done` |
| T-B013 | GET | `/api/admin/song/generations` | `AdminSongConfigService` | `done` |
| T-B013 | GET | `/api/admin/song/works` | `AdminSongConfigService` | `done` |
| T-B013 | GET | `/api/admin/song/albums` | `AdminSongConfigService` | `done` |
| T-B011 | GET/POST | `/api/admin/products` | `AdminProductService` | `done` |

## 8. 模块开发文档列表

| 顺序 | 模块 | 文档 | 状态 |
|------|------|------|------|
| 1 | Schema 与迁移 | `04-后端/开发计划/01-schema-and-migration.md` | `done` |
| 2 | 配置与案例 | `04-后端/开发计划/02-song-config-and-cases.md` | `done` |
| 3 | 资源上传 | `04-后端/开发计划/03-song-assets.md` | `done` |
| 4 | AI 帮写与图片描述 | `04-后端/开发计划/04-lyrics-and-image-prompt.md` | `done` |
| 5 | 生成核心 | `04-后端/开发计划/05-generation-core.md` | `done` |
| 6 | MiniMax Provider | `04-后端/开发计划/06-minimax-provider.md` | `done` |
| 7 | 资源持久化 | `04-后端/开发计划/07-resource-storage.md` | `done` |
| 8 | 歌词时间轴 | `04-后端/开发计划/08-lyric-timeline.md` | `done` |
| 9 | 作品接口 | `04-后端/开发计划/09-song-works.md` | `done` |
| 10 | 专辑接口 | `04-后端/开发计划/10-song-albums.md` | `done` |
| 11 | 会员积分商品 | `04-后端/开发计划/11-member-points-products.md` | `done` |
| 12 | Admin App 与权限 | `04-后端/开发计划/12-admin-app-permission.md` | `done` |
| 13 | Admin Song API | `04-后端/开发计划/13-admin-song-api.md` | `done` |
| 14 | 后端测试回归 | `04-后端/开发计划/14-backend-tests.md` | `done` |

## 9. 编码约束

- 不新建独立服务。
- 不把业务逻辑写进 Controller。
- 不保存第三方临时 URL 为最终播放地址。
- 不在日志输出密钥、Token、完整歌词、临时 URL。
- 所有用户资源必须校验 `userId` 归属。
- 后台所有操作必须有 selected appCode 和权限校验。
- 生成任务、积分、资源、作品写入必须在事务和补偿规则内闭环。
- 真实 MiniMax 配置缺失时，先用 Mock Provider 保持接口可测。
- 模块文档与本文档冲突时，以 `java-tech.md` 为准，先修文档再编码。

## 10. 测试策略

| 测试 | 最低要求 |
|------|----------|
| SchemaRoutingIntegrationTests | catsinger/narrate/catcomic 专属表隔离 |
| SongConfigInspirationIntegrationTests | 保留并扩展配置兜底 |
| SongAssetControllerTest | 上传类型、大小、归属、失败 |
| SongGenerationServiceTest | 幂等、积分冻结、扣减、退款、状态机 |
| MiniMaxProviderMockTest | 请求映射、错误映射、trace |
| SongResourceStorageServiceTest | HEX、临时 URL、本地/云存储 mock |
| LyricTimelineServiceTest | PROVIDER、ESTIMATED、MANUAL |
| SongWorkControllerTest | 列表、详情、下载、分享、收藏、隐藏 |
| SongAlbumControllerTest | 创建、详情、添加/移除 |
| AdminSongApiTest | App 切换、权限、配置、任务、作品、专辑 |
| NarrateRegressionTest | 旧 narrate 登录、积分、作品、任务中心 |

## 11. 恢复点

Java 编码已完成并通过全量测试。下一步可回到 Flutter 编码完成设计稿对齐，或进入 15 联调与测试 QA 做三端联调验收。

## 12. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-06-11 | 按 `v1.0-design-mvp` 同步 Java 总体开发计划 | active，继续第 12 步 |
| 2026-06-11 | 完成 T-B001 至 T-B014 Java 编码与回归 | `./gradlew test` 通过，138 项测试通过；`./gradlew build` 通过 |
| 2026-08-04 | CHG-0056 作品创作参数快照与详情扩展 | 新增 `creation_params_json` 迁移和存量任务回填；新作品落快照、原地重生成保留非空快照；详情按所有者隔离参考音频。快照存在时风格只返回原始请求参数，不合并作品 Provider 结果标签；历史空快照仅从结构化引导词和详情标签降级 |
| 2026-08-05 | CHG-0061 用户封面异步任务接口 | 复用既有封面任务表和调度器，新增用户创建、最近任务和指定任务查询；按作品活动槽幂等并校验用户归属，用户任务执行继续复用 `SongWorkService` 的积分冻结、成功确认和失败退款，后台任务行为保持不变；无需数据库迁移，7 项用户任务/后台任务/同步计费定向回归通过 |

## 13. 路径恢复补充实现轨迹

2026-07-31 恢复的后续 Java 开发计划位于 `recovered-engineering-track-20260731/java-dev-plan.md`，独有模块计划已迁入 `开发计划/`。当前未完成项只进入 workflow 的并行 QA 队列，不改变本文现有完成状态。
