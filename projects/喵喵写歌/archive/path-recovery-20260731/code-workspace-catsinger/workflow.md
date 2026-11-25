# catsinger 工作空间流程状态

> 用途：记录 catsinger 当前变更的实施状态和恢复点。

## 项目级配置

| 字段 | 当前值 |
|---|---|
| `currentProject` | `catsinger` |
| `currentVersion` | `v0.6.6`（资源缓存服务已收口，主线仍待真实单曲联调） |
| `frontendRepo` | `/Users/soul/code/lxwx/catsinger` |
| `adminRepo` | `/Users/soul/code/lxwx/lxwx_admin` |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| `aiServiceRepo` | `/Users/soul/code/lxwx/lxwx_ai_service` |
| `musicFactoryRepo` | `/Users/soul/code/lxwx/lxwx_music_factory` |

## 当前流程

| 字段 | 内容 |
|---|---|
| 当前阶段 | `15 联调与测试 QA` |
| 当前步骤 | `CHG-0019/0022 正式单曲全链路联调` |
| 当前步骤状态 | `waiting_review` |
| 当前恢复点 | `正式 Doctor 已验证 PostgreSQL、Redis、Catsinger、管理员 JWT 和首页控制面；运营账号已解冻且积分充足；CHG-0024 已增加 db-upgrade/doctor 明确成败反馈和失败退出码` |
| 下一步默认动作 | `按 README 使用 2026-07-20-hot-song-smoke-v1，保持 maxInFlight=1 创建并执行一个真实批次，验证用户自动登录、Provider 配额、生成轮询、审核和标签绑定` |

## 总体流程列表

| 序号 | 流程项 | 当前状态 | 说明 |
|---|---|---|---|
| 0 | 变更校准 | `done` | 已登记 CHG-0001 至 CHG-0026；CHG-0026 资源服务收口已完成 |
| 1 | 需求分析 | `done` | CHG-0019 三链路边界和受限并发方案已确认 |
| 2 | 需求文档生成 | `done` | 已同步业务标签分组、显式生产方案和整批绑定语义 |
| 5 | 技术方案计划 | `done` | 已同步标签准备、全批门禁和兼容回退集成契约 |
| 6 | 工作时长评估 | `skipped` | 用户明确要求直接实现，中间不因文档阶段暂停 |
| 13P | Python 内容工具编码 | `done` | CHG-0024 `db-upgrade` 和 Doctor 问题清单/失败退出码已完成；113 项自动化通过 |
| 13 | Flutter/Web Admin/Android 编码 | `done` | CHG-0026 Flutter 资源缓存服务收口与调用迁移已完成 |
| 14 | Java 编码 | `done` | CHG-0021 已增强音乐封面实际正向提示词禁用文字硬约束并补回归测试 |
| 15 | 联调与测试 QA | `waiting_review` | 正式控制面、解冻和积分条件已就绪；等待 CHG-0019/0022 真实单曲生成和 CHG-0020 成功登录/每日重置冒烟 |
| 16 | 构建与打包 | `pending` | 本轮只生成 Android candidate；支付真机 QA 关闭后重跑最终九渠道正式包，不做 Docker/后端构建 |

## 当前变更登记

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 |
|---|---|---|---|---|---|
| `CHG-0001` | 歌词时间轴重新生成与本地 AI 接入 | `feature_add` | `v0.2.0` | `done` | 13、14、15 |
| `CHG-0002` | 支付宝 Web/WAP 支付弹层与 App 外部唤起 | `feature_modify` | `v0.2.1` | `in_progress` | 13、15（编码完成，QA 待验收） |
| `CHG-0003` | Web 后台商品管理 | `feature_add` | `v0.3.0` | `done` | 13（与其他开发任务并行） |
| `CHG-0004` | Web 后台商品价格分位显示修复 | `feature_modify` | `v0.3.1` | `done` | 13（独立小修复） |
| `CHG-0005` | 支付方式入口与自动拉起支付中弹框 | `feature_modify` | `v0.3.2` | `done` | 13、15（编码完成，QA 待真机验收） |
| `CHG-0006` | 商品默认数据入库与编码唯一性 | `feature_modify` | `v0.3.3` | `done` | 14（与其他开发任务并行） |
| `CHG-0007` | 支付模块工程结构收口 | `feature_modify` | `v0.3.4` | `done` | 13、15（自动化完成，随支付链路回到 Android 真机验收） |
| `CHG-0008` | Web 后台商品删除按钮 | `feature_modify` | `v0.3.5` | `done` | 13（与 CHG-0007 并行） |
| `CHG-0009` | 测试环境商品改价与正式环境锁价 | `feature_modify` | `v0.3.6` | `done` | 13、14（独立开发任务） |
| `CHG-0010` | Android 混淆与多渠道重签打包 | `feature_add` | `v0.3.7` / App `1.0.1+104` | `in_progress` | 13 已完成；15 等待 candidate 真机验收；16 终包受 QA 门禁 |
| `CHG-0011` | 首页模块收口与旧首页业务删除 | `feature_remove` | `v0.3.8` | `done` | 13（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0012` | 首页歌曲列表独立编排 | `feature_add` | `v0.4.0` | `done` | 13、14、15（自动化验收完成；未修改 App） |
| `CHG-0013` | AI 模型提示词分层组装 | `feature_add` | `v0.4.1` | `done` | 14（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0014` | 首页标签封面与歌曲二级页 | `feature_modify` | `v0.4.2` | `done` | 13、14、15（自动化验收完成；不改变 CHG-0010 真机 QA 状态） |
| `CHG-0015` | AI 业务强类型引导词 | `feature_modify` | `v0.4.3` | `done` | 14（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0016` | 首页歌曲二级页返回与播放状态同步修复 | `feature_modify` | `v0.4.4` | `done` | 13（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0017` | 首页歌曲二级页新版对稿与自动播放 | `feature_modify` | `v0.4.5` | `done` | 13（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0018` | 音乐业务提示词最小收口 | `feature_modify` | `v0.4.6` | `done` | 14（与 CHG-0010 真机 QA 并行完成） |
| `CHG-0019` | AI 音乐内容自动生产工具 | `feature_add` | `v0.5.0` | `waiting_review` | 13P 与自动化完成；等待真实 Catsinger/Provider 单曲联调 |
| `CHG-0020` | 运营专用账号与每日冻结门禁 | `feature_add` | `v0.6.0` | `waiting_review` | Admin 已解冻；等待首个真实用户请求和下一次每日重置冒烟 |
| `CHG-0021` | 音乐封面正向提示词禁用文字约束 | `feature_modify` | `v0.6.1` | `done` | 14（独立小修复；待随正式发布生成新封面做效果验证） |
| `CHG-0022` | 批量生产账号自动认证与用户 Token 续期 | `feature_modify` | `v0.6.2` | `waiting_review` | 解冻和正式配置已就绪；等待真实单曲验证自动登录和 Provider 链路 |
| `CHG-0023` | 音乐工厂正式联调与自动执行说明 | `feature_modify` | `v0.6.3` | `done` | README 环境检查、单曲联调、PyCharm 参数和常驻/自动执行已补全 |
| `CHG-0024` | 环境检查明确反馈与失败退出码 | `feature_modify` | `v0.6.4` | `done` | `db-upgrade` 成败反馈、Doctor 总结/问题/建议和退出码已完成 |
| `CHG-0025` | 媒体稳定缓存键与单请求加载 | `feature_modify` | `v0.6.5` | `done` | Flutter 稳定业务键、音频/图片单请求、封面失效和定向回归完成 |
| `CHG-0026` | 资源服务收口 | `feature_modify` | `v0.6.6` | `done` | 删除 MediaCacheService，缓存、换签、图片解码和容量管理统一由 ResourceService 提供 |

## 当前步骤需加载规则

- `code-plan-workflow/SKILL.md`
- `00-核心工作流程.mdc`
- `14-Java编码索引.mdc`、后端工程 `00-编码工作流程.mdc`、`02-项目结构目录.mdc`、`03-编码规范.mdc`、`04-路由与控制器规则.mdc`、`05-数据库与持久化.mdc`、`07-新接口开发.mdc`、`09-大功能先规划再编码.mdc`
- `13-Flutter编码索引.mdc`、Web/Admin 工程 `02-项目结构目录.mdc`、`03-编码规范.mdc`、`04-后台管理UI规则.mdc`、`05-接口与鉴权规则.mdc`、`06-编码工作流程.mdc`
- 本轮 CHG-0013 实际加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`14-Java编码索引.mdc`、Java `02/03/04/10` 子规则与后端工程 `00/02/03/09/13` 规则
- 本轮 CHG-0014 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`13-Flutter编码索引.mdc`、`14-Java编码索引.mdc` 及三端项目级 UI、路由、接口、数据库、测试规则
- 本轮 CHG-0015 加载 `code-plan-workflow/SKILL.md`、工作台核心/Java 索引与后端工程 `00/02/03/04/09/10/13` 规则；未涉及新接口、鉴权或数据库迁移
- 本轮 CHG-0016 加载 `code-plan-workflow/SKILL.md`、工作台核心/Flutter 索引与 App 工程编码、结构、UI、导航、Bug 修复、逻辑修改和测试规则
- 本轮 CHG-0017 加载 `code-plan-workflow/SKILL.md`、工作台核心/Flutter 索引、Product Design 对稿规则与 App 工程编码、结构、UI、导航、Bug 修复、逻辑修改和测试规则
- 本轮 CHG-0018 加载 `code-plan-workflow/SKILL.md`、工作台核心/Java 索引与后端工程 `00/02/03/09/13` 规则；无接口、数据库、鉴权或 Provider 变更
- 本轮 CHG-0019 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`01-需求分析.mdc`、App `09-大功能先规划再编码.mdc`，以及后端 `AGENTS.md`、`00-编码工作流程.mdc`、`02-项目结构目录.mdc`、`09-大功能先规划再编码.mdc`；只读核对现有实现，未进入编码规则
- CHG-0019 实施轮加载 `02-需求文档生成.mdc`、`05-技术方案计划.mdc`，并在独立 Python 工程实现和验证；Java 工程只读接口契约，未修改源码
- 本轮 CHG-0020 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`13-Flutter编码索引.mdc`、`14-Java编码索引.mdc`、`15-联调与测试QA.mdc`，以及 Java/Web Admin 工程的编码、结构、接口、鉴权、安全与测试规则
- 本轮 CHG-0021 加载 `code-plan-workflow/SKILL.md`、工作台核心/Java 索引与后端工程编码、规范和 Bug 修复规则；未涉及接口、数据库、鉴权或 Provider 规则
- 本轮 CHG-0022 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`15-联调与测试QA.mdc` 和音乐工厂 `AGENTS.md`；只修改 Python 鉴权适配、私有配置模板、运行文档和测试，Java 只读核对登录/刷新契约
- 本轮 CHG-0023 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`15-联调与测试QA.mdc` 和音乐工厂 `AGENTS.md`；只修改 README 与工作流记录，通过 CLI `--help` 核对命令契约
- 本轮 CHG-0024 加载 `code-plan-workflow/SKILL.md`、`00-核心工作流程.mdc`、`15-联调与测试QA.mdc` 和音乐工厂 `AGENTS.md`；修改 Python CLI/诊断、测试和运行/QA 文档，不进入 Java/Flutter 规则
- 本轮 CHG-0025 加载 App `AGENTS.md`、`10-编码工作流程.mdc`、`03-编码规范.mdc`、`task-logic_change.mdc`、`task-bug_fix.mdc` 和 `11-测试规则.mdc`；只修改 Flutter 媒体缓存、播放、图片入口和测试
- 本轮 CHG-0026 加载 App `AGENTS.md`、`10-编码工作流程.mdc`、`03-编码规范.mdc`、`task-refactor.mdc` 和 `11-测试规则.mdc`；只修改 Flutter 资源服务、调用点、测试和前端开发记录

## 当前步骤依赖文件

- 用户确认的 CHG-0012 实施计划
- `/Users/soul/code/lxwx/projects/catsinger/03-前端/flutter-tech.md`
- `/Users/soul/code/lxwx/projects/catsinger/03-前端/flutter-dev-plan.md`
- `/Users/soul/code/lxwx/projects/catsinger/04-后端/java-tech.md`
- `/Users/soul/code/lxwx/projects/catsinger/04-后端/java-dev-plan.md`
- Java `app/catsinger/config/`、`admin/song/`、catsinger Flyway、service-data 与相关集成测试
- Web/Admin `lib/core/`、`lib/data/`、`lib/models/`、`lib/pages/app/catsinger/song_config_page.dart` 与相关测试
- CHG-0013 依赖 `04-后端/java-tech.md`、`java-dev-plan.md`、`开发计划/ai-model-prompt.md`、`AIModelPromptService`、`AiModelCallService`、thirdparty AI Command、Catsinger 歌词/生成/标题/封面调用点和相关测试
- CHG-0014 依赖用户确认实施计划、Figma `首页（32:122）`/`首页2（32:247）`、CHG-0012 首页列表接口、App 首页/场景/作品组件与三端相关测试
- CHG-0015 依赖用户确认实施计划、CHG-0013 提示词实现、`AIModelPromptService`、`AiModelCallService`、thirdparty AI Command、Catsinger 歌词/生成/标题/封面调用点及相关测试
- CHG-0016 依赖 CHG-0014 的 `pages/home/song_list`、`SongWorkDetailPage` 返回按钮样式、`SongPlayerController` 与 `MusicPlayService` 当前歌曲状态
- CHG-0017 依赖 TalkToFigma `thx5vx4v` 的 `首页2（32:247）`、CHG-0014 首页歌曲列表和 CHG-0016 配置歌曲播放器播放会话同步
- CHG-0018 依赖用户确认计划、`MusicPromptContext` 通用请求契约、`MusicPromptBusiness`、`AIModelPromptService`、现有 `AiModelCallService` 字符串方法及 Catsinger 歌词/音乐/歌名/封面调用点
- CHG-0019 依赖用户需求说明、现有 Java `generation/songworkflow/works/config/admin/song/core/resource` 实现、Catsinger Flyway、现有 `lxwx_ai_service` 工程边界，以及抖音/YouTube/Spotify 官方公开文档
- CHG-0020 依赖现有 `users`、`user_app_profiles`、积分账户、Refresh Token、JWT ACTIVE 校验、审核账号隔离模式、Admin 用户页和 App schema 路由
- CHG-0021 依赖 CHG-0018 的 `MusicPromptBusiness`、`AIModelPromptService`、`AiModelCallService` 图片结构化重载和 `ImageGenerateCommand` 参数边界
- CHG-0022 依赖 CHG-0019 Catsinger 适配器、CHG-0020 运营账号冻结门禁及现有 `/api/auth/sms/login`、`/api/auth/refresh` 契约
- CHG-0023 依赖 `/Users/soul/code/lxwx/lxwx_music_factory/README.md`、`src/music_factory/cli.py`、`celery_app.py`、`tasks.py` 和单曲方案 `2026-07-20-hot-song-smoke-v1`
- CHG-0024 依赖音乐工厂 `cli.py`、`services/diagnostics.py`、Alembic 配置、README/运行手册和 `cases/music-factory.md`
- CHG-0025 依赖 App `ResourceService`、`MusicPlayService`、`AudioPlayClient`、`AppCachedNetworkImage`、歌曲作品/首页标签/音色稳定 id 和现有缓存设置
- CHG-0026 依赖 CHG-0025 资源缓存实现、`ResourceService`、隐私受保护服务初始化和既有缓存持久化键
- `/Users/soul/code/lxwx/projects/catsinger/04-后端/开发计划/operations-account.md`
- `/Users/soul/code/lxwx/projects/catsinger/03-前端/开发计划/operations-account-admin.md`
- `/Users/soul/code/lxwx/projects/catsinger/05-联调与测试/cases/operations-account.md`

## 当前步骤生成文件

- `change-plan.md`、前后端技术与开发计划中的 CHG-0012 实施契约
- 首页列表 Flyway、Entity/Repository/Service/DTO/VO、Admin/Public 接口与集成测试
- Web/Admin 首页列表编排、标签筛选、模型/Repository/API Client、演示数据与测试
- `/Users/soul/code/lxwx/projects/catsinger/05-联调与测试/cases/song-home-list.md`
- CHG-0010 的渠道代码、工具和 candidate 产物保持不变
- CHG-0013 变更计划、Java 技术说明、`04-后端/开发计划/ai-model-prompt.md`、`AIModelPromptService`、Catsinger 业务码、调用重载/接入和测试
- CHG-0014 变更计划、前后端模块计划、标签封面字段/API、Admin 封面配置、App 标签首页/歌曲二级页与测试
- CHG-0015 变更计划、Java 技术/开发计划、核心强类型提示词契约、Catsinger 四组业务提示词与共享输入、调用迁移和测试
- CHG-0016 变更计划、Flutter 模块计划、返回按钮复用、配置歌曲播放状态同步和定向回归
- CHG-0017 变更计划、Flutter 模块计划、Figma 新版紧凑歌曲列表、标签播放队列自动播放和定向回归
- CHG-0018 通用提示词上下文契约、`MusicPromptBusiness`、通用分发服务、模型调用重载、四个 Catsinger 上下文映射及定向回归
- `/Users/soul/code/lxwx/projects/catsinger/01-需求/requirements-list.md`：CHG-0019 阶段一需求清单、整体方案、项目结构、模块划分、后台结合方式和开发步骤
- `/Users/soul/code/lxwx/projects/catsinger/01-需求/requirements.md`：CHG-0019 正式 PRD
- `/Users/soul/code/lxwx/projects/catsinger/02-技术方案/tech-plan.md`：Python 状态机、全局平台并发和 Java 契约
- `/Users/soul/code/lxwx/lxwx_music_factory`：独立 Python 工程、Alembic、CLI/Celery、适配器、文档、模板和测试
- `/Users/soul/code/lxwx/lxwx_music_factory/profiles/2026-07-20-market-trends-v1`：4 个业务标签及 35 条榜单样本聚合分析
- `/Users/soul/code/lxwx/lxwx_music_factory/plans/2026-07-20-market-trends-v1`：50 首显式原创歌曲生产方案与不可变清单
- `/Users/soul/code/lxwx/projects/catsinger/05-联调与测试/cases/music-factory.md`：自动化与模拟端到端 QA 记录
- Java 独立 `OperationsAccountService`、`OperationsAccountLifecycle`、认证门禁、Admin GET/PATCH、删除保护、配置和集成/OpenAPI 测试
- Web/Admin `BackendOperationsAccount`、API Client、Repository 状态、用户页运营账号卡片、原因确认、跨 App 隔离和 `operations_account_test.dart`
- CHG-0021 的音乐封面正向禁字硬约束、core 提示词回归和最终图片 Command 参数捕获回归
- CHG-0022 的运营用户自动登录/续期配置、Catsinger 内存 Token 与 401 单次重放、5 项鉴权回归、README/契约/运行手册和 QA 更新
- CHG-0023 重写后的 `/Users/soul/code/lxwx/lxwx_music_factory/README.md`：环境 Doctor、首次单曲、PyCharm、单批/全局 Worker、Celery 与 `AUTO` 发布命令
- CHG-0024 的 `db-upgrade` CLI、Doctor 顶层总结/问题/警告与退出码、7 项新增定向回归、README/运行手册及 QA 记录更新
- CHG-0025 的稳定媒体业务键、旧 URL 键兼容账本、音频/图片单请求加载、封面重新生成失效、定向测试和 `03-前端/开发计划/media-cache-stable-keys.md`
- CHG-0026 的统一 `ResourceService`、私有 `resource_cache.dart` 实现、全量调用点迁移、隐私初始化边界和定向测试
- `/Users/soul/code/lxwx/projects/catsinger/04-后端/开发计划/operations-account.md`、`03-前端/开发计划/operations-account-admin.md` 与 `05-联调与测试/cases/operations-account.md`

## 额外注意事项

- 保留 Java 与 Python 工程中已有未提交改动，不覆盖、不回退。
- 保留 Flutter 工程当前未提交的支付链路改动，仅在 CHG-0002 影响范围内增量修改。
- 日志正文与阶段名称使用中文；技术标识保留原值。
- 不记录完整歌词、绝对路径、完整 URL、Token 或原始请求响应体。
- 除 CHG-0012 已确认的首页列表接口与 `V2.6` 数据表外，不修改其他公开接口、数据库结构或 Python API。
- 不进行 Docker 构建。
- CHG-0025 不修改对象存储、后端接口、数据库或本地缓存容量选项；旧 URL 键文件不强制清空，继续由总容量 LRU 淘汰。
- 本次 UI 以参考工程支付页源码和用户提供的当前效果截图为依据，无需 Figma。
- 开发阶段内 CHG 条目是可并行任务，不因存在 `in_progress` 或 `waiting_review` 的其他开发任务阻塞新任务。
- CHG-0003 仅修改 Web/Admin 工程；商品 UI 沿用现有后台页面风格，无需单独 Figma 输入。
- CHG-0004 仅修正 Web/Admin 通用金额显示精度，不修改后端数据和商品页面布局。
- CHG-0006 不新增数据库迁移；仅在新增商品前且当前 App 商品表为空时导入 JSON，普通查询只读，数据库非空时不补齐、不覆盖、不删除。
- CHG-0005 的微信支付仅为占位入口，不创建微信订单、不发送微信渠道请求，也不实现 `weixin://` 拉起。
- CHG-0007 仅重构 Flutter 支付领域目录与公共流程；不修改 UI、路由地址、后端/API、数据配置或数据库。
- CHG-0008 仅增加 Web/Admin 商品删除入口和交互测试；后端删除接口、占用规则与数据库均不修改。
- CHG-0009 新增商品仍允许填写价格；已有商品仅在显式开启改价的测试环境且当前状态为 0 时允许改价，正式环境默认关闭并由 ProductService 强制拒绝。
- 测试环境部署需设置 `PRODUCT_PRICE_EDIT_ENABLED=true`；正式环境不设置或显式设为 `false`。
- CHG-0010 仅生成 Android arm64-v8a 候选包；渠道协议固定为 `META-INF/channel-<channel>`，所有渠道继续使用现有 lxwx 签名。
- CHG-0010 友盟使用具体分发渠道，版本更新接口仍只传 `office` / `store`；不修改服务端协议。
- CHG-0010 渠道 APK 命名固定为 `catsinger_v<versionName>_<channel>_release.apk`，当前版本示例为 `catsinger_v1.0.1_baidu_release.apk`。
- Flutter `--target-platform android-arm64` 不会剔除所有第三方 AAR 的其他 ABI，CHG-0010 同时在 release Gradle 配置中固定 `arm64-v8a` 过滤。
- 支付真机 QA 未关闭前，candidate 产物不视为商店就绪或最终正式包。
- CHG-0011 只做页面结构收口与未使用客户端业务删除；保留 `SongHomeItem`、`SongHomeModule`、`/api/song-config/home-*`、场景写歌、歌曲案例详情及独立视频创建/作品入口。
- CHG-0011 不修改 UI、后端、数据库、Android/iOS 原生配置或 CHG-0010 candidate 产物；旧 `/home-cases/:id` 无 Deep Link 兼容要求，可直接删除。
- CHG-0011 的首页 Widget 3 项和歌曲配置 Store 9 项通过，生产代码静态检查无问题；全工程 analyze 仅剩 1 个既有测试重复 key 警告，完整套件复现既有乱码断言和音频持续帧级联失败。
- CHG-0012 不修改 App 工程；Web/Admin 删除展示模式管理，后端保留 `display_mode` 和旧 `home-modules` 字段兼容。
- CHG-0012 新增 `catsinger_song_home_lists`，不回填、不删除存量数据；未持久化列表按标签和原歌曲排序运行时回退。
- CHG-0012 默认展示数量为 `scene_template=4`、`hot_song=10`、其他标签 10；显式列表允许保存空 `itemCodes`。
- CHG-0012 已保存 tagCode 不可修改；列表引用的歌曲删除或标签移除由后端拒绝并提示先清理列表。
- CHG-0013 不使用责任链、Handler 或 Catalog；不修改数据库、公开 API、计费、模型选择和 thirdparty Command 字段结构。
- CHG-0014 直接修改开发期 `V2.6__catsinger_song_home_lists.sql` 增加标签 `cover_url`，不新增 V2.7、不回填数据；已执行旧 V2.6 的数据库需单独同步字段与 Flyway 校验。
- CHG-0014 二级页不显示底部导航；歌曲行复用“我的作品”视觉和只读详情，公共歌曲不提供删除等所有者操作。
- CHG-0014 App 生产代码静态检查和新增/相关测试通过；全量测试继续复现已登记的乱码断言与 `audioplayers` 级联失败。Web/Admin 48 项全量测试通过；Java 456 项中仍仅有已登记的 31 项积分基线失败。
- CHG-0015 不使用责任链、Handler、Catalog、数据库或管理后台；删除 capability 通用提示词和开发期 `promptCode` 重载，原始 String 方法、REST、任务表、计费、Provider 与 thirdparty Command 结构保持不变。
- CHG-0015 定向测试和构建通过；Java 全量增加到 460 项，仍仅有已登记的 31 项积分基线失败，没有新增失败。
- CHG-0016 只修改 Flutter App 的按钮复用、播放器状态订阅和测试；生产代码分析与四组相关回归通过，全工程 analyze 仅保留既有测试重复 key 警告；CHG-0010 真机 QA 状态未改变。
- CHG-0017 只修改 Flutter App 的首页歌曲二级页、复用歌曲行、播放队列接入和测试；Figma 关键尺寸与自动播放队列回归通过，完整套件仅复现已登记基线问题；CHG-0010 真机 QA 状态未改变。
- CHG-0018 允许 App 使用 `core.ai.aiprompt` 的上下文契约；音乐模板与适配只位于 `MusicPromptBusiness`，`AIModelPromptService` 只校验分发，`core.ai.aimodel.AiModelCallService` 统一触发优化后委托现有 String 方法。framework 不得反向认识提示词业务；REST、数据库、任务结构、计费、Provider 和 thirdparty Command 保持不变。
- CHG-0019 已建立独立 Python 内容工厂；不修改 Flutter、Java、Web/Admin 或 `lxwx_ai_service`，不直接连接 Java 业务数据库，不复制音乐 Provider、OSS、审核和作品逻辑。
- 每次榜单采集固定通过 Codex 对话形成不可变 Markdown/JSON/Manifest；采集导入不触发音乐生产，Codex 调试也不是生产运行依赖。
- 音乐平台并发限制按 `Provider + Model` 跨生产批次全局计算；未知限制默认为 1，活动槽位是 `SUBMITTING + GENERATING`。
- 榜单采集只保存合规元数据，不下载或保存原曲、歌词、旋律和版权媒体；未确认官方/授权方式的数据源默认关闭。
- CHG-0019 采集导入与生产创建显式分离，最终发布默认人工审核；内部成本归属等待 Java 计费策略确认。
- CHG-0019 当前 Catsinger 创建接口继续走用户 JWT 与普通用户积分，Python 不绕过；若业务接受该成本规则，无需 Java 改造。只有未来要求内部免积分或机器鉴权时才另立 Java 变更。
- CHG-0020 与 App 审核账号完全独立，不继承 Apple 审核白名单；运营账号继续走普通用户积分、音乐生成与内容审核规则。
- CHG-0020 源码默认关闭且凭证为空；正式值只保存在私有运行配置，不进入 Git、文档、测试、接口响应或日志。
- CHG-0020 首次创建即冻结，服务进入就绪前执行一次冻结，之后按 `Asia/Shanghai` 每日定时恢复冻结；启动冻结失败时不允许服务带着未冻结账号就绪。
- CHG-0020 Java `compileJava`、`build -x test`、定向测试与差异检查通过；全量 470 项有 45 项既有基线失败，CHG-0020 用例未失败。
- CHG-0020 Web/Admin 53 项测试、`flutter analyze`、Web 正式构建与差异检查通过；正式后端已返回运营账号冻结门禁，Admin 解冻和真实成功登录仍待验证。
- CHG-0021 只修改 `MusicPromptBusiness` 封面正向提示词、同步 1 条封面旧断言并新增 1 项最终 Command 回归；定向测试和 `build -x test` 通过，全量 471 项剩余 44 项既有基线失败，差异检查通过。
- CHG-0022 运营账号专用于歌曲提交/查询；用户 Token 自动登录并只在内存续期，管理员 Token 继续独立用于标签/发布；冻结时不绕过门禁。
- CHG-0022 Catsinger 鉴权定向 20 项、Python 全量 106 项、Ruff、格式和编译检查通过；本地 PostgreSQL/Redis、Alembic head 与模拟 Doctor 正常。

## 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|---|---|---|
| Java 全量测试当前 471 项有 44 项既有基线失败，覆盖积分初始值、提示词、数据引导与歌曲资源等存量断言 | 不影响 CHG-0020/0021 定向测试、编译和无测试构建结果；CHG-0021 相关用例通过 | 保留现状并另立基线清理任务，不在本轮提示词小修复内扩散修复 |
| Flutter 完整测试存在大量旧 `????` 文案断言；进入歌曲播放器后又出现 `audioplayers` 持续帧并导致后续 `pumpAndSettle` 级联超时 | 不影响 CHG-0011 首页 Widget 3 项、歌曲配置 Store 9 项及既有独立测试结果 | 不在 CHG-0011 内批量改写无关旧用例；后续单独清理乱码断言并修复播放器测试隔离后重跑完整套件 |
| CHG-0002/CHG-0005/CHG-0007 Android 真机支付验收未关闭 | CHG-0010 只能生成 candidate，不能标记最终正式包 | 完成候选构建验证后回到真机 QA；通过后重跑同一九渠道流水线 |
| CHG-0019/0022 尚未发送真实单曲生成请求，MiniMax Provider/Model 配额只能在首个提交时最终确认 | 正式 Doctor、管理员 JWT、运营账号解冻和积分已就绪；真实 Provider 链路仍待联调 | 按 README 使用单曲方案和 `maxInFlight=1` 执行 `prepare → start → worker`，失败时保留批次并使用 `status/inspect/reconcile` 诊断 |
| CHG-0020 正式 Admin 已解冻，但 `doctor` 不发起运营用户登录 | 成功登录和每日重置门禁仍未完成端到端冒烟 | 以首个真实生成提交验证用户登录；下一次每日冻结后再验证拒绝与 Admin 重新解冻 |

## 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|---|---|---|---|
| 2026-07-13 | 变更校准 | 建立最小工作空间并登记 CHG-0001 | `done` |
| 2026-07-13 | Flutter 编码 | 增加播放器入口、动态计费确认、重复点击拦截和状态刷新 | `done` |
| 2026-07-13 | Java 编码 | 增加作品级 Redis 锁、本地 FunASR 接入和中文链路日志 | `done` |
| 2026-07-13 | 自动化验证 | Flutter analyze/全部测试、Java 定向测试、diff 检查和服务健康检查 | `done` |
| 2026-07-13 | 本地验收 | 等待重启 Java 后从播放器执行真实歌曲验证 | `waiting_review` |
| 2026-07-14 | 变更校准 | 登记 CHG-0002，补齐支付宝支付 Flutter 最小技术与开发计划 | `done` |
| 2026-07-14 | Flutter 编码 | 完成支付底部弹层、隐藏 WebView、支付宝 scheme 拦截、外部 App 启动、订单回查与关闭返回契约 | `done` |
| 2026-07-14 | 自动化验证 | `dart format`、`flutter analyze`、支付/会员/积分及 Apple IAP 独立回归、Android Debug APK 编译、`git diff --check` | `done` |
| 2026-07-14 | 完整 Flutter 测试 | 执行后从歌曲路由用例开始因 `audioplayers` 持续帧产生级联 `pumpAndSettle` 超时 | `blocked` |
| 2026-07-14 | Android 真机验收 | 已安装和未安装支付宝两种场景 | `waiting_review` |
| 2026-07-15 | 变更校准 | 登记 CHG-0003，并明确开发任务可并行、不互斥 | `done` |
| 2026-07-15 | Flutter/Web Admin 编码 | 开始实现商品管理、新增默认未上架及上下架 | `in_progress` |
| 2026-07-15 | Flutter/Web Admin 编码 | 完成商品筛选、新增抽屉、默认未上架保护、上下架确认与状态刷新 | `done` |
| 2026-07-15 | 自动化验证 | `dart format`、`flutter analyze`、完整 `flutter test`、`git diff --check` | `done` |
| 2026-07-15 | Flutter/Web Admin Bug 修复 | 登记 CHG-0004，并定位 `moneyFromCents` 非整元金额仅保留 1 位小数 | `in_progress` |
| 2026-07-15 | Flutter/Web Admin Bug 修复 | 非整元金额改为两位小数，整元保持无小数显示 | `done` |
| 2026-07-15 | 自动化验证 | 金额定向测试、`flutter analyze`、完整 `flutter test`（38 项）、`git diff --check` | `done` |
| 2026-07-15 | 变更校准 | CHG-0004 编号已占用，顺延登记 CHG-0005 支付方式与自动拉起弹框，不覆盖已完成变更 | `in_progress` |
| 2026-07-15 | Flutter 编码 | 积分与会员页增加微信占位入口；支付路由改为自动提交的阻塞式“支付处理中”弹框 | `done` |
| 2026-07-15 | 自动化验证 | `dart format`、`flutter analyze`、支付域 45 项定向测试与 `git diff --check` 通过；完整套件复现既有歌曲音频帧级联超时 | `done` |
| 2026-07-15 | Android 真机验收 | 已安装/未安装支付宝及微信占位入口交互 | `waiting_review` |
| 2026-07-15 | 变更校准 | 登记 CHG-0006 商品默认数据入库与编码唯一性；确认与 CHG-0005、CHG-0002 并行 | `done` |
| 2026-07-15 | Java 编码 | 确认 products 表已有 `(app_code, product_code)` 唯一约束，开始调整 ProductService | `in_progress` |
| 2026-07-15 | Java 编码 | 完成仅新增前空表 JSON 入库、查询只读、数据库唯一展示、商品编码防重及新增默认未上架 | `done` |
| 2026-07-15 | 自动化验证 | 商品定向测试与 `build -x test` 通过；全量 419 项仍为既有 31 项积分基线失败；`git diff --check` 通过 | `done` |
| 2026-07-15 | 变更校准 | 登记 CHG-0007 支付模块工程结构收口，重新进入 Flutter 编码阶段 | `done` |
| 2026-07-15 | Flutter 编码 | 开始迁移支付页面/组件并抽取统一支付流程协调器 | `in_progress` |
| 2026-07-15 | Flutter 编码 | 完成支付页面/组件目录收口、路由导入更新和 PaymentFlowCoordinator 抽取 | `done` |
| 2026-07-15 | 自动化验证 | `dart format`、`flutter analyze`、支付域 50 项与 `git diff --check` 通过；完整套件复现既有歌曲音频帧级联超时 | `done` |
| 2026-07-15 | 变更校准 | 登记 CHG-0008 Web 后台商品删除按钮；确认与 CHG-0007 并行且不修改后端 | `done` |
| 2026-07-15 | Flutter/Web Admin 编码 | 开始增加仅下架/未上架已入库商品可见的删除操作与确认交互 | `in_progress` |
| 2026-07-15 | Flutter/Web Admin 编码 | 完成删除按钮可见性、不可恢复确认、成功刷新和后端业务错误提示 | `done` |
| 2026-07-15 | 自动化验证 | `dart format`、`flutter analyze`、商品页 3 项定向测试、完整 `flutter test`（40 项）与 `git diff --check` | `done` |
| 2026-07-15 | 变更校准 | 登记 CHG-0009；确认复用既有更新接口，以后端默认关闭的环境配置为最终改价门禁 | `done` |
| 2026-07-15 | Web Admin/Java 编码 | 开始实现测试环境下架商品改价和正式环境锁价 | `in_progress` |
| 2026-07-15 | Web Admin/Java 编码 | 完成改价弹窗、正式环境禁用提示、Repository 更新及 ProductService 环境门禁 | `done` |
| 2026-07-15 | 自动化验证 | Web `flutter analyze`、完整 42 项测试与差异检查通过；Java 商品环境定向测试和 `build -x test` 通过，全量 421 项仍为既有 31 项积分基线失败 | `done` |
| 2026-07-16 | 变更校准 | 登记 CHG-0010，确认 office 单次 arm64-v8a 混淆构建与 Python 九渠道重签方案 | `done` |
| 2026-07-16 | Flutter/Android 构建工具编码 | 开始实现 META-INF 渠道读取、友盟具体渠道与安全重签工具 | `in_progress` |
| 2026-07-16 | Android 候选构建 | 首次构建成功，但 aapt 检测到第三方 AAR 仍包含 armeabi-v7a/x86_64，追加 release ABI 过滤后重建 | `in_progress` |
| 2026-07-16 | Flutter/Android 构建工具编码 | 完成 APK 渠道读取、友盟具体渠道、版本更新二分类、Python 九渠道工具和自动化测试 | `done` |
| 2026-07-16 | Android candidate 构建 | office arm64-v8a R8/Dart 混淆构建通过，Dart symbols 与 R8 mapping 已归档 | `done` |
| 2026-07-16 | Android candidate 验证 | office/huawei 渠道包通过 META-INF、zipalign、V2/V3、证书、版本、ABI 与 SHA-256 校验 | `done` |
| 2026-07-16 | Android candidate 命名调整 | 九渠道包改为 `catsinger_v1.0.1_<channel>_release.apk`，旧命名自动清理；10 项 Python 测试、九渠道重签、清单和 SHA-256 校验通过 | `done` |
| 2026-07-16 | Android 真机验收 | 等待安装 candidate 验证一键登录、支付宝、友盟渠道和版本更新分组 | `waiting_review` |
| 2026-07-17 | 变更校准 | 登记 CHG-0011，确认与 CHG-0010 真机 QA 并行且不修改服务端/UI | `done` |
| 2026-07-17 | Flutter 编码 | 完成现用首页迁移、页面层类名收口和旧首页页面/API/模型/路由/测试夹具删除 | `done` |
| 2026-07-17 | 自动化验证 | `dart format`、生产代码分析、首页 Widget 3 项、歌曲配置 Store 9 项、遗留引用扫描与差异检查通过；完整套件复现既有乱码断言和音频帧级联失败 | `done` |
| 2026-07-17 | 变更校准 | CHG-0011 编号已占用，顺延登记 CHG-0012 首页歌曲列表独立编排并保持 CHG-0010 真机 QA 状态 | `done` |
| 2026-07-17 | Java 编码 | 完成 V2.6 首页列表表、默认/显式列表合并、Admin/Public 接口、旧 home-modules 复用、404 和关联保护 | `done` |
| 2026-07-17 | Flutter/Web Admin 编码 | 完成展示模式移除、首页列表编排、歌曲标签筛选、API/Repository/模型/演示数据与操作日志 | `done` |
| 2026-07-17 | 自动化验证 | Web/Admin analyze 与 46 项全量测试通过；Java 新增定向/OpenAPI 测试和 build 通过，全量 443 项仅保留既有 31 项积分基线失败；两工程差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0012 归档为 v0.4.0；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | 登记 CHG-0013 AI 模型提示词分层组装，补充 Java 技术与模块计划，与 CHG-0010 真机 QA 并行 | `done` |
| 2026-07-17 | Java 编码 | 完成五类 Command 四层提示词组装、Catsinger 业务码、AiModelCallService 兼容重载与业务调用接入 | `done` |
| 2026-07-17 | 自动化验证 | 提示词与模型调用定向测试、compileJava、build 通过；全量 453 项仅保留既有 31 项积分基线失败；差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0013 归档为 v0.4.1；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | CHG-0013/v0.4.1 已占用，顺延登记 CHG-0014/v0.4.2 首页标签封面与歌曲二级页；CHG-0010 真机 QA 状态保持不变 | `in_progress` |
| 2026-07-17 | Java 编码 | 完成 V2.6 标签 cover_url、Admin 封面上传、标签 DTO/VO 与公开有效封面实时回退 | `done` |
| 2026-07-17 | Flutter/Web Admin 编码 | 完成 Admin 标签封面预览/上传/清空、App 动态标签首页、独立歌曲二级页与只读详情 | `done` |
| 2026-07-17 | 自动化验证 | App 生产代码分析与相关测试、Web/Admin analyze 和 48 项全量测试、Java 定向/OpenAPI/build 通过；Java 全量 456 项仅保留既有 31 项积分基线失败，三工程差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0014 归档为 v0.4.2；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | CHG-0014/v0.4.2 已占用，顺延登记 CHG-0015/v0.4.3 AI 业务强类型引导词，与 CHG-0010 真机 QA 并行 | `done` |
| 2026-07-17 | Java 编码 | 完成核心强类型契约、Catsinger 四组八业务提示词、共享输入、AiModelCallService 重载替换及业务调用迁移 | `done` |
| 2026-07-17 | 自动化验证 | 提示词/业务格式/模型调用与 3 项业务集成定向测试、build 通过；全量 460 项仅保留既有 31 项积分基线失败；差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0015 归档为 v0.4.3；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | 登记 CHG-0016/v0.4.4 首页歌曲二级页返回与播放状态同步修复，与 CHG-0010 真机 QA 并行 | `done` |
| 2026-07-17 | Flutter 编码 | 复用作品详情圆形返回按钮；配置歌曲播放器绑定自身会话后同步当前歌曲、详情、进度和播放态 | `done` |
| 2026-07-17 | 自动化验证 | 首页返回、配置/普通歌曲切歌和首页列表 Controller 回归通过；生产代码分析无问题，全工程 analyze 仅保留既有重复 key 警告，差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0016 归档为 v0.4.4；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | 登记 CHG-0017/v0.4.5 首页歌曲二级页新版对稿与自动播放，与 CHG-0010 真机 QA 并行 | `done` |
| 2026-07-17 | Flutter 编码 | 按 Figma 首页2 校准紧凑歌曲列表；点击歌曲建立标签播放队列、选中当前歌曲并调用自动播放 | `done` |
| 2026-07-17 | 自动化验证 | 首页列表 Controller、Figma 关键尺寸/只读菜单/自动播放队列和配置播放器会话回归通过；生产代码分析无问题，全工程 analyze 仅保留既有重复 key 警告，差异检查通过；完整套件复现既有基线失败 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0017 归档为 v0.4.5；恢复 CHG-0010 Android candidate 真机 QA，状态保持 waiting_review | `waiting_review` |
| 2026-07-17 | 变更校准 | 登记 CHG-0018/v0.4.6 音乐业务提示词最小收口，确认 App 只传 MusicPromptContext，模型调用入口统一触发优化 | `done` |
| 2026-07-17 | Java 编码 | 新增通用上下文契约与 MusicPromptBusiness；AIModelPromptService 只校验分发；完成模型调用重载和四个 Catsinger 上下文映射 | `done` |
| 2026-07-17 | 自动化验证 | core 18 项、模型调用 10 项、业务集成 9 项通过；干净基线 build 通过，全量 466 项仅保留 31 项积分基线失败；依赖扫描和差异检查通过 | `done` |
| 2026-07-17 | 流程恢复 | CHG-0018 归档为 v0.4.6；等待用户确认，不自动推进 QA 或其他变更 | `done` |
| 2026-07-20 | 变更校准 | 登记 CHG-0019/v0.5.0 AI 音乐内容自动生产工具；确认本轮只做需求分析，不写业务代码 | `done` |
| 2026-07-20 | 需求分析 | 核对 App、Java 后台、独立 AI 推理服务和官方榜单接入边界；形成独立 Python 内容工厂与 Java 复用方案 | `done` |
| 2026-07-20 | 需求分析交付 | 输出 `01-需求/requirements-list.md`，等待用户确认后再进入 PRD，不自动编码 | `waiting_review` |
| 2026-07-20 | 方案确认 | 用户确认 Codex 采集/调试、Python 持续生产和平台受限并发三链路，并要求直接实施 | `done` |
| 2026-07-20 | PRD/技术方案 | 更新确认需求，生成正式 PRD 和 Python/Java 集成技术方案 | `done` |
| 2026-07-20 | Python 业务标签自动化 | 完成严格生产方案、标签禁用创建/续跑、显式列表阻断、整批生成屏障、部分发布重审、绑定重试核验失效、新标签启用、Java 有效歌曲过滤兼容、公开后 Admin 二次快照和批次异常隔离 | `done` |
| 2026-07-20 | Codex 内容产物 | 完成 4 个业务标签/35 条榜单样本分析和 50 首显式原创生产方案，标题/描述/prompt 均通过来源歌曲与歌手隔离校验 | `done` |
| 2026-07-20 | 自动化与迁移验证 | Ruff、格式、编译、101 项 pytest、Alembic 升降级/check、干净导入和模拟端到端通过 | `done` |
| 2026-07-20 | 真实环境联调 | 等待 Catsinger 用户/Admin Token、足够测试积分和 MiniMax 并发/超时配置，以 maxInFlight=1 联调一首 | `waiting_review` |
| 2026-07-20 | 变更校准 | 登记 CHG-0020/v0.6.0 独立运营账号、每日冻结和后台解冻门禁；CHG-0019 恢复点保持 waiting_review | `done` |
| 2026-07-20 | Java/Web Admin 编码 | 完成独立账号生命周期、登录/Token 门禁、Admin GET/PATCH、用户页卡片、原因确认与跨 App 状态隔离 | `done` |
| 2026-07-20 | 自动化验证 | Java 编译、无测试构建、CHG-0020/审核账号/OpenAPI 定向测试与差异检查通过；Admin 53 项测试、analyze 与差异检查通过 | `done` |
| 2026-07-20 | Java 全量回归 | 执行 470 项，45 项既有基线失败；CHG-0020 用例未失败 | `done` |
| 2026-07-20 | 正式环境发布与冒烟 | 私有配置已准备；尚未部署，等待核验默认冻结、后台解冻及真实登录鉴权 | `waiting_review` |
| 2026-07-20 | 变更校准 | 登记 CHG-0021/v0.6.1 音乐封面正向提示词禁用文字约束，保留 CHG-0019/0020 恢复点 | `done` |
| 2026-07-20 | Java 编码 | 将文字、伪文字、乱码、Logo、水印、二维码和 UI 等硬性禁用项合并到封面最终正向 prompt | `done` |
| 2026-07-20 | 自动化验证 | 2 项封面定向回归通过，build 通过；全量 471 项剩余 44 项既有基线失败；差异检查通过 | `done` |
| 2026-07-20 | 流程恢复 | CHG-0021 归档为 v0.6.1；恢复 CHG-0020 正式发布与解冻冒烟等待状态 | `waiting_review` |
| 2026-07-21 | 变更校准 | 用户明确运营账号用于批量歌曲生产；登记 CHG-0022/v0.6.2，补齐静态用户 Token 无法覆盖长批次的续期缺口 | `done` |
| 2026-07-21 | Python 内容工具编码 | 完成运营账号私有凭证自动登录、Access/Refresh Token 内存态、401 Refresh、失败回退登录和原请求单次重放 | `done` |
| 2026-07-21 | 自动化与本地环境 | 鉴权定向 20 项、全量 106 项、Ruff/格式/编译通过；PostgreSQL 5433、Redis、Alembic head 与模拟 Doctor 正常 | `done` |
| 2026-07-21 | 正式环境检查 | PostgreSQL、Redis、Catsinger 健康、管理员 JWT、首页标签/列表控制面和 `maxInFlight=1` 已通过 Doctor；运营账号已解冻且积分充足 | `done` |
| 2026-07-21 | 变更校准 | 登记 CHG-0023/v0.6.3，限定为音乐工厂 README 和工作流记录修改 | `done` |
| 2026-07-21 | 运行文档 | 补全环境检查、单曲联调、PyCharm 参数、单批/全局 Worker、Celery 和 `AUTO` 发布命令 | `done` |
| 2026-07-21 | 命令契约验证 | `music-factory --help`、`worker --help` 和 `approve-publish --help` 与 README 一致；未发送真实生成请求 | `done` |
| 2026-07-21 | 变更校准 | 登记 CHG-0024/v0.6.4，修复 Alembic/Doctor 缺少明确成败反馈和 Doctor 失败仍退出 0 的问题 | `done` |
| 2026-07-21 | Python 环境诊断 | 新增 `db-upgrade`；Doctor 新增顶层 `ok`、中文总结、组件化问题/建议、不阻断警告和失败退出码 1 | `done` |
| 2026-07-21 | 自动化验证 | Ruff、格式、编译和 113 项 pytest 通过；本地 PostgreSQL 升级成功反馈与 Redis 故障注入退出码 1 通过 | `done` |
| 2026-07-21 | 真实单曲联调 | 等待按 README 创建 smoke 批次并执行 `prepare → start → worker`，验证用户登录、Provider 生成、审核和标签绑定 | `waiting_review` |
| 2026-07-23 | 变更校准 | 登记 CHG-0025/v0.6.5，确认临时媒体 URL 导致重复缓存且首播/首图存在双请求 | `done` |
| 2026-07-23 | Flutter 编码 | 完成环境隔离稳定业务键、歌曲/标签/案例/专辑/音色接入、主音频和图片单请求加载、封面重新生成失效与 LRU 访问刷新 | `done` |
| 2026-07-23 | 自动化验证 | `dart format`、生产代码分析、稳定媒体键/主播放单请求/隐私前迷你播放器及首页列表 6 项测试通过；全工程 analyze 仅保留既有重复 key 警告 | `done` |
| 2026-07-23 | 流程恢复 | CHG-0025 归档为 v0.6.5；恢复 CHG-0019/0022 正式单曲全链路联调等待状态 | `waiting_review` |
| 2026-07-30 | Flutter 重构 | 登记并完成 CHG-0026/v0.6.6；删除 MediaCacheService，资源换签、缓存、图片解码与容量管理统一收口到 ResourceService | `done` |
| 2026-07-30 | 自动化验证 | `dart format`、`flutter analyze`、ResourceService 8 项单测和资源缓存/主播放/隐私降级/统一图片定向用例通过；扩展回归仅复现既有 audioplayers 残留帧和乱码文案断言 | `done` |
| 2026-07-30 | 流程恢复 | CHG-0026 归档为 v0.6.6；恢复 CHG-0019/0022 正式单曲全链路联调等待状态 | `waiting_review` |
