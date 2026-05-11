# 执行力 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录当前流程进度、恢复点、需加载规则、依赖文件和注意事项。  
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `Flutter编码准备` |
| 当前步骤 | `F-001 工程骨架与目录初始化` |
| 当前步骤状态 | `pending` |
| 当前恢复点 | `projects/执行力/03-前端/开发计划/01-app-foundation.md` |
| 下一步默认动作 | 按 `flutter-dev-plan.md` 从工程骨架、初始化、路由、主题和最小可运行链路开始编码 |

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

## 2. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、架构门禁 |
| `.cursor/rules/07-Flutter开发计划文档.mdc` | 总体开发计划恢复点与任务状态规则 |
| `.cursor/rules/08-Flutter模块开发文档.mdc` | 模块计划读取与执行规则 |
| `.cursor/rules/flutter/08-项目结构目录.mdc` | Flutter 工程目录约束 |
| `.cursor/rules/flutter/task-project_init.mdc` | 工程初始化编码规则 |

---

## 3. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `projects/执行力/01-需求/requirements.md` | 已通过 PRD 与业务范围 | 是 |
| `projects/执行力/01-需求/detection-feedback.md` | 需求检测反馈、长期注意事项与闭环情况 | 是 |
| `projects/执行力/01-需求/references/README.md` | 参考素材索引 | 是 |
| `projects/执行力/02-技术方案/tech-plan.md` | 总体架构、模块拆分和接口规划 | 是 |
| `projects/执行力/03-前端/flutter-tech.md` | Flutter 技术实现口径 | 是 |
| `projects/执行力/03-前端/flutter-dev-plan.md` | 当前恢复点、任务状态和编码顺序 | 是 |
| `projects/执行力/03-前端/开发计划/01-app-foundation.md` | 当前模块编码计划 | 是 |
| `projects/执行力/04-后端/kotlin-tech.md` | 后端接口、状态流转、错误码与数据结构 | 是 |

---

## 4. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| Flutter 工程骨架 | `pending` | 实际代码工程内的目录、入口、初始化、路由与基础主题 |

---

## 5. 额外注意事项

- `requirements.md` 状态为“已通过”，后续小改动不得整篇重写 PRD。
- `detection-feedback.md` 记录了需求文档质量标准、离线优先、多端长期方向、页面级固定模板等注意事项；需求或 UI 变更时必须读取。
- 仓库内暂未发现 `projects/执行力/01-需求/figma-design-plan.md`；后续 UI、页面、状态、组件与交互约束需要补齐该文件，或由用户明确确认以 Figma `执行力设计稿 / 手机版`、`references/images/` 和现有 `flutter-dev-plan.md` 为准。
- 编码前必须先读取参考工程 `G:\code\soul\Solfeggio` 的真实目录结构和入口文件。
- UI 小变更必须先生成或更新 `change-plan.md`，明确需求、产品文档、技术文档与代码的影响文件清单。

---

## 6. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| `projects/执行力/01-需求/figma-design-plan.md` 缺失 | 新规则默认优先读取设计计划；直接编码可能缺少仓库内设计计划真源 | 编码或 UI 变更前补齐设计计划，或由用户确认使用现有 Figma 真源和参考图继续 |

---

## 7. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 需求分析 | `projects/执行力/01-需求/requirements-list.md` | `done` | 已沉淀需求清单 |
| 需求文档生成 | `projects/执行力/01-需求/requirements.md` | `done` | PRD v1.4 已通过 |
| 需求文档检测 | `projects/执行力/01-需求/detection-feedback.md` | `done` | 反馈闭环记录已沉淀 |
| 技术方案计划 | `projects/执行力/02-技术方案/tech-plan.md` | `done` | 已生成技术方案 |
| 前端Flutter文档 | `projects/执行力/03-前端/flutter-tech.md` | `done` | 已生成前端技术文档 |
| 后端Kotlin文档 | `projects/执行力/04-后端/kotlin-tech.md` | `done` | 已生成后端技术文档 |
| Flutter总体开发计划 | `projects/执行力/03-前端/flutter-dev-plan.md` | `done` | 文档状态为 `approved`，编码状态为 `pending` |
| Flutter模块开发文档 | `projects/执行力/03-前端/开发计划/*.md` | `done` | 已拆分模块计划 |

---

## 8. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-05-02 | 工作空间状态初始化 | 根据现有产物生成 `workflow.md` | 当前恢复点记录为 `F-001 工程骨架与目录初始化`，并记录缺少 `figma-design-plan.md` 的注意事项 |
