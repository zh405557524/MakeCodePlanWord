# v2.1.1 线上问题修复

> 规则：工作台 `workflow/08-线上问题.md`。一个问题一节。
> **给执行者：只改每节"修复方案"里列出的文件。修复方案还没写的问题不要动手，遇到计划外情况停下来报告。**
> 2026-10-07 迁移时创建，内容来自 App 仓库 `doc/android-release-qa.md`（AND-001～005）、service 仓库 `docs/store-order-amount.md` 和 App 仓库当前未提交的改动。

| 项 | 值 |
|---|---|
| 状态 | 开发中 |
| 创建日期 | 2026-10-07 |
| 基于版本 | v2.1.0（App 提交 `4baae4c`；Android 出包另含 `238a7c7`、`1acd98f`） |
| 修复方案确认 | （F-02～F-05 待写方案后确认） |
| 构建号 | Android： / iOS： |
| 发布日期 | |

| 仓库 | 绝对路径 |
|---|---|
| App | `/Users/soul/code/soul/Solfeggio` |
| 后端 | `/Users/soul/code/soul/service` |

背景：v2.1.0 已在 Google Play 上线，F-02～F-05 是发布前测试就发现、但没在 Google Play 包里修复的问题，现在是线上问题。iOS v2.1.0 审核被拒；如果被拒需要改代码，在本文件新增一节（见 `v2.1.0/release.md` 第 5 节），iOS 可以直接用 v2.1.1 提交。

## 已读规范

（每个问题写修复方案前补充：App 仓库 `AGENTS.md` → `.cursor/rules/`；后端仓库 `AGENTS.md` → `.cursor/rules/00-编码工作流程.mdc`）

| 仓库 | 规范文件 | 关键条款 |
|---|---|---|

---

## F-01 订单金额和币种与商店扣款不一致（后端，已修复上线）

### 现象
- Google Play 月卡付款页显示 US$2.99，成功后 App 订单页显示 CNY 18.00（原 AND-004）。
- 影响：所有 Apple / Google 订单的展示金额都是内部人民币定价，与用户实际付款的币种和金额不一致。用户主要在美国、欧盟、南美。
- 从 v2.1.0 上线起存在（订单记录功能随 v2.1.0 上线）。

### 原因
订单只保存内部商品快照 `amount_cents/currency`（例如 1800 / CNY），确认成功后没有保存商店交易价格；订单接口直接返回内部快照。

### 修复（已完成）
- service 提交 `1664bf0`、`f436b0e`：新增公共迁移 `common/V5.0__verified_store_order_amount.sql`（`payment_orders.store_amount_cents / store_currency / store_transaction_id`）；Apple 用 App Store Server API 验签交易价格，Google 用 `orders.get` 的 `Order.total`；订单接口的 `amountCents/currency` 改为返回商店金额。App 不需要改动。
- 状态：**已上线（仅后端）**（2026-10-06 部署 `5.0.0-f436b0e`，三个业务 schema 迁移成功；Pixel 真机新订单显示 USD 2.99，数据库与 Google 订单一致）。
- 后端 tag：`solfeggio-backend-5.0.0`（待打）。
- 详细说明：service 仓库 `docs/store-order-amount.md`。

### 数据修复
部署前的旧订单商店金额为空，仍显示内部 CNY 快照；没有批量回填。⚠️ 是否需要对旧订单做一次性核对或回填，待决定。

### 验证
- 自动化：service 26 个测试套件 203 项通过（命令见 `docs/store-order-amount.md`）。
- 数据链路：Google 月卡已验证（商店 → 数据库 → 接口 → App 订单页 → 后台）。
- 还没验：Apple 真机购买、Google 季卡 / 年卡、显式重复确认、旧订单补齐、退款生命周期 → 用 `doc/testing/regression.md` 的 PAY-009 补测。

### 防再发
- 为什么测试阶段没发现：旧用例 PAY-001 只检查会员页显示的价格和币种，没有检查下单后订单里记录的金额；测试规则也不让写"接口 / 数据库应该是什么"；测试账号只有一个地区。
- 已补进 `regression.md`：PAY-001、PAY-003、PAY-006、PAY-008 增加「预期（数据）」，新增 PAY-009（非美元地区购买）、PAY-010（金额缺失或异常不代填）。
- 已补进 `risk-checklist.md`：支付领域"订单币种、金额与商店实际扣款一致，多地区账号验证"。

---

## F-02 取消 Google Play 购买后长时间卡在"支付处理中"（P1，原 AND-001）

### 现象
在 Google Play 付款页取消后，App 一直显示"支付处理中 / 检查未完成交易"，购买入口不可用，约 100 秒后才恢复。

### 复现
- 环境：Google Pixel（Android 10）、`2.1.0+210` Release、许可证测试账号
- 步骤：进入月卡付款页 → 系统返回 → 选择"不用了"

### 原因（初步）
`lib/store/payment.dart:994` 附近按 `purchase.productID` 寻找待处理订单；`in_app_purchase_android 0.5.0` 在取消且没有购买列表时发出 `productID: ''` 的取消事件，找不到订单，前台购买 Future 不结束。

### 修复方案
待写（按 `workflow/04-开发计划.md` 任务格式）。要求：保证当前账号、环境和前台订单归属的前提下，空商品取消事件也能立即结束当前购买；补空商品取消回调的回归测试。
- 状态：待开始

---

## F-03 歌曲结果页的分析使用固定数字（P2，原 AND-002）

### 现象
只答错一次，顶部错误数为 1，但错误小节显示"错音数 4"，复习建议固定推荐第 4、8、16 小节。

### 原因
`lib/pages/song/practice/result/view.dart:564`、`:589` 用 `index == 0 ? 4 : 3 - index` 生成错音数；`:662` 使用固定的 `songResultFocusMeasures` 文案。

### 修复方案
待写。要求：按真实作答明细生成；数据不足时隐藏对应分析（与 `doc/product/00-总纲.md` 8.6"不编造评价"一致）。
- 状态：待开始

---

## F-04 新增导入完成后，个人曲谱列表不刷新（P2，原 AND-003）

### 现象
从空列表新增 MIDI，完成校对和确认后返回列表，仍显示"还没有导入曲谱"，切换筛选后才出现。

### 原因
`lib/pages/score_import/personal_scores/view.dart:27` 直接打开来源页路由，没有等返回后刷新；`openScore` 有返回刷新，新增导入路径没有。

### 修复方案
待写。要求：覆盖空列表新增、处理中任务回流、确认完成回流三种情况。
- 状态：待开始

---

## F-05 商店网络错误被提示为"商店未配置"（P2，原 AND-005）

### 现象
手机访问 Google 商店的网络有问题时（BillingClient 返回 12 NETWORK_ERROR 或 6），会员页购买按钮显示"商店未配置"。

### 原因
`lib/pages/payment/controller.dart` 在商店商品为空时统一显示 `paymentStoreProductMissing`，没有区分查询失败和商品确实不存在。

### 修复方案
待写。要求：区分商品查询错误和商品缺失，网络错误给出重试。
- 状态：待开始

---

## F-06 MIDI 设备页蓝牙权限流程调整（进行中）

### 现象 / 目标
进入 MIDI 设备页时不再主动申请蓝牙权限；用户点击"扫描蓝牙设备"时才申请；拒绝蓝牙权限后 USB MIDI 仍可连接并收到音符。

### 当前状态
App 仓库有未提交的改动（`lib/pages/settings/midi_device/`、`lib/services/midi/midi_service.dart`、`lib/utils/permission_helper.dart`、`lib/utils/access.dart`、`lib/store/config.dart`、三语 arb 及新测试 `test/midi_permission_flow_test.dart`）。⚠️ 这项改动是否属于 v2.1.1，以及修复方案和验证结果，待补。
- 状态：进行中

---


## F-07 iOS 游客入口替换为真正的 Apple 登录（代码完成，配置待验收）

后续结构实现见 F-08：用户授权全量重建后，Apple 表与绑定约束已并入 `solfeggio/V5.3__solfeggio_schema.sql`，原 Java V5_1 migration 已删除。以下保留 F-07 初次实现和验证事实；当前 SQL、PostgreSQL 验证及部署状态以 F-08 为准。

### 现象 / 原因
App Review 4.8：已有 Google 登录，原“游客登录”使用设备随机凭证连接自有服务器，没有 Apple 原生授权和身份验签，不能作为 Apple 登录。

### 执行授权
2026-10-07 用户在本次对话明确要求“帮我把游客登录 改成苹果登录”。按该明确执行授权实施本节；不包含服务器部署、Apple Developer 配置发布或商店重新提交。工作中仓库新增文档流程，本节补录此次已授权的修复范围，不改线上产品/技术基线。

2026-10-07 版本修正授权：用户明确要求迁移保持 5.x。本次采用未占用的 V5.1，后端 5.1.0；同步修正规则中强制升主版本的条款，只更名未发布迁移，不改结构内容或冻结迁移。按文档目录过渡说明将本节和证据同步到工作区；同步完成后移除代码仓库中的版本副本。

### 已读规范
App：AGENTS.md、00-workflow、01-conventions、02-project-map、task-new_feature、10-ui、11-getx、13-i18n、21-reuse、20-plan-mode、doc/README.md、testing/risk-checklist.md。后端：AGENTS.md、00-编码工作流程、01/02/03、04/05/06/07/08/09/11 对应规则；冻结迁移基线最高 V5.0。

### 修复方案
1. iOS 原游客按钮替换为同等大小的黑色 Apple 按钮，提供简中、繁中、英文。Google/用户名登录继续可用，Android 游客流程保留。
2. 服务端发放十分钟 nonce，客户端原生 Apple 授权将 identityToken、authorizationCode、challengeId 交给后端。校验 RS256、issuer、audience、有效期、nonce 和本地分区；nonce 只允许同一幂等操作重放。
3. Apple subject hash 是唯一身份，不按邮箱合并。新身份绑定当前本地分区；已有身份切换到其原账号。当前已登录游客升级原 userId，订单/会员/练习不搬迁，撤销旧游客凭证；Apple 已属于另一账号则提示身份占用。
4. 兑换授权码并 AES-256-GCM 加密保存 Apple refresh token；应用会话刷新核验 Apple 授权，到期注销任务先撤销授权再删除凭证，失败沿用既有重试。
5. 配置 Runner entitlement、登录 P8/Team/Key/AES 密钥安全占位，记录 Apple Developer 能力、私有配置与真机验证要求。

允许修改/新增文件（相对各仓库）：
- App：pubspec.yaml（lockfile 若已追踪）、ios/Podfile.lock、ios/Runner/Runner.entitlements、ios/Runner.xcodeproj/project.pbxproj；lib/global.dart、lib/services/core/index.dart、apple_sign_in_service.dart；lib/apis/auth_api.dart；lib/pages/login/index.dart、controller.dart、view.dart；lib/l10n/app_{en,zh,zh_TW}.arb 及生成的 lib/generated/l10n*.dart；.cursor/rules/02-project-map.mdc。
- App 测试：test/apple_login_controller_test.dart、apple_sign_in_service_test.dart、login_recheck_layout_test.dart；google_login_controller_test.dart、guest_login_payment_gate_test.dart、payment_login_navigation_test.dart 仅补接口签名兼容；本节 fix.md 和对应版本 evidence/；按过渡说明同步工作区同名文档及 evidence/，更新两处 README 和移除代码仓库版本副本。
- service：build.gradle、src/main/resources/application.yml；core/auth/config/AppleAuthProperties.java、infra/AppleSignInProvider.java、service/AppleAuthProvider.java、AppleTokenPayload.java、ExternalSessionVerifier.java、TokenService.java、AccountIdentityService.java；core/user/service/UserService.java；app/solfeggio/auth/{controller/SolfeggioAccountAuthController.java,dto/AccountAuthRequests.java,entity/AppleAuthChallengeEntity.java,AppleCredentialEntity.java,repository/AppleAuthChallengeRepository.java,AppleCredentialRepository.java,service/SolfeggioAccountAuthService.java,SolfeggioAppleAuthService.java,SolfeggioAppleSessionVerifier.java}；app/solfeggio/accountdeletion/service/SolfeggioAccountDeletionFinalizer.java；src/main/java/db/migration/solfeggio/V5_1__solfeggio_apple_login.java；README.md、.cursor/rules/02-项目结构目录.mdc、.cursor/rules/05-数据库与持久化.mdc；测试 SolfeggioAppleAuthIntegrationTests、core/auth/infra/AppleSignInProviderTest，账号/注销/schema 相关回归。

数据库改动：后端升级 5.1.0，以 V5.1 追加 Solfeggio 专用迁移。扩展绑定表 CHECK，新增 solfeggio_apple_auth_challenges 和 solfeggio_apple_credentials。Java Flyway 入口按实际名称替换历史匿名 CHECK，兼容 PostgreSQL/H2；只有 solfeggio schema 执行，不改历史迁移，不批量改存量数据，不改变订单、用户主键、会员、积分和支付事件。用户主动登录/升级时才写身份与会话。未执行生产迁移。
数据/配置改动：源码默认关闭 Apple 登录；本机 IDE 私有配置已启用。用户提供的登录专用 P8 已接入被 Git 忽略的 `service/config/private/apple/sign-in/AuthKey.p8`，源文件和副本权限均为 600，与 IAP 配置分开。本机及正式部署准备配置分别使用独立随机 32 字节 AES 密钥，保留版本号以支持轮换。正式运行 env 和 P8 上传清单已在本地准备，未上传或部署；Apple Developer 的 App ID 能力及更新后的签名描述文件仍须在签名真机验收时确认。

### 验证用例及预期（数据）
- 首次/再次 Apple 登录、隐藏邮箱、第二次无姓名邮箱：一个 subject 对应一个 user_login_identities，email 不明文存入 users，第一次姓名保留。
- 游客升级：userId、支付订单及 entitlements 行完全不变，本地 owner 分区保留，旧游客凭证和令牌失效。
- 身份已占用：不合并账号，不迁移会员，不改变游客 account_type。
- 错签名/issuer/audience/nonce/过期/本地分区错配/换幂等键：不创建身份或账号；失败事务回滚挑战消费。相同操作重放不重复兑换授权码。
- 取消授权、隐私未同意、网络错误、退出页面或账号切换后的迟到响应：不认证、不调用后续账号业务或覆盖当前分区；重复点击只发一条链路。
- Apple 授权失效：应用 refresh 不再续发会话；加密凭证篡改或移到其他 userId 解密失败。
- 到期注销：先撤销 Apple 授权；外部失败保留加密凭证用于重试，成功后删除，不泄露 token。
- UI：三语、小/大手机与 iPad、大字号、加载禁用；Google/用户名/Android 游客继续可用。
- 回归：Flutter analyze/test，Google/游客/支付导航、后端原账号/注销/schema 隔离，iOS 模拟器原生构建。受控 Provider/模拟器不代表真实 Apple 登录、签名或商店审核通过。

### 结果
代码已完成。Flutter 全量测试 **1613 项通过、1 项既有跳过**；后端相关 **46 项通过**；登录页三语/五种尺寸/大字号/Android 与 iOS 回归 **148 项通过**，已查看手机和 iPad 截图。Apple SDK 原生通道用受控响应覆盖，登录控制器用真实本地分区 Store 验证升级及迟到响应；后端用真实 H2/Flyway 和受控 Apple Provider，不代表 Apple 真机授权。

全量 `flutter analyze` 仍有 **19 项既有提示**（practice 未使用方法、output 下旧 QA 文件、sync 测试括号），本次 Apple 修改范围分析 **0 问题**；不为此任务改动这些原有文件。修复过程中初始用例失败日志保留在 build/，调整受控 HTTP 匹配器/注销夹具时间/Toast 出帧等待，没有删除或放松业务断言。

iOS 模拟器 Debug 构建通过，新增 Apple 原生插件进入 Pods/registrant；已配置全部 Runner 构建项的 entitlement。尚未进行签名真机、Release 归档或实际 Apple 授权。登录专用 P8、Key ID、Team ID 和 AES 私有配置已在本机补齐，实际 P8 签名验证通过；源码安全默认开关仍为关闭，正式环境尚未部署。**F-07 尚不满足发布条件**。本机无可用 PostgreSQL 服务，本次迁移验证为 H2；发布前仍须在隔离 PostgreSQL 验证迁移。完整命令、边界与截图见 [Apple 登录证据](evidence/apple-login/README.md)。

V5.1 版本修正回归：SchemaRoutingIntegrationTests、SolfeggioAppleAuthIntegrationTests、SolfeggioAccountAuthIntegrationTests、SolfeggioPublishedMigrationChecksumTest 共 **21 项通过**。编译产物只有 V5_1，无 V6_0；Java 迁移 SQL 和执行逻辑与更名前完全相同，已发布 SQL 未改。Flutter/SDK/UI 上轮证据继续有效，本次不改 App 代码。

2026-10-07 私有配置接入：用户提供下载后的 Sign in with Apple P8，授权补齐本机配置与本地正式部署准备配置。Spring 实际绑定两套配置后，调用当前 Apple Provider 生成 client_secret；实际 P8 的 ES256 签名、issuer/audience/subject/Key ID、五分钟有效期与 AES-256-GCM 检查通过。正式配置仅在本机验证时替换为可读 P8 路径，不代表服务器已存在该文件。Apple Provider 9 项及 Apple 账号集成 11 项共 **20 项通过**；私钥上传清单的格式、600 权限与 Git 忽略检查通过。没有连接数据库、向 Apple 发起 OAuth 请求、上传文件、部署或执行真实用户授权。

数据库改动：本次 P8 配置接入无改动；V5.1 仍未在生产执行。原有 Google、IAP 及其他运行配置经结构比较保持不变，修改前的私有备份保留在后端忽略目录。

### Apple Developer 配置与发布验收
P8 是服务端用于生成 Apple `client_secret` 的私钥文件。用户仍通过系统 Apple 账号/Face ID 登录，不需要知道或提供 P8；此文件也不属于 App 的资源包。官方步骤见 [创建 Sign in with Apple 私钥](https://developer.apple.com/help/account/capabilities/create-a-sign-in-with-apple-private-key)。

1. 发布验收：Apple Developer → Certificates, Identifiers & Profiles → Identifiers → `com.soul.solfeggio`：启用 **Sign in with Apple**，按独立原生应用设为 Primary App ID。
2. 登录专用 P8 已由用户创建并下载；后续重建步骤为 Keys → 新建 Key → 勾选 **Sign in with Apple** → Configure 关联该 Primary App ID → 注册并下载 `AuthKey_<KeyID>.p8`。记录 Key ID 和 Team ID；私钥只可下载一次，妥善保存。本任务只做原生 iOS 登录，不需要网页 Services ID/回调地址。
3. 本机 IDE 与正式部署准备配置已补齐；部署时将文件放到后端部署环境可读的私有路径，仅在被 Git 忽略的配置中设置下列内容；登录密钥与 IAP 配置分开。AES 值是另行生成的随机 32 字节 Base64，例如在安全终端执行 `openssl rand -base64 32`；不要把输出粘贴到聊天或源码。

```yaml
app:
  solfeggio:
    apple-auth:
      enabled: true
      client-id: com.soul.solfeggio
      team-id: "<Apple Developer Team ID>"
      key-id: "<Sign in with Apple Key ID>"
      private-key-path: "/absolute/private/path/AuthKey_<KeyID>.p8"
      key-version: v1
      encryption-keys:
        v1: "<独立随机32字节的Base64>"
```

原生 Xcode Runner 已包含 Sign in with Apple entitlement，但 Apple Developer 的能力及新描述文件仍需更新。配置后须单独授权部署并重新构建签名包；按首次登录/再次无姓名邮箱/隐藏邮箱/已有游客升级/取消授权/Apple 设置停止使用后刷新/到期注销顺序真机验收。未经以上步骤不能把此次本地测试作为 4.8 审核通过证据。

### 防再发 / 发布时基线合并
把“游客不是平台授权登录”及“Google + Apple 同等隐私入口”的账户用例合入 regression.md；增加 nonce/授权撤销/隐藏邮箱维度。发布时同步 product/02 和 tech/api、data-model；当前不提前改线上基线。


## F-08 全量 SQL 基线与正式数据重建（本机完成，正式未执行）

### 执行授权与范围
2026-10-07 用户明确授权“sql 全部重新写”“备份数据 → 清空数据库 → 重建表 → 拷贝备份数据，用于更新正式服务器”，并确认当前没有正式用户。按此范围整理后端全部迁移；数据库结构及恢复用 SQL/迁移脚本，登录验签和接口业务仍由 Java Service 处理。

### 方案与允许修改文件
- 当前 `src/main/resources/db/migration/{common,android_interview,zhixingli,solfeggio}/` 的历史增量整理为最终结构：common/V5.0__common_schema.sql，加 V5.1 面试、V5.2 知行力、V5.3 钢琴视奏专属 SQL，活动版本全局唯一并按顺序递增。删除原活动历史 SQL 与 Java V5_1 migration；历史事实保留在 Git 和重建前完整备份中。表、字段、索引、约束、注释及 App 隔离保持原行为，Solfeggio 绑定允许 APPLE。
- 后端 `.cursor/rules/05-数据库与持久化.mdc`、02-项目结构目录、README、docs/{production-flyway-baseline,sql-baseline-rebuild,store-order-amount}.md 同步新基线与发布方式；build 保持 5.1.0。
- 迁移工具范围：`.local/lib/{db-migrate-core.sh,prod-data-migrate-deploy.sh,deploy-core.sh}`、`.local/prod/bin/db-migrate.sh`、对应 `.local/prod/tests/` 和 `.local/local/tests/`。完整发布同步正式 env/P8，停服、完整备份、隔离库演练通过后重建三个业务 schema，再恢复数据并校验；失败恢复原库、原 Jar 和原 env，备份保留。不删除数据库内其他 schema。
- 测试范围：SchemaRoutingIntegrationTests、SolfeggioPublishedMigrationChecksumTest、SolfeggioPolicyMigrationTest、RemoteScoreWorkerIntegrationTest 与所需测试资源；全部后端回归、临时 PostgreSQL 完整迁移与失败恢复验收。原失败证据和业务断言保留。
- 用户要求精简正式指令入口：`.local/prod/README.md` 只展示日常发布、数据库重建、状态与日志；原低频命令和详细约束移至 `.local/prod/README-advanced.md`，同步后端结构索引。仅调整文档，脚本、配置及数据库不变。

数据库改动：重建 android_interview、zhixingli、solfeggio 的最终表结构，并恢复可兼容业务表数据。保留用户 ID、账号身份、订单/支付事件、会员/积分与练习数据；旧 Flyway 历史不恢复进新库。新增 Apple 表为空，原表如已存在则恢复凭证；私钥与加密密钥不入 SQL。非空旧表缺少映射时停止，不静默丢数据。

### 验证与恢复
- 实际 PostgreSQL 从旧结构和测试数据执行完整演练、重建、恢复；比较每表行数与内容摘要、重验外键、校准序列，并检查后续插入不冲突。
- 注入数据恢复、健康检查与配置切换失败，验证原库/原 Jar/原 env 恢复；恢复失败保持停服并保留备份。
- 后端全量测试与构建、迁移资源清单、App schema 隔离和源码/配置门禁。
- 正式更新前报告验证结果和实际发布范围；不把本地夹具通过写成正式已更新。

### 当前状态
SQL、正式迁移脚本和配置上传入口已准备完成。活动 SQL 统一按 V5.0 公共 → V5.1 面试 → V5.2 知行力 → V5.3 钢琴视奏编号；部署检查拒绝跨目录重复版本及 Java migration。后端构建版本保持 5.1.0。

最终版本相关回归 **37 项通过**；部署脚本、env/P8 候选上传与失败恢复测试 **14 项通过**；`bootJar` 构建通过，四份 SQL 与源码字节一致。14 份原 SQL 以原始字节保存在测试资源；实际 PostgreSQL 对比三个 App 的最终表结构、默认值、约束、索引和注释均一致。

PostgreSQL 18.6 从原始 V5.0 库执行备份、临时库演练、重建与数据恢复通过，验证旧数据完整内容、订单/账号/练习数据、已发放的序列高水位、后续插入与外键。真实数据库失败恢复覆盖原 Flyway 历史、原 Jar 及新 Apple 凭证；演练后行数不变但内容变化会在清理前拒绝执行。systemd/健康检查使用本地夹具，临时数据库仅监听独立本机端口，验证结束后服务已停止。

全量后端回归复测 **486 项：481 通过、4 跳过、1 失败**。既有 OMR `interruptionStopsRecognitionProcess()` 子进程退出测试在全量中重复失败，单独复测通过；此独立问题未扩入 SQL 修改，原日志和断言保留。正式 env/私密文件检查通过，源码门禁因本次改动未提交而失败，发布前仍须处理测试阻塞并满足干净 `main` 要求。

尚未连接正式服务器、清理正式数据库或切换正式配置。完整流程见后端 [重建说明](/Users/soul/code/soul/service/docs/sql-baseline-rebuild.md)，本机日志和验收边界见 [SQL 重建证据](evidence/sql-baseline-rebuild/README.md)。

正式部署 README 已精简为四条常用命令；原低频操作和约束保留在独立按需说明，路径和动作检查通过。常用命令和按需说明的远程命令示例已补充末尾 SSH 密码参数；核对现有入口传递与认证逻辑，传入密码后不再询问 SSH 密码，发布/重建确认保留。此次文档调整未改动部署脚本、配置或数据库。

## F-09 Audiveris 取消识别后未等待进程退出（后端，本机修复与回归完成，待提交发布）

### 现象与原因
2026-10-07 正式重建命令在本机构建阶段执行 486 项测试，`AudiverisScoreRecognitionServiceTest.interruptionStopsRecognitionProcess()` 失败，4 项跳过。该问题已在 F-08 的全量回归中出现，独立复测曾通过。

`AudiverisScoreRecognitionService.stopProcess()` 向启动脚本及派生进程调用 `destroyForcibly()` 后立即返回；线程执行结束不能证明操作系统已完成进程退出。取消路径还会先恢复线程中断标记，因此直接增加一次可中断的 `waitFor()` 也不能保证等待生效。当前失败发生在本机测试，不是数据库迁移失败。

### 已读规范
后端 AGENTS.md；.cursor/rules/00-编码工作流程.mdc、02-项目结构目录.mdc、03-编码规范.mdc、12-Bug修复任务.mdc；工作台 workflow/00-总流程.md、08-线上问题.md。复用本任务已读的数据库与密钥规则，测试不使用生产配置或凭据。

### 修复方案与允许修改文件
- `service/src/main/java/com/soul/service/app/solfeggio/scoreimport/service/AudiverisScoreRecognitionService.java`：结束进程树后，在有界时间内等待启动进程实际退出；清理期间暂时消费线程中断状态，记录等待期间的新中断，完成清理后恢复中断标记。正常返回、失败、超时、取消及运行时探测复用这一清理入口。
- `service/src/test/java/com/soul/service/app/solfeggio/scoreimport/service/AudiverisScoreRecognitionServiceTest.java`：保留取消后进程必须退出的原断言，重复覆盖取消时序，并确认中断标记保留；不通过延迟断言、放松断言或跳过用例消除失败。
- 本节及 `versions/v2.1.1/evidence/audiveris-process-cleanup/`：保存原失败 XML、修复验证日志和结果，更新任务状态。

数据库改动：无。接口、数据模型、其他 App Code、部署脚本及正式服务器不在本次修改范围内。

### 验证与防再发
先验证取消、超时、运行时探测及解析相关测试；由于当前问题阻塞正式构建，再执行一次全量后端测试确认原失败消失。重复取消用例覆盖任务线程结束时进程已退出的时序；实际 Audiveris 图片/PDF 识别仍需独立验收。

### 当前状态
2026-10-07 用户要求解除正式更新阻塞，并确认由自己执行正式更新；按以上最小方案修复和验证，本任务不代为连接或更新正式服务器。

修复完成：清理入口发出终止信号后最多等待启动进程退出 3 秒，等待期间收到的中断也会保留；取消、超时和探测失败使用相同清理入口。原取消测试改为 20 次重复，保留即时检查进程已退出的断言，并新增中断标记保留断言。

修复前 20 次取消测试有 **19 次失败**，原失败 XML 和重复复现日志保留。修复后相关测试 **60 项：57 通过、3 跳过**；全量测试与 `bootJar` **505 项：501 通过、4 既有跳过、0 失败**，其中取消路径 20 次均通过。总用例数比原 486 增加 19，是同一取消用例增加重复次数。`git diff --check` 通过，未降低或删除业务断言。

后端当前为 `main`，只有本次两处 Java 修改未提交；正式发布源码门禁要求先提交并保持工作区干净。用户自行执行完整迁移入口，不使用跳过测试或绕过源码门禁的方式。正式数据库、运行 Jar 和配置未在本次修复中更新；实际 Audiveris 图片/PDF 识别仍未由本轮证明。完整证据见 [进程清理回归](evidence/audiveris-process-cleanup/README.md)。

## F-10 iOS 会员免注册购买与 IAP 恢复（已修复，真机验收待补）

### 现象、授权与目标
App Review 5.1.1(v)：首次购买会员被 App 登录门禁拦截。2026-10-07 用户确认“按照这样帮我进行修改吧”，并明确重装恢复使用 Apple IAP 购买凭证。按已确认方案执行：未注册用户可购买、使用及恢复匿名会员；Apple 登录用于可选同步与原游客 ID 升级，不作为购买条件。

### 已读规范
App AGENTS.md、00-workflow、01-conventions、02-project-map、task-maintenance、10-ui、11-getx、12-router、13-i18n、20-plan-mode；文档 README、testing/risk-checklist；工作台 workflow/00-总流程、08-线上问题。后端 AGENTS.md、00-编码工作流程、02-项目结构目录、03/05/08/10/14 对应规则。

### 修复方案与允许修改文件
- `Solfeggio/lib/pages/payment/controller.dart`：iOS 点击购买直接进入支付，匿名身份或网络失败不导航登录；Android 原登录门禁保留。
- `Solfeggio/lib/store/user.dart`：用户主动购买时允许建立 iOS 匿名会话，复用安全存储凭证；隐私未同意、已失效账号、切换中的账号不得生成替代身份，迟到的响应不得覆盖已切换账号或环境。
- `Solfeggio/lib/store/payment.dart`：在创建订单前取得匿名支付身份，传递已有身份服务；商品浏览与后台补单不自动创建身份，保留验真、订单归属及重复支付保护。
- `Solfeggio/lib/pages/payment/view.dart`、`lib/l10n/app_{en,zh,zh_TW}.arb` 及生成的 `lib/generated/`：在现有会员说明区域解释 iOS 免注册购买和恢复；保留布局和 Android 文案。
- `Solfeggio/test/ios_anonymous_membership_test.dart`、`guest_login_payment_gate_test.dart`、`payment_login_navigation_test.dart`、`payment_recovery_test.dart`、`apple_login_controller_test.dart`：覆盖首次匿名购买、恢复、取消、失败、隐私、重复点击与身份切换，保护 Android 门禁和 Apple 升级权益。
- `Solfeggio/.cursor/rules/02-project-map.mdc`、本节与 `versions/v2.1.1/evidence/anonymous-membership/`：同步入口职责、测试结果和验收边界。复用后端既有匿名身份、订单验真与恢复代码，验证 GuestAccountServiceTest、SolfeggioAccountAuthIntegrationTests、SolfeggioAppleAuthIntegrationTests；不修改后端业务代码。

### 数据库改动
无。不新增迁移，不重建或修改正式数据库；订单、权益仍由现有 API 在原匿名 userId 下创建和验证。Apple 升级保留 userId、订单和会员，不合并已有其他账号。

### 验证与预期（数据）
- 首次安装不登录 → 购买：一次匿名认证、一个业务订单、一次商店购买；只有验真的 PAID 订单开放会员，不要求用户名、邮箱或 Apple 登录。
- 重复点击、凭证或网络失败、购买取消、隐私未同意：不重复创建订单或发放会员；失败可重试，原有账号和本地记录保留。
- 原匿名账号购买后无本地 token/订单 → 恢复：上报 IAP 签名交易，服务端恢复原购买 userId，会员到期时间保持原值；不重新下单或延长权益。
- 用户选择 Apple 升级：保持原 userId、本地数据分区及已付会员；已有其他身份不自动合并。原账号已注册后的账号恢复沿用既有登录安全边界，不用交易凭证签发可读取私人资料的注册账号会话。
- Flutter 完整 analyze/test；后端相关账号、验真及权益测试。自动化不代表真实 App Store 购买或重装验收，签名真机/Sandbox 与新构建上传独立验收。

### 防再发与当前状态
补充“未登录首次购买、匿名 IAP 重装恢复、购买后可选账号升级”维度，发布时合入 testing/regression 和 risk-checklist。旧导航测试默认采用已登录/必须登录场景，没有覆盖 iOS 首次离线游客购买。

2026-10-07 已完成：iOS 购买入口取消强制登录，在创建业务订单前复用安全凭证取得匿名身份；网络失败不导航登录；账号或环境已切换时拒绝迟到匿名响应。商品浏览、后台补单不创建身份，Android 登录门禁保留。会员页简中、繁中、英文说明已同步，IAP 原匿名会员恢复入口无需本地 token 或订单。项目结构索引已同步，未修改后端业务代码或数据库。

### 验证结果与发布边界
- 修复前首次匿名购买回归失败（实际 failed，预期 success）；修复后完整 `flutter test --reporter expanded`：1626 通过、1 原有跳过。页面测试验证 iOS 成功/网络失败均不进入登录页，原 Android 登录返回不自动下单。
- 后端 GuestAccountServiceTest（8）、SolfeggioAccountAuthIntegrationTests（7）、SolfeggioAppleAuthIntegrationTests（11）共 26 通过；Apple 升级集成用例比较原 userId、订单行和会员权益行，升级前后保持一致。
- 完整 `flutter analyze` 已运行，退出 1：未修改的练习页、旧 UI 审计文件和同步测试仍有 19 条既有提示（17 warning、2 info）。本次相关 Dart 文件及生成文案分析 0 问题；未扩大计划处理历史提示。格式检查与 `git diff --check` 通过。
- 自动化使用商店/Apple Provider 替身及后端测试数据库，不能作为真实扣款、Sandbox、卸载重装或正式发布证明。尚未出新签名包、上传商店或部署正式服务器；签名真机需验收免注册购买、同 App Store 账号恢复原匿名会员及购买后可选 Apple 升级。

完整命令、预期（数据）、输出日志和验收边界见 [免注册会员证据](evidence/anonymous-membership/README.md)。

## 测试结论
- 能否发布：
- 阻塞项及用户决定：
- 发布前仍需补的真机验收：实体 USB / 蓝牙 MIDI 琴（连接、按键、踏板、断开重连）、实际听感、图片 / PDF 识别全流程、和弦和视奏完整结算、新用户首次安装与权限流程、其他 Android 版本

## 发布收尾
- [ ] 用例合并进 `regression.md`，维度合并进 `risk-checklist.md`（F-01 已完成）
- [ ] 产品行为或接口有变化的，同步 `doc/product/`、`doc/tech/`
- [ ] `doc/README.md` 线上版本和版本历史
- [ ] tag `v2.1.1`；后端 tag
