# MakeCodePlanWord

一个人 + AI 做 App 的开发流程工作台：流程规则、文档模板、提示词和脚本。

## 核心思路

- **基线 + 版本增量**：`doc/product/`、`doc/tech/`、`doc/testing/` 描述线上产品现在的样子；`doc/versions/vX.Y.Z/` 描述这一版要改什么。发布时把版本合并回基线，打 git tag 冻结。
- **工作区和代码分开**：项目文档放在 `projects/{项目名}/doc/`；代码仓库只放代码和编码规范，仓库根 `AGENTS.md` 写明文档目录的路径，AI 在仓库里写代码时按路径去读计划和基线。
- **先计划后开发**：前后端一份计划，按功能切片排任务，写到执行 AI 照着做不会走偏，审核后才写代码。
- **测试查到数据层**：验收标准和用例要写清"存了什么、接口返回什么"，高风险领域按清单逐条测，每个线上 bug 都补进回归集和清单。
- **AI 自动读规范**：每个代码仓库根目录放 `AGENTS.md`（Codex、Cursor 自动读）和 `CLAUDE.md`（Claude Code 自动读），规范放仓库的规范目录（如 `.cursor/rules/`）并由 `AGENTS.md` 索引。

## 一个版本怎么走

```
① scope 版本范围 → ② changes 需求变更 → ③ 设计（可选）→ ④ plan 开发计划 + test 用例 → 【审核】
→ ⑤ 开发执行 → ⑥ 测试验收 → ⑦ 发布 + 合并回基线 + tag
```

线上 bug：开 patch 版本，写一页 `fix.md`。

## 快速开始

| 我要…… | 看这里 |
|---|---|
| 了解整个流程 | `workflow/00-总流程.md` |
| 开一个新版本 | `prompts/提示词.md` P1 |
| 版本开发中改需求 | `prompts/提示词.md` P10 |
| 修线上 bug | `prompts/提示词.md` P9 |
| 新建项目 | `workflow/09-新项目初始化.md` |
| 把 v1 旧项目迁移过来 | `workflow/10-旧项目迁移.md` |

## v1 去哪了

原来的 `.cursor/rules/`（01–19 阶段规则）和路径守卫脚本移到了 `legacy/v1/`。`projects/` 下的旧工作区原样保留，只读；各项目下次开发前按 `workflow/10-旧项目迁移.md` 迁移。
