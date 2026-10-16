# T-35 主动保存相册检测

2026-10-15；阶段保持开发，整项待双端真实验收。App在dev，提交见result.json。复用写歌的Access.saveVideoToGallery与既有image_gallery_saver_plus 4.0.1，没有新增依赖、权限声明、后端接口或成片上传。

## 已验证

- 239项相关App方法通过，新增16项状态/故障、4项Widget、9项插件封装；0失败/跳过。[清单](flutter-summary.json)、[原日志](flutter-test.jsonl)。加载/teardown/重复运行不计入独立方法。
- analyze无问题，20份Dart格式检查零变更；[静态](flutter-analyze.log)、[格式](format-result.json)。native_media_engine源码未改，其16项沿T-34有效基线保留，本轮未重跑。
- 相册状态独立于导出成功，原SAVING先落盘再写系统；重复点击等同一操作，系统明确失败只重存原MP4。未知回执保SAVING，恢复先提示检查相册，明确确认后才重存；成功/失败回执的记录写盘失败只补原记录，不再次请求权限或系统写入。
- 系统已经成功但记录失败时仍展示“已保存到相册”，提示重试记录；不把记录失败当作视频保存失败。保存旧成片不移动最新导出指针或修改工程。
- iPhone15ProMax/iOS26.4模拟器：1项实际流程通过，3张截图已核对。先注入明确失败，再真实调用相册插件保存同一原文件，1个编码任务、1次实际系统成功写入。[设备结果](ios-album-result.json)。
- 系统副本与原MP4 SHA-256一致，H264/AAC、320×180、24/1、2秒/48帧；应用临时成片清理后，系统副本仍可独立解码。[真实系统副本校验](gallery-verification.json)、[实际文件](ios-artifacts/system-gallery.mp4)。
- 测试时仅添加权限获准、相册读取被拒绝，真实保存仍成功；测试后只恢复本App这两项权限到测试前状态。[权限恢复](permission-restoration.json)。预授权是QA条件，不作为首次弹框或设置返回的验收。
- Figma rq4owed6的5:6413/5:6458及4组原图片/状态图标三倍率直接使用，按钮同色绿渐变，真实名称/封面/规格；[源节点](figma-nodes.json)。负的旧配色图片在before-visual-polish，不作为最终图。
- Android APK构建通过：[摘要及正式标识](android-artifact.json)、[日志](android-build.log)。未安装到正在测试其他App的Android真机，实际系统保存另验。

## 复现

App工作目录`/Users/soul/code/lxwx/catdrama`，Flutter SDK为`/Users/soul/data/flutter/flutter/bin`。

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter test --no-pub --machine test/editor/clip_tools_test.dart test/editor/local_export_album_test.dart test/editor/local_export_album_widget_test.dart test/editor/local_export_test.dart test/editor/local_export_widget_test.dart test/editor/local_store_test.dart test/editor/preparation_ui_test.dart test/editor/subtitle_task_recovery_test.dart test/editor/subtitle_test.dart test/editor/text_draft_test.dart test/editor/text_editor_widget_test.dart test/editor/timeline_commands_test.dart test/editor/timeline_media_test.dart test/editor/timeline_restore_test.dart test/plugins/media_library_test.dart test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter analyze --no-pub
JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' ANDROID_HOME=/Users/soul/data/android_sdk ANDROID_SDK_ROOT=/Users/soul/data/android_sdk PUB_HOSTED_URL=https://pub.flutter-io.cn flutter build apk --debug --no-pub
```

iOS实际流程使用已有test_driver/editor_recovery_driver.dart，目标integration_test/save_video_test.dart。仅对本任务QA模拟器/本App预设“读取拒绝、添加允许”，记录测试前TCC状态和DCIM文件列表，测试结束恢复原权限。正常App仍通过用户主动点击及公共权限入口申请。

```sh
PATH=/Users/soul/.gem/ruby/2.6.0/bin:$PATH PUB_HOSTED_URL=https://pub.flutter-io.cn CATDRAMA_MEDIA_EVIDENCE_DIR='/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-35' CATDRAMA_TEST_PLATFORM=ios CATDRAMA_EDITOR_PHASE=album flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/save_video_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
```

工作区执行`python3 v1.0.0/05-测试/evidence/T-35/verify_gallery.py`，主机需ffprobe。脚本只读本次系统视频及留存副本，核对摘要/真实编码，不改变相册或权限。前置DCIM列表用于仅识别本次新增视频，不删除或读取原有媒体内容。

## 修正及边界

初始夹具错误使用不存在的MUTE命令、只改单独token字段而未经过实际切账号入口，已分别改为SET_CLIP_AUDIO与真实saveSessionFromAuth。Widget初始同名标题/按钮选择器和过早只等系统成功、未等页面完成的问题已修正。负日志保留，最终239项通过才计入结果。主机首次元数据命令使用不存在的build-tools/36.0.0路径，随后从已安装工具中解析aapt，构建结果不受影响。

保存失败的设备分支为注入，不等于真实磁盘耗尽；真实系统拒绝/设置恢复、OS写相册中断、Android实际保存、两端真机/空间/生命周期以及T-27/T-39完整联验仍未执行。当前样片/声音自建，不作为真实模型或ASR验收。测试重复运行不重复计数；相册中仅新增本任务样片，未清理其他媒体。

[逐条部分验证](case-results.json)、[源码摘要](code-snapshot.json)、[总结果](result.json)。未改产品/设计/技术与上线基线。
