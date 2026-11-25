# AGENTS.md — MakeCodePlanWord 工作台

这个仓库存放 AI 做 App 的**流程规则、模板、提示词和脚本**，以及每个项目的工作区 `projects/{项目名}/`（全部文档都在工作区）。代码仓库只放代码、编码规范和指向工作区的 `AGENTS.md`。

## 收到任务时

1. **确定项目**：查 `workspace-registry.json`（按 `name` / `aliases` 匹配），拿到 `appRepo`、`backendRepos`、`workspace`、`flow`。匹配不到或有歧义时问用户。
2. **按 `flow` 处理**：
   - `"v2"`：按 `workflow/00-总流程.md` 的八个阶段工作，文档在 `workspace`。
   - `"v1-legacy"`：项目还没迁移。`projects/{项目名}/` 下的旧文档只读；要继续开发时先问用户是否按 `workflow/11-旧项目迁移.md` 迁移。
3. **找阶段**：读工作区 `README.md` 找到开发中版本，看版本 `README.md` 顶部的状态。线上已完成的功能在工作区 `当前产品文档/`。
4. **按需读取**：先读 `workflow/00-总流程.md`，再只读当前阶段的那一份细则，不要一次读完 `workflow/`。
5. **写代码时**：到代码仓库里工作，以仓库根 `AGENTS.md` 和仓库规范目录（如 `.cursor/rules/`）为准；`templates/repo-rules/` 只是新项目模板。

## 目录

| 路径 | 用途 |
|---|---|
| `工作说明.md` | 一页纸：每个阶段做什么、产出什么、用哪个提示词 |
| `workflow/` | 流程规则：`00-总流程.md` 是总纲；`01`～`08` 是八个阶段；`09` 线上问题、`10` 新项目、`11` 旧项目迁移；`参考/` |
| `templates/project/` | 项目工作区模板：README、backlog、testing、当前产品文档（空） |
| `templates/version/` | 版本文件夹模板：版本 README、`01-产品`（requirements-list.md、requirements.md、requirements-review.md、detection-feedback.md）… `06-上线` |
| `templates/patch/` | patch 修复单模板 |
| `templates/repo/` | 代码仓库根目录的 `AGENTS.md`、`CLAUDE.md` 模板 |
| `templates/repo-rules/` | Flutter / Java 编码规范模板（新项目复制到仓库规范目录） |
| `prompts/提示词.md` | 每个阶段的提示词 |
| `scripts/init-project.sh` | 生成项目工作区骨架 |
| `scripts/new-version.sh` | 开版本：生成四份本版增量产品模板，复制上一版的设计、技术文档；`--patch` 开 patch |
| `scripts/update-current-doc.sh` | 仅兼容旧全量格式的归档；四文档增量版本禁止整份替换，按 workflow/08 合并 |
| `scripts/lib-doc.sh` | 上面两个脚本共用的函数 |
| `workspace-registry.json` | 项目登记：仓库路径、工作区、流程版本 |
| `projects/` | 各项目的工作区 |
| `legacy/v1/` | v1 的 Cursor 规则和脚本，只供追溯 |

## 改这个仓库本身时

- `workflow/` 每个文件保持短小；新增规则前先看能不能并进已有文件。
- 模板改动不会同步到已有项目，需要的话在对应项目里单独改。
- 产品阶段只保留四份文档：需求清单、本版产品需求、用户评审版、独立检测报告。全量定义在 `当前产品文档/`，开发依据为全量基线 + 本版已确认增量；检测通过且用户明确确认才进下一阶段，结构确认不等于业务批准。
- 自己出稿先出图片，经用户检查通过后才按对应图片绘制 Figma；Figma 再经用户确认后进入技术规划。AI 自检、图片生成完成和同意流程都不等于用户批准图片。
- 已归档的版本文件夹不修改；当前产品文档只在归档时合并已上线增量。
- 不要在 `projects/` 下新建 v1 风格的文件（`workflow.md`、`change-plan.md`、`change-log.md`）。
- `legacy/` 只读。
- 涉及大批量删除时，先列明对象、范围、影响和恢复方式，取得用户明确确认后才执行；替换设计稿时默认逐个完成并核验新稿，再删除对应旧稿，不能自行扩大成整页或整版清空。

## 测试产物不进入 Git

- 测试截图、录屏、安装包、运行日志、接口响应、临时构建文件和原始证据仅在本地保存，不提交 Git，不使用 `git add -f` 绕过忽略规则。
- `projects/` 下测试阶段目录及 `evidence/`、`artifacts/` 等产物目录由 `.gitignore` 排除；其中 Markdown 测试计划和文字报告继续纳入版本管理。
- 设计稿、产品素材和正式产品文档按原规则管理；本规则不授权自动删除本地文件。
