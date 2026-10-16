# T-21 镜头导航与完整草稿保护

2026-10-16，当前仍为开发阶段。App dev `a4e2884d9813fdcff6e3b6caeb18b46f21302ac1`；T-42旧TXT夹具修复单独提交 `282dd6fa942c22763160e41e4390f70e4d9f063b`。未推送。

## 本次实现与依据

按已批准P-18及T-21补齐固定本集剧本/素材入口，使用真实作品、分集和镜头ID。列表/详情的GetBuilder同时绑定key/tag；离开动作由Controller统一协调：冻结交互、失焦等帧、暂停播放、完整草稿实际写盘，再核对账号/环境及作品期限。输入法末次回写进入revision循环；写盘失败留页保稿，用户可重试。返回后刷新服务端快照，保留本机手改；浏览不隐式PATCH、分析或生成。

旧版实际写盘阻塞时仍可编辑已复现，见[修复前记录](before-fix-summary.json)与压缩原日志。旧路由超时未单独作为key问题的根因证明；新增回归和实际两端流程证明当前稳定身份及两份草稿独立。未改API、数据库、依赖、公共业务或原生媒体实现，未新增手机FFmpeg。

## 检测结果

| 检查 | 实际结果 |
|---|---|
| 镜头套件 | 34项通过，原23项加11项；包含晚到输入、写盘失败、切号/到期、真实路由及缺入口 |
| 相关回归 | 镜头、视频生成、视频应用合计54项通过 |
| 全套App | 1041项通过，0失败、0跳过；机器事件done.success=true |
| 静态与格式 | analyze通过；8份Dart格式通过，其中7份T-21、1份T-42 |
| Android | 自有Catdrama_T17_QA_20261015模拟器，3个业务方法完整通过，9张系统截图 |
| iOS | 自有iPhone 15 Pro Max/iOS26.4模拟器，3个业务方法完整通过，9张系统截图；相同源码再跑3项通过 |
| 图片 | 18张最终系统图、12张Widget图；全部总览，8张系统图及4张新增Widget图详看 |

每平台报告中的+5包含setUpAll/tearDownAll，仅3项为业务方法。原生检查使用实际CustomRouter页面、回环HTTP与公共GetStorage，并读取实际GetStorage.gs文件核实草稿。故障在真实公共写盘队列注入，不等于物理磁盘耗尽。所有页面往返断言无业务写请求；未调用真实Java、模型、OSS或生成音视频。

[全套事件汇总](flutter-summary.json)、[范围/提交](result.json)、[用例范围](case-results.json)、[截图清单](image-evidence.json)、[Android报告](devices/android-shot-navigation-result.json)、[iOS报告](devices/ios-shot-navigation-result.json)、[iOS稳定性复跑](devices/ios-confirmation/ios-shot-navigation-result.json)。

## 原始失败与修正

- 修复前冻结断言失败、初检编译错误和路由夹具清理问题均保留；一次确认持有的挂起Flutter进程被中断，不计通过。路由回归改用页面实际拥有的Controller，避免测试预注入所有权造成到期定时器未清理。
- 一次相关命令把video_apply_test.dart误写为video_application_test.dart，49项通过但有1项加载失败；该命令不计通过，改为实际文件后54项通过。
- 第一轮全套1040通过/1失败：旧TXT覆盖用例固定等50ms，第二次弹框尚未出现就点击。T-42只改为等待实际弹框，保留取消/确定和完整输入断言；14项定向与后续1041全套通过。
- Android首轮测试查找已滚出视区且未构建的镜头项，随后原生tearDown误调用需要inTest的pumpWidget；修正测试生命周期。第二轮两项通过、一项因历史入口滚动未稳定未命中而超时；改为滚动、等帧、对齐和hitTestable断言后完整通过。失败命令及SDK不完整报告均被驱动校验拒绝。
- iOS首轮两项通过、一项的输入在切换前截图已是旧值；补失焦后等待页面稳定及四阶段输入观察后，两次完整复跑通过。首次没有四阶段观测，不能据此认定真实输入法兼容问题已定位/解决；物理设备及原生输入法仍待验。
- 最终18张系统图之外，失败、Android先前通过及iOS重复采集分别放在对应目录，不重复计入最终图数。没有弱化业务断言。

原日志按[清单](raw-output-manifest.json)无损gzip，原始未压缩副本/源码备份留在本机originals/且不提交。系统相册、照片及权限未改，没有生产或数据库操作。

## 可复跑入口

在App仓库使用已安装Flutter，不升级依赖：

```sh
flutter test --no-pub test/shots/shot_detail_test.dart test/shots/video_generation_test.dart test/shots/video_apply_test.dart --reporter expanded
flutter test --no-pub --machine
flutter analyze --no-pub
```

系统采集沿test_driver/capture_native.py；Android宿主56898转发到访客19139，iOS使用19339（稳定性复跑19439）。采集器须在drive前启动，预期9张，完成报告须包含draftNavigation/failureAndRetry/expiredEntry及四阶段inputReadiness；缺项不因驱动退出0而算通过。Android/iOS依次运行：

```sh
CATDRAMA_TEST_PLATFORM=android \
CATDRAMA_TEST_SLICE=shot-navigation \
CATDRAMA_BUSINESS_EVIDENCE_DIR='<证据目录>/devices' \
flutter drive --no-pub --driver=test_driver/catdrama_business_driver.dart \
  --target=integration_test/shot_navigation_test.dart -d '<自有QA设备>' \
  --dart-define=CATDRAMA_CAPTURE_PORT='<访客或iOS宿主端口>' --keep-app-running
```

iOS将平台改为ios，并选择对应自有QA模拟器。系统采集不用SDK图片充数。[analyze原日志](analyze-final.log.gz)、[格式](format-final.log.gz)、[相关回归](related-final.log.gz)、[全套原事件](full-tests-final.jsonl.gz)、[Android原日志](android-drive.log.gz)、[iOS原日志](ios-drive.log.gz)、[iOS复跑](ios-confirmation.log.gz)。

[文档复检](document-review.json)已核对47任务、186用例编号、原用例正文/执行状态、局部链接、六处路径守卫及audit；源文件、原始日志gzip及最终截图摘要一致。只补执行记录，未推进阶段。

## 剩余验收与清理

rq4owed6本轮仍返回Not connected to Figma，最新视觉对稿未验。真实有声模型/私有OSS、物理设备/输入法、完整报价生成及同一作品成片链路待外部条件；后台本轮未改未重跑，历史3项公共夹具失败继续保留，不能用本轮App全绿覆盖。任务保持未完成。

[运行所有权](devices/ownership.json)、[清理结果](devices/cleanup-final.json)记录仅启动并停止自有QA模拟器、精确删除56898转发；无遗留测试/采集进程。47任务仍7完成/38进行中/2待外部，186用例仍9通过/172部分/5未执行；只补执行证据，产品/设计/技术/当前产品基线未改。

本轮用量未取得，未额外查询。
