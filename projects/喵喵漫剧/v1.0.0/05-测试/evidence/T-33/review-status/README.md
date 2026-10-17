# T-33 校对提示与预览取证复检

2026-10-17，App dev `bfd460d`，未推送。本批修复/检测完成，整体继续开发；47任务仍7完成/38进行中/2待外部验证，186正式用例仍9通过/172部分/5未执行。

## 结论

**T43-SUBTITLE-01已修复。** 原提示只看识别任务的`CANDIDATE`状态，人工校对后该任务仍保留原结果，因此持续显示去校对。现在复用原应用命令核对结果已经保存，并读取当前字幕的`reviewed`：全部校对且保存后显示“字幕已校对”；部分校对、撤销、声音变化重新提示核对；清空后不再提示。候选未应用或工程写盘失败不报已校对，补存后才刷新。不改变原任务状态、编号、请求、存储格式或后台。

**T43-PREVIEW-01的上轮判断更正为截图裁剪误判。** 校对入口滚动了整个编辑区，截图中可见的红/蓝画面只是完整画布的一部分。本批记录实际Texture矩形、滚动位置和裁剪边界，再将完整画布的系统像素与750ms实际编码帧比较，双端位置一致；没有修改原生渲染或布局。旧证据和当时的待定位记录保留，由本轮结论覆盖。

| 平台 | 滚动前画布top / 裁剪top（逻辑像素） | 当时可见比例 | 完整画布与编码帧最大字幕边界误差 |
|---|---|---|---|
| iOS | -36.629 / 124.424 | 33.41% | 1.25%画布宽/高 |
| Android | -7.912 / 123.010 | 48.05% | 1.25%画布宽/高 |

比较容差预设为2.5%以容纳系统采样/缩放和H.264压缩，不宣称逐像素相同。滚回完整画布后矩形尺寸未变，字幕仍使用原计划x=112、y=134、96×22像素层。问题来自对可见区域的错误归一化；本例不替代其他画幅、更多字体或最新Figma验收。

![系统完整画布与750ms编码帧](frame-comparison.png)

## 实际验证

- 修复前最终复现：8新增场景中4失败/4对照通过，连原17项共21通过/4失败；[原失败](unit-before-fix.log)。最初两轮存在夹具期望和本地函数声明顺序错误，原始日志只留`originals/`，不计业务证据。
- 修复后9新增、43字幕专项、1205全套Flutter自动检测及全工程analyze通过；[专项](subtitle-unit.log)、[全套逐项](flutter-full-result.json)、[analyze](analyze.log)。包含撤销/重做、部分校对、声音变化、清空、候选尚未应用、写盘失败补存、NO_SPEECH/FAILED/STALE优先级。
- 两端构建、严格driver各1条完整原生方法通过；Flutter另计tearDownAll，不算另一业务方法。实际页面断言提示从待校对变为已校对，原识别提交1次/上传1次，未因提示刷新新增请求。混音、校对、离线原生烧录沿原生产服务，ASR/上传为显式协议夹具。
- 两份实际WAV/MP4摘要、16000 Hz/单声道/16位/4秒WAV、H.264/AAC/320×180约4秒成片及完整解码通过。[独立媒体结果](media-result.json)、[验证脚本](verify_media.py)。色块和合成音不是模型画面/真实对白，不证明ASR准确率。
- 12张系统图总览已查看，详看iOS滚动前、Android完整画布；双端完整画布和实际编码帧对比图已查看。最新Figma通道未连接，仅复用已存设计依据，无新设计稿或样式取舍。

![双端六状态](system-screens-overview.png)

| 状态 | iOS | Android |
|---|---|---|
| 主动确认 | [图](ios/ios-os-subtitle-confirm.png) | [图](android/android-os-subtitle-confirm.png) |
| 原任务等待 | [图](ios/ios-os-subtitle-waiting.png) | [图](android/android-os-subtitle-waiting.png) |
| 校对 | [图](ios/ios-os-subtitle-correction.png) | [图](android/android-os-subtitle-correction.png) |
| 滚动后裁剪状态 | [图](ios/ios-os-subtitle-before-preview-scroll.png) | [图](android/android-os-subtitle-before-preview-scroll.png) |
| 完整画布与已校对提示 | [图](ios/ios-os-subtitle-saved-preview.png) | [图](android/android-os-subtitle-saved-preview.png) |
| 本机编码后 | [图](ios/ios-os-subtitle-exported-timeline.png) | [图](android/android-os-subtitle-exported-timeline.png) |

## 范围与复跑

生产改动仅`local_subtitles.dart`、编辑页`subtitles.dart`和统一文案；App另外更新原单测、原集成方法、严格driver及两份项目说明。原生引擎、依赖、契约、产品/设计/技术稿、数据库和后台没有改动；后台本轮未重跑。真实ASR/OSS、物理设备、完整制作与相册链路及最新Figma仍分别待验，T-33/T-43整项不勾选。

原型/设计依据保持原范围。TC-20-01/02/04和TC-X06只增加本例覆盖，186条正式正文逐字保持，不将此切片当作整个用例通过。旧T-43联测证据没有改动。

复跑App：`flutter test test/editor/subtitle_test.dart test/editor/subtitle_task_recovery_test.dart`、`flutter analyze`、`flutter test`。原生入口为`integration_test/local_subtitle_flow_test.dart`，构建时显式指定每端独立`CATDRAMA_CAPTURE_PORT`；driver环境选择`CATDRAMA_TEST_SLICE=subtitle-flow`、平台和独立证据目录，使用`--keep-app-running`。系统截图握手沿`test_driver/capture_native.py`、预期6张；Android安装启动后核对本轮自有forward仍存在，不能因ACK缺失放宽断言。

媒体脚本使用本机FFmpeg/FFprobe和带Pillow/NumPy的工作区Python，不在手机使用FFmpeg。可用运行时：`/Users/soul/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 verify_media.py`。只读范围/摘要复检使用`python3 verify.py`。

两个自有QA模拟器已停止，本App相册权限仍为空记录，未写相册、未删相册文件或卸载App，两个采集端口已关闭。[清理](cleanup.json)。原始日志、早期探针和本机原文件保存在Git忽略的`originals/`；发布日志已脱敏并保留摘要来源。[结果](result.json)、[终端状态](terminal-results.json)、[摘要](manifest.json)、[复检](verification.json)。
