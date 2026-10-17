# T-37 取消订单后的分页修复

修复“待支付”筛选中取消订单后继续翻页漏单的问题。只调整App订单列表读取及检测，支付、扣费、订单状态、原购买快照和后端接口保持原实现。

## 问题与修复

公共接口按页码和每页20条返回数据。旧页面在取消后只移除当前行，仍从第二页继续读取；服务端数据已少一行，原第21笔因此被跳过。取消时恰好支付成功也会使订单移出待付筛选，旧总数停留在45。

修复后仍先读取本人原单、沿公共取消接口操作并再核实真实状态；随后重读第一页，重新取得真实总数和分页位置。取消失败提示在自动刷新完成后保留，直到用户主动重试；不在客户端伪造已取消或已支付。

[修复前结果](before-fix-summary.json)对应2条失败回归和1条通过的放弃取消用例：原第21笔被第22笔替代；支付竞态下应为44的总数仍为45。Flutter原失败日志省略了长列表后半部分，不将打印出的前25条当作完整列表。原始日志保留在私有 `originals/`。

## 检测结果

- 新增3项回归，订单/流水专项37项、全量App 1208项通过，0失败/跳过；[全量结果](frontend-full-results.json)、[汇总](frontend-full-summary.json)、[检查项](checks.json)。
- 全量analyze、4文件格式检查和双端debug构建通过。之后仅修正截图采集，生产Controller和专项测试源码未变；最终两端各2条完整方法重新通过。
- 两端均使用实际订单页面、真实Dio和回环HTTP协议夹具。通过页面筛选、打开详情、确认取消、更多和重试按钮完成流程；每端两种场景最终44个订单号与服务端夹具逐条一致，无遗漏/重复。
- 取消成功场景和“取消请求失败但真实状态已支付”场景均只提交一次取消，创建订单和续取支付参数均为0，测试未开启真实支付渠道。后者还验证第二页失败保留首屏、重试仍读取原第二页。
- [iOS结果](ios/ios-order-pagination-result.json)、[Android结果](android/android-order-pagination-result.json)、[双端运行结果](outcomes.json)。本例不调用真实商店、支付服务或生产后台，不代表真实支付验收。
- 本轮未修改或重跑后台；原T-37的74项后端证据保留为历史，不关闭T-42原3项公共失败。

![双端实际系统图](screenshots-overview.png)

## 系统图采集复检

最终截图由页面停留、宿主检查实际App PID、执行系统截图、回执后继续的握手生成。iOS沿 `simctl io screenshot`，Android沿 `adb exec-out screencap`，分别核对6个递增序号。[图像检查](screenshot-checks.json)、[iOS采集记录](ios/system-captures.json)、[Android采集记录](android/system-captures.json)与原图摘要绑定；不是测试结束后补拍。

首轮把系统图放进integrationDriver截图回调，回调实际在结束时执行，图像与名称不符，保留为[无效视觉证据](attempts/late-system-capture/failure.json)。第二轮实时握手中，Android的测试截图Surface转换使系统图落后一个状态，保留为[无效Android视觉证据](attempts/android-conversion-lag/failure.json)。最终订单切片不转换Surface、不调用测试截图API，只用直接系统截图，双端完整复跑。两轮业务断言通过不替代图像复检通过。最初新增单测错误地按OutlinedButton定位公共取消按钮，已在修业务前改为实际文字定位并重跑，未弱化放弃取消断言。

## 复现入口

1. 使用现有Flutter `/Users/soul/data/flutter/flutter`，原依赖源 `https://pub.flutter-io.cn`，命令均带 `--no-pub`；不升级或改锁文件。
2. 专项：`flutter test --no-pub test/payment/ledger_orders_test.dart`。全量：`flutter test --no-pub --reporter json`。静态：`flutter analyze --no-pub`。
3. 两端编译 `integration_test/public_business_test.dart`，定义 `CATDRAMA_PUBLIC_SLICE=order-pagination`。iOS的 `CATDRAMA_CAPTURE_PORT=54381`，Android为54382；iOS按正常模拟器构建，使用已安装的CocoaPods，不关闭签名。
4. 仅启动自有iOS模拟器 `E33B4820-6860-419F-8B17-B6A8FA94EA77` 和Android AVD `Catdrama_T17_QA_20261015` / `emulator-5556`，运行 `python3 run_devices.py`。复用现有业务driver，预构建二进制配合 `--keep-app-running` 保留安装/沙盒；缺业务结果、采集序号或系统图即失败。
5. [源码冻结](source-freeze.json)、[二进制指纹](binary-fingerprints.json)用于核对实际版本。测试数据为45笔自建待付订单，第二种场景只在协议夹具中模拟支付竞态和503，测试凭证使用内存安全存储，不替代原生登录证明。

## 范围与剩余工作

本例挂载实际订单页，未复验普通启动/完整公共路由、真实后台订单规模、真实支付/商店、物理设备或最新Figma；页面布局和资源未修改。两个测试场景的放弃取消、错误、页码与状态有各自断言，不把模拟器/夹具当作实际账务验收。

开发阶段保持不变。T-37仍进行中；47项7完成/38进行中/2待外部、正式186条9通过/172部分/5未执行保持。进度表单独记录本次已完成的分页修复。

[终态](terminal.json)记录自有App/模拟器与forward的清理；[范围复检](scope-check.json)核对原有未提交状态、保护文档及正式用例正文。[复检结论](review.json)和[摘要清单](manifest.json)随最终提交保存；`verify.py`只读检查最终结果与摘要。
