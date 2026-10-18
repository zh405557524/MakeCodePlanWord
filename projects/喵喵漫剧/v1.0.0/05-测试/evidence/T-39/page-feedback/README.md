# T-39 任务中心领取状态复核

2026-10-17：本机页面修复及检测通过，整项 T-39 仍未完成。App dev `9e07713f1032ca9d0f28f841ebb9b55314112c83`，未推送。后台、公共发奖、接口、数据库、依赖和媒体引擎本轮未改未跑；没有生成图片、视频或首次导出事实。

领取期间，签到、待核对签到的查询和刷新按钮均禁用；领取结束恢复。旧代码读取方法已限制领取互斥，页面按钮没有同步。外层 Obx 订阅 claimingGrowth，查询 getter 复用同一条件；余额仍使用原公共账户回执。首次红例中的余额是正确的，本次不登记余额缺陷。

| 场景 | 实际观察 | 证据范围 |
|---|---|---|
| 领取中的按钮 | 签到和刷新变灰，成长卡显示领取中，结束后恢复；受控账户从70到账80，页面采用80而非旧30自行加10 | 双端实际页面/HTTP/Hive；资格、账户受控 |
| 领取回执丢失 | 页面保旧30，用户重试时GET原状态和账户到40；同一Hive键，领取POST仍1次，重进已领不可点 | 无重复POST，不代表生产发奖证明 |
| 资格读取失败 | 成长卡显示错误，公共签到仍可用，到33；重取资格不自动领奖 | 既有公共规则保持 |
| 签到结果待核对 | 领取中查询禁用，到43后恢复；点击查询只GET，签到和领取各1次POST | 原签到恢复，不重做签到 |

最终检查为1项新增并补强1项既有Widget用例，16成长专项包含在54相关检查内，包含在1260全套App测试内，不相加。均0失败、0跳过；analyze及6份Dart格式检查通过。Android/iOS各4条完整页面方法、各13张操作系统截图通过；SDK的“+6”含两个全局hook，不算六条业务。26张图及六份总览已实际查看，滚动位置不同造成首尾卡片在视口外，不作为整页截图。

| 材料 | 链接 |
|---|---|
| 结果与逐条边界 | [result](result.json)、[case-results](case-results.json)、[defects](defects.json) |
| 最终自动检查 | [54相关](related-verified.json)、[16成长派生结果](growth-verified.json)、[1260全套](full-verified.json)、[analyze](analyze-verified.json)、[格式](format-final.json) |
| 最终双端 | [Android报告](native-02/android/android-growth-rewards-result.json)、[iOS报告](native-02/ios/ios-growth-rewards-result.json) |
| 原始系统图索引 | [26图及摘要](screenshots.json)、[人工查看记录](visual-review.json) |
| 图像总览 | [Android1](contact-sheets-final/android-1.jpg)、[Android2](contact-sheets-final/android-2.jpg)、[Android3](contact-sheets-final/android-3.jpg)、[iOS1](contact-sheets-final/ios-1.jpg)、[iOS2](contact-sheets-final/ios-2.jpg)、[iOS3](contact-sheets-final/ios-3.jpg) |
| 失败与修正 | [attempts](attempts.json)、[初始红例](red.json)、[查询分支真正红例](red-query-corrected.json) |
| 源码、日志和范围 | [source](source.json)、[日志归档及原/公开摘要](log-archives.json)、[scope](scope-check.json)、[清理复查](cleanup-recheck.json) |
| 门禁及复核 | [文档门禁](guard-before-docs.json)、[manifest](manifest.json)、[只读复核](verification.json) |

`native-01`保留最初双端三方法/20图成功记录；随后扩展签到待核对分支，最终以`native-02`四方法/26图为准。初次新增分支测试仍错误要求不存在签到消息，另有旧余额键名及结尾条件沿用；这些已修正，不作为产品缺陷证据。`red-query-corrected`才是在控制器未修复时查询按钮仍启用、刷新已禁用且余额正确的负例。早期15/53/1259成功记录与格式info也保留，均不重复计数。受控夹具用finally保留已完成但回执丢失的签到余额，未改变公共签到实现。

复用原LocalGrowthFactsService、HTTP、GetStorage及Hive，不新增领奖流程或存储。视觉沿[既有T-39来源](../README.md)的Figma节点5:8073/5:8218及5:8173，没有本轮最新Figma验收。与[API §11](../../../../03-技术规划/api.md#api-11)的个人素材领取空body、原幂等键和公开账户回执保持一致。

在App仓库可运行：

```sh
flutter test --no-pub test/growth/checkin_invite_test.dart test/growth/growth_test.dart test/services/storage_isolation_test.dart test/integration/session_race_test.dart
flutter analyze --no-pub
flutter test --no-pub
```

本目录的`run_native.py`只使用指定自有模拟器及只读设备辅助函数，检测会安装App测试构建。重跑应使用新的`native-*`目录，不能覆盖既有结果或占用其他人的设备；保持真实相册和授权。只读复核使用`python3 verify.py`，不会启动后台、生成或领奖。压缩日志与原始日志逐份摘要对应，仅公开日志中的ADB公钥被遮盖；本机`originals/`排除提交。26份截图、原始私有日志及历史失败均保留。

仍待实际个人图片/生成或导出到真实后台领取、OSS/Provider、A/B完整独立业务、系统终止恢复、物理设备及最新Figma。两端使用真实页面和本机Hive、真实回环HTTP，但账户/资格是受控数据；无真实Java或积分账务验收。47任务7完成/38进行中/2待外部、186用例9通过/172部分/5未执行保持，阶段仍为开发。
