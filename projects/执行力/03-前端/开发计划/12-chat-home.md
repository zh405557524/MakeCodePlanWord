# 执行力 Flutter 模块开发文档 - ChatHome

> 模块编号：`M-12`
> 对应总体任务：`F-024 ~ F-025`
> 状态：`done`
> 当前策略：基于现有 `Chat` 消息与草稿能力迁移，优先落 v2 唯一一级对话主入口

---

## 一、模块定位

`ChatHome` 是 v2 的唯一一级页面。用户打开 App 后不再进入旧 `Now` 首页或底部 Tab 壳层，而是直接看到一个对话式入口。

本模块负责：

- 首次入口空态
- 活跃态消息流
- 底部 composer
- `+` 工具菜单
- 左上侧边菜单
- 今日计划入口
- `TodayFocus` 返回后的结果反馈消息
- 计划创建、笔记、计划库、设置等二级入口分发

本模块不负责：

- 专注页完整 UI
- 计划编辑器内部表单
- Notes 文件夹和文件编辑细节
- 后端真实 AI 会话接口

---

## 二、目标代码落点

建议新增或迁移到以下文件：

- `lib/pages/chat_home/index.dart`
- `lib/pages/chat_home/controller.dart`
- `lib/pages/chat_home/view.dart`
- `lib/pages/chat_home/widgets/chat_home_top_bar.dart`
- `lib/pages/chat_home/widgets/chat_composer_bar.dart`
- `lib/pages/chat_home/widgets/tool_menu_sheet.dart`
- `lib/pages/chat_home/widgets/side_menu_drawer.dart`
- `lib/pages/chat_home/widgets/chat_message_bubble.dart`
- `lib/pages/chat_home/widgets/today_plan_suggestion.dart`

可复用来源：

- `lib/pages/chat/` 的消息、composer、草稿卡能力
- `DraftStore`
- `ChatService`
- `PlanStore`
- `NowService` 或后续迁移出的 `TodayFocusService`

---

## 三、路由与入口

目标路由：

- `/` -> `ChatHomePage`

入口规则：

- `Splash` 初始化完成后进入 `/`。
- 旧 `MainShell / BottomNav` 不再作为首屏分发。
- `ToolMenu` 和 `SideMenu` 是 `ChatHome` 内部 overlay / drawer，不注册独立路由。

---

## 四、页面状态

至少支持：

1. `entry_empty`：首次入口，只问“要开启今天的计划吗？”
2. `entry_suggested`：已有今日推荐，显示一条轻提示和主 CTA。
3. `active_conversation`：已有消息和执行反馈。
4. `tool_menu_open`：点击 `+` 展开工具菜单。
5. `side_menu_open`：点击左上 menu 展开侧边菜单。
6. `focus_result`：从 `TodayFocus` 返回后插入一条反馈消息。

---

## 五、交互规则

- 点击“开启今天计划”进入 `RouteName.todayFocus`。
- 点击 `+` 打开工具菜单，菜单项包括：
  - 开启今天计划
  - 创建计划
  - 写笔记
  - 查看计划库
- 点击左上 menu 打开侧边菜单，入口包括：
  - 最近对话
  - 计划库
  - 笔记
  - 设置
- 输入消息时先写本地消息，再触发草稿或建议生成。
- `TodayFocus` 完成、推迟或放弃后，回到 `ChatHome` 并生成简短反馈消息。

---

## 六、实现边界

本模块要做：

- 把对话入口做成首屏。
- 保留页面下方 composer 作为主操作入口。
- 保证 375x812 不重叠、不溢出。
- 让 `PlanCreate / NotesEntry / PlanLibrary / Profile` 都能从 `ChatHome` 到达。

本模块不做：

- 底部 Tab。
- 旧 Now 首页卡片堆叠。
- 把专注 UI 塞在首页。
- 新增复杂 AI 后端能力。

---

## 七、验收标准

- 打开 App 后首屏是 `ChatHome`，不是仪表盘。
- 首屏没有底部 Tab。
- composer 固定在底部且不遮挡主要内容。
- `ChatHome -> TodayFocus -> ChatHome` 可闭合。
- `ChatHome -> ToolMenu -> PlanCreate / NotesEntry` 可闭合。
- `ChatHome -> SideMenu -> 计划库 / 笔记 / 设置` 可达。
- 页面视觉对齐 Figma `V2-01-ChatHome-Entry`、`V2-02-ChatHome-Active`、`V2-04-ToolMenu`、`V2-05-SideMenu`。

---

## 八、视觉参考

- Figma：`V2-01-ChatHome-Entry`
- Figma：`V2-02-ChatHome-Active`
- Figma：`V2-04-ToolMenu`
- Figma：`V2-05-SideMenu`

---

## 九、完成记录

| 日期 | 操作 | 结果 |
|------|------|------|
| 2026-06-05 | 实现 v2 ChatHome 首屏 | 已新增 `lib/pages/chat_home/`，完成空态、活跃态、composer、工具菜单、侧边菜单和专注反馈消息 |
