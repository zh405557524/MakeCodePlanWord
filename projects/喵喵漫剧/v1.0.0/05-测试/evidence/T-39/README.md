# T-39 两项成长资格与一次性领取

2026-10-16：功能已实现，整项保持“未完成·待联验”。App、后台分别在dev提交，见[提交](commits.json)；无推送或部署。执行者自检不代表独立评审或完整验收。

个人图仅在成功保存并应用可用图片后取得资格，自动入库首图走同一规则；候选、空卡、失败事务不满足。首导出消费既有Hive成功事实，用户主动领取时才提交clientExportId和本人源剧集ID，不传本机时间轴、音频、字幕或成片。后台只验证归属；各任务10积分、每账号一次，资格/公共发奖同事务。删除/过期不重置；网络或落盘失败恢复原领取，不改变本机导出成功状态。

相关后端90项（新增20），App110项（新增15），0失败/跳过；重复复跑不累加。Growth最终20、Asset修正后32；未受最终修正影响的自动入库23和邀请15保留本轮有效结果。App完整110后，test-only字体加载修正另复检15；analyze无问题、15文件格式未改，两端debug构建通过。[后端](backend-summary.json)、[App](app-summary.json)、[构建](build-results.json)。

[成长卡片](growth-claimed.png)为小屏Widget实际渲染，已查看；反馈在成长卡片内，不能替代两端运行或完整Figma验收。rq4owed6读取5:8073/5:8218，使用5:8173导出28/56/84px原图标，见[来源](figma-source.json)、[三倍率](image-variants.json)、[截图边界](image-evidence.json)。设计演示第三条任务不覆盖已确认的两项业务。

原始失败日志保留：初始App使用猜测的导出方法、HTTP夹具匹配path而非uri.path和清理等待修正；attempt2被明确中断，退出0不计通过。后台初始Asset旧断言随T-39资格改变、上传路由及OpenAPI内联枚举校正。真实发现的新接口坏JSON返回500已局部改400；成长提示落入签到区域及账务标题使用枚举名已修正。analyze初始14项和首次Android未设置SDK环境均已处理，最终结果为准。上述负日志不算新增通过方法。

## 复现

在App仓库，使用当前Flutter、镜像与现有依赖：

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter test --no-pub test/growth test/editor/local_export_test.dart test/editor/local_export_album_test.dart test/services/editing_cache_test.dart test/app_bootstrap_test.dart --reporter json
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter analyze --no-pub
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build apk --debug --no-pub
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build ios --debug --simulator --no-codesign --no-pub
```

工具路径：`/Users/soul/data/flutter/flutter/bin`；JDK为Android Studio的`Contents/jbr/Contents/Home`，Android SDK为`/Users/soul/data/android_sdk`，构建同时设置ANDROID_HOME、ANDROID_SDK_ROOT。单独截图复检用`flutter test --no-pub test/growth/growth_test.dart --reporter json`，环境变量CATDRAMA_GROWTH_EVIDENCE_DIR指向本目录。不是普通启动或真机验收。

后台使用Java21、自建本机PG数据库，按[postgres.json](postgres.json)登记的测试URL（重跑前先启动专用测试库）：

```sh
CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:51346/catdrama_test ./gradlew test --tests '*CatdramaGrowthTests' --tests '*CatdramaAssetTests' --tests '*CatdramaAssetLibraryTests' --tests '*CatdramaInviteTests' --max-workers=2 --console=plain --no-daemon
```

当前最终证据来自分批修复/复检及有效复用，详见每份XML与日志，不宣称最终一次运行全部90项。所有测试限自有临时schema，非系统schema剩余0且专用实例已停止；不连接生产。无需新DDL/迁移、依赖或FFmpeg；公共账务实现未重写，现有成长表及唯一约束复用。

真实OSS/Provider、两端实际“应用图/导出→任务中心→实际后台到账”、A/B独立完成领取和设备中断仍未完成。受控原生输出不证明本次实际生成了手机成片，既有T-34真实媒体证据单列保留。[用例](case-results.json)、[自检](review.json)、[源码](final-source-manifest.json)、[其他改动保护](preservation.json)。工作区当前总进度7整项完成/34进行中/2待外部验证/4未开始，186用例9通过/164部分/13未执行。
