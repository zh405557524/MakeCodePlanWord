# 执行力 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录当前流程进度、恢复点、需加载规则、依赖文件和注意事项。
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `Flutter编码` |
| 当前步骤 | `v2 ChatHome / TodayFocus 核心代码评审` |
| 当前步骤状态 | `waiting_review` |
| 当前恢复点 | `projects/执行力/03-前端/flutter-dev-plan.md` |
| 下一步默认动作 | 进入 `F-028 v2 主链路联调`，验证 `ChatHome -> TodayFocus -> ChatHome`、`ChatHome -> ToolMenu -> PlanCreate / NotesEntry`、`ChatHome -> SideMenu -> 计划库 / 笔记 / 设置`，并做 Figma `V2-Chat-First` 对稿 |

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
| 0 | 变更校准 | `projects/执行力/change-plan.md` | `done` | 已登记 v2 对话主入口与全屏专注页重构，范围到 Figma 设计稿 |
| 1 | 需求分析 | `projects/执行力/01-需求/requirements-list.md` | `done` | 已补 v2 `ChatHome / TodayFocus / ToolMenu / SideMenu` 页面摘要 |
| 2 | PRD / 需求文档 | `projects/执行力/01-需求/requirements.md` | `done` | 已追加 v2 信息架构、导航规则和页面级需求 |
| 3 | 产品文档 | `projects/执行力/01-需求/references/docs/执行力-产品文档-v1.1-2026-03-31.md` | `done` | 已追加 v2 路由草案和页面说明 |
| 4 | Figma 设计更新 | `执行力设计稿 / 手机版` | `done` | 已新增 `V2-Chat-First` 区域和 7 张 v2 frame，本轮按用户“继续下一步”视为可进入技术方案同步 |
| 5 | Figma 设计计划文档 | `projects/执行力/01-需求/figma-design-plan.md` | `done` | 已新增 v2 页面清单、原型链路和设计验收标准 |
| 6 | 技术方案同步 | `projects/执行力/02-技术方案/tech-plan.md` | `done` | 已同步 ChatHome 根入口、TodayFocus 二级页、旧 Now / Chat 迁移口径 |
| 7 | 前端 Flutter 技术文档同步 | `projects/执行力/03-前端/flutter-tech.md` | `done` | 已同步 ChatHome 根路由、TodayFocus 二级页、无底部 Tab 壳层规则 |
| 8 | 后端 Kotlin 技术文档同步 | `projects/执行力/04-后端/kotlin-tech.md` | `done` | 已补 Notes 接口、表设计、服务职责和 v2 ChatHome / TodayFocus 接口复用说明 |
| 9 | Flutter 总体开发计划同步 | `projects/执行力/03-前端/flutter-dev-plan.md` | `done` | 已将编码恢复点切到 `F-024 v2 路由与壳层重构` |
| 10 | Flutter 模块开发文档同步 | `projects/执行力/03-前端/开发计划/*.md` | `done` | 已新增 `12-chat-home.md`、`13-today-focus.md`，并补旧 Now / Chat / Shell 迁移说明 |
| 11 | 后端 Kotlin 开发计划同步 | `projects/执行力/04-后端/kotlin-dev-plan.md` | `done` | 已新增 `B-001 ~ B-018` 后端任务、v2 联调重点和测试计划 |
| 12 | Flutter 编码 | `G:\code\soul\DoFlow` | `waiting_review` | 已完成 `F-024 ~ F-027` 核心代码，下一步进入 `F-028` 主链路联调 |
| 13 | 后端代码开发 | `后端工程代码` | `waiting_review` | 等用户确认后从 `B-001` 开始；属于阻塞式代码开发阶段 |
| 14 | 前端接入后端接口 | `前端对接真实 API` | `pending` | 属于阻塞式代码开发阶段；通常依赖后端接口稳定后持续联调，未收到“进入下一步”前不自动推进 |

---

## 3. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、架构门禁 |
| `.cursor/rules/09-Flutter开发计划文档.mdc` | 总体开发计划恢复点与任务状态规则 |
| `.cursor/rules/11-Flutter模块开发文档.mdc` | 模块计划读取与执行规则 |
| `.cursor/rules/flutter/01-项目初始化规则.mdc` | Flutter 工程初始化模板与基础规则 |
| `.cursor/rules/flutter/02-项目结构目录.mdc` | Flutter 工程目录约束 |
| `.cursor/rules/flutter/03-编码规范.mdc` | Flutter 通用编码约束 |
| `.cursor/rules/flutter/04-导航规则.mdc` | Flutter 路由层组织与跳转规则 |
| `.cursor/rules/flutter/05-多语言支持.mdc` | Flutter 多语言与文案资源规则 |
| `.cursor/rules/flutter/06-第三方依赖参考.mdc` | 初始化阶段第三方依赖基线参考 |
| `.cursor/rules/flutter/07-新功能开发.mdc` | 新功能与配套层扩展规则 |
| `.cursor/rules/flutter/08-UI处理任务.mdc` | UI 对稿、页面状态与交互实现规则 |
| `.cursor/rules/flutter/09-大功能先规划再编码.mdc` | 多模块任务的规划优先原则 |
| `.cursor/rules/flutter/10-编码工作流程.mdc` | Flutter 代码阶段内部的执行、验证与回写流程 |
| `.cursor/rules/flutter/11-测试规则.mdc` | 测试人员测试用例与 Python 辅助执行规则 |

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
| `projects/执行力/04-后端/kotlin-dev-plan.md` | 后端开发恢复点、任务状态和编码顺序 | 是 |

---

## 5. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| Notes 模块代码 | `done` | 已完成 `Notes / NoteFolder / NoteFile`、路由、存储、服务与主导航接入 |
| 本地测试数据与调试入口 | `done` | 已完成 `LocalSeedService`、`full_demo` 场景、`/debug/tools` 调试页与隐藏入口，可稳定导入 `Plan / BattleMap / TrackDetail / Now / Chat / PlanEditor / Notes / Profile` 联调数据 |
| v2 Figma 设计稿 | `done` | 已在 Figma 新增 `V2-Chat-First` 区域，包含 ChatHome 入口态、活跃态、TodayFocus、工具菜单、侧边菜单、计划创建和笔记入口 |
| v2 技术方案与 Flutter 计划 | `done` | 已同步 `tech-plan.md`、`flutter-tech.md`、`flutter-dev-plan.md` 和 `M-12 / M-13` 模块计划 |
| Kotlin 后端开发计划 | `done` | 已新增 `kotlin-dev-plan.md`，包含 `B-001 ~ B-018`、v2 联调重点和测试计划 |
| Flutter 编码 | `waiting_review` | 已完成 `ChatHome / TodayFocus / planCreate` 核心代码，下一步进入 `F-028 v2 主链路联调` |
| 后端编码 | `waiting_review` | 若进入后端代码，从 `B-001 Ktor 工程骨架与运行底座` 开始 |

---

## 6. 额外注意事项

- `requirements.md` 状态为“已通过”，后续小改动不得整篇重写 PRD。
- `detection-feedback.md` 记录了需求文档质量标准、离线优先、多端长期方向、页面级固定模板等注意事项；需求或 UI 变更时必须读取。
- 当前仓库内已补齐 `projects/执行力/01-需求/figma-design-plan.md`，后续 UI 和编码需优先按该文件与当前 Figma 真源执行。
- 编码前必须先读取参考工程 `G:\down\baidu\fuyao\translator-flutter` 的初始化结构参考，以及 `G:\code\soul\Solfeggio` 的抽象规则与工程组织方式。
- UI 小变更必须先生成或更新 `change-plan.md`，明确需求、产品文档、技术文档与代码的影响文件清单。
- “总体流程列表”优先表达当前版本下的真实完成度；如果后续再新增需求，应先回写该表，再决定是否进入编码。
- `Flutter 编码`、`后端代码开发`、`前端接入后端接口` 都属于阻塞式代码开发阶段；如果用户没有明确说“进入下一步”或切换到新的流程项，默认保持在当前编码步骤内持续修改、调试和回写状态，不自动推进到下一个流程阶段。
- 2026-06-05 起，前端已完成 `F-024 ~ F-027` 核心代码；下一步进入 `F-028 v2 主链路联调`，不继续旧 v1 `F-018`。
- 2026-06-05 起，后端恢复点补齐为 `B-001 Ktor 工程骨架与运行底座`，进入后端代码时先读 `kotlin-tech.md` 与 `kotlin-dev-plan.md`。

---

## 7. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 真机 `FA68Z0310730` 当前停留在锁屏密码页 | 无法完整执行无需人工介入的真机页面截图复核 | 已改用 `emulator-5554` 完成本轮主要页面对稿，待设备解锁后再补真机图 |

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
| Flutter总体开发计划 | `projects/执行力/03-前端/flutter-dev-plan.md` | `done` | 已推进到 v2 `F-028` 主链路联调恢复点 |
| Flutter模块开发文档 | `projects/执行力/03-前端/开发计划/*.md` | `done` | 已拆分模块计划 |
| Kotlin后端开发计划 | `projects/执行力/04-后端/kotlin-dev-plan.md` | `done` | 已补齐后端 `B-001 ~ B-018` 开发计划 |

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
| 2026-05-12 | Flutter 规则库重组 | 将 `.cursor/rules/flutter/` 调整为“通用规则库 + 代码模板库”，统一为 `01-09` 编号命名，并把项目专属规则输出逻辑收口到 `07-前端Flutter技术文档.mdc` | 后续 Flutter 初始化、技术文档生成与代码实现默认按统一编号规则文件执行，通用规则库本身不再承担项目输出说明职责 |
| 2026-05-12 | Flutter 规则库二次校准 | 去掉 Flutter 规则目录中的规则说明型文件与抽象中间层，只保留可直接复用的通用规则与代码模板，并同步顶层工作流、技术文档阶段与项目引用 | `.cursor/rules/flutter/` 现已稳定为可直接复用的 `01-09` 通用规则库，项目专属规则输出职责仅保留在 `07-前端Flutter技术文档.mdc` |
| 2026-05-13 | Flutter 编码工作流程补充 | 在 `.cursor/rules/flutter/` 中新增独立的 `10-编码工作流程.mdc`，专门描述 Flutter 代码阶段内部的推进、验证与回写顺序 | 现已明确区分“整体项目流程”和“Flutter 编码流程”，后续进入 Flutter 代码阶段时需同时遵守该编码工作流程规则 |
| 2026-05-14 | Flutter 总体开发计划重写 | 按新的 Flutter 规则库重写 `flutter-dev-plan.md`，统一到 `01-11` 规则口径，并补入测试人员用例与 Python 辅助执行规划 | 当前恢复点保持 `F-018` 不变，后续继续按联调、对稿、测试资料准备顺序推进 |
| 2026-05-14 | Flutter 模块开发文档重写 | 按新的 Flutter 总体开发计划重写 `01-11` 模块文档，并与 `G:\code\soul\DoFlow` 当前真实代码结构对齐 | 模块文档不再按“从零开发”口径描述，改为“基于现有代码增量重构”，当前恢复点仍保持 `F-018` |
| 2026-05-26 | UI 尺寸收口与页面对稿 | 在 `G:\code\soul\DoFlow` 收紧共享按钮和底导尺寸，重做 `Now / Profile` 摘要密度，并同步压缩 `Notes / Plan / Chat` 的首屏块级尺寸 | 已通过 `flutter analyze`、`flutter test`，并完成 `Now / Notes / Profile / Plan / Chat / BattleMap / UserProfile` 的模拟器截图复核；真机截图受锁屏阻塞，`TrackDetail` 因缺少主线数据待补抓 |
| 2026-05-26 | 本地测试数据补齐 | 在 `G:\code\soul\DoFlow` 新增 `LocalSeedService`、`full_demo` 固定业务数据、`/debug/tools` 调试页、隐藏入口与自动化校验 | 已可手动重置并导入稳定联调数据，`TrackDetail`、`Now`、`Chat`、`Notes`、`Profile` 主链路页面均有可复用本地数据支撑 |
| 2026-06-05 | v2 对话主入口设计重构 | 按用户要求先推进到 Figma 设计稿，不进入 Flutter 代码 | 已完成文档口径同步，并在 Figma 新增 `V2-Chat-First` 区域与 7 张 v2 frame，当前等待用户评审 |
| 2026-06-05 | v2 技术方案与 Flutter 计划同步 | 用户要求“继续下一步”，同步 `tech-plan.md`、`flutter-tech.md`、`flutter-dev-plan.md` 和模块开发文档 | 当前恢复点切到 `F-024 v2 路由与壳层重构`，等待确认是否进入 Flutter 代码 |
| 2026-06-05 | Kotlin 后端开发计划补齐 | 用户希望“后台的开发计划也写上”，新增 `kotlin-dev-plan.md` 并同步 `kotlin-tech.md` 与 workflow | 当前后端恢复点为 `B-001 Ktor 工程骨架与运行底座`，等待确认是否进入后端代码 |
| 2026-06-05 | v2 Flutter 核心代码实现 | 在 `G:\code\soul\DoFlow` 新增 ChatHome 和 TodayFocus，并调整 Splash、路由和 ChatService | 已通过 `flutter analyze` 与 `flutter test`，当前恢复点推进到 `F-028 v2 主链路联调` |
