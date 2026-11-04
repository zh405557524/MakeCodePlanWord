# 签到与积分详情 UI 检查

日期：2026-11-03。范围：T-37 / T-38，App `dev` 提交 `1f618e4`，未推送。状态：实现与开发检查完成，待用户验收。

用户确认：签到成功状态用绿色；积分详情“保留记录，只去掉‘解冻’字样”。Figma 通道 `ydfaqyoa`，任务中心节点 `5:8073` / `5:8218`，积分详情 `5:8363`。本次只读设计稿。

## 实现

- 签到完成勾选使用 Figma `5:8116` 原图，导出 1x / 2x / 3x 并统一着色为主题绿 `#B9DF7A`；成功按钮保留完整绿色渐变，继续禁止重复点击。未完成的禁用状态保留原有透明度。
- 积分详情保留全部流水，`UNFREEZE` 金额显示为绿色 `+数值`，不再附带“解冻”。有 `REFUND` 操作的记录仍保留既有“退回”标题；缺少操作字段的历史记录使用原始标题。接口字段、记录数量、金额、序列化方向及记账逻辑保持。
- 卡片沿用设计稿的布局：横向边距 15、行高 60、行距 13、圆角 18；标题 15、时间 12、金额 20。未新增页面文案或交互入口。

代码范围：任务中心、积分详情、流水显示模型、文案、资源路径及三档勾选图片；补充现有流水测试中的真实 `UNFREEZE` 与旧记录场景。本地核验入口和电脑控机脚本放在 App `.local/`，不纳入提交。

## 自动检查

| 检查 | 结果 |
| --- | --- |
| 修改文件 format、Git diff 检查 | 通过 |
| `flutter analyze --no-pub` | 无问题 |
| `test/payment/ledger_orders_test.dart` 与 `test/growth/checkin_invite_test.dart` | 82 项通过；另 1 项既有失败单列 |
| 流水保留、旧记录、金额显示及序列化 | 三条测试记录完整保留，`+120` / `+30` 可见，无“解冻”，方向仍为 `UNFREEZE` |

已知失败：`recharge ledger link opens the exact original order detail` 在打开原订单详情后 `pumpAndSettle` 超时。完整运行及单项重跑均失败；将本次修改文件恢复到修改前版本的独立基线副本中，单项仍以相同错误失败。此项未记为通过，也未扩大本次范围修复。

最终回归明确排除该基线失败，命令为：

```sh
flutter test --no-pub test/payment/ledger_orders_test.dart test/growth/checkin_invite_test.dart --name '^(?!recharge ledger link opens the exact original order detail$)' --reporter expanded
```

本地日志：[最终 82 项回归](evidence/checkin-ledger-ui-20261103/tests-final-verified.log)、[原始完整运行](evidence/checkin-ledger-ui-20261103/tests.log)、[单项重跑](evidence/checkin-ledger-ui-20261103/order-link-retest.log)、[修改前基线复现](evidence/checkin-ledger-ui-20261103/baseline-order-link-final.log)、[静态检查](evidence/checkin-ledger-ui-20261103/analyze-final.log)。

## 原生页面核对

固定池 iPhone 13 mini，iOS 26.5，设备 `44CBBE60-E35E-4C71-9B1B-A13AA15B425B`；逻辑视口 375×812。按池规则领取，Xcode 明确指定设备并禁用并行克隆。通过桌面 Appium 控制真实 `TaskCenterPage` / `PointsLedgerPage`，使用本地受控 HTTP 数据，不连接真实账务服务。

| 操作 | 观察结果 |
| --- | --- |
| 进入未签到状态 | 积分 8000，显示“立即签到” |
| 点击签到，关闭成功回执 | 增加 3 分，连续 1 天；已签到勾选为绿色，按钮保留绿色渐变 |
| 再点已签到按钮 | 按钮不可点击，签到提交次数仍为 1 |
| 返回并重新进入 | 积分 8003，完成状态保持 |
| 打开积分详情 | 四条记录全部显示，含两条 `UNFREEZE`；金额为 `+3`、`-120`、`+120`、`+30` |
| 查看历史记录与退回记录 | 不显示“解冻”；`生成失败（退回）` 与 `历史生成记录` 均保留，退回金额为绿色 |

最终截图已实际查看：[任务中心](evidence/checkin-ledger-ui-20261103/tasks-os-raw.png)、[积分详情](evidence/checkin-ledger-ui-20261103/ledger-os-raw.png)。过程见 [电脑控机步骤](evidence/checkin-ledger-ui-20261103/steps.jsonl)、[受控状态与请求次数](evidence/checkin-ledger-ui-20261103/fixture-state.json)。设计参考：[任务中心](evidence/checkin-ledger-ui-20261103/figma-tasks.png)、[积分详情](evidence/checkin-ledger-ui-20261103/figma-ledger.png)。

本机安全区顶部 50，设计稿顶部 44，内容整体有 6 个逻辑像素的设备安全区差异；本次没有修改全局安全区。任务中心设计稿内容高 1074，设备视口高 812，本次检查修改涉及的状态及可见区域，不宣称整页逐像素验收。勾选绿色以用户本次确认优先于旧稿白色。

测试结束后已关闭 Appium 会话、Flutter 调试及本任务 WDA / Appium 进程，关闭并释放上述模拟器。原始截图、日志、运行脚本及构建产物仅保存在本地忽略目录，不提交 Git。

## 验证边界

已验证原生页面显示、完成状态保持、禁用重复点击以及受控流水完整性。真实后台签到发奖、真实账户流水、Android、物理设备、渠道包与上线均未在本次验收；不变更历史正式验收统计。保留仓库内其他任务的未提交修改。

## 2026-11-04 补充复检：签到成功弹窗

用户反馈成功弹窗仍与设计稿不一致。本轮于 11 月 3 日开始、11 月 4 日收尾，重新读取独立稿 `5:1885` 和弹窗节点 `5:2004`，以相同示例“连续签到 2 天，成功领取 +10 积分”逐项对比。App `dev` 提交 `324b2a8`、`afa86f9`，未推送；实现与开发检查完成，待用户验收。

发现并修正：标题继承了主题的灰紫色，改为稿中的白色；数字原先各自计算渐变且前后留白字号不一致，改为整句坐标的数字渐变及对应留白；确认按钮原先偏黄、字重偏重，改为 `#1A211C` 深绿色底、柔和内沿高光及对应字重。最终高光由圆角描边的代码渐变加模糊实现，圆角处连续柔化，不使用按钮背景切图。“我知道了”同时具有独立按钮语义，电脑控机可按名称点击。

仅修改 `lib/components/reward_receipt_dialog.dart` 与 `lib/theme.dart`。到账判断、连续天数和积分值继续取原回执；领取成功弹窗保留原样式，积分详情沿用上一轮修正。

| 检查 | 本轮结果 |
| --- | --- |
| format、scoped diff 检查 | 通过 |
| `flutter analyze --no-pub` | 无问题 |
| `flutter test --no-pub test/growth/checkin_invite_test.dart test/widgets/auth_reward_feedback_test.dart --reporter expanded` | 52 项通过，无排除项；含 375×812 / 375×667 与大额积分、长天数及关闭动作 |
| 原生设计示例 | “2 天、+10 积分”同数据对比已查看；按钮原生边界为 x72 / y425 / 230×42，与稿对应 |
| 真实页面受控签到路径 | 8000 → 签到一次 → 成功弹窗“1 天、+3 积分” → 关闭 → 已签到 8003；重进保持，禁用按钮重复点击后提交次数仍为 1 |
| 领取成功回执回归 | 原生显示 100 积分及原取消/确定按钮，点击取消正常关闭；自动测试覆盖两个关闭动作 |

证据：[设计稿与修正后对比（左稿、右 App）](evidence/checkin-receipt-20261103/figma-vs-final.png)、[三列对比（设计稿 / 修改前 / 修正后）](evidence/checkin-receipt-20261103/panel-comparison.png)、[最终成功弹窗系统原图](evidence/checkin-receipt-20261103/receipt-os-raw.png)、[重进后的已签到状态](evidence/checkin-receipt-20261103/22-final-reentry.png)、[领取回执](evidence/checkin-receipt-20261103/14-claim-receipt.png)。原始 [Figma 参数](evidence/checkin-receipt-20261103/figma-receipt.json)、[控机步骤](evidence/checkin-receipt-20261103/steps.jsonl)、[结果断言](evidence/checkin-receipt-20261103/result.json)、[最终测试日志](evidence/checkin-receipt-20261103/tests-glow.log)、[最终静态检查](evidence/checkin-receipt-20261103/analyze-glow.log)均保留本地；52 项为最终一轮数量，不累加重复执行。

验证仍为固定池 iPhone 13 mini / iOS 26.5，原生 App 页面与受控 HTTP 数据。设计母稿为 375×885 且底图为设置页，设备为 375×812、底图为实际任务中心；只对同为 284×183 的弹窗组件及状态核对。并排图使用原生截图裁切，没有缩放；Appium 截图与 Figma 导出存在 1 个栅格像素的取整差异，不宣称整屏逐像素一致。原始系统截图另存。中间调试图不是最终结果，以本段链接为准。

最终 iOS 编译完成，Flutter CLI 随后的日志读取连接报错；已通过 Appium 激活编译后的 App，并完整跑通最终原生页面路径，不把 CLI 调试连接记为通过。Appium 会话、Flutter 调试及本任务 WDA / Appium 进程已结束，模拟器已关闭释放。真实后台发奖、Android、物理设备和正式包未在本轮验证；测试素材与日志继续仅本地保存。
