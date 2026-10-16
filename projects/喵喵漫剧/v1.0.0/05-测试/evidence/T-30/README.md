# T-30 本机工程、真实入口与恢复

实现已提交前端dev，整项继续保持未完成。完整快照、固定来源、串行命令、撤销/重做、保存失败重试、来源引用和账号/环境隔离已接；T-29准备页/M-28及作品入口接入真实编辑器。没有后台timeline、成片上传或新的依赖/数据库改动。

实际结果见[result.json](result.json)、[逐方法结果](flutter-summary.json)、[提交与文件摘要](source-manifest.json)。128项相关自动检测（新增23）、analyze、28文件格式检查通过，0失败/跳过。后台本轮没有改动或重跑，原T-29后端证据保留。

## 真实设备范围

iPhone 15 Pro Max / iOS 26.4模拟器使用真实红/蓝MP4、原生组合预览、实际缩略图和Hive。通过实际“作品→本集视频剪辑”入口，完成准备、播放/暂停、定位、撤销/重做及保存。测试中删除未在head里的历史视频；第二进程仍恢复同一工程UUID、revision、head、selection及完整历史，准备阶段后台/清单/签名请求均为0。云端作品读取使用隔离协议夹具，不代表Java部署、真实OSS或模型输出。

write阶段使用`--keep-app-running`保留沙盒；宿主确认实际PID及expected.json存在，执行simctl terminate，确认进程消失，见[process-stop.json](process-stop.json)。随后recover阶段实际重新启动、恢复、再次预览/撤销重做。[write](ios-simulator-write-result.json)、[recover](ios-simulator-recover-result.json)、[首进截图](ios-simulator-editor-write-native-preview.png)、[恢复截图](ios-simulator-editor-recover-native-preview.png)。这是**已保存快照后的实际进程终止**，未覆盖正在写入时强杀、真实Hive put/flush磁盘故障或全量媒体矩阵。

Android debug APK已构建，aapt核实包名com.lxwx.catdrama，大小/摘要见机器结果。连接的vivo当时在其他App，保留其状态，Android实际媒体/恢复未执行；APK构建不替代真机验收。

## 自动断言和修复

- 同集并发初始化只有一个工程；固定来源与实际比例/有理帧率来自源快照，无固定分辨率档位。
- head、undo、redo、文字、字幕、音轨、封面、输出设置和选中上下文完整保存；新编辑清redo，旧revision/冲突commandId不能覆盖。
- 写入前失败保当前候选；写入成功后回执丢失只重存同一快照，revision/历史不重复；未知documentVersion保文件并拒绝误读。故障注入位于真实Hive写入前/后，不冒充真实存储介质损坏。
- head必需文件按真实大小/摘要检查；历史仍保护，但历史视频缺失不阻挡当前head。撤销若需要缺失文件则失败并保留当前文档。
- 清理预览不删文件或改索引；实际清理统计释放量并保护有效引用。M-28在320/375/430宽显示真实公式、清理/调上限/取消动作。
- 删除作品同步本机删除标记，即使删除先于首次租约也拒绝迟到复活；切账号/后台环境及保存途中切账号均不串写。日历回拨不续期。
- 设备测试修复LayoutBuilder内状态未观察导致画面不刷新；iOS AVPlayer seek等待completion再返回实际位置，并拒绝旧轮询覆盖新定位/播放回执。并发预览准备共享同一次有效性检查。

## Figma与范围差异

用户当前通道为`rq4owed6`，已连接并实际读取剪辑页19个状态；[完整节点（gzip）](figma-editor-nodes.json.gz)、[首屏原稿](figma-editor-initial.png)、[五组三倍率图标](figma-assets.json)。历史设计文件保留；当前通道同步到代码仓库AGENTS/90-project。

原稿的“字幕收起等待”“按镜头原文生成字幕”和90秒截取限制不覆盖已确认业务。主动识别实际混音、不可关闭等待、不新增90秒限制继续由T-33/T-46实施。当前页面已接真实预览/轨道与保存信息；裁剪、文字、字幕、音轨/封面工具及导出按T-31至35继续，导出入口尚未启用，截图不是完整P-19视觉验收。

本机实现另存固定sources、selection及命令回执，History保存baseRevision/inputHash，删除标记为ledger的可选deletedProjects；这些是完整快照/幂等保护的内部落盘字段，无新增后台协议。原设计/技术阶段文档保持原稿，本次只在开发结果记录实现说明。

## 复现

App仓库运行：

```sh
flutter test --no-pub test/editor test/services/editing_prepare_test.dart test/services/editing_cache_test.dart test/services/media_download_test.dart test/services/storage_isolation_test.dart test/services/resource_identity_test.dart test/projects/project_detail_test.dart packages/native_media_engine/test/native_media_engine_test.dart
flutter analyze --no-pub
flutter drive --no-pub --keep-app-running --driver=test_driver/editor_recovery_driver.dart --target=integration_test/editor_recovery_test.dart --dart-define=EDITOR_RECOVERY_PHASE=write -d "$CATDRAMA_DEVICE_ID"
xcrun simctl terminate "$CATDRAMA_DEVICE_ID" com.lxwx.catdrama
flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/editor_recovery_test.dart --dart-define=EDITOR_RECOVERY_PHASE=recover -d "$CATDRAMA_DEVICE_ID"
flutter build apk --debug --no-pub
```

驱动的CATDRAMA_EDITOR_PHASE与dart-define阶段一致；用CATDRAMA_MEDIA_EVIDENCE_DIR指定证据目录。默认Flutter drive会卸载App，跨进程检测write阶段必须保留安装与沙盒；先前未保留时的失败仅为测试编排问题，记录在ios-recover-final.log，最终有效链路是ios-write-retained.log→process-stop.json→ios-recover-retained.log。首次设备失败另外留存页面刷新/异步定位的修复前证据；不计入最终通过数量。

TC-18-03、TC-26-01和TC-X15由未执行转部分验证；其余T-29和隔离用例追加本次范围。累计9通过/130部分/47未执行，总186；不按方法数折算验收。Android实机、写入中强杀、完整已有字层离线预览/校对/导出、新获取字幕、T-27版本更换和真实OSS仍未完成。继续开发阶段及T-31，不新增审批关卡，不进入测试阶段。
