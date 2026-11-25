# 02 Schema、Entity 与 Repository

> 任务族：`T-B002`
> 骨架任务：`T-B002-S`
> 真实任务：`T-B002-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 数据范围：catsinger 专属 + common 审核最小扩展

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B002-S`
- 本阶段交付：只定义后续持久化端口、领域 ID 和 Service 调用边界，使上层代码可编译；数据库改动明确为无，不创建 Flyway、Entity、Mapper 或 Repository 实现。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B002-R`
- 本阶段交付：按本文件设计新增 7 张专属表、必要字段、Entity、Repository、索引、注释和迁移验证。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

为用户音色、训练和多渠道绑定保存不可替代的领域事实，并在现有生成任务、作品和公共审核表上增加最小关联字段。不新增第二套资源、积分、模型、歌曲任务或作品表。

## 2. 迁移文件

编码前先读取真实最大版本，再新增：

- `db/migration/catsinger/V{next}__catsinger_voice_clone_cover.sql`
- `db/migration/common/V{next}__content_moderation_manual_review.sql`

禁止修改历史迁移。narrate 等非 catsinger schema 不创建 7 张音色专属表。

## 3. 新表

| 表 | 核心字段与索引 |
|----|----------------|
| `catsinger_song_voice_profiles` | owner_type/owner_user_id、current profile/model version、status、publish_status、sort_order、deleted_at；用户/官方列表索引 |
| `catsinger_song_voice_profile_versions` | voice_profile_id、version_no、display_name、description、avatar_resource_id、moderation reference、revision；profile+version 唯一 |
| `catsinger_song_voice_materials` | profile_version_id、asset_id、source_type、clip range、duration/size、quality/status、sort、lock/retention；asset 关系唯一 |
| `catsinger_song_voice_model_versions` | profile_id、training_task_id、version_no、status、audition_resource_id、unavailable_reason；历史版本不可覆盖 |
| `catsinger_song_voice_provider_bindings` | model_version_id、provider_code、model_code、provider_model_id、模型/配置资源引用、status/expiry/error；版本+provider+model 唯一 |
| `catsinger_song_voice_training_tasks` | user/profile/version、route/price/idempotency、status/stage/progress、provider task、error、output model version；user+idempotency 唯一 |
| `catsinger_song_voice_consent_records` | user、business_type/business_id、consent_version、各授权布尔值、不可变快照、created_at；business 唯一关联 |

字段类型、主键、审计列、软删除和命名必须遵循当前工程现有 Entity/Base 约定。Entity 持久化字段逐字段写清晰注释。

## 4. 现有表扩展

`catsinger_song_generation_tasks` 增加：voice_profile_version_id、voice_model_version_id、voice_provider_binding_id、consent_record_id、provider_accepted_at、deadline_at。

`catsinger_song_works` 增加：voice_profile_version_id、voice_model_version_id。

`content_moderation_records` 增加：manual_result、manual_reviewer_id、manual_reason、manual_reviewed_at、revision。

不在 `catsinger_song_assets` 重复保存音色关系或审核结论。

## 5. Repository

每张新表一个 Repository，使用现有 JPA/查询风格。必须提供：owner/状态分页、当前版本、幂等任务、有效渠道绑定、活动训练、发布官方音色和条件唯一查询。自定义 SQL 需行为测试。

## 6. 数据完整性

- profile version 只追加，不原地覆盖历史展示资料。
- model version 只由成功训练产生；失败重训新建版本。
- 运行中任务引用的素材、模型版本、授权不可删除。
- 外键策略不级联删除通用 resource/work/ledger。
- 状态、时间和软删除条件进入常用索引。

## 7. 实现步骤

1. 盘点当前最大 Flyway 版本、ID/时间/JSON 类型和 schema location。
2. 编写 catsinger/common 迁移及约束、索引和数据库注释。
3. 新增 Entity 并逐字段注释。
4. 新增 Repository 和必要投影/锁查询。
5. 增加 schema routing、迁移和 Repository 行为测试。

## 8. 测试要求

- 干净 narrate：只有 common 扩展，无 voice 表。
- 干净 catsinger：common + 7 张 voice 表和现有表字段齐全。
- 重启迁移幂等，历史数据保留。
- 唯一键、软删除、版本追加、活动状态和跨用户查询正确。
- appCode 路由后数据不串 schema。

## 9. 验收标准

- 每个表/字段都对应技术文档中的声音克隆独有事实。
- 未新增重复任务、作品、资源、积分、模型或审核真源。
- Entity 注释、索引、约束与 Repository 查询一致。
- 迁移可在开发空库执行，正式迁移策略另在部署模块验证。

## 10. 编码注意事项

当前 Java 工作区可能有其他任务的未提交改动，编码时不得覆盖。迁移版本不能沿用文档占位 `V4.8/V4.9`，必须重新扫描后确定。
