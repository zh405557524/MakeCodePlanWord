# 喵喵写歌 V2.1 Java 总体开发计划

> 版本：`v2.1-model-driven-params` · CHG-0076/0078 第 14 步本地真实实现 `waiting_review` · 更新：2026-09-14
> 依据：[当前 PRD](../01-需求/requirements.md)、[当前技术方案](../02-技术方案/tech-plan.md)、[CHG-0078 增量工时](../02-技术方案/effort-estimate.md)、[Java 技术文档](java-tech.md)、[Flutter/Web 技术文档](../03-前端/flutter-tech.md)。

## 1. 用途、现状与恢复点

本文是 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` **当前 V2.1 参数随模型变化的增量总体计划**，不是重写服务，也不恢复已归档的 CHG-0073 开发计划。现有 `X-App-Code`、Catsinger schema routing、Spring Boot 3 / Gradle / MyBatis-Plus / PostgreSQL、独立业务 Controller、模型映射、积分、审核、资源及歌曲工作流继续使用。声音克隆业务留在 `app/catsinger/voicecover/`；`thirdparty/aimodel/music/` 只描述和适配厂家能力，不拥有 App 任务状态。

当前用户已明确授权本版跳过骨架评审，`implementationMode=direct_implementation`、`implementationPhase=real_review`。B001～B009 已完成本地真实实现，Java 全量 1956 项回归通过；目标环境迁移、算道账号/场景/计费/验证短句与真实可播放闭环仍待第 15 步。

下文第 2～7 节保留授权前的双阶段计划，用于追溯任务边界，不代表当前仍处于 `skeleton_coding`；当前状态以第 8 节最新执行记录和模块索引为准。

## 2. 总体顺序和双阶段门禁

**骨架阶段**：正式 DTO/VO、现有 Controller 的兼容扩展、Service 高层方法和集中 Skeleton Fixture；调用链覆盖读取模型、合成有效能力、校验请求、准备报价、创建任务、查询状态等步骤，但新分支仅在 local/test 返回确定值。`-S` 不新增 Flyway、Entity、Mapper/Repository，不读写新业务数据库，不冻结积分，不做真实审核、上传、Provider 调用、转存或作品创建；生产默认关闭新未完成功能且不得伪造成功。现有生产写歌/改编等已完成路径继续原样运行，不被测试 fixture 接管。

三端骨架整体通过编译、Controller/Service 契约和副作用隔离检查后进入 `skeleton_review`，提供代码地图、调用图、固定数据和 `TODO(REAL-IMPLEMENTATION)` 清单；**必须取得用户明确骨架确认**才能做任何 `-R`。普通“继续/下一步”只能推进允许的文档或骨架工作。

**真实实现阶段**：按“Provider 精确声明 → 有效能力合成/后台合法子集 → 创建前复核 → 计费/任务快照 → App/Admin 联调”的依赖顺序。数据库只在现有训练任务无法保存不可变契约/请求快照且第 12 步给出证据时做 catsinger 专属最小增量迁移；不预先修改 V1/V12 或 common/narrate。每个新任务在积分冻结和厂家调用前拒绝无效参数，已有任务/作品不被改型或重算。

## 3. 状态、时间和跨端里程碑

状态为 `pending / in_progress / waiting_review / done / blocked`；每个 `-S`、`-R` 分别记录验证结果和恢复点，不能用骨架 `done` 推导真实实现 `done`。每项完成证据至少包含影响类/接口、DTO 兼容、定向测试、失败/未覆盖项和下一依赖。线上 Bug 修复独立记录，不借机推进本版任务。

本节的 Java 约 2 个 8 小时 AI 辅助工作日仅是 **CHG-0076 原参数适配排期**，不代表原任务已完成。CHG-0078 新增工作量另见[当前增量工时](../02-技术方案/effort-estimate.md)，其中 Java 约 2 天、三端骨架审阅准备共 0.5 天；它们属于同一名跨端执行人的 6 天总投入，不能按三人并行压缩。骨架评审等待、线上 Bug 或测试资源缺口使条件日历顺延。

| 里程碑 | Java 可检查产物 | 前置与门禁 |
|--------|------------------|------------|
| M0 文档可编码 | 原 CHG-0076 第 11/12 步模块文档已生成；CHG-0078 需另建增量模块文档 | 新模块目前 `pending`；不得用原模块文档代替 CHG-0078 的门禁 |
| M1 可运行骨架 | B001～B006 的 `-S`，独立接口调用链、固定能力、生产禁用 | `compileJava`、定向契约测试和无副作用证明；全三端共同评审 |
| M2 真实能力 | B001/002/006 的 `-R`，精确模型能力、后台交集、版本/价格快照 | 用户明确确认骨架；无证据模型保持 `NOT_DECLARED` |
| M3 业务复核 | B003～B005 的 `-R`，四入口冻结前拦截并走旧平台流程 | 成功/失败/幂等/旧客户端与 narrate 隔离回归 |
| M4 用户验收 | App/Admin 真实配置、训练/翻唱/写歌/改编、资源与可播放作品 | 第 15 步 Android+iOS 用户测试；服务测试不能替代 |

## 4. Java 任务清单

任务编号与[当前技术方案](../02-技术方案/tech-plan.md)的 T-B001～T-B006（原 CHG-0076）一一对应。每行有两个独立任务；所有 `-R` 除本项 `-S` 外，都依赖整个三端骨架评审通过。

| ID / 所属模块 | `-S` 骨架：高层步骤与固定响应 | `-R` 真实实现及完成条件 | 依赖 |
|---------------|--------------------------------|-------------------------|------|
| `T-B001` Provider 能力 | `T-B001-S`：在 `thirdparty/aimodel/music/` 声明四种操作的接口/标准键，受控 fixture 返回确定的支持、未知、禁用模型；不调用厂家 | `T-B001-R`：仅给有证据的算道精确模型/操作填硬约束；未知 `NOT_DECLARED`，Provider 请求前拒绝未声明或越界可选参数；SoVITS/Suno 不推定互通 | 现有 `IMusicModelService`，厂家证据 |
| `T-B002` 有效契约 | `T-B002-S`：在 `core/ai/aiconfig/` 建合成 Service 步骤，扩展现有响应的 `contractVersion/effectiveParameters/mediaConstraints` 目标结构；训练/克隆返回同语义固定结构 | `T-B002-R`：厂家声明 ∩ 后台合法子集、默认/范围/原因/稳定版本；兼容旧 `parameters` 与旧声音 `capabilityLimits`；公开响应脱敏，后台保存不可扩大厂家能力 | B001、现有场景映射 |
| `T-B003` 写歌/改编 | `T-B003-S`：现有两条 Service 插入“解析模型→有效契约→逐参数/互斥校验→报价→任务”的可读方法调用，测试路径固定返回且不冻结 | `T-B003-R`：真实在冻结前校验有效可选键、纯音乐与歌词/音色互斥、改编原词策略，拒绝禁用旧值；保留旧业务 `mode`、幂等和作品归属 | B002/B006、现有 `generation/cover/` |
| `T-B004` 本人音色训练 | `T-B004-S`：现有训练 Service 增加按训练模型检查媒体、审核与效果提醒的步骤；受控数据展示硬边界与非阻断建议 | `T-B004-R`：按厂家明确硬条件及平台安全限制验素材；移除无依据分钟硬门槛及强制效果确认，仍遵本人/审核/报价/任务链路 | B001/B002/B006、现有 `voicecover/` |
| `T-B005` 声音克隆翻唱 | `T-B005-S`：现有克隆 Service 显式检查源整曲、音色状态/精确兼容、可选设置、价格，再委托任务；固定响应不生成作品 | `T-B005-R`：真实兼容绑定和模型上限、源资源审核事实、报价前复核；未选参数不因 `normalized()` 注入成用户已提交值；旧改编不变 | B001/B002/B006、现有 `voicecover/` |
| `T-B006` 价格与快照 | `T-B006-S`：正式版本/价格校验 DTO 与高层步骤，集中 fixture 给固定模型和价格，生产禁用假结算 | `T-B006-R`：现有计费目录重取价格、比较版本、幂等冻结/失败释放、保存不可变有效请求；只有证实缺快照字段才追加 catsinger 专属迁移并覆盖旧数据查询 | B002、现有计费/任务/资源 |

**不做平行平台**：不新建第二套任务中心、积分流水、审核表或资源台账；不会为了本次逐模型参数改动把旧 `COVER` 作品转成 `VOICE_COVER`。`app_code` 继续防御/审计，真实隔离依赖 schema routing；管理员身份与 App 切换由原有管理块授权。

## 5. API 与数据任务对照

以下是**已有或目标兼容扩展**，不是宣布新增接口已上线。`依赖表/数据` 写明本版是否新建表；骨架阶段一律不访问这些真实数据。正式 DTO/VO 以现有 Controller 实际字段为准，扩展前对照 Flutter 技术文档和 `/v3/api-docs`，不在计划里发明另一套 wire shape。

| 任务 | 方法与路径 | 依赖表 / 数据 | Service/边界 | 状态 |
|------|------------|---------------|--------------|------|
| B001/B002 | `GET /api/ai-model-options?sceneCode=song.generate|song.cover.generate` | 现有场景映射、模型配置、计费目录；无新表 | `AiSceneModelMappingService` 合成有效契约；Provider 只描述硬能力 | `pending` |
| B001/B002 | `GET /api/song-config/models?sceneCode=song.voice.train|song.voice.cover.generate` | 同上，现有声音配置；无新表 | `VoiceCoverConfigService` 复用同一合成逻辑，保留旧字段兼容 | `pending` |
| B003/B006 | `POST /api/song-generations` | 现有歌曲任务、积分及快照；不预设新表 | 写歌 Service 固定写歌语义、冻结前复核 | `pending` |
| B003/B006 | `POST /api/song-covers` | 现有改编任务、资源与积分；不预设新表 | 改编 Service 保持旧 `COVER` 业务类型 | `pending` |
| B004/B006 | `POST /api/song-voice-training-tasks` | 现有音色资料/训练任务；快照字段待证实 | 训练 Service 只按厂家硬限制与平台安全限制拦截 | `pending` |
| B005/B006 | `POST /api/song-voice-covers` | 现有声音克隆任务/作品/资源；不预设新表 | 克隆 Service 服务端固定 `VOICE_COVER` | `pending` |
| B002/B006 | `GET/POST/PUT /api/admin/ai-scene-model-mappings` 及现有模型/计费管理入口 | `ai_scene_model_mappings.metadata_json` 等既有配置；无新表 | Admin 保存 Service 校验合法子集、版本、App/角色权限 | `pending` |
| B003～B005 | 上述业务的现有任务查询/active 与作品接口 | 现有任务/作品/资源台账；无新表 | 任务恢复、成品审核与播放沿原工作流，不改公开路径 | `pending` |

`contractVersion` 是能力/后台配置版本，`pricingVersion` 是价格版本，不可混用。响应保留 `operationType/status/parameters`，新增 `effectiveParameters[]` 的 `key/supported/editable/reasonCode/reasonText/constraints/effectiveDefault` 和 `mediaConstraints`。旧客户端不带新增版本时服务端也必须重验；不支持/越界/未知/互斥参数返回字段级错误，且不产生冻结或厂家调用。价格若今后随具体参数组合变化，先回卷方案，不在此处虚构报价接口。

## 6. 第 12 步模块文档清单（已生成，待整体评审）

[本版模块索引](开发计划/00-module-index.md) 为唯一入口；01～08 文档已按 Controller → Service → 现有 Mapper/Entity/必要迁移 → 定向测试拆分 `-S/-R`，当前为 `waiting_review`，并未修改 Java/数据库。无数据库改动的模块明确“无新迁移”，不能沿用归档旧表清单。

| 模块文档（拟定） | 对应任务 | 必要对账 |
|------------------|----------|----------|
| `01-provider-capabilities.md` | B001-S/R | 四操作、厂家证据、未知状态、标准键 |
| `02-effective-contract.md` | B002-S/R | 模型与后台交集、版本、公开响应、Admin 保存验证 |
| `03-song-and-adaptation.md` | B003-S/R | 两业务独立入口、互斥/原词、冻结前拒绝 |
| `04-voice-training.md` | B004-S/R | 训练硬限制与效果建议、审核事实 |
| `05-voice-clone-cover.md` | B005-S/R | 精确音色绑定、源歌曲和参数缺省 |
| `06-pricing-snapshot.md` | B006-S/R | 价格版本、幂等、任务快照与必要时 catsinger 迁移 |
| `07-admin-and-security.md` | B002/B006 与 W001/W002 契约 | App/角色、合法配置、旧 metadata 兼容 |
| `08-verification.md` | B001～B006 及第 15 步移交 | local/test 与生产门禁、跨 App、旧客户端和真实可播放 |

## 7. 编码与验证约束

- 保留现有包结构和 `ApiResponse`，控制器只做鉴权/参数入口，高层业务步骤留在 Service；Provider adapter 不冻结积分、不写作品。新增公共 wire 字段先与 Flutter/Web 同版本技术及模块文档对齐。
- 骨架 `TODO(REAL-IMPLEMENTATION)` 与固定响应集中管理，固定模型/价格/原因/任务 ID 确定可重复；local/test 显式启用，生产默认关闭。测试要证明骨架不触数据库、积分、审核、上传、Provider、资源转存，也证明生产不返回伪造成功。不要让已有生产写歌/改编回退到假数据。
- 真实实现按受影响范围运行 Gradle 定向测试；公共能力合成涉及四场景和 Admin，应扩大到跨业务/跨 App 回归。必要时跑 `./gradlew test`、`./gradlew build`，不要把仅编译写成真厂家训练成功。迁移有证据才写，`db/migration/catsinger/` 追加版本，验证干净 schema 与既有数据，不改历史 V1/V12。
- 后台配置需验证模型能力只读、保存越界拒绝、普通角色越权拒绝、`X-App-Code` 切换不串；真实任务验证审核、冻结/扣减/失败释放、幂等、临时资源持久化及成品可播放。Android/iOS 真机用户测试仍归第 15 步，缺 iOS 真机与模拟器则双平台验收失败。
- 文档或骨架阶段不触线上环境、真实价格、付费、删除或厂家请求。发现当前代码与计划不符，先在本版 CHG 做影响分析并更新技术/模块文档，不借用旧版模块计划。

## 8. 执行记录

| 日期 | 结果 | 状态 / 下一恢复点 |
|------|------|-------------------|
| 2026-09-13 | 根据当前 PRD、技术方案、第 7/8 步文档及条件排期生成 Java 增量总体计划；未建模块文档，未改 Java、数据库或配置 | 本文 `waiting_review`；下一步第 11/12 步模块文档，骨架仍为 `skeleton_pending` |
| 2026-09-13 | 第 12 步已生成本版索引与 01～08 模块文档，覆盖 B001～B006 的独立 `-S/-R` 和 Admin/安全配套；未改业务代码或数据库 | 本总体计划作为输入记 `done`；模块文档 `waiting_review`，骨架仍为 `skeleton_pending` |
| 2026-09-14 | 用户要求继续，进入第 14 步；B001-S 已补四操作与受控 Fixture，B002-S 已加兼容响应结构，尚未接正式查询；Java 模型定向测试通过，生产未启用 Fixture。数据库改动：无 | B001-S `done`，B002-S `in_progress`，其余 `-S/-R` `pending`；整体 `skeleton_coding` |
| 2026-09-14 | 用户确认 CHG-0078 第 7/8 步技术增量后，在本计划增写第 9 节；原 CHG-0076 骨架及并行线上 Bug 状态不改 | B007～009 的 `-S/-R` 均 `pending`；第 12 步新模块待建，本增量 `waiting_review`，未改代码/迁移 |
| 2026-09-14 | 用户继续第 11/12 步，已生成 CHG-0078 后端 09～12 增量模块文档并接入索引；原 01～08 不改 | 本总体计划第 9 节作为已确认输入记 `done`；新增模块文档 `waiting_review`，B007～009 的 `-S/-R` 仍 `pending`；未改代码/迁移 |
| 2026-09-14 | 用户明确授权本版三端跳过骨架评审、直接真实实现。已接四场景厂家能力/后台有效契约与提交校验，以及 Catsinger 首页海报发布审核、注册赠额配置、新人礼状态和 V4.10 迁移。定向架构/OpenAPI/配置/schema 测试通过 | 第 14 步 `in_progress`；V4.10 尚未部署，设备/厂家/积分/审核联调未验收；全量 Gradle 测试因 OOM 和其他旧用例失败中止 |
| 2026-09-14 | 修复歌曲轨道审核、标题/歌词时间轴一致性、参考音频纯音乐参数、积分周期和历史测试预期；完成算道动态输出格式持久化对账。`./gradlew test` 全量 1956 项通过，0 失败、0 错误、3 跳过 | 第 14 步转 `waiting_review`；目标迁移和真实算道 Provider/场景/计费/审核/积分/播放闭环仍归第 15 步验证 |

## 9. CHG-0078 首页运营与新用户权益增量总体计划

### 9.1 用途、依赖和执行顺序

> 本版执行覆盖：用户已授权 `direct_implementation / real_coding`。本节原“仅骨架/无迁移”段落是授权前历史；当前已有 Catsinger 专属 V4.10 迁移，未在目标库执行。原 local/test Fixture 仍保持生产禁用。

本节只处理 PRD P01/W08/W09 的后端增量：公开首页海报、Catsinger 注册赠额配置与新人礼资格。沿用现有 `X-App-Code: catsinger`、`AppContext` schema routing、`app_configs`、`UserService.createUser → grantDefaultPointsForNewUser → PointsService.grantPermanent` 及 `NEW_USER:{userId}` 幂等。游客绑定同一账号不重发；旧积分流水、narrate 及其他 App 行为不改。三类创作业务仍分别使用原有独立 API，本节**不**新建/改写歌曲任务类型、积分流水或作品链。

第 12 步模块文档已确认；B007～009-S 的 local/test 骨架已写并通过定向 Gradle 测试，状态 `waiting_review`，全部 `-R` 为 `pending`。项目级 `implementationPhase=skeleton_coding` 同时包含原 CHG-0076 未完成骨架，不代表整体评审通过。任务状态仍逐阶段记录；本轮没有数据迁移、数据库/积分/审核写入。

执行顺序：`B007-S/B008-S/B009-S` 的正式 Controller/Service/DTO 与集中 fixture → Flutter/Web 同路径 UI 骨架 → 三端一起审阅 → 用户**明确确认骨架** → `B007-R` 配置与发布共校验 → `B008-R` 既有建号赠额配置读取 → `B009-R` catsinger 资格状态/频控 → Flutter/Web 真联调 → 第 15 步双平台用户测试。Java 真实模块间可按依赖调整，但不得把 `-R` 移到骨架审阅前。

### 9.2 容量与里程碑

共用[CHG-0078 六日排期](../02-技术方案/effort-estimate.md)：同一名 AI 辅助跨端执行人每天 8 小时，Java 约 2 天；Flutter 1 天、Web/Admin 1 天、三端骨架与审阅准备 0.5 天、Android/iOS 用户测试 1 天、Bug 修复回归 0.5 天。不是三个角色各自满载的并行估算。9 月 16～24 日为附条件日期，评审、审核素材或设备延迟时整体顺延；不能把等待时间记为开发完成。

| 里程碑 | Java 可检查产物 | 退出条件 |
|--------|------------------|----------|
| H0 文档可编码 | 本计划第 9 节与第 12 步新增模块文档、前端第 11 步契约同版 | 任务 ID、路径、字段、状态和禁做范围一致；未生成模块前不能编码本增量 |
| H1 可运行骨架 | B007～009-S：正式 API 路径、DTO/VO、Service 业务步骤和受控固定响应 | `compileJava`/定向契约验证；生产默认拒绝 fixture，不能读写业务 DB/积分/审核；整体 `skeleton_review` 后暂停 |
| H2 真实规则 | B007～009-R：海报原子发布、Catsinger 建号赠额读取、弹窗资格和频次 | **用户明确确认骨架**；旧业务、其他 App 和历史账号不受影响 |
| H3 联调验收 | Admin 写配置后 App 真实读取；新账号积分/弹窗结果可查 | 第 15 步 Android+iOS 和服务端流水、状态对照；失败不标 PASS |

### 9.3 Java 任务清单（每个后缀单独推进）

| 任务与归属 | `-S` 骨架：方法调用及完成条件 | `-R` 真实实现及完成条件 | 依赖 / 当前状态 |
|------------|--------------------------------|-------------------------|------------------|
| `T-B007` 海报与配置共校验，`app/catsinger/config/`、`admin/song/` | `T-B007-S`：用户端 `home-banners` 与 Admin `home-banners` DTO/Controller→Service→集中 Skeleton Fixture；方法显式校验 App/权限/配置/资源/目标，返回确定的两张海报，仅 local/test | `T-B007-R`：复用 Catsinger `app_configs`、现有上传审核/安全 URL 投影、配置版本/原子整份发布；阻止删停最后一张；**专用和通用 Admin 写入口同校验**，跨 App/无权限拒绝并审计 | 现有配置、资源及权限服务；`-S=waiting_review`（资源/角色仅占位），`-R=pending` |
| `T-B008` 新账号赠额，`core/user/service/UserService` 的 Catsinger 分支与配置规则 | `T-B008-S`：正式 `new-user-points` 管理 DTO/Controller、读取/校验/兜底高层步骤，受控 fixture 给 30；不改真实建号、不调用 `PointsService` | `T-B008-R`：仅 Catsinger 从 `song.new_user_points` 读有效正整数，缺失/非法回退 30、数据库故障照原失败；新账号沿原 `NEW_USER:{userId}` 发一次，绑定/历史不重发；其他 App 保留旧额 | B007 共校验/既有建号；`-S=waiting_review`，`-R=pending` |
| `T-B009` 新人礼，`app/catsinger/config/` 资格 Service 与 Admin 配置 | `T-B009-S`：`new-user-gift` 查询/曝光/稍后/领取正式 DTO/Controller/Service 方法；fixture 覆盖应弹/不弹/已领，但**不**创建表、不真实计数 | `T-B009-R`：Catsinger 专属状态迁移与原子资格更新、固定上线资格起点、`ONCE/DAILY/PER_OPEN` 频次、令牌去重与精准撤销；领取只跳签到/任务，不调用赠积分，Admin 共校验启停/人群/素材/目标 | B007 共校验、现有账号/资源鉴权；`-S=waiting_review`，`-R=pending` |

`B007～009-R` 只在整体骨架评审获明确确认后启动。骨架中固定数据集中在已有受控 fixture 体系，不散落在 Controller；所有真实存储/审核/发积分/发布副作用标 `TODO(REAL-IMPLEMENTATION)`，生产配置默认关闭新功能或明确拒绝，不影响现有已上线接口。真实阶段只在 `db/migration/catsinger/` **追加**新人礼资格状态表；不改历史 V1/V12、common、narrate。`app_configs` 是既有表，海报/赠额/弹窗不新建三张配置表。具体表名、唯一键、下一个迁移号及实体类型由第 12 步读现有迁移后定稿，计划阶段不猜测。

### 9.4 API 接口任务表与数据边界

以下是**待实现**契约，字段与[Java 技术文档第 9 节](java-tech.md)、[Flutter/Web 第 8 节](../03-前端/flutter-tech.md)同义。沿用现有 `ApiResponse`、App Token 与 Admin Token；不新增同义路线或改 `POST /api/song-generations`、`/api/song-covers`、`/api/song-voice-covers`。

| 任务 | 方法与路径 | 依赖数据 | Service/行为 | 状态 |
|------|------------|----------|--------------|------|
| B007 | `GET /api/song-config/home-banners` | Catsinger `app_configs` 的 `song.home.banners`、已审核资源 | 投影有序 `items[{id,imageUrl,targetCode?}]`；静态目标为 `null` | `pending` |
| B007 | `GET/PUT /api/admin/song/home-banners` | 同一配置键、资源审核/发布记录 | `song_config` 权限、至少一张有效、版本比较；通用配置写入口同验 | `pending` |
| B008 | `GET/PUT /api/admin/song/new-user-points` | `song.new_user_points`、现有用户/流水 | 金额正整数/有界；只改后续新账号，非法内容兜底 30 | `pending` |
| B008 | 原 `UserService.createUser` 建号发放点 | 既有 `users`、`point_ledgers`、`app_configs` | 新建时读取当前 Catsinger 配置并沿 `NEW_USER:{userId}` 幂等记账；不另建领积分接口 | `pending` |
| B009 | `GET /api/song-config/new-user-gift`（登录态） | `song.new_user_gift`、现有用户与拟增资格状态 | `shouldShow/impressionToken?/imageUrl?/text?/targetCode?/configVersion?`；`openId` 仅辅助每次打开 | `pending` |
| B009 | `POST /api/song-config/new-user-gift/impressions` | Catsinger 资格状态 | `{impressionToken,openId?}`；实际显示后按账号/令牌幂等确认曝光 | `pending` |
| B009 | `POST /api/song-config/new-user-gift/dismiss` | Catsinger 资格状态 | `{impressionToken}`；仅撤销当前匹配曝光，不减少别人次数 | `pending` |
| B009 | `POST /api/song-config/new-user-gift/claim` | Catsinger 资格状态 | `{impressionToken}`；一次 `claimedAt`，返回 `targetCode?`，无任何赠积分调用 | `pending` |
| B009 | `GET/PUT /api/admin/song/new-user-gift` | `song.new_user_gift`、审核资源、后台审计 | `song_config` 权限，合法频次/人群/目标/资格起点；保存冲突明确拒绝 | `pending` |
| B007～009 | 现有通用 `PUT /api/admin/configs/{configKey}`（仅上述三个 key） | Catsinger 对应 `app_configs` | 委托相同验证/发布服务；禁止绕过最后一张/赠额/目标审核 | `pending` |

资格状态真实实现建议按 `user_id` 唯一、`claimed_at` 和当前曝光令牌/自然日/打开标识存于 Catsinger schema；以账号 `createdAt` 和不可移动的上线资格起点限制“只影响之后符合条件的新用户”。`DAILY` 按 Java 技术文档的 `Asia/Shanghai` 自然日，`PER_OPEN` 仅用冷启动 `openId` 辅助；「稍后领取」撤回**本次**曝光且不结束资格，领取成功永久结束。认证/权限、资源审核和并发逻辑在 Service 事务层，Controller 只解析 DTO。Admin 任意入口的无效配置均拒绝发布；生产读取历史坏值时，**仅赠额内容错误**可回退 30，DB/积分失败不可伪装正常赠送。首批两张海报必须有审核通过资源才可发布；素材未就绪不能用不受控远程图冒充通过。

### 9.5 第 12 步增量模块文档与验证

已在[当前后端模块索引](开发计划/00-module-index.md)下追加 CHG-0078 专区，下列 4 份模块文档已确认，B007～009 的 `-S` 待代码审阅；**不表示真实配置或迁移已完成，也不改原 01～08 完成记录**。各模块细化 Controller/Service/DTO、需要的 Mapper/Entity/迁移（仅 `-R`）、接口状态/错误、鉴权、定向测试、`-S/-R` 恢复点。

| 已建文件 | 任务 | 重点 |
|----------|------|------|
| `09-home-banners.md` | B007-S/R | 资源审核、目标白名单、原子发布和通用入口同验 |
| `10-new-user-points.md` | B008-S/R | 既有建号时点、坏配置兜底、原流水幂等与跨 App |
| `11-new-user-gift-state.md` | B009-S/R | Catsinger 迁移、资格起点、时区、曝光/稍后/领取并发 |
| `12-home-benefit-verification.md` | B007～009 与 T-Q002 | 生产禁用骨架、Admin 权限、Android/iOS 流水与 UI 对照 |

骨架定向验证：`./gradlew compileJava --offline` 及 `./gradlew test --offline --tests '*SongHomeBenefitSkeletonServiceTests'` 通过；注解检查 local/test 且需显式开启属性，未做真实 HTTP 生产态联调。真实实现后按范围执行 Gradle 定向测试：配置缺失/非法与数据库故障区分、`NEW_USER:{userId}` 幂等、并发删最后海报、频次/时区边界、稍后精准撤销、双设备重复领取、Admin 越权/跨 App、旧 narrate 登录/积分不变；共享基础设施确有改动时扩大到全量回归。第 15 步使用 Android+iOS 与后台实际配置核对**真实新账号**流水和领取态，不能把 mock 或接口 200 当成用户功能通过。当前不改迁移、不部署，等待整体骨架确认。
