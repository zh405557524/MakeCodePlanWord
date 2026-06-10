# 需求清单 - 执行力

> 状态：与 `requirements.md` v1.5 对齐。  
> 项目路径：`projects/执行力/`（核心工作流程见 `.cursor/rules/00-核心工作流程.mdc`）。

## 原始材料路径

- 图片：`projects/执行力/01-需求/references/images/`
- 文档：`projects/执行力/01-需求/references/docs/`
- **PRD**：[requirements.md](requirements.md)

## 产品主线

**记录笔记 / 输入计划 → 规划计划 → 执行计划 → 结果处理（成功/失败）**

## v2 信息架构调整（2026-06-05）

本轮重构将产品首层心智从 `Now / Chat / Plan / Notes / Profile` 五个入口，调整为 `ChatHome` 对话主入口：

- `ChatHome` 是唯一一级页面，负责承接询问、今日计划入口、工具入口与结果反馈。
- `TodayFocus` 是二级全屏专注页，只突出一件当前任务，不显示底部导航、侧边菜单、聊天输入框或任务列表。
- `PlanCreate`、`NotesEntry`、`ProfileSettings`、计划库等能力从 `ChatHome` 的工具菜单、侧边菜单或对话意图进入。
- v1 已完成的 5 Tab 结构保留为旧方案与实现参考；v2 Figma 设计稿独立成区，不覆盖旧设计稿。

## 核心功能列表（摘要）

| # | 功能 | 说明 |
|---|------|------|
| 1 | 开屏 | 品牌与加载 |
| 2 | Now | 按当前时间聚合「此刻应执行」 |
| 3 | Chat | 对话生成/修改计划（草案确认落库） |
| 4 | Plan | 当天/本周课表视图 |
| 5 | BattleMap | 总体计划 + 年度下计划一览 |
| 6 | TrackDetail | 单计划时间线（`planId`） |
| 7 | PlanEditor | 创建/更新计划、阶段、任务 |
| 8 | Notes | 一级笔记页，展示文件夹与文件入口 |
| 9 | NoteFolder / NoteFile | 子文件夹浏览、文档 / Markdown 编辑与预览 |
| 10 | 执行反馈 | 推迟、放弃、可行性提示 |
| 11 | Profile / UserProfile | 设置与资料维护 |

## v2 核心页面（设计重构范围）

| # | 页面 | 说明 |
|---|------|------|
| 1 | ChatHome-Entry | 对话主入口空态，询问是否开启今天计划，保留底部 composer |
| 2 | ChatHome-Active | 已有执行反馈后的对话主页，显示少量消息和下一步入口 |
| 3 | TodayFocus | 二级全屏专注页，一屏一件事，只有开始专注与弱化次操作 |
| 4 | ToolMenu | `+` 工具菜单，进入开启计划、创建计划、写笔记、计划库 |
| 5 | SideMenu | 历史、计划库、笔记、设置的轻量侧边入口 |
| 6 | PlanCreate | 二级计划创建页，由对话草稿或工具菜单进入 |
| 7 | NotesEntry | 二级笔记入口，由工具菜单或侧边菜单进入 |

## 技术约束

- Flutter + GetX；Kotlin Ktor + PostgreSQL。

## 待确认

见 `requirements.md` §8。
