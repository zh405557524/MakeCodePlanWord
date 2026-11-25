# projects/

每个项目一个目录，是这个项目的**工作区**（和代码仓库分开）：

| 位置 | 内容 |
|---|---|
| `projects/{项目名}/README.md` | 线上版本、开发中版本、版本列表 |
| `projects/{项目名}/vX.Y.Z/` | 版本文件夹：`01-产品` … `06-上线`；patch 只有 `修复单.md` |
| `projects/{项目名}/testing/`、`backlog.md` | 跨版本的回归用例、高风险清单、想法池 |
| `projects/{项目名}/` 下其余文件（未迁移的项目） | v1 流程的旧工作区（`workflow.md`、`change-plan.md`、`01-需求/`……），只读，按 `workflow/11-旧项目迁移.md` 迁移 |

每个项目用的是哪种流程、工作区在哪，看工作台根目录 `workspace-registry.json` 的 `flow` 和 `workspace`。
