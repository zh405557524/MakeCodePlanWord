# AI 音乐内容自动生产工具技术方案

> 版本：v0.5.0
> 日期：2026-07-20
> 关联 PRD：`../01-需求/requirements.md`

## 1. 系统架构

```text
Codex-1 榜单采集
        │
        ▼
Codex-2 标签规划 → Codex-3 榜单分组 → Codex-4 原创歌曲方案
        │
        ▼
严格 ProductionPlanDocument
        │
        ▼
Python CLI / Pydantic Validator / PostgreSQL
        │
        ├── 标签与显式列表预检 ──→ Catsinger Admin API
        │
        ├── 短调度 Tick ─────────→ Catsinger 生成 API → 音乐 Provider
        │
        └── 整批审核后绑定 ───────→ Catsinger Admin API
                                          │
                                          └── 全部绑定后启用新标签
```

| 层级 | 技术 | 说明 |
|---|---|---|
| 内容准备 | Codex 对话 | 人工发起的采集、标签规划、分组和原创方案，不是生产服务 |
| Runtime | Python 3.11 | 独立工程，不进入 Flutter、Admin、Java 或 AI 推理服务 |
| 输入校验 | Pydantic 2 | 严格采集包和 `ProductionPlanDocument` Schema |
| 数据模型 | SQLAlchemy 2 + Alembic | PostgreSQL 生产事实源，SQLite 测试 |
| 队列 | Celery + Redis | 只唤醒短 tick，不保存事实状态 |
| HTTP | httpx | Catsinger 标签、列表、生成、查询和首页条目现有接口 |
| CLI | argparse + JSON | 方案导入、批次控制、诊断、恢复和审核 |
| 测试 | pytest + MockTransport | 门禁、并发、恢复、幂等和禁止接口断言 |

运行时不集成 OpenAI SDK，不读取 `OPENAI_API_KEY`。Codex 产物通过文件导入，生产进程无需调用 Codex 或 OpenAI API。

## 2. 输入与 Codex 1–4 契约

### 2.1 Codex-1：CollectionBatch

每次采集输出 `collection.md`、`collection.json`、`manifest.json`。导入时校验 Schema、哈希和版权字段，只保存公开榜单事实；不创建分析、方案、标签或生产任务。

### 2.2 Codex-2：首页标签计划

Codex 先在 `profiles/{profileId}/tag-profile.json` 中输出业务标签分析，再将可执行标签白名单写入 `ProductionPlanDocument.businessTags`：

| 字段 | 作用 |
|---|---|
| `tagCode` | 稳定首页模块编码，后续所有绑定的唯一业务键 |
| `tagName` | 计划展示名称；存量启用标签名称不同时记录警告并保留后台名称 |
| `sortOrder` | 新标签创建时的排序建议 |

样本、平台分布、聚合内容标签、生产方向与配额保留在 `tag-profile.json`；生产方案的 `businessTags` 只保留 `tagCode/tagName/sortOrder`。

### 2.3 Codex-3：榜单分组

分组保存 `groupCode/label/styleTags/tagCodes/sourceEntries`。每个来源引用由 `{collectionId, platform, chartType, chartDate, rank}` 唯一定位，供覆盖率、配额和版权审计使用。生成请求组装器只读取歌曲方案白名单字段，明确丢弃分组引用、歌曲名、歌手和来源地址。

### 2.4 Codex-4：歌曲计划

Codex 为每首歌曲输出稳定 `planSongId`、`sequence`、`sourceGroupCode`、标题、描述、原创 prompt、内容参数、`styleTags` 和 `tagCodes`。Python 不再使用 `autoFromAnalysis` 为真实 Catsinger 批次临时合成歌曲方案；真实启动必须绑定已导入的 `ProductionPlanDocument`。

## 3. ProductionPlanDocument Schema

### 3.1 顶层模型

| 字段 | 类型 | 约束 |
|---|---|---|
| `schemaVersion` | string | 支持 `1.x` Schema；当前产物使用 `1.0` |
| `planId` | string | 全局稳定；相同 ID 不允许内容变化 |
| `createdAt` | datetime | 带时区 |
| `sourceCollectionIds` | string[] | 非空、唯一且全部已导入 |
| `businessTags` | object[] | `tagCode` 唯一，字段为 `tagCode/tagName/sortOrder` |
| `sourceGroups` | object[] | `groupCode` 唯一，来源引用只能指向已声明采集包 |
| `songs` | object[] | `planSongId` 唯一，数量即生产任务数量 |
| `execution` | object | Provider、Model、并发、轮询、提交间隔、重试、超时和发布模式 |
| `copyrightGuard` | object | 五项原创与禁止复制声明必须全部为真 |

### 3.2 PlannedSong 白名单

允许持久化和传递给生产层的字段为：

- `planSongId`、`sequence`、`sourceGroupCode`、原创 `title`、`description`、`prompt`。
- `language`、`vocal`、`instrumental`、`durationSeconds`。
- `styleTags`、`tagCodes`。
- `theme`、`instruments`、`bpm`、`structure`。

歌曲不携带 `sourceEntries`；它只通过 `sourceGroupCode` 指向审计分组。提交 Java 时不会读取 `sourceGroups`。

严格禁止：完整歌词、参考音频、媒体下载 URL、旋律、指纹、榜单歌曲或歌手模仿要求，以及 `homeList/itemCodes/displayCount` 等显式列表字段。

### 3.3 一致性与幂等

1. 每个 `sourceGroups[].sourceEntries` 必须能在 `sourceCollectionIds` 对应的规范化采集包中解析。
2. 每首歌曲至少一个 `tagCode`，且只能引用同文档 `businessTags` 和对应来源分组已声明标签。
3. `styleTags` 必须非空，并与 `tagCodes` 分开校验和保存，禁止相互推导。
4. 生产方案的整数和布尔字段使用 Pydantic 严格类型；`planId`、`planSongId`、`groupCode/sourceGroupCode` 最大 64 字符，与数据库列一致。
5. 标题、描述、Prompt 和生成平台可见的 `styleTags` 都执行采集歌曲名、歌手名与正向模仿扫描。
6. 规范化 JSON 计算 SHA-256；相同哈希幂等返回原记录。
7. 同一 `planId` 不同哈希返回稳定冲突错误。
8. 方案导入是纯本地事务，不调用 Catsinger。

## 4. 数据库设计

| 表/实体 | 职责 |
|---|---|
| `collection_batches` | 不可变采集包、哈希和规范化 JSON |
| `analysis_runs` | 历史聚合趋势；不再直接决定真实生产歌曲 |
| `production_plans` | 不可变方案、Schema 版本、哈希和规范化 JSON |
| `production_batches` | 引用 planId，保存 Provider/Model、并发、标签准备、审核和发布阶段 |
| `generation_jobs` | `planSongId`、单曲状态、attempt、Java/Provider/work/home-item 映射 |
| `job_events` | 只追加的任务状态、错误和 trace 审计 |

标签准备记录、警告、启用进度保存在 `production_batches.tag_preparation_json`，公开首页反查结果保存在 `public_verification_json`；不额外引入标签或批次事件表。

关系为：

```text
CollectionBatch <- ProductionPlan.sourceCollectionIds（JSON 引用并在导入时校验）
ProductionPlanDocument 1:N ProductionBatch
ProductionBatch 1:N GenerationJob
GenerationJob 1:N JobEvent
```

方案 JSON 保持不可变；执行快照保存到批次和任务，后续 Codex 重新生成方案必须使用新 `planId` 和新批次。

## 5. 三层标签数据模型

| 层级 | Python 字段 | Catsinger 字段/接口 | 写入规则 |
|---|---|---|---|
| 歌曲内容标签 | `PlannedSong.styleTags` | `home-item.styleTags`、生成参数 | Codex 明确，Python 原样校验后传递 |
| 首页模块归属 | `PlannedSong.tagCodes` | `home-tag.tagCode`、`home-item.tagCodes` | 仅使用 `businessTags` 中的编码 |
| 显式首页列表 | 无写模型 | `home-list.itemCodes/displayCount` | 只读预检；禁止 PUT |

`styleTags` 不会创建标签，`tagCodes` 不会自动改变显式列表。`ProductionPlanDocument` 出现任何显式列表写入字段时，在导入阶段直接拒绝。

## 6. 标签准备算法

标签准备必须在第一个真实生成请求前完成，并对一个批次加行锁串行执行。

### 6.1 阶段 A：全量只读预检

1. 从方案提取去重后的全部目标 `tagCodes`。
2. 调用 `GET /api/admin/song/home-tags` 和 `GET /api/admin/song/home-lists` 获取同一 `X-App-Code` 下的事实快照。
3. 对已存在且启用的标签按 `tagCode` 复用；`tagName` 不同只记录 `HOME_TAG_NAME_REUSED` 警告并保留后台名称。
4. 已存在但禁用、且不是本批次先前创建的标签标记 `EXISTING_TAG_DISABLED`，禁止擅自接管。
5. 对应首页列表 `persisted=true` 时标记 `EXPLICIT_HOME_LIST_PRESENT`。
6. 只要出现重复编码、预先禁用标签或显式列表，准备失败；批次保留 `READY` 并在 `tag_preparation_json.error` 记录原因，不调用生成接口。

### 6.2 阶段 B：缺失标签禁用创建

1. 阶段 A 全部通过后，按稳定 `tagCode` 创建缺失标签，固定 `enabled=false`，名称和排序来自 `businessTags`。
2. 调用前先保存 `createdByBatch=true/createPending=true` 的创建意图，响应后补齐 Admin 标签 ID；即使远端成功后进程立即退出，重启也能按本批次事实认领并核对该禁用标签。
3. 超时或结果不确定时，重试先重新查询 `tagCode`；事实已存在且字段一致则恢复成功，不重复 POST。
4. 若创建过程中另一方创建了同编码但字段不一致，批次进入人工处理，新标签不得自动启用。
5. 全部目标标签为“既有启用可复用”或“本批次创建且禁用”后，批次才能进入 `TAGS_READY`。

### 6.3 续跑与核对

重复执行 `prepare` 时根据 `tag_preparation_json` 与 Admin 事实核对：本批次创建的标签必须仍存在并保持禁用，直到绑定完成；已准备步骤不会重复创建。`resume`、`reconcile`、调度 tick 和槽位认领均检查 `tags_prepared_at`，不能绕过准备门禁。当前 `reconcile` 不重新执行运行中标签漂移预检；若未来要求运行期持续监听运营改动，需另行扩展。

## 7. 调度与整批生成门禁

### 7.1 滑动窗口

调度 tick 按以下顺序运行：释放到期重试、恢复不确定提交、轮询在途任务、执行单曲质量检查、聚合整批门禁、数据库锁内计算槽位、提交新任务。

- 锁定 `production_batches` 后计算 Provider + Model 的全局空闲槽位。
- 活动槽位包括 `SUBMITTING` 和 `GENERATING`。
- 待领取任务使用 `FOR UPDATE SKIP LOCKED`。
- 外部 HTTP 不在槽位预留事务内执行；预留后状态先变为 `SUBMITTING`。
- 创建超时保留 attempt，在后续 tick 使用同一幂等键恢复。
- `tick_all` 对每个批次独立捕获并返回错误；单批标签启用/公开核验失败不会中止后续批次。

### 7.2 单曲状态

```text
PENDING → SUBMITTING → GENERATING → GENERATED → QUALITY_CHECKING → READY_TO_PUBLISH
```

异常状态为 `RETRY_WAITING`、`MANUAL_INTERVENTION`、`TERMINAL_FAILED`、`CANCELLED`。单曲不再从完成回调直接进入首页绑定。

### 7.3 批次状态

```text
READY
→ PREPARING_TAGS
→ TAGS_READY
→ RUNNING
→ GENERATION_COMPLETE
→ WAITING_REVIEW
→ BINDING
→ COMPLETED
```

旁路状态包括 `PAUSED`、`PARTIAL_FAILED` 和 `FAILED`。`MANUAL_INTERVENTION`、`TERMINAL_FAILED`、`CANCELLED` 属于单曲状态。

进入 `WAITING_REVIEW` 必须同时满足：

1. 计划中的 `songs[]` 均有且仅有一个本地任务。
2. 所有任务均为 `READY_TO_PUBLISH`。
3. 每首歌曲存在有效 `workId`，并通过元数据/资源质量检查。
4. 没有在途、重试、人工干预、终止失败或取消任务。

任意单曲提前成功只释放并发槽位并补交下一首，不触发首页条目创建。

## 8. 批次审核、条目绑定与标签启用

### 8.1 批次审核

`approve-publish <batchId>` 默认只接受 `WAITING_REVIEW` 批次；`PARTIAL_FAILED` 必须显式增加 `--allow-partial`。命令保存 `publish_approved` 和部分发布标记，歌曲清单、`styleTags` 与 `tagCodes` 继续来自不可变方案；当前 CLI 不额外持久化操作者身份。

若部分发布后对生成阶段失败的歌曲执行重试，调度器清除旧 `publish_approved/allow_partial_publish/generation_completed_at/tags_activated_at/public_verification_json`（AUTO 仅恢复自动批准语义），重新经过整批完成门禁；`REVIEW_REQUIRED` 必须再次审核。只重试同一 `workId` 的首页绑定时不重复审核或生成。

### 8.2 首页歌曲条目绑定

审核通过后才创建首页条目，载荷至少包含：

- 稳定 `itemCode`，当前实现为 `mf-` 加稳定本地 `jobId` 的 24 位无连字符前缀。
- `sourceType=WORK` 和 Java `sourceWorkId`。
- 标题、已生成资源/歌词时间轴等现有字段。
- `styleTags` 原样来自 PlannedSong。
- `tagCodes` 原样来自 PlannedSong，且均已完成标签准备。

绑定前后均可通过现有首页条目查询按稳定 `itemCode` 核对。响应不确定时不生成新编码；已存在且 `sourceWorkId/tagCodes` 一致视为成功，不一致进入人工处理。

部分绑定失败时：

- 已成功条目不回滚。
- 未完成条目保持待绑定，可重试和 `reconcile`。
- 本批次创建的新标签全部继续禁用。
- 批次不得进入完成状态。

### 8.3 全部绑定后启用新标签

仅当所有选定歌曲条目均绑定并核对成功时，在 `BINDING` 阶段继续启用标签并公开反查：

1. 只选择 `createdByBatch=true` 的标签。
2. 调用现有标签更新接口，将 `enabled` 改为 `true`；不修改复用标签的名称、排序、封面或状态。
3. 启用调用使用后台 ID 和保存的期望字段，失败后可按事实状态续跑。
4. Admin 侧确认全部选定歌曲已绑定，并读取同一标签的兼容回退 `itemCodes`；持久化显式列表若在生产期间出现则暂停，绝不覆盖。
5. 查询匿名公开歌曲。由于 Java 会先过滤禁用条目和不可用作品再执行 `displayCount`，公开编码必须是 Admin 回退顺序的有序有效子序列，且至少包含本批一个编码。
6. 公开查询后再次读取 Admin 列表作为最终快照，重新检查本批绑定、相对顺序和 `persisted=false`。本批无可见可用歌曲、相对顺序异常或期间切换为显式列表时，持久化可操作错误并暂停。
6. 核验失败把 expected/actual/error 写入 `public_verification_json`；确定性顺序或容量问题自动 `PAUSED`，运营修复后 `resume` 只重新核验，不重复生成或绑定。全部确认后批次才变为 `COMPLETED`。

## 9. 显式首页列表保护

Python 对显式列表只有一个用途：真实生成前检测阻断。

- 允许：`GET /api/admin/song/home-lists`，读取 `tagCode` 和 `persisted` 状态。
- 禁止：任何 `PUT /api/admin/song/home-lists/{tagCode}`。
- 禁止：在 Python 内实现 GET → 合并 itemCodes → PUT 的读改写。
- 禁止：方案导入时接受 `itemCodes/displayCount`。
- Python 不提供显式列表写能力；运行期间若运营新增显式列表，当前版本不会覆盖它，正式生产需在启动前完成预检并控制运营变更窗口。

HTTP 适配器应通过能力接口隔离“查询列表”和“修改列表”；Music Factory 后端协议不暴露列表写方法。测试使用 MockTransport 断言完整生产流程没有发出 home-list PUT。

## 10. Catsinger 现有接口契约

| 能力 | 方法与路径 | 使用阶段 | 当前结论 |
|---|---|---|---|
| 运营用户登录 | `POST /api/auth/sms/login` | 进程首次用户请求且无静态 JWT | 私有固定凭证换取 Access/Refresh Token，仅保存在内存 |
| 运营用户续期 | `POST /api/auth/refresh` | 用户请求返回 401 | 优先刷新；失败后重新登录，原请求最多重放一次 |
| 创建音乐 | `POST /api/song-generations` | 标签准备和人工启动后 | 已有用户鉴权和幂等；继续走普通用户积分 |
| 查询音乐 | `GET /api/song-generations/{id}` | 生成轮询/核对 | 映射 status、workId、failureReason |
| 查询标签 | `GET /api/admin/song/home-tags` | 预检、续跑、启用前核对 | 复用现有接口 |
| 创建/更新标签 | `POST/PUT /api/admin/song/home-tags` | 缺失标签禁用创建、全部绑定后启用 | 复用现有接口 |
| 查询列表 | `GET /api/admin/song/home-lists` | 预检/核对 | 只读；persisted 列表阻断 |
| 查询/创建首页条目 | `GET/POST /api/admin/song/home-items` | 批次审核通过后 | 稳定 itemCode 幂等恢复 |
| 覆盖显式列表 | `PUT /api/admin/song/home-lists/{tagCode}` | 不使用 | 明确禁止 |

本轮不修改 Java、Web/Admin、Flutter、Catsinger 数据库、公开接口、用户鉴权、积分、Provider 或 OSS。Python 使用运营账号自动登录/续期后的用户 Token 生成，使用独立 Admin Token 配置标签和首页条目。运营账号冻结时不绕过门禁，保留批次等待后台解冻后续跑。

## 11. 工程模块调整计划

- `schemas.py`：严格 `ProductionPlanDocument`、`BusinessTagDefinition`、`TagSourceGroup`、`PlannedSong` 和来源引用模型。
- `models.py` / Alembic：增加 `production_plans`、批次标签准备/公开反查字段；任务关联 `planSongId`。
- `services/plans.py`：规范化、哈希、版权检查、引用完整性和幂等导入。
- `services/business_tags.py`：标签/列表快照、阻断、禁用创建、最终启用和公开反查。
- `services/production.py`：只从已导入方案创建任务，不为真实批次自动补方案。
- `services/scheduler.py`：整批门禁、审核后绑定和全部绑定后标签启用。
- `backends/base.py`：增加标签查询/准备、列表只读查询、条目查询/创建和标签启用协议；不提供列表写协议。
- `backends/catsinger.py` / `simulated.py`：复用现有接口实现相同状态语义；Catsinger 适配器支持运营用户静态 Token 或私有凭证登录、内存续期和 401 单次重放。
- `cli.py`：增加 `plan-manifest-build`、`plan-import`、`prepare`，扩展 status/inspect/doctor/reconcile/approve-publish 输出。
- `diagnostics.py`：展示 planId、标签准备状态、阻断原因、绑定进度和新标签启用进度。

## 12. 事务、幂等与失败恢复

| 操作 | 幂等键/事实依据 | 不确定结果处理 |
|---|---|---|
| 方案导入 | `planId + normalizedHash` | 相同返回原记录，不同拒绝 |
| 标签创建 | `appCode + tagCode` | 重新查询并校验名称/状态 |
| 音乐创建 | `music-factory:{batchId}:{planSongId}` + attempt 请求键 | 保留 `SUBMITTING` 并复用 attempt |
| 首页条目 | 稳定 `itemCode` | 查询已有条目并校验 workId/tagCodes |
| 标签启用 | Admin 标签 ID + 期望 enabled | 查询事实，已启用视为成功 |

外部 HTTP 调用前后分别提交短事务和事件。Python 退出、机器重启或代码修复后，调度器从 PostgreSQL 当前步骤继续；已经成功的标签、歌曲、条目或启用动作不会重复执行。

## 13. 安全、凭证与日志

- Python 运行不需要 `OPENAI_API_KEY`，配置读取器和 `doctor` 都不得把它列为依赖。
- 所需凭证仅包括 PostgreSQL、Redis、Catsinger 运营用户静态 Bearer Token或私有登录凭证、Admin Token、`X-App-Code` 和 Provider/Model 限制配置。
- 运营用户 Access/Refresh Token 只保存在进程内存；固定凭证只保存在权限受限且不纳入版本控制的 `.env`。账号冻结、续期失败或配置不完整时安全停止。
- 日志包含 planId、collectionId、batchId、jobId、tagCode、providerJobId 和 traceId。
- 不记录 Token、完整歌词、完整 prompt、榜单歌曲/歌手明细或原始大响应。
- Codex 调试只读取脱敏诊断和测试结果；不作为 Celery worker 或运行时回调。

## 14. 测试方案

### 14.1 文档和版权

- ProductionPlanDocument 幂等导入、ID/哈希冲突、未知字段拒绝。
- 无效 collection/source 引用、重复标签/歌曲、跨文档 tagCode 拒绝。
- 字符串数字/布尔、超长数据库 ID、歌词、参考音频、媒体 URL、模仿指令和显式列表字段拒绝。
- 标题、描述、Prompt 和 `styleTags` 的榜单歌曲/歌手隔离。
- Java prompt 组装不包含来源歌曲名、歌手和 `sourceEntries`。

### 14.2 标签准备和列表阻断

- 已有启用标签且无显式列表可复用。
- 缺失标签统一以 disabled 创建，超时后查询恢复且不重复创建。
- 存量启用标签名称差异记录警告；重复编码、预先禁用和 persisted 显式列表均在第一条生成请求前阻断。
- 同一批次创建的禁用标签在续跑时合法，其他禁用标签不可接管。
- 完整流程断言从未调用 home-list PUT。

### 14.3 整批门禁和发布

- 单曲完成不创建首页条目；仍有在途/失败任务时不能审核。
- 全部成功且有 workId 才进入 WAITING_REVIEW。
- 未审核批次不能绑定；审核后按明确 styleTags/tagCodes 创建条目。
- 绑定部分失败可续跑，新标签保持禁用。
- 全部绑定后才启用新标签；复用标签不被修改。
- 兼容回退旧歌与本批新歌按 Admin 顺序组成候选列表；公开结果允许跳过禁用/不可用作品，但必须保持相对顺序且包含本批可用歌曲，否则持久化错误并暂停。公开查询后还要再次阻断期间出现的显式列表。
- 部分发布后重试生成会重新进入整批审核和公开核验；仅绑定重试不重新生成、不重复审核，但必须使旧激活/核验失效并在绑定后重新核验。
- Worker 重启、网络超时和 reconcile 不重复生成、绑定或启用。
- 一个活动批次抛错时，周期调度继续处理其他批次。

### 14.4 回归

- 采集导入、趋势分析、全局并发、暂停、重试和 Catsinger attempt 幂等保持通过。
- CLI/doctor 不要求 `OPENAI_API_KEY`。
- Java、Web/Admin、Flutter 工作区无本变更代码差异。

## 15. 风险与处理

| 风险 | 处理 |
|---|---|
| 现有 Java 创建接口冻结普通积分 | 正式批量启动前确认成本和余额；本轮不绕过、不改 Java |
| 标签创建成功但响应丢失 | 按 appCode + tagCode 查询恢复 |
| 运营在运行期间修改标签或列表 | 当前版本不覆盖运营配置，也不主动监听漂移；生产窗口冻结目标标签/列表，人工发现变化后暂停处理 |
| 单曲成功导致半批提前展示 | 整批审核前不创建 home-item；新标签全部绑定前保持禁用 |
| 已有启用标签绑定时无法实现跨条目原子可见 | 接受现有接口边界；如需原子可见另立 Java 变更 |
| 兼容回退没有本批可见可用歌曲 | 绑定后以最终 Admin 顺序校验公开有效子序列；本批无可见歌曲时暂停并要求运营调整排序、displayCount 或作品可用性，不由 Python 写列表 |
| 显式列表并发覆盖 | 检测到 persisted 列表即阻断，协议不暴露 PUT |
| 误把榜单信息送入生成 prompt/styleTags | 严格白名单组装、生成可见字段扫描和请求级测试 |
| 误认为需要 OpenAI API | 文档、配置、doctor 和测试均明确无 `OPENAI_API_KEY` |
