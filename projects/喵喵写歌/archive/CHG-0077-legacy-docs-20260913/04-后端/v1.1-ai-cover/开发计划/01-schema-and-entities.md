# 01 翻唱数据结构与实体模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-01
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块负责 AI 翻唱需要的数据库迁移、实体字段和枚举。按当前数据规则，翻唱属于 catsinger 专属业务，只能进入 catsinger schema。

## 2. 表结构策略

优先扩展已有歌曲作品、任务、配置表；只有现有表无法表达时才新增表。

建议对象：

| 对象 | 归属 | 说明 |
| --- | --- | --- |
| `catsinger_song_works` 扩展 | catsinger | 增加 `song_type/source_work_id/source_audio_asset_id/cover_voice_id` |
| `catsinger_song_generation_tasks` 扩展 | catsinger | 支持 `mode=cover` 和翻唱进度字段 |
| `catsinger_song_assets` 扩展 | catsinger | 标记 `asset_usage=COVER_SOURCE/ORIGINAL_AUDIO/COVER_AUDIO` |
| `catsinger_cover_voices` | catsinger | 音色配置，如已有配置表可合并 |
| `catsinger_cover_settings` 可选 | catsinger | 保存翻唱参数快照 |

## 3. 枚举

| 枚举 | 值 |
| --- | --- |
| `SongType` | `ORIGINAL/COVER/INSTRUMENTAL` |
| `GenerationMode` | 追加 `COVER` |
| `AssetUsage` | 追加 `COVER_SOURCE/ORIGINAL_AUDIO/COVER_AUDIO` |
| `CoverVoiceGroup` | `MALE/FEMALE/ANIME/SPECIAL` |

## 4. 实体要求

- 翻唱作品必须能追溯来源作品或来源音频。
- 翻唱设置需要快照，避免运营改音色配置后历史作品展示变化。
- 资源 URL 存持久化地址，不存 Provider 临时 URL。
- 表内 `app_code` 保留审计字段，但隔离依赖 schema routing。

## 5. 实现步骤

1. 新增 catsinger 专属迁移，例如 `db/migration/catsinger/V14__catsinger_cover.sql`。
2. 扩展实体和枚举。
3. 补 Repository 查询方法。
4. 补 DTO 映射。
5. 检查 narrate schema 不会执行本迁移。

## 6. 验收标准

- 干净库启动后 catsinger 有翻唱表/字段，narrate 没有 catsinger 翻唱表。
- 老作品不受 `song_type` 新字段影响，默认按 `ORIGINAL` 处理。
- 实体字段能完整表达翻唱来源、音色、参数和资源。
