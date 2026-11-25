# 喵喵写歌工作空间流程历史快照

> `reference-only`。这是 2026-09-13 第 9/10 步总体开发计划生成后的原 `workflow.md` 全文快照。历史相对链接按当时位置保留；当前恢复点以项目根目录的 `workflow.md` 为准。

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录当前流程进度、总体流程列表、恢复点、需加载规则、依赖文件、变更登记和注意事项。
> 2026-09-13 当前阶段记录：用户要求下一步，CHG-0076 第 7/8 步技术文档作为输入记 `done`；已生成本版第 9 步 Flutter/Web 总体开发计划与第 10 步 Java 总体开发计划，均为 `waiting_review`。第 11/12 步模块文档尚未生成，三端代码、数据库及线上配置未改；`implementationPhase=skeleton_pending`，旧 CHG-0073 的骨架批准不适用本版本。
> 2026-09-13 第 7/8 步历史记录：用户要求继续，CHG-0076 第 6 步条件排期记 `done`；已生成同版本第 7 步 Flutter/Web 技术文档与第 8 步 Java 技术文档，当时状态为 `waiting_review`。当时第 9～12 步尚未生成；三端代码、数据库及线上配置未改。
> 2026-09-13 第 5～6 步历史记录：用户要求继续，CHG-0076 第 5 步当前技术方案记 `done`，当时进入第 6 步工时评估 `waiting_review`。新排期按一名 AI 辅助跨端开发者、8 小时/天估算 6.5 个工作日，包含三端可运行骨架、真实实现、后台配置、Android/iOS 用户测试和 Bug 修复；骨架必须单独经用户明确确认才可进入真实实现。旧 CHG-0073 的编码批准不转移到新版本。当时未改三端业务代码、数据库或线上配置。
> 2026-09-13 CHG-0077 归档时状态：旧版 01～04 阶段需求、技术方案、前后端技术/总体/模块计划与旧截图索引已移至 `archive/CHG-0077-legacy-docs-20260913/`，原相对目录保留，状态 `reference-only`。归档当时第 7～12 步文档未生成、恢复点为第 6 步 `waiting_review`；此后第 7/8 步已重新生成。未改三端代码、数据库、线上配置或并行 QA。
> 2026-09-13 上一阶段记录：用户要求继续，第 3 步新版需求检测 PASS 已确认并记 `done`；第 4 步沿用当前 Figma `vn7k0jqv`、状态 `skipped`，不修改设计稿。第 5 步已生成 `02-技术方案/v2.1-model-driven-params/tech-plan.md`，当时状态 `waiting_review`；技术方案以真实三端代码对账，训练素材仅按厂家硬限制、动态数值按模型和后台配置处理，未核实的算道同厂音色兼容仍为技术待办。该记录不表示三端实现已符合新需求。
> 2026-09-13 上一阶段记录：CHG-0076 V2.1 新需求第 3 步正式检测 PASS，当时为 `waiting_review`；用户随后要求继续，现已记 `done`。视觉真源仍为 Figma `vn7k0jqv` / `working (91:106)`，21 张本地图仅是导出快照；第 4 步 `skipped`，Figma 原稿不改。训练素材只按厂家硬限制校验，算道音色只供算道实际兼容模型；同厂 SoVITS/Suno 写歌兼容待技术核验。此记录不表示产品发布批准或三端实现已符合新需求。
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

> 2026-09-09 本轮记录：用户明确确认“骨架已确认，开始真实实现”，解除 CHG-0073 的真实编码门禁。Flutter T-F001-R 至 T-F010-R、Java T-B001-R 至 T-B013-R 已完成本地实现和规定验证，当前 `implementationPhase=real_review`；T-B014-R、部署后完整业务联调及 Android 真机验收仍待执行，Web/Admin 页面继续 `deferred`。最新 Figma 通道为 `p354jft5`，文件「working」、页面 `working (91:106)`，38 个有效 Frame 和 1 个非页面 Group 继续作为移动端视觉真源。

> 2026-09-09 本轮记录：完成 CHG-0075“先可运行骨架、后真实实现规范”。全局核心流程、模板、Flutter/Java 编码规则和两端工程规则已增加 `skeleton_first` 双阶段门禁；CHG-0073 的总体计划、模块索引和 28 份模块文档已拆为 `-S/-R`。当前保持第 11/12 步 `waiting_review`，`implementationPhase=skeleton_pending`；本轮未修改 Flutter/Java 业务代码、数据库或 Web/Admin 页面。

> 2026-09-09 本轮记录：用户继续下一步，视为第 9/10 步总体开发计划评审通过。已按同版本计划生成第 11 步 Flutter/Web 15 份模块开发文档和第 12 步 Java 15 份模块开发文档，覆盖契约、入口、页面、采集、审核、训练、翻唱、作品、Admin、测试、部署及真实厂家闭环。模块文档契约扫描通过，当前 `waiting_review`；未修改三端业务代码。

> 2026-09-09 本轮记录：用户确认继续，并提供当前 Figma 通道 `ujnpl6tr`。已只读核验文件「音乐」、页面 `working (91:106)`，仍为 38 个有效 Frame 和 1 个非页面 Group，与本地导出一致。第 7/8 步技术文档记为 `done`；已生成第 9 步 Flutter（含 Web/Admin）总体开发计划和第 10 步 Java 总体开发计划，任务分别对齐 T-F001～T-F010、T-W001～T-W008、T-B001～T-B014，当前状态 `waiting_review`。尚未生成模块开发文档，未修改三端业务代码。

> 2026-09-09 本轮记录：用户在 7 个 AI 工作日排期补齐后要求继续下一步，视为第 6 步工时评估通过。已按当前 `v2.1-ai-cover-voice-clone` 需求、技术方案、Figma 真源和三端代码基线完成第 7 步 Flutter 技术文档与第 8 步 Java 技术文档；移动端与 Web/Admin 交互、独立 `/api/song-voice-covers`、`voicecover/` 领域边界、真实 `provider/model`、多渠道绑定、资源审核、积分、最小数据库增量及测试门禁均已写清。当前第 7/8 步状态 `waiting_review`；尚未生成当前版本总体/模块开发计划，也未修改三端业务代码。

> 2026-09-09 本轮记录：用户要求继续下一步。第 5 步技术方案已完成评审收口，并按当前 Flyway、实体、资源台账和作品生命周期实现把数据库变更收缩为 7 张声音克隆领域表、生成任务 6 个必要字段和作品 2 个必要引用，不重复扩展素材、资源、歌曲任务或生命周期体系。现进入第 6 步工作时长评估；用户要求按 Codex 直接写代码的真实速度计算，并明确必须包含后端配置、真实音色训练、完整测试和 Bug 修改。当前排期统一为 7 个 AI 工作日，不再使用多人累计人天口径，状态 `waiting_review`；未修改三端业务代码。

> 2026-09-09 本轮记录：用户最终确认音乐生成与翻唱声音克隆应在公开接口层区分。CHG-0073 已统一改为独立 `POST /api/song-voice-covers`、`GET /api/song-voice-covers/{id}`、`GET /api/song-voice-covers/active`；创建请求不传 `mode`，`SongVoiceCoverController` 固定内部 `VOICE_COVER` 后委托共享歌曲任务编排，真实 `provider/model` 仍来自后台模型配置。AI 写歌 `/api/song-generations`、AI 改编 `/api/song-covers` 和旧 `cover/` 均保持不变。第 5 步继续 `waiting_review`，未修改三端业务代码。

> 2026-09-09 本轮记录：用户确认翻唱声音克隆是独立业务，要求像现有 `cover/` 一样建立独立 Java 目录。技术方案已调整为新增同级 `app/catsinger/voicecover/`：新目录拥有声音资料、训练、渠道绑定、专属校验和工作流步骤实现，任务、工作流引擎、模型路由、审核、积分、资源、作品和 Admin 基础设施继续共用；现有 `cover/` 不修改。该记录发生在 D-U09 公开接口最终校准之前，当前创建入口以 `/api/song-voice-covers` 为准。第 5 步保持 `waiting_review`，未创建代码目录。

> 2026-09-09 本轮记录：D-U08 中间口径曾暂定新功能使用 `POST /api/song-generations` 并传 `mode=voice_cover`，同时确认 `provider/model` 必须使用模型列表返回的真实厂家编码，不能把业务类型当作模型。其模型字段结论继续有效，公开接口部分已由 D-U09 的独立 `/api/song-voice-covers` 最终口径替代。现有 AI 改编 `/api/song-covers` 始终保持原样。

> 2026-09-09 本轮记录：用户校准翻唱处理的 10 分钟起点。平台任务处于平台侧排队时不启动生成倒计时，也不能因排队超过 10 分钟报生成失败；只有厂商确认接单并返回可查询任务标识后才开始计时，厂商侧排队、生成、平台资源持久化、探测、成品审核和作品完成均计入。需求与技术方案已回卷，仍停在第 5 步 `waiting_review`，未修改业务代码。

> 2026-09-08 本轮记录：用户确认 V2.1 新功能正式产品展示名为「翻唱声音克隆」，避免继续与现有 AI 改编混淆。需求、技术方案、Figma 资源说明和流程入口已统一名称；原始 DOCX/Figma 名称只作溯源，`VOICE_COVER`、场景编码、页面路由和版本目录等内部技术标识保持不变；生成 API 与模型字段在 2026-09-09 另行校准。当前仍停在第 5 步 `waiting_review`，未修改业务代码。

> 2026-09-08 本轮记录：用户明确生成歌曲、AI 改编、翻唱声音克隆是三个独立业务，但共用同一歌曲业务流程；现有 AI 改编保持原样，CHG-0073 不改名称、入口、页面、接口、配置、任务、数据或交互。已只读核验 Java 与 Admin：V2.1 只在当前资源/审核、歌曲生成任务与工作流、模型/场景路由/模型选项、积分、作品、AI 运维和角色权限体系中新增翻唱声音克隆模式及专属步骤；站内 `sourceAudioAssetId`、`sourceWorkId`、`referenceAudioAssetId` 满足上传审核或作品审核事实后，在任务内与现有 AI 改编一致跳过重复源审核。需求文档与技术方案已同步回卷，仍停在第 5 步 `waiting_review`，未修改业务代码。

> 2026-09-08 本轮记录：用户确认 V2.1 完整需求检测 PASS，并明确 Figma 设计稿已经定稿、直接跳过第 4 步。第 3 步已标记 `done`，第 4 步标记 `skipped`，不生成 `figma-design-plan.md`；通道 `dfgz0898` 的 38 个有效 Frame 继续作为 Flutter UI 真源。已完成同版本技术方案，当前停在第 5 步 `waiting_review`，未修改 Flutter、Java 或 Web/Admin 业务代码。

> 2026-09-08 本轮记录：用户指出 P12 播放器 UI 约束不准确。需求已改为直接复用当前 Flutter 工程 `SongPlayerPage`，删除旧截图和自定义布局要求；V2.1 不新增翻唱结果页、不重做播放器，只接入翻唱声音克隆作品数据、审核门禁和重新翻唱动作。流程仍停留在第 2 步 `waiting_review`，未修改业务代码。

> 2026-09-08 本轮记录：用户要求 Web/Admin 需求与产品文档合并维护。W01～W12 共 12 个后台逻辑页面及其字段、按钮、权限、状态、异常恢复与验收口径已完整并入 `requirements.md` P13；独立后台需求文件已移除，避免形成第二份业务真源。Q-A01～Q-A05 等待评审，当前仍为第 2 步需求文档生成 `waiting_review`，本轮不修改三端业务代码。

> 2026-09-08 本轮记录：CHG-0073 Product Review 已收口。用户逐项确认歌曲最长 10 分钟、平台控制并发、翻唱处理 10 分钟超时、不提供取消、多渠道/商家模型切换、主动轮询、真实资源兼容、官方音色资料来源、默认 100/200 积分和低置信度告警放行规则；超时起点已于 2026-09-09 校准为平台排队不计入、厂商确认接单后开始。并新增 D-U07，要求翻唱声音克隆范围内图片、音频和文字上传全部安全审核。三份需求文档已同步回卷，当前恢复点仍为第 3 步完整需求文档检测待执行。本轮不修改三端业务代码，`v1.2.0+121-as-built` 整 App QA 继续并行。

> 2026-09-07 本轮记录：CHG-0071 已把独立测试工程升级为 Android ADB + iOS Appium/XCUITest。默认 smoke 同时执行两端；iOS 真机优先、模拟器兜底、都不存在则 FAIL。iOS 真机 smoke 10/10 PASS，默认双平台 smoke 20/20 PASS；iOS full 为 10 PASS、304 NOT_RUN，总体 `INCOMPLETE`，整 App QA 保持 `in_progress`。

> 2026-09-07 本轮记录：完成 CHG-0070 生成完成播放器目标作品锁定修复。生成页继续按任务返回的 `workId` 跳转，播放器在该作品真正进入播放会话前不再采纳进入页面前的无关当前歌曲；4 条相关 Widget 回归与 `flutter analyze` 通过。仅修改 Flutter Controller 和回归测试，不改接口、后端或数据库，不改变当前第 15 步 QA 主线。

> 2026-09-05 本轮记录：模型配置第 2 版与可选图标已编码；追加 Figma 范围仅为移动端模型入口/弹窗和图标导出，不改三种模式整页。专项验证与未完成的真实浏览器、OSS 匿名访问验收见 [模型选择 UI 历史记录](archive/CHG-0077-legacy-docs-20260913/03-前端/model-option-ui-20260905.md)。不改变当前第 15 步 QA 主线，不自动部署或重启。

> 2026-09-05 追加 UI：创作模型入口去积分（弹窗保留价格），专业模式新增青色“润色歌词”图文按钮；7 项定向测试、静态检查、增量对稿通过。仅改移动端两处组件，不改业务。窄屏整页顶部标签溢出另行记录，原整页/真机验收状态不推进，详见同一 UI 记录的追加章节。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `喵喵写歌` | 工作空间根目录名 |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/喵喵写歌` | 唯一允许写入流程文档的项目工作区；不得按代码仓库当前目录解析相对 `projects/` |
| `currentVersion` | `v2.1` | 产品迭代版本；旧 CHG-0073 本地编码状态不证明 CHG-0076 已实现 |
| `activeDocVersion` | `v2.1-model-driven-params` | 当前唯一可用于 V2.1 新需求评审和后续回卷的文档版本 |
| `iterationMode` | `version_iteration` | 当前为声音克隆翻唱增量迭代，不重新执行初版全量流程 |
| `implementationMode` | `skeleton_first` | 大功能先完成可运行骨架，再经用户整体评审后进入真实实现 |
| `implementationPhase` | `skeleton_pending` | CHG-0076 是新的跨三端改动；旧 CHG-0073 的 `real_review` 仅为历史状态 |
| `skeletonTargets` | `flutter,java,web` | 当前增量覆盖 Flutter、Java 和 Web/Admin，三端均先交可运行骨架 |
| `skeletonRuntime` | `local_test_fixed` | 固定数据只允许 local/test，生产默认关闭 |
| `baseDocVersion` | `v2.1-ai-cover-voice-clone` | 本次需求回卷的旧 V2.1 文档基线；三端实际代码/QA 仍以 `v1.2.0+121-as-built` 等现有记录单独对账 |
| `baseArchiveVersion` | `archive/legacy-20260610/` | 旧 Sonus 参考图只作为差异对照 |
| `currentRequirementEntry` | `01-需求/v2.1-model-driven-params/requirements.md` | 新版 V2.1 完整 PRD 主入口；根路径镜像同步 |
| `currentRequirementReviewEntry` | `01-需求/v2.1-model-driven-params/requirements-review.md` | 新版 Product Review，已作为当前技术方案输入记 `done` |
| `currentRequirementDetectionEntry` | `01-需求/v2.1-model-driven-params/detection-feedback.md` | 第 3 步新版检测 PASS、已按用户要求继续；旧 PASS 不可复用 |
| `currentAdminRequirementEntry` | `01-需求/v2.1-model-driven-params/requirements.md` | Web/Admin 详细需求在新版 PRD P14/W01～W07 |
| `currentTechPlanEntry` | `02-技术方案/v2.1-model-driven-params/tech-plan.md` | 当前第 5 步版本化技术方案已记 `done`；旧 V2.1 方案仅供差异分析 |
| `currentEffortEstimateEntry` | `02-技术方案/v2.1-model-driven-params/effort-estimate.md` | 当前第 6 步工时评估，`done`；根路径为指针 |
| `currentFlutterTechEntry` | `03-前端/flutter-tech.md` | 第 7 步当前版 Flutter/Web 技术文档，`done` |
| `currentJavaTechEntry` | `04-后端/java-tech.md` | 第 8 步当前版 Java 技术文档，`done` |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | 第 9 步当前版 Flutter/Web 总体计划，`waiting_review` |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md` | 第 10 步当前版 Java 总体计划，`waiting_review` |
| `currentFrontendModulePlanEntry` | `03-前端/开发计划/00-module-index.md` | `pending`，当前版尚未生成 |
| `currentBackendModulePlanEntry` | `04-后端/开发计划/00-module-index.md` | `pending`，当前版尚未生成 |
| `currentQaEntry` | `05-联调与测试/cases/v1.2.0+121-as-built/` | 既有版本并行 QA 入口，不是 V2.1 验收入口 |
| `archiveIndex` | `archive/` | 旧版快照归档目录；仅用于追溯、差异对比、回滚和验收争议 |
| `referenceProject` | `/Users/soul/code/lxwx/catsinger` | 当前复制来的 Flutter 参考/目标工程 |
| `frontendRepo` | `/Users/soul/code/lxwx/catsinger` | 前端代码工程位置 |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | 后端代码工程位置 |
| `adminRepo` | `/Users/soul/code/lxwx/lxwx_admin` | Web/Admin 后台管理工程位置 |
| `androidTestRepo` | `/Users/soul/code/lxwx/test/catsinger` | catsinger 独立 Python + ADB 测试工程，可由 PyCharm 直接打开 |
| `iosTestRepo` | `/Users/soul/code/lxwx/test/catsinger` | 同一 Python 工程通过 Appium/XCUITest 执行 iOS 真机/模拟器用户测试 |
| `flutterChannel` | `stable` | Flutter 通道 |
| `backendFramework` | `Spring Boot` | Java 后端框架 |
| `backendBuildTool` | `Gradle` | Java 后端构建工具 |
| `targetStores` | `AppStore, Android 应用市场` | 目标应用商店清单 |

---

## 1.1 当前主文档入口与归档索引

> 工作区主路径永远保存当前最新可执行文档；`archive/` 只保存旧版快照，状态统一为 `reference-only`。
> 旧 `versions/` 目录已归档到 `archive/reference-indexes/v1.0-design-mvp/`，不作为编码或文档更新入口。

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 当前入口说明 | `CURRENT.md` | `active` | 当前主路径入口说明，不指向 `versions/` 或 `archive/` |
| V2.1 新需求清单 | `01-需求/v2.1-model-driven-params/requirements-list.md` | `done` | 三业务与逐模型参数；根路径 `01-需求/requirements-list.md` 为同步镜像，非发布验收 |
| V2.1 新完整 PRD | `01-需求/v2.1-model-driven-params/requirements.md` | `done` | 当前唯一新需求真源；P14 内嵌 W01～W07 后台管理域，非发布验收 |
| V2.1 新 Product Review | `01-需求/v2.1-model-driven-params/requirements-review.md` | `done` | 固定 11 章；未核实厂家能力继续留作技术核验 |
| V2.1 新需求检测 | `01-需求/v2.1-model-driven-params/detection-feedback.md` | `done` | 新版正式检测 PASS，用户要求继续；Figma 原稿不改，旧根路径反馈为历史 |
| V2.1 新技术方案 | `02-技术方案/v2.1-model-driven-params/tech-plan.md` | `done` | 第 5 步已按用户继续要求推进；旧技术方案不得作为本版编码入口 |
| V2.1 当前工时评估 | `02-技术方案/v2.1-model-driven-params/effort-estimate.md` | `done` | 第 6 步增量排期；根路径 `02-技术方案/effort-estimate.md` 指向此版本 |
| V2.1 Flutter/Web 技术文档 | `03-前端/flutter-tech.md` | `done` | 第 7 步；本版逐模型参数 UI、App 接口消费与 Web/Admin 能力收窄设计 |
| V2.1 Java 技术文档 | `04-后端/java-tech.md` | `done` | 第 8 步；本版能力契约、提交复核、模型兼容与共享流程设计 |
| V2.1 Flutter/Web 总体计划 | `03-前端/flutter-dev-plan.md` | `waiting_review` | 第 9 步；T-F001～005 与 T-W001～002 均拆 `-S/-R` |
| V2.1 Java 总体计划 | `04-后端/java-dev-plan.md` | `waiting_review` | 第 10 步；T-B001～006 均拆 `-S/-R` |
| V2.1 当前 Figma 真源 | `vn7k0jqv` / `working (91:106)`；快照索引 `01-需求/references/images/v2.1/model-driven-params/` | `active-design` | 当前线上画面主导视觉与交互；本地 21 图非全部 Frame，也不证明以后没有变化 |
| V2.1 旧需求快照 | `archive/CHG-0076-pre-rewrite/` | `reference-only` | 原 V2.1 三件套及旧根路径原样保留 |
| V2.1 当前前后端模块计划 | `03-前端/README.md`、`04-后端/README.md` | `pending` | 第 11/12 步当前版本模块文档未生成；旧计划已归档，不能据此编码 |
| V2.1 旧技术方案/工时/前后端技术与开发计划 | `archive/CHG-0077-legacy-docs-20260913/` | `reference-only` | 原相对目录保留，只供差异分析 |
| 当前 UI/代码基线 | `05-联调与测试/mobile-code-test-baseline-v1.2.0+121.md` | `base-reference` | V2.1 影响分析使用的三端现状，不代表新功能已实现 |
| 整 App 用例 | `05-联调与测试/cases/v1.2.0+121-as-built/` | `in_progress` | 既有版本 QA 并行执行，不覆盖 V2.1 需求主线 |
| 历史技术/开发文档 | `archive/CHG-0077-legacy-docs-20260913/02-技术方案/v1.1-ai-cover/` 等 | `reference-only` | 只作差异输入；V2.1 编码前必须生成当前版本前后端技术文档和开发计划 |

| 归档目录 | 来源版本 / CHG | 归档内容 | 状态 | 说明 |
|----------|----------------|----------|------|------|
| `archive/legacy-20260610/` | `legacy-20260610` | 旧 Sonus 参考图和早期历史说明 | `reference-only` | 仅在差异对比、回滚、追溯或验收争议时读取 |
| `archive/legacy-20260611-pre-rework/` | `CHG-0011` 前置旧计划 | 返工前 Flutter App 旧模块计划 | `reference-only` | v1.1 不读取该目录作为执行入口 |
| `archive/reference-indexes/v1.0-design-mvp/` | `v1.0-design-mvp` 兼容索引 | 历史版本索引 README | `reference-only` | 保留兼容，不作为当前执行入口 |
| `archive/path-recovery-20260731/` | 错误工作区路径恢复 | 原 catsinger 错误工作区原样快照与 SHA-256 | `reference-only` | CHG-0015～CHG-0040 的来源证据，不作为执行入口 |
| `archive/CHG-0077-legacy-docs-20260913/` | CHG-0077 旧文档整理 | 01～04 阶段旧需求、旧技术方案、前后端旧技术与模块计划和旧截图索引 | `reference-only` | 当前版第 7～10 步已重建；第 11/12 步模块文档仍 pending |

---

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `09 Flutter/Web 总体开发计划 + 10 Java 总体开发计划` |
| 当前步骤 | `CHG-0076 当前版本三端增量总体开发计划待评审` |
| 当前步骤状态 | `waiting_review` |
| 当前恢复点 | `阅读 03-前端/flutter-dev-plan.md 与 04-后端/java-dev-plan.md，核对 T-F001～005、T-W001～002、T-B001～006 的 -S/-R 拆分、依赖、6.5 天共享排期、正式 API 路径及生产禁用门禁；当前均为计划而非已完成代码` |
| 下一步默认动作 | `第 9/10 步评审后生成第 11/12 步当前版 Flutter/Web 与 Java 模块开发文档；模块齐全后才能进入可运行骨架编码。骨架审阅必须单独明确确认，不自动进入真实实现` |

状态枚举：`pending`、`in_progress`、`waiting_review`、`done`、`blocked`、`skipped`。

---

## 3. 总体流程列表

本轮独立变更：`CHG-0067 歌词、封面超时调整与翻唱歌词补齐`。App 和后端实现已完成，Flutter 定向及 analyze、后端全量通过；Flutter 全量因旧测试失败及内存膨胀未完成，已记录的失败均在同依赖旧基线复现。不替换上方 CHG-0066 iOS 验收恢复点，不自动部署或回填历史数据。详细边界、命令和验证记录见 `04-后端/v1.1-ai-cover/开发计划/09-cover-lyrics-backfill.md`。

本轮独立变更：`CHG-0068 场景模型映射与移动端单次任务模型选择`。后端保留 `ai_model_configs` 单场景默认模型逻辑，新增公共场景映射、脱敏查询和任务价格快照；Admin 增加通用映射配置；catsinger 简易、专业、翻唱接入页面级选择；Figma 已基于用户最新修改重新检测并补齐交互说明。该变更不替换上方 CHG-0066 恢复点，不自动执行数据库迁移或写入真实映射配置，详细交付见 `02-技术方案/模型选择-开发交付说明.md`。

本轮独立变更：`CHG-0070 生成完成播放器目标作品锁定`。任务成功跳转仍显式携带后端返回的 `workId`；普通作品播放器在目标作品尚未进入播放会话时忽略既有无关播放歌曲的详情同步，目标作品开始播放后恢复队列切歌联动。该修复不停止原播放、不修改生成接口或歌词数据，不替换当前 CHG-0069 QA 恢复点。

本轮独立变更：`CHG-0071 iOS 真机/模拟器用户自动化与双平台测试门禁`。测试工程新增 Appium/XCUITest，默认命令必须覆盖 Android/iOS；iOS 真机优先、无真机启模拟器、均不可用则整套 FAIL。本轮只修改测试工程和 QA 文档，不修改三端业务代码。

本轮独立变更：`CHG-0072 歌曲改编测试增加成品可播放硬门禁`。歌曲改编正向生成用例只有在目标作品真实生成、播放器开始播放且进度连续增长至少 5 秒后才能 PASS；生成失败、超时、资源缺失/失效或无法播放均判 FAIL。本轮只更新测试用例和 catalog，按用户要求不执行设备测试或修改业务代码。

当前需求主线：`CHG-0076 V2.1 三业务参数随模型变化`。AI 写歌、歌曲改编、翻唱声音克隆继续作为三个独立业务，沿用各自公开入口及共用平台流程；新需求按真实厂家模型返回支持参数，保留不支持设置但置灰并说明，切模型清空无效值和重新报价。D-03 训练建议不作硬门槛，未声明上限不阻断模型开放；D-04 算道训练音色只供算道兼容模型使用，具体模型兼容仍需技术核验。来源为三份新飞书文档、Figma `vn7k0jqv`、算道文档和用户明确补充。旧 CHG-0073 的代码和 38 张旧图只作实现/历史对照；本轮仅文档回卷，旧需求检测 PASS 和技术计划不得证明新需求已实现，现有安装包及并行 QA 结果不改变。

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0-CHG-0076 | 变更登记与旧需求归档 | `change-plan.md`、`archive/CHG-0076-pre-rewrite/` | `done` | 新版 V2.1 需求独立于 CHG-0073 的历史实现 |
| 1-CHG-0076 | 需求清单回卷 | `01-需求/v2.1-model-driven-params/requirements-list.md` | `done` | 三业务逐模型能力规则已回卷；产品发布仍待后续验收 |
| 2-CHG-0076 | PRD 与 Product Review | `01-需求/v2.1-model-driven-params/requirements.md`、`requirements-review.md` | `done` | 13 个 App 逻辑页 + W01～W07；新检测独立执行 |
| 3-CHG-0076 | 新需求检测 | `01-需求/v2.1-model-driven-params/detection-feedback.md` | `done` | 新版文档检测 PASS，用户要求继续；不是功能发布验收 |
| 4-CHG-0076 | Figma 设计稿计划 | 现有 Figma `vn7k0jqv` / `working (91:106)` | `skipped` | 用户明确当前 Figma 即 UI 真源；不重复出稿，本地 21 图是快照，后续按线上节点对稿 |
| 5-CHG-0076 | 当前版本技术方案 | `02-技术方案/v2.1-model-driven-params/tech-plan.md` | `done` | 已按用户继续要求进入排期；未核实厂家能力仍是技术待办 |
| 6-CHG-0076 | 当前版本工作时长评估 | `02-技术方案/v2.1-model-driven-params/effort-estimate.md` | `done` | 6.5 个 AI 工作日条件排期，含骨架评审、测试和 Bug 修复 |
| 7-CHG-0076 | Flutter/Web 技术文档 | `03-前端/flutter-tech.md` | `done` | 当前版总体计划的输入，不是实现证明 |
| 8-CHG-0076 | Java 技术文档 | `04-后端/java-tech.md` | `done` | 当前版总体计划的输入，不是实现证明 |
| 9-CHG-0076 | Flutter/Web 总体开发计划 | `03-前端/flutter-dev-plan.md` | `waiting_review` | F001～F005、W001～W002 双阶段，Web 骨架包含在本版范围 |
| 10-CHG-0076 | Java 总体开发计划 | `04-后端/java-dev-plan.md` | `waiting_review` | B001～B006 双阶段，沿现有能力/任务/计费/审核平台 |
| 11-12-CHG-0076 | 当前版本模块开发文档 | Flutter/Web、Java 的 `开发计划/` 当前版模块索引与详细计划 | `pending` | 旧 CHG-0073 计划只供对账；编码前必须有同版本可执行模块计划 |
| 13-14-CHG-0076 | 三端骨架与后续真实编码 | Flutter、Java、Admin 代码工程 | `pending` | 新骨架未完成及明确评审前不得进入真实实现 |
| 以下 0～19 | CHG-0073 历史执行快照 | 旧 `v2.1-ai-cover-voice-clone` 文档与代码 | `reference-only` | 表内原有 `done` 仅表示旧需求当时完成，不是 CHG-0076 状态 |
| 0 | 变更校准 | `change-plan.md` | `done` | 已登记 CHG-0073，明确 V2.1 增量范围和旧版 QA 并行边界 |
| 1 | 需求分析 | `archive/CHG-0077-legacy-docs-20260913/01-需求/v2.1-ai-cover-voice-clone/requirements-list.md` | `done` | 已整理来源、业务隔离、范围、规则、页面、数据和完整确认记录 |
| 2 | 需求文档生成 | `archive/CHG-0077-legacy-docs-20260913/01-需求/v2.1-ai-cover-voice-clone/requirements.md`、`requirements-review.md` | `done` | 完整 PRD P13 已包含 Web/Admin W01～W12，Q-A01～Q-A05 已确认 |
| 3 | 需求文档检测 | `archive/CHG-0077-legacy-docs-20260913/01-需求/v2.1-ai-cover-voice-clone/detection-feedback.md` | `done` | 完整检测 PASS，用户已确认继续 |
| 4 | Figma 设计稿计划 | 不生成重复设计计划 | `skipped` | 用户明确设计稿已经定稿并要求直接跳过；38 个 Frame 仍是 UI 真源 |
| 5 | 技术方案 | `archive/CHG-0077-legacy-docs-20260913/02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md` | `done` | 已明确业务边界、共用流程和最小数据库变更；未建设平行任务、资源、积分或作品体系 |
| 6 | 工作时长评估 | `archive/CHG-0077-legacy-docs-20260913/02-技术方案/v2.1-ai-cover-voice-clone/effort-estimate.md` | `done` | Codex 直接跨三端执行；含配置、真实训练、完整测试和 Bug 修改共 7 个工作日，用户已继续流程 |
| 7 | 前端 Flutter 技术文档 | `archive/CHG-0077-legacy-docs-20260913/03-前端/v2.1-ai-cover-voice-clone/flutter-tech.md` | `done` | 已按当时 App/Admin 代码、38 个 Frame 和独立新业务契约完成评审 |
| 8 | 后端 Java 技术文档 | `archive/CHG-0077-legacy-docs-20260913/04-后端/v2.1-ai-cover-voice-clone/java-tech.md` | `done` | 已按当时 Java 代码、最小数据库增量和共享工作流完成评审 |
| 9 | Flutter 总体开发计划 | `archive/CHG-0077-legacy-docs-20260913/03-前端/v2.1-ai-cover-voice-clone/flutter-dev-plan.md` | `done` | 已拆 T-F001～T-F010、T-W001～T-W008 和 15 份模块文档入口 |
| 10 | Java 总体开发计划 | `archive/CHG-0077-legacy-docs-20260913/04-后端/v2.1-ai-cover-voice-clone/java-dev-plan.md` | `done` | 已拆 T-B001～T-B014、API/数据/工作流/验证和 15 份模块文档入口 |
| 11 | Flutter 模块开发文档 | `archive/CHG-0077-legacy-docs-20260913/03-前端/v2.1-ai-cover-voice-clone/开发计划/*.md` | `done` | 用户已确认 00 索引及 01-14 双阶段文档；Web/Admin deferred |
| 12 | Java 模块开发文档 | `archive/CHG-0077-legacy-docs-20260913/04-后端/v2.1-ai-cover-voice-clone/开发计划/*.md` | `done` | 用户已确认 00 索引及 01-14 双阶段文档 |
| 13 | Flutter 编码 | `{frontendRepo}` | `waiting_review` | T-F001-R 至 T-F010-R 已本地实现并通过静态检查、定向测试和双平台构建；待部署联调及 Android 真机 |
| 14 | Java 编码 | `{backendRepo}` | `waiting_review` | T-B001-R 至 T-B013-R 已本地实现并通过定向验证；T-B014-R 待迁移、配置和真实厂家闭环 |
| 15 | 联调与测试 QA | `05-联调与测试/qa-plan.md`、`05-联调与测试/cases/v1.2.0+121-as-built/`、`/Users/soul/code/lxwx/test/catsinger` | `in_progress` | CHG-0069/0074 当前为 334 条动态用例；已补齐专业模式参考音频生成闭环；CHG-0071 双平台 smoke 20/20 PASS，iOS 手工/外部能力全量尚未关闭 |
| 16 | 构建与打包 | `06-构建打包/{build-plan.md,android.md,ios.md}` | `pending` | 待联调通过 |
| 17 | 应用商店上架 | `07-应用上架/release-checklist.md` 等 | `pending` | 待构建通过 |
| 18 | 发布与版本管理 | `08-发布版本/{release-plan.md,changelog.md}` | `pending` | 待上架前 |
| 19 | 上线监控与迭代 | `09-上线监控/{monitoring-plan.md,feedback-loop.md}` | `pending` | 待发布前 |

---

## 4. 当前变更登记

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 | 备注 |
|--------|------|------|--------|------|----------|------|
| CHG-0076 | V2.1 三业务参数随模型变化需求回卷 | requirement_iteration | v2.1-model-driven-params | waiting_review | 9/10 总体开发计划 | 第 7/8 步已记 done；当前 Flutter/Web 与 Java 总体计划待评审，模块计划 pending，骨架门禁有效 |
| CHG-0077 | 旧版需求、技术与前后端计划工作区归档 | docs_archive | v2.1-model-driven-params | done | 工作区归档 | 旧版 01～04 阶段 217 个文件按原目录归档；当前版第 7～10 步已重建，第 11/12 步 pending，无代码变更 |
| CHG-0075 | 先可运行骨架、后真实实现规范 | workflow_rule_change | v2.1-ai-cover-voice-clone | done | 全局规则 / 9-14 文档与编码门禁 | CHG-0074 已用于测试用例补齐，本次按编号不可复用规则顺延；已增加 skeleton_first、-S/-R、生产禁用和整体评审门禁，无业务代码或数据库改动 |
| CHG-0074 | 专业模式参考音频生成闭环测试补齐 | test_case_fix | v1.2.0+121-as-built | done | 15 联调与测试 QA | 新增 `AUDIOREF-008`～`AUDIOREF-012`，覆盖作品库/本地参考音频随专业任务付费生成和成品播放、删除/更换、失败重试、生成同款回填；Catalog 334 条且 31 项工程自检通过，尚未执行新增真机用例 |
| CHG-0073 | V2.1 翻唱声音克隆 | feature_add / version_iteration | v2.1-ai-cover-voice-clone | waiting_review | 13/14 Flutter 与 Java 真实实现评审 | App 与 Java 本地实现及定向验证完成；Web/Admin deferred，等待部署、真实厂家、付费和可播放闭环 |
| CHG-0072 | 歌曲改编测试增加成品可播放硬门禁 | test_case_fix | v1.2.0+121-as-built | done | 15 联调与测试 QA | ADAPT-009、ADAPT-012 已回卷为完整生成与播放验证；任务提交或状态成功不再提前 PASS，无法播放一律 FAIL；本轮未执行设备测试 |
| CHG-0070 | 生成完成播放器目标作品锁定 | bug_fix | v1.2.0+121-as-built | done | 13 Flutter 编码 / 15 QA | 修复生成成功自动跳转后，播放器被进入页面前的全局当前歌曲覆盖的问题；显式路由 `workId` 优先，目标作品进入播放会话后仍支持队列切歌；4 条定向 Widget 回归与 `flutter analyze` 通过，无后端、接口或数据库改动 |
| CHG-0069 | 移动端全量用户功能测试与 ADB 工程升级 | test_plan | v1.2.0+121-as-built | in_progress | 15 联调与测试 QA | 当前 334 条用例；历史 329 条 full 报告保留；提现不在范围，专业参考音频新增闭环尚待执行；等待专用数据、iOS/人工及真实 Provider 验收 |
| CHG-0071 | iOS 真机/模拟器用户自动化与双平台测试门禁 | test_infrastructure | v1.2.0+121-as-built | in_progress | 15 联调与测试 QA | Appium/XCUITest 已接入；iOS 真机 10/10、默认双平台 20/20 smoke PASS；iOS full 为 10 PASS/304 NOT_RUN、总体 INCOMPLETE；无真机和模拟器时 FAIL |
| CHG-0068 | 场景模型映射与移动端单次任务模型选择 | feature_add | v1.1.0-as-built | waiting_review | 4 Figma / 13 Flutter 编码 / 14 Java 编码 / 15 QA | 保留后台单场景默认模型；新增 App/场景/商家/模型映射、公开 UUID、实时真实计费和任务快照；Admin 配置公开名称、图标、JSON 扩展、排序与启停；移动端选择只影响本次任务且不持久化；专项测试和双端 analyze 通过；后端全量报告为 851 项、3 个会员路径失败并有 1 个执行器 OOM，待迁移、配置、真实价格及真机联调 |
| CHG-0067 | 歌词/封面 120 秒与翻唱歌词补齐 | logic_change | v1.1.0-as-built | waiting_review | 13 Flutter 编码 / 14 Java 编码 / 15 QA | 两类生成响应统一 120 秒；翻唱海报后新增取词检查点和两分钟降级上限；播放器静态/同步歌词与缓存刷新；独立 dry-run/apply 历史工具，无迁移、不运行真实回填；Flutter 定向/analyze 与后端全量通过，Flutter 全量受旧失败/内存膨胀影响未完成；待发布验收 |
| CHG-0066 | iOS 游客账号与订阅恢复 | compliance_fix | v1.1.0+111 | waiting_review | 13 Flutter 编码 / 14 Java 编码 / 15 QA / 17 应用商店上架 | iOS 游客拥有正式 userId/JWT，可购买、写歌、生成和查看作品；手机号绑定完全可选且仅允许未注册号码。所有新用户创建统一发放一次 30 积分，游客恢复和绑定不重复发放。Keychain 保存 App 隔离凭证，路由拆分 session/registered，恢复购买通过 Apple 双重验真回到原游客；登录首屏已移除顶部标题、游客说明和“无需手机号”文案，固定提供“游客登录 / 手机号登录”，号码认证可用时在其下显示“一键登录”，由用户点击后才打开原生授权页；关闭返回选择页、“其他手机号登录”进入短信页，不可用时隐藏入口；游客退出提示不再出现技术术语。会员购买补单在旧账号交易已安全结束后继续当前账号的新购买，本地待确认订单按用户与服务环境隔离；Android 保持原手机号登录。后端及双端专项测试、Flutter analyze、catsinger iOS Simulator 构建通过；待带 SIM iPhone 一键登录及 StoreKit/App Review 真机验收 |
| CHG-0065 | OPPO 友盟 GAID 超范围收集合规修复 | compliance_fix | v1.1.0-as-built | waiting_review | 13 Flutter 编码 / 15 QA / 17 应用商店上架 | Android 改用无原生实现的 iOS-only 本地友盟插件并移除 preInit、合规桥接、集成测试 Scheme、混淆和全部友盟依赖；iOS 保留固定 `UMCommon 7.5.11`、`UMDevice 3.6.0` 且仅在同意后初始化；隐私政策改为仅 iOS 友盟披露，不修改隐私弹框。双平台 Release、定向测试、包体静态检查和 V1981A 冷启动通过，待新 APK 复测 OPPO 2.5 |
| CHG-0064 | 友盟 GAID 初始化门禁与隐私政策明示补强 | compliance_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA / 17 应用商店上架 | 首层隐私弹框仅保留用户协议与隐私政策提示，不直接展开友盟信息；`Global.initProtectedServices()` 与 `UmengAnalyticsService.init()` 增加未同意即返回的双层兜底，Android启动阶段仅保留不采集的 `UMConfigure.preInit`；Web隐私政策在既有友盟章节补齐目的、方式、信息范围、收集频率、使用场景及隐私政策链接，并区分App自身与第三方SDK的信息收集边界；隐私流程和弹框测试、`flutter analyze`、Debug APK构建、HTML结构校验与两工程 `git diff --check` 通过 |
| CHG-0063 | 首次进入主页隐私协议弹框修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 首页首帧后主动检查隐私状态；首次未选择用户立即展示不可拖拽、不可点遮罩关闭的协议弹框，已同意或已明确拒绝不自动重复弹；受保护能力仍在拒绝后按需再询问，更新检查仅在同意后执行；隐私链路 6 项、弹框交互 1 项及 `flutter analyze` 通过 |
| CHG-0062 | 专业模式歌词润色等待防息屏 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 专业模式主页面 AI 帮写和全屏歌词页智能优化共用的 `/api/song-lyrics/assist` 请求在等待期间通过统一 `ScreenAwakeCoordinator` 持有唤醒锁；成功、失败自动释放，校验拦截和重复点击不额外持有；8 项屏幕常亮定向回归及歌词请求参数回归通过 |
| CHG-0061 | 封面海报异步任务轮询接入 | logic_change | v1.1.0-as-built | done | 13 Flutter 编码 / 14 Java 编码 / 15 QA | Java 复用现有封面任务表开放用户创建、最近任务和指定任务查询，后台调度执行时继续走原积分冻结、确认与失败退款；播放器和作品详情改为创建任务后每 3 秒轮询，成功再刷新详情，15 分钟超时或离页停止；Flutter 8 项、Java 7 项定向回归通过 |
| CHG-0060 | 歌词时间轴异步任务轮询接入 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | App 从同步 `/regenerate-timeline` 切换为创建用户异步任务并每 3 秒查询状态；成功后重拉作品详情，失败传递任务原因，15 分钟超时或页面销毁停止轮询；7 项定向回归通过 |
| CHG-0059 | “生成同款”参数降级提示移除 | ui_adjustment | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 原参数无法匹配当前配置时仍执行原有回退、过滤与清理，但不再弹出“部分原参数当前不可用”提示；3 项同款定向回归通过 |
| CHG-0058 | 播放器“生成海报”入口恢复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 播放缓存仅负责首帧，播放器每次进入均后台刷新详情；封面 URL 非空但图片加载失败时也显示重新生成入口，已有封面先确认积分，取消不提交；4 项播放器定向回归通过 |
| CHG-0057 | 作品详情封面重新生成缓存同步修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 保留播放器缓存/列表摘要首帧，同时每次进入详情都请求最新数据；普通详情请求继续同步 `MusicPlayService`，封面重新生成即时响应仅更新当前详情与作品 Store，并清理稳定封面缓存键、刷新列表，不改播放器缓存 |
| CHG-0056 | 歌曲“生成同款”参数持久化与风格对齐 | feature_modify | v1.1.0-as-built | done | 13 Flutter 编码 / 14 Java 编码 / 15 QA | 作品保存创作参数快照并扩展详情 `creationParameters`；快照风格不再混入 Provider 结果标签。App 等待动态配置后把旧标签映射为当前选项 `value`，人声标签独立恢复，未知项丢弃并合并提示；参考音频仅所有者可见，旧接口与普通入口安全降级 |
| CHG-0055 | 封面海报生成接口超时调整 | logic_change | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | App 仅将 `/api/song-works/{id}/regenerate-cover` 的响应等待超时覆盖为 1 分钟，并与歌词生成复用生成响应超时常量；其他接口及连接超时保持不变，请求级回归测试通过，`flutter analyze` 仅保留既有未使用方法告警 |
| CHG-0054 | 翻唱作品重新生成参数恢复修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 14 Java 编码 / 15 QA | 正式服失败任务被错误创建为 `ADVANCED_SONG` 且缺少翻唱源音频/特征 ID；后端现按原成功任务恢复 `COVER_SONG`、源音频、音色和翻唱设置并继续覆盖原 `workId`，Flutter 按 `currentStep` 展示真实失败步骤；前后端定向回归通过 |
| CHG-0053 | AI 歌词生成接口超时调整 | logic_change | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | App 仅将 `/api/song-lyrics/assist` 的响应等待超时从全局 30 秒覆盖为 1 分钟，其他接口及连接超时保持不变；请求级回归测试通过，`flutter analyze` 仅保留既有未使用方法告警 |
| CHG-0052 | Android MP4 音频转换兼容修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 部分 Vivo 系统 `MediaMuxer` 会拒绝合法的双字节 AAC CSD；App 继续优先无损封装 M4A，失败时绕过厂商 Muxer、无损写出 ADTS AAC，并按原生实际返回路径同步 `.aac` 文件名和 `audio/aac`；V1981A 使用用户失败原文件真机回归成功生成 AAC-LC 44.1kHz 双声道文件，未触发生成任务或扣分 |
| CHG-0051 | 热歌改编自定义歌名保留修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | App 在热歌改编提交时按用户歌名是否为空发送 `titleExplicit`：用户输入歌名时为 `true`，空输入使用来源标题兜底时为 `false`，避免后端把自定义歌名当成可重新生成的兜底标题；自定义歌名请求回归通过，`flutter analyze` 仅保留既有未使用方法告警 |
| CHG-0050 | 歌曲“重新生成”积分确认、加载反馈与原作品更新修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 14 Java 编码 / 15 QA | 详情弹层、独立详情页和播放器 Controller 按原作品 provider/model 当前价格确认积分并显示阻断 Loading；后端重新生成任务直接绑定原 `workId`，不插入新作品，提交后原作品立即切为 `GENERATING` 并关联新 task，成功切回 `SUCCEEDED` 且保留收藏/专辑关系，失败恢复原任务关联和可播放状态；Flutter 与 Java 定向回归通过，V1981A 真机已验积分弹框取消路径，未提交扣分 |
| CHG-0049 | iOS“哼歌成曲”麦克风授权修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 专业写歌与歌曲改编统一走 `Access.microphone`；启用 iOS 麦克风权限编译宏，首次未决定时请求系统授权，首次拒绝不连续弹设置、下次再引导，设置弹框明确提供 App 设置页及系统麦克风备用路径；5 项权限测试、iOS 模拟器构建和 iOS 26.4 Simulator 允许/拒绝/设置恢复全链路通过 |
| CHG-0048 | 作品详情弹层真机空白修复 | bug_fix | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 固定 Sliver 头部的 ScreenUtil 小数高度在 1080×2408@3x 下触发浮点几何断言；高度向下对齐整数逻辑像素后，弹层内容、操作区和基础信息在 V1981A 真机正常显示，定向回归通过 |
| CHG-0047 | 歌曲播放期间防自动锁屏 | logic_change | v1.1.0-as-built | waiting_review | 13 Flutter 编码 / 15 QA | 主歌曲仅在真实播放时保持屏幕常亮；统一 owner 协调 Loading/弹层，后台释放、前台恢复；定向测试通过，待 Android/iOS 真机验收 |
| CHG-0046 | 专业写歌参考音频上限提升至 50MB | logic_change | v1.1.0-as-built | waiting_review | 13 Flutter 编码 / 14 Java 编码 / 15 QA | Flutter 与后端默认值、multipart 和 OSS 直传双阶段校验已统一为 52,428,800 字节；定向测试通过，待部署 catsinger 路由后更新目标环境既有配置并实测 |
| CHG-0045 | “我的音乐”列表自动刷新 | logic_change | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 作品页可见且有生成中作品时每分钟静默刷新；六类任务创建成功立即刷新；请求串行补发、失败保留和 13 项定向测试通过 |
| CHG-0044 | 个人页 Figma 对齐与积分入口调整 | ui_adjustment | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 当前 Figma `81:559` 八项菜单对齐；订单列表复用既有页面、图标与登录门禁；顶部积分/充值进入充值页、明细进入原详情页；共享底部导航不变 |
| CHG-0043 | ADB 冒烟测试加速与结果打印 | test_automation_optimize | v1.1.0-as-built | done | 15 QA | 默认 balanced 10/10 PASS、63.96 秒；22 项框架单测及四类报告通过，保留 isolated 排障模式 |
| CHG-0042 | 全 App 非确定性加载样式统一 | ui_adjustment | v1.1.0-as-built | done | 13 Flutter 编码 / 15 QA | 已按参考图统一为固定弧线五点整体旋转：页面/局部/按钮/刷新外框为 32/24/16/20，12 处下拉刷新按 0～80px 映射角度与最大 60px 跟手位移，触发后回弹至 40px 持续旋转；保留确定性进度条和图片占位 |
| CHG-0041 | catsinger 独立 Python ADB 整 App 测试工程 | test_automation | v1.1.0-as-built | done | 15 QA | 147 条映射、16 项框架单测、10 条 UI 冒烟通过；测试实例待部署 catsinger 路由 |
| CHG-0014 | 实现反向需求、UI 与测试基线校准 | docs_test_sync | v1.1.0-as-built | done | 15 QA | 已生成当前需求、截图、代码基线和整 App 用例 |
| CHG-0013 | v1.1 AI 改编功能（历史目录名保留） | feature_add | v1.1-ai-cover | waiting_review | Java/Flutter/Web 编码 | 已完成现有 AI 改编三端对账与验证；CHG-0073 不修改该业务 |
| CHG-0011 | 前端 UI 未按设计稿对齐返工 | feature_modify | v0.1.0 | in_progress | 13 Flutter 编码 | 已完成 `03-前端/开发计划/rework/01-09` 编码与命令验证，截图验收待补 |
| CHG-0012 | 项目工作区归档整理 | docs_archive | v0.1.0 | done | 工作区归档 | 旧 Sonus 图、旧 `versions` 索引、返工前 Flutter App 模块计划已移入 `archive/` |

### 4.1 路径恢复迁入的并行 QA 队列

> CHG-0015～CHG-0040 从错误工作区别名 `catsinger` 按 `旧编号 + 14` 迁入。完整映射与状态见 `change-plan.md`；原始实现轨迹版本不覆盖当前 App `v1.1.0`。

| 优先级 | CHG-id | 状态 | 恢复条件 / 动作 |
|--------|--------|------|-----------------|
| 当前主线 | CHG-0076 | waiting_review | 第 7/8 步技术文档已作为输入完成；当前第 9/10 步总体计划待评审，下一步第 11/12 步模块计划 |
| 并行 QA | CHG-0069、CHG-0071 | in_progress | 继续执行 `v1.2.0+121-as-built` Android/iOS 整 App QA；不覆盖 V2.1 文档状态 |
| P1 | CHG-0033、CHG-0036 | waiting_review | 使用单曲 smoke 方案验证用户自动登录、Provider、生成轮询、审核和标签绑定 |
| P2 | CHG-0034 | waiting_review | 验证运营账号首次真实登录、解冻和下一次每日重置 |
| P3 | CHG-0016 | in_progress | Android 真机验收支付宝 Web/WAP 支付并清理完整测试基线 |
| P4 | CHG-0024 | in_progress | candidate 真机 QA 通过后生成九渠道最终正式包 |

CHG-0015、CHG-0017～CHG-0023、CHG-0025～CHG-0032、CHG-0035、CHG-0037～CHG-0040 均按恢复证据登记为 `done`。迁入队列不会改变本文第 2 节的当前阶段、当前步骤、恢复点或下一步默认动作。

---

## 5. 当前步骤需加载规则

> CHG-0076 当前处于第 9/10 步 Flutter/Web 与 Java 总体开发计划待评审：必读核心、09/10 总体计划规则、当前版 PRD/技术方案/工时和第 7/8 步技术文档。本阶段不加载编码规则，也不授权真实编码。

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、版本隔离和当前文档门禁 |
| `.cursor/rules/09-Flutter开发计划文档.mdc` | 第 9 步 Flutter App 与 Web/Admin 总体开发计划与双阶段任务 |
| `.cursor/rules/10-Java开发计划文档.mdc` | 第 10 步 Java 总体开发计划、API 表与双阶段任务 |
| `.cursor/rules/07-前端Flutter技术文档.mdc`、`.cursor/rules/08-后端Java技术文档.mdc` | 上游技术契约输入，不代替当前总体计划 |

---

## 6. 当前步骤依赖文件

> 本轮以当前版本需求、方案、排期与第 7/8 步技术文档为输入。CHG-0073 的旧计划仅供差异分析，不是当前执行基线。

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| 三份新飞书来源笔记：`01-需求/references/docs/v2.1/20260913-feishu-source-notes.md` | 新业务需求与用户决策，非在线全文 | 是 |
| `01-需求/references/images/v2.1/model-driven-params/` | Figma `vn7k0jqv` 新版关键页面/置灰状态 | 是 |
| `01-需求/v2.1-model-driven-params/requirements.md` | 当前完整 PRD，P14 内含 Web/Admin | 是 |
| `02-技术方案/v2.1-model-driven-params/tech-plan.md` | 当前技术任务、三端现状与测试边界 | 是 |
| `02-技术方案/v2.1-model-driven-params/effort-estimate.md` | 6.5 个 AI 工作日的条件排期和骨架评审门禁 | 是 |
| `03-前端/flutter-tech.md` | App/Web 页面、API 消费和目标能力契约 | 是 |
| `04-后端/java-tech.md` | Java 业务边界、已有接口、能力/价格版本及校验 | 是 |
| `/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice`、`/Users/soul/code/lxwx/lxwx_admin` | 必要时三端只读现状，核对文件与接口名；本步不改代码 | 否 |
| `workflow.md` | 当前流程状态和用户补充约束 | 是 |

---

## 7. 当前步骤生成文件

> 以下当前版本文档有效；原有旧版 `done` 行是 CHG-0073 历史状态，不能作为新需求编码通过证明。

| 文件 | 状态 | 说明 |
|------|------|------|
| `01-需求/v2.1-model-driven-params/requirements-list.md`、根路径镜像 | `done` | 三业务参数随模型变化清单，非产品发布验收 |
| `01-需求/v2.1-model-driven-params/requirements.md`、根路径镜像 | `done` | 当前完整 PRD，13 个 App 页面与 P14/W01～W07 |
| `01-需求/v2.1-model-driven-params/requirements-review.md`、根路径镜像 | `done` | 固定 11 章；D-04 同厂兼容待技术核验 |
| `01-需求/v2.1-model-driven-params/detection-feedback.md` | `done` | 第 3 步正式 PASS，用户要求继续；不是发布或代码验收 |
| `02-技术方案/v2.1-model-driven-params/tech-plan.md` | `done` | 第 5 步当前版本技术方案，未核实厂家能力仍是技术待办 |
| `02-技术方案/v2.1-model-driven-params/effort-estimate.md`、根路径指针 | `done` | 第 6 步增量排期，6.5 个 AI 工作日，骨架评审后才能真实实现 |
| `03-前端/flutter-tech.md` | `done` | 第 7 步 Flutter/Web 增量技术文档，当前版技术输入 |
| `04-后端/java-tech.md` | `done` | 第 8 步 Java 增量技术文档，当前版技术输入 |
| `03-前端/flutter-dev-plan.md` | `waiting_review` | 第 9 步 Flutter/Web 增量总体计划，含 F/W 双阶段任务和模块文档清单 |
| `04-后端/java-dev-plan.md` | `waiting_review` | 第 10 步 Java 增量总体计划，含 B 双阶段任务、API 表和模块文档清单 |
| `01-需求/references/images/v2.1/model-driven-params/` | `source-exported` | 当前 Figma 的 21 张关键状态快照；线上设计稿仍是视觉真源 |
| `archive/CHG-0076-pre-rewrite/` | `reference-only` | 旧 V2.1 需求快照及原根路径 v0.1.2 工时评估 |
| `archive/CHG-0077-legacy-docs-20260913/` | `reference-only` | 旧版 01～04 阶段文件、模块计划及旧截图索引；当前版本第 11/12 步仍 pending |

### 7.1 旧版生成记录（reference-only）

> 下表保留 CHG-0073 和更早时期写入时的状态用作审计历史。其 `done`/PASS 不表示通过当前 CHG-0076 需求，也不能作本轮编码依据。

| 历史文件 | 当时状态 | 当时说明 |
|----------|----------|----------|
| `01-需求/v2.1-ai-cover-voice-clone/requirements-list.md` | `done` | 所有产品决策已确认，Web/Admin 入口统一指向完整 PRD P13 |
| `01-需求/v2.1-ai-cover-voice-clone/requirements.md` | `done` | V2.1 唯一完整 PRD；P13 内嵌 W01～W12 后台详细需求 |
| `01-需求/v2.1-ai-cover-voice-clone/requirements-review.md` | `done` | Product Review 已完成固定 11 章、页面 Checklist、反向场景和确认记录对齐 |
| `01-需求/v2.1-ai-cover-voice-clone/detection-feedback.md` | `done` | 完整检测 PASS，用户已确认继续 |
| `01-需求/v2.1-ai-cover-voice-clone/figma-design-plan.md` | `skipped` | 设计稿已经定稿，用户明确跳过第 4 步；不生成重复设计计划 |
| `02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md` | `done` | 当前版本完整技术方案；数据库变更已按现有实现收缩并完成第 5 步 |
| `02-技术方案/v2.1-ai-cover-voice-clone/effort-estimate.md` | `done` | 当前版本工时评估；7 个 AI 工作日完整交付口径已确认并进入下一步 |
| `03-前端/v2.1-ai-cover-voice-clone/flutter-tech.md` | `done` | 当前版本 Flutter App 与 Web/Admin 技术文档；旧 v1.1 前端文档不得作为执行计划 |
| `04-后端/v2.1-ai-cover-voice-clone/java-tech.md` | `done` | 当前版本 Java 技术文档；明确独立接口/业务目录和共享底层流程 |
| `03-前端/v2.1-ai-cover-voice-clone/flutter-dev-plan.md` | `done` | T-F001～T-F010、T-W001～T-W008、跨端顺序、模块文档清单和验收门禁 |
| `04-后端/v2.1-ai-cover-voice-clone/java-dev-plan.md` | `done` | T-B001～T-B014、API 任务表、数据迁移、工作流、测试和真实联调计划 |
| `03-前端/v2.1-ai-cover-voice-clone/开发计划/00-module-index.md`、`01-14` | `waiting_review` | T-F001-R 至 T-F010-R 已本地完成；Web/Admin deferred，目标环境业务闭环待验收 |
| `04-后端/v2.1-ai-cover-voice-clone/开发计划/00-module-index.md`、`01-14` | `waiting_review` | T-B001-R 至 T-B013-R 已本地完成；T-B014-R 等待迁移、配置和真实厂家闭环 |
| `01-需求/references/docs/v2.1/喵喵写歌-AI翻唱产品需求与技术方案-V2.1.docx` | `done` | 用户原始产品资料归档，保留 SHA-256 |
| `01-需求/references/images/v2.1/ai-cover-voice-clone/*.png` | `done` | Figma 当前 38 个有效 Frame 的本地只读导出 |
| `01-需求/references/images/v2.1/ai-cover-voice-clone/README.md` | `done` | Figma 节点、页面状态、文件名和文案校准索引 |
| `archive/reference-indexes/v1.0-design-mvp/01-需求/versions/v1.0-design-mvp/README.md` | `reference-only` | 历史兼容索引，不作为当前执行入口 |
| `01-需求/requirements-list.md` | `done` | 需求清单，已同步 PRD 待确认项收口 |
| `01-需求/requirements.md` | `done` | PRD，检测结论 PASS |
| `01-需求/detection-feedback.md` | `done` | 新 PRD 需求文档检测反馈，结论 PASS |
| `01-需求/figma-design-plan.md` | `skipped` | 用户明确跳过 UI/Figma 流程，不生成该文件 |
| `archive/reference-indexes/v1.0-design-mvp/02-技术方案/versions/v1.0-design-mvp/README.md` | `reference-only` | 历史兼容索引，不作为当前执行入口 |
| `02-技术方案/tech-plan.md` | `done` | 已同步新 MVP 真功能范围，作为下一步工时重估输入 |
| `02-技术方案/effort-estimate.md` | `pending` | 待按更新后的技术任务重新估算 |
| `archive/reference-indexes/v1.0-design-mvp/03-前端/versions/v1.0-design-mvp/README.md` | `reference-only` | 历史兼容索引，不作为当前执行入口 |
| `03-前端/flutter-tech.md` | `done` | 已作为 Flutter 总体开发计划输入 |
| `03-前端/flutter-ui-implementation-plan.md` | `done` | 新增前端 UI 对稿、适配和页面验收说明 |
| `03-前端/ui-rework-dev-plan.md` | `done` | CHG-0011 前端 UI 返工影响审计与逐页开发清单，结论为局部返工 |
| `03-前端/开发计划/rework/*.md` | `done` | CHG-0011 按模块拆分的详细开发文档，已补 `09-scenario-flow.md` 并完成编码 |
| `archive/reference-indexes/v1.0-design-mvp/04-后端/versions/v1.0-design-mvp/README.md` | `reference-only` | 历史兼容索引，不作为当前执行入口 |
| `04-后端/java-tech.md` | `done` | 已同步 v1.0-design-mvp 后端技术文档 |
| `03-前端/flutter-dev-plan.md` | `done` | 已同步模块文档状态 |
| `04-后端/java-dev-plan.md` | `done` | 已按 T-B001 至 T-B014 重写 |
| `03-前端/开发计划/rework/*.md` | `done` | 当前 Flutter App UI 返工编码输入 |
| `03-前端/开发计划/admin-*.md` | `done` | 当前 Web/Admin 编码输入 |
| `04-后端/开发计划/*.md` | `done` | 已生成当前版本 14 个模块文档 |
| `01-需求/v1.1-ai-cover/requirements.md` | `reference-only` | 现有 AI 改编的历史目录文档；目录名保留，不得作为 V2.1 声音克隆翻唱需求入口 |
| `01-需求/references/README.md` | `done` | 2026-06-25 已补充 v1.1 AI 改编参考资料和设计稿索引 |
| `02-技术方案/v1.1-ai-cover/tech-plan.md` | `reference-only` | 现有 AI 改编技术参考，只作 V2.1 差异输入 |
| `03-前端/v1.1-ai-cover/flutter-tech.md` | `reference-only` | 现有 AI 改编 Flutter 技术参考，只作 V2.1 差异输入 |
| `03-前端/v1.1-ai-cover/flutter-dev-plan.md` | `reference-only` | 现有 AI 改编开发计划，禁止用于 V2.1 编码 |
| `03-前端/v1.1-ai-cover/开发计划/00-cover-module-index.md` | `reference-only` | 现有 AI 改编 Flutter / Web(Admin) 模块索引 |
| `03-前端/v1.1-ai-cover/开发计划/01-cover-api-models.md` | `done` | Flutter 接口、DTO、Store、路由参数模块已按实现对齐 |
| `03-前端/v1.1-ai-cover/开发计划/02-home-and-work-entry.md` | `done` | 首页 AI 改编入口和作品重新改编入口已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/03-cover-upload-step.md` | `done` | 上传歌曲步骤已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/04-cover-voice-step.md` | `done` | 选择音色步骤已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/05-cover-settings-submit.md` | `done` | 高级设置和提交已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/06-cover-progress-result.md` | `done` | 翻唱生成中和结果页已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/07-works-integration.md` | `done` | 作品列表和详情集成已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/08-admin-cover-ui.md` | `done` | Web/Admin 翻唱配置页面已对齐 |
| `03-前端/v1.1-ai-cover/开发计划/09-flutter-qa.md` | `done` | v1.1 AI 改编前端命令验证已完成，人工截图待验 |
| `04-后端/v1.1-ai-cover/java-tech.md` | `reference-only` | 现有 AI 改编 Java 技术参考，只作 V2.1 差异输入 |
| `04-后端/v1.1-ai-cover/java-dev-plan.md` | `reference-only` | 现有 AI 改编 Java 开发计划，禁止用于 V2.1 编码 |
| `04-后端/v1.1-ai-cover/开发计划/00-cover-module-index.md` | `reference-only` | 现有 AI 改编 Java 模块索引 |
| `04-后端/v1.1-ai-cover/开发计划/01-schema-and-entities.md` | `done` | 翻唱数据结构与实体已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/02-cover-voice-config.md` | `done` | 翻唱模型与音色配置已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/03-cover-source-audio-upload.md` | `done` | 翻唱源音频上传已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/04-cover-task-api-service.md` | `done` | 翻唱任务接口与服务已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/05-cover-workflow-provider-resource.md` | `done` | MiniMax Provider 与资源持久化已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/06-points-idempotency.md` | `done` | 翻唱积分与幂等已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/07-admin-cover-api.md` | `done` | Web/Admin 翻唱管理接口已对齐 |
| `04-后端/v1.1-ai-cover/开发计划/08-java-tests.md` | `done` | v1.1 AI 改编 Java targeted tests 和全量测试已通过 |
| `05-联调与测试/v1.1-ai-cover-code-audit.md` | `done` | CHG-0013 三端代码对账、补齐项和验证记录 |
| `01-需求/v1.1.0-as-built/requirements.md` | `done` | 按 Android 1.1.0 和当前 Flutter 代码反推的实际交付需求 |
| `01-需求/references/images/v1.1.0-as-built/android/*.png` | `done` | 首页、专业模式、生成进度、作品、我的 5 张真机截图 |
| `05-联调与测试/frontend-code-test-baseline-v1.1.0.md` | `done` | 当前三 Tab、页面入口、Controller 和已知差异基线 |
| `05-联调与测试/frontend-code-test-baseline.md` | `reference-only` | 旧五槽/四 Tab 代码基线 |
| `05-联调与测试/qa-plan.md` | `in_progress` | 已切换到 v1.2.0+121-as-built 双平台执行入口 |
| `05-联调与测试/cases/v1.2.0+121-as-built/` | `done` | 当前 334 条 Android/iOS 整 App 测试用例目录 |
| `/Users/soul/code/lxwx/test/catsinger` | `in_progress` | 独立 PyCharm ADB/Appium/XCUITest 工程；默认双平台 smoke 20/20 PASS，iOS manual/assisted 仍待执行 |
| `05-联调与测试/cases/00-10` | `reference-only` | 旧 223 条用例，不直接执行 |
| `/Users/soul/code/lxwx/catsinger` | `waiting_review` | v1.1 AI 改编 App 编码已完成命令验证，等待人工截图验收 |
| `/Users/soul/code/lxwx/lxwx_admin` | `waiting_review` | v1.1 Web/Admin 编码已完成命令验证，等待后台页面人工验收 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `waiting_review` | v1.1 Java 后端已完成命令验证，等待真实 MiniMax / 资源存储联调 |
| `workflow.md` | `done` | 当前流程状态 |
| `CURRENT.md` | `done` | 当前主路径入口说明，不指向 `versions/` 或 `archive/` |
| `archive/legacy-20260610/README.md` | `done` | 旧版本 reference-only 归档说明 |
| `archive/legacy-20260611-pre-rework/README.md` | `done` | CHG-0011 返工前 Flutter App 旧模块计划归档说明 |
| `archive/reference-indexes/v1.0-design-mvp/README.md` | `done` | 旧 `versions` 兼容索引归档说明 |
| `change-plan.md` | `done` | 初始空变更计划 |
| `change-log.md` | `done` | 初始研发变更日志 |

---

## 8. 上架就绪检查表

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 15 联调与测试 QA 通过 | ☐ | 用例已生成，尚未执行 |
| `change-plan.md` 顶部「进行中变更」区块为空 | ☐ | CHG-0011 前端 UI 返工进行中 |
| `change-log.md` 当前版本号已确定 | ☑ | v0.1.0 |
| Android AAB / APK 已生成并测试安装通过 | ☐ | 未进入 |
| iOS IPA 已生成并 TestFlight 通过 | ☐ | 未进入 |
| 签名配置正常，无过期证书 | ☐ | 未进入 |
| 隐私政策已就绪并 URL 可访问 | ☐ | 未进入 |
| 商店素材已就绪 | ☐ | 未进入 |
| 第三方 SDK 合规清单已声明 | ☐ | 未进入 |
| 国内商店备案/软著材料 | ☐ | 未进入 |

---

## 9. 额外注意事项

- 历史纠正：前期先整理需求，不直接写代码；用户后续已多次确认进入下一步并进入编码阶段。
- 当前 V2.1 Product Review、需求清单、完整 PRD、需求检测、技术方案、工时评估、前后端技术文档和模块文档均为 `done`；第 4 步按用户决定 `skipped`。Flutter/Java 本地真实实现已进入 `real_review`，Web/Admin 页面仍不编码；旧版计划只作实现基线和并行事项。
- P12 翻唱播放不新建页面或重做 UI，直接复用当前 Flutter 工程 `SongPlayerPage`；旧播放器截图不再作为 V2.1 验收依据。
- Q-A01～Q-A05、模块文档和骨架均已确认；真实编码只按 `v2.1-ai-cover-voice-clone` 文档执行。当前等待部署联调和真实成品可播放验收，禁止用旧版本计划或 Mock 结果替代。
- 2026-09-08 用户收口 V2.1 原待确认项：歌曲最长 10 分钟、平台控制并发、翻唱任务 10 分钟超时、不提供取消；2026-09-09 进一步校准为平台排队不计入，厂商确认接单并返回可查询任务标识后才开始 10 分钟处理计时。算道模型 ID 失效后不可重新导入，翻唱声音克隆需支持多渠道/商家模型切换且音色按渠道绑定；算道回调无安全协议，本期主动轮询；默认训练/翻唱分别 100/200 积分且后台可配置；官方试听由算道提供、名称头像由我方提供；低置信度告警可确认继续。
- 2026-09-08 用户新增并校准 D-U07：翻唱声音克隆范围内 App 和 Web/Admin 上传的图片、音频、可展示文字全部安全审核；文件仍进入现有资源台账，资源技术状态与审核业务状态分离。未通过前不得公开展示、训练、翻唱、冻结积分、调用 Provider 或发布；上传者可按 OWNER 权限试听自有音频，页面可读取参考价格。站内受信源在任务内与 AI 改编一致跳过重复源审核，生成成品仍须审核通过且真实可播放。
- 2026-09-08 用户明确 V2.1 不得另起业务体系：AI 改编与翻唱声音克隆仅在产品语义、场景编码、计费项、任务用途、作品类型和筛选条件上区分；模型、路由、任务、资源、审核、积分、作品、Admin App 切换和角色权限全部复用现有能力，只补声音资料与训练所需最小模块。
- 2026-09-08 用户确认正式产品展示名为「翻唱声音克隆」；旧 DOCX/Figma 文案只作来源记录，内部 `VOICE_COVER`、场景编码、页面路由和版本目录保持稳定；生成 API 和模型字段以 2026-09-09 的 D-U09 最终口径执行。
- 2026-09-09 D-U08 先确认业务类型与厂家模型必须分离，App 必须从模型列表取得并提交真实 `provider/model`；其公开复用 `/api/song-generations` 并传 `mode` 的中间口径已由 D-U09 替代。
- 2026-09-09 D-U09 最终确认接口层业务隔离：翻唱声音克隆使用 `/api/song-voice-covers`，公开请求不传 `mode`，服务端固定内部 `VOICE_COVER` 后委托共享任务编排。AI 写歌 `/api/song-generations` 和 AI 改编 `/api/song-covers` 保持不变。
- 2026-09-09 用户确认业务目录边界：翻唱声音克隆新建 `app/catsinger/voicecover/`，与现有 AI 改编 `cover/` 同级且业务实现隔离；新目录通过服务委托和工作流 SPI 接入同一套歌曲任务、模型、审核、积分、资源、作品与调度能力，不复制底层体系。
- 2026-09-08 用户要求 Web/Admin 需求与产品文档写在一起；W01～W12 已完整并入 `requirements.md` P13，独立后台需求文件已删除，Q-A01～Q-A05 已在本轮评审收口。
- 2026-09-08 用户提供新的 Figma 通道 `dfgz0898`；已连接并确认 `working (91:106)` 仍有 38 个有效 Frame 和 1 个 Group，节点与本地图片索引一致，不需要重新导出。
- 2026-09-09 用户提供当前 Figma 通道 `ujnpl6tr`；已只读核验同一文件「音乐」和页面 `working (91:106)`，仍为 38 个有效 Frame 和 1 个非页面 Group，本地图片无需重导。
- 2026-06-09 18:35 已生成 PRD `01-需求/requirements.md`；2026-06-09 18:46 已进入需求文档检测并通过。
- 2026-06-09 18:46 用户收口 PRD 待确认项：MiniMax 配置按既有阿里云短信方案后置添加；首批示例由 Web/Admin 添加且无数据展示空态；后台增加超级管理员和角色管理块权限；专辑高级能力和下载音质区分暂不做但预留扩展；v1 需要接入歌词逐句时间轴。
- 2026-06-09 18:46 已完成需求文档检测，结论 PASS；存在非阻塞优化项，需在 UI 参考约束和技术方案阶段处理。
- 2026-06-09 18:54 用户明确要求跳过 UI 这一个流程；Figma 设计稿计划 / UI 参考约束文档阶段标记为 skipped，不生成 `figma-design-plan.md`。
- 技术方案阶段不引用 Figma 设计计划，改为直接引用 PRD、检测反馈和参考截图索引。
- 2026-06-09 19:02 已生成技术方案 `02-技术方案/tech-plan.md`；该方案覆盖 Flutter App、Java 后端、Web/Admin、MiniMax Provider、积分链路、专辑和歌词逐句时间轴。
- 2026-06-09 19:22 用户确认第三方生成音频需由后端下载/解码并保存到自有资源；已同步技术方案，明确第三方 Provider 只作为生成源，App 和后台只使用自有资源地址。
- 2026-06-09 19:29 用户补充资源持久化可能上传到第三方云存储；已同步技术方案，明确云存储属于我们账号控制下的自有资源存储实现，通过 `ResourceStorageProvider` 适配。
- 2026-06-09 19:45 用户进入下一步并要求工时评估按“大功能-前端、后端、Web端-具体小功能”口语化说明，同时按 AI 开发速度和 8 小时/天计算；已生成 `02-技术方案/effort-estimate.md`。
- 2026-06-09 19:50 用户反馈 AI 写代码很快，上一版工时偏长；已将 `effort-estimate.md` 修订为强 AI 辅助压缩版：可演示版约 16-20 人天，可上线版建议预留 32-35 人天。
- 2026-06-09 19:52 用户要求工时评估先按功能排时间，让人能看懂；已将 `effort-estimate.md` 主结构改为写歌功能、播放功能、情景写歌、Web 后台配置等功能排期。
- 2026-06-10 09:23 用户进入下一步；已生成 `03-前端/flutter-tech.md` 与 `04-后端/java-tech.md`。UI/Figma 流程保持 skipped，不进入代码实现。
- 2026-06-10 09:55 用户进入下一步；已生成 `03-前端/flutter-dev-plan.md` 与 `04-后端/java-dev-plan.md`，总体计划覆盖 App、Web/Admin、后端接口、Provider、资源持久化、歌词时间轴和权限。
- 2026-06-10 10:11 用户继续流程；已生成 App 端 11 个模块文档、Web/Admin 9 个模块文档、Java 后端 11 个模块文档。由于 UI/Figma 阶段用户已明确跳过，Flutter 模块文档中的视觉口径改用 PRD、参考截图和现有工程组件，不以缺失 `figma-design-plan.md` 作为阻塞。
- 2026-06-10 用户确认进入下一步，已进入 Flutter/Java 编码阶段；首批编码目标限定为基础链路：App 标识与 Song API/骨架、后端 catsinger schema/配置接口、Web/Admin App 切换与配置入口。
- 2026-06-10 11:20 首批基础链路编码完成：App 端完成 catsinger 标识、4 Tab、Song 配置/生成/作品/播放页面骨架；后端完成 catsinger schema、歌曲配置/生成/作品/专辑接口骨架、Admin App 列表和歌曲配置接口；Web/Admin 完成 App 切换和模型/情景/示例配置页。验证通过：后端 `./gradlew test`、Admin `flutter analyze`/`flutter test`、App `flutter analyze`/`flutter test`、三端 `git diff --check`。
- 2026-06-10 17:25 已按用户确认的“重写 V1/V12”方案完成后端 App 分层建表：公共表放 `db/migration/common/`，剧说表放 `db/migration/narrate/`，喵喵写歌表放 `db/migration/catsinger/`；后端数据规则和技术文档已同步，验证通过 `./gradlew test` 与 `git diff --check`。
- 2026-06-11 已完成 CHG-0008：写歌页新增“灵感速递”按钮，从 `GET /api/song-config/inspiration` 获取 prompt 并覆盖音乐描述；首页/作品页普通写歌入口直接切换到底部写歌 Tab；本轮不新增 Web/Admin 可视化配置页，灵感文案先复用 `app_configs`。
- 2026-06-11 验证记录：App `flutter analyze` 通过、`flutter test` 49 项通过；后端 `./gradlew test --tests SongConfigInspirationIntegrationTests` 通过；后端全量 `./gradlew test` 仍有反馈模块既有失败，非 CHG-0008 改动引入。
- 2026-06-11 16:55 已完成 CHG-0009：补充 `UserMembershipEntity`、`PointAccountEntity`、`PointLedgerEntity` 字段 JavaDoc；按用户要求，本轮不修改 SQL 迁移注释；验证通过 `./gradlew test --tests SchemaRoutingIntegrationTests`。
- 2026-06-11 18:00 已完成 CHG-0010：归档新产品文档和 v1.0 设计稿，重写需求清单、PRD、Flutter 技术文档、Flutter 总体计划和主页面模块文档；用户强调前端页面需按设计稿写 UI，已作为后续编码重点和验收基准。
- 2026-06-24 已完成 CHG-0013：新增 v1.1 AI 改编功能，包含 Flutter App 首页入口与三步改编流程、Java 后端 `music-cover` 任务链路和 Web/Admin 音色配置与作品类型筛选；验证通过后端 `./gradlew test`、App `flutter analyze` / `flutter test`、Admin `flutter analyze`、三端 `git diff --check`。
- 2026-06-25 用户要求“请先出需求文档”；已将当前阶段回退到 v1.1 AI 改编需求文档生成，重整 `01-需求/v1.1-ai-cover/requirements.md` 为完整 PRD，并等待用户确认或进入需求文档检测。
- 2026-06-25 用户要求“每个页面，帮我加上入口，跟里面的按键交互”；已补齐 v1.1 AI 改编 PRD 中每个页面的页面入口和页面内按键交互，不进入编码。
- 2026-06-25 用户要求“帮我生成对应的技术文档”；已生成/重写 `02-技术方案/v1.1-ai-cover/tech-plan.md`、`03-前端/v1.1-ai-cover/flutter-tech.md`、`04-后端/v1.1-ai-cover/java-tech.md`，当前等待用户确认。
- 2026-06-25 用户补充“对应的模块开发文档也需要有”；已生成 v1.1 AI 改编 Flutter/Web(Admin) 10 份模块开发文档、Java 9 份模块开发文档，并同步 `flutter-dev-plan.md`、`java-dev-plan.md`、`CURRENT.md`、`change-plan.md` 和本 workflow。
- 2026-06-25 用户确认“按照模块开发文档进行编码”；已完成 CHG-0013 三端代码对账与补齐：后端 `/api/song-covers` 强制 cover 模式并新增集成测试，Flutter 新增翻唱参数序列化测试，文档统一 `coverVoiceCode` 口径，新增 `05-联调与测试/v1.1-ai-cover-code-audit.md`。验证通过：后端 targeted tests / `./gradlew test`、App `flutter analyze` / `flutter test`、Admin `flutter analyze` / `flutter test`。
- 2026-06-25 用户追问“页面是否准确”；已确认此前不能宣称准确，并修正 AI 改编首页入口、三步页结构和底部导航小高度溢出。Web 预览首页入口已可见，AI 改编三步页因登录拦截仍需登录态/真机截图做最终视觉验收。
- 2026-06-25 用户反馈“选择歌曲后无反应、点击我确认无反应”；已修复 AI 改编页局部响应式刷新，覆盖作品选择、版权确认、上传状态、音色选择、高级设置和底部按钮；新增 Widget 测试 `song cover source selection and copyright tap update page`，验证通过 `flutter analyze`、`flutter test`、App `git diff --check`。
- 2026-06-11 18:20 已完成新 PRD 需求文档检测：补齐页面级交互流程图和关键状态后检测 PASS；下一步建议同步技术方案和后端接口缺口。
- 2026-06-11 18:27 已完成技术方案 v0.1.1 同步：新增图片写歌、AI帮写、参考音频、热门案例详情、最近作品、真实分享、会员积分商品、生成进度字段、上传资源表和后端接口补强。
- 2026-06-11 已按核心流程新增版本隔离规则：当前有效文档版本为 `v1.0-design-mvp`，旧 Sonus 参考图、旧页面骨架和旧开发计划归入 `legacy-20260610/reference-only`，不得作为后续编码执行依据。
- 2026-06-11 已按用户要求从第 8 步继续且中间不停留：后端 Java 技术文档、Java 总体开发计划和 Java 模块开发文档已同步到 `v1.0-design-mvp`；下一步 Java 编码从 `04-后端/开发计划/01-schema-and-migration.md` 开始。
- 2026-06-11 Java 编码完成：后端 T-B001 至 T-B014 已落地，包含 catsinger 迁移、配置/案例、素材上传、AI 帮写、生成积分冻结、MiniMax Provider、资源持久化、歌词时间轴、作品/专辑、商品 App 隔离、Admin App/角色权限、Admin Song API，并修复反馈模块 appCode 边界；验证通过 `./gradlew test` 和 `./gradlew build`。
- 2026-06-11 已启动 CHG-0011：用户反馈前端 UI 未按设计稿实现，已新增 `03-前端/ui-rework-dev-plan.md`，审计结论为需求文档、技术方案、Java 后端、Web/Admin 不需要全部返工；Flutter App 需按新设计稿局部返工四个主 Tab、底部导航和接口消费。
- 2026-06-11 用户指出返工文档仍太简单，要求按模块输出详细模块开发文档后再按模块开发；已新增 `03-前端/开发计划/rework/00-rework-index.md` 至 `08-qa-acceptance.md`，旧 `04-home.md` 等只作参考。
- 2026-06-12 已按 CHG-0011 rework 模块文档完成 Flutter UI 返工编码：新增主题和公共组件，重写底部 Tab、首页、写歌页、作品/专辑页、我的页，并补齐热门案例、最近作品、AI帮写和生成进度字段；验证通过 `flutter analyze`、`flutter test` 49 项和 App 工程 `git diff --check`。
- 2026-06-22 已完成高级创作参考音频子能力：App 端支持现场录制、导入音频、上传 `/api/song-assets/reference-audios`、生成提交携带 `referenceAudioAssetId`；验证通过 `flutter analyze`、`flutter test` 83 项和 App 工程 `git diff --check`。
- 2026-06-23 已按用户反馈调整导入音频来源：导入入口改为从系统相册/媒体库查找音频资产，并补 Android 音频媒体权限；验证通过 `flutter analyze`、`flutter test` 84 项和 App 工程 `git diff --check`。
- 2026-06-23 已按用户反馈修复灵感创作携带音频参数：`referenceAudioAssetId` 只在高级创作且音频上传成功时提交，灵感/场景创作请求体不再带该字段；验证通过 `flutter analyze`、`flutter test` 88 项和 App 工程 `git diff --check`。
- CHG-0010 后，旧 Sonus 参考图只作历史参考；前端 UI 以 `01-需求/references/images/v1.0/` 为真源。
- CHG-0010 新增图片写歌、AI帮写、参考音频、真实下载分享、会员积分等真功能范围，后续需同步技术方案、后端 Java 文档和接口实现。
- `appCode` 需求已锁定为 `catsinger`。
- 歌曲生成首期平台为 MiniMax，但接口需要预留按 provider/model 路由不同平台。
- 生成计费采用按次扣积分。
- 2026-06-09 18:01 用户补充：需要在 `/Users/soul/code/lxwx/lxwx_admin` 新增后台 Web 管理页面，并可切换 app 显示对应 app 的数据。
- 2026-06-09 18:12 用户确认：App 名称、包名、默认模型、默认价格、运营素材配置、分享占位、专辑、后台 appCode 配置范围和后台可操作能力。

---

## 10. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 算道请求、查询状态码和资源字段的精确映射 | 影响技术 DTO、状态映射和资源下载实现，不再阻塞产品规则 | 技术方案逐字段核对；产品侧已确定主动轮询、厂商确认接单后 10 分钟总处理时限、真实资源校验和多渠道路由，不得静默改回待定 |
| 多渠道下音色绑定与商家模型配置结构 | 影响数据库、Provider 路由和 Admin 交互 | 技术方案设计“平台业务模型—渠道—商家模型—音色绑定”关系；无有效绑定时不自动跨渠道 |
| MiniMax 真实配置值未提供 | 不阻塞技术方案；后续真实联调会受影响 | 配置方案参考既有阿里云短信方案，代码完成后再添加真实配置 |
| 图片写歌最终 Provider 未定 | 影响图片内容能否真实转成音乐描述 | 技术方案已保留 `SongImagePromptProvider` 抽象，上线前必须选定可用 Provider |
| 参考音频真实生成效果待联调 | 不阻塞 App 端闭环；影响最终生成效果验收 | App 已完成录音/相册导入/上传和 `referenceAudioAssetId` 提交，需结合 MiniMax 配置确认参考音频实际生效 |
| 分享形态和会员积分 SKU 未定 | 影响最终分享页和支付商品验收 | Web/Admin 先支持配置，工时评估和后续编码按可配置方案预留 |

---

## 11. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 需求分析 | `01-需求/requirements-list.md` | `done` | 已确认并用于生成 PRD |
| 需求文档生成 | `01-需求/requirements.md` | `done` | 已通过需求文档检测 |
| 需求文档检测 | `01-需求/detection-feedback.md` | `done` | 新 PRD 检测 PASS，等待用户确认进入技术方案同步 |
| Figma 设计稿计划 | `01-需求/figma-design-plan.md` | `skipped` | 用户明确跳过 UI 这一个流程 |
| 技术方案 | `02-技术方案/tech-plan.md` | `done` | 已同步新 MVP 真功能，等待进入工时重估 |
| 工作时长评估 | `02-技术方案/effort-estimate.md` | `pending` | 新 MVP 范围扩大，待重新评估 |
| 前端 Flutter 技术文档 | `03-前端/flutter-tech.md` | `done` | 已作为总体开发计划输入 |
| 后端 Java 技术文档 | `04-后端/java-tech.md` | `done` | 已同步 v1.0-design-mvp |
| Flutter 总体开发计划 | `03-前端/flutter-dev-plan.md` | `done` | 已作为模块开发文档输入 |
| Java 总体开发计划 | `04-后端/java-dev-plan.md` | `done` | 已按 T-B001 至 T-B014 重写 |
| Flutter 模块开发文档 | `03-前端/开发计划/*.md` | `done` | 用户已继续进入编码，模块文档作为编码输入 |
| Java 模块开发文档 | `04-后端/开发计划/*.md` | `done` | 已生成当前版本 14 个模块文档 |

---

## 12. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-09-13 | CHG-0076 / 第 5～6 步 | 用户要求继续，将当前技术方案记 `done`；按单人 AI 辅助、8 小时/天和周末休息生成当前版本增量工时评估，并归档旧根路径 v0.1.2 评估 | `02-技术方案/v2.1-model-driven-params/effort-estimate.md` 为第 6 步 `waiting_review`；6.5 个工作日含三端骨架、真实实现、后台配置、Android/iOS 测试和 Bug 修复，骨架单独评审门禁有效；未修改三端业务代码 |
| 2026-09-13 | CHG-0076 / 第 3～5 步 | 用户要求继续，确认新版第 3 步检测 PASS；第 4 步沿用当前 Figma `skipped`；只读核对 Flutter/Java/Admin 后生成当前版本技术方案 | `02-技术方案/v2.1-model-driven-params/tech-plan.md` 为第 5 步 `waiting_review`；旧技术与开发计划仍仅作差异输入，未修改三端代码、数据库或线上配置 |
| 2026-09-13 | CHG-0076 / 当前 Figma 口径纠正 | 按用户明确说明重新连接 `vn7k0jqv`，确认 `working (91:106)`；更新 PRD、检测报告、资源索引与恢复点 | 当前 Figma 是视觉/交互真源，21 图仅为快照；第 4 步不重复设计计划，保持第 3 步 PASS 待确认；未改 Figma 或三端代码 |
| 2026-09-13 | CHG-0076 / 动态数值与设计稿边界 | 按用户最新决策更新全局流程、需求/设计/UI 规则及当前 PRD、Review、检测报告、资源索引和恢复点 | 示例数值与运行时配置差异不构成设计冲突；Figma 原稿不改，App 实际业务文案按已确认需求实现；第 3 步继续 `waiting_review`，未改三端代码 |
| 2026-09-13 | CHG-0076 / 第 3 步新版需求检测 | 对照飞书提炼笔记、21 张新 Figma 截图及算道已知能力；补齐歌词截图并标出训练 1 分钟与音色创建两处文案冲突；执行双文档结构/链接/镜像检查 | `v2.1-model-driven-params/detection-feedback.md` PASS、`waiting_review`；仅文档修订，下一步待确认后走第 4 步，未修改三端代码 |
| 2026-09-13 | CHG-0076 / D-03、D-04 产品决策校准 | 按用户补充修正训练素材硬限制与算道音色厂家隔离，重写 PRD、清单、Review 并同步根路径镜像 | 未声明时长/片段上限不阻断训练模型；算道音色只供算道兼容模型；同厂 SoVITS/Suno 兼容待技术核验。需求仍 `waiting_review`，未修改三端代码 |
| 2026-09-13 | CHG-0076 / 第 1～2 步需求回卷 | 读取三份新飞书与 Figma `vn7k0jqv`，导出 21 张关键画面，原样归档旧需求，重写清单/PRD/Review 并同步根路径与流程入口 | `v2.1-model-driven-params` 需求三件套 `waiting_review`；旧检测/技术/计划 `needs_reconciliation`；仅文档和设计资源变动，三端代码与并行 QA 保留 |
| 2026-09-09 | CHG-0073 / 第 13～14 步真实实现 | 用户明确确认骨架并授权真实实现；按当前模块文档完成 Flutter App 与 Java 代码、定向验证和 iOS 375x812 页面检查 | Flutter T-F001-R～T-F010-R、Java T-B001-R～T-B013-R 本地完成并进入 `real_review`；Web/Admin deferred，T-B014-R、Android 真机及部署后真实训练/翻唱/付费/审核/可播放闭环待验收 |
| 2026-09-09 | CHG-0075 / 全局规范与 CHG-0073 文档回卷 | 增加 `skeleton_first`、实现阶段字段、`-S/-R` 任务和骨架整体评审门禁；同步 Flutter/Java 工程规则与 V2.1 总体/模块计划 | 规则及文档已更新；CHG-0073 保持第 11/12 步 `waiting_review`、`skeleton_pending`，Web/Admin deferred；未修改业务代码或数据库 |
| 2026-09-09 | CHG-0073 / 第 11～12 步 | 用户继续下一步，将前后端总体计划收口，并按当前版本任务、技术文档、Figma 与三端代码边界生成模块开发文档 | `flutter-dev-plan.md`、`java-dev-plan.md` 为 `done`；Flutter/Web 15 份与 Java 15 份模块文档已生成并完成契约扫描，当前 `waiting_review`；未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / 第 7～10 步 | 用户确认继续并提供 Figma 通道 `ujnpl6tr`；核验当前 38 个 Frame 后，将技术文档收口并生成 Flutter/Java 总体开发计划 | `flutter-tech.md`、`java-tech.md` 为 `done`；`flutter-dev-plan.md`、`java-dev-plan.md` 为 `waiting_review`；下一步是第 11/12 步模块开发文档，未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / 第 6～8 步 | 用户在 7 个 AI 工作日完整排期后要求继续；将工时评估收口，并按当前版本需求、技术方案、Figma 与三端代码基线生成 Flutter/Java 技术文档 | 工时评估 `done`；`03-前端/v2.1-ai-cover-voice-clone/flutter-tech.md` 与 `04-后端/v2.1-ai-cover-voice-clone/java-tech.md` 已生成并进入 `waiting_review`；第 9/10 步开发计划仍为 `pending`，未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / 第 5～6 步 | 按用户问题核对现有 Flyway、实体、资源台账和作品生命周期，收缩数据库方案；工时改按 Codex 直接写三端代码的真实速度计算 | 技术方案只新增 7 张声音克隆领域表及现有任务/作品最小关联字段并标记 `done`；最终排期为 7 个 AI 工作日，明确包含后端部署配置、真实音色训练/翻唱、完整测试和 Bug 修改；当前第 6 步 `waiting_review`，未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / 公开接口最终隔离（D-U09） | 按用户最终确认，将翻唱声音克隆改为独立 `/api/song-voice-covers`；公开创建请求不传 `mode`，服务端固定内部 `VOICE_COVER`，并继续提交真实 `provider/model` | 需求清单、PRD、Product Review、检测反馈、技术方案、变更计划与当前入口已同步；AI 写歌和 AI 改编公开接口不变，内部任务、工作流、模型、审核、积分、资源和作品继续共用；第 5 步保持 `waiting_review`，未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / Java 业务目录边界校准 | 对账 `SongCoverController` 和 `SongCoverVoiceEntity` 后，按用户确认新增同级 `app/catsinger/voicecover/`，隔离现有 AI 改编与翻唱声音克隆业务代码 | 技术方案、变更计划和当前入口已同步；`voicecover/` 独立承载专属业务，任务、工作流、模型、审核、积分、资源和作品继续共用；公开入口随后由 D-U09 校准为 `/api/song-voice-covers`，第 5 步保持 `waiting_review`，未创建代码目录 |
| 2026-09-09 | CHG-0073 / 生成接口与模型字段中间校准（D-U08） | 先纠正业务类型与厂家模型混淆，明确 `provider/model` 传模型列表返回的真实厂家编码；当时暂定公开复用 `/api/song-generations` 并传 `mode` | 模型字段结论继续有效；公开接口部分随后由 D-U09 替代。现有 AI 改编 `/api/song-covers` 始终保持不变，未修改三端业务代码 |
| 2026-09-09 | CHG-0073 / 翻唱超时起点校准 | 按用户反馈将平台排队从 10 分钟翻唱总处理时限中排除，改为厂商确认接单并返回可查询任务标识后开始计时 | 需求清单、PRD、Product Review、检测反馈、技术方案、变更计划和当前入口已同步；厂商侧排队、生成、平台持久化、审核和可播放校验均计入；第 5 步保持 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 产品名称校准 | 将 V2.1 新功能正式展示名统一为「翻唱声音克隆」，并与现有 AI 改编保持清晰区分 | 需求、技术方案、Figma 资源说明、变更计划与当前流程入口已同步；原始资料名称和内部 `VOICE_COVER`、场景编码、页面路由、版本目录保持不变；生成 API 与模型字段于 2026-09-09 另行校准。第 5 步继续 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 三业务共用流程校准 | 按用户澄清，将生成歌曲、AI 改编、翻唱声音克隆定义为三个独立业务，并删除 V2.1 对现有 AI 改编的改名、迁移、UI 和后台配置调整要求 | 需求清单、PRD、Product Review、检测报告、技术方案、变更计划和当前入口已同步；技术方案明确翻唱声音克隆以新模式和专属步骤进入现有歌曲业务流程，AI 改编零修改；第 5 步保持 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 第 5 步当前业务体系对账 | 只读检查 Java 资源/审核、Catsinger 歌曲任务与工作流、模型路由/选项、积分、作品及 Admin 页面/API；按用户反馈回卷技术方案和三份需求文档 | 确认站内 asset/work/reference 在任务内沿用 AI 改编的免重复源审核逻辑；V2.1 上传阶段复用现有审核记录建立受信事实；不新增隔离资源状态、通用内容版本、报价单、平行歌曲任务或 `/api/admin/ai-cover` 体系；第 5 步保持 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 第 3～5 步 | 用户确认需求检测结论通过，并明确 Figma 设计稿已经定稿、直接跳过设计计划；以 38 个有效 Frame、当前 PRD 和三端代码基线生成 V2.1 技术方案 | 第 3 步 `done`、第 4 步 `skipped`，未生成 `figma-design-plan.md`；`02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md` 已生成并进入 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 第 3 步完整需求检测 | 收口 Q-A01～Q-A05，连接新 Figma 通道 `dfgz0898`，对需求清单、PRD、Product Review、38 个 Frame、DOCX、算道能力目录和代码基线执行一致性检测 | 检测 PASS；补齐 6 个 App 页面交互流程，将反向 Review 压缩为 15 个场景；当前 `waiting_review`，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / P12 播放器 UI 校准 | 删除旧截图和自定义播放器结构，明确直接复用当前工程 `SongPlayerPage` | 需求清单、完整 PRD、Product Review 和检测反馈已同步；未修改 Flutter、Java 或 Admin 代码，仍为第 2 步 `waiting_review` |
| 2026-09-08 | CHG-0073 / Web/Admin 需求并入产品文档 | 将原 P13 后台总纲扩展为 W01～W12 共 12 个逻辑页面，补齐模型路由、价格、官方/本人音色、安全审核、训练/翻唱任务、作品资源、角色权限和操作审计 | 全部内容已并入 `requirements.md` P13，独立后台需求文件已删除；同步需求清单、Product Review、检测反馈和当前入口，Q-A01～Q-A05 等待评审，未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / 需求检测阶段用户反馈回卷 | 将“图片、音频、文字上传均需安全审核”登记为 D-U07，并同步需求清单、完整 PRD、Product Review、变更计划和当前入口 | 当时先记录上传审核、页面门禁、计费、人工复核和成品审核；随后在第 5 步按当前后端资源/审核体系及用户最新反馈完成实现口径校准，本轮始终未修改三端业务代码 |
| 2026-09-08 | CHG-0073 / V2.1 Product Review 收口 | 将用户对 Q-P01～Q-UI01 的逐项答复同步到需求清单、完整 PRD、Product Review、变更计划和当前入口 | 三份需求文档状态改为 `done`；确定 10 分钟歌曲/任务规则、平台并发、多渠道和商家模型切换、无取消、主动轮询、真实资源兼容、官方音色来源、默认 100/200 积分及低置信度告警放行；超时起点后续于 2026-09-09 校准；流程推进到第 3 步需求文档检测 `pending`，未修改三端代码 |
| 2026-09-08 | CHG-0073 / V2.1 需求分析与文档生成 | 归档用户 DOCX，只读读取 Figma 通道 `w2197tnq`，校准 AI 改编/翻唱声音克隆边界并生成需求清单、完整 PRD 和 Product Review | `waiting_review`；当前 Figma 可读取 38 个有效 Frame 并全部导出 PNG，原列表中的重复训练指南节点 `114:7853` 已由外部移除；输出格式、音色可用性和资源保留规则已按用户修正，不修改三端业务代码 |
| 2026-09-07 | 联调与测试 QA / 测试服全量与购买复测 | 执行 329 条 full，补测模型选择、0.01 元会员、0.01 元积分及简易生成 | full 为 12 PASS/1 FAIL/1 BLOCKED/315 NOT_RUN，Run ID `20260907-021240-a11317`；FAIL 为 Python TLS 辅助校验，App 已进入专业生成 65%；模型切换回显、会员到账并增 800 积分、积分购买再增 800、简易模式 20 积分完整生成均 PASS；QA 保持 `in_progress` |
| 2026-09-07 | CHG-0070 Flutter 编码 / 生成完成跳转 | 复现“旧歌正在播放、任务成功返回新 `workId`”组合，修正播放器对全局播放歌曲的采纳边界并补回归 | 显式路由目标保持为新作品，旧播放会话不再覆盖页面；目标作品开始播放后继续允许上一首/下一首联动；4 条 Widget 回归与 `flutter analyze` 通过，未跑全量测试，当前 QA 主线不变 |
| 2026-09-07 | 联调与测试 QA / 三模式完整复测 | 按真实业务流程独立执行简易模式、专业模式和歌曲改编/翻唱；付费生成已授权 | 专业模式 PASS（润色歌词后完整生成，Run ID `20260907-104945-flow-create-001`）；歌曲改编/翻唱 PASS（上传、100 积分、生成和 0:59 播放器均完成）；简易模式切换普通模型后仍因测试账号缺会员权益 BLOCKED，未扣积分；全量 QA 保持 `in_progress` |
| 2026-09-07 | 联调与测试 QA / 专业模式专项复测 | 单独复跑 `FLOW-CREATE-001 --allow-paid` 并补跑 `CREATE-001` | 完整闭环仍在进入专业模式前因 `Unsupported X-App-Code` FAIL；专业模式页面及主要控件 1/1 PASS，Run ID `20260907-102655-create-001`；提交、扣积分和 Provider 尚未验证 |
| 2026-09-07 | 联调与测试 QA / 纠正后全量执行 | 按当前 329 条目录执行 `full --mode balanced --allow-paid --allow-delete` | 12 PASS、1 FAIL、1 BLOCKED、315 NOT_RUN；`FLOW-CREATE-001` 因 `Unsupported X-App-Code` FAIL，`WORK-004` 因缺生成中作品 BLOCKED；未创建任务、未扣积分、未删除作品；Run ID `20260907-102144-fa0cbd` |
| 2026-09-07 | 联调与测试 QA / 提现范围纠正 | 按用户确认，将仓库中的提现代码骨架与当前版本已交付业务区分，移除 8 条 WITHDRAW 和依赖提现页的 INVITE-008 | 当前 catalog 329 条，覆盖矩阵和 23 项框架自检通过；修正后 destructive 11 NOT_RUN，Run ID `20260907-101115-edeea1`；提现不再属于本版本测试范围 |
| 2026-09-07 | 联调与测试 QA / 付费及 destructive 授权 | 按用户授权执行 `paid --allow-paid` 与 `destructive --allow-delete --allow-withdrawal`；账号注销不授权 | paid 为 0 PASS/1 FAIL/56 NOT_RUN，自动闭环在提交前被 `Unsupported X-App-Code` 拒绝，未创建任务或扣积分；destructive 为 16 NOT_RUN，未删除作品、未提现；Run ID 分别为 `20260907-100829-008373`、`20260907-100902-07efab` |
| 2026-09-07 | 联调与测试 QA / v1.2.0+121-as-built 安全全量 | 在 Android `e2b8595a` 执行 `full --mode balanced`，不提供付费、删除、提现和注销授权 | 338 条中 12 PASS、0 FAIL、2 BLOCKED、324 NOT_RUN；14 条自动化结果均有截图和 UI XML；Run ID `20260907-100315-200a49`；catsinger 路由仍为 `Unsupported X-App-Code`，完整 QA 保持 `in_progress` |
| 2026-09-04 | CHG-0068 场景模型映射与移动端单次任务模型选择 | Java 新增映射表、公开/后台接口和任务快照；Admin 新增通用映射页；catsinger 三类写歌入口接入动态选项；通过 cursor-talk-to-figma-mcp 重新检测用户最新界面并补齐交互标注 | `waiting_review`；后端映射、任务和 OpenAPI 专项、Admin AI 配置页测试文件 11 项、catsinger 3 项及双端 `flutter analyze` 通过；后端全量报告 851 项，3 个会员周期/时间边界用例失败，另有 1 个执行器 512MB heap OOM；未部署、未执行真实迁移或映射配置，待联调验收 |
| 2026-08-13 | CHG-0066 iOS 登录三入口调整 | 登录首页固定展示“游客登录 / 手机号登录”，后台预检成功后显示“一键登录”，取消自动拉起；用户点击才打开运营商授权页，关闭后可再次点击，其他手机号进入短信页，不可用时隐藏入口 | iOS 三入口 5 项与含 Android 自动流程的登录回归 7 项通过，`flutter analyze` 与 iOS Simulator 构建通过；无后端、数据库、Admin、游客积分和支付业务变更，待带 SIM iPhone 真机验证运营商授权页 |
| 2026-08-12 | CHG-0066 正式服 Sandbox 会员补单真机验收 | 用户在 iPhone 14 Pro 的 1.1.0+111 构建触发旧交易补单；后端订单确认 paid，客户端完成 StoreKit 交易并清空待确认缓存；补充 appAccountToken UUID 大小写无关匹配和回归用例 | 游客账号会员有效至 2026-09-11，积分余额 830；重复支付流回调保持幂等；iOS 支付专项 21 项和 `flutter analyze` 通过，待重装恢复、退款/撤销与审核路径验收 |
| 2026-08-12 | CHG-0066 iOS 跨环境遗留交易阻塞修复 | Apple 本地待确认订单新增服务环境归属，按“用户 + local/test/prod + baseUrl”隔离；旧版本无环境缓存不再提交当前服务确认；正式服对测试订单返回通用 404 时按订单不匹配清理 StoreKit 旧交易，非续期会员同一次点击继续创建正式服新订单 | 游客/环境归属 4 项、iOS 支付专项 20 项、支付 UI 8 项和 `flutter analyze` 通过；无后端代码和数据库变更，待安装新 iOS 构建并确认正式服 catsinger Sandbox 审核模式后真机复测 |
| 2026-08-12 | CHG-0066 iOS 会员购买补单阻塞修复 | 将补单结果拆分为已确认、无归属已清理、取消、处理中和失败；会员无归属旧交易完成 StoreKit 清理后继续当前购买，积分无归属交易继续阻断；修复订单不匹配测试夹具 | iOS 支付专项 20 项、支付 UI 8 项、`flutter analyze` 与 iOS Simulator Debug 构建通过；无数据库变更，待当前 Sandbox 账号真机复测。全量旧 `widget_test.dart` 因历史 `????` 断言和动画超时未通过，与本次支付路径无关 |
| 2026-08-12 | CHG-0066 iOS 游客账号与订阅恢复 | 实现共享后端游客会话/绑定/Apple 恢复、Keychain 凭证、账号类型、路由分级、待确认订单归属和三处主动恢复入口；统一所有新用户创建时发放一次 30 积分 | `waiting_review`，游客创建/恢复/绑定积分专项通过，绑定手机号不重复发放；Flutter 游客专项、静态分析和 iOS Simulator 构建通过；待 StoreKit Sandbox 真机验收 |
| 2026-06-09 17:52 | 需求分析 | 归档 UI 参考图并整理需求清单 | 已生成 `requirements-list.md`，等待确认 |
| 2026-06-09 18:01 | 需求分析 | 补充 Web/Admin 后台管理需求 | 已更新需求清单、参考资料和变更记录 |
| 2026-06-09 18:12 | 需求分析 | 固化用户确认项 | 已更新需求清单、参考资料、流程和变更记录 |
| 2026-06-09 18:35 | 需求文档生成 | 根据需求清单生成 PRD | 已生成 `01-需求/requirements.md`，等待用户评审 |
| 2026-06-09 18:46 | 需求文档生成 | 收口 PRD 待确认项 | 已更新 `requirements.md`、`requirements-list.md`、参考资料、变更记录和流程 |
| 2026-06-09 18:46 | 需求文档检测 | 对 PRD 进行结构、一致性、交互和历史反馈闭环检测 | 已生成 `01-需求/detection-feedback.md`，结论 PASS |
| 2026-06-09 18:54 | Figma 设计稿计划 | 用户要求跳过 UI 这一个流程 | 已将第 4 阶段标记为 skipped，进入技术方案阶段 |
| 2026-06-09 19:02 | 技术方案 | 生成技术方案计划 | 已生成 `02-技术方案/tech-plan.md`，等待用户确认 |
| 2026-06-09 19:22 | 技术方案评审 | 补强第三方音频结果自有存储方案 | 已更新 `02-技术方案/tech-plan.md`、`change-plan.md`、`change-log.md`，继续等待技术方案确认 |
| 2026-06-09 19:29 | 技术方案评审 | 补充第三方云存储适配方案 | 已更新 `02-技术方案/tech-plan.md`、`change-plan.md`、`change-log.md`，继续等待技术方案确认 |
| 2026-06-09 19:45 | 工作时长评估 | 生成 AI 辅助开发工时评估 | 已生成 `02-技术方案/effort-estimate.md`，等待用户确认 |
| 2026-06-09 19:50 | 工作时长评估评审 | 收紧 AI 辅助开发工时评估 | 已更新 `02-技术方案/effort-estimate.md`、`change-plan.md`、`change-log.md`，继续等待工时确认 |
| 2026-06-09 19:52 | 工作时长评估评审 | 工时评估改为按功能排期 | 已更新 `02-技术方案/effort-estimate.md`、`change-plan.md`、`change-log.md`，继续等待工时确认 |
| 2026-06-10 09:23 | 前后端技术文档 | 生成 Flutter 与 Java 技术文档 | 已生成 `03-前端/flutter-tech.md` 和 `04-后端/java-tech.md`，等待用户确认 |
| 2026-06-10 09:55 | 前后端总体开发计划 | 生成 Flutter 与 Java 总体开发计划 | 已生成 `03-前端/flutter-dev-plan.md` 和 `04-后端/java-dev-plan.md`，等待用户确认 |
| 2026-06-10 10:11 | 前后端模块开发文档 | 生成 Flutter/App、Web/Admin 与 Java 模块开发文档 | 已生成 `03-前端/开发计划/*.md` 与 `04-后端/开发计划/*.md`，等待用户确认 |
| 2026-06-10 11:20 | Flutter/Java/Web 编码 | 完成首批基础链路编码并验证 | 已完成 App 标识与歌曲页面骨架、后端 catsinger schema 与歌曲配置/作品接口骨架、Web/Admin App 切换与歌曲配置页；验证通过后端 `./gradlew test`、Admin `flutter analyze`/`flutter test`、App `flutter analyze`/`flutter test`、三端 `git diff --check` |
| 2026-06-10 17:25 | Java 编码 / 数据库迁移 | 重写 V1/V12 为按 App 分层建表 | 已拆分 Flyway 目录为 common/narrate/catsinger，调整迁移策略、schema routing 测试、任务中心测试和后端数据规则；验证通过后端 `./gradlew test` 与 `git diff --check` |
| 2026-06-11 11:56 | Flutter/Java 编码 | 完成写歌页灵感速递与入口切 Tab | 已完成 App 写歌页参考图式 UI、灵感速递请求、首页/作品页普通入口切 Tab、后端 `/api/song-config/inspiration`、catsinger 默认灵感配置迁移和集成测试；验证通过 App `flutter analyze`、`flutter test`、后端新增接口测试 |
| 2026-06-11 16:55 | Java 编码 / 实体注释 | 补充权益和积分实体字段注释 | 已补充 `UserMembershipEntity`、`PointAccountEntity`、`PointLedgerEntity` 字段 JavaDoc；SQL 迁移文件无本轮注释 diff；验证通过 `./gradlew test --tests SchemaRoutingIntegrationTests` 和本轮文件 `git diff --check` |
| 2026-06-11 18:00 | 需求与前端计划重整 | 按新产品文档和设计稿重整 PRD 与前端 UI 计划 | 已归档新资料，重写 `requirements-list.md`、`requirements.md`、`flutter-tech.md`、`flutter-dev-plan.md`，新增 `flutter-ui-implementation-plan.md`，并更新主页面模块文档；本轮只改文档，不改代码 |
| 2026-06-11 18:20 | 需求文档检测 | 检测 CHG-0010 后的新 PRD | 已补齐页面级交互流程图和关键状态，生成 `01-需求/detection-feedback.md`，检测结论 PASS |
| 2026-06-11 18:27 | 技术方案 | 同步 CHG-0010 后的新 MVP 技术方案 | 已更新 `02-技术方案/tech-plan.md` 至 v0.1.1，补齐图片写歌、AI帮写、参考音频、热门案例、分享、会员积分和生成进度字段；等待用户确认后进入工时重估 |
| 2026-06-11 19:10 | 核心流程规则 | 补齐版本迭代与文档隔离状态 | 历史记录：曾按 `v1.0-design-mvp` 维护文档版本矩阵；现已迁移为主路径最新、旧索引 `reference-only` |
| 2026-06-11 19:30 | 后端 Java 技术文档 | 从第 8 步继续同步 Java 技术文档 | 已将 `04-后端/java-tech.md` 更新为 `v1.0-design-mvp` active 文档，覆盖新 MVP 接口、表结构、Provider、资源、积分和权限 |
| 2026-06-11 19:35 | Java 总体开发计划 | 同步第 10 步 Java 总体开发计划 | 已将 `04-后端/java-dev-plan.md` 更新为 T-B001 至 T-B014 当前版本计划 |
| 2026-06-11 19:40 | Java 模块开发文档 | 同步第 12 步 Java 模块开发文档 | 已替换旧 11 个模块文档，生成当前版本 14 个模块文档；流程恢复点推进到 Java 编码 T-B001 |
| 2026-06-11 21:39 | Java 编码 | 完成 T-B001 至 T-B014 后端编码与回归 | 已完成 catsinger 后端 14 个模块、Admin 权限与歌曲后台 API，并修复反馈模块 appCode 边界；验证通过 `./gradlew test` 和 `./gradlew build` |
| 2026-06-11 | Flutter 编码 / UI 返工影响审计 | 新增 CHG-0011 前端 UI 返工开发文档并回写流程 | 已生成 `03-前端/ui-rework-dev-plan.md`，小修 `requirements.md`、`tech-plan.md`、`flutter-dev-plan.md`，当前阶段切回 `13 Flutter 编码`；结论为局部返工，不需要全部返工 |
| 2026-06-11 | Flutter 编码 / UI 返工模块文档 | 按模块细化 CHG-0011 前端 UI 返工开发文档 | 已新增 `03-前端/开发计划/rework/00-rework-index.md` 至 `08-qa-acceptance.md`，并将下一步恢复点改为从 `01-ui-foundation.md` 开始逐模块编码 |
| 2026-06-22 | Flutter 编码 / 高级创作参考音频 | 完成参考音频录制、导入、上传和生成提交闭环 | 已在 App 端新增 `record`、平台录音权限、参考音频上传 API、Controller 状态、截图样式双入口、内联模型列表和相关 Widget/API 测试；验证通过 `flutter analyze`、`flutter test` 83 项和 App 工程 `git diff --check` |
| 2026-06-23 | Flutter 编码 / 导入音频来源调整 | 导入音频改为从相册/媒体库查找音频 | 已将写歌页导入音频从文件选择器调整为 `wechat_assets_picker` 音频资产选择，补 `Access.audio`、Android `READ_MEDIA_AUDIO`、iOS 相册用途文案和权限测试；验证通过 `flutter analyze`、`flutter test` 84 项和 App 工程 `git diff --check` |
| 2026-06-23 | Flutter 编码 / 创作提交参数修复 | 灵感创作不再携带音频参数 | 已将生成请求中的 `referenceAudioAssetId` 限定为高级创作上传成功音频，参数模型不再序列化空音频字段，并补灵感/场景不带音频参数回归测试；验证通过 `flutter analyze`、`flutter test` 88 项和 App 工程 `git diff --check` |
| 2026-06-25 | v1.1 AI 改编 / 模块开发文档 | 生成 Flutter/Web(Admin) 与 Java 模块开发文档 | 已生成 `03-前端/v1.1-ai-cover/开发计划/00-09` 共 10 份、`04-后端/v1.1-ai-cover/开发计划/00-08` 共 9 份，并同步 v1.1 前后端开发计划、CURRENT、change-plan 和 workflow |
| 2026-07-10 | 联调与测试 QA / 整 App 用例 | 基于 Flutter 当前代码为 v1.0 全量和 v1.1 AI 改编生成测试基线与模块用例 | 已生成 `frontend-code-test-baseline.md`、`qa-plan.md` 和 `cases/00-10` 共 223 条用例；第15步切为 in_progress，下一步执行 P0 冒烟 |
| 2026-07-31 | 联调与测试 QA / 实际交付校准 | 按当前 Android 1.1.0 和 Flutter 代码重新整理需求、UI 截图和测试用例 | 已完成 CHG-0014，新增 `v1.1.0-as-built` 需求、5 张真机截图、当前代码基线和整 App 用例；旧 223 条用例改为 reference-only |
| 2026-07-31 | 工作区路径恢复 | 将错误工作区别名 catsinger 原样归档并安全合并 | CHG-0015～CHG-0040 已重编号迁入；当前 v1.1.0-as-built QA 主线保持不变 |
| 2026-07-31 | Flutter 编码 / 全局加载样式 | 按加载设计稿统一全 App 非确定性加载状态 | 已完成 CHG-0042：新增五点渐变加载组件及三档规格，迁移页面、按钮、Toast、媒体缓冲和 12 处下拉刷新；保留 5 处确定性进度条；`flutter analyze`、42 项独立测试、专项 Widget 测试和相关路由单测通过；完整 `widget_test.dart` 仍受既有 `????` 占位断言影响 |
| 2026-07-31 | Flutter 编码 / 加载尺寸复核 | 根据 Figma 节点 `65:1470` 校正完整加载组合尺寸 | 已将完整组合锁定为 65×81：圆点区 65×49、上下间距 15、文字行高 17；脉冲缩放下限由 72% 提高到 90%，避免视觉尺寸偏小；专项 Widget 测试与 `flutter analyze` 通过 |
| 2026-07-31 | Flutter 编码 / 下拉刷新样式 | 将系统下拉刷新圆环替换为设计稿五点图标并缩小尺寸 | 12 处页面统一迁移到 `AppRefreshIndicator`，保留原刷新手势、回调和禁用逻辑；刷新图标固定宽 28（高约 21），不显示系统圆环或背景圆盘；新增拖拽触发 Widget 测试 |
| 2026-07-31 | 联调与测试 QA / ADB 冒烟加速 | 复用整套会话并打印逐条和汇总结果 | 已完成 CHG-0043：默认 balanced 模式 10/10 PASS、63.96 秒，较 296.88 秒缩短约 78.5%；22 项框架单测、147/147 目录校验、四类报告和 isolated 抽查通过 |
| 2026-08-03 | Flutter 编码 / 五点整体旋转与距离联动刷新 | 按参考图让固定弧线五点整体转圈，并让下拉角度跟随距离 | 已完成 CHG-0042 增量：五点几何为 65×49 并置于方形旋转场，四档外框为 32/24/20/16，页面文案间距 10；12 处刷新 0～80px 线性映射一圈，触发后连续旋转；专项与独立测试 47 项、`flutter analyze` 通过，完整测试首个失败仍为 `widget_test.dart:661` 的既有 `????` 断言 |
| 2026-08-03 | Flutter 编码 / 下拉刷新图标跟手修正 | 保留系统刷新业务逻辑，让五点图标跟随下拉位移 | `RefreshIndicator.noSpinner` 继续负责阈值、触发和回调；五点图标在 0～80px 下拉期间同步移至最大 60px，松手后 150ms 回弹至 40px，取消/完成按 200ms 退出；不修改 12 处页面刷新回调；加载专项 10 项、其余独立测试合计 48 项与 `flutter analyze` 通过 |
| 2026-08-03 | Flutter 编码 / 个人页 Figma 对齐 | 以当前 `81:559「个人」` 调整页面并校准积分、订单入口 | 已完成 CHG-0044 增量：顶部头像/积分/设置、VIP 卡和八项菜单对齐；订单列表复用已有 1x/2x/3x 图标、订单页路由与登录门禁；三档适配、Design QA、定向测试与 `flutter analyze` 持续验收，不改变第15步默认部署/整 App QA 主线 |
| 2026-08-03 | Flutter 编码 / 任务中心签到状态 UI 对稿 | 以 Figma `73:294`、`73:407` 校准签到按钮完成态 | 保留连续签到静态文案和未签到青色渐变；完成态改为“签到成功”、`0x33FFFFFF` 实底与 `#666666` 加粗文字，保持按钮禁用及现有接口/积分流转；375×812 双状态截图对稿、320×568/430×932 适配和定向测试通过，不改变第15步默认部署/整 App QA 主线 |
| 2026-08-03 | Flutter 编码 / “我的音乐”列表自动刷新 | 生成中作品条件轮询并在任务创建后刷新 | 已完成 CHG-0045：作品页可见且有生成中作品时每分钟静默刷新，离页/退出登录/全部终态/销毁即停止；灵感、专业、情景、AI 改编及播放器/详情重新生成成功后立即刷新；自动失败保留列表，请求串行并单次补发；`flutter analyze`、13 项定向 Widget 测试和 `git diff --check` 通过，不改变第15步默认部署/整 App QA 主线 |
| 2026-08-03 | Flutter / Java 编码 / 专业写歌参考音频 | 将参考音频上限从 20MB 提升到 50MB | CHG-0046 编码完成待环境验收：App 配置缺省、选择/落盘/最终直传校验与后端默认配置、multipart 兜底、OSS 直传 prepare/complete 校验已统一为 52,428,800 字节；`flutter analyze`、3 项 Flutter 定向用例、Java 定向测试、两个仓库 `git diff --check` 和路径守卫 `audit` 通过；Flutter 全量仍受既有 `????` 占位断言与连锁超时影响（125 通过、195 失败），Java 全量 827 项中 825 通过、2 个显式外部集成测试因 PostgreSQL 不可达失败；测试服务器尚未部署 catsinger 路由且当前无管理凭证，未执行目标环境 PUT 与 20～50MB 实测 |
| 2026-08-03 | Flutter 编码 / 歌曲播放屏幕常亮 | 主歌曲播放期间阻止系统自动锁屏 | CHG-0047 编码完成待真机验收：新增 owner 式唤醒锁协调器，`MusicPlayService` 仅在 `playing` 状态持有，暂停/结束/失败/销毁释放；全局 Loading 与写歌弹层已迁移为独立 owner/Future 作用域，后台释放、恢复前台后重申；`flutter analyze`、5 项唤醒锁定向测试、Loading 专项 10 项和 `git diff --check` 通过；完整 `flutter test` 仍被既有 `????` 乱码期望、旧文案断言和页面溢出基线阻断；待 Android/iOS 短自动锁屏时间、电源键手动锁屏与暂停恢复验收，不改变第15步默认部署/整 App QA 主线 |
| 2026-08-03 | Flutter 编码 / 作品详情弹层 | 修复点击“查看详情”只显示黑色空弹层 | 已完成 CHG-0048：通过 V1981A（1080×2408@3x）Flutter attach 定位到 `SliverPersistentHeader` 的 `84.h` 变为小数后触发 `layoutExtent > paintExtent` 浮点几何断言；固定头部高度向下对齐整数逻辑像素，新增同分辨率 Widget 回归；定向用例和真机热重载验收通过，作品模块回归的 5 个既有 `????` 乱码/旧文案断言仍失败，`flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警；不改变第15步 QA 主线 |
| 2026-08-03 | Flutter 编码 / 专业写歌与歌曲改编 iOS 麦克风授权 | 统一两个“哼歌成曲”入口的权限处理 | CHG-0049 已完成：专业写歌与歌曲改编均通过 `Access.microphone(context)` 处理权限；iOS 启用 `PERMISSION_MICROPHONE=1`，首次未决定权限时请求系统授权，首次拒绝后本次安静结束、下次永久拒绝状态再引导设置，引导文案已补充 App 设置页和“设置 > 隐私与安全性 > 麦克风”备用路径；4 项 `Access` 权限测试、1 项歌曲改编入口级测试和 11 项媒体权限测试、iOS Simulator Debug 构建、CocoaPods 宏检查与 `git diff --check` 通过；iOS 26.4 Simulator 已实测首次允许后录音成功、首次拒绝不连续弹框、再次点击显示设置引导、权限重新开启后恢复录音；`flutter analyze` 仅有既有未使用方法告警，专业写歌旧页面用例仍被既有 `????` 占位文案阻断，不改变第15步 QA 主线 |
| 2026-08-03 | Flutter / Java 编码 / 歌曲重新生成 | 补齐积分确认、阻断加载、详情弹层导航并修正为原作品更新 | CHG-0050 已完成：详情弹层、独立详情页与播放器 Controller 复用统一流程，精确匹配原作品 provider/model 当前模型积分；缺失/停用/无效配置和积分不足均阻止提交，取消不请求；提交时显示阻断 Loading，成功关闭详情弹层并进入有效 taskId 进度页且只刷新一次；Java 任务直接绑定原 `workId`，不插入占位作品，提交后原作品立即关联新 task 并切为 `GENERATING/PENDING_REVIEW`，成功原地更新且切回 `SUCCEEDED`，失败恢复原任务关联与 `SUCCEEDED/APPROVED` 并保留旧音频；Flutter 与 Java 定向回归通过，V1981A 真机已验证 20 积分弹框与取消返回详情，未提交扣分；既有封面/播放器旧用例仍被 `????` 占位断言和 Controller 注册基线阻断，不改变第15步 QA 主线 |
| 2026-08-03 | Flutter 编码 / 热歌改编歌名 | 修复用户输入歌名仍被后端重新生成 | CHG-0051 已完成：热歌改编提交时把非空用户歌名标记为 `titleExplicit=true`，空输入的来源标题兜底保持 `false`；请求级 Widget 回归验证自定义歌名和显式标志均正确，`flutter analyze` 仅有既有 `custom_toast.dart` 未使用方法告警；无需修改后端，不改变第15步 QA 主线 |
| 2026-08-04 | Flutter / Android 编码 / MP4 音频转换 | 修复部分 Vivo 设备选择 MP4 后转换失败 | CHG-0052 已完成：定位为 V1981A Android 12 厂商 `MediaMuxer` 拒绝合法双字节 AAC CSD，原有 M4A 直封装和转码兜底均会失败；新增不经过 Muxer 的 ADTS AAC 无损兜底、原生完整异常日志，以及 Dart 对原生实际扩展名和 MIME 的透传；用户失败原 MP4 真机回归生成 432,539 字节、1,142 帧的 AAC-LC 44.1kHz 双声道文件；定向测试、Kotlin 编译、Debug APK 构建通过，`flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警；未触发生成任务或扣分，不改变第15步 QA 主线 |
| 2026-08-04 | Flutter 编码 / AI 歌词生成 | 将歌词辅助生成接口响应超时调整为 1 分钟 | CHG-0053 已完成：仅为 `/api/song-lyrics/assist` 设置 1 分钟 `receiveTimeout`，保留全局 30 秒连接超时和其他接口默认值；`test/http_service_test.dart` 2 项通过，`flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警，`git diff --check` 通过；不改变第15步 QA 主线 |
| 2026-08-04 | Flutter / Java 编码 / 翻唱重新生成 | 修复正式服翻唱作品重新生成缺少源音频参数 | CHG-0054 已完成：生产数据确认失败任务被错误创建为 `custom / ADVANCED_SONG / ORIGINAL`，源音频、音色和翻唱设置均为空，MiniMax 因缺少 `cover_feature_id` 或音频而拒绝；Java 现从原成功任务和作品恢复 `COVER_SONG`、源音频、音色、版权与高级设置并重新预处理特征，同一 `workId` 状态按提交/成功/失败流转；Flutter 消费 `currentStep` 映射真实失败步骤；定向回归通过，尚未执行正式服部署 |
| 2026-08-04 | Flutter 编码 / 封面海报生成 | 将封面海报生成接口响应超时调整为 1 分钟 | CHG-0055 已完成：仅为 `/api/song-works/{id}/regenerate-cover` 设置 1 分钟 `receiveTimeout`，并与歌词生成复用同一生成响应超时常量；`test/http_service_test.dart` 3 项通过，`flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警，`git diff --check` 通过；不改变第15步 QA 主线 |
| 2026-08-04 | Flutter / Java 编码 / 歌曲生成同款 | 持久化原始参数并将自动回填风格对齐当前前端配置 | CHG-0056 已完成：Java 保存作品级参数快照并做 Flyway 存量回填，快照存在时详情不再合并 Provider 结果风格；Flutter 等待配置后按 `code/label/value` 和固定别名映射，`Male/Female Vocal` 只恢复人声，多词标签不按空格拆分，未知项统一降级提示；不调用 AI，参考音频优先提交 `assetId`，旧 App/旧后端与普通入口兼容 |
| 2026-08-04 | Flutter 编码 / 作品详情封面缓存 | 保留缓存首帧并修正封面重新生成后的同步边界 | CHG-0057 已完成：恢复 `MusicPlayService.cachedDetail/currentDetail`、入口摘要和作品列表的同步首帧铺壳，但 Controller 每次创建仍请求完整详情；普通网络详情继续同步播放器，封面重新生成即时响应仅更新详情与作品 Store，清理作品稳定封面键并刷新列表；定向 Widget 与资源缓存回归通过，不修改后端或数据库 |
| 2026-08-04 | Flutter 编码 / 播放器封面入口 | 恢复紫色占位状态下的“生成海报”操作 | CHG-0058 已完成：同曲活动播放不再阻止后台详情刷新；封面 URL 非空但图片加载失败时，占位卡显示重新生成入口，已有封面先走积分确认并支持取消/权益错误处理；缺失封面、活动旧缓存、加载失败和配置歌曲 4 项回归通过，不修改后端或数据库 |
| 2026-08-04 | Flutter 编码 / 生成同款提示 | 移除不可用原参数的降级提示 | CHG-0059 已完成：专业模式回填同款参数时不再显示青色降级提示；已停用模型、未知风格和失效参考音频仍按原规则静默回退，不改生成请求及计费；3 项同款定向回归通过 |
| 2026-08-04 | Flutter 编码 / 歌词时间轴重生 | 将播放器同步请求改为异步任务轮询 | CHG-0060 已完成：新增时间轴任务模型与创建/查询 API，播放器每 3 秒轮询 `PENDING/RUNNING`，成功后刷新详情、播放缓存和作品列表；失败、超时、离页及估算时间轴分支均已处理；7 项定向 Widget/API 回归通过，`flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警，不改变第 15 步 QA 主线 |
| 2026-08-05 | Flutter / Java 编码 / 封面海报重生 | 将播放器与作品详情同步封面请求改为异步任务轮询 | CHG-0061 已完成：后端复用 `catsinger_song_cover_regeneration_tasks` 增加用户端创建、最近任务和指定任务查询接口，按作品活动任务幂等，调度执行复用原封面计费、扣减和退款规则；App 两个封面入口创建任务后每 3 秒轮询，成功再清缓存并刷新详情/Store/列表，失败显示任务原因，15 分钟超时或 Controller 销毁停止；无需数据库迁移，Flutter 8 项、Java 7 项定向回归通过 |
| 2026-08-05 | Flutter 编码 / 专业模式歌词润色防息屏 | AI 帮写和智能优化等待歌词接口时保持屏幕常亮 | CHG-0062 已完成：`SongMasterCreateController.assistLyrics()` 在输入校验通过后使用统一 `ScreenAwakeCoordinator.keepAwakeWhile()` 包裹歌词辅助请求；成功、接口失败均自动释放，空输入不启用，重复点击不产生第二个请求或额外 owner，后台/前台行为继续复用现有生命周期协调；新增挂起成功、失败、校验拦截回归，屏幕常亮相关 8 项及歌词请求参数回归通过，`flutter analyze` 无问题，Debug APK 构建通过；V1981A 将系统自动锁屏临时设为 15 秒，智能优化请求等待超过阈值仍保持亮屏，回填歌词后静置超过阈值正常息屏，验收后已恢复原 30 分钟设置；不改变第15步 QA 主线 |
| 2026-08-08 | Flutter 编码 / 首次隐私弹框 | 首次进入主页时主动展示用户协议与隐私政策 | CHG-0063 已完成：`MainPage` 在首帧后调用 `PrivacyConsentFlow.ensureAcceptedOnFirstHomeEntry()`，仅对未同意且未明确拒绝的首次用户弹出现有协议弹框；已同意不重复弹，已拒绝可继续有限浏览且在访问受保护能力时再询问；启动更新检查延后到隐私同意之后，不提前初始化支付、一键登录、更新和资源缓存等受保护能力；隐私流程 6 项、弹框交互 1 项、`flutter analyze` 与 `git diff --check` 通过，不改变第15步 QA 主线 |
| 2026-09-05 | 联调与测试 QA / 当前代码全量用户用例 | 按 App 1.2.0+121 和三端当前代码重建移动端用例与 ADB 执行框架 | CHG-0069 已生成 338 条模块化 Android/iOS 用户用例、覆盖矩阵和动态 catalog；23 项框架自检、compileall、路径审计通过；Android smoke 10/10 PASS，最终 core 12 PASS/0 FAIL/1 BLOCKED 且 13 条均有截图和 UI XML；测试服务器 catsinger 路由与生成中作品数据仍阻塞完整 QA，未修改三端业务代码 |
