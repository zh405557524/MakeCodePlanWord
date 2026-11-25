# Java 模块开发文档：内容任务、脚本版本与镜头

> 版本：`v1.0`｜状态：已完成｜任务：`T-B006 脚本与镜头`

## 1. 功能定位与边界

创建统一内容任务：先由文本模型生成脚本/镜头，再交由分镜图片模块生成每个镜头图片；完成后进入 `EDITING`。同时提供脚本历史、编辑版本、镜头修改、整体重生成和版本恢复。本模块不实现图片 Provider 细节。

## 2. 类清单

Controller：`CatsellerContentTaskController`、`CatsellerScriptController`、`CatsellerShotController`。Service：ContentTask/ScriptVersion/Shot/WorkState。Workflow：`SellerWorkflowDefinitionProvider`、`SellerWorkflowEngine`、`SellerContentWorkflowStep`。Mapper/Entity：Works、Inputs、ScriptVersions、Shots、GenerationTasks、GenerationTaskSteps。DTO/VO：ContentTaskCreate、ScriptVersionItem、ShotUpdate、TaskProgress。

## 3. 接口契约

对应 Flutter：`06-content-and-script.md`。

| 方法与路径 | 请求 | 响应 | 主要错误 |
|------------|------|------|----------|
| `POST /api/catseller/works/{workId}/content-tasks` | 登录+幂等；使用当前输入 version | taskId、`CONTENT_RUNNING`、进度 | `WORK_STATE_CONFLICT`、`CONTENT_REJECTED`、`IDEMPOTENCY_CONFLICT` |
| `POST /api/catseller/works/{workId}/versions` | 从完成/编辑作品建立新编辑版本 | 新脚本版本/输入版本摘要 | `WORK_RUNNING_LOCKED` |
| `GET /api/catseller/works/{workId}/script-versions` | cursor/limit | 脚本历史摘要、当前标记 | `WORK_NOT_FOUND` |
| `POST /api/catseller/works/{workId}/content-tasks/regenerate` | 幂等；当前输入/重生成确认 | 新 taskId、运行状态 | `POINTS_INSUFFICIENT`、`WORK_STATE_CONFLICT` |
| `POST /api/catseller/works/{workId}/script-versions/{versionId}/restore` | 幂等；目标版本 | 新当前脚本版本和镜头摘要 | `WORK_STATE_CONFLICT` |
| `PATCH /api/catseller/works/{workId}/shots/{shotId}` | 画面、可空口播、version | 最新镜头、version | `SHOT_CONTENT_INCOMPLETE`、`WORK_STATE_CONFLICT` |

所有接口还可能返回 `WORK_NOT_FOUND`、`AUTH_REQUIRED`；所有写操作校验当前用户和 catseller App。

## 4. 数据表与迁移

- `catseller_script_versions`：workId、版本号、schemaVersion、来源、当前标记、结构化脚本。
- `catseller_shots`：scriptVersionId、顺序、画面、可空口播、建议时长、version。
- `catseller_generation_tasks`：`CONTENT` 任务、内部步骤、租约、幂等和错误。
- `catseller_generation_task_steps/events`：参考 SongWorkflow 保存固定步骤实例与脱敏执行事件。
- `catseller_works`：当前脚本版本、状态、失败阶段、resumeState、version。
- 唯一约束：同作品脚本版本号、同脚本镜头顺序、最多一个当前脚本、同阶段一个活动任务。

## 5. 业务规则与状态流转

```text
DRAFT/EDITING → 创建内容任务 → CONTENT_RUNNING
  → 审核输入 → 文本模型生成结构化脚本 → 校验/有限修复
  → 保存脚本版本与镜头 → 调度分镜图片
  → 全部可用或允许局部失败恢复 → EDITING
  → 不可恢复失败 → FAILED(failedStage=CONTENT, resumeState=DRAFT/EDITING)
```

- 文本输出必须符合已确认 Schema：标题/镜头顺序、画面、可空口播、建议时长；总时长与目标配置一致。
- 任务开始后不可取消/删除/编辑输入。
- 编辑镜头只在 `EDITING`；画面必填，口播可空；乐观锁 CAS。
- 历史恢复不覆盖旧记录，而是新建当前版本。
- 整体重生成创建新任务；旧成功脚本和视频保持可查。
- `SELLER_CONTENT_V1` 按固定步骤推进；创建时初始化全部步骤，恢复时跳过已成功/已跳过步骤，等待图片子任务时标记 `PAUSED`。

## 6. 异常与日志

JSON Schema 失败执行有限修复，超过上限进入稳定失败；不把原始 Prompt/模型响应完整写日志。状态 CAS 失败返回冲突并由客户端刷新。任务异常保留已成功脚本/镜头。

## 7. 依赖前置

依赖作品草稿、审核、文本模型配置、任务执行器；分镜图片模块消费已保存镜头。视频模块只读取已确认当前版本。

## 8. 建议实现步骤

1. 建立脚本/镜头 Entity、Mapper、唯一约束。
2. 参考 `SongGenerationService` 实现内容任务幂等创建、请求快照、步骤初始化和快速返回。
3. 参考 `SongWorkflowEngine` 实现内容步骤定义、状态 CAS、事件记录和暂停等待。
4. 实现模型输出 Schema 校验、保存和分镜调度。
5. 实现镜头编辑、版本历史和恢复。
6. 实现整体重生成、失败状态和任务恢复。

## 9. 编码任务

| 子任务 | 名称 | 状态 | 退出条件 |
|--------|------|------|----------|
| T-B006-01 | 内容任务 | done | 单一主任务正确编排脚本和图片 |
| T-B006-02 | 脚本 Schema | done | 非法输出可控修复或失败 |
| T-B006-03 | 镜头编辑 | done | 画面必填、口播可空、CAS 正确 |
| T-B006-04 | 历史与恢复 | done | 新版本恢复且旧内容不丢 |

## 10. 测试要求

Service：合法/非法状态、Schema 解析、顺序/时长、版本 CAS、历史恢复。集成：每接口正常+错误；重复提交、Worker 重启、部分步骤失败。Mapper：当前版本/唯一顺序/活动任务。Flutter 契约：一个内容生成状态、镜头字段完整。

## 11. 验收标准

内容任务完成后作品进入编辑脚本，聚合详情返回脚本、镜头和进度；运行中不可取消；画面必填口播可空；历史和重生成不会覆盖旧成功版本。

## 12. 编码注意事项

不在 Controller 调模型；不将脚本和分镜拆成两个作品主状态；不建立独立配音任务；不把 Redis 作为任务真源；不直接引用 catsinger 的 SongWorkflow 枚举、Entity 或表。

## 13. 实现结果

已完成独立内容工作流、固定步骤、脚本 JSON 校验、脚本/镜头落库、编辑版本、历史恢复和镜头乐观锁；内容任务统一生成脚本与分镜图片。

恢复点：前后端联调中的内容生成和确认脚本页面。
