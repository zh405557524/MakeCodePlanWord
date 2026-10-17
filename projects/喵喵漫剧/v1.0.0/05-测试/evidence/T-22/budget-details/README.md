# T-22 预算明细与有界读取复检

2026-10-16，本轮仍处于开发。T-22保持“未完成（预算明细与有界读取已检；真实链路待验）”。前端dev提交 `6900cbcdfeb75487bf0c92d0c5090e90bad17f97`；T-42旧反馈等待修复独立提交 `f1d8c9d9cdf26c1e83b682d2323dceba8633b4f5`。均未推送。

## 交付范围

素材清单P-14、镜头清单P-18新增共用的只读预算入口；用户点击后才读取。与已有生成确认共用明细视图，显示单集/全剧的新图片数量、镜头目标秒数、服务端单价与逐项小计、可复用结果、待应用候选、处理中项目、剩余预计费用、余额和差额。查看、刷新和重试预算均不创建付费任务。

共享图片按assetId全剧去重，逐集仍显示本集完整需求；镜头按稳定shotId及实际覆盖参数报价。刷新素材、镜头或参数会清除旧预算；迟到结果和切号结果不覆盖新页面。缺历史、缺价或重复历史分页保持“估算不完整”，不把未知费用当0；过期报价不形成完整预算。

分集最多4路读取，同次共享图片历史复用Future；30集/180镜头/1800秒的受控测试完整遍历，3项共享素材只发3次历史读取、3次分类报价，累计216360积分，测试断言峰值在2至4之间。这仅验证读取边界和完整性，尚未给出真实网络或真机性能结论。详见[有界读取断言](bounded-read.json)。

**引用保护的澄清**：依据已批准R-26，有效作品已应用/固定引用的图片和视频继续受保护，不能仅因版本原始30天已到而要求重新付费生成。未应用且已过期的视频候选不能排除待生成镜头；明确EXPIRED且已不可用的图片也不能当作可复用结果。本轮初始“已应用视频过期应再计费”测试预期与R-26冲突，已纠正预期，不将其记为业务缺陷。原确认轮“过期图”描述以本条有效引用/不可用结果的区分为准。

## 实际执行结果

| 检查 | 结果 |
|---|---|
| 新增App方法 | 20项：18项预算＋2项报价 |
| 预算与报价 | 60项通过（18＋42） |
| 相关五套件 | 117项通过 |
| 既有素材列表布局 | 28项通过，新增入口后明确滚动再保留原断言 |
| 既有设置 | 29项通过；3处等待改动归T-42 |
| App全套 | 1073项通过，0失败、0跳过；175个隐藏框架事件未计方法 |
| analyze | 通过 |
| 格式 | 21个Dart文件、0改动：T-22为19个，T-42为2个 |
| Android/iOS集成 | 每平台5个业务方法通过，完整5组报告；终端+7含setup/teardown，不能记7个业务方法 |

[汇总](result.json)、[全套方法统计](full-suite-summary.json)、[原始全套输出](full-tests-final.jsonl.gz)、[相关原始输出](related-final.log.gz)、[analyze](analyze-final.log.gz)、[格式](format-final.log.gz)。两端drive包含调试构建；本轮未另重跑普通App构建或后台测试。原129项后台证据仅保留历史。

## 两端实际页面与边界

集成目标为现有 `integration_test/generation_confirmation_test.dart`，实际运行GoRouter、生成确认、素材清单及镜头清单，回环HTTP服务提供受控协议/余额，并核对公共GetStorage实际落盘。五组流程分别验证：

1. 受理回执丢失、坏恢复回执被拒、原任务901和原幂等键继续恢复。
2. 快速充值只进入一次，返回重读余额/报价且不自动提交。
3. 阻塞、报价过期和取消均不提交。
4. 所选预算不完整时阻止付费；仅本集完整时必须明确选择本集。
5. 两个实际清单展示3图360＋6个10秒视频7200＝7560，余额30差7530；15秒覆盖参数刷新后65秒/8160/差8130，逐镜头15秒报价1800。查看与刷新付费POST为0。

充值目的地是**导航探针**，不代表公共充值页面、商店或真实付款验收。素材与镜头页面间在测试中显式换路由，不代表完整素材就绪流程。设备为自有Android AVD和iOS模拟器，不能替代物理设备。

[Android最终日志](android-drive.log.gz)、[iOS最终日志](ios-drive.log.gz)、[Android完整报告](devices/android-generation-confirmation-result.json)、[iOS完整报告](devices/ios-generation-confirmation-result.json)。[Android终态核对](devices/android-final-verification.json)、[iOS终态核对](devices/ios-final-verification.json)。

## 截图复核

最终44张系统图（42产品页面＋2充值导航探针）和10张Widget图，共54张已逐张总览。系统图单独详看10张，Widget单独详看6张；具体文件、尺寸、SHA256和查看范围见[图片清单](images.json)。Android冷启动首页仅作诊断，不计产品图。

[Android总览](review/android-contact.png)、[iOS总览](review/ios-contact.png)、[Widget总览](review/widget-contact.png)。代表性实际页面：[Android明细](devices/os/android-os-budget-materials-summary.png)、[iOS刷新明细](devices/os/ios-os-budget-materials-refreshed.png)、[Android镜头逐项](devices/os/android-os-budget-shots-shot.png)。

本轮重连原Figma通道仍返回Not connected，见[连接结果](figma-check.json)；现有视觉沿用，不宣称最新Figma对稿通过。

## 中间失败与复跑

[全部尝试](attempts.json)保留中间输出，不用最后通过覆盖失败：

- 已复现并修复：未应用的过期视频候选错误排除生成需求；已过期报价错误形成完整预算。
- 新测试初轮包含夹具分集/ordinal问题、真实截图IO位于FakeAsync导致等待，记录[主动中止原因](interrupted-run.json)后修正；编译名/样式诊断已修正。
- 首轮全套的旧430宽素材测试假定屏外SCENE已构建，改为先实际滚动，再执行原空状态/表单断言；未删除原断言。
- 后续全套的旧反馈固定10ms等待过早，独立归T-42修复，详见[等待证据](../../T-42/settings-post-wait/README.md)。
- Android第一次因刷新后测试定位方向不对而失败，仅四组报告，18张图不计最终通过，保留[失败报告](devices/android-failed-first/android-generation-confirmation-result.json)。
- Android第二次虽然五方法通过，但22张系统图全被“System UI isn't responding”遮挡，视觉验收明确排除，见[发现记录](devices/android-systemui-overlay/finding.json)。未将系统弹框归因于App。
- 同一份已提交代码在同一自有AVD无快照冷启动后第三次执行，五组通过、22张图无遮挡，启动与结束UI层级均已核对：[复核](devices/android-ui-review.json)。未清空应用数据，未修改业务代码来处理系统弹框。

自有截图采集器、端口转发、临时UI层级文件及本轮启动模拟器已清理，未关闭无关Flutter daemon；见[清理记录](devices/cleanup.json)。日志原字节gzip往返及SHA256见[输出清单](raw-output-manifest.json)，未修剪失败原文。

## 复现入口

在App仓库依次执行，测试或构建运行中不要编辑源文件：

```sh
flutter test test/generation/budget_test.dart test/generation/quote_test.dart test/assets/image_batch_test.dart test/assets/material_list_test.dart test/shots/video_generation_test.dart
flutter test test/settings/settings_test.dart
flutter test --machine
flutter analyze
```

原生入口为 `flutter drive --driver=test_driver/catdrama_business_driver.dart --target=integration_test/generation_confirmation_test.dart -d <自有设备ID> --dart-define=CATDRAMA_CAPTURE_PORT=<设备侧端口>`；环境变量选择 `CATDRAMA_TEST_SLICE=generation-confirmation`、`CATDRAMA_TEST_PLATFORM=android或ios` 与新证据目录 `CATDRAMA_BUSINESS_EVIDENCE_DIR`。同时用 `python3 test_driver/capture_native.py <主机端口> <设备ID> <平台> <新截图目录> 22`采集并确认22次；Android需将主机端口转发到设备侧端口。本轮实际端口/设备见[Android](devices/android-run.json)、[iOS](devices/ios-run.json)，复跑前重新确认归属及空闲端口。

## 剩余验收

首次实际付费到真实生成的完整链路、Provider/私有OSS/支付、最新Figma、物理机与真实网络大规模性能仍待。本轮没有改API、DDL、依赖、后台或原生媒体实现；没有改产品/设计/技术/上线基线，没有推进阶段。

47任务仍为7完成/38进行中/2外部；186用例仍为9通过/172部分/5未执行。四个受影响用例追加本轮局部证据，见[用例结果](case-results.json)。源码精确范围和哈希见[源码核对](source-verification.json)、[提交](app-commit.json)；原文档与源码备份保存在本地originals，不纳入提交。
