# 喵喵带货 Java 后端技术文档

> 版本：`v1.0`  
> 日期：2026-07-21  
> 状态：已确认  
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`  
> 管理后台工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 需求基线：`requirements.md` v0.1.6  
> 技术基线：`tech-plan.md` v1.3  

---

## 1. 文档目标

本文件说明喵喵带货如何接入现有 Java 多 App 服务，重点定义数据隔离、作品状态、脚本与分镜、视频任务、积分、审核和后台管理的实现边界。

本阶段只输出技术文档，不修改 Java 或管理后台代码。实际编码时以本文件、已确认技术方案和现有工程代码共同为准。

## 2. 已确认的实现结论

- 不新建独立 Java 服务，在现有 `lxwxservice` 中新增 `catseller` App schema 和业务包。
- 继续使用 Spring Boot 3.3.0、Java 21、Gradle、MyBatis-Plus、PostgreSQL、Redis 和 Flyway。
- 继续使用 `X-App-Code` 选择 App 与数据库 schema；喵喵带货固定为 `catseller`。
- 公共认证、用户、会员、积分、商品、支付、资源、审核、反馈、任务中心和邀请能力直接复用。
- 新增带货作品聚合、脚本版本、镜头、分镜图片、视频快照、生成任务、首页案例和业务配置。
- 首张有效商品图保存成功后幂等创建草稿作品。
- 内容任务内部按“文本脚本 → 分镜图片”执行，用户侧只维护一个“内容生成中”主状态。
- 用户确认脚本与分镜图片后，由视频模型直接生成最终视频，不建设独立配音/TTS 工作流。
- 生成任务开始后不可取消、不可删除；失败保留已成功内容。
- 生成任务编排参考现有 `app/catsinger/songworkflow`，沿用任务创建、步骤定义、步骤实例、调度执行、暂停等待、事件日志和失败补偿的业务模式，但使用 catseller 自己的类、枚举和数据表。
- 视频生成积分按分镜图片数量报价；客户端不得提交自算总价。
- 商品、文本、图片、形象和视频审核复用现有阿里内容安全能力。
- 后端只返回 `aiGenerated` 来源标记，AI 水印由 Flutter 前端处理。
- 作品及相关内容 7 天后隐藏、30 天后删除；运行中内容不进入清理。
- 首版不发送任务完成/失败通知，也不建设 WebSocket 推送。

## 3. 当前 service 事实

### 3.1 技术栈

| 项目 | 当前实现 |
|------|----------|
| Java | 21 Toolchain |
| 框架 | Spring Boot 3.3.0 |
| 构建 | Gradle |
| 数据访问 | MyBatis-Plus 3.5.7 |
| 数据库 | PostgreSQL，按 App 独立 schema |
| 迁移 | Flyway，公共迁移 + App 专属迁移 |
| 缓存/风控 | Redis |
| 鉴权 | Spring Security + JWT |
| 接口文档 | springdoc OpenAPI |
| 对象存储 | 公共资源台账 + 阿里云 OSS |
| 内容审核 | 公共审核模块 + 阿里 Green |
| AI | Provider 适配层，已有文本、图片、视频接口 |
| 测试 | Spring Boot Test、Spring Security Test、H2 |

### 3.2 已有多 App 机制

- `AppCodeFilter` 校验 `X-App-Code`、`X-App-Version`、`X-OS-Type`。
- `AccessAuditFilter` 对 `/api/**` 输出独立结构化访问审计日志；普通运行日志仍按原策略滚动，审计日志默认保留 190 天。
- `AppContext` 使用请求线程上下文保存当前 App。
- `SchemaRoutingDataSourceConfig` 为每个 App 建立连接池，并按 schema 路由。
- Flyway 启动时为每个 App 执行 `db/migration/common`，再执行 `db/migration/{appCode}`。
- 后台任务需要显式设置并清理 `AppContext`，不能依赖请求线程默认值。

当前 `application.yml` 已注册 `narrate`、`catsinger`、`catcomic`，尚未注册 `catseller`。这是本项目第一项后端前置工作。

### 3.3 可直接复用的模块

| 现有模块 | 本项目用途 |
|----------|------------|
| `core/auth`、`core/user` | 登录、Token、用户和账号 |
| `core/entitlement` | 会员、积分账户、冻结、确认、退款和流水 |
| `core/order`、`core/payment`、`core/product` | 充值、会员商品和支付订单 |
| `core/resource`、`thirdparty/oss` | 商品图、形象、分镜图和视频资源 |
| `core/moderation`、`thirdparty/contentmoderation` | 阿里文本、图片和视频审核 |
| `core/ai`、`thirdparty/aimodel` | 模型配置及文本、图片、视频 Provider |
| `app/growth` | 任务中心、兑换码、邀请和反馈 |
| `admin` 公共模块 | App 切换、用户、商品、积分、兑换码和通用配置 |
| `framework/util/IdempotencyService` | 创建与提交接口幂等 |

公共模块不得复制到 `app/catseller`。只有带货特有领域逻辑进入新业务包。

## 4. 项目专属开发规则

### 4.1 继承规则

编码阶段继承工作区 Java 初始化、目录、编码、控制器、数据库、依赖、接口、安全、测试和编码工作流规则。进入实际编码前必须重新加载 Java 编码索引及对应模块规则。

### 4.2 本项目特化规则

1. `X-App-Code: catseller` 和 JWT 中的 App 必须一致，不允许跨 schema 查询或兜底扫描。
2. 客户端不传 `userId`；所有私有对象按当前登录用户校验归属。
3. 作品主状态只有草稿、内容生成中、编辑脚本、视频生成中、视频已完成；内部步骤不能扩张成用户主状态。
4. 运行中任务没有取消接口，删除接口必须在服务端拒绝运行中作品。
5. 作品详情是业务聚合真源；列表只返回卡片摘要，不让客户端拼装状态。
6. 生成提交必须以数据库唯一约束、幂等记录和状态 CAS 共同防重。
7. Provider 原始错误、密钥、Prompt、签名 URL和第三方任务 ID不得返回 App。
8. 视频报价、积分冻结和视频任务创建必须处于同一业务幂等边界。
9. AI 水印不进入后端任务状态；后端只保存并返回 `aiGenerated`。
10. 所有表结构变更必须通过 `db/migration/catseller` Flyway 脚本，不使用启动代码临时建表。

## 5. 项目结构

```text
src/main/java/com/lxwx/narrateservice/
├── app/catseller/
│   ├── casecontent/       # 首页与更多案例
│   ├── config/            # 带货规格和业务配置
│   ├── persona/           # 平台、上传和 AI 形象
│   ├── work/              # 作品、输入、版本、镜头、详情
│   ├── generation/        # 内容、分镜图和视频任务
│   ├── workflow/          # 带货工作流定义、执行器、步骤、事件与补偿
│   └── billing/           # 视频报价与公共积分适配
├── admin/catseller/       # 案例、配置、作品和任务查询
├── core/                  # 复用公共能力
└── thirdparty/aimodel/    # 扩展 Provider 中立视频输入

src/main/resources/
├── application.yml
├── db/migration/catseller/
└── service-data/apps/catseller/
```

包内延续现有 `controller / service / repository / entity / dto / vo / domain / task` 分层。不要新建第二个 Spring Boot 启动类。

## 6. 配置与数据隔离

### 6.1 Schema 注册

`application.yml` 增加：

```yaml
app:
  schema-routing:
    mappings:
      catseller: ${CATSELLER_DB_SCHEMA:catseller}
```

同时增加 `db/migration/catseller` 和 `service-data/apps/catseller`。启动测试必须证明公共表和专属表只创建在 catseller schema，且不会写入 catsinger。

### 6.2 初始配置

建议放入后台或 service-data 的配置：

- 商品图片数量、格式、大小和清晰度限制。
- 比例和时长选项。
- 形象数量、脚本历史和图片历史上限。
- 7 天隐藏、30 天删除期限。
- 首页入口、营销文案和案例开关。
- 视频每张分镜图片积分单价及价格版本。
- 失败积分处理策略和展示文案。
- 文本、图片、视频模型与 Prompt/Schema 版本。

`catseller.business` 只接受当前代码配套的 JSON 结构，不设置 `configVersion`，也不提供历史配置迁移或静默补齐。运行时同 key 数据库配置优先，数据库缺少记录时读取随包 `app-configs.json`；旧结构需要由运营清空 `app_configs` 或恢复为当前 JSON。

真实密钥只通过私有配置或环境变量注入，不写入仓库和 service-data。

### 6.3 BigLongXia Google 视频公共能力

公共 `providerCode=biglongxia` 按模型编码区分视频协议。原 Grok 模型继续使用
`/v1/videos` 及 Bearer content 下载；下列 Google 模型使用
`POST /v1/video/generations`、`GET /v1/video/generations/{taskId}` 和查询响应中的签名 URL：

- `gemini-omni-flash-preview`：1–8 秒、720p，仅支持首帧。
- `veo-3.1-fast-generate-preview`：1–8 秒、1080p，支持首帧和显式尾帧。
- `veo-3.1-generate-preview`：1–8 秒、1080p，支持首帧和显式尾帧。

三款模型仅支持 `16:9`、`9:16`，多张参考图只取稳定顺序第一张；`generateAudio`
默认 `false`，`responseFormat` 固定为 `privacy_url`。提交/查询路径可分别通过
`BIGLONGXIA_GOOGLE_VIDEO_SUBMIT_PATH`、`BIGLONGXIA_GOOGLE_VIDEO_QUERY_PATH` 覆盖，鉴权继续共用
`BIGLONGXIA_API_KEY`，密钥不得进入代码、service-data、任务结果或日志。

本节仅登记公共模型目录和 Provider 协议能力。Catseller 当前 10/15 秒选项、分段计划、报价、
计费和默认 Seedance 路由保持不变；未完成模型感知改造前，不承诺上述 Google 模型可直接用于
Catseller 生成流程。

## 7. 领域状态

### 7.1 作品状态

| 状态 | 含义 | 可执行操作 |
|------|------|------------|
| `DRAFT` | 已创建作品，继续填写信息 | 保存、提交内容生成、删除 |
| `CONTENT_RUNNING` | 正在生成脚本和分镜图片 | 查询进度；不可改、不可取消、不可删 |
| `EDITING` | 脚本和图片可编辑确认 | 修改、重生成、替换、报价、删除 |
| `VIDEO_RUNNING` | 已冻结/处理积分并生成视频 | 查询进度；不可改、不可取消、不可删 |
| `COMPLETED` | 至少存在一个成功视频 | 播放、下载、分享、新建编辑版本、重新生成、删除 |
| `FAILED` | 当前内容或视频任务失败 | 按失败阶段重试或返回可编辑状态 |
| `HIDDEN` | 7 天后不再出现在列表 | 查看隐藏说明、主动删除 |
| `DELETED` | 30 天后删除或用户主动删除 | 不可恢复 |

`FAILED` 需要同时保存 `failedStage` 和 `resumeState`，这样脚本失败、部分图片失败、视频失败能回到不同的恢复入口。

### 7.2 任务状态

任务统一使用 `PENDING / RUNNING / SUCCEEDED / FAILED`，并保存：

- `taskType`：描述帮写、定制形象、内容、单镜头图片、视频。
- `currentStep`：仅用于展示和运维，不改变作品主状态。
- `progress`：真实进度；Provider 无百分比时允许为空。
- `leaseUntil`、`retryCount`、`nextRunAt`：Worker 恢复。
- `providerTaskId`：服务端内部使用并建唯一约束。
- `errorCode`、脱敏 `errorMessage`、失败阶段和恢复建议。

所有生成任务开始后不提供取消状态或取消接口。

工作流步骤使用 `PENDING / RUNNING / PAUSED / SUCCESS / FAILED / SKIPPED`。`PAUSED` 仅表示等待 Provider 或审核结果，任务主状态仍为运行中；恢复时跳过已经 `SUCCESS/SKIPPED` 的步骤。步骤失败由工作流引擎统一记录错误、事件和补偿，再更新任务及作品状态。App 只读取任务主状态、业务阶段和聚合进度，不直接解释内部步骤状态。

## 8. 数据库设计

### 8.1 专属表

| 表 | 作用 | 关键字段/约束 |
|----|------|---------------|
| `catseller_works` | 作品聚合根 | 用户、不可变 `work_type`、状态、当前输入/脚本/视频版本、最后使用、隐藏/删除时间、乐观锁 |
| `catseller_work_inputs` | 填写信息版本 | 通用 `selling_points`、比例、时长、清晰度、形象、版本、输入快照 |
| `catseller_work_assets` | 输入图片及排序 | 作品、resourceId、`asset_type` 图片角色、顺序、主图、审核状态；同作品顺序唯一 |
| `catseller_personas` | 用户/平台/AI 形象 | owner、来源、resourceId、授权、AI 标记、有效期、状态 |
| `catseller_script_versions` | 整稿历史 | 作品、版本号、Schema 版本、来源、当前标记；版本唯一 |
| `catseller_shots` | 镜头 | 脚本版本、顺序、画面、可选口播、建议时长、乐观锁 |
| `catseller_storyboard_images` | 分镜图片历史 | 镜头、resourceId、版本、来源、审核、AI 标记、当前标记 |
| `catseller_video_snapshots` | 不可变视频输入 | 作品、脚本/图片快照、snapshotHash、报价、失败策略版本 |
| `catseller_videos` | 成功或失败视频记录 | 快照、resourceId、状态、审核、AI 标记、有效期 |
| `catseller_generation_tasks` | 统一生成任务 | 类型、业务对象、状态、步骤、Provider、租约、幂等键、错误 |
| `catseller_generation_task_steps` | 工作流步骤实例 | taskId、步骤编码、状态、顺序、重试、请求/结果摘要、错误、起止时间；taskId+stepCode 唯一 |
| `catseller_generation_task_events` | 任务事件日志 | taskId、事件类型、步骤、脱敏消息和数据摘要、时间 |
| `catseller_generation_compensations` | 失败补偿记录 | taskId、步骤、补偿类型、状态、重试和错误；同一动作唯一 |
| `catseller_cases` | 首页/更多案例 | 封面、视频、排序、上下线、AI 标记 |
| `catseller_billing_quotes` | 视频报价 | 图片数、单价、总价、价格版本、snapshotHash、失败规则、过期时间 |

商品图、形象、分镜图片和视频实体只保存公共 `resource_records.id`，不把临时 Provider URL当长期结果。

### 8.1.1 探店增量迁移

`V3.4__catseller_store_video.sql` 只扩展现有聚合：`catseller_works` 新增 `work_type` 并将历史数据视为 `PRODUCT_VIDEO`；`product_description` 数据保留地重命名为 `selling_points`；`catseller_work_assets.asset_type` 直接保存四种图片角色。图片分析缓存增加 `work_type + asset_role`，唯一键按资源、场景、角色和分析版本隔离。脚本、分镜、视频、报价、积分、审核和退款表均不新增探店副本。

### 8.2 关键约束

- 同一作品同一阶段最多一个活动任务。
- 同一脚本版本镜头顺序唯一。
- 同一镜头图片版本号唯一，且最多一个当前图片。
- 同一作品脚本版本号唯一，且最多一个当前脚本。
- Provider 任务 ID 在有效 Provider 范围内唯一。
- 报价绑定 `snapshotHash`，任一脚本、图片或配置改变即失效。
- 所有可编辑聚合表保留 `version` 乐观锁字段。

### 8.3 公共表复用

继续使用用户、Token、会员、积分账户/流水/扣费订单、支付订单、商品、资源台账、内容审核、AI 模型配置、反馈、任务中心、兑换码和邀请等公共表，不在 catseller schema 建同义副本。

## 9. API 设计

### 9.1 统一约定

- HTTPS REST/JSON，返回 `{code, message, data}`。
- 普通 App API 必须携带 `X-App-Code: catseller`。
- 私有接口使用 JWT；所有对象做当前用户归属校验。
- 创建、提交、重生成和恢复接口读取 `Idempotency-Key`。
- 作品和案例列表使用游标分页，无筛选，按后台顺序或更新时间排序。
- 聚合详情返回 `version`、`updatedAt`、`actions` 和运行中 `nextPollAfterMs`。
- 媒体接口返回资源描述和短期访问数据，不返回永久 OSS 原地址。

### 9.2 首页、案例和配置

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/catseller/home` | 游客首页案例、入口和营销文案 |
| GET | `/api/catseller/cases` | 登录后的更多案例列表，无筛选 |
| GET | `/api/catseller/cases/{caseId}` | 案例预览数据 |
| GET | `/api/catseller/config` | 图片、比例、时长、开关和提示配置 |

### 9.3 AI 帮写和形象

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/catseller/description-tasks` | 创建描述帮写任务 |
| GET | `/api/catseller/description-tasks/{taskId}` | 查询帮写结果 |
| GET | `/api/catseller/personas` | 查询平台和个人可用形象 |
| POST | `/api/catseller/personas` | 登记审核通过的上传形象 |
| POST | `/api/catseller/persona-tasks` | 创建 AI 定制形象任务 |
| GET | `/api/catseller/persona-tasks/{taskId}` | 查询定制结果 |
| PATCH | `/api/catseller/personas/{personaId}` | 重命名形象 |
| DELETE | `/api/catseller/personas/{personaId}` | 删除未被运行任务引用的形象 |

### 9.4 作品和输入

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/catseller/works` | 以首图资源幂等创建草稿 |
| PATCH | `/api/catseller/works/{workId}/input` | 保存草稿输入，运行中拒绝 |
| POST | `/api/catseller/works/{workId}/content-tasks` | 提交脚本和初始分镜图片任务 |
| GET | `/api/catseller/works` | 无筛选作品列表，只返回可见作品 |
| GET | `/api/catseller/works/{workId}` | 作品聚合详情和可执行操作 |
| DELETE | `/api/catseller/works/{workId}` | 删除允许删除的非运行中作品 |
| POST | `/api/catseller/works/{workId}/versions` | 从完成作品创建新编辑版本 |

### 9.5 脚本、镜头和分镜图片

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/catseller/works/{workId}/script-versions` | 整稿历史 |
| POST | `/api/catseller/works/{workId}/content-tasks/regenerate` | 重生成整稿和全部图片 |
| POST | `/api/catseller/works/{workId}/script-versions/{versionId}/restore` | 恢复脚本及其图片关系 |
| PATCH | `/api/catseller/works/{workId}/shots/{shotId}` | 修改画面和可选口播 |
| GET | `/api/catseller/works/{workId}/shots/{shotId}/images` | 镜头图片历史 |
| POST | `/api/catseller/works/{workId}/shots/{shotId}/image-tasks` | 重生成当前镜头图片 |
| POST | `/api/catseller/works/{workId}/shots/{shotId}/images` | 关联用户上传替换图 |
| PUT | `/api/catseller/works/{workId}/shots/{shotId}/current-image` | 选择审核通过的历史图片 |
| POST | `/api/catseller/works/{workId}/failed-shots/retry` | 只重试失败镜头 |

### 9.6 报价和视频

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/catseller/works/{workId}/video-quotes` | 生成图片数、单价、总积分和失败规则报价 |
| POST | `/api/catseller/works/{workId}/video-tasks` | 校验报价和快照，冻结积分并创建任务 |
| POST | `/api/catseller/works/{workId}/video-tasks/retry` | 失败后重新报价并创建新任务 |
| GET | `/api/catseller/works/{workId}/video` | 获取可播放结果、AI 来源和有效期 |

登录、会员、积分、充值、任务、订单、兑换码、设置和邀请接口沿用现有公共接口，不新增 catseller 平行版本。

## 10. 作品聚合详情

`GET /api/catseller/works/{workId}` 是 App 恢复业务的唯一真源，建议响应至少包含：

- 作品基础信息：名称、封面、主状态、失败阶段、更新时间和生命周期时间。
- 当前输入：商品图、描述、参数、形象和输入版本。
- 当前内容：脚本版本、镜头和每个镜头当前图片。
- 运行任务：类型、阶段、真实进度、错误、下次轮询间隔。
- 当前视频：成功版本、播放资源、AI 来源和有效期。
- 报价摘要：仅在当前快照仍有效时返回。
- `actions`：服务端计算出的保存、编辑、重试、删除、下载等操作权限。

客户端不能根据状态自行猜测所有操作权限；运行任务、资源过期、审核中或旧成功视频并存时由服务端给出明确动作。

草稿详情的 `draft.taskInput.inputImages[]` 及兼容别名 `productImages[]` 均返回 `sizeBytes`，值来自现有资源台账；正常资源返回正数，历史缺失元数据返回 0。该字段仅支持 Flutter 恢复草稿后计算压缩图片总量，不新增数据库字段，也不在后端实施 10 MiB 总量拦截。

## 11. 内容生成工作流

### 11.1 参考 SongWorkflow 的实现方式

现有 Java 代码中的以下结构作为带货任务实现参考：

| SongWorkflow 现有结构 | 带货对应结构 | 复用边界 |
|----------------------|--------------|----------|
| `SongGenerationService` | `SellerGenerationTaskService` | 幂等校验、请求快照、初始化步骤、快速返回任务 |
| `SongGenerationExecutionScheduler/Service` | `SellerGenerationExecutionScheduler/Service` | 设置 `AppContext=catseller`、批量捞取、CAS 抢占、处理暂停任务 |
| `SongWorkflowDefinitionProvider` | `SellerWorkflowDefinitionProvider` | 按任务类型返回固定步骤定义，不复制歌曲步骤编码 |
| `SongWorkflowEngine`、`SongWorkflowStep` | `SellerWorkflowEngine`、`SellerWorkflowStep` | 跳过已完成步骤，统一处理 success/skipped/paused/failed |
| `SongWorkflowStepService` | `SellerWorkflowStepService` | 幂等初始化步骤和持久化步骤状态/摘要 |
| `SongTaskEventLogService` | `SellerTaskEventLogService` | 记录脱敏任务与步骤事件 |
| `SongGenerationCompensationService` | `SellerGenerationCompensationService` | 对积分、资源、作品状态执行幂等补偿 |

若编码时抽取公共工作流引擎，公共层只能包含无业务语义的定义、步骤结果和执行骨架；catseller 不得直接引用 catsinger 的步骤枚举、Entity、Repository、表名或音乐文案。

AI 帮写和定制形象也使用同一执行骨架，但各自拥有轻量定义：`SELLER_DESCRIPTION_ASSIST_V1`（校验/审核输入 → 生成描述 → 审核输出 → 保存候选 → 完成）和 `SELLER_PERSONA_V1`（校验授权与素材 → 审核输入 → 生成形象 → 保存资源 → 审核输出 → 保存形象 → 完成）。它们不并入作品内容或视频工作流。

### 11.2 创建草稿

1. 公共资源模块完成商品图或门头图上传。
2. 审核全部输入图片并确认资源属于当前用户和 catseller。
3. 使用 `Idempotency-Key + workType + 主资源` 创建草稿、首个输入版本和带角色的素材关系。
4. 相同键和相同摘要返回原作品；相同键不同摘要返回幂等冲突。

商品视频只允许 `PRODUCT_IMAGE` 1～3 张；探店视频要求 `STORE_FRONT` 1～3 张，允许 `STORE_INTERIOR`、`STORE_OFFERING` 各 0～4 张。全局禁止重复资源，组内顺序稳定。`workType` 只存在于创建请求、作品响应和任务快照中，`UpdateCatsellerWorkInputRequest` 不声明该字段；更新请求即使传入相同值或 `null` 也必须在加锁和数据读写前返回 `BAD_REQUEST(-400)`，不能创建输入版本或修改作品。

更新作品图片统一使用 `imageGroups`；商品图片通过 `PRODUCT_IMAGE` 角色表达，更新请求不再声明或兼容 `productImageResourceIds`。

### 11.3 生成脚本和分镜图片

1. 校验作品为草稿或允许重新生成的编辑状态。
2. 根据 `workType` 校验图片角色/数量、卖点、形象、比例、时长和审核结果。
3. 保存不可变输入快照，作品进入 `CONTENT_RUNNING`。
4. 文本模型按版本化 JSON Schema 生成结构化脚本。
5. 校验镜头顺序、画面描述、可选口播和建议时长。
6. 解析失败时有限重试；仍失败则记录脚本失败，保留输入。
7. 保存脚本版本和镜头后，为每个镜头创建图片任务。
8. 图片逐张生成、入资源台账、审核并保存版本；部分失败不回滚已成功图片。
9. 所有必需镜头有可用图片后进入 `EDITING`；存在失败镜头则返回可局部重试的问题列表。

内容任务是用户可见的一项任务，但内部步骤必须可观测、可恢复。

当前真实内容工作流固定为 `VIDEO_CONTENT_WORKFLOW_V1`：`CHECK_CONTENT_RESOURCE → REVIEW_CONTENT_INPUT → GENERATE_SCRIPT → GENERATE_STORYBOARD → SAVE_CONTENT_DRAFT → PUBLISH_CONTENT_RESULT`。两种场景步骤编码和顺序完全相同。`VIDEO_CONTENT_STORYBOARD_IMAGE_V1` 仅是可选单分镜图片能力，不属于当前文本分镜直接生成视频的主链路。

根上下文 schema v2 保存不可变 `workType` 和带 `role` 的 `inputImages`；读取旧上下文时映射为 `PRODUCT_VIDEO + PRODUCT_IMAGE`。单分镜图片任务也固化 `workType`，旧任务缺失时按商品视频恢复；明确但不支持的场景不得回退。

作品提示词由 `SellerBusiness` 门面统一接入，门面通过不可变的 `SellerScenePromptRegistry` 路由到 `SellerScenePromptStrategy`。当前 `ProductVideoPromptStrategy`、`StoreVideoPromptStrategy` 分别完整实现图片分析、卖点、脚本、文本分镜、单分镜图片和最终视频六类能力；注册表发现重复策略或任一 `CatsellerWorkType` 缺少实现时启动失败。公共 JSON 序列化和字段渲染由无场景判断的辅助组件提供，人物形象提示词继续由门面直接处理。未来新增场景只需增加枚举、图片规则、策略实现与测试，不修改通用 AI 入口或门面分支。

商品策略保持既有带货语义。探店策略根据 `STORE_FRONT`、`STORE_INTERIOR`、`STORE_OFFERING` 分别关注门头外立面与招牌、店内空间装修陈列、图片可见商品或服务，并贯穿脚本、分镜图片和视频提示词；所有模板只能引用图片可见内容和用户卖点，不得虚构店名、地址、营业时间、价格、优惠、认证或不可见服务。

### 11.4 脚本输出 Schema

至少包含：

```json
{
  "schemaVersion": "1.0",
  "shots": [
    {
      "order": 1,
      "visualDescription": "商品特写，展示瓶身和质感",
      "voiceover": "",
      "suggestedDurationMs": 3000
    }
  ]
}
```

画面描述必填，口播可空。模型原始文本和解析错误只写脱敏运维信息，不直接返回客户端。

## 12. 视频工作流

### 12.1 不可变快照

提交视频前生成 `video_snapshot`，固定：

- 当前输入版本、脚本版本和镜头顺序。
- 每个镜头选中的分镜图片版本。
- 比例、目标时长、形象和模型配置。
- 图片数量、报价、价格版本和失败处理策略。
- `snapshotHash`。

快照哈希必须包含 `workType` 与每张图片的角色。参考图按商品/门头、环境、商品或服务、人物的稳定顺序传递，所有通过校验的图片都参与分析和最终快照，不静默筛除。

任务开始后编辑页面不能修改该快照。用户从完成页重新编辑时创建新版本，不覆盖旧视频。

### 12.2 Provider 中立输入

扩展现有视频 Provider 命令，支持：

- 有序镜头列表：镜头 ID、图片资源、画面描述、可选口播、建议时长。
- 全局参数：比例、目标时长、形象引用和负向约束。
- 业务信息：作品 ID、快照 ID、幂等业务键和短期资源访问数据。

若 Provider 只能逐镜生成片段，合成行为必须封装在 Provider/工作流内部；产品仍只看到“视频生成中”。

### 12.3 处理流程

1. 校验报价、快照和用户积分。
2. 在业务幂等边界内创建扣费订单、冻结积分、视频快照和视频任务。
3. Worker 领取任务并写租约。
4. 提交 Provider，保存内部任务 ID并轮询或接收回调。
5. 下载/转存最终视频到公共资源模块。
6. 复用阿里视频审核。
7. 按报价快照中的失败策略确认或处理积分。
8. 成功写入视频版本并进入 `COMPLETED`；失败写失败阶段并保留旧成功视频。

当前真实视频工作流固定为 `VIDEO_RENDER_WORKFLOW_V1`：`CHECK_VIDEO_RESOURCE → REVIEW_VIDEO_INPUT → CALCULATE_POINTS → CHECK_BALANCE → RESERVE_POINTS → SUBMIT_VIDEO_TASK → POLL_VIDEO_RESULT → STORE_CANDIDATE_VIDEO → SUBMIT_VIDEO_REVIEW → WAIT_VIDEO_REVIEW → SETTLE_POINTS → PUBLISH_VIDEO`。该十二步对商品和探店完全共用；Provider 或审核未完成时使用 `PAUSED`，不得靠阻塞线程等待。

## 13. 任务并发、幂等与恢复

- 执行主链参考 `SongWorkflow`：创建接口只落任务和步骤；调度器按 App 扫描；执行服务 CAS 抢占；Pipeline 建立上下文；Engine 顺序推进 Step。
- 已成功/跳过步骤恢复时直接略过；暂停步骤重新检查外部结果；长时间 RUNNING 的外部调用不得直接重复提交，应先按 Provider 任务 ID 或幂等业务键对账。
- 每个步骤保存脱敏请求/结果摘要，每次开始、暂停、成功、失败和工作流终态写事件日志。
- 补偿记录必须可重复执行且不重复退款、删除资源或覆盖旧成功作品。
- 同一作品同一阶段最多一个活动任务，数据库唯一约束是最终防线。
- `IdempotencyService` 保存键、请求摘要和首次结果；同键不同请求拒绝。
- 状态更新使用乐观锁或条件更新，禁止无条件覆盖终态。
- Worker 通过 `leaseUntil` 领取任务；进程崩溃后允许其他实例续领。
- Provider 提交成功但本地超时的任务必须先按幂等键/Provider ID查询，不能直接重复提交。
- 回调和轮询同时到达时，通过 Provider 任务唯一键和终态幂等防止重复入库或扣费。
- 分镜图片部分失败只重试失败镜头。
- 视频失败可创建新任务，但必须生成新报价和新扣费业务号。
- 任务最终只有成功或失败；超时达到上限后明确失败，不无限运行。

## 14. 积分计费

### 14.1 报价

服务端计算：

```text
预计积分 = 已确认且审核通过的分镜图片数量 × 当前每图积分单价
```

报价保存图片数、单价、总价、价格版本、快照哈希、失败策略、展示文案和过期时间。

### 14.2 扣费

复用现有 `PointsService` 的生成冻结、确认和退款能力：

- 提交时重新校验图片数量、价格版本、报价有效期和余额。
- 冻结积分成功后才能创建/启动视频任务。
- 成功后确认消耗。
- Provider 失败、审核拒绝和系统失败如何处理，读取报价中固化的失败策略。
- 用户每次重新生成都创建新报价并重新消耗积分。
- 充值返回后客户端必须获取新余额和新报价。

客户端提交的总价只作展示回传，不参与服务端扣费计算。

## 15. 内容审核

复用 `ContentModerationService` 和阿里 Green，增加 catseller 场景和目标类型：

| 节点 | 审核内容 |
|------|----------|
| 草稿输入 | 商品图、商品描述、上传人像 |
| AI 帮写 | 输入和输出文本 |
| 内容生成 | 脚本文本、每张分镜图片 |
| 用户编辑 | 修改后的画面描述、口播、上传替换图 |
| 形象定制 | AI 形象图片 |
| 视频完成 | 最终视频 |

- 同步拒绝立即返回可理解原因。
- 异步审核未完成前，不能返回媒体结果或把作品标记为完成。
- 审核 Provider 不可用时按后台配置决定重试或失败，不能默认放行。
- 对 App 只返回公开错误分类，不返回内部标签和第三方原文。

## 16. AI 来源标记

- AI 生成的分镜图片、定制形象、案例和视频保存 `ai_generated=true`。
- 用户上传且未经过生成模型的图片保存为 false。
- 所有媒体响应统一返回 `aiGenerated`。
- 后端不创建水印任务、不修改媒体文件，也不返回“水印处理中”状态。
- Flutter 保存或分享时是否添加水印，唯一判断依据是该字段。

## 17. 资源与生命周期

### 17.1 资源

- 使用公共资源模块申请直传、完成确认、审核、查询和物理删除。
- 原始对象默认私有；模型和客户端读取使用短期签名地址。
- 业务表保存 `resourceId`、摘要和来源，不保存 Provider 临时 URL。
- 删除前检查脚本版本、镜头、视频快照和运行任务引用。

### 17.2 7 天隐藏、30 天删除

- 从内容生成完成或最后一次使用时间计算。
- 到 7 天后设置作品及关联内容为隐藏，不再返回作品列表。
- 到 30 天后删除业务记录或做不可恢复删除标记，并调用公共资源删除能力。
- 运行中的任务及其输入不进入隐藏/删除。
- 后台定时任务遍历全部 App 时必须显式切换 `AppContext`，每个 schema 独立处理和记录。
- 首版不发送到期通知。

## 18. 安全与隐私

- JWT 的 App 与 `X-App-Code` 不一致时拒绝请求。
- 所有作品、镜头、图片、形象、报价和视频都校验用户归属。
- 当前 `SecurityConfig` 的兜底规则是 `anyRequest().permitAll()`，因此新增接口时必须显式配置：仅 `GET /api/catseller/home` 和 `GET /api/catseller/config` 匿名可读，其他 `/api/catseller/**` 全部要求登录；不能依赖控制器自行判断作为唯一鉴权。
- 人像记录授权版本、确认时间和来源；授权失效后禁止用于新任务。
- 普通业务日志只记录 traceId、内部 ID、状态和脱敏错误，不记录 Token、签名参数、完整手机号或完整 Prompt。
- 独立访问审计日志记录 App、认证账号内部 ID、操作类型、HTTP 方法和接口路径、结果、耗时、源/目标网络端点、App/OS 版本、设备型号、匿名安装标识摘要及 User-Agent；不记录查询参数、请求/响应正文、Authorization、手机号或验证码。
- 访问审计日志按日期和 50MB 大小滚动，默认保留 190 天且不配置容量上限提前淘汰；生产经过受控网关时才开启代理头信任，并由网关覆盖客户端传入的转发头。
- 管理后台只能读取所选 App schema；管理员权限不足时不展示或调用 catseller 菜单。
- 删除账号时扩展 catseller 数据检查；存在运行任务时按公共注销规则处理。

## 19. 运营后台

现有 `lxwx_admin` 已完成 catseller App 切换和以下后台业务：

| 页面 | 功能 |
|------|------|
| 后台入口 | 注册 catseller App 和业务菜单，沿用现有管理员登录权限 |
| 案例管理 | 封面、视频、排序、上下线、AI 标记 |
| 业务与视频计费配置 | 图片限制、视频类型、比例/时长、清晰度、默认参数、保留期、单图积分、计费版本、失败策略 |
| AI 模型配置 | 复用通用 Provider/模型配置，增加带货场景和 Schema 版本 |
| 作品查询 | 按作品编号、标题、状态查询填写信息、脚本分镜、审核和视频 |
| 生成任务查询 | 按任务编号、作品编号、类型、状态查询步骤、失败原因和脱敏 trace |

作品和生成任务保持只读，不提供手工篡改作品状态、脚本、积分或任务终态的操作。案例封面和视频通过公共资源台账上传，无新增数据库表。视频类型演示视频可由上传接口生成地址，也可手工填写当前 OSS 的 `public/catseller/video-type-videos/` 公开目录地址；手工地址无需已有资源台账记录，外部域名或其他目录拒绝保存，封面留空时自动抽帧并保存为公开资源。

## 20. 错误码

| 错误码 | 含义 |
|--------|------|
| `AUTH_REQUIRED` | 需要登录 |
| `WORK_NOT_FOUND` | 作品不存在或无权访问 |
| `WORK_STATE_CONFLICT` | 当前状态与请求不一致 |
| `WORK_RUNNING_LOCKED` | 运行中不可编辑、取消或删除 |
| `CONTENT_REJECTED` | 输入或生成内容审核拒绝 |
| `ASSET_INVALID_OR_EXPIRED` | 资源无效、过期或不属于当前用户 |
| `SHOT_CONTENT_INCOMPLETE` | 镜头缺少画面或可用图片 |
| `POINTS_INSUFFICIENT` | 积分不足 |
| `QUOTE_EXPIRED` | 报价或快照已变化 |
| `IDEMPOTENCY_CONFLICT` | 同幂等键请求摘要不一致 |
| `GENERATION_PROVIDER_BUSY` | Provider 暂不可用，可稍后重试 |
| `GENERATION_FAILED` | 任务已失败并有恢复入口 |
| `RESOURCE_HIDDEN` | 内容已隐藏 |
| `RESOURCE_DELETED` | 内容已删除不可恢复 |

错误响应附带 traceId。公开 `message` 必须说明用户能做什么，内部异常堆栈只写服务端日志。

## 21. 测试计划

### 21.1 单元和服务测试

- 作品状态迁移与非法迁移。
- 首图幂等创建草稿。
- 脚本 JSON Schema 解析、修复和失败。
- 分镜图片部分成功、部分失败和局部重试。
- 镜头编辑、图片版本选择和整稿恢复。
- 报价按图片数量计算、报价失效和价格版本变化。
- 积分冻结、确认、失败策略和幂等补偿。
- 同一作品活动任务唯一约束和状态 CAS。
- 7 天隐藏、30 天删除以及运行中跳过。
- `aiGenerated` 在图片、形象、案例和视频中的一致返回。

### 21.2 集成测试

- `X-App-Code: catseller` 命中 catseller schema，无法访问 catsinger 数据。
- API 访问审计事件包含账号、操作、结果、网络端点和客户端特征，设备标识只落 SHA-256 摘要，日志中不存在查询参数、Token 和请求正文。
- 游客首页可访问，案例/作品/账户类私有接口受保护。
- 公共资源上传、归属校验和阿里审核。
- 文本 → 分镜图 → 编辑 → 报价 → 视频的完整链路。
- App 重复提交、请求超时后重试和回调/轮询竞争不重复扣费。
- 任务进程重启后的租约恢复。
- 旧成功视频在新版本失败后仍可访问。
- Admin App 切换、权限和查询隔离。

### 21.3 编码提交门禁

至少执行：

```bash
./gradlew test
./gradlew build
```

涉及 Flyway 时必须在空库和已有开发库分别验证迁移；涉及 Provider、OSS、阿里审核和支付时必须使用受控测试环境完成真实联调。

## 22. 开发顺序

| 顺序 | Java 后端工作 | 对外结果 |
|------|---------------|----------|
| 1 | 注册 catseller、数据隔离、商品图、形象和草稿作品 | 首图可创建草稿 |
| 2 | 首页案例、AI 帮写、作品聚合、脚本和镜头 | 填写和脚本链路可联调 |
| 3 | 分镜图片、任务进度和失败恢复 | 可进入编辑脚本并看到图片 |
| 4 | 视频 Provider、报价、积分和审核 | 可提交视频并得到成功/失败结果 |
| 5 | 生命周期、后台管理和公共业务复用 | 完整业务与后台可用 |
| 6 | 接口冻结、自动化测试和问题修复 | 支持全量回归和内部验收 |

## 23. 编码前门禁

- [ ] `catseller` schema、App 标签和后台权限命名已确认。
- [ ] 文本模型、图片模型和视频模型测试账号及额度可用。
- [ ] 视频 Provider 已验证多镜头图片、横竖屏、时长和音频输出。
- [ ] 脚本 JSON Schema v1 已评审并与 Flutter 模型一致。
- [ ] 公共资源模块支持本项目图片和视频规格。
- [ ] 阿里审核场景、超时和不可用策略已确认。
- [ ] 每张分镜图片积分单价与失败策略可从后台配置。
- [ ] 7 天隐藏/30 天删除对数据库和 OSS 的处理边界已确认。

## 24. 下一步

本文件评审通过后，生成 `java-dev-plan.md`，再按数据隔离、作品、脚本分镜、视频、积分审核、后台和测试拆分开发文档。实际编码前重新检查 Java 工程状态及其 `AGENTS.md`，加载 Java 编码规则后开工。

## 25. 路径恢复补充实现轨迹

2026-07-31 恢复的 catseller 外部接口与配置兜底技术轨迹位于 `recovered-engineering-track-20260731/java-tech.md`。CHG-0027 保留 `in_progress` 但已 defer，必须等 CHG-0020 新计费合同同步后重新核对并继续。

## 26. 智能视频时长技术增量

- `catseller_work_inputs` 保存不可歧义的 `duration_mode`：`FIXED` 必须有固定秒数，`AUTO` 必须没有请求秒数；历史输入按 `FIXED` 兼容。
- AUTO 脚本提示词要求模型返回 5～60 秒整数，并限制口播字数不超过最终秒数乘以 3.2；缺失、越界、小数或超长口播均按 Provider 输出错误失败，不做默认值或截断。
- `GENERATE_SCRIPT` 将最终秒数写入步骤结果和脚本版本；`GENERATE_STORYBOARD` 从脚本结果读取同一秒数，不能继续使用原始输入。
- 视频报价从当前脚本版本读取最终秒数，并把模式、请求秒数和最终秒数纳入快照；计费、视频快照和 Provider 始终使用具体最终秒数。
- 工作流编码、状态、计费步骤、审核和发布流程均不变。
- 开发阶段直接修订尚未发布的 `V3.6__catseller_video_remake_and_analysis_cache.sql`，不新增迁移版本。
## CHG-0044：填写信息更新与详情编辑分流

`PATCH /api/catseller/works/{workId}/input` 增加 `updateMode`：

- `INPUT_EDIT`：默认值，兼容旧客户端；沿用修改填写信息并重置为 `DRAFT / PREPARE_RESOURCES` 的既有行为。
- `DETAIL_EDIT`：只接收可选 `title` 或非空 `shots`，禁止混入商品图、卖点、比例、时长、清晰度、形象等填写页字段。

`DETAIL_EDIT` 在作品写锁和同一事务内完成归属、完成状态、无活动任务、当前活动脚本、镜头归属和 `expectedVersion` 校验。标题同步作品与当前脚本版本；分镜只更新画面描述和口播，随后重算当前脚本快照及内容哈希。多分镜任一冲突时整体回滚。

该模式只递增变更实体的数据版本并更新 `updatedAt`，明确不修改作品状态、根任务阶段/进度/失败信息、当前脚本指针、当前或已发布视频、`lastUsedAt`。无需数据库迁移，现有确认脚本接口及其进入 `EDITING` 的行为保持不变。
