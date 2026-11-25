# v1 流程（已停用）

这里保存 2026-10 之前使用的流程规则，只供追溯和查阅，不再作为执行依据。

| 内容 | 原位置 | 现在 |
|---|---|---|
| `cursor-rules/` | `.cursor/rules/` | 01–19 阶段规则、Flutter / Java 子规则、v1 模板 |
| `AGENTS.md` | 仓库根目录 | v1 的工作台入口（含路径守卫要求） |
| `scripts/workspace-path-guard.sh` | `scripts/` | v1 的项目路径守卫 |

v1 中仍有价值的内容已经并入 v2：

- Flutter / Java 编码规范 → `templates/repo-rules/`
- PRD 页面模板、推导规则标记、设计稿与动态数值的边界 → `workflow/02-需求变更.md`、`workflow/03-设计.md`
- 测试用例写法 → `workflow/06-测试验收.md`
- 构建、上架、发布、监控清单 → `workflow/07-发布.md`、`workflow/参考/首次上架清单.md`

`projects/` 下 v1 工作区里的 `workflow.md` 等文件引用的 `.cursor/rules/...` 路径，现在对应 `legacy/v1/cursor-rules/...`。
