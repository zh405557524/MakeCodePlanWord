# 剧说 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录“剧说”当前流程进度、总体流程列表、恢复点、依赖文件、变更登记和注意事项。
> 当前用户要求：新增 CHG-0012 积分任务中心，入口放在 App「我的」页「支付订单」上方；跨端闭环实现；第一版保留连续签到和邀请好友任务，不做广告任务；用户提供图片作为信息架构参考，视觉与当前 App 保持一致；用户指出新增代码需按工程编码规范补齐业务注释；随后要求任务中心「去邀请」直接跳到推广素材页面。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `剧说` | 工作空间根目录名 |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/剧说` | 唯一允许写入流程文档的项目工作区 |
| `currentVersion` | `v0.8.0` | 积分任务中心跨端编码版本 |
| `iterationMode` | `version_iteration` | 已有 CHG-0001 ~ CHG-0012 历史变更，按版本迭代处理 |
| `baseArchiveVersion` | `none` | 当前未指定需要对照的历史归档 |
| `currentRequirementEntry` | `01-需求/requirements.md` | 当前需求主入口 |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md` | 当前技术方案主入口 |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | 当前 Flutter 计划主入口 |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md` | 当前后端计划主入口 |
| `archiveIndex` | `archive/` | 旧版快照归档目录；仅用于追溯、差异对比、回滚和验收争议 |
| `referenceProject` | 空 | 暂无参考工程 |
| `frontendRepo` | `/Users/soul/code/lxwx/narrate` | Flutter 工程路径 |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | Java / Gradle 后端工程根目录 |
| `flutterChannel` | `stable` | 暂按 stable |
| `backendFramework` | `Spring Boot` | Java 后端框架固定：Spring Boot |
| `backendBuildTool` | `Gradle` | Java 后端构建工具固定：Gradle |
| `targetStores` | 待确认 | AppStore / Google Play / 国内商店暂未确认 |

---

## 1.1 当前主文档入口与归档索引

> 工作区主路径永远保存当前最新可执行文档；`archive/` 只保存旧版快照，状态统一为 `reference-only`。

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 需求 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/detection-feedback.md` | `active` | 当前需求、PRD 和检测反馈入口 |
| 技术方案 | `02-技术方案/tech-plan.md`、`02-技术方案/effort-estimate.md` | `active` | 当前技术方案和工时入口；本项目工时评估曾按用户要求跳过 |
| 前端 | `03-前端/flutter-tech.md`、`03-前端/flutter-dev-plan.md`、`03-前端/开发计划/` | `active` | 当前 Flutter 技术文档、总体计划和模块计划入口 |
| 后端 | `04-后端/java-tech.md`、`04-后端/java-dev-plan.md`、`04-后端/开发计划/` | `active` | 当前 Java 技术文档、总体计划和模块计划入口 |

| 归档目录 | 来源版本 / CHG | 归档内容 | 状态 | 说明 |
|----------|----------------|----------|------|------|
| `archive/` | 后续迭代按需创建 | 旧版主文档镜像 | `reference-only` | 仅在差异对比、回滚、追溯或验收争议时读取 |

---

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `跨端功能变更` |
| 当前步骤 | `CHG-0012 积分任务中心跨端编码与验证` |
| 当前步骤状态 | `done` |
| 当前恢复点 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice`、`/Users/soul/code/lxwx/narrate`、`/Users/soul/code/lxwx/lxwx_admin`、`projects/剧说/change-plan.md`、`projects/剧说/change-log.md`、`projects/剧说/01-需求/积分任务中心需求文档.md`、`projects/剧说/02-技术方案/积分任务中心技术文档.md`；2026-06-08 已完成 CHG-0012-R1 注释规范返工并通过三端验证；2026-06-08 已完成 CHG-0012-R2 任务中心邀请任务直达推广素材并通过 App 验证 |
| 下一步默认动作 | 等待用户确认后进入 `15 联调与测试 QA` |

---

## 3. 总体流程列表

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `projects/剧说/change-plan.md` | `done` | 已补齐变更计划骨架；本轮是从头重启需求分析，不登记局部 CHG |
| 1 | 需求分析 | `projects/剧说/01-需求/requirements-list.md` | `done` | 已按 Figma Page 1 的 20 个 frame 重新整理需求清单，并确认主要缺失页为 3 个 |
| 2 | 需求文档生成 | `projects/剧说/01-需求/requirements.md` | `done` | 已生成 Figma 直读版 PRD |
| 3 | 需求文档检测 | `projects/剧说/01-需求/detection-feedback.md` | `done` | PRD 检测 PASS，允许进入技术方案 |
| 4 | Figma 设计稿计划 | `projects/剧说/01-需求/figma-design-plan.md` | `skipped` | 用户说明本轮直接查看 Figma 现有图，少走生成 Figma 设计稿这一步 |
| 5 | 技术方案 | `projects/剧说/02-技术方案/tech-plan.md`、`backend-evaluation.md` | `done` | 已深化 Java + Spring Boot + Gradle 后端方案评估；视频业务接入百度 VOD，补齐接口契约草案、状态机、账本规则和 Adapter 设计 |
| 6 | 工作时长评估 | `projects/剧说/02-技术方案/effort-estimate.md` | `skipped` | 用户明确要求不用评估时长 |
| 7 | 前端 Flutter 技术文档 | `projects/剧说/03-前端/flutter-tech.md` | `done` | 已生成 Flutter 技术文档与项目专属开发规则，并补充 Java 后端方案评估口径 |
| 8 | 后端 Java 技术文档 | `projects/剧说/04-后端/java-tech.md` | `done` | 已按 Java 21 + Spring Boot 3.x + Gradle + 百度 VOD 口径生成 |
| 9 | Flutter 总体开发计划 | `projects/剧说/03-前端/flutter-dev-plan.md` | `done` | 已生成，并进入模块开发文档 |
| 10 | Java 总体开发计划 | `projects/剧说/04-后端/java-dev-plan.md` | `done` | 已生成，不输出工时 |
| 11 | Flutter 模块开发文档 | `projects/剧说/03-前端/开发计划/*.md` | `done` | 已按用户要求一次性生成 6 份模块开发文档 |
| 12 | Java 模块开发文档 | `projects/剧说/04-后端/开发计划/*.md` | `done` | 已生成 7 份模块开发文档 |
| 13 | Flutter 编码 | `/Users/soul/code/lxwx/narrate` | `done` | 已完成 T-F001 至 T-F013、API adapter、缺失二级页、状态异常补齐和包名配置；`flutter analyze`、`flutter test` 均通过 |
| 14 | Java 编码 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `done` | T-B001 至 T-B011 已落地并通过 `./gradlew build` |
| 14.5 | 跨端功能变更文档审核 | `CHG-0011` 邀请好友逻辑文档 | `done` | 用户已继续要求进入后续开发，并补充 App UI 必须使用 Figma channel `slk656ok` 设计稿 |
| 14.6 | CHG-0011 跨端编码与验证 | Java 后端、App Flutter、后台 Web | `done` | 邀请好友闭环与兑换码补充项均已落地；后端、App、后台 Web 验证通过，已归档到 `change-log.md` |
| 14.7 | CHG-0012 积分任务中心跨端编码与验证 | Java 后端、App Flutter、后台 Web、专题文档 | `done` | 已完成积分任务中心跨端闭环，含签到、邀请任务展示、后台配置与三端验证；CHG-0012-R1 已补齐新增代码注释并重新验证通过；CHG-0012-R2 已将邀请任务按钮改为直达推广素材页 |
| 15 | 联调与测试 QA | `projects/剧说/05-联调与测试/qa-plan.md` | `pending` | 编码完成后进入 |
| 16 | 构建与打包 | `projects/剧说/06-构建打包/{build-plan.md,android.md,ios.md}` | `pending` | QA 通过后进入 |
| 17 | 应用商店上架 | `projects/剧说/07-应用上架/release-checklist.md` 等 | `pending` | 构建完成后进入 |
| 18 | 发布与版本管理 | `projects/剧说/08-发布版本/{release-plan.md,changelog.md}` | `pending` | 上架材料确认后进入 |
| 19 | 上线监控与迭代 | `projects/剧说/09-上线监控/{monitoring-plan.md,feedback-loop.md}` | `pending` | 发布后进入 |

---

## 4. 当前变更登记

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 | 备注 |
|--------|------|------|--------|------|----------|------|
| `CHG-0001` | 后端 Java 方案评估 | `tech_adjust` | `v0.2.0` | `done` | 5 技术方案 | 已生成 `backend-evaluation.md` 并同步 `tech-plan.md` |
| `CHG-0002` | 后端方案评估深化 | `tech_adjust` | `v0.2.1` | `done` | 5 技术方案 | 补充接口契约草案、状态机、账本规则、支付幂等和 Provider Adapter |
| `CHG-0003` | 百度 VOD 接入口径确认 | `tech_adjust` | `v0.2.2` | `done` | 5 技术方案 | 视频业务处理从待确认推进为百度智能云智能点播平台 VOD |
| `CHG-0004` | Java 文档推进到模块开发 | `doc_generation` | `v0.3.0` | `done` | 8 / 10 / 12 Java 文档链路 | 已生成 `java-tech.md`、`java-dev-plan.md` 和 7 份 Java 模块开发文档 |
| `CHG-0005` | Java 项目目录结构调整 | `doc_adjust` | `v0.3.1` | `done` | 12 Java 模块开发文档 | 按 `common/auth/user/product/order/payment/entitlement/app/admin` 结构调整后端文档 |
| `CHG-0006` | Java T-B001 基础设施落地 | `code` | `v0.3.2` | `done` | 14 Java 编码 | 在 Gradle 后端工程落地 Spring Boot 基础设施、迁移脚本和测试基线 |
| `CHG-0007` | Java 真实包名修正 | `code_adjust` | `v0.3.3` | `done` | 14 Java 编码 | 将模板包名统一修正为 `com.lxwx.narrateservice` |
| `CHG-0008` | Java T-B002 账号鉴权与用户落地 | `code` | `v0.4.0` | `done` | 14 Java 编码 | 实现 mock 短信登录、一键登录占位、JWT 鉴权、用户资料、退出登录和注销申请 |
| `CHG-0009` | Java T-B003 至 T-B011 编码收口 | `code` | `v0.5.0` | `done` | 14 Java 编码 | 实现积分、支付会员、百度 VOD 生成闭环、作品、邀请、反馈、配置和后台配置预留 |
| `CHG-0010` | App 首页热门案例管理 | `feature` | `v0.6.0` | `done` | 跨端功能变更 | 新增热门案例分类 / 案例后端接口、后台管理页面和 App 首页动态读取 |
| `CHG-0011` | 邀请好友逻辑跨端实现与兑换码补充 | `feature_add` | `v0.7.0` | `done` | 跨端功能变更 / 编码验证 | Java 后端、App Flutter、后台 Web 已编码；App 兑换码 UI 使用 Figma channel `slk656ok`；三端验证通过并已归档 |
| `CHG-0012` | 积分任务中心 | `feature_add` | `v0.8.0` | `done` | 跨端功能变更 / 编码验证 | App 我的页新增任务中心入口；后端新增任务中心、签到、后台配置；邀请任务复用既有邀请奖励，不做广告任务；三端验证通过并已归档 |
| `CHG-0012-R1` | 积分任务中心注释规范返工 | `code_quality` | `v0.8.0` | `done` | 跨端功能变更 / 编码验证 | 已补齐 App、后台 Web、Java 后端任务中心新增代码业务注释；反馈提交接口补充 `POST /api/feedback` 兼容映射；三端验证通过并已归档 |
| `CHG-0012-R2` | 任务中心邀请任务直达推广素材 | `ux_adjust` | `v0.8.0` | `done` | 跨端功能变更 / 编码验证 | App 任务中心「去邀请」按钮已从邀请首页改为直达推广素材页；App 验证通过并已归档 |

---

## 5. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约、变更管控 |
| `.cursor/rules/03-编码规范.mdc` | 新增 / 修改代码注释、字段说明和 public API 文档要求 |
| `.cursor/rules/02-需求文档生成.mdc` | PRD 增量同步规则 |
| `.cursor/rules/05-技术方案计划.mdc` | 技术方案与后端能力边界同步 |
| `.cursor/rules/07-前端Flutter技术文档.mdc` | Flutter / 后台 Web 文档增量参考 |
| `.cursor/rules/08-后端Java技术文档.mdc` | Java 后端技术文档生成规则 |
| `.cursor/rules/10-Java开发计划文档.mdc` | Java 总体开发计划生成规则 |
| `.cursor/rules/11-Flutter模块开发文档.mdc` | App / 后台 Web 模块文档增量参考 |
| `.cursor/rules/12-Java模块开发文档.mdc` | Java 模块开发文档生成规则 |
| `.cursor/rules/java/01-项目初始化规则.mdc` | Java 工程基础设施参考 |
| `.cursor/rules/java/02-项目结构目录.mdc` | Java 分层目录参考 |
| `.cursor/rules/java/05-数据库与持久化.mdc` | PostgreSQL / Redis / 迁移评估参考 |
| `.cursor/rules/java/08-鉴权与安全.mdc` | 登录、JWT、支付和敏感数据安全参考 |

---

## 6. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `projects/剧说/01-需求/requirements.md` | Figma 直读版 PRD | 是 |
| `projects/剧说/01-需求/邀请好友需求文档.md` | CHG-0011 邀请好友独立需求审核文档 | 是 |
| `projects/剧说/02-技术方案/tech-plan.md` | 当前技术方案与任务拆分 | 是 |
| `projects/剧说/02-技术方案/邀请好友技术文档.md` | CHG-0011 邀请好友独立技术审核文档 | 是 |
| `projects/剧说/02-技术方案/backend-evaluation.md` | 本轮后端方案评估输出 | 是 |
| `projects/剧说/04-后端/java-tech.md` | Java 后端技术文档 | 是 |
| `projects/剧说/04-后端/java-dev-plan.md` | Java 总体开发计划 | 是 |
| `projects/剧说/04-后端/开发计划/*.md` | Java 模块开发文档 | 是 |
| `projects/剧说/04-后端/开发计划/08-邀请好友后端开发文档.md` | CHG-0011 后端独立开发审核文档 | 是 |
| `projects/剧说/03-前端/flutter-tech.md` | 前端和后台 Web 文档增量 | 是 |
| `projects/剧说/03-前端/flutter-dev-plan.md` | 前端和后台 Web 开发计划增量 | 是 |
| `projects/剧说/03-前端/开发计划/05-商业化与我的二级页.md` | App 邀请、收益、提现页面文档补充 | 是 |
| `projects/剧说/03-前端/开发计划/07-邀请好友前端开发文档.md` | CHG-0011 前端独立开发审核文档 | 是 |
| `projects/剧说/workflow.md` | 当前流程与历史状态 | 是 |
| `projects/剧说/change-plan.md` | 登记并归档 CHG-0012 / CHG-0012-R1 / CHG-0012-R2 变更 | 是 |

---

## 7. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `projects/剧说/01-需求/requirements-list.md` | `done` | Figma 直读版需求清单 |
| `projects/剧说/01-需求/requirements.md` | `done` | Figma 直读版 PRD |
| `projects/剧说/01-需求/requirements.md` | `done` | CHG-0011 主 PRD 已改为专题文档索引，用户已继续进入编码 |
| `projects/剧说/01-需求/邀请好友需求文档.md` | `done` | CHG-0011 独立需求文档，覆盖邀请好友、收益、提现、后台规则和落地页；用户已继续进入编码 |
| `projects/剧说/01-需求/detection-feedback.md` | `done` | PRD 检测报告，结论 PASS |
| `projects/剧说/02-技术方案/tech-plan.md` | `done` | 已同步 Java 后端方案评估口径，未包含工时评估 |
| `projects/剧说/02-技术方案/tech-plan.md` | `done` | CHG-0011 主技术方案已改为专题文档索引，用户已继续进入编码 |
| `projects/剧说/02-技术方案/邀请好友技术文档.md` | `done` | CHG-0011 独立技术文档，覆盖邀请关系、收益账本、提现审核和公开落地页方案；用户已继续进入编码 |
| `projects/剧说/02-技术方案/backend-evaluation.md` | `done` | 本轮核心输出：Java 后端方案评估 |
| `projects/剧说/04-后端/java-tech.md` | `done` | Java 后端技术文档，固定 Gradle、PostgreSQL、Redis、MyBatis-Plus、Flyway、JWT、百度 VOD |
| `projects/剧说/04-后端/java-tech.md` | `done` | CHG-0011 Java 技术总文档已改为专题文档索引，用户已继续进入编码 |
| `projects/剧说/04-后端/java-dev-plan.md` | `done` | Java 总体开发计划，拆分 T-B001 至 T-B011 |
| `projects/剧说/04-后端/java-dev-plan.md` | `done` | CHG-0011 已新增 T-B012 文档任务，用户已继续进入编码 |
| `projects/剧说/04-后端/开发计划/01-基础设施.md` | `done` | Java 基础设施模块开发文档 |
| `projects/剧说/04-后端/开发计划/02-账号鉴权与用户.md` | `done` | 账号鉴权与用户模块开发文档 |
| `projects/剧说/04-后端/开发计划/03-积分账务.md` | `done` | 积分账务模块开发文档 |
| `projects/剧说/04-后端/开发计划/04-支付会员.md` | `done` | 支付会员模块开发文档 |
| `projects/剧说/04-后端/开发计划/05-百度VOD素材与生成.md` | `done` | 百度 VOD 素材与生成模块开发文档 |
| `projects/剧说/04-后端/开发计划/06-作品服务.md` | `done` | 作品服务模块开发文档 |
| `projects/剧说/04-后端/开发计划/07-邀请反馈配置.md` | `done` | 邀请、反馈、配置模块开发文档 |
| `projects/剧说/04-后端/开发计划/07-邀请反馈配置.md` | `done` | CHG-0011 已改为独立后端开发文档索引，用户已继续进入编码 |
| `projects/剧说/04-后端/开发计划/08-邀请好友后端开发文档.md` | `done` | CHG-0011 独立后端开发文档，覆盖 T-B012 接口、表结构、迁移计划和状态流转；用户已继续进入编码 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle` | `done` | Java 21 + Spring Boot 3.3 + Gradle 8.8 后端依赖与构建配置 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/settings.gradle` | `done` | Gradle 根项目名 `lxwx_service` |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/gradle/wrapper/gradle-wrapper.properties` | `done` | Gradle wrapper 固定到 8.8，兼容 Spring Boot 3.3 插件 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/**` | `done` | `ServerApplication`、`common` 基础设施代码和业务包目录骨架 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V1__init_schema.sql` | `done` | 首版业务表 Flyway 迁移脚本 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ServerApplicationTests.java` | `done` | Spring Boot 上下文测试 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/auth/**` | `done` | T-B002 账号鉴权、mock 短信、一键登录占位、JWT token 服务 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/user/**` | `done` | T-B002 用户资料、用户创建、注销申请、我的页聚合 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/entitlement/**` | `done` | T-B002 所需积分账户最小初始化与会员状态查询 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AuthUserIntegrationTests.java` | `done` | T-B002 集成测试，覆盖验证码、登录、鉴权、用户资料 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/product/**` | `done` | T-B004 商品 / 会员套餐能力 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/order/**` | `done` | T-B004 支付订单能力 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/payment/**` | `done` | T-B004/T-B011 mock 支付、回调幂等和 Provider 事件 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/**` | `done` | T-B005 至 T-B010 素材、创作、生成、作品、邀请、反馈、配置模块 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/**` | `done` | T-B010 后台配置预留接口 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V2__seed_app_configs.sql` | `done` | 默认风格、音色、背景音乐、计费和静态协议配置 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V3__add_idempotency_keys.sql` | `done` | 素材上传和生成任务 `Idempotency-Key` 持久化 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/BackendWorkflowIntegrationTests.java` | `done` | T-B003 至 T-B011 集成测试，覆盖支付到账、生成成功 / 失败、重复回调、作品、邀请、反馈和配置 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.gitignore` | `done` | 忽略 Gradle 构建产物、IDE 文件和本机文件 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/README.md` | `done` | 后端工程技术栈、目录结构和构建命令说明 |
| `projects/剧说/03-前端/flutter-tech.md` | `done` | Flutter 技术文档与项目开发规则 |
| `projects/剧说/03-前端/flutter-tech.md` | `done` | CHG-0011 Flutter 技术总文档已改为专题文档索引，用户已继续进入编码 |
| `projects/剧说/03-前端/flutter-dev-plan.md` | `done` | Flutter 总体开发计划 |
| `projects/剧说/03-前端/flutter-dev-plan.md` | `done` | CHG-0011 已新增 T-F015 / T-F016 文档任务，用户已继续进入编码 |
| `projects/剧说/03-前端/开发计划/01-工程骨架.md` | `done` | Flutter 工程骨架模块开发文档 |
| `projects/剧说/03-前端/开发计划/02-登录主框架我的页.md` | `done` | 登录、主框架、我的页模块开发文档 |
| `projects/剧说/03-前端/开发计划/03-创作流程.md` | `done` | 创作页和创作弹层模块开发文档 |
| `projects/剧说/03-前端/开发计划/04-作品模块.md` | `done` | 作品列表和作品详情模块开发文档 |
| `projects/剧说/03-前端/开发计划/05-商业化与我的二级页.md` | `done` | 会员、积分、邀请、设置、反馈模块开发文档 |
| `projects/剧说/03-前端/开发计划/06-状态与验收.md` | `done` | 全局状态与验收模块开发文档 |
| `projects/剧说/03-前端/开发计划/07-邀请好友前端开发文档.md` | `done` | CHG-0011 独立前端开发文档，覆盖 App 与后台 Web；用户已继续进入编码 |
| `/Users/soul/code/lxwx/narrate/.cursor/rules/**` | `done` | Flutter 工程内 Cursor 规则，后续代码编写以工程内规则为准 |
| `/Users/soul/code/lxwx/narrate/README.md` | `done` | 已写入工程目录结构、业务功能、开发进度、包名配置、待联调事项和验证记录；后续 Flutter 模块完成后需同步更新 |
| `/Users/soul/work/MakeCodePlanWord/mcp/figma-rest/**` | `cancelled` | Figma REST MCP 方案因 API 限流已撤销，相关本地文件已删除 |
| `/Users/soul/code/lxwx/narrate/pubspec.yaml` | `done` | 已加入 T-F001 基础依赖 |
| `/Users/soul/code/lxwx/narrate/lib/**` | `done` | 已完成 T-F001 至 T-F012：工程骨架、API adapter、登录、首页、创作、作品、会员 / 积分、邀请、设置、反馈、静态协议页和全局状态异常补齐 |
| `/Users/soul/code/lxwx/narrate/test/widget_test.dart` | `done` | 已更新骨架 smoke test |
| `projects/剧说/01-需求/references/README.md` | `done` | Figma frame 索引与读取备注 |
| `projects/剧说/change-plan.md` | `done` | CHG-0011 已从进行中变更归档到本迭代历史变更 |
| `projects/剧说/change-log.md` | `done` | 已新增 `v0.7.0` 研发变更日志 |
| `projects/剧说/workflow.md` | `done` | 当前流程已完成 CHG-0011 跨端编码验证，下一步进入联调与测试 QA |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V2__quick_generation_batches.sql` | `done` | CHG-0011 邀请关系、代理档案、收益账本、提现申请表结构已合并在既有迁移链路中 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V11__redeem_codes.sql` | `done` | CHG-0011 兑换码批次、兑换码明细、兑换记录迁移脚本 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/invite/**` | `done` | App 邀请绑定、推广素材、收益汇总、收益明细、提现记录和公开落地页后端能力 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/**Invite**` | `done` | 邀请规则、用户代理配置、提现审核 / 驳回 / 打款状态后台接口 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/redeem/**` | `done` | App 兑换码兑换接口、批次校验、权益发放与幂等记录 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/controller/AdminRedeemCodeController.java` | `done` | 后台兑换码批次创建、启停和兑换记录查询接口 |
| `/Users/soul/code/lxwx/narrate/lib/pages/invite/**` | `done` | App 邀请收益页面按 Figma channel `slk656ok` 画板重做，含收益首页、绑定、列表、收益明细、提现、提现记录、推广素材和佣金说明 |
| `/Users/soul/code/lxwx/narrate/lib/pages/redeem_code/**` | `done` | App 兑换码页面按 Figma channel `slk656ok` 的 `兑换码` 画板风格实现 |
| `/Users/soul/code/lxwx/narrate/lib/apis/redeem_code.dart` | `done` | App 兑换码 API adapter，接入 `POST /api/redeem-codes/redeem` |
| `/Users/soul/code/lxwx/narrate/lib/models/data/redeem_code_result.dart` | `done` | App 兑换码兑换结果模型 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/invite_page.dart` | `done` | 后台 Web 邀请收益管理页面，覆盖规则配置、用户代理配置和提现管理 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/redeem_codes_page.dart` | `done` | 后台 Web 兑换码管理页面，覆盖批次管理、启停确认和兑换记录查询 |
| `projects/剧说/01-需求/积分任务中心需求文档.md` | `done` | CHG-0012 独立需求文档，覆盖入口、签到、邀请任务、视觉和后台配置规则 |
| `projects/剧说/02-技术方案/积分任务中心技术文档.md` | `done` | CHG-0012 独立技术文档，覆盖接口、数据账本、App 和后台方案 |
| `projects/剧说/03-前端/开发计划/08-积分任务中心前端开发文档.md` | `done` | CHG-0012 App / 后台 Web 前端开发文档，已同步完成记录 |
| `projects/剧说/04-后端/开发计划/09-积分任务中心后端开发文档.md` | `done` | CHG-0012 后端开发文档，已同步完成记录 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/task/**` | `done` | App 用户侧任务中心概览、签到、签到记录和规则聚合服务 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/controller/AdminTaskCenterController.java` | `done` | 后台任务中心规则查询与更新接口 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/feedback/controller/FeedbackController.java` | `done` | CHG-0012-R1 验证返工中补充 `POST /api/feedback` 与 `/api/feedback/datafeed` 双路径兼容 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V12__task_center.sql` | `done` | 任务中心签到记录表与默认配置迁移 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/TaskCenterIntegrationTests.java` | `done` | 后端任务中心集成测试，覆盖概览、签到幂等、邀请进度和后台配置 |
| `/Users/soul/code/lxwx/narrate/lib/pages/task_center/**` | `done` | App 任务中心页面，参考图片信息架构并使用剧说 App 深色 / 荧光黄绿视觉；CHG-0012-R2 已将「去邀请」改为直达推广素材页 |
| `/Users/soul/code/lxwx/narrate/lib/apis/tasks.dart` | `done` | App 任务中心 API adapter，接入 `GET /api/tasks/center` 和 `POST /api/tasks/check-in` |
| `/Users/soul/code/lxwx/narrate/lib/models/data/task_center_overview.dart` | `done` | App 任务中心总览、签到概览、签到天数和每日任务模型 |
| `/Users/soul/code/lxwx/narrate/lib/models/data/task_check_in_result.dart` | `done` | App 签到结果模型 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/pages/task_center_page.dart` | `done` | 后台 Web「任务中心」配置页，支持开关、7 天奖励和邀请任务展示文案 |
| `/Users/soul/code/lxwx/lxwx_admin/lib/models/admin_models.dart` | `done` | 后台 Web 新增 `TaskCenterRulesConfig` 与 `AdminSection.taskCenter` |
| `/Users/soul/code/lxwx/lxwx_admin/lib/core/api_client.dart` | `done` | 后台 Web 任务中心规则查询 / 更新 API facade |
| `/Users/soul/code/lxwx/lxwx_admin/lib/data/admin_repository.dart` | `done` | 后台 Web 任务中心规则加载、保存、demo 和操作日志 |
| `projects/剧说/change-plan.md` | `done` | CHG-0012-R1 注释规范返工、CHG-0012-R2 任务中心邀请任务直达推广素材已从进行中归档到历史变更 |
| `projects/剧说/change-log.md` | `done` | `v0.8.0` 已补充 CHG-0012-R1 注释规范返工、反馈接口兼容记录和 CHG-0012-R2 UX 调整 |
| `projects/剧说/workflow.md` | `done` | 当前流程同步 CHG-0012-R1 / CHG-0012-R2 完成状态、验证记录和下一步默认动作 |

---

## 8. 上架就绪检查表（进入 17 阶段前必须全绿）

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 15 联调与测试 QA 通过（P0/P1 全部修复并回归） | ☐ | 尚未进入 |
| `change-plan.md` 顶部「进行中变更」区块为空 | ☑ | `CHG-0012`、`CHG-0012-R1` 与 `CHG-0012-R2` 已归档到本迭代历史变更 |
| `change-log.md` 当前版本号已确定 | ☑ | 当前完成版本为 `v0.8.0` |
| Android AAB / APK 已生成并测试安装通过 | ☐ | 尚未进入 |
| iOS IPA 已生成并 TestFlight 通过 | ☐ | 尚未进入 |
| 签名配置正常，无过期证书 | ☐ | 尚未进入 |
| 隐私政策已就绪并 URL 可访问 | ☐ | 尚未进入 |
| 商店素材已就绪 | ☐ | 尚未进入 |
| 第三方 SDK 合规清单已在隐私政策声明 | ☐ | 尚未进入 |
| 国内商店：ICP/MIIT 备案、软著（如需要） | ☐ | 尚未进入 |

---

## 9. 额外注意事项

- 本轮 Figma MCP 已连通 channel `q7qei3nx`，并成功读取 Page 1 的 20 个 frame。
- CHG-0011 已切换并连通 Figma channel `slk656ok`，读取并导出 `绑定邀请人`、`收益明细`、`邀请列表`、`提现`、`提现记录`、`我的收益`、`推广素材`、`会员佣金说明` 等邀请收益相关 frame；App 邀请 UI 已按这些设计稿重做。
- CHG-0011 已从文档审核推进并完成编码：Java 后端、App Flutter、后台 Web 均已修改，`change-log.md` 已归档 `v0.7.0`。
- CHG-0011 邀请收益表结构随既有迁移链路合并处理；兑换码新增后端迁移脚本 `V11__redeem_codes.sql`。
- CHG-0011 验证记录：`/Users/soul/code/lxwx/lxwx_service/lxwxservice` 执行 `./gradlew testClasses`、`./gradlew test` 通过；`/Users/soul/code/lxwx/narrate` 执行 `flutter analyze`、`flutter test` 通过；`/Users/soul/code/lxwx/lxwx_admin` 执行 `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。
- CHG-0011 用户已确认邀请奖励规则：注册送直接邀请人 `10` 积分；直接返佣按个人代理等级 `10% / 20% / 30%`；间接收益由后台按用户开启，固定 `10%`，只穿一层；会员返佣只返首次开通会员，续费、再次开通会员和充值积分不返。
- CHG-0011 用户已确认兑换码规则：入口放在 App「我的」页「支付订单」下一行；同一兑换码批次只能发放一种商品，积分或会员天数二选一，不能同时发放。
- CHG-0012-R1 注释规范返工已完成：App / 后台 Web / Java 后端新增任务中心代码已补齐业务注释；后端反馈提交接口补充 `POST /api/feedback` 兼容映射并保留 `/api/feedback/datafeed`。
- CHG-0012-R1 验证记录：`/Users/soul/code/lxwx/lxwx_service/lxwxservice` 执行 `./gradlew test` 通过；`/Users/soul/code/lxwx/narrate` 执行 `flutter analyze`、`flutter test` 通过；`/Users/soul/code/lxwx/lxwx_admin` 执行 `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。
- CHG-0012-R2 UX 调整已完成：App 任务中心「去邀请」按钮直接跳转到「推广素材」页；`/Users/soul/code/lxwx/narrate` 执行 `flutter analyze`、`flutter test` 通过。
- 旧的截图版 `effort-estimate.md` 仍保留在项目中，但对当前 v0.2.0 流程视为历史估时产物，后续若要排期需要重新启用第 6 步。
- 整页 `scan_text_nodes` 对大节点容易超时，本轮采用 `get_node_info` 与单 frame `scan_text_nodes` 结合读取。
- 当前 Figma 中存在若干疑似文案问题，已记录到需求清单“假设与待确认项”。
- 用户已明确本轮少走“生成 Figma 设计稿”这一步；后续 UI 真源以现有 Figma frame 和 `references/README.md` 索引为准。
- 用户确认当前主要缺失页面收敛为 3 个：邀请好友、我的页更多设置、意见反馈；已写入 `requirements-list.md` 的“当前确认的缺失页面”。
- 用户明确要求“不用评估时长”，因此第 6 步工作时长评估标记为 `skipped`，后续 Flutter 文档不引用 `effort-estimate.md`。
- 本轮已进入 Flutter 编码阶段，`frontendRepo` 为 `/Users/soul/code/lxwx/narrate`。
- 用户原先要求“后端相关变成待确定”，本轮已继续推进为 Java 后端方案评估；Flutter 仍按 mock / adapter 前端先行策略处理。
- 本轮后端评估结论：建议采用 Java 21 + Spring Boot 3.x + Gradle + PostgreSQL + Redis + MyBatis-Plus；视频业务处理已确认接入百度智能云智能点播平台 VOD，短信、一键登录和支付供应商仍待确认。
- 用户已要求本轮忽略前端开发，流程已进入 Java 后端编码；后续默认不继续 Flutter 编码，除非用户重新指定。
- Java 文档链路已完成：`04-后端/java-tech.md`、`04-后端/java-dev-plan.md`、`04-后端/开发计划/*.md` 已生成。
- Java 项目目录结构已按用户指定的基础业务 / 具体业务 / 后台管理分层调整：`common`、`auth`、`user`、`product`、`order`、`payment`、`entitlement`、`app/*`、`admin`。
- Java 后端工程路径已确认：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`，该目录是实际 Gradle 项目根。
- T-B001 已完成：Spring Boot + Gradle 基础设施、`com.lxwx.narrateservice` 包结构、通用响应 / 异常 / 配置、Flyway 初始迁移和上下文测试已落地；`./gradlew build` 通过。
- 用户确认此前使用的是模板包名，真实后端包名为 `com.lxwx.narrateservice`；代码目录、package、Gradle group 和文档已统一修正。
- T-B002 已完成：mock 短信验证码、短信登录、一键登录占位、JWT 鉴权、我的页聚合、退出登录和注销申请已落地；`./gradlew build` 通过。
- T-B003 至 T-B011 已完成：积分账务、支付会员、百度 VOD 素材与生成、作品、邀请、反馈、配置、后台配置预留和 Provider Adapter 骨架已落地；`./gradlew build` 通过。真实百度 VOD、短信、一键登录和支付渠道仍待联调替换 Provider。
- 用户明确要求“模块的开发文档一次生产，不用等我确认”，因此 `03-前端/开发计划/` 下 6 份模块文档均已生成并标记完成。
- 用户明确要求工程骨架阶段把 Flutter Cursor 规则写入 Flutter 工程；已记录为 T-F001 首步，后续代码编写以 `frontendRepo/.cursor/rules/` 为准。
- T-F001 已完成：工程内 `.cursor/rules/`、基础依赖、`lib/` 分层骨架、主框架占位页已落地；`flutter analyze` 与 `flutter test` 均通过。
- API adapter 基础设施已完成：10 个 API、统一 mock/real 开关、候选 endpoint、DTO/领域模型和错误转换已落地；后端真实地址与敏感业务 SDK 仍待确定。
- T-F002/T-F003/T-F007 已完成：登录、主框架/创作首页、我的页已按 Figma 读取结果实现；`flutter analyze` 与 `flutter test` 均通过。
- T-F004/T-F005 已完成：创作页、选择视频、解说风格、配音角色、更多设置、删除确认、积分确认、权益不足弹窗已按 Figma 读取结果实现；`flutter analyze` 与 `flutter test` 均通过。
- T-F006 已完成：作品空态、作品列表、作品详情、状态标签、下载占位和主框架作品 tab 已按 Figma 读取结果实现；`flutter analyze` 与 `flutter test` 均通过。
- T-F008 已完成：VIP 会员、积分充值、积分流水、支付提交占位和用户积分 / 会员态更新已实现；`flutter analyze` 与 `flutter test` 均通过。
- T-F009/T-F010/T-F011 已完成：邀请好友、更多设置、意见反馈和协议静态页已按用户确认的缺失页补齐；真实分享、附件上传、注销流程以后端 / SDK 定稿为准。
- T-F012 已完成：已补 `ViewState`、`AppStateBuilder`、`AppButton`、`AppValidators`、keyed mock 空态 / 失败开关，并接入主要页面 loading / empty / error / submitting / not_found 状态；`flutter analyze` 与 `flutter test` 均通过。
- T-F013 已完成：Android `namespace/applicationId/MainActivity` 与 iOS Runner `PRODUCT_BUNDLE_IDENTIFIER` 已统一为 `com.lxwx.narrate`；`flutter analyze`、`flutter test`、`plutil -lint` 通过；Android debug 构建卡在 Gradle `assembleDebug` 长时间无输出，已中断。
- T-F014 已撤销：因 Figma REST API 限流，不再使用 REST API 下载图标；相关规则、配置和本地导出文件已清理。
- CHG-0010 已完成：新增 App 首页热门案例管理能力。默认分类保留「漫剧解说」，分类名称可在后台维护；后台 Web 支持本地封面上传、App 卡片预览、上下架和删除；App 首页改为读取动态分类与案例，点击案例仅记录使用次数。
- 为避免云上 Flyway 已存在 `V4` 迁移时发生版本冲突，热门案例迁移文件使用 `V5__home_hot_cases.sql`。
- CHG-0010 验证记录：后端 `./gradlew test` 通过；后台 Web `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过；App `flutter analyze`、`flutter test` 通过。
- CHG-0012 App UI 参考用户提供的任务中心截图做信息层级：总积分、连续签到、每日任务；色调改用剧说 App 深绿黑背景、暗色卡片和荧光黄绿主色，不使用参考图蓝橙配色。
- CHG-0012 第一版每日任务只展示邀请好友；视频、插屏、广告任务不展示，也不接广告 SDK。
- CHG-0012 验证记录：`/Users/soul/code/lxwx/lxwx_service/lxwxservice` 执行 `./gradlew test` 通过；`/Users/soul/code/lxwx/narrate` 执行 `flutter analyze`、`flutter test` 通过；`/Users/soul/code/lxwx/lxwx_admin` 执行 `flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。

---

## 10. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 邀请好友、我的页更多设置、意见反馈 3 个二级页未在当前 Figma 中展开 | 可能影响后续视觉精修 | 已按用户确认在 Flutter 中补齐前端页面；后续如提供 Figma 可继续视觉复核 |
| 生成任务状态页未在当前 Figma 中完整展示 | 会影响 PRD 的任务状态机、失败重试和积分补偿规则 | 作为 PRD 状态补充处理，不作为本轮主要缺失页面 |
| 背景音乐完整流程未展开 | 会影响视频创作页更多设置和生成配置 | 暂列待确认，不归入用户确认的 3 个主要缺失页面 |
| 支付价格、权益文案存在疑似异常 | 会影响会员 / 充值规则 | PRD 阶段以业务确认值为准 |
| 百度 VOD 账号区域、工作流 / 模板、回调签名、自定义域名和播放鉴权待确认；短信、一键登录、支付供应商待确认 | 会影响真实接口字段、回调、鉴权和联调 | Java 后端先按 `BaiduVodProvider` 与其他 Provider Adapter 设计，Flutter 继续使用 mock / adapter 层 |

---

## 11. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 旧截图版 1-6 步 | `requirements-list.md`、`requirements.md`、`figma-design-plan.md`、`tech-plan.md`、`effort-estimate.md` | 历史完成 | 2026-05-18 起被 Figma 直读版需求分析覆盖，需要重新同步 |
| Figma 直读版需求分析 | `projects/剧说/01-需求/requirements-list.md` | `done` | 已确认并进入 PRD |
| Figma 直读版 PRD | `projects/剧说/01-需求/requirements.md` | `done` | 已生成并通过检测 |
| PRD 检测 | `projects/剧说/01-需求/detection-feedback.md` | `done` | PASS |
| 技术方案 | `projects/剧说/02-技术方案/tech-plan.md`、`projects/剧说/02-技术方案/backend-evaluation.md` | `done` | 已补 Java 后端方案评估，未评估时长 |
| Java 技术文档 | `projects/剧说/04-后端/java-tech.md` | `done` | 已生成 Java 21 + Spring Boot 3.x + Gradle + 百度 VOD 技术文档 |
| Java 总体开发计划 | `projects/剧说/04-后端/java-dev-plan.md` | `done` | 已生成 T-B001 至 T-B011 后端总体计划 |
| Java 模块开发文档 | `projects/剧说/04-后端/开发计划/01-基础设施.md` 至 `07-邀请反馈配置.md` | `done` | 已按用户要求推进到 Java 模块开发阶段 |
| Java 编码 T-B001 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `done` | 工程基础设施已落地，`./gradlew build` 通过 |
| Java 编码 T-B002 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `done` | 账号鉴权与用户模块已落地，`./gradlew build` 通过 |
| Java 编码 T-B003 至 T-B011 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | `done` | 积分、支付会员、百度 VOD 生成闭环、作品、邀请、反馈、配置和后台配置预留已落地，`./gradlew build` 通过 |
| Flutter 技术文档 | `projects/剧说/03-前端/flutter-tech.md` | `done` | 已生成 |
| Flutter 总体开发计划 | `projects/剧说/03-前端/flutter-dev-plan.md` | `done` | 已生成 |
| Flutter 模块开发文档 | `projects/剧说/03-前端/开发计划/01-工程骨架.md` 至 `06-状态与验收.md` | `done` | 已按用户要求一次性生成全部模块文档 |
| CHG-0011 文档审核 | `邀请好友需求文档.md`、`邀请好友技术文档.md`、`07-邀请好友前端开发文档.md`、`08-邀请好友后端开发文档.md` | `done` | 已拆分为独立专题文档；用户已继续进入编码 |
| CHG-0011 跨端编码与验证 | Java 后端、App Flutter、后台 Web | `done` | 邀请好友闭环与兑换码补充项均已完成；后端、App、后台 Web 验证通过，已归档到 `change-log.md` |
| CHG-0012 积分任务中心跨端编码与验证 | Java 后端、App Flutter、后台 Web | `done` | 积分任务中心闭环已完成；后端、App、后台 Web 验证通过，已归档到 `change-log.md` |

---

## 12. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-05-13 | 旧截图版需求到估时 | 根据用户截图与说明创建“剧说”文档工作区 | 已完成到第 6 步工作时长评估，后续被本轮 Figma 直读流程覆盖 |
| 2026-05-18 11:26 | 1 需求分析 | 连接 Figma channel `q7qei3nx`，读取 Page 1 的 20 个 frame，重写需求清单与流程状态 | 已生成 Figma 直读版 `requirements-list.md`，状态为 `waiting_review` |
| 2026-05-18 11:45 | 1 需求分析 | 根据用户判断收敛主要缺失页面 | 已记录 3 个主要缺失页面：邀请好友、我的页更多设置、意见反馈 |
| 2026-05-18 11:56 | 2 需求文档生成 | 根据 Figma 直读版需求清单生成 PRD | 已生成 `requirements.md`，状态为 `waiting_review` |
| 2026-05-18 12:04 | 3-7 连续推进 | 按用户要求跳过 Figma 图和工时评估，生成检测报告、技术方案、Flutter 技术文档 | 已停在 `flutter-tech.md` 待确认 |
| 2026-05-18 13:53 | 9 Flutter 总体开发计划 | 按用户要求将后端相关改为待确定，并生成 Flutter 总体开发计划 | 已生成 `flutter-dev-plan.md`，状态为 `waiting_review` |
| 2026-05-18 14:04 | 11 Flutter 模块开发文档 | 生成工程骨架模块开发文档 | 已生成 `03-前端/开发计划/01-工程骨架.md` |
| 2026-05-18 14:18 | 11 Flutter 模块开发文档 | 按用户要求一次性生成剩余模块开发文档 | 已生成 `02-登录主框架我的页.md`、`03-创作流程.md`、`04-作品模块.md`、`05-商业化与我的二级页.md`、`06-状态与验收.md`；当前编码被 `frontendRepo` 缺失阻塞 |
| 2026-05-18 14:30 | 13 Flutter 编码准备 | 根据用户要求补充工程骨架规则落地要求 | 已明确 T-F001 首步写入 `frontendRepo/.cursor/rules/`，后续代码编写以工程内规则为准 |
| 2026-05-18 14:42 | 13 Flutter 编码 | 执行 T-F001 工程骨架编码 | 已在 `/Users/soul/code/lxwx/narrate` 完成工程内规则、依赖、`lib/` 分层骨架、路由、服务、Store、通用组件和主框架占位页；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 15:15 | 13 Flutter 编码准备 | 按用户要求重建工程内项目规则 | 已清理混入工程的流程规则，`/Users/soul/code/lxwx/narrate/.cursor/rules/` 仅保留 01-10 项目规则；当前暂停等待用户确认 |
| 2026-05-18 15:33 | 13 Flutter 编码准备 | 按用户要求修正工程内项目结构目录规则 | `widgets/`、`dialog/`、`{sub_feature}/` 改为有内容才显示、有内容才创建；创作首页不预设 `widgets/` 文件；当前暂停等待用户确认 |
| 2026-05-18 15:55 | 13 Flutter 编码 | 实现 API 与 SDK 编码方案调整 | 已在 Flutter 工程落地 `HttpService` baseUrl、`ConfigStore.mockEnabled/apiBaseUrl`、统一 `ApiAdapter`、10 个 API、领域模型和 API adapter 测试；`flutter analyze`、`flutter test` 均通过；未引入未确认业务 SDK |
| 2026-05-18 16:00 | 5 技术方案 / 后端方案评估 | 按用户要求继续“剧说”的后端方案评估，并采用 Java 后端技术口径 | 已生成 `02-技术方案/backend-evaluation.md`，同步 `tech-plan.md` 和 workflow；下一步可生成 `04-后端/java-tech.md` |
| 2026-05-18 16:05 | 5 技术方案 / 后端方案评估 | 根据用户确认将视频业务处理接入百度智能云智能点播平台 VOD | 已同步 `backend-evaluation.md`、`tech-plan.md` 和 workflow；后续 Java 技术文档按 `BaiduVodProvider` 设计 |
| 2026-05-18 16:12 | 13 Flutter 编码 | 实现 T-F002/T-F003/T-F007 | 已完成登录、主框架/创作首页、我的页与路由接入；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:19 | 13 Flutter 编码 | 实现 T-F004/T-F005 创作流程 | 已完成创作页、选择视频、风格/配音/更多设置弹层、删除确认、积分确认、权益不足弹窗；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:26 | 13 Flutter 编码 | 实现 T-F006 作品模块 | 已完成作品空态、作品列表、作品详情、状态预留、下载占位与主框架作品 tab 接入；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:32 | 13 Flutter 编码 | 实现 T-F008 会员与积分 | 已完成 VIP 会员、积分充值、积分流水、支付提交占位和积分 / 会员态更新；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:38 | 13 Flutter 编码 | 实现 T-F009/T-F010/T-F011 二级页 | 已完成邀请好友、更多设置、意见反馈和协议静态页；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:40 | 13 Flutter 编码 | 实现 T-F012 状态与异常补齐 | 已完成统一状态枚举 / 状态组件 / 按钮 / 校验器 / keyed mock 开关并接入主要页面；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:45 | 13 Flutter 编码 / 进度记录 | 更新 Flutter 工程 README 和模块规则 | 已在 `/Users/soul/code/lxwx/narrate/README.md` 写入工程目录、业务功能、开发进度、待联调事项和验证记录；已在 Flutter 总体计划与状态验收模块补充“模块完成后同步 README”要求 |
| 2026-05-18 17:49 | 13 Flutter 编码 / 包名配置 | 将 Flutter 工程包名改为 `com.lxwx.narrate` | 已更新 Android `namespace/applicationId/MainActivity`、iOS Runner Bundle Identifier 和 README；`flutter analyze`、`flutter test`、`plutil -lint` 通过；`flutter build apk --debug` 卡在 Gradle `assembleDebug` 长时间无输出，已中断 |
| 2026-05-19 10:06 | MCP 工具建设 | 撤销 Figma REST MCP | 因 Figma REST API 限流，已删除 `mcp/figma-rest/` 并移除 Codex `FigmaRest` 配置 |
| 2026-05-19 10:23 | 13 Flutter 编码 / 资源导出 | 撤销 REST 图标导出 | 已清理 REST 下载规则、`assets/images/` / `assets/icons/` 中的 REST 导出图标、`pubspec.yaml` 资源注册和 `AppAssets` 图标常量 |
| 2026-05-19 | 8 / 10 / 12 Java 文档链路 | 按用户要求忽略前端开发并推进到 Java 模块开发 | 已生成 `04-后端/java-tech.md`、`java-dev-plan.md` 和 7 份 Java 模块开发文档；下一步可指定 / 创建 Java 后端工程进入编码 |
| 2026-05-19 | 12 Java 模块开发文档 | 按用户给定结构调整 Java 项目目录 | 已将后端文档调整为 `com.lxwx.narrateservice`、`ServerApplication.java`、`common/auth/user/product/order/payment/entitlement/app/admin` 分层；保持 Java + Gradle 口径 |
| 2026-05-19 | 14 Java 编码 / T-B001 | 在 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 落地 Java 工程基础设施 | 已完成 Spring Boot + Gradle 配置、目录骨架、通用能力、Flyway 初始迁移、测试基线；`./gradlew build` 通过 |
| 2026-05-19 | 14 Java 编码 / 包名修正 | 将模板包名修正为真实包名 `com.lxwx.narrateservice` | 已完成 Java 源码目录、package/import、`@MapperScan`、Gradle group、README 和后端文档同步；`./gradlew build` 通过 |
| 2026-05-19 | 14 Java 编码 / T-B002 | 落地账号鉴权与用户模块 | 已完成 mock 短信验证码、短信登录、一键登录占位、JWT 鉴权、我的页聚合、退出登录、注销申请和集成测试；`./gradlew build` 通过 |
| 2026-05-19 | 14 Java 编码 / T-B003 至 T-B011 | 按用户要求不等待确认，完成剩余 Java 后端编码任务 | 已完成积分账务、支付会员、百度 VOD 素材与生成、作品、邀请、反馈、配置和后台配置预留；新增跨模块集成测试；`./gradlew build` 通过 |
| 2026-06-02 12:42 | 跨端功能变更 / CHG-0011 文档审核 | 按用户要求新增邀请好友逻辑，但先暂停在文档审核，不进入编码 | 已同步 PRD、技术方案、Flutter / 后台 Web 文档、Java 文档和模块文档；`change-log.md` 暂不归档；当前状态 `waiting_review` |
| 2026-06-02 14:00 | 跨端功能变更 / CHG-0011 文档审核整理 | 按用户要求将邀请好友需求、技术、前端开发、后端开发文档拆成独立文件 | 已新增 4 份专题审核文档，主文档改为索引；删除前端 / 后台 Web 合并旧文档；当前状态仍为 `waiting_review` |
| 2026-06-02 14:43 | 跨端功能变更 / CHG-0011 文档审核细化 | 按用户确认调整邀请奖励、直接返佣、间接收益和首次会员返佣规则 | 已同步 4 份专题审核文档、`change-plan.md` 和 workflow；当前状态仍为 `waiting_review`，未进入编码 |
| 2026-06-02 15:40 | 跨端功能变更 / CHG-0011 编码验证 | 用户要求继续后续开发，并确认 App UI 使用 Figma channel `slk656ok` 设计稿 | 邀请好友闭环完成后端、App Flutter、后台 Web 编码；App UI 按 Figma channel `slk656ok` 落地 |
| 2026-06-02 19:03 | 跨端功能变更 / CHG-0011 兑换码补充与归档 | 用户补充兑换码入口、批次商品二选一和后台管理规则 | 已完成后端兑换码迁移与接口、App「我的」页兑换码入口和兑换页、后台 Web 兑换码管理；后端 `./gradlew testClasses` / `./gradlew test`、App `flutter analyze` / `flutter test`、后台 Web `flutter analyze` / `flutter test` / release Web build 全部通过；`change-log.md` 已归档 `v0.7.0` |
| 2026-06-08 15:20 | 跨端功能变更 / CHG-0012 积分任务中心编码验证 | 按用户确认的计划与参考图完成积分任务中心三端实现 | 已完成后端任务中心与签到、App 任务中心页面和入口、后台 Web 任务中心配置页；后端 `./gradlew test`、App `flutter analyze` / `flutter test`、后台 Web `flutter analyze` / `flutter test` / release Web build 全部通过；`change-log.md` 已归档 `v0.8.0` |
