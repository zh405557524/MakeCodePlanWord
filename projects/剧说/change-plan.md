# 剧说 变更计划

> 规则来源：`.cursor/rules/00-核心工作流程.mdc` 第五步「变更管控与版本化记录」
> 用途：登记本迭代内进行中与已完成的变更，控制影响范围，避免局部改动触发大面积重写。
> 当前说明：2026-06-08 CHG-0012 积分任务中心已完成跨端实现、注释规范返工、邀请任务直达推广素材调整和验证归档，当前完成版本为 `v0.8.0`。

---

## 第一区块：进行中变更（pending / in_progress）

（暂无）

---

## 第二区块：本迭代历史变更（done / rolled_back）

### CHG-0012-R2 任务中心邀请任务直达推广素材

- 类型：`ux_adjust`
- 版本号：`v0.8.0`
- 状态：`done`
- 提出时间：`2026-06-08`
- 完成时间：`2026-06-08 18:44`
- 触发原因：用户要求“任务中心-去邀请”直接跳到推广素材页面，减少中间跳转。
- 影响范围：
  - Flutter App：是，已将任务中心邀请按钮跳转目标从邀请首页调整为推广素材页，并新增路由级 widget 测试。
  - Java 后端：否。
  - 后台 Web：否。
  - 业务逻辑：否，未改变任务数据、邀请奖励、签到和后台配置。
- 验证：
  - `/Users/soul/code/lxwx/narrate`：`flutter analyze`、`flutter test` 通过。

### CHG-0012-R1 积分任务中心注释规范返工

- 类型：`code_quality`
- 版本号：`v0.8.0`
- 状态：`done`
- 提出时间：`2026-06-08`
- 完成时间：`2026-06-08 18:22`
- 触发原因：用户指出任务中心新增代码未按工程编码规范补齐业务注释，需要对 CHG-0012 进行注释规范返工。
- 影响范围：
  - Flutter App：是，已补齐任务中心 API、模型、controller、view 新增代码的 `///` 业务注释。
  - Java 后端：是，已补齐任务中心 Controller、Service、DTO/VO、Entity、Repository 的 Javadoc。
  - 后台 Web：是，已补齐任务中心配置模型、API client、repository 和页面关键字段 / 方法注释。
  - 反馈接口兼容：是，验证中发现既有集成测试要求 `POST /api/feedback`，当前控制器仅保留 `/api/feedback/datafeed`；已补充根路径兼容映射并保留旧路径。
  - 业务逻辑：否，未改变任务中心接口、路由、页面行为、数据结构和测试断言。
- 验证：
  - `/Users/soul/code/lxwx/lxwx_service/lxwxservice`：`./gradlew test` 通过。
  - `/Users/soul/code/lxwx/narrate`：`flutter analyze`、`flutter test` 通过。
  - `/Users/soul/code/lxwx/lxwx_admin`：`flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。

### CHG-0012 积分任务中心

- 类型：`feature_add`
- 版本号：`v0.8.0`
- 状态：`done`
- 提出时间：`2026-06-08`
- 完成时间：`2026-06-08 15:20`
- 触发原因：用户要求“剧说项目新增积分任务中心，入口放在我的页面支付订单上面；颜色与当前 App 一致；按工作流程开始”，并确认第一版为跨端闭环、保留连续签到、每日任务只做邀请好友、不做广告任务，邀请奖励复用现有邀请奖励不额外发放；随后补充参考图片用于信息架构，色调仍采用 App。
- 核心规则：
  - App「我的」页新增「任务中心」入口，位置在「支付订单」上方。
  - 页面参考截图的信息架构，但视觉使用剧说现有深色背景与荧光黄绿主色。
  - 第一版任务包含连续签到与邀请好友；广告任务不展示、不接 SDK。
  - 签到奖励默认 7 天循环 `[3, 3, 4, 3, 4, 5, 10]`，后台可配置。
  - 邀请任务展示进度与奖励说明，复用现有邀请积分奖励，不新增二次领取。
- 影响范围：
  - 需求文档：是，已新增积分任务中心专题需求文档。
  - 技术方案：是，已新增积分任务中心专题技术文档。
  - Flutter App：是，已新增任务中心入口、路由、页面、API adapter、model 和 mock。
  - Java 后端：是，已新增任务中心概览、签到接口、签到记录表、后台规则配置和测试。
  - 后台 Web：是，已新增任务中心配置页，支持签到奖励与邀请任务展示规则。
- 主要改动清单：
  - 文档：`projects/剧说/01-需求/积分任务中心需求文档.md`、`projects/剧说/02-技术方案/积分任务中心技术文档.md`、`projects/剧说/03-前端/开发计划/08-积分任务中心前端开发文档.md`、`projects/剧说/04-后端/开发计划/09-积分任务中心后端开发文档.md`
  - 后端：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/task/**`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/controller/AdminTaskCenterController.java`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V12__task_center.sql`
  - App：`/Users/soul/code/lxwx/narrate/lib/pages/task_center/**`、`/Users/soul/code/lxwx/narrate/lib/apis/tasks.dart`、`/Users/soul/code/lxwx/narrate/lib/models/data/task_center_overview.dart`、`/Users/soul/code/lxwx/narrate/lib/models/data/task_check_in_result.dart`
  - 后台 Web：`/Users/soul/code/lxwx/lxwx_admin/lib/pages/task_center_page.dart`、`/Users/soul/code/lxwx/lxwx_admin/lib/models/admin_models.dart`、`/Users/soul/code/lxwx/lxwx_admin/lib/core/api_client.dart`、`/Users/soul/code/lxwx/lxwx_admin/lib/data/admin_repository.dart`
- 验证：
  - `/Users/soul/code/lxwx/lxwx_service/lxwxservice`：`./gradlew test` 通过。
  - `/Users/soul/code/lxwx/narrate`：`flutter analyze`、`flutter test` 通过。
  - `/Users/soul/code/lxwx/lxwx_admin`：`flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。

### CHG-0011 邀请好友逻辑跨端实现与兑换码补充

- 类型：`feature_add`
- 版本号：`v0.7.0`
- 状态：`done`
- 提出时间：`2026-06-02 12:42`
- 完成时间：`2026-06-02 19:03`
- 触发原因：用户要求“剧说新增邀请好友逻辑”，审核文档后继续跨端编码；随后补充 App UI 使用 Figma channel `slk656ok` 设计稿，并补齐兑换码入口、批次商品二选一和后台管理。
- 核心规则：
  - 注册奖励积分默认 `10` 积分，后台可配置。
  - 个人代理等级只影响直接返佣：1 级 `10%`、2 级 `20%`、3 级 `30%`。
  - 关系层级只影响直接 / 间接收益范围；间接收益由后台按用户开启，固定 `10%`，只穿一层。
  - 会员返佣只返被邀请人第一次开通会员订单；续费会员、再次开通会员和充值积分都不返。
  - 同一兑换码批次只能发放一种商品：积分或会员天数二选一，不能同时发放。
- 影响范围：
  - 需求文档：是，已补充邀请、收益、提现、落地页和兑换码补充规则。
  - Figma：未生成新 UI；App 邀请与兑换码 UI 均读取并复用 channel `slk656ok` 现有设计稿。
  - Flutter App：是，邀请中心、登录邀请码、兑换码入口与兑换页、API adapter 和 mock 均已修改。
  - Java 后端：是，邀请绑定、注册送积分、首次会员返佣、一层间接返佣、收益账本、提现、兑换码批次与兑换接口均已落地。
  - 后台 Web：是，新增邀请收益管理与兑换码管理，覆盖规则配置、用户代理配置、提现审核、批次启停和兑换记录。
- 主要改动清单：
  - 文档：`projects/剧说/01-需求/邀请好友需求文档.md`、`projects/剧说/02-技术方案/邀请好友技术文档.md`、`projects/剧说/03-前端/开发计划/07-邀请好友前端开发文档.md`、`projects/剧说/04-后端/开发计划/08-邀请好友后端开发文档.md`
  - 后端：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/invite/**`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/redeem/**`、`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V11__redeem_codes.sql`
  - App：`/Users/soul/code/lxwx/narrate/lib/pages/invite/**`、`/Users/soul/code/lxwx/narrate/lib/pages/redeem_code/**`、`/Users/soul/code/lxwx/narrate/lib/apis/invite.dart`、`/Users/soul/code/lxwx/narrate/lib/apis/redeem_code.dart`
  - 后台 Web：`/Users/soul/code/lxwx/lxwx_admin/lib/pages/invite_page.dart`、`/Users/soul/code/lxwx/lxwx_admin/lib/pages/redeem_codes_page.dart`
- 验证：
  - `/Users/soul/code/lxwx/lxwx_service/lxwxservice`：`./gradlew testClasses`、`./gradlew test` 通过。
  - `/Users/soul/code/lxwx/narrate`：`flutter analyze`、`flutter test` 通过。
  - `/Users/soul/code/lxwx/lxwx_admin`：`flutter analyze`、`flutter test`、`flutter build web --release --no-wasm-dry-run --no-web-resources-cdn` 通过。

### CHG-0001 后端 Java 方案评估

- 类型：`tech_adjust`
- 版本号：`v0.2.0`
- 状态：`done`
- 触发原因：用户要求继续“剧说”的后端方案评估，并明确后端开发技术采用 Java。
- 影响范围：
  - PRD：否
  - 技术方案：是，补充 Java 后端方案评估
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，继续保持 mock / adapter 先行策略
  - Java 模块：是，作为后续 `java-tech.md`、`java-dev-plan.md` 输入
- 最小改动清单：
  - 新增：`projects/剧说/02-技术方案/backend-evaluation.md`
  - 修改：`projects/剧说/02-技术方案/tech-plan.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0002 后端方案评估深化

- 类型：`tech_adjust`
- 版本号：`v0.2.1`
- 状态：`done`
- 触发原因：继续推进后端方案评估，使评估结果达到可生成 `java-tech.md` 的程度。
- 影响范围：
  - PRD：否
  - 技术方案：是，补充接口契约草案、状态机、账本规则、支付幂等和 Provider Adapter
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，继续保持 mock / adapter 先行策略
  - Java 模块：是，作为后续后端技术文档输入
- 最小改动清单：
  - 修改：`projects/剧说/02-技术方案/backend-evaluation.md`
  - 修改：`projects/剧说/02-技术方案/tech-plan.md`
  - 修改：`projects/剧说/workflow.md`

### CHG-0003 百度 VOD 接入口径确认

- 类型：`tech_adjust`
- 版本号：`v0.2.2`
- 状态：`done`
- 触发原因：用户确认视频业务处理接入百度智能云智能点播平台 VOD。
- 影响范围：
  - PRD：否
  - 技术方案：是，视频业务供应商从待确认推进为百度 VOD
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，Flutter 仍通过 API / SDK adapter，不直连 VOD 密钥
  - Java 模块：是，后续 `java-tech.md` 需要设计 `BaiduVodProvider`
- 最小改动清单：
  - 修改：`projects/剧说/02-技术方案/backend-evaluation.md`
  - 修改：`projects/剧说/02-技术方案/tech-plan.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0004 Java 文档推进到模块开发

- 类型：`doc_generation`
- 版本号：`v0.3.0`
- 状态：`done`
- 触发原因：用户要求“按照流程到 Java 模块开发。前端的开发请忽略”。
- 影响范围：
  - PRD：否
  - 技术方案：否，沿用既有 Java + Gradle + 百度 VOD 口径
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，本轮明确忽略前端开发
  - Java 模块：是，生成 Java 技术文档、总体开发计划和模块开发文档
- 最小改动清单：
  - 新增：`projects/剧说/04-后端/java-tech.md`
  - 新增：`projects/剧说/04-后端/java-dev-plan.md`
  - 新增：`projects/剧说/04-后端/开发计划/01-基础设施.md`
  - 新增：`projects/剧说/04-后端/开发计划/02-账号鉴权与用户.md`
  - 新增：`projects/剧说/04-后端/开发计划/03-积分账务.md`
  - 新增：`projects/剧说/04-后端/开发计划/04-支付会员.md`
  - 新增：`projects/剧说/04-后端/开发计划/05-百度VOD素材与生成.md`
  - 新增：`projects/剧说/04-后端/开发计划/06-作品服务.md`
  - 新增：`projects/剧说/04-后端/开发计划/07-邀请反馈配置.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0005 Java 项目目录结构调整

- 类型：`doc_adjust`
- 版本号：`v0.3.1`
- 状态：`done`
- 触发原因：用户提供新的后端目录结构，要求按该结构调整项目目录。
- 影响范围：
  - PRD：否
  - 技术方案：否
  - 工时评估：否
  - Flutter 模块：否
  - Java 模块：是，调整技术文档、总体计划和模块文档中的包路径 / 模块归属
- 最小改动清单：
  - 修改：`projects/剧说/04-后端/java-tech.md`
  - 修改：`projects/剧说/04-后端/java-dev-plan.md`
  - 修改：`projects/剧说/04-后端/开发计划/*.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0006 Java T-B001 基础设施落地

- 类型：`code`
- 版本号：`v0.3.2`
- 状态：`done`
- 触发原因：用户说明工程目录已创建，要求重新开始并按流程进入 Java 模块开发。
- 影响范围：
  - PRD：否
  - 技术方案：否，沿用 Java + Gradle + 百度 VOD 口径
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，本轮明确忽略前端开发
  - Java 模块：是，落地 T-B001 工程基础设施并同步任务状态
- 最小改动清单：
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/settings.gradle`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/gradle/wrapper/gradle-wrapper.properties`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/.gitignore`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/application.yml`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V1__init_schema.sql`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/ServerApplicationTests.java`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/resources/application-test.yml`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/README.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/04-后端/java-dev-plan.md`
  - 修改：`projects/剧说/04-后端/开发计划/01-基础设施.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0007 Java 真实包名修正

- 类型：`code_adjust`
- 版本号：`v0.3.3`
- 状态：`done`
- 触发原因：用户确认此前包名只是目录结构模板，真实包名应为 `com.lxwx.narrateservice`。
- 影响范围：
  - PRD：否
  - 技术方案：否
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否
  - Java 模块：是，修正源码目录、package/import、扫描路径、Gradle group 与文档包名口径
- 最小改动清单：
  - 移动：Java main 源码从模板包路径迁移到 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/**`
  - 移动：Java test 源码从模板包路径迁移到 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/**`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/README.md`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/04-后端/java-tech.md`
  - 修改：`projects/剧说/04-后端/java-dev-plan.md`
  - 修改：`projects/剧说/04-后端/开发计划/*.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0008 Java T-B002 账号鉴权与用户落地

- 类型：`code`
- 版本号：`v0.4.0`
- 状态：`done`
- 触发原因：用户要求继续下一步，按 Java 开发计划进入 `T-B002 账号鉴权与用户`。
- 影响范围：
  - PRD：否
  - 技术方案：否
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，本轮明确忽略前端开发
  - Java 模块：是，新增账号鉴权、mock 短信、一键登录占位、JWT 鉴权和用户资料聚合
- 最小改动清单：
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/README.md`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/application.yml`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/resources/application-test.yml`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/common/security/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/auth/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/user/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/entitlement/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AuthUserIntegrationTests.java`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/04-后端/java-tech.md`
  - 修改：`projects/剧说/04-后端/java-dev-plan.md`
  - 修改：`projects/剧说/04-后端/开发计划/02-账号鉴权与用户.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0009 Java T-B003 至 T-B011 编码收口

- 类型：`code`
- 版本号：`v0.5.0`
- 状态：`done`
- 触发原因：用户要求“把编码任务都完成，不要等我确定了”。
- 影响范围：
  - PRD：否
  - 技术方案：否，沿用 Java + Gradle + 百度 VOD Provider Adapter 口径
  - 工时评估：否，本轮不输出人天或日历排期
  - Flutter 模块：否，本轮明确忽略前端开发
  - Java 模块：是，完成 T-B003 至 T-B011 后端编码、迁移和集成测试
- 最小改动清单：
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/README.md`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/common/security/SecurityConfig.java`
  - 新增 / 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/entitlement/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/product/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/order/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/payment/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V2__seed_app_configs.sql`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V3__add_idempotency_keys.sql`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/BackendWorkflowIntegrationTests.java`
  - 修改：`projects/剧说/workflow.md`
  - 修改：`projects/剧说/04-后端/java-tech.md`
  - 修改：`projects/剧说/04-后端/java-dev-plan.md`
  - 修改：`projects/剧说/04-后端/开发计划/03-积分账务.md`
  - 修改：`projects/剧说/04-后端/开发计划/04-支付会员.md`
  - 修改：`projects/剧说/04-后端/开发计划/05-百度VOD素材与生成.md`
  - 修改：`projects/剧说/04-后端/开发计划/06-作品服务.md`
  - 修改：`projects/剧说/04-后端/开发计划/07-邀请反馈配置.md`
  - 修改：`projects/剧说/change-plan.md`
  - 修改：`projects/剧说/change-log.md`

### CHG-0010 App 首页热门案例管理

- 类型：`feature`
- 版本号：`v0.6.0`
- 状态：`done`
- 触发原因：用户要求新增后台管理页面，用于配置 App 首页热门案例数据；分类名称必须可维护，并保留「漫剧解说」分类口径。
- 影响范围：
  - PRD：否
  - 技术方案：是，新增首页运营配置能力
  - 工时评估：否
  - Flutter App：是，首页热门案例分类与列表改为读取后端接口，卡片点击只增加使用次数
  - Flutter Admin：是，新增「热门案例管理」页面、分类维护、封面上传、预览、上下架和删除操作
  - Java 后端：是，新增热门案例分类、案例、操作审计表和 `/api/config/home-cases/**`、`/api/admin/home-cases/**` 接口
- 最小改动清单：
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/narrate/homecase/**`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/controller/AdminHomeCase*.java`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/dto/HomeCase*.java`
  - 新增：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V5__home_hot_cases.sql`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/common/config/WebConfig.java`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/application.yml`
  - 修改：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AdminManagementIntegrationTests.java`
  - 新增：`/Users/soul/code/lxwx/lxwx_admin/lib/pages/hot_cases_page.dart`
  - 修改：`/Users/soul/code/lxwx/lxwx_admin/lib/core/api_client.dart`
  - 修改：`/Users/soul/code/lxwx/lxwx_admin/lib/models/admin_models.dart`
  - 修改：`/Users/soul/code/lxwx/lxwx_admin/lib/pages/shell_page.dart`
  - 修改：`/Users/soul/code/lxwx/lxwx_admin/test/admin_repository_test.dart`
  - 修改：`/Users/soul/code/lxwx/narrate/lib/apis/home.dart`
  - 修改：`/Users/soul/code/lxwx/narrate/lib/models/data/home_case.dart`
  - 修改：`/Users/soul/code/lxwx/narrate/lib/pages/home/controller.dart`
  - 修改：`/Users/soul/code/lxwx/narrate/lib/pages/home/view.dart`

---

## 影响文件清单（聚合视图）

| 文件 | 影响来源 CHG-id | 影响原因 | 处理方式 |
|------|----------------|----------|----------|
| `projects/剧说/02-技术方案/backend-evaluation.md` | CHG-0001 / CHG-0002 / CHG-0003 | 新增并深化后端 Java 方案评估，确认百度 VOD 接入口径 | 已同步 |
| `projects/剧说/02-技术方案/tech-plan.md` | CHG-0001 / CHG-0002 / CHG-0003 | 从后端完全待定推进到 Java + Gradle + 百度 VOD 评估口径 | 已同步 |
| `projects/剧说/workflow.md` | CHG-0001 / CHG-0002 / CHG-0003 | 回写当前阶段、恢复点、Java 后端流程项和百度 VOD 接入信息 | 已同步 |
| `projects/剧说/change-plan.md` | CHG-0001 / CHG-0002 / CHG-0003 | 归档本轮变更 | 已同步 |
| `projects/剧说/change-log.md` | CHG-0001 / CHG-0003 | 记录 v0.2.0 至 v0.2.2 技术方案变更 | 已同步 |
| `projects/剧说/04-后端/java-tech.md` | CHG-0004 | 生成 Java 后端技术文档 | 已新增 |
| `projects/剧说/04-后端/java-dev-plan.md` | CHG-0004 | 生成 Java 总体开发计划 | 已新增 |
| `projects/剧说/04-后端/开发计划/*.md` | CHG-0004 | 生成 Java 模块开发文档 | 已新增 |
| `projects/剧说/workflow.md` | CHG-0004 | 回写当前阶段到 Java 模块开发完成 | 已同步 |
| `projects/剧说/04-后端/java-tech.md` | CHG-0005 | 调整 Java 工程目录树为基础业务 / 具体业务 / 后台管理结构 | 已同步 |
| `projects/剧说/04-后端/java-dev-plan.md` | CHG-0005 | 调整任务模块归属到 `product/order/payment/entitlement/app/*` | 已同步 |
| `projects/剧说/04-后端/开发计划/*.md` | CHG-0005 | 调整模块文档代码清单路径 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/**` | CHG-0006 | 落地 Java 后端 T-B001 基础设施代码、配置、迁移脚本和测试基线 | 已同步 |
| `projects/剧说/workflow.md` | CHG-0006 | 回写 Java 编码阶段、后端工程路径、T-B001 完成状态和恢复点 | 已同步 |
| `projects/剧说/04-后端/java-dev-plan.md` | CHG-0006 | 将 B-Stage-01 / T-B001 状态更新为 `done`，后续恢复点指向工程根 | 已同步 |
| `projects/剧说/04-后端/开发计划/01-基础设施.md` | CHG-0006 | 将基础设施模块状态、前置条件、任务清单和验证记录更新为已完成 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/**` | CHG-0007 | 将模板包名修正为真实包名，并压平多余 `server` 目录层级 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/**` | CHG-0007 | 同步测试包名与目录 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/build.gradle` | CHG-0007 | Gradle group 改为 `com.lxwx`，版本推进到 `0.3.3` | 已同步 |
| `projects/剧说/04-后端/**` | CHG-0007 | 所有 Java 后端文档统一真实包名 `com.lxwx.narrateservice` | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/auth/**` | CHG-0008 | 实现验证码、mock provider、JWT token、登录和退出登录 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/user/**` | CHG-0008 | 实现用户创建、我的页资料聚合和注销申请 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/common/security/**` | CHG-0008 | 接入 JWT 鉴权过滤器与 REST 401 响应 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/AuthUserIntegrationTests.java` | CHG-0008 | 覆盖 T-B002 关键接口闭环 | 已同步 |
| `projects/剧说/workflow.md` | CHG-0008 | 回写 T-B002 完成状态和下一步 T-B003 | 已同步 |
| `projects/剧说/04-后端/java-dev-plan.md` | CHG-0008 | 将 B-Stage-02 / T-B002 状态更新为 `done` | 已同步 |
| `projects/剧说/04-后端/开发计划/02-账号鉴权与用户.md` | CHG-0008 | 将模块状态、执行记录和验证结果更新为已完成 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/entitlement/**` | CHG-0009 | 实现积分账务、会员状态和权益激活 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/product/**` | CHG-0009 | 实现商品 / 会员套餐能力 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/order/**` | CHG-0009 | 实现支付订单创建 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/payment/**` | CHG-0009 | 实现 mock 支付、支付回调、Provider 事件和幂等 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/**` | CHG-0009 | 实现素材、创作、生成、作品、邀请、反馈和配置模块 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/**` | CHG-0009 | 实现后台配置预留接口 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V2__seed_app_configs.sql` | CHG-0009 | 初始化默认预设、计费和静态协议配置 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/db/migration/V3__add_idempotency_keys.sql` | CHG-0009 | 增加素材和生成任务幂等键 | 已同步 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/BackendWorkflowIntegrationTests.java` | CHG-0009 | 覆盖 T-B003 至 T-B011 关键闭环 | 已同步 |
| `projects/剧说/04-后端/java-tech.md` | CHG-0009 | 回写 T-B001 至 T-B011 已完成状态 | 已同步 |
| `projects/剧说/04-后端/java-dev-plan.md` | CHG-0009 | 回写 B-Stage-03 至 B-Stage-07、T-B003 至 T-B011 已完成状态 | 已同步 |
| `projects/剧说/04-后端/开发计划/03-积分账务.md` 至 `07-邀请反馈配置.md` | CHG-0009 | 回写模块任务、执行记录和验证结果 | 已同步 |

---

## 不应改动范围（聚合视图）

- 不处理真实百度 VOD、短信、一键登录、支付供应商和人工打款 SDK 联调。
- 不输出工时、人天或日历排期。
- 不生成新的 Figma UI；App 邀请与兑换码 UI 复用 channel `slk656ok` 现有设计稿。

---

## 完成记录

| 时间 | CHG-id | 操作 | 修改文件 | 结果 |
|------|--------|------|----------|------|
| 2026-05-18 11:26 | 无 | 创建变更计划骨架 | `projects/剧说/change-plan.md` | 已创建，暂无进行中变更 |
| 2026-05-18 16:00 | CHG-0001 | 生成后端 Java 方案评估并同步技术方案 | `backend-evaluation.md`、`tech-plan.md`、`workflow.md`、`change-plan.md`、`change-log.md` | 已完成 |
| 2026-05-18 16:05 | CHG-0002 / CHG-0003 | 深化后端方案评估并纳入百度 VOD | `backend-evaluation.md`、`tech-plan.md`、`workflow.md`、`change-plan.md`、`change-log.md` | 已完成 |
| 2026-05-19 | CHG-0004 | 推进到 Java 模块开发文档阶段 | `java-tech.md`、`java-dev-plan.md`、`04-后端/开发计划/*.md`、`workflow.md`、`change-plan.md`、`change-log.md` | 已完成 |
| 2026-05-19 | CHG-0005 | 调整 Java 项目目录结构 | `java-tech.md`、`java-dev-plan.md`、`04-后端/开发计划/*.md`、`workflow.md`、`change-plan.md`、`change-log.md` | 已完成 |
| 2026-05-19 | CHG-0006 | 落地 Java T-B001 基础设施 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`workflow.md`、`java-dev-plan.md`、`01-基础设施.md`、`change-plan.md`、`change-log.md` | 已完成，`./gradlew build` 通过 |
| 2026-05-19 | CHG-0007 | 修正 Java 后端真实包名 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`workflow.md`、`java-tech.md`、`java-dev-plan.md`、`04-后端/开发计划/*.md`、`change-plan.md`、`change-log.md` | 已完成，`./gradlew build` 通过 |
| 2026-05-19 | CHG-0008 | 落地 Java T-B002 账号鉴权与用户 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`workflow.md`、`java-tech.md`、`java-dev-plan.md`、`02-账号鉴权与用户.md`、`change-plan.md`、`change-log.md` | 已完成，`./gradlew build` 通过 |
| 2026-05-19 | CHG-0009 | 落地 Java T-B003 至 T-B011 后端编码收口 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice/**`、`workflow.md`、`java-tech.md`、`java-dev-plan.md`、`03-积分账务.md` 至 `07-邀请反馈配置.md`、`change-plan.md`、`change-log.md` | 已完成，`./gradlew build` 通过 |
| 2026-06-02 14:43 | CHG-0011 | 按用户确认细化邀请奖励和返佣规则 | 4 份邀请好友独立审核文档、`workflow.md`、`change-plan.md` | 已同步注册奖励 10 积分、直接返佣等级、间接收益开关和首次会员返佣限制 |
| 2026-06-02 15:40 | CHG-0011 | 进入跨端编码并按 Figma channel `slk656ok` 重做 App UI | Java 后端、App Flutter、后台 Web、`workflow.md`、`change-plan.md` | 邀请好友闭环已落地；App UI 按 Figma channel `slk656ok` 实现 |
| 2026-06-02 19:03 | CHG-0011 | 补齐兑换码功能并完成跨端验证归档 | 后端兑换码迁移与接口、App 兑换码入口与页面、后台 Web 兑换码管理、`workflow.md`、`change-plan.md`、`change-log.md` | 已归档为 `v0.7.0`；后端、App、后台 Web 验证均通过 |
