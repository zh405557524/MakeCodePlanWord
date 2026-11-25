# 邀请好友与银行卡提现 · App/Figma 对照验收

## 2026-09-02 P04 好友手机号复核

- 设计真源：Figma `43:2285`，375×812；实现证据：`/Users/soul/code/lxwx/catseller/test/goldens/invite/07-commission-list.png`，同为 375×812、1×。
- 首轮确认现有佣金行只有时间，缺少好友手机号；实现后两条数据均显示“服务端脱敏手机号 · yyyy.MM.dd”，空值只显示日期。全页与列表区域已放入同一比较输入复核，没有新增 P0/P1/P2。
- 字体、11sp 次要色、行距和现有图标未改；动态结算时间及“直接邀请首单奖励”属于已确认业务扩展，不压缩回 Figma 示例会员卡文案。
- 邀请页面 41 项和 `flutter analyze --no-pub` 通过；未进行真机或线上接口验收。

final result: passed

## 2026-09-02 P06 协议区复核

- 当前设计真源为通道 `x5x4ir6u` 的 `66:120`。P06 底部已按“主体锁定提示→签署按钮→默认未勾选协议区”实现，协议原文在 375 宽完整显示；小屏和字体放大允许自然换行。
- 页面复选框是唯一确认入口。未勾选、表单不完整或照片未完成均不创建认证会话；旧 `43:2565` D02 弹窗及其本地截图只保留历史追溯，不再属于当前验收流程。
- 当前截图：[标准页](/Users/soul/code/lxwx/catseller/test/goldens/invite/split-identity.png)、[小屏键盘](/Users/soul/code/lxwx/catseller/test/goldens/invite/split-identity-keyboard.png)、[错误态](/Users/soul/code/lxwx/catseller/test/goldens/invite/split-identity-error.png)。邀请相关 86 项与静态分析通过，真实 H5/真机仍待验收。

## 2026-08-31 实名/绑卡拆分复核

新稿66:120/66:198替代旧合并认证表单和结果页；已在同一比较输入中打开原稿与实现，修正输入卡间距、字重、提示卡和错误可见性，并复查小屏键盘。当前本地Widget QA通过，不等同于真机/工猫验收。完整五类复核、差异及截图见 [当前Design QA](/Users/soul/code/lxwx/catseller/design-qa.md)，测试统计与恢复点见 [拆分验证](../05-联调与测试/invite-identity-bank-split-verification.md)。下方2026-08-27图及原生验收为历史记录，不作为本次真实设备证据。

> 2026-08-27 / CHG-0068 / `waiting_review`
> 设计源：用户最新通道 `mj5kz8uv`，页面 `39:95`。检查范围仅邀请、佣金、实名/银行卡、提现和活动规则，不涉及其他产品页面。

## 1. 检查方法与结论

22 个设计状态均有对应实现截图，并把原图和实现截图放在同一轮比较后修正。21 张为生产 Flutter Widget 的可重复截图；19 为生产规则 HTML 在浏览器中以 375px 内容宽度运行的截图。Flutter 视口采用 375×812；邀请首页为 375×920，保留 44/34 安全区。Widget 测试不伪造系统时间/电池，字体使用本机中文字体，不能称为逐像素完全一致。

另在 iPhone 17 Pro / iOS 26.4 模拟器通过真实页面操作邀请→推广素材、提现输入→税费试算→协议勾选→提交→结果。使用 `test/invite_preview.dart` 离线入口和虚构数据，所有 HTTP 被测试适配器接管，**不是已登录生产 App 或真实工猫验收**。

本地核心页面及导航可评审；真实 H5/摄像头、银行卡、签署、打款与退票仍等待配置和双平台真机联调。

## 2. 对照清单

| 页面/状态 | Figma 节点 | 设计图 | 本地实现图 |
|---|---|---|---|
| 邀请有礼 10%/零余额 | 43:1638 | [原图](../01-需求/references/images/invite-withdrawal/01-invite-level-10.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/01-invite-level-10.png) |
| 邀请有礼 20% | 43:1754 | [原图](../01-需求/references/images/invite-withdrawal/02-invite-level-20.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/02-invite-level-20.png) |
| 邀请有礼 30% | 43:1870 | [原图](../01-需求/references/images/invite-withdrawal/03-invite-level-30.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/03-invite-level-30.png) |
| 实名说明弹窗 | 43:1989 | [原图](../01-需求/references/images/invite-withdrawal/04-realname-policy-dialog.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/04-realname-policy-dialog.png) |
| 邀请好友/推广素材 | 43:2118 | [原图](../01-需求/references/images/invite-withdrawal/05-promotion-materials.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/05-promotion-materials.png) |
| 邀请记录 | 43:2222 | [原图](../01-需求/references/images/invite-withdrawal/06-invite-records.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/06-invite-records.png) |
| 佣金明细 | 43:2285 | [原图](../01-需求/references/images/invite-withdrawal/07-commission-list.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/07-commission-list.png) |
| 未绑卡提现 | 43:2362 | [原图](../01-需求/references/images/invite-withdrawal/08-withdrawal-unbound.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/08-withdrawal-unbound.png) |
| 提现记录 | 43:2425 | [原图](../01-需求/references/images/invite-withdrawal/09-withdrawal-records.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/09-withdrawal-records.png) |
| 实名绑卡表单 | 43:2504 | [原图](../01-需求/references/images/invite-withdrawal/10-withdrawal-auth-form.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/10-withdrawal-auth-form.png) |
| 协议确认 | 43:2565 | [原图](../01-需求/references/images/invite-withdrawal/11-agreement-confirm-dialog.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/11-agreement-confirm-dialog.png) |
| 绑卡成功 | 43:2639 | [原图](../01-需求/references/images/invite-withdrawal/12-bank-bind-success.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/12-bank-bind-success.png) |
| 认证成功 | 43:2716 | [原图](../01-需求/references/images/invite-withdrawal/13-certification-success.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/13-certification-success.png) |
| 绑卡失败 | 43:2793 | [原图](../01-需求/references/images/invite-withdrawal/14-bank-bind-failure.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/14-bank-bind-failure.png) |
| 认证失败 | 43:2872 | [原图](../01-需求/references/images/invite-withdrawal/15-certification-failure.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/15-certification-failure.png) |
| 提现填写 | 43:2951 | [原图](../01-需求/references/images/invite-withdrawal/16-withdrawal-form.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/16-withdrawal-form.png) |
| 超过可提现额 | 43:3014 | [原图](../01-需求/references/images/invite-withdrawal/17-withdrawal-excess.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/17-withdrawal-excess.png) |
| 银行卡选择 | 43:3079 | [原图](../01-需求/references/images/invite-withdrawal/18-bank-selection.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/18-bank-selection.png) |
| 活动规则 Web | 43:3167 | [原图](../01-需求/references/images/invite-withdrawal/19-activity-rules.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/19-activity-rules.png) |
| 申请提交待审核 | 43:3257 | [原图](../01-需求/references/images/invite-withdrawal/20-withdrawal-submitted.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/20-withdrawal-submitted.png) |
| 未到账/失败 | 43:3338 | [原图](../01-需求/references/images/invite-withdrawal/21-withdrawal-not-received.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/21-withdrawal-not-received.png) |
| 佣金空状态 | 43:3403 | [原图](../01-需求/references/images/invite-withdrawal/22-commission-empty.png) | [实现](/Users/soul/code/lxwx/catseller/test/goldens/invite/22-commission-empty.png) |

## 3. 本轮已修正的差异

- P01：使用 Figma 礼盒/飘带/金币素材，真实人数逐人填充连线，当前等级高亮，提现渐变按钮；六入口指向各自页面，主 CTA 进入“邀请好友”。
- P02/P03/P04：推广素材命名统一、服务端链接及动态二维码；邀请记录显示真实汇总数量和服务端筛选；待结算、冲正、负余额、期初转入分别显示。佣金空态替换为原稿钱包素材及描边邀请按钮。
- P05/P06：绑卡素材及已知银行图标、表单间距、选卡弹层/关闭/默认/删除/新增；超额金额红框、底部协议与 CTA 可见；认证说明/协议弹窗由默认紫色样式改为原稿白色圆角、居中标题及渐变胶囊按钮。
- P07/P08：提现记录补齐钱包头图、描边卡片和状态标签；结果使用真实九态、费用和事件时间线，不以“申请已提交”冒充已到账。
- P09：活动规则使用五类原稿图标和卡片、按 App 请求动态 N/最低额；App 容器内隐藏重复标题，独立浏览保留标题。
- 小屏/放大字体可滚动，无核心操作被固定底栏永久遮挡；选择银行卡与协议均可取消。

## 4. 与设计示例的必要差异

1. 不写死示例金额、手机号、银行卡、会员人数、未来时间。卡列表条数/弹层高度由数据决定，不以不相符银行 Logo 冒充真实银行。
2. 人工审核、待查单、失败/退票、退款冲正、N 天待结算和动态最低额来自已确认需求；新增费用行和确认提示使部分页面更长，允许滚动。
3. 删除设计中无官方接口支撑的银行卡短信验证码；核身和完整合同由工猫 H5 承担，不能用自有页面假签署。
4. 提交/失败详情标题均为“提现详情”；只有确认到账才展示成功。未确定的网络结果不展示“失败已返还”。
5. 系统字体、系统状态栏、不同手机安全区、细阴影仍有平台差异；本轮不是 100% 像素一致或所有设备实机通过的声明。规则正文按用户新增业务约束扩展，不能压缩回设计示例的旧文案。

## 5. 操作和安全回归

自动化覆盖真实进度 0/1/9/10/11/19/20、六入口、服务端筛选竞态、脱敏选卡、协议取消/确认、身份输入清理、动态最低额、试算旧响应丢弃、提交超时复用原幂等键、轮询后台暂停/终态停止、未知状态、HTTPS 白名单和小屏大字体。

原生截图：[邀请首页](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/home.png)、[邀请好友](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/materials.png)、[提现填写](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/withdrawal-form.png)、[100 元申请待审核](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/withdrawal-submitted.png)。最新结果截图/验收统计见 [本地三端验证报告](../05-联调与测试/invite-withdrawal-local-verification.md)。

## 6. 复现与待验收

`flutter test --no-pub test/invite_bank_flow_test.dart test/invite_contract_types_test.dart` 可执行契约/页面测试；`--update-goldens` 仅在人工确认视觉变更后使用，不以更新基线代替对稿。

真机验收待用户补充共享工猫配置后进行：H5 断网/中断恢复、摄像头权限拒绝/授权、签署确认、默认卡/删卡、真实税费、审核及回调、成功后退票。App 全量测试中其他模块的失败见验证报告，未擅自改动其业务。

## 7. P01 顶部颜色复审增量（2026-08-27）

本节只验收用户指出的「邀请有礼状态栏/导航栏不是纯白」差异，不重新宣称整个页面逐像素一致。流程状态保持 `waiting_review`。

### 7.1 视觉证据和范围

- 设计真源：`mj5kz8uv` / `43:1638`，顶部背景组 `43:1639`。`43:1640` 为五段暖粉底色（0% `#FCF8F9`、25% `#FDF9F8`、50% `#FCF8F9`、75% `#FDF9F8`、100% `#FDF9F9`），`43:1641` 为透明白色向不透明白色的纵向渐隐。
- 直接使用背景组的原始 3x PNG（1125×1083，对应 375×361 逻辑尺寸），只含背景，不包含时间、电量、标题或按钮；按宽度缩放、顶部对齐，不能把整张渐隐图压缩成导航栏高度。
- 全页同轮比较：上表 01/02/03 的 Figma 原图与更新后的 Flutter 截图均为 375×920、1x。顶部安全区 44、导航栏 44；数据为测试夹具，不将示例金额/人数不同记为颜色缺陷。
- 局部同轮比较：[Figma 顶部 375×88](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/header-figma-crop.png) 与 [Flutter 顶部 375×88](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/header-widget-crop.png)。两图均从上述全页无缩放裁切，用于检查浅色渐变和与 Banner 的边界。
- 原生补充证据：[iOS 邀请首页](/Users/soul/code/lxwx/catseller/test/goldens/invite/native/home-header.png)，iPhone 17 Pro / iOS 26.4，1206×2622 像素、402×874 逻辑尺寸、3x。该设备安全区和设计稿不同，只检查真实系统图标、背景覆盖及导航返回，不声称与 375px 稿逐像素一致。

### 7.2 差异、修复与复验

1. 首轮发现 `[P2]`：`InviteSurface` 的白色 AppBar 覆盖了原稿暖粉底色，状态栏与导航栏看起来是纯白，结论为 `blocked`。
2. 修复：为现有组件增加可选 `appBarBackground`，仅 P01 传入原图；设置透明 AppBar/状态栏和深色系统图标。底图显式填满 AppBar，避免空尺寸导致仍显示白色。未启用该参数的页面保持原表现。
3. 修复后重新生成 01/02/03 截图，与设计原图及局部裁切在同一轮比较；顶部浅暖粉色连续，无白色横条或背景拉伸。先确认视觉变更，再用普通测试验证更新后的基线，未以更新 golden 本身作为通过依据。
4. 模拟器操作：进入邀请有礼 → 点击主 CTA 进入邀请好友 → 返回；页面正常、顶部颜色保持。使用 `test/invite_preview.dart` 离线入口和虚构数据，不调用真实提现或工猫服务。

### 7.3 五类视觉检查

| 检查面 | 本次结论 |
|---|---|
| 字体与排版 | 标题、活动规则文字仍为深色，可读性正常；未更换字体。Widget 不绘制系统时间/电池，原生截图由 iOS 绘制。 |
| 间距与布局 | 顶部仍为 44+44，未推移 Banner 和正文；返回按钮位置及平台字体度量等既有细微差异不在本次改动范围。 |
| 颜色与令牌 | 使用原始五段底色与白色渐隐合成图；状态栏和导航栏连续，滚动不触发 Material 着色。 |
| 图片质量 | 原稿 3x 导出、按宽度取景，没有拉伸、文字烘焙或重复状态栏；礼盒/Banner 未改动。 |
| 文案与内容 | 标题、活动规则及各入口文案未改；金额、人数继续使用服务端/测试夹具数据。 |

### 7.4 检查结果和边界

- [x] `flutter test --no-pub test/invite_bank_flow_test.dart test/invite_contract_types_test.dart --reporter expanded`：39 项通过，包含新增 2 项顶部回归（状态栏/导航栏像素、滚动、加载/错误、记录页仍为白色）。
- [x] `flutter analyze --no-pub`：无问题。
- [x] `flutter build ios --simulator --debug --no-pub -t test/invite_preview.dart`：构建成功并安装操作复验。
- [x] 仅更新 3 张受影响的首页 golden；其余邀请页面基线仍通过，不扩展修改用户的账号页或全局配置。
- 待验收：本轮未做 Android 真机截图或真实工猫验收；正文的既有字体、图标与间距差异不属于这次顶部颜色修正的验收结论。

final result: passed
# P03 邀请记录好友手机号增量（2026-09-02）

- source visual truth：`01-需求/references/images/invite-withdrawal/06-invite-records.png`，Figma `43:2222`；implementation：`/Users/soul/code/lxwx/catseller/test/goldens/invite/06-invite-records.png`。
- 两图均为 375×812、1×；全页比较 `/tmp/catseller-invite-record-phone-compare.png`，首行聚焦比较 `/tmp/catseller-invite-record-phone-focus.png`。
- Pass 1：用户截图显示“好友7”，确认 P1 身份信息缺失。修复后 P03 首行优先显示服务端脱敏手机号，空值保留展示名；头像、Tab、时间、状态和行高未改。
- 五类表面：字体沿用 14sp/600；间距和布局不变；颜色沿用既有 token；图片资源不变；文案只将占位名替换为脱敏手机号。Figma 示例计数与 fixture 动态计数、开通时间与绑定时间属于既有数据/产品差异。

final result: passed

---
