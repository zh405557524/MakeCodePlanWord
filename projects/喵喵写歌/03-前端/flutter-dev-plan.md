# 喵喵写歌 V2.1 Flutter / Web 总体开发计划

> 2026-09-17 AI 写歌模型校正提示修复：默认模型加载、程序化同步及隐藏模式参数校正改为静默，能力保护和安全序列化保持不变；仅用户在当前可见的简易/专业模式主动换模并确实清值时，提示具体字段。新增两条 Widget 回归、模型契约 8 项测试和静态分析通过；无后端、数据库、SQL、价格或模型配置改动。

> 2026-09-17 AI 翻唱本地文件名展示修复：已选歌曲卡片不再直接展示完整 `share_<hash>` 内部名称，统一去扩展名并按 Unicode 前 8 个字符截断，超出追加省略号；上传、查重和 `originalFilename` 仍使用完整原名，选择时仍不产生网络请求。相关测试 `34/34`、P05 与 375×812 截图用例、静态分析及差异检查通过；后端、数据库和 SQL 无改动。

> 2026-09-17 通用阻塞加载组件收口：App 将 `app_blocking_status_dialog.dart` 重命名为 `loading_dialog.dart`，删除支付专属包装，素材提交、资料审核、最终朗读和支付统一复用 `LoadingDialog`。组件固定为单动画、单行文案和不可退出交互，页面按钮不再叠加 loading；业务时序、接口、后端、数据库及 SQL 均未改变。定向回归 `46/46`、两项截图用例、静态分析及 iOS 模拟器 Debug 构建/安装/启动通过。

> 2026-09-15 音色卡片修复：用户确认计划已直接落地 App + Java；最新训练状态、临时音色隐藏、选中/试听/删除、失败重训及退出确认丢弃已实现。Flutter 定向 21 项、后端 12 项、静态分析通过，375×812 状态布局及 Android 真机灰卡清除/退出弹窗已检查。后端运行实例待重启、真实试听与厂家训练待验收；详见 [F004 修复交付](开发计划/04-voice-train-and-clone.md)。既有其他任务状态不变。

> 版本：`v2.1-model-driven-params` · CHG-0076/0078 第 13 步本地真实实现 `waiting_review` · 更新：2026-09-14
> 依据：[当前 PRD](../01-需求/requirements.md)、[当前技术方案](../02-技术方案/tech-plan.md)、[CHG-0078 增量工时](../02-技术方案/effort-estimate.md)、[Flutter/Web 技术文档](flutter-tech.md)、[Java 技术文档](../04-后端/java-tech.md)；当前 Figma 通道为 `bbxou598`，翻唱声音克隆以 `157:*` 页面组为视觉真源。

## 1. 用途、范围与恢复点

本文是**本版本增量编码的总体计划**，不是旧 CHG-0073 的全量页面计划，也不是已实现记录。覆盖 Flutter App `/Users/soul/code/lxwx/catsinger` 和 Flutter Web/Admin `/Users/soul/code/lxwx/lxwx_admin`；后端任务由[同版本 Java 总体计划](../04-后端/java-dev-plan.md)负责。只有第 11/12 步模块文档完成并与本计划一致后，才具备进入骨架编码的文档条件。

当前恢复点：用户已明确授权本版跳过骨架评审，`implementationMode=direct_implementation`、`implementationPhase=real_review`。F001～F007、W001～W004 已完成本地真实实现；Android 真机与 iOS 模拟器已完成关键 UI/文件选择验收。真实翻唱声音克隆仍缺算道账号、场景映射、计费和验证短句，未形成可播放作品。

> CHG-0079（2026-09-15）：最新 Figma `bbxou598` 的 `157:* AI翻唱` 页面组已用于 Flutter `song_voice_cover` 返工，保留现有真实业务调用。Android 真机、iOS 模拟器、定向测试和双端 Debug 构建已通过，当前回到 `real_review`；真实厂家成品仍独立阻塞。

下文第 2～7 节保留授权前的双阶段计划，用于追溯任务边界，不代表当前仍处于 `skeleton_coding`；当前状态以第 8 节最新执行记录和模块索引为准。

范围是三业务和本人音色训练的**逐模型参数适配**：AI 写歌、歌曲改编、翻唱声音克隆各自保持现有页面、Controller 和公开创建接口，复用既有任务、作品、播放器。W01～W07 只在后台现有信息架构中增量调整；不重写会员、积分、审核、上传、作品或登录。旧文档统一位于[归档](../archive/CHG-0077-legacy-docs-20260913/)，只能差异对账，不能作为任务完成依据。

## 2. 执行策略与跨端依赖

1. **先锁契约**：与 Java 的 `musicContract` 目标字段 `contractVersion/effectiveParameters/mediaConstraints` 对齐，同时保留现有 `operationType/status/parameters`、价格版本和响应包络。训练与克隆模型返回同语义契约；旧 `capabilityLimits` 仅兼容，不当作厂家真源。字段仍是技术方案，未实现前不伪称接口已返回。
2. **先 Java local/test 骨架，再页面骨架**：新 UI 和 Admin 调用已确定的现有 API 路径，由受控 local/test 后端给固定能力；页面不得散落模拟的模型、价格或可用状态。旧生产功能保持原状，新增未完成功能默认关闭，不用固定响应覆盖生产真实数据。
3. **两端完整骨架共同评审**：App 置灰、原因提示、切模型清值、请求序列化和 Admin 收窄表单都有可运行调用链；Java 侧能解释对应原因且生产不返回伪成功。三端整体进入 `skeleton_review` 后停下，只有用户明确确认骨架，才开始 `-R`。
4. **真实实现与验收**：后端有效能力/提交校验先落地，再接 App/Admin；用户测试必须走 Android 和 iOS 的真实模型配置、训练/生成、作品播放，不用 Widget 通过代替业务通过。

模型已选后，App 固定字段目录只负责布局、控件类型和互斥。能力不支持或未声明时控件仍可见、置灰且可点出原因；切换模型时只保留新模型仍支持且合法的用户值，其他值清空、合并提示，上传资源本身不删除。价格跟模型/影响价格的设置刷新，缺价不可提交；请求只送业务必需字段与当前有效可选项。纯音乐互斥的歌词保留本地草稿但不发送，与切模型清空是两回事。服务端仍是最终校验者。

## 3. 状态、里程碑与工时

任务状态用 `pending → in_progress → waiting_review → done`，另有 `blocked`；每完成一个任务，写明修改文件、契约版本、验证命令、未通过项和下一恢复点。`-S` 与 `-R` 分别记状态，骨架通过不等于真实实现通过。Web 任务也拆 `-S/-R`，因为本版 `skeletonTargets` 包含 `web`。

本节 6.5 个 AI 辅助工作日仅是 **CHG-0076 原参数适配排期**，不是本次首页任务用时，也不代表原任务已经完成。CHG-0078 的新增 6 个有效工作日单列在[当前增量工时](../02-技术方案/effort-estimate.md)，不能与原排期直接相加为同一人连续承诺。1 天按 8 小时；两轮骨架评审等待、测试素材或线上 Bug 占用均会使日历顺延。

| 里程碑 | App / Web 交付 | 门禁 |
|--------|----------------|------|
| M0 文档对齐 | 原 CHG-0076 第 11 步文档已生成；CHG-0078 需另建增量模块文档并与 Java 第 12 步对齐 | 新模块目前 `pending`；不能据原模块计划编码 CHG-0078 |
| M1 可运行骨架 | 两端 `-S` 任务完成：路由/控件、Controller、Repository/API 调用、受控固定响应 | `flutter analyze/test` 与生产禁用检查；全三端 `skeleton_review` |
| M2 真实实现 | 用户明确确认骨架后执行 `-R`；按真实模型参数与后台配置工作 | 服务端校验已就绪，App/Admin 不信任本地旧值 |
| M3 用户验收 | Android/iOS 三业务和训练；后台切 App/角色/价格/能力；真实成品可播放 | 属第 15 步 QA；未过不能标本版 done |

## 4. Flutter App 任务

任务编号与当前[技术方案第 7 节](../02-技术方案/tech-plan.md)的 CHG-0076 部分对齐；下表每行 `-S` 与 `-R` 是**两个任务**，不能批量标完成。每个 `-R` 都依赖所有三端骨架整体评审通过，而不只是本模块 `-S` 完成。

| ID / 目标域 | `-S` 骨架：调用链与固定状态 | `-R` 真实实现与完成条件 | 主要依赖 |
|-----------|----------------------------|-------------------------|----------|
| `T-F001` 模型契约、通用投影 | `T-F001-S`：`models/data/`、`apis/`、Controller 层解析目标 `musicContract`；本地/测试后端覆盖支持、禁用、未知、缺价、版本变化；旧响应安全置灰 | `T-F001-R`：真实响应解析、切模请求竞态、失效值清除/合法值保留、原因码映射；模型列表变更后草稿与价格一致 | `T-B001/002-S/R`，T-W001 |
| `T-F002` 简易/专业写歌 | `T-F002-S`：现有 `song_create/` 页面按 Figma 保留字段位置，置灰可点说明、纯音乐互斥、按钮与价格状态走 Controller；既有 `POST /api/song-generations` 路径 | `T-F002-R`：专业歌词/音色/参考音频真实能力交集、旧值过滤、最小有效载荷、当前价确认；不改写任务业务类型 | F001、B003/B006、现有上传/歌词接口 |
| `T-F003` 歌曲改编 | `T-F003-S`：现有 `song_cover/` 接入独立场景 `song.cover.generate`、禁用提示和歌词开关状态；继续使用 `POST /api/song-covers` | `T-F003-R`：保留原词关闭时不暗送旧词，识别/新词状态与模型切换、报价及请求复核一致；历史改编仍为改编 | F001、B003/B006、现有来源接口 |
| `T-F004` 音色训练/克隆 | `T-F004-S`：现有 `song_voice_cover/`、音色/训练页接动态控件范围、兼容原因、训练媒体限制展示；训练与克隆各走自己的既有 API | `T-F004-R`：真实素材硬限制、可用音色绑定、动态移调/音量/输出选项、无效值省略；训练建议不变硬拦截，实际本人音色仅用于兼容模型 | F001、B004/B005/B006、现有资源/审核 |
| `T-F005` 报价、任务与作品 | `T-F005-S`：现有等待/作品/`SongPlayerPage` 显示价格/任务状态与三业务返回路由；固定结果仅 local/test | `T-F005-R`：切价重确认、过期版本恢复、前后台任务恢复、正确重新创作入口和真实音频播放；API 状态成功但无法播放判失败 | F002～004、B006、现有作品/播放器 |

**App API 对账**：`GET /api/ai-model-options?sceneCode=song.generate|song.cover.generate`、`GET /api/song-config/models?sceneCode=song.voice.train|song.voice.cover.generate`、`GET /api/song-config/generation-options`（仅运营选项）、三个独立歌曲创建接口及训练接口均沿[技术文档](flutter-tech.md)既有路径。App 不新增同义创建 API；报价或参数差异计价若现有接口不足，先回卷技术方案和模块文档再实现。

## 5. Web/Admin 任务

页面保持 `Widget → AdminRepository → ApiClient → /api/admin/**`，不在 Widget 直接拼路径。现有 `AiModelOptionsPage`、`SongConfigPage`、官方音色和任务/作品入口按 W01～W07 分工；没有新后台设计稿，沿用当前管理端布局。后台可以缩小厂家范围、关闭参数、调整合法默认值与价格，不能开启未声明能力。服务端仍要校验 App/角色/版本，不能只靠灰按钮。

| ID / 管理范围 | `-S` 骨架 | `-R` 真实实现与完成条件 | 依赖 |
|---------------|------------|-------------------------|------|
| `T-W001` W02 模型能力 | `T-W001-S`：厂家能力只读区、合法子集表单、未知/越界置灰及原因；local/test 走现有 Admin 模型/映射 API | `T-W001-R`：真实读取/保存后台收窄值，过期版本冲突保留草稿；服务端拒绝越界、未知或扩大能力，刷新后 App 可见 | B001/002、Admin 现有权限 |
| `T-W002` W01/W03～W07 | `T-W002-S`：复用 App 切换、价格、官方音色、任务、审核、作品视图，展示四场景和空/失败/403；只用受控固定响应 | `T-W002-R`：真实价格/默认/音色配置、切 App 草稿隔离、角色权限及作品类型对账；不修改旧改编任务和历史作品分类 | W001、B005/006、现有 Admin API |

## 6. 第 11 步模块文档清单（已生成，待整体评审）

本版 [模块索引](开发计划/00-module-index.md) 与下列详细文档已生成并用于本轮编码。每份包含当前 Figma/PRD 来源、现状差异、API/Model/Controller/Store、`-S/-R` 方法调用、异常/空态、影响文件、验证与恢复点；旧版同名计划不得搬回工作区。

| 模块文档（拟定） | 覆盖任务 | 依赖 |
|------------------|----------|------|
| `01-contract-and-fixture.md` | F001-S/R，跨端 wire shape、受控测试数据 | Java B001/002 |
| `02-song-create.md` | F002-S/R，简易/专业、纯音乐、报价、载荷 | 01 |
| `03-song-adaptation.md` | F003-S/R，原词策略和改编独立业务 | 01 |
| `04-voice-train-and-clone.md` | F004-S/R，媒体、音色、动态设置 | 01 |
| `05-task-work-player.md` | F005-S/R，任务恢复和成品播放 | 02～04 |
| `06-admin-capabilities.md` | W001-S/R，模型能力和合法收窄 | 01、Java B002 |
| `07-admin-operations.md` | W002-S/R，价格、音色、任务、App/角色隔离 | 06 |
| `08-acceptance.md` | 两端验收和第 15 步移交 | 全部 |

## 7. 编码约束和验证

- 继续沿用 GetX、go_router、Dio、GetStorage/Hive、现有主题/资源和 `CustomScaffold`；不把 UI 逻辑搬到 API 类，也不新建并行状态框架。375×812 主验，390×844/414×896 抽查键盘、长动态数字、底栏、按钮与禁用提示；动态示例值不同不要求改 Figma。
- 骨架只在 local/test 开启新增固定能力；页面/Controller 使用正式 API 方法和路径，固定响应由集中 fixture 或 Java 受控测试服务提供。生产配置下新未完成功能默认关闭、不得返回或显示伪成功；现有线上写歌/改编功能不因骨架被覆盖。
- 每个 App/Web 模块完成时运行格式化、`flutter analyze`、相关 `flutter test`；对模型切换、缺契约、价格变化、后台跨 App、403 和禁用项请求写定向回归。骨架验证不调用真实上传、审核、积分或厂家。
- 真实实现后与 Java 同步按场景验请求、任务/冻结/失败释放、资源持久化；Android/iOS 真正生成的目标作品能持续播放才算通过。iOS 真机优先、模拟器兜底，都没有则双平台验收不通过。第 15 步记录截图、日志、任务/作品 ID、失败原因，不把“提交成功”写成通过。
- 不改无关脏工作树、旧 CHG-0073 实现或线上 Bug 修复；发现接口字段不一致，先回卷本版 Flutter/Java 技术文档和对应模块计划。

## 8. 执行记录

| 日期 | 结果 | 状态 / 下一恢复点 |
|------|------|-------------------|
| 2026-09-13 | 依据当前 PRD、技术方案、第 7/8 步技术文档及 6.5 天共用排期生成本版总体计划；未生成模块文档，未修改三端代码 | 本文 `waiting_review`；下一步第 11/12 步模块文档，骨架仍为 `skeleton_pending` |
| 2026-09-13 | 第 11 步已生成本版索引与 01～08 模块文档，覆盖 F001～005/W001～002 的独立 `-S/-R`，并与 Java 第 12 步对齐；未改业务代码 | 本总体计划作为输入记 `done`；模块文档 `waiting_review`，骨架仍为 `skeleton_pending` |
| 2026-09-14 | 用户要求继续，进入第 13 步；F001-S 已在 Flutter 模型层安全解析目标契约，旧响应/缺版本默认禁用；`flutter analyze --no-pub` 和定向测试通过。页面投影及 Web/Admin 未做 | F001-S `in_progress`，其余 `-S/-R` `pending`；整体 `skeleton_coding`，未进入真实实现 |
| 2026-09-14 | 按用户指出的目录规则修复 `song_voice_cover`：`library/profile/training/generating` 四个独立子流程各有可执行的 `index/controller/view`；音色库选择草稿移入自身 Controller，共用格式方法抽至 `shared.dart`。正式包保留既有翻唱主页；新音色库仅 local/test 显式预览。App `flutter analyze --no-pub` 和 13 项定向测试通过，未部署真机 | F004-S `in_progress`，F004-R `pending`；还需本人验证、动态参数、截图与完整链路验收 |
| 2026-09-14 | 用户确认 CHG-0078 第 7/8 步增量技术文档后，在本计划增写第 9 节；旧 CHG-0076 任务状态和并行线上 Bug 不回写 | 本次新增 T-F006/007、T-W003/004 均 `pending`；第 11 步增量模块文档待建，计划增量 `waiting_review`，未改三端代码 |
| 2026-09-14 | 用户继续第 11/12 步，已生成 CHG-0078 前端 09～13 增量模块文档并接入索引；原 01～08 不改 | 本总体计划第 9 节作为已确认输入记 `done`；新增模块文档 `waiting_review`，所有新 `-S/-R` 仍 `pending`；未改三端代码 |
| 2026-09-14 | 用户明确授权本版三端跳过骨架评审、直接真实实现。App 接入模型参数/置灰、新首页/新人礼与独立音色库默认路由；Admin 接入模型、海报、赠额及新人礼配置。App/Admin `flutter analyze`、App 新增定向测试、Admin 全量 233 项、Android Debug APK、Admin Web 构建通过 | 第 13 步 `in_progress`；旧骨架行只作历史，设备截图、真实厂家、积分/审核与 App 全量 Widget 回归未验收 |
| 2026-09-14 | 完成本地实现与 UI 审计：Flutter analyze、V2.1 定向 22/22、Android/iOS Debug 构建、Admin analyze/234/234/Web 构建通过；Android 真机和 iOS 模拟器验证翻唱主页、音色库/资料及文件选择。已有 AI 改编音频播放位置递增通过 | 第 13 步转 `waiting_review`；翻唱声音克隆没有可用模型/验证短句/成品，真实播放为 NOT_RUN。Flutter 全量 141 个历史损坏文案断言单列测试债务 |
| 2026-09-15 | CHG-0079 按 Figma `157:*` 重组翻唱声音克隆主页：使用原始头图，同页选择歌曲/设置/我的与官方音色，补训练中/失败/不可用/模型不兼容状态；Android 真机与 iOS 模拟器检查歌曲面板、授权开关、创建音色和滚动布局 | `flutter analyze`、定向 13/13、Android/iOS Debug 构建和 diff check 通过；第 13 步 `waiting_review`，真实厂家成品仍 BLOCKED/NOT_RUN |
| 2026-09-15 | 修复首页海报无法完整轮播及 P03/P04 共用音频参考弹框遮罩不可关闭：首页支持触摸/鼠标/触控板、5 秒自动切页及生命周期暂停，弹框恢复内容高度并显式允许遮罩/下滑关闭 | 新增定向 Widget 6/6、相邻首页回归 3/3、`flutter analyze`、375×812 双海报截图逐文件 SHA-256 同基准、390/414 弹框布局及 diff check 通过；全量 280 项通过、138 项因既有 `????` 文案断言和级联失败，未宣称全量 PASS |

## 9. CHG-0078 首页与新用户权益增量总体计划

### 9.1 范围、策略与恢复点

> 本版执行覆盖：用户已授权 `direct_implementation / real_coding`。本节原“待评审/仅骨架”段落保留为授权前历史，不再禁止 `-R`。新版首页和音色库在 Debug/Release 默认启用，Fixture 仍只在本地/测试环境可用；真实链路未经验收不得记为 `done`。

本节仅覆盖 PRD P01/W08/W09：首页运营海报与三个独立业务入口、现有建号赠积分可配置、新人礼弹窗和后台维护。设计真源是当前 Figma `xvrgwxfy` 的 `151:7830/7973/8116`，任务中心 `151:8281/8422` 只复用现有页面；动态积分、签到奖励和任务奖励均取服务端，不照设计示例写死。App `/Users/soul/code/lxwx/catsinger`、Admin `/Users/soul/code/lxwx/lxwx_admin` 的既有登录、路由、任务/作品与歌曲接口保持不变。第 11 步必须为本节新建独立模块计划；旧 `01～08` 只负责 CHG-0076，不能当作本节可编码证据。

当前阶段：第 11/12 步增量模块文档待评审；`implementationPhase=skeleton_coding` 描述**原 CHG-0076**，不代表 CHG-0078 已开工。CHG-0078 的 `-S/-R` 任务初态都是 `pending`。任务状态单项按 `pending → in_progress → waiting_review → done` 更新，阻塞用 `blocked`；每次只变动实际完成项，写明修改文件、调用链证据、测试结果/未测项和下一恢复点。整体骨架未进入 `skeleton_review` 且未获用户明确确认前，全部 `-R` 严禁执行。

### 9.2 同一人 6 日容量与交付顺序

本节共用[CHG-0078 六日估算](../02-技术方案/effort-estimate.md)：Flutter 1 天、Java 2 天、Web/Admin 1 天、三端骨架与审阅准备 0.5 天、Android/iOS 用户测试 1 天、Bug 修复回归 0.5 天，均为**同一名** AI 辅助执行人每天 8 小时，不按三端并行再压缩。9 月 16～24 日仅在文档/素材/设备按时就绪且骨架及时明确确认时成立；未确认则后续真实实施与验收整体顺延。业务功能先后为“海报/三入口 → 赠额配置 → 新人礼 → 配置联调 → 双端用户验收”；技术依赖允许 Java 契约与 Flutter/Web 表单骨架交错完成，但任何真实副作用均在骨架门禁之后。

| 里程碑 | App / Admin 可检查结果 | 依赖与退出条件 |
|--------|----------------------|----------------|
| H0 增量文档 | 当前第 9/10 步计划与第 11/12 步新增模块文档对齐 | 技术字段、任务编号和未做范围一致；只有文档完成，不宣称功能完成 |
| H1 三端可运行骨架 | 首页轮播/三卡、礼物弹窗、Admin 两配置块走正式 API 方法和 local/test 固定响应 | Java B007～009-S 先提供正式路径；Flutter/Web `-S` 通过分析/定向测试，生产默认关闭；整体 `skeleton_review` |
| H2 真实配置与权益 | Banner 正式发布、后台金额/弹窗规则、App 读配置与资格状态 | 用户明确确认整体骨架后才执行所有 `-R`，先 Java 发布/资格，再 App/Admin 联调 |
| H3 用户验收 | Android+iOS 三入口、海报、稍后/领取及后台生效记录 | 属第 15 步；真实新账号流水和服务端领取态一致，未测不报 PASS |

### 9.3 Flutter App 任务（`-S/-R` 分开验收）

| 任务 / 主落点 | `-S` 骨架与完成条件 | `-R` 真实实现与完成条件 | 依赖 / 当前状态 |
|----------------|----------------------|-------------------------|------------------|
| `T-F006` 首页海报与三入口：`pages/home/`、`pages/main/controller.dart`、Song API/Model | `T-F006-S`：按新稿呈现轮播、指示器、三入口、加载/占位；Controller 通过真实 `GET /api/song-config/home-banners` API 方法消费受控 fixture，静态海报不跳转，三入口各到原业务页面；生产未完成功能关闭 | `T-F006-R`：消费后台有序审核海报，图片失效安全降级、可选 `targetCode` 白名单路由；热门案例独立失败，保持返回滚动位置；375×812 主图及 390/414 抽查合格 | B007-S/R；`-S=waiting_review`，`-R=pending`；设备对稿未验 |
| `T-F007` 新人礼弹窗：首页 Controller/覆盖层、Song API/Model | `T-F007-S`：登录态才查资格，实际渲染后确认曝光，按钮分别走 dismiss/claim 正式方法；固定状态只从 local/test fixture 来，关闭不做本地永久已领取，成功可走原签到/任务路由 | `T-F007-R`：服务器 `shouldShow` 为唯一资格判断；同次启动 `openId` 复用、重复点击锁定、失败恢复、切后台/登录切换重新查；稍后不消耗曝光，领取后不再弹 | B009-S/R、F006；`-S=waiting_review`，`-R=pending` |

App 接口：`GET /api/song-config/home-banners` 得 `items[{id,imageUrl,targetCode?}]`；`GET /api/song-config/new-user-gift` 得 `shouldShow/impressionToken?/imageUrl?/text?/targetCode?/configVersion?`，本次启动 `openId` 只辅助 `PER_OPEN`；`POST .../impressions` 与 `/dismiss`、`/claim` 均携带本次 `impressionToken`，曝光可带 `openId`。View 不直拼接口、不存永久资格；未知/下线目标不可跳。写歌、改编、翻唱分别沿原业务导航和各自 `/api/song-generations`、`/api/song-covers`、`/api/song-voice-covers`，首页点击**不**创建任务或冻结积分。

### 9.4 Web/Admin 任务

沿用 `SongConfigPage → AdminRepository → ApiClient`、既有 App 切换及 `song_config` 管理块，不新开平行后台。Admin 对 Catsinger 显示 W08/W09；切换 App 清空列表/编辑上下文，403 表示无权限而非登录失效。上传图片及可展示文字沿既有安全审核资源链，不允许绕过审核直接发布或填任意外链。

| 任务 / 视图 | `-S` 骨架与完成条件 | `-R` 真实实现与完成条件 | 依赖 / 当前状态 |
|-------------|----------------------|-------------------------|------------------|
| `T-W003` W08 海报管理 | `T-W003-S`：现有 Catsinger 配置页增有序海报表/预览/资源选择/目标/启停/保存状态；正式 `GET/PUT /api/admin/song/home-banners` 调用层，固定响应只在 local/test | `T-W003-R`：审核资源、排序、版本冲突、至少一张启用有效海报；删停最后一张服务端拒绝并保留草稿，发布后 App 读取一致 | B007-S/R；`-S=waiting_review`（资源选择仅 ID 占位），`-R=pending` |
| `T-W004` W09 新人权益配置 | `T-W004-S`：赠额、人群、频次、样式、目标表单及提示；正式 `GET/PUT /api/admin/song/new-user-points` 与 `/new-user-gift` 方法，固定展示只在 local/test | `T-W004-R`：真实权限/版本/审核联调；赠额只影响之后的账号，旧无效值显示兜底告警；签到/任务目标白名单，领取态不可由后台重置 | B008/B009-S/R；`-S=waiting_review`，`-R=pending` |

### 9.5 第 11 步已建的增量模块文档

当前[前端模块索引](开发计划/00-module-index.md)已追加 CHG-0078 专区，下列 5 份文档已创建，状态均为 `waiting_review`；**文档完成不表示已编码，也不改变原 01～08 状态**。各模块包含 Figma/PRD 来源、现状差异、API/Model/Controller/Store、状态/错误、影响文件、`-S/-R` 步骤与独立验收，并与 Java 第 12 步模块契约对齐。

| 已建文件 | 对应任务 | 核心依赖 |
|----------|----------|----------|
| `09-home-carousel.md` | T-F006-S/R | Java B007；设计稿 `151:7830/7973` |
| `10-new-user-gift.md` | T-F007-S/R | Java B009；设计稿 `151:8116`，现有签到/任务路由 |
| `11-admin-home-banners.md` | T-W003-S/R | Java B007；现有媒体审核与 Admin 权限 |
| `12-admin-new-user-benefits.md` | T-W004-S/R | Java B008/B009；配置版本与审计 |
| `13-home-benefit-acceptance.md` | T-Q002 的 App/Admin 用户验收交接 | 全部新模块；Android/iOS 和 Web 配置矩阵 |

### 9.6 验证、回滚与编码边界

文档阶段只核对两端字段、正式路径与模块计划依赖，**不**运行三端业务测试或宣称已实现。骨架后分别跑 Flutter App/Web 的 `flutter analyze` 和受影响 `flutter test`；后端契约测试证明生产默认禁用 fixture，所有上传、审核、积分、数据库写入、副作用都未发生。真实实现后核验配置冲突、跨 App/越权、旧值兜底与真正 DB 故障的区分。第 15 步用新建游客/手机号、绑定及历史账户做用户路径，查积分流水、弹窗资格和海报目标；iOS 真机优先，模拟器兜底，均不可用则双平台验收失败。任何 Android/iOS 结果未验证时标 `NOT_RUN/BLOCKED`，不冒充 PASS。

回退时只停用 CHG-0078 新入口/配置展示并恢复前一个有效海报配置，不触碰既有建号流水、旧 AI 改编作品或 CHG-0076 模型骨架；真实数据回退须先核对已发放积分和资格记录，不以删除配置当作撤销资金。三端新功能不得混入线上 Bug 修复。当前恢复点：第 13 步 `-S` 已编译待 UI/代码审阅，全部 `-R` pending。App/Admin `flutter analyze` 及定向测试通过；App 全量旧 Widget 测试连续超时后中止，未通过全量回归。原 F001-S 独立继续，整体仍在 `skeleton_coding`。
