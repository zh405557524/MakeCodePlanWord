# 执行力 变更计划

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录二次调整、局部修改或返工计划，控制影响范围，避免小改动触发大面积重写。
> 维护规则：发生变更时创建或更新；变更完成后补充完成记录。

---

## 1. 变更概况

| 字段 | 内容 |
|------|------|
| 变更类型 | `refactor` |
| 变更来源 | `2026-06-05 用户要求先完成 Flutter 代码编写` |
| 变更摘要 | `在 DoFlow 中实现 v2 ChatHome 对话主入口、TodayFocus 全屏专注页、路由切换和专注反馈返回；本步不修改后端代码` |
| 当前状态 | `waiting_review` |

变更类型：

| 类型 | 含义 |
|------|------|
| `small_change` | 局部小改，默认类型，只允许修改影响文件清单内的内容 |
| `refactor` | 局部或模块级重构，必须由用户明确要求 |
| `rewrite` | 大范围重写，必须由用户明确要求 |

---

## 2. 影响文件清单

| 文件 | 影响原因 | 处理方式 |
|------|----------|----------|
| `projects/执行力/workflow.md` | 恢复点需从 Figma 评审切到 v2 Flutter 编码准备 | 修改 |
| `projects/执行力/02-技术方案/tech-plan.md` | 总体技术方案需同步 ChatHome 根入口和 TodayFocus 二级页 | 修改 |
| `projects/执行力/03-前端/flutter-tech.md` | Flutter 路由、页面映射、壳层规则和页面实现规范需同步 v2 | 修改 |
| `projects/执行力/03-前端/flutter-dev-plan.md` | 编码恢复点需从 v1 `F-018` 切到 v2 `F-024` | 修改 |
| `projects/执行力/03-前端/开发计划/01-app-foundation.md` | 需补 v2 路由与根入口变更边界 | 修改 |
| `projects/执行力/03-前端/开发计划/02-splash-shell.md` | 需明确底部 Tab 退出首屏分发 | 修改 |
| `projects/执行力/03-前端/开发计划/03-plan.md` | Plan 需从一级 Tab 入口调整为 ChatHome 派生能力页 | 修改 |
| `projects/执行力/03-前端/开发计划/07-now.md` | 旧 Now 页需标记为 TodayFocus 业务迁移来源 | 修改 |
| `projects/执行力/03-前端/开发计划/08-chat.md` | 旧 Chat 页需标记为 ChatHome 消息与草稿迁移来源 | 修改 |
| `projects/执行力/03-前端/开发计划/09-profile.md` | Profile 需从一级 Tab 入口调整为 SideMenu 入口 | 修改 |
| `projects/执行力/03-前端/开发计划/10-integration-and-qa.md` | 联调计划需切到 v2 主链路 | 修改 |
| `projects/执行力/03-前端/开发计划/11-notes.md` | Notes 需从一级 Tab 入口调整为 ToolMenu / SideMenu 入口 | 修改 |
| `projects/执行力/03-前端/开发计划/12-chat-home.md` | 新增 v2 ChatHome 模块计划 | 新增 |
| `projects/执行力/03-前端/开发计划/13-today-focus.md` | 新增 v2 TodayFocus 模块计划 | 新增 |
| `projects/执行力/04-后端/kotlin-tech.md` | 需补 v2 对后端接口命名、NowService、ChatService 的影响说明 | 修改 |
| `projects/执行力/04-后端/kotlin-dev-plan.md` | 需新增 Kotlin 后端开发恢复点和任务清单 | 新增 |
| `G:\code\soul\DoFlow\lib\routes\name.dart` | 新增 `chatHome / todayFocus / planCreate` 路由名 | 修改 |
| `G:\code\soul\DoFlow\lib\routes\router.dart` | `/` 指向 ChatHome，新增 `/today/focus`、`/plan/create`，二级入口不再走 MainShell | 修改 |
| `G:\code\soul\DoFlow\lib\pages\splash\controller.dart` | Splash 完成后进入 ChatHome | 修改 |
| `G:\code\soul\DoFlow\lib\pages\chat_home\*` | 新增 v2 对话主入口页面 | 新增 |
| `G:\code\soul\DoFlow\lib\pages\today_focus\*` | 新增 v2 全屏专注页 | 新增 |
| `G:\code\soul\DoFlow\lib\services\chat_service.dart` | 增加专注页返回反馈消息写入能力 | 修改 |

---

## 3. 不应改动范围

- 本轮不直接修改 `G:\code\soul\DoFlow` Flutter 业务代码。
- 本轮不直接修改后端工程业务代码。
- 不删除旧 `Now / Chat / MainShell` 文档或代码；它们作为兼容和迁移来源保留。
- 不改后端接口和数据库设计，`/api/v1/now` 可以继续作为当前任务校对接口。
- 不把已经通过的 PRD、产品文档或 Figma v1 旧稿整篇推倒重来。

---

## 4. 分步执行计划

1. 同步 `tech-plan.md`，把总体架构切到 `ChatHome` 根入口和 `TodayFocus` 二级页。
2. 同步 `flutter-tech.md`，明确 v2 路由、页面映射、壳层和禁止事项。
3. 同步 `flutter-dev-plan.md`，新增 `F-024 ~ F-030` 并暂停旧 `F-018`。
4. 新增 `12-chat-home.md`、`13-today-focus.md`，并补旧模块迁移说明。
5. 补充 `kotlin-tech.md` 的 v2 后端影响说明。
6. 新增 `kotlin-dev-plan.md`，写清后端阶段、任务、恢复点、测试和联调重点。
7. 在 `G:\code\soul\DoFlow` 实现 `ChatHome / TodayFocus` 核心 Flutter 代码。
8. 运行 `flutter analyze` 与 `flutter test`。
9. 回写 `workflow.md`，将下一步默认动作切到 `F-028 v2 主链路联调`。

---

## 5. 验收标准

- 技术方案、Flutter 技术文档和开发计划都明确 `ChatHome` 是唯一一级入口。
- `TodayFocus` 被定义为二级全屏专注页，不显示 composer、底部 Tab、侧边菜单或任务列表。
- 旧 `Now / Chat` 只作为迁移来源，不再驱动 v2 首屏。
- 后端计划明确不按 UI 页面改 API 名称，继续以领域接口支撑 `ChatHome / TodayFocus`。
- `workflow.md` 的恢复点切到 `F-024 v2 路由与壳层重构`。
- `workflow.md` 记录后端恢复点 `B-001 Ktor 工程骨架与运行底座`。
- `flutter analyze` 与 `flutter test` 通过。
- 本轮不改后端业务代码，后端仍等待 `B-001`。

---

## 6. 完成记录

| 时间 | 操作 | 修改文件 | 结果 |
|------|------|----------|------|
| 2026-05-12 | 创建 Notes 变更计划 | `projects/执行力/change-plan.md` | 已建立本轮变更登记，当前状态为 `in_progress` |
| 2026-05-12 | 同步 Notes 文档体系 | `figma-design-plan.md`、`tech-plan.md`、`flutter-tech.md`、`kotlin-tech.md`、`flutter-dev-plan.md`、`开发计划/*.md`、`workflow.md` | 文档侧已统一到 Notes 当前版本口径，可进入 Flutter 编码 |
| 2026-06-05 | 推进 v2 对话主入口设计重构到 Figma | `requirements-list.md`、`requirements.md`、产品文档、`figma-design-plan.md`、Figma `V2-Chat-First` | 已完成 v2 文档口径与 Figma 设计区，等待用户评审 |
| 2026-06-05 | 同步 v2 技术方案与 Flutter 计划 | `tech-plan.md`、`flutter-tech.md`、`flutter-dev-plan.md`、`开发计划/*.md`、`workflow.md` | 已把编码恢复点从 v1 `F-018` 切换到 v2 `F-024` 路由与壳层重构准备，等待确认进入 Flutter 代码 |
| 2026-06-05 | 补充 Kotlin 后端开发计划 | `kotlin-tech.md`、`kotlin-dev-plan.md`、`workflow.md`、`change-plan.md` | 已新增后端 `B-001 ~ B-018` 任务与 v2 联调重点，等待评审 |
| 2026-06-05 | 实现 v2 Flutter 核心代码 | `G:\code\soul\DoFlow\lib\routes\*.dart`、`lib\pages\chat_home\*`、`lib\pages\today_focus\*`、`lib\services\chat_service.dart` | 已完成 `F-024 ~ F-027`，通过 `flutter analyze` 与 `flutter test` |

---

## 7. 2026-06-05 v2 对话主入口重构

### 7.1 变更目标

- `ChatHome` 成为唯一一级入口，打开 App 后直接进入对话主页面。
- `TodayFocus` 成为二级全屏专注页，不显示底部导航、侧边菜单、聊天输入框或任务列表。
- 计划创建、笔记、个人资料与计划库从对话入口、工具菜单或侧边菜单进入。
- 本轮推进到 Figma 正稿与原型连线，不改 `G:\code\soul\DoFlow` Flutter 代码。

### 7.2 本轮影响文件清单

| 文件 / 产物 | 影响原因 | 处理方式 |
|-------------|----------|----------|
| `projects/执行力/change-plan.md` | 登记 v2 信息架构重构范围 | 修改 |
| `projects/执行力/workflow.md` | 暂停 v1 `F-018`，恢复点切到 v2 Figma 设计更新 | 修改 |
| `projects/执行力/01-需求/requirements-list.md` | 需求摘要需记录 v2 主入口与专注页原则 | 修改 |
| `projects/执行力/01-需求/requirements.md` | PRD 需补 v2 信息架构与页面级需求 | 小范围追加 |
| `projects/执行力/01-需求/references/docs/执行力-产品文档-v1.1-2026-03-31.md` | 产品文档需补 v2 路由与页面说明 | 小范围追加 |
| `projects/执行力/01-需求/figma-design-plan.md` | Figma 真源计划需新增 v2 页面清单与验收标准 | 修改 |
| Figma `执行力设计稿 / 手机版` | 新增 `V2-Chat-First` 区域与 7 张 v2 frame | 新增，不覆盖旧稿 |

### 7.3 不应改动范围

- 不改 Flutter 代码，不进入真实 API 接入。
- 不删除或覆盖旧 Figma `01-14` frame。
- 不把旧 PRD 整篇重写为 v2；本轮只追加 v2 决策与设计真源说明。

### 7.4 分步执行计划

1. 回写本文件与 `workflow.md`，将当前工作流切到 v2 Figma 设计重构。
2. 小范围同步需求清单、PRD、产品文档和 Figma 设计计划。
3. 在 Figma 新增 `V2-Chat-First` 区域。
4. 创建 `V2-01-ChatHome-Entry`、`V2-02-ChatHome-Active`、`V2-03-TodayFocus`、`V2-04-ToolMenu`、`V2-05-SideMenu`、`V2-06-PlanCreate`、`V2-07-NotesEntry`。
5. 以 `ChatHome-Entry -> TodayFocus -> ChatHome-Active` 为核心链路补原型关系。

---

## 8. 2026-06-05 v2 技术方案与 Flutter 计划同步

### 8.1 变更目标

- 将 `ChatHome` 写入技术方案和 Flutter 技术文档，作为 App 根路由与唯一一级页面。
- 将 `TodayFocus` 写入技术方案和 Flutter 技术文档，作为二级全屏专注页。
- 暂停 v1 `F-018` 的旧首页状态补齐，把下一轮编码恢复点切到 v2 壳层与路由重构。
- 保留旧 `Now / Chat / Plan / Notes / Profile` 实现作为迁移来源，不在本步删除代码。

### 8.2 本轮影响文件清单

| 文件 / 产物 | 影响原因 | 处理方式 |
|-------------|----------|----------|
| `projects/执行力/02-技术方案/tech-plan.md` | 总体架构需从 5 Tab 调整为 ChatHome 根入口 + TodayFocus 二级页 | 小范围修改 |
| `projects/执行力/03-前端/flutter-tech.md` | Flutter 路由、页面映射、壳层规则和页面规范需同步 v2 | 小范围修改 |
| `projects/执行力/03-前端/flutter-dev-plan.md` | 恢复点需从 v1 `F-018` 切到 v2 `F-024` | 修改 |
| `projects/执行力/03-前端/开发计划/01-app-foundation.md` | 需补 v2 路由和根入口改造边界 | 修改 |
| `projects/执行力/03-前端/开发计划/02-splash-shell.md` | 需明确底部 Tab 退出一级分发，ChatHome 成为根页面 | 修改 |
| `projects/执行力/03-前端/开发计划/07-now.md` | 旧 Now 页需标记为 TodayFocus 的业务迁移来源 | 修改 |
| `projects/执行力/03-前端/开发计划/08-chat.md` | 旧 Chat 页需标记为 ChatHome 的消息与草稿迁移来源 | 修改 |
| `projects/执行力/03-前端/开发计划/10-integration-and-qa.md` | 联调与 QA 需切到 v2 链路 | 修改 |
| `projects/执行力/03-前端/开发计划/12-chat-home.md` | 新增 v2 ChatHome 模块计划 | 新增 |
| `projects/执行力/03-前端/开发计划/13-today-focus.md` | 新增 v2 TodayFocus 模块计划 | 新增 |
| `projects/执行力/workflow.md` | 当前流程恢复点与下一步默认动作需回写 | 修改 |

### 8.3 不应改动范围

- 不直接修改 `G:\code\soul\DoFlow` Flutter 业务代码。
- 不删除旧模块文档；旧 `Now` 和 `Chat` 作为 v2 迁移依据保留。
- 不做后端接口重构；`/api/v1/now` 可继续作为服务端校对接口，前端 UI 名称切到 `TodayFocus`。

### 8.4 分步执行计划

1. 同步总体技术方案中的路由、模块和关键链路。
2. 同步 Flutter 技术文档中的页面映射、壳层、视觉和页面实现规则。
3. 调整 Flutter 总体开发计划，新增 v2 `F-024 ~ F-030` 任务。
4. 新增 `ChatHome`、`TodayFocus` 模块计划，并给旧 `Now / Chat` 文档补迁移说明。
5. 回写 `workflow.md`，将下一步切到 v2 Flutter 编码准备评审。

---

## 9. 2026-06-05 Kotlin 后端开发计划补充

### 9.1 变更目标

- 补齐 Kotlin 后端开发计划，让后端也有可断点恢复的任务清单。
- 明确 v2 `ChatHome / TodayFocus` 对后端的影响：后端按领域接口命名，不按 UI 页面命名。
- 将后端恢复点设为 `B-001 Ktor 工程骨架与运行底座`。
- 本步只写文档，不进入后端代码实现。

### 9.2 本轮影响文件清单

| 文件 / 产物 | 影响原因 | 处理方式 |
|-------------|----------|----------|
| `projects/执行力/04-后端/kotlin-tech.md` | 后端技术文档需补 v2 接口复用和命名说明 | 小范围修改 |
| `projects/执行力/04-后端/kotlin-dev-plan.md` | 新增后端总控开发计划 | 新增 |
| `projects/执行力/change-plan.md` | 登记本轮后端计划补充 | 修改 |
| `projects/执行力/workflow.md` | 回写当前恢复点和下一步默认动作 | 修改 |

### 9.3 不应改动范围

- 不直接修改后端工程代码。
- 不因为前端 UI 改为 `ChatHome / TodayFocus` 就重命名现有 API。
- 不提前引入登录、鉴权、多端冲突合并或真实 LLM 供应商。

### 9.4 分步执行计划

1. 在 `kotlin-tech.md` 补充 v2 对后端的影响说明。
2. 新增 `kotlin-dev-plan.md`，写清 `B-001 ~ B-018` 后端任务。
3. 将 `ChatHome / TodayFocus` 的联调重点写入后端计划。
4. 回写 `workflow.md`，让后端计划成为当前评审恢复点。
