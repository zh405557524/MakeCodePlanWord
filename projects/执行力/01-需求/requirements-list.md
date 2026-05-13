# 需求清单 - 执行力

> 状态：与 `requirements.md` v1.5 对齐。  
> 项目路径：`projects/执行力/`（核心工作流程见 `.cursor/rules/00-核心工作流程.mdc`）。

## 原始材料路径

- 图片：`projects/执行力/01-需求/references/images/`
- 文档：`projects/执行力/01-需求/references/docs/`
- **PRD**：[requirements.md](requirements.md)

## 产品主线

**记录笔记 / 输入计划 → 规划计划 → 执行计划 → 结果处理（成功/失败）**

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

## 技术约束

- Flutter + GetX；Kotlin Ktor + PostgreSQL。

## 待确认

见 `requirements.md` §8。
