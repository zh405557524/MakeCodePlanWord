# 执行力 变更计划

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录二次调整、局部修改或返工计划，控制影响范围，避免小改动触发大面积重写。  
> 维护规则：发生变更时创建或更新；变更完成后补充完成记录。

---

## 1. 变更概况

| 字段 | 内容 |
|------|------|
| 变更类型 | `small_change` |
| 变更来源 | `2026-05-11/2026-05-12 用户新增 Notes 需求，并要求继续执行整体计划` |
| 变更摘要 | `将 Notes 模块正式纳入当前版本，同步需求、设计、技术文档、开发计划与 workflow，再进入 Flutter 编码` |
| 当前状态 | `done` |

变更类型：

| 类型 | 含义 |
|------|------|
| `small_change` | 局部小改，默认类型，只允许修改影响文件清单内的内容 |
| `refactor` | 局部或模块级重构，必须由用户明确要求 |
| `rewrite` | 大范围重写，必须由用户明确要求 |

---

## 2. 影响文件清单

| 文件 | 影响原因 | 处理方式 |
|------|----------|----------|
| `projects/执行力/workflow.md` | 需要新增总体流程列表并回写当前版本真实完成度 | 修改 |
| `projects/执行力/01-需求/requirements.md` | Notes 已进入当前版本范围 | 已修改 |
| `projects/执行力/01-需求/requirements-list.md` | 需求摘要需纳入 Notes | 已修改 |
| `projects/执行力/01-需求/detection-feedback.md` | 需要沉淀 Notes 新需求闭环记录 | 已修改 |
| `projects/执行力/01-需求/references/README.md` | 需要补充 32-34 号 Notes 参考图索引 | 已修改 |
| `projects/执行力/01-需求/references/docs/执行力-产品文档-v1.1-2026-03-31.md` | 产品路由、数据结构、页面说明需纳入 Notes | 已修改 |
| `projects/执行力/01-需求/figma-design-plan.md` | 仓库内缺失设计计划文档，需补齐并纳入 Notes 页面 | 新增 |
| `projects/执行力/02-技术方案/tech-plan.md` | 当前技术方案仍是旧栈口径，且缺少 Notes 模块 | 修改 |
| `projects/执行力/03-前端/flutter-tech.md` | 需补 Notes 路由、页面、存储和 UI 约束 | 修改 |
| `projects/执行力/04-后端/kotlin-tech.md` | 需补 Notes 接口、表设计和服务职责 | 修改 |
| `projects/执行力/03-前端/flutter-dev-plan.md` | 需把 Notes 纳入总体任务顺序、恢复点和模块清单 | 修改 |
| `projects/执行力/03-前端/开发计划/01-app-foundation.md` | 需补 Notes 本地 box 和路由预注册要求 | 修改 |
| `projects/执行力/03-前端/开发计划/02-splash-shell.md` | MainShell 已从 4 入口升级为 5 入口 | 修改 |
| `projects/执行力/03-前端/开发计划/10-integration-and-qa.md` | 联调和 Figma 对照需要纳入 Notes 链路与页面 | 修改 |
| `projects/执行力/03-前端/开发计划/11-notes.md` | 需要新增 Notes 模块开发文档 | 新增 |

---

## 3. 不应改动范围

- `G:\code\soul\DoFlow` 代码工程本轮先不正式写业务代码，待文档与计划同步完成后再进入编码。
- 未受 Notes 影响的后端实现细节、既有数据库迁移细节和非相关模块文档不做无意义重写。
- 不因为本轮新增 Notes 需求，把已经通过的 PRD 和产品文档整篇推倒重来。

---

## 4. 分步执行计划

1. 创建 `change-plan.md`，明确本轮 Notes 变更的影响范围与非改动范围。
2. 补齐 `figma-design-plan.md`，让仓库内存在可回溯的设计计划真源。
3. 同步 `tech-plan.md`、`flutter-tech.md`、`kotlin-tech.md`，统一到 `GetX + GetStorage + Hive + Notes` 口径。
4. 同步 `flutter-dev-plan.md` 与受影响模块文档，并新增 `11-notes.md`。
5. 回写 `workflow.md`，更新总体流程列表、阻塞项和下一步默认动作。
6. 文档体系无冲突后，再进入 `G:\code\soul\DoFlow` 正式编码。

---

## 5. 验收标准

- 所有当前版本文档都明确 Notes 是正式模块，而非长期规划能力。
- 技术方案、前端技术文档、后端技术文档、开发计划之间不再残留 `Riverpod + Drift + 4 Tab` 旧口径冲突。
- `workflow.md` 的总体流程列表能准确反映当前版本哪些阶段完成、哪些阶段待继续。
- Flutter 编码开始前，文档侧已经能回答 Notes 的路由、数据模型、存储边界、页面结构和验收口径。

---

## 6. 完成记录

| 时间 | 操作 | 修改文件 | 结果 |
|------|------|----------|------|
| 2026-05-12 | 创建 Notes 变更计划 | `projects/执行力/change-plan.md` | 已建立本轮变更登记，当前状态为 `in_progress` |
| 2026-05-12 | 同步 Notes 文档体系 | `figma-design-plan.md`、`tech-plan.md`、`flutter-tech.md`、`kotlin-tech.md`、`flutter-dev-plan.md`、`开发计划/*.md`、`workflow.md` | 文档侧已统一到 Notes 当前版本口径，可进入 Flutter 编码 |
