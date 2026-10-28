# M04 积分充值与支付修复验证

2026-10-28。开发完成、待用户验收。客户端 dev，提交 `88b56ca`、`f9a792c`；Flutter 3.41.6 / Dart 3.11.4。无数据库、服务端、写歌、渠道配置或生成扣费修改。真实支付/真实积分到账未执行。

## 实际实现

普通入口仅加载套餐与可用渠道；旧待支付/旧成功不接管页面。新购与显式 `resumeOrderNo` 分开，按幂等键保存购买快照；旧单条记录兼容迁移并保留。未知创建在下一次明确点击沿原键核实后结束操作。SDK 取消、网络中断、待确认保留充值页；当前主动支付的可信成功/明确失败保留结果页。

订单列表核对、续付、取消原单；Android 续付重新确认协议，iOS 仅核实未完成交易。历史到账只更新账务。失败重试先回确认；成功返回本次入口或去制作，不自动生成。

## 验证结果

| 层级 | 结果与证据 |
|---|---|
| 静态检查 | `flutter analyze --no-pub`：0 问题；[日志](logs/final-analyze.log) |
| 业务与协议 | `flutter test --no-pub test/payment test/widgets/app_gradient_loading_test.dart test/settings/legal_pages_test.dart`：124 项通过；其中支付/处理中 119 项、官网协议组件 5 项；[日志](logs/final-regression.log) |
| 视觉 | 7 个 375×812 状态截图检查通过；包含 Android 双渠道、iOS 未勾选/已勾选、不可用渠道、成功、失败、待确认；[日志](logs/final-visual.log)、[截图](widget/) |
| 构建 | Android debug APK、iOS simulator debug 通过；目标为隔离桌面测试入口，非发行包；[Android](logs/final-apk.log)、[iOS](logs/final-ios.log) |
| 桌面双端 | 外部 ADB/Appium 点击真实充值/订单页面，取消→待确认→明确失败→回确认→成功→创建入口→重新进入充值→历史到账；[Android结果](android-desktop-result.json)、[iOS结果](ios-desktop-result.json) |
| 原单处理 | Android 原单续付不创建第二单、取消后无付款操作；iOS 核实不增加购买/支付参数请求；[Android步骤](android-recovery-steps.json)、[iOS步骤](ios-steps.json)及 iOS O00049～55 |
| 真实进程重启 | Android 创建响应丢失后 force-stop/重新启动。原键仍在，重进不发创建请求；下次主动点击同键重放，创建 HTTP 次数6→7、唯一订单数保持6、SDK调用数不增；[结果](android-recovery-result.json) |
| 原生来源回归 | 两端各1项：历史订单不接管、资料刷新失败后可重试、有效来源返回、过期回作品列表；[iOS日志](logs/ios-protocol-test.log)、[Android日志](logs/android-protocol-test.log)，每端4张系统截图 |
| 边界 | 单元/组件覆盖存储失败、旧缓存迁移及损坏、账号/App/后台隔离、连点、终态、金额/归属校验、小屏320×640、长价格、1.3文字缩放和安全区。原生不是320小屏验收 |

## UI 对稿与多余文案检查

Figma 通道 4f6qy6d4；只读导出，没有改设计稿。原图：[Android 5:2156](figma/android.png)、[iOS 5:7781](figma/ios.png)、[成功 5:7697](figma/success.png)、[失败 5:7739](figma/failure.png)、[处理中 43:2405](figma/processing.png)。未选渠道圆环最后替换为5:2247灰色源资源，追加7态视觉与静态检查通过；该纯资源追加未重复原生支付。代码摘要见 [source-manifest.json](source-manifest.json)。新增资源逐项来源和摘要见 [assets.json](assets.json)。

| 检查对象 | 已查看的稳定画面 / 结论 |
|---|---|
| 普通 Android 充值 | [原生](android-final2/observations/O00055.png)、[375×812双渠道](widget/recharge__android.png)：余额、套餐、渠道、按钮、协议，无制作说明、旧单摘要、常驻重试 |
| iOS 充值 | [原生](ios-final/observations/O00004.png)、[375×812](widget/recharge__apple-accepted.png)：App Store 渠道；协议勾选可被原生辅助功能点击 |
| 本次成功 | [iOS](ios-final/observations/O00034.png)、[Android](android-final2/observations/O00046.png)：插画、标题、说明、返回/去制作；没有订单号/金额/查询/取消订单 |
| 本次失败 | [iOS](ios-final/observations/O00026.png)、[375×812](widget/payment-success__failed.png)：顶部“支付失败”，取消/重新支付；不声称网络异常等于支付失败 |
| 原单确认 | [最终Android](android-final-ui/observations/O00006.png)：原积分和金额、原渠道、未勾选协议；移除重复积分和“原购买快照”技术文案 |
| 小屏及长价格 | 组件测试通过，无布局异常；正常充值不显示制作费用；费用说明仅实际制作来源存在时展示 |

按稿恢复套餐选中高光、按钮背景、字重和渠道行；Android 按支付宝→微信排序。保留已确认差异：真实余额/套餐价格、两位小数价格、实际可用渠道、《积分充值协议》单协议；失败说明为“请确认支付方式后重试”，避免把待确认描述为失败。iPhone 13 mini 顶部安全区50而稿为44，主体相应下移6；Android为不同逻辑屏幕尺寸。Widget 字体渲染和系统状态栏不作为原生像素验收依据。

部分 `act` 后截图在路由动画中，不能拿作稳定对稿；上表指定已目视核对的稳定截图，动作前后 XML/JSON/PNG 原证据均保留。视觉开发自检不等于用户验收。

## 复跑与证据边界

- `test_driver/recharge_desktop.dart` 是专用模拟器入口。真实页面/控制器/幂等存储/协调器，HTTP、商店交易、账户与创建入口为夹具；没有使用真实资金、商店订单或生成服务。
- [run_desktop.py](run_desktop.py) 先跑当前支付各分支；[run_android_recovery.py](run_android_recovery.py) 接着跑原单和实际进程重启。通过 `phone-ui/phone_test.py` 驱动；每步存截图、界面树、动作与读取状态。新跑需使用新 run 目录和独立夹具初态，不能重放未知购买按钮。
- 原生来源切片运行 `flutter test integration_test/recharge_protocol_test.dart --plain-name 'ordinary reentry ignores history' -d <device> --dart-define=CATDRAMA_CAPTURE_PORT=<port>`；[capture_protocol.py](capture_protocol.py) 为每个序号保存系统截图后确认，非结束时补拍。
- 来源路由/创建入口为受控入口，不将这轮结果扩大为正式登录、全制作输入编辑或自动生成验收；输入保留与来源校验有组件覆盖。实体机、真实支付宝/微信/StoreKit到账另行验收。
- 并行 M05 已将充值协议切换到固定官网。合并后的协议路由与返回保留测试通过；本轮桌面访问包含正式地址未发布的错误路径，不把官网正文发布记为通过。正式发布边界见 [M05](../M05/README.md)。
- 初次桌面订单分页夹具遗漏 `page/pageSize`，被客户端严格拒绝；补齐后双端历史到账通过。早期 `*-desktop`、`android-final` 和 error 文件保留追溯，以本文结果为准。Android 重新安装测试包可能重置夹具临时目录；只有 `android-recovery-result.json` 的实际 force-stop 重启是持久化证据。
- 专用设备：iOS `E39D3C5C-A3AC-46C7-BE7D-24F3240F7C55`，Android `emulator-5564`；未操作实体机，也未操作其他任务的模拟器。

## 结论

三批客户端开发与计划内受控验证完成；未执行真实支付渠道、正式官网发布或用户视觉验收。既有版本186条总体验收统计不改写。
