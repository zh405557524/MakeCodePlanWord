# 执行力 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录当前流程进度、恢复点、需加载规则、依赖文件和注意事项。  
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `Flutter编码` |
| 当前步骤 | `F-018 补齐同步态与异常态` |
| 当前步骤状态 | `in_progress` |
| 当前恢复点 | `projects/执行力/03-前端/开发计划/10-integration-and-qa.md` |
| 下一步默认动作 | 读取 `figma-design-plan.md`、`flutter-tech.md`、`flutter-dev-plan.md`、`10-integration-and-qa.md` 与 `11-notes.md`，继续在 `G:\code\soul\DoFlow` 补齐 `Notes / Now / Chat / Profile` 的空状态、异常态与联调链路 |

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

## 2. 总体流程列表

> 说明：本表用于记录“从当前需求版本出发”还需要做哪些事。即使某个阶段曾经完成过，只要被新需求影响且尚未同步到位，就应重新标记为 `pending` 或 `in_progress`。

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `projects/执行力/change-plan.md` | `done` | 已补 Notes 变更计划，并明确本轮影响范围 |
| 1 | 需求分析 | `projects/执行力/01-需求/requirements-list.md` | `done` | 已把 Notes 功能纳入需求清单摘要 |
| 2 | PRD / 需求文档 | `projects/执行力/01-需求/requirements.md` | `done` | 已更新到 `v1.5`，纳入 Notes、5 Tab 和 3 个页面 |
| 3 | 产品文档 | `projects/执行力/01-需求/references/docs/执行力-产品文档-v1.1-2026-03-31.md` | `done` | 内容已升级到 `v1.2`，补齐 Notes 路由、数据结构和页面说明 |
| 4 | Figma 设计更新 | `执行力设计稿 / 手机版` | `done` | 已新增 `12-Notes`、`13-NoteFolder`、`14-NoteFile` |
| 5 | Figma 设计计划文档 | `projects/执行力/01-需求/figma-design-plan.md` | `done` | 已补齐仓库内设计计划文档，并纳入 Notes 页面 |
| 6 | 技术方案同步 | `projects/执行力/02-技术方案/tech-plan.md` | `done` | 已统一到 `GetX + GetStorage + Hive + Notes` 口径 |
| 7 | 前端 Flutter 技术文档同步 | `projects/执行力/03-前端/flutter-tech.md` | `done` | 已补 Notes 路由、页面、存储和 UI 约束 |
| 8 | 后端 Kotlin 技术文档同步 | `projects/执行力/04-后端/kotlin-tech.md` | `done` | 已补 Notes 接口、表设计与服务职责 |
| 9 | Flutter 总体开发计划同步 | `projects/执行力/03-前端/flutter-dev-plan.md` | `done` | 已把 Notes 纳入总体任务顺序、恢复点与联调链路 |
| 10 | Flutter 模块开发文档同步 | `projects/执行力/03-前端/开发计划/*.md` | `done` | 已更新受影响模块文档并新增 `11-notes.md` |
| 11 | Flutter 编码 | `G:\code\soul\DoFlow` | `in_progress` | 属于阻塞式代码开发阶段；主壳、计划链路、Notes 链路与辅助页面已落地，当前进入状态补齐、链路联调与 Figma 对稿阶段，未收到“进入下一步”前默认持续停留在本阶段 |
| 12 | 后端代码开发 | `后端工程代码` | `pending` | 属于阻塞式代码开发阶段；进入后默认在当前编码步骤持续修改与调试，直到用户明确要求切到下一步 |
| 13 | 前端接入后端接口 | `前端对接真实 API` | `pending` | 属于阻塞式代码开发阶段；通常依赖后端接口稳定后持续联调，未收到“进入下一步”前不自动推进 |

---

## 3. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、架构门禁 |
| `.cursor/rules/07-Flutter开发计划文档.mdc` | 总体开发计划恢复点与任务状态规则 |
| `.cursor/rules/08-Flutter模块开发文档.mdc` | 模块计划读取与执行规则 |
| `.cursor/rules/flutter/01-项目初始化规则.mdc` | Flutter 工程初始化模板与基础规则 |
| `.cursor/rules/flutter/02-项目结构目录.mdc` | Flutter 工程目录约束 |
| `.cursor/rules/flutter/03-编码规范.mdc` | Flutter 通用编码约束 |
| `.cursor/rules/flutter/04-导航规则.mdc` | Flutter 路由层组织与跳转规则 |
| `.cursor/rules/flutter/06-第三方依赖参考.mdc` | 初始化阶段第三方依赖基线参考 |
| `.cursor/rules/flutter/07-新功能开发.mdc` | 新功能与配套层扩展规则 |
| `.cursor/rules/flutter/08-UI处理任务.mdc` | UI 对稿、页面状态与交互实现规则 |
| `.cursor/rules/flutter/09-大功能先规划再编码.mdc` | 多模块任务的规划优先原则 |
| `.cursor/rules/flutter/10-编码工作流程.mdc` | Flutter 代码阶段内部的执行、验证与回写流程 |

---

## 4. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `projects/执行力/01-需求/requirements.md` | 已通过 PRD 与业务范围 | 是 |
| `projects/执行力/01-需求/detection-feedback.md` | 需求检测反馈、长期注意事项与闭环情况 | 是 |
| `projects/执行力/01-需求/figma-design-plan.md` | Figma 页面、状态、组件与交互真源计划 | 是 |
| `projects/执行力/01-需求/references/README.md` | 参考素材索引 | 是 |
| `projects/执行力/02-技术方案/tech-plan.md` | 总体架构、模块拆分和接口规划 | 是 |
| `projects/执行力/03-前端/flutter-tech.md` | Flutter 技术实现口径 | 是 |
| `projects/执行力/03-前端/flutter-dev-plan.md` | 当前恢复点、任务状态和编码顺序 | 是 |
| `projects/执行力/03-前端/开发计划/10-integration-and-qa.md` | 当前联调与状态补齐计划 | 是 |
| `projects/执行力/03-前端/开发计划/11-notes.md` | 当前新增 Notes 模块实现与验收口径 | 是 |
| `projects/执行力/04-后端/kotlin-tech.md` | 后端接口、状态流转、错误码与数据结构 | 是 |

---

## 5. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| Notes 模块代码 | `done` | 已完成 `Notes / NoteFolder / NoteFile`、路由、存储、服务与主导航接入 |
| 联调与状态补齐 | `in_progress` | 当前正在补齐空状态、异常态，并校准主链路与 Notes 链路恢复点 |

---

## 6. 额外注意事项

- `requirements.md` 状态为“已通过”，后续小改动不得整篇重写 PRD。
- `detection-feedback.md` 记录了需求文档质量标准、离线优先、多端长期方向、页面级固定模板等注意事项；需求或 UI 变更时必须读取。
- 当前仓库内已补齐 `projects/执行力/01-需求/figma-design-plan.md`，后续 UI 和编码需优先按该文件与当前 Figma 真源执行。
- 编码前必须先读取参考工程 `G:\code\soul\Solfeggio` 的真实目录结构和入口文件。
- UI 小变更必须先生成或更新 `change-plan.md`，明确需求、产品文档、技术文档与代码的影响文件清单。
- “总体流程列表”优先表达当前版本下的真实完成度；如果后续再新增需求，应先回写该表，再决定是否进入编码。
- `Flutter 编码`、`后端代码开发`、`前端接入后端接口` 都属于阻塞式代码开发阶段；如果用户没有明确说“进入下一步”或切换到新的流程项，默认保持在当前编码步骤内持续修改、调试和回写状态，不自动推进到下一个流程阶段。

---

## 7. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 无 | 无 | 无 |

---

## 8. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 需求分析 | `projects/执行力/01-需求/requirements-list.md` | `done` | 已沉淀需求清单 |
| 需求文档生成 | `projects/执行力/01-需求/requirements.md` | `done` | PRD v1.5 已通过 |
| 需求文档检测 | `projects/执行力/01-需求/detection-feedback.md` | `done` | 反馈闭环记录已沉淀 |
| Figma设计稿计划 | `projects/执行力/01-需求/figma-design-plan.md` | `done` | 已补齐设计计划，并纳入 Notes 页面 |
| 技术方案计划 | `projects/执行力/02-技术方案/tech-plan.md` | `done` | 已生成技术方案 |
| 前端Flutter文档 | `projects/执行力/03-前端/flutter-tech.md` | `done` | 已生成前端技术文档 |
| 后端Kotlin文档 | `projects/执行力/04-后端/kotlin-tech.md` | `done` | 已生成后端技术文档 |
| Flutter总体开发计划 | `projects/执行力/03-前端/flutter-dev-plan.md` | `done` | 文档状态为 `approved`，编码状态已进入 `in_progress` |
| Flutter模块开发文档 | `projects/执行力/03-前端/开发计划/*.md` | `done` | 已拆分模块计划 |

---

## 9. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-05-02 | 工作空间状态初始化 | 根据现有产物生成 `workflow.md` | 当前恢复点记录为 `F-001 工程骨架与目录初始化`，并记录缺少 `figma-design-plan.md` 的注意事项 |
| 2026-05-11 | 需求变更补充 | 根据新增笔记需求更新 PRD、产品文档与 Figma | Notes 模块进入当前版本范围，需同步主页导航、页面结构与设计稿 |
| 2026-05-12 | workflow 增强 | 新增“总体流程列表”并校准下一步默认动作 | 可以直接看出当前版本下哪些阶段已完成、哪些阶段需因 Notes 需求重新同步 |
| 2026-05-12 | Notes 文档体系同步 | 创建 `change-plan.md`、补齐 `figma-design-plan.md`，并同步技术方案、前后端文档与开发计划 | 当前文档侧已对齐，可以进入 `G:\code\soul\DoFlow` 开始编码 |
| 2026-05-12 | Notes 编码落地与恢复点回写 | 在 `G:\code\soul\DoFlow` 完成 Notes 路由、模型、服务、存储与三层页面，并将恢复点推进到 `F-018` | Flutter 编码阶段从“待开始”切换为“进行中”，后续优先处理状态补齐、联调与 UI 对稿 |
| 2026-05-12 | 编码阶段流程约定补充 | 在 workflow 中新增“后端代码开发”“前端接入后端接口”两个后续流程项，并明确编码阶段默认停留在当前步骤循环调试 | 后续若未收到“进入下一步”的明确指令，将继续停留在当前编码步骤执行 |
| 2026-05-12 | 阻塞式编码阶段规则补充 | 明确 `Flutter 编码` 也属于阻塞式代码开发阶段，并与后端开发、前端接接口保持同一推进规则 | 后续所有代码开发阶段都必须等待用户明确说“进入下一步”后才允许切换流程项 |
| 2026-05-12 | Flutter 规则库重组 | 将 `.cursor/rules/flutter/` 调整为“通用规则库 + 代码模板库”，统一为 `01-09` 编号命名，并把项目专属规则输出逻辑收口到 `05-前端Flutter技术文档.mdc` | 后续 Flutter 初始化、技术文档生成与代码实现默认按统一编号规则文件执行，通用规则库本身不再承担项目输出说明职责 |
| 2026-05-12 | Flutter 规则库二次校准 | 去掉 Flutter 规则目录中的规则说明型文件与抽象中间层，只保留可直接复用的通用规则与代码模板，并同步顶层工作流、技术文档阶段与项目引用 | `.cursor/rules/flutter/` 现已稳定为可直接复用的 `01-09` 通用规则库，项目专属规则输出职责仅保留在 `05-前端Flutter技术文档.mdc` |
| 2026-05-13 | Flutter 编码工作流程补充 | 在 `.cursor/rules/flutter/` 中新增独立的 `10-编码工作流程.mdc`，专门描述 Flutter 代码阶段内部的推进、验证与回写顺序 | 现已明确区分“整体项目流程”和“Flutter 编码流程”，后续进入 Flutter 代码阶段时需同时遵守该编码工作流程规则 |
