# 喵喵写歌工作流程

> 2026-09-20 第 15 步 QA：[双端测试环境功能执行记录](05-联调与测试/v2.1-dual-functional-20260920.md)。当前源码 Android 真机/iOS 模拟器各 8 PASS / 1 FAIL 只读检查；三条真实生成任务中，原创与专业写歌双端可播放且积分流水一致，AI 改编因韩文演唱 FAIL（DEF-V21-002）。首页假案例另记 DEF-V21-003，整曲来源旧文案 DEF-V21-001 仍在；翻唱声音克隆无测试音色 BLOCKED。随后测试环境 `/api/*` 返回 nginx 502，已停止继续写入数据的用例；恢复点为真实 API 返回业务 JSON 后继续。182 条 V2.1 用例未逐条完成，QA 不验收通过；本轮未改三端业务代码，不改变 CHG-0080/0081/0085 的需求评审状态。

> 2026-09-20 CHG-0087 双端重装测试：[记录](05-联调与测试/v2.1-new-user-gift-reinstall-20260920.md)。8080 新进程健康，已在本地准备无图新人礼配置，Admin 创建两名新账号并核对各 30 积分/1 条建号流水；Android 登录协议、iOS 首次协议待用户自行确认，弹窗/跳转 `BLOCKED/NOT_RUN`。运行中的 Admin 旧 UI 仍误拦截无图保存，须重启后单独回归。

> 2026-09-20 CHG-0087：新人礼弹窗为提示与导航，不负责发积分；本地已完成默认内置图、后台图片可选且自定义图继续审核的局部修复。Java 定向 10/10、Admin 面板 3/3、App 模型 3/3，App/Admin 静态分析均通过；部署与设备展示待验。注册赠额仍由建号链路发放，CHG-0080/0081/0085 的需求评审恢复点不变。

> 2026-09-20 第 15 步 QA：[V2.1 双端只读自动化复测](05-联调与测试/v2.1-auto-smoke-20260920.md)在 Android 真机与 iOS 375×812 模拟器分别执行 9 个检查点，合计 16 PASS / 2 FAIL；DEF-V21-001 整曲来源弹层旧文案双端复现。独立脚本不替代全量 180 条用例，也未执行生成/支付/删除。测试用户待真实 DEV 管理员登录后创建，DEMO 假用户不用于登录；CHG-0080/0081/0085 需求评审恢复点不变。

> 2026-09-19 CHG-0086：P03 音频参考与 P04 歌曲改编统一上传入口改为「我的创作 / 相册上传 / 本地上传」。素材选择后按 10 秒至 10 分钟及当前模型更短上限校验，超限报错要求重选，不自动截取或清除原素材；生成结果时长不变。本次为并行移动端交互修复，不改变 CHG-0080/0081/0085 需求评审恢复点。

> 2026-09-19 CHG-0085：用户将专业写歌/歌曲改编的「使用指定音色」延至下个版本。V2.1 两页不显示入口、不进 P07、不提交指定音色；P05 翻唱声音克隆本人/官方音色不变，CHG-0081 上传前查重不变。需求清单、PRD、Review 已回卷，仍 `waiting_review`；本轮不动三端业务代码。

> 2026-09-19 CHG-0084：第 15 步新增 [V2.1 独立全量移动端用户用例](05-联调与测试/cases/v2.1-model-driven-params/README.md)，与 V1.2 并行结果严格隔离。现已做 [Android 真机 + iOS 模拟器安全冒烟抽查](05-联调与测试/v2.1-dual-smoke-20260919.md)：部分页面检查通过，整曲翻唱来源弹层双端 FAIL（DEF-V21-001）；完整用例、算道生成、支付及新作品播放仍未验收。

> 2026-09-19 CHG-0083：按用户最新口径，旧「AI 翻唱」对应歌曲改编，当前「AI 翻唱」对应翻唱声音克隆；两个生成页均取消权利勾选与提交门槛。Flutter 仍分别请求 `/api/song-covers` 与 `/api/song-voice-covers`，原授权字段固定传 `true` 兼容稳定后端，旧客户端及后端不变；音色训练本人声明不变。当前页面没有显式勾选，服务端记录的 `true` 不能单独证明发生过勾选。静态分析、相关定向测试和 P05 页面截图用例通过；真实厂商生成未在本轮执行。CHG-0080/0081 的需求评审恢复点不变。

> 2026-09-17 AI 写歌默认模型校正误提示已收口：默认选模和程序化同步继续按模型契约清除无效参数，但不再弹无上下文提示；隐藏专业模式的“生成时长”校正不会干扰当前简易模式。只有用户在当前可见模式主动换模且确有设置被清除时，才提示具体字段。新增两条 Widget 回归、模型契约 8 项测试及静态分析通过；现有 `song create` 名称组另有 6 条既有 `????` 文案断言/空模型夹具失败，不计为本修复通过。无后端、数据库、SQL、价格或模型配置改动。

> 2026-09-17 AI 翻唱已选文件名显示修复：本地音频卡片只展示去扩展名后的前 8 个 Unicode 字符，超出追加 `…`，空名称回退“本地音频”；完整原名仍用于服务端查重、上传和 `originalFilename`。选择文件仍仅本地暂存，点击“开始生成”后才上传。相关测试 `34/34`、P05 截图矩阵、375×812 长名称截图、静态分析及差异检查通过；无后端、数据库或 SQL 改动。

> 2026-09-17 通用 `LoadingDialog` 收口：错误的两行“上传中 / 请勿退出”及支付专属包装已删除，原 `app_blocking_status_dialog.dart` 重命名为 `loading_dialog.dart`，阻塞加载统一使用 `LoadingDialog.show()`。素材上传/任务创建、头像昵称审核、最终朗读及支付只显示一个青色动画和一行文案，底层按钮不再叠加转圈；规则文件已加入唯一组件门禁。相关定向回归 `46/46`、资料页和支付截图用例各 `1/1`、静态分析及 iOS 375×812 模拟器 Debug 构建/安装/启动通过。无后端、数据库或 SQL 改动，未发起真实支付、审核或训练任务。

> 2026-09-17 头像/昵称资料页提交时序纠偏：选择头像和编辑/失焦昵称现在只更新本地预览，不上传、不创建审核任务；仅点击“继续”后才上传头像、分别送审并保存音色资料。训练请求继续只携可信 `voiceProfileId`，后端以既有 `voiceProfileVersionId` 锁定本次训练对应的头像/昵称，供音色列表卡片展示。相关音色回归 49 项及 `flutter analyze` 通过，当前源码 iOS 375×812 模拟器 Debug 构建、安装和启动通过；无后端接口、数据库或 SQL 改动，真实审核仍待测试环境联调。

> 2026-09-17 音色素材录音页纠偏：`立即录音` 已改为先进入 Figma `148:*` 独立五状态页面，页内开始、暂停继续、本地试听确认后才上传；离开提醒恢复 `157:3513` 文案与按钮语义。扩展后的 56 项相关回归和 375×812 逐态对稿通过；iOS 26.4 的 375×812 模拟器已完成当前源码构建、安装及版权/资料/离开提醒实际导航。无后端、数据库或 SQL 改动，真机真实麦克风/试听/上传待最终验收。详见 F004 开发计划及 App `design-qa.md`。

> 2026-09-16 统一模型选择弹框：音色卡片与 AI 翻唱已共用深色底部模型弹框，各走原模型接口；单模型可打开、确认才应用、忙碌禁切换，翻唱立即清除不兼容音色。相关 60 项测试通过，最终共享组件 11 项复测及静态分析通过；375×812 对稿和 Android 翻唱真实单模型弹框已验证，创建完整真机流程待验收。无后端、SQL、数据库改动，不变更其他评审状态；详见 F004 开发计划本轮记录。

> 2026-09-16 头像状态补修：已核对用户 Figma 通道 `1y5zlrns` 的 `157:3569/3613/3665`；上传/审核复用旋转五点动画，上传成功保留本地预览，失败及审核拒绝显示持续提示，审核查询失败可重试，移除头像拒绝引起的昵称错误。相关 37 项测试通过；不更改服务端接口和其他评审状态。

> 2026-09-16 音色定制侧滑退出补修：保留禁止直接 pop，增加两侧边缘向内滑动的确认入口，与系统返回共用确认逻辑；不影响中部横滑、纵向滚动及短拖动。新增 3 项 Cupertino 路由手势测试，连同既有音色回归共 24 项通过。其他评审状态不变。

> 2026-09-15 本轮用户明确批准的音色卡片修复已实现，独立于 CHG-0080/0081 文档评审：App + Java 最新训练状态、草稿过滤、选择/试听/删除、失败重训、退出确认丢弃。Flutter 定向 21 项、后端 12 项与静态分析通过；Android 真机确认 6 张旧临时卡不再展示及退出提示，375×812 六状态布局已检查。数据库无结构/迁移变更、无批量删除。后端实例尚未重启，真实厂家训练与音频验收仍待完成；恢复点为 [F004 修复交付](03-前端/开发计划/04-voice-train-and-clone.md)，不改变其他任务的阶段与评审状态。

> 当前有效版本：`v2.1-model-driven-params` / CHG-0076 + CHG-0078 + CHG-0079 + CHG-0080 + CHG-0081。本文只保存当前状态与下一恢复点；截至 2026-09-13 的完整历史见[归档快照](archive/workflow-history-through-20260913.md)，旧版需求与开发计划见[CHG-0077 归档](archive/CHG-0077-legacy-docs-20260913/README.md)。历史记录均为 `reference-only`，不能作为本版本编码依据。

## 1. 项目配置

| 字段 | 当前值 |
|------|--------|
| `currentProject` | `喵喵写歌` |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/喵喵写歌` |
| `currentVersion` | `v2.1` |
| `activeDocVersion` | `v2.1-model-driven-params` |
| `iterationMode` | `version_iteration` |
| `baseDocVersion` | `v2.1-ai-cover-voice-clone`（历史对照，非执行版本） |
| `baseArchiveVersion` | `archive/legacy-20260610/` |
| `archiveIndex` | `archive/` |
| `implementationMode` | `direct_implementation`（用户明确授权本版跳过骨架评审） |
| `implementationPhase` | `real_review`（既有实现状态保留；CHG-0080 需求复检前不得据此继续扩码） |
| `skeletonTargets` | `none`（已写骨架保留，未完成项不记为 done） |
| `skeletonRuntime` | `none`（既有 local/test Fixture 仍保持生产禁用） |
| `currentRequirementEntry` | `01-需求/requirements.md` |
| `currentRequirementReviewEntry` | `01-需求/requirements-review.md` |
| `currentRequirementDetectionEntry` | `01-需求/detection-feedback.md` |
| `currentAdminRequirementEntry` | `01-需求/requirements.md`（P14/W01～W09） |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md`（CHG-0078 增量 `done`，旧模型方案保留） |
| `currentEffortEstimateEntry` | `02-技术方案/effort-estimate.md`（CHG-0078 增量 `done`） |
| `currentFlutterTechEntry` | `03-前端/flutter-tech.md` |
| `currentJavaTechEntry` | `04-后端/java-tech.md` |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md`（本地实现完成，真实环境验收待补） |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md`（本地实现与全量回归完成，真实环境验收待补） |
| `currentFrontendModulePlanEntry` | `03-前端/开发计划/00-module-index.md`（按当前模块索引执行） |
| `currentBackendModulePlanEntry` | `04-后端/开发计划/00-module-index.md`（按当前模块索引执行） |
| `currentQaEntry` | `05-联调与测试/cases/v2.1-model-driven-params/README.md`；实测见 `05-联调与测试/v2.1-dual-smoke-20260919.md`（抽查 FAIL，完整用例待执行） |
| `referenceProject` | `/Users/soul/code/lxwx/catsinger` |
| `frontendRepo` | `/Users/soul/code/lxwx/catsinger` |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| `adminRepo` | `/Users/soul/code/lxwx/lxwx_admin` |
| `androidTestRepo` | `/Users/soul/code/lxwx/test/catsinger` |
| `iosTestRepo` | `/Users/soul/code/lxwx/test/catsinger` |

## 2. 当前流程

| 项目 | 当前内容 |
|------|----------|
| 当前阶段 | 第 2 步 CHG-0080/CHG-0081 产品文档评审；既有第 13～16 步状态作为实现基线保留 |
| 状态 | `waiting_review`；需求清单、PRD、Product Review 已按 CHG-0085 延期 P03/P04 指定音色，保留上传前查重，尚未执行本次第 3 步检测 |
| 恢复点 | 用户确认 CHG-0080/CHG-0081/CHG-0085 当前产品文档；V2.1 QA 用例已编制但未执行，旧 PASS 不替代本次确认 |
| 下一步 | 用户确认后合并执行第 3 步需求检测，再做技术方案、模块计划和三端代码的增量影响审计 |
| 编码门禁 | 本版 `direct_implementation` 为用户明确授权的例外；线上 Bug 修复并行，本轮不覆盖既有未提交修改。高风险数据库、积分、审核和 Provider 改动逐项验证 |

## 3. 总体流程列表

> 状态描述 **CHG-0076 当前版本及 CHG-0080/CHG-0081 需求回卷**。旧 CHG-0073 的本地编码状态、旧需求 PASS 和并行整 App QA 不并入本表。

| 步骤 | 产物 / 动作 | 状态 |
|------|-------------|------|
| 0 变更登记 | CHG-0080/CHG-0081 登记，两个改写前需求快照归档 | `done` |
| 1 需求分析 | 当前 Figma、本地上传查重及 P03/P04 指定音色延期回卷到需求清单 | `waiting_review`（CHG-0080/0081/0085） |
| 2 需求文档 | PRD 与 Product Review 按当前稿及延期边界更新 | `waiting_review`（CHG-0080/0081/0085） |
| 3 需求检测 | CHG-0080/0081/0085 尚未检测；CHG-0078 PASS 仅作历史记录 | `pending` |
| 4 Figma 设计计划 | 当前通道 `bbxou598`；`157:*` 为翻唱声音克隆最新视觉真源，不重复出稿 | `skipped` |
| 5 技术方案 | 原模型参数方案保留；首页/新人权益增量已对账并写入第 9 节 | `done`（CHG-0078 局部） |
| 6 工时评估 | 首页、新人权益、三端骨架、双端测试与修复另估 6 个有效工作日 | `done`（CHG-0078 局部） |
| 7 Flutter/Web 技术文档 | 原文保留；第 8 节补首页/新人礼与 W08/W09 双阶段契约 | `done`（CHG-0078 局部） |
| 8 Java 技术文档 | 原文保留；第 9 节补配置/建号/弹窗事务与并发契约 | `done`（CHG-0078 局部） |
| 9 Flutter/Web 总体计划 | 原计划保留；第 9 节补 F006/007、W003/004 双阶段增量 | `done`（CHG-0078 局部） |
| 10 Java 总体计划 | 原计划保留；第 9 节补 B007～009 与接口/数据依赖 | `done`（CHG-0078 局部） |
| 11 Flutter/Web 模块文档 | 原 01～08 不改；新增 09～13 已建并获继续授权 | `done`（CHG-0078 局部） |
| 12 Java 模块文档 | 原 01～08 不改；新增 09～12 已建并获继续授权 | `done`（CHG-0078 局部） |
| 13 Flutter/Web 编码 | 模型参数、首页/新人礼和 Admin 配置保留；翻唱声音克隆按 `157:*` 新稿返工 | `waiting_review`（CHG-0079 UI 已完成） |
| 14 Java 编码 | 模型能力/校验、算道适配、资源持久化、首页/新人礼和 Admin 权限已完成；全量 1956 项测试通过 | `waiting_review`（目标环境待部署） |
| 15 联调与测试 | V2.1 全量用例已编制；双端安全冒烟抽查发现 DEF-V21-001，完整用例、真实训练、翻唱、积分、审核和新成品播放待验 | `in_progress`（P1 缺陷及环境/数据阻塞） |
| 16 构建与打包 | Android debug APK、iOS simulator debug 构建已通过；正式签名与发布构建待后续阶段 | `in_progress` |
| 17 应用上架 | 商店材料与审核 | `pending` |
| 18 发布与版本 | 发布、回滚与变更日志 | `pending` |
| 19 上线监控 | 运行监控、反馈与迭代 | `pending` |

## 4. 当前文档与归档

| 文档域 | 当前主入口 | 状态 |
|--------|------------|------|
| 需求 | [需求清单](01-需求/requirements-list.md)、[PRD](01-需求/requirements.md)、[Product Review](01-需求/requirements-review.md)、[检测报告](01-需求/detection-feedback.md) | CHG-0080/0081/0085 `waiting_review`；旧 PASS 不覆盖当前延期范围与资源规则 |
| V2.1 QA 用例 | [全量用例](05-联调与测试/cases/v2.1-model-driven-params/README.md)、[覆盖矩阵](05-联调与测试/cases/v2.1-model-driven-params/coverage-matrix.md)、[双端抽查](05-联调与测试/v2.1-dual-smoke-20260919.md) | CHG-0084 文档编制；双端抽查 FAIL，完整原用例仍未逐条执行，不继承 V1.2 PASS |
| 技术与工时 | [技术方案](02-技术方案/tech-plan.md)、[工时评估](02-技术方案/effort-estimate.md) | 原方案保留；CHG-0078 技术与工时增量 `done` |
| 前端 | [技术文档](03-前端/flutter-tech.md)；[总体计划](03-前端/flutter-dev-plan.md) | 本地实现完成，Android/iOS 页面与文件选择已验；真实翻唱成品待测 |
| 后端 | [技术文档](04-后端/java-tech.md)；[总体计划](04-后端/java-dev-plan.md) | 本地实现及 1956 项全量回归通过；目标环境部署和厂家闭环待测 |
| 模块计划 | [Flutter/Web](03-前端/开发计划/00-module-index.md)、[Java](04-后端/开发计划/00-module-index.md) | 当前 `-R` 代码完成并进入 `real_review`；环境验收未通过前不关闭 CHG |
| 当前入口 | [CURRENT.md](CURRENT.md) | `active` |
| 历史与差异 | [流程历史](archive/workflow-history-through-20260913.md)、[旧版文档](archive/CHG-0077-legacy-docs-20260913/README.md) | `reference-only` |

## 5. 当前变更与并行事项

- **CHG-0076**：V2.1 三业务参数随所选模型变化。AI 写歌、歌曲改编、翻唱声音克隆仍为独立业务，共用平台任务/审核/积分/资源/作品流程；三端已接能力契约与参数校验，设备和真实厂家联调待做。
- **CHG-0077**：旧版 01～04 阶段文档已归档，`done`；不得把旧开发计划或旧骨架确认当作 CHG-0076 执行授权。
- **CHG-0078**：飞书首页改版及首页/新人礼/任务中心节点已纳入需求。已接真实 Catsinger 配置、审核、注册赠点和新人礼状态；原 Fixture 仅 local/test 保留。Catsinger 专属 V4.10 迁移尚未部署，移动端对稿和本版 QA 未验收。
- **CHG-0079**：Figma `bbxou598` 的 `157:* AI翻唱` 页面组已用于翻唱声音克隆 UI 返工；双端页面和核心入口已验，状态 `waiting_review`，厂家真实成品仍单独阻塞。
- **CHG-0080**：以同一当前 Figma 的 `157:*` 完整状态重新回卷产品文档；App 翻唱主页不再按“缺稿复用旧布局”处理。需求 `waiting_review`，技术和代码差异尚未重新审计。
- **CHG-0081/0085**：CHG-0081 的本地最终资源上传前查重保留；专业写歌/歌曲改编的「使用指定音色」按用户最新要求延期，V2.1 不展示、不进入 P07。P05 翻唱目标音色仍为本期功能；资源实现与目标环境需按当前代码复核，不沿用旧“未实现”判断。
- **CHG-0084**：V2.1 用户测试目录已独立编制并与 V1.2 结果隔离；双端安全抽查的通过项与 DEF-V21-001 见独立报告，不等于完整 V2.1 用例 PASS。
- **并行 QA**：`v1.2.0+121-as-built` 整 App 测试和线上 Bug 修复各按自身 CHG 继续；本版文档状态不覆盖其 PASS/FAIL/待测项。
- **2026-09-15 首页/弹框交互修复**：首页海报已补触摸、鼠标/触控板手动切页、5 秒自动轮播、主 Tab/前后台暂停和动态列表收敛；P03/P04 共用音频参考入口弹框已恢复点击遮罩关闭。新增 6 条定向 Widget 回归、`flutter analyze`、375×812 双海报像素同源复验和 `git diff --check` 通过；全量 Widget 仍因历史 `????` 文案断言及其级联失败，不能记整体 PASS。

## 6. 本步规则、输入与执行记录

| 类别 | 内容 |
|------|------|
| 需加载规则 | `.cursor/rules/00-核心工作流程.mdc`、`01-需求分析.mdc`、`02-需求文档生成.mdc`、`03-需求文档检测.mdc` |
| 必读输入 | 当前 Figma `bbxou598`、[34 张稳定快照](01-需求/references/images/v2.1/figma-bbxou598/README.md)、当前需求清单、PRD 与 Product Review |
| 本步产物 | CHG-0080/CHG-0081 需求三件套、两次改写前归档快照、Figma 状态图索引和当前流程恢复点；不含三端业务代码 |
| 待核验 | 用户确认后执行第 3 步需求检测；检测通过后对延期边界、资源摘要/查重、既有技术方案、模块计划、Flutter/Java/Admin 和双端 QA 做增量影响审计 |
| 最近记录 | 2026-09-15：已读取 Figma `157:*` 状态并补 P05～P12；随后按用户补充把 P03/P04 指定音色统一接 P07，并将 Catseller 上传前查重流程校准为 Catsinger 私有资源目标，状态 `waiting_review` |

状态枚举：`pending`、`in_progress`、`waiting_review`、`done`、`blocked`、`skipped`。任何新变更先登记 [change-plan.md](change-plan.md)；更新工作区文档前运行 `workspace-path-guard resolve/check`，完成后运行 `audit`。
