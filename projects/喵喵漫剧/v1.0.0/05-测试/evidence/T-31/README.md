# T-31 本机片段编辑与恢复检测

2026-10-15，App `dev` 提交 `97b9dc2bdb42f100e256f7dadc4b453f123e5e00`。功能已实现，整项仍待两端真机及下游联验。后台、数据库、依赖和原生平台源码无修改。

## 已验证

- 118项相关App自动检测全部通过，0失败/跳过；新增44项。纯命令、实际Hive/私有文件、HTTP清单契约、真实PNG解码/随包字体排版和弹框交互分层断言，原生音频探测在单位层受控，不当作设备证明。
- 裁剪可在源真实边界内调整，片段/分割两侧至少500ms；最后一片拒删。文字/字幕按明确源锚点投影，分割新片段显式映射，不靠编号/位置猜测来源。
- 原镜头只排除完全不在轴上的shot；任一残片阻止重复添加。所选当前视频完整恢复，按原顺序插入；新来源与完整工程原子保存，原commandId重复不再插入。下载后和用户确认后落盘前均核对应用版本；取消/失败/换版不改旧head。
- 独立音轨按放置片段及偏移移动。删锚点需用户明确改绑/随删/取消，保存失败保候选和源文件，重试同一快照；撤销恢复完整文字、字幕、声音和封面。
- 复用FilePicker13字节流（包括Android content URI与未知长度流），MP3/WAV/M4A≤50MiB；超限、坏数据、空间不足、取消及切账号不接受新输入。复制到私有工程，原路径不作为持久依赖。无90秒限制、无自动ASR或AI/积分调用。
- iOS实际模拟器流程1项通过：真实红/蓝视频与M4A、原生解码/预览、随包中文字层；导入后移动原文件仍可用。真实页面走试听后取消、500ms分割、删除取消、音轨改绑、精确撤销、当前画面封面和实际播放。3张设备截图已查看，均为受控320×180样片，不代表模型成片质量或完整视觉验收。
- Android debug APK构建通过，包名com.lxwx.catdrama；摘要见[产物](android-artifact.json)。当前物理设备正在供其他App使用，本轮未中断它，也未声称Android实际媒体验收。
- flutter analyze无问题，19个Dart文件格式检查0变化。21张图标为Figma rq4owed6原节点各1x/2x/3x导出；4个相关页面节点原始数据已存压缩文件。[资源依据](figma-icons.json)、[Figma选中片段参考](figma-selected-clip.png)。

## 可复查命令

在App仓库运行，Flutter使用本机 `/Users/soul/data/flutter/flutter/bin/flutter`；不重新解析依赖。

```sh
flutter test --no-pub --reporter json test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart test/services/timeline_preview_test.dart
flutter analyze --no-pub
flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/timeline_preview_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
flutter build apk --debug --no-pub
```

驱动环境：`CATDRAMA_MEDIA_EVIDENCE_DIR`指向本目录，`CATDRAMA_TEST_PLATFORM=ios`，`CATDRAMA_EDITOR_PHASE=timeline`；CocoaPods在`/Users/soul/.gem/ruby/2.6.0/bin`。Android SDK路径`/Users/soul/data/android_sdk`，Java使用Android Studio内置JBR。

## 首轮问题与复检

- 原文件选择实现误用旧FilePicker API，改为本机安装的v13静态pickFile和字节流；长度可空单独判断。编译问题保存在`analyze-media.log`/`commands-media.jsonl`等初始记录。
- 新测试中的非const MediaRate和Nullable Store类型问题已修正，未改变业务断言。新增快照测试最初用Store.read读到未保存内存候选，已改为直接读取真实Hive ledger验证磁盘仍是旧head；原“expected1/actual2”判断原因来自测试取值路径，不是放宽落盘要求。
- 首次iOS夹具Get.put被推断为可空泛型，导致页面找不到非空Store；改为显式Get.put<LocalEditorStore>。工具查找前等待响应式重建。初次失败日志/结果单独保留，随后真实同一流程全部通过。
- 最后仅移除集成测试中多余的非空断言以通过analyze，不改变已执行设备流程；该测试源码及全部交付文件摘要见[source.json](source.json)。

## 未完成的验证

[TC-18-01至09](case-results.json)均只记部分验证。两端真机性能、写入中强杀、真实OSS/模型来源、T-27已有工程换版，以及T-32至35文字编辑/主动字幕/导出/相册仍需联验。当前导出、文本/字幕编辑按钮保持未开放；已有字层会参与真实组合预览。没有独立云端剪辑、云端成片同步或导出成功的替代状态。

命令输出仅将VM调试地址的授权段脱敏；其余可能包含工具控制台的尾部空格，作为原始证据保留；Markdown/JSON及本任务代码分别执行空白和结构检查。
