# 邀请好友与银行卡提现 Flutter 总体开发计划

## 2026-09-03 最新增量：P06 固定 HTML 灵活用工协议

- Admin/Web 在 `web/sites/catseller/legal/flexible-employment-agreement/index.html` 维护协议正文，页面针对移动 WebView 自适应，不含脚本、外链和远程素材。主体为杭州工猫科技有限公司，合作企业为深圳市灵犀万象科技有限公司，服务类型为软件推广。
- App 在现有环境协议 map 中新增固定页键，原 P06 路由改为 `StaticPageView`；点击不再请求 `/api/invite/agreements/flexible-employment`，不传递签名 URL。测试环境域名为 `test.lxwanxiang.com`，正式为 `www.lxwanxiang.com`。
- 删除远程 PDF 页面、下载/重试/外部打开分支及 `pdfrx/PDFium` 依赖。后端接口、Java、Admin 功能页、数据库和实名签约状态流不改。
- 回归要求：固定 pageKey/环境 URL、P06 不发协议 API、不勾选、不创建 session/confirm；执行 `flutter analyze`、定向测试、全量测试、Android Debug、iOS Simulator 和 HTML 移动视口检查。发布顺序为先 Admin/Web 静态页，再 App。

## 2026-09-03 最新增量：静态页面环境根地址统一

- `constants.dart`、`privacy_consent.dart` 从 `lib/utils/` 正式迁移至 `lib/config/`，由 `config/index.dart` 聚合；所有实际使用方显式导入 config，utils 不提供兼容导出。`PrivacyConsentService` 内容和 SHA-256 保持不变。
- `Global` 的原环境配置块保持不变，仍通过 `currentServerAddressType = 1/2/3` 切换环境，三个 server address 继续引用 `AppConstants`。`legalPageUrls` 在编译时直接形成最终 URL：local/test → `https://test.lxwanxiang.com`，production → `https://www.lxwanxiang.com`；活动规则直接包含 `appCode=catseller&embedded=1&v=20260828-display`，已删除二次换域名函数。
- 通用静态 WebView 和阿里云一键登录原生协议入口都直接读取 map；`AliyunNumberAuthService` 不再接收 `apiBaseUrl`。旧本地提现规则 URL 指向 Java 8080 并返回 JSON 404，现不再访问本地静态路径；API baseUrl、后端、Admin/Web 文件和服务器配置不变。
- 回归覆盖全部 9 个页面 key 的最终根地址、path/query、P09 固定 pageKey、登录门禁和一键登录协议参数。协议/邀请定向 69 项、登录 Widget 2 项、`flutter analyze` 和 Android Debug APK 构建通过；全量仅剩 7 个既有 Golden 失败。代码状态 `waiting_review`，真机 WebView 待安装新包后验收。

## 2026-09-03 最新增量：新版用户协议与隐私政策重新确认

- Catseller 中文《用户协议》和《隐私政策》新增灵活用工、敏感个人信息、工猫开放平台、动态财税服务商、银行卡与提现说明；现有正式 URL 和页面 key 不变。
- `PrivacyConsentService.currentConsentVersion` 从 1 升至 2。旧版 acceptedVersion=1 不再满足 `hasAccepted`，下次进入受保护启动/操作流程时复用现有总协议弹层重新确认；接受 v2 后继续按原流程初始化受保护服务。
- P06 的《灵活用工协议》与《实名认证服务协议》仍使用独立、默认未勾选的确认控件。打开协议、返回 App、页面恢复和查询状态均不改变同意状态或触发签约，总协议 v2 也不替代专项同意。
- 新增定向版本回归；不修改 URL、路由、SDK 初始化顺序、实名/签约/银行卡/提现接口、数据库或配置。真实升级覆盖安装和双平台展示仍为 `waiting_review`。

## 2026-09-03 最新增量：P06 工猫签名 PDF 远程加载修复

- P06 不再把签名 URL 直接交给 `PdfDocumentRefUri`。App 使用独立 `HttpClient` 在内存中完整下载，30 秒总超时、20 MiB 上限、无业务鉴权头、安全 HTTPS 跳转不超过 3 次；校验 PDF 文件头后交给 `PdfDocumentRefData + PdfViewer`。
- 签名 URL 校验后保留原字符串，仅存在路由 `extra`；不使用移动端时钟预判有效期，按 OSS 的 401/403、超时、网络、非 PDF、超限、不安全跳转分类日志，所有日志保持不含 URL、正文和原始异常。
- 工猫样本已在 iOS Simulator 使用 PDFium 实际渲染成功。Widget 回归需覆盖原始签名编码保留、内存 PDF 引用、下载/渲染失败重试、过期拒绝、外部浏览器、HTML WebView、非法 URL 和只读边界；Android/iOS 使用新鲜签名地址的真机网络验收保持 `waiting_review`。
- 已执行：邀请专项 57 项、`flutter analyze`、Android Debug APK、iOS Simulator Debug 无签名构建通过；全量 340 项通过、7 项既有无关 Golden 失败，未更新无关基线。

## 2026-09-02 最新增量：P06 PDF 内置查看

- P06 灵活用工协议路由与短期 URL 安全校验保持不变；HTML 继续用 WebView，PDF 默认用 `pdfrx 2.4.7` 内置查看，系统浏览器降为加载失败兜底。
- PDF 请求独立于业务 Dio，空附加请求头、30 秒超时；插件 key 使用固定脱敏名称和 URL 摘要，不在日志、错误、路由 query 或持久化中暴露签名地址。第一版只支持阅读、滚动和缩放。
- 失败态固定提供重试、外部打开和返回实名认证；点击协议仍不切换页面勾选、不创建或确认实名认证会话。
- 专项 56 项、静态分析、Android Debug 与 iOS Simulator 无签名构建通过；全量 339 项通过、7 项既有无关 Golden 失败。保持 `waiting_review`，等待真实 Android/iOS 工猫 PDF、弱网和外部兜底验收。

## 2026-09-02 最新增量：P03 已开通状态展示

- 真实 `GET /api/invite/records` 响应在 `memberCommissionStatus` 使用 `OPENED/NOT_OPENED`；原 View 仅识别旧值 `SETTLED`，因此产生“已开通 Tab 中的记录标签显示未开通”。
- `InviteRecord.isMemberOpened` 现统一识别当前 `OPENED` 和旧版 `SETTLED`，行内文案与颜色只依赖该语义；筛选、计数、分页和手机号展示不变。
- 夹具已改用真实合同值，并覆盖当前/旧版已开通值、未开通值和 Tab 切换。邀请专项 53 项、指定 Widget 用例及静态分析通过；保持 `waiting_review`，未修改后端/数据库/配置，真实接口和真机未验收。

## 2026-09-02 最新增量：P01 一级佣金动态展示

- `InviteOverview` 保留当前一级佣金等级、当前比例和三档一级比例；删除误加的自动等级、人工保底及等级模式字段，旧响应缺少比例时兼容 10%/20%/30%。
- P01 移除写死的“最高30%”和三档比例，按服务端最终值展示当前一级佣金；真实邀请人数进度和 10/20 人门槛保持不变，不向用户解释后台身份或等级来源。
- P04 的二级关系收益统一显示“推广奖励”，隐藏后台关系层级和二级比例。fixture 与 Widget 回归覆盖 12%/25%/35% 动态配置、后台调整后最终比例、真实人数进度以及用户端禁词。
- 本增量保持 `waiting_review`；没有部署、真机/真实接口验收、线上配置保存或业务数据变更。

## 2026-09-02 最新增量：P04 佣金卡种标题

- `GET /api/invite/earnings/ledgers` 列表项新增可空 `productName`；Catseller Model 解析该字段，`DIRECT_REWARD` 显示“好友开通${productName}”，空值显示“好友开通会员”。
- 月卡、季卡、年卡和缺失字段均有 Model 回归，P04 Widget 断言旧“直接邀请首单奖励”不再出现；只更新 `07-commission-list` Golden 并与 Figma `43:2285` 对稿。
- 退款冲正、间接收益、期初余额、金额/状态/结算/提现、其他 App 客户端和数据库均不改；本地实现保持 `waiting_review`，未部署或真机验收。

## 2026-09-02 最新增量：P06 协议区按 Figma 修正

- 设计真源更新为通道 `x5x4ir6u` 的 `66:120`。P06 显示两份协议原文并默认不勾选，只接受页面复选框主动确认。
- 删除旧 D02 二次确认路径；未勾选不创建认证会话，提交失败保留本页勾选状态，离页不持久化。完整协议继续在工猫 H5 签署，不新增独立协议页。
- 只调整 Catseller P06、专项测试、Golden 和文档；后端接口、P10、其他 App 及数据库不变，状态保持 `waiting_review`。

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


验证、截图与真实渠道边界见 [拆分验证](../05-联调与测试/invite-identity-bank-split-verification.md)。


> 2026-08-31 T-F001/T-F005 缺陷修复：银行卡响应 ID 独立解析数字字符串或整数，不再误用金额校验；保持整数请求格式、金额校验和认证/提现门禁。新增4项回归，相关61项测试、analyze、格式化及差异检查通过。详情见 [提现模块](开发计划/03-invite-withdrawal-auth.md#2026-08-31-银行卡-id-解析修复)。本地实现 `waiting_review`，未做本轮真机验收；数据库改动：无。

> 2026-08-28 T-F006 增量已实现：session 的 `h5AllowedHostsEnabled` 仅布尔 false 关闭域名列表匹配，缺失/异常默认开启；初始加载、导航、权限来源共用同一策略，基础安全约束不变。仅 Debug 去重输出域名，认证容器存活期间 SDK 原始日志临时静默，退出恢复。真实 H5/双平台设备验收仍未完成，保持 waiting_review；测试与配置流程见 [本次验证](../05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-工猫-h5-域名白名单开关)。数据库改动：无；活动规则和其他 WebView 的页面行为未调整。

> 2026-08-28 规则展示最新修复：规则接口现在复用后台原有/新版规则数据来源，向 Web 返回用户指定的八项积分、比例、升级人数和最低额；正文默认可见，活动或工猫开关、参数更新失败均不阻断阅读。App HTML 与 Web 脚本使用 v=20260828-display 避开旧缓存；登录及提现安全校验不变。Java 全量 1320 通过 / 3 跳过，Web 12 项、App 专项 50 项、Admin 167 项通过；App 全量 286 通过 / 5 项既有失败。未部署，仍 waiting_review，详见本地验证报告最新增量。

> 2026-08-28 最新增量：活动规则仍复用 StaticPageView，但 URL 已跟随当前 API 环境（含 HTTP 测试服），不再固定正式站；其他协议及工猫 H5 不变。工猫未就绪只阻断提现，不影响邀请和规则。相关 50 项测试及 analyze 通过，全量 286 通过 / 5 项既有失败。详情见 [本地验证报告](../05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-邀请业务与提现通道解耦)。本条取代下方旧固定正式地址要求，不推进 waiting_review。

> 2026-08-28 P09 容器简化：活动规则路由直接显示 `StaticPageView(pageKey: 'invite-rules')`，删除专用页面/Controller；`legalPageUrls` 固定正式地址并包含 `embedded=1`。46 项相关回归及 analyze 通过；共享静态页代码未改，工猫容器与此前正式动态规则接口待验收事项不变。以下早前专用容器描述只用于历史追溯。

> 2026-08-27 实现回写：三端核心代码、共享工猫私有配置、Admin 增量与 App 22图对稿已完成本地检查，当前 waiting_review。最新真实进度以 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md) 和 [验证报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md) 为准；未自动启用/部署，真实 H5/银行及未勾选任务待验收。下文为已确认技术/任务基线，不用历史“待实现”描述覆盖最新记录。

> 2026-08-27 P01 顶部复审增量：已按 Figma `43:1639` 将邀请有礼状态栏/导航栏改为原稿暖粉渐隐背景，仅此页启用。39 项邀请专项、analyze、iOS 模拟器构建及跳转返回复验通过；3 张首页对稿和范围说明见 [design-qa.md 第 7 节](./design-qa.md#7-p01-顶部颜色复审增量2026-08-27)。等待用户视觉复审，不改变真实渠道待验收状态。

> 2026-08-28 P09 地址调整：已改为 `AppConstants.legalPageUrls['invite-rules']` 中的正式站 URL，不再调用 overview/capability 获取页面地址；规则正文中的结算天数和最低额仍动态读取。46 项相关测试及 analyze 通过；另运行的既有全局协议常量测试在改前、改后均因客服 URL 断言陈旧而失败，本轮未调整客服。正式 HTML 可访问，但公开动态规则接口返回 `code=-404`，页面内容联调待后端发布；详见模块 04。


> 版本：`v1.0.0`
> 日期：2026-08-27
> 状态：`done`
> 移动端工程：`/Users/soul/code/lxwx/catseller`
> 需求基线：[requirements.md](../01-需求/requirements.md) v1.0.3
> Flutter 技术文档：[flutter-tech.md](./flutter-tech.md) v1.0.0
> 后端技术文档：[java-tech.md](../04-后端/java-tech.md) v1.0.0
> 工时基线：[effort-estimate.md](../02-技术方案/effort-estimate.md) v1.0.1

---

## 1. 文档用途与范围

本文把当前独立 Flutter 技术方案拆成可执行、可暂停、可恢复的总体开发计划，作为下一阶段模块开发文档和后续 Flutter 编码的唯一总体计划入口。

本计划只覆盖：

- P01 邀请有礼、P02 邀请好友、P03 邀请记录、P04 佣金明细。
- P05 银行卡提现、P06 实名电签、P07 提现记录、P08 提现结果。
- D01 实名通知、P06 页面协议确认区、D03 银行卡选择。
- P09 活动规则受控 WebView。
- Invite API、Model、GetX Controller、路由、生命周期、安全和自动化测试。

本计划不覆盖视频、作品、积分、登录、会员、订单等其他喵喵带货功能，也不包含支付宝、微信、银行卡短信验证码、二级佣金或其他 App 品牌页面。运营后台与活动规则 Web 的实现任务归入 [Java 总体开发计划](../04-后端/java-dev-plan.md)。

本阶段只生成开发计划，不修改 Flutter 业务代码。

### 1.1 数据库改动

Flutter：无数据库改动。身份证、完整卡号等敏感输入只存在于页面内存与单次 HTTPS 请求，不进入 GetStorage、Hive、日志、埋点、路由参数或剪贴板。

## 2. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `13 Flutter 编码` |
| 当前任务 | `首批基础代码可评审；下一佣金模块待金额口径确认` |
| 当前状态 | `in_progress`（总体计划已确认，首批已编码） |
| 当前恢复点 | 枚举/整数分工具与新增 6 项测试完成；API/参数/路由待后端合同；详见 `../implementation-progress.md` |
| 下一步默认动作 | 确认返佣舍入/部分退款口径后按 Java 01 → Flutter 邀请/记录 → Admin 查询继续，不重复计划评审 |

编码门禁：`flutter-tech.md`、本计划及全部当前邀请提现模块文档均经确认前，禁止进入 Flutter 编码。

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 尚未开始 |
| `in_progress` | 正在执行，必须记录具体恢复点 |
| `waiting_review` | 产物完成，等待用户审核或真机确认 |
| `done` | 代码、必要测试和验收门禁均通过 |
| `blocked` | 被接口、设计、权限、环境或外部 H5 阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

1. 开始某项编码前把任务改为 `in_progress`，记录已修改文件、未完成步骤和下一条安全命令。
2. 代码完成但后端合同、工猫 H5、真机摄像头或活动规则 URL 未验证时，保持 `waiting_review` 或记录外部阻塞，不能宣称 `done`。
3. 每完成一项同步任务清单、模块文档和执行记录；中断后只从最后恢复点继续。
4. API 路径、请求字段、九态枚举、Figma 页面或产品规则变化时，先回卷需求/技术文档，再调整本计划。
5. 不以页面“看起来完成”替代 Model、错误态、生命周期、安全和自动化验收。

## 4. 总体开发策略

### 4.1 实施原则

1. 复用现有 `lib/apis/invite.dart`、`lib/pages/invite/` 和 8 个邀请路由，不建立第二套邀请模块。
2. 先冻结 Java OpenAPI 合同，再统一升级 Model/API/枚举；页面不得各自解析同一状态。
3. 先完成邀请和佣金只读链路，再完成涉及敏感输入和资金提交的认证/提现链路。
4. 所有金额使用整数分；所有返佣、余额、税费、资格和终态使用服务端真值。
5. 使用 capability/availableActions 控制模式和动作，禁止按 `catseller` 名称分支。
6. 工猫 H5 与活动规则 WebView 使用不同白名单；回跳后只调用后端 confirm，不信任 H5 展示文案。
7. 最后统一完成异常恢复、轮询生命周期、Figma 对稿和双平台回归。

### 4.2 与 Java 并行边界

- T-F001 可先按 `java-tech.md` 写 Model、Fixture 和 API 契约测试，但真实 API 联调以 `/v3/api-docs` 为准。
- T-F002～T-F005 可在用户查询接口冻结后并行实施。
- T-F006 依赖身份/合同/银行卡 API 和工猫测试 H5。
- T-F007 依赖提现创建、详情和状态机接口。
- T-F008 的正式 HTTPS URL 固定在 App `legalPageUrls` 中；不再依赖 T-B001 下发 URL。Web 仍依赖 `/api/config/invite-rules` 提供动态业务参数，本期无规则 CMS。
- 网络 Mock 只用于自动化，不得成为 release 运行时兜底。

## 5. 阶段、工时与里程碑

本计划引用已确认的 AI 工时，不重新估算：Flutter 代码初稿占第一个执行日约 `0.25` 个 AI 工作日；第二个执行日与 Java/Admin 一起完成构建、自动化、对稿和集中修复。外部工猫或银行等待不计入 AI 工时。

| 阶段 | 计划窗口 | 任务 | 退出条件 |
|------|----------|------|----------|
| F1 合同与骨架 | 第 1 日 | T-F001 | Model/API/枚举/路由可编译，Fixture 契约通过 |
| F2 邀请与佣金 | 第 1 日 | T-F002～T-F004 | P01～P04 真实数据、进度、分页、冲正和空态可用 |
| F3 认证与提现 | 第 1 日 | T-F005～T-F007 | P05～P08、D01～D03、H5 回跳、quote、幂等和九态可用 |
| F4 活动规则 | 第 1 日 | T-F008 | P09 使用 App 常量正式 URL，仅允许其 HTTPS host，外链策略正确 |
| F5 验证与修复 | 第 2 日 | T-F009 | format、analyze、定向/全量测试、双平台构建和对稿完成 |

里程碑：

| 里程碑 | Flutter 交付结果 |
|--------|------------------|
| 三端代码初稿 | 2026-08-27：P01～P09 与 D01～D03 已接入现有工程，不含本期外功能 |
| 本地验证版本 | 2026-08-28：主要测试、Android/iOS Debug 构建和集中修复完成 |
| 工猫真实验收 | 环境就绪后：真机摄像头、刷脸电签、回跳和状态查询通过 |

## 6. 详细任务清单

任务 ID 与 `tech-plan.md` 的 T-F001～T-F009 一一对应，不新增平行编号。

| 任务 ID | 业务任务 | 依赖 | 主要文件/模块 | 状态 | 完成标准 |
|---------|----------|------|---------------|------|----------|
| T-F001 | 新用户接口、DTO、错误码和状态映射 | T-B007 合同冻结 | `apis/invite.dart`、invite Model/Params、routes | `in_progress` | 请求字段、九态、错误码和未知态兜底与 Java 一致；金额只用分 |
| T-F002 | P01 邀请首页与真实人数进度 | T-F001 | `pages/invite/`、进度组件 | `pending` | 六类入口正确；0/1/9/10/11/19/20 人逐人填充；负余额禁用提现 |
| T-F003 | P02 邀请好友页面复用升级 | T-F001 | `pages/invite/materials/` | `pending` | 标题统一“邀请好友”；链接/二维码/海报由服务端返回；复制、分享、保存反馈完整 |
| T-F004 | P03/P04 邀请与佣金明细 | T-F001 | `records/`、`ledgers/` | `pending` | 服务端筛选分页；只展示直接奖励和退款冲正；加载/空/错误/负余额覆盖 |
| T-F005 | P05 提现、D03 选卡与试算 | T-F001、T-B007 | `withdrawal/`、银行卡/金额组件 | `pending` | 资格、默认卡、金额转分、debounce quote、过期重算、全部提现和幂等提交正确 |
| T-F006 | P06/D01 实名电签、页面协议确认与受控 H5 | T-B005、T-B006、T-B007 | `withdrawal_auth/`、受控 WebView | `waiting_review` | 敏感输入不落地；协议必须主动勾选；H5 中断/回跳/生成中/完成均可恢复 |
| T-F007 | P07/P08 提现记录、详情与轮询 | T-B007、T-B008 | `withdrawals/`、`withdrawal_result/`、时间线 | `pending` | 九态展示一致；APPROVED/处理中状态轮询；后台停止；失败/退票返还文案准确 |
| T-F008 | P09 活动规则静态页复用 | T-A006、公开动态规则 API | `routes/router.dart`、`pages/webview/`、`utils/constants.dart` | `waiting_review` | 直接使用 `StaticPageView(pageKey: 'invite-rules')`，固定正式 URL；不请求后端取地址，不注入 JWT；不再维护规则专用容器，待正式数据联调 |
| T-F009 | Flutter 综合自动化与对稿回归 | T-F002～T-F008 | `test/apis`、`test/models`、`test/pages/invite` | `pending` | 自动化、22 图对稿、小屏/字体/弱网/生命周期及双平台 Debug 构建达到门禁 |

## 7. API 与本地逻辑依赖

| 业务 | API | Flutter 本地职责 | 禁止行为 |
|------|-----|------------------|----------|
| 首页 | `GET /api/invite/overview` | 绘制服务端进度/余额/入口 | 自算佣金和余额 |
| 邀请素材 | `GET /api/invite/materials` | 保存、分享、复制和权限反馈 | 客户端拼 inviterId 链接 |
| 邀请记录 | `GET /api/invite/records` | Tab 驱动服务端分页 | 对已加载页本地筛选 |
| 佣金 | `GET /api/invite/earnings/summary`、`/ledgers` | 格式化正负金额和空态 | 展示二级/团队佣金 |
| 提现资格 | `GET /api/invite/withdrawal-eligibility` | 根据阻断码显示下一动作 | 根据本地日期判每日次数 |
| 实名电签 | `POST /identity-sessions`、`/{id}/confirm` | 内存表单、受控 H5、resume 确认 | 信任 H5 文案或保存证件号 |
| 银行卡 | `GET/PUT/DELETE /api/invite/bank-accounts/**` | 脱敏列表、选择、默认和删除确认 | 上传完整卡号到提现创建接口 |
| 试算 | `POST /api/invite/withdrawal-quotes` | debounce、丢弃旧响应、处理过期 | 客户端自算税费 |
| 创建提现 | `POST /api/invite/withdrawals` | 同次尝试复用 Idempotency-Key | 生成/替换工猫 requestId |
| 记录/详情 | `GET /api/invite/withdrawals`、`/{id}` | 分页、时间线、可见时轮询 | 把提交成功解释为到账 |

仅允许持久化现有全局会话信息。本功能页面状态默认内存保存；如编码时确需跨进程恢复认证 session，只能保存后端 opaque sessionId 与过期时间，并先通过安全评审。

## 8. 模块开发文档列表

旧综合 Flutter 模块文档已原样移入 CHG-0063 归档；以下 6 份当前模块文档已获用户确认，文档状态为 `done`；编码任务仍未开始：

| 顺序 | 计划路径 | 覆盖任务 | 状态 |
|------|----------|----------|------|
| 1 | `03-前端/开发计划/00-invite-contract-routing.md` | T-F001 | `done` |
| 2 | `03-前端/开发计划/01-invite-overview-materials.md` | T-F002、T-F003 | `done` |
| 3 | `03-前端/开发计划/02-invite-records-ledgers.md` | T-F004 | `done` |
| 4 | `03-前端/开发计划/03-invite-withdrawal-auth.md` | T-F005、T-F006 | `done` |
| 5 | `03-前端/开发计划/04-invite-withdrawal-results-web.md` | T-F007、T-F008 | `done` |
| 6 | `03-前端/开发计划/05-invite-flutter-tests.md` | T-F009 | `done` |

模块文档必须明确 View、Controller、API、Model、本地状态、异常、Figma 节点和测试之间的关系，不得只列 UI 组件。

## 9. 编码约束

1. 沿用 `GetX + Dio + go_router + GetStorage/Hive + Global.init() + CustomScaffold`，不引入 Provider、Riverpod、Drift 或第三套路由/网络框架。
2. 页面保持工程现有 `index.dart/controller.dart/view.dart` 组织；邀请内组件留在模块目录。
3. 先读取 Flutter 编码索引和当前任务所需最小规则，再修改代码。
4. 金额用整数分；字符串转分必须确定性处理两位小数，不用 `double * 100`。
5. capability 驱动新旧模式；客户端不使用 App 名称硬编码。
6. 敏感资料禁止持久化、打印、放入路由、错误、截图缓存和分析事件。
7. H5 与活动规则 URL 必须 HTTPS 白名单；证书错误不得绕过。
8. 提现提交防抖不是幂等边界；网络不明确时先查已有单，不更换同次 Idempotency-Key。
9. 不覆盖用户未提交改动，不顺带调整邀请提现以外页面。

## 10. 验证与完成标准

### 10.1 自动化门禁

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- 邀请 API/Model/Controller/Widget/WebView 定向测试。
- 全量 `flutter test`；既有无关失败需有可复现证据，不能静默忽略。
- Android 与 iOS Debug 构建至少各一次。
- `git diff --check`。

### 10.2 重点验收

- 真实进度边界：0、1、9、10、11、19、20。
- 重复点击/超时、quote 过期、每日一次、负余额、余额变化。
- H5 权限拒绝、中断、回跳失败、合同生成中、App resume。
- 九态、未知状态、审核驳回、查单中、明确失败、成功、退票。
- 姓名/证件/手机号/卡号不出现在存储、日志、URL 和普通响应。
- 22 张 Figma 的布局和交互，以及 PRD 补充的加载/空/错误状态。

## 11. 风险与编码前门禁

- Java OpenAPI 的分页参数、稳定错误码和 display 字段需在 T-F001 开始前冻结。
- 工猫测试 H5 host、回跳 URL/scheme 和相机权限说明需在 T-F006 真机验收前提供。
- 活动规则正式 HTTPS URL 已固定且 HTML 读取为 200；T-F008 release 验收前需确认公开动态规则接口可用，不能把 HTML 可达误当规则数据已上线。
- 首批启用 App 清单不影响共享 Flutter 代码结构，但决定 capability 测试数据。
- 返佣舍入、历史余额和税费口径由后端负责；Flutter 不因待确认自行实现计算。

## 12. 执行记录

| 日期 | 阶段/任务 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-08-27 | 09 Flutter 总体开发计划 | 用户通过“继续下一步”确认 Flutter 技术文档；归档旧综合 Flutter 总体计划，并按现有 InviteAPI、GetX 页面、路由、Figma 与 Java 合同生成 T-F001～T-F009 当前计划 | 用户已确认，`done`；未修改 Flutter 代码 |
| 2026-08-27 | CHG-0068 首批编码 | 枚举/整数分工具与新增 6 项测试完成；API/参数/路由待后端合同 | analyze、新增测试通过；全量 211 通过、11 项非邀请失败 |

## 13. 下一步

总体/模块文档已确认，失效规则引用已修复。本批实际完成项见任务表，其余功能保持 pending。下一佣金模块需用户确认金额舍入及部分退款口径；准确代码、验证和恢复顺序见 [implementation-progress.md](../implementation-progress.md)，不以文档 done 代替实现完成。


## 普通页面结构与 Controller 增量记录（2026-08-27）

用户另行批准全 App 普通页面结构整理，实施记录见 [普通页面结构与 Controller 统一整理](开发计划/page-structure-controller-refactor.md)。公共骨架、页面 Controller 生命周期、导航/正文/底栏分区与适配已完成；分析通过，完整测试 280 通过、5 项既有失败（客服 URL 旧断言、4 份详情 Golden 基准缺失），未批量更新 Golden。26 组前后截图已归档，真实设备与授权/支付/银行链路仍待验收。

这是独立增量记录，不推进邀请提现原有任务状态；当前主流程和业务待验收状态继续保持 `waiting_review`，不自动部署、迁移或启用资金。

## P04 好友手机号展示增量（2026-09-02）

Catseller 的 `InviteEarningLedger` 接收共享接口新增的可空 `sourcePhoneMasked`，佣金明细显示“服务端脱敏手机号 · yyyy.MM.dd”，空值只保留日期。仅修改 P04 model、View、fixture、Widget/Golden 回归；不修改其他 App 客户端、不接收完整手机号、不改变佣金金额/状态/分页。邀请页面 41 项和 `flutter analyze --no-pub` 通过，375×812 实现图已与 Figma `43:2285` 同轮比较；真实接口和真机未验收。

## P03 邀请记录好友手机号增量（2026-09-02）

Catseller 的 `InviteRecord` 接收共享接口新增的可空 `inviteePhoneMasked`，邀请记录首行优先显示带分组空格的服务端脱敏手机号；字段为空时保留原 `inviteeName`，筛选、分页、绑定时间和会员状态不变。fixture 用“占位展示名 + 独立脱敏手机号”锁定真实合同，新增有值、解析及空值兜底回归；邀请页面 48 项、静态分析和 Figma `43:2222` 的 375×812 Golden 对照通过。其他 App 客户端、数据库和线上环境未改。

## App Store Release 本地网络权限整改（2026-09-16）

本轮为独立 iOS 上架修复：正式环境仅连接公网 HTTPS，因此删除 `AppDelegate` 中无条件的 `_http._tcp` Bonjour 扫描，并从源 `Info.plist` 删除本地网络权限与 Bonjour 声明。Release 构建产物不包含 `NSBonjourServices`、`NSLocalNetworkUsageDescription` 或 `NSAllowsLocalNetworking`；Debug 构建仍由 Flutter 工具自动注入 `_dartVmService._tcp` 调试声明。本次不改内购开关、StoreKit 链路、页面、接口或后端。

验证：`plutil` 源文件与 Release 产物检查通过；iOS Release 无签名构建、iOS Simulator Debug 构建及 `flutter analyze --no-pub` 通过。未生成签名 IPA、未上传 App Store Connect、未真机验收，不推进邀请提现主计划状态。
