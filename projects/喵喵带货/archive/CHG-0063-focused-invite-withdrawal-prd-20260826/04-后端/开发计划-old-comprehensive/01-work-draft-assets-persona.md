# Java 模块开发文档：草稿、商品资源与带货形象

> 版本：`v1.0`｜状态：已完成｜任务：`T-B003 商品图片与带货形象`、`T-B005 作品与五个状态`

## 1. 功能定位与边界

实现商品首图幂等建草稿、输入保存、作品列表/聚合详情、删除，以及带货形象上传、定制任务、重命名和删除影响。作品是所有脚本、图片、视频任务的聚合根；本模块不生成脚本或视频。

## 2. Controller / Service / Repository / Entity

| 分层 | 计划类 |
|------|--------|
| Controller | `CatsellerWorkController`、`CatsellerPersonaController`、`CatsellerPersonaTaskController` |
| Service | `CatsellerWorkService`、`CatsellerWorkQueryService`、`CatsellerPersonaService`、`CatsellerPersonaTaskService`、`CatsellerWorkActionService` |
| Workflow | `SellerPersonaWorkflowStep`，使用通用 SellerWorkflow 执行骨架 |
| Repository/Mapper | Works、Inputs、Assets、Personas、GenerationTasks 对应 Repository/Mapper |
| Entity/VO | `CatsellerWorkEntity`、`WorkInputEntity`、`WorkAssetEntity`、`PersonaEntity`、`GenerationTaskEntity`；WorkSummary/Detail、PersonaItem、TaskProgress |

## 3. 接口契约

对应 Flutter：`03-create-and-draft.md`、`04-description-and-persona.md`、`05-works-and-state-routing.md`。

| 方法与路径 | 鉴权 | 请求 | 响应 | 主要错误 |
|------------|------|------|------|----------|
| `POST /api/catseller/works` | 登录+幂等 | 首图 resourceId、图片顺序及初始输入 | workId、`DRAFT`、version、输入摘要 | `ASSET_INVALID_OR_EXPIRED`、`CONTENT_REJECTED`、`IDEMPOTENCY_CONFLICT` |
| `PATCH /api/catseller/works/{workId}/input` | 登录 | 商品图顺序、描述、比例、时长、可空 personaId、version | 最新输入、version、actions | `WORK_NOT_FOUND`、`WORK_STATE_CONFLICT`、`ASSET_INVALID_OR_EXPIRED` |
| `GET /api/catseller/works` | 登录 | cursor、limit | 无筛选作品摘要页 | `AUTH_REQUIRED` |
| `GET /api/catseller/works/{workId}` | 登录 | path workId | 作品聚合详情、输入图片 `sizeBytes`、任务、脚本/镜头摘要、报价/视频、actions、nextPollAfterMs | `WORK_NOT_FOUND`、`RESOURCE_HIDDEN`、`RESOURCE_DELETED` |
| `DELETE /api/catseller/works/{workId}` | 登录+幂等 | workId | 删除结果 | `WORK_RUNNING_LOCKED`、`WORK_STATE_CONFLICT` |
| `GET /api/catseller/personas` | 登录 | cursor/limit | 可用形象及失败形象 | `AUTH_REQUIRED` |
| `POST /api/catseller/personas` | 登录+幂等 | resourceId、授权确认信息 | personaId、识别/审核状态、aiGenerated=false | `ASSET_INVALID_OR_EXPIRED`、`CONTENT_REJECTED` |
| `POST /api/catseller/persona-tasks` | 登录+幂等 | 已确认定制参数、报价/积分凭据（若收费） | taskId、状态、nextPollAfterMs | `POINTS_INSUFFICIENT`、`GENERATION_PROVIDER_BUSY` |
| `GET /api/catseller/persona-tasks/{taskId}` | 登录 | taskId | 任务进度、结果 persona | `WORK_NOT_FOUND`、`GENERATION_FAILED` |
| `PATCH /api/catseller/personas/{personaId}` | 登录 | 名称、version | 最新形象 | `WORK_STATE_CONFLICT` |
| `DELETE /api/catseller/personas/{personaId}` | 登录+幂等 | personaId | 删除或引用影响结果 | `WORK_STATE_CONFLICT` |

所有私有对象按安全上下文 userId 和 `AppContext=catseller` 校验，不接收客户端 userId 作为归属真源。

## 4. 数据表与迁移

- `catseller_works`：状态、当前版本引用、用户、时间、version。
- `catseller_work_inputs`：描述、比例、时长、persona、输入快照、版本。
- `catseller_work_assets`：resourceId、顺序、主图、审核；同作品顺序唯一。
- `catseller_personas`：owner、来源、resourceId、授权、AI 标记、有效期、状态。
- `catseller_generation_tasks`：形象任务；任务类型、状态、幂等键、Provider、错误、租约。
- `catseller_generation_task_steps/events`：`SELLER_PERSONA_V1` 的授权/素材校验、输入审核、生成形象、保存资源、输出审核、保存形象和完成步骤。
- 迁移沿用 foundation 创建的表；若基础迁移未包含必要索引，只新增下一版 Flyway，不修改旧文件。

## 5. 业务规则与状态流转

- 首图必须属于当前用户、审核通过且可用；事务内幂等创建 `DRAFT` 和首个输入版本。
- 重复幂等键+相同摘要返回原作品；相同键不同摘要返回 `IDEMPOTENCY_CONFLICT`。
- 只有 `DRAFT/EDITING/COMPLETED` 按 actions 允许删除；`CONTENT_RUNNING/VIDEO_RUNNING` 禁止。
- 保存输入只允许草稿；开始内容生成后该输入版本不可变。
- 作品列表不筛选，默认按更新时间倒序；详情每次实时组装当前状态。
- 详情的 `draft.taskInput.inputImages[]` 与兼容 `productImages[]` 从资源台账返回 `sizeBytes`；缺失元数据返回 0，不新增表结构或服务端图片总量校验。
- 形象可为空；上传形象保存授权版本/时间/来源。AI 定制结果 `aiGenerated=true`。
- 删除形象前检查作品引用；历史版本可保留稳定引用，新任务不得使用失效形象。
- 定制形象等待 Provider/审核时使用 `PAUSED`；恢复时跳过已经成功的资源保存和审核步骤。

## 6. 异常处理与日志

资源无效、审核拒绝、版本冲突、非法状态和归属不符使用确认错误码；日志仅记录 traceId、workId/personaId、状态和脱敏原因。事务失败不得留下无输入的作品。Provider 回调重复时按 providerTaskId/幂等键返回原结果。

## 7. 依赖前置

依赖数据隔离基础、公共资源台账、阿里审核、AI Provider、积分（定制收费时）和用户安全上下文。内容生成模块依赖本模块的 work/input 真源。

## 8. 建议实现步骤

1. 完成 Entity/Mapper 和资源归属查询。
2. 实现首图建草稿事务与幂等。
3. 实现输入保存、列表、聚合详情和 actions。
4. 实现形象上传、识别/审核、列表、重命名和删除影响。
5. 参考 SongWorkflow 实现定制形象步骤定义、任务创建、Worker、PAUSED 恢复、事件和积分协作。
6. 完成归属、并发、重复请求和状态矩阵测试。

## 9. 详细编码任务清单

| 子任务 | 名称 | 状态 | 退出条件 |
|--------|------|------|----------|
| T-B003-01 | 商品资源归属 | done | 图片审核、顺序和主图约束正确 |
| T-B003-02 | 带货形象 | done | 上传、定制、重命名、删除影响完整 |
| T-B005-01 | 首图建草稿 | done | 幂等事务只创建一个 DRAFT |
| T-B005-02 | 输入与版本 | done | 保存、冲突和不可变版本正确 |
| T-B005-03 | 作品聚合 | done | 列表无筛选，详情/actions/轮询字段完整 |
| T-B005-04 | 删除规则 | done | 运行中拒绝，其余按状态安全清理 |

## 10. 测试要求

- Service：首图幂等、资源归属、版本 CAS、形象引用、非法状态。
- 集成：每个接口正常路径+至少一个错误码；用户 A 不能访问用户 B。
- 契约：Flutter 能按详情状态进入正确页面；未知/隐藏/删除返回稳定语义。
- Mapper：作品列表排序、活动任务/当前版本和形象引用查询。

## 11. 验收标准

- 首图成功后作品立即处于草稿并可从作品页进入填写信息。
- 聚合详情是状态和 actions 真源；运行中无取消/删除。
- 商品图/形象均校验 App、用户、审核和有效期。
- 形象非必填，AI 形象返回来源标记。
- 重复请求、并发保存、跨用户和跨 App 测试通过。

## 12. 编码注意事项

不保存永久 Provider URL；不扫描其他 schema；不把列表摘要当详情；不因形象删除破坏历史作品；不在 Controller 编排事务。

## 13. 实现结果

已完成首图幂等建草稿、填写信息版本控制、作品状态入口、运行锁、用户隔离，以及带货形象上传、生成、修改、删除和复用。

恢复点：前后端联调中的填写信息、作品和带货形象页面。
## CHG-0044 input PATCH 模式分流

| 模式 | 允许字段 | 状态行为 |
|------|----------|----------|
| 缺省 / `INPUT_EDIT` | 原商品图、卖点与视频参数字段 | 维持旧的草稿输入重置行为 |
| `DETAIL_EDIT` | `title`、`shots[].shotId/visualDescription/voiceover/expectedVersion` | 仅完成态且无活动任务可用，作品和任务状态完全不变 |

`DETAIL_EDIT` 必须在作品写锁和事务内校验归属、当前活动脚本、镜头与版本；标题同步脚本标题，分镜更新后统一重算脚本快照与哈希。非法混合字段、非完成态、活动任务、越权和版本冲突均不产生部分写入。无需数据库迁移。

## CHG-0057 作品详情图片大小实现结果

`CatsellerProductImageResponse` 已增加非空 `Long sizeBytes`，用户作品详情从当前 App/用户可读的资源台账装配真实大小，历史缺失或不可读元数据按 0 返回；兼容别名 `productImages` 与 `inputImages` 共用结构。OpenAPI、详情准确值、用户/App 隔离回归及后端强制全量测试通过，无 Flyway 和服务端总量校验变更。
