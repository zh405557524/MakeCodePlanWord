# T-47 普通 App 场景／道具真实帮写补验

日期：2026-10-19。范围：普通 App、本机实际后端、正式 DeepSeek 适配器与公共任务调度。没有使用模型替身或注入候选。App 业务代码沿 `49c005c`；随后 `64d0fd4` 仅改规则和模板说明。后端沿 `6bd40ee6`，本轮未改业务源码、配置或表结构。

## 结果

| 检查 | 实际结果 | 证据 |
|---|---|---|
| iOS 场景候选与主动确认 | 名称“本机帮写雨巷”、原描述12字；实际返回128字，确认前保留原文，点击使用后才替换 | [原表单](run-ios/observations/O00013.png)、[候选](run-ios/observations/O00019.png)、[应用后](run-ios/observations/O00021.png) |
| iOS 道具恢复与保留 | 名称“本机帮写银钥匙”、原描述12字；实际返回84字。后台成功后系统终止 App，重开同类型表单恢复候选，选择保留仍为原12字 | [提交](run-ios/observations/O00033.png)、[恢复](run-ios/observations/O00041.png)、[保留](run-ios/observations/O00043.png)、[终止记录](ios-lifecycle.json) |
| 按类型恢复表单 | 处理道具后重开场景，名称和已应用128字保持，没有道具内容串入 | [最终场景](run-ios/observations/O00050.png) |
| 免费及副作用 | 只增加两个成功 FREE 帮写任务，对应两个外呼 HTTP200；积分仍30可用/0冻结，流水6、资产1、图片任务1、图片版本1保持 | [之前](ios-before.json)、[之后](final.json)、[外呼摘要](provider-events.json) |
| Android 普通构建与入口 | 本机地址10.0.2.2，1.0.0+1安装启动成功，首页进入资产后要求登录。无SIM模拟器进入短信页，缺少已授权短信登录条件，帮写尚未执行 | [构建身份与摘要](android-build-proof.json)、[资产入口](run-android/observations/O00006.png)、[短信页](run-android/observations/O00008.png)、[结果](run-android/result.md) |

两次新增任务：SCENE `2112171647647207425`、PROP `2112173202249207810`；两类表单使用不同 clientFormId。恢复和保留后任务总数仍为五（含上一轮三个 ROLE），未新增外呼、扣分、生图、资产或成长奖励。数据库改动：无；任务记录由正常 App API 创建，本次 SQL 仅只读核对，没有直接改写账务或业务数据。

## 验证边界

- 本轮证明普通 iOS 模拟器的两类正常帮写、成功结果恢复及用户确认。终止时后台已明确 SUCCEEDED，不能据此宣称处理中断恢复通过。
- 未重跑旧自动化基线；新增执行 Android debug 构建、两端普通 App 控机及实际后端/Provider核对。相关测试沿原有效证据。
- 原型或 Figma 像素核对、完整坏值及失败矩阵、并发、写盘故障、Android 登录后帮写、物理设备、远端部署仍待。Android 缺项按用户要求记录，不阻塞其他任务。
- 控机报告保留 blocked，因为整条用例尚未覆盖；本轮已验证子流程如上。TC-03-09、TC-03-10、TC-X31 保持部分验证。47项仍7完成/40未完成，186条仍12通过/171部分/3未执行。
- 控机事件中保留一次大语义容器点击及一次查询按钮已消失的定位结果；均核对实际界面后继续，没有重复生成。导航过渡帧不作为像素验收证据。

完整控机过程见 [iOS结果](run-ios/result.md)、[iOS事件](run-ios/events.jsonl) 和 [Android结果](run-android/result.md)。原始媒体摘要及本轮范围见 [verification.json](verification.json)。所有运行授权串、token、完整 Provider 日志均未复制到证据目录。
