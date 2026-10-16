# T-46 相册视频提取音轨：实施与检测

2026-10-16。App dev提交 `c044e3d4a96e493f1a61aee9e1fbc84cdfac1787`，未推送。实现已完成，整项仍未完成。后端、数据库、外部依赖及生产环境未改；iOS只追加系统Photos框架并刷新本地插件Pod校验值。

MediaLibrary沿写歌既有单选插件和公共视频权限；LocalAudioImportService在同一Hive账本audioImports保存操作、候选和原ADD_AUDIO命令。选轨真实波形、试听及提取共用身份与范围，不混入默认语言。源视频不入clips、不上传，输出为独立M4A/AAC且≤50 MiB，无90秒限制；源视频按缓存及磁盘预算。未知只查询原编号，保存失败补原结果/命令；作品期限、账号、撤销链和缓存保护沿现有实现。

| 检测 | 实际结果 |
|---|---|
| App相关回归 | 263个方法通过，0失败/跳过；其中31项新增，排除加载和收尾计数 |
| 插件协议 | 23个方法通过，其中7项新增；属于受控通道验证 |
| 静态/格式 | analyze无问题，18份Dart格式及白空格检查通过 |
| Android | 原生Kotlin编译和debug APK构建通过，未作为实际播放/相册证明 |
| iOS | 最终模拟器构建通过；1个真实相册/媒体方法通过，重复执行不累加 |
| 独立媒体检查 | 手机产生的M4A、16k单声道PCM WAV、MP4均完整解码；所选880Hz与默认440Hz分离，尾部无循环 |

真实流程使用自建92秒、440/880Hz双音轨视频。相册选择前按摘要锁定唯一测试文件；在实际选轨和RangeSlider回调设置90500–91500ms，试听、提取、原ADD_AUDIO保存，确认clips不变和声音修订递增。系统删除仅针对该测试源，进入“最近删除”；独立音轨继续通过当前混音和本机导出。系统删除确认由电脑操作完成，毫秒范围由测试回调输入，不能写成全程无人操作或真机手势验收。

前期问题均留在日志：脚本缺少权限等待、使用未加载的相册title、选择器确认按钮识别错误；iOS暂存扩展名导致探测失败，及并发写入重复计量引发假空间不足，已修正。attempt4/5主动中止，不作通过；attempt7/8实际通过。来源面板与选段图已检，相册截图仅是加载态；最终小调显式白色滑块和真实系统文件名后，相关回归及两端构建通过。

App实际方案为Flutter页面＋iOS AVFoundation／Android Media3及原生编解码。FFmpeg仅用于本目录生成夹具、在电脑独立解码核验，不在App或后台承担剪辑合成。

复现命令（工程目录运行）：

```sh
flutter analyze --no-pub
flutter test --no-pub test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/app_bootstrap_test.dart
```

插件在 `packages/native_media_engine` 运行 `flutter test --no-pub`。真实相册流程先运行本目录 `sh generate-fixture.sh`，把该视频加入专用测试设备相册，并将文件SHA256作为 `CATDRAMA_SOURCE_AUDIO_SHA` 传给 `integration_test/source_audio_import_test.dart`；驱动为 `test_driver/editor_recovery_driver.dart`。原始样片只用于本机测试，重新生成不会发请求或扣积分。真实iOS输出在本目录ios-artifacts，`python3 verify-media.py`重新生成独立解码结果。

仍待：Android实际媒体；两端真机及长片/真实空间耗尽/进程强杀；有限或拒绝权限、云端占位视频；真实ASR/OSS结果与字幕时段联验。当前正弦音不能证明对白识别或生成模型质量，不把构建和受控故障当成这些验收。

证据：[总结果](result.json)、[逐项用例](case-results.json)、[App方法](app-test-summary.json)、[截图](image-evidence.json)、[真实iOS](ios-native-checks.json)、[独立解码](media-check.json)、[复核](review.json)。完整输出、原始失败及最终日志保留；originals备份留在本机，不纳入提交。
