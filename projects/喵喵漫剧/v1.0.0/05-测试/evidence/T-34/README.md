# T-34 本机当前预览导出检测

日期：2026-10-15；阶段保持开发。App在dev，整项未验收。后台、数据库、依赖及商店/签名配置未改；相册写入归T-35，没有成片上传或后台剪辑接口。

## 实现与证据

固定已保存head、具体源版本/摘要、混音、文字/字幕、封面、实际画布和分数帧率后，先落同一Hive账本，再启动唯一原生任务。未知回执只查询原ID/文件；确认失败或中断后手动重试固定旧输入；成功结果保存失败只补存。发布前实读MP4轨道/尺寸/帧率/时长/摘要与内嵌PNG，媒体/当前指针/首次导出事实同事务提交。

- 210项相关App方法（新增32逻辑＋5Widget）与16项插件方法（新增3项）通过，0失败/跳过；[App清单](flutter-summary.json)、[插件清单](plugin-summary.json)。加载/teardown隐藏事件不算独立方法。
- analyze无问题，30份Dart最终格式检查零变更；[日志](flutter-analyze.log)、[格式](format-result.json)。只格式化controller后未重复计算测试，Kotlin方法名修正在最终APK中编译验证。
- iPhone 15 Pro Max / iOS26.4模拟器，主流程与真实进程恢复各1项通过；[主流程](ios-export-result.json)、[恢复](ios-recover-result.json)。seed准备阶段由主机故意终止，不作为通过方法；[实际终止点](cold-seed-proof.json)、[被中断driver日志](ios-cold-seed-interrupted.log)。
- [三份MP4](ios-artifacts/)均独立解码：[横竖主流程](media-verification.json)、[冷启动原文件](cold-media-verification.json)。横屏320×180/24fps/96帧、竖屏180×320/30000/1001fps/120帧，4秒；封面covr准确，未变第一帧/时长。静音窗RMS=0，导入音轨/镜头原声窗均有真实信号；250/3750ms无字，750/2500ms有字。黑边像素比例1.0；750ms截图排除播放按钮后仍有中文字像素。
- 6张截图已视觉核对：横竖画布确认/不可关闭等待/实际预览与恢复预览；尺寸和名称为实际夹具值。[Figma四帧及三倍率原切图记录](figma-nodes.json)，当前通道rq4owed6。
- Android APK已构建：[文件摘要及标识](android-artifact.json)、[日志](android-build.log)。未安装到正在进行其他测试的Android真机，实际Android媒体及两端真机性能未执行。

## 复现

App工作目录：`/Users/soul/code/lxwx/catdrama`。Flutter SDK：`/Users/soul/data/flutter/flutter/bin`；本机镜像与SDK路径只用于执行，不提交私密配置。

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter test --machine test/editor/clip_tools_test.dart test/editor/local_export_test.dart test/editor/local_export_widget_test.dart test/editor/local_store_test.dart test/editor/preparation_ui_test.dart test/editor/subtitle_task_recovery_test.dart test/editor/subtitle_test.dart test/editor/text_draft_test.dart test/editor/text_editor_widget_test.dart test/editor/timeline_commands_test.dart test/editor/timeline_media_test.dart test/editor/timeline_restore_test.dart test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter analyze --no-pub
```

插件工作目录为`packages/native_media_engine`，执行`flutter test --machine`。Android执行：

```sh
JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' ANDROID_HOME=/Users/soul/data/android_sdk ANDROID_SDK_ROOT=/Users/soul/data/android_sdk PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build apk --debug --no-pub
```

iOS执行以下命令；main、seed-result、recover分相。每相使用相应`CATDRAMA_EXPORT_PHASE`与证据phase名称。seed-result写下实际完成文件/持久ENCODING-PACKAGING的marker后等待主机；核对SHA/字节后用`xcrun simctl terminate <测试模拟器ID> com.lxwx.catdrama`终止，再运行recover，不能清理恢复根目录。这里只能终止本任务测试App。

```sh
PATH=/Users/soul/.gem/ruby/2.6.0/bin:$PATH PUB_HOSTED_URL=https://pub.flutter-io.cn CATDRAMA_MEDIA_EVIDENCE_DIR='/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-34' CATDRAMA_TEST_PLATFORM=ios CATDRAMA_EDITOR_PHASE=main flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart  --target=integration_test/local_export_test.dart --dart-define=CATDRAMA_EXPORT_PHASE=main  -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
```

在工作区执行独立解码（需要主机ffmpeg/ffprobe及Pillow）：

```sh
/Users/soul/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3  v1.0.0/05-测试/evidence/T-34/verify_media.py
/Users/soul/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3  v1.0.0/05-测试/evidence/T-34/verify_media.py  v1.0.0/05-测试/evidence/T-34 ios-cold-checks.json cold-media-verification.json
```

## 已发现并复检的问题

- 首次iOS安装出现IXErrorDomain19终止断言；仅重启当前QA模拟器、不清除数据后主流程/恢复通过。
- 最初750ms页面仍可能显示封面：播放器尚未就绪及旧定位回执覆盖导致。修正READY/初次seek屏障、实际位置回执和轮询代次保护；最终帧像素及控制器回执均通过。[原负证据](before-preview-fix/)保留，不作为通过图。
- Android首次编译的方法`isSizeAndRateSupported`不存在。由本机SDK javap核对为`areSizeAndRateSupported`后最终APK通过。[原失败](android-build-before-fix.log)。
- seed主机监视器启动晚于marker且错误使用新鲜度门槛，未及时触发终止；之后独立核对原文件/持久状态并实际终止App，恢复同一ID/attempt=1/摘要成功。此为主机测试调度问题，不算产品恢复失败或完整seed通过。
- 最终格式检查发现1个controller排版需调整，已格式化；[原检查](format-before-final.json)保留。

## 尚待验收

活动编码中强杀、磁盘实际耗尽、两端真机/长工程性能、Android真实媒体矩阵、真实模型/OSS/ASR链路、T-27版本替换全链路、T-35相册权限/写入/重试及T-39成长领取。当前低分辨率样片和声音为自建夹具，不能作为模型成片质量/对白识别或真机性能证明。

[逐条部分验证范围](case-results.json)、[实际源码摘要](code-snapshot.json)、[总结果](result.json)。原件备份在before/app，未改上线基线，不把方法数折算成完整验收用例数。
