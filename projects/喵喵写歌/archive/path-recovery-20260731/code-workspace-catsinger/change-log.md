# catsinger 研发变更日志

> 完成中的变更先记录在 `change-plan.md`；实现已完成但仍待外部联调的版本可预记，并明确标注 Pending。

## v0.6.4 - 2026-07-21

### Added

- [CHG-0024] 新增 `music-factory db-upgrade`，封装 Alembic `upgrade head` 并在成功时明确输出“数据库迁移成功”。
- [CHG-0024] `doctor` 新增顶层 `ok`、中文 `summary`、`problemCount/problems` 和 `warningCount/warnings`。

### Changed

- [CHG-0024] `doctor` 必要检查失败时以退出码 1 结束；PyCharm、Shell 和 CI 不再把子项失败误判为成功。
- [CHG-0024] 环境问题按数据库、Redis、后端健康、首页控制面、运营用户认证和管理员 JWT 分类，每项附脱敏处理建议。
- [CHG-0024] README 和运行手册默认使用 `db-upgrade → doctor`，并说明成功、失败和不阻断警告语义。

### Verification

- Ruff、格式、Python 编译和 113 项 pytest 通过。
- 本地 PostgreSQL 升级到 `head` 的成功反馈已验证；注入 Redis 连接失败时，`doctor` 输出问题/建议并返回退出码 1。
- 输出不包含数据库原始连接错误、用户凭证、JWT 或后端原始敏感响应。

## v0.6.3 - 2026-07-21

### Changed

- [CHG-0023] 补全音乐工厂 README 的环境检查、首次正式单曲联调和持续/自动执行说明。
- [CHG-0023] 明确 `doctor`、`prepare`、`start` 是一次性命令，单批 Worker、全局 Worker 和 Celery Worker + Beat 的运行边界各不相同。
- [CHG-0023] 增加 PyCharm `Script parameters` 对照、`batchId` 重复创建风险，以及 `REVIEW_REQUIRED` 人工审核和新 `planId` + `AUTO` 全自动发布约束。

### Verification

- `music-factory --help`、`worker --help` 和 `approve-publish --help` 与 README 命令、参数一致。
- 本变更只修改文档和工作流记录，没有发送真实生成请求，也没有修改任务、标签或私有配置。

## v0.6.2 - 2026-07-21（实现完成，待真实单曲联调）

### Changed

- [CHG-0022] 明确运营专用账号作为 AI 音乐工厂批量歌曲提交与查询的用户身份；管理员 JWT 继续只用于标签、首页条目和发布。
- [CHG-0022] Catsinger 适配器支持私有固定凭证自动登录、Access/Refresh Token 内存保存、401 后 Refresh、Refresh 失败回退登录以及原请求最多一次重放。
- [CHG-0022] 账号冻结、凭证缺失或续期失败时安全停止，不循环登录、不绕过每日冻结门禁，也不记录手机号、验证码或 Token。

### Verification

- Catsinger 鉴权定向 20 项和 Python 全量 106 项测试通过。
- `ruff check`、格式检查和 Python 编译检查通过。
- 本地 PostgreSQL/Redis、Alembic head 与模拟 Doctor 正常；未修改 Java、Web/Admin、Flutter 或业务数据库迁移。

### Pending

- 正式 Doctor、管理员 JWT、运营账号解冻和积分已就绪；保持 `maxInFlight=1` 完成一首真实生成、轮询、审核和标签绑定，并在首个真实提交时确认 Provider/Model 配额。

## v0.6.1 - 2026-07-20

### Changed

- [CHG-0021] 音乐封面最终正向 `prompt` 增加必须严格遵守的禁字约束，覆盖文字、伪文字、乱码、歌词、歌名、标题、字幕、字母、数字、Logo、水印、二维码、招牌、标签、编号和 UI 元素，并禁止预留文字排版区域。
- [CHG-0021] 保留原 `negativePrompt` 和模型调用链；未修改 Provider、thirdparty Command、App、REST、数据库或任务结构。

### Verification

- core 提示词与最终 `ImageGenerateCommand` 参数捕获 2 项回归通过，provider、model 和 `paramsJson` 保持原值。
- `build -x test` 与 `git diff --check` 通过；全量 471 项剩余 44 项既有基线失败，本轮修正 1 条冲突的封面旧断言，没有新增失败。

## v0.6.0 - 2026-07-20（实现完成，待正式发布冒烟）

### Added

- [CHG-0020] 新增独立运营账号配置、账号服务和登录门禁；固定凭证命中后仍必须通过数据库 `ACTIVE` 状态校验，不复用 App 审核账号策略。
- [CHG-0020] 新增启动就绪前冻结与 `Asia/Shanghai` 每日定时冻结；首次创建即为冻结状态，重复冻结保持幂等。
- [CHG-0020] 新增运营账号 Admin GET/PATCH 契约，支持查询脱敏状态、填写原因后冻结/解冻，并在冻结时撤销 Refresh Token。
- [CHG-0020] Web/Admin 用户页新增运营账号独立卡片、每日重置说明、冻结/解冻确认及跨 App 缓存隔离。

### Changed

- [CHG-0020] 运营账号冻结时同步用户与 App 资料状态；现有 JWT 请求继续复用 ACTIVE 校验，冻结后的 Access Token 在下一次请求被拒绝。
- [CHG-0020] 普通用户删除流程保护配置中的运营账号；运营账号继续使用普通积分、音乐生成和内容审核规则。
- [CHG-0020] 源码配置默认关闭且凭证为空；正式值只保存在私有运行配置，接口、日志、测试和版本化文档不返回或记录真实凭证。

### Verification

- Java `compileJava`、`build -x test`、CHG-0020/审核账号/OpenAPI 定向测试和 `git diff --check` 通过。
- Java 全量执行 470 项，45 项既有基线失败；CHG-0020 用例未失败，本变更未扩散修复无关基线。
- Web/Admin 53 项 `flutter test`、`flutter analyze`、`flutter build web` 和 `git diff --check` 通过。
- 未新增数据库表、字段或迁移；未修改 Flutter App、Apple 审核账号能力或用户积分规则。

### Pending

- 正式 Admin 已解冻运营账号；仍需通过首个真实用户请求确认成功登录，并完成下一次每日重置冒烟。冒烟通过前 CHG-0020 保持 `waiting_review`。

## v0.5.0 - 2026-07-20（Python 实现完成，待真实联调）

### Added

- [CHG-0019] 新增独立 Python AI 音乐内容工厂，支持不可变榜单采集包、业务标签分析、严格 `ProductionPlanDocument`、PostgreSQL 状态事实源、CLI/Celery 短调度和 Catsinger/模拟后端适配。
- [CHG-0019] 新增标签与显式列表全量预检、缺失标签禁用创建和幂等续跑；`styleTags`、首页 `tagCodes` 与显式 `home-list.itemCodes` 保持独立。
- [CHG-0019] 新增 Provider + Model 全局滑动窗口、整批生成屏障、批次审核、WORK 首页条目幂等绑定、新标签最终启用及公开首页歌曲反查。
- [CHG-0019] 形成 4 个业务标签/35 条榜单样本的标签分析，以及 50 首带稳定 `planSongId` 的显式原创生产方案。
- [CHG-0019] 增加独立 `2026-07-20-hot-song-smoke-v1` 单曲方案，用于以 `maxInFlight=1` 完成首次真实全链路联调，不启动 50 首正式批次。

### Changed

- [CHG-0019] Python 不再根据趋势临时推测真实生产标签或创作 prompt，只执行 Codex 已生成并严格校验的方案；榜单歌曲名、歌手和来源分组不会进入 Java 生成请求。
- [CHG-0019] 默认整批成功后才允许绑定；永久失败进入 `PARTIAL_FAILED`，只有显式 `--allow-partial` 才可发布成功部分。
- [CHG-0019] 存量启用标签按 `tagCode` 复用，名称差异只记录警告；非本批次禁用标签和持久化显式列表在产生音乐成本前阻断。
- [CHG-0019] 兼容回退旧歌允许保留并追加；公开歌曲按 Java 过滤规则校验为最终 Admin 有序 `itemCodes` 的有效子序列，本批无可见可用歌曲、相对顺序异常或核验期间出现显式列表时保存原因并暂停。

### Fixed

- [CHG-0019] 修复部分发布后重试生成可沿用旧审核/公开核验、部分激活后绑定重试可沿用旧公开快照、`resume/reconcile` 可绕过标签准备、`styleTags` 版权漏检、Schema 类型/ID 长度漂移及单批异常饿死其他批次的问题。

### Verification

- `uv run pytest` 101 项、Ruff、格式检查和 Python 编译检查通过。
- Alembic 独立 SQLite `upgrade head → check → downgrade base → upgrade head` 通过。
- 模拟端到端覆盖标签准备、受限并发、整批审核、绑定、启用与公开反查；Catsinger MockTransport 覆盖现有标签/列表/首页条目接口和不确定绑定响应恢复。
- 本轮未修改 Java、Web/Admin 或 Flutter；运行不依赖 `OPENAI_API_KEY`。

### Pending

- 等待创建真实联调 `.env`、接通 PostgreSQL，并配置有效 Catsinger 用户/Admin Token、足够测试积分和 MiniMax Provider/Model 配额；以 `maxInFlight=1` 完成一首真实联调后再关闭 CHG-0019 验收。

## v0.4.6 - 2026-07-17

### Added

- [CHG-0018] 新增通用 `AIModelPromptContext`、`AIModelPromptBusinessType`、`AIModelPromptRequest`、`AIModelPromptTarget`、`AIModelPromptResult`，以及只表达歌曲事实的不可变 `MusicPromptContext` 和七种 `MusicPromptBusinessType`。
- [CHG-0018] 新增 `MusicPromptBusiness`，统一管理歌词创建/优化、音乐生成/翻唱、歌名生成/重生和封面图片七种音乐业务模板及 Provider/Model 适配。
- [CHG-0018] `AiModelCallService` 增加文本、图片、音乐和歌词的结构化提示词请求重载。

### Changed

- [CHG-0018] `AIModelPromptService` 收口为通用 target/context 校验和业务分发；音乐业务内容全部委托 `MusicPromptBusiness`，不接触 thirdparty Command。
- [CHG-0018] `AiModelCallService` 强类型重载在模型调用前生成最终提示词，随后统一委托现有 String 方法；Command 创建仍只有一条路径。
- [CHG-0018] Catsinger 歌词辅助、歌曲工作流、歌名重生和封面生成只将现有数据映射为 `AIModelPromptRequest<MusicPromptContext>`；歌词、模式、音频引用、Provider 参数、计费、状态与存储流程保持不变。

### Verification

- core 18 项、模型调用 10 项和 Catsinger 集成 9 项定向测试通过。
- 在只包含本轮改动的干净基线副本中，`build -x test` 通过；全量 466 项仅保留已登记的 31 项积分基线失败，没有新增失败。
- 依赖扫描和 `git diff --check` 通过；未修改 framework、thirdparty Command/Provider、REST、Entity、Repository、数据库或任务结构。
- 当前主工作区标准构建仅受本轮开始前已有的 `uploadTagCover` 与 `getCoverUrl` 两个 Admin 编译缺口阻塞；本轮相关源码已完成独立编译和定向验证。

## v0.4.5 - 2026-07-17

### Changed

- [CHG-0017] `SongHomeListPage` 按 TalkToFigma 最新 `首页2（32:247）` 改为 333 高曲线头图、无圆底返回键、16 号栏目标题、54×54 封面、70 点歌曲行节奏和正文红蓝光晕。
- [CHG-0017] `SongWorkListTile` 增加默认关闭的首页紧凑样式；“我的作品”现有封面、AI 标记、间距和操作保持不变。
- [CHG-0017] 点击首页歌曲时按服务端顺序建立完整标签播放队列，选中当前歌曲并调用播放后进入配置歌曲播放器，上一首/下一首继续沿用该标签顺序。

### Fixed

- [CHG-0017] 修复首页歌曲列表只跳转播放器、不调用播放，导致详情已打开但歌曲不自动播放的问题。

### Verification

- 首页列表 Controller 3 项、Figma 关键尺寸/只读菜单/自动播放队列 2 项和配置歌曲播放会话 1 项通过。
- `dart analyze lib` 无问题；`flutter analyze` 仅保留既有测试重复 key 警告；`git diff --check` 通过。
- 完整套件再次复现已登记的旧乱码断言和 `audioplayers` 级联超时；未修改 Java、Web/Admin、数据库、原生层或 CHG-0010 candidate，Android 真机 QA 继续保持 `waiting_review`。

## v0.4.4 - 2026-07-17

### Changed

- [CHG-0016] SongHomeListPage 返回按钮改为复用 SongWorkDetailPage 同款圆形按钮和返回图标。
- [CHG-0016] 配置歌曲播放器绑定自身播放会话后，随当前播放歌曲同步详情、活动 ID、进度、时长和播放状态；无关旧播放会话不会覆盖刚点击歌曲。
- [CHG-0016] 播放器移除对 MusicPlayService 单监听器的重复占用，统一使用页面生命周期内可释放的 GetX Worker。

### Verification

- 首页返回按钮、配置歌曲切歌、普通作品切歌和首页列表 Controller 定向测试通过。
- `dart analyze lib` 无问题；`flutter analyze` 仅保留既有测试重复 key 警告；`git diff --check` 通过。
- 未修改 Java、Web/Admin、数据库、公开接口、原生层或 CHG-0010 candidate；Android 真机 QA 继续保持 `waiting_review`。

## v0.4.3 - 2026-07-17

### Added

- [CHG-0015] 新增 `AIModelBusinessPrompt`、`AIModelPromptTarget` 和公开 `AIModelPromptFragment`，以强类型业务对象表达五类 AI Command 的提示词输入。
- [CHG-0015] 新增 `CatsingerCreativePromptInput`，统一规范创建歌曲与歌词辅助的结构化输入并生成兼容任务表的可读摘要。
- [CHG-0015] 新增歌词、音乐、标题、封面四组业务提示词类及八个嵌套业务 record，业务、MiniMax、默认 Provider 和具体模型规则归属对应 record。
- [CHG-0015] 新增共享输入、八个业务格式、固定合并顺序、target 校验、字段保持和调用兼容测试。

### Changed

- [CHG-0015] `AIModelPromptService` 改为接收强类型业务对象，并固定按原 Command、业务、厂商、模型顺序合并；空对象原样返回，target 不匹配立即失败。
- [CHG-0015] `AiModelCallService` 使用强类型重载处理业务提示词；原始 String 方法继续直接发送调用方提供的提示词。
- [CHG-0015] 歌词辅助、歌曲工作流、标题重生和封面生成改为构造业务对象；歌词、音乐歌词、模式、音频引用与 Provider 参数保持独立 Command 字段传递。

### Removed

- [CHG-0015] 删除 `CatsingerAIModelPromptCodes`、开发期 `promptCode` 重载和业务 Service 内重复的模型提示词拼接方法。
- [CHG-0015] 删除 capability 通用提示词；所有新增规则均归属具体业务对象，未引入责任链、Handler、Catalog、数据库或管理后台。

### Verification

- 提示词、八个业务格式、模型调用和 3 项业务集成定向测试通过。
- `./gradlew build -x test` 通过；全量 460 项仍仅有已登记的 31 项积分基线失败，没有新增失败。
- `git diff --check` 通过；REST、任务表、数据库、计费、Provider 和 thirdparty Command 结构均未改变。

## v0.4.2 - 2026-07-17

### Added

- [CHG-0014] App 新增首页标签元数据模型、公开列表 API、独立 `/song/home-lists/:tagCode` 二级路由和加载/空/失败/标签失效/下拉刷新状态。
- [CHG-0014] Web/Admin 新增标签封面预览、上传、替换和清空；Java 新增 `POST /api/admin/song/home-tags/covers`。
- [CHG-0014] 增加 App 标签顺序/路由/歌曲顺序/无底栏/只读菜单、Admin 封面交互，以及 Java 封面优先级与回退测试。

### Changed

- [CHG-0014] 首页“热门案例”由本地静态图片改为 `/api/song-config/home-lists` 动态标签双列卡片；歌曲进入二级页后按标签加载。
- [CHG-0014] 二级页按 Figma 使用曲线封面头图和红蓝光晕，歌曲行复用“我的作品”视觉；三点菜单仅保留只读详情，所有者操作不展示。
- [CHG-0014] 开发期 Flyway V2.6 为 `catsinger_home_song_tags` 增加可空 `cover_url`；公开列表优先独立封面，否则实时回退到编排后第一首有效公开歌曲封面。
- [CHG-0014] 后台资源关联反查纳入标签 `cover_url`，已被标签使用的上传封面可被资源管理正确识别。

### Removed

- [CHG-0014] 移除首页本地静态热门案例数据；未删除旧 `home-modules` 接口、`display_mode` 字段或任何 Android/iOS 原生实现。

### Verification

- App 生产代码 `dart analyze lib`、Controller/Store/首页及二级页相关测试通过；全量测试仅复现已登记的乱码断言和 `audioplayers` 级联失败，全工程 analyze 仍只有既有重复 key 测试警告。
- Web/Admin `flutter analyze` 和完整 48 项测试通过。
- Java 新增定向/OpenAPI 测试及 `build -x test` 通过；全量 456 项仍仅有已登记的 31 项积分基线失败。
- 三工程 `git diff --check` 通过；CHG-0010 Android candidate 真机 QA 保持 `waiting_review`。

## v0.4.1 - 2026-07-17

### Added

- [CHG-0013] 新增 `AIModelPromptService`，统一处理文本、图片、音乐、歌词和视频 Command，并以私有 `PromptFragment` 表达各类提示词字段。
- [CHG-0013] 新增八个 Catsinger 提示词业务码，覆盖歌词辅助、歌曲生成、翻唱、标题生成/重生成和封面生成。
- [CHG-0013] 新增提示词分层、字段保持和模型调用回归测试。

### Changed

- [CHG-0013] `AiModelCallService` 增加带 `promptCode` 的兼容重载，在调用 thirdparty Service 前按通用、业务、厂商、模型固定顺序追加提示词。
- [CHG-0013] 歌词辅助、歌曲工作流、翻唱、标题和封面调用传入对应业务码；旧方法签名及无业务码行为保持不变。

### Removed

- [CHG-0013] 无删除项；未引入责任链、Handler、Catalog、数据库或管理后台。

### Verification

- `AIModelPromptServiceTests` 和 `AiModelCallServiceTests` 通过，覆盖空业务码、四层顺序、厂商/模型匹配和非提示词字段保持。
- `compileJava` 与 `build -x test` 通过；全量 453 项测试仅保留已记录的 31 项积分基线失败，没有新增失败。
- `git diff --check` 通过；未修改公开接口、数据库、Provider 和 thirdparty Command 结构。

## v0.4.0 - 2026-07-17

### Added

- [CHG-0012] 新增每标签唯一的首页歌曲列表编排、1-100 展示数量、有序 `itemCodes`、空列表保存和同标签候选选择。
- [CHG-0012] 新增 Admin 首页列表查询/覆盖接口和公开列表元数据/按标签歌曲接口；新增 catsinger Flyway `V2.6` 与 `catsinger_song_home_lists`。
- [CHG-0012] Web/Admin 新增首页列表配置弹窗、歌曲标签筛选、筛选标签下新增歌曲默认预选、演示数据和配置操作日志。

### Changed

- [CHG-0012] 模块标签不再展示或编辑展示模式，已保存 tagCode 不可修改；后端继续保留 `display_mode` 兼容字段。
- [CHG-0012] 未持久化列表按歌曲标签和原排序回退，默认场景模板 4 首、热门歌曲 10 首、其他标签 10 首；首次保存后完全使用显式顺序。
- [CHG-0012] 公开歌曲按列表顺序过滤禁用、不可播放或不可公开作品后限量，后续可用歌曲自动补位；旧 `home-modules` 保持响应结构和 `displayMode`，内容复用新列表。
- [CHG-0012] 列表引用的歌曲不可直接删除或移除对应标签，保存时校验标签、数量、重复歌曲和跨标签歌曲。

### Removed

- [CHG-0012] 移除 Web/Admin 模块标签的展示模式列与编辑控件；未删除数据库字段和旧公开接口。

### Verification

- Web/Admin `flutter analyze` 和完整 46 项测试通过。
- Java 新增定向测试、OpenAPI 路径检查和 `build -x test` 通过；全量 443 项仅保留既有 31 项积分基线失败。
- 两工程 `git diff --check` 通过；本轮未修改 App，CHG-0010 Android 真机 QA 状态保持 `waiting_review`。

## v0.3.8 - 2026-07-17

### Added

- [CHG-0011] 首页 Widget 回归改为断言当前真实中文文案，并覆盖配置为空时静态入口保留、歌曲首页配置加载且不提前请求作品列表。

### Changed

- [CHG-0011] 当前歌曲首页从 `lib/pages/song_home/` 迁移到 `lib/pages/home/`，页面层类名统一为 `HomePage`、`HomeController`、`HomePopularCase`；主 Tab 和歌曲子流程路由导入同步更新。
- [CHG-0011] 工程页面目录索引与 Flutter 开发计划同步采用新的首页目录口径。

### Removed

- [CHG-0011] 删除未使用的视频解说首页及详情、HomeAPI、HomeCase/HomeCaseCategory、`/home-cases/:id`、`RouteName.homeCaseDetail` 和对应测试夹具。

## v0.3.6 - 2026-07-15

### Added

- [CHG-0009] Web/Admin 为测试环境中已入库且未上架/已下架的商品增加改价弹窗、金额校验和成功反馈。
- [CHG-0009] 增加测试环境下架后改价、正式环境服务层拒绝、Web 禁用态和 Repository 请求回归测试。

### Changed

- [CHG-0009] ProductService 通过 `PRODUCT_PRICE_EDIT_ENABLED` 控制已有商品改价，默认关闭；测试环境显式开启，正式环境保持关闭。
- [CHG-0009] 商品响应沿用 `immutableFields` 告知 Web 价格是否可编辑；已上架商品在测试环境也必须先下架。

### Removed

（暂无）

## v0.3.5 - 2026-07-15

### Added

- [CHG-0008] 商品列表为已入库且未上架/已下架的商品增加红色“删除”操作和不可恢复二次确认。
- [CHG-0008] 增加删除按钮可见性、取消、成功、JSON 默认商品隐藏删除及后端业务拒绝的 Widget 回归测试。

### Changed

- [CHG-0008] 删除成功后刷新商品列表并提示“商品已删除”；删除失败时保留当前商品并直接展示后端业务错误。

### Removed

（暂无）

## v0.3.4 - 2026-07-15

### Added

- [CHG-0007] 增加 `PaymentFlowCoordinator`，支持可注入订单加载器、Web 支付启动器、轮询次数/间隔、状态文案和日志标签。
- [CHG-0007] 增加 Web 返回、SDK 成功/处理中、取消/失败、缺少订单号、终态提前结束和有界轮询回归测试。

### Changed

- [CHG-0007] 会员购买、积分充值、支付订单、支付处理中及支付专用组件统一归入 `lib/pages/payment/`；路由名称、URL、类名和返回契约保持不变。
- [CHG-0007] 会员、积分和订单 Controller 统一委托 Coordinator 执行支付与查单，领域成功处理仍由各 Controller 负责。

### Removed

- [CHG-0007] 移除旧页面目录、全局支付专用组件入口和三个 Controller 内重复的支付调起/订单轮询方法。

## v0.3.3 - 2026-07-15

### Added

- [CHG-0006] 增加商品空表查询不落库、新增前默认数据入库，以及新增、更新 `product_code` 防重回归测试。

### Changed

- [CHG-0006] ProductService 仅在新增商品前且当前 App 商品表为空时将 `products.json` 全量写入数据库；普通查询不写库，商品表非空时仅以数据库数据作为展示和支付快照来源。
- [CHG-0006] 新增商品未传状态时默认未上架；新增、更新均进行服务层编码防重，并沿用数据库 `(app_code, product_code)` 唯一约束兜底。

### Removed

- [CHG-0006] 移除数据库已有商品时对缺失 JSON 默认项的自动补齐展示。

## v0.3.2 - 2026-07-15

### Added

- [CHG-0005] Android 积分充值和会员购买页新增“微信支付 Web/WAP”占位入口，复用现有微信图标与支付选择样式；点击仅提示暂未开通并保持支付宝选中。
- [CHG-0005] 增加通用支付渠道选择行及支付自动拉起、失败退出、协议超时、回前台查单和订单终态测试。

### Changed

- [CHG-0005] 支付宝 Web/WAP 路由改为居中阻塞式“支付处理中”弹框，首次显示后自动加载一次 WAP form 并拉起支付宝，回前台后执行一次有界订单查询。
- [CHG-0005] 拉起失败、未安装支付宝、表单异常或协议捕获超时会关闭弹框并在来源页提示，不再进入全屏 WAP 页面。

### Removed

- [CHG-0005] 移除 Web 支付底部弹层中的订单、金额、渠道和“确认支付”二次确认 UI。

## v0.3.1 - 2026-07-15

### Added

- [CHG-0004] 增加 Web/Admin 金额格式化回归测试，覆盖 1 分、1 角、普通小数金额和整元金额。

### Changed

- [CHG-0004] 非整元金额统一保留两位小数，修复 `1` 分显示为 `¥0.0` 的精度丢失；整元金额继续不显示 `.00`。

### Removed

（暂无）

## v0.3.0 - 2026-07-15

### Added

- [CHG-0003] 在 Web/Admin 的“交易与增长”菜单增加商品管理页面，支持商品名称/编码、类型和上下架状态筛选。
- [CHG-0003] 增加积分商品与会员商品新增抽屉、字段校验、加载/空数据/失败/提交状态及操作结果反馈。
- [CHG-0003] 增加商品管理页面交互测试，覆盖新增、上架和下架；增加 Repository 测试验证新增请求状态固定为 `0`。

### Changed

- [CHG-0003] Web/Admin 商品 Repository 的新增入口统一强制未上架，避免调用方误传上架状态。
- [CHG-0003] 商品列表支持确认上架和下架，操作后重新请求 `/api/admin/products` 刷新状态。

### Removed

（暂无）

## v0.2.0 - 2026-07-13

### Added

- [CHG-0001] 在普通作品播放器“更多”菜单增加“重新生成歌词时间轴”，支持动态积分确认、加载态、防重复点击和生成结果即时刷新。
- [CHG-0001] Java 歌词时间轴重新生成链路接入本机 FunASR，并将 Java `traceId` 透传为 Python `X-Request-Id`。
- [CHG-0001] 增加应用、用户、作品维度的 15 分钟 Redis 锁，避免并发调用 AI 和重复扣费。
- [CHG-0001] 增加覆盖校验、计费、音频解析、AI 调用、结果保存、降级退款和锁释放的中文结构化日志。
- [CHG-0001] 增加 Flutter 交互测试以及 Java FunASR、日志、traceId 和并发锁测试。

### Changed

- [CHG-0001] 本地私有配置启用 `127.0.0.1:18080` FunASR 服务；Token 仅保存在 Git 忽略配置中。

### Removed

（暂无）
