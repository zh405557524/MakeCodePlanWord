# catsinger 变更计划

## 进行中变更

### [CHG-0022] 批量生产账号自动认证与用户 Token 续期

- 版本号: v0.6.2（音乐工厂正式生产鉴权增强）
- 提出时间: 2026-07-21
- 类型: feature_modify
- 触发原因: 用户明确运营账号用于批量生产歌曲；现有 Python 只读取静态用户 JWT，而正式 Access Token 默认约 2 小时过期，长批次可能在提交或轮询过程中因 Token 失效中断。
- 影响范围:
  - 需求文档: 否；账号用途仍属于 CHG-0019/CHG-0020 已确认边界
  - 技术方案: 是；补充用户固定凭证登录、内存 Refresh Token 和 401 单次续期策略
  - Python 模块: 是；`config.py`、Catsinger HTTP 适配器、诊断、私有环境配置模板、运行文档和测试
  - Java/Web Admin/Flutter/数据库迁移: 否；只复用现有 `/api/auth/sms/login` 与 `/api/auth/refresh`
- 最小改动清单:
  - 必要新增: 用户登录手机号/验证码与登录、刷新路径配置；适配器内存态 Access/Refresh Token；401 后单次安全续期
  - 对应修改: `src/music_factory/config.py`、`backends/catsinger.py`、`services/diagnostics.py`、`.env.example`、README/契约/运行手册、Catsinger 适配器测试和 QA 记录
  - 必要删除: 无
- 不应改动范围: 运营账号每日冻结策略、管理员鉴权、积分/计费、Provider 并发、批次状态机、Java 接口与任何真实密码日志
- 验收标准:
  1. 批量生成请求使用独立运营账号登录取得的用户 JWT，管理员 JWT 只用于标签与发布。
  2. 未配置静态用户 JWT 时，可通过私有手机号/验证码登录；Access/Refresh Token 只保存在进程内存。
  3. 用户接口返回 401 时优先 Refresh，失败后允许固定凭证重新登录并只重放原请求一次。
  4. 冻结账号、缺失凭证或续期失败时安全停止，不循环重试、不泄露凭证和 Token。
  5. 现有静态 Token 配置继续兼容，模拟后端和管理员鉴权行为不变。
  6. Ruff、格式、编译、pytest 与差异检查通过；真实账号解冻后再做单曲联调。
- 回滚说明: 删除新增登录配置和自动续期分支，恢复只读取静态用户 JWT；不涉及数据库或外部状态回滚。
- 自动化结果:
  - Catsinger 鉴权定向测试 20 项通过，覆盖首次登录、Refresh 续期、Refresh 失败回退登录、401 单次重放、缺失凭证和冻结错误脱敏。
  - `uv run pytest`：106 项通过。
  - `uv run ruff check .`、`uv run ruff format --check .`、`uv run python -m compileall -q src tests`：通过。
  - 本地 PostgreSQL 端口隔离为 5433，Alembic 已升级到 head，模拟 `doctor` 全部正常。
- 状态: waiting_review（实现与自动化完成；正式 Doctor、管理员 JWT、运营账号解冻和积分条件已就绪，等待真实单曲提交验证用户登录、Provider 生成与长批次续期）
- 关联恢复点: 15 联调与测试 QA / CHG-0022 运营账号真实单曲鉴权联调

### [CHG-0020] 运营专用账号与每日冻结门禁

- 版本号: v0.6.0（新增独立运营账号能力）
- 提出时间: 2026-07-20
- 类型: feature_add
- 触发原因: 用户要求新增一个区别于 App 审核账号的正式服运营账号；账号默认冻结，每天自动恢复冻结，只有后台管理员显式解冻后才能登录和继续使用。
- 影响范围:
  - Java 模块: 是；新增独立固定登录配置、账号生命周期、每日冻结任务和 Admin 查询/冻结接口
  - Web/Admin 模块: 是；用户管理页新增运营账号状态卡片与冻结/解冻操作
  - Flutter App: 否；继续复用现有短信登录接口和账号状态鉴权
  - 数据库: 无新表、字段或迁移；复用现有 `users`、`user_app_profiles`、积分账户和 refresh token 状态
- 最小改动清单:
  - Java: `AuthProperties`、`AuthService`、独立 `OperationsAccountService`、生命周期任务、Admin Controller/DTO/VO 和集成测试
  - Web/Admin: 独立模型、API Client、Repository、用户页卡片和测试；同时修复切换 App 后账号缓存未清理及旧请求回写风险
  - 私有正式配置: 只在 `.local/prod/config/runtime.env` 注入启用开关、手机号、固定验证码、AppCode 和每日冻结策略；源码、测试和文档不保存真实凭证
- 验收标准:
  1. 运营账号与审核账号使用不同配置、服务和 Admin 接口，运营账号不具备 Apple 审核沙盒白名单能力。
  2. 配置启用后账号以冻结状态创建；服务启动及每天 `Asia/Shanghai` 00:00 幂等恢复冻结。
  3. 冻结期间即使固定验证码正确也不能登录；后台解冻后可登录，下一次自动冻结后再次不可用。
  4. 冻结后现有 Access Token 在下一次请求立即失效，所有可用 Refresh Token 被撤销。
  5. Admin 只展示脱敏手机号，不返回或展示固定验证码；冻结/解冻要求填写原因。
  6. AppCode 不匹配、配置缺失或与审核账号冲突时安全失败，不创建或修改其他 App 用户。
  7. 切换 Admin App 时清理两类账号缓存，旧 App 延迟响应不得覆盖新 App 状态。
  8. Java 定向集成测试、Admin 静态检查/测试与两工程差异检查通过；既有基线问题单独记录。
- 回滚说明: 关闭正式环境的运营登录与每日冻结开关，回滚 Java/Admin 代码；现有运营用户记录保留为冻结普通用户，不需要数据库回滚。
- 实现与自动化结果:
  - Java 已完成独立运营账号服务、登录门禁、启动/每日冻结、Admin GET/PATCH、Token 失效和删除保护；无数据库迁移。
  - Java `compileJava`、`build -x test`、CHG-0020/审核账号/OpenAPI 定向测试与差异检查通过。
  - Java 全量共 470 项，45 项既有基线失败；CHG-0020 用例未失败，基线失败不在本变更内扩散修复。
  - Web/Admin 已完成独立模型、API、Repository、用户页卡片、原因确认和跨 App 缓存隔离；53 项测试、`flutter analyze`、Web 正式构建与差异检查通过。
  - 私有正式配置已准备，源码、测试、文档和接口响应均未记录真实手机号、固定验证码或 Token。
- 状态: waiting_review（正式 Admin 已解冻运营账号；等待首个真实用户请求验证成功登录，以及下一次每日重置冒烟）
- 关联恢复点: 15 联调与测试 QA / CHG-0020 正式部署与运营账号解冻冒烟


### [CHG-0019] AI 音乐内容自动生产工具

- 版本号: v0.5.0（新增独立内部工具模块）
- 提出时间: 2026-07-20
- 类型: feature_add
- 触发原因: 用户确认实施“Codex 采集、Codex 辅助调试、Python 持续生产”三链路方案，并进一步明确 Codex 完成榜单采集、首页业务标签规划、榜单歌曲分组和原创提示词；Python 只校验并执行明确方案，先创建缺失标签，整批生成完成后再绑定歌曲。
- 影响范围:
  - 需求文档: 是；更新 `01-需求/requirements-list.md` 与 `requirements.md` 的标签分组、方案输入和整批绑定语义
  - Figma 设计计划: 否；本轮只提供 CLI，不新增内部控制台页面
  - 技术方案: 是；增加可执行生产方案、标签前置准备、整批生成门禁、幂等绑定和兼容回退列表校验
  - 工时评估: 否；用户明确要求方案确认后连续编码，不因评估阶段暂停
  - Flutter 模块: 否；当前不修改 App
  - Java 模块: 否；本轮复用现有生成、标签、列表和首页条目接口，不修改既有用户计费行为；只有未来要求免积分或机器鉴权时另立变更
- 最小改动清单:
  - 必要新增: 严格 `ProductionPlanDocument`、业务标签/榜单成员引用契约、方案导入命令、标签准备状态与 Catsinger 标签/列表查询能力
  - 对应修改: Python 生产批次、调度器、Catsinger/模拟适配器、CLI、迁移、运行文档和测试；同步 `requirements-list.md`、`requirements.md`、`tech-plan.md`、QA、`workflow.md` 与 `change-plan.md`
  - 必要删除: 无
- 不应改动范围: Flutter App、现有公开 API、现有用户生成计费行为、MiniMax/OSS/审核 Provider、现有 AI 推理服务、榜单版权音频和歌词
- 验收标准:
  1. 输出整体实现方案、项目结构、模块划分、现有后台结合方式和分阶段开发步骤。
  2. 明确公开榜单的合规接入优先级和禁止下载版权内容的技术门禁。
  3. 盘点现有 Java 音乐生成、资源、作品、标签和首页编排能力，缺口只给最小接口优化建议。
  4. 数据采集、开发调试、生产执行相互解耦；平台并发未知时默认为 1。
  5. Python 进程重启或修复 Bug 后可续跑，且不会重复提交已成功/在途歌曲。
  6. Python 只执行 Codex 生成的显式歌曲方案，`styleTags`、首页 `tagCodes` 与显式 `home-list` 语义分离。
  7. 标签缺失时禁用创建；重复编码、非本批次禁用标签或显式列表在任何真实生成请求前停止。存量启用标签名称差异只记录警告并保留后台名称。
  8. 首歌完成不得提前绑定；整批生成完成且通过批次审核后才创建首页歌曲条目。
  9. 新标签先禁用创建，全部歌曲绑定后再启用；不调用显式首页列表 PUT 接口。
  10. 已有兼容回退歌曲允许保留并追加；公开结果允许 Java 过滤禁用/不可用作品，但必须保持最终 Admin 相对顺序且本批有可用歌曲可见，核验期间出现显式列表时暂停等待运营处理。
  11. 部分发布后的生成重试必须重新审核和公开核验；已有作品的绑定重试不重新生成/审核，但必须使旧激活与核验失效；未准备标签不能通过 resume/reconcile 启动，单批错误不阻塞其他批次。
- 回滚说明: 停止 Celery/CLI worker，对独立 music factory 数据库执行 Alembic downgrade 后移除独立 Python 工程；Flutter、Java、Web/Admin 无代码回滚项。
- 状态: waiting_review（Python 与自动化完成，等待真实 Catsinger/Provider 单曲联调）
- 关联恢复点: 15 联调与测试 QA / CHG-0019 真实 Catsinger 单曲联调
- 真实联调前置: `.env`、PostgreSQL、Redis、管理员 JWT、运营账号解冻和积分已就绪；保持 `maxInFlight=1` 执行单曲，由首个真实提交确认 MiniMax Provider/Model 配额
- 自动化结果:
  - `uv run pytest`：101 项通过
  - `uv run ruff check .`、`uv run ruff format --check .`、`uv run python -m compileall -q src tests`：通过
  - Alembic `upgrade/downgrade/check`：通过，无待生成迁移
  - 模拟业务标签端到端：`READY → PREPARING_TAGS → TAGS_READY → RUNNING → GENERATION_COMPLETE → WAITING_REVIEW → BINDING → COMPLETED`
  - 4 个业务标签/35 条榜单样本分析与 50 首显式原创生产方案通过严格 Schema、来源引用和版权隔离校验
  - 独立单曲联调方案 `2026-07-20-hot-song-smoke-v1` 已准备，固定 `maxInFlight=1`
  - Java、Web/Admin、Flutter 无本变更代码修改；运行不需要 `OPENAI_API_KEY`

### [CHG-0002] 支付宝 Web/WAP 支付弹层与 App 外部唤起

- 版本号: v0.2.1
- 提出时间: 2026-07-14
- 类型: feature_modify
- 触发原因: 用户反馈支付宝 Web 支付页点击后无法跳转支付宝，并确认适配复用 `/Users/soul/code/soul/clip-flutter` 的支付底部弹层且只直达支付宝。
- 影响范围:
  - 需求文档: 否；以用户确认计划为准
  - Figma 设计计划: 否；参考工程源码与当前效果截图已提供 UI 输入
  - 技术方案: 是；补充 Flutter 支付模块最小技术说明
  - 工时评估: 否；单模块 Bug 修复与交互适配
  - Flutter 模块: 是；支付 Web 模块、支付路由、第三方依赖、Android scheme 声明和测试
  - Java 模块: 否；沿用现有订单、支付参数和订单查询接口
- 最小改动清单:
  - 必要新增: `flutter_inappwebview`、`url_launcher` 依赖，支付底部路由过渡，隐藏 WebView/外部启动器测试注入点
  - 对应修改: `lib/pages/payment_web/` 的 View/Controller，`lib/routes/router.dart`、`lib/routes/transitions.dart`，Android Manifest 与支付测试
  - 生成文件: macOS、Windows Flutter 插件注册文件随依赖解析更新；本次业务验收仍以 Android 为准
  - 必要删除: 当前支付模块内可见全屏 WebView 和“我已完成支付”按钮；普通网页 WebView 保留
- 不应改动范围: 后端接口、数据库、Apple IAP、历史支付宝 App SDK、商品和订单协议、会员与积分页面视觉
- 验收标准:
  1. Android 创建 Web 支付订单后展示约 380.h 的支付底部弹层。
  2. 点击“确认支付”通过隐藏 WebView 捕获 `alipay/alipays` 并直接拉起支付宝，不再展示全屏 WAP 页。
  3. 无支付宝、拉起失败或超时均回到可重试状态并显示友好提示。
  4. 从支付宝返回后自动查询订单并沿用现有权益/积分刷新流程。
  5. `flutter analyze`、完整 `flutter test` 和 `git diff --check` 通过，真机支付单独验收。
- 回滚说明: 恢复 `paymentWebPay` 的 Cupertino 全屏路由和可见 `WebViewWidget`，移除新增依赖及 Android scheme 查询声明。
- 状态: in_progress（编码完成，等待 Android 真机验收与完整测试基线清理）
- 关联恢复点: 13 Flutter 编码 / 支付宝 Web/WAP 支付弹层与外部唤起
- 自动化结果:
  - `dart format`：通过
  - `flutter analyze`：通过
  - 支付、会员、积分充值及 Apple IAP 独立回归：通过
  - Android Debug APK 编译：通过
  - `git diff --check`：通过
  - 完整 `flutter test`：受既有歌曲播放器 `audioplayers` 持续帧影响，从首个歌曲路由用例开始级联超时；未将该结果记为通过

### [CHG-0010] Android 混淆与多渠道重签打包

- 版本号: v0.3.7（App 候选构建沿用 `1.0.1+104`）
- 提出时间: 2026-07-16 16:34
- 类型: feature_add
- 触发原因: 用户要求 Android 正式包启用混淆，并参考 `/Users/soul/code/soul/clip-flutter/script` 实现 office 基础 APK 的 arm64-v8a 多渠道重签打包；后续将渠道包命名收敛为 `catsinger_v<versionName>_<channel>_release.apk`。
- 影响范围:
  - 需求文档: 否；以用户确认的实施计划为准
  - Figma 设计计划: 否；无 UI 变更
  - 技术方案: 是；新增 Android 渠道标识、重签和符号归档说明
  - 工时评估: 否；独立构建工具与原生渠道读取改动
  - Flutter 模块: 是；友盟 Android 渠道解析改为读取具体分发渠道
  - Java 模块: 否；不修改服务端，版本更新接口继续只接收 `office` / `store`
- 最小改动清单:
  - 必要新增: Android APK 渠道读取器，`script/android_channels/` Python 工具与测试，`06-构建打包/build-plan.md`、`android.md`
  - 对应修改: `android/app/build.gradle.kts` release ABI 过滤，`AppUpdatePlugin.kt`、`MainApplication.kt`、`lib/utils/app_channel.dart`、`.gitignore`、渠道解析测试和工作空间流程文件
  - APK 命名: `catsinger_v1.0.1_<channel>_release.apk`，不再在文件名中重复 versionCode 与 ABI
  - 构建验证: office arm64-v8a release APK 使用 Dart obfuscation 与 split debug info；Python 生成并校验 office/huawei 候选渠道包
  - 必要删除: 无
- 不应改动范围: 后端接口、数据库、支付业务、iOS、现有 keystore 内容、`pgyer_upload.sh` 和用户未提交的 `lib/global.dart` 正式环境切换
- 验收标准:
  1. Flutter 只构建一次 `office` 的 `arm64-v8a` release APK，R8 与 Dart 混淆同时启用并保留符号文件。
  2. Python 通过 `META-INF/channel-<渠道>` 生成 office、huawei、xiaomi、oppo、vivo、honor、yyb、juliang、baidu 九个可配置渠道包。
  3. 渠道包完成 zipalign、V2/V3 重签、包名/版本/ABI/渠道标识/证书一致性和 SHA-256 校验，签名密码不进入日志或仓库。
  4. 友盟读取具体渠道；版本更新仍将 office 映射为 `office`、其他渠道映射为 `store`。
  5. `dart format`、`flutter analyze`、相关测试、Android release 构建和 `git diff --check` 通过；真机支付与渠道上报留作最终正式包门禁。
  6. 九个渠道 APK 使用 `catsinger_v1.0.1_<channel>_release.apk` 命名，清单与 SHA-256 文件同步引用新名称。
- 回滚说明: 删除渠道读取器与 `script/android_channels/`，恢复 AppUpdatePlugin/MainApplication/AppChannelResolver 的 `app_update_channel` 二分类读取；无需迁移数据或更换签名。
- 状态: in_progress（代码与 office/huawei candidate 已完成，等待 Android 真机 QA 后生成九渠道最终正式包）
- 关联恢复点: 15 联调与测试 QA / CHG-0010 Android candidate 真机验收
- 自动化结果:
  - Python `py_compile`、10 项标准库单元测试和 `--help`：通过
  - 已渠道化 APK 输入的失败清理/友好错误：通过，无 Traceback、未覆盖既有产物
  - `dart format`、`flutter analyze`、AppChannelResolver 3 项测试：通过
  - office release：`1.0.1+104`、仅 `arm64-v8a`、R8 与 Dart obfuscation 构建通过，Dart symbols 与 R8 mapping 已归档
  - 九渠道 candidate：统一使用 `catsinger_v1.0.1_<channel>_release.apk`；META-INF 渠道唯一、zipalign、V2/V3、证书一致性、包名/版本/ABI、清单文件名与 SHA-256 校验全部通过
  - `git diff --check`：通过
- 待验收: arm64 真机启动、一键登录、支付宝已安装/未安装、友盟具体渠道与版本更新 office/store 分组

## 本迭代历史变更

### [CHG-0024] 环境检查明确反馈与失败退出码

- 版本号: v0.6.4
- 提出时间: 2026-07-21 10:53
- 完成时间: 2026-07-21 10:59
- 类型: feature_modify
- 状态: done
- 完成内容: 新增 `db-upgrade` 封装命令，成功时明确输出已升级到 `head`，失败时仅输出脱敏异常类型和 PostgreSQL 配置建议；`doctor` 新增顶层 `ok`、中文 `summary`、`problems` 与 `warnings`，必要检查失败时以退出码 1 结束。
- 异常范围: 数据库、Redis、后端健康、首页控制面、运营用户认证和管理员 JWT；模拟后端、显式列表和未检查积分/Provider 配额作为不阻断警告。
- 验证结果: Ruff、格式、编译和 113 项 pytest 通过；本地 PostgreSQL `db-upgrade` 成功输出已验证；注入 Redis 故障时输出组件/建议并以退出码 1 结束。
- 影响边界: 修改 Python CLI/诊断、测试、README/运行手册和 QA 记录；未修改生产批次、调度、标签、Provider、计费、Java/Web/Admin/Flutter、私有 `.env` 或真实歌曲状态。
- 回滚说明: 移除 `db-upgrade` 和诊断汇总字段，恢复 README 原命令与工作流记录；无数据回滚。

### [CHG-0023] 音乐工厂正式联调与自动执行说明

- 版本号: v0.6.3
- 提出时间: 2026-07-21 10:20
- 完成时间: 2026-07-21 10:24
- 类型: feature_modify
- 状态: done
- 完成内容: 重新组织音乐工厂 README 的环境检查、首次正式单曲联调和持续/自动执行章节；增加 `doctor` 退出语义、通过判据、`batchId` 生命周期、PyCharm 参数对照、单批/全局 Worker、Celery 常驻和 `REVIEW_REQUIRED`/`AUTO` 边界。
- 验证结果: CLI 总帮助、Worker 参数和审核参数与 README 一致；未运行真实生成请求。
- 影响边界: 只修改 README 与项目工作流记录；未修改 Python、Java、Web/Admin、Flutter、数据库、私有 `.env` 或外部生产状态。
- 回滚说明: 恢复 README 运行章节并删除 CHG-0023 工作流记录；无数据回滚。

### [CHG-0021] 音乐封面正向提示词禁用文字约束

- 版本号: v0.6.1
- 提出时间: 2026-07-20 20:43
- 完成时间: 2026-07-20 20:52
- 类型: feature_modify
- 状态: done
- 完成内容: `MusicPromptBusiness` 将文字、伪文字、乱码、歌词、歌名、标题、字幕、字母、数字、Logo、水印、二维码、招牌、标签、编号和 UI 元素作为“必须严格遵守”的硬性约束合并到音乐封面最终正向 `prompt`，并要求不预留文字排版区域、只生成纯视觉画面。
- 调用边界: 保留现有 `negativePrompt`；未修改 `AIModelPromptService`、`AiModelCallService`、Zhipu/其他图片 Provider、thirdparty Command、App 调用、REST、数据库或任务结构。
- 验证结果: core 正向/负向提示词测试与真实 `AiModelCallService -> ImageGenerateCommand` 参数捕获测试通过，provider、model 和 `paramsJson` 保持原值；`build -x test` 与 `git diff --check` 通过。全量执行 471 项，剩余 44 项既有基线失败；本轮同步修正了 1 条与新行为冲突的封面旧断言，没有新增失败。
- 回滚说明: 恢复 `MusicPromptBusiness.buildCoverImagePrompt` 的原封面输出要求并删除本轮新增断言；无数据回滚。

### [CHG-0018] 音乐业务提示词最小收口

- 版本号: v0.4.6
- 提出时间: 2026-07-17 16:47
- 完成时间: 2026-07-17
- 类型: feature_modify
- 状态: done
- 完成内容: 在 `core/ai/aiprompt/domain` 新增通用上下文、业务类型、请求、目标、结果及不可变 `MusicPromptContext`；新增 `MusicPromptBusiness`，集中管理歌词、音乐、翻唱、歌名和图片封面七种音乐业务模板及 Provider/Model 适配。
- 调用边界: `AIModelPromptService` 只做通用 target/context 校验和业务分发；`AiModelCallService` 的强类型重载取得优化结果后统一委托原 String 方法创建 Command，不存在两套提示词模板逻辑。App 只将现有 Request、Task、Work 映射成 `AIModelPromptRequest<MusicPromptContext>`。
- 行为边界: 歌词和音乐正文继续使用 Command 独立字段；歌名生成只返回一个标题，重生要求不同；封面提示词明确为方形音乐海报并分离负向提示词；`music-cover` 既有限长规则归属 `MusicPromptBusiness`。provider、model、模式、音频引用、`paramsJson`、计费、任务状态和工作流不变。
- 验证结果: core 18 项、模型调用 10 项、Catsinger 集成 9 项定向测试通过；干净基线副本中全量 466 项仅保留已登记的 31 项积分基线失败，`build -x test` 通过；依赖扫描和 `git diff --check` 通过。当前主工作区全量构建仅受 CHG-0014 相关未完成 Admin 改动的两个既有编译错误阻塞，本轮源码已独立编译验证。
- 影响边界: 未修改 framework、thirdparty Command/Provider、REST、Entity、Repository、数据库、任务表或公开接口；无需数据迁移。
- 回滚说明: 恢复四个 App Service 的原字符串提示词方法，删除本轮 core 音乐上下文、业务和调用重载即可。

### [CHG-0017] 首页歌曲二级页新版对稿与自动播放

- 版本号: v0.4.5
- 提出时间: 2026-07-17
- 完成时间: 2026-07-17
- 类型: feature_modify
- 状态: done
- 根因: 首页歌曲行点击只执行配置歌曲播放器路由跳转，没有把标签歌曲写入 `MusicPlayService`，也没有调用 `playId`，因此播放器能展示详情但不会自动播放，且没有标签级上一首/下一首队列。
- 完成内容: 按 TalkToFigma `thx5vx4v` 最新 `首页2（32:247）` 校准二级页，使用 333 高曲线头图、无圆底返回键、16 号栏目标题、54×54 封面、70 点歌曲行节奏和正文红蓝光晕；歌曲行增加仅首页启用的紧凑模式，“我的作品”默认样式不变。
- 播放修复: 点击歌曲时按接口返回顺序构造完整 `MusicPlayTrack` 队列，强制选中当前歌曲，调用 `playId` 后再进入配置歌曲播放器；CHG-0016 会话同步继续负责播放器内当前歌曲与播放状态更新。
- 兼容性: 首页接口、路由地址、服务端编排、只读详情、作品所有者操作、Java、Web/Admin、数据库和原生层均未修改；CHG-0010 candidate 不变。
- 验证结果: 首页列表 Controller 3 项、Figma 关键尺寸/无底栏/只读菜单/自动播放队列 2 项、配置歌曲播放会话 1 项均通过；`dart analyze lib` 无问题，`flutter analyze` 仅保留既有重复 key 警告，差异检查通过。完整套件再次复现既有乱码断言与 `audioplayers` 级联超时，未作为本次新增失败。
- 回滚说明: 移除歌曲行紧凑参数和首页播放队列方法，恢复仅路由跳转；无需数据迁移。

### [CHG-0016] 首页歌曲二级页返回与播放状态同步修复

- 版本号: v0.4.4
- 提出时间: 2026-07-17
- 完成时间: 2026-07-17
- 类型: feature_modify
- 状态: done
- 根因: 配置歌曲模式在 `_syncPlaybackSong` 中提前返回，并始终优先使用初始 `configuredSongId`，导致全局当前歌曲变化后详情、活动 ID、进度和播放态未一起更新。
- 完成内容: SongHomeListPage 复用 SongWorkDetailPage 同款 `WorkDetailCircleButton + Icons.arrow_back_rounded`；配置歌曲播放器先保护用户刚点击歌曲不受无关旧会话覆盖，绑定自身播放会话后持续同步 `currentMusic/currentDetail`、活动 ID、进度、时长和播放状态；移除页面对 MusicPlayService 单监听器的重复占用，保留可释放 Worker。
- 兼容性: 路由地址、首页/歌曲接口、作品所有者操作、Java、Web/Admin、数据库和 Android/iOS 原生层均未修改；CHG-0010 candidate 不变。
- 验证结果: 返回按钮、配置歌曲切歌、普通作品切歌和首页列表 Controller 定向测试通过；`dart analyze lib` 无问题，`flutter analyze` 仅保留既有测试重复 key 警告，`git diff --check` 通过。
- 回滚说明: 恢复 SongHomeListPage 原 IconButton，并恢复配置模式提前返回和初始 ID 优先逻辑；无数据迁移。

### [CHG-0015] AI 业务强类型引导词

- 版本号: v0.4.3
- 提出时间: 2026-07-17 15:38
- 完成时间: 2026-07-17
- 类型: feature_modify
- 状态: done
- 完成内容: `core/ai/aiprompt` 新增 `AIModelBusinessPrompt`、`AIModelPromptTarget` 和公开 `AIModelPromptFragment`；`AIModelPromptService` 改为按原 Command、业务、厂商、模型固定顺序处理五类 Command，并校验业务目标类型。Catsinger 在 `app/catsinger/aiprompt` 按歌词、音乐、标题、封面定义四组类和八个嵌套业务 record，厂商/模型适配规则归属对应业务对象。
- 业务迁移: `AiModelCallService` 删除开发期 `promptCode` 重载并增加强类型业务对象重载；歌词辅助、歌曲工作流、标题重生和封面服务只构造业务对象。歌词原文、音乐歌词、模式、音频引用与 Provider 参数继续通过 Command 独立字段传递，未在 prompt 中重复。
- 共享输入: `CatsingerCreativePromptInput` 统一解析创建歌曲与歌词辅助的结构化 Map，规范空值、字符串、列表和重复值，并生成兼容任务表与接口字段的可读摘要；移除两个 Service 内重复的 Map 解析和值对象。
- 删除内容: 删除 `CatsingerAIModelPromptCodes`、`promptCode` 重载，以及歌词辅助、歌曲工作流、标题和封面 Service 内的模型提示词拼接方法；未引入责任链、Handler、Catalog、数据库或管理后台。
- 兼容性: REST 接口、任务表、数据库、计费、模型选择、Provider 与 thirdparty Command 字段不变；最早的原始 String 调用方法保持直接发送原 Command 的行为。
- 验证结果: 提示词、八个业务格式和模型调用定向测试，以及 3 项业务集成回归通过；`./gradlew build -x test` 通过。全量 460 项测试仍仅有已登记的 31 项积分基线失败，没有新增失败；`git diff --check` 通过。
- 回滚说明: 恢复 CHG-0013 的业务码常量、`promptCode` 重载和 Service 内字符串拼接；删除强类型业务提示词对象，无数据迁移。

### [CHG-0014] 首页标签封面与歌曲二级页

- 版本号: v0.4.2
- 提出时间: 2026-07-17
- 完成时间: 2026-07-17
- 类型: feature_modify
- 状态: done
- 完成内容: App 首页移除本地静态热门案例，改为按 `sortOrder` 展示公开首页标签双列卡片；点击进入独立 `/song/home-lists/:tagCode` 路由，二级页不展示底部导航，提供 Figma 曲线封面头图、返回、加载/空/失败/失效/刷新状态。
- 歌曲交互: 二级页保持服务端顺序和数量，复用“我的作品”封面、标题、“歌手名称”、AI 标识和三点按钮；点击进入配置歌曲播放器，三点菜单仅提供“查看详情”，详情弹层只读且不显示删除、重新生成或加入专辑等所有者操作。
- Admin 与后端: 标签增加封面预览、上传、替换和清空；Java 直接修改开发期 V2.6 增加可空 `cover_url`，新增 Admin 封面上传接口，并将标签封面纳入后台资源关联反查。公开列表优先返回标签封面，缺省时实时取编排后第一首有效公开歌曲封面，空列表或无有效封面返回空字符串。
- 兼容性: 旧 `home-modules` 路径、结构和 `displayMode` 不变；未修改 Android/iOS 原生层、支付/积分/订单、歌曲生成流程或 CHG-0010 candidate。
- 验证结果: App 生产代码分析、新增 Controller 3 项、歌曲配置 Store 9 项和首页/二级页 Widget 3 项通过；全量测试复现已登记的乱码断言与 `audioplayers` 级联失败。Web/Admin analyze 与 48 项全量测试通过。Java 定向/OpenAPI 测试和 `build -x test` 通过，全量 456 项仅保留既有 31 项积分基线失败；三工程 `git diff --check` 通过。
- 回滚说明: 恢复首页静态案例和旧配置加载，移除二级页/路由、只读参数和标签封面 UI/API/字段映射，并从尚未执行的开发期 V2.6 移除 `cover_url`；已执行旧 V2.6 的数据库必须单独处理字段和 Flyway 校验。
- 后续状态: CHG-0010 Android candidate 真机 QA 继续保持 `waiting_review`。

### [CHG-0013] AI 模型提示词分层组装

- 版本号: v0.4.1
- 提出时间: 2026-07-17 14:24
- 完成时间: 2026-07-17
- 类型: feature_add
- 状态: done
- 完成内容: 新增唯一提示词核心类 `AIModelPromptService`，以固定 `switch` 按通用、业务、厂商、模型顺序处理文本、图片、音乐、歌词和视频 Command；新增八个 Catsinger 业务码，并在歌词辅助、歌曲生成、翻唱、标题和封面调用中传入对应业务码。
- 兼容性: `AiModelCallService` 保留全部旧签名并增加带 `promptCode` 的重载；无业务码时返回原 Command，不追加提示词；仅重建对应提示词字段，厂商、模型、参数、歌词、标题和音频引用不变。
- 未引入内容: 无责任链、Handler、Catalog、数据库、管理后台、公开接口、Provider 或 thirdparty Command 结构变更。
- 验证结果: `AIModelPromptServiceTests`、`AiModelCallServiceTests`、`compileJava` 和 `build -x test` 通过；全量 453 项仍为已记录的 31 项积分基线失败，没有新增失败；`git diff --check` 通过。
- 回滚说明: 删除提示词业务码与测试，恢复 `AiModelCallService` 直接发送原 Command 的路径，并将业务调用恢复为无 `promptCode` 的旧重载；无数据迁移。

### [CHG-0012] 首页歌曲列表独立编排

- 版本号: v0.4.0
- 提出时间: 2026-07-17
- 完成时间: 2026-07-17
- 类型: feature_add
- 状态: done
- 完成内容: Web/Admin 模块标签移除展示模式管理并锁定已保存 tagCode；新增每标签唯一的首页列表编排、同标签候选选择、加入/移除、上下排序、1-100 展示数量、空列表保存，以及歌曲“全部 + 标签”筛选和新增默认标签。
- 后端与兼容: 新增 `catsinger_song_home_lists`、Admin/Public 首页列表接口和运行时回退；公开歌曲按编排过滤不可用作品后限量并补位；旧 `home-modules` 的路径、字段和 `displayMode` 保持不变，`items` 复用新列表结果。
- 数据库改动: catsinger Flyway `V2.6` 新增 `id/tag_code/display_count/item_codes_json/created_at/updated_at`，`tag_code` 唯一且展示数量限制 1-100；无外键、无回填、不修改存量数据。
- 关联保护: 显式列表中的歌曲不可直接删除或移除对应标签；保存时拒绝未知标签、重复歌曲、跨标签歌曲和非法展示数量；标签编码创建后不可修改。
- 验证结果: Web/Admin `flutter analyze` 和完整 46 项测试通过；Java 新增定向/OpenAPI 测试与 `build -x test` 通过，全量 443 项仅保留已记录的 31 项积分基线失败；两工程 `git diff --check` 通过。
- 回滚说明: 回滚 Web/Admin 编排 UI 和新接口代码，恢复旧标签聚合；新增表可暂留为空，不影响旧逻辑和存量数据。
- 后续联调: 本轮未修改 App；后续 App 接入新接口时按 `05-联调与测试/cases/song-home-list.md` 补客户端验收。CHG-0010 Android 真机 QA 继续保持 `waiting_review`。

### [CHG-0011] 首页模块收口与旧首页业务删除

- 版本号: v0.3.8
- 提出时间: 2026-07-17 11:00
- 完成时间: 2026-07-17
- 类型: feature_remove
- 状态: done
- 完成内容: 将当前实际使用的歌曲首页从 `lib/pages/song_home/` 迁移为 `lib/pages/home/`，页面层类名收口为 `HomePage`、`HomeController`、`HomePopularCase`；同步主 Tab、子流程路由导入、测试和工程目录索引，首页现有 UI 与歌曲配置行为不变。
- 删除内容: 删除旧视频解说首页及详情、HomeAPI、HomeCase/HomeCaseCategory 模型、`/home-cases/:id`、`RouteName.homeCaseDetail` 和废弃测试夹具；独立视频创建/作品入口继续保留。
- 兼容性: 保留 `SongHomeItem`、`SongHomeModule`、`/api/song-config/home-*`、`/song/scenario/:code`、`/song/cases/:id` 及后端协议，无数据迁移。
- 验证结果: `dart format`、生产代码 `dart analyze lib`、首页 Widget 3 项、歌曲配置 Store 9 项、遗留引用扫描和 `git diff --check` 通过；全工程 `flutter analyze` 仅有未改动测试数据的 1 个既有重复 key 警告。完整测试中本次首页用例通过，但旧 `????` 文案断言与 `audioplayers` 持续帧产生级联失败，运行至 74 项通过、160 项既有失败后停止。
- 回滚说明: 恢复旧首页页面/API/模型/路由与测试夹具，并将当前首页目录和页面层类名恢复为 `song_home`/`SongHome*`；无需回滚服务端或数据。

### [CHG-0009] 测试环境商品改价与正式环境锁价

- 版本号: v0.3.6
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: Web/Admin 为状态 `0` 且已入库的商品增加改价确认弹窗；后端通过 `PRODUCT_PRICE_EDIT_ENABLED` 控制能力，默认 `false`，测试环境显式开启。已上架商品必须先下架，正式环境 Web 操作为禁用态，直接调用更新接口也由 ProductService 拒绝。
- 兼容性: 新增商品仍可在所有环境填写价格；复用既有 `PUT /api/admin/products/{id}` 和 `immutableFields`，未新增接口字段，订单成交价快照与商品权益规则不变。
- 验证结果: Web `dart format`、`flutter analyze`、商品页 4 项、Repository 36 项、完整 `flutter test`（42 项）和差异检查通过；Java 两个商品环境定向测试类与 `./gradlew build -x test` 通过。Java 全量 421 项仍为已记录的 31 项积分基线失败，本次商品测试无失败。
- 回滚说明: 移除 Web 改价入口、Repository 方法和后端价格环境门禁，恢复原 publishedAt 不可变校验；无需回滚数据库。
- 数据/配置改动: 新增 `PRODUCT_PRICE_EDIT_ENABLED` 非敏感运行配置；测试环境设为 `true`，正式环境保持 `false`
- 数据库改动: 无

### [CHG-0008] Web 后台商品删除按钮

- 版本号: v0.3.5
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: 商品列表仅为状态 `0` 且 `persisted=true` 的商品显示红色“删除”；已上架商品和未入库 JSON 默认商品不显示删除。删除前展示不可恢复二次确认，确认后复用 `AdminRepository.deleteProduct` 和既有 DELETE 接口，成功刷新列表并提示，失败保留商品并展示后端业务错误。
- 未改动范围: 后端删除接口、订单/权益/积分占用限制、Repository 接口、数据模型、数据库结构、Flutter App 支付模块和 CHG-0007 文件。
- 验证结果: `dart format`、`flutter analyze`、商品页 3 项定向 Widget 测试、Web/Admin 完整 `flutter test`（40 项）和 `git diff --check` 均通过；覆盖删除可见性、取消、成功、JSON 默认商品及后端拒绝场景。
- 回滚说明: 移除商品操作列的删除按钮、确认方法和对应 Widget 测试；Repository 与后端无需回滚。
- 数据/配置改动: 无
- 数据库改动: 无

### [CHG-0007] 支付模块工程结构收口

- 版本号: v0.3.4
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: 将会员购买、积分充值、支付订单、支付处理中和支付专用组件统一迁入 `lib/pages/payment/`；新增 `PaymentFlowCoordinator` 统一三个 Controller 的 Web/SDK 支付调起、取消/失败反馈与最多 5 次订单轮询。
- 兼容性: 路由名称、URL、页面/Controller 类名、`PaymentOrder?` 返回契约、后端/API 和用户交互保持不变；积分余额/流水及会员权益模型仍留在原领域。
- 验证结果: `dart format`、`flutter analyze`、支付域 50 项定向测试、`git diff --check` 通过；完整 `flutter test` 已执行，仍从既有歌曲路由持续音频帧开始出现级联 `pumpAndSettle` 超时。
- 后续验收: 与 CHG-0002/CHG-0005 一并回到 Android 已安装/未安装支付宝真机回归，确认结构迁移未改变支付行为。
- 数据/配置改动: 无
- 数据库改动: 无

### [CHG-0005] 支付方式入口与自动拉起支付中弹框

- 版本号: v0.3.2
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: Android 积分充值和会员购买页新增支付宝、微信两行支付入口；微信点击仅提示暂未开通并保持支付宝选中。支付宝订单创建后直接进入阻塞式“支付处理中”弹框，自动加载一次 WAP form、拉起支付宝并在回前台后单次有界查单，移除了原订单、金额、渠道和“确认支付”二次确认 UI。
- 未改动范围: Java 后端、数据库、微信 H5 真实下单与 App 拉起、Apple IAP、历史支付宝 App SDK 和普通网页 WebView。
- 验证结果: `dart format`、`flutter analyze`、支付/会员/积分/订单相关定向测试（45 项）和 `git diff --check` 通过；完整 `flutter test` 已执行，但受既有歌曲播放器持续音频帧影响从首个歌曲路由用例开始级联超时，支付域在全新进程独立通过。
- 后续验收: Android 真机分别验证已安装与未安装支付宝；确认已安装时直接进入支付宝、未安装时关闭弹框并提示，且不会出现全屏 WAP 页。

### [CHG-0006] 商品默认数据入库与编码唯一性

- 版本号: v0.3.3
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: 在 ProductService 统一实现仅新增商品前的当前 App 空表检查与 products.json 全量入库；普通查询不写库，空表时只读展示 JSON，商品表非空时列表、详情和支付快照只读取数据库；新增和更新均校验 product_code，既有数据库唯一约束作为并发兜底；新增未传状态时默认未上架。
- 数据库改动: 仅有新增商品前的数据初始化行为，无表结构迁移；普通查询不写库，不覆盖、不补齐、不删除已有数据库商品。
- 未改动范围: 公开接口结构、支付/订单/权益/积分逻辑、Flutter、Web/Admin、CHG-0002、CHG-0005 及现有 products.json 内容。
- 验证结果: 商品定向集成测试通过，覆盖空表查询不落库、非空仅展示数据库、新增前初始化、新增/更新编码防重和 App 隔离；`./gradlew build -x test` 与 `git diff --check` 通过。全量 419 项仍有已记录的 31 项积分基线失败，本次新增测试无失败。
- 回滚说明: 恢复 ProductService 的 JSON 只读合并兜底和空实现 `ensureDefaultProducts`；无需回滚数据库结构。

### [CHG-0004] Web 后台商品价格分位显示修复

- 版本号: v0.3.1
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_modify
- 状态: done
- 完成内容: 将 Web/Admin 通用金额格式化的非整元显示从 1 位小数修正为 2 位小数，`1` 分显示为 `¥0.01`，`10` 分显示为 `¥0.10`，整元仍显示为 `¥68`。
- 未改动范围: 商品接口、商品页面布局、新增与上下架逻辑、Java 后端和 CHG-0002 状态。
- 验证结果: 金额格式化定向测试通过；`flutter analyze`、完整 `flutter test`（38 项）和 `git diff --check` 均通过。
- 后续验收: 刷新 Web/Admin 商品管理页，确认 1 分测试商品显示为 `¥0.01`。

### [CHG-0003] Web 后台商品管理

- 版本号: v0.3.0
- 提出时间: 2026-07-15
- 完成时间: 2026-07-15
- 类型: feature_add
- 状态: done
- 完成内容: 在交易与增长菜单增加商品管理页，支持名称/编码、类型和状态筛选；通过右侧抽屉新增积分或会员商品；新增请求在 Repository 层强制状态为 `0`；支持确认上架与下架并刷新列表。
- 未改动范围: App 前端、Java 后端接口与数据库、支付流程、会员/积分发放规则和 CHG-0002 验收状态。
- 验证结果: `dart format`、`flutter analyze`、Web/Admin 完整 `flutter test`、`git diff --check` 均通过；仓储测试验证新增状态强制为 `0`，页面测试覆盖新增、上架和下架。
- 后续验收: 可在已登录 Web/Admin 环境按实际 App 切换并确认商品数据与用户端展示。

### [CHG-0001] 歌词时间轴重新生成与本地 AI 接入

- 版本号: v0.2.0
- 提出时间: 2026-07-13
- 完成时间: 2026-07-13
- 类型: feature_add
- 状态: done
- 完成内容: 播放器入口、动态积分确认、状态刷新、作品级 Redis 锁、本地 FunASR 调用、traceId 透传和中文链路日志。
- 未改动范围: 公开接口、数据库、Python API、Docker 和其他 Provider。
- 验证结果: Flutter 静态检查与全部测试通过；Java 本功能定向测试通过；两个工程 `git diff --check` 通过；本机 Java 和 AI 健康检查均为 200。
- 后续验收: 重启 Java 服务加载本地私有配置后，从播放器使用真实歌曲手动验证。

## 影响文件清单

| 文件 | 影响来源 | 处理方式 |
|---|---|---|
| `/Users/soul/code/lxwx/catsinger/lib/pages/song_works/player/view.dart` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/song_works/player/controller.dart` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/store/song.dart` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/catsinger/test/widget_test.dart` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/catsinger/works/service/SongWorkService.java` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/thirdparty/aimodel/asr/channel/funasr/FunAsrHttpClient.java` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/thirdparty/aimodel/asr/channel/funasr/FunAsrModelProvider.java` | CHG-0001 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/config/application.yml` | CHG-0001 | 修改（Git 忽略） |
| Java/Flutter 相关测试文件 | CHG-0001 | 修改或新增 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/payment_web/` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/routes/router.dart` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/routes/transitions.dart` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/pubspec.yaml` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/android/app/src/main/AndroidManifest.xml` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/test/widget_test.dart` | CHG-0002 | 修改 |
| `/Users/soul/code/lxwx/catsinger/macos/Flutter/GeneratedPluginRegistrant.swift` | CHG-0002 | 依赖生成文件更新 |
| `/Users/soul/code/lxwx/catsinger/windows/flutter/generated_plugin_registrant.cc` | CHG-0002 | 依赖生成文件更新 |
| `/Users/soul/code/lxwx/catsinger/windows/flutter/generated_plugins.cmake` | CHG-0002 | 依赖生成文件更新 |
| `/Users/soul/code/lxwx/projects/catsinger/03-前端/` | CHG-0002 | 新增或修改最小支付计划 |
| `/Users/soul/code/lxwx/projects/catsinger/05-联调与测试/cases/payment-web.md` | CHG-0002 | 新增 |
| `/Users/soul/code/lxwx/catsinger/lib/widgets/app_payment_channel_option.dart` | CHG-0005 | 新增 |
| `/Users/soul/code/lxwx/catsinger/lib/widgets/index.dart` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/points/recharge/` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/membership/` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/payment_web/` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/routes/` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/catsinger/test/widget_test.dart` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/projects/catsinger/03-前端/` | CHG-0005 | 修改支付技术与开发计划 |
| `/Users/soul/code/lxwx/projects/catsinger/05-联调与测试/cases/payment-web.md` | CHG-0005 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/common/products_page.dart` | CHG-0003 | 新增 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/models/admin_models.dart` | CHG-0003 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/data/admin_repository.dart` | CHG-0003 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/shell_page.dart` | CHG-0003 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/test/products_page_test.dart` | CHG-0003 | 新增 |
| `/Users/soul/code/lxwx/lxwx_admin/test/admin_repository_test.dart` | CHG-0003 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/core/formatters.dart` | CHG-0004 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/test/formatters_test.dart` | CHG-0004 | 新增 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/product/service/ProductService.java` | CHG-0006 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/ServiceDataBootstrapRunner.java` | CHG-0006 | 修改职责注释 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ProductDefaultFallbackIntegrationTests.java` | CHG-0006 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ProductAdminRulesIntegrationTests.java` | CHG-0006 | 修改 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/payment/` | CHG-0007 | 新增并迁移支付领域页面与组件 |
| `/Users/soul/code/lxwx/catsinger/lib/services/payment_flow.dart` | CHG-0007 | 新增统一支付流程协调器 |
| `/Users/soul/code/lxwx/catsinger/lib/services/index.dart` | CHG-0007 | 修改公共服务导出 |
| `/Users/soul/code/lxwx/catsinger/lib/routes/index.dart` | CHG-0007 | 更新页面导入，路由契约不变 |
| `/Users/soul/code/lxwx/catsinger/test/widget_test.dart` | CHG-0007 | 更新导入并补充 Coordinator 测试 |
| `/Users/soul/code/lxwx/projects/catsinger/03-前端/` | CHG-0007 | 更新支付结构与开发计划 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/common/products_page.dart` | CHG-0008 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/test/products_page_test.dart` | CHG-0008 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/common/products_page.dart` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/data/admin_repository.dart` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/test/products_page_test.dart` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_admin/test/admin_repository_test.dart` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/product/service/ProductService.java` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/application.yml` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/resources/application-test.yml` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ProductAdminRulesIntegrationTests.java` | CHG-0009 | 修改 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ProductPriceEnvironmentIntegrationTests.java` | CHG-0009 | 新增 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/home/` | CHG-0011 | 由现用歌曲首页迁移并统一页面层类名 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/song_home/` | CHG-0011 | 迁移后删除 |
| `/Users/soul/code/lxwx/catsinger/lib/apis/home.dart`、`lib/models/data/home_case.dart` | CHG-0011 | 删除旧首页客户端 API 与模型 |
| `/Users/soul/code/lxwx/catsinger/lib/pages/main/`、`lib/routes/` | CHG-0011 | 更新首页调用方并删除旧详情路由 |
| `/Users/soul/code/lxwx/catsinger/test/widget_test.dart`、`.cursor/rules/02-项目结构目录.mdc` | CHG-0011 | 更新首页回归与目录索引，删除旧测试夹具 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/catsinger/config/`、`admin/song/` | CHG-0012 | 新增首页列表持久化、服务、DTO/VO 与 Admin/Public 接口 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/catsinger/V2.6__catsinger_song_home_lists.sql` | CHG-0012 | 新增首页列表配置表，不回填数据 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/` | CHG-0012 | 首页列表 Admin/Public、兼容与关联保护集成测试 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/core/api_client.dart`、`lib/data/admin_repository.dart`、`lib/models/admin_models.dart` | CHG-0012 | 首页列表接口、状态、模型与操作日志 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/app/catsinger/song_config_page.dart`、`test/` | CHG-0012 | 首页列表编排、标签筛选和 Widget/Repository 测试 |
| `/Users/soul/code/lxwx/projects/catsinger/03-前端/`、`04-后端/`、`05-联调与测试/` | CHG-0012 | 最小技术、开发与验收文档 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/core/ai/aiprompt/service/AIModelPromptService.java` | CHG-0013 | 完善五类 Command 的四层提示词组装 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/core/ai/aimodel/service/AiModelCallService.java` | CHG-0013 | 增加带业务码的兼容重载并在发送前处理提示词 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/catsinger/aiprompt/`、Catsinger 生成调用点 | CHG-0013 | 新增业务码并接入歌词、音乐、标题和封面调用 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AIModelPromptServiceTests.java`、`AiModelCallServiceTests.java` | CHG-0013 | 新增分层组装、字段边界和调用回归测试 |
| `/Users/soul/code/lxwx/projects/catsinger/04-后端/` | CHG-0013 | 更新 Java 技术说明、开发计划和模块计划 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/framework/security/AuthProperties.java`、`core/auth/service/AuthService.java` | CHG-0020 | 增加安全默认配置与独立固定凭证登录门禁 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/core/user/service/OperationsAccountService.java`、`OperationsAccountLifecycle.java` | CHG-0020 | 新增账号生命周期、启动/每日冻结与 Token 撤销 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/user/`、`src/test/java/com/lxwx/narrateservice/` | CHG-0020 | 新增 Admin 契约、删除保护和集成/OpenAPI 回归 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/core/api_client.dart`、`lib/data/admin_repository.dart`、`lib/models/admin_models.dart`、`lib/pages/common/users_page.dart` | CHG-0020 | 新增运营账号后台管理链路与跨 App 状态隔离 |
| `/Users/soul/code/lxwx/lxwx_admin/test/operations_account_test.dart`、相关 Repository 测试 | CHG-0020 | 新增模型、接口状态、页面交互与竞态回归 |
| `/Users/soul/code/lxwx/projects/catsinger/03-前端/`、`04-后端/`、`05-联调与测试/cases/operations-account.md` | CHG-0020 | 更新最小技术、模块计划与验收记录 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/core/ai/aiprompt/business/MusicPromptBusiness.java` | CHG-0021 | 将音乐封面禁用文字硬约束合并到实际正向 prompt |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AIModelPromptServiceTests.java`、`AiModelCallServiceTests.java` | CHG-0021 | 验证提示词结果与最终 ImageGenerateCommand 正向禁字约束 |

## 不应改动范围

- 除 CHG-0012 已确认的 catsinger 首页列表迁移与接口、CHG-0013 已确认的 Java 提示词组装外，不修改其他数据库迁移、公开接口结构、Python API 和 Docker 配置。
- CHG-0020 不修改 Flutter App、Apple 审核账号策略、用户积分规则、音乐审核流程或数据库结构；正式凭证不进入版本化文件。
- 不回退三个工程已有未提交修改。

## 完成记录

| 时间 | CHG-id | 操作 | 结果 |
|---|---|---|---|
| 2026-07-13 | CHG-0001 | 建立变更记录 | `in_progress` |
| 2026-07-13 | CHG-0001 | 完成代码、定向测试与本地健康检查 | `done` |
| 2026-07-14 | CHG-0002 | 登记支付弹层与支付宝外部唤起变更 | `in_progress` |
| 2026-07-14 | CHG-0002 | 完成 Flutter 编码、静态检查和支付域独立回归 | `waiting_review` |
| 2026-07-15 | CHG-0003 | 登记 Web 后台商品管理并确认与其他开发任务并行 | `in_progress` |
| 2026-07-15 | CHG-0003 | 完成商品页、默认未上架保护、上下架交互和完整 Web/Admin 验证 | `done` |
| 2026-07-15 | CHG-0004 | 登记商品价格分位显示缺陷并定位通用金额格式化根因 | `in_progress` |
| 2026-07-15 | CHG-0004 | 修正分位精度并通过定向、全量和静态验证 | `done` |
| 2026-07-15 | CHG-0005 | 完成支付方式入口、自动支付中弹框、支付域回归与流程回写 | `done` |
| 2026-07-15 | CHG-0006 | 登记商品空表 JSON 入库、数据库唯一展示和编码防重规则 | `in_progress` |
| 2026-07-15 | CHG-0006 | 完成 ProductService、集成测试、构建与差异检查 | `done` |
| 2026-07-15 | CHG-0007 | 登记支付模块工程结构收口并重新进入 Flutter 编码阶段 | `in_progress` |
| 2026-07-15 | CHG-0007 | 完成目录迁移、公共支付流程抽取、支付域 50 项回归与流程回写 | `done` |
| 2026-07-15 | CHG-0008 | 登记 Web 后台商品删除按钮与前端删除限制 | `in_progress` |
| 2026-07-15 | CHG-0008 | 完成删除入口、确认交互、失败反馈和 Web/Admin 40 项回归 | `done` |
| 2026-07-15 | CHG-0009 | 登记测试环境商品改价、正式环境后端锁价和前端禁用规则 | `in_progress` |
| 2026-07-15 | CHG-0009 | 完成前后端改价门禁、Web 交互、定向测试和完整回归 | `done` |
| 2026-07-17 | CHG-0011 | 登记首页模块收口与旧首页业务删除 | `in_progress` |
| 2026-07-17 | CHG-0011 | 完成目录迁移、旧链路清理、定向回归和流程归档 | `done` |
| 2026-07-17 | CHG-0012 | 首页歌曲列表独立编排、接口、数据库与 Web/Admin 自动化验收完成并归档 | `done` |
| 2026-07-17 | CHG-0013 | 完成五类提示词组装、兼容重载、Catsinger 调用接入、测试与流程归档 | `done` |
| 2026-07-20 | CHG-0020 | 登记独立运营账号、每日冻结与后台解冻门禁 | `in_progress` |
| 2026-07-20 | CHG-0020 | 完成 Java/Web Admin 实现、私有配置准备和自动化验证 | `done` |
| 2026-07-20 | CHG-0020 | 等待正式部署后验证默认冻结、后台解冻与真实登录鉴权 | `waiting_review` |
| 2026-07-20 | CHG-0021 | 完成封面正向禁字硬约束、最终 Command 回归、构建与差异检查 | `done` |
