# 邀请好友 + 银行卡提现 · 三端本地验证

## 2026-09-03 静态协议页面环境根地址统一

状态：`waiting_review`。本次只修改 Catseller 配置文件归属、静态页面最终 URL 和阿里云一键登录协议参数，不修改 Java/Admin/Web、数据库、服务器配置、实名签约或资金提交。

### 根因与实现

- 当前本地包环境是 local，API 根地址为 `http://192.168.31.243:8080`。旧解析把 P09 模板 path 替换到该 origin，实际请求返回 `404 application/json`；相同本地公开规则 API 返回成功，证明 IP/端口可达，缺失的是 Java 端口上的静态 Web 资源。
- `constants.dart`、`privacy_consent.dart` 已从 `lib/utils/` 迁移到 `lib/config/`，由 `config/index.dart` 聚合且不保留 utils 兼容导出；隐私同意文件迁移前后 SHA-256 均为 `0c6c11cd7118679a2d769f093d5cfa0ee94f037e5ec2519914581bb4a7047f26`。
- `Global` 的原环境配置块保持不变，仍通过 `currentServerAddressType = 1/2/3` 切换环境，三个 server address 继续引用 `AppConstants`。所有 `legalPageUrls` 直接保存最终地址：local/test 使用测试站 root，production 使用正式站 root；P09 的 URL 直接包含 `appCode=catseller&embedded=1&v=20260828-display`，不再读取 API baseUrl 二次解析。
- `StaticPageController` 和阿里云号码认证 SDK 的用户协议/隐私政策直接读取同一 map；`AliyunNumberAuthService` 构造不再接收 `apiBaseUrl`。路由查询参数仍不能覆盖 pageKey/URL；不向 WebView 注入 JWT 或用户资料。

### 验证

- 修改后协议版本、规则地址、App 身份和邀请提现共 69 项通过；覆盖全部 9 个页面 key 的当前 local 测试站根地址、完整 path/query、P09 路由和账号门禁。
- `test/widget_test.dart` 的静态常量与阿里云原生授权页协议参数 2 项通过；SDK `configure` 收到 map 中的测试站用户协议与隐私政策最终地址。
- `flutter analyze` 无问题。最新 Flutter 全量为 342 通过、7 个既有 Golden 失败：`split Figma identity`、`small screen keyboard identity`、`split error state identity` 为旧基线像素差异，4 个 work-detail 用例因对应基线文件不存在失败；未更新无关 Golden。
- `flutter build apk --debug --no-pub` 成功，产物为 `build/app/outputs/flutter-apk/app-debug.apk`。构建仍提示既有 `flutter_secure_storage` 建议 compileSdk 37（当前 36），但未阻断本次 APK；本轮未顺带修改 Android 构建配置。
- 只读网络检查：测试站与正式站的 9 个当前模板路径均返回 `200 text/html`。本轮未部署、未修改运行中的 Java/Web 服务，真实 Android/iOS WebView 与缓存行为待更新包验收。

## 2026-09-02 佣金明细卡种展示修复

状态：`waiting_review`。本次只修改共享 Java 佣金列表只读字段和 Catseller P04 展示；其他 App 客户端、资金结算、退款、比例、提现和数据库均未修改。未部署、未连接线上接口或执行真机验收。

### 实现与合同

- `GET /api/invite/earnings/ledgers` 路径及既有字段保持不变，列表项新增可空字符串 `productName`；OpenAPI 说明其来源为会员订单商品名称快照并标记 nullable。
- 后端收集当前页订单号，通过核心订单 Service 一次查询当前 App schema 的 `payment_orders.product_name`，限定 `MEMBERSHIP`；不添加软删除过滤，因此历史软删除订单仍可显示。无订单的期初余额、缺失/非会员订单返回空，不跨 App、不按金额猜卡种。
- Catseller 的 `DIRECT_REWARD` 有快照时显示“好友开通月卡/季卡/年卡”，缺失时显示“好友开通会员”；退款冲正、间接收益和期初余额原文案不变。其他 App 客户端未修改。
- 数据库改动：无。未新增/修改 Flyway、表、字段、索引、回填、配置或订单写入逻辑。

### 本地验证

- `./gradlew test --tests com.lxwx.narrateservice.InviteBankWithdrawalIntegrationTests --rerun-tasks --console=plain`：69 项通过。覆盖月卡返回、软删除仍读取、缺失订单空值、同一订单号在 Catseller/Catsinger schema 返回各自快照，以及 OpenAPI `type=string/nullable=true/商品名称快照`。
- `./gradlew test --console=plain`：1093 项完成，1085 通过、7 失败、1 跳过。7 项均为无关 `SongWorkLifecycleIntegrationTests`：首项在 Spring 上下文创建时 JVM `OutOfMemoryError`，其余因上下文失败阈值连锁失败；该类随后单独运行 7 项全部通过。本次全量不能记为通过。
- `flutter test --no-pub test/invite_bank_flow_test.dart --reporter compact`：49 项通过；覆盖月卡、季卡、年卡、缺失/空白兜底、旧标题消失、退款/期初文案不变及 P04 Golden。
- `flutter analyze --no-pub`：通过。只更新本机既有忽略目录内的 `07-commission-list` Golden；与 Figma `43:2285` 原图目视比较，卡种标题一致，金额、状态、手机号、日期和布局未见回归。

### 交付边界

本地 H2、MockMvc、Widget 和 Golden 结果不代替线上历史订单、运行服务或 Android/iOS 真机验收。发布时需先更新共享 Java 接口，再更新 Catseller；旧后端返回缺失字段时新 App 会显示“好友开通会员”，不会恢复旧“首单奖励”标题。

## 2026-08-28 工猫 H5 域名白名单开关

状态：`waiting_review`。本次仅 Java + catseller 认证链路、配置与开发记录；未改 Admin/Web 页面、退款、资金状态机或其他 App 的客户端。数据库改动：无。未部署、未触发真实认证/提现，保留各工程已有改动。

### 已实现

- 平台共享 `app.gongmall.h5-allowed-hosts-enabled`，未配置 true，TEST/PRODUCTION 均可显式 false，支持 `GONGMALL_H5_ALLOWED_HOSTS_ENABLED`。本机 Git 忽略的 `config/application.yml` 默认 false、白名单仍为空，未改服务器配置或密钥。
- 开启要求有效非空名单；关闭仅略过名单校验和精确匹配，不略过凭据、BANK、业务资格、HTTPS/合法域名/443/无用户信息。认证创建/确认及连接状态响应包含布尔 `h5AllowedHostsEnabled`，OpenAPI 同步。
- App 仅布尔 false 关闭列表检查；初始加载、导航和权限来源统一策略，其他值默认开启。保留证书默认验证、精确回跳、用户相机授权、禁文件与无 JWT/JS bridge 注入。补齐空用户信息 `https://@host` 的原始 authority 校验。
- 后端启动关闭警告与 `工猫认证地址域名: host=`；App Debug 关闭模式按容器去重输出 `[工猫 H5 域名] host=`，不自动保存/信任域名。SDK 原始调试日志在认证容器存活期间临时全局静默，退出后恢复原设置；此时其他 WebView 的 SDK 原始日志也静默，但不影响页面行为，域名诊断独立保留。

### 自动化结果

| 验证 | 结果与边界 |
|---|---|
| 后端改前定向 `GongmallConfigurationTests` | 11 项中 3 项失败，复现缺少开关响应、TEST/PRODUCTION 关闭后仍被空名单阻断 |
| 后端标准 `./gradlew test` | 未通过；当次 1472 项中 515 失败、3 跳过。工作区另一项 maintenance 改动将 `CoverLyricsMaintenanceConfiguration` 加入测试 classpath，与主服务 `SchemaRoutingDataSourceConfig` 的 `dataSource` Bean 重名，阻断大量 Spring 集成测试。更早一次还被该任务进行中的缺失类型阻断；未改动/回滚相关代码 |
| 临时隔离维护入口的后端验证 | `./gradlew test -I /tmp/gongmall-h5-verification.2yG3Zs/invite-only.gradle --tests '*Invite*' --tests '*Gongmall*'`：13 组、179 项通过，0 失败/跳过。仅从此轮测试 classpath 排除 maintenance output，主服务和测试用例保持原样；不是全量测试通过，也不是生产配置变更 |
| App 格式与静态分析 | 对本次 9 个 Dart 文件运行 `dart format`；最终 `flutter analyze --no-pub` 无问题 |
| App 邀请回归 | `flutter test --no-pub test/invite_h5_policy_test.dart test/invite_bank_flow_test.dart test/invite_contract_types_test.dart test/invite_rules_url_test.dart`：57 项全部通过。未运行/宣称 App 全量通过 |
| 差异与流程门禁 | 两端及流程工作区 `git diff --check`，本地运行手册 whitespace 检查；工作区写前 check，收尾 audit。未修改其他 CHG 状态 |

后端专项覆盖：默认开启、环境变量覆盖、TEST/PRODUCTION 显式关闭且空/无效名单、其他必要配置缺失/BANK 关闭、非法 URL、创建/确认布尔字段与空名单、OpenAPI、日志精确输出域名且不含查询串/路径/凭据、原合同确认及资金幂等回归。

App 专项覆盖：缺失/null/字符串/数值等开关异常默认开启、空名单下两种初始加载、后续导航与 onLoadStart、相机拒绝与授权、陌生来源和非相机权限拒绝、回跳只触发一次、系统证书策略及禁文件设置、域名去重和 SDK 日志恢复；另通过真实认证页面 + Mock transport 验证 `false` 透传、空名单下进入 H5、回跳后调用一次 confirm 并显示成功。WebView 使用测试平台替身、系统权限用测试 channel，不访问真实工猫、不打开相机，不代表真机验收。

临时专项 XML/HTML 保留在 `/tmp/gongmall-h5-verification.2yG3Zs/` 供本机复核；正式发布前需先解决无关 maintenance 冲突并重跑标准全量测试。运行说明见 [工猫配置手册](/Users/soul/code/lxwx/lxwx_service/lxwxservice/docs/invite-gongmall-operations.md)。

### 用户后续验收（未代执行）

1. 重启后端和更新后的 App；确认关闭模式存在启动警告，其他配置齐全。**单纯启动不获取 authUrl**。
2. 主动发起本人实名认证，确认页面可打开；后端日志只有初始域名，App Debug 的新跳转/权限来源只出现一次域名，不含链接令牌/资料。
3. 拒绝相机后不得授予，重新授权后可继续；退出/回跳由后端 confirm 确认合同，不能仅凭 H5 文案判成功。双平台真实设备仍待验收。
4. 向工猫确认当前环境必要域名，填写名单、开关改 true、重启并退出重进认证页；已知域名正常加载，陌生域名/非法 URL 继续拒绝。回跳域名用独立精确匹配，不因日志中出现就自动加入名单。

---

> 2026-08-27 / CHG-0068 / waiting_review。与真实工猫环境验收分开记账。

## 1. 已执行

| 范围 | 命令/方式 | 结果 |
|---|---|---|
| Java | `./gradlew test build` | 1248 项，0 失败/错误，3 跳过；test 与 build 成功 |
| Java 邀请/工猫 | 集成/并发/加密/Gateway/权限/OpenAPI | 67 项全部通过，含监控隔离与 SQL 验证 |
| 数据库 | 隔离 PostgreSQL 16，无网络/端口，tmpfs | common V1.1～V4.7 + platform V4.0/V4.1 共 14 个脚本顺序执行成功；容器已停止并自动删除 |
| Admin | `flutter test --no-pub` | 163 项全部通过 |
| Admin | `flutter analyze --no-pub` / Web release build | 无问题 / 构建成功 |
| App 邀请专项 | 31 页面/行为 + 6 契约测试 | 37 项通过，22 图逐页比较；不是工猫真实环境验收 |
| App 全量 | `flutter test --no-pub` | 242 通过、11 失败，不计全量通过 |
| App 构建 | Android debug APK；iOS main/离线 preview simulator | 均成功；Android 有现存插件 SDK 37 建议警告，当前 SDK 36 构建仍通过 |
| App 静态检查 | `flutter analyze --no-pub` | No issues found |
| 原生操作 | iPhone 17 Pro / iOS 26.4 | 离线真实 Widget：邀请入口→推广素材、提现输入/协议/试算/提交/结果；无真实资金 |
| 活动规则 Web | 浏览器 + 本地虚构 API | catseller 的 7 天/1 元与 otherapp 的 14 天/10 元隔离；缺 App/停用失败关闭，重试可用，embedded 无重复标题 |

SQL 重放不等于 PostgreSQL 整套应用/Flyway 运行时联调。Spring 集成测试使用隔离 H2 PostgreSQL 模式，OpenAPI 通过真实测试路径 `/v3/api-docs` 检查，不声称已部署服务已更新。

## 2. 高风险用例

已覆盖：重复首单/退款通知、比例升级仅后续订单、不足 1 分舍去、累计部分退款及全额补齐、N 天精确到期/配置快照、退款先到、负余额；并发提现单一赢家、每日一次、金额冻结/驳回返还、提交前退款及派发后退款；未知提交不得重发、重复回调不直接改资金、原 ID 查单、成功后退票一次返还；App 关闭后历史对账持续；跨 App 权限/数据、查看密码五次锁定、单条字段最小化、解析错误不输出敏感 body；旧资金预检/摘要变化拒绝/切换日/幂等启用/停用不丢账。

Admin 最后增加 4 项测试，验证敏感查看 5 分钟清空、退后台清空/切 App 关闭详情、无权限不显示查看入口、新模式金额拒绝小数。测试发现明文复用了可复制文本组件，已改为不可选取文本，仅修改本功能详情，不影响其他后台页面；不宣称可以防止截图或人工抄录。

GongmallGateway 使用模拟 HTTP 返回验证字段/金额/状态；配置与密码为测试专用。RSA 传输与 AES-GCM 存储分工符合当前确认技术方案。

## 3. App 全量测试未通过项

本轮邀请测试均通过；11 项失败集中于非邀请页面：视频/脚本失败返回导航、协议常量 URL、首页“一键生成”、设置退出/注销返回页面、作品详情视觉基线、反馈弹层。未在干净工作树独立复跑，不能直接宣称已证明是历史基线问题；不为让测试全绿修改用户范围外业务。

详细测试日志在本机 `/tmp/catseller-invite-full-test.log`；临时日志会被系统清理，结论以本文及提交的测试用例为持久记录。

## 4. 未执行与上线门禁

- 未连接真实工猫、未真人刷脸/签约、未真实银行卡校验/打款/退票；等待用户在私有 config 填参数。
- 未部署 Web/后端、未增加生产 App 权限、未启用 DIRECT_BANK_GONGMALL、未回填历史余额。
- 未执行 Android 真机和两平台真实 WebView 摄像头/恢复验收；模拟器及 Widget 通过不能替代。分享/保存权限、Admin 真实会话离页/退出清理仍保留操作验收项。
- 真实退票查单语义、商户余额/BANK/模板、上线文案、告警接收渠道、生产容量需环境确认。
- 当前已接会员成功事件及 Apple 已验签退款；其他真实支付渠道退款协议与异常退款金额人工核对需单独验收，不能泛称全部渠道已通。

配置/迁移/运维入口见 [后端运行手册](/Users/soul/code/lxwx/lxwx_service/lxwxservice/docs/invite-gongmall-operations.md)，页面对照见 [design-qa.md](../03-前端/design-qa.md)。

## 数据库改动

有：common V4.5/V4.6/V4.7，platform V4.1。仅隔离测试执行；真实业务库无变更，无真实资金迁移。已有旧账和其他 App 模式保持不变。

## 5. 最终更新记录

最终统计由 Gradle JUnit XML 与 Flutter 结束行核对：Java 1248 项（1245 通过、3 跳过），其中邀请/工猫 67 项全部通过；Admin 163 项全部通过；App 邀请 37 项全部通过。App/Admin analyze 无问题，Android debug APK、iOS main simulator、Admin Web release 构建成功。

App 全量仍为 242 通过、11 失败，不能把专项通过写成全量通过。真实资金和外部验收边界仍以上述第 4 节为准。文档已同步模块恢复点，不重做或自动进入部署。

最终文档检查：21 份恢复点/模块/验收文档的本地链接与代码围栏通过，22 个 Figma 节点及原图/实现图链接均有效；App、Java、Admin、流程工作区的 `git diff --check` 通过；`workspace-path-guard.sh audit` 通过。私有 `config/application.yml` 的 Git 忽略状态已确认，未读取或输出真实密钥。


## 2026-08-28 邀请业务与提现通道解耦

本次仅代码和隔离测试，用户已授权三仓修改。工猫未就绪不影响邀请、绑定、奖励累计、记录查询和规则阅读；实名、电签、提现试算/申请、审核与打款继续执行既有门禁。原业务状态保持 waiting_review。

### 检查结果

| 检查 | 实际结果 |
|---|---|
| Java 改前完整 `./gradlew test --console=plain` | 1316 通过、3 跳过、0 失败 |
| Java 新增激活回归（改前） | 复现“工猫未就绪”阻断激活；随后改动门禁 |
| Java 邀请银行卡与基础合同定向 | 31 项通过，含真实测试 JWT/API、无外部网关请求、重复激活/绑定/支付及 App 隔离 |
| Java 最终完整 `./gradlew test --console=plain` | 1322 总数 = 1319 通过 + 3 项既有跳过，0 失败/错误 |
| catseller `dart format` / `flutter analyze --no-pub` | 格式化完成 / No issues found |
| catseller 规则地址、银行卡流程、类型合同、App 标识专项 | 50 项通过；工猫关闭时素材/二维码数据/记录可用，提现按钮禁用且不发起申请 |
| catseller 完整 `flutter test --no-pub --reporter expanded` | 286 通过、5 项既有失败，不计全量通过 |
| Admin `flutter test --no-pub` / analyze | 167 项通过 / No issues found |
| Admin `flutter build web --no-pub` | 成功；构建后 index.html、rules.js 与源文件一致 |
| Web `node --test test/invite_rules_web_test.mjs` | 12 项通过，执行真实规则脚本，覆盖未启用/通道不可用/正常/旧响应、错误/超时/重试及字段校验 |
| 三仓 `git diff --check` | 通过；19 个既有未提交文件原内容经 SHA256 核对保持，README 只追加本次说明 |

App 既有失败为 `test/widget_test.dart` 的客服地址旧断言，以及 `test/work_detail_visual_golden_test.dart` 的 landscape、portrait、title sheet、script editing 四份 Golden 文件缺失。与既有工作区记录一致，本次未修改上述文件或更新 Golden。

后端公开规则追加 `withdrawalEnabled`；`enabled` 保持直邀模式语义。公开状态仅表示本地配置，不是用户资格或真实商户/银行验收。未配置仍为 LEGACY、显式停用仍为 DISABLED，不自动启用或修改业务数据。

### 本地浏览器检查

使用现有 `test/support/invite_rules_preview.mjs` 的虚构响应，读取真实 HTML/JS/CSS。请求视口 390×844、768×1024，当前浏览器缩放下实际 CSS 宽度分别约 354、698；两种宽度无横向溢出，窄屏实际滚动到规则底部。工猫不可用只出现提示、五节规则均可达；未启用时明确标记“尚未生效”，不显示默认参数为有效值；正常状态显示另一个虚构 App 的 14 天/10 元，未串用 catseller 参数。浏览器 console 未发现警告/错误；本次没有把本地模拟当作手机或服务器验证。

- [工猫不可用，规则正文仍显示](evidence/invite-decouple-20260828/rules-offline-390.png)
- [窄屏滚动至提现及其他说明](evidence/invite-decouple-20260828/rules-offline-lower.png)
- [未启用模式的只读规则说明](evidence/invite-decouple-20260828/rules-inactive-390.png)
- [正常通道与另一 App 的参数](evidence/invite-decouple-20260828/rules-ready-768.png)

### 数据库与发布边界

数据库改动：无。没有修改迁移、业务数据、后台下载地址配置、工猫私有参数或资金开关，也没有执行真实激活、部署或外部工猫请求。新增业务数据和授权仅存在于隔离内存 H2 测试中。

发布需同步 Java、Web 静态规则目录及 catseller。活动规则固定路径 `/legal/invite-rules/index.html?appCode=catseller&embedded=1` 跟随 API origin；本地/测试 HTTP 可用，但该 origin 必须同时提供规则资源及 `/api/config/invite-rules`，没有静态资源不会回退到正式站。部署后核对手机实际 URL 与响应，再验收工猫关闭时邀请/奖励/查询可用、提现被拒绝，通道恢复后的个人资格与审批仍生效。真实 H5、电签、银行到账和回退行为仍由原验收流程确认。


## 2026-08-28 规则展示读取后台真实参数

### 根因与范围

用户明确要求保留接口，只读取后台红框的八项规则参数，其他开关不参与展示判断。原接口的 enabled 仅表示新版直邀模式，LEGACY 返回 false 并不表示邀请功能关闭；旧 Web 把它误判为整页不可读。此外旧公开接口没有读取原有 invite.rules，缺少注册积分、比例和等级门槛。

公开接口路径不变，保留现有字段并追加 registerRewardPoints、directCommissionRates（level1/2/3）、agentLevelThresholds（level2/3）、indirectCommissionRate；minWithdrawCents 与后台取同一来源。InvitePublicRulesService 复用 InviteService.adminRules / InviteConfigVersionService.response，不另写一份规则解析，不暴露后台权限、下载配置、任意私有字段。原有及新版邀请业务、提现安全校验不变。

Web 从 HTML 起就显示规则正文，JS 异步补数据；不读取 enabled、withdrawalEnabled、模式、版本或协议字段控制显示。网络失败只在文末提示与重试，单个字段异常保留该项通用说明，其余有效数据仍展示。缺 App 标识不猜配置来源，也不隐藏正文。App/脚本入口版本为 20260828-display，其他协议及 WebView 登录数据不变。

### 实际验证

| 验证 | 结果 |
|---|---|
| Java 修改前定向 | 13 项中 3 项因新公开字段不存在失败；其余 10 项通过 |
| Java 修改后邀请基础/银行卡 | 32 项通过，含公开与后台八项参数一致、动态更新、App 隔离、新模式正确来源及不可提现保护 |
| Java 全量 `./gradlew test --console=plain` | 1323 总数：1320 通过、3 项既有跳过、0 失败/错误 |
| Web `node --test test/invite_rules_web_test.mjs` | 12 项通过，HTML 无 JS、待请求/失败/超时/重试、开关任意值、部分坏字段和旧响应均不隐藏正文 |
| catseller 邀请专项 | 50 项通过 |
| catseller 完整 Flutter 测试 | 286 通过 / 5 项既有失败，不计全量通过；客服 URL 旧断言、四份详情 Golden 缺失 |
| App/Admin analyze | 均无问题 |
| Admin 完整 Flutter 测试 | 167 项通过 |
| Admin Web build | 成功；构建中的 HTML/JS 与源文件一致 |

浏览器使用本地只读预览及虚构响应，不连接后台管理会话或工猫。请求 390×844 视口，当前浏览器缩放实际 CSS 宽 354，无横向溢出且可滚动至底部；原有模式 enabled=false / withdrawalEnabled=false 仍显示 0 积分、10/20/30%、10/30 人、间接 10%、最低 1 元。503 场景完整正文仍显示，提示和重试位于文末。

- [八项配置展示](evidence/invite-display-20260828/rules-legacy.png)
- [正文底部与最低金额](evidence/invite-display-20260828/rules-legacy-lower.png)
- [接口不可用仍显示正文](evidence/invite-display-20260828/rules-api-unavailable.png)
- [接口失败的文末重试](evidence/invite-display-20260828/rules-api-unavailable-lower.png)

浏览器工具拒绝 file:// URL 导航，本轮未绕过该限制，不声称文件直开浏览器实测；初始 HTML 无 JS 可见由自动化测试验证。

### 环境核对与发布

本轮只读 GET 核对发现测试服 HTML/JS 已包含上一轮改动（脚本不含“当前应用尚未开放此邀请提现活动”），公开接口正常返回 enabled=false / withdrawalEnabled=false，但尚无新增八项字段；正式站仍有旧脚本且公开接口 404。因此截图中的旧提示不能用修改开关解决，可能来自旧缓存/旧页面，未取得手机实际 WebView URL 前不指定唯一缓存来源。

本次新增代码未部署。发布顺序：Java 新字段 → Web 规则目录 → App 版本化入口/重新进入页面。旧 App 或旧 HTML 缓存可能继续执行旧脚本，应核对页面 v=20260828-display 及响应中的八项配置。无需为阅读规则启用新版活动。真实手机访问、服务器发布、银行资金闭环仍待验收。

数据库改动：无。数据/配置改动：无。仅隔离 H2 测试写入虚构规则，未操作共享数据库、工猫配置或业务开关，原 waiting_review 状态不变。
