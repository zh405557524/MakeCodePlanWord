# T-46 试听生命周期与相册提音复检

2026-10-17，App dev `a08b5701505008bc8282f7d31f31a2286bd1f583`，未推送。修复切片及可执行验证完成，T-46整项继续待真实验收。

原实现先await设备/期限检查，之后才登记播放器。校验间关闭或切后台时，stopPreview尚无编号可取消，迟到请求仍会开始试听；旧稿不变但可能离开后出声。先登记本次短期意图，关闭/后台同时使其失效；旧回执只释放原编号，不清新试听。弹层仅显示当前代次的真实错误。意图不入Hive，原提取/ADD_AUDIO/未知任务恢复均保留。

| 检测 | 实际结果 |
|---|---|
| 修复前复现 | 2个新用例均失败，关闭/后台后仍返回PLAYING；[原日志](before-fix.log) |
| 专项 / 相关 / 全套 | 40 / 306 / 1185个方法通过；7项新增，0失败/跳过；不累计加载和收尾 |
| 静态 / 格式 | analyze无问题，7个Dart文件0格式变化 |
| Android / iOS | 各1条完整原生方法通过；系统相册、真实选轨/波形/试听、独立提取和导出 |
| 实际产物 | 每端M4A、16k单声道混音WAV、H.264/AAC MP4；共6份完整解码，SHA/大小与原生回执一致 |
| 截图 | 每端6张流程图及2张系统确认图；16张总览，5张关键图详检 |
| 路径脚本 | check/audit通过，5项隔离自检通过；脚本为此前已补齐版本 |

使用[既有自建92秒双音轨样片](../generate-fixture.sh)，SHA固定在[夹具记录](fixture.json)。440Hz是默认轨，880Hz是明确选取的另一轨。最终预览/提取同为90500–91500ms，不改clips；声音修订增加，源私有副本清理。系统删除只针对按摘要核对的自建源，独立音轨继续参与当前混音及导出，2秒后无循环声音。[逐项断言](case-results.json)、[独立解码](media-check.json)。

暂停检测先用80000–91000ms，避免1秒试听在系统截图期间自然结束；之后恢复90500–91500ms并试听、提取同一轨道和区间。Android独立AAC实际1045ms（编码边界），工程仍用确认的1000ms；iOS实际1000ms。成片实际时长为Android14042ms、iOS14003ms，均按真实探测记录；这些自建低分辨率样片不限定正式模型/设备输出规格。

区间通过真实RangeSlider的回调输入，系统授权和删除确认由电脑处理；不冒充真机手势或全程无人工介入。最终两端使用相同脚本摘要，最终原生脚本补强后只重跑原生链路；[全套时源码](unit-run-source-freeze.json)与[最终源码](source-freeze.json)除该集成脚本外保持一致。后台、媒体引擎、模型/API/路由、存储格式和依赖未改。App继续Flutter＋Media3/AVFoundation，电脑FFmpeg只作独立解码。

历史尝试完整保留：初次设备发现失败；缩略图误按RawImage定位而实际为ExtendedRawImage；iOS授权返回后点击了未启用帧；短试听在截图期间结束。最终按App回前台及当前InkWell可点等待，结算帧后重新核对条件，原业务断言保持。前次Android成功存入attempts/06，不重复计数。初轮全套另有公共反馈pumpAndSettle超时（1184通过/1失败），未改原页面和断言，单独29项及全套复跑均通过；[统计](test-summary.json)。

本机夹具故意不注册HTTP服务，版本核对显示可继续本机版本的提示并保留日志；该提示不代表真实后台/OSS已连通。真实Provider/ASR、有限/拒绝权限、云端占位、真机/长片/空间耗尽与活动任务强杀继续待验。当前Figma通道rq4owed6未连接，精确视觉验收不作通过。正式186条定义及状态仍为9通过/172部分/5未执行，阶段保持开发。

[Android总览](android-contact.png) · [iOS总览](ios-contact.png) · [源码/边界复核](verification.json) · [结果](result.json) · [系统确认记录](devices-and-fixture.json)

复现自动验证，在App目录运行：

```sh
flutter analyze --no-pub
flutter test --no-pub test/editor/source_audio_import_test.dart test/editor/source_audio_widget_test.dart
flutter test --no-pub test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/app_bootstrap_test.dart
flutter test --no-pub
```

原生流程使用`integration_test/source_audio_import_test.dart`及`test_driver/catdrama_business_driver.dart`，切片`source-audio`；传入本目录fixture.json中的SHA和单独截图端口，先将该自建样片加入专用设备相册。实际驱动和截图命令见[native-commands.json](native-commands.json)，两端原始drive.log保留输出。`python3 verify-media.py`重查媒体，`python3 verify.py`重查源码、日志、图片及文档边界。originals仅为本机备份，不提交。
