# T-23 / T-25 图片失败原因与提示词修改

2026-11-05（America/Los_Angeles）。服务端 `dev` 提交 `40c6cb7d`，App `dev` 提交 `1ae9b3a`。覆盖 AC-IMAGE-ERR-01～03，按后端和 App 分批检查并本地提交。

## 实现

- BigLongXia 的 HTTP 拒绝与响应内错误、豆包同步和异步错误转换为可公开的中文原因。提示词、参考图、输出图、设置、授权、限流和故障分别处理。渠道原文、访问凭据和签名地址留在公开原因之外，积分说明由现有失败补偿流程按账务状态生成。
- 使用任务和图片版本的现有失败字段。个人详情和编辑在一次详情请求中读取最新生成摘要，作品描述编辑和批量卡片按任务归属读取原因。已有成功图片可继续查看。
- 本机保留单张失败任务的模型、风格与参考图选项。只有最新失败任务编号吻合时才复用这些选项，新报价使用当前素材版本和新保存的描述。处理中与结果未知的任务继续使用原身份恢复。

## 自动检查

| 层 | 检查 | 结果 |
|---|---|---|
| 后端 | BigLongXia、豆包同步和异步、控制面恢复、图片与批量任务接口、原订单补偿幂等 | 212 项定向通过 |
| 后端扩展 | 271 项图片和渠道回归 | 241 项通过，30 项与修改前的失败多重集相同 |
| App 专项 | 失败摘要、旧图保护、编辑刷新、保留参考图和设置、重新报价、恢复、账号和环境隔离 | 18 项通过 |
| App 回归 | 资产、上传、工作台、作用范围、批量、素材列表和报价 | 排除下列改前问题后 323 项通过 |
| 静态检查 | Dart 格式、`flutter analyze --no-pub`、两批代码的 `git diff --check` | 通过 |

后端使用隔离 PostgreSQL 和模拟渠道响应。定向检查验证同步及异步审核错误、HTTP 200 内嵌错误、空错误响应、参数与授权、限流、服务异常、任务和素材原因一致以及一次退款。后端扩展的既有失败涉及旧图片版本标记、处理和审核夹具。 [后端用例汇总](raw/backend-checks.txt)。

App 扩大回归发现 3 个既有批量失败，分别是余额不足重试、小屏滚动和混合结果重试。工作台重开原任务的 1 个断言在修改前后分别单独复现。工作台成功结果跟随选择、单张 AI 提交两个场景在修改前后停滞，保留记录后停止对应测试进程。重跑覆盖其余 323 项，包含活动态、历史、失败后重新报价和未知受理恢复。 [相关回归](raw/flutter-stable.log) · [专项](raw/flutter-focused.log) · [扩展记录](raw/flutter-related.log) · [改前对照](raw/flutter-baseline.log) · [单张提交对照](raw/flutter-baseline-workbench-submit.log) · [静态分析](raw/flutter-analyze.log)。

## 双端桌面验证

Android 使用固定池 Pixel 4 AVD `Catdrama_Editor_20261025`（1080 × 2280），通过 ADB 操作。iOS 使用 `Catdrama-Visual-SE-20261020`（iPhone SE 第三代，iOS 26.5，750 × 1334），通过 Appium XCUITest 操作。测试包为 `1.0.1+101`，双端构建源码与 App 提交逐文件核对。网络使用本机夹具，截图显示现有 App 页面。

| 核对内容 | Android | iOS |
|---|---|---|
| 个人资产显示旧图、最新失败原因和可编辑提示词 | [保存后详情](raw/android/09-personal-quote-cancel.png) | [编辑时原因](raw/ios/03-personal-editor.png) |
| 个人资产保存修订稿，以素材版本 2 报价 7 积分 | [新报价](raw/android/08-personal-new-price-verified.png) | [新报价](raw/ios/08-personal-new-price-verified.png) |
| 另一素材的参考图审核原因独立显示，重试进入对应工作台 | [失败项](raw/android/13-failed-target-workbench.png) | [失败项](raw/ios/13-failed-target-workbench.png) |
| 作品描述编辑时保留失败原因，重新读取影响范围保留未保存文字 | [编辑](raw/android/17-work-scope-editor.png)、[刷新](raw/android/20-work-prompt-refreshed.png) | [编辑](raw/ios/17-work-scope-editor.png)、[刷新](raw/ios/21-work-prompt-refreshed.png) |
| 同步关联集，保存后以绑定版本 2 报价 11 积分 | [范围确认](raw/android/21-work-scope-confirmation.png)、[新报价](raw/android/27-work-quote-verified.png) | [范围确认](raw/ios/22-work-scope-confirmation.png)、[新报价](raw/ios/28-work-quote-verified.png) |
| 取消报价，两个新报价均未提交生成任务 | [最终读数](raw/android/28-work-quote-cancel.json) | [最终读数](raw/ios/29-work-quote-cancel.json) |

实际查看两端失败区、编辑态和报价截图，原因完整换行，原操作均可到达。Figma 实时连接超时，工作台布局核对使用留存的失败态设计图。设备两组流程各完成一次个人资料保存和一次作品范围保存，均使用夹具。 [留存设计图](../material-detail-ui-20261021/figma/failed.png)。

桌面驱动逐步保存截图、界面层级和夹具状态。初次脚本对报价版本字段使用了错误的字段名，按实际 `expectedRevision` 修正后两端重验通过。两台模拟器关闭并归还固定池。 [Android 步骤](raw/android/steps.jsonl) · [iOS 步骤](raw/ios/steps.jsonl) · [桌面脚本](raw/desktop_image_failure.py) · [页面夹具](raw/image_failure_driver.dart)。

数据库改动为无，历史失败按已保存的原因展示。真实模型、OSS、真实扣费、真机、部署和正式环境验收待执行。
