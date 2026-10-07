# 漫剧制作 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录当前流程进度、恢复点、需加载规则、依赖文件和注意事项。  
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `漫剧制作` | 工作空间根目录名 |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/漫剧制作` | 唯一允许写入流程文档的项目工作区 |
| `currentVersion` | `v0.1.0` | 当前初版开发口径 |
| `iterationMode` | `initial_full_development` | 暂无项目级 CHG，仍按初版全量流程处理 |
| `baseArchiveVersion` | `none` | 初版开发无历史归档对照 |
| `currentRequirementEntry` | `01-需求/requirements.md` | 当前需求主入口 |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md` | 当前技术方案主入口 |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | 当前 Flutter 计划主入口 |
| `currentBackendPlanEntry` | `待生成` | 当前后端计划主入口，后续生成后改为 `04-后端/kotlin-dev-plan.md` |
| `archiveIndex` | `archive/` | 旧版快照归档目录；仅用于追溯、差异对比、回滚和验收争议 |
| `referenceProject` | `G:\code\soul\Solfeggio` | 编码前需读取的参考工程 |
| `backendFramework` | `Kotlin` | 当前后端技术文档口径 |

---

## 1.1 当前主文档入口与归档索引

> 工作区主路径永远保存当前最新可执行文档；`archive/` 只保存旧版快照，状态统一为 `reference-only`。

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 需求 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/detection-report.md`、`01-需求/figma-design-plan.md` | `active` | 当前需求、PRD、检测报告和设计计划入口 |
| 技术方案 | `02-技术方案/tech-plan.md`、`02-技术方案/app-flow.md`、`02-技术方案/effort-estimate.md` | `active` | 当前技术方案、业务流程和工时入口 |
| 前端 | `03-前端/flutter-tech.md`、`03-前端/flutter-dev-plan.md`、`03-前端/开发计划/` | `active` | 当前 Flutter 技术文档、总体计划和模块计划入口 |
| 后端 | `04-后端/kotlin-tech.md`、`04-后端/kotlin-dev-plan.md（待生成）` | `active-partial` | 当前 Kotlin 技术文档已存在，后端开发计划待生成 |

| 归档目录 | 来源版本 / CHG | 归档内容 | 状态 | 说明 |
|----------|----------------|----------|------|------|
| `archive/` | 后续迭代按需创建 | 旧版主文档镜像 | `reference-only` | 仅在差异对比、回滚、追溯或验收争议时读取 |

---

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `Flutter编码准备` |
| 当前步骤 | `F-001 工程骨架与目录初始化` |
| 当前步骤状态 | `pending` |
| 当前恢复点 | `projects/漫剧制作/03-前端/开发计划/01-app-foundation.md` |
| 下一步默认动作 | 审核 Flutter 总体开发计划和模块开发计划，通过后从 `F-001` 开始编码 |

状态枚举：

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 执行中 |
| `waiting_review` | 待用户审核或确认 |
| `done` | 已完成 |
| `blocked` | 被缺失信息、冲突或外部条件阻塞 |
| `skipped` | 用户明确跳过 |

---

## 3. 总体流程列表

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `change-plan.md` | `skipped` | 初版全量开发，暂无项目级 CHG |
| 1 | 需求分析 | `01-需求/requirements-list.md` | `done` | 已沉淀需求清单 |
| 2 | 需求文档生成 | `01-需求/requirements.md` | `done` | PRD 已生成 |
| 3 | 需求文档检测 | `01-需求/detection-report.md` | `done` | 检测报告已生成 |
| 4 | Figma 设计稿计划 | `01-需求/figma-design-plan.md` | `done` | 已生成设计计划 |
| 5 | 技术方案 | `02-技术方案/tech-plan.md` | `done` | 已生成技术方案 |
| 6 | 工作时长评估 | `02-技术方案/effort-estimate.md` | `done` | 已生成工时评估 |
| 7 | 前端 Flutter 技术文档 | `03-前端/flutter-tech.md` | `done` | 已生成前端技术文档 |
| 8 | 后端 Kotlin 技术文档 | `04-后端/kotlin-tech.md` | `done` | 已生成后端技术文档 |
| 9 | Flutter 总体开发计划 | `03-前端/flutter-dev-plan.md` | `done` | 当前恢复点记录在该文档中 |
| 10 | 后端 Kotlin 总体开发计划 | `04-后端/kotlin-dev-plan.md` | `pending` | 当前主入口为待生成 |
| 11 | Flutter 模块开发文档 | `03-前端/开发计划/*.md` | `done` | 已拆分模块计划 |
| 12 | 后端 Kotlin 模块开发文档 | `04-后端/开发计划/*.md` | `pending` | 后续进入后端计划后补齐 |
| 13 | Flutter 编码 | `{frontendRepo}` | `pending` | 当前停在 F-001 工程骨架与目录初始化 |
| 14 | 后端编码 | `{backendRepo}` | `pending` | 后端计划生成后再进入 |
| 15 | 联调与测试 QA | `05-联调与测试/qa-plan.md` | `pending` | 待编码完成后进入 |
| 16 | 构建与打包 | `06-构建打包/{build-plan.md,android.md,ios.md}` | `pending` | 待 QA 通过后进入 |
| 17 | 应用商店上架 | `07-应用上架/release-checklist.md` 等 | `pending` | 待构建通过后进入 |
| 18 | 发布与版本管理 | `08-发布版本/{release-plan.md,changelog.md}` | `pending` | 待上架前进入 |
| 19 | 上线监控与迭代 | `09-上线监控/{monitoring-plan.md,feedback-loop.md}` | `pending` | 发布后进入 |

---

## 4. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、架构门禁 |
| `.cursor/rules/07-Flutter开发计划文档.mdc` | 总体开发计划恢复点与任务状态规则 |
| `.cursor/rules/08-Flutter模块开发文档.mdc` | 模块计划读取与执行规则 |
| `.cursor/rules/flutter/08-项目结构目录.mdc` | Flutter 工程目录约束 |
| `.cursor/rules/flutter/task-project_init.mdc` | 工程初始化编码规则 |

---

## 5. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `projects/漫剧制作/01-需求/requirements.md` | 已确认 PRD 与业务范围 | 是 |
| `projects/漫剧制作/01-需求/figma-design-plan.md` | 页面、状态、组件、交互与设计出稿计划 | 是 |
| `projects/漫剧制作/02-技术方案/tech-plan.md` | 总体架构、模块拆分和接口规划 | 是 |
| `projects/漫剧制作/02-技术方案/app-flow.md` | 业务流程与步骤流转 | 是 |
| `projects/漫剧制作/03-前端/flutter-tech.md` | Flutter 技术实现口径 | 是 |
| `projects/漫剧制作/03-前端/flutter-dev-plan.md` | 当前恢复点、任务状态和编码顺序 | 是 |
| `projects/漫剧制作/03-前端/开发计划/01-app-foundation.md` | 当前模块编码计划 | 是 |
| `projects/漫剧制作/04-后端/kotlin-tech.md` | 后端接口、状态流转、错误码与数据结构 | 是 |

---

## 6. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| Flutter 工程骨架 | `pending` | 实际代码工程内的目录、入口、初始化、路由与基础主题 |

---

## 7. 额外注意事项

- 当前项目已具备 PRD、Figma 设计稿计划、技术方案、前端技术文档、后端技术文档、总体开发计划和模块开发计划。
- `flutter-dev-plan.md` 明确当前恢复点为 `F-001 工程骨架与目录初始化`。
- 编码前必须先读取参考工程 `G:\code\soul\Solfeggio` 的真实目录结构和入口文件。
- 后续小改动必须先生成或更新 `change-plan.md`，只修改影响文件清单内的内容。

---

## 8. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 无 | 无 | 无 |

---

## 9. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 需求分析 | `projects/漫剧制作/01-需求/requirements-list.md` | `done` | 已沉淀需求清单 |
| 需求文档生成 | `projects/漫剧制作/01-需求/requirements.md` | `done` | PRD 已生成 |
| 需求文档检测 | `projects/漫剧制作/01-需求/detection-report.md` | `done` | 检测报告已生成 |
| Figma设计稿计划 | `projects/漫剧制作/01-需求/figma-design-plan.md` | `done` | 已生成设计计划 |
| 技术方案计划 | `projects/漫剧制作/02-技术方案/tech-plan.md` | `done` | 已生成技术方案 |
| 前端Flutter文档 | `projects/漫剧制作/03-前端/flutter-tech.md` | `done` | 已生成前端技术文档 |
| 后端Kotlin文档 | `projects/漫剧制作/04-后端/kotlin-tech.md` | `done` | 已生成后端技术文档 |
| Flutter总体开发计划 | `projects/漫剧制作/03-前端/flutter-dev-plan.md` | `done` | 当前恢复点记录在该文档中 |
| Flutter模块开发文档 | `projects/漫剧制作/03-前端/开发计划/*.md` | `done` | 已拆分模块计划 |

---

## 10. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-05-02 | 工作空间状态初始化 | 根据现有产物生成 `workflow.md` | 当前恢复点记录为 `F-001 工程骨架与目录初始化` |
