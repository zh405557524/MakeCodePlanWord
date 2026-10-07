# 数据模型

> 基线文档：线上数据库结构（服务端）和 App 本地存储。
> 2026-10-07 迁移时从 service 仓库迁移脚本自动提取。只列字段名和类型；约束、索引、注释以迁移脚本为准。以后改表时，在版本 `plan.md` 第 3 节写清变更，发布时更新这里。

## 1. 服务端数据库

- 多 App 共用一个 PostgreSQL，按 App Code 分 schema：钢琴视奏为 `solfeggio`。
- 迁移脚本：`service/src/main/resources/db/migration/common/`（每个 App schema 都执行）和 `.../migration/solfeggio/`（只在 solfeggio schema 执行）。
- **已发布的迁移冻结，禁止修改或重命名**；冻结边界见 service 仓库 `docs/production-flyway-baseline.md`。
- solfeggio 专属迁移：V2.1、V2.3、V2.4、V3.1、V3.2、V3.3、V4.0；公共迁移最新为 `common/V5.0__verified_store_order_amount.sql`（2026-10-06 上线）。

### 1.1 公共表（common，与钢琴视奏相关的部分）

#### payment_orders（支付订单）

| 字段 | 类型 | 说明 |
|---|---|---|
| order_no | VARCHAR(64) 主键 | 订单号，包含可解析的 App 编码 |
| app_code | VARCHAR(32) | 业务应用编码 |
| user_id | BIGINT | |
| product_id / product_code | VARCHAR | 会员商品：`com.soul.solfeggio.vip.{monthly,quarterly,yearly}.v1` |
| product_type / card_type / product_name | | |
| amount_cents / currency | BIGINT / VARCHAR(16) | **内部定价快照**（例如 1800 / CNY），用于后台财务口径 |
| store_amount_cents / store_currency / store_transaction_id | BIGINT / VARCHAR(3) / VARCHAR(128) | **商店核验的实际交易金额**（V5.0 新增，三者同时为空或同时存在）；接口返回给 App 的金额以它为准 |
| channel / status / provider_order_no / pay_params | | 渠道（例如 GOOGLE_PLAY）、状态、渠道订单号、加密支付参数 |
| paid_at / expires_at / deleted_at / created_at / updated_at | TIMESTAMP | |

其他公共表（商品、支付事件、会员权益、积分流水、用户、身份、资源等）见 `common/V2.0__common_schema.sql`。

### 1.2 solfeggio 专属表

#### solfeggio_songs
- 用途：官方曲目：标题、作者、等级、所需等级、版权、上下架、排序
- 创建：`V2.1__solfeggio_core.sql`
- 注意：`required_chord_stage`、`access_tier` 只保留给旧配置和接口适配，**歌曲权限不再使用它们**；免费体验曲目由固定配置 `song-access-policy.json` 决定（见第 1.3 节）。

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| song_key | VARCHAR(64) |
| title | VARCHAR(128) |
| composer | VARCHAR(128) |
| difficulty | VARCHAR(32) |
| level | INT |
| required_level | INT |
| cover_url | TEXT |
| copyright_status | VARCHAR(32) |
| copyright_source | VARCHAR(255) |
| online_status | VARCHAR(32) |
| sort_order | INT |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |
| required_chord_stage | INTEGER (+V3.2__solfeggio_local_first_practice.sql) |
| access_tier | VARCHAR(16) (+V3.2__solfeggio_local_first_practice.sql) |

#### solfeggio_song_arrangements
- 用途：曲目编配与谱面 JSON（手机 / 钢琴模式可用性）
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| song_id | BIGINT |
| arrangement_key | VARCHAR(96) |
| title | VARCHAR(128) |
| mode | VARCHAR(32) |
| staff_type | VARCHAR(32) |
| key_signature | VARCHAR(32) |
| time_signature | VARCHAR(32) |
| bpm | INT |
| phone_mode_available | BOOLEAN |
| piano_mode_available | BOOLEAN |
| score_json | TEXT |
| status | VARCHAR(32) |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_song_segments
- 用途：编配的练习片段（小节范围）
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| arrangement_id | BIGINT |
| title | VARCHAR(128) |
| measure_start | INT |
| measure_end | INT |
| practice_focus | VARCHAR(128) |
| sort_order | INT |
| created_at | TIMESTAMP |

#### solfeggio_song_unlocks
- 用途：用户曲目解锁记录
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| song_id | BIGINT |
| unlock_source | VARCHAR(64) |
| unlocked_at | TIMESTAMP |

#### solfeggio_song_practice_sessions
- 用途：歌曲练习会话（phone / piano）
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| song_id | BIGINT |
| arrangement_id | BIGINT |
| mode | VARCHAR(32) |
| status | VARCHAR(32) |
| resume_index | INT |
| progress_json | TEXT |
| duration_seconds | INT |
| started_at | TIMESTAMP |
| completed_at | TIMESTAMP |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_song_practice_results
- 用途：歌曲练习结果
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| session_id | BIGINT |
| song_id | BIGINT |
| arrangement_id | BIGINT |
| mode | VARCHAR(32) |
| accuracy | NUMERIC(6,3) |
| completion | NUMERIC(6,3) |
| score | INT |
| wrong_bars_json | TEXT |
| duration_seconds | INT |
| result_json | TEXT |
| completed_at | TIMESTAMP |
| created_at | TIMESTAMP |

#### solfeggio_chord_practice_sessions
- 用途：和弦练习会话
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| level | INT |
| total_questions | INT |
| questions_json | TEXT |
| status | VARCHAR(32) |
| current_index | INT |
| correct_count | INT |
| started_at | TIMESTAMP |
| completed_at | TIMESTAMP |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_chord_practice_answers
- 用途：和弦答题记录
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| session_id | BIGINT |
| user_id | BIGINT |
| question_id | VARCHAR(64) |
| pressed_notes_json | TEXT |
| missing_notes_json | TEXT |
| extra_notes_json | TEXT |
| wrong_notes_json | TEXT |
| is_correct | BOOLEAN |
| duration_ms | INT |
| answered_at | TIMESTAMP |
| created_at | TIMESTAMP |

#### solfeggio_practice_records
- 用途：客户端同步上来的练习记录（按 client_record_id 去重）
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| client_record_id | VARCHAR(96) |
| practice_type | VARCHAR(32) |
| payload_json | TEXT |
| occurred_at | TIMESTAMP |
| created_at | TIMESTAMP |

#### solfeggio_learning_snapshots
- 用途：学习概览快照：累计/本周练习、连续天数、等级、和弦阶段、成就
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| total_practice_count | BIGINT |
| total_practice_seconds | BIGINT |
| accuracy | NUMERIC(6,3) |
| weekly_practice_count | BIGINT |
| weekly_practice_seconds | BIGINT |
| weekly_accuracy | NUMERIC(6,3) |
| streak_days | INT |
| daily_scores_json | TEXT |
| achievement_json | TEXT |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |
| skill_level | INTEGER (+V3.2__solfeggio_local_first_practice.sql) |
| chord_stage | INTEGER (+V3.2__solfeggio_local_first_practice.sql) |

#### solfeggio_user_preferences
- 用途：云端练习偏好
- 创建：`V2.1__solfeggio_core.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| preferences_json | TEXT |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_iap_confirmation_tasks
- 用途：Apple 内购持久化补单任务（加密凭证、重试、租约）
- 创建：`V2.3__solfeggio_iap_confirmation_tasks.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| app_code | VARCHAR(40) |
| user_id | BIGINT |
| order_no | VARCHAR(100) |
| transaction_id | VARCHAR(128) |
| proof_digest | VARCHAR(64) |
| encrypted_proof | TEXT |
| key_version | VARCHAR(40) |
| status | VARCHAR(24) |
| attempt_count | INTEGER |
| next_retry_at | TIMESTAMP |
| lease_until | TIMESTAMP |
| version | BIGINT |
| error_code | VARCHAR(100) |
| failure_stage | VARCHAR(80) |
| trace_id | VARCHAR(100) |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_score_imports
- 用途：曲谱导入任务（状态、进度、识别结果、原文件删除时间）
- 创建：`V2.4__solfeggio_score_import.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| user_id | BIGINT |
| idempotency_key | VARCHAR(96) |
| source_type | VARCHAR(16) |
| status | VARCHAR(32) |
| progress_percent | INTEGER |
| current_step | VARCHAR(32) |
| original_resource_ids_json | TEXT |
| original_resource_keys_json | TEXT |
| original_filenames_json | TEXT |
| file_digest | VARCHAR(64) |
| options_json | TEXT |
| provider | VARCHAR(32) |
| provider_task_id | VARCHAR(128) |
| score_json | TEXT |
| issues_json | TEXT |
| error_code | VARCHAR(96) |
| error_message | VARCHAR(255) |
| retry_count | INTEGER |
| next_retry_at | TIMESTAMP |
| lease_until | TIMESTAMP |
| version | BIGINT |
| cancellable | BOOLEAN |
| confirmed_score_id | BIGINT |
| raw_files_delete_after | TIMESTAMP |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |
| completed_at | TIMESTAMP |
| cancelled_at | TIMESTAMP |
| worker_id | VARCHAR(96) (+V3.1__solfeggio_v3.sql) |
| claim_token_hash | VARCHAR(64) (+V3.1__solfeggio_v3.sql) |
| result_digest | VARCHAR(64) (+V3.1__solfeggio_v3.sql) |
| current_score_version_id | BIGINT (+V3.1__solfeggio_v3.sql) |

#### solfeggio_personal_scores
- 用途：个人曲谱（导入确认后的曲谱）
- 创建：`V2.4__solfeggio_score_import.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| user_id | BIGINT |
| import_id | BIGINT |
| title | VARCHAR(160) |
| composer | VARCHAR(160) |
| source_type | VARCHAR(16) |
| bpm | INTEGER |
| key_signature | VARCHAR(24) |
| time_signature | VARCHAR(24) |
| measure_count | INTEGER |
| duration_seconds | INTEGER |
| difficulty_level | INTEGER |
| score_json | TEXT |
| review_version | BIGINT |
| practice_progress | INTEGER |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |
| deleted_at | TIMESTAMP |
| current_score_version_id | BIGINT (+V3.1__solfeggio_v3.sql) |

#### solfeggio_score_versions
- 用途：个人曲谱版本（内联或对象存储）
- 创建：`V3.1__solfeggio_v3.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| owner_user_id | BIGINT |
| import_id | BIGINT |
| personal_score_id | BIGINT |
| version_number | BIGINT |
| storage_location | VARCHAR(16) |
| inline_score_json | TEXT |
| resource_id | BIGINT |
| size_bytes | BIGINT |
| sha256 | VARCHAR(64) |
| status | VARCHAR(16) |
| created_by | VARCHAR(16) |
| created_at | TIMESTAMP |
| superseded_at | TIMESTAMP |
| deleted_at | TIMESTAMP |

#### solfeggio_account_deletion_requests
- 用途：账号注销申请（冷静期、执行、重试）
- 创建：`V3.1__solfeggio_v3.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| user_id | BIGINT |
| status | VARCHAR(24) |
| active_slot | SMALLINT |
| source | VARCHAR(16) |
| requested_at | TIMESTAMP |
| erase_after | TIMESTAMP |
| cancelled_at | TIMESTAMP |
| cancel_reason | VARCHAR(500) |
| completed_at | TIMESTAMP |
| retry_count | INTEGER |
| next_retry_at | TIMESTAMP |
| lease_until | TIMESTAMP |
| last_error_code | VARCHAR(100) |
| version | BIGINT |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_piano_soundfonts
- 用途：钢琴音色包上传与发布
- 创建：`V3.1__solfeggio_v3.sql`

| 字段 | 类型 |
|---|---|
| id | BIGINT 自增 |
| resource_id | BIGINT |
| status | VARCHAR(24) |
| published_slot | SMALLINT |
| original_filename | VARCHAR(255) |
| content_type | VARCHAR(128) |
| expected_size_bytes | BIGINT |
| content_sha256 | CHAR(64) |
| staging_object_key | VARCHAR(1024) |
| upload_expires_at | TIMESTAMP |
| failure_reason | VARCHAR(500) |
| created_by_admin_id | BIGINT |
| verified_at | TIMESTAMP |
| published_at | TIMESTAMP |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_account_bindings
- 用途：账号绑定（provider、会话纪元）
- 创建：`V3.3__solfeggio_account_binding.sql`

| 字段 | 类型 |
|---|---|
| user_id | BIGINT 主键 |
| provider | VARCHAR(16) |
| session_epoch | VARCHAR(64) |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

#### solfeggio_auth_operations
- 用途：认证操作回执（幂等重放）
- 创建：`V3.3__solfeggio_account_binding.sql`

| 字段 | 类型 |
|---|---|
| idempotency_key | VARCHAR(128) 主键 |
| local_profile_id | VARCHAR(128) |
| action | VARCHAR(32) |
| credential_fingerprint | VARCHAR(64) |
| user_id | BIGINT |
| provider | VARCHAR(16) |
| transition | VARCHAR(32) |
| created_at | TIMESTAMP |

#### solfeggio_auth_mutex
- 用途：认证事务互斥行
- 创建：`V3.3__solfeggio_account_binding.sql`

| 字段 | 类型 |
|---|---|
| id | INT 主键 |

#### solfeggio_review_prompt_states
- 用途：评价邀请状态（次数、冷却、抑制原因）
- 创建：`V3.3__solfeggio_account_binding.sql`

| 字段 | 类型 |
|---|---|
| user_id | BIGINT 主键 |
| attempt_count | INTEGER |
| last_attempt_at | TIMESTAMP |
| baseline_practice_count | INTEGER |
| suppression_reason | VARCHAR(16) |
| updated_at | TIMESTAMP |

#### solfeggio_review_prompt_events
- 用途：评价邀请事件
- 创建：`V3.3__solfeggio_account_binding.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| event_key | VARCHAR(140) |
| record_id | VARCHAR(160) |
| event_type | VARCHAR(8) |
| attempted_at | TIMESTAMP |
| created_at | TIMESTAMP |

#### solfeggio_score_import_rate_events
- 用途：导入频率计数事件（带时区偏移，用于自然日统计）
- 创建：`V4.0__solfeggio_score_import_rate_events.sql`

| 字段 | 类型 |
|---|---|
| id | BIGSERIAL 主键 |
| user_id | BIGINT |
| task_id | BIGINT |
| action | VARCHAR(12) |
| counted | BOOLEAN |
| zone_offset_minutes | SMALLINT |
| created_at | TIMESTAMP |

### 1.3 固定配置文件（随后端发布）

目录：`service/src/main/resources/service-data/apps/solfeggio/`

| 文件 | 内容 |
|---|---|
| `products.json` | 会员商品（月 / 季 / 年卡），`id` = `productCode` = 商店商品 ID |
| `app-configs.json` | 导入资源保护（并发 2、每小时 10、每自然日 30）、导入原文件保留 7 天、Apple 沙盒开关 |
| `song-access-policy.json` | 官方曲目固定权限：免费体验曲目 key 与别名。App 内有同源副本，修改后用同步脚本 `--check` 校验一致 |

## 2. App 本地存储

| 存储 | 内容 | 隔离方式 |
|---|---|---|
| GetStorage 账号注册表 | 当前本地账号、云端身份映射、退出模式、会话、认证操作键 | 设备级 |
| GetStorage / Hive（按本地账号分区） | 练习记录、等级、上传队列、缓存、收藏、头像昵称、偏好、练习断点 | 按本地账号隔离；切换账号不串数据 |
| flutter_secure_storage | 游客恢复凭证、待撤销会话任务 | 设备级、平台安全存储 |
| 设备级配置 | 隐私同意、系统权限、服务器地址 | 设备级 |
| 内置曲库资源 | `assets/` 下的官方曲目谱面、音频、音色包 | 随包发布 |

⚠️ 上表由账号绑定契约整理，存储键名和 Hive box 名以 App 代码（`lib/store/`、`lib/services/core/`）为准，下次改动本地存储时补全。
