# F-10 iOS 免注册会员购买与恢复

日期：2026-10-07。用户已确认按免注册购买、Apple IAP 购买凭证恢复方案执行。数据库改动：无；后端业务代码改动：无；正式服务器、商店与签名发布包未更新。

## 实现

- iOS 购买按钮直接执行支付，不要求用户名、邮箱或 Apple 登录；创建订单前使用已有安全存储匿名凭证取得服务端 GUEST 身份。
- 匿名身份只由主动购买/主动游客登录建立，商品浏览和后台补单默认不创建身份。失败可重试，不创建额外订单；重复点击、账号切换、服务器切换和隐私撤回仍受保护。
- 原匿名会员可凭 IAP 签名交易恢复原服务端 userId，无需本地 token/订单，不重新下单或延长到期日。真实有效权益仍由服务器验证。
- Apple 登录用于可选同步和原游客 ID 升级，已有其他账号不合并。已注册账号沿用原账号登录边界，交易凭证不用于签发可读取注册账号私人资料的会话。
- Android 保留原登录门禁；中、繁、英文文案已通过 `flutter gen-l10n` 生成。

## 行为预期（数据）与结果

| 场景 | 预期（数据） | 自动化结果 |
|---|---|---|
| 首次未登录 iOS 购买 | 匿名认证 1 次、订单 1 个、商店购买 1 次；不提交用户名/邮箱；服务器 PAID 后会员 ACTIVE，待处理订单清空 | 通过 |
| 浏览与后台补单 | 无身份时匿名认证 0 次、下单 0 次、购买 0 次 | 通过 |
| 隐私未同意 | 匿名认证/订单/商店购买均 0，会员不激活 | 通过 |
| 匿名认证网络失败后重试 | 首次下单和购买均 0；重试匿名凭证不变，最终仅 1 个订单和 1 次购买 | 通过 |
| 认证期间重复点击 | 匿名认证 1 次、订单 1 个、购买 1 次，第二次只返回处理中 | 通过 |
| 匿名响应迟到时切换账号或服务器 | 旧响应不安装，当前账号保持原值，不下单/购买 | 通过 |
| StoreKit 取消 | 原匿名 ID 保留，订单未确认 PAID，会员不激活 | 通过 |
| 失效账号或 Android 未注册 | 不创建替代匿名身份、不下单 | 通过 |
| 无本地 token/订单时 IAP 恢复 | 仅恢复签名交易，绑定原付费 GUEST ID、会员 ACTIVE、原到期日不变；匿名认证/新订单/再次购买均 0 | 通过 |
| iOS 页面成功及网络失败 | 登录路由访问 0 次，成功仅 1 次购买，失败不下单 | 通过 |
| Android 从登录页返回 | 原选中套餐和协议保留，不自动下单或购买 | 通过 |
| 原游客 Apple 升级 | 同 userId、本地数据分区保留；后端原订单行、会员权益行完全一致，不二次发放会员 | 通过 |

上述客户端商店交易和 Apple Provider 均为替身，后端集成测试使用测试数据库。自动化不等于实际 App Store 扣款或真机重装恢复。

## 命令与日志

工作目录 `/Users/soul/code/soul/Solfeggio`：

```bash
flutter gen-l10n
flutter test --no-pub test/ios_anonymous_membership_test.dart --plain-name 'first iOS purchase needs no registration and grants verified membership' --reporter expanded
flutter test --no-pub test/ios_anonymous_membership_test.dart test/payment_recovery_test.dart test/guest_login_payment_gate_test.dart test/payment_login_navigation_test.dart test/apple_login_controller_test.dart --reporter expanded
flutter test --no-pub test/payment_login_navigation_test.dart --reporter expanded
flutter analyze
flutter test --reporter expanded
flutter analyze --no-pub lib/store/user.dart lib/store/payment.dart lib/pages/payment/controller.dart lib/pages/payment/view.dart lib/generated test/ios_anonymous_membership_test.dart test/payment_login_navigation_test.dart test/payment_recovery_test.dart test/apple_login_controller_test.dart test/guest_login_payment_gate_test.dart
dart format --output=none --set-exit-if-changed lib/store/user.dart lib/store/payment.dart lib/pages/payment/controller.dart lib/pages/payment/view.dart test/ios_anonymous_membership_test.dart test/payment_recovery_test.dart test/payment_login_navigation_test.dart
git diff --check
```

- [修复前回归](before-fix.log)：首次匿名购买为 failed，成功预期不满足。
- [首轮相关测试](scoped-tests.log)：81 通过；随后增加两项 iOS 页面回归。
- [最终页面回归](navigation-tests.log)：6 通过。测试替身在异步页面回调中使用 `expect` 与 pump 冲突，改为同样断言语义的 `expectSync`；失败诊断保存在 [页面回调诊断](navigation-detail.log)，未删除业务断言。
- [完整分析](flutter-analyze.log)：19 既有提示，退出 1；练习页 unused_element 1、旧 UI 审计文件 16 条 warning、同步测试 2 条 info。本次首次分析中的新测试未使用导入已移除。
- [本次文件分析](changed-files-analyze.log)：0 问题，退出 0。
- [完整测试](flutter-test.log)：1626 通过、1 原有跳过，退出 0。
- 格式检查 7 文件、0 改写，`git diff --check` 通过。

工作目录 `/Users/soul/code/soul/service`：

```bash
./gradlew test --tests '*GuestAccountServiceTest' --tests '*SolfeggioAccountAuthIntegrationTests' --tests '*SolfeggioAppleAuthIntegrationTests'
```

[后端输出](backend-tests.log)：BUILD SUCCESSFUL；[测试结果摘要](backend-test-summary.json)：8 + 7 + 11 = 26，failure/error/skipped 均 0。未修改其他任务进行中的 Audiveris 业务或测试文件。

## 发布前仍需真机验收

1. 新安装、同意隐私后不登录 App，购买会员，确认服务器验真后可进入会员练习。
2. 同 App Store 测试账号删除 App 并重装，不登录 App，点击恢复购买，确认原匿名会员和原到期日恢复。
3. 购买后自愿选择 Apple 登录，确认升级保持原会员、订单和练习记录，不再次扣款。

本轮未创建签名发布包、未上传商店，也未执行正式数据库迁移或服务器部署。版本整体发布结论由 v2.1.1/fix.md 其他修复和真机验收共同决定。
