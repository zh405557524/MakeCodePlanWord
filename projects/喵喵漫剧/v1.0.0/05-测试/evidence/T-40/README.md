# T-40 设置、缓存管理、反馈和有效正文

2026-10-16：功能已实现，整项仍为未完成·待联验。前后端dev分别提交，未推送或部署；[提交](commits.json)、[源码](final-source-manifest.json)。数据库改动：无表/列/索引/SQL迁移，既有反馈服务及当前App配置复用。专用PG非系统schema剩余0且已停止。

设置沿现有CacheService/MediaCacheScope.previewIdle/clearIdle及同一Hive账本；确认后仅清原账号作用域，保护未过期作品/撤销链和活动任务，不碰工程、草稿、付款意图或系统相册。上限先保存才更新预算，失败保持原值。正文只读当前App正式接口，空配置明确提示，实际App版本来自PackageInfo；HTML禁脚本，允许初始about/data文档和本页锚点，不将外部链接作为正文导航。

反馈沿公共POST /api/feedback，Unicode500字、可选联系、真实记录回执；失败保输入，等待防连点，成功返回原来源。晚回包、账号/环境变更和等待中手改均已保护。后台只对catdrama增加500码点上限，其他App与公共DTO1000长度规则保留。

23项后端（新增9，另配置14），155项相关App（新增29），0失败/跳过；analyze无问题、18文件格式、Android debug APK与iOS模拟器debug构建通过。[后端](backend-summary.json)、[App](app-summary.json)、[构建](build-results.json)。App155由最终29项设置复检加本轮未受影响的126项相关通过证据组成，不宣称最后一次命令运行155项；重复运行不累加。构建后仅调整Widget截图范围，生产Dart未变化。

5张Widget图已查看：[反馈失败](feedback-failure.png)、[清理确认](settings-clear-preview.png)、[真实释放量](settings-cleared.png)、[正文](static-configured.png)、[未配置](static-unconfigured.png)。仅为受控HTTP和小屏Flutter渲染，部分图有测试debug标识，不替代两端或Figma精确验收。最新通道rq4owed6未连接，设计引用5:1504/5:1622/5:2015/5:8440及既有参考，未伪称读取了最新帧；无新图片资产。

原始失败均保留：首次后台测试辅助方法与父类count重名，已改反馈专用命名；App初始空Authorization头断言按公共null覆盖契约修正；真实修正小字节释放显示、无效上限、偏好写失败旧预算、退出期间迟到统计与静态错误码字符串匹配。HTML导航经自检增加初始文档允许，未声称已跑原生HTML页。部分删除故障用自有临时目录chmod只读制造，真实释放40 B、失败50 B保留，恢复后可重试；不冒充Android/iOS系统磁盘或相册故障。初次dart fix双目录参数失败仅属工具用法，最终分目录执行并检查。

## 复现

在App仓库：

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter test --no-pub test/settings/settings_test.dart --reporter json
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter test --no-pub test/services/editing_cache_test.dart test/payment/recharge_test.dart test/pages/account_session_test.dart test/app_bootstrap_test.dart test/services/resource_identity_test.dart test/editor/local_export_test.dart test/editor/local_export_album_test.dart --reporter json
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter analyze --no-pub
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build apk --debug --no-pub
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build ios --debug --simulator --no-codesign --no-pub
```

Flutter路径`/Users/soul/data/flutter/flutter/bin`；JDK为Android Studio的`Contents/jbr/Contents/Home`，ANDROID_HOME与ANDROID_SDK_ROOT为`/Users/soul/data/android_sdk`。截图环境变量CATDRAMA_SETTINGS_EVIDENCE_DIR指向本目录。

后台使用Java21及[专用测试PG](postgres.json)（已停止，重跑需先启动本人专用实例）：

```sh
CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:51346/catdrama_test ./gradlew test --tests '*CatdramaFeedbackTests' --tests '*CatdramaConfigTests' --max-workers=2 --console=plain --no-daemon
```

真实手机到已部署公共接口、原生HTML、当前配置正文、系统拒绝/设置恢复、两端真实容量/生命周期及最新Figma仍待T-43联验；不因当前构建或分层测试标整项完成。[用例](case-results.json)、[自检](review.json)、[保护其他改动](preservation.json)。五条AC均仅部分验证；全局186条为9通过/169部分/8未执行。下一任务T-41保留期和引用保护。
