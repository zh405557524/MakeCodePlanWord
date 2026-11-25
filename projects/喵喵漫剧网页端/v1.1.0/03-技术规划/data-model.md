# 数据模型

> v1.1.0 做完后的**完整**数据结构（服务端数据库 + 网页端本地存储）。改过的小节下面加 `> 本版改动：R-xx`。
>
> 网页端与手机端共用后端 App `catdrama` 的同一个 schema；本版只改 `catdrama_assets`（加两列，见“漫剧素材：主图 + 形象”，R-01），其他漫剧业务表不改；现有表结构的唯一出处是后端迁移脚本（`src/main/resources/db/migration/common/`、`…/catdrama/`），这里只写本版新增的部分和网页端自己的存储。

## 1. 服务端数据库

### `user_password_credentials`（新）

- 用途：保存用户的登录密码（只存 BCrypt 加密结果，不存明文、不可还原）。一个用户最多一条。
- 归属：每个 App 的 schema 各有一张（迁移放在 `common` 目录）；按 `user_id` 归属，`app_code` 冗余记录所属 App。只有 `core/auth` 模块读写。

| 字段 | 类型 | 可空 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | `BIGSERIAL` | 否 | 自增 | 主键 |
| `user_id` | `BIGINT` | 否 | — | 用户 ID，外键 `users(id)` |
| `app_code` | `VARCHAR(32)` | 否 | — | 所属 App 编码，如 `catdrama` |
| `password_hash` | `VARCHAR(100)` | 否 | — | BCrypt 结果（60 字符，含盐） |
| `password_updated_at` | `TIMESTAMP` | 否 | — | 最近一次设置 / 重置密码的时间（北京时间） |
| `created_at` | `TIMESTAMP` | 否 | `CURRENT_TIMESTAMP` | 创建时间 |
| `updated_at` | `TIMESTAMP` | 否 | `CURRENT_TIMESTAMP` | 最近更新时间 |

索引：`UNIQUE (user_id)`（`uk_user_password_credentials_user`）。

存量与回退：上线时表为空，所有老用户视为“未设密码”。回退代码时保留此表，旧代码不读它。用户注销后重新用同一手机号注册会得到新的用户 ID，旧记录随旧账号保留、不会被新账号使用。

### 相关的现有表（不改，列出便于理解）

| 表 | 本版怎么用 |
|---|---|
| `users` | 按 `(app_code, phone)` 唯一找账号；新建账号仍由 `UserService.findOrCreateByPhone` 完成 |
| `sms_codes` | 注册、重置密码复用现有验证码（同一个“发送验证码”接口，验证一次即作废） |
| `refresh_tokens` | 密码登录、注册、重置成功后照常签发刷新凭证 |
| `payment_orders` | 电脑端支付宝订单与手机端同表，`channel = alipay_web` |

### 漫剧分析与片段（2026-11-16 调整）

| 表 | 变化 | 说明 |
|---|---|---|
| `catdrama_episodes` | **加字段** `asset_plan JSONB NULL`：分集时定好的本集素材清单 `{roles:[],scenes:[],props:[]}`（K-08）；阶段约束 `ck_catdrama_episode_stage` 加 `SHOTS` | 老作品为空；迁移见下方“漫剧迁移” |
| `catdrama_episode_assets` | 无结构变化；写入时机变化 | 由素材分析（K-01）按每集 `asset_plan`（并按最新正文补漏）建立，不再由拆片段结果建立 |
| `catdrama_analysis_runs` | 无结构变化；`candidate_document` 多存 `problems`、`failureReason`、`rawOutput` | 检测问题与原始返回（K-05） |
| `catdrama_shots` | **加字段** `analysis_problems JSONB NULL`：`{"problems": AnalysisProblem[], "descriptionHash": "生成时描述的 SHA-256"}`——最近一次生成的检测问题（见 `api.md` §6.0），指纹用来判断描述是否被手改（K-04 的 `-560017`）（T-09 用户定：放 JSON） | 可空，老数据为空；迁移同上 |
| `catdrama_jobs` | 任务种类约束 `ck_catdrama_job_kind` 加 `SHOT_DESCRIPTION`；其任务结果多存 `rawOutput` | 见第 3 节；迁移同上 |

漫剧迁移（2026-11-16 按后端 05 规则查证）：`catdrama/V4.17～V4.19` 随 2026-11-11 起的正式包打包，但四次正式部署日志都是“忽略不属于发布 schema 的迁移目录”，正式环境没有执行 。虽然可以改现有文件，**用户 2026-11-16 决定新增文件**（测试环境和本地库已执行过 `V4.19`，改它会校验和不一致）：以上四项写进新文件 `catdrama/V5.2__catdrama_asset_plan_and_shots.sql`（M04 B-01 一次做完，排在 M01 的 `common/V5.1` 之后），`V4.17～V4.19` 不动。阶段约束原值 `EDIT_READY` 保留（`V4.18` 已把数据并到 `VIDEOS`，代码不再使用）。

### 漫剧素材：主图 + 形象（R-01，2026-11-23）

> 本版改动：R-01（改表需用户同意，技术方案 T-01）

`catdrama_assets` 加两列，其余列不变（现有结构的唯一出处仍是迁移脚本 `catdrama/V4.17__catdrama_foundation.sql` 等）：

| 字段 | 类型 | 可空 | 默认 | 说明 |
|---|---|---|---|---|
| `parent_asset_id` | `BIGINT` | 是 | `NULL` | 所属主体（角色 / 场景）的素材 ID，外键指向本表 `id`；为空 = 这条就是主体。只有两层：主体的 `parent_asset_id` 必须为空。形象和主体同 `kind`、同 `user_id`、同 `scope`；作品素材同 `project_id`。道具不能有形象。由 `asset` 模块的服务代码保证（不加跨行的数据库约束） |
| `aliases` | `JSONB` | 否 | `'[]'::jsonb` | 角色别名数组（字符串），0～10 个，每个 1～20 字；约束 `ck_catdrama_asset_aliases`：`jsonb_typeof(aliases) = 'array'`。同一作品里不重名由服务代码在事务内锁行后检查 |

索引：`idx_catdrama_assets_parent (parent_asset_id)`。

形象怎么存：
- 形象 / 子场景就是一行素材，`name` 存它自己的名称（如“婚纱”，1～10 字，服务代码限制；表约束仍是 1～20），接口返回时拼成“主名·形象名”。
- 出现集数 = 它在 `catdrama_episode_assets` 里未归档的关联；片段引用它 = `catdrama_shot_asset_refs` 指向它的关联（一个片段同一角色两个形象 = 两条不同引用，现有唯一约束 `(shot_id, binding_id)` 不冲突）。
- 形象出图时，`catdrama_asset_image_versions.input_snapshot` 多记 `parentImageVersionId`（用的哪张主图）；主体后来换了图，接口返回 `parentImageOutdated = true`。
- 资产库（`PERSONAL`）里的形象挂在资产库里的主体下。

迁移：新文件 `catdrama/V5.6__catdrama_asset_looks.sql`（`ALTER TABLE … ADD COLUMN`、加约束和索引；不回填）。老数据：全部是主体、别名为空；老作品不做兼容（T-04）：描述里的“关联主场景”不再被识别，老场景一律当普通场景。回退：两列可空 / 有默认值，旧代码不读，可直接回退代码。

### Redis 键（新）

| 键 | 类型 | 内容 | 过期 |
|---|---|---|---|
| `auth:web-register-ip:{appCode}:{ip}` | 有序集合 | 成员 = 本次建号的请求标识，分数 = 建号时间（毫秒）。每次检查先删掉 30 天前的成员，再数个数 | 31 天（每次写入时刷新） |
| `auth:pwd-fail:{appCode}:{userId}` | 字符串计数 | 连续输错次数；到 5 次触发锁定时删除 | 最后一次输错后 24 小时 |
| `auth:pwd-lock:{appCode}:{userId}` | 字符串 | 锁定标记；剩余时间 = 键的剩余过期时间 | 15 分钟 |

Redis 数据丢失的影响：计数清零（注册限制和锁定暂时失效），不影响账号和密码本身。

### 迁移脚本

迁移脚本目录：后端 `src/main/resources/db/migration/common/`。
本版新增：`V5.1__user_password_credentials.sql`。依据：`common` 最新的 `V4.16__ai_artifact_marking_actor.sql` 已在正式执行（2026-11-16 部署日志 `deploy-prod-upgrade-20261116011615.log` 有“catoutfit 已执行 Flyway 版本: V4.16”），不能改，只能新增；命名按 05 规则 `V{build 主版本}.{当前大版本最大排序号+1}`，`build.gradle` 为 `5.0.0`，现有 5 大版本只有 `platform/V5.0` → `V5.1`。开工时再核对一次有没有新文件。
按后端 `docs/database-version-management.md`：开发阶段不更新该文档，大版本收口时统一整理。

## 2. 网页端本地存储

| 存储 | 键 | 内容 | 按账号隔离 | 同步方式 |
|---|---|---|---|---|
| localStorage | `catdrama_studio.auth` | `{ accessToken, refreshToken, userId }` | 是：退出、切换账号、刷新失败时整条删除 | 不同步；只在本浏览器 |
| localStorage | `catdrama_studio.theme` | `dark` 或 `light`：用户选的主题（R-33，M13）；没有或是别的值时用 `Global.defaultThemeMode` | 否：退出登录不清除 | 不同步；只在本浏览器 |
| localStorage | `catdrama_studio.device_id` | 网页端的设备标识（随机生成），发验证码时放在请求头 `X-Device-Id` 里，后端按设备限制短信频率用（M10） | 否：退出登录不清除 | 不同步；只在本浏览器 |
| sessionStorage | `catdrama_studio.invite_code` | 从带 `inviteCode` 参数的地址进来时记下的邀请码，登录 / 注册时带给后端 | 否 | 不同步；关掉标签页即丢 |
| 内存 | 登录前未完成的操作 | 弹出登录前当前页已填内容和要做的动作，登录成功后恢复（AC-02-3） | 是 | 不落盘；关页面即丢 |
| 内存 | 创建项目输入框 | 导入的 TXT 文字只放在输入框里，点“分析内容”时随现有接口提交 | 是 | 不单独上传 |

不在浏览器里保存：密码、短信验证码、私有图片 / 视频的签名地址（每次用时重新换签）。

## 3. 枚举与状态

| 枚举 | 取值 | 说明 |
|---|---|---|
| 请求头 `X-OS-Type` | `ios`、`android`、**`web`**、**`windows`**、**`mac`** | 本版新增后三个（R-06）；网页端固定发 `web` |
| 网页端客户端判定 | `web`、`windows`、`mac` | 后端用这三个值判断“电脑端”：网页注册限制、电脑支付宝表单 |
| 支付渠道 `channel` | `alipay`（App 支付）、`wechat`、`ios`、`alipay_web`（网页支付）、`mock` | 网页端只用 `alipay_web` |
| 订单状态 `status` | `PENDING`、`PAID`、`FAILED`、`CANCELLED`、`CLOSED` | 网页只把 `PAID` 当到账 |
| 账号类型 `accountType` | `GUEST`、`REGISTERED` | 网页端没有游客，只会是 `REGISTERED` |
| 是否设过密码 | 有 / 无 `user_password_credentials` 记录 | 不在用户资料接口里返回；设置页统一显示“登录密码（设置 / 修改）” |
| 核身电签 `contractStatus` | `0` 未同步、`1` 待签、`2` 生成中、`3` 完成 | `identityReady = true` 表示完成（现有） |
| 漫剧任务种类 `DramaJobKind` | `STORY`、`SCREENPLAYS`、`PROJECT_ANALYSIS`、`EPISODE_ANALYSIS`、`IMAGE`、`VIDEO`、`BATCH_IMAGE`、`BATCH_VIDEO`、`SUBTITLE_RECOGNITION`、`ASSET_DESCRIPTION`、`MEDIA_PROCESS`、**`SHOT_DESCRIPTION`（新）** | 网页不用 `SUBTITLE_RECOGNITION`、`MEDIA_PROCESS`。`PROJECT_ANALYSIS` 只做素材分析；`EPISODE_ANALYSIS` = 单集生成片段 + 视频描述词（确认素材后自动提交，或单集重新生成）；`SHOT_DESCRIPTION` = 单个片段描述（B-10） |
| 剧集阶段 `stage` | `ANALYSIS`（素材分析还没完成）、`MATERIALS`、**`SHOTS`（新）**、`VIDEOS`（`EDIT_READY` 已在 `V4.18` 并入 `VIDEOS`） | 见 `api.md` §6.7（B-10） |
| 片段生成状态 `shotGeneration.state` | `NONE`、`RUNNING`、`READY`、`FAILED` | 剧集上的新字段（B-10） |
| 片段提醒 `reminders[].code` | `LOOK_MISMATCH` | 原文提到某个形象的名称，片段却用了同一角色的别的形象（K-22，R-01）；只提醒，不挡生成 |
| 检测问题原因码 `reasonCode` | 沿用现有 `DramaAnalysisFailureReason`：`TASK_BLOCKED`、`MODEL_INCOMPLETE`、`MODEL_NO_SHOTS`、`MODEL_FORMAT`、`MODEL_SOURCE_MISMATCH`、`MODEL_COVERAGE`、`MODEL_REFERENCE`、`SCRIPT_DUPLICATE_TEXT`、`SCRIPT_LINE_TOO_LONG`、`MODEL_DURATION`、`MODEL_ASSETS`、`SERVICE_UNAVAILABLE`、`UNKNOWN` | 同一份定义，前后端不各写一份（B-10） |
