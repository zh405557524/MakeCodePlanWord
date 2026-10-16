# T-22 生成确认、原任务恢复与预算门禁

2026-10-16，仍在开发阶段。前端 dev 提交 `b5fb51860f48142f55c7f01c7553d0273153bb02`；未推送。修复确认切片并完成本机验证，T-22 整项仍未完成。

## 改动与依据

- 坏恢复回执必须先核对 `kind` / `quoteId`，不能先进入内存补存缓存；下一次继续查询原任务，不换键、不重报新任务。
- 充值跳转前立即保护重复点击；返回重新读取余额和报价，不自动生成。打开路由失败在原页显示错误。
- 按已批准 R-22 / TC-22-06 跟踪逐集预算完整性。所选范围缺分析、引用、历史或模型价格时禁止付费提交；本集完整、其他集未知时必须明确选择仅制作本集。旧报价回调、重报价或重预估不能沿用旧确认。
- 过期图片不视为可复用结果；有效共享图片、候选和活动任务继续排除重复预算。`completeEpisodes` 仅为本机计算，不新增接口字段。

没有修改后台、公共支付/账务、API、数据库、依赖或原生媒体实现；产品、技术、设计和上线基线未改。本轮后台未重跑，原 129 项后端结果属于历史证据。

## 测试与证据

| 范围 | 实际结果 | 证据 |
|---|---|---|
| 报价单元/Widget | 新增 12 项，当前 40 项通过 | [方法清单](quote-methods.json) |
| 相关三套 App | 69 项通过，0 失败/跳过 | [最终输出](related-final.log.gz) |
| 全套 App | 1053 个可见方法通过，0 失败/跳过；172 个隐藏框架事件不计入方法数 | [机器汇总](full-suite-summary.json)、[最终原始流](full-tests-final.jsonl.gz) |
| 静态与格式 | analyze 无问题；12 个 Dart 文件格式一致 | [输出](analyze-final.log.gz)、[源码核验](source-verification.json) |
| Android 模拟器 | 4 条业务方法通过，完整四组业务报告，无迟到异常 | [报告](devices/android-generation-confirmation-result.json)、[核验](devices/android-final-verification.json)、[日志](android-drive.log.gz) |
| iOS 模拟器 | 同一源码 4 条业务方法通过，驱动退出 0 | [报告](devices/ios-generation-confirmation-result.json)、[核验](devices/ios-final-verification.json)、[日志](ios-drive.log.gz) |

两端沿实际镜头详情、确认组件、GoRouter、回环 HTTP 和公共 GetStorage 执行；直接读取 `.gs` 核对原任务号及幂等键落盘。四条方法分别覆盖丢受理回执及坏查询后恢复、快速充值返回、阻塞/过期/取消、预算不完整及明确本集选择。驱动核实四组报告，不能只凭 SDK 的成功文字判断通过。

充值目的地是明确标注的**导航探针**，用于核对原来源、重复入口和返回行为；受控 HTTP 模拟余额变化。不是公共支付页面、真实到账、Java 账务或 Provider 验收。本轮正常 App 独立构建未重跑，两端驱动各自完成了集成 debug 构建。

Android 首次驱动虽然生成四组报告，但服务释放顺序造成迟到查询报错，退出 1，保留在 [失败首轮](devices/android-failed-first/android-drive.log.gz)，不计通过。修复仅涉及测试请求归属/排空与服务收尾，再运行同一流程。最终 Android 工具会话句柄因输出截断已不可查询退出码；已核对终态日志、完整四组报告、15 张系统图及无迟到异常，未因此另起重复执行。iOS 最终退出码已实际取得。

先复现了三项恢复/充值缺陷及五项预算反例，再验证修复。编译导入、旧测试预算夹具及等待方式的失败与修正均保留，[各次用途](attempts.json) 区分中间执行与最终结果，不累加复跑数。原始日志压缩后逐字节回解核验，[摘要](raw-output-manifest.json) 可复查；本机 originals 备份不纳入提交。

## 截图检查

30 张系统截图包含 28 张产品页面及 2 张充值导航探针；另有 8 张 Widget 图。三张总览检查了全部 38 张；单独详看两端各四张预算阻塞、仅本集选择/勾选、坏查询页面，以及四张新增 Widget 图。范围、尺寸与 SHA256 见 [图片清单](images.json)。失败首轮的 15 张系统图单列，未计入最终 30 张。

- [Android 总览](review/android-contact.png)、[iOS 总览](review/ios-contact.png)、[Widget 总览](review/widget-contact.png)。
- [预算不完整](devices/os/android-os-quote-budget-blocked.png)、[明确选择本集](devices/os/ios-os-quote-episode-choice.png)、[本集确认后](devices/os/ios-os-quote-episode-confirmed.png)。
- [坏回执后继续查原任务](devices/os/android-os-quote-query-rejected.png)。

费用、余额、差额和确认按钮在所检状态可见，无溢出告警；勾选前后按钮状态与网络提交断言一致。当前 Figma `rq4owed6` 未连接，[检查记录](figma-check.json) 保留；截图检查不等于最新设计稿或物理设备验收。

## 复现

在 `/Users/soul/code/lxwx/catdrama`，使用当前锁定依赖；命令清单见 [commands.json](commands.json)。

```sh
flutter test --no-pub test/generation/quote_test.dart test/shots/video_generation_test.dart test/assets/image_batch_test.dart
flutter test --no-pub --machine test
flutter analyze --no-pub
```

原生驱动使用 `CATDRAMA_TEST_SLICE=generation-confirmation`、`test_driver/catdrama_business_driver.dart` 和 `integration_test/generation_confirmation_test.dart`。每端独立采集端口，Android 区分宿主与访客端口；采集器等待 15 个名称并逐帧确认。设备、端口与初始归属分别见 [ownership](devices/ownership.json)、[Android](devices/android-run.json)、[iOS](devices/ios-run.json)。只停止本轮启动的两个模拟器和采集进程，未重置 App 数据、相册文件或授权；[清理复查](devices/cleanup.json) 已确认无活动测试进程。

## 剩余事项

费用预估的数量、秒数和排除项完整明细，首次付费到实际生成的完整流程，以及大规模预算读取性能尚未闭合。真实模型、私有 OSS、支付、最新 Figma 及物理设备继续待验证。五条关联用例保持部分验证，见 [case-results.json](case-results.json)；47 项任务及 186 条用例统计不变，不自动进入下一阶段。

前端提交范围及 SHA256 见 [source-verification.json](source-verification.json)，[结果](result.json) 和 [提交](app-commit.json) 记录本轮边界。开发计划、测试结果、风险清单和两份工作区 README 同步更新。

本轮用量未取得，未额外查询。
