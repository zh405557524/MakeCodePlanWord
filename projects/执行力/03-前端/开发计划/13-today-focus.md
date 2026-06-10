# 执行力 Flutter 模块开发文档 - TodayFocus

> 模块编号：`M-13`
> 对应总体任务：`F-024、F-026`
> 状态：`done`
> 当前策略：基于旧 `Now` 推荐和反馈能力迁移，重做为 v2 二级全屏专注页

---

## 一、模块定位

`TodayFocus` 是从 `ChatHome` 进入的二级全屏页面。它不承担导航分发，也不是任务仪表盘，只服务当前一件任务。

本模块负责：

- 当前任务读取
- 预计时长与所属计划展示
- 开始专注
- 换一个
- 稍后
- 完成 / 推迟 / 放弃
- 返回 `ChatHome` 并传递结果反馈

本模块不负责：

- 聊天 composer
- 侧边菜单
- 底部 Tab
- 备用任务列表
- 统计卡
- 计划摘要卡
- 复盘和笔记的大面积展开

---

## 二、目标代码落点

建议新增以下文件：

- `lib/pages/today_focus/index.dart`
- `lib/pages/today_focus/controller.dart`
- `lib/pages/today_focus/view.dart`
- `lib/pages/today_focus/widgets/focus_top_bar.dart`
- `lib/pages/today_focus/widgets/focus_task_panel.dart`
- `lib/pages/today_focus/widgets/focus_primary_action.dart`
- `lib/pages/today_focus/widgets/focus_result_sheet.dart`

可复用来源：

- `lib/pages/now/` 的推荐、切换和反馈交互
- `NowService`
- `TaskInstanceService`
- `PlanStore`
- `SyncStore`

后续如果迁移成本可控，可把旧 `NowService` 重命名或包一层为 `TodayFocusService`。

---

## 三、路由与返回

目标路由：

- `/today/focus` -> `TodayFocusPage`

进入来源：

- `ChatHome` 的“开启今天计划”
- `ToolMenu` 的“开启今天计划”
- 后续可从计划详情的“现在执行”进入

返回规则：

- 关闭 / 返回：回到 `ChatHome`，不生成完成反馈。
- 稍后：回到 `ChatHome`，生成“已稍后处理”的轻反馈。
- 完成：先写本地任务状态，再回到 `ChatHome`，生成“已记录完成，计划进度已更新。”
- 放弃：写入放弃原因或简短状态，再回到 `ChatHome`。

---

## 四、页面状态

至少支持：

1. `loading`：读取当前任务。
2. `ready`：展示当前任务。
3. `running`：进入计时 / 专注中状态。
4. `completed`：完成后准备返回。
5. `postponed`：稍后后准备返回。
6. `empty`：今天没有可执行任务，提供返回 `ChatHome` 和创建计划入口。
7. `error`：读取失败，允许重试和返回。

---

## 五、视觉和交互规则

- 顶部只保留关闭 / 返回、轻量标题或时长。
- 中央突出任务名称，允许两行以内换行。
- 主 CTA 只有 `开始专注`。
- 次操作最多保留 `换一个`、`稍后`，视觉弱化。
- 执行中状态只展示极简计时和必要反馈。
- 不出现备用任务列表、统计卡、计划摘要或旧 Now 页卡片堆叠。
- 不出现 composer、底部 Tab 或侧边菜单。

---

## 六、数据写回

完成、推迟、放弃都必须本地优先：

1. 更新 `task_instances.status / resolution / updated_at`。
2. 更新 `PlanStore` 或当前任务缓存。
3. 写入 `SyncStore` 待同步记录。
4. 返回 `ChatHome` 并生成反馈消息。
5. 网络可用时再同步远端。

---

## 七、验收标准

- `ChatHome -> TodayFocus` 可进入。
- `TodayFocus -> 完成 / 稍后 -> ChatHome` 可返回并显示反馈消息。
- 首屏只突出一件当前任务。
- 375x812 不重叠、不溢出。
- 页面没有底部 Tab、composer、侧边菜单、备用列表和统计卡。
- 视觉对齐 Figma `V2-03-TodayFocus`。

---

## 八、视觉参考

- Figma：`V2-03-TodayFocus`
- 业务参考：v1 `02-Now` 的推荐与反馈逻辑

---

## 九、完成记录

| 日期 | 操作 | 结果 |
|------|------|------|
| 2026-06-05 | 实现 v2 TodayFocus 全屏专注页 | 已新增 `lib/pages/today_focus/`，完成当前任务、开始专注、换一个、稍后、完成和返回 ChatHome 反馈 |
