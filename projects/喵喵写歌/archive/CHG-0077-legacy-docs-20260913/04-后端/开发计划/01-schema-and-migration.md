# 01 Schema 与迁移模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B001
> 状态：done

## 功能定位

补齐 catsinger schema 的 v1 真功能表和字段。公共表继续放 `db/migration/common`，喵喵写歌专属表只放 `db/migration/catsinger`。

## 涉及文件

| 类型 | 文件 |
|------|------|
| 迁移 | `src/main/resources/db/migration/catsinger/V15__catsinger_song_v1_mvp.sql` |
| 实体 | `app/catsinger/song/entity/*Entity.java` |
| Repository | `app/catsinger/song/repository/*Repository.java` |
| 测试 | `SchemaRoutingIntegrationTests` |

## 数据表与迁移

新增表：

- `catsinger_song_cases`
- `catsinger_song_assets`
- `catsinger_song_share_records`
- `catsinger_song_operation_logs`

扩展表：

- `catsinger_song_generation_tasks`：`progress_percent`、`stage_text`、`estimated_remaining_seconds`、`image_asset_id`、`reference_audio_asset_id`、`ai_lyrics_meta_json`。
- `catsinger_song_works`：`timeline_source`、`storage_provider`、`storage_bucket`、`storage_region`、`resource_key`、`storage_meta_json`、`provider_output_type`、`favorite`。
- `catsinger_song_albums`：`description`、`cover_url`、`hidden`。

## 索引

- `catsinger_song_cases(enabled, sort_order, id)`
- `catsinger_song_assets(user_id, asset_type, created_at desc)`
- `catsinger_song_share_records(work_id, created_at desc)`
- `catsinger_song_operation_logs(target_type, target_id, created_at desc)`

## 实现步骤

1. 新增 V15 迁移。
2. 补 Entity 字段和 Repository。
3. 确认 Flyway `common + catsinger` 执行后只 catsinger schema 有歌曲表。
4. 更新 `SchemaRoutingIntegrationTests`。

## 测试要求

- catsinger schema 有 common 表和 `catsinger_song_*`。
- narrate schema 没有 `catsinger_song_*`。
- catcomic schema 没有 `catsinger_song_*`。
- V15 字段存在且索引存在。

## 验收标准

干净库启动后，`catsinger` 可完整创建 v1 歌曲业务表，旧 app schema 不多建喵喵写歌表。

## CHG-0056 作品创作参数快照

- 新增 Flyway `V3.4__catsinger_song_work_creation_params.sql`，为 `catsinger_song_works` 增加 `creation_params_json TEXT NOT NULL DEFAULT '{}'` 并添加字段注释，不新增索引。
- 迁移从作品当前关联任务的 `normalized_request_json` 回填非空快照；任务已清理或无法追溯的历史作品保持 `{}`，由客户端使用详情现有字段降级。
- 新作品占位创建时写入规范化请求快照；原地重新生成成功时保留已有非空快照，只在历史空快照时以当前任务补齐。
- 该迁移仅进入 catsinger schema，不修改用户、积分、订单和其他 App schema。
- CHG-0056 风格对齐修正复用该 JSON 快照列，不新增参数表、索引或其他字段；Provider 结果标签仍留在作品结果字段，不写回或合并进原始创作参数语义。

测试需覆盖字段默认值、可追溯任务回填、任务清理后作品快照保留、历史空快照降级和其他 schema 隔离。
