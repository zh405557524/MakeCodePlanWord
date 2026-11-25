# 喵喵带货 工作空间流程状态

## 2026-09-27 iOS 内购构建开关回归修复

- 状态：`done`（本地代码、自动化与无签名 Release 构建）。2026-09-16 曾移除内购构建开关，但本轮检查当前仓库发现 `PaymentConfig.appleIapEnabled` 再次默认为 `false`，`make_ios.sh` 和 `pgyer_upload.sh` 也再次传入旧开关；以下以本轮当前代码为准。
- 再次删除 Dart 编译开关、支付网关禁用分支及两条打包脚本中的 `APPLE_IAP_ENABLED` 传参，同时清理示例配置、README、关闭态测试和误导性的“内购暂未开通”文案。iOS 直接查询 StoreKit、监听交易并允许会员及积分商品购买；Android 平台限制、服务端订单验真与补单逻辑保留。
- 验证：身份配置 4 项、iOS 相关 21 项、支付 28 项、充值 8 项通过；显式传入旧参数 `--dart-define=APPLE_IAP_ENABLED=false` 的 App Store 相关 2 项也通过。`flutter analyze --no-pub`、Shell 语法、蒲公英示例 JSON 解析及 `git diff --check` 通过；不传内购参数的 `flutter build ios --release --no-codesign --no-pub` 成功生成 `Runner.app`。
- 仅完成本地代码与无签名构建，尚未签名、上传或安装新包，也未执行真实 StoreKit Sandbox 交易。App Store Connect 商品状态、付费协议、服务端验真及新 build 的真机付款仍需发布链路验收；旧二进制不会随源码修改而改变。邀请提现主流程状态不变。

## 2026-09-16 iOS 内购构建开关移除

- 状态：`done`（本地代码与无签名 Release 构建）。根因是 `PaymentConfig.appleIapEnabled` 使用 `bool.fromEnvironment` 且默认为 `false`；Xcode/Flutter 发布构建未显式传入 `APPLE_IAP_ENABLED=true` 时，审核包即使已包含 StoreKit 插件和 Xcode In-App Purchase Capability，客户端仍会在调起 StoreKit 前拦截为“iOS 内购暂未开通”。
- 已删除 Dart 编译开关、支付网关禁用分支、关闭态测试和“内购暂未开通”错误文案；iOS 现固定查询 StoreKit、订阅交易流并允许 App Store 支付，非 iOS 平台门禁保持不变。
- `make_ios.sh`、`pgyer_upload.sh`、`pgy_config.example.json` 和 README 已移除 `APPLE_IAP_ENABLED/appleIapEnabled`，因此 Xcode Archive、本地 IPA 和蒲公英 IPA 不再依赖人工打包参数。未修改后端、Admin、数据库、App Store Connect 商品或交易验签规则。
- 验证：身份配置 4 项、iOS 会员/积分购买与自动补单 13 项通过；额外显式传入旧参数 `--dart-define=APPLE_IAP_ENABLED=false` 时，iOS 会员购买回归仍通过，证明旧参数已无法关闭内购。`flutter analyze`、两个 Shell 语法检查、蒲公英示例 JSON 解析和 `git diff --check` 通过；不传任何内购参数的 `flutter build ios --release --no-codesign` 成功生成 `Runner.app`。
- 原已提交审核的二进制无法远程修复，必须用本次代码重新生成并上传新 build。StoreKit Sandbox 真机购买、App Store Connect 商品/付费协议状态及新 build 的审核仍需外部验收。

## 2026-09-03 灵活用工协议改为固定 HTML 页

- 状态：`waiting_review`。Admin/Web 新增 Catseller 专用页 `web/sites/catseller/legal/flexible-employment-agreement/index.html`；测试环境地址为 `https://test.lxwanxiang.com/sites/catseller/legal/flexible-employment-agreement/index.html`，正式地址为 `https://www.lxwanxiang.com/sites/catseller/legal/flexible-employment-agreement/index.html`。本轮只完成本地文件与 App 接入，未部署。
- 2026-09-03 只读探测两个目标地址均返回 `200 text/html`，但响应哈希同为 `e61b142e...`，内容是灵犀万象官网首页兜底，不是本地协议文件 `47ab3a23...`。因此发布前 App 不得以 HTTP 200 当作协议已可用，必须验证正文主体和哈希。
- 正文严格沿用用户提供的 2025-09 版《服务协议》模板，仅将三个模板占位值替换为“杭州工猫科技有限公司”、“深圳市灵犀万象科技有限公司”和“软件推广”；不在模板前追加主体信息卡片，不自行改写协议条款。
- App 新增 `flexible-employment-agreement` 固定页键，原 `/invite/agreements/flexible-employment` 路由保持不变，但直接返回 `StaticPageView`。P06 不再请求 `GET /api/invite/agreements/flexible-employment`，已删除 `RemoteAgreementPage`、短期签名 URL/PDF 下载代码以及 `pdfrx/PDFium` 依赖。后端旧接口不修改，只是当前 App 不再使用。
- 阅读仍为只读动作：不勾选、不提交资料、不创建/确认实名会话；最终核身电签仍由工猫 H5 完成。静态页不包含脚本、图片、外链或第三方资源，390px 移动视口下 `scrollWidth=clientWidth=390`。
- 验证：`flutter analyze` 通过，固定页/路由 7 项、邀请提现专项 51 项通过，Android Debug APK 与 iOS Simulator 无签名构建通过。全量为 337 项通过、7 项既有无关 Golden 失败（4 项作品详情基线缺失、3 项实名认证旧基线差异），未更新基线。

## 2026-09-03 静态协议页面环境根地址统一

- 状态：`waiting_review`。本地包原本把“提现规则”解析为 `http://192.168.31.243:8080/legal/invite-rules/...`；该地址可连接本地 Java，但静态页返回 `404 application/json`，而公开规则 API 正常，根因是本地 8080 未承载 Admin/Web 静态目录，不是局域网或明文 HTTP 权限问题。
- `lib/utils/constants.dart` 与 `lib/utils/privacy_consent.dart` 已正式迁移到 `lib/config/` 并由 `config/index.dart` 聚合；`utils/index.dart` 不再拥有或导出这两个类型，只在内部工具需要时导入 config。隐私同意文件迁移前后 SHA-256 一致，协议版本 2、存储键和接受/拒绝/撤回行为不变。
- 原有 `Global.currentServerAddressType` 和三组 server address 引用保持原结构，切换环境仍只修改 `Global.currentServerAddressType`。`legalPageUrls` 直接保存该构建环境的最终 URL：local/test 使用 `https://test.lxwanxiang.com`，production 使用 `https://www.lxwanxiang.com`；页面 path/query 保持不变，活动规则直接包含 `appCode=catseller&embedded=1&v=20260828-display`。已删除运行时二次换域名函数。
- `StaticPageController` 与阿里云一键登录原生授权页直接读取 `AppConstants.legalPageUrls`；`AliyunNumberAuthService` 恢复为不接收 `apiBaseUrl` 的构造方式。路由、页面 key、App 标识、登录门禁、规则动态接口、实名/签约和提现状态流均未修改。
- 测试/正式两站共 9 个当前静态页面路径只读检查均返回 `200 text/html`。协议/邀请定向 69 项和登录 Widget 2 项通过，`flutter analyze` 无问题；最新全量为 342 通过、7 个既有 Golden 失败（3 个实名认证旧基线差异、4 个作品详情基线缺失）。Android Debug APK 构建成功，保留 compileSdk 36/插件建议 37 的既有告警；新 APK 未自行安装，真实设备 WebView 仍待复验。

## 2026-09-03 用户协议与隐私政策灵活用工增量

- Admin/Web 已更新 Catseller 当前正式地址对应的中文《用户协议》和《隐私政策》，补充邀请收益、实名认证、身份证照片、人脸核验、动态财税服务商、银行卡绑定、税费试算与提现处理规则；英文协议及其他 App 协议不变。
- 工猫开放平台运营方明确为杭州工猫科技有限公司；实际财税服务商和灵活用工合同相对方仍以每次提交前展示的动态合同和签约页面为准，服务商变更须重新告知并依法取得单独同意。
- Catseller `PrivacyConsentService.currentConsentVersion` 从 1 升至 2，使已接受旧版总协议的用户按现有启动门禁重新查看并确认新版；P06 默认未勾选的专项确认继续独立存在，总协议同意不能代替实名认证敏感信息同意或灵活用工签约。
- 本轮不修改认证、签约、绑卡、资金、接口、数据库或配置，不部署。静态协议发布前仍须由法务、运营确认动态合同确实展示当次财税服务商名称和联系方式，并完成双平台更新提示验收。

## 2026-09-03 实名认证服务协议公共目录迁移

- Admin/Web 将所有 App 共用的协议正文移动到 `web/sites/common/legal/identity-verification-service-agreement/index.html`；App 专属协议仍放在 `web/sites/{appCode}/legal/`。移动前后 SHA-256 一致，不保留旧目录副本。
- Catseller 的 `identity-verification-service-agreement` 正式地址同步改为 `https://www.lxwanxiang.com/sites/common/legal/identity-verification-service-agreement/index.html`，页面 key、`StaticPageView` 路由和标题合同不变。
- 阅读协议仍是只读动作，不切换勾选、不创建实名认证会话、不调用签约确认。状态保持 `waiting_review`；本轮不部署，新地址需随 Admin/Web 和更新后的 App 一起发布后验收。

## 2026-09-03 工猫签名 PDF 远程加载兼容修复

- 状态：`waiting_review`。本节覆盖下方 `PdfDocumentRefUri` 直连方案。有效期内取得的工猫样本是可解析的 2 页 PDF，且已在 iOS Simulator 用 PDFium 实际渲染成功；原失败发生在 `pdfrx` 的 URI 下载/缓存阶段，但旧日志未保留可定位的异常类型，原签名地址现已过期，因此不把单一 HTTP 原因写成已证实结论。
- PDF 改为 Catseller 独立 `HttpClient` 完整下载到内存，30 秒总超时、20 MiB 上限、不携带 JWT、`X-App-Code` 或业务 Dio 请求头；最多跟随 3 次通过现有 HTTPS 安全校验的跳转。下载完成后校验前 1024 字节内存在 `%PDF-`，再交给 `PdfDocumentRefData + PdfViewer` 渲染，不写文件缓存。
- 签名 URL 原样保存在路由 `extra` 内存对象中，避免重新序列化；不依赖移动端时钟预判有效期，由 OSS 的 401/403 响应归类为地址失效。日志只输出 `expired / timeout / network / invalidFile / tooLarge / unsafeRedirect` 分类或渲染异常类型，不输出 URL、响应正文或原始异常。
- 失败继续提供“重试 / 使用系统浏览器打开 / 返回实名认证”；查看仍为只读，不勾选协议、不创建或确认实名认证会话。真实 Android/iOS 使用新鲜工猫签名地址的网络下载、弱网和外部兜底仍待真机验收。
- 验证：邀请专项 57 项、`flutter analyze`、Android Debug APK、iOS Simulator Debug 无签名构建通过；iOS Simulator 已用真实工猫样本完成 PDFium 渲染。全量测试 340 项通过、7 项既有无关 Golden 失败（4 项作品详情基线文件缺失、3 项实名认证旧基线差异），未更新无关 Golden。

## 2026-09-02 灵活用工协议 PDF 内置查看修复

- 状态：`waiting_review`。根因是工猫短期协议接口可返回带签名的 PDF 地址，而 Catseller 原页面识别 `.pdf` 后直接停用 WebView 并要求系统浏览器打开；现已新增 `pdfrx: ^2.4.7`，当前 Flutter/Dart 依赖解析为 `pdfrx 2.4.7`。
- PDF 默认通过 `PdfDocumentRefUri + PdfViewer` 在 App 内阅读，保留滚动、缩放和加载进度；请求超时 30 秒、附加请求头为空，不复用 Catseller JWT、`X-App-Code` 或业务 Dio。HTML 地址继续使用原 `WebViewWidget`。
- `PdfDocumentRefKey` 只显示固定脱敏名称，唯一部分使用短期 URL 的 SHA-256 摘要与重试次数；页面、业务日志和错误提示不输出签名 URL 或原始异常。失败时只提供“重试 / 使用系统浏览器打开 / 返回实名认证”，外部浏览器不再是 PDF 默认路径。
- 查看协议仍是只读动作，不勾选协议、不创建实名认证会话、不调用签约确认；后端接口、返回字段、一小时有效期、Admin、数据库、配置和认证状态流均未修改。
- 验证：`flutter analyze --no-pub`、邀请专项 56 项、Android Debug APK、iOS Simulator Debug 无签名构建通过。全量测试 339 项通过、7 项既有 Golden 失败（4 项作品详情基线文件缺失、3 项当前实名认证页面与旧基线差异），未更新无关 Golden。真实 Android/iOS 工猫 PDF 的首屏、滚动/翻页、双指缩放、返回、弱网和外部兜底仍待真机验收。

## 2026-09-02 邀请记录已开通状态展示修复

- 状态：`waiting_review`。后端 `GET /api/invite/records` 的当前列表合同在 `memberCommissionStatus` 返回 `OPENED/NOT_OPENED`，App 行内却只把旧结算态 `SETTLED` 判为已开通，导致记录能被服务端筛进“已开通” Tab，但行标签仍显示“未开通”。
- Catseller `InviteRecord` 集中提供会员已开通判断：当前 `OPENED` 和旧版 `SETTLED` 都显示“已开通”，`NOT_OPENED/PENDING` 不误判为已开通；View 的文案、背景色和文字色共用该判断。
- 测试夹具已改为真实响应值并保留旧值兼容回归；邀请专项 53 项、指定 Widget 筛选用例及 `flutter analyze --no-pub` 通过。后端、数据库、配置和运行中服务未修改；真实接口与真机仍待更新 App 后复验。

## 2026-09-02 佣金规则与团长推广重构

- 状态：`waiting_review`。本节纠正上一版把关系层级和佣金等级混为“代理等级/保底等级”的设计：关系只表示一级关系 A→B、二级关系 A→B→C；用户档案分别保存一级关系佣金等级与二级关系佣金等级，各为 1/2/3 档，不存在保底、固定或等级模式。
- 当前 App 的 `invite.rules` 保存六个全局百分比：`directCommissionRates.level1/2/3` 与 `indirectCommissionRates.level1/2/3`，均为 0～100 整数且各组三档非递减。完全缺失时两组都只读回退 10%/20%/30%；旧二级单比例配置兼容映射到二级三档，首次后台保存后才持久化六档。
- 一级佣金等级按有效直邀首单人数在 10/20 人门槛只自动升级、不自动降级；二级佣金等级绝不按人数升级，只由后台团长推广活动直接调整属性值。团长只是独立活动名册，身份本身不发佣金、也不打开二级关系佣金资格；停用活动身份时按人数恢复一级等级并将二级等级恢复为 1，二级资格开关保持原值。
- Admin 拆为非佣金规则、六档佣金比例、邀请与佣金查询、逐用户二级代理开关、团长推广、提现和审计页面。团长页调整两项佣金等级，二级代理页只调整该用户资格开关；所有读取、写入和审计继续按当前 `X-App-Code` 隔离。
- 新付款在既有并发锁内锁定关系层级、对应佣金等级、比例、金额和配置版本。规则、等级或开关修改只影响新付款；历史、待结算、退款及已结算记录继续使用付款快照，团长名册不进入付款分支。
- Catseller P01 只接收和显示当前生效的一级佣金比例、三档一级比例和真实人数进度，不显示团长、二级代理、二级佣金、人工、自动或保底来源；二级关系收益在明细中仅显示通用“推广奖励”，不展示后台二级档位比例。公开活动规则页同样只展示一级佣金规则。
- 数据库仅修改明确未发布的公共 `V4.5__invite_direct_bank_withdrawal.sql`：新增 `indirect_commission_level`、两类佣金快照字段、1～3/关系层级约束及软状态团长活动表。没有业务数据 `UPDATE`、回填、物理删除或字段删除；没有执行线上 SQL、Flyway repair、部署或历史订单重算。

## 2026-09-02 佣金明细卡种展示修复

- 状态：`waiting_review`。共享 `GET /api/invite/earnings/ledgers` 列表项增加可空 `productName`，只通过支付订单 Service 按当前 App 和本页订单号批量读取既有 `payment_orders.product_name` 快照；用户软删除订单仍可读取，缺失订单返回空，不跨 App、不按金额推断。
- Catseller P04 的 `DIRECT_REWARD` 改为“好友开通月卡/季卡/年卡”，空字段兜底“好友开通会员”；退款冲正、间接收益、期初余额、金额、状态、结算和提现逻辑均不变，其他 App 客户端未修改。
- 数据库改动：无。没有 Flyway、字段、回填、配置或写入逻辑；当前只完成本地代码、接口/Widget 回归和 375×812 Golden 对稿，未部署、未进行线上接口或真机验收。
- 验证：最终后端邀请集成 69 项、Catseller 邀请页 49 项及 `flutter analyze --no-pub` 通过。后端全量共 1093 项，其中 1085 通过、7 项无关 `SongWorkLifecycleIntegrationTests` 因 JVM OOM/上下文失败阈值失败、1 项跳过；该无关类随后单独 7 项全通过。最终差异检查与工作区审计结果见本地验证记录。

## 2026-09-02 实名认证双协议展示

- 状态：`waiting_review`。P06 的两份协议改为独立可点击入口：灵活用工协议每次由共享后端实时查询工猫唯一合同模板并返回一小时有效地址；实名认证服务协议由 Admin/Web 提供 Catseller 正式静态页。
- 阅读协议只打开只读页面，不切换勾选、不提交实名资料、不创建或确认认证会话。签署按钮与协议行按 Figma 增加 `8.w` 间距；复选框继续是唯一同意入口。
- 新接口 `GET /api/invite/agreements/flexible-employment` 要求 JWT 与 `X-App-Code`，响应 `Cache-Control: no-store`；模板失败、空/多模板或危险地址继续使用 `-7117 / HTTP 503`。短期地址不缓存、不落库、不写普通日志。
- Admin/Web 新增 `web/legal/catseller/identity-verification-service-agreement/index.html`，正式发布前必须经过法务/运营复核。本轮无数据库和配置改动，不部署、不调用真实工猫、不签约或提现。

## 2026-09-02 实名认证协议区按 Figma 修正

- 状态：`waiting_review`。以新通道 `x5x4ir6u` 的 P06 `66:120` 为真源，实名认证底部恢复 Figma 原文、全宽锁定提示、签署按钮和默认未勾选协议区。
- 页面复选框成为唯一确认入口；删除旧 D02 二次确认及自动勾选。未勾选或资料/照片/配置不完整时不创建认证会话；失败保留页面内勾选状态，退出不持久化。签署前可分别查看两份协议，工猫 H5 仍负责最终核身与电子签约。
- 邀请相关 86 项和 `flutter analyze --no-pub` 通过；标准、小屏键盘、错误态 Golden 已更新并目视复核。数据库、后端、P10、其他 App 和服务器均未修改，真实双平台/H5待用户复审。

## 2026-09-01 实名电签自动确认修复

- 状态：`waiting_review`。Catseller 页面加载发现历史会话时只调用新 `GET /api/invite/identity-sessions/{sessionId}/status`；App `resumed`、相机/相册返回、手动关闭 H5、空 H5 地址和缺失/非法 state 均不提交签约。
- 受控 H5 仅从与服务端回跳地址完全匹配的主框架 HTTPS URL 提取单个 43 位 URL-safe `state`。只有该值经 App `POST .../{sessionId}/confirm` 或平台已校验路由的 `H5_RETURN` Inbox 才能调用一次 `signContract`；合同通知、创建后复核和定时恢复只查合同状态。
- 后端资格仅返回 `PENDING + provider_flow_id非空` 的会话；`RETRY/CREATING` 不再触发自动确认，失败记录保留，同主体重提沿用既有 `SUPERSEDED` 规则。错误合同固定为 400/409/503，未签完成保持 HTTP 200 + `identityReady=false`。
- 数据库结构和现有数据不改；未清理截图中的 RETRY 会话，未部署、未重启、未调用真实工猫。当前专项、静态分析和差异检查结果见 [拆分验证最新增量](05-联调与测试/invite-identity-bank-split-verification.md#2026-09-01-实名电签自动确认修复)。
- 恢复点：前后端必须同步更新后再复验。进入实名页、切换前后台或关闭 H5 时 Network 中不得出现 confirm；完成合法工猫回跳时恰好一次带 state 的 confirm，随后只查状态。真实 Android/iOS WebView、工猫测试合同和运行服务仍待用户环境验收。

## 2026-09-01 每日提现次数配置

- 状态：`waiting_review`。Admin 按当前 App 编辑 1～100 的每日上限，保存在现有 `invite.rules.dailyWithdrawalLimit`；旧配置缺失该键时继续按 1 次，不新增数据库字段。
- 后端以上海自然日统计当前 App/用户已成功创建的提现申请；驳回、失败或退票不返还次数，同一幂等请求不重复计数。新 V4.8 自动迁移仅将旧每日唯一索引改为普通计数索引，不回填历史数据，无需人工执行 SQL。
- Catseller 资格模型读取接口上限，提现页和达限文案不再硬编码 1 次。三端专项用例已覆盖默认 1、配置 2/3、超限阻断和配置整数校验；未部署、未调用真实银行/工猫。

## 2026-08-31 OSS 签名地址重复编码修复

- 用户已授权修复；公共 HTTP 普通/文件发送改用已编码 URI，避免签名中的 `%` 被重复编码；不改工猫配置、App/Admin、认证/绑卡/资金逻辑。数据库改动：无。
- 状态 `waiting_review`；新增8项本地传输回归，修复前签名用例失败、修复后专项301项通过；全量1672项中1668通过、1项既有视频批次失败、3跳过。差异检查与工作区守卫通过，详细结果见 [补充验证](05-联调与测试/invite-identity-bank-split-verification.md#2026-08-31-补充oss-签名地址重复编码修复)。不覆盖其他CHG状态。
- 后续需重启更新后的本地后端再由用户复验；当前未重启、不部署、不访问真实身份证或调用工猫。不因本次错误重传已上传照片或更换工猫密钥。

## 2026-08-31 姓名中文输入修复

- 状态：`waiting_review`。仅调整 Catseller 实名认证、独立绑卡两页姓名输入；原拆分流程、其他 CHG、后端和 Admin 不变。数据库改动：无。
- 原因：共用输入组件固定 `enableSuggestions=false`，本机 Flutter Android 引擎因此附加可见密码输入标志，影响部分中文输入法。两处姓名改为 `TextInputType.name` 并开启候选词；其他字段保持原配置，个性化学习、自动填充及自动纠错仍关闭。
- 新增两页输入法配置/拼音组合/中文姓名回归用例，修复前失败、修复后邀请相关 79 项通过；格式化、静态分析通过。详细验证见 [本次补充记录](05-联调与测试/invite-identity-bank-split-verification.md#2026-08-31-补充姓名中文输入修复)。
- 恢复点：更新运行中的 App，退出并重新进入认证/绑卡页复验中文输入；本轮未做真机输入法测试、全量 App 测试、打包或部署，不用 Widget 测试替代真机验收。

## 2026-08-31 当前增量：实名认证与独立绑卡

用户已确认拆分计划，本地实现 `waiting_review`。P06三项资料+两张私有身份证resourceId、18–65周岁校验；P10独立四项绑卡表单。提现页不强跳，点击时先判实名再判ACTIVE卡；认证成功只返回刷新并等待“去绑定”，绑卡成功再返回。后端认证不建卡/不激活旧PENDING；新增POST bank-accounts核对本App资料后调用updateEmployee，明确成功才激活，用户锁/同卡去重/显式未知重试与默认卡规则已实现。

本次App与共享后端一起更新（identityReady替代ready，删除bankAccount），不修改Admin、其他App页面或资金状态机。业务/工猫连接共用，实名、照片、会话、银行卡和资金全部按App隔离；下方历史“敏感资料共享”不再作为当前实现依据。

数据库：有既有持久化行为调整，无新增/修改SQL、表、字段、索引或Flyway；不修复checksum、不清库、不动余额。保持正式SQL冻结基线、此前10元、现有改动和其他CHG状态。本轮没有部署、真实OSS上传、核身签约或提现。

[详细验证、截图与恢复点](./05-联调与测试/invite-identity-bank-split-verification.md)。后续：重启更新后的本地后端、更新App后进行用户复审；真实Android/iOS权限/H5和工猫61–65周岁渠道另行验收，不以离线测试冒充渠道通过。


## 2026-08-31 App 银行卡 ID 解析修复

- 状态：`waiting_review`；用户截图确认资格响应中的银行卡 `id` 为字符串，App 误用整数金额解析器导致整页加载失败，现已修复并完成本地回归。
- 范围：仅 catseller 银行卡 Model、测试 fixture 和回归用例；保持请求中的整数 ID、金额校验、`PENDING`/实名/提现门禁不变，不修改 Java、Admin 或数据库。
- 验证：新增页面用例在修复前复现“加载失败”；修复后 61 项邀请/银行卡/合同/H5/规则测试、`flutter analyze --no-pub`、格式化和 `git diff --check` 通过。未运行全量 App 测试、原生构建或真机/真实提现验收。
- 恢复点：更新 App 后重新进入提现页复验；仍须完成实名电签和银行卡认证，不将 `PENDING` 视为 `ACTIVE`。详细记录见 [Flutter 提现模块](03-前端/开发计划/03-invite-withdrawal-auth.md#2026-08-31-银行卡-id-解析修复)，不推进原主流程。

## 2026-08-31 提现协议版本与后台密码加款增量

- 状态：`waiting_review`；[本增量开发记录](04-后端/开发计划/08-invite-agreement-balance-credit.md)。共享Java/Admin本地实现完成，App及其他CHG不变。
- 协议版本 `agreementVersion` 用于用户确认版本，不是工猫模板ID；随包默认 `v1`，已有有效保存值优先。后台新增必填校验/用途说明和密码加款入口，后者要求目标App的 `INVITE_VIEW` + `INVITE_BALANCE_CREDIT`，正金额/原因/二次确认、原钱包幂等账本和审计。
- 数据库：只复用现有表，无表结构或Flyway修改。本地Catseller缺失版本已显式补 `v1`、配置版本1，1份快照/1条维护审计，其他规则及原10元余额不变；不操作服务器、不自动授权、不真实加款。
- 账号权限：本地 `narrate/admin`（ID1）没有邀请显式授权，已询问是否仅授予Catseller查看/规则编辑/加款/审计权限，等待用户确认；未擅自新增权限。
- 验证：邀请/工猫204项全通过；Admin179项、静态分析与Web构建通过；后端完整1519项中1项既有QuickBatch视频内容审核失败、3跳过，整体build未通过，详细证据见开发记录。
- 下一步：确认账号授权；重启更新后的后端并刷新Admin复审。当前运行后端尚无新加款API，未登录真实后台操作、未签约/提现、不部署。

## 2026-08-28 共享邀请提现统一增量

- 状态：`waiting_review`；M1→M4 已本地实现，统一后端与 Admin，App 不改。
- 恢复入口：[共享统一开发记录](04-后端/开发计划/07-invite-unified-manual-payout.md)。旧双模式设计不再作为本增量依据，其他 CHG 保持原状态。
- 数据库改动：有。用户提供最新正式发布记录、JAR 和部署日志后，核对 31 份已发布 SQL 哈希不变；仅原地改未发布 common V4.5/V4.7 与 platform V4.1，V4.6 不变。交付本地只读预检/备份/DDL 同步工具，未执行结构/存量迁移、不部署、不真实工猫打款；补充授权的本地单帐号 10 元测试款已独立幂等入账。
- 当前：后端 Invite/Gongmall 181 项和 Admin 全量 172 项通过，Web 构建成功；后端全量 1496 项中 1 项视频生成内容审核失败、3 跳过，单独复测仍失败，整体 build 未通过。真实 PostgreSQL 迁移、H5/银行/退票及恢复演练仍待独立验收，不修改其他 CHG 状态。

## 2026-08-28 工猫 H5 白名单开关增量

- 执行状态：`waiting_review`；共享 `h5-allowed-hosts-enabled` 已实现，本次不推进其他 CHG 或真实渠道验收。
- 变更范围：Java 配置/就绪检查/认证地址策略/既有响应，catseller 认证 Model/受控 H5，专项测试与运行说明。默认开启，仅显式 false 关闭域名列表检查，TEST/PRODUCTION 均支持；本机私有配置关闭，不修改服务器。
- 安全边界：HTTPS、合法域名、443、禁止用户信息、证书、回跳、相机授权和文件访问限制继续保留；日志只记域名，不自动加入白名单。
- 数据库改动：无。不部署、不调用真实认证/提现、不调整退款与资金状态机。
- 验证：后端隔离无关 maintenance 入口后 179 项邀请/工猫相关测试通过；原始全量测试被该入口与主服务的 `dataSource` 重名冲突阻断，不宣称全量通过。App 结果与复验步骤见 [本次验证](05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-工猫-h5-域名白名单开关)。
- 下一步：用户重启后端和更新后的 App，主动发起认证获取域名；确认名单后启用检查、重启并退出重进认证页。启动本身不获取地址。SDK 原始调试日志在认证页存活期间暂时静默、退出恢复，仅保留安全域名日志；其他 WebView 行为不变。

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`
> 用途：记录当前流程进度、总体流程列表、恢复点、需加载规则、依赖文件、变更登记和注意事项。
> 维护规则：每次生成、修改、检测或编码完成后更新本文档。

---

## 1. 项目级配置

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `currentProject` | `喵喵带货` | 当前工作空间项目 |
| `canonicalWorkspaceRoot` | `/Users/soul/work/MakeCodePlanWord/projects/喵喵带货` | 唯一允许写入流程文档的项目工作区；不得按代码仓库当前目录解析相对 `projects/` |
| `currentVersion` | `v1.0.1+102` | iOS 游客账号审核候选版本；保留作品详情已有改动 |
| `iterationMode` | `version_iteration` | CHG-0063 将邀请好友与银行卡提现重建为独立需求版本 |
| `baseArchiveVersion` | `v0.2.0 / archive/CHG-0063-focused-invite-withdrawal-prd-20260826/` | 旧综合需求只用于追溯和回滚 |
| `currentRequirementEntry` | `01-需求/requirements.md` | 当前需求主入口 |
| `currentTechPlanEntry` | `02-技术方案/tech-plan.md` | v1.0.0 独立技术方案，仅覆盖多 App 邀请好友、银行卡提现、活动规则 Web 与现有 Admin 增量 |
| `currentFrontendPlanEntry` | `03-前端/flutter-dev-plan.md` | v1.0.0 独立 Flutter 总体开发计划，T-F001～T-F009 |
| `currentBackendPlanEntry` | `04-后端/java-dev-plan.md` | v1.0.0 独立 Java 总体开发计划；Admin/Web 独立计划为 `04-后端/admin-web-dev-plan.md` |
| `archiveIndex` | `archive/` | 仅用于旧版追溯、差异对比和回滚 |
| `referenceProject` | `projects/喵喵写歌` | 仅用于核对复用业务来源；移动端实现真源始终是 `/Users/soul/code/lxwx/catseller`，Catsinger 代码只作补充对照 |
| `frontendRepo` | `/Users/soul/code/lxwx/catseller` | 喵喵带货 Flutter 移动端真实工程；已完成登录/我的/积分充值及积分详情、订单列表、意见反馈、推广素材 Figma 对稿与真机回归 |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` | 已完成 catseller Java 后端、公共能力复用与多 App schema 接入 |
| `adminRepo` | `/Users/soul/code/lxwx/lxwx_admin` | 现有 Flutter Web 后台；已存在“交易与增长 > 邀请收益管理”和 `lib/pages/common/invite_page.dart` |
| `flutterChannel` | `stable` | 现有 catseller 工程；Dart SDK 约束 `^3.11.4` |
| `backendFramework` | `Spring Boot 3.3.0 / Java 21` | 以现有后端 `build.gradle` 为准 |
| `backendBuildTool` | `Gradle` | 复用现有 Wrapper 与 `build.gradle` |
| `targetStores` | `待确认` | 目标市场和商店尚未确认 |

## 1.1 当前主文档入口与归档索引

| 文档域 | 当前主路径 | 状态 | 说明 |
|--------|------------|------|------|
| 当前入口说明 | `CURRENT.md` | `active` | 明确当前唯一需求范围和技术隔离门禁 |
| 需求 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md` | `done` | v1.0.3 已确认，只包含多 App 共用的邀请好友、银行卡提现、活动规则 Web 页及现有后台复用/升级 |
| 需求检测 | `01-需求/detection-feedback.md` | `PASS / done` | 用户已通过生成技术方案指令确认检测结论，旧版结论仍不得复用 |
| 设计素材 | `01-需求/references/images/invite-withdrawal/`、`01-需求/figma-design-plan.md` | `done` | 22 张页面图已导出、嵌入 PRD 并完成设计输入复核 |
| 技术方案 | `02-技术方案/tech-plan.md` | `done` | 用户已确认 v1.0.0 多 App 邀请提现技术方案 |
| 工时评估 | `02-技术方案/effort-estimate.md` | `done` | 用户已确认：1 个工作日完成三端代码初稿，2 个工作日形成可本地验证版本；外部等待不计入 AI 工时 |
| 前端技术文档 | `03-前端/flutter-tech.md` | `done` | 用户已确认 v1.0.0 邀请、实名电签、银行卡和提现技术方案 |
| 后端技术文档 | `04-后端/java-tech.md` | `done` | 用户已确认 v1.0.0 Java/Admin/Web 技术方案 |
| Flutter 总体计划 | `03-前端/flutter-dev-plan.md` | `done` | T-F001～T-F009、接口依赖和 6 份已生成模块文档 |
| Java 总体计划 | `04-后端/java-dev-plan.md` | `done` | T-B001～T-B013、API、迁移和 7 份已生成模块文档 |
| Admin/Web 总体计划 | `04-后端/admin-web-dev-plan.md` | `done` | 独立 T-A001～T-A007 与 4 份已生成模块文档 |
| Flutter 模块文档 | `03-前端/开发计划/` | `done` | 6 份已确认；API/路由及邀请/实名/银行卡/提现/规则页面已本地实现，22图对稿待复审 |
| Java 模块文档 | `04-后端/开发计划/`（不含 admin） | `done` | 7 份已确认；00 基础/迁移、05 能力/规则权限已实施；未启用资金 |
| Admin/Web 模块文档 | `04-后端/开发计划/admin/` | `done` | 4 份已确认；多 App 后台独立实施 |
| 三端编码恢复点 | `implementation-progress.md` | `waiting_review` | CHG-0068 三端核心实现、配置与对稿本地检查完成；真实渠道待验收 |

| 归档目录 | 来源版本 / CHG | 归档内容 | 状态 | 说明 |
|----------|----------------|----------|------|------|
| `archive/path-recovery-20260731/` | 错误工作区路径恢复 | 原 catseller 错误工作区原样快照与 SHA-256 | `reference-only` | CHG-0021～CHG-0027 的来源证据，不作为执行入口 |
| `archive/CHG-0062-invite-withdrawal-prd-20260826/` | v0.1.7 / CHG-0062 | 变更前需求清单、PRD 与素材索引 | `reference-only` | 仅用于 v0.2.0 差异对比和回滚，不作为当前执行入口 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/` | v0.2.0 / CHG-0063 | 旧综合需求、Figma、排期、Flutter/Java 技术文档、总体计划与 23 份旧模块文档 | `reference-only` | 不得作为当前需求、技术方案、计划或编码依据 |

---

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `13/14 本地实现评审；15 真实环境准备` |
| 当前步骤 | `三端核心实现与22图对稿已完成本地检查，等待用户复审及工猫配置` |
| 当前步骤状态 | `waiting_review` |
| 当前恢复点 | 三端核心实现和本地检查已回写 implementation-progress.md；本次 P01 顶部暖粉背景修正、3 图对照和 39 项邀请专项通过，详见 03-前端/design-qa.md 第 7 节。真实工猫/银行、双平台真机及未勾选专项仍待验收，不恢复到历史骨架批次。 |
| 下一步默认动作 | 复审页面及本地验证报告；用户补充工猫私有配置后安排真实 H5/银行联调。不自动部署、迁移或启用。 |

状态枚举：`pending`、`in_progress`、`waiting_review`、`done`、`blocked`、`skipped`。

---

## 3. 总体流程列表

| 序号 | 流程项 | 目标产物 / 目标动作 | 当前状态 | 说明 |
|------|--------|----------------------|----------|------|
| 0 | 变更校准 | `change-plan.md` | `in_progress` | CHG-0067 排期纠正已确认；CHG-0063～CHG-0066 继续承载当前功能评审链路，其他进行中 CHG 保持原状态 |
| 1 | 需求分析 | `01-需求/requirements-list.md` | `done` | v1.0.3 固定共享邀请、佣金、实名、银行卡、提现、活动规则 Web 和现有后台边界 |
| 2 | 需求文档生成 | `01-需求/requirements.md` | `done` | 11 节独立 PRD 包含 8 个 App 原生页、1 个活动规则 Web 页、1 个现有 Admin 页面和 22 张 Figma 图片 |
| 3 | 需求文档检测 | 检测报告 + `01-需求/detection-feedback.md` | `done` | v1.0.3 检测 PASS，用户已确认进入技术方案 |
| 4 | Figma 设计稿计划 | `01-需求/figma-design-plan.md` | `done` | 复核 22 张现成设计、PRD 补充状态与现有 Admin UI 基线；无新增设计产出 |
| 5 | 技术方案 | `02-技术方案/tech-plan.md` | `done` | 用户已确认 v1.0.0 多 App 隔离、账本/账户、工猫、Admin/Web 与安全方案 |
| 6 | 工作时长评估 | `02-技术方案/effort-estimate.md` | `done` | 用户确认单 AI 代理 1 天完成代码初稿、2 天形成本地验证版本 |
| 7 | 前端 Flutter 技术文档 | `03-前端/flutter-tech.md` | `done` | 用户通过“继续下一步”确认 v1.0.0 |
| 8 | 后端技术文档 | `04-后端/java-tech.md` | `done` | 用户通过“继续下一步”确认 v1.0.0；capability 已与技术方案统一 |
| 9 | Flutter 总体开发计划 | `03-前端/flutter-dev-plan.md` | `done` | 用户已确认 v1.0.0：T-F001～T-F009、API/本地逻辑、6 份模块文档 |
| 10 | 后端总体开发计划 | `04-后端/java-dev-plan.md`、`04-后端/admin-web-dev-plan.md` | `done` | 用户已确认 v1.0.0：T-B001～T-B013 与独立 T-A001～T-A007 |
| 11 | Flutter 模块开发文档 | `03-前端/开发计划/` 6 份模块 | `done` | 用户已确认，代码进度独立记录 |
| 12 | Java/Admin/Web 模块开发文档 | `04-后端/开发计划/` 7 份 Java + `admin/` 4 份模块 | `done` | 用户已确认，代码进度独立记录 |
| 13 | Flutter 编码 | `{frontendRepo}` | `waiting_review` | 页面/导航/契约/安全本地实现与22图对稿；37专项通过，全量11项非邀请失败单列 |
| 14 | 后端与 Admin/Web 编码 | `{backendRepo}`、`{adminRepo}` | `waiting_review` | 工猫/身份/资金/Admin/Web本地核心实现；真实渠道、运维及专项测试余项见恢复点 |
| 15 | 联调与测试 QA | `05-联调与测试/invite-withdrawal-local-verification.md` | `in_progress` | 本地测试及模拟页面验收已执行；真实工猫/双平台真机/银行验收尚未执行 |
| 16 | 构建与打包 | `06-构建打包/{build-plan.md,android.md,ios.md}` | `pending` | 待 QA 通过 |
| 17 | 应用商店上架 | `07-应用上架/release-checklist.md` 等 | `pending` | 待构建通过 |
| 18 | 发布与版本管理 | `08-发布版本/{release-plan.md,changelog.md}` | `pending` | 待上架准备完成 |
| 19 | 上线监控与迭代 | `09-上线监控/{monitoring-plan.md,feedback-loop.md}` | `pending` | 发布后进入 |

---

## 4. 当前变更登记

- 2026-08-28 CHG-0068 P09 容器简化（`waiting_review`）：活动规则路由已直接返回 `StaticPageView(pageKey: 'invite-rules')`，复用通用静态页，删除规则专用三件套；正式地址与 `embedded=1` 放在 `legalPageUrls`。46 项相关测试和 analyze 通过，未改工猫 H5、共享静态页组件、Web 正文、后端或数据库。原生 WebView 和正式规则数据仍待验收，详情见 Flutter 模块 04 最新回写。

- 2026-08-28 CHG-0068 P09 地址调整（`waiting_review`）：已改读 `AppConstants.legalPageUrls['invite-rules']` 中的正式 HTTPS 地址，不请求 overview/capability 获取 URL。46 项相关测试、analyze 通过；全局协议常量用例改前改后均因既有客服地址断言不一致而失败，未顺带修复。正式 HTML 为 200，公开动态规则接口返回 `code=-404`，完整内容待对应后端发布/原生联调；N 天和最低额仍动态读取。不修改其他 App、Java/Admin 或数据库，不执行线上部署，详见 Flutter 模块 04 最新回写。

- 2026-08-27 CHG-0068 页面复审增量（`waiting_review`）：已使用 Figma `43:1639` 原始五段暖粉/白色渐隐图修正 P01 状态栏与导航栏，其他子页不启用。3 张首页同轮对稿、39 项邀请专项（新增 2 项顶部回归）、analyze、iOS 离线预览构建与跳转返回通过，证据见 `03-前端/design-qa.md` 第 7 节。未改资金规则、后端、Admin 或数据库；保留用户账号页及全局配置改动，真实渠道门禁仍在。

- 2026-08-27 CHG-0068 最新：已完成三端核心实现、工猫共享私有配置读取与安全状态显示、资金状态机/回调查单、Admin审核/查看密码、规则Web及App22图对稿；状态 waiting_review。实际验证和剩余门禁以 implementation-progress.md 及 invite-withdrawal-local-verification.md 为准。以下批次均为历史追溯，不表示功能仍停留在骨架。

- 2026-08-27 CHG-0068 第二批（历史）：实现首单付费事实、N 天结算快照/到期任务、累计退款差额/全额补齐、负余额，以及 Admin 结算天数与最低额动态配置。Java 默认 test/build 最终成功（1217 项，0 失败、3 跳过），Admin 156 项/analyze/Web build 通过；V4.6 在隔离 PostgreSQL 重放验证。查询/新模式绑定、移动页面、其他退款渠道及完整工猫提现仍待后续，不启用模式、不改历史资金。金额、N 天及最低额选择已确认，恢复时直接读 implementation-progress.md 继续。

- 2026-08-27 CHG-0068：按用户继续授权修复失效规则引用并完成首批三端基础代码。Java test/build（1187 项，0 失败，3 跳过）、Admin 153 项与 Web 构建、新增 App 6 项通过；App 全量 11 项非邀请失败未修复。PostgreSQL 16 隔离重放 5 个 App 与 platform SQL 通过，无业务库变更或真实工猫调用。新 Figma 通道 mj5kz8uv 的 22 图与现有素材字节一致。下一模块等待返佣舍入/部分退款口径确认；历史记录以下保持可追溯，当前状态以本条及编码恢复点为准。

- 2026-08-27 用户确认进入三端代码开发，CHG-0063～CHG-0066 文档评审已闭合；实现进度仍未开始。当前因移动端必读规则缺失暂停业务代码修改；该阻塞与分批恢复顺序写入 implementation-progress.md，其他 CHG 和未提交改动保持不变。

- CHG-0063～CHG-0066 已进入模块开发文档复审：用户确认 Flutter、Java、Admin/Web 三份总体计划；旧综合模块已可恢复归档，当前 17 份模块只覆盖邀请与银行卡提现。已按技术方案和现有接口统一表名、错误码、page/pageSize 与提交前退款复核口径；未修改业务代码或数据库。

- CHG-0067 AI 工时口径已纠正并由用户通过“继续下一步”确认：v1.0.1 固定为 2026-08-27 用 1 个工作日完成 Java、Flutter、Admin/Web 全部代码初稿，2026-08-28 再用 1 个工作日完成构建、自动化测试、数据库迁移校验和集中修复；真实工猫联调、法务财务确认、人工验收等待与银行到账不计入 AI 工时。未修改业务代码或数据库。

- CHG-0063/CHG-0064/CHG-0065/CHG-0066 技术方案已确认：用户已确认需求检测并要求生成技术方案，随后通过“下一步，评估工时”确认进入工时阶段。`02-技术方案/tech-plan.md` 采用 App 能力模式、App schema 资金隔离、平台共享工猫连接、有符号账本与账户快照、稳定 requestId、可靠任务、回调触发原 ID 查单、可逆数据加密和 Admin 短时敏感查看。未修改 Flutter、Java、Admin、Web 或数据库代码。

- CHG-0066 需求基线已确认：v1.0.3 将邀请等级连线改为按有效人数逐人推进，明确 P01 六类入口和 P02“邀请好友（推广素材）”单页；P09 改为 `/Users/soul/code/lxwx/lxwx_admin/web/` 下参考隐私协议实现的活动规则 Web 页。所有启用 App 共用一套平台工猫商户连接与密钥，requestId 持久化映射负责 App 归属。Admin 默认脱敏，专用权限管理员输入独立平台查看密码并填写原因后，只能在当前详情最多 5 分钟查看数据库解密值；失败锁定、审计、禁止复制/批量/导出已写入。未修改 Flutter、Java、Admin 或数据库代码。

- CHG-0065 需求基线已确认：用户明确邀请返佣与提现是多 App 共用能力。v1.0.2 PRD 保留喵喵带货 22 张移动端 Figma 作为首个落地参考，但将后台、后端、数据、工猫 Provider、回调、定时任务、权限和审计统一改为按 App Code 隔离；Admin 复用现有 App 切换和 InvitePage，展示/操作由当前 App 的能力模式决定，不以 Catseller 名称硬编码。启用 App 使用统一直邀首单、BANK 和提现状态机，未启用 App 不被隐式迁移。本轮未修改 Admin、Flutter、Java 或数据库代码。

- CHG-0064 需求基线已确认：已确认 `/Users/soul/code/lxwx/lxwx_admin` 现有“交易与增长 > 邀请收益管理”，以及 `lib/pages/common/invite_page.dart` 的规则配置、用户代理配置、提现管理三个页签。v1.0.1 PRD 按“已有复用、缺失新增、冲突调整”补充 A01：复用现有入口、页面和已有操作，新增佣金流水、BANK/工猫详情与主动对账；Catseller 隐藏二级代理、人工等级和人工打款终态，其他 App 保持原行为。本轮未修改 Admin、Flutter、Java 或数据库代码。

- CHG-0063 需求基线已确认：当前主需求已重建为 v1.0.0，只包含邀请好友、返佣、实名协议、银行卡和提现；最新 Figma 通道 `czmwv14c` 的 22 张设计图已导出并直接嵌入 9 个页面详细需求。旧 v0.2.0 综合需求已整体归档为 `reference-only`，当前技术方案未引用旧综合需求。本轮未修改 Flutter、Java、Admin 或数据库。

- CHG-0062 已被 CHG-0063 取代：其 v0.2.0 综合需求与旧 Figma 素材仅保留在归档中，不再作为当前执行入口。

- CHG-0061 已完成：为 `catseller_cases` 增加非空 `work_type` 快照字段，历史来源案例优先从来源作品回填，无法取得类型的历史案例回填 `PRODUCT_VIDEO`。来源案例创建时忽略前端类型并采用来源作品真实类型，同一来源后续编辑保留已保存快照；手工案例支持三种类型并兼容旧后台缺字段时默认商品视频。数据库不使用固定三值 `CHECK`，合法编码由后端枚举统一校验，后续增加作品类型无需再改表结构。公开首页、案例分页、详情及后台响应统一返回 `workType`；Admin 列表显示类型，来源案例只读，手工案例可选，替换为手工素材后保留当前类型并开放修改；Flutter 继续使用现有映射并增加契约回归。分类标签问题不在本次范围。

- CHG-0060 已完成：移动端不再使用友盟统计。Flutter 删除 `umeng_common_sdk`、`UmengAnalyticsService`、AppKey 常量、统计渠道解析和对应测试；隐私拒绝/撤回流程不再调用友盟合规接口。Android 删除 `MainApplication` 预初始化、合规 MethodChannel、集成测试 URI、AppKey `BuildConfig`、R8 规则和插件 Kotlin 兼容配置；iOS 删除 UMCommon 辅助类、Xcode 源文件登记、Podfile 兼容逻辑及 Pod 锁定。README 和当前 Flutter 技术/计划文档同步移除友盟配置。依赖树、Android APK dex、iOS Simulator App、`pubspec.lock`、`Podfile.lock` 和插件注册表扫描均无友盟符号；`flutter analyze`、身份 4 项、隐私门禁 11 项、Android Debug APK 与 iOS Simulator 构建通过。组合 Widget 回归 117 项通过、5 项既有法务地址/首页旧文案/Golden 断言失败，与本变更无关。未修改后端、Admin、数据库或接口。

- CHG-0059 已完成：`ResourceService` 从隐私保护服务组迁到 App 基础启动阶段，在 `StorageService` 初始化完成后读取本地缓存账本并永久注册；初始化本身不读取设备信息，也不主动下载资源。未同意、拒绝或撤回隐私协议后，该服务仍保留，匿名用户主动点击公开首页案例时可继续换签、下载和缓存播放；撤回授权只清理设备审计请求头及登录、支付、一键登录、分享、更新和统计等受保护服务，不自动删除已有媒体缓存，设置页清理缓存入口保持不变。未修改接口、模型、路由、后端、Admin、数据库或原生配置。隐私/作品门禁 8 项、首页案例 9 项、资源服务 7 项及 `flutter analyze` 通过；Android/iOS 冷启动真实播放待总体 QA 执行。

- CHG-0058 已完成并按统一入口返工：所有进入登录页的路径均前置全局用户协议与隐私政策确认。主动跳转统一收口到 `CustomRouter.openLogin`，作品 Tab、账户页、`LoginService` 和接口 401 回跳不再各自实现；登录路由增加 `AuthPrivacyGate`，继续兜住鉴权同步重定向、直接 `/login` 和 Deep Link。用户同意并完成受保护服务初始化后才构建登录页，拒绝或上下文失效时停留原页面或回主页面；登录页内部提交登录前的页面级协议勾选保持不变。隐私/登录入口 10 项、游客账号 4 项回归、`flutter analyze` 与差异检查通过。

- CHG-0057 已完成：商品、探店和爆款复刻分析素材图上传前统一转 JPEG，保持原分辨率并按 95 至 60 逐级降质，使用能满足当前作品压缩后总量不超过 10 MiB 的最高质量；恢复草稿图片纳入总量，作品详情 `inputImages/productImages` 新增资源台账 `sizeBytes`。压缩准入串行、上传可并发，查重与 OSS 全链路只使用压缩文件；删除、替换、返回、系统弹出、Controller 销毁和进入生成页清理页面级缓存，24 小时遗留目录由新会话兜底，槽位版本阻止旧回调覆盖。模特照片、参考视频、数据库和服务端总量拦截不变。后端强制全量测试、Flutter 定向 23 项、静态分析和双平台构建通过；Flutter 全量 202 项通过、11 项既有导航/法务地址/Golden 等失败，与本变更无关。

- CHG-0056 已完成并按运营恢复策略收口：视频类型演示视频限定 `public/catseller/video-type-videos/` OSS 公开目录，业务配置以永久 `demoVideoUrl` 替代私有资源 ID；Admin 支持上传、替换、清除及手工粘贴公开目录地址，手工地址无需已有资源台账记录，任意外部地址仍拒绝，封面为空时继续自动抽帧；视频类型弹窗改为“保存并生效”，确认后立即调用业务配置保存接口写入 `app_configs`，失败时恢复原页面值并提示错误，不再要求运营额外点击页面右上角保存。移动端优先使用后台封面并在视频类型预览弹层自动播放真实演示视频，支持暂停、重播、失败重试、退后台暂停和关闭释放。Catseller `configVersion`、迁移接口、注册器、全部历史迁移类和兼容测试均已删除，代码只读取当前数据库结构，清空 `app_configs` 后直接使用当前随包 JSON；非法旧结构明确失败。无 Flyway 或表结构变更，清除视频配置不删除 OSS 对象。后端全量测试、Admin 相关 79 项测试、移动端相关 6 项测试和两端 `flutter analyze` 均通过。
- CHG-0055 已完成：Catseller 图片/视频理解升级为单次媒体模型直接生成可见事实和候选卖点，缓存版本升为 v2；用户确认卖点后复用 `/api/catseller/works/{workId}/script-tasks`，单次文本模型直接生成 `title + durationSeconds + shots[]`。商品仅使用原 8 种类型，探店由服务端固定 `store_visit` 且用户端严格隐藏，爆款复刻不使用视频类型；业务配置同步为当时最新结构。新增 `/api/admin/ai-prompts/**` 目录、草稿、发布、恢复、预览、真实输入、三类 Provider 调试、执行记录与轮询，数据库使用通用迁移 `V3.12__ai_prompt_management.sql`（`V3.11` 已被既有迁移占用）。Admin 同步移除废弃阶段并支持结构化调试结果；Flutter 用户端未修改。
- CHG-0054 已完成：脚本生成和视频合成等待页可见期间持有屏幕常亮，离开页面后释放；新增多持有者协调并收口既有 Toast/指示器常亮调用，只有最后持有者释放才恢复系统熄屏。未修改任务提交、轮询、路由、Java、Admin、数据库或接口。2 项常亮自动化、2 项生成链路回归、`flutter analyze` 和 `git diff --check` 通过；`SCRIPT-010`、`VIDEO-011` 待双端真机 QA。
- CHG-0053 已完成：`HomeController` 保持启动即请求；iOS 首次失败先保留 loading，500ms 内不展示错误区或 Toast，系统联网授权弹窗停留期间继续隐藏。观察到 `inactive → resumed`、首次请求失败、无可用数据且当前空闲时，延迟 300ms 复用 `/api/catseller/home` 静默重载一次；兼容先 resumed、后收到失败的竞态。没有授权生命周期时恢复原错误与手动入口，自动重试失败也保留错误区但不重复 Toast。生命周期监听随 Controller 关闭注销；Android、App 内隐私协议、catsinger、后端、Admin、数据库和接口均未修改。新增 8 项测试、首页案例 9 项与隐私流程 5 项回归及 `flutter analyze` 通过；全量 178 项通过、11 项既有无关失败。手工用例 `HOME-011` 仍待当前总体 QA 执行。
- CHG-0052 已完成：AI 带货商品图、AI 探店门头/环境/餐品图和爆款复刻素材图统一增加客户端单图 10 MiB 前置校验；恰好 10 MiB 允许上传，超一字节即提示“图片大小不能超过 10MB”。校验先于槽位 loading、MD5、资源查重和直传，空槽或已有成功图片不会被超限选择覆盖；模特图不受影响，参考视频仍为 80MB。新增边界测试及资源/图片分组回归共 11 项通过，`flutter analyze` 通过；全量 170 项通过、11 项既有无关失败。Java、Admin、数据库和接口未修改，手工用例 `CREATE-014` 仍待当前总体 QA 执行。
- CHG-0051 已完成：iOS 阿里云一键登录原生授权页不再用 260 pt 固定占位宽度计算号码 x 坐标，改为读取 SDK 返回的真实号码 frame 宽度并相对父视图水平居中；根据用户真机反馈继续将协议区底部约束从 10 调整为 24 个设计像素，使协议整体上移 14 个设计像素。Logo、号码纵向位置、字号、按钮、登录流程和 Android 实现均未改变。`flutter analyze`、2 项 iOS 一键登录回归、iOS Simulator 构建和 iPhone 14 Pro / iOS 26.3 真机签名安装均通过；真机真实运营商授权页的全屏、号码和底部协议聚焦对比无 P0/P1/P2 差异，未勾选协议、未提交登录。
- CHG-0050 已完成：iOS 登录页、会员开通页和设置页全部移除“恢复购买/正在恢复购买”用户入口，并清理三处页面 Controller 中仅服务于这些按钮的状态、getter 与点击方法。`LoginService.restoreAppleSubscription`、支付网关、StoreKit 交易监听、未完成订单自动补单和后端恢复接口保持不变；未修改 Android、后端、Admin、数据库或 iOS 原生配置。3 项入口 Widget 回归与 8 项 Apple IAP 购买/取消/自动补单专项通过，`flutter analyze` 通过；Flutter 全量 166 项中 155 项通过，11 项失败均为现有导航、法务地址、旧页面文案和作品详情 Golden 基线，与本次入口移除无关。
- 2026-08-19 已完成移动端全量手工回归用例编制并按平台修订账号边界：新增 `05-联调与测试/qa-plan.md` 和 `cases/mobile-full-regression.md`，Android 明确不提供游客账号，登录页只覆盖手机号和环境可用时的一键登录；A1 游客创建、恢复、绑定和游客门禁仅在 iOS 执行。其余用例覆盖启动隐私、首页案例、三种创作、脚本分镜、视频积分、作品详情、下载分享、账户公共页、弱网进程恢复和平台兼容。当前仅为 `waiting_review / not_run`，未执行、未预填通过结论，不关闭 CHG-0020/CHG-0019，不修改 Flutter、Java、Admin、数据库或接口。
- CHG-0049 已完成：视频合成失败页在自动失败跳转后即使成为路由栈底，顶部返回和 Android 系统返回也会通过 `CustomRouter.popOrMain` 回到主页面；从作品页等有历史栈入口进入时仍正常返回上一页。同步修复脚本创意失败页的同类问题，并新增 4 项 Widget 回归覆盖两个失败页的顶部返回与系统返回。定向测试和 `flutter analyze` 通过；Flutter 全量 167 项通过、9 项既有无关失败（5 项现有 Widget 断言、4 项作品详情 Golden 差异），未修改接口、Controller、生成/重试或返回修改流程。
- CHG-0048 已完成：积分充值结果页在支付成功时不再展示“重新支付”或其他重试入口，底部仅保留铺满可用宽度的“返回页面”；支付失败状态继续保留“重新充值”。定向 Widget 回归和 `flutter analyze` 通过，未修改支付、积分刷新、路由分流或后端。
- CHG-0047 代码完成、待真机验收：首页案例预览已同时透传 `caseId / videoResourceId / videoUrl`；播放时优先用资源 ID 调用 `/api/resources/{resourceId}/access-url` 换取临时地址并下载到统一视频缓存，再通过本地文件播放器播放，旧案例缺少资源 ID 时使用补全后的 URL 兜底。支持播放、暂停、播完重播、加载失败重试、App 退后台自动暂停和页面销毁释放播放器；仅资源 ID 的案例也显示播放按钮，无任何视频来源的占位案例不显示。有视频来源时复用作品详情 `AppAiGeneratedWatermark(compact: true)`，在视频区右下角固定展示“AI生成”标识。案例预览与资源服务合计 16 项测试、`flutter analyze` 和差异检查通过，仍需 Android/iOS 真机验证首次下载、画面、声音和前后台切换。
- CHG-0046 已完成：视频生成草稿填写页的“参数设置 > 视频时长”暂时隐藏“智能时长”选项，仅增加展示层开关；`FIXED / AUTO` 配置解析、草稿恢复、选择方法和请求序列化逻辑均保留。`flutter analyze` 和 3 项时长模式专项测试通过；未修改后端、Admin 或数据库。
- CHG-0045 等待外部验收：iOS 游客拥有正式 userId/JWT，可填写商品、生成脚本、购买、合成视频和查看作品；手机号绑定完全可选。所有新用户创建统一发放一次 30 积分，游客恢复及绑定手机号不重复发放。已恢复真实路由门禁并移除固定登录成功绕过，Keychain 游客凭证、账号类型、session/registered 权限、待确认 Apple 订单 ownerUserId 与三处主动恢复入口已接入。iOS 登录首屏进一步移除标题和游客说明，固定提供“游客登录 / 手机号登录”，全局隐私同意后异步检测一键登录，支持时显示第三个入口但不自动打开；用户点击后才进入运营商授权页，取消回选择页并可再次点击，“其他手机号登录”进入短信页，不支持时隐藏入口。原生授权页已撤销重复游客入口与 `guest_login` 结果。Android 保持手机号登录和环境可用时的一键登录，不提供游客账号或游客入口；Android 账户、积分、购买恢复、后端、数据库和 Admin 均未改动。iOS 三入口与 Android 登录回归、4 项 iOS 游客账号测试、Flutter analyze 与 catseller iOS Simulator 构建通过；Flutter 全量基线仍保留 5 项既有无关断言失败。保留 CHG-0044 的作品详情及 `lib/apis/catseller.dart` 重叠改动，待带 SIM iPhone、StoreKit Sandbox 与完整带货真机验收。
- CHG-0044 已完成并完成详情编辑返工：作品详情按 Figma `31:96`、`37:95` 恢复横竖屏预览、商品脚本卡片和底部操作，标题编辑使用 `32:268` 底部弹框。商品脚本默认只读并在右上角显示铅笔；进入编辑后底部切换为“取消 / 确定”，失焦和键盘完成不保存，确定时以一次 `DETAIL_EDIT` 事务批量提交变化分镜，取消还原全部本地输入，失败保留编辑态和内容。底部按钮在有无系统 inset 时均保持 36px 设计留白。详情页“重新生成”已接入与确认脚本页“生成视频”相同的最新报价、积分确认、余额复检、权益引导、幂等任务提交和合成等待页链路；不调用详情编辑接口，也不重置为草稿。公共积分确认弹框的积分数字改为单行自适应，避免三位数报价挤出确认按钮。`PATCH /api/catseller/works/{workId}/input` 的 `INPUT_EDIT / DETAIL_EDIT` 分流及状态不变约束保持不变。Flutter analyze、15 项作品详情专项测试、后端 Catseller/OpenAPI 专项测试、后端无测试构建和四态视觉 QA 通过；Flutter 全量 139 项通过、5 项既有无关断言失败，后端全量 963 项中 36 项既有跨模块/环境断言失败。无数据库迁移，不涉及 Admin。
- CHG-0043 已完成：公共资源 MD5 查重接口由 Catseller 业务目录参数改为通用 `mediaType=IMAGE|VIDEO`。Core 只负责媒体分类、摘要和大小查询，允许共享的业务资源目录由 Catseller 层 `ReusableResourcePolicy` 映射；查重响应不再返回业务 `resourceType`。移动端商品/探店图片查重发送 `IMAGE`，prepare/complete 仍使用 `catseller/product-images` 确定 OSS 存储目录。本次无数据库改动。
- CHG-0042 已完成：三种作品场景增加 `FIXED / AUTO` 时长模式。固定模式保持原配置秒数；智能模式由脚本模型在 5～60 秒内返回严格整数，并把最终秒数固化到脚本版本、报价快照和视频 Provider 请求。移动端填写页增加“智能时长”，确认脚本页不提前展示最终秒数，报价阶段展示具体秒数；Web/Admin 作品详情兼容显示“智能时长”。不新增工作流步骤，开发阶段直接修订尚未部署的 Catseller `V3.6` 迁移。后端 952 条测试与 build、管理后台 98 条测试、两端静态分析及差异检查通过；移动端新增定向测试和 analyze 通过，全量仍保留 5 条既有无关 Widget 断言失败。
- CHG-0041 已完成：Java 服务新增独立结构化 API 访问审计日志，记录 traceId、App、认证账号内部 ID、操作类型、接口路径、HTTP 结果、耗时、源/目标网络端点以及最小客户端特征；审计日志按天和大小滚动，默认保留 190 天且不设置容量提前淘汰。Flutter 在用户同意隐私政策后发送匿名安装标识、系统版本和设备型号，撤回同意后立即移除；服务端仅保存安装标识 SHA-256 摘要，不记录请求正文、查询参数、Token、手机号、验证码或响应正文。本次无数据库变更。
- CHG-0039 已完成：通过 Figma 通信频道 `z1uz2bzy` 读取登录画板 `12:313`，将页面渐变、顶部渐变和两处淡粉光晕合成为 375×812 比例的全屏背景资源。Flutter 登录页改由 `CustomScaffold.backgroundImage` 加载，背景适配统一为 `BoxFit.cover`；Android/iOS 原生一键登录同步使用同一视觉资源。Android 阿里云授权页进一步启用 SDK 官方 `SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN`，状态栏与底部系统栏改为透明，使页面背景连续覆盖系统栏。`flutter analyze`、7 项登录定向回归、Android Debug APK 和 iOS Simulator 构建均通过；V1981A Android 12 已验证状态栏全屏背景及未勾选静态提示。未修改登录业务、协议行为、后端、管理后台或数据库。
- CHG-0038 已完成：“我的”页“邀请好友”在登录门禁后直接进入推广素材；以 Figma `25:612` 为视觉真源，将推广素材从旧黑紫色页面改为白底粉色结构，并使用 `25:671` 真源 AI 带货视频海报。复制链接、动态二维码与保存海报业务保持不变；V1981A Android 12 完成 375×812 归一化同屏复核，P0/P1/P2 清零。
- CHG-0037 已完成：Flutter `AppConstants.legalPageUrls` 的用户协议、隐私政策、会员协议和退款协议改为正式站直达 `index.html` 地址；算法备案改为正式站 `/miaomiao-commerce/` 页面。同步更新常量回归测试；支付协议与客服地址因本轮未新增对应页面保持不变。
- CHG-0036 已完成：Android 阿里云一键登录授权页接入 Flutter 已下发的《用户协议》《隐私政策》URL；移除误绑定到协议文字和勾选框的加载旋转动画，未勾选点击登录时仅提示“请先勾选同意协议”。同时为 SDK 内置协议 WebView 补充 AppCompat 白色主题，避免点击协议崩溃。V1981A Android 12 已验证三份协议展示、两个应用协议页面、未勾选提示及页面稳定性；未修改 iOS、后端、管理后台或数据库。
- CHG-0034 已完成：Flutter 会员开通页和积分充值页从 Android/Web 可选渠道中移除尚未开通的微信支付，默认选中支付宝；iOS App Store 支付、支付服务能力、历史订单、后端和数据库均保持不变，并补充页面回归用例防止微信支付入口重新出现。
- CHG-0033 已完成：`MembershipPage` 改为 `CustomScaffold` 的真实 `appBar / body / bottomNavigationBar` 分区；透明 AppBar 保留沉浸式首图，正文支持小屏纵向滚动，购买按钮与会员协议固定在安全区底栏。同步补充普通页面默认骨架规则，特色页面仍按明确设计单独处理；未修改 Controller、接口、支付流程、后端、管理后台或数据库。
- CHG-0032 已完成：Flutter 版本检查接口返回 `NOT_FOUND / 配置不存在` 时，将缺失策略按更新功能未启用处理；设置页手动检查只提示“已是最新版本”，其他网络或服务异常仍保留原有错误处理。
- CHG-0031 已完成：以 Figma `17:1681/1758/1815/1874` 为视觉真源，将积分详情、会员/积分订单样本和意见反馈切换为白底粉色体系；新增通用 `statusPendingAccent` 主题令牌，保留订单筛选/取消/续付/删除和反馈提交业务。V1981A Android 12 完成 375×812 归一化同屏对比，P0/P1/P2 清零；本轮不处理 iOS，不修改后端、管理后台或数据库。
- CHG-0030 已完成：以 Figma `12:313/368/427/486/126/562/596/664/791/847/905/1042/1199/1340/1489` 为视觉真源，完成 Flutter 与 Android/iOS 原生登录、我的、积分充值和成功/失败页；原生返回一次退出整个登录路由，仅“其他手机号登陆”进入短信登录。支付返回类型化，充值成功/失败/取消/待确认分流已覆盖。未改动后端、管理后台、数据库及用户现有 `lib/global.dart` 本地地址。
- CHG-0029 已完成：`workType` 仅允许创建时确定，更新请求传入同值、异值或 `null` 均返回 `BAD_REQUEST(-400)` 且不产生数据写入；`SellerBusiness` 改为门面并通过注册表路由商品/探店六类提示词策略，人物提示词保持公共处理，单分镜任务固化场景。本次无数据库、Flutter 或 Web 管理后台改动。
- CHG-0028 实现中：探店视频复用视频带货完整生命周期，不新增工作流、状态、计费、审核、补偿或发布分支；新增 `workType`、图片角色、V3.4 增量迁移和场景化提示词。本次仅修改 Java 后端与 Web 管理后台；Flutter 移动端接入后续单独实施。端到端验证前 `STORE_VIDEO` 保持 `COMING_SOON`。
- CHG-0020 正在评审：视频积分改为“时长 × 每秒积分单价 × 清晰度倍率”，当前每秒 10 积分、720p 为 1.0 倍、1080p 为 1.5 倍；失败全额退款，重新生成再次计费。产品文档已完成，技术和代码待同步。
- CHG-0019 等待环境复核：V2.7 的 15 张表和全部字段注释已补齐；本次不改变业务逻辑、接口或数据库结构。
- CHG-0021～CHG-0026 从错误工作区别名 `catseller` 迁入并按恢复证据登记为 `done`，原实现轨迹版本 `v1.0.0/v1.0.1` 不覆盖当前研发版本。
- CHG-0027 从 legacy-0007 迁入，保留 `in_progress` 事实但明确 defer；必须等 CHG-0020 产品合同确认并同步技术方案后重新校准，当前不得据此继续编码。

---

## 5. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、工作空间、状态与门禁 |
| `.cursor/rules/13-Flutter编码索引.mdc` | Flutter 编码门禁、按模块加载和实现回写 |
| `.cursor/rules/14-Java编码索引.mdc` | Java 编码门禁、依赖顺序和实现回写 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/00-编码工作流程.mdc` | 工程任务基础上下文与本轮禁止提前编码边界 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/14-其他任务.mdc` | 纯文档任务验证要求 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/05-数据库与持久化.mdc` | 校验模块文档中的迁移、唯一约束和事务边界；本轮不执行迁移 |
| `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/07-新接口开发.mdc`、`08-鉴权与安全.mdc` | 校验 API、App 隔离、幂等、回调和敏感信息边界 |

当前已获用户编码授权；三端各自项目规则已检查，移动端 task-new_feature 强制引用的业务复用规则缺失。遵守项目 AGENTS 暂停业务代码修改；需补充或获授权修复该引用后继续，具体已读规则及最小恢复入口以 implementation-progress.md 为准。

---

## 6. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `01-需求/requirements.md`、`01-需求/figma-design-plan.md` | 当前业务、页面、Figma 与补充状态 | 是 |
| `02-技术方案/tech-plan.md` | T-F001～009、T-A001～007、T-B001～013 和依赖真源 | 是 |
| `02-技术方案/effort-estimate.md` | 已确认的 1 天代码、2 天本地验证排期 | 是 |
| `03-前端/flutter-tech.md` | Flutter API、页面、状态、安全和测试实现基线 | 是 |
| `04-后端/java-tech.md` | Java/Admin/Web 数据、接口、状态机、工猫和安全实现基线 | 是 |
| `03-前端/flutter-dev-plan.md`、`04-后端/java-dev-plan.md`、`04-后端/admin-web-dev-plan.md` | 已确认的 T-F/T-B/T-A 总体计划和模块拆分 | 是 |
| `change-plan.md` | CHG-0063～CHG-0066 当前影响范围与旧综合文档隔离说明 | 是 |
| `implementation-progress.md`、当前批次模块文档 | 用户编码授权、首批门禁、文件范围、验证与下一恢复点 | 是 |

---

## 7. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `CURRENT.md` | `done` | 已指向 17 份模块文档、隔离门禁和下一步 |
| `workflow.md` | `done` | 已记录 13/14 编码授权、缺失规则阻塞与恢复点，并保留其他 CHG 原状态 |
| `change-plan.md` | `in_progress` | CHG-0066/CHG-0065/CHG-0064/CHG-0063 继续处于当前功能评审链路，CHG-0020 和 CHG-0019 保持原状态 |
| `.cursor/rules/02-需求文档生成.mdc` | `done` | 已增加“有 Figma 时页面级直接嵌入设计稿”规则 |
| `01-需求/references/README.md` | `done` | 已登记 22 个节点、P09 Web 使用边界及多 App Admin 参考边界；后台暂无 Figma |
| `01-需求/references/images/invite-withdrawal/` | `done` | 22 张有效 PNG，已全部嵌入 PRD |
| `01-需求/requirements-list.md` | `done` | v1.0.3：多 App 邀请提现、活动规则 Web、共享工猫连接及现有 Admin 受控敏感查看 |
| `01-需求/requirements.md` | `done` | v1.0.3：11 节独立 PRD、8 个 App 原生页、1 个 Web 页、1 个多 App Admin 页面、3 个弹层 |
| `01-需求/detection-feedback.md` | `PASS / done` | v1.0.3 正式检测 PASS，用户已确认进入技术方案 |
| `01-需求/figma-design-plan.md` | `done` | 复核 22 张现成设计、Figma 未覆盖状态和 Admin 现有 UI 基线 |
| `02-技术方案/tech-plan.md` | `done` | 用户已确认 v1.0.0 架构、数据、接口、任务、安全、测试和发布方案 |
| `02-技术方案/effort-estimate.md` | `done` | v1.0.1 已确认：代码初稿 08-27、本地验证版本 08-28，共 2 个 AI 工作日 |
| `03-前端/flutter-tech.md` | `done` | 用户已确认 v1.0.0 独立 Flutter 技术文档 |
| `04-后端/java-tech.md` | `done` | 用户已确认 v1.0.0 独立 Java/Admin/Web 技术文档 |
| `03-前端/flutter-dev-plan.md` | `done` | v1.0.0，T-F001～T-F009 与 6 份模块文档清单 |
| `04-后端/java-dev-plan.md` | `done` | v1.0.0，T-B001～T-B013、API 与 7 份模块文档清单 |
| `04-后端/admin-web-dev-plan.md` | `done` | v1.0.0，独立 T-A001～T-A007 与 4 份模块文档清单 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/effort-estimate-v1.8-old-comprehensive.md` | `reference-only` | 旧视频/脚本/作品综合项目七天排期，禁止用于当前邀请提现实施 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/flutter-tech-old-comprehensive.md` | `reference-only` | 旧综合 Flutter 技术文档，禁止作为当前实现基线 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/java-tech-old-comprehensive.md` | `reference-only` | 旧综合 Java 技术文档，禁止作为当前实现基线 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/flutter-dev-plan-old-comprehensive.md` | `reference-only` | 旧综合 Flutter 总体计划，禁止作为当前实现基线 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/java-dev-plan-old-comprehensive.md` | `reference-only` | 旧综合 Java 总体计划，禁止作为当前实现基线 |
| `03-前端/开发计划/` | `done` | 6 份文档已确认，编码任务未开始 |
| `04-后端/开发计划/`（不含 admin） | `done` | 7 份文档已确认，编码任务未开始 |
| `04-后端/开发计划/admin/` | `done` | 4 份文档已确认，编码任务未开始 |
| `implementation-progress.md` | `blocked` | 三端依赖分批、规则缺失和基线测试记录 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/开发计划-old-comprehensive/` | `reference-only` | 13 份旧综合 Flutter 模块，原样可恢复 |
| `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/开发计划-old-comprehensive/` | `reference-only` | 10 份旧综合 Java 模块，原样可恢复 |

---

## 8. 上架就绪检查表（进入 17 阶段前必须全绿）

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 15 联调与测试 QA 通过 | ☐ | 尚未进入 |
| `change-plan.md` 进行中变更为空 | ☐ | CHG-0066、CHG-0065、CHG-0064、CHG-0063、CHG-0020、CHG-0019 仍为进行中；正式 QA 和打包前必须闭合或明确 defer |
| `change-log.md` 当前版本号已确定 | ☑ | `v0.1.18` |
| Android AAB / APK 已生成并测试 | ☐ | 尚未进入 |
| iOS IPA 已生成并 TestFlight 通过 | ☐ | 尚未进入 |
| 签名配置正常 | ☐ | 尚未进入 |
| 隐私政策已就绪 | ☐ | 人像与 AI 内容合规为重点 |
| 商店素材已就绪 | ☐ | 尚未进入 |
| 第三方 SDK 合规清单已声明 | ☐ | 尚未进入 |
| 国内商店备案/软著（如需要） | ☐ | 目标市场待确认 |

---

## 9. 额外注意事项

- 当前工作空间仍属于“喵喵带货”项目，但主路径 v1.0.3 需求定义的是多 App 共用能力；工作区归属和首个 Figma 参考不得被解释为后台/后端只服务 Catseller。
- 当前流程已进入 `13 Flutter + 14 Java/Admin/Web 编码`；17 份模块文档已确认，失效规则门禁已解除，基础与佣金资金批次已实现。既有代码、文档评审和基线测试通过不代表本轮升级已实现。
- 当前排期只使用已确认需求、Figma 设计基线和当前技术方案；旧 v1.8 七天综合排期已归档，不是本功能工时输入。
- 当前按 AI 纯执行速度估算：第 1 天集中完成 Java、Flutter、Admin/Web 全量代码初稿，第 2 天完成构建、自动化测试、数据库迁移校验、跨端回归和集中修复。真实工猫环境、人工确认与银行到账等待不占用 AI 工时。
- 本期仅支持银行卡；支付宝、微信和银行卡短信验证码不进入本版本。
- Figma 当前通道 `mj5kz8uv` 已复核的 22 张喵喵带货移动端 PNG 已导出并逐页嵌入 PRD；设计示例数据不得写死，其他 App 不直接照搬其品牌视觉。
- 首笔会员订单付款成功后等待后台按 App 配置的 N 天到期入账，默认 0；订单保留原规则快照，待结算退款减少净额/全额取消。最低提现额默认 1 元，按 App 动态调整，仅新申请适用。
- 设计稿 `43:3257` 的中央状态“申请已提交”是产品语义；页面不得用顶部示例标题误导用户认为资金已到账。
- 规则、法务、税务和协议文案在上线前需由产品、法务和财务确认。
- 现有 Admin 已有 App 切换、“邀请收益管理”及三个页签；技术方案必须遵循“已有复用、缺失新增、按 App 能力模式展示”，所有查询、配置、审核、对账和权限绑定 App Code，不得以 Catseller 名称硬编码。
- 活动规则由 `lxwx_admin/web/` 静态页面承载，参考现有隐私协议目录和发布方式；邀请等级进度按人数真实填充，“邀请好友/推广素材”为同一 P02 页面。
- 所有启用 App 共用平台级工猫连接；后台敏感查看是唯一允许返回数据库解密值的专用受控接口，技术实现前必须完成后端安全规则例外评审。

---

## 10. 阻塞项

失效规则引用已按用户授权修复；返佣取整、累计退款、N 天结算及最低额动态配置均已确认，无需再次等待这些选择。查询/绑定/页面、工猫/提现及余额预检切换工具已本地实现；剩余为真实工猫/设备验收、其他渠道退款与异常金额核对、生产权限/告警/容量和显式切换审批，不得据本地通过自动启用。CHG-0020、CHG-0019 等保持原状态并 defer.

---

## 11. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 项目建档 | `CURRENT.md`、`workflow.md`、`change-plan.md`、`change-log.md` | `done` | 新建喵喵带货工作空间 |
| 原始材料归档 | `01-需求/references/` | `done` | 10 张页面图已复制并建立索引 |
| 需求分析 | `01-需求/requirements-list.md` | `done` | 基于用户明确生成 PRD 的指令确认本轮素材范围 |
| CHG-0001 需求修订 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md` | `done` | 三个一级页面、统一作品预览、分镜图片确认和状态恢复流程已合入 |
| CHG-0002 “我的”页修订 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md` | `done` | 保留会员/积分/任务/订单/兑换码，移除作品资产统计并登记跨项目参考 |
| CHG-0003 视频模型与 UI 清册修订 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md` | `done` | 取消独立配音，校准 4/23/19/26 清册，并用当前 Flutter 代码完成“我的”页及下级业务终审 |
| CHG-0004 产品决策收口 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md` | `done` | 固化 P0/P1/P2 决策，移除任务取消/通知链路，校准 4/23/19/25 清册并收敛为产品文档 |
| CHG-0005 检测问题修订 | `01-需求/requirements-list.md`、`01-需求/requirements.md`、`01-需求/references/README.md`、`01-需求/detection-feedback.md` | `done` | P08～P19 复用豁免、P06 草稿/隐藏、P05 无筛选、P20 案例列表，第二轮检测 PASS |
| CHG-0006 作品五阶段修订 | 需求清单、PRD、素材索引、检测反馈、技术方案 | `done` | 首图建草稿、内容统一生成、编辑脚本、视频生成、视频完成及作品页按状态恢复，第三轮检测 PASS |
| CHG-0007 技术方案表达修订 | 技术方案、工作流和变更记录 | `done` | AI 水印改由前端处理；T-F/T-A/T-B 按功能、页面、弹框和业务结果重写，编号不变 |
| CHG-0008 截图式任务名称修订 | 技术方案、工作流和变更记录 | `done` | 名称列改为短业务名，页面/弹框与处理说明拆列，任务编号不变 |
| CHG-0009 工时与排期修订 | 工时评估、工作流和变更记录 | `done` | 改为 AI 辅助 10 小时口径；增加 UI 开工门禁、角色排期和延期规则 |
| CHG-0010 两周并行排期 | 工时评估、工作流和变更记录 | `done` | UI/Flutter/Java 明日同启，UI 分批交图，D1～D10 容量倒排至内部验收包 |
| CHG-0011 连续七天排期 | 工时评估、工作流和变更记录 | `done` | 首页 UI 已完成；工时仅保留天数；D1～D7 连续实施至内部验收包 |
| CHG-0012 UI 页面名称修订 | 工时评估、工作流和变更记录 | `done` | UI 交图表移除 P/D/T-F 编号和页面内元素，一个页面只保留一个名称 |
| CHG-0013 排期业务化表达 | 工时评估、工作流和变更记录 | `done` | 工时和七天排期移除研发编号，按 UI、移动端、运营后台和 Java 后端直接描述；删除正文版本历史 |
| CHG-0014 周日休息顺延 | 工时评估、工作流和变更记录 | `done` | 07-26 不安排工作，后续整体顺延；UI 07-27 定稿，内部验收包 07-29 交付 |
| CHG-0015 更多案例最后开发 | 工时评估、工作流和变更记录 | `done` | 更多案例从 07-23 移至 07-27 最后一个功能开发日，工时与验收时间不变 |
| CHG-0016 五个项目里程碑 | 工时评估、工作流和变更记录 | `done` | 用基础 App、脚本与分镜、视频与作品、复用功能、整体 App 五个里程碑替换每日检查点 |
| CHG-0017 技术文档移除工时 | 技术方案、前后端技术文档、总体计划、模块文档、工作流和变更记录 | `done` | 技术文档只保留功能、依赖、实现与验收；工时和日期仅在独立排期文档维护 |
| CHG-0018 参考 SongWorkflow | 技术方案、Java 技术文档、前后端任务模块文档、工作流和变更记录 | `done` | 带货生成任务采用任务主表、固定步骤、PAUSED、事件与补偿模式，保持 catseller 领域隔离 |
| 05 技术方案 v1.3 | `02-技术方案/tech-plan.md` | `done` | 用户确认截图式短业务任务表并要求进入下一步 |
| 旧综合工作时长评估 v1.8 | `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/effort-estimate-v1.8-old-comprehensive.md` | `reference-only` | 旧视频/脚本/作品七天排期，已从当前主路径移出，不是邀请提现基线 |
| 旧综合 Flutter 技术文档 v1.0 | `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/flutter-tech-old-comprehensive.md` | `reference-only` | 原视频/作品等综合技术文档，已从当前主路径移出 |
| 旧综合 Java 技术文档 v1.0 | `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/java-tech-old-comprehensive.md` | `reference-only` | 原 Catseller 全量业务技术文档，已从当前主路径移出 |
| 当前邀请提现 Flutter 技术文档 v1.0.0 | `03-前端/flutter-tech.md` | `done` | 用户已确认；只覆盖邀请、佣金、实名电签、银行卡与提现移动端增量 |
| 当前邀请提现 Java 技术文档 v1.0.0 | `04-后端/java-tech.md` | `done` | 用户已确认；覆盖共享后端、工猫、资金状态机、现有 Admin 与活动规则 Web 增量 |
| 旧综合 Flutter 总体计划 v1.0 | `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/flutter-dev-plan-old-comprehensive.md` | `reference-only` | 原视频/作品等总体计划，已从当前主路径移出 |
| 旧综合 Java 总体计划 v1.0 | `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/java-dev-plan-old-comprehensive.md` | `reference-only` | 原 Catseller 全量后端总体计划，已从当前主路径移出 |
| 当前邀请提现 Flutter 总体计划 v1.0.0 | `03-前端/flutter-dev-plan.md` | `done` | T-F001～T-F009 与 6 份模块文档清单 |
| 当前邀请提现 Java 总体计划 v1.0.0 | `04-后端/java-dev-plan.md` | `done` | T-B001～T-B013、API 与 7 份模块文档清单 |
| 当前邀请提现 Admin/Web 总体计划 v1.0.0 | `04-后端/admin-web-dev-plan.md` | `done` | 独立 T-A001～T-A007 与 4 份模块文档清单 |
| 旧综合流程 Figma 计划 | 无文件 | `skipped` | 2026-07-21 的历史决定；已被当前 `01-需求/figma-design-plan.md` 设计基线取代，不作为当前门禁 |
| 当前邀请提现 Figma 计划 | `01-需求/figma-design-plan.md` | `done` | 22 张现成设计、PRD 补充状态和现有 Admin UI 基线已复核 |

---

## 12. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-08-27 | 13/14 三端编码入口 | 用户确认 17 份模块文档并要求依次编码；检查三端规则、工程、dirty worktree、邀请接口与迁移清单；后端基线 `./gradlew test --console=plain` 通过 | `blocked`：移动端必读业务复用规则缺失；仅回写授权、文档评审和恢复点，未修改业务代码或数据库 |
| 2026-08-27 | CHG-0068 首批三端编码 | 按用户继续授权修复规则引用；完成 Java 能力/迁移/规则权限、Admin 能力/规则与 Flutter 枚举/金额；新 Figma 22 图复核一致 | 基础代码本地可评审；Java/后台/新 App 测试通过，App 全量 11 项非邀请失败；无生产数据库、部署、工猫操作；下一步金额口径待确认 |
| 2026-08-27 | 11/12 三端模块开发文档 | 用户确认三份总体计划；归档 13 份 Flutter 与 10 份 Java 旧综合模块，生成当前 6+7+4 共 17 份模块文档；复核 22 张图片，统一表名、错误码、分页和退款提交前复核口径 | `waiting_review`；未修改 Flutter、Java、Admin、Web 或数据库代码 |
| 2026-08-27 | 11/12 文档校验 | 检查 27 份当前相关文档、17 份模块、29 个总体任务覆盖、124 个本地链接、22 张 PNG 引用、章节/状态/围栏与新增空白；核对旧 23 份模块和两份总体计划归档摘要；执行两工作区 `git diff --check` 与路径守卫 `audit` | 通过；保留既有技术方案标题的 6 处 Markdown 硬换行。仅验证文档，未运行或宣称通过业务代码测试 |
| 2026-08-27 | 09/10 三端总体开发计划 / v1.0.0 | 用户通过“继续下一步”确认 Flutter/Java 技术文档；归档旧综合总体计划，生成 T-F001～T-F009 和 T-B001～T-B013 当前计划；根据用户补充要求新增独立 T-A001～T-A007 Admin/Web 计划；统一 capability 为 `DIRECT_BANK_GONGMALL` | `waiting_review`；三份计划只覆盖邀请好友与银行卡提现，未修改 Flutter、Java、Admin、Web 或数据库代码 |
| 2026-08-27 | 07/08 前后端技术文档 / v1.0.0 | 用户通过“继续下一步”确认 AI 排期；复核 catseller InviteAPI/路由/页面、Java 邀请/支付结算/Admin 接口和现有 Admin 三页签；归档旧综合技术文档，生成独立 Flutter 与 Java/Admin/Web 技术文档 | `waiting_review`；工时评估已 `done`，两份技术文档只覆盖邀请好友与银行卡提现，未修改业务代码或数据库 |
| 2026-08-26 | 06 工作时长评估 / v1.0.1 | 用户指出旧 12 天口径不符合 AI 真实写代码速度；将排期纠正为纯执行时间：首日完成 Java、Flutter、Admin/Web 代码初稿，次日完成构建、自动化测试、迁移校验和集中修复，外部等待单列 | `waiting_review`；计划 08-27 完成代码初稿、08-28 形成本地验证版本，未修改 Flutter、Java、Admin、Web 或数据库代码 |
| 2026-08-26 | 05 技术方案计划 / v1.0.0 | 用户确认进入技术方案；复核 Flutter、Java、Admin/Web、common/platform Flyway 和工猫协议基线；生成 Figma 设计计划与独立技术方案，设计多 App 双模式、资金账本、状态机、回调查单、敏感查看和任务拆解 | `done`；用户已通过“下一步，评估工时”确认，未修改 Flutter、Java、Admin、Web 或数据库代码 |
| 2026-08-26 | 03 需求文档检测 / v1.0.3 | 对照独立需求清单、11 节 PRD、22 张 Figma、素材索引、现有 Admin 基线、工猫官方协议和全部用户反馈执行正式检测 | `PASS / done`；用户已通过生成技术方案指令确认，随后完成 Figma 设计输入复核 |
| 2026-08-26 | CHG-0066 邀请页交互、活动规则 Web 化与敏感查看 | 将需求升级为 v1.0.3；补充人数真实进度、P01 明确跳转、P02 单页；P09 改为参考隐私协议的 Admin/Web 静态页；工猫连接改为平台共用；A01 增加查看密码、原因、短时数据库解密、锁定和审计 | `waiting_review`，11 节、10 个页面模板和 22 张图片保持；未修改 Flutter、Java、Admin 或数据库 |
| 2026-08-26 | CHG-0065 邀请返佣与提现多 App 共用 | 将需求升级为 v1.0.2；保留喵喵带货移动端 Figma，后台复用现有 App 切换与 InvitePage；补充按 App Code 启用、配置、数据路由、Provider、回调、任务、权限、审计和隔离验收 | `waiting_review`，共享能力不得 Catseller 硬编码；启用 App 使用统一新模式，未启用 App 不被隐式迁移；未修改 Flutter、Java、Admin 或数据库 |
| 2026-08-26 | CHG-0064 现有邀请收益后台升级需求 | 只读核对 `/Users/soul/code/lxwx/lxwx_admin` 的现有导航和 `InvitePage` 三个页签；将需求升级为 v1.0.1，增加 A01 页面、后台流程、现状复用/差异、权限、审核、主动对账、配置版本和验收 | `waiting_review`，已有功能复用、缺失功能新增、冲突能力仅对 Catseller 调整；后台暂无 Figma 已明确；未修改 Flutter、Java、Admin 或数据库 |
| 2026-08-26 | CHG-0063 邀请好友与银行卡提现独立 PRD | 读取 Figma 新通道 `czmwv14c`；归档旧 v0.2.0 综合需求；重建只含邀请与银行卡提现的 v1.0.0 需求清单和 11 节 PRD；导出 22 张设计图并逐页嵌入；更新需求文档生成规则和当前执行入口 | `waiting_review`，当前主需求与旧综合需求已隔离；本轮未修改 Flutter、Java、Admin 或数据库 |
| 2026-08-26 | CHG-0062 邀请返佣与工猫银行卡提现 PRD | 归档 v0.1.7；将需求清单和 PRD 升级为 v0.2.0；补齐主流程、10 个页面级章节、17 个 Figma 节点映射、前后端/Admin 职责、接口能力合同、工猫状态与安全边界；工作流回退到需求评审 | `waiting_review`，本轮未修改 Flutter、Java、Admin 或数据库；Figma 通道可加入但节点读取/导出持续超时，PNG 待插件恢复后补导出 |
| 2026-08-25 | CHG-0061 案例保存作品类型 | 新增 V4.4 案例类型快照迁移；后端统一保存和返回 `workType`；Admin 增加列表类型、来源只读和手工选择；Flutter 补明确类型优先的契约回归 | `done`，后端全量测试、Admin 全量 141 项、两端 `flutter analyze` 与移动端定向测试通过；数据库不固化枚举集合，分类标签问题不在范围 |
| 2026-08-25 | CHG-0060 移除友盟统计 SDK | 删除 Flutter 依赖、统计服务、AppKey/渠道逻辑及测试；删除 Android 预初始化、合规桥接、集成测试和构建配置；删除 iOS UMCommon 源码、Xcode/Pod 配置与锁定，并同步 README 和 Flutter 计划文档 | `done`，依赖树与双端产物无友盟符号；`flutter analyze`、15 项定向测试、Android Debug APK 与 iOS Simulator 构建通过；组合 Widget 117 项通过、5 项既有无关失败 |
| 2026-08-25 | CHG-0059 ResourceService 基础启动初始化 | 在本地存储初始化后准备媒体缓存并永久注册；从隐私保护服务初始化、就绪判断和撤回释放中移除，保留设备审计、登录、支付、一键登录、分享、更新与统计门禁；同步 Flutter 技术文档、基础模块、首页案例模块和开发计划 | `done`，隐私/作品门禁 8 项、首页案例 9 项、资源服务 7 项与 `flutter analyze` 通过；未改接口、后端、Admin、数据库或原生配置，Android/iOS 冷启动真实播放待总体 QA 执行 |
| 2026-08-21 | CHG-0053 iOS 首次联网授权后自动重载首页 | 保持启动即请求；iOS 首次失败先进入 500ms 隐藏宽限期，授权弹窗期间持续 loading，`inactive → resumed` 后延迟 300ms 静默重试一次；补齐显隐、时序竞态、平台和失败回退测试及 `HOME-011` | `done`，新增 8 项、首页案例 9 项、隐私流程 5 项与 `flutter analyze` 通过；全量 178 项通过、11 项既有无关失败；总体 QA 保持 `waiting_review`，未改 Android、catsinger、后端、Admin、数据库或接口 |
| 2026-08-21 | CHG-0052 商品/产品分析图片 10 MiB 限制 | 在统一分析素材图入口于状态变更和网络链路前校验文件大小；超限保留原槽位，新增边界测试与 `CREATE-014` | `done`，定向 11 项与 `flutter analyze` 通过；全量 170 项通过、11 项既有无关失败；总体 QA 保持 `waiting_review`，未改模特图、参考视频、后端、Admin、数据库或接口 |
| 2026-08-21 | CHG-0051 iOS 一键登录号码居中与底部留白 | 原生号码 frame 改用 SDK 实际宽度计算水平中心，协议区底部约束由 10 增至 24 个设计像素；保留中间控件、视觉资源和登录行为 | `done`，2 项登录回归、`flutter analyze`、iOS Simulator 构建及 iPhone 14 Pro 真机授权页同屏 QA 通过；未提交登录，未改 Android、后端、Admin 或数据库 |
| 2026-08-21 | CHG-0050 iOS 主动恢复购买入口移除 | 从登录、会员开通和设置三个 iOS 页面移除恢复购买按钮，清理页面级状态与处理方法；保留 StoreKit 监听、未完成交易自动补单和底层恢复服务 | `done`，3 项入口回归、8 项 Apple IAP 专项及 `flutter analyze` 通过；全量 155/166 通过，11 项现有无关基线失败；未改 Android、后端、Admin、数据库或原生配置 |
| 2026-08-19 | 15 移动端全量手工回归用例 | 生成并修订 Android 优先、iOS 差异回归的 QA 计划与详细 P0～P2 用例；Android 明确无游客账号，只测手机号/一键登录，iOS 单独覆盖游客创建、恢复、绑定和门禁；其余覆盖启动隐私、首页案例、三种创作、脚本视频、积分支付、作品、导出、公共页、弱网恢复和兼容安全 | `waiting_review / not_run`，只完成文档编制和平台边界修订，未执行测试或预填通过结论；CHG-0020 精确计费用例保持 BLOCKED，CHG-0019 仍为门禁；未修改 Flutter、Java、Admin、数据库或接口 |
| 2026-08-14 | CHG-0048 充值成功页重试入口移除 | 成功态只保留铺满底部可用宽度的“返回页面”，不再渲染“重新支付”；失败态仍可“重新充值” | `done`，定向 Widget 回归和 `flutter analyze` 通过；支付结算与路由分流未改 |
| 2026-08-14 | CHG-0047 首页案例预览播放 | 透传 `caseId / videoResourceId / videoUrl`，播放前按资源 ID 换签并缓存为本地文件；旧 URL 兼容兜底，保留播放/暂停、重播、失败重试和生命周期释放；右下角复用作品详情“AI生成”标识 | `in_progress`，案例与资源服务 16 项测试、`flutter analyze` 与差异检查通过；待 Android/iOS 真机播放验收 |
| 2026-08-14 | CHG-0046 填写页智能时长入口隐藏 | 在参数设置组件增加展示层开关，不再把“智能时长”芯片加入视频时长选项列表 | `done`，仅隐藏入口，AUTO 配置、草稿恢复和请求逻辑保留；`flutter analyze` 与 3 项专项测试通过 |
| 2026-08-13 | CHG-0045 iOS 登录三入口调整 | 登录首页固定展示“游客登录 / 手机号登录”，后台预检成功后显示“一键登录”，取消自动拉起；用户点击才打开运营商授权页，取消后可再次点击，切换手机号进短信页；撤销原生授权页重复的游客按钮和 `guest_login` 结果 | `waiting_review`，iOS 三入口 5 项与含 Android 自动流程的登录回归 8 项通过，`flutter analyze`、iOS Simulator 构建及差异检查通过；Android、后端、数据库、Admin、游客积分和购买恢复逻辑未改，待带 SIM iPhone 真机验证 |
| 2026-08-12 | CHG-0045 iOS 游客账号与订阅恢复 | 实现共享后端游客会话/绑定/Apple 恢复；catseller 接入 Keychain 凭证、账号类型、真实会话门禁、游客生成购买链路和主动恢复入口；统一所有新用户创建时发放一次 30 积分 | `waiting_review`，游客创建/恢复/绑定积分专项通过，绑定手机号不重复发放；Flutter 游客专项、静态分析、路由门禁定向测试和 iOS Simulator 构建通过，待 StoreKit Sandbox 与带货全链路真机验收 |
| 2026-07-20 | 工作空间定位 | 检查现有项目和 `.cursor/rules`，确认需新建“喵喵带货” | 完成 |
| 2026-07-20 | 01 需求分析 | 归档 10 张页面图并生成素材索引、需求清单 | `done` |
| 2026-07-20 | 02 需求文档生成 | 生成包含页面、流程、规则、交互、状态和验收标准的 PRD | `waiting_review` |
| 2026-07-20 | CHG-0001 评审修订 | 按用户反馈调整一级导航、统一作品入口、脚本/分镜图/合成流程和失败恢复 | `done`，PRD 等待用户复审 |
| 2026-07-20 | CHG-0002 评审修订 | 参考喵喵写歌细化“我的”页；按用户澄清保留会员/积分/任务/订单/兑换码并移除资产统计 | `done`，PRD 等待用户复审 |
| 2026-07-20 | CHG-0003 评审修订 | 改为视频模型生成；补充 UI 页面/弹框清册与参考图；只读审阅当前 Flutter 代码并据此重写“我的”页 | `done`，v0.1.3 PRD 等待用户复审 |
| 2026-07-21 | CHG-0003 代码级终审 | 补齐推广素材页、版本/权限覆盖层、隐私与支付计数边界、登录/充值/游客状态；复核 4/23/19/26 清册 | `done`，需求文档保持 `waiting_review` |
| 2026-07-21 | CHG-0004 产品决策收口 | 固化用户 P0/P1/P2 决策；移除任务取消与通知；加入按分镜图计积分、7/30 保留、阿里审核和 AI 水印；PRD 移除实现细节 | `done`，v0.1.4 PRD 等待用户复审 |
| 2026-07-21 | 03 需求文档检测 | 对照 PRD、需求清单、10 张原图、历史 CHG 和“我的”页当前代码；检查结构、清册、流程、状态和反馈闭环 | `waiting_review`，首轮结论 FAIL，详见 `01-需求/detection-feedback.md` |
| 2026-07-21 | CHG-0005 检测问题修订 | 按用户口径收敛复用页、补齐 P06、移除作品筛选并新增 P20；同步清册、素材索引和产品规则 | `done`，v0.1.5 基线为 4/23/20/25 |
| 2026-07-21 | 03 需求文档第二轮检测 | 检查页面 ID、弹层 ID、复用范围、P06 状态、P05/P20 无筛选、访问门禁和图片引用 | `waiting_review`，最新结论 PASS，等待进入 Figma 计划确认 |
| 2026-07-21 | 04 Figma 设计稿计划 | 用户明确要求跳过 Figma，保留 PRD 第 3.9/5 节和原始图为 UI 真源 | `skipped`，未生成 figma-design-plan.md |
| 2026-07-21 | 05 技术方案计划 | 深读 PRD，核对 Flutter/Java/Admin 真实工程；生成作品聚合、状态机、版本、异步任务、计费、审核、水印和清理方案 | `waiting_review`，详见 `02-技术方案/tech-plan.md` |
| 2026-07-21 | CHG-0006 作品流程修订 | 按用户口径改为首图建草稿和五个作品主阶段；补齐视频完成态，按作品状态恢复对应业务，并同步技术方案 | `done`，v0.1.6 第三轮检测 PASS，等待用户确认 |
| 2026-07-21 | 03 需求文档第三轮确认 | 用户确认 v0.1.6 作品五阶段需求基线，流程恢复到已同步的技术方案 v1.1 | `done`，进入 `05 技术方案计划` 等待评审 |
| 2026-07-21 | CHG-0007 技术方案修订 | AI 水印改由移动端前端处理；保留任务编号，按功能、页面、弹框和业务结果重写移动端、后台与后端任务 | `done`，技术方案 v1.2 待用户评审 |
| 2026-07-21 | CHG-0008 任务名称修订 | 参考 UI 映射表，把任务名称改为“首页、填写信息、编辑脚本、视频生成”等短业务名，并将页面、弹框和处理说明拆列 | `done`，技术方案 v1.3 待用户评审 |
| 2026-07-21 | 05 技术方案确认 | 用户要求继续下一步，技术方案 v1.3 作为当前技术基线 | `done`，进入 06 工作时长评估 |
| 2026-07-21 | 06 工作时长评估 v1.0 | 按 2 Flutter、2 Java、1 QA 和 6 小时人天生成首版三点估计 | `done`，已由 CHG-0009 的 v1.1 取代，关键数据保留在版本历史 |
| 2026-07-21 | CHG-0009 工时与排期修订 | 改为 AI 辅助、10 小时人天；新增 1 名 UI、前端开工门禁、分角色日期排期、甘特图和延期规则 | `done`，工时评估 v1.1 待用户评审 |
| 2026-07-21 | CHG-0010 两周并行排期 | 用户明确 UI 已开做首页，UI/Flutter/Java 明日同启；改为 UI 分批交图和十个工作日容量倒排 | `done`，工时评估 v1.2 待用户评审 |
| 2026-07-21 | CHG-0011 连续七天排期 | 首页 UI 标记完成；删除 O/M/P/E；工时单位天；按 7 月 22～28 日连续七天重排 | `done`，工时评估 v1.3 待用户评审 |
| 2026-07-21 | CHG-0012 UI 页面名称修订 | UI 交图表只写页面名称；移除内部编号和图片上传、预览等页面内元素的独立展示 | `done`，工时评估 v1.4 待用户评审 |
| 2026-07-21 | CHG-0013 排期业务化表达 | 删除工时和每日排期中的研发编号，改用页面与业务名称；删除工时正文版本历史 | `done`，工时评估 v1.5 待用户评审 |
| 2026-07-21 | CHG-0014 周日休息顺延 | 07-26 周日不安排工作；原后续工作整体顺延一天，最终验收改为 07-29 | `done`，工时评估 v1.6 待用户评审 |
| 2026-07-21 | CHG-0015 更多案例最后开发 | 更多案例 UI 和移动端功能从 07-23 移至 07-27，排在其他主要功能之后 | `done`，工时评估 v1.7 待用户评审 |
| 2026-07-21 | CHG-0016 五个项目里程碑 | 按用户给出的五个业务结果重写验收节点，并删除重复的每日检查点 | `done`，工时评估 v1.8 待用户评审 |
| 2026-07-21 | 06 工作时长评估确认 | 用户要求进入下一步，v1.8 作为七个工作日实施基线 | `done`，进入 07/08 技术文档阶段 |
| 2026-07-21 | 07 Flutter 技术文档 | 读取 catseller 真实依赖、启动、路由、三 Tab、公共账户能力和残留写歌页面；生成并确认移动端技术文档 | `done`，详见 `03-前端/flutter-tech.md` |
| 2026-07-21 | 08 Java 技术文档 | 读取现有多 App schema、公共积分/资源/审核/AI Provider 和后台 App 切换；生成并确认后端技术文档 | `done`，详见 `04-后端/java-tech.md` |
| 2026-07-21 | 旧 09 Flutter 总体开发计划 | 按视频/作品等综合业务生成的历史 Flutter 总体计划 | `reference-only`，已移至 `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/03-前端/flutter-dev-plan-old-comprehensive.md` |
| 2026-07-21 | 旧 10 Java 总体开发计划 | 按 Catseller 全量综合业务生成的历史 Java 总体计划 | `reference-only`，已移至 `archive/CHG-0063-focused-invite-withdrawal-prd-20260826/04-后端/java-dev-plan-old-comprehensive.md` |
| 2026-07-21 | 11 Flutter 全部模块文档 | 基于需求原图、PRD 和 catseller 真实代码，完成 11 份 Flutter 编码级模块文档 | `waiting_review`，统一评审后进入 Flutter 开发 |
| 2026-07-21 | 12 Java 全部模块文档 | 基于 PRD、接口清单及 Java 后端真实结构，完成 10 份 Java 编码级模块文档 | `waiting_review`，统一评审后进入 Java 开发 |
| 2026-07-21 | CHG-0017 技术文档移除工时 | 从技术方案、前后端技术文档、总体计划和全部模块文档中移除工时及日期排期 | `done`，排期仍由 `02-技术方案/effort-estimate.md` 单独维护 |
| 2026-07-21 | 14 Java 00～09 编码 | 完成 catseller V2.7、业务接口、独立工作流、计费审核、生命周期、后台和公共复用 | `done` |
| 2026-07-21 | Java 全量验收 | 新增 catseller 集成测试，修复既有 44 条失败基线；完成 H2、PostgreSQL 15 迁移、全量测试、构建和差异检查 | `done`，流程停在前后端联调与验收 |
| 2026-07-21 | CHG-0018 参考 SongWorkflow | 核对 Java 真实 `app/catsinger/songworkflow`，将任务创建、步骤实例、调度、暂停、事件和补偿模式写入带货技术文档 | `done`，只复用模式，不复用歌曲领域对象或数据表 |
| 2026-07-22 | CHG-0019 数据库注释修正 | 按 lxwxservice 工程版 `05-数据库与持久化.mdc` 为 V2.7 的 15 张表和 211 个字段补注释，并增加全量注释检查 | `in_progress`，H2 与 catseller 相关 15 条测试通过；等待 PostgreSQL 实库和当前全量外部联调测试环境恢复 |
| 2026-07-23 | CHG-0020 视频流程与积分规则 | 新增视频带货整体业务流程文档；积分改为时长 × 每秒单价 × 清晰度倍率；失败全额退款，重新生成再次计费 | `waiting_review`，产品文档已完成，技术与代码待同步 |
| 2026-07-31 | 工作区路径恢复 | 将错误工作区别名 catseller 原样归档并安全合并 | CHG-0021～CHG-0027 已重编号迁入；CHG-0020 产品评审主线保持不变，CHG-0027 明确 defer |
| 2026-08-06 | CHG-0029 多场景提示词架构 | Java 更新契约移除并严格拒绝 `workType`，拆分商品/探店六类提示词策略，固化单分镜场景并补测试 | `done`，`./gradlew test`、OpenAPI、`git diff --check` 与工作区路径审计通过；无数据库、Flutter 或 Web 改动 |
| 2026-08-07 | CHG-0031 账户关联页 Figma 对稿 | 修改积分详情、订单列表和意见反馈 UI，补 Android 真机夹具、组件测试和四组同屏对比 | `done`，109 项 Flutter 测试、静态分析、Android 构建、V1981A 真机截图与路径审计通过；本轮不处理 iOS |
| 2026-08-07 | CHG-0032 版本检查缺失配置降级 | 缺失版本策略时返回本地 disabled 结果，并增加服务层与手动检查提示回归用例 | `done`，不再暴露“配置不存在”，手动检查提示“已是最新版本” |
| 2026-08-08 | CHG-0033 会员页小屏结构适配 | 将会员页拆分为透明 AppBar、可滚动正文和固定安全区购买底栏，并补普通页面 UI 骨架规则与短屏 Widget 回归 | `done`，`flutter analyze`、112 项 Flutter 测试、差异检查和路径审计通过；业务接口、支付/IAP、路由和 Controller 保持不变 |
| 2026-08-08 | CHG-0034 隐藏微信支付入口 | 会员开通和积分充值页仅保留当前已开放渠道，Android/Web 默认选中支付宝，iOS 保持 App Store 支付 | `done`，微信支付入口页面回归通过；未修改后端、数据库或微信支付底层能力 |
| 2026-08-08 | CHG-0035 会员与积分充值页面二次适配 | 协议区调整为 12sp/20px 并补齐法务入口；积分充值页改为真实 AppBar、可滚动正文和固定安全区底栏；不可用渠道增加选择防御 | `done`，Figma `23:232/23:356` 同屏 QA 与 20 项支付回归通过；全量 115 项中 3 个既有首页旧文案断言失败，未推进其他任务状态 |
| 2026-08-08 | CHG-0036 Android 一键登录协议修复 | 原生授权页增加用户协议和隐私政策，未勾选改为静态提示并修复 SDK 协议 WebView 主题 | `done`，V1981A Android 12 三协议展示、两个应用协议页面和未勾选提示验证通过；112/115 项 Flutter 测试通过，3 项既有首页旧文案断言失败 |
| 2026-08-08 | CHG-0037 正式服法务地址修正 | 用户、隐私、会员、退款四个法务入口改用 catseller 正式站直达文件，算法备案切换至 miaomiao-commerce 正式页面 | `done`，正式地址 HTTP 与页面标题核对通过；定向测试、`flutter analyze`、差异检查和路径审计通过 |
| 2026-08-08 | CHG-0038 推广素材 Figma 对稿 | “我的 > 邀请好友”直达推广素材，页面切换为白底粉色体系并替换为 Figma AI 带货视频真源海报 | `done`，推广素材 3 项定向回归、Android QA 构建、V1981A 真机截图和 Figma `25:612` 同屏对比通过 |
| 2026-08-08 | CHG-0039 登录全屏背景修复 | 从 Figma `12:313` 合成登录全屏背景，Flutter 通过 `CustomScaffold.backgroundImage` 加载，Android/iOS 原生一键登录同步使用；Android 授权页启用沉浸式状态栏 | `done`，`flutter analyze`、7 项登录定向回归、双端构建通过；V1981A 已验证背景覆盖状态栏且未勾选提示正常 |
| 2026-08-08 | CHG-0040 推广素材复制链接修复 | 对照喵喵写歌邀请落地页规则，将 catseller 空地址、旧地址及跨产品地址统一修正为 `miaomiao-commerce` 正式注册链接，复制按钮与海报二维码共用结果 | `done`，7 项定向回归、`flutter analyze`、差异检查和路径审计通过；全量 114 项通过、4 项既有无关断言失败；未推进无关任务状态 |
| 2026-08-10 | CHG-0041 六个月访问审计留存 | Java 增加独立 JSON 访问审计日志和 190 天滚动归档；Flutter 在隐私同意后补充匿名设备审计请求头，撤回后清除 | `done`，Java 全量测试、Flutter 静态分析和 4 项定向测试通过；Flutter 全量 114 项通过、5 项既有 Widget 断言失败；无数据库变更，未推进无关任务状态 |
| 2026-08-12 | Flutter 编译回归修复 | 清理重复依赖与重复模型定义，统一智能时长和资源查重的类型化契约，恢复填写页 Controller 与参数组件状态一致性 | `done`，`flutter analyze` 通过，时长/资源定向测试 13 项通过；全量 120 项通过、5 项既有 Widget 断言失败，未改变业务范围或任务状态 |


## 普通页面结构与 Controller 增量记录（2026-08-27）

用户另行批准全 App 普通页面结构整理，实施记录见 [普通页面结构与 Controller 统一整理](03-前端/开发计划/page-structure-controller-refactor.md)。公共骨架、页面 Controller 生命周期、导航/正文/底栏分区与适配已完成；分析通过，完整测试 280 通过、5 项既有失败（客服 URL 旧断言、4 份详情 Golden 基准缺失），未批量更新 Golden。26 组前后截图已归档，真实设备与授权/支付/银行链路仍待验收。

这是独立增量记录，不推进邀请提现原有任务状态；当前主流程和业务待验收状态继续保持 `waiting_review`，不自动部署、迁移或启用资金。

## 佣金明细好友手机号增量（2026-09-02）

用户明确要求后端保持多 App 共享、不添加 Catseller 限制，App 端只修改喵喵带货。共享 `/api/invite/earnings/ledgers` 已增量返回当前 App schema 中来源好友的 `sourcePhoneMasked`；按页批量查询，不跨库、不返回完整手机号、不改数据库。Catseller P04 按 Figma `43:2285` 显示“脱敏手机号 · 短日期”，空值只显示日期；其他 App 客户端未改。

验证：后端邀请集成 64 项、Catseller 邀请页面 41 项和静态分析通过。后端全量 1088 项中 1080 通过、7 项无关歌曲生命周期测试因 JVM OOM 失败、1 项跳过；该无关类单独 7 项通过。375×812 Golden 与 Figma 同轮复核通过。本轮未部署、未进行线上接口或真机验收，不改变其他邀请提现 `waiting_review` 状态。

## 邀请记录好友手机号增量（2026-09-02）

用户截图确认 P03“邀请记录”仍显示后端占位文案“好友7”。共享 `/api/invite/records` 已增量返回当前 App schema 内受邀好友的 `inviteePhoneMasked`，按页批量查询并复用统一脱敏逻辑；不跨库、不返回完整手机号、不增加任何 App 条件分支。Catseller P03 优先显示带分组空格的脱敏手机号，空值继续显示 `inviteeName`，其他 App 客户端未改。

验证：后端邀请集成 69 项、Catseller 邀请页面 48 项、`flutter analyze --no-pub` 通过；375×812 Golden 与 Figma `43:2222` 同轮复核通过。后端完整测试因无关歌曲生命周期类 JVM OOM 且测试 XML 写出失败而未全绿，该类单独 7 项通过。数据库改动：无；未部署、未进行线上接口或真机验收，不改变其他邀请提现 `waiting_review` 状态。

## catseller 邀请链接增量记录（2026-08-28）

后端 `PublicUrlService` 已补齐 catseller 的 `/miaomiao-commerce/invite/register.html` 与 `download.html` 路径，沿用既有域名、编码和参数生成。未开放 catseller 歌曲分享，未改变其他 App 或直邀模式后台下载地址的语义。实施与验收记录见 [Java 用户接口模块](04-后端/开发计划/03-invite-user-api-withdrawal.md#catseller-邀请链接修复记录2026-08-28)。

修复前新增回归用例复现 8 项空链接失败，修复后 18 项定向测试全部通过；完整后端测试 1316 项通过、3 项既有跳过、0 失败，`git diff --check` 通过。数据库改动：无；未修改 App 页面、后台配置、迁移或资金开关。

仅完成代码与本地测试，未部署；手机刷新、复制链接、海报二维码及落地页访问待部署后验收。主流程与业务待验收状态继续保持 `waiting_review`。

## P02 HTTP 测试环境链接增量（2026-08-28）

用户明确要求取消推广素材的 HTTPS-only 限制。素材 Controller 现接受 HTTP / HTTPS，展示保留端口，复制与海报二维码直接共用服务端链接，不重建正式地址。8 项邀请相关 Widget/模型测试、42 项邀请合同/银行卡流程/规则地址测试及 analyze、差异检查通过；记录见 [邀请好友模块](03-前端/开发计划/01-invite-overview-materials.md#p02-http-邀请链接增量2026-08-28)。

本次不修改后端、Admin、数据库、原生配置或其他 WebView 策略，已有及并行改动保留。未运行完整 Flutter 测试，未替用户执行手机扫码或相册保存，原有主流程和业务待验收状态继续保持 `waiting_review`。


## 邀请业务与提现通道解耦（2026-08-28）

本轮用户明确授权同时修改 catseller、Java 和 Web/Admin 相关代码：工猫未就绪只限制提现相关动作，不影响邀请、绑定、奖励、历史查询和活动规则查看。本次代码与本地回归已完成；原主流程及业务待验收状态仍为 `waiting_review`。

- 后端：显式激活仍要求 Admin JWT、X-App-Code、INVITE_VIEW + INVITE_CONFIG_EDIT、有效参数、切换日期、余额预检/checksum、事务与审计，但不再调用工猫或要求工猫就绪。保留显式停用、无配置 LEGACY、逐 App 启用及所有提现安全门禁，不自动激活任何 App。
- 公开规则：保留既有 enabled 的“直邀模式已启用”含义，追加 withdrawalEnabled 表示银行卡通道可用性（不代表个人已具备提现资格）；读取不写库、不调用外部工猫。Web 不再因 enabled=false 隐藏整页；未启用时明确显示为规则说明、不把默认参数冒充当前生效规则。通道不可用时只提示银行卡提现不可用。
- App：P09 继续复用 StaticPageView，仅活动规则 URL 跟随当前 API 环境；保留 appCode、embedded=1 及原路由账号门禁，其他协议继续正式地址，工猫 H5 策略不变。本地 HTTP 环境需要同源提供静态规则资源；无资源时报告加载错误，不自动跳到正式站。
- 验证：先复现旧门禁；覆盖工猫未配置/恢复、正常提现、显式停用、LEGACY、权限/预检/幂等、catseller 邀请素材/绑定/奖励查询；Web 覆盖启用/未启用/通道关闭、真实错误/超时/重试和响应字段校验；App 覆盖地址环境、路由和提现阻断不影响邀请。

### 数据库改动

无迁移、表结构或业务数据修改；不连接共享/生产数据库，不执行真实激活、资金开关或部署。仅在隔离 H2 测试中验证既有显式激活的期初余额/快照/审计行为，权限和账务约束保持不变。数据/配置改动：无。

### 本地验证结果

- 后端：改前全量 1316 通过 / 3 跳过；新增用例先复现工猫门禁阻止激活，再通过。最终 `./gradlew test --console=plain` 共 1322 项，1319 通过、3 项既有跳过、0 失败；邀请提现/基础合同定向 31 项通过。覆盖 catseller / catsinger 的真实测试 JWT、邀请接口、重复绑定、幂等首单奖励、查询、通道恢复及隔离；测试仅用隔离 H2 与 Mock 工猫。
- App：`dart format`、`flutter analyze --no-pub` 通过；邀请专项 50 项通过。全量 `flutter test --no-pub --reporter expanded` 为 286 通过、5 项既有失败：全局客服 URL 旧断言、4 份作品详情 Golden 文件缺失；未修改这些无关断言或生成 Golden 掩盖差异。
- Admin/Web：`flutter analyze --no-pub`、完整 Flutter 测试 167 项、`flutter build web --no-pub` 通过；`node --test test/invite_rules_web_test.mjs` 的真实 rules.js 行为测试 12 项通过。构建产物的 HTML/JS 与源文件逐字比较一致。
- 浏览器：本地虚构接口下验证启用但通道关闭、未启用只读说明、正常通道；窄屏滚动可达底部、无横向溢出，console 无警告/错误。不是测试服务器或真机验收。截图与详情见 [本地验证报告](05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-邀请业务与提现通道解耦)。
- 三仓 `git diff --check` 通过。19 个既有未提交文件已核对 SHA256，除 README 仅追加本次说明外原内容均保持不变；未修改 AGENTS、迁移、私有配置或资金开关。

### 发布后待验收

本轮未发布、未启用 App。需同步发布 Java 及 `web/legal/invite-rules/` 的 HTML/JS/CSS，保证测试 API 同源可访问规则静态资源；更新 catseller 后打开当前环境的规则页。只更新 Java 不会替换旧 Web 脚本，旧 App 仍可能读取正式站。

工猫未就绪时验证邀请分享/绑定/奖励/记录/规则仍可用，提现页提示不可用且服务端拒绝试算、申请；恢复通道后按原个人资格与审核流程验收。若尚未启用直邀，仍需授权管理员复核预检、余额摘要和切换日后显式启用，不能以规则可阅读代替业务激活。真实 H5/银行/资金闭环、手机刷新和返回仍待环境验收；所有原业务待验收状态不变。


## 规则正文先显示、动态参数异步补充（2026-08-28）

用户继续反馈旧规则页面阻断，并明确：不是完全不请求接口，而是展示不要受过多限制。本轮按此口径调整，覆盖前一轮“先请求成功才展示正文”的实现；不改变现有登录、邀请业务与提现安全校验，业务状态仍 waiting_review。

- HTML 默认就展示完整规则，结算天数及最低额提供通用说明，不等待 JS/API 返回。
- 保留同源公开接口补充真实有效参数；活动未启用、工猫未就绪、缺少 App 标识、网络/格式错误均不隐藏正文。失败只提示参数未更新并允许重试，不把默认金额冒充已生效参数。
- 为规则 HTML 入口和脚本增加本次显示版本参数，避免继续命中旧缓存；不清除其他 WebView 缓存或登录数据。
- 根据随后后台截图补充范围：公开规则接口复用后台已有 LEGACY/直邀规则来源，追加注册积分、三级直接比例、两个等级门槛、间接比例，最低提现额也取同一来源。保留既有响应字段，不修改业务开关、配置或资金逻辑；Web 只消费展示数据，不以 enabled/withdrawalEnabled 阻断正文。catseller 仅变更规则 URL 缓存版本。数据库改动：无；不自动发布。

### 本轮结果

已完成代码与本地验证。根因包括：旧 Web 脚本把新版直邀 enabled 标志当作展示门禁；公开接口仅提供新版缺省参数，未读取后台原有 invite.rules。现在公开读取与后台复用同一来源，补齐注册积分、三级直接比例、两个升级人数门槛、间接返佣比例和最低提现额；正文从初始 HTML 起即显示，JS 不读取活动或通道开关作为展示条件。

- Java 邀请基础/银行卡定向 32 项通过；完整 `./gradlew test --console=plain` 1323 总数 = 1320 通过 + 3 项既有跳过，0 失败。新增用例在修改前复现缺失字段，修改后验证公开数据与 catseller / catsinger 后台数据逐项一致、保存值变化可读、App 隔离、只读无自动启用；新模式仍返回自己的真实规则。
- Web 真实 HTML/JS 行为 12 项通过，覆盖八项配置、无 JS、pending、失败/超时/重试、enabled/withdrawalEnabled 任意值、缺 App 标识、部分坏字段和旧响应；没有删除接口请求。浏览器本地虚构 API 下验证原有模式八项数据、小屏滚动和 503 时正文始终可见。浏览器工具阻止 file:// 导航，未宣称直接文件打开已实测；无 JS 默认可见由 HTML 测试验证。
- catseller 专项 50 项通过；完整 Flutter 测试 286 通过、5 项既有无关失败（客服旧 URL 断言、4 份缺失 Golden），未更新 Golden。App/Admin analyze 通过，Admin 全量 167 项及 Web 构建通过。
- 本轮仅发布代码准备，没有部署、改业务数据、改后台配置或切换模式；原 waiting_review 保持。需先更新 Java 响应，再发布 Web 的 HTML/JS/CSS，并更新 App 规则入口版本或重新进入页面，避免旧缓存。无需为查看规则开启新版活动。

详细验证和截图见 [本地验证报告](05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-规则展示读取后台真实参数)。

## App Store Release 本地网络权限整改（2026-09-16）

App Store 审核指出 iOS 本地网络用途说明不充分。核查确认正式环境仅使用公网 HTTPS 服务，原生 `AppDelegate` 中的 `_http._tcp` Bonjour 启动扫描只是历史开发辅助，不应进入 Release。本轮删除启动扫描、`Network` 引用、`NSBonjourServices`、`NSLocalNetworkUsageDescription` 及冗余 `NSAllowsLocalNetworking`；不修改支付、内购、后端、数据库或其他业务。

本地验证：源 `Info.plist` 语法通过；`flutter build ios --release --no-codesign --no-pub` 成功，Release `Runner.app` 中上述三项本地网络键均不存在；`flutter build ios --simulator --debug --no-pub` 成功，Debug 产物仅由 Flutter 工具注入 `_dartVmService._tcp` 和调试专用说明；`flutter analyze --no-pub` 通过。未签名、未上传 App Store Connect、未在真机重置权限后验收，不改变原邀请提现 `waiting_review` 状态。
