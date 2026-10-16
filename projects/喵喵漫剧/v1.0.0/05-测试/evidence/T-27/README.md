# T-27 免费应用视频与本机显式换版

当前：功能已实现、部分验证，整项仍未完成。App dev `fafb632`，后端dev `54eb67b7`，均未推送。汇总：[结果](result.json)、[逐用例](case-results.json)、[原始代码与提交](source-manifest.json)。产品/设计/技术及上线基线未改。

新增11项后台、20项App。68项相关后台、297项相关App全部通过，无失败/跳过；iOS实际媒体1项通过，重复运行、截图和teardown不累计。analyze无问题，23个Dart文件格式0变更，Android debug APK已核对 `com.lxwx.catdrama`。Android设备当时在验收其他App，本轮未安装或打断。[后台方法](backend-summary.json)、[App方法](flutter-summary.json)、[分析](analyze-final.log)、[格式](format-final.log)、[Android](android-artifact.json)。

## 实际实现及边界

`POST /api/drama/shots/{shotId}/videos/{versionId}/apply`接收严格正整数CAS和明确确认，原Idempotency-Key先持久化。Service复用来源草稿动作回执及草稿→作品→镜头锁序；校验本人同镜头成功、仍可读的历史原快照。不创建Job、收费、改截止或文件；应用只更新镜头指针/修订。重放读取当前Shot，后来的选择不会被旧请求回滚。有效作品保护的旧视频继续可用，失败/处理中/过期无保护/坏元数据不能应用。Shot装配可读取当前配置；资格检查沿原成功版本，未调用AI生成。

App复用原ShotAction、DramaShotService原操作队列及公共存储，不新增HTTP/KV/轮询器。未知回执继续原键、原CAS、原版本；失败响应与解析失败区分。历史即使为空/全失败仍可打开，只有成功项可试听和明确应用。Figma `rq4owed6` 已实际连接，读取7帧，查看 `5:10225` 原PNG；重用现有三倍率图片。[设计来源](figma-source.json)。

本机只读核对写同一Hive账本 `videoChecks`，记录服务端核对时刻，失败展示上次核对并允许原固定源离线使用；检测本身不改head/导出。用户明确更新时列出全部受影响分割片段、默认全选并可取消。只下载所选新版，复用原容量/摘要/原生探测；下载后及保存前再次核对当前应用。越界必须明确重裁或使用全段，不比例换算或自动裁短。全部合法才一次提交，未选保原版本。文字/字幕/封面/音轨按片段锚点映射，字幕标待复核；实际换版使旧成片过时，旧MP4和相册内容保持。

LocalEditorStore复用原完整快照/串行命令/文件校验/一次撤销，未增加第二套剪辑存储。明确写前失败保旧head；put后回执未知保原候选、只补保存，不能倒写旧状态或重复执行命令。内存与持久化记录分开核对。

## 检测与复现

App在 `/Users/soul/code/lxwx/catdrama`，现有Flutter，`PUB_HOSTED_URL=https://pub.flutter-io.cn`，均 `--no-pub`：

```sh
flutter test --no-pub test/shots/video_apply_test.dart test/editor/video_replace_test.dart test/editor/video_replace_widget_test.dart test/editor/video_replace_export_test.dart
flutter analyze --no-pub
flutter build apk --debug --no-pub
```

新增20项均在297项相关回归内；[24个相关套件](app-regression-suites.json)含T-35原有效239项、镜头详情/视频生成回归与本轮新增。[完整事件](flutter-regression-1.jsonl)、[末次历史控件复检](flutter-history-visual-final.jsonl)。单元层使用真实Hive/临时文件和HTTP协议，原生探测/媒体元数据、资源与Provider返回是受控边界，不能宣称真实OSS或Android播放通过。

后台在 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，现有Android Studio JBR，临时独占PG端口56287、用户/库catdrama_test；仅随机自有schema。实例路径必须匹配既有测试护栏，不访问共享数据库。验证完成后自有schema剩余0、实例已停止；复现时自行启动独立测试实例并传对应 `CATDRAMA_TEST_POSTGRES_URL`：

```sh
./gradlew test --offline --console=plain --tests com.lxwx.narrateservice.CatdramaVideoApplyTests --tests com.lxwx.narrateservice.CatdramaShotTests --tests com.lxwx.narrateservice.CatdramaDownloadManifestTests --tests com.lxwx.narrateservice.CatdramaVideoTests
```

[实际日志](backend-attempt-2.log)、4份压缩JUnit XML、[自有schema](schemas-after-backend.txt)、[停止回执](postgres-stop.log)。包含真实HTTP/JWT/PG事务、并发CAS、回执回滚、跨账号/App和有效保护，以及T-26原Worker/公共账务/FFmpeg坏文件/首应用回归。模型和OSS仍为受控替身。无表、字段、索引、迁移、存量修复或生产操作。

## iOS实际文件及画面

iPhone 15 Pro Max模拟器 iOS26.4，`E33B4820-6860-419F-8B17-B6A8FA94EA77`。新用独立测试目录，没有清除已有工程或相册。使用10秒H264/AAC测试源与4.004秒竖屏原文件：旧[4,9]保持；非法新版裁剪被拒绝；选择全段后整次换版、字幕待复核、一次撤销/重做。旧成片仍在，重新导出实际12.012秒MP4。实际App ExportPage定位750ms后抓图，已查看可见的视频画面；独立FFmpeg完整音画解码和字幕抽帧通过。[实际回执](ios-video-version-result.json)、[实际页](ios-video-version-native-preview.png)、[MP4核验](media-verification.json)、[成片](media/ios-replaced.mp4)、[750ms帧](media/ios-frame-750ms.png)。自建低分辨率/合成音/测试字幕仅证明媒体处理，不代表模型、对白/旁白或真实ASR质量，未操作相册。

```sh
PATH=/Users/soul/.gem/ruby/2.6.0/bin:$PATH PUB_HOSTED_URL=https://pub.flutter-io.cn CATDRAMA_MEDIA_EVIDENCE_DIR=工作区证据绝对目录 CATDRAMA_TEST_PLATFORM=ios CATDRAMA_EDITOR_PHASE=video-version flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/video_replace_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
```

原始结果：[真实页检测](ios-native-page.log)。3张真实Widget图也已查看：[历史](screenshots/video-history.png)、[分割选择](screenshots/split-clip-selection.png)、[越界](screenshots/shorter-video-range.png)。无后期修改；测试没有封面时显示真实占位。历史关闭与播放使用明确可见的控件，封面占位复用既有三倍率资源；末次5项Widget复检通过，不重复累计方法。

## 发现与修正

- BUG-T27-001：写后回执失败时从共享Session读取旧内存head，错误判成未提交。现在直接读Hive记录；写前失败保旧，写后未知补存原候选。新增故障断言通过。
- 初次后台测试将读取模型配置误断为AI生成外呼；修正为验证无AI生成、Job/收费/截止不变，重验68项通过。[首次结果](backend-attempt-1.log)。
- 初次Widget截图在假时钟里等文件IO，已停止该次运行；改runAsync后完整回归通过。初次App格式/静态问题亦已修正，[首次事件](flutter-attempt-1.jsonl)、[初始分析](analyze-attempt-1.log)。
- 简化Texture测试夹具抓到黑屏，未作为有效视觉证据；保留[诊断图](attempts/bare-texture-black-diagnostic.png)与[状态](attempts/bare-texture-native-state.json)。改为实际ExportPage复检，真实画面和字幕帧已看；这是测试夹具修正，没有改动既有播放器引擎。

## 保留的未完成项

真实Provider/私有OSS的应用→下载链路、Android实际换版/预览/导出、两端真机长片/性能、真实空间与生命周期中断仍待验证；不以Mock或APK构建代替。七条TC-15均仅部分验证；总186条为9完整通过/160部分/17未执行。开发任务为7完成/32进行中/2外部/6未开始，已开展41项。后端原Catseller改动及工作区其他改动均保留，只提交本任务白名单。
