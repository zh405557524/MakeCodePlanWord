# T-06 / T-23 / T-26 图片与视频模型切换

2026-11-04 至 11-05（America/Los_Angeles）。服务端 `dev` 提交 `d080d542`，App `dev` 提交 `805e8d3`。按两批检查后分别本地提交。

## 实现结果

- 图片和视频统一用当前默认加有效公开映射。无公开映射、当前默认未启用展示或公开选项停用后，仅保留可用默认与剩余有效选项。默认置首，按商家和型号去重。当前默认不可用时沿用不可用状态。
- 新报价检查实际型号和参数。图片可继承兼容风格和参考图，按作品视频通道选不到公开的图片型号时用默认。旧视频完整组合受支持则保留，否则回落到当前默认组合，仍执行镜头时长校验。显式请求已退出公开目录的型号沿用不可用错误。
- App 刷新后替换旧选项并更新待编辑草稿，沿用既有服务端保存动作。自动换型时由现有确认弹框展示实际型号、参数和新价格。已提交、提交结果未知和历史结果沿原身份查询与恢复。

## 自动检查

| 层 | 覆盖 | 结果 |
|---|---|---|
| 后端配置与视频模型选项 | 无公开列表、默认未展示但旧映射启用、有效多模型、默认切换、停用、默认重复、默认能力或价格不可用、App 隔离 | 30 项通过 |
| 后端图片计价、视频新报价及任务恢复 | 作品通道回落、显式非公开错误、图片批量报价、视频单项与批量、兼容参数、旧确认拒绝、已受理原模型与价格 | 11 项通过 |
| Flutter 定向 | 个人资产、作品素材图片、生成确认、制作设置和镜头。恢复旧草稿、参考图与风格、配置失败、账号和环境变化后的迟到响应、批量及未知请求恢复 | 381 项通过，3 项既有失败 |
| Flutter 最终专项复跑 | 失效型号回落、兼容参数、图片报价刷新及未知保护、视频报价弹框和预加载 | 14 项通过 |
| 格式与静态检查 | App 提交的 20 个 Dart 文件、隔离提交快照 `flutter analyze --no-pub`、两批 `git diff --check` | 通过 |

后端使用隔离 PostgreSQL。扩大范围时出现的 48 个既有失败用同环境的修改前版本复现，分布为计价 26、视频 18、公共映射 4。扩展检查曾另有一个新增用例漏配默认图片计价夹具，修正夹具后相关计价及最终 41 项通过。服务端最终与基线用例列表留在本地 `raw/backend-checks.txt`。

App 的 3 个既有失败集中在 `image_batch_test.dart` 的余额不足重试、窄屏滚动和混合结果重试，均在基线 `71e0808` 复现。扩大范围时还复现了已有的声音报价夹具转换及自动素材入口定时器问题，宽范围试跑受其他并行改动的资源和超时影响，结果未作为门禁。混合工作树最终分析有一条邀请提现页的未使用导入，隔离后的提交快照无分析问题。日志见 [定向结果](raw/flutter-gate.log)、[基线](raw/flutter-baseline.log)、[最终复跑](raw/flutter-model-switch-final.log)、[提交快照分析](raw/flutter-analyze-staged.log)。

## 桌面控机

Android 复用固定池的 Pixel 5 AVD `Solfeggio_Store_Phone_20261019`（1080 × 2340），以 ADB 点按、滑动和截图。iOS 复用 `Catdrama-Visual-SE-20261020`（iPhone SE 第三代，iOS 26.5，750 × 1334），以 Appium XCUITest 操作。测试包装载 App 的资产编辑、分镜列表和镜头详情，使用本机 HTTP 夹具切换目录并记录模型、配置读取、报价及写入次数。最终双端测试包使用与 App 提交逐文件核对过的源码，包内版本为 `1.0.1+101`。

| 步骤 | 核对内容 | Android | iOS |
|---|---|---|---|
| 1 | 图片多模型时显示当前和另一个公开型号 | [04](raw/android/04-fixed-image-multi-verified.png) | [11](raw/ios/11-fixed-image-multi-verified.png) |
| 2 | 夹具切成单模型后重开图片选型，仅显示并选中当前默认；原描述保留 | [08](raw/android/08-fixed-image-single-verified.png) | [15](raw/ios/15-fixed-image-single-verified.png) |
| 3 | 确认框显示新图片型号及 7 积分，取消后无提交 | [12](raw/android/12-fixed-image-quote.png) | [18](raw/ios/18-fixed-image-quote.png) |
| 4 | 视频多模型时可查看两项；切换配置后同一镜头重新报价 | [20](raw/android/20-fixed-video-multi-verified.png) | [26](raw/ios/26-fixed-video-multi-verified.png) |
| 5 | 再开镜头参数，旧 720P 切至当前默认 1080P；选型只有当前默认 | [28](raw/android/28-fixed-video-form-verified.png)、[30](raw/android/30-fixed-video-single-verified.png) | [34](raw/ios/34-fixed-video-form-verified.png)、[36](raw/ios/36-fixed-video-single-verified.png) |
| 6 | 视频报价显示实际新型号、1080P 和 24 积分；取消后提交和云端写入计数均为 0 | [36](raw/android/36-visual-verified.png)、[37](raw/android/37-visual-cancel.png) | [43](raw/ios/43-visual-verified.png)、[44](raw/ios/44-visual-cancel.png) |

首个 iOS 隔离包因补丁应用目录受父仓库影响，实际构建了改前代码。该包的截图保留作旧版复现，确认重开仍显示旧项。修正构建输入并复测后，检查到 iOS 小屏报价参数第二行轻微裁切，调整行距与位置并重建双端。最终截图已核对两行参数和取消、确认按钮。[改前复现](raw/ios/07-before-stale-model-evidence.png)。

逐步操作、页面层级和截图留在 `raw/ios/` 与 `raw/android/`。本地留有 [ADB/Appium 驱动](raw/desktop_model_switch.py)、[应用夹具](raw/model_switch_driver.dart)、[Android 步骤](raw/android/steps.jsonl) 和 [iOS 步骤](raw/ios/steps.jsonl)。调试服务已结束，两台模拟器关闭并归还固定池。

验收范围是隔离服务端测试与双端受控页面。真实模型、真实扣费、OSS、真机、Figma 整页像素验收、部署和正式环境验收均未执行。
