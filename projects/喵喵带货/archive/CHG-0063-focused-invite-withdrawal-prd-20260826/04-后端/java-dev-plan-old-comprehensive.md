# 喵喵带货 Java 总体开发计划

> 版本：`v1.1`  
> 日期：2026-07-21  
> 状态：已完成  
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`  
> 关联技术文档：`java-tech.md` v1.0、`flutter-tech.md` v1.0  

---

## 1. 文档用途

本文档把 Java 技术方案拆成可执行、可暂停、可恢复的总体开发计划，供后续生成模块开发文档和执行编码使用。

本计划负责：

- 明确后端功能顺序、接口范围、依赖和验收结果。
- 对齐移动端的首页、填写信息、内容生成、编辑脚本、视频生成、作品和“我的”业务。
- 明确数据隔离、任务状态、计费、审核、保留期和后台配置的实现边界。
- 记录任务与模块文档的恢复点，避免中断后重复分析。

本计划不负责：

- 不直接修改 Java、Flutter 或运营后台代码。
- 不在本阶段展开类和方法级编码步骤；模块细节在下一阶段输出。
- 不重新实现登录、会员、积分、充值、订单、任务中心和兑换码等已有公共能力。

任务编号只用于技术追踪。日常沟通与验收均使用“草稿、生成脚本与分镜、视频生成、积分扣费”等直接业务名称。

## 2. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `15 前后端联调与验收` |
| 当前任务 | CHG-0057 作品详情图片大小契约 |
| 当前状态 | `done` |
| 当前恢复点 | `GET /api/catseller/works/{workId}` 的 `inputImages/productImages` 已从资源台账装配 `sizeBytes`，缺失返回 0；无数据库迁移和后端总量校验，强制全量测试通过 |
| 下一步默认动作 | 交付 Flutter 真机联调，继续保持用户/App 隔离与既有资源可读性规则 |

已完成 00～09 全部 Java 模块、自动化回归、构建和文档收口。真实视频模型仍需在私密账号与额度具备的环境中做最终渠道联调，仓库内契约和 Mock 链路不依赖真实密钥。

### 2.1 CHG-0055 当前实现补充

- 图片与视频解析各只调用一次媒体理解模型并直接返回候选卖点；用户卖点优先，确认后才能提交分镜。
- `/api/catseller/works/{workId}/script-tasks` 一次文本调用直接生成标题、最终时长和完整镜头，工作流为检查资源、输入审核、直接生成分镜、保存草稿、发布结果。
- 商品类型固定原 8 种，探店内部固定 `store_visit`，爆款复刻为空；公共响应隐藏内部类型。
- 配置版本升至 v7，v6→v7 迁移保留运营字段；分析缓存升至 v2。
- 新增提示词状态、发布版本、正式执行快照、后台调试任务及视频分段调试表；接口覆盖目录、草稿、发布、恢复、预览、真实调试和执行记录查询。
- 废弃卖点文本生成与内容脚本生成业务类型、AI 场景、模型绑定和提示词节点；数据库无提示词配置时使用代码默认模板。
- 本次不修改既有 Catseller 业务表/Entity/历史作品，也不修改 Flutter 用户端。

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 尚未开始 |
| `in_progress` | 正在执行 |
| `waiting_review` | 产物已完成，等待评审 |
| `done` | 已完成并通过对应验证 |
| `blocked` | 被接口、模型、配置、额度或环境阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

1. 开始编码前将当前任务设为 `in_progress`，并记录实际恢复点和数据库版本。
2. 代码完成但依赖视频模型、Flutter 联调或测试数据时，不标记 `done`，应记录具体阻塞。
3. 每完成一个任务，同步更新任务清单、接口清单和执行记录。
4. 接口路径、作品状态或计费规则变化时，先同步技术文档，再更新本计划。
5. 本计划评审通过前，不生成模块开发文档，也不进入编码。

## 4. 总体开发策略

后端沿用现有多 App Java 服务，不另建独立服务：

1. 先建立 catseller 数据隔离、配置、表结构、权限和资源归属。
2. 复用现有登录鉴权、资源上传、积分、支付、会员、订单、任务中心、兑换码和阿里审核能力。
3. 打通商品图片、首图建草稿、填写信息、AI 帮写和带货形象。
4. 建立作品聚合和“草稿、内容生成中、编辑脚本、视频生成中、视频已完成”五个主状态。
5. 完成脚本、镜头、分镜图片、历史版本和失败镜头恢复。
6. 完成按确认分镜图数量报价、积分预扣/结算、视频任务和失败恢复。
7. 最后完成 7 天隐藏、30 天删除、运营后台、公共能力复用和全链路回归。

生成任务的应用层编排参考现有 `app/catsinger/songworkflow`：创建任务后初始化固定步骤，由调度器和 Engine 推进，外部等待使用 `PAUSED`，成功步骤恢复时跳过，失败统一写事件并执行幂等补偿。catseller 使用自己的工作流定义、步骤编码和数据表，不直接复用歌曲领域对象。

两名 Java 开发并行时必须共用同一作品状态机、任务表、错误码和幂等规则，不得为脚本、图片、视频分别建立互不关联的作品真源。

## 5. 功能实施顺序

| 顺序 | Java 后端 | Flutter/UI 前置 | 验收结果 |
|------|-----------|----------------|----------|
| 1 | 数据隔离、商品图片与形象资源、首图建草稿；跑通视频模型最小调用 | 首页已完成；需要填写信息、AI 帮写和带货形象 UI | 可创建 catseller 草稿；资源归属正确；视频 Provider 能返回真实任务结果 |
| 2 | 首页与案例、AI 帮写、作品聚合、脚本与镜头基础接口 | 需要作品、内容生成和编辑脚本 UI | 首页和填写信息可联调；作品能进入内容生成；脚本和镜头数据可保存 |
| 3 | 分镜图片生成、历史版本、失败镜头重试和任务进度恢复 | 需要视频生成 UI | 脚本与分镜图片完整生成；退出重进后能恢复真实状态 |
| 4 | 视频报价、积分扣费、视频任务、失败恢复和阿里审核 | 需要视频完成和我的 UI | 可按分镜图数量报价并提交视频；失败不重复扣费；审核结果可追踪 |
| 5 | 隐藏/删除、案例和配置后台、作品与任务查询、公共能力复用 | 更多案例作为最后新增页面 | 运营后台可配置和查询；7/30 生命周期可执行；复用接口不受影响 |
| 6 | 接口冻结、联调、数据校验、回归测试和异常路径修复 | Flutter 全链路联调 | 主流程通过；无重复任务或重复扣费；具备内部验收条件 |

### 5.1 里程碑对应

| 里程碑 | Java 退出条件 |
|--------|---------------|
| 基础 App 结构搭建 | 首页数据可返回；商品首图上传后可幂等创建草稿 |
| 生成脚本功能 | 内容任务可生成脚本、镜头和分镜图片；作品可进入编辑脚本状态 |
| 视频生成和作品列表 | 作品聚合、报价、扣费、视频任务、失败恢复和视频结果可用 |
| 复用功能移植 | 现有登录、会员、积分、充值、个人信息等公共接口在 catseller 下可正常使用 |
| 整体 App 完成 | 移动端与后台接口回归通过，生命周期任务可执行，内部环境可验收 |

## 6. 后端详细任务清单

| 任务 ID | 业务名称 | 依赖 | 模块文档 | 状态 | 验收要点 |
|---------|----------|------|----------|------|----------|
| T-B001 | 数据隔离 | - | `00-catseller-foundation-and-schema.md` | done | catseller schema、App 配置、权限和资源归属正确，不串到其他 App |
| T-B002 | 首页与案例 | 数据隔离 | `02-home-description-and-cases.md` | done | 游客首页可用；案例无筛选分页；后台可上下线和排序 |
| T-B003 | 商品图片与带货形象 | 数据隔离、公共资源 | `01-work-draft-assets-persona.md` | done | 图片审核后保存资源；首图幂等建草稿；形象可选择、定制、重命名和删除 |
| T-B004 | AI 帮写 | 数据隔离、AI 配置 | `02-home-description-and-cases.md` | done | 可生成和重新生成描述；任务可恢复；结果不自动覆盖用户输入 |
| T-B005 | 作品与五个状态 | 数据隔离、商品资源 | `01-work-draft-assets-persona.md` | done | 聚合详情返回最新版本、状态、可执行操作和轮询时间；点击作品可准确恢复业务页面 |
| T-B006 | 脚本与镜头 | 作品、内容任务 | `03-content-script-and-shots.md` | done | 脚本、镜头、画面、可空口播和历史版本可保存；并发编辑可检测冲突 |
| T-B007 | 分镜图片 | 脚本与镜头、图片模型 | `04-storyboard-images.md` | done | 按镜头生成、重生成、上传替换、历史切换和失败镜头重试可用 |
| T-B008 | 视频生成 | 已确认脚本与图片、视频模型 | `05-video-workflow-and-provider.md` | done | 快照后提交视频；运行中不可取消/编辑；完成结果可播放、下载和分享 |
| T-B009 | 积分计费 | 视频报价、公共积分 | `06-billing-and-moderation.md` | done | 按确认分镜图数量和后台单价报价；幂等扣费；失败按配置处理，不重复扣费 |
| T-B010 | 内容审核 | 公共阿里审核 | `06-billing-and-moderation.md` | done | 商品图、形象、描述、脚本、分镜图和视频按节点审核；结果和失败原因可追踪 |
| T-B011 | 任务进度与失败恢复 | 内容、图片、视频任务 | `07-task-recovery-and-lifecycle.md` | done | 任务开始后不能取消；回调、轮询和补偿幂等；失败保留已成功内容和最小恢复入口 |
| T-B012 | 作品隐藏与删除 | 作品和资源 | `07-task-recovery-and-lifecycle.md` | done | 完成作品 7 天后隐藏、30 天后删除；运行中不处理；删除后资源不可访问 |
| T-B013 | 运营后台 | 数据隔离、业务接口 | `08-admin-and-common-reuse.md` | done | 案例、业务/计费配置、作品和任务查询可用；权限和 App 隔离正确 |
| T-B014 | 公共功能复用 | catseller App 配置 | `08-admin-and-common-reuse.md` | done | 登录、会员、积分、充值、订单、任务中心、兑换码等沿用现有逻辑，积分规则按本业务区分 |
| T-B015 | 后端验收 | 全部后端任务 | `09-java-tests-and-acceptance.md` | done | 接口、数据库、权限、幂等、定时任务、计费、审核和其他 App 回归通过 |

## 7. 接口开发任务表

### 7.1 首页、AI 帮写与形象

| 任务 | 接口 | 方法 | 路径 | 主要数据 | 计划服务 | 状态 |
|------|------|------|------|----------|----------|------|
| 首页 | 首页聚合 | GET | `/api/catseller/home` | 案例、业务配置 | `CatsellerHomeService` | done |
| 首页 | 案例列表 | GET | `/api/catseller/cases` | `catseller_cases` | `CatsellerCaseService` | done |
| 首页 | 案例详情 | GET | `/api/catseller/cases/{caseId}` | `catseller_cases` | `CatsellerCaseService` | done |
| 填写信息 | 业务配置 | GET | `/api/catseller/config` | App 配置、计费配置 | `CatsellerConfigService` | done |
| AI 帮写 | 创建描述任务 | POST | `/api/catseller/description-tasks` | 生成任务、资源引用 | `CatsellerDescriptionTaskService` | done |
| AI 帮写 | 查询描述任务 | GET | `/api/catseller/description-tasks/{taskId}` | 生成任务、结果 | `CatsellerDescriptionTaskService` | done |
| 带货形象 | 形象列表 | GET | `/api/catseller/personas` | 形象、资源记录 | `CatsellerPersonaService` | done |
| 带货形象 | 上传形象 | POST | `/api/catseller/personas` | 形象、资源记录 | `CatsellerPersonaService` | done |
| 带货形象 | 创建定制任务 | POST | `/api/catseller/persona-tasks` | 生成任务、形象 | `CatsellerPersonaTaskService` | done |
| 带货形象 | 查询定制任务 | GET | `/api/catseller/persona-tasks/{taskId}` | 生成任务、形象 | `CatsellerPersonaTaskService` | done |
| 带货形象 | 重命名 | PATCH | `/api/catseller/personas/{personaId}` | 形象 | `CatsellerPersonaService` | done |
| 带货形象 | 删除形象 | DELETE | `/api/catseller/personas/{personaId}` | 形象、作品引用 | `CatsellerPersonaService` | done |

### 7.2 作品、脚本与分镜图片

| 任务 | 接口 | 方法 | 路径 | 主要数据 | 计划服务 | 状态 |
|------|------|------|------|----------|----------|------|
| 填写信息 | 首图建草稿 | POST | `/api/catseller/works` | 作品、输入、资源引用 | `CatsellerWorkService` | done |
| 填写信息 | 保存带货信息 | PATCH | `/api/catseller/works/{workId}/input` | 作品输入、版本号 | `CatsellerWorkService` | done |
| 内容生成 | 直接生成分镜 | POST | `/api/catseller/works/{workId}/script-tasks` | 作品冻结输入、脚本版本、镜头、任务 | `CatsellerContentWorkflowSubmissionService` | done |
| 作品 | 作品列表 | GET | `/api/catseller/works` | 作品摘要 | `CatsellerWorkQueryService` | done |
| 作品 | 作品聚合详情 | GET | `/api/catseller/works/{workId}` | 作品、输入、脚本、镜头、任务、视频 | `CatsellerWorkQueryService` | done |
| 作品 | 删除草稿或完成作品 | DELETE | `/api/catseller/works/{workId}` | 作品、资源、任务状态 | `CatsellerWorkService` | done |
| 编辑脚本 | 新建编辑版本 | POST | `/api/catseller/works/{workId}/versions` | 作品版本、脚本版本 | `CatsellerScriptVersionService` | done |
| 编辑脚本 | 脚本历史 | GET | `/api/catseller/works/{workId}/script-versions` | 脚本版本 | `CatsellerScriptVersionService` | done |
| 编辑脚本 | 重新生成完整文本分镜 | POST | `/api/catseller/works/{workId}/script-tasks` | 新脚本版本、标题、时长和镜头 | `CatsellerContentWorkflowSubmissionService` | done |
| 编辑脚本 | 恢复脚本版本 | POST | `/api/catseller/works/{workId}/script-versions/{versionId}/restore` | 脚本版本、镜头 | `CatsellerScriptVersionService` | done |
| 编辑镜头 | 保存镜头 | PATCH | `/api/catseller/works/{workId}/shots/{shotId}` | 镜头、版本号 | `CatsellerShotService` | done |
| 分镜图片 | 图片历史 | GET | `/api/catseller/works/{workId}/shots/{shotId}/images` | 镜头图片版本 | `CatsellerStoryboardService` | done |
| 分镜图片 | 重新生成图片 | POST | `/api/catseller/works/{workId}/shots/{shotId}/image-tasks` | 图片任务、镜头 | `CatsellerStoryboardService` | done |
| 分镜图片 | 上传替换图片 | POST | `/api/catseller/works/{workId}/shots/{shotId}/images` | 镜头图片、资源引用 | `CatsellerStoryboardService` | done |
| 分镜图片 | 选择当前图片 | PUT | `/api/catseller/works/{workId}/shots/{shotId}/current-image` | 镜头、图片版本 | `CatsellerStoryboardService` | done |
| 分镜图片 | 重试失败镜头 | POST | `/api/catseller/works/{workId}/failed-shots/retry` | 失败镜头、图片任务 | `CatsellerStoryboardService` | done |

### 7.3 视频与后台

| 任务 | 接口 | 方法 | 路径 | 主要数据 | 计划服务 | 状态 |
|------|------|------|------|----------|----------|------|
| 视频生成 | 获取视频报价 | POST | `/api/catseller/works/{workId}/video-quotes` | 当前镜头快照、计费配置 | `CatsellerVideoBillingService` | done |
| 视频生成 | 创建视频任务 | POST | `/api/catseller/works/{workId}/video-tasks` | 视频任务、报价、积分流水 | `CatsellerVideoTaskService` | done |
| 视频失败 | 重试视频任务 | POST | `/api/catseller/works/{workId}/video-tasks/retry` | 视频任务、失败策略 | `CatsellerVideoTaskService` | done |
| 视频完成 | 查询视频结果 | GET | `/api/catseller/works/{workId}/video` | 视频版本、资源记录 | `CatsellerVideoQueryService` | done |
| 案例后台 | 案例管理 | CRUD | `/api/admin/catseller/cases` | `catseller_cases` | `AdminCatsellerCaseService` | done |
| 配置后台 | 业务配置 | GET/PUT | `/api/admin/catseller/config` | App 业务配置 | `AdminCatsellerConfigService` | done |
| 配置后台 | 计费配置 | GET/PUT | `/api/admin/catseller/billing` | 单图积分、失败策略 | `AdminCatsellerBillingService` | done |
| 查询后台 | 作品查询 | GET | `/api/admin/catseller/works` | 作品、审核、状态 | `AdminCatsellerQueryService` | done |
| 查询后台 | 任务查询 | GET | `/api/admin/catseller/tasks` | 内容、图片、视频任务 | `AdminCatsellerQueryService` | done |

AI 模型场景配置继续复用现有通用后台配置接口，不新增 catseller 专属重复接口。

## 8. 数据库与迁移顺序

数据库修改必须按以下顺序实施：

1. 建立 catseller schema 和 App 配置，补齐后台权限资源。
2. 建立案例、作品、作品输入和形象数据。
3. 建立作品版本、脚本版本、镜头和镜头图片版本。
4. 建立生成任务、任务步骤、回调记录、视频版本和业务资源引用。
5. 建立视频报价快照、积分业务流水关联和审核记录。
6. 建立必要索引、唯一键、乐观锁字段、隐藏/删除时间字段。
7. 加入定时隐藏、删除和失败补偿任务。

迁移要求：

- 只新增 catseller 业务对象和必要公共扩展，不改写其他 App 历史数据。
- 草稿创建、生成任务、回调和扣费均有业务唯一键，支持重复请求安全返回。
- 数据库状态是任务和扣费真源，不能以 Provider 返回或客户端页面状态替代。
- 媒体表只保存资源标识和元数据，客户端通过受控接口获取短期访问地址。
- 删除前检查运行中任务；运行中作品不得被隐藏或删除。

## 9. 作品与任务处理规则

| 业务阶段 | 后端行为 |
|----------|----------|
| 草稿 | 第一张有效商品图审核并保存成功后幂等创建；允许保存输入和删除 |
| 内容生成中 | 先生成脚本与镜头，再按镜头生成分镜图片；统一返回内容生成进度 |
| 编辑脚本 | 允许修改画面、可空口播、切换图片、上传替换和新建版本 |
| 视频生成中 | 固化脚本、镜头、当前图片、比例、时长、形象和报价快照；禁止编辑、取消和删除 |
| 视频已完成 | 返回当前视频版本；允许重新编辑、重新生成和删除 |
| 失败 | 记录失败阶段、错误码和已保留内容；只开放对应最小恢复操作 |

其他规则：

- 内容和视频任务开始后均不支持取消。
- 不建设独立配音、字幕或通知任务；视频模型直接产出最终视频。
- 客户端只轮询当前详情页，服务端返回建议轮询间隔，不发送站内信或推送通知。
- 重新生成脚本、分镜图片或视频均是新任务；需要消耗积分的操作先返回明确报价。
- `aiGenerated` 由后端随资源返回，AI 水印由 Flutter 在预览和本地导出时处理。

## 10. 模块开发文档列表

用户确认本总体计划后，按以下顺序生成模块文档：

| 顺序 | 模块文档 | 覆盖业务 | 关联任务 | 状态 |
|------|----------|----------|----------|------|
| 1 | `04-后端/开发计划/00-catseller-foundation-and-schema.md` | 数据隔离、配置、安全、迁移和资源归属 | T-B001 | done |
| 2 | `04-后端/开发计划/01-work-draft-assets-persona.md` | 商品图片、首图建草稿、作品聚合和带货形象 | T-B003、T-B005 | done |
| 3 | `04-后端/开发计划/02-home-description-and-cases.md` | 首页、案例、业务配置和 AI 帮写 | T-B002、T-B004 | done |
| 4 | `04-后端/开发计划/03-content-script-and-shots.md` | 内容任务、脚本版本和镜头编辑 | T-B006 | done |
| 5 | `04-后端/开发计划/04-storyboard-images.md` | 分镜图片、历史版本、上传替换和失败重试 | T-B007 | done |
| 6 | `04-后端/开发计划/05-video-workflow-and-provider.md` | 视频快照、Provider、生成、结果和失败恢复 | T-B008 | done |
| 7 | `04-后端/开发计划/06-billing-and-moderation.md` | 按图报价、积分扣费、失败规则和阿里审核 | T-B009、T-B010 | done |
| 8 | `04-后端/开发计划/07-task-recovery-and-lifecycle.md` | 幂等、进度、补偿、7 天隐藏和 30 天删除 | T-B011、T-B012 | done |
| 9 | `04-后端/开发计划/08-admin-and-common-reuse.md` | 运营后台和登录/会员/积分等公共能力复用 | T-B013、T-B014 | done |
| 10 | `04-后端/开发计划/09-java-tests-and-acceptance.md` | 接口、数据库、权限、任务、计费和回归验收 | T-B015 | done |

每份模块文档必须明确 Controller、请求/响应、Service、Repository/Mapper、表和索引、事务边界、状态变化、幂等键、错误码、审核、测试命令和完成标准。

## 11. 编码约束

- 后端实现真源是 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，不得另建平行服务。
- 所有 catseller 私有接口必须执行现有 Token 鉴权，并校验用户、App 和作品归属。
- 编码前必须检查现有 Security 配置；不得保留可能让新增私有接口被 `permitAll` 覆盖的配置。
- 用户身份来自安全上下文，不从客户端提交的 userId 决定资源归属。
- 所有创建、提交、重新生成、恢复和回调操作必须幂等。
- 任务状态、作品状态和积分状态分别持久化，并通过业务事务或可补偿流程保持一致。
- 视频提交前必须校验报价未过期、镜头快照未变化、余额足够和审核通过。
- 运行中作品不得取消、编辑、删除或生命周期清理。
- 内容审核复用现有阿里能力；后台仅查询结果，不在客户端决定放行。
- 登录、会员、积分、充值、支付、订单、任务中心和兑换码复用现有逻辑，只增加 catseller App 隔离和本业务积分场景。
- 不建设消息推送、WebSocket、独立配音、独立字幕或用户资产统计。
- 返回媒体资源时同时返回 `aiGenerated` 和有效期；不在服务端永久暴露公开 URL。

## 12. 验证与完成标准

每个模块至少完成：

- 编译、单元测试和相关模块集成测试。
- 数据库迁移在空库和已有多 App 测试库执行成功。
- Controller 权限、App 隔离、用户归属和参数校验测试。
- 首图重复提交、任务重复提交、重复回调和重复扣费测试。
- 脚本、图片、视频成功、部分失败、全部失败和超时恢复测试。
- 7 天隐藏、30 天删除、运行中跳过和资源清理测试。
- catsinger 及其他已有 App 关键公共接口回归。

总体完成标准：

- 五个作品主状态和失败/隐藏状态均能由聚合详情准确表达。
- 作品页面每次进入都能按最新服务端状态恢复到正确业务页面。
- 生成脚本与分镜图片是一个内容任务，内部子步骤失败可恢复。
- 视频按确认分镜图数量报价，重复操作不会重复创建任务或重复扣费。
- 运行中任务无取消、删除和编辑能力。
- 阿里审核、公共积分和支付能力正确复用。
- 运营后台能管理案例与配置并查询作品和任务，不影响其他 App。
- 内部环境主流程验收通过。

## 13. 编码门禁结果

- [x] 本计划及 Flutter 总体计划已确认。
- [x] 数据库迁移命名、作品状态、任务状态和错误码已冻结。
- [x] 单张分镜图积分配置、报价有效期和失败积分规则可由后台配置。
- [x] 阿里审核接入沿用现有公共审核能力。
- [x] Java 工程已有用户改动已识别并保护。
- [x] 视频 Provider 提交/查询契约与 Mock 全链路已通过。
- [ ] 真实视频 Provider 账号、密钥和额度由联调环境提供，不写入仓库。
- [ ] 首页之外的 Flutter 页面完成后进入前后端联调。

## 14. 执行记录

| 时间 | 任务 | 操作 | 结果 |
|------|------|------|------|
| 2026-07-21 | Java 总体计划 | 基于已确认的 Flutter/Java 技术文档生成总体开发计划 | `waiting_review` |
| 2026-07-21 | Java 总体计划确认 | 用户要求进入下一步，v1.0 确认为模块拆分基线 | `done` |
| 2026-07-21 | 数据隔离模块文档 | 生成 catseller schema、迁移、安全、默认配置和跨 App 隔离的编码级文档 | `waiting_review` |
| 2026-07-21 | Java 全部模块文档 | 按用户要求批量生成草稿、首页、脚本、图片、视频、计费、任务、后台和验收共 10 份文档 | `waiting_review` |
| 2026-07-21 | Java 00～09 实现 | 完成 Schema、业务接口、独立工作流、积分审核、生命周期、后台和公共复用 | `done` |
| 2026-07-21 | Java 全量验收 | 完成 catseller 集成测试和既有 44 条失败基线修复；H2 与 PostgreSQL 15 迁移通过，并完成全量测试、构建与差异检查 | `done` |
| 2026-08-11 | 智能视频时长 | 增加时长模式、AUTO 脚本出参校验、脚本版本最终秒数、分镜衔接、报价快照与 Provider 传递；直接修订未部署 V3.6 | `done`，952 条测试、`./gradlew build`、OpenAPI 断言和差异检查通过 |

## 15. 下一步

Java 后端已完成，流程停在前后端联调与验收。下一步由 Flutter 按已确认契约接入，不自动开始 Flutter 编码。

## 16. CHG-0042 智能时长完成条件

- 创建、更新和 OpenAPI 正确区分 `FIXED / AUTO`，AUTO 禁止携带请求秒数。
- 三种作品场景的脚本都能生成 5～60 秒严格整数，分镜、脚本版本、报价、快照和视频 Provider 使用同一最终秒数。
- 固定时长历史行为、内容六步、视频十二步、审核、计费和发布流程保持不变。
- V3.6 在空库执行成功，完整测试、构建、OpenAPI 和差异检查通过。
## CHG-0044：详情编辑接口任务

- [x] 为 input PATCH 增加 `INPUT_EDIT / DETAIL_EDIT` 枚举，缺省兼容旧客户端。
- [x] 增加标题与分镜 DTO 校验、非法模式混用拦截、完成态/活动任务门禁、归属和版本校验。
- [x] 在同一事务中更新标题或多分镜，重算脚本快照与哈希，并保证任一冲突整体回滚。
- [x] 保持作品、工作流、当前脚本指针、当前/发布视频和 `lastUsedAt` 不变。
- [x] 更新 OpenAPI 枚举说明并覆盖默认兼容、越权、非完成态、版本冲突、回滚和状态不变测试。
- [x] 不新增或修改数据库迁移，不进入 Admin 工程。
