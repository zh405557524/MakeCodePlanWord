# projects/

每个项目一个目录，是这个项目的**工作区**（和代码仓库分开）：

| 位置 | 内容 |
|---|---|
| `projects/{项目名}/README.md` | 线上版本、开发中版本、版本列表 |
| `projects/{项目名}/vX.Y.Z/` | 版本文件夹：`01-产品` … `06-上线`；patch 只有 `修复单.md` |
| `projects/{项目名}/testing/`、`backlog.md` | 跨版本的回归用例、高风险清单、想法池 |
| `projects/{项目名}/` 下其余文件（未迁移的项目） | v1 流程的旧工作区（`workflow.md`、`change-plan.md`、`01-需求/`……），只读，按 `workflow/11-旧项目迁移.md` 迁移 |

每个项目用的是哪种流程、工作区在哪，看工作台根目录 `workspace-registry.json` 的 `flow` 和 `workspace`。

## 项目一览

流程以 `workspace-registry.json` 为准。各项目的版本和进度看它自己的 `README.md`，这里不重复，免得过时。

| 项目 | 流程 | 入口 | 说明 |
|---|---|---|---|
| 钢琴视奏 | v2 | `钢琴视奏/README.md` | |
| 喵喵漫剧 | v2 | `喵喵漫剧/README.md` | |
| 喵喵漫剧网页端 | v2 | `喵喵漫剧网页端/README.md` | |
| GPU集群 | v2 | `GPU集群/README.md` | |
| 灵犀万象后端与后台 | v2 | `灵犀万象后端与后台/开发计划/` | 后端和 Web 后台专用；开发计划按“待执行 / 待检验 / 已执行”三个文件夹放；还没有 README |
| 喵喵写歌 | 旧流程（只读） | `喵喵写歌/CURRENT.md` | 下次开发前按 `workflow/11-旧项目迁移.md` 迁移 |
| 喵喵带货 | 旧流程（只读） | `喵喵带货/CURRENT.md` | 同上 |
| 喵喵穿搭 | 旧流程（只读） | `喵喵穿搭/workflow.md` | 同上 |
| 剧说 | 旧流程（只读） | `剧说/workflow.md` | 同上 |
| 喵喵漫画 | 旧流程（只读） | `喵喵漫画/workflow.md` | 同上 |
| 漫剧制作 | 旧流程（只读） | `漫剧制作/workflow.md` | 同上 |
| 执行力 | 旧流程（只读） | `执行力/workflow.md` | 登记表里的仓库路径还是 Windows 的 `G:\code\soul\DoFlow` |

