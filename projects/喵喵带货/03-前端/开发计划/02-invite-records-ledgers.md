# Flutter 模块 02：邀请记录与佣金明细

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F004`
> 工程：`/Users/soul/code/lxwx/catseller`

## 1. 功能定位与边界

升级 P03/P04，将邀请关系和直接首单佣金做成可分页、可恢复、可脱敏的只读列表。只显示直接奖励与会员退款冲正；不显示二级/团队佣金，不将提现扣款/退票返还伪装成佣金流水。

数据库改动：无。

## 2. 入口、路由与页面文件

- P03：`/invite/records`，`lib/pages/invite/records/`。
- P04：`/invite/ledgers`，`lib/pages/invite/ledgers/`。
- 两页均从 P01 明确入口进入，页内不导航到旧代理等级页。

## 3. 依赖前置

- [00-invite-contract-routing.md](./00-invite-contract-routing.md) 中 records/summary/ledgers 契约完成。
- Java `T-B003/T-B004/T-B007` 提供首单转化、冲正和服务端分页。

## 4. 视觉参考与设计稿分析

- P03：[邀请记录](../../01-需求/references/images/invite-withdrawal/06-invite-records.png)，Figma `43:2222`。
- P04：[佣金列表](../../01-需求/references/images/invite-withdrawal/07-commission-list.png)、[佣金空态](../../01-需求/references/images/invite-withdrawal/22-commission-empty.png)，Figma `43:2285/3403`。

P03 从上到下：导航栏、全部/已开通/未开通 Tab、头像/脱敏用户行、时间与会员状态；图中统一写“开通时间”，目标按 PRD/API 区分绑定时间与会员状态。P04 从上到下：累计收益及待结算/已入账摘要、全部/待结算/已入账筛选、有符号金额流水；空态包含“去邀请好友”按钮并跳 P02。图中“会员订单通过后自动入账”以最新确认口径为准：付款成功后等待后台配置的 N 天，到期才可提现；保存订单原结算时间，显示预计结算时间与退款后的待结算净额。冲正、负余额和分页错误由 PRD 补充。

## 5. 涉及模块与类

- `InviteRecordsController/View`：服务端筛选、分页、刷新和错误恢复。
- `InviteLedgersController/View`：汇总+流水、正负格式和负余额提示。
- `InviteRecord`、`InviteEarningSummary`、`InviteEarningLedger`、`InviteLedgerKind`。
- 复用现有列表、下拉刷新、加载、空态和错误组件。

## 6. 业务内容与数据流

1. P03 Tab 依次对应 `ALL/OPENED/NOT_OPENED`，每次切换都取消/忽略旧请求并重请第一页，不对已加载数据本地过滤。
2. P04 先加载 summary，再加载流水；列表失败不清空已有汇总/列表。
3. JSON `DIRECT_REWARD/REFUND_REVERSAL` 分别映射 Dart `directReward/membershipRefundReversal`；前者显示正号，并以可空 `productName` 显示“好友开通月卡/季卡/年卡”或兜底“好友开通会员”，后者显示负数和“会员退款冲正”。
4. 用户、手机、订单信息只显示服务端脱敏值，不在 Flutter 通过完整值再脱敏。

## 7. 现有工程参考点

复用 `records` 和 `ledgers` 的页面拆分、分页和刷新方式；删除/隐藏旧间接佣金 UI 时先检查其他 capability 的兼容路径，不破坏 `LEGACY` 响应解析。

## 8. 建议实现步骤

1. 用 fixture 先固定分页、空页和冲正契约。
2. 重构 P03 筛选为服务端分页，补快速切 Tab 竞态。
3. 重构 P04 类型、金额与负余额表达。
4. 补加载/空/错误/刷新/分页失败状态。

## 9. 详细编码任务清单

- [x] `T-F004-01` 完成 P03 三筛选服务端分页。
- [x] `T-F004-02` 完成 P04 直接奖励与退款冲正显示。
- [x] `T-F004-03` 完成负余额、空态和分页错误恢复。
- [x] `T-F004-04` 补 Controller/Widget 竞态、脱敏和未知类型测试。

## 10. 验收标准

1. 快速切换 P03 Tab 不会回填旧筛选数据。
2. 重复刷新/翻页不重复行，失败不丢已加载数据。
3. P04 只出现直接奖励和冲正，负数、负余额与空态正确。
4. 列表不含完整手机、身份证或银行卡。

## 11. 编码注意事项

分页参数统一为现有接口的 `page/pageSize`，编码时用 OpenAPI 验证。未知流水类型显示“记录处理中”并允许刷新，不猜测资金语义。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。

## 好友手机号展示增量（2026-09-02）

- 共享流水响应增加可空 `sourcePhoneMasked`；Flutter 只消费服务端脱敏值，不接收完整手机号或自行重建脱敏内容。
- P04 数据行显示“脱敏手机号 · yyyy.MM.dd”；手机号为空时只显示日期，期初余额等无来源用户流水保持可展示。
- model 解析、有值/空值 Widget 回归及 `07-commission-list` Golden 已更新；邀请页面 41 项与静态分析通过。其他 App 页面、佣金状态和金额语义未改。

## 卡种标题展示增量（2026-09-02）

- 共享列表项新增可空 `productName`，来源是当前 App 支付订单已有的不可变商品名称快照；软删除订单仍可读取，缺失订单为空，不在客户端按金额推断。
- Catseller 的 `DIRECT_REWARD` 有值时显示“好友开通${productName}”，缺失时显示“好友开通会员”；旧“直接邀请首单奖励”不再出现。退款冲正、间接收益和期初余额文案保持不变。
- fixture 和 Model/Widget 测试覆盖月卡、季卡、年卡与空值；邀请页 49 项和静态分析通过，`07-commission-list` Golden 已按 Figma `43:2285` 更新并目视复核。数据库改动：无，其他 App 客户端未改。

## 邀请记录手机号展示增量（2026-09-02）

- 共享邀请记录响应增加可空 `inviteePhoneMasked`；Catseller 只消费服务端脱敏值，不接收完整手机号或根据用户 ID 猜测手机号。
- P03 首行优先显示 `138 **** 1234`；手机号为空或用户缺失时保留既有 `inviteeName`，不影响整页、筛选或分页。
- fixture 不再把手机号伪装进 `nicknameMasked`，而是固定“好友占位名 + 独立手机号字段”；model、有值/空值 Widget 回归及 `06-invite-records` Golden 已更新。邀请页面 48 项和静态分析通过，其他 App 页面未改。

## 邀请记录已开通状态修复（2026-09-02）

- 根因是前后端状态值口径脱节：服务端用 `OPENED/NOT_OPENED` 筛选并返回列表项，App 行标签仍比较历史结算值 `SETTLED`；所以记录属于已开通分页，但行内走入未开通分支。
- `InviteRecord` 现用 `isMemberOpened` 收口语义，当前 `OPENED` 与旧版 `SETTLED` 均为已开通；View 的标签文案、底色和文字色不再各自比较原始字符串。
- 测试数据已使用当前合同 `OPENED/NOT_OPENED`，另保留 `SETTLED/PENDING` 兼容断言。邀请专项 53 项、指定列表 Widget 用例、静态分析及差异检查通过。未修改后端、数据库、配置或运行进程，需更新 App 后真机复验。
