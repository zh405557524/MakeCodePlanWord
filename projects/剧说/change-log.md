# 剧说 研发变更日志

> 规则来源：`.cursor/rules/00-核心工作流程.mdc` 第五步「变更管控与版本化记录」
> 用途：跨迭代累积面向研发的变更日志，按 semver 版本号汇总。
> 当前说明：项目已完成 Figma 直读版 PRD、技术方案、Flutter 工程骨架、Java 后端文档链路、Java T-B001 至 T-B011 后端编码、App 首页热门案例管理、邀请好友闭环、兑换码补充能力和积分任务中心。

---

## 版本号规则

- `patch++`：编码期局部修改、缺陷修复、文案 / 资源调整。
- `minor++`：新增功能 / 模块，无破坏性。
- `major++`：架构调整、不兼容改动、推翻重做。

---

## v0.8.0 - 2026-06-08

> 关联阶段：跨端功能变更 / CHG-0012 积分任务中心
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`/Users/soul/code/lxwx/narrate/**`、`/Users/soul/code/lxwx/lxwx_admin/**`、`projects/剧说/**`

### Added

- 新增 App 积分任务中心：`/task-center` 路由、总积分展示、连续签到卡片、每日邀请好友任务、签到接口调用和 mock 数据。
- 新增 App「我的」页「任务中心」入口，位置固定在「支付订单」上方。
- 新增后端任务中心能力：用户侧概览接口、签到接口、签到记录表、`TASK_CHECKIN` 积分账本类型、后台规则查询与更新接口。
- 新增后台 Web「任务中心」配置页，支持任务中心开关、7 天签到奖励、邀请任务标题、说明、目标人数、奖励展示文案和按钮文案。
- 新增 App 与后台 Web 测试覆盖任务中心模型、入口顺序、任务中心 mock 展示、签到后积分更新和后台规则保存。

### Changed

- App 任务中心 UI 参考用户提供图片的信息层级，但视觉使用剧说现有深色背景、暗色卡片和荧光黄绿主色。
- 第一版每日任务只保留邀请好友；视频、插屏、广告任务不展示，也不接广告 SDK。
- 邀请任务复用既有邀请奖励，不在任务中心额外发放二次积分。
- 补齐 CHG-0012 新增 App、后台 Web、Java 后端代码的业务注释 / Javadoc，覆盖模型字段、API facade、controller、service、DTO/VO、Entity 和页面关键方法。
- 后端用户反馈提交接口补充兼容 `POST /api/feedback`，同时保留既有 `POST /api/feedback/datafeed`，用于满足既有集成测试与 App 候选接口口径。
- App 任务中心「去邀请」按钮改为直接打开「推广素材」页面，减少从邀请首页再进入素材页的中间步骤。

### Verification

- `/Users/soul/code/lxwx/lxwx_service/lxwxservice`: `./gradlew test` 通过。
- `/Users/soul/code/lxwx/narrate`: `flutter analyze`、`flutter test` 通过。
- `/Users/soul/code/lxwx/lxwx_admin`: `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。
- 2026-06-08 18:22 返工验证：上述三端命令重新执行通过。
- 2026-06-08 18:44 UX 调整验证：`/Users/soul/code/lxwx/narrate` 执行 `flutter analyze`、`flutter test` 通过。

### Rolled back

- （暂无）

---

## v0.7.0 - 2026-06-02

> 关联阶段：跨端功能变更 / CHG-0011 邀请好友逻辑与兑换码补充
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`/Users/soul/code/lxwx/narrate/**`、`/Users/soul/code/lxwx/lxwx_admin/**`、`projects/剧说/**`

### Added

- 新增邀请好友闭环：邀请链接注册、App 内绑定邀请人、注册送 `10` 积分、直接会员返佣、后台开启的一层间接返佣、收益账本、收益明细、提现申请和后台提现审核。
- 新增 App 邀请中心，并按 Figma channel `slk656ok` 设计稿落地绑定邀请人、邀请列表、我的收益、收益明细、推广素材、提现、提现记录和佣金说明。
- 新增后台 Web「邀请收益管理」，支持邀请规则、用户代理配置、间接收益资格开关、提现审核、驳回、打款成功和打款失败。
- 新增兑换码能力：后端迁移 `V11__redeem_codes.sql`、App 接口 `POST /api/redeem-codes/redeem`、App「我的」页「支付订单」下方兑换码入口、兑换码页面、后台 Web「兑换码管理」。
- 新增后台兑换码批次创建、启停和兑换记录查询；批次商品类型为积分或会员天数二选一。

### Changed

- 登录请求支持可选 `inviteCode`，注册或首次登录后可自动绑定邀请关系。
- 直接返佣按个人代理等级计算：1 级 `10%`、2 级 `20%`、3 级 `30%`；直邀满 `10` 人后第 `11` 人起按 2 级，满 `30` 人后第 `31` 人起按 3 级。
- 间接收益与个人代理等级明确区分：后台按用户开启，固定 `10%`，只穿一层。
- 会员返佣只针对被邀请人首次开通会员订单；续费会员、再次开通会员和充值积分不返佣。
- 兑换码批次强制单商品规则：同一批次只能发积分或发会员天数，不能同时发放两种权益。

### Verification

- `/Users/soul/code/lxwx/lxwx_service/lxwxservice`: `./gradlew testClasses`、`./gradlew test` 通过。
- `/Users/soul/code/lxwx/narrate`: `flutter analyze`、`flutter test` 通过。
- `/Users/soul/code/lxwx/lxwx_admin`: `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。

### Rolled back

- （暂无）

---

## v0.6.0 - 2026-05-29

> 关联阶段：跨端功能变更 / App 首页热门案例管理
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`/Users/soul/code/lxwx/lxwx_admin/**`、`/Users/soul/code/lxwx/narrate/**`

### Added

- 新增热门案例分类、热门案例、操作审计表，迁移文件为 `V5__home_hot_cases.sql`，避免与云上既有 `V4` Flyway 历史冲突。
- 新增公开接口 `/api/config/home-case-categories`、`/api/config/home-cases`、`/api/config/home-cases/{caseId}/use`，供 App 首页读取动态分类与案例，并统计点击使用次数。
- 新增后台接口 `/api/admin/home-case-categories/**` 与 `/api/admin/home-cases/**`，支持分类新增 / 改名、案例列表、详情、保存、复制、上架、下架、删除、封面上传。
- 新增后台 Web「热门案例管理」页面，包含统计卡片、筛选、分类 Tab、表格、编辑抽屉、App 卡片预览、手机预览、二次确认弹窗。
- 新增后台数据层测试与后端集成测试，覆盖分类可编辑、案例创建、列表筛选、前台读取、使用次数、下架原因必填、删除。

### Changed

- App 首页热门案例从固定分类列表改为后端动态分类，默认种子分类保留「漫剧解说」。
- App 首页案例卡片点击行为改为仅调用使用次数统计接口，不做页面跳转。
- 后台 Web 新增 `file_picker` 用于本地选择封面并上传到后端 `/uploads/home-cases/`。

### Verification

- `/Users/soul/code/lxwx/lxwx_service/lxwxservice`: `./gradlew test` 通过。
- `/Users/soul/code/lxwx/lxwx_admin`: `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。
- `/Users/soul/code/lxwx/narrate`: `flutter analyze`、`flutter test` 通过。

### Rolled back

- （暂无）

---

## v0.5.0 - 2026-05-19

> 关联阶段：14 Java 编码 / T-B003 至 T-B011
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`

### Added

- 新增积分账户、积分流水、冻结、确认扣减、失败退回和支付到账账务能力。
- 新增会员套餐、会员状态、支付订单、mock 支付参数、支付回调幂等和 Provider 事件保存。
- 新增百度 VOD 素材上传凭证、素材列表、草稿、积分预估、生成任务、VOD 回调、作品创建、播放 / 下载地址签发。
- 新增邀请概览、邀请记录、反馈提交、预设配置、静态协议和后台配置预留接口。
- 新增 `V2__seed_app_configs.sql` 默认配置迁移和 `V3__add_idempotency_keys.sql` 幂等字段迁移。
- 新增 `BackendWorkflowIntegrationTests`，覆盖支付到账、重复回调、生成成功 / 失败、作品、邀请、反馈、配置和后台配置。

### Changed

- Gradle 版本号推进到 `0.5.0`。
- 安全路由从只保护用户模块扩展到积分、会员状态、订单、素材、创作、生成、作品、邀请、反馈和后台接口。
- README、workflow、Java 总体计划和 03-07 模块文档同步 T-B003 至 T-B011 完成状态。

### Verification

- `./gradlew test` 通过。
- `./gradlew build` 通过。

### Rolled back

- （暂无）

---

## v0.4.0 - 2026-05-19

> 关联阶段：14 Java 编码 / T-B002
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`

### Added

- 新增 mock 短信验证码发送、60 秒限流、验证码哈希存储、5 分钟有效期和使用状态。
- 新增短信登录、一键登录占位、JWT access token、refresh token 入库和退出登录撤销 refresh token。
- 新增 `/api/user/profile`、`/api/user/logout`、`/api/user/delete-request`，支持我的页用户资料、积分余额和会员状态聚合。
- 新增 JWT 鉴权过滤器和 REST 401 响应，保护 `/api/user/**`。
- 新增 `AuthUserIntegrationTests`，覆盖验证码发送、重复发送、错误验证码、新用户登录、未登录访问、带 token 访问、退出登录和注销申请。

### Changed

- Gradle 版本号推进到 `0.4.0`。
- 后端 README、workflow、Java 总体计划和账号鉴权模块文档同步 T-B002 完成状态。

### Verification

- `./gradlew build` 通过。

### Rolled back

- （暂无）

---

## v0.3.3 - 2026-05-19

> 关联阶段：14 Java 编码 / T-B001 包名修正
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`

### Changed

- 将模板包名统一修正为真实包名 `com.lxwx.narrateservice`。
- Java 源码目录迁移为 `src/main/java/com/lxwx/narrateservice/**`，测试目录迁移为 `src/test/java/com/lxwx/narrateservice/**`。
- 同步修正源码 `package/import`、MyBatis-Plus `@MapperScan`、Gradle group、README 和后端文档包名口径。

### Verification

- `./gradlew build` 通过。

### Rolled back

- （暂无）

---

## v0.3.2 - 2026-05-19

> 关联阶段：14 Java 编码 / T-B001
> 关联产物：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`

### Added

- 在 Java 后端工程落地 `com.lxwx.narrateservice.ServerApplication` 和 `common` 基础设施代码。
- 新增统一响应、分页结构、错误码、业务异常、全局异常处理、traceId、幂等服务、Redis 锁服务、Web / Redis / MyBatis-Plus / Security 配置。
- 新增 `application.yml`、`application-test.yml` 和 `V1__init_schema.sql`，覆盖用户、验证码、积分、会员、支付、素材、生成、作品、邀请、反馈和配置基础表。
- 新增 Spring Boot 上下文测试、后端工程 README 和工程级 `.gitignore`。

### Changed

- 后端 Gradle 工程固定为 Java 21 + Spring Boot 3.3 + Gradle 8.8 wrapper，避免 Spring Boot 3.x 插件与 Gradle 9.x 的兼容冲突。
- `workflow.md`、`java-dev-plan.md`、`01-基础设施.md` 同步 T-B001 完成状态和真实后端工程路径。

### Removed

- 移除旧生成包名的入口和测试文件。

### Verification

- `./gradlew build` 通过。

### Rolled back

- （暂无）

---

## v0.3.1 - 2026-05-19

> 关联阶段：12 Java 模块开发文档
> 关联产物：`projects/剧说/04-后端/**`

### Changed

- Java 后端项目结构调整为 `com.lxwx.narrateservice`、`ServerApplication.java`、`common/auth/user/product/order/payment/entitlement/app/admin` 分层。
- `java-tech.md` 调整工程目录树，使用 `common/response`、`auth/infra`、`payment/channel/*`、`app/*`、`admin` 等目录。
- `java-dev-plan.md` 和 7 份模块开发文档同步调整模块归属与代码清单路径。

### Removed

- 移除 Java 后端文档中的旧包名和旧目录树口径。

### Rolled back

- （暂无）

---

## v0.3.0 - 2026-05-19

> 关联阶段：8 后端 Java 技术文档 / 10 Java 总体开发计划 / 12 Java 模块开发文档
> 关联产物：`projects/剧说/04-后端/**`

### Added

- 新增 `projects/剧说/04-后端/java-tech.md`，固定 Java 21 + Spring Boot 3.x + Gradle + PostgreSQL + Redis + MyBatis-Plus + Flyway + JWT + 百度 VOD 后端技术方案。
- 新增 `projects/剧说/04-后端/java-dev-plan.md`，拆分 T-B001 至 T-B011 后端总体开发任务。
- 新增 7 份 Java 模块开发文档：基础设施、账号鉴权与用户、积分账务、支付会员、百度 VOD 素材与生成、作品服务、邀请反馈配置。

### Changed

- `projects/剧说/workflow.md` 当前阶段推进到 `12 Java 模块开发文档`，并记录本轮前端开发忽略。
- `projects/剧说/change-plan.md` 归档 `CHG-0004 Java 文档推进到模块开发`。

### Removed

- （暂无研发变更）

### Rolled back

- （暂无）

---

## v0.2.2 - 2026-05-18

> 关联阶段：技术方案 / 后端方案评估
> 关联产物：`projects/剧说/02-技术方案/backend-evaluation.md`

### Changed

- 视频业务处理从“供应商待确认”推进为接入百度智能云智能点播平台 VOD。
- `backend-evaluation.md` 补充 `BaiduVodProvider`、VOD 媒资字段映射、VOD 回调入口、`VIDEO_GENERATE_COMPLETE` 处理和播放 / 下载地址签发策略。
- `tech-plan.md` 与 `workflow.md` 同步百度 VOD 接入口径。

### Removed

- （暂无研发变更）

### Rolled back

- （暂无）

---

## v0.2.1 - 2026-05-18

> 关联阶段：技术方案 / 后端方案评估
> 关联产物：`projects/剧说/02-技术方案/backend-evaluation.md`

### Changed

- 深化 Java + Spring Boot + Gradle 后端评估，补充接口契约草案、生成任务状态机、积分账本规则、支付订单状态和 Provider Adapter 设计。
- `projects/剧说/02-技术方案/tech-plan.md` 同步 Gradle、状态机、账本和 Adapter 口径。

### Removed

- （暂无研发变更）

### Rolled back

- （暂无）

---

## v0.2.0 - 2026-05-18

> 关联阶段：需求分析重新开始
> 关联产物：`projects/剧说/01-需求/requirements-list.md`

### Added

- 新增 `projects/剧说/02-技术方案/backend-evaluation.md`，评估 Java 21 + Spring Boot 3.x + Gradle 后端方案、模块边界、数据模型、外部供应商接入和风险。

### Changed

- `projects/剧说/02-技术方案/tech-plan.md` 从“后端完全待确定”推进为“建议 Java 后端方案，供应商和最终接口仍待确认”。
- `projects/剧说/workflow.md` 同步 Java 后端流程项、当前恢复点和下一步动作。

### Removed

- （暂无研发变更）

### Rolled back

- （暂无）

---

## v0.1.0 - 2026-05-13

> 关联阶段：旧截图版需求到工时评估
> 说明：历史文档已生成到第 6 步，但 2026-05-18 起当前版本改为 Figma 直读版需求分析，旧下游文档需重新同步后才能继续引用。

### Added

- 旧截图版需求清单、PRD、Figma 设计稿计划、技术方案和工时评估文档。

### Changed

- （暂无）

### Removed

- （暂无）

### Rolled back

- （暂无）
