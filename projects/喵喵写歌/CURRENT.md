# 喵喵写歌当前主文档入口

## 共享后端增量引用（2026-08-28）

邀请与银行卡提现统一改造适用于所有 App，执行记录统一见[共享邀请提现计划](../喵喵带货/04-后端/开发计划/07-invite-unified-manual-payout.md)。文档承载位置不代表 Catseller 专属实现。资金、规则、认证授权按 App 隔离；敏感底层资料与工猫配置共享；人工是同一提现流程的补充。本轮只改 Java/Admin，不改本 App 页面，不混入旧支付宝客户端银行卡接入；不改变本项目其他任务状态。

共享增量 M1～M4 已本地实现并进入 `waiting_review`；相关 181 项后端测试、172 项 Admin 测试通过，后端全量有一项视频内容审核测试失败。正式 SQL 与数据未改，实际结构/存量迁移及渠道验收未执行；本项目其他事项仍按下方原状态推进。

> 本文件用于避免版本迭代时误读旧需求、旧技术文档或旧开发计划。
> 当前执行入口一律指向工作区主路径；历史资料统一在 `archive/` 中，只作追溯和差异对照。
> 当前产品需求主线为 CHG-0076 / `v2.1-model-driven-params`，包含首页增量、当前 Figma 产品文档、本地最终资源上传前查重和 CHG-0085 范围调整：P03/P04 的「使用指定音色」延至下版，本期不显示入口、不跳 P07；P05 翻唱音色保留。需求三件套仍 `waiting_review`。CHG-0084 的 V2.1 全量用户用例独立编制；双端安全抽查已发现 P1 缺陷，完整用例尚未验收，V1.2 QA 结果不得继承。真实算道训练、积分与新生成可播放成品仍待目标环境验收。
> CHG-0077 已将旧版资料移入 `archive/CHG-0077-legacy-docs-20260913/`。当前版两端 00 索引含原 CHG-0076 01～08 和 CHG-0078 前端 09～13/后端 09～12；旧 CHG-0073 计划、代码状态和骨架确认不得作为新版本验收或真实实现授权。

| 字段 | 当前值 |
|------|--------|
| `currentProject` | `喵喵写歌` |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/喵喵写歌` |
| `currentVersion` | `v2.1` |
| `activeDocVersion` | `v2.1-model-driven-params` |
| `iterationMode` | `version_iteration` |
| `implementationMode` | `direct_implementation`（本版用户明确授权的例外） |
| `implementationPhase` | `real_review` |
| `skeletonTargets` | `none`（既有骨架保留但非当前门禁） |
| `skeletonRuntime` | `none`（既有 Fixture 仅 local/test 可启用） |
| `baseDocVersion` | `v2.1-ai-cover-voice-clone`（旧需求；三端代码/QA 基线单独保留） |
| `baseArchiveVersion` | `archive/legacy-20260610/` |
| `archiveIndex` | `archive/` |
| `currentRequirementEntry` | `01-需求/requirements.md` |
| `currentRequirementReviewEntry` | `01-需求/requirements-review.md` |
| `currentRequirementDetectionEntry` | `01-需求/detection-feedback.md`（CHG-0080/CHG-0081 `NOT_RUN`；旧 CHG-0078/0076 PASS 不可复用） |
| `currentAdminRequirementEntry` | `01-需求/requirements.md`（P14/W01～W09） |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md`（CHG-0078 第 9 节 `done`） |
| `currentEffortEstimateEntry` | `02-技术方案/effort-estimate.md`（CHG-0078 增量 `done`） |
| `currentFlutterTechEntry` | `03-前端/flutter-tech.md`（原版及 CHG-0078 增量均 `done`） |
| `currentJavaTechEntry` | `04-后端/java-tech.md`（原版及 CHG-0078 增量均 `done`） |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md`（本地真实实现完成，双端真实成品待验） |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md`（本地真实实现和全量回归完成，目标环境待验） |
| `currentFrontendModulePlanEntry` | `03-前端/开发计划/00-module-index.md`（当前 `-R` 进入 `real_review`） |
| `currentBackendModulePlanEntry` | `04-后端/开发计划/00-module-index.md`（当前 `-R` 进入 `real_review`） |

## 当前可执行文档

| 文档域 | 当前入口 | 状态 |
|--------|----------|------|
| V2.1 需求清单 | `01-需求/requirements-list.md` | CHG-0080/0081/0085 当前 Figma、P03/P04 指定音色延期及上传查重，`waiting_review` |
| V2.1 完整 PRD（含 Web/Admin P14） | `01-需求/requirements.md` | P03/P04 不进入 P07；P05 翻唱目标音色和本地资源查重保留，`waiting_review` |
| V2.1 Product Review | `01-需求/requirements-review.md` | 与 PRD 同步的延期范围，`waiting_review` |
| V2.1 需求检测报告 | `01-需求/detection-feedback.md` | CHG-0080/CHG-0081 `NOT_RUN`；旧 PASS 只作历史记录 |
| V2.1 当前技术方案 | `02-技术方案/tech-plan.md` | 主路径为完整当前版；原模型参数方案保留、CHG-0078 第 9 节 `done` |
| V2.1 当前工时评估 | `02-技术方案/effort-estimate.md` | CHG-0078 增量 6 个有效工作日、`done`；原 CHG-0076 排期单独留作参考 |
| V2.1 当前 Flutter/Web 技术文档 | `03-前端/flutter-tech.md` | 原 CHG-0076 `done`，CHG-0078 首页/Admin 第 8 节 `done` |
| V2.1 当前 Java 技术文档 | `04-后端/java-tech.md` | 原 CHG-0076 `done`，CHG-0078 配置/赠额/弹窗第 9 节 `done` |
| V2.1 当前 Flutter/Web 总体计划 | `03-前端/flutter-dev-plan.md` | 本地真实实现完成，Android/iOS UI 已阶段验收，厂家成品待验 |
| V2.1 当前 Java 总体计划 | `04-后端/java-dev-plan.md` | 本地真实实现完成，1956 项全量测试通过，目标环境待部署 |
| V2.1 Flutter/Web 模块文档 | `03-前端/开发计划/00-module-index.md` + 原 01～08、新 09～13 | 第 13 步 `waiting_review`；真实成品验收未过 |
| V2.1 Java 模块文档 | `04-后端/开发计划/00-module-index.md` + 原 01～08、新 09～12 | 第 14 步 `waiting_review`；真实厂家闭环未过 |
| V2.1 当前 Figma 设计稿 | 当前通道 `bbxou598`；翻唱声音克隆使用 `157:*`，34 张需求快照见 `01-需求/references/images/v2.1/figma-bbxou598/` | `active-design`；本轮作为 CHG-0080 产品文档真源 |
| V2.1 旧需求快照 | `archive/CHG-0076-pre-rewrite/`、`archive/CHG-0077-legacy-docs-20260913/01-需求/` | `reference-only` |
| V2.1 原始产品资料 | `01-需求/references/docs/v2.1/喵喵写歌-AI翻唱产品需求与技术方案-V2.1.docx` | `reference-only` |
| 当前代码基线 | `05-联调与测试/mobile-code-test-baseline-v1.2.0+121.md` | `base-reference` |
| 当前 V2.1 整 App 用户用例 | `05-联调与测试/cases/v2.1-model-driven-params/` | CHG-0084 文档已编制；双端抽查见 `05-联调与测试/v2.1-dual-smoke-20260919.md`，完整用例待执行 |
| 旧 V1.2 整 App 用例与结果 | `05-联调与测试/cases/v1.2.0+121-as-built/` | 并行历史基线，不作为 V2.1 PASS |
| V2.1 旧技术/计划与 AI 改编参考 | `archive/CHG-0077-legacy-docs-20260913/` | `reference-only`；原相对目录结构保留，不能用作当前编码入口 |
| V2.1 前端模块计划入口 | `03-前端/README.md` | `done`；第 13 步真实实现进行中 |
| V2.1 后端模块计划入口 | `04-后端/README.md` | `done`；第 14 步真实实现进行中 |
| Android/iOS 自动化 | `/Users/soul/code/lxwx/test/catsinger` | `in_progress`（并行） |

## 当前实现状态

> **以下 CHG-0073 实现清单是改版前代码与验证的历史状态，不是 CHG-0076 新需求的实现证明。** 当前只读 Java 对账发现 `/api/ai-model-options` 的 `musicContract` 仅填充写歌和改编场景，`generation-options` 仍是 App 级选项；翻唱声音克隆/训练缺等价逐参数契约。新 Flutter 置灰、切模型参数清理、Java 提交校验和 Admin 能力边界均待技术/代码对账。本轮没有改三端代码或配置。

- CHG-0073 / V2.1 翻唱声音克隆的需求、技术文档、总体计划和模块文档均已通过；用户已明确授权真实实现。Flutter T-F001-R 至 T-F010-R、Java T-B001-R 至 T-B013-R 已完成本地编码，当前统一进入 `real_review`。
- Web/Admin 的 `T-Wxxx-S/T-Wxxx-R` 保持 `deferred`。Java T-B014-R 以及 Flutter 的目标环境完整业务验收等待部署后执行，不能用本地 Mock、接口 200 或任务状态字段代替真实可播放作品。
- 两端已移除骨架固定响应和 `TODO(REAL-IMPLEMENTATION)`；生产代码接入真实数据库、积分、审核、上传、Provider、轮询、资源持久化和作品链路。目标环境尚未部署新迁移与配置，因此当前不是生产交付完成状态。
- P12 翻唱播放直接复用当前 Flutter 工程 `SongPlayerPage`，不新增翻唱声音克隆结果页、不重做播放器 UI，旧截图不作为本版本验收基线。
- 生成歌曲、AI 改编、翻唱声音克隆是三个独立业务，但共用当前歌曲业务流程和模型路由、审核、积分、资源、作品、播放器及 Web/Admin 管理体系。生成歌曲与 AI 改编完全保持当前名称、入口、页面、接口、配置、任务、数据和交互；V2.1 只新增本人克隆音色/后台官方音色的翻唱声音克隆模式及其专属步骤。
- 三项业务的公开创建接口固定分开：AI 写歌使用 `/api/song-generations`，AI 改编使用 `/api/song-covers`，翻唱声音克隆使用 `/api/song-voice-covers`。翻唱声音克隆请求不传 `mode`，由服务端固定内部 `VOICE_COVER`，并提交模型列表返回的真实 `provider/model`；任务创建后冻结实际厂家路由快照，后台模型切换只影响新任务。
- Java 已新增与现有 `app/catsinger/cover/` 同级的 `app/catsinger/voicecover/` 业务目录。`cover/` 只保留 AI 改编的运营预设音色和旧接口；`voicecover/` 承载本人/官方克隆音色、训练、渠道绑定、专属校验和步骤实现，并继续委托同一套生成任务、工作流、模型、审核、积分、资源和作品能力。
- V2.1 已确认歌曲最长 10 分钟、平台控制并发、平台排队不计入生成超时、厂商确认接单并返回可查询任务标识后开始 10 分钟总处理时限、无取消、主动轮询、多渠道/商家模型切换、音色渠道绑定、默认训练/翻唱 100/200 积分和低置信度告警放行规则。厂商侧排队、生成、平台持久化、审核和可播放校验均计入这 10 分钟。
- V2.1 已确认翻唱声音克隆范围内所有图片、音频和可展示文字上传均需安全审核：上传继续写入现有资源台账，资源技术状态与内容审核状态分离，不新增隔离资源状态机或通用内容版本。审核通过前不得公开展示、加入训练、创建翻唱任务、冻结积分、调用 Provider 或发布；上传者可按现有 OWNER 权限试听自有音频，页面可读取模型参考价格。站内 `sourceAudioAssetId`、`sourceWorkId`、`referenceAudioAssetId` 满足上传审核或已有作品审核事实后，任务内与 AI 改编一致跳过重复源审核；外部 URL 继续走现有任务内送审。厂家成品仍须通过平台审核并真实可播放才算成功。
- 2026-09-08 已完成当前 Java 代码对账：W01～W12 仅作为产品管理任务分组，技术上映射现有 App 切换、AI 模型、场景路由、模型选项、计费、AI 运维、歌曲作品、资源、角色和审计模块；只补声音资料与训练所必需的数据和页面，不建设平行翻唱声音克隆后台。
- 正式产品展示名统一为「翻唱声音克隆」；原始 DOCX/Figma 中的旧名称只作溯源，内部 `VOICE_COVER`、场景编码、页面路由和版本目录保持不变。公开接口固定为 `/api/song-voice-covers`，厂家模型由独立 `provider/model` 字段表达，内部仍接入共享歌曲生命周期。
- CHG-0073 旧全量工时曾按 7 个 AI 工作日管理，其本地编码与剩余部署/测试状态仅为历史快照；CHG-0076 当前增量排期以 `v2.1-model-driven-params/effort-estimate.md` 的 6.5 个工作日为准，不混算旧版剩余工作。
- CHG-0014 已完成：当前需求、UI 截图和测试基线已按实际安装包 `1.1.0 (110)` 重新校准。
- 当前 App 主导航为“首页 / 作品 / 我的”三 Tab；旧四 Tab 和五槽导航文档不再作为测试预期。
- 当前 V2.1 第 15 步用户用例入口为 `05-联调与测试/cases/v2.1-model-driven-params/`；Python 测试工程默认目录暂未切换，正式执行需显式配置新目录并记录实际设备/构建。V1.2 结果不混入新报告。
- 2026-07-31 已将错误工作区别名 `catsinger` 的 CHG-0015～CHG-0040、独有开发计划、QA 与构建记录迁入正确工作区；这些内容是并行实现轨迹，不覆盖本文件指定的 v1.1.0-as-built 主入口。
- 重名需求和技术文档的恢复版本位于各业务目录的 `recovered-engineering-track-20260731/`，必须结合当前主文档做差异对照，不得单独作为编码依据。
- 旧 `05-联调与测试/cases/00-10` 共 223 条用例只作历史参考。
- CHG-0013 / v1.1 对应现有 AI 改编业务，已按模块开发文档完成三端编码对账、缺口补齐和命令验证，当前状态为 `waiting_review`；其历史目录名 `v1.1-ai-cover` 保留，CHG-0073 不修改该业务。
- 2026-06-25 已补齐现有 AI 改编每个页面的页面入口和页面内按键交互。
- 2026-06-25 已生成现有 AI 改编对应技术文档：`02-技术方案/v1.1-ai-cover/tech-plan.md`、`03-前端/v1.1-ai-cover/flutter-tech.md`、`04-后端/v1.1-ai-cover/java-tech.md`。
- 2026-06-25 已生成现有 AI 改编对应模块开发文档：`03-前端/v1.1-ai-cover/开发计划/00-09` 共 10 份，`04-后端/v1.1-ai-cover/开发计划/00-08` 共 9 份。
- 2026-06-25 已新增代码对账清单：`05-联调与测试/v1.1-ai-cover-code-audit.md`。
- V2.1 当前验证：Flutter `flutter analyze`、V2.1 定向 22/22、Android Debug APK 和 iOS Simulator Debug 构建通过；Java `./gradlew test` 全量 1956 项通过；Web/Admin `flutter analyze`、234/234 和 Web 构建通过。Flutter 全量仍有 141 个历史损坏文案断言失败，单独作为测试债务。
- Android 真机与 iOS 375x812 模拟器已验证翻唱声音克隆页面、登录门禁、音色库/创建音色和系统文件选择；Android 已有 AI 改编作品播放位置由 00:02 增至 00:46。翻唱声音克隆没有生成成品，仍为 NOT_RUN，不得借旧改编播放结果标 PASS。
- 第15步整 App QA 作为并行事项保留；当前主线下一步是用户确认 CHG-0080/CHG-0081 产品文档并执行需求检测，检测通过后再决定是否回卷技术、音色库跳转、资源查重与三端代码。
- CHG-0069 已将独立 PyCharm 测试工程 `/Users/soul/code/lxwx/test/catsinger` 升级为模块化目录，当前有效 catalog 为 329 条；CHG-0071 已接入 iOS Appium/XCUITest，优先真机、无真机时使用模拟器、均不可用则测试 FAIL。
- 2026-09-07 iOS 真机 smoke 10/10 PASS，默认 Android+iOS smoke 20/20 PASS；iOS full 的 314 条适用用例为 10 PASS、304 NOT_RUN，总体 `INCOMPLETE`。这只关闭双平台安全冒烟，不代表 iOS StoreKit、系统权限和全部手工用例已通过。
- 当前测试服务器 `http://120.25.199.191:8080` 基础健康为 UP，但尚不支持 `X-App-Code: catsinger`；Android smoke 10/10 PASS，core 12 PASS/0 FAIL/1 BLOCKED，写歌/翻唱闭环需待测试实例部署当前后端并准备测试数据。
- QA 未通过前不进入打包或上架；CHG-0011 与 CHG-0013 继续保持待验收，不因用例文档完成而提前关闭。
- CHG-0011 / v0.1.0 前端 UI 返工仍保留为历史进行中事项，待单独截图验收，不作为 v1.1 编码入口。

## 隔离规则

- V2.1 当前新需求只读取 `01-需求/v2.1-model-driven-params/` 与根路径同步镜像；旧需求、技术方案和前后端计划均在 `archive/CHG-0077-legacy-docs-20260913/`，只作 `reference-only`。现有 AI 改编历史数据不得因名称相似而迁到声音克隆翻唱。
- CHG-0073 的技术方案、Flutter/Java 技术文档、总体/模块计划均已归档，不得沿用其旧 `done` 作为 CHG-0076 验收或部署依据。当前 Figma 是 UI 真源，第 4 步不重复出稿；第 11/12 步本版模块计划已完成。用户已明确授权本版跳过骨架评审并执行真实实现；既有线上 Bug 修复和并行 QA 不受影响。
- `skeleton_review` 的一般门禁仍适用于其他版本；本版经用户明确授权采用 `direct_implementation / real_coding`，普通“继续”不能被误解为其他版本的授权。
- 旧 AI 改编 `v1.1-ai-cover/` 技术与开发文档已在 `archive/CHG-0077-legacy-docs-20260913/` 保留，只能用于差异分析，不能作为 V2.1 声音克隆翻唱的编码计划。
- 只有在 V2.1 Product Review、需求检测、两份技术文档、总体开发计划和同版本模块开发文档全部通过后，才能进入 Flutter、Java 或 Web/Admin 编码。
- `v1.2.0+121-as-built` QA 是历史版本并行任务；其 PASS、FAIL、BLOCKED、NOT_RUN 结果不得被 V2.1 文档生成状态覆盖。V2.1 独立用户用例尚未设备执行。
- 旧 Sonus 参考图统一归为 `archive/legacy-20260610/`，只能 `reference-only`。
- 旧 Flutter App 模块计划统一归为 `archive/legacy-20260611-pre-rework/`，只能 `reference-only`。
- 旧 `versions/` 兼容索引统一归为 `archive/reference-indexes/v1.0-design-mvp/`，不作为当前执行入口。
- V2.1 QA 读取当前主路径需求与 `cases/v2.1-model-driven-params/`，执行时重取实际代码/安装包基线；V1.2 并行 QA 仍只读取自己的旧目录，两个版本不可混跑。`v1.1.0-as-built` 及更早内容只作 `reference-only`。
- 后续进入 Flutter / Java / Web(Admin) 编码时，以 `v1.2.0+121-as-built` 差异为输入建立 V2.1 新版本计划，不直接沿用旧开发计划。
- 若后续新增接口或字段，必须先同步主路径文档，再进入对应编码阶段。

## 归档索引

| 归档目录 | 内容 | 状态 |
|----------|------|------|
| `archive/legacy-20260610/` | 旧 Sonus 参考图和早期历史说明 | `reference-only` |
| `archive/legacy-20260611-pre-rework/` | CHG-0011 返工前的 Flutter App 旧模块计划 | `reference-only` |
| `archive/reference-indexes/v1.0-design-mvp/` | 旧 `versions/` 兼容索引 README | `reference-only` |
| `archive/path-recovery-20260731/` | 原 catsinger 错误工作区原样快照、SHA-256 与编号映射 | `reference-only` |
| `archive/CHG-0076-pre-rewrite/` | 新飞书/Figma 需求回卷前 V2.1 清单、PRD、Review 和旧根路径快照 | `reference-only` |
| `archive/CHG-0077-legacy-docs-20260913/` | 01～04 阶段旧版需求、技术方案、前后端技术/总体/模块计划及旧截图索引，原目录结构保留 | `reference-only` |
| `archive/CHG-0081-pre-voice-library-resource-dedup-20260915/` | 指定音色入口与本地上传查重补充前的当前需求四件套 | `reference-only` |
