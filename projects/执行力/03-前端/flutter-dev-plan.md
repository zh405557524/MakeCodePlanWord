# 执行力 Flutter 总体开发计划书

> 版本：v4.1
> 更新时间：2026-06-05
> 关联技术文档：[`flutter-tech.md`](./flutter-tech.md)
> 关联设计真源：Figma `执行力设计稿 / 手机版`
> 规则基线：`.cursor/rules/flutter/01-11`
> 初始化结构参考：`G:\down\baidu\fuyao\translator-flutter`
> 抽象规则参考：`G:\code\soul\Solfeggio\.cursor\rules`
> 文档状态：`approved`
> 编码状态：`waiting_review`

---

## 1. 文档用途

本文件用于把当前项目的 Flutter 开发工作组织成一份可持续执行、可断点恢复、可回写状态的总体开发计划书。

它主要回答这些问题：

- 当前 Flutter 开发到底走到哪一步
- 下一步优先做什么
- 各阶段之间的依赖如何闭合
- 哪些模块已经完成，哪些模块还要联调、对稿和补测试用例
- 编码、联调、测试用例和后续接口接入之间怎么衔接

使用规则：

1. 每次开始或继续 Flutter 工作前，先读本文件，再读当前恢复点对应的模块文档。
2. 编码阶段默认停留在当前步骤内循环修改、调试、验证和回写，不自动推进到下一阶段。
3. 若本文件与 [`flutter-tech.md`](./flutter-tech.md) 或 `figma-design-plan.md` 冲突，先修文档口径再写代码。

---

## 2. 当前状态与恢复点

### 2.1 当前整体状态

当前项目的 Flutter 文档与实现状态如下：

| 项目 | 状态 | 说明 |
|------|------|------|
| Flutter 技术文档 | `done` | 已统一到 `GetX + GetStorage + Hive + Global.init() + go_router + CustomScaffold` |
| 总体开发计划 | `done` | 已同步 v2 ChatHome / TodayFocus 重构恢复点 |
| 模块开发文档 | `done` | `01-13` 模块文档已存在，新增 ChatHome 与 TodayFocus 模块 |
| Flutter 编码 | `waiting_review` | 已完成 v2 `F-024 ~ F-027` 的核心代码实现 |
| 当前重点 | `waiting_review` | 等待评审 ChatHome / TodayFocus 实现，并进入 v2 主链路联调 |

### 2.2 当前恢复点

- 当前恢复点：`F-028 v2 主链路联调`
- 当前恢复点文件：[`10-integration-and-qa.md`](./开发计划/10-integration-and-qa.md)

当前默认动作：

1. 联调 `ChatHome -> TodayFocus -> ChatHome`。
2. 联调 `ChatHome -> ToolMenu -> PlanCreate / NotesEntry`。
3. 联调 `ChatHome -> SideMenu -> 计划库 / 笔记 / 设置`。
4. 对照 Figma `V2-Chat-First` 做 375x812 首屏对稿。
5. 补 v2 测试用例和验收资料。

### 2.3 恢复规则

1. 先看本文件“执行记录”与 `workflow.md` 当前步骤。
2. 优先继续唯一的 `in_progress` 主任务。
3. 若主任务闭合，再进入第一个依赖满足的 `pending` 任务。
4. 若发现 `blocked`，先解除阻塞，再继续当前阶段。

---

## 3. 规则基线与工程口径

本计划书基于新的 Flutter 规则库组织，而不是沿用旧的临时文档口径。

### 3.1 规则来源

编码和计划默认同时遵守以下规则：

- `.cursor/rules/flutter/01-项目初始化规则.mdc`
- `.cursor/rules/flutter/02-项目结构目录.mdc`
- `.cursor/rules/flutter/03-编码规范.mdc`
- `.cursor/rules/flutter/04-导航规则.mdc`
- `.cursor/rules/flutter/05-多语言支持.mdc`
- `.cursor/rules/flutter/06-第三方依赖参考.mdc`
- `.cursor/rules/flutter/07-新功能开发.mdc`
- `.cursor/rules/flutter/08-UI处理任务.mdc`
- `.cursor/rules/flutter/09-大功能先规划再编码.mdc`
- `.cursor/rules/flutter/10-编码工作流程.mdc`
- `.cursor/rules/flutter/11-测试规则.mdc`

### 3.2 当前项目最终技术口径

| 层级 | 当前口径 |
|------|----------|
| 页面组织 | `pages/{feature}/index.dart + controller.dart + view.dart` |
| 路由 | `go_router + RouteName` |
| 状态管理 | `GetX` |
| 轻量配置 | `GetStorage` |
| 结构化数据 | `Hive` |
| 启动入口 | `main.dart + Global.init()` |
| 页面壳 | `CustomScaffold / MainShell` |
| UI 适配 | `flutter_screenutil` |
| 当前数据策略 | 本地优先，远端同步后置 |

### 3.3 与参考工程的关系

- `translator-flutter` 用于约束初始化骨架、目录层次、入口组织与基础依赖风格。
- `Solfeggio` 用于抽象编码规范、导航规则、规划优先和通用工作流思路。
- 当前项目不复制参考工程业务，只继承它们的结构和规则风格。

---

## 4. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 执行中 |
| `waiting_review` | 结果待用户审核 |
| `done` | 已完成 |
| `blocked` | 被信息、依赖或外部条件阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

1. 同一时刻只允许一个主任务处于 `in_progress`。
2. 总计划、`workflow.md`、模块开发文档的状态必须同步回写。
3. 代码阶段若未收到“进入下一步”，默认仍停留在当前步骤。
4. 若需求、Figma 或规则口径变化，先修文档状态，再决定是否调整代码步骤。

---

## 5. 总体开发策略

本项目的 Flutter 开发顺序按“先结构、再主壳、再主链路、再独立业务链路、再联调与测试资料”推进。

### 5.1 结构优先

先把工程结构、入口、路由、服务、存储和页面壳稳定下来，再做业务页面。
没有稳定底座时，不直接大面积铺页面。

### 5.2 主壳优先

先保证 `Splash -> MainShell -> 主导航` 可运行，再进入沉浸式二级页和复杂表单页。

### 5.3 业务链路优先于纯视觉

先让页面“能进、能退、能保存、能回写”，再做逐页 Figma 收口。
尤其是 `PlanEditor`、`Now`、`Notes` 这种带状态流转的页面，不允许只做静态图。

### 5.4 本地优先，接口后接

当前 Flutter 阶段先完成本地可运行闭环：

- 计划、任务实例、聊天草稿、用户资料、笔记内容先本地可用
- 同步态和异常态要在本地能跑通
- 真正接入后端接口属于总体流程后续阶段，但页面必须提前预留服务层与状态边界

### 5.5 测试用例前置

联调与验收前，不只补代码状态，也要补测试人员可执行的测试用例。
Python 自动化脚本只做辅助执行、截图和冒烟，不代替测试用例文档。

### 5.6 v2 对话入口优先

v2 不再把产品做成传统效率 App 的五入口首页，而是先落 `ChatHome` 和 `TodayFocus`：

- `ChatHome` 是唯一一级入口。
- `TodayFocus` 是二级全屏专注页。
- 旧 `Now / Chat / Plan / Notes / Profile` 代码以迁移和复用为主，不作为首屏信息架构继续扩展。
- 编码顺序先重构路由和壳层，再做页面视觉，再做联调状态。

---

## 6. 总体阶段划分与里程碑

> 说明：当前仓库未单独维护 `effort-estimate.md`。以下工时采用计划级估算口径，用于标记工作量和里程碑，不冒充精确排期。

| 阶段 | 名称 | 目标 | 主要模块 | 预估工作量 | 当前状态 | 里程碑 |
|------|------|------|----------|------------|----------|--------|
| A | 工程初始化与运行底座 | 工程可启动，初始化、存储、路由、主题就位 | `main/global/theme/routes/services/store/utils/widgets` | 2-3 人日 | `done` | 工程可稳定启动 |
| B | 应用骨架 | Splash、MainShell、底部导航和一级页容器完成 | `Splash / MainShell / BottomNav` | 1-2 人日 | `done` | 主导航可进入 |
| C | 计划主链路 | Plan、BattleMap、TrackDetail、PlanEditor 本地闭环完成 | `Plan / BattleMap / TrackDetail / PlanEditor` | 4-6 人日 | `done` | 计划链路可保存和回写 |
| D | Notes 独立链路 | Notes 三层页面和本地存储闭环完成 | `Notes / NoteFolder / NoteFile` | 2-3 人日 | `done` | Notes 可独立使用 |
| E | 当前执行链路 | Now 的推荐、反馈和本地状态编排完成 | `Now` | 2-3 人日 | `done` | Now 可承接任务执行 |
| F | 辅助链路 | Chat、Profile、UserProfile 完成 | `Chat / Profile / UserProfile` | 2-3 人日 | `done` | 辅助链路可达可回写 |
| G | v1 联调与状态补齐 | 空状态、异常态、主链路联调完成 | `Now / Chat / Plan / Notes / Profile` | 2-4 人日 | `pending` | v2 重构前暂缓 |
| H | 测试用例与冒烟辅助 | 测试人员用例、冒烟脚本和验收资料就位 | `05-联调与测试/cases`、`scripts/test` | 1-2 人日 | `pending` | 可交付测试执行 |
| I | v2 对话主入口重构 | ChatHome 根入口、TodayFocus 二级页、工具菜单和侧边菜单完成 | `ChatHome / TodayFocus / Shell / Routes` | 3-5 人日 | `done` | v2 首屏像对话 App |
| J | v2 联调与对稿 | v2 主链路、状态反馈、截图和测试资料完成 | `ChatHome / TodayFocus / PlanCreate / NotesEntry` | 2-4 人日 | `pending` | v2 主链路可验收 |

---

## 7. 详细任务清单

| ID | 阶段 | 任务 | 依赖 | 主要输出 | 状态 |
|----|------|------|------|---------|------|
| F-001 | A | 创建工程骨架与目录 | 无 | `apis / components / enums / models / pages / routes / services / store / utils / widgets / global.dart / theme.dart` | `done` |
| F-002 | A | 建立 `main.dart` 与 `Global.init()` | F-001 | 启动入口、依赖注入、初始化链路 | `done` |
| F-003 | A | 接入 `GetStorage` 与轻量配置服务 | F-002 | 安装实例、启动标记、轻量偏好 | `done` |
| F-004 | A | 接入 `Hive` 与核心 box | F-002 | 计划、任务实例、消息、资料、Notes、本地同步状态 | `done` |
| F-005 | A | 建立 `RouteName + router + observers` | F-001 | 路由常量、路由表、观察器、沉浸式二级页入口 | `done` |
| F-006 | A | 建立通用 UI 基础设施 | F-001 | `CustomScaffold / Theme / Button / Dialog / Toast / HeroCard` | `done` |
| F-007 | B | 实现 Splash 页面 | F-002、F-005、F-006 | 品牌启动页、自动跳转 | `done` |
| F-008 | B | 实现 MainShell 与底部导航 | F-005、F-006 | `Now / Plan / Notes / Profile` 主壳与 `Chat` 入口 | `done` |
| F-009 | C | 实现 Plan 页面 | F-004、F-008 | BattleMap Hero、计划卡片、新建入口 | `done` |
| F-010 | C | 实现 BattleMap 页面 | F-009 | 年度 Hero、主线卡片、状态分层 | `done` |
| F-011 | C | 实现 TrackDetail 页面 | F-010 | Hero、阶段时间线、执行数据、AI 建议 | `done` |
| F-012 | C | 实现 PlanEditor 页面 | F-004、F-009 | 新建 / 编辑 / 草稿预填充 / 保存后重建 `task_instances` | `done` |
| F-012A | D | 实现 Notes 数据模型与本地服务 | F-004、F-005 | `NoteFolder / NoteFile` 模型、Hive box、NotesService / NotesStore | `done` |
| F-012B | D | 实现 Notes 与 NoteFolder 页面 | F-008、F-012A | 根目录、子文件夹、创建入口、导航高亮 | `done` |
| F-012C | D | 实现 NoteFile 页面 | F-012A、F-012B | 编辑 / 预览切换、路径展示、正文保存 | `done` |
| F-013 | E | 实现 Now 业务服务 | F-004、F-012 | 推荐、候选切换、反馈写回、本地同步编排 | `done` |
| F-014 | E | 实现 Now 页面 | F-008、F-013 | 建议卡、推荐任务、专注交互、状态入口 | `done` |
| F-015 | F | 实现 Chat 页面 | F-004、F-008、F-012 | 消息流、草稿卡、应用到编辑器 | `done` |
| F-016 | F | 实现 Profile 页面 | F-004、F-008 | Hero、能量模式、AI 模型、资料入口 | `done` |
| F-017 | F | 实现 UserProfile 页面 | F-016 | 头像、昵称、标签、数据卡、固定保存栏 | `done` |
| F-018 | G | 补齐同步态与异常态 | F-014、F-015、F-017、F-012C | `loading / empty / error / disabled / pending_sync / sync_failed / not_found` | `pending` |
| F-019 | G | v1 主链路联调 | F-018 | 旧 `Chat -> PlanEditor -> Plan -> BattleMap -> TrackDetail -> Now` 链路，v2 重构后再决定是否迁移执行 | `pending` |
| F-020 | G | Figma 对照与 UI 修正 | F-019 | 对照 `figma-design-plan.md`、Figma 真源和 `references/images` 逐页收口 | `pending` |
| F-021 | H | 编写测试人员执行的测试用例 | F-019 | `qa-plan.md`、`cases/notes.md`、`cases/plan.md`、`cases/profile.md` | `pending` |
| F-022 | H | 补 Python 冒烟辅助脚本 | F-021 | `scripts/test/*.py`，用于点击、输入、截图和复现标准用例 | `pending` |
| F-023 | H | 整理联调与验收资料 | F-020、F-021 | 截图点、执行记录、遗留风险清单 | `pending` |
| F-024 | I | v2 路由与壳层重构 | F-005、F-008、Figma `V2-Chat-First` | `/` 指向 `ChatHome`，底部 Tab 退出首屏分发，二级页路由补齐 | `done` |
| F-025 | I | 实现 ChatHome 对话主入口 | F-024、F-015 | 空态 / 活跃态、composer、工具菜单、侧边菜单、消息反馈 | `done` |
| F-026 | I | 实现 TodayFocus 全屏专注页 | F-024、F-013、F-014 | 当前任务、开始专注、换一个、稍后、完成反馈返回 ChatHome | `done` |
| F-027 | I | 调整二级入口与迁移旧模块 | F-025、F-026 | PlanCreate、NotesEntry、PlanLibrary、Profile 从 ChatHome 进入 | `done` |
| F-028 | J | v2 主链路联调 | F-025、F-026、F-027 | `ChatHome -> TodayFocus -> ChatHome`、`ChatHome -> ToolMenu -> PlanCreate / NotesEntry` | `pending` |
| F-029 | J | v2 Figma 对稿与截图复核 | F-028 | 375x812 无重叠、无溢出，专注页无干扰 | `pending` |
| F-030 | J | v2 测试用例和验收资料 | F-028、F-029 | `cases/chat-home.md`、`cases/today-focus.md`、截图点和遗留风险 | `pending` |

---

## 8. 业务边界与后端依赖口径

本计划不只列页面，也要明确当前 Flutter 侧的业务边界。

### 8.1 当前本地优先闭环

| 模块 | 当前本地职责 | 后续接口依赖 |
|------|--------------|--------------|
| ChatHome | 展示对话主入口、工具菜单、侧边菜单、执行结果反馈 | 后续接入 AI 会话、历史会话和个性化推荐 |
| TodayFocus | 读取当前推荐任务、执行专注、写回完成 / 推迟 / 放弃 | 后续接入推荐校对与任务反馈同步接口 |
| Plan / BattleMap / TrackDetail | 展示主线、阶段、任务结构和执行视图 | 后续同步计划与轨迹状态 |
| PlanEditor | 创建 / 编辑自定义计划、保存草稿、重建 `task_instances` | 后续接入计划持久化与同步接口 |
| Now | 作为 v1 实现保留，向 TodayFocus 迁移推荐和反馈能力 | 后续不再作为用户可见一级入口扩展 |
| Chat | 作为 v1 实现保留，向 ChatHome 迁移消息、composer 和草稿能力 | 后续不再作为底部导航入口扩展 |
| Profile / UserProfile | 本地展示和修改个人资料、模式、偏好 | 后续接入资料同步接口 |
| Notes | 本地创建文件夹、子文件夹、文件，支持编辑与预览 | 后续接入笔记同步与冲突处理接口 |

### 8.2 当前不在本轮 Flutter 本地编码内闭合的内容

- 真实 API 对接
- 登录态与鉴权体系
- 云端同步冲突解决
- 服务端轮询与消息推送

这些内容属于总体流程中的后续阶段，不在本轮 Flutter 本地闭环里直接落地，但必须保留 `Service / Store / SyncStatus` 的扩展口。

---

## 9. 模块开发文档列表

| 模块编号 | 文档 | 当前状态 | 说明 |
|----------|------|----------|------|
| M-01 | [`01-app-foundation.md`](./开发计划/01-app-foundation.md) | `done` | 工程底座、初始化、全局依赖 |
| M-02 | [`02-splash-shell.md`](./开发计划/02-splash-shell.md) | `done` | Splash、MainShell、底导 |
| M-03 | [`03-plan.md`](./开发计划/03-plan.md) | `done` | Plan 总入口与 BattleMap 入口 |
| M-04 | [`04-battle-map.md`](./开发计划/04-battle-map.md) | `done` | BattleMap 主线结构 |
| M-05 | [`05-track-detail.md`](./开发计划/05-track-detail.md) | `done` | TrackDetail 单页多视觉态 |
| M-06 | [`06-plan-editor.md`](./开发计划/06-plan-editor.md) | `done` | 编辑器、草稿、本地重建 |
| M-07 | [`07-now.md`](./开发计划/07-now.md) | `done` | Now 推荐与执行页 |
| M-08 | [`08-chat.md`](./开发计划/08-chat.md) | `done` | Chat 消息和草稿链路 |
| M-09 | [`09-profile.md`](./开发计划/09-profile.md) | `done` | Profile 与 UserProfile |
| M-10 | [`10-integration-and-qa.md`](./开发计划/10-integration-and-qa.md) | `pending` | 下一步进入 v2 主链路联调、状态补齐、Figma 走查 |
| M-11 | [`11-notes.md`](./开发计划/11-notes.md) | `done` | Notes 三层链路与本地存储 |
| M-12 | [`12-chat-home.md`](./开发计划/12-chat-home.md) | `done` | v2 对话主入口 |
| M-13 | [`13-today-focus.md`](./开发计划/13-today-focus.md) | `done` | v2 全屏专注页 |

---

## 10. 测试用例与验收资料计划

本轮计划按新的 `.cursor/rules/flutter/11-测试规则.mdc` 执行，测试重点放在“测试人员可执行的用例”，不是代码层测试模板。

### 10.1 交付物

- `projects/执行力/05-联调与测试/qa-plan.md`
- `projects/执行力/05-联调与测试/cases/notes.md`
- `projects/执行力/05-联调与测试/cases/plan.md`
- `projects/执行力/05-联调与测试/cases/profile.md`
- `scripts/test/*.py` 或 `tools/test/*.py`

### 10.2 最低覆盖要求

每个核心模块至少覆盖：

1. 一条主流程成功用例
2. 一条异常用例
3. 一条边界或状态用例

当前优先级：

| 模块 | 必须先补的测试用例 |
|------|------------------|
| Notes | 新建文件夹、新建笔记、进入子文件夹、编辑/预览切换、空状态 |
| Plan 链路 | 新建计划、编辑计划、进入 BattleMap、进入 TrackDetail、去 Now |
| Profile 链路 | 进入资料页、修改资料、保存回写、返回主页校验 |
| Chat 链路 | 草稿生成、应用到编辑器、回到 PlanEditor |
| ChatHome 链路 | 首次入口、开启今天计划、工具菜单、侧边菜单、反馈消息 |
| TodayFocus 链路 | 开始专注、换一个、稍后、完成后返回 ChatHome |

### 10.3 Python 辅助执行定位

Python 仅用于：

- 模拟点击、输入、切换和截图
- 固定冒烟步骤复现
- 给测试人员提供标准操作脚本

Python 不用于：

- 替代测试用例文档
- 替代完整人工验收

---

## 11. 编码约束

编码时必须同时遵守：

- [`flutter-tech.md`](./flutter-tech.md)
- `.cursor/rules/flutter/01-项目初始化规则.mdc`
- `.cursor/rules/flutter/02-项目结构目录.mdc`
- `.cursor/rules/flutter/03-编码规范.mdc`
- `.cursor/rules/flutter/04-导航规则.mdc`
- `.cursor/rules/flutter/05-多语言支持.mdc`
- `.cursor/rules/flutter/06-第三方依赖参考.mdc`
- `.cursor/rules/flutter/07-新功能开发.mdc`
- `.cursor/rules/flutter/08-UI处理任务.mdc`
- `.cursor/rules/flutter/09-大功能先规划再编码.mdc`
- `.cursor/rules/flutter/10-编码工作流程.mdc`
- `.cursor/rules/flutter/11-测试规则.mdc`

强约束：

1. 使用 `GetX`。
2. 使用 `GetStorage + Hive`。
3. 不引入 `Riverpod + Drift`。
4. 不使用 `Get.context`。
5. 页面模块默认采用 `index.dart + controller.dart + view.dart`。
6. 目录结构优先对齐新的 Flutter 规则库，不再使用历史零散命名。
7. 没有直接 Figma 上下文时，必须先读 `figma-design-plan.md`，再对照 `references/images`。
8. 当前阶段若未明确进入 Flutter 代码，先停在 v2 文档与计划评审，不继续 v1 `F-018`。

---

## 12. 审核关注点

1. 任务顺序是否真的符合当前工程依赖。
2. `PlanEditor`、`TrackDetail`、`Notes` 是否按“业务闭环优先”组织，而不是只做静态页。
3. 联调阶段是否把空状态、异常态、同步态单独列为任务，而不是混在页面实现里。
4. 测试用例是否已经进入总计划，而不是等 QA 阶段临时补。
5. 新规则库 `01-11` 是否已经被完整纳入计划口径。

---

## 13. 执行记录

| 日期 | 操作 | 结果 | 当前恢复点 | 备注 |
|------|------|------|-----------|------|
| 2026-04-03 | 生成 Flutter 总体开发计划文档 | 完成 | `F-001` | 初版文档 |
| 2026-04-03 | 生成 Flutter 模块开发文档 | 完成 | `F-001` | 已生成 `开发计划/` 下模块文档 |
| 2026-04-04 | 对齐 `Solfeggio` 重写 Flutter 文档体系 | 完成 | `F-001` | 切换至 `GetX + GetStorage + Hive + Global.init()` |
| 2026-04-20 | 按 Figma 设计稿联动重构总文档、开发计划与模块文档 | 完成 | `F-001` | 统一到 Figma 驱动版口径 |
| 2026-05-12 | 同步 Notes 版本文档体系 | 完成 | `F-001` | 新增 Notes 任务、模块文档与联调链路 |
| 2026-05-12 | 回写 DoFlow 当前实现进度 | 完成 | `F-018` | 已完成 A-F 阶段落地，进入联调与状态补齐阶段 |
| 2026-05-14 | 按新的 Flutter 规则库重写总体开发计划书 | 完成 | `F-018` | 统一到 `01-11` 规则口径，补入测试用例与 Python 辅助执行规划 |
| 2026-06-05 | 同步 v2 ChatHome / TodayFocus 开发计划 | 完成 | `F-024` | 暂缓 v1 `F-018`，新增 `F-024 ~ F-030` 和 `M-12 / M-13` |
| 2026-06-05 | 实现 v2 ChatHome / TodayFocus 核心代码 | 完成 | `F-028` | 已完成 `/` 切到 ChatHome、`/today/focus`、`/plan/create`、工具菜单、侧边菜单和专注反馈返回；`flutter analyze`、`flutter test` 通过 |

---

*本文件是 Flutter 编码阶段的总控计划书。后续每次继续 Flutter 工作时，先更新本文件状态，再进入对应模块文档或代码实现。*
