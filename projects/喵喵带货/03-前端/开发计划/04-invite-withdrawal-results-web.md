# Flutter 模块 04：提现记录、结果与活动规则 Web

> 2026-09-03 配置迁移与环境根地址修复：`constants.dart`、`privacy_consent.dart` 已正式迁入 `lib/config/`，不保留 utils 兼容导出。`Global` 原环境配置块保持不变，P09 及其他 `legalPageUrls` 按 `Global.currentServerAddressType` 直接生成当前构建环境最终 URL：local/test 使用测试站，production 使用正式站；不再读取 API baseUrl 或二次换域名。页面 path/query 保持，活动规则直接包含 `appCode=catseller&embedded=1&v=20260828-display`。阿里云一键登录协议链接同步直接读取 map；代码回归、analyze 与 Android Debug APK 构建通过，真机待安装新包复验。

> 2026-08-28 最新用户澄清：规则正文默认可见，接口只异步补充有效参数；任何活动/通道状态及请求失败均不得阻断正文，保留非阻断重试和通用参数说明。App 规则入口及 Web 脚本增加显示版本以区分旧缓存，其他业务门禁不变。该条覆盖此前依赖接口成功才展示的约束；验证见 workflow.md「规则正文先显示、动态参数异步补充」。

> 2026-08-28 用户已授权的最新增量约束：本轮 P09 增量只调整当前 API 环境对应的规则 URL，不恢复专用页面/Controller，不改变工猫 H5 或账号门禁；下文固定正式站的旧约束由本条取代。 实施与验收记录见工作区 `workflow.md`「邀请业务与提现通道解耦」；主流程保持 waiting_review。

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F007`、`T-F008`
> 工程：`/Users/soul/code/lxwx/catseller`

## 1. 功能定位与边界

实现 P07 提现记录、P08 提现详情/结果和 P09 活动规则 Web。九态、费用、失败、返还和时间线全部以服务端为真值；“申请已提交”不等于已到账。P09 按 2026-08-28 最新要求直接复用 `StaticPageView`，不内置正式规则正文，也不复用工猫专用 H5 容器。

数据库改动：无。

## 2. 入口、路由与页面文件

- P07：`/invite/withdrawals`，升级 `lib/pages/invite/withdrawals/`。
- P08：`/invite/withdrawals/:id`，新增 `lib/pages/invite/withdrawal_result/`。
- P09：保留 `/invite/rules` 及原入口门禁，路由直接显示 `StaticPageView(pageKey: 'invite-rules')`；复用 `lib/pages/webview/`，删除 `lib/pages/invite/rules/` 专用文件。
- P07 行点击进 P08；P05 创建成功 replace 进 P08；P01 活动规则进 P09。

## 3. 依赖前置

- [00-invite-contract-routing.md](./00-invite-contract-routing.md) 的九态、详情和路由完成。
- Java [04-gongmall-callback-reconcile.md](../../04-后端/开发计划/04-gongmall-callback-reconcile.md) 提供最终状态和时间线。
- Admin/Web [03-activity-rules-web-tests.md](../../04-后端/开发计划/admin/03-activity-rules-web-tests.md) 将页面发布到测试/正式站 `/legal/invite-rules/index.html`，公开动态规则接口可用。App URL 集中维护于 `AppConstants.legalPageUrls['invite-rules']`，不再依赖后端提供地址。

## 4. 视觉参考与设计稿分析

- P07：[09-withdrawal-records.png](../../01-需求/references/images/invite-withdrawal/09-withdrawal-records.png)，Figma `43:2425`。
- P08：[20-withdrawal-submitted.png](../../01-需求/references/images/invite-withdrawal/20-withdrawal-submitted.png)、[21-withdrawal-not-received.png](../../01-需求/references/images/invite-withdrawal/21-withdrawal-not-received.png)，Figma `43:3257/3338`。
- P09：[19-activity-rules.png](../../01-需求/references/images/invite-withdrawal/19-activity-rules.png)，Figma `43:3167`。

P07 从上到下：导航、累计提现卡、全部/处理中/已到账/失败筛选、提现行（金额、卡、时间、用户态）。P08 提交态从上到下：状态图标/标题、金额、时间线、脱敏卡/费用卡、完成按钮；失败态改为安全原因、返还提示、卡/申请与处理时间。图中顶部“提现成功”与中央“提交申请已提交”冲突，目标只能按服务端状态命名；图中到账短信不属于本期承诺。P09 的内容层级由外部 Web 实现，App 仅提供标题、返回、加载和错误。

## 5. 涉及模块与类

- `InviteWithdrawalsController/View`：分组筛选、分页和列表状态。
- `InviteWithdrawalResultController/View`：详情、时间线、轮询、手动刷新和可操作项。
- `WithdrawalTimeline`：使用服务端事件渲染，未知事件安全兜底。
- `StaticPageView/Controller`：直接读取 `AppConstants.legalPageUrls['invite-rules']`（包含 `appCode=catseller&embedded=1&v=20260828-display`），共享静态页面的标题、加载、错误重试和返回；不新增规则 Controller，不请求 capability/overview 获取 URL。

## 6. 业务内容与数据流

1. P07 筛选使用服务端定义的状态分组；切换重请第一页，不本地筛选。
2. P08 展示 `displayStatus/displayMessage/availableActions`，本地枚举只做离线兜底。
3. `APPROVED/SUBMITTING/PROCESSING/RECONCILING` 前台可见时 3～5 秒起步并退避轮询；后台、离页或终态立即停止，resume 立即刷新。
4. `FAILED` 显示安全失败原因和余额已返还；`RETURNED` 明确银行退票且余额已返还；`RECONCILING` 不得诱导重复申请。
5. P09 使用 `legalPageUrls` 中当前构建环境的最终地址：local/test 为测试站，production 为正式站，查询参数固定为 `appCode=catseller&embedded=1&v=20260828-display`。复用 `StaticPageView` 的现有浏览行为，不再单独使用 `InviteWebPolicy`，也不修改共享静态页策略。不注入 JWT/敏感信息；页面内的 N 天和最低额继续由公开接口动态读取。

## 7. 现有工程参考点

复用现有 withdrawals 列表骨架、生命周期观察和 `pages/webview/StaticPageView`，不为规则页另建页面或 Controller。

## 8. 建议实现步骤

1. 先写九态/未知态/分组映射和时间线测试。
2. 升级 P07 列表分页和点击导航。
3. 新增 P08 详情、时间线、轮询与生命周期。
4. P09 直接复用通用静态页，验证固定地址、标题和原有路由门禁；工猫白名单保持独立。

## 9. 详细编码任务清单

- [x] `T-F007-01` 完成 P07 九态分组列表与分页。
- [x] `T-F007-02` 完成 P08 详情、费用、脱敏卡和时间线。
- [x] `T-F007-03` 完成可见轮询、退后台停止、resume 刷新与终态停止。
- [x] `T-F008-01` P09 路由直接使用 `StaticPageView`，地址在统一常量中维护。
- [x] `T-F008-02` 复用静态页加载/失败/重试/返回，保留既有入口门禁；不新建规则状态机。

## 10. 验收标准

1. 九态和未知态不混淆，提交/处理中不显示到账成功。
2. 页面不可见、App 后台或终态时无轮询泄漏；resume 可刷新最新状态。
3. 失败和退票文案与余额返还真值一致，不暴露工猫原始报文。
4. P09 只能由固定 `pageKey: invite-rules` 读取统一常量，不接受路由查询参数覆盖为其他页面或任意 URL，不向 Web 注入会话。
5. P09 使用 `legalPageUrls` 最终地址；运行中的 API 地址、overview URL 缺失、异常或返回其他域名均不能改变该地址。页面加载和重试由现有 `StaticPageView` 处理；独立超时和外链白名单不是该组件当前提供的能力，不保留过期验收声明。

## 11. 编码注意事项

列表与详情冲突时以详情更新的 `updatedAt/version` 为准。活动规则最终地址固定在 App 常量中并随构建环境选择测试/正式根地址；不增加服务端地址兜底，不改变其他 App、工猫 H5 白名单或动态业务参数。

## 配置正式迁移回写（2026-09-03）

- `lib/utils/constants.dart`、`lib/utils/privacy_consent.dart` 已迁移到 `lib/config/` 并由 `config/index.dart` 聚合；实际使用方显式导入 config，utils 仅内部导入且不导出。隐私同意版本 2、存储键及状态行为未变。
- `Global.currentServerAddressType` 继续统一控制 API 与静态页面环境，三个地址引用保持原样。`legalPageUrls` 直接包含最终 URL，已删除 `resolveLegalPageUrl`。
- `StaticPageController` 和阿里云原生授权页直接读取 map；`AliyunNumberAuthService` 恢复无 `apiBaseUrl` 构造参数。
- 协议/邀请定向 69 项、登录 Widget 2 项、`flutter analyze` 与 Android Debug APK 构建通过。最新全量 342 通过、7 个既有 Golden 失败；未修改这些无关基线，未部署或安装 APK。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。

## P09 地址调整回写（2026-08-28，专用容器部分已被下方简化记录取代）

- `AppConstants.legalPageUrls` 新增 `invite-rules` 正式地址，`legalPageTitles` 同步登记“活动规则”。`InviteRulesController` 直接读取并附加 `embedded=1`；删除取地址的 API 调用、加载状态和重试分支，网页自身的加载/失败/超时/重试继续由 `InviteControlledWeb` 负责。
- 新增 `test/invite_rules_url_test.dart` 三项回归：正式常量登记；本地/测试 API 不可用时地址仍立即确定且无 HTTP 请求；App 标识、嵌入参数与 HTTPS 白名单不变。
- `flutter test --no-pub test/invite_rules_url_test.dart test/invite_bank_flow_test.dart test/invite_contract_types_test.dart test/app_identity_test.dart --reporter expanded`：46 项通过；`flutter analyze --no-pub`：无问题；已格式化改动 Dart 文件。
- 单独执行 `test/widget_test.dart` 的 `legal page constants expose production catseller urls`：改动前和改动后均因既有客服地址 `/legal/catseller/customer-service/` 与实际 `/miaomiao-commerce/customer-service/` 不一致而失败。本次仅补上活动规则常量预期，未修改无关客服地址或抹去失败。
- 只读正式站检查：规则 HTML 返回 200 且内容确为活动规则；`/api/config/invite-rules` 带 `X-App-Code: catseller` 返回 `code=-404 / 资源不存在`。因此固定地址已实现，但完整线上规则内容仍待对应后端接口发布和原生 WebView 联调；未自动部署，不声明线上验收完成。
- 数据库改动：无；其他 App、共享后端/Admin 配置和业务参数未修改。

## P09 StaticPageView 简化回写（2026-08-28）

- 保留原 `/invite/rules` 路由及账号门禁，生产 `pageBuilder` 直接返回 `StaticPageView(pageKey: 'invite-rules')`；首页“活动规则”和提现页“提现规则”入口无需改变。
- 删除 `pages/invite/rules/{index,controller,view}.dart` 三个已被复用组件替代的文件，Git 历史可恢复；移除对应 import，工猫 `InviteControlledWeb` 保持不变，通用 `StaticPageView` 本身不改。
- `embedded=1` 写入 `legalPageUrls['invite-rules']`，无单独拼接 Controller。规则页加载、错误与重试沿用通用组件，不将工猫容器的白名单、超时或遮罩声明为通用组件已提供的能力。
- 更新 3 项专项测试，验证固定常量、生产路由直接返回通用页面且查询参数不能覆盖 pageKey、原有账号门禁不变；加上邀请与 App 身份回归共 46 项通过，`flutter analyze --no-pub` 通过。
- 本轮未挂载原生 WebView 验收或再次验证正式 API；此前动态规则接口 404 的上线问题不会因换容器自动解决。既有全局客服 URL 断言问题仍按上一轮记录，不顺带处理。
- 用户正在修改的全局环境、素材页/二维码及目录规则其他内容保留；未改 Web 正文、后端、Admin 或数据库。
