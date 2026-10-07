# AGENTS.md — MakeCodePlanWord 工作台

这个仓库存放 AI 编码的**流程规则、文档模板、提示词和脚本**。每个项目的文档放在 `projects/{项目名}/doc/`（文档目录）；代码仓库只放代码、编码规范和指向文档目录的 `AGENTS.md`。

## 收到任务时

1. **确定项目**：查 `workspace-registry.json`（按 `name` / `aliases` 匹配），拿到 `appRepo`、`backendRepos`、`docRoot`、`flow`。匹配不到或有歧义时问用户。
2. **按 `flow` 处理**：
   - `"v2"`：按 `workflow/00-总流程.md` 工作，项目文档在 `docRoot`。
   - `"v1-legacy"`：项目还没迁移。`projects/{项目名}/` 下的旧文档只读查阅；要继续开发时先问用户是否按 `workflow/10-旧项目迁移.md` 迁移。
3. **按需读取**：先读 `workflow/00-总流程.md`，再只读当前步骤对应的那一份细则，不要一次读完 `workflow/` 下所有文件。
4. **写代码时**：到代码仓库里工作，以仓库根 `AGENTS.md` 和仓库规范目录（如 `.cursor/rules/`）为准；`templates/repo-rules/` 只是新项目模板。

## 目录

| 路径 | 用途 |
|---|---|
| `workflow/` | 流程规则：`00-总流程.md` 是总纲，`01`–`10` 是每一步的细则，`参考/` 是参考清单 |
| `templates/doc/` | 项目 `doc/` 的模板（基线、版本五件套、patch、测试清单） |
| `templates/repo/` | 代码仓库根目录的 `AGENTS.md`、`CLAUDE.md` 模板 |
| `templates/repo-rules/` | Flutter / Java 编码规范模板（新项目复制到仓库规范目录，如 `.cursor/rules/`） |
| `prompts/提示词.md` | 每一步的提示词 |
| `scripts/init-doc.sh` | 生成项目 `doc/` 骨架 |
| `scripts/new-version.sh` | 创建版本文件夹（`--patch` 创建 patch） |
| `workspace-registry.json` | 项目登记：仓库路径、文档位置、流程版本 |
| `projects/` | 各项目的工作区：`{项目名}/doc/` 是当前文档；没迁移的项目目录里是 v1 旧工作区（只读） |
| `legacy/v1/` | v1 的 Cursor 规则和脚本，只供追溯 |

## 改这个仓库本身时

- `workflow/` 每个文件保持短小；新增规则前先看能不能并进已有文件。
- 模板改动不会同步到已有项目，需要的话在对应项目里单独改。
- 不要在 `projects/` 下新建 v1 风格的文件（`workflow.md`、`change-plan.md`、`change-log.md`）。
- `legacy/` 只读。
