# Java 模块开发文档：首页、案例与 AI 帮写

> 版本：`v1.0`｜状态：已完成｜任务：`T-B002 首页与案例`、`T-B004 AI 帮写`

## 1. 功能定位与边界

提供游客首页与业务配置、登录后的无筛选案例列表/详情，以及可恢复的 AI 商品描述任务。生成结果不自动覆盖用户描述；“生成同款”本版不创建任务。

## 2. 类清单

Controller：`CatsellerHomeController`、`CatsellerCaseController`、`CatsellerDescriptionTaskController`。Service：Home/Config/Case/DescriptionTask。Workflow：`SellerDescriptionWorkflowStep`。Mapper/Entity：Cases、GenerationTasks、GenerationTaskSteps；复用 AppConfig、Resource、AI 配置公共模块。

## 3. 接口契约

对应 Flutter：`02-home-and-cases.md`、`04-description-and-persona.md`。

| 方法与路径 | 鉴权 | 请求/响应 | 错误 |
|------------|------|-----------|------|
| `GET /api/catseller/home` | 游客 | 返回主入口、营销文案、案例摘要、`workType` 和 AI 标记；不返回私有作品 | 配置异常使用安全降级，不泄露内部错误 |
| `GET /api/catseller/config` | 游客 | 图片限制、比例/时长、功能开关、水印/提示配置版本 | 配置不可用返回明确服务状态 |
| `GET /api/catseller/cases` | 登录 | cursor/limit；返回无筛选、后台排序的案例摘要页 | `AUTH_REQUIRED` |
| `GET /api/catseller/cases/{caseId}` | 登录 | 返回封面、视频短期资源、AI 标记、上下线状态 | `WORK_NOT_FOUND` 或可理解下线状态 |
| `POST /api/catseller/description-tasks` | 登录+幂等 | 商品资源/描述及用户补充字段 | taskId、状态、nextPollAfterMs | `CONTENT_REJECTED`、`GENERATION_PROVIDER_BUSY` |
| `GET /api/catseller/description-tasks/{taskId}` | 登录 | 任务状态、进度、结果、失败原因 | `GENERATION_FAILED` |

## 4. 数据表与迁移

- `catseller_cases`：封面/视频资源、作品类型快照、排序、上下线和 AI 标记。V4.4 增加非空 `work_type`；历史数据优先按来源作品回填，其余按商品视频回填。
- `work_type` 不使用固定枚举 `CHECK`，数据库只保证非空和默认值；合法编码由后端统一校验，新增作品类型无需再变更表结构。
- `catseller_generation_tasks`：`DESCRIPTION` 任务、幂等键、请求摘要、Provider、租约、结果、错误。
- `catseller_generation_task_steps/events`：`SELLER_DESCRIPTION_ASSIST_V1` 的校验/审核输入、生成描述、审核输出、保存候选和完成步骤。
- 首页与业务配置使用公共 `app_configs` catseller 数据，不建专属重复配置表。
- 案例资源引用公共资源记录，返回短期访问数据。

## 5. 业务规则与状态

- 首页和配置允许游客；案例列表/详情登录。
- 首页只返回已上线案例，按后台顺序，限制摘要数量。
- 来源案例创建时以来源作品真实类型为准，忽略前端传入类型；同一来源后续编辑保留快照。手工案例由后台选择类型，旧请求缺字段时兼容为商品视频。
- 案例列表无筛选；下线案例不能新进入，但已有页面获得明确下线状态。
- 描述输入先经阿里文本/图片审核，再创建任务；`PENDING→RUNNING→SUCCEEDED/FAILED`。
- 用户离开不取消任务；同幂等键返回原任务。重生成是新任务并按配置处理积分。
- 结果保存但不写入作品输入，只有 Flutter“使用这段描述”后才 PATCH work input。
- 等待 Provider 或审核时步骤为 `PAUSED`；恢复时只检查结果，不重复生成已经成功的候选。

## 6. 异常与日志

配置缺失不返回密钥或 Prompt；Provider 错误转为稳定业务错误。日志记录 taskId、provider、状态和 traceId，Prompt 只记录摘要。公开首页失败不影响私有数据安全。

## 7. 依赖前置

依赖 foundation、公共 AppConfig、资源、阿里审核、AI Provider 和任务执行器。案例后台由 Java admin 模块提供。

## 8. 建议实现步骤

1. 完成案例 Entity/Mapper/查询。
2. 完成公开首页和配置聚合。
3. 完成案例列表/详情与短期资源。
4. 参考 SongWorkflow 完成描述任务步骤定义、幂等创建、Worker、PAUSED 恢复和事件日志。
5. 完成结果查询、审核、失败和 Provider 降级测试。

## 9. 编码任务

| 任务 | 名称 | 状态 | 退出条件 |
|------|------|------|----------|
| T-B002-01 | 首页与配置 | done | 游客可用且不返回私有数据 |
| T-B002-02 | 案例 | done | 无筛选分页、排序、下线正确 |
| T-B004-01 | 描述任务 | done | 幂等创建、真实进度、结果可恢复 |
| T-B004-02 | 审核与失败 | done | 拒绝、忙碌、失败语义稳定 |

## 10. 测试要求

每个接口正常+错误路径；首页游客/案例未登录；案例上下线、排序、三种类型、来源防伪、历史回填和未知类型拒绝；描述重复提交、审核拒绝、Provider 忙、任务重启恢复；Flutter 契约验证结果不自动写回。

## 11. 验收标准

首页/配置游客可用；案例登录且无筛选；案例统一返回 `workType` 和 `aiGenerated`；描述任务离开重进可恢复；结果不自动覆盖作品；无固定 30 秒 SLA。

## 12. 编码注意事项

不返回后台 Prompt/密钥，不实现生成同款，不在首页返回用户作品，不将 Provider 百分比缺失伪造成假进度。

## 13. 实现结果

已完成游客首页与配置、登录后案例列表/详情、案例作品类型快照，以及不会自动覆盖原描述的 AI 帮写任务和结果查询。

恢复点：前后端联调中的首页、更多案例和 AI 帮写页面。
