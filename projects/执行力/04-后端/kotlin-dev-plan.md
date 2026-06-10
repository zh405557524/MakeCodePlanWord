# 执行力 Kotlin 后端开发计划书

> 版本：v1.0
> 更新时间：2026-06-05
> 关联技术文档：[kotlin-tech.md](./kotlin-tech.md)
> 关联总体技术方案：[../02-技术方案/tech-plan.md](../02-技术方案/tech-plan.md)
> 关联需求文档：[../01-需求/requirements.md](../01-需求/requirements.md)
> 文档状态：`waiting_review`
> 编码状态：`pending`

---

## 1. 文档用途

本文件用于把 Kotlin 后端开发工作组织成一份可断点恢复、可验收、可和前端 v2 链路对齐的计划书。

它主要回答：

- 后端从哪里开始编码
- 哪些接口先做，哪些接口后做
- v2 `ChatHome / TodayFocus` 对后端有什么影响
- 后端如何支持本地优先、同步补偿和设备级数据隔离
- 后端测试和联调资料按什么顺序补

本文件是开发计划，不替代 [kotlin-tech.md](./kotlin-tech.md) 的接口和表结构细节。

---

## 2. 当前状态与恢复点

### 2.1 当前整体状态

| 项目 | 状态 | 说明 |
|------|------|------|
| Kotlin 技术文档 | `done` | 已定义 Ktor、Exposed、PostgreSQL、接口、表结构和服务边界 |
| 后端开发计划 | `waiting_review` | 本文件为首次正式补齐 |
| 后端编码 | `pending` | 尚未进入后端工程代码实现 |
| 当前重点 | `waiting_review` | 等待确认是否从 `B-001` 开始后端编码 |

### 2.2 当前恢复点

- 当前恢复点：`B-001 Ktor 工程骨架与运行底座`
- 当前恢复点文件：[kotlin-dev-plan.md](./kotlin-dev-plan.md)

当前默认动作：

1. 确认后端工程目录和构建工具。
2. 建立 Ktor 应用骨架、插件配置、健康检查和统一响应结构。
3. 接入 `X-Installation-Id` 请求上下文。
4. 建立 Flyway、Exposed、PostgreSQL 基础配置。
5. 按模块顺序推进 Profile / Plan / TaskInstance / Chat / Notes / Sync。

---

## 3. v2 信息架构对后端的影响

v2 是前端入口和页面层级重构，不要求后端跟着 UI 页面改 API 名称。

| v2 前端页面 / 能力 | 后端支撑 | 说明 |
|--------------------|----------|------|
| `ChatHome` 首屏 | `GET /api/v1/chat/messages`、`POST /api/v1/chat/messages` | 对话历史、消息写入、草稿生成 |
| `ChatHome` 今日建议 | `GET /api/v1/now` | 可作为当前任务校对和推荐说明来源 |
| `TodayFocus` 当前任务 | `GET /api/v1/now` | 返回推荐任务、候选任务和推荐原因 |
| `TodayFocus` 完成 / 推迟 / 放弃 | `PATCH /api/v1/task-instances/{id}` | 写回执行实例状态 |
| 工具菜单创建计划 | `POST /api/v1/chat/messages`、`POST /api/v1/plans` | 先草稿，后创建正式计划 |
| 工具菜单写笔记 | `POST /api/v1/notes/files` | 创建笔记文件 |
| 侧边菜单计划库 | `GET /api/v1/plans` | 计划列表 |
| 侧边菜单笔记 | `GET /api/v1/notes` | 根目录笔记结构 |
| 侧边菜单设置 | `GET /api/v1/me/profile`、`GET /api/v1/me/settings` | 资料与偏好 |

关键决策：

- 后端接口按领域命名，不按 UI 页面命名。
- `NowService` 可以继续保留命名，前端 UI 层显示为 `TodayFocus`。
- 暂不新增强制性的 `ChatHome` 聚合接口，避免过早绑定 UI。
- 后续如果首屏请求过多，可新增 `GET /api/v1/home/bootstrap` 作为可选聚合接口。

---

## 4. 后端阶段划分

| 阶段 | 名称 | 目标 | 主要模块 | 当前状态 | 里程碑 |
|------|------|------|----------|----------|--------|
| A | 工程底座 | Ktor 可启动，健康检查、序列化、异常、日志就位 | `Application / plugins / response` | `pending` | 服务可本地启动 |
| B | 数据底座 | 安装实例、数据库迁移、Exposed 表定义就位 | `installation / db / tables` | `pending` | 可按设备隔离数据 |
| C | 资料与设置 | 个人资料和偏好读写 | `Profile / Settings` | `pending` | 设置入口可联调 |
| D | 计划主链路 | 计划、阶段、任务、时间线、作战地图 | `Plan / Schedule / Overview` | `pending` | 计划库与详情可联调 |
| E | 执行反馈链路 | 当前任务推荐和任务实例反馈 | `Now / TaskInstance` | `pending` | `TodayFocus` 可联调 |
| F | 对话与草稿 | 消息历史、草稿生成、草稿应用 | `Chat / DraftGenerator` | `pending` | `ChatHome` 可联调 |
| G | Notes 链路 | 文件夹、文件、编辑、删除和同步字段 | `Notes` | `pending` | 笔记入口可联调 |
| H | 同步与幂等 | 版本冲突、重试、软删除、错误码 | `SyncSupport` | `pending` | 弱网补偿可验收 |
| I | 测试与联调 | 单元测试、接口测试、前后端联调脚本 | `test / docs` | `pending` | 可交付联调 |

---

## 5. 详细任务清单

| ID | 阶段 | 任务 | 依赖 | 主要输出 | 状态 |
|----|------|------|------|----------|------|
| B-001 | A | 建立 Ktor 工程骨架 | 无 | `Application.kt`、Gradle、基础目录 | `pending` |
| B-002 | A | 配置插件与统一响应 | B-001 | `Routing / Serialization / StatusPages / Monitoring`、`ApiResponse` | `pending` |
| B-003 | A | 健康检查与基础日志 | B-002 | `GET /health`、请求日志 | `pending` |
| B-004 | B | 接入 installation 上下文 | B-002 | `X-Installation-Id` 校验、设备注册、上下文对象 | `pending` |
| B-005 | B | 配置 PostgreSQL、Flyway、Exposed | B-001 | 数据源、迁移目录、事务工具 | `pending` |
| B-006 | B | 建立核心表迁移与表定义 | B-005 | `device_installations / plans / tasks / chat / notes / profile` | `pending` |
| B-007 | C | 实现 Profile / Settings 接口 | B-004、B-006 | `GET/PUT /api/v1/me/profile`、`GET/PUT /api/v1/me/settings` | `pending` |
| B-008 | D | 实现 Plan / Phase / Task CRUD | B-004、B-006 | `GET/POST/PUT/DELETE /api/v1/plans` | `pending` |
| B-009 | D | 实现 Schedule / BattleMap / Timeline 聚合 | B-008 | `/plans/schedule`、`/overview/battle-map`、`/plans/{id}/timeline` | `pending` |
| B-010 | E | 实现 Now 推荐接口 | B-008、B-009 | `GET /api/v1/now`，支撑 `TodayFocus` 当前任务 | `pending` |
| B-011 | E | 实现 TaskInstance 反馈接口 | B-010 | `PATCH /api/v1/task-instances/{id}`，完成 / 推迟 / 放弃 | `pending` |
| B-012 | F | 实现 Chat 消息历史与写入 | B-004、B-006 | `GET/POST /api/v1/chat/messages` | `pending` |
| B-013 | F | 实现 DraftGenerator 与草稿应用 | B-012、B-008 | `POST /api/v1/chat/plan-drafts/apply` | `pending` |
| B-014 | G | 实现 Notes 文件夹和文件接口 | B-004、B-006 | `GET /notes`、`POST folders/files`、`PUT files`、`DELETE notes` | `pending` |
| B-015 | H | 实现同步幂等和版本冲突处理 | B-007、B-008、B-011、B-014 | `SyncSupportService`、`1010` 版本冲突 | `pending` |
| B-016 | I | 编写服务层单元测试 | B-007 ~ B-015 | Plan、Now、Chat、Notes、Sync 测试 | `pending` |
| B-017 | I | 编写接口集成测试 | B-007 ~ B-015 | Ktor test host 覆盖核心 API | `pending` |
| B-018 | I | 整理前后端联调说明 | B-010、B-011、B-012、B-014 | v2 `ChatHome / TodayFocus` 联调清单 | `pending` |

---

## 6. 编码顺序建议

优先顺序：

1. `B-001 ~ B-006`：先把服务跑起来，保证 installation 和数据库可用。
2. `B-007`：Profile / Settings 简单，适合验证请求上下文和读写链路。
3. `B-008 ~ B-009`：Plan 是后续 Now、Chat 草稿和 BattleMap 的数据基础。
4. `B-010 ~ B-011`：补 `TodayFocus` 需要的当前任务和反馈写回。
5. `B-012 ~ B-013`：补 `ChatHome` 需要的消息和草稿。
6. `B-014`：补 Notes 入口和文件接口。
7. `B-015 ~ B-018`：同步、测试、联调资料收口。

不建议一开始就做：

- 登录和鉴权体系。
- 多端冲突合并的复杂策略。
- 真实 LLM 供应商接入。
- UI 页面命名驱动的 API 重命名。

---

## 7. 数据与同步边界

- 所有业务数据必须按 `installation_id` 隔离。
- 所有写接口应尽量支持幂等重放。
- 删除优先采用软删除。
- 版本冲突统一返回 `1010`，并带回服务端当前版本摘要。
- 前端本地成功不等待后端成功；后端需要支持补偿同步。

---

## 8. v2 联调重点

### 8.1 ChatHome

- 首屏拉取最近消息。
- 发送消息后保存历史。
- 草稿生成失败时返回明确错误码，不影响本地消息展示。
- 侧边菜单进入计划库、笔记、设置时对应接口可用。

### 8.2 TodayFocus

- `GET /api/v1/now` 在无任务时返回清晰空状态。
- 当前任务必须包含任务 id、标题、所属计划、预计时长、推荐说明。
- `PATCH /api/v1/task-instances/{id}` 支持 `completed / postponed / dropped`。
- 反馈写回后再次 `GET /api/v1/now` 不应继续推荐已完成任务。

### 8.3 PlanCreate / NotesEntry

- 计划草稿可应用为正式计划。
- 创建计划后可在计划库和 BattleMap 聚合中看到。
- 创建笔记后可在根目录或指定文件夹中看到。

---

## 9. 测试计划

### 9.1 单元测试

- `InstallationService`：缺失 installation、首次注册、更新时间。
- `PlanService`：创建完整计划、更新阶段和任务、软删除。
- `NowService`：无任务、有多个候选、已完成任务过滤。
- `TaskInstanceService`：完成、推迟、放弃、版本冲突。
- `ChatService`：消息保存、草稿结构生成、草稿应用。
- `NotesService`：根目录、子文件夹、文件更新、软删除。
- `SyncSupportService`：幂等重放、版本冲突。

### 9.2 集成测试

- `GET /health`
- `GET/PUT /api/v1/me/profile`
- `POST /api/v1/plans` 后 `GET /api/v1/plans`
- `GET /api/v1/now` 后 `PATCH /api/v1/task-instances/{id}`
- `POST /api/v1/chat/messages` 后 `GET /api/v1/chat/messages`
- `POST /api/v1/chat/plan-drafts/apply`
- `GET /api/v1/notes`、`POST /api/v1/notes/files`、`PUT /api/v1/notes/files/{id}`

### 9.3 联调验收

- `ChatHome -> 发送消息 -> 生成计划草稿`
- `ChatHome -> 开启今天计划 -> TodayFocus -> 完成 -> ChatHome`
- `ChatHome -> 侧边菜单 -> 计划库`
- `ChatHome -> 工具菜单 -> 写笔记 -> NotesEntry`

---

## 10. 风险与处理

| 风险 | 影响 | 处理方式 |
|------|------|----------|
| 前端 v2 首屏需要太多接口 | 首屏慢或联调复杂 | 先复用领域接口，必要时后置新增 `/home/bootstrap` |
| `NowService` 名称和 `TodayFocus` UI 名称不一致 | 文档阅读混淆 | 技术文档明确后端按领域命名，前端按 UI 呈现 |
| 草稿生成依赖真实 LLM | 阻塞 MVP 联调 | 先使用规则生成器或 mock，保持接口结构稳定 |
| 同步冲突策略过早复杂化 | 延迟核心接口交付 | 当前只做版本冲突和幂等，复杂合并后置 |
| Notes 文件夹树删除复杂 | 数据误删 | 优先软删除，并在接口返回中隐藏 deleted 资源 |

---

## 11. 执行记录

| 日期 | 操作 | 结果 | 当前恢复点 | 备注 |
|------|------|------|------------|------|
| 2026-06-05 | 创建 Kotlin 后端开发计划 | 完成 | `B-001` | 首次补齐后端编码任务、v2 联调重点和测试计划 |

---

*本文件是 Kotlin 后端编码阶段的总控计划书。进入后端代码前，应先确认本计划与 `kotlin-tech.md`、`tech-plan.md` 和当前 v2 前端恢复点一致。*
