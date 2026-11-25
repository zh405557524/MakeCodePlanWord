# Flutter 模块 01：邀请有礼与邀请好友

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F002`、`T-F003`
> 工程：`/Users/soul/code/lxwx/catseller`

## 2026-09-02 一级佣金展示校准

- P01 只展示当前生效的一级佣金比例、一级三档比例和真实有效直邀人数进度，不展示后台团长、二级代理、二级佣金、人工、自动、保底等身份或来源信息。
- `InviteOverview` 不保留自动等级、人工保底、等级模式、二级资格或二级比例字段。后台调整用户一级佣金等级后，App 只消费最终 `agentLevel/directCommissionRate`；真实人数继续独立驱动两段进度。
- 动态三档缺失时回退 10%/20%/30%；“最高奖励”和下一档提示不写死。二级关系收益明细只显示通用“推广奖励”及金额，不展示二级档位比例。
- 本增量无 App 数据库、配置或写接口改动，不部署、不做线上配置或历史订单重算。

## 1. 功能定位与边界

在现有邀请首页和素材页上实现 P01/P02。P01 是汇总与六个业务入口；P02 就是现有“推广素材”页，产品标题统一为“邀请好友”。不新增平行素材页，不由客户端拼邀请链接或佣金规则。

数据库改动：无。

## 2. 入口、路由与页面文件

- P01：`/invite`，现有 `lib/pages/invite/{index.dart,controller.dart,view.dart}`。
- P02：`/invite/materials`，现有 `lib/pages/invite/materials/`与 `poster_export.dart`。
- P01 CTA“立即邀请 赚钱佣金”必须跳 P02。
- P01 其他入口：邀请记录、佣金明细、提现、提现记录、活动规则。

## 3. 依赖前置

- [00-invite-contract-routing.md](./00-invite-contract-routing.md) 完成 overview/materials model 与 API。
- Java `GET /api/invite/overview`、`GET /api/invite/materials` 可用。
- 复用工程现有分享、保存相册、二维码和权限能力。

## 4. 视觉参考与设计稿分析

- P01：[10%](../../01-需求/references/images/invite-withdrawal/01-invite-level-10.png)、[20%](../../01-需求/references/images/invite-withdrawal/02-invite-level-20.png)、[30%](../../01-需求/references/images/invite-withdrawal/03-invite-level-30.png)，Figma `43:1638/1754/1870`。
- P02：[邀请好友](../../01-需求/references/images/invite-withdrawal/05-promotion-materials.png)，Figma `43:2118`。

P01 从上到下：导航栏（右侧活动规则）、活动 Banner、可提现/待结算/累计收益卡、当前档位与两段进度卡、主 CTA、累计邀请/已开会员统计卡、邀请记录/佣金明细/提现记录三行入口；立即提现在收益卡内。档位间颜色必须按真实人数逐步向前：第一段 `clamp(count,0,10)/10`，第二段 `clamp(count-10,0,10)/10`。图中人数与“再邀请”示例不完全一致，目标版本只用服务端真实人数和下一档差值。

P01 顶部不是纯白：状态栏与导航栏使用背景组 `43:1639` 的五段暖粉底色和白色渐隐，深色标题/系统图标。采用原图按宽度缩放、顶部取景，加载、错误、滚动及返回后保持；仅作用于 P01，不全局改变邀请子页或其他 App。

P02 从上到下：页面标题、方法一“分享链接”卡与复制按钮、方法二“分享海报”预览卡与保存按钮。图中标题仍为“推广素材”，目标版本统一“邀请好友”；系统分享复用现有能力。图中链接和海报为示例，实际内容以服务端为准。

## 5. 涉及模块与类

- `InviteController`：加载 overview，管理 loading/content/error 和六入口。
- `InviteMaterialsController`：加载服务端素材，协调复制、分享和保存。
- `InviteLevelProgress`：新增邀请模块内聚组件，只负责显示。
- 复用 `InviteOverview`、`InviteMaterial`、`InviteAPI`、现有主题/加载/错误组件。

## 6. 业务内容与数据流

1. P01 进入后请求 overview，直接渲染 `effectiveInviteCount/currentRatePercent`、两段进度、收益和 capability。
2. 可提现余额为负时保留负数与“后续奖励优先抵扣”，禁用提现但不禁用记录/明细。
3. 素材按需在 P02 加载，不在 P01 预下载大海报。
4. 复制、分享、保存独立返回成功/失败；相册权限拒绝不影响链接复制和系统分享。

## 7. 现有工程参考点

优先在现有 `materials/controller.dart`、`view.dart`、`poster_export.dart` 增量改造，保留现有二维码、分享和图片导出方式。不从参考 App 复制业务代码。

## 8. 建议实现步骤

1. 先写 0/1/9/10/11/19/20 进度 Widget 测试。
2. 升级 P01 Controller/View 和六入口，补负余额及错误重试。
3. 升级 P02 标题和服务端素材数据流。
4. 补复制、分享、保存和权限异常反馈。
5. 对照四张图做小屏、大字体和安全区验收。

## 9. 详细编码任务清单

- [x] `T-F002-01` 完成真实进度组件与边界测试。
- [x] `T-F002-02` 完成 P01 收益、负余额和六入口。
- [x] `T-F003-01` 将素材页统一为“邀请好友”并使用服务端数据。
- [ ] `T-F003-02` 完成复制/分享/保存的成功、失败与权限回归。

## 10. 验收标准

1. 0/1/9/10/11/19/20 人时进度逐人前进，不按档位整段跳满。
2. P01 六个入口准确，主 CTA 只跳 P02。
3. 负余额禁止提现但保留历史查询。
4. P02 不拼用户 ID 或邀请链接，三类操作均有独立反馈。
5. P01 顶部状态栏和导航栏连续展示原稿浅暖粉背景，无白色覆盖；其他子页默认背景不变。

## 11. 编码注意事项

Figma 是布局真源，但金额、档位、URL 和入口能力以 API 为准。不因本模块改动登录、首页 Tab 或其他业务页。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。

顶部复审增量：2026-08-27 已导出并接入 `invite_header_background.png`，为 `InviteSurface` 增加可选背景且仅 P01 使用。3 张首页截图完成同轮对稿，新增 2 项顶部检查，邀请专项合计 39 项及 analyze 通过；iOS 离线预览构建、进入素材页并返回复验通过。详见上述对稿报告第 7 节，编码状态仍为 `waiting_review`，未修改后端/数据库。

## P02 HTTP 邀请链接增量（2026-08-28）

用户确认测试环境不使用 HTTPS，要求去掉推广素材链接仅限 HTTPS 的校验。`InviteMaterialsController.inviteLink` 现接受服务端 HTTP / HTTPS 链接，仍拒绝空主机、格式错误、带用户凭据及非网页协议；不重建链接或切换到正式域名。链接卡片使用 URI authority 保留 `:8080` 等端口，复制及预览/导出海报共用同一服务端链接。

本次只修改素材 Controller 和现有 `test/widget_test.dart`。不调整活动规则、认证 WebView、API 合同、后端、Admin 或 Android/iOS 配置；保留工作区原有及并行改动。数据库改动：无。

验证：新增 HTTP 刷新场景在修复前复现链接不显示；修复后 8 项邀请相关 Widget/模型测试、42 项邀请合同/银行卡流程/规则地址测试全部通过，`dart format`、`flutter analyze --no-pub`、`git diff --check` 通过。覆盖 HTTPS 原行为、HTTP 刷新后完整地址（含端口/邀请码）、剪贴板内容、两处二维码组件及导出海报链接；无效 URL 仍返回空。此次未运行完整 Flutter 测试。

设备复验：热重载或重启后重新打开邀请好友页，确认接口返回的 HTTP 链接可见，复制与海报二维码保留端口和邀请码。真实手机扫码、相册保存、局域网落地页可达性仍待验证；本轮不勾选 `T-F003-02`，主流程继续保持 `waiting_review`。
