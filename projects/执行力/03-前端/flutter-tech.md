# 执行力 Flutter 前端技术文档

> 版本：v3.1  
> 更新时间：2026-05-12  
> 设计真源：Figma `执行力设计稿 / 手机版`  
> 关联产品文档：`../01-需求/references/docs/执行力-产品文档-v1.1-2026-03-31.md`  
> 关联颜色文档：`../01-需求/references/docs/执行力-颜色文档-v1.1.md`  
> 关联开发计划：[`flutter-dev-plan.md`](./flutter-dev-plan.md)  
> Flutter 版本：3.24+  
> 目标平台：iOS / Android  
> 参考工程：`G:\code\soul\Solfeggio`

---

## 0. 文档定位

本文档是“执行力”Flutter 端的总技术规范，负责回答以下问题：

- 当前 Flutter 实现到底遵循什么技术路线
- Figma 页面分别落到哪些 Flutter 页面、路由和目录
- 哪些视觉规则必须照着设计稿落地
- 页面状态、数据模型、存储边界和跳转关系如何统一
- 哪些实现细节必须前置约束，避免编码阶段自行发挥

本文件不是任务清单。任务拆分、恢复点和阶段推进以 [`flutter-dev-plan.md`](./flutter-dev-plan.md) 为准。

---

## 1. 技术路线结论

### 1.1 当前唯一有效方案

| 层级 | 方案 | 说明 |
|------|------|------|
| 页面组织 | `pages/{feature}/view.dart + controller.dart + index.dart` | 与参考工程统一 |
| 状态管理 | `GetX` | 页面状态归 `GetxController`，全局共享状态归 `GetxService` / Store |
| 路由 | `go_router` | 使用 `RouteName + GoRoute` 收口 |
| 轻量存储 | `GetStorage` | 保存安装实例、轻量设置、启动标记 |
| 结构化数据 | `Hive` | 保存计划、任务实例、聊天消息、用户资料、Notes 数据、同步记录 |
| 启动流程 | `main.dart + Global.init()` | 先初始化，再进入 Splash / MainShell |
| 网络 | `dio` | 统一请求头、错误处理和日志 |
| UI 适配 | `flutter_screenutil` | 以 375 宽设计稿为适配基准 |
| 页面容器 | `CustomScaffold` | 统一安全区、背景、滚动和底部操作承接 |

### 1.2 旧方案废弃说明

以下口径不再作为 Flutter 端实现依据：

- `Riverpod`
- `Drift`
- `Provider-based local DB orchestration`
- 以 `core/db + provider + 自建同步编排` 为核心的新分层

原因不是这些方案不能做，而是当前项目已经明确切换到与 `Solfeggio` 接近的工程组织方式。后续编码应尽量减少二次架构决策。

---

## 2. Figma 页面与路由映射

当前 Figma `手机版` 页面中的 frame 与 Flutter 页面映射如下：

| Figma Frame | Flutter 页面 | 路由 | 底部导航 | 代码目录 |
|-------------|--------------|------|----------|----------|
| `01-SplashScreen` | SplashScreen | `RouteName.splash` | 隐藏 | `pages/splash/` |
| `02-Now` | NowPage | `/` | 显示 | `pages/now/` |
| `03-Chat` | ChatPage | `/chat` | 隐藏 | `pages/chat/` |
| `04-Plan` | PlanPage | `/plan` | 显示 | `pages/plan/` |
| `05-BattleMap` | BattleMapPage | `/plan/battle` | 隐藏 | `pages/battle_map/` |
| `06-TrackDetail-换工作` | TrackDetailPage | `/plan/battle/:trackId` | 隐藏 | `pages/track_detail/` |
| `07-TrackDetail-恋爱` | TrackDetailPage | `/plan/battle/:trackId` | 隐藏 | `pages/track_detail/` |
| `08-PlanEditor-恋爱` | PlanEditorPage | `/plan/editor`、`/plan/editor/:id` | 隐藏 | `pages/plan_editor/` |
| `09-PlanEditor-默认` | PlanEditorPage | `/plan/editor`、`/plan/editor/:id` | 隐藏 | `pages/plan_editor/` |
| `10-Profile` | ProfilePage | `/profile` | 显示 | `pages/profile/` |
| `11-UserProfile` | UserProfilePage | `/profile/me` | 隐藏 | `pages/user_profile/` |
| `12-Notes` | NotesPage | `/notes` | 显示 | `pages/notes/` |
| `13-NoteFolder` | NoteFolderPage | `/notes/folder/:id` | 显示 | `pages/note_folder/` |
| `14-NoteFile` | NoteFilePage | `/notes/file/:id` | 隐藏 | `pages/note_file/` |

落地规则：

- `TrackDetail` 只有一个页面骨架，`换工作 / 恋爱` 是由 `trackId` 驱动的不同视觉态和文案态，不拆分成两个页面目录。
- `PlanEditor` 只有一个编辑器页面，`默认 / 恋爱` 是两套表单视觉态和 CTA 颜色，不拆分成两个页面目录。
- `MainShell` 只承接 `Now / Plan / Notes / Profile` 四个主壳页和入口式 `Chat` Tab；真正进入 `ChatPage` 后使用沉浸式全屏页面，不复用底部导航。
- `UserProfile`、`BattleMap`、`TrackDetail`、`PlanEditor` 都按沉浸式二级页处理。
- `NoteFile` 按沉浸式二级页处理；`NoteFolder` 仍保留主导航高亮 `Notes`。

### 2.1 路由约束

文档统一以这些公开路由为准：

- `/`
- `/chat`
- `/plan`
- `/notes`
- `/plan/battle`
- `/plan/battle/:trackId`
- `/plan/editor`
- `/plan/editor/:id`
- `/profile`
- `/profile/me`
- `/notes/folder/:id`
- `/notes/file/:id`

建议的 `RouteName` 收口方式：

- `RouteName.splash`
- `RouteName.now`
- `RouteName.chat`
- `RouteName.plan`
- `RouteName.notes`
- `RouteName.battleMap`
- `RouteName.trackDetail`
- `RouteName.planEditorCreate`
- `RouteName.planEditorEdit`
- `RouteName.profile`
- `RouteName.userProfile`
- `RouteName.noteFolder`
- `RouteName.noteFile`

---

## 3. 视觉令牌与 UI 基础规范

### 3.1 页面级背景与主色

| 场景 | 颜色 / 渐变 | 说明 |
|------|-------------|------|
| 通用浅色页 | `#f5f4ff` | Plan、Profile、UserProfile、编辑器基础底色 |
| Now 页背景 | `linear-gradient(180deg,#eeecff 0%,#f5f4ff 60%,#f9f8ff 100%)` | 整页背景 |
| Chat 页背景 | `linear-gradient(160deg,#1a1740,#2d2a6e,#4c1d95)` | 沉浸式深色页 |
| Splash 背景 | `linear-gradient(160deg,#0f0d2e,#1a1740,#2d2a6e,#3730a3)` | 全屏品牌页 |
| 品牌主色 | `#6366f1` | 主按钮、激活态、进度条起点 |
| 品牌辅色 | `#8b5cf6` | 品牌渐变终点、次级强调 |
| 成功色 | `#10b981` | 完成态、active 徽章 |
| 警告色 | `#f59e0b` | 进行中、循环任务等强调 |
| 危险色 | `#ef4444` | blocked、危险确认 |

### 3.2 主线专属渐变

BattleMap、TrackDetail、PlanEditor 的主题色需跟随主线，不允许全局混用：

| 主线 | 渐变 |
|------|------|
| 换工作 | `linear-gradient(135deg,#6366f1,#8b5cf6)` |
| 作品集 | `linear-gradient(135deg,#f59e0b,#ef4444)` |
| 买房 | `linear-gradient(135deg,#10b981,#06b6d4)` |
| 恋爱 | `linear-gradient(135deg,#ec4899,#f43f5e)` |
| 状态管理 | `linear-gradient(135deg,#3b82f6,#06b6d4)` |

### 3.3 圆角、阴影、动效

| 规则 | 数值 |
|------|------|
| 按钮 / tag | `8px - 12px` |
| 白卡 / 小卡 | `16px - 20px` |
| Hero / 大卡 | `20px - 28px` |
| 白卡阴影 | `0 2px 10px rgba(0,0,0,0.05)` |
| 品牌卡阴影 | `0 8px 24px rgba(49,46,129,0.3)` |
| 页面入场 | `opacity 0→1, y 16→0, duration 0.3s` |
| 列表错位入场 | `stagger 0.07s` |
| 按压反馈 | `scale 0.92-0.97` |

### 3.4 底部导航与页面壳

- `Now / Chat / Plan / Notes / Profile` 是五个一级导航入口。
- 仅 `Now / Plan / Notes / Profile` 作为主壳页固定在 `MainPage` 中。
- `Chat` 由主壳的入口按钮进入全屏页，进入后隐藏底部导航。
- 二级页一律使用独立 `CustomScaffold`，不要把它们塞进 `IndexedStack`。
- 通用页面骨架优先抽为：
  - `AppScaffold`
  - `BottomNavShell`
  - `GradientHeroCard`
  - `SectionCard`
  - `MetricCard`
  - `TimelineCard`
  - `PrimaryBottomBar`

---

## 4. 数据模型与存储边界

### 4.1 公开模型

Flutter 端直接沿用产品文档里的领域模型，不在总技术文档中重新发明同义模型：

- `Task`
- `ChatMessage`
- `AppState`
- `NoteFolder`
- `NoteFile`
- `CustomTask`
- `CustomPhase`
- `CustomPlan`
- `UserProfileData`
- `Track`
- `Phase`
- `DailyTask`

### 4.2 存储边界

| 数据 | 存储方式 | 说明 |
|------|----------|------|
| `installation_id` | `GetStorage` | 首次启动生成并长期保存 |
| `now_initialized` | `GetStorage` | 启动引导与初始化标记 |
| 能量 / 模式 / AI 模型 | `GetStorage + ConfigStore` | 轻量配置 |
| 计划、阶段、任务 | `Hive + PlanStore` | 结构化业务数据 |
| `task_instances` | `Hive` | 由 `PlanEditor` 保存链路统一重建 |
| 聊天消息 / 草稿 | `Hive + DraftStore` | Chat 与 PlanEditor 共享 |
| 笔记文件夹 | `Hive + NotesStore` | `NoteFolder` 结构树 |
| 笔记文件 | `Hive + NotesStore` | `document / markdown` 内容 |
| 用户资料 | `Hive + UserStore` | `UserProfileData` |
| 同步状态 | `Hive + SyncStore` | `pending_sync / sync_failed` 等 |

### 4.3 页面层数据流原则

- UI 优先展示本地数据，不等待远端返回后再首屏绘制。
- 编辑和反馈一律本地优先：
  - 保存计划：先写 `Hive`，再更新 `Store`，最后入同步队列
  - 完成任务：先写本地实例，再刷新页面，再尝试同步
  - 保存资料：先写本地资料，再同步远端
  - 创建文件夹 / 文件：先写本地 Notes 结构，再尝试同步
  - 编辑笔记：先写本地文件内容，再尝试同步
- `Now` 不负责首次生成 `task_instances`，实例统一由 `PlanEditor` 保存链路重建。

---

## 5. 页面组织与分层约定

### 5.1 目录结构

```text
lib/
├── apis/
├── models/
├── pages/
├── routes/
├── services/
├── store/
├── utils/
├── widgets/
├── global.dart
├── main.dart
└── theme.dart
```

### 5.2 分层职责

| 层 | 责任 |
|----|------|
| View | 负责结构渲染、事件绑定、滚动布局 |
| Controller | 管页面状态、交互方法、页面级校验 |
| Service | 负责业务规则、Hive / API / Store 编排 |
| Store | 负责全局可观察状态 |
| Hive / GetStorage | 最终持久化 |

### 5.3 页面实现规则

- 页面统一采用 `Binding + Controller + View`。
- 复杂页面允许拆分 `widgets/sections/`，但不新增并列页面层级替代主页面。
- 聚合逻辑放 `Service`，不要放进 `Widget` 或 `View`。
- 所有主页面都应保留唯一主控制器，section 组件只接收数据和回调。

---

## 6. 页面实现规范

### 6.1 SplashScreen

- 目标：品牌露出 + 启动过渡，不承载业务。
- 结构：全屏渐变背景、Logo 卡、应用名、副标题、旋转光环、跳动圆点。
- 关键规则：
  - 启动约 2 秒
  - 完成初始化后自动跳 `MainPage`
  - 不在 Splash 中做业务分流判断

### 6.2 NowPage

- 目标：始终告诉用户“现在应该做什么”。
- Figma 结构：顶部时间与欢迎语、右上状态徽章、AI 建议卡、主任务卡、`开始专注 / 换一个`、备用任务列表。
- Controller 职责：
  - `loadNowData()`
  - `switchCandidate()`
  - `startFocus()`
  - `completeTask() / postponeTask() / dropTask()`
- 需要单独补完专注层或专注弹框，不能只停留在静态卡片。

### 6.3 ChatPage

- 目标：沉浸式消息页，承接草稿生成与应用。
- Figma 结构：深色全屏背景、消息流、快捷回复、毛玻璃输入栏、发送按钮。
- 关键规则：
  - 进入页面后隐藏底部导航
  - 消息先写本地再请求远端
  - 草稿先落本地，再通过 `draftId` 跳 `PlanEditor`

### 6.4 PlanPage

- 目标：计划入口页，不承担详情编辑。
- Figma 结构：标题栏、`BattleMap` Hero 卡、进度 / Tab 区、计划卡片列表、悬浮新建按钮。
- 关键规则：
  - Hero 卡始终优先进入 `BattleMap`
  - 计划卡片承接查看详情或继续编辑的主入口
  - 空状态也要保留 `BattleMap` 入口和新建入口

### 6.5 BattleMapPage

- 目标：展示年度计划局势。
- Figma 结构：年度 Banner、五条主线卡片、状态徽章、7 日节奏、AI 建议。
- 关键规则：
  - 卡片颜色必须跟随主线渐变
  - 点击卡片统一进入 `TrackDetail(trackId)`
  - 不把 BattleMap 做成列表页或详情页的变体

### 6.6 TrackDetailPage

- 目标：展示单条主线的长期推进情况，并把“现在去执行”闭合到 `Now`。
- 统一骨架：
  - Hero 概览区
  - 阶段时间线
  - 当前阶段目标与任务
  - 执行数据 / 节奏区
  - AI 建议卡
  - CTA：去 `Now` 页面执行
- 多视觉态规则：
  - `换工作` 使用蓝紫色职业主题
  - `恋爱` 使用粉红色关系主题
  - 差异由 `trackId` 驱动主题、文案、指标，不拆分目录

### 6.7 PlanEditorPage

- 目标：完成计划新建、编辑、草稿校对。
- 统一骨架：
  - 顶部返回 / 保存
  - 基础信息卡
  - 时间规划卡
  - 阶段卡
  - 日常任务 / 一般任务卡
  - 固定底部 CTA
- 多视觉态规则：
  - `默认` 与 `恋爱` 共用一套表单结构
  - 主差异是顶部 tag、CTA 渐变、部分默认内容
- 保存链路必须固定为：
  1. 表单校验
  2. 组装 `CustomPlan / CustomPhase / CustomTask`
  3. `PlanService` 本地保存
  4. `TaskInstanceService.rebuildForPlan()`
  5. 更新 `PlanStore`
  6. 写入 `SyncStore`

### 6.8 ProfilePage 与 UserProfilePage

- `ProfilePage` 是个人中心摘要页：
  - 深色 Hero 卡
  - 能量选择卡
  - 执行模式卡
  - AI 模型卡
  - 产品理念卡
- `UserProfilePage` 是资料编辑页：
  - 顶部返回 / 保存
  - 头像卡
  - 昵称 / 座右铭 / 城市卡
  - 数据统计卡
  - 标签卡
  - 固定底部保存栏
- 两页职责不能混写成一个“设置页”。

### 6.9 NotesPage / NoteFolderPage / NoteFilePage

- `NotesPage` 是一级页：
  - 顶部标题
  - `新建文件夹 / 新建笔记`
  - 根目录文件夹 / 文件列表
  - 底部导航高亮 `Notes`
- `NoteFolderPage` 是带层级上下文的二级页：
  - 路径 / 面包屑
  - 当前层级下的子文件夹与文件
  - 仍保留 `Notes` 导航高亮
- `NoteFilePage` 是沉浸式文件页：
  - 返回、标题、路径
  - `编辑 / 预览`
  - 文档正文 / Markdown 预览

关键规则：

- Notes 是主导航独立页面，不并入 `Plan` 或 `Profile`。
- `NoteFolder` 允许继续创建子文件夹和文件。
- `NoteFile` 默认优先进入最近一次使用的模式；若无记录，进入编辑态。
- 当前版本只要求普通文档和 Markdown 的基础编辑与预览，不引入复杂块编辑器。

---

## 7. 公共组件与接口约束

建议优先抽象以下公共承接单位：

- `BottomNavShell`
- `PrimaryGradientButton`
- `SecondaryGhostButton`
- `GradientHeroCard`
- `TrackMetricCard`
- `TimelineSection`
- `TaskTypeTag`
- `GlassInputBar`
- `StickyBottomActionBar`
- `SyncStateBadge`

接口级约束：

- 路由跳转优先使用 `RouteName` 封装，不在页面里散写路径字符串。
- 页面参数命名统一：
  - `trackId` 用于 `TrackDetail`
  - `id` 用于 `PlanEditor` 编辑态
  - `draftId` 通过 `extra` 传递
- 页面目录导出统一走 `index.dart`。

---

## 8. 验收标准与禁止事项

### 8.1 文档驱动的实现验收

- 每个 Figma 页面都能对应到唯一 Flutter 页面和路由。
- `flutter-dev-plan.md` 的阶段与任务必须能直接引用本文件。
- `TrackDetail`、`PlanEditor`、`Profile / UserProfile` 的页面边界无歧义。
- `Notes / NoteFolder / NoteFile` 的页面边界、导航显示规则和数据来源无歧义。
- 视觉实现不允许把渐变 Hero、固定底部栏、时间线等关键结构简化成普通列表。

### 8.2 禁止事项

- 不引入 `Riverpod + Drift`
- 不使用 `Get.context`
- 不把二级页塞回 `MainPage` 的 `IndexedStack`
- 不把业务聚合逻辑写进 `Widget`
- 不脱离 Figma 与颜色文档自行发明主题色和交互层级

---

*本文件是 Flutter 前端实现的最高优先级技术约束。若模块文档与本文件冲突，以本文件为准，并同步修正文档体系。*
