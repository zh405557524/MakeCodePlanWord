# 喵喵穿搭 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录当前流程进度、恢复点、依赖文件和生成文件。  
> 维护规则：每次生成、修改、检测或编码完成后更新本文档。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `喵喵穿搭` | 工作空间根目录名 |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/喵喵穿搭` | 唯一允许写入流程文档的项目工作区 |
| `currentVersion` | `v0.1.0` | 首版需求版本 |
| `iterationMode` | `initial_full_development` | 初版全量开发 |
| `baseArchiveVersion` | `none` | 初版无历史归档 |
| `currentRequirementEntry` | `01-需求/requirements.md` | 当前需求主入口 |
| `currentRequirementReviewEntry` | `01-需求/requirements-review.md` | 产品负责人快速审核入口，不代替完整 PRD |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md` | 当前技术方案主入口 |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | 当前 Flutter 计划主入口 |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md` | 当前后端计划主入口 |
| `currentQAPlanEntry` | `05-联调与测试/qa-plan.md` | 测试设计主入口；已完成多轮前置测试，不代表进入正式 QA 阶段 |
| `archiveIndex` | `archive/` | 历史快照目录 |
| `referenceProject` |  | 暂无参考代码工程 |
| `frontendRepo` | `/Users/soul/code/lxwx/catoutfit` | 喵喵穿搭 Flutter 工程；本轮仅作 CHG-0010～0013 独立缺陷维护 |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | 共享 Java 后端，App Code `catoutfit`；本轮只读核对 |
| `flutterChannel` | `stable` | 规划值，编码前确认 |
| `backendFramework` | `Spring Boot` | 规划值，技术方案阶段确认 |
| `backendBuildTool` | `Gradle` | 规划值，技术方案阶段确认 |
| `targetStores` | `AppStore, Android 应用市场` | 具体 Android 渠道待确认 |

## 1.1 当前主文档入口与归档索引

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 需求清单 | `01-需求/requirements-list.md` | `active` | 需求分析阶段真源 |
| 需求文档 | `01-需求/requirements.md` | `active` | 当前 PRD 真源 |
| 产品 Review | `01-需求/requirements-review.md` | `active` | v0.1.0-draft.5 快速审核层；25项穿搭产品决策待确认 |
| 原始材料索引 | `01-需求/references/README.md` | `active` | 老板文档和 Figma 材料索引 |
| 需求检测反馈 | `01-需求/detection-feedback.md` | `pending` | 进入需求检测后创建 |
| Figma 设计计划 | `01-需求/figma-design-plan.md` | `pending` | PRD 检测通过后创建 |
| 测试用例与 QA 计划 | `05-联调与测试/qa-plan.md` | `planning_only / partial_pre_qa_execution` | 正式152条用例未逐条裁决；前置执行仍为 FAIL/INCOMPLETE，第15阶段保持 pending |
| 优先批次可执行用例 | `05-联调与测试/test-cases-executable.md` | `partial_design` | 原152个编号中46个已补前置、素材、步骤、判据和实测子路径；106个尚待细化 |
| AI 辅助测试执行记录 | `05-联调与测试/test-execution-record.md` | `done` | 记录自动测试、iOS只读冒烟、Android素材链路、后端阻塞、证据和未执行边界 |
| Android 素材真机执行记录 | `05-联调与测试/material-test-execution-record.md` | `done_with_defect` | TEST真机代表链路10 PASS / 1 FAIL；发现 DEF-0004 |
| Android 当前包前置复测记录 | `05-联调与测试/retest-execution-record-20260929.md` | `done_with_defect` | P01～P30逐页区分失败、局部验证和未运行；5个页面/子入口不合格，新增 DEF-0005 |
| iPhone 图片上传前置实测 | `05-联调与测试/ios-image-upload-execution-record-20260929.md` | `partial_pre_qa_execution` | Soul 1.0.1(2)：人物正/负预检、档案、免费普通导入三件衣物及试衣选衣局部通过；账号差异已说明并清理本轮4条数据；非正式QA |
| Android 混合测试前置执行 | `05-联调与测试/android-hybrid-smoke-execution-20260929.md` | `partial_pre_qa_execution` | 已安装 1.0.1(2) 页面/未勾协议/低额商品门禁；真实付款与选图未执行，不推进第15阶段 |
| Android 冒烟脚本 | `05-联调与测试/android-smoke/README.md` | `active` | 脚本、纯解析单测与说明统一在工作台；Flutter 工程旧位置不再是执行入口 |
| Android 1.0.2 页面脚本报告 | `05-联调与测试/android-smoke/runs/20260930-01/results.md` | `partial_pre_qa_execution` | 25 PASS / 8 SKIP / 0 FAIL；仅页面子路径，真实支付/图片链路未运行 |
| AI 合成测试素材 | `05-联调与测试/test-materials/20260928/README.md` | `ready_and_executed` | 9张人物/衣物/负向素材及压缩包；已导入iOS模拟器和Android真机并完成代表性实测 |

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `02 需求文档生成` |
| 当前步骤 | `评审 v0.1.0-draft.5 的穿搭专属待确认项` |
| 当前步骤状态 | `waiting_review` |
| 当前恢复点 | `CHG-0010～0013 独立缺陷维护中；P08/P11 图片问题由另一方修复；P0-01 容量已按后端100件关闭，其余25项仍待评审` |
| 下一步默认动作 | `等待可追溯设备包复测 DEF-0001/0002/0003/0005；产品逐项回答剩余25项专属问题，高风险未决不能推进技术方案或常规编码流程` |

## 3. 总体流程列表

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `change-plan.md` | `done` | CHG-0001～0009 已完成，记录移入历史区并同步 change-log |
| 1 | 需求分析 | `01-需求/requirements-list.md` | `done` | 已结合老板文档与 Figma 整理 |
| 2 | 需求文档生成 | `01-需求/requirements.md` + `01-需求/requirements-review.md` | `waiting_review` | v0.1.0-draft.5 已同步后端100件容量；25项穿搭产品决策未获逐项批准 |
| 3 | 需求文档检测 | 检测报告 + `01-需求/detection-feedback.md` | `pending` | 未执行完整检测；本轮结构自检不等于正式 PASS |
| 4 | Figma 设计稿计划 | `01-需求/figma-design-plan.md` | `pending` | PRD 检测通过后执行 |
| 5 | 技术方案 | `02-技术方案/tech-plan.md` | `pending` | 未开始 |
| 6 | 工作时长评估 | `02-技术方案/effort-estimate.md` | `pending` | 未开始 |
| 7 | 前端 Flutter 技术文档 | `03-前端/flutter-tech.md` | `pending` | 未开始 |
| 8 | 后端技术文档 | `04-后端/java-tech.md` | `pending` | 未开始 |
| 9 | Flutter 总体开发计划 | `03-前端/flutter-dev-plan.md` | `pending` | 未开始 |
| 10 | 后端总体开发计划 | `04-后端/java-dev-plan.md` | `pending` | 未开始 |
| 11 | Flutter 模块开发文档 | `03-前端/开发计划/*.md` | `pending` | 未开始 |
| 12 | 后端模块开发文档 | `04-后端/开发计划/*.md` | `pending` | 未开始 |
| 13 | Flutter 编码 | `{frontendRepo}` | `pending` | 常规第13阶段未开始；独立缺陷维护已按 Flutter 工程规则执行 |
| 14 | Java 编码 | `{backendRepo}` | `pending` | 未加载编码规则，尚未进入编码阶段 |
| 15 | 联调与测试 QA | `05-联调与测试/qa-plan.md` + `test-cases-executable.md` | `pending` | 152条为覆盖检查点，46条已细化、106条待细化；仍有缺陷与大量未执行项，未开始正式 QA |
| 16 | 构建与打包 | `06-构建打包/` | `pending` | 未开始 |
| 17 | 应用商店上架 | `07-应用上架/` | `pending` | 未开始 |
| 18 | 发布与版本管理 | `08-发布版本/` | `pending` | 未开始 |
| 19 | 上线监控与迭代 | `09-上线监控/` | `pending` | 未开始 |

## 4. 当前变更登记

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 | 备注 |
|--------|------|------|--------|------|----------|------|
| CHG-0010 | 会员权益与容量对齐 | feature_modify | v0.1.0 | in_progress | 02 / 独立维护 | 仅对齐已实现后端，不新增权益 |
| CHG-0011 | 衣物编辑按钮文案 | feature_modify | v0.1.0 | in_progress | 02 / 独立维护 | 不触碰 P08/P11 图片加载 |
| CHG-0012 | Debug 环境断言 | feature_modify | v0.1.0 | in_progress | 02 / 独立维护 | 保持默认 TEST |
| CHG-0013 | iOS 冒烟协议定位 | feature_modify | v0.1.0 | in_progress | 02 / 独立维护 | 不改变登录业务逻辑 |

## 5. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 工作空间定位、流程状态和阶段门禁 |
| `.cursor/rules/02-需求文档生成.mdc` | PRD 固定结构和页面模板 |
| `.cursor/rules/templates/requirements-review.md` | Review 固定11章、来源标记、决策和场景模板 |
| `.cursor/rules/03-需求文档检测.mdc` | 下一阶段的检测维度 |
| `.cursor/rules/15-联调与测试QA.mdc` | 本次提前编写测试用例时的 QA 门禁、矩阵和报告规范 |
| `.cursor/rules/templates/qa-plan.md` | 测试计划与缺陷/验收模板 |

## 6. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `01-需求/requirements-list.md` | 用户已授权据此生成文档；具体假设/商业规则并未逐项批准 | 是 |
| `01-需求/requirements.md`、`01-需求/requirements-review.md` | 同版本完整真源与产品审核层 | 是 |
| `01-需求/references/README.md` | 原始材料与 Figma 来源索引 | 是 |
| `/Users/soul/Downloads/喵喵穿搭产品需求文档V1.1详细研发版.docx` | 老板提供的产品资料 | 是 |
| Figma Channel `beo7uxnz` | 使用2026-08-25提取记录；本轮未连接，截图待导出 | 是 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `catoutfit` 公共后端现状与针对性测试依据；不作为生产部署证明 | 是 |
| `/Users/soul/code/lxwx/catoutfit` | 实际 Flutter 工程；CHG-0010～0013 仅作授权的独立缺陷维护，不代表进入常规第13阶段 | 是 |
| `/Users/soul/code/lxwx/catseller` | 后端未说明客户端体验时的已完成 App 参考；只复用会员公共流程，不复制带货专属业务 | 是 |
| `change-plan.md`、`change-log.md` | CHG-0001～0008 范围与变更记录 | 是 |

## 7. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `workflow.md` | `done` | 当前流程状态 |
| `01-需求/requirements-list.md` | `done` | 需求清单 |
| `01-需求/requirements.md` | `waiting_review` | PRD v0.1.0-draft.5，公共后端/会员参考与穿搭专属需求分层 |
| `01-需求/requirements-review.md` | `waiting_review` | 11章、31逻辑页面/入口、8场景；34个历史编号中9项关闭、25项待确认 |
| `01-需求/references/README.md` | `done` | 原始材料及共享后端实现基线索引 |
| `05-联调与测试/qa-plan.md` | `planning_only / partial_pre_qa_execution` | 31个页面/入口、10个E2E场景；正式152条用例未逐条执行，前置结果 FAIL/INCOMPLETE |
| `05-联调与测试/test-cases-executable.md` | `partial_design` | 原152编号中46条的前置/数据/步骤/判据；106条仍未细化 |
| `05-联调与测试/test-execution-record.md` | `done` | Flutter测试/分析/构建、iOS自动与只读冒烟、Java阻塞和安全边界 |
| `05-联调与测试/material-test-execution-record.md` | `done_with_defect` | Android真机TEST代表链路、积分变化、证据和未覆盖边界 |
| `05-联调与测试/retest-execution-record-20260929.md` | `done_with_defect` | Android 已安装包页面复测、Flutter 自动测试和 Java 测试阻塞分开记录；5个页面/子入口 FAIL |
| `05-联调与测试/ios-image-upload-execution-record-20260929.md` | `partial_pre_qa_execution` | iPhone Soul 实测图片上传局部链路；不代表 P01～P30 或 P08/P11 缺陷关闭 |
| `05-联调与测试/android-hybrid-smoke-execution-20260929.md` | `partial_pre_qa_execution` | ADB 三入口脚本的设备包、账号、价格、页面子路径及未测边界；支付后待用户完成付款 |
| `05-联调与测试/android-smoke/` | `active` | Android 页面与支付门禁脚本、纯解析单测及 README；CHG-0015 从 Flutter 工程归位，逻辑与历史结果不变 |
| `05-联调与测试/defects/DEF-0001.md`～`DEF-0005.md` | `open / source_fixed_pending_device` | DEF-0001/0002/0003/0005 源码维护中但未关闭；DEF-0004 由并行修复方负责 |
| `05-联调与测试/test-materials/20260928/` | `ready_and_executed` | 9张AI合成人物/衣物/负向素材、README和15MB分发压缩包；已完成Android代表性实测 |

## 8. 额外注意事项

- 当前仍处于需求阶段，未进入常规 Flutter/Java 编码流程；本次 CHG-0010～0013 是用户单独授权的缺陷维护。已按 Flutter 工程规则操作；共享后端仅只读核对，未修改 Java 代码或数据库。
- 授权“生成文档”“实施计划”只批准文档工作，不等于批准业务规则。用户已明确公共及会员逻辑以后端为准、缺失客户端体验参考喵喵带货；新增依据后端统一100件关闭 P0-01，合计9项关闭、25项仍无逐项产品确认记录。
- 参考 App 只提供公共流程证据。喵喵带货的高阶模型、配音、商品分析等专属权益，以及喵喵穿搭当前残留的“让带货更简单”文案，均不得写入正式穿搭需求。
- “材料已写明”“AI推导”“用户明确确认”分别记录，尤其免费失败恢复、游客准备、作品起算等原文已有规则不能再称完全未定义。
- 新工作台规则已要求 PRD/Review 同步与确认门禁；不回填其他项目，不修改原始Word或Figma。
- 本轮仅做文档结构/一致性自检，第03阶段正式检测仍未执行；12组页面截图待导出，不能标记设计完成。
- CHG-0003 静态自检：双文档31个逻辑页面对应、26个有效待确认问题逐字同步、8个关闭编号同步、8个指定场景齐全；工作区路径审计通过。Review 约5400汉字；Mermaid 未做视觉渲染。
- CHG-0005 前置执行显示：Flutter 268/269条通过，静态分析和双端Debug构建通过；iOS自动冒烟失败、只读UI发现1个会员权益缺陷；Java穿搭定向测试被共享工程其他模块的测试编译错误阻断。
- CHG-0006 已准备9张AI合成测试图并导入iOS模拟器与Android真机；CHG-0007 已验证人物预检、衣橱解析、成功扣分、首次免费搭配和作品落库。所有素材均非真人且无品牌。
- 前置测试不是正式验收：仅有一台Android真机的一条成功生成代表链路和一轮页面只读抽查；失败退款、支付、删除、更多AI模块、iOS真机、弱网、性能、无障碍、Figma像素对比及152条设计用例逐条裁决仍未执行，因此第15阶段保持 `pending`，正式通过率为 N/A。
- CHG-0008 审计确认：原152条主要是覆盖检查点，并非152条可直接执行的完整用例；46条优先批次已补详细步骤，DEF-0004 有回归路径，但106条及未决产品规则仍是测试设计缺口。
- CHG-0009 前置复测：Android 已安装包在 P08/P11 仍有一件衣橱缩略图无法自动加载，P20/P21 会员权益与统一100件后端容量冲突；P09 新发现编辑按钮文案不符（DEF-0005）。Flutter 269 PASS / 1 FAIL，Java 穿搭定向测试执行0条；本轮未重新构建安装包，不能把源码结果等同于设备包结果。
- 本轮对账确认当前后端存在衣橱100件、档案5个、作品留存15天和会员/积分商品目录；衣橱100件已同步 PRD/Review，其他未决行为仍需产品判断。
- 产品文档与 Figma 冲突处统一保留为 `TBD`，未获得产品负责人确认前不得作为开发常量。
- Figma 中存在“喵喵写歌”“喵喵带货”“音乐生成”等跨项目残留文案，不能作为需求依据。
- 原始人物照片、身体参数和试妆照片属于高敏感个人数据，后续设计、技术方案和合规评审必须重点处理。

## 9. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 个人档案字段和照片类型不一致 | 影响页面、数据模型和 AI 输入 | 产品负责人确定必填/选填范围 |
| AI 妆容原型覆盖不完整、原文多品类规则尚未确认是否沿用 | 无法完整验收 | 先作 P0-07 决策再补原型，不擅自删范围 |
| 当前穿搭专属规则尚未确认 | 影响首免、游客本机准备、AI任务计费/返还、留存及范围；衣橱统一100件已定 | 通过 Review 25项逐条决定；公共/会员规则不再重复审核，有来源仍不等于已批准 |
| Figma本轮未连接且页面截图未落盘 | 设计素材追溯未完成，不能正式通过设计要求 | 恢复连接后按页面状态导出并嵌入，不造失效链接 |
| 会员页旧包宣称高清保存、优先生成和500件衣橱，后端没有对应权益契约 | 旧安装包仍可能误导付费用户 | DEF-0001 源码已移除，等待新构建设备回归 |
| Flutter Debug 旧注释和测试与默认TEST环境不一致 | 旧测试失败且环境可能误判 | DEF-0002 源码断言已修，等待完整回归结果 |
| iOS 预发布冒烟脚本曾使用已移除的控件类型 | 自动冒烟无法继续验证后续安全链路 | DEF-0003 已改稳定 Key，等待隔离模拟器重跑 |
| AI解析衣物保存后衣橱缩略图不会自动加载 | 影响衣橱主路径浏览；多件导入需逐张手动重试 | 处理 DEF-0004，补首屏加载恢复与有限自动重试后回归 |
| 并行私有图片上传改动使全量 Flutter 套件的发型模板用例报缺 OSS 直传凭证 | 本轮全量单并发 271 PASS / 1 FAIL，不能宣称全绿 | 由 P08/P11 图片修复方核对上传契约与测试夹具；本轮不跨工程或覆盖其改动 |
| 已有衣物编辑页旧包主按钮写“加入衣橱” | 与实际更新动作不符，用户可能担心重复新增 | DEF-0005 源码已改，等待同一新包回归编辑保存与数量不变 |
| 原152条覆盖清单尚未全部细化 | 正式 QA 无法逐条按统一数据/步骤/判据执行 | 先用 `test-cases-executable.md` 执行优先批次；需求与接口冻结后补齐剩余 P0/P1，仍不得写成“全部完成” |
| Java 定向测试被喵喵带货测试源码编译错误阻断 | 穿搭后端测试实际执行0条 | 修复共享测试编译问题后原命令重跑，不以本次阻塞判定穿搭后端通过或失败 |

## 10. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 01 需求分析 | `01-需求/requirements-list.md` | `done` | 2026-08-25 完成 |

## 11. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-08-25 | 01 需求分析 | 解析老板文档与 Figma 全画布，整理需求和冲突 | 完成 |
| 2026-08-25 | 02 需求文档生成 | 登记项目、创建标准工作区并生成 PRD 首版 | 等待评审 |
| 2026-08-28 | CHG-0001 / 02 | 新增 Product Review、对照 Word 同步 PRD 与来源状态；更新工作台双层规范及门禁 | 文档工作完成；11项静态自检、门禁规则走查、路径审计通过；waiting_review，未作正式03检测或业务批准 |
| 2026-09-02 | CHG-0002 / 02 | 只读核对 `catoutfit` 共享后端，按现有公共逻辑重整 PRD、Review、清单、来源和工程映射 | 2项公共问题关闭、32项穿搭问题待确认；4组针对性测试及文档一致性/路径审计通过；仍为 waiting_review |
| 2026-09-02 | CHG-0003 / 02 | 会员逻辑全部以后端为准；后端未覆盖的客户端状态只读参考已完成的喵喵带货 | 新增关闭6项会员问题，合计8项关闭、26项待确认；双文档一致性与路径审计通过；仍为 waiting_review |
| 2026-09-27 | 独立 Flutter 缺陷修复（不推进项目流程） | 修复首页“新人见面礼”弹窗固定高度导致的底部溢出；补截图尺寸与矮屏大字体回归 | `flutter test test/home_feature_test.dart`、`flutter analyze`、`git diff --check` 通过；未做真机验收，当前需求评审阶段保持 `waiting_review` |
| 2026-09-28 | CHG-0004 / 测试设计 | 基于 PRD draft.4 生成测试用例与 QA 计划，分离公共后端回归、穿搭当前业务和待确认期望 | 测试设计完成，全部结果 not_run；未满足 QA 入场门禁，阶段02/waiting_review 与阶段15/pending 均保持不变 |
| 2026-09-28 | CHG-0005 / AI辅助前置测试 | 参考喵喵写歌分层执行Flutter测试/分析/构建、iOS自动与只读冒烟、Java定向测试启动检查 | FAIL/INCOMPLETE；3个缺陷open、后端测试blocked；未执行真实高风险链路，阶段02/waiting_review 与阶段15/pending 不变 |
| 2026-09-28 | CHG-0006 / 测试素材 | 使用内置图像生成准备正向人物、单品/多单品和负向人物素材，打包并导入iOS模拟器 | 9张PNG格式/大小检查通过，模拟器相册15张中确认9张新素材可见；未执行真实生成或实体机导入，项目阶段不变 |
| 2026-09-28 | CHG-0007 / 素材真机实测 | 使用TEST测试用户在Android真机执行人物预检、衣橱解析、积分和首次免费搭配生成 | 10 PASS / 1 FAIL；余额1030→1020，免费生成不扣分；登记DEF-0004，阶段02/waiting_review与阶段15/pending不变 |
| 2026-09-28 | CHG-0008 / 测试设计补充 | 审计152条检查点，新增优先批次可执行明细，映射实测子路径和DEF-0004，修正100件容量样本 | 只补测试文档，不新增实测通过；保留02/waiting_review与15/pending |
| 2026-09-29 | CHG-0009 / 前置复测 | Android TEST 已安装包按 P01～P30 逐页抽查；Flutter 全量测试/静态分析；Java 穿搭定向测试启动 | 5个页面/子入口有3个缺陷，新增DEF-0005；Flutter 269 PASS / 1 FAIL，Java 用例 0 条执行；阶段02/waiting_review与15/pending不变 |
| 2026-09-29 | CHG-0010～0013 / 独立缺陷维护 | 修 P20/P21 会员承诺、P09 编辑按钮、Debug 环境断言及 iOS 冒烟协议定位；同步 PRD/Review 统一100件和 QA/缺陷记录 | Flutter 全量不稳定，单并发仍有并行上传路径用例1项失败；静态分析通过。iOS 隔离模拟器越过旧定位点但整条冒烟未完成；四项缺陷仍待新包设备回归，02/waiting_review 与15/pending不变 |
| 2026-09-29 | iPhone 图片上传前置实测 | Soul 1.0.1(2) 用 AI 合成素材测人物正/负预检、建档、免费普通导入三件衣物、衣橱缩略图和试衣相册选衣；发现账号不同后经用户同意仅清理本轮4条数据 | 已覆盖子路径未见 FAIL；余额 7933 分未变；构建来源/后端环境未证实，AI 解析和 P01～P30 全量未执行；02/waiting_review 与15/pending不变 |
| 2026-09-29 | CHG-0014 / Android 混合前置测试 | 在已安装 1.0.1(2) 上新增并运行 ADB 页面、未勾协议和低于 ¥1 的付款前门禁；复杂图片/AI 与真实付款保留人工 | 页面仅局部裁决；会员按钮定位误报已修并复测；商品 ¥0.01、账号与包哈希已核，未证实请求主机且无真实新订单，支付后 `SKIP`；02/waiting_review 与15/pending不变 |
| 2026-09-30 | CHG-0015 / 测试工具路径归位 | 将 Android 冒烟脚本、单测和 README 迁入 `05-联调与测试/android-smoke/`，同步当前文档入口并移除 Flutter 工程旧副本 | 新位置6个单测通过；当前手机包已变1.0.2(102)，旧版门禁 `BLOCKED`，未重跑页面/支付；02/waiting_review 与15/pending不变 |
| 2026-09-30 | CHG-0016 / 当前包页面脚本复跑 | 用显式版本参数核对1.0.2(102)，在Android当前账号执行pages并保存工作台报告 | 25 PASS / 8 SKIP / 0 FAIL，退出码0；6个脚本单测通过。图片/AI/真实付款未测，缺陷未关闭；02/waiting_review与15/pending不变 |
