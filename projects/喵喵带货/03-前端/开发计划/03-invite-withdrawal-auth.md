# Flutter 模块 03：提现表单、实名电签与银行卡

## 2026-09-03 P06 灵活用工协议改为固定 HTML

- 本节覆盖下方“工猫签名 PDF”和“双协议查看增量”中的短期地址方案。Admin/Web 新增 Catseller 专用纯静态页，正式地址为 `https://www.lxwanxiang.com/sites/catseller/legal/flexible-employment-agreement/index.html`。
- 正文严格使用用户提供模板，仅把占位值替换为杭州工猫科技有限公司、深圳市灵犀万象科技有限公司和软件推广；不增加主体信息卡片，不改写原协议条款。
- `inviteFlexibleAgreement` 路由保持兼容，内容改为 `StaticPageView(pageKey: 'flexible-employment-agreement')`。移除协议 API 调用、短期 URL model/参数、远程 PDF 页和 `pdfrx/PDFium`；只复用现有 WebView 加载、错误与重试能力。
- 查看不改变 `agreed`，不创建/确认实名会话，不替代工猫 H5 最终核身电签。后端旧 `/api/invite/agreements/flexible-employment` 留存但 Catseller 当前无调用；不修改 Java、数据库、配置或资金流。
- 已验证静态页内容/移动视口、`flutter analyze`、定向 58 项、Android Debug APK 和 iOS Simulator 无签名构建；全量 337 通过、7 项既有无关 Golden 失败，未更新基线。未部署，发布后仍需 Android/iOS 真机 WebView 验收。

## 2026-09-03 用户协议与隐私政策重新确认

- Catseller 线上中文《用户协议》和《隐私政策》已增加本模块的邀请收益、实名认证、身份证照片、人脸核验、动态财税服务商、银行卡与提现说明，正式 URL 与 WebView 页面 key 不变。
- 全局隐私同意版本由 1 升至 2，旧版用户在下次进入受保护流程时按现有弹层重新查看和确认。该确认只控制全局受保护服务初始化，不写入或替代 P06 的 `agreed` 状态。
- P06 复选框继续默认未勾选并作为实名认证资料处理及专项协议确认入口；阅读/返回/恢复不自动勾选，不创建 session，不调用 confirm。动态灵活用工合同仍负责展示当次财税服务商和合同相对方。
- 本轮不改认证、H5、绑卡、提现状态机、接口、数据库或配置；发布前需法务/运营复核正文并用升级覆盖安装验证总协议 v2 与专项同意互不替代。

## 2026-09-03 P06 实名认证服务协议公共目录迁移

- Admin/Web 将所有 App 共用的协议正文移动到 `web/sites/common/legal/identity-verification-service-agreement/index.html`，Catseller 固定正式地址同步切换到 `/sites/common/legal/identity-verification-service-agreement/index.html`；App 专属协议继续使用 `web/sites/{appCode}/legal/`。
- 继续使用 `identity-verification-service-agreement` 页面键和既有 `StaticPageView`；点击只打开只读页面，不改变 `agreed`，不创建或确认认证会话。
- 本轮不改变工猫协议、实名、照片、银行卡和资金流程，不执行部署；新地址需在 Admin/Web 与 App 同步发布后进行双平台 WebView 验收。

## 2026-09-03 P06 工猫签名 PDF 下载链路修复

- 本节覆盖下方 `PdfDocumentRefUri` 描述。有效期内下载的工猫样本是合法 2 页 PDF，并已在 iOS Simulator 用 PDFium 实际渲染；移动端现以独立 `HttpClient` 完整下载到内存，校验 `%PDF-` 文件头后使用 `PdfDocumentRefData + PdfViewer`，规避插件 URI 下载/落盘缓存兼容问题。
- 下载总超时 30 秒、最大 20 MiB、最多 3 次安全 HTTPS 跳转；不复用 `HttpService`，不携带 JWT 或 `X-App-Code`。签名 URL 保留原字符串且只存在路由 `extra`，PDF 字节不落盘；日志只输出脱敏失败分类。
- 不用移动端时钟预判 `Expires`，由 OSS 的 401/403 响应识别短期地址失效；网络、超时、非 PDF、超限和不安全跳转均显示固定提示，并保留重试、系统浏览器和返回实名认证。查看仍不修改勾选态，不创建或确认实名认证会话。
- 验证：邀请专项 57 项、`flutter analyze`、Android Debug APK、iOS Simulator Debug 构建通过，且 iOS Simulator 已实际渲染工猫样本；全量 340 项通过、7 项既有无关 Golden 失败。新鲜签名地址的 Android/iOS 真机网络与弱网验收保持 `waiting_review`。

## 2026-09-02 P06 灵活用工 PDF 内置查看修复

- 本节覆盖紧随其后的“双协议查看增量”中“PDF 使用系统浏览器”的旧策略。`RemoteAgreementArgs` 继续只接受安全 HTTPS 域名、默认/443 端口、无 userinfo/fragment 的地址，并保留 `.pdf` 路径识别和脱敏 `toString()`。
- 新增 `pdfrx: ^2.4.7`，当前依赖解析为 2.4.7。PDF 使用 `PdfDocumentRefUri`，30 秒超时、空附加请求头，不复用 `HttpService`；`PdfDocumentRefKey` 的可打印名称固定脱敏，唯一部分为 URL SHA-256 摘要和重试次数。HTML 继续走原 WebView。
- PDF 默认在 App 内显示加载进度、滚动和缩放。原始加载异常和签名地址不进入 UI/业务日志；失败只显示固定提示及“重试 / 使用系统浏览器打开 / 返回实名认证”。不增加下载、分享、批注或保存。
- Widget 回归覆盖默认内置查看、30 秒超时、空请求头、脱敏 key、加载失败/重试/外部兜底、HTML WebView、非法 URL，以及协议点击不勾选、不创建/confirm 会话。
- 验证：`flutter test --no-pub test/invite_bank_flow_test.dart` 56 项、`flutter analyze --no-pub`、Android Debug APK、iOS Simulator Debug 无签名构建通过；全量 339 项通过、7 项既有无关 Golden 失败。真实 Android/iOS 工猫 PDF 的首屏、滚动/翻页、双指缩放、返回、弱网与外部兜底待真机验收，状态 `waiting_review`。
- 数据库改动：无。后端 `/api/invite/agreements/flexible-employment`、一小时有效期、Admin、配置和实名认证签约状态流均不修改。

## 2026-09-02 P06 双协议查看增量

- 《灵活用工协议》点击时调用 `GET /api/invite/agreements/flexible-employment`，仅把短期 URL 保存在路由 `extra` 内存对象中；受控 WebView 优先，PDF 或主页面失败时尝试系统浏览器，禁止写日志、缓存和持久化。
- 《实名认证服务协议》使用 `identity-verification-service-agreement` 页面键，通过既有 `StaticPageView` 打开正式固定地址。两份链接点击不改变 `agreed`，只有圆形复选框切换同意状态。
- 对照 `66:120` 在签署按钮和协议行之间增加 `SizedBox(height: 8.w)`；链接请求中只锁定对应入口，失败停留本页并显示固定重试文案。
- 数据库改动：无。App 不改变实名创建、合法 H5 回跳确认、银行卡或资金流程；真实双平台 WebView/系统浏览器仍需设备验收。

## 2026-09-02 P06 协议区按 Figma 修正

- Figma 通道 `x5x4ir6u`、节点 `66:120` 为当前真源。底部按锁定提示、签署按钮、协议勾选排列，协议原文完整展示且默认不勾选。
- 页面复选框是唯一确认入口；未勾选只提示、不请求 `POST /api/invite/identity-sessions`，删除旧“同意协议”弹窗及自动勾选。签署前可分别查看两份协议，工猫 H5 仍负责最终核身与电子签约。
- 后端请求合同、H5回跳、P10和数据库均不变；专项测试覆盖未勾选零请求、主动勾选后单次创建、失败重试及新 Golden，状态 `waiting_review`。

## 2026-09-01 实名电签自动确认修复

- 本地实现 `waiting_review`。历史 PENDING 会话进入页面和“查询已有核验结果”只调用 `GET .../status`；移除 P06 的 App resume 自动 confirm，相机/相册返回及普通前后台切换零签约请求。
- WebView 合法回跳必须完整匹配服务端 returnUrl 且只有一个 43 位 URL-safe state；Navigator 返回 state 后，实名页才调用 `POST .../confirm` 的 `{state}` body。非法/缺失/重复 state、手动关闭和空 H5 地址不提交。
- 相关 Widget/Controller/API 回归覆盖页面进入、生命周期、空地址、手动关闭、非法回跳和合法回跳恰好一次；布局、实名/照片/协议/绑卡/提现门禁不变。数据库改动：无；真实双平台 WebView 与工猫待验收。

## 2026-09-01 每日提现次数动态化

- 本地实现 `waiting_review`；`InviteWithdrawalEligibility` 新增严格整数 `dailyWithdrawalLimit`（1～100，旧响应缺失时兼容 1）。提现页“每日最多成功创建”和 `DAILY_LIMIT_REACHED` 文案都使用服务端返回值，不在 App 内自行计数或写死 1 次。
- 日限额、当日已用次数和可提现结果仍全部信任后端资格接口；不改金额、报价、幂等键、实名或银行卡流程。App 无数据库改动。
- `flutter test test/invite_bank_flow_test.dart` 36 项通过，包含配置为 3、当日已创建 2 次仍可提现的模型回归；真机、真实银行/工猫和部署未执行。

## 2026-08-31 姓名中文输入修复

- 本地实现 `waiting_review`，只改 P06/P10 的姓名输入配置。共用 `InviteIdentityField` 增加默认关闭的 `enableSuggestions` 参数；两处姓名显式使用 `TextInputType.name` 和 `enableSuggestions=true`，避免 Android 将输入框标记为可见密码而影响中文候选词。
- 保持 `enableIMEPersonalizedLearning=false`、`autocorrect=false`、空 `autofillHints`；身份证/手机号/银行卡字段保持原配置，不修改姓名校验、敏感资料生命周期、协议、提交或资金逻辑。数据库改动：无。
- 两页分别验证平台输入类型、候选词开关、隐私标志、拼音 composing 保留、“张三”及“阿依·古丽”输入、其他字段候选词仍关闭、输入不触发 POST。邀请相关 79 项及静态分析通过；真机输入法待用户复验，详见 [补充验证](../../05-联调与测试/invite-identity-bank-split-verification.md#2026-08-31-补充姓名中文输入修复)。

## 2026-08-31 最新增量：实名认证与银行卡绑定拆分

用户已确认本次计划并授权开发，本地实现状态 `waiting_review`。本节优先于下方历史合并认证说明，其他CHG及已确认基线状态不变。

- Figma通道 `eeis7852`：P06 `66:120`，P10 `66:198`。P05打开不跳页；用户点击后按最新资格：未实名→P06、已实名无ACTIVE卡→P10、有卡→原提现。
- P06只填写姓名、大陆身份证、手机号及两面私有照片，类型 `invite/id-card-images`，≤3MiB，complete=READY后只提交resourceId。支持相机/相册、预览/替换、进度/重试；只清理本流程临时副本，不删相册、不长期缓存。
- 校验真实出生日期、身份证校验码、18–65周岁；61–65仍需工猫商户渠道验收，不绕过渠道拒绝。
- 认证只维护实名和会话，不建银行卡；syncInfo不传卡号。创建/确认返回 `identityReady` 替代 `ready`，删除 `bankAccount`；主动查合同2/3才成功，旧PENDING卡不自动激活。
- 认证成功自动返回提现页并刷新，等待用户点击“去绑定”。P10 `/invite/bank-bind` 重填四项资料、同意当前协议；不重复照片、H5或短信。
- POST bank-accounts先核对当前App的姓名、身份证和手机号；不一致不调用工猫。用户级Redis锁+同卡HMAC去重，短事务准备→事务外updateEmployee→严格success=true后短事务激活；有效同卡直接返回，未知PENDING可显式重试同卡，不自动重试；首张有效卡默认，新增不覆盖默认。
- 绑卡只接受ACTIVE为成功，提示后返回P05刷新；失败保留可编辑表单，成功/离页清除敏感输入。未签署、仅登记或PENDING绝不显示成功。
- H5权限、白名单开关、回跳查询和银行卡ID解析修复保留；不变更Admin、其他App页面、佣金/退款/打款。
- 业务与工猫配置共享，所有实名/照片/银行卡/会话/资金按App隔离。数据库：有持久化行为调整，但无新增表、字段、索引或SQL/Flyway；bank_account_id已可空。不处理历史数据、不调整余额、不部署或真实签约/提现。


验证、截图与真实渠道边界见 [拆分验证](../../05-联调与测试/invite-identity-bank-split-verification.md)。


## 2026-08-31 银行卡 ID 解析修复

- 状态：`waiting_review`；仅修复 catseller App 的响应解析，不修改后端、Admin、页面布局或资金规则。数据库改动：无。
- 根因：真实资格响应的 `bankAccounts[].id` 为字符串（截图为 `"1"`），`InviteBankAccount.fromJson` 原先调用只接受整数金额的 `InviteMoney.requireCents`，抛出异常后被显示为整页“加载失败”。
- 实现：银行卡 ID 使用独立解析方法，接收十进制数字字符串和整数，拒绝缺失、浮点、非正数、非法格式和超 JSON 安全整数范围；模型与请求仍保留 `int`，不放宽金额字段解析。`status=PENDING`、合同状态、`canWithdraw` 和默认卡选择逻辑均不变。
- 回归：fixture 的卡 ID 改为与后端一致的字符串；新增合法/非法 ID 模型用例、待认证卡页面用例及卡列表→试算→提现响应的 ID 传递用例，全部使用虚构数据和测试 transport，不调用真实接口。页面用例在修复前复现原错误，修复后显示 10 元余额与实名提示，仍拒绝提现且不发送试算/提现请求。
- 验证：`flutter test --no-pub test/invite_contract_types_test.dart test/invite_bank_flow_test.dart test/invite_h5_policy_test.dart test/invite_rules_url_test.dart --reporter expanded` 共61项全部通过；`dart format --output=none --set-exit-if-changed`（4个变更Dart文件）、`flutter analyze --no-pub`、`git diff --check` 通过。未运行本轮全量测试、Android/iOS构建、真机或真实 H5/银行验收。
- 复验：更新 App 后重新进入提现页，应正常显示余额与认证提示；截图中的待认证卡仍需完成既有实名/电签流程，不能以解析成功代替资格通过。原主流程和未勾选渠道验收项保持不变。

## 2026-08-28 H5 开关实现增量

- `InviteIdentitySession` 新增 `h5AllowedHostsEnabled`；只解析明确布尔 false 为关闭，不接受字符串/数值代替。
- P06 向 `InviteWebPolicy` 传递开关，`InviteControlledWeb` 的初始加载、后续导航及相机请求来源共享策略。关闭只跳过域名集合比较，HTTPS、合法域名、443、无用户信息（含空 @）、证书、相机授权、回跳拦截和禁止文件访问继续保留。
- 关闭时 `InviteH5HostDiagnostics` 在 Debug 中按容器去重输出域名。SDK 原始日志可能包含 URL，`InviteH5SdkLogGuard` 在认证容器存活期间临时静默全局 SDK 调试日志，退出后恢复；只影响这段时间的原始日志，不改变其他 WebView 行为。无新增依赖。
- 配置变更需退出当前 H5，后端重启后重新进入；不在 App 自动保存/信任域名。专项验证见 [本次验证](../../05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-工猫-h5-域名白名单开关)。本地实现 waiting_review，不勾选下方真实设备验收任务。数据库改动：无。

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F005`、`T-F006`
> 工程：`/Users/soul/code/lxwx/catseller`

## 1. 功能定位与边界

实现 P05/P06 和 D01/D03：用户完成资格检查、页面协议确认、敏感资料提交、工猫 H5 刷脸电签、银行卡选择、金额输入、服务端试算和幂等提交。本期只支持银行卡；不包含支付宝、微信、银行卡短信验证码，不在客户端自算税费。

数据库改动：无。敏感表单仅存内存，提交后立即清理。

## 2. 入口、路由与页面文件

- P05：`/invite/withdrawal`，替换 `lib/pages/invite/withdrawal/` 现有 `ALIPAY/accountNo/accountName` 表单。
- P06：`/invite/withdrawal-auth`，新建 `index.dart/controller.dart/view.dart` 及受控 H5 容器。
- D03 作为 P05 银行卡选择底部弹层；“添加银行卡”进独立P10（bank_bind三件套）。
- 提现创建成功后 `replace` 到 `/invite/withdrawals/:id`，避免返回重复提交。

## 3. 依赖前置

- [00-invite-contract-routing.md](./00-invite-contract-routing.md) 完成资格、session、银行卡、quote、提现合同。
- Java [02-invite-identity-gongmall.md](../../04-后端/开发计划/02-invite-identity-gongmall.md) 与 [03-invite-user-api-withdrawal.md](../../04-后端/开发计划/03-invite-user-api-withdrawal.md)。
- 需要工猫测试 H5 host、回跳 scheme/URL 和相机权限说明才能完成真机验收。

## 4. 视觉参考与设计稿分析

- D01：[04-realname-policy-dialog.png](../../01-需求/references/images/invite-withdrawal/04-realname-policy-dialog.png)，`43:1989`。
- P05：[08-withdrawal-unbound.png](../../01-需求/references/images/invite-withdrawal/08-withdrawal-unbound.png)、[16-withdrawal-form.png](../../01-需求/references/images/invite-withdrawal/16-withdrawal-form.png)、[17-withdrawal-excess.png](../../01-需求/references/images/invite-withdrawal/17-withdrawal-excess.png)。
- D03：[18-bank-selection.png](../../01-需求/references/images/invite-withdrawal/18-bank-selection.png)。
- 历史P06/D02（由新稿66:120/66:198替代，仅追溯）：[认证表单](../../01-需求/references/images/invite-withdrawal/10-withdrawal-auth-form.png)、[协议确认](../../01-需求/references/images/invite-withdrawal/11-agreement-confirm-dialog.png)、[绑卡成功](../../01-需求/references/images/invite-withdrawal/12-bank-bind-success.png)、[认证成功](../../01-需求/references/images/invite-withdrawal/13-certification-success.png)、[绑卡失败](../../01-需求/references/images/invite-withdrawal/14-bank-bind-failure.png)、[认证失败](../../01-需求/references/images/invite-withdrawal/15-certification-failure.png)，Figma `43:2504/2565/2639/2716/2793/2872`。

P05 从上到下：可提现金额卡、银行卡摘要、金额输入与全部提现、预计到账/每日说明、主按钮和安全提示；冻结/最低额/税费/服务费与协议确认按 PRD 补齐。图中输入 100 却预计到账 200 仅是示例，不能复制其数值。P06当前为三项资料和两面私有照片，P10为独立四项绑卡表单；成功提示后返回提现，失败原页修改或查询。工猫 H5 为外部页，不按 Figma 重画。

## 5. 涉及模块与类

- `InviteWithdrawalController/View`：资格、卡、金额、quote、协议、幂等提交。
- `InviteWithdrawalAuthController/View`：敏感表单、D01、页面协议确认、session、H5、confirm 和恢复。
- 组件：`MaskedBankCard`、`MoneyAmountField`、选卡 Sheet、受控 H5 容器。
- Model：eligibility、identity session、bank account、quote、withdrawal。

## 6. 业务内容与数据流

1. P05 并行加载资格和卡列表；负余额、今日已创建、未认证、无可用卡均根据服务端阻断码显示下一动作。
2. 选卡/金额变化后 300～500ms debounce quote，递增序号丢弃旧响应；quote 过期或余额变化必须重算并让用户重新核对。
3. 提交只传四个安全字段；同次尝试复用 `Idempotency-Key`，网络不明时先查提现记录/详情。
4. P06校验两面照片READY、大陆身份证校验码/真实生日/18–65周岁；创建 session 成功后立即清理输入，打开受控 H5。
5. 崩溃/页面恢复只调status；只有受控H5匹配回跳中的合法state才调confirm。用户关闭、App resume、相机/相册返回不提交签约，也不信任H5文案。
6. 认证完成后返回 P05，刷新资格和卡；合同主动查询2/3且identityReady才成功，无卡等待用户点击去P10，不自动激活旧卡。
7. 最低提现额从当前 App 资格接口读取，不硬编码 1 元。后台变更后新申请以后端最新门槛为准；收到低于门槛/配置变更错误时刷新资格、保留用户金额供修改并重新试算。已创建申请及原幂等键重试不因调高门槛变成新单。

## 7. 现有工程参考点

删除/替换 `withdrawal/dialog/account_sheet.dart` 中支付宝账号语义，但复用现有底部 Sheet 视觉和表单验证风格。WebView 使用工程既有稳定封装，不新增第三套依赖。

## 8. 建议实现步骤

1. 先实现资格/卡/quote 状态机和 Controller 测试。
2. 替换 P05 表单，实现 D03、全部提现、quote 与按钮门禁。
3. 实现 P06/D01、页面协议确认、敏感表单和清理。
4. 接入 H5 白名单、相机权限、回跳state校验、只读status与显式confirm。
5. 补幂等键、超时恢复和页面生命周期测试。

## 9. 详细编码任务清单

- [x] `T-F005-01` 完成 P05 资格、卡、金额与 D03。
- [x] `T-F005-02` 完成 quote debounce/过期/余额变化和幂等提交。
- [x] `T-F006-01` 完成 P06/D01、页面协议确认及敏感输入清理。
- [x] `T-F006-02` 完成工猫 H5 白名单、权限、合法state回跳confirm和只读恢复status；resume不提交。
- [ ] `T-F006-03` 补齐 H5 中断、合同生成中、失败恢复与真机验收。

## 10. 验收标准

1. P05 只有银行卡，创建请求不含姓名和完整卡号。
2. 负余额、最低额、每日限制、无卡、quote 过期和余额变化均有正确阻断/恢复。
3. 快速改金额/卡不回填旧 quote，重复点击/超时不产生新幂等尝试。
4. 姓名、身份证、手机、卡号不出现在本地存储、日志、路由、截图缓存和埋点。
5. H5拒绝相机、关闭、回跳失败和App resume均不提交签约；合同生成中可由status安全恢复，合法回跳只confirm一次。

## 11. 编码注意事项

工猫 H5 与活动规则使用不同白名单。禁止 `http/file/data` 和证书错误绕过，不注入 JWT/用户资料/任意 JS bridge，日志不记完整 H5 URL。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
