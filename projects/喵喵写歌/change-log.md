# 喵喵写歌 研发变更日志

> 当前为新项目基线建立阶段。  
> 后续变更从 `change-plan.md` 完成后归档到本文件。

---

## v2.1-model-driven-params 历史文档归档 - 2026-09-13

> 关联变更：CHG-0077 · 归档：`archive/CHG-0077-legacy-docs-20260913/`

### Added

- 新增旧需求、技术方案、前后端技术/总体/模块计划及旧设计资源的归档索引，保留原相对目录结构和旧需求资料索引。

### Changed

- 工作区 01～04 阶段仅保留当前 `v2.1-model-driven-params` 需求、技术方案、工时入口和最新 Figma 快照；旧文档统一 `reference-only`。
- 第 7～12 步当前版技术与开发计划标为 `pending`，不再指向旧 CHG-0073 计划。CHG-0076 保持第 6 步 `waiting_review`。

### Removed

- 从当前工作目录移出 217 个旧版文件；全部保留在归档中，未删除内容。

### Verified

- 文档链接、路径守卫和工作区 audit 通过；未修改 Flutter、Java、Web/Admin 代码或数据库。

---

## v2.1-ai-cover-voice-clone 先骨架后真实实现规范 - 2026-09-09

> 关联变更：CHG-0075
> 影响范围：全局流程规则、Flutter/Java 工程规则、CHG-0073 总体计划与模块文档

### Added

- 新增 `implementationMode`、`implementationPhase`、`skeletonTargets`、`skeletonRuntime` 四个流程字段。
- 新增 `T-F/T-W/T-B xxx-S` 骨架任务和 `xxx-R` 真实实现任务，以及 `skeleton_review` 明确确认门禁。
- 新增 local/test 集中固定响应、生产默认关闭、代码地图/调用图/固定数据/TODO 清单要求。

### Changed

- 大功能和跨模块新功能默认先做可编译、可运行骨架；线上 Bug 和小范围逻辑调整可直接实现。
- CHG-0073 当前只规划 Flutter App 与 Java 骨架，Web/Admin 暂缓；骨架阶段数据库改动为无。

### Verified

- 全局与项目级规则包含双阶段门禁；CHG-0073 的 28 份模块正文均存在 `-S/-R` 映射。
- 当前仍停在第 11/12 步 `waiting_review`、`skeleton_pending`；未修改三端业务代码或数据库。

---

## v1.1.0-as-built 场景模型映射与移动端单次任务模型选择 - 2026-09-04

> 关联变更：CHG-0068  
> 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`、`/Users/soul/code/lxwx/lxwx_admin`、`/Users/soul/code/lxwx/catsinger`、Figma

### Added

- 新增公共 `ai_scene_model_mappings`，以公开 UUID 映射 App、业务场景、真实商家模型、移动端名称/图标、真实计费项和公开 JSON 扩展；任务表新增模型选项和价格版本快照。
- 新增脱敏模型选项查询接口和后台场景模型映射管理接口；Admin 增加筛选、编辑、图标上传、实时计费展示和默认映射告警。
- catsinger 简易、专业、AI 翻唱新增动态模型选择器；Figma 已在用户最新修改基础上重新检测并补齐三类入口与弹层交互标注。

### Changed

- 新客户端创建歌曲只提交 `modelOptionId`；服务端按当前 App 和任务场景解析真实模型与计费，选择只影响当前任务并固化快照。
- 未提交选项的旧客户端继续使用 `ai_model_configs` 默认模型；其单 App、单场景唯一约束和后台保存逻辑保持不变。
- 移动端不保存上一次选择、不增加会员模型、不暴露真实商家/模型/计费编码；价格始终读取真实计费项。

### Verified

- 后端映射、任务接口和 OpenAPI 专项通过；Admin AI 配置页测试文件 11 项、catsinger 3 项及双端 `flutter analyze` 通过。
- 后端全量报告记录 851 项，其中 3 个会员周期/时间边界用例失败，另有 1 个 Gradle Test Executor 因 512MB Java heap OOM 失败；模型选择专项单独执行无失败。
- 未执行真实数据库迁移、场景映射配置、Provider、真机或已部署环境联调。

---

## v1.1.0+111 iOS 游客账号与订阅恢复 - 2026-08-12

> 关联变更：CHG-0066  
> 影响工程：`/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

### Added

- iOS 登录页增加“游客继续（无需手机号）”“手机号登录”和用户主动“恢复购买”；游客 Keychain 凭证按 `catsinger` 隔离并恢复同一正式 `userId + JWT`。
- 新增游客会话、可选绑定未注册手机号和 Apple 自动续订订阅恢复接口；所有新用户创建时统一获得一次 30 积分，游客绑定手机号不重复发放，并保留会员、积分和作品。
- 会员页、设置页增加恢复购买入口；用户资料增加 `accountType`，游客在“我的”页显示“游客账号”和“绑定手机号（可选）”。

### Changed

- 路由权限拆为 sessionRequired 与 registeredRequired；游客可购买、写歌、生成、查看作品及会员/积分记录，邀请、兑换码和账号安全提示绑定手机号后使用。
- Apple 本地待确认订单记录 `ownerUserId`；主动恢复时先结算当前账号本地订单，未匹配的有效订阅才通过 Apple 双重验真恢复原购买游客，积分等消耗型商品明确不可恢复。
- Android 不展示或调用游客能力，原手机号登录与路由行为保持不变。

### Verified

- 后端游客专项、Apple 恢复验真、限流、手机号状态和 OpenAPI 契约测试通过；Flutter `flutter analyze` 与游客专项测试通过。
- catsinger iOS Simulator Debug 构建通过。
- 后端已统一新用户 30 积分测试基线；游客创建、恢复和绑定专项通过，完整套件仅余与本规则无关的既有工作流断言。Flutter 历史全量套件仍被既有乱码断言及其连锁超时阻断，本次新增专项无失败。

---

## v1.1.0-as-built OPPO 友盟 GAID 超范围收集合规修复 - 2026-08-10

> 关联变更：CHG-0065  
> 影响工程：`/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_admin`

### Changed

- Android 完整移除友盟组件化基础库、移动统计 SDK、preInit、授权桥接、集成测试 Scheme 和混淆配置，避免 SDK 内部重复读取 GAID。
- 新增 API 兼容的 iOS-only 本地插件，继续使用固定 `UMCommon 7.5.11`、`UMDevice 3.6.0`；iOS 仍仅在用户同意隐私政策后初始化。
- 隐私政策将友盟章节改为仅 iOS 使用，披露 iOS 组件、设备信息、IDFA/IDFV、功能使用记录和日志；删除 Android 友盟包名及 GAID、MAC、软件安装列表等 Android 专属说明。
- 隐私弹框和登录、创作、播放、支付、分享业务保持不变。

### Verified

- `flutter analyze` 无问题；受保护服务 2 项、隐私流程 6 项定向测试通过。
- Android Release APK 和 iOS 无签名 Release 构建通过；Android release 依赖树、合并 Manifest、DEX 均无友盟 Android SDK、`AD_ID` 或 MSA 权限。
- iOS Pod 锁定版本保持不变；隐私政策 HTML 结构校验通过。
- V1981A 覆盖安装 Release APK 并保留原数据，冷启动 2.37 秒进入首页；进程日志和设备包信息无友盟、GAID、Advertising ID、`AD_ID`、MSA、缺类或插件异常。
- App、Web/Admin 与流程工作区 `git diff --check` 通过，流程工作区路径守卫 `audit` 通过。
- 待使用新 Android Release APK 复测 OPPO 自动化检测 2.5 项。

---

## v1.1.0-as-built “生成同款”参数降级提示移除 - 2026-08-04

> 关联变更：CHG-0059  
> 影响工程：`/Users/soul/code/lxwx/catsinger`

### Changed

- 移除进入“生成同款”后的“部分原参数当前不可用，已使用默认配置”提示，避免在用户编辑表单时额外弹出无需感知的降级信息。
- 原参数的别名映射、已停用模型回退、未知风格过滤、人声推断和参考音频失效清理仍保持原行为，仅改为静默应用当前可用配置。
- 后端接口、请求字段、计费和数据库均不变。

### Verified

- 3 项“生成同款” Widget 回归通过，覆盖 Provider 别名与未知标签映射、快照风格优先级、纯音乐回填；未知标签被过滤时确认不再出现该提示。

---

## v1.1.0-as-built 播放器“生成海报”入口恢复 - 2026-08-04

> 关联变更：CHG-0058  
> 影响工程：`/Users/soul/code/lxwx/catsinger`

### Fixed

- 修复播放器使用完整播放缓存时跳过详情网络刷新，导致失效旧封面 URL 长期保留、“生成海报”入口被错误隐藏的问题；播放缓存继续负责首帧，但每次进入播放器都会后台刷新作品详情。
- 修复封面 URL 非空但图片实际加载失败时只显示紫色占位图的问题；错误占位现在同时恢复“重新生成封面”入口，不再仅按 URL 是否为空判断可用性。

### Changed

- 封面为空时继续免费走现有生成路径；图片加载失败但接口详情仍有封面时，播放器先展示统一积分确认，取消不提交，积分不足继续进入权益提示。
- 生成成功继续清理稳定封面缓存键并同步播放器、作品 Store 和列表刷新事件；后端接口、请求体、响应结构和数据库不变。

### Verified

- 4 项播放器 Widget 回归通过，覆盖缺失封面、活动播放旧缓存网络刷新、非空封面 URL 加载失败后恢复入口及积分确认取消、配置歌曲缺失封面入口。
- `dart format` 与 `git diff --check` 通过；`flutter analyze` 无新增诊断，仅保留既有 `custom_toast.dart` 未使用私有方法警告。

---

## v1.1.0-as-built 作品详情封面重新生成缓存同步修复 - 2026-08-04

> 关联变更：CHG-0057  
> 影响工程：`/Users/soul/code/lxwx/catsinger`

### Fixed

- 恢复作品详情“播放器详情缓存/入口列表摘要首帧展示 + 后台请求最新完整详情”的行为；独立详情页和详情弹层每次重新创建 Controller 都会请求 `GET /api/song-works/{id}`，缓存命中不再阻止网络刷新。
- 修复封面重新生成成功后直接改写 `MusicPlayService`、导致播放态详情缓存与仅封面操作耦合的问题；封面接口响应现在只更新当前详情和 `SongWorkStore.currentWork`。

### Changed

- 普通详情网络加载成功仍同步完整详情到 `MusicPlayService`；仅封面重新生成的即时响应关闭该同步，下一次详情网络刷新再更新播放器缓存。
- 封面重新生成成功继续按作品 ID 清理稳定图片缓存键并发送一次 `SongWorksRefreshRequested`，确保当前详情和作品列表使用新封面，不改变播放器音频缓存和其他歌曲操作。
- 后端接口、请求体、响应结构和数据库均不变。

### Verified

- Widget 回归覆盖播放器缓存首帧、网络请求挂起、网络结果替换、关闭后重新进入再次请求，以及普通详情结果同步播放器缓存。
- 封面回归覆盖当前详情、作品 Store、列表刷新更新且播放器详情缓存不被即时响应改写；既有稳定封面业务键失效后重新下载测试继续通过。

---

## v1.1.0-as-built 歌曲“生成同款”参数持久化与风格对齐 - 2026-08-04

> 关联变更：CHG-0056  
> 影响工程：`/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

### Added

- `catsinger_song_works` 新增非空 `creation_params_json`，新作品保存规范化请求快照；Flyway 从仍存在的关联任务回填存量作品，任务已清理的历史作品保留空对象。
- `GET /api/song-works/{id}` 新增可选 `creationParameters`，包含风格、场景、对象、纯音乐、人声、语言、时长和仍可复用的参考音频。

### Changed

- 播放器“生成同款”会等待完整详情，再通过路由 `extra` 进入专业模式；一次性回填歌名、歌词、风格、场景、对象、纯音乐、人声、语言、时长、可用原模型和参考音频。
- 创作快照存在时，风格只使用原始请求参数，不再与 Provider 产出的作品结果标签合并；历史空快照才从结构化“音乐风格”引导词和详情标签降级。
- App 等待动态配置后，将旧中文/英文标签确定性映射为当前启用选项的 `value`。`Mandopop`、`Romantic Ballad`、`Acoustic Pop` 对齐为 `流行、浪漫、慢板`，`Male/Female Vocal` 恢复人声参数而不占用风格，未知或禁用标签丢弃并合并提示一次；不调用 AI。
- 标签文本仅按逗号、顿号、分号和换行分隔，多词英文标签不再按空格拆分；纯音乐不复制歌词，普通专业入口仍允许手动自定义标签。
- 参考音频只向作品所有者返回；App 提交时优先使用 `assetId`，无素材 ID 才使用原 `submitUrl`，不会同时提交两种来源。
- 原地重新生成保留已有非空创作快照，避免通用重生成参数覆盖原作品；点击专业模式“生成歌曲”仍创建新作品，不修改来源歌曲。

### Verified

- Java 快照风格不混入结果标签、历史结构化引导词降级、完整详情参数、任务清理后恢复和公开作品参考音频隔离定向集成测试及完整 `./gradlew test` 通过。
- Flutter 截图英文标签映射、快照优先、多词解析、结构化引导词、纯音乐、旧接口、普通入口、模型回退和播放器同款入口共 9 项相关测试通过；目标文件静态分析无问题，全量 `flutter analyze` 无新增诊断，仅保留既有未使用私有方法警告。

---

## v1.1.0-as-built 翻唱作品重新生成参数恢复修复 - 2026-08-04

> 关联变更：CHG-0054  
> 影响工程：`/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

### Fixed

- 修复翻唱作品点击“重新生成”后被后端错误组装为 `custom / ADVANCED_SONG / ORIGINAL` 的问题；新任务现在保持 `cover / COVER_SONG / COVER` 和 `MUSIC_COVER_SONG_V1` 工作流。
- 从原成功任务和作品快照恢复翻唱源音频、音色、版权确认、保留原歌词/伴奏、移调、情感强度和混响设置；源音频继续执行 MiniMax 翻唱特征预处理，生成请求携带有效 `cover_feature_id`。
- 普通/纯音乐重新生成保留原作品类型，并复用原任务的参考音频和高级创作选项，不再把纯音乐错误降级为人声歌曲。
- Flutter 生成任务模型接收后端 `currentStep`；失败阶段文案较泛时按真实步骤映射，`GENERATE_SONG` 等音频步骤不再错误显示为“准备创作”失败。

### Changed

- 重新生成仍创建新的计费任务，但任务始终绑定并覆盖原 `workId`，不新增作品；提交后原作品切换为 `GENERATING`，成功更新原作品，失败恢复原任务和可播放内容。
- 后端接口、响应结构和数据库保持不变，仅修复重建请求参数及前端既有字段消费。

### Verified

- Java 集成回归覆盖翻唱原任务成功、重新生成任务参数/工作流恢复、同一作品更新、两次特征预处理及 MiniMax 特征 ID 入参。
- Flutter 回归覆盖 `currentStep=GENERATE_SONG` 且通用失败文案时，“生成音频”步骤标记失败、“准备创作”标记已完成。
- 后端 `./gradlew test` 全量通过；Flutter 详情重新生成 6 项定向用例与失败步骤用例通过，`flutter analyze` 无新增诊断（保留既有 `custom_toast.dart` 未使用私有方法警告）；两端 `git diff --check` 和流程工作区路径审计通过。

---

## v1.1.0-as-built 歌曲“重新生成”积分确认与加载反馈修复 - 2026-08-03

> 关联变更：CHG-0050  
> 影响工程：`/Users/soul/code/lxwx/catsinger`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

### Fixed

- 详情弹层、独立详情页和播放器 Controller 的“重新生成”统一在请求前展示积分确认框，按原作品 provider/model 精确读取当前启用模型价格，不再使用作品历史消耗。
- 详情或模型配置需要网络预加载时显示“正在获取积分信息...”，确认后提交期间显示阻断式“正在提交重新生成任务...”，并防止重复提交。
- 详情弹层成功时先关闭 Loading 和弹层，再用弹层外导航进入生成进度页，避免进度页被弹层遮挡或退场动画弹回。
- 修复后端把“重新生成”误走普通新建流程、额外插入占位作品的问题；重新生成任务现在直接关联原 `workId`，提交成功即把原作品关联到新 task 并切换为 `GENERATING/PENDING_REVIEW`，列表中始终只有原作品一条。

### Changed

- 模型配置缺失、停用或积分非正数时不提交；本地或服务端返回积分不足时复用会员权益弹框，其他异常展示接口原因并确保关闭 Loading。
- 取消积分确认不请求 `/api/song-works/{id}/regenerate`、不刷新列表；仅有有效 taskId 创建成功时才发送一次 `SongWorksRefreshRequested` 并导航。
- 重新生成成功后在原作品 ID 上更新音频、歌词和模型产物并切回 `SUCCEEDED`，收藏、专辑等作品关系保持；生成失败时恢复原任务关联与 `SUCCEEDED/APPROVED` 状态，保留原作品内容和可播放状态。
- 后端接口、请求体和响应结构不变；数据库无表结构或迁移改动，复用生成任务既有 `work_id` 字段。

### Verified

- 6 项新增 Widget 用例通过，覆盖当前模型价格、取消、挂起请求 Loading、防重入、成功导航/单次刷新、本地与服务端积分不足、模型缺失、普通失败和空 taskId。
- Java 回归覆盖提交后作品数不增加、原作品立即显示 `GENERATING` 并关联新 task、幂等重试、运行中防重复、成功原地更新并保留收藏，以及失败时恢复原任务关联和可播放状态。
- 作品详情弹层真实分辨率布局用例和歌词时间轴 API 回归通过；既有封面/播放器旧用例仍被仓库已有 `????` 占位断言与 Controller 注册基线阻断。
- V1981A Android 真机已验证作品详情弹层展示当前模型 20 积分确认框，点击关闭后正常返回详情且无提交 Loading；未点击“立即生成”，未扣除验收账户积分。

---

## v1.1.0-as-built iOS“哼歌成曲”麦克风授权修复 - 2026-08-03

> 关联变更：CHG-0049  
> 影响工程：`/Users/soul/code/lxwx/catsinger`

### Fixed

- iOS CocoaPods 为 `permission_handler_apple` 启用 `PERMISSION_MICROPHONE=1`，首次录音可真正触发系统麦克风授权框。
- 专业写歌与歌曲改编的“哼歌成曲”统一通过 `Access.microphone(context)` 处理权限，不再由歌曲改编入口直接调用录音插件并只显示 Toast。
- iOS 首次在系统弹框拒绝后，本次安静结束录音动作；再次点击时才显示“无法访问麦克风/去设置”，并明确提示 App 设置页及“设置 > 隐私与安全性 > 麦克风”备用路径。
- 保留永久拒绝后的设置引导，以及 Android、相册和媒体权限的原有行为。

### Verified

- 4 项 `Access` 麦克风权限测试、1 项歌曲改编入口级权限测试和 11 项既有媒体权限测试通过；iOS Simulator Debug 构建成功，CocoaPods 构建配置包含 `PERMISSION_MICROPHONE=1 PERMISSION_PHOTOS=1`。
- iOS 26.4 Simulator 实测通过首次系统授权、允许后自动录音、首次拒绝不连续弹设置、再次进入设置引导，以及权限重新开启后恢复录音并生成录音文件。
- `flutter analyze` 仅保留既有 `custom_toast.dart` 未使用方法告警，无新增诊断；`git diff --check` 和工作区路径守卫 `audit` 通过。

---

## v1.1.0-as-built “我的音乐”列表自动刷新 - 2026-08-03

> 关联变更：CHG-0045  
> 影响工程：`/Users/soul/code/lxwx/catsinger`

### Added

- 作品页可见、用户已登录且存在生成中作品时，每 1 分钟静默刷新一次；返回作品页时先立即同步一次。
- 灵感、专业、情景、AI 翻唱任务，以及播放器和作品详情重新生成任务创建成功后，统一发送既有 `SongWorksRefreshRequested`。
- 新增轮询生命周期、失败恢复、请求串行/单次补发和任务创建事件 Widget 回归测试。

### Changed

- 离开作品 Tab、退出登录、全部作品进入终态或 Controller 销毁时停止轮询。
- 定时、下拉和创建事件刷新统一串行执行，在途期间的重复触发合并为至多一次待刷新。
- 自动刷新失败保留当前作品与专辑，不切换整页 Loading、不弹错误 Toast，并等待下一轮恢复。

### Verified

- `dart format`、`flutter analyze` 和 App 工程 `git diff --check` 通过。
- 13 项定向 Widget 测试全部通过，覆盖轮询条件、终止条件、失败恢复、请求合并、所有任务创建入口及接口失败不发送事件。

---

## v1.1.0-as-built 个人页 Figma 对齐 - 2026-08-03

> 关联变更：CHG-0044  
> 视觉真源：Figma `81:559「个人」`（替代原节点 `67:90`）

### Added

- 新增从 Figma 导出的积分充值、积分明细 1x/2x/3x PNG 图标。
- 新增个人页积分入口路由、游客门禁、八项菜单顺序和三档手机尺寸 Widget 回归测试。
- 新增 `design-qa.md`，记录 `375x812` 同视口视觉比较和浏览器证据。

### Changed

- 个人页顶部头像、用户信息、积分/设置按钮、VIP 卡和菜单尺寸/间距对齐当前节点 `81:559`。
- 菜单顺序调整为积分充值、积分福利、订单列表、积分明细、邀请好友、联系客服、意见反馈、更多设置。
- “订单列表”复用已有图标和 `RouteName.paymentOrders`，并沿用隐私同意与登录门禁。
- 顶部积分余额和积分充值统一进入积分充值页；积分明细进入原积分详情页；积分福利保持进入任务中心。

### Verified

- `flutter analyze` 和 4 项个人页定向 Widget 测试通过，覆盖登录路由、游客门禁及 `375x812`、`390x844`、`414x896` 适配。
- Figma 真源与 Flutter 浏览器渲染实现在 `375x812` 同图比较，无 P0/P1/P2 差异，控制台无 warning/error。
- 完整 `flutter test` 已启动；既有 `????` 占位断言首先失败，随后产生与本次个人页无关的 `pumpAndSettle` 连锁超时，运行 5 分 13 秒后终止并作为仓库基线保留。

---

## v1.1.0-as-built - 2026-07-31

> 关联变更：CHG-0014
> 关联文档：`01-需求/v1.1.0-as-built/requirements.md`、`05-联调与测试/cases/v1.1.0-as-built/app-test-cases.md`

### Added

- 新增基于当前 Android `1.1.0 (110)` 和 Flutter 代码反推的实际交付需求。
- 新增首页、专业模式、生成进度、作品、我的 5 张当前真机截图。
- 新增当前 Flutter 代码测试基线和整 App 测试用例，覆盖三 Tab、歌曲创建、生成、作品、播放器、AI 翻唱、会员积分和 UI 适配。

### Changed

- 当前需求从旧四 Tab/五槽描述校准为“首页、作品、我的”三 Tab。
- 旧 v0.1.0/v1.1 PRD、旧代码基线和 223 条旧用例改为 `reference-only`。
- QA 当前入口切换到 `v1.1.0-as-built`。

### Known risks

- 首页“AI写歌”进入专业模式，“改编歌曲”进入歌曲改编模式。
- 场景写歌、灵感模式和首页 AI 翻唱没有当前主界面入口。
- AI 翻唱版权确认尚未参与第一步门禁，提交时仍固定发送 `true`。

---

## v1.1.0-as-built QA 自动化 - 2026-07-31

> 关联变更：CHG-0041  
> 测试工程：`/Users/soul/code/lxwx/test/catsinger`

### Added

- 新增 catsinger 独立 Python + ADB 测试工程，可由 PyCharm 直接打开并运行中文菜单。
- 新增 147 条 as-built 用例目录、ADB/UI Automator 封装、安全门禁、JSON/JUnit/HTML 报告、截图/UI XML/日志证据和音频边界夹具。
- 新增 Doctor、Interactive、Smoke 三套 PyCharm Run Configuration。

### Fixed

- 修正 `COVER-016` 测试用例缺失前置条件列，目录从 146 条恢复为 147 条。
- 作品 API 客户端兼容直接数组和常见分页结构。
- 完整生成闭环超时后不再误判成功；测试健康检查与业务请求头分离。

### Verified

- Python 框架 16 项单测通过，`compileall` 通过，147/147 目录校验通过。
- Android `1.1.0` 的 `APP-004` 和 10 条只读 UI 冒烟全部 PASS。
- 测试服务器基础健康为 UP；业务闭环因测试实例尚不支持 `X-App-Code: catsinger` 暂未执行。本地后端配置和正式环境均已确认支持。

---

## v1.1.0-as-built QA 自动化加速 - 2026-07-31

> 关联变更：CHG-0043  
> 测试工程：`/Users/soul/code/lxwx/test/catsinger`

### Added

- 新增 `balanced` 默认执行模式，整套冒烟复用 App 与登录会话；保留 `isolated` 逐用例冷启动排障模式。
- 新增控制台逐条结果、耗时、失败证据和最终中文汇总；新增持久化 `summary.txt` 报告。
- 新增会话复用、APP-004 强制冷启动、登录缓存和首页恢复失败回退的自动化单测。

### Changed

- 页面恢复优先使用底部导航和有限返回，失败时才冷启动；启动和页面等待改为条件轮询。
- UI 定位按当前 Flutter 代码校准为“专业模式 / 歌曲改编”，首页两个入口分别验证对应模式。

### Verified

- Android 真机 10 条只读 UI 冒烟 10/10 PASS，总耗时从 296.88 秒降至 63.96 秒，缩短约 78.5%。
- 每条用例均生成截图和 UI XML；HTML、JSON、JUnit、`summary.txt` 四类报告同时生成。
- Python 框架 22 项单测、`compileall` 和 147/147 用例目录校验通过；`isolated` 单用例抽查通过。

---

## v1.1-ai-cover - 2026-06-24

> 关联变更：CHG-0013  
> 关联文档：`01-需求/v1.1-ai-cover/requirements.md`、`02-技术方案/v1.1-ai-cover/tech-plan.md`

### Added

- [CHG-0013] 新增 AI 翻唱功能：Flutter App 首页 `AI翻唱` 入口、上传歌曲/选择音色/高级设置三步页、作品类型标签、播放器和作品详情“重新翻唱”入口。
- 后端新增 catsinger AI 翻唱链路：翻唱源音频上传校验、翻唱音色配置、`mode=cover` 任务创建、MiniMax `music-cover` 调用、资源持久化和默认 150 积分计费配置。
- Web/Admin 新增翻唱音色配置，支持名称、分组、标签、头像/图标、试听音频、提示词模板、启用状态和排序维护。

### Changed

- 作品管理在 catsinger 下支持按 `原创 / 翻唱 / 纯音乐` 筛选，并展示翻唱作品音色。
- 资源生命周期测试断言对齐当前默认 `LOCAL_RETENTION` 策略：本地保留资源状态为 `LOCAL_RETAINED`。

### Verified

- 后端 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`：`./gradlew test` 通过。
- Flutter App `/Users/soul/code/lxwx/catsinger`：`flutter analyze`、`flutter test` 通过。
- Web/Admin `/Users/soul/code/lxwx/lxwx_admin`：`flutter analyze` 通过。
- 三端均已执行 `git diff --check`，无空白错误。

---

## v0.1.0 - 2026-06-09

> 关联里程碑：需求分析  
> 关联需求清单：`01-需求/requirements-list.md`

### Added

- 初始化喵喵写歌项目流程工作区。
- 归档用户提供的 UI 参考截图。
- 生成需求分析阶段需求清单。
- [CHG-0001] 新增 Web/Admin 后台管理页面需求，支持切换 App 并查看对应 App 数据。
- [CHG-0002] 固化 App 名称、包名、默认模型、价格配置、运营素材配置、静态歌词、分享占位、专辑和后台可操作能力。

### Changed

- [CHG-0003] 收口 PRD 待确认项：MiniMax 配置按既有阿里云短信方案后置添加，歌曲示例由 Web/Admin 添加且无数据展示空态，后台增加超级管理员和角色管理块权限，歌词能力调整为 v1 接入逐句时间轴，同时将专辑高级能力和下载音质区分标记为后续扩展。
- [CHG-0004] 补强第三方音频生成结果自有存储方案：明确第三方 Provider 只作为生成源，后端必须对 `hex` 音频解码或对临时 URL 立即下载，校验后保存到自有资源目录/OSS；App、下载接口和后台资源查看只使用自有资源地址，资源保存失败时任务失败并退款。
- [CHG-0005] 补充第三方云存储适配方案：资源持久化可使用我们账号控制下的阿里云 OSS、腾讯 COS、七牛云或 S3 兼容存储，并通过 `ResourceStorageProvider` 适配；App 消费后端返回的自有公开/CDN/签名地址，不直接依赖云厂商私有地址。
- [CHG-0006] 收紧 AI 辅助开发工时评估：将工时主口径调整为强 AI 辅助压缩版，可演示版约 16-20 人天/1.5-2.5 周，可上线版净工时约 28.8 人天，建议预留 32-35 人天/3.5-4.5 周。
- [CHG-0007] 工时评估改为按功能排期：将 `effort-estimate.md` 主结构调整为写歌功能、情景写歌、生成链路、音频资源存储、播放功能、作品专辑、Web 后台配置等功能块，降低任务编号表的阅读权重。
- [CHG-0008] 写歌页灵感速递与入口切 Tab：App 首页/作品页普通“去写歌”入口改为直接切换底部写歌 Tab；写歌页简单模式改为参考图风格的“灵感创作 / 高级创作 + 音乐描述 + 灵感速递 + 纯音乐 + 开始创作”；后端新增 `GET /api/song-config/inspiration`，从当前 App schema 的 `app_configs` 读取 `song.inspiration.prompts`，配置缺失、空数组或非法 JSON 时返回内置兜底文案。
- [CHG-0009] 补充权益和积分实体字段注释：为 `UserMembershipEntity`、`PointAccountEntity`、`PointLedgerEntity` 补充字段 JavaDoc，说明权益、积分账户余额、冻结积分、流水批次、来源订单、过期和来源流水等语义；本轮不修改 SQL 迁移注释。
- [CHG-0010] 新产品文档与设计稿重整 PRD、技术方案和前端 UI 计划：归档 `/Users/soul/Documents/喵喵写歌` 新产品文档和首页/AI写歌/作品/我的设计稿，重写需求清单、PRD、Flutter 技术文档、Flutter 总体计划与主页面模块文档；同步 `tech-plan.md`，补齐图片写歌、AI帮写、参考音频、热门案例、分享、会员积分商品和生成进度字段；明确前端页面必须按新设计稿写 UI，适配按内层屏幕换算到 Flutter `375x812`。
- [CHG-0012] 项目工作区归档整理：旧 Sonus `.jpeg` 参考图移入 `archive/legacy-20260610/`，旧 `versions/` 兼容索引移入 `archive/reference-indexes/v1.0-design-mvp/`，返工前 Flutter App 旧模块计划移入 `archive/legacy-20260611-pre-rework/`；当前工作区保留 v1.0 主文档、`references/images/v1.0/` 最新设计稿和 `03-前端/开发计划/rework/` 当前执行文档。

### Removed

- （暂无）

### Rolled back

- （暂无）

---

## 路径恢复索引 - 2026-07-31

> 本区块不是新的产品版本；它将错误工作区别名 `catsinger` 的实现轨迹并入唯一正确工作区。原始变更日志位于 `archive/path-recovery-20260731/code-workspace-catsinger/change-log.md`，原始实现轨迹版本不会覆盖当前 App `v1.1.0`。

### Recovered

- [CHG-0015 / legacy-0001 / v0.2.0] 歌词时间轴重新生成与本地 AI 接入：done。
- [CHG-0016 / legacy-0002 / v0.2.1] 支付宝 Web/WAP 支付弹层与 App 外部唤起：in_progress。
- [CHG-0017 / legacy-0003 / v0.3.0] Web 后台商品管理：done。
- [CHG-0018 / legacy-0004 / v0.3.1] Web 后台商品价格分位显示修复：done。
- [CHG-0019 / legacy-0005 / v0.3.2] 支付方式入口与自动拉起支付中弹框：done。
- [CHG-0020 / legacy-0006 / v0.3.3] 商品默认数据入库与编码唯一性：done。
- [CHG-0021 / legacy-0007 / v0.3.4] 支付模块工程结构收口：done。
- [CHG-0022 / legacy-0008 / v0.3.5] Web 后台商品删除按钮：done。
- [CHG-0023 / legacy-0009 / v0.3.6] 测试环境商品改价与正式环境锁价：done。
- [CHG-0024 / legacy-0010 / v0.3.7] Android 混淆与多渠道重签打包：in_progress。
- [CHG-0025 / legacy-0011 / v0.3.8] 首页模块收口与旧首页业务删除：done。
- [CHG-0026 / legacy-0012 / v0.4.0] 首页歌曲列表独立编排：done。
- [CHG-0027 / legacy-0013 / v0.4.1] AI 模型提示词分层组装：done。
- [CHG-0028 / legacy-0014 / v0.4.2] 首页标签封面与歌曲二级页：done。
- [CHG-0029 / legacy-0015 / v0.4.3] AI 业务强类型引导词：done。
- [CHG-0030 / legacy-0016 / v0.4.4] 首页歌曲二级页返回与播放状态同步修复：done。
- [CHG-0031 / legacy-0017 / v0.4.5] 首页歌曲二级页新版对稿与自动播放：done。
- [CHG-0032 / legacy-0018 / v0.4.6] 音乐业务提示词最小收口：done。
- [CHG-0033 / legacy-0019 / v0.5.0] AI 音乐内容自动生产工具：waiting_review。
- [CHG-0034 / legacy-0020 / v0.6.0] 运营专用账号与每日冻结门禁：waiting_review。
- [CHG-0035 / legacy-0021 / v0.6.1] 音乐封面正向提示词禁用文字约束：done。
- [CHG-0036 / legacy-0022 / v0.6.2] 批量生产账号自动认证与用户 Token 续期：waiting_review。
- [CHG-0037 / legacy-0023 / v0.6.3] 音乐工厂正式联调与自动执行说明：done。
- [CHG-0038 / legacy-0024 / v0.6.4] 环境检查明确反馈与失败退出码：done。
- [CHG-0039 / legacy-0025 / v0.6.5] 媒体稳定缓存键与单请求加载：done；本次从原 workflow 和 Flutter 计划补齐正式记录。
- [CHG-0040 / legacy-0026 / v0.6.6] 资源服务收口：done；本次从原 workflow 和 Flutter 计划补齐正式记录。

### Recovery artifacts

- 原始快照与 SHA-256：`archive/path-recovery-20260731/`。
- 重名文档的补充实现轨迹：各业务目录下的 `recovered-engineering-track-20260731/`。
- 独有开发计划、QA 与构建说明已迁入对应主路径并使用新 CHG 编号。
