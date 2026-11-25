# {项目名称} 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录当前流程进度、总体流程列表、恢复点、需加载规则、依赖文件、变更登记和注意事项。
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `{项目名}` | 工作空间根目录名 |
| `canonicalWorkspaceRoot` | `{由 scripts/workspace-path-guard.sh resolve 输出的绝对路径}` | 唯一允许写入流程文档的项目工作区；不得由代码仓库当前目录推导 |
| `currentVersion` | `v0.1.0` | 研发当前版本号（与 `change-log.md` 一致） |
| `iterationMode` | `initial_full_development` | `initial_full_development` 初版全量开发；`version_iteration` 版本迭代 |
| `baseArchiveVersion` | `none` | 当前迭代需要对照的历史归档；初版填 `none` |
| `currentRequirementEntry` | `01-需求/requirements.md` | 当前需求主入口 |
| `currentRequirementReviewEntry` | `01-需求/requirements-review.md` | 产品负责人快速审核入口，不替代 PRD |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md` | 当前技术方案主入口 |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | 当前 Flutter 计划主入口 |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md` | 当前后端计划主入口；Java 项目填 `java-dev-plan.md`，Kotlin 项目填 `kotlin-dev-plan.md` |
| `archiveIndex` | `archive/` | 旧版快照归档目录；只用于追溯、差异对比、回滚和验收争议 |
| `referenceProject` | `{绝对路径或留空}` | 参考工程绝对路径；留空表示无参考 |
| `frontendRepo` | `{Flutter 工程绝对路径或留空}` | 前端代码工程位置 |
| `backendRepo` | `{Java 工程绝对路径或留空}` | 后端代码工程位置 |
| `flutterChannel` | `stable` | Flutter 通道（stable / beta / master） |
| `backendFramework` | `Spring Boot` | Java 后端框架（固定：Spring Boot） |
| `backendBuildTool` | `Gradle` | Java 后端构建工具（固定：Gradle） |
| `targetStores` | `AppStore, Google Play` | 目标应用商店清单 |

---

## 1.1 当前主文档入口与归档索引

> 说明：工作区主路径永远保存当前最新可执行文档；编码、技术文档和开发计划默认只读取主路径。
> `archive/` 只保存旧版快照，状态统一为 `archived/reference-only`，用于追溯、差异对比、回滚和验收争议，不能作为编码执行依据。

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 当前入口说明 | `CURRENT.md`（可选） | `active` | 如存在，必须指向本表主路径，不得指向 `versions/` 或 `archive/` |
| 需求 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/requirements-review.md`、`01-需求/detection-feedback.md`、`01-需求/figma-design-plan.md` | `active` | PRD 是完整真源；Review 是产品审核层；检测与设计另行执行 |
| 技术方案 | `02-技术方案/tech-plan.md`、`02-技术方案/effort-estimate.md` | `active` | 技术方案、工时评估当前真源 |
| 前端 | `03-前端/flutter-tech.md`、`03-前端/flutter-dev-plan.md`、`03-前端/开发计划/` | `active` | Flutter 技术文档、总体计划、模块计划当前真源 |
| 后端 | `04-后端/java-tech.md` / `04-后端/kotlin-tech.md`、`04-后端/java-dev-plan.md` / `04-后端/kotlin-dev-plan.md`、`04-后端/开发计划/` | `active` | 后端技术文档、总体计划、模块计划当前真源 |

| 归档目录 | 来源版本 / CHG | 归档内容 | 状态 | 说明 |
|----------|----------------|----------|------|------|
| `archive/{version-or-date}/` | `{版本号或 CHG-id}` | `{受影响主文档镜像}` | `reference-only` | 仅在差异对比、回滚、追溯或验收争议时读取 |

---

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `{阶段编号 + 名称}` |
| 当前步骤 | `{步骤名}` |
| 当前步骤状态 | `pending` |
| 当前恢复点 | `{从哪里继续}` |
| 下一步默认动作 | `{下一步动作}` |

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

> 说明：本表用于记录“从当前版本目标出发”整体还需要做哪些事，以及哪些已经完成、哪些尚未完成。
> 若出现新增需求、局部返工或二次调整，即使某个阶段曾经完成过，只要受本轮变更影响且尚未同步到位，就应重新标记为 `pending` 或 `in_progress`。

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `change-plan.md` | `pending` | 新增需求、返工或局部调整时先登记影响范围 |
| 1 | 需求分析 | `01-需求/requirements-list.md` | `pending` | 需求清单是否已沉淀 |
| 2 | 需求文档生成 | `01-需求/requirements.md` + `01-需求/requirements-review.md` | `pending` | 双文档是否生成并同步；生成完成不代表产品决策批准 |
| 3 | 需求文档检测 | 检测报告 + `01-需求/detection-feedback.md` | `pending` | 双文档、来源、确认依据是否通过检测 |
| 4 | Figma 设计稿计划 | `01-需求/figma-design-plan.md` | `pending` | 设计计划是否已生成并补齐设计稿 |
| 5 | 技术方案 | `02-技术方案/tech-plan.md` | `pending` | 总体架构、模块边界与接口是否已同步 |
| 6 | 工作时长评估 | `02-技术方案/effort-estimate.md` | `pending` | 三点估计、关键路径与里程碑是否已生成并被用户确认 |
| 7 | 前端 Flutter 技术文档 | `03-前端/flutter-tech.md` | `pending` | 前端实现口径是否已同步 |
| 8 | 后端技术文档 | `04-后端/java-tech.md` / `04-后端/kotlin-tech.md` | `pending` | 接口、数据结构、同步策略是否已同步 |
| 9 | Flutter 总体开发计划 | `03-前端/flutter-dev-plan.md` | `pending` | 前端任务顺序、恢复点、验收路径是否已同步 |
| 10 | 后端总体开发计划 | `04-后端/java-dev-plan.md` / `04-后端/kotlin-dev-plan.md` | `pending` | 后端任务顺序、恢复点、验收路径是否已同步 |
| 11 | Flutter 模块开发文档 | `03-前端/开发计划/*.md` | `pending` | 前端模块级计划是否已补齐 |
| 12 | 后端模块开发文档 | `04-后端/开发计划/*.md` | `pending` | 后端模块级计划是否已补齐 |
| 13 | Flutter 编码 | `{frontendRepo}` | `pending` | 阻塞式代码开发阶段；前置文档确认后执行完整实现 |
| 14 | Java 编码 | `{backendRepo}` | `pending` | 阻塞式代码开发阶段；进入后持续修改和调试直至真实验收 |
| 15 | 联调与测试 QA | `05-联调与测试/qa-plan.md` | `pending` | 联调矩阵 / 测试用例 / 缺陷登记 / 验收报告是否完成 |
| 16 | 构建与打包 | `06-构建打包/{build-plan.md,android.md,ios.md}` | `pending` | 签名、版本号、CI、发布包是否就绪 |
| 17 | 应用商店上架 | `07-应用上架/release-checklist.md` 等 | `pending` | 商店素材、隐私政策、合规材料是否齐全 |
| 18 | 发布与版本管理 | `08-发布版本/{release-plan.md, changelog.md}` | `pending` | 灰度策略、用户面向 changelog、回滚预案 |
| 19 | 上线监控与迭代 | `09-上线监控/{monitoring-plan.md, feedback-loop.md}` | `pending` | 监控接入、反馈回流 |

---

## 4. 当前变更登记

> 列出 `change-plan.md` 中所有 `pending` 与 `in_progress` 的变更条目。
> 每次新增 / 完成变更条目时，同步本表。

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 | 备注 |
|--------|------|------|--------|------|----------|------|
| `CHG-0001` | `{示例：新增夜间模式}` | `feature_add` | `v0.1.0` | `pending` | 13 Flutter 编码 | 详见 `change-plan.md` |

---

## 5. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、变更管控、架构门禁 |
| `{步骤规则文件}` | 当前步骤执行规则 |

---

## 6. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `{项目文件路径}` | `{为什么需要读取}` | 是 |

---

## 7. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `{项目文件路径}` | `pending` | `{产物说明}` |

---

## 8. 上架就绪检查表（进入 17 阶段前必须全绿）

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 15 联调与测试 QA 通过（P0/P1 全部修复并回归） | ☐ | |
| `change-plan.md` 顶部「进行中变更」区块为空 | ☐ | |
| `change-log.md` 当前版本号已确定 | ☐ | |
| Android AAB / APK 已生成并测试安装通过 | ☐ | |
| iOS IPA 已生成并 TestFlight 通过 | ☐ | |
| 签名配置正常，无过期证书 | ☐ | |
| 隐私政策已就绪并 URL 可访问 | ☐ | |
| 商店素材（图标 / 截图 / 描述 / 关键词）已就绪 | ☐ | |
| 第三方 SDK 合规清单已在隐私政策声明 | ☐ | |
| 国内商店：ICP/MIIT 备案、软著（如需要） | ☐ | |

---

## 9. 额外注意事项

- `{需要在当前步骤中特别注意的点}`
- 需求变更先更新 PRD 再同步 Review；“下一步”不等于全部待确认项已批准。技术方案与编码前执行核心规则 4.4 门禁。
- 文档生成状态、正式检测结论和产品决策确认分开记录；高风险事项未关闭时保持 `waiting_review`，不自动进入技术方案/编码。
- 总体流程列表必须优先反映“当前版本真实完成度”，不能只记录历史上曾完成过的阶段。
- 需求、技术方案、前端技术文档、后端技术文档、开发计划必须以主路径作为当前真源；旧版本只能进入 `archive/` 并标记为 `archived/reference-only`，不能作为编码执行依据。
- 13 Flutter 编码、14 Java 编码都属于阻塞式代码开发阶段；如果用户没有明确说「进入下一步」，默认保持在当前编码步骤内持续修改、调试和回写状态，不自动推进到下一个流程项。
- 15 联调 → 16 构建 → 17 上架 → 18 发布 → 19 监控 是串行强门禁，前一项未达验收不允许进下一项。

---

## 10. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 无 | 无 | 无 |

---

## 11. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| `{阶段名}` | `{产物路径}` | `done` | `{备注}` |

---

## 12. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| `{YYYY-MM-DD}` | `{阶段/步骤}` | `{执行内容}` | `{结果}` |
