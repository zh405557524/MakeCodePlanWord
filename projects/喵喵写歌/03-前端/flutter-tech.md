# 喵喵写歌 V2.1 Flutter 与 Web/Admin 技术文档

## 2026-09-15 用户确认的音色卡片修复增量

本增量按用户确认计划直接实施。`SongVoiceProfile` 增加可空最新训练任务 ID、状态、阶段、进度和失败原因，旧响应仍可解析；资料状态不再作为训练失败事实。个人临时资料不进入选择列表。可用兼容卡片支持点击选中/再次取消，选中后波形按钮独立播放/暂停；仅可用个人音色显示删除确认，历史作品不删除。训练卡打开任务，失败卡通过明确重训按钮进入原音色资料流程；排队、等待朗读、提交待确认分别展示，后两者不可重训或删除。主页面有活动训练时每 5 秒刷新，后台暂停。

每次新建均为全新定制；训练任务创建前返回一律提示“继续定制 / 丢弃并退出”。确认后清理临时音色，失败仅按账号保存待清理 ID 并于下次登录/加载重试，补偿前读取详情保护已创建任务。已经进入训练的音色及重训所用原音色不因退出删除。歌曲和翻唱参数草稿保持原行为。验收记录见 [F004](开发计划/04-voice-train-and-clone.md)。

> 文档版本：`v2.1-model-driven-params` · CHG-0076 原文 `done` / CHG-0078 首页增量 `waiting_review` · 阶段 07 · 更新：2026-09-14
> 依据：[当前 PRD](../01-需求/requirements.md)、[技术方案](../02-技术方案/tech-plan.md)、[增量工时](../02-技术方案/effort-estimate.md)；CHG-0076 其余页面见[原快照](../01-需求/references/images/v2.1/model-driven-params/README.md)，CHG-0078 首页与新人礼见[新快照](../01-需求/references/images/v2.1/home-revision/README.md)及当前 Figma `xvrgwxfy`。第 04 步按用户决定跳过重复出稿。
> 实现边界：本文件是**增量技术设计**，不是三端已实现报告或编码授权。旧 CHG-0073 文档仅在[归档](../archive/CHG-0077-legacy-docs-20260913/README.md)供差异核对。

## 1. 技术路线与现状

| 工程 | 沿用的结构和依赖 | 已核对的入口 | 本版增量 |
|------|------------------|--------------|----------|
| 移动 App `/Users/soul/code/lxwx/catsinger` | Flutter、GetX、go_router、Dio、GetStorage、Hive、flutter_screenutil；`main.dart`/`Global.init()` 沿用 | `lib/pages/song_create/`、`song_cover/`、`song_voice_cover/`、`routes/` | 解析逐模型契约，处理置灰/切换/报价/载荷；不重建页面或状态框架 |
| Web/Admin `/Users/soul/code/lxwx/lxwx_admin` | Flutter Web；`lib/core/api_client.dart` → `lib/data/admin_repository.dart` → `lib/models/` → `lib/pages/` | `pages/common/ai_model_options_page.dart`、`pages/app/catsinger/song_config_page.dart` | 在现有模型/场景/计费页加只读厂家能力与合法收窄配置；不另建后台视觉体系 |

当前 `SongModelOption` 只解析模型 ID、价格版本及 `metadata`，**未解析**后端已有的 `musicContract`。`SongVoiceModelOption.capabilityLimits` 来自映射元数据，不能作为厂家硬能力。`SongGenerationOptions` 是 App 级运营选项，不等于选中模型实际支持。以上均为缺口，不标记为完成。

本版不新增 Flutter 状态、网络、持久化或播放器依赖。优先用现有 API/Model/Controller/Widget 分层，不在 View 中拼接口路径、解析原始 JSON 或写死厂家能力。Android/iOS 平台权限与上传插件沿用当前工程；若后续新增本地录音、视频提取能力，须另做原生权限对账，本版不假定它们已就绪。

## 2. 四个场景与公开接口

| 独立业务 | 场景码 | 模型选项读取 | 创建与查询 | 页面入口 |
|----------|--------|--------------|------------|----------|
| AI 写歌 | `song.generate` | `GET /api/ai-model-options?sceneCode=song.generate` | `POST /api/song-generations`、现有任务查询 | `SongCreateController`，简易/专业两种输入模式 |
| 歌曲改编 | `song.cover.generate` | `GET /api/ai-model-options?sceneCode=song.cover.generate` | `POST /api/song-covers`、现有任务查询 | `SongCoverController` |
| 本人音色训练 | `song.voice.train` | `GET /api/song-config/models?sceneCode=song.voice.train` | `POST /api/song-voice-training-tasks`、现有训练查询 | `SongVoiceTrainingController` |
| 翻唱声音克隆 | `song.voice.cover.generate` | `GET /api/song-config/models?sceneCode=song.voice.cover.generate` | `POST /api/song-voice-covers`、现有任务查询 | `SongVoiceCoverController` |

`/api/song-covers` 只表示旧歌曲改编，不承载声音克隆；克隆请求不传 `mode`，仍走独立接口。`GET /api/song-config/generation-options` 只提供全 App 标签/展示选项，必须再与选中模型的有效能力相交。现有 `X-App-Code: catsinger`、App 登录态与服务端返回包络维持不变；Web/Admin 使用独立后台 token 与 `/api/admin/**` 权限。

### 2.1 拟定的增量响应契约

在现有 `musicContract.operationType/status/parameters` 上**追加**下列可选字段，不重命名旧字段；`SongVoiceModelOption` 增加同语义 `musicContract`，保留旧 `capabilityLimits` 仅供旧客户端兼容：

| 字段 | 类型/含义 | 前端处理 |
|------|-----------|----------|
| `contractVersion` | 稳定的有效能力版本字符串，独立于 `pricingVersion` | 与当前模型草稿绑定；版本变化重新确认 |
| `effectiveParameters[]` | 每项含 `key`、`supported`、`editable`、`reasonCode`、可展示原因、`constraints`、`effectiveDefault` | 固定页面字段目录按 `key` 匹配；未知键不渲染为可编辑；缺项置灰 |
| `mediaConstraints` | 训练/源音频的格式、字节数、时长毫秒数、片段数硬限制；未声明上限为 `null` | 展示模型限制与平台上传限制的交集；不把 `null` 当“无限制” |
| 现有 `pricePoints/pricingVersion` | 后端计费目录得出的本次模型报价 | 缺价、过期或刷新失败不得提交；图上的金额只是布局示例 |

这是第 7/8 步的**目标 wire shape**，尚未在三端实现。Java 文档必须使用同一字段语义；正式 DTO 命名与响应包络以联调时现有 Controller/VO 为准。`parameters` 仍是厂家已声明的标准能力，不把后台最终展示状态偷换进去。公众响应不能包含厂家密钥、内部计费项或模型文件 URL。

## 3. Flutter Model、状态与数据流

### 3.1 模型边界

- 在 `lib/models/data/` 增加一个共享的强类型有效契约解析模型（建议 `SongEffectiveMusicContract` 和 `SongEffectiveParameter`），由 `SongModelOption` 与 `SongVoiceModelOption` 共同使用；不在两个业务里复制 JSON 解析逻辑。
- 解析旧响应、缺字段、未知枚举、无效数值时安全降级为 `NOT_DECLARED`，**不能**默认全部可用。`SUPPORTED` 也只允许 `effectiveParameters` 明确标记可编辑的设置；若服务端只返回旧 `parameters` 而无有效交集，新客户端可选项先置灰，避免误读后台收窄能力。
- 页面固定字段目录只管**顺序、标签、控件类型和互斥关系**，不内置模型支持项/范围/价格。标准键与 Java 保持一致；`generation-options` 的运营标签只可在有效枚举里显示。
- UI 派生状态建议为 `loading / ready / notDeclared / unsupported / error / repricing`，并区分模型级不可执行、字段级禁用、业务互斥和缺前置资源四种原因。

### 3.2 选模与草稿算法

1. 进入页面读取该业务场景的模型列表，选择当前默认或用户本次所选项；切换请求带递增序号，旧响应返回时不得覆盖新模型状态。
2. 以原草稿和新模型契约逐项比较：仍支持且在新范围内的值保留；不支持、越界或音色/素材不兼容的值**清空**并合并提示，不静默夹取到边界，也不自动填一个新默认。未被用户修改的默认值只用于控件占位，提交前按服务端规则计算。
3. 上传资源本身保留在资源库；若新模型不接受本次引用，只取消本次选择并提示，不删除用户资源。纯音乐开启时的歌词、人声仅保留页面草稿，提交载荷省略；关闭后可恢复草稿。纯音乐互斥与换模型清空是两条独立规则。
4. 模型或影响价格的设置变化后重取报价/价格版本，提交前检查契约版本和报价。若目前计费只按模型，则复用模型选项刷新；只有确认按设置差异计价，才与 Java 同步定义无副作用报价接口。
5. 创建请求只序列化业务必填字段、有效且用户已启用的可选字段，以及可选 `contractVersion`/现有 `pricingVersion`。不得发送置灰项的旧值、空的高级设置对象或浏览器/本地旧缓存参数。

提交按钮启用条件 = 基础输入满足 + 该场景模型可执行 + 所需资源/音色/权利状态合法 + 有效报价可确认 + 无正在提交。`NOT_DECLARED` 仅在服务端**另有证据**证明基础操作可执行时允许最小参数提交；否则禁用。网络失败、模型下架、能力解析失败或缺价一律禁用并保留草稿。

### 3.3 存储与生命周期

- 页面未提交草稿可沿用当前 Controller/GetStorage 习惯；如已有 Hive 草稿结构则沿用，不新建第二份相同草稿。**不持久化能力契约为长期真源**，回到前台或配置过期时重取。
- `modelOptionId` 只作用于本次任务，不改后台场景默认；`contractVersion` 与价格版本不可混用。
- 生成/训练任务退出页面后仍由现有 active 查询恢复；成功后仍走当前作品和播放器。不能把“API 返回成功”或“任务状态成功”当成音频可播放验收。

## 4. 页面与 Figma 对稿落点

| PRD / 当前画面 | 当前页面与增量交互 | 必须覆盖的状态 |
|----------------|--------------------|----------------|
| P01 首页 `151:7830/7973/8116` | CHG-0078 的轮播、三入口及新人礼详见第 8 节；现有三业务各走独立路由 | 海报加载/失效、静态目标、未登录/已领取、返回滚动位置 |
| P02 简易 `148:1287/1404` | 灵感、人声、纯音乐和模型选择读取有效契约；纯音乐让人声可见置灰 | 两模型差异、缺价、置灰点击原因、加载失败 |
| P03 专业 `148:1674/1934/2068/2205/7238` | 歌词/参考音频/系统人声与 `weirdness_constraint`、`style_weight`、`audio_weight` 分别按模型驱动；`148:2205` 指定音色仅作下版设计参考，本期入口关闭 | 互斥、长歌词、参考音频替换/删除、无指定音色入口、歌词草稿恢复 |
| P04 改编 `148:5350/5548/5750/5647` | 保留原歌词开关与歌词识别/新歌词策略保持独立；只显示该改编模型有效参数 | 识别中/失败、切模型清值、关闭保留后绝不暗用原词 |
| P05～P10 克隆/音色/训练 `148:129/381/3888/3965/432/7293` | 克隆主页复用现有 `song_voice_cover/` 布局；音色、训练素材、移调/音量按精确模型能力和兼容绑定判断 | 审核中/拒绝、音色未就绪、不兼容、硬媒体限制、训练效果建议非硬门槛 |
| P11～P13 等待/作品/播放器 `148:5115`、`146:7543` 与现有播放器 | 复用当前任务恢复、作品分类和 `SongPlayerPage`；重新翻唱仍回声音克隆 | 失败退款、历史作品、真实文件格式和可播放状态 |

375×812 为主验收，390×844/414×896 抽查；安全区、键盘、底部按钮/迷你播放器互不遮挡。动态金额、时长、容量、单位和提示文字要可换行；设计示例值不同不构成对稿失败。复用现有主题、图标和公共组件，未获授权不改 Figma 本身。

## 5. Web/Admin 技术设计

`AiModelOptionsPage` 继续承载 W02/W03 现有模型/场景映射操作，`SongConfigPage` 继续承载 Catsinger 配置；官方音色、任务和作品入口按现有页面归属做增量，不造平行 Admin。页面不直接访问 API，调用顺序固定为 `Widget → AdminRepository → ApiClient → /api/admin/**`。

| 管理视图 | 前端状态/动作 | 服务端约束 |
|----------|---------------|------------|
| W01 App/权限 | 切 App 前提示未保存草稿；切换后清理旧列表和编辑上下文，重新加载 | 服务端按 App 与管理块二次鉴权；403 不伪装为 401 |
| W02 模型能力 | 厂家硬能力只读，后台子集可编辑；`NOT_DECLARED`/越界行置灰并说明 | 保存时拒绝扩大厂家上限或开启未声明项；配置收缩须显示冲突 |
| W03 价格 | 价格、计费版本、模型默认与能力状态并列展示；缺价有明确空态 | 报价由现有计费目录计算，不能在浏览器本地计算冻结金额 |
| W04～W07 音色/任务/审核/作品 | 复用现有筛选、详情、审核、危险操作确认；按原创/改编/克隆分离 | 操作审计与实际 App/schema 隔离；不改旧 `COVER` 历史类型 |

现有 `AiSceneModelMapping.metadataJson` 是自由 JSON；前端可提供结构化子集表单，但不能把浏览器校验当成发布许可。保存时带能力版本，版本变化要求重新加载；保存失败保留草稿。后台暂无新设计稿，沿用密集表格/筛选/详情，桌面优先、窄屏可滚动，不做营销式卡片。Web 组件也考虑加载、空、失败、提交中、403 和配置冲突。

## 6. 项目专属规则与编码阶段

- **继承**工作台 Flutter 01～11：现有项目目录、Controller/View 分工、go_router、GetX、依赖基线、主题/适配、测试用例 ID、自动化证据；不重做初始化模板。
- **裁剪**：第 04 步 `figma-design-plan.md` 由用户明确跳过，用当前 Figma + PRD + 21 张快照替代；本次不新增多语言体系或新 Web 设计稿。通用规则里的示例依赖版本与页面结构不得覆盖三个实际工程。
- **特化**：三业务接口与 Controller 严格分开；所有可选参数由具体 `provider/model + operation` 的有效契约决定；厂家未知不自动开放；置灰行保留点击提示；动态数字不用 Figma 示例做校验；音色精确兼容、不推定同厂全兼容。
- **导航**：继续使用 `lib/routes/name.dart`/`router.dart` 已有路由，路由 `extra` 只传必要业务草稿或作品 ID，不在页面跳转中切换任务业务类型。
- **编码前门禁**：先完成 CHG-0078 第 9/11 步增量总体与模块计划并对齐 Java 契约。`implementationMode=skeleton_first`、`skeletonTargets=flutter,java,web`；原 CHG-0076 骨架 `skeleton_coding` 进度保留，CHG-0078 新模块未启动。骨架只连已确定的正式 API 路径和 local/test 固定响应，生产功能入口关闭；整体骨架进入 `skeleton_review` 后必须等用户明确确认，普通“继续”不解锁真实实现。
- **真实实现顺序**：共享 Model/解析 → 各业务 Controller 与序列化 → 页面置灰/提示/报价 → Admin 合法收窄 → Android/iOS 与后台联调。任何跨端 wire shape 变化先同步本版 Java 技术与模块文档。

## 7. 增量任务与验证

| 任务 | 实施落点 | 验证重点 |
|------|----------|----------|
| T-F001 | `models/data/song.dart`、`song_voice_cover.dart`，相关 API/Store | 旧响应缺字段、解析错误、两模型差异、无效值清空、竞态 |
| T-F002 | `pages/song_create/` | 简易/专业、纯音乐/歌词/音色/参考音频、高级设置置灰和请求载荷 |
| T-F003 | `pages/song_cover/` | 改编歌词策略、识别三态、独立业务创建 |
| T-F004 | `pages/song_voice_cover/` 及 `training/` | 音色兼容、训练素材和可选设置动态范围 |
| T-F005 | 现有等待、作品、播放器与路由 | 恢复、价格版本、实际音频播放、三种作品标签 |
| T-W001/002 | `ai_model_options_page.dart`、`song_config_page.dart`、Repository/Model | 切 App 不串草稿、能力只读/收窄、缺价/越权/保存冲突 |

文档评审只验证路径、接口名和与 Java 技术文档的一致性，**不宣称代码测试通过**。编码后每模块运行 `dart format`、`flutter analyze` 和相关 `flutter test`；Android/iOS 按用户操作走两模型切换、禁用提示、创建/失败/恢复。真实作品必须在目标设备上播放才算通过；iOS 优先真机，模拟器兜底，都没有则双平台测试不通过。Python 测试工程 `/Users/soul/code/lxwx/test/catsinger` 仅辅助执行有编号的现行用例，记录截图、日志、作品号与 PASS/FAIL/BLOCKED，不用脚本成功代替业务验收。Web/Admin 运行 `flutter analyze`、相关 Widget 测试与真实切 App/权限检查；两端用户测试和后台配置联调均属于后续第 15 步。

## 8. CHG-0078 首页、Web 配置与新人礼增量

### 8.1 页面落点与导航

仅增量修改当前 Flutter 工程 `lib/pages/home/`、`lib/pages/main/controller.dart`，以及相关 `lib/apis/`、`lib/models/data/`；沿用 GetX Controller、Dio 包络、现有路由与主题，不动三项业务创建 API。当前静态 `_HomePromoCard` 改为读取后台发布海报；热门案例继续独立加载，海报请求失败不能使整页失败。移动端首页按 Figma `151:7830/7973` 实现品牌区、轮播/指示器、AI 写歌通栏卡、改编歌曲和 AI 翻唱并排卡、案例、底栏。弹窗按 `151:8116` 覆盖首页；任务中心 `151:8281/8422` 只复用现有页面，不凭截图重建一套任务中心。

| 入口 | 现有业务目标 | 前端约束 |
|------|--------------|----------|
| AI 写歌 | `MainController` 现有写歌入口（简易/专业） | 进入页面不创建生成任务、不扣积分 |
| 改编歌曲 | `MainController.openCover` / 原改编 Controller | 保持 `song.cover.generate`，不跳声音克隆 |
| AI 翻唱 | `MainController.openVoiceCover` / `RouteName.songVoiceCover` | 保持独立的翻唱声音克隆业务 |
| 运营海报 | 后端 `targetCode` 到**已有路由**的白名单映射 | `null`、未知、已下线或本地构建未开放的目标保持静态；不解释任意路由/URL |

页面状态：海报 `loading / ready / fallback`；图片加载失败使用不可点击占位并允许下次刷新；轮播长度动态、单张不滚动且指示器同步。初始两张由后台发布，不在 Flutter 写死内容或数量；页面返回保持滚动位置。375×812 主基准，390×844/414×896 抽查横排卡文案、弹窗、安全区、底部导航和长动态数字；使用已有 `flutter_screenutil`、主题及共享组件，金额/积分/任务奖励永远从对应响应读取，不以 Figma 示例数字作常量。

### 8.2 App API/模型契约（与 Java 第 9 节一致，尚未实现）

| API | 建议响应数据 / 请求 | UI 行为 |
|-----|---------------------|---------|
| `GET /api/song-config/home-banners` | `items: [{id, imageUrl, targetCode?}]`，已发布顺序 | 仅绘制已审核可展示海报；空/失败降级不可点击占位 |
| `GET /api/song-config/new-user-gift`（登录态） | `shouldShow, impressionToken?, imageUrl?, text?, targetCode?, configVersion?`；本次打开另传 `openId`（仅 `PER_OPEN` 频次使用） | 不符合资格/配置异常直接不弹；登录切换或返回前台重新查；不缓存永久资格 |
| `POST /api/song-config/new-user-gift/impressions` | `{impressionToken, openId?}`；仅弹窗实际渲染后发送 | 防并发，只确认本次显示，重复请求由服务端幂等 |
| `POST /api/song-config/new-user-gift/dismiss` | `{impressionToken}` | 「稍后领取」、系统返回或关闭时撤销本次曝光，关当前弹窗；不本地记为已领取 |
| `POST /api/song-config/new-user-gift/claim` | `{impressionToken}`；响应 `targetCode?`、领取态 | 点击防重复，成功后标记本次已领取并经白名单去原签到/任务页；失败提示可重试，不先行发积分 |

API 通过现有 Song API 层接入 `X-App-Code: catsinger` 与登录 token，View 不拼接 URL。`HomeBanner` 和 `NewUserGiftState` 强类型解析缺失/未知字段：未知目标一律不可跳；错误不伪造可领取结果。本地 `openId` 只表示一次 App 冷启动，会话中复用，**不是**跨设备身份标识；只有符合用户资格并真正展示时调用曝光确认。「稍后领取」不消耗资格，同次页面切换不立即反复弹出，下一次符合配置的触发再取服务端状态。领取成功后即使目标后来失效也不恢复领取资格。客态不请求需要用户身份的新人礼接口。

### 8.3 Web/Admin 视图与状态

在 `/Users/soul/code/lxwx/lxwx_admin` 的现有 `SongConfigPage` 内增量增加 W08 海报列表/编辑与 W09 新人权益配置，不造平行后台。仍按 `Widget → AdminRepository → ApiClient → /api/admin/song/**`；沿用 App 切换、后台 token、`song_config` 管理块和已有媒体审核/资源选择流程。当前代码无下述表单，文档为待实现契约。

| 模块 | 字段/动作 | 校验与反馈 |
|------|-----------|------------|
| W08 海报 | 稳定 ID、已审核图片资源、启用、顺序、可选目标；支持新增/删除/拖动排序/预览/保存 | 至少一张审核通过且可访问；删停最后一张、本 App 不支持目标或审核中图片均禁止发布；提交中锁定、冲突后保留草稿 |
| W09 注册积分 | 正整数金额、当前生效额和「仅以后新建账号生效」提示 | 初始 30；非法值不允许前端保存，读到旧非法配置显示告警/后端兜底值，不偷偷回写历史流水 |
| W09 弹窗 | 启停、已审核图与文案资源、目标（签到/任务白名单）、人群（会员/非会员）、频次（`ONCE/DAILY/PER_OPEN`）、只读上线资格起点 | 配置故障/无权限/素材未过审给明确失败态；预览动态数字占位，不参与收益计算；保存失败保留原草稿 |

Admin 接口分别为 `GET/PUT /api/admin/song/home-banners`、`/new-user-points`、`/new-user-gift`。切离 `catsinger` 时清空列表、选择和未保存草稿；403 必须显示无权而非重新登录提示；服务器再次做 App、权限、内容审核、配置版本/并发发布校验。通用配置入口即使绕过本表单也须受 Java 同一规则约束。后台输入只选资源 ID/白名单目标，不可粘贴任意远程图片 URL/自定义路由。无独立 Admin 设计稿，沿用现有列表/表单密度与错误样式。

### 8.4 双阶段任务和验证

| 任务 | 骨架 `-S`（local/test，生产隐藏） | 真实 `-R`（骨架整体获明确确认后） |
|------|---------------------------------|----------------------------------|
| T-F006 | 轮播/三入口/占位状态、正式 API 方法与集中固定响应调用链 | 消费已审核海报配置、目标白名单、异常刷新与跨尺寸截图 |
| T-F007 | 登录态弹窗/按钮状态、曝光/关闭/领取 API 调用与任务页导航骨架 | 服务端频次/幂等联调、重启/登录切换/失败恢复 |
| T-W003 | Catsinger 海报列表/表单及正式 Admin API 调用 | 审核资源、原子发布、目标/权限/多 App 联调 |
| T-W004 | 赠额/新人礼字段、表单状态和正式 Admin API 调用 | 历史/新账号对照、频次配置/权限/审计联调 |

第 9/11 步仍须生成各任务的详细增量总体/模块计划，旧 T-F001～005、T-W001/002 完成记录不被本增量重置。文档阶段仅核对接口和设计真源；编码后 Flutter/Web 分别 `flutter analyze` 与受影响 `flutter test`，Android/iOS 实机路径验证「稍后」再弹、「领取」不再弹、三业务入口不串。骨架阶段**不得**真实赠积分、持久化曝光或接真实上传审核；固定值只在受控 fixture，生产入口默认关闭，待整体 `skeleton_review` 明确确认后才做 `-R`。
