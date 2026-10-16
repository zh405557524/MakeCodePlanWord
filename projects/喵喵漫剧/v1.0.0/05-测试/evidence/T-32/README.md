# T-32 文字局部草稿检测

2026-10-15，App dev `7ef8072ba24118d7fe242e509fda74bddb0ef0c3`。文字核心交互已实现；整项保持进行中，更多字体/背景预设、真机及下游导出尚未验收。后台、数据库、依赖及原生平台源码无修改。

## 已实测

- 新增27项，145项相关App自动检测全部通过，0失败/跳过；flutter analyze无问题，17个Dart文件格式检查0变化。
- TextDraft只在页面内存保存试写，正文1–500 Unicode码点，输入超限不截断；毫秒精度时间范围可纠正，不把无效秒值当旧值。跨片使用源锚点，样式编辑保留既有不连续anchors。
- ×丢弃本次试写，✓由稳定commandId/revision一次保存完整工程；原有另一文字和其他轨道保持。真实Hive重开恢复全部文字/样式。明确写入前失败回到旧head且保留输入；已put但flush/回执不明保留同一候选，禁止把不确定保存当作取消，重试不产生新历史。
- 文字输入、可用Noto Sans SC、常规/加粗、描边、字号、颜色、透明度、对齐、出现/结束时间、拖动/缩放、删除均已接。时间轴每条文字独立一行，可选择重叠文字；离开先选保存/放弃/继续，导出守卫拒绝局部稿。实际成片流程仍由T-34/T-35交付。
- 试写只用共享MediaTextRasterizer生成透明PNG，原生底图不重复绘制活跃文字；其余层仍保留。输入预览不反复重建播放器，不进媒体ledger或head；保存后同一字体/布局进入NativeRenderPlan，PNG摘要完全相同。
- iOS真实模拟器流程1项通过：新建取消不留记录、已有取消完整恢复；字体样式/时段预览、明确保存、返回处理草稿、单条删除及完整撤销。最终实际seek=1000ms，已保存的原生字层可见；截图按实际Texture边界取样，有29740个亮文字像素，排除编辑控件区域。[报告](ios-text-editor-result.json)、[像素检查](ios-pixels.json)。三个最终页面图已查看，红色320×180受控样片不代表真实模型质量。
- Android debug APK构建通过，包名com.lxwx.catdrama，产物摘要见[APK记录](android-artifact.json)。已连接Android设备前台为com.lxwx.catseller，本轮未中断它，未将构建当作Android媒体验收。
- 实际读取Figma rq4owed6的6个文字状态；4组图标各1x/2x/3x直接导出。[图标依据](figma-icons.json)、[样式参考图](figma-text-style.png)。

## 命令

在App仓库使用本机Flutter；不更新依赖。

```sh
flutter test --no-pub --reporter json test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart test/services/timeline_preview_test.dart
flutter analyze --no-pub
flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/text_editor_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
flutter build apk --debug --no-pub
```

Flutter `/Users/soul/data/flutter/flutter/bin/flutter`；驱动设`CATDRAMA_MEDIA_EVIDENCE_DIR`为本目录、`CATDRAMA_TEST_PLATFORM=ios`、`CATDRAMA_EDITOR_PHASE=text-editor`。CocoaPods路径`/Users/soul/.gem/ruby/2.6.0/bin`；Android SDK `/Users/soul/data/android_sdk`，Java使用Android Studio内置JBR。像素取样用内置Python/Pillow运行[verify_pixels.py](verify_pixels.py)读取原截图，不改图片。

## 首轮问题与复检

- 首轮新增测试误在已变更revision后重新派生旧草稿，已改为重复提交完全相同的固定命令；补齐受控视频的原声音轨规格，保持实际NativeMediaInfo校验。失败记录见`text-initial.jsonl`。
- 小屏检查发现固定区域过高，已将紧凑面板的选项加入滚动；Widget夹具同时按真实375/320逻辑宽设置ScreenUtil，不用800宽设备中的375像素容器冒充手机。复检5项界面及22项模型/持久化用例通过。
- 第一份设备流程虽通过，但已保存截图在0ms，不能证明500ms后字层可见。已强化用例：等待编辑命令结束，断言真实seek到1000ms，保存Texture矩形并检查原生字层像素。复检通过；`before-seek-check`文件仅供追溯，不能作为最终字层通过证据。
- 模拟器键盘占位实际为0，输入流程可测但没有软键盘展示证明；320×200紧凑Widget覆盖不能替代真实软键盘/输入法验收。

## 尚未闭合

当前真实字体资源只有Noto Sans SC，Figma其余字体未开放；带底色文字预设没有已确认TextStyle背景字段，不能用其他字体或描边伪造。已在任务/风险中保留待补，未修改产品、设计或技术原稿。两端真机、多输入法、写入中强杀和长工程性能，以及T-34/T-35实际MP4/相册、完整切集仍未执行。[TC-19-01至04](case-results.json)均只记部分验证，不折算整项完成。

命令输出仅脱敏VM调试地址授权段；控制台尾部空格作为证据保留。代码、Markdown和结构化JSON分别核对空白与链接。
