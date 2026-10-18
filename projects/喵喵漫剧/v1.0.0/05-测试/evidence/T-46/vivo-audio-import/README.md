# T-46 Android12真机相册提音

2026-10-18，vivo V1981A / API31 / `e2b8595a`。最终完整App方法、严格driver及采集宿主均退出0；[原始报告](android/android-source-audio-result.json)、[实际结果](outcome.json)。App dev `df72c7b`，未推送或部署。

本轮只扩展既有`source_audio_import_test.dart`、共用严格driver和App说明。生产Dart、原生引擎、权限策略、后端/API/数据库/依赖均未改。40项既有提音相关测试、analyze、两文件格式和Android集成构建通过；1269全套沿上一轮`f399154`有效基线，本轮未重跑。

## 实际路径与结果

从真实未决定的存储读取状态，点击现有音频→从相册导入→用途说明“继续”，电脑按新鲜原生XML点击系统“允许”。没有预授权或覆盖公共权限通道。使用本轮唯一名称和实际相册ID`25251`，核对自建92秒蓝色视频的SHA，复用原插件网格选中；主机不枚举私人相册。[源记录](seed.json)、[系统动作](android/os-actions.json)。

真实Media3读取两音轨和各256点波形；选择第二轨，区间90500–91500ms。取消尚未启动的试听、播放/暂停11秒选段，再确认原1秒选段提取并保存独立音轨。原画面clips和14.004秒时间轴不变，声音修订只加一次；源视频未导入画面或上传。

App调用系统删除精确自建源，电脑在“删除这1个视频”弹框中允许一次。随后独立M4A仍可生成真实字幕输入WAV和本机MP4；[源确实消失](source-removal.json)，没有主机补删或清空相册。这个夹具不调用后台ASR、不保存输出到相册，不是完整制作服务器或真实语音识别验收。精确区间使用RangeSlider原回调，不当作真机拖拽证明。

## 独立媒体核验

[三份实际媒体](media-check.json)均经电脑FFmpeg完整解码（只用于QA，未加入App）：

| 文件 | 实际时长 | 声音核验 |
|---|---|---|
| [独立M4A](android/android-selected-track.m4a) | 0.998458秒 | 主频880Hz，非默认440Hz，差109.55dB |
| [实际混音WAV](android/android-actual-mix-for-asr.wav) | 14.004秒 | 主频880Hz，2秒后PCM16 RMS=0 |
| [实际成片MP4](android/android-timeline-with-imported-audio.mp4) | 14.041667秒 | 主频880Hz，2秒后PCM16 RMS=0 |

已登记时长分别999/14004/14042ms，与独立文件探测差均不超过1ms。[时长一致性](timing-consistency.json)同时核对原请求1000ms、实际登记999ms、应用999ms。视频末帧按实际帧率封装，工程时长没有延长；音轨不循环。

## 两次App失败与准备问题

1. [第一次](attempts/01-observer-delay/attempt-result.json)：选源/授权/波形成功，但宿主每轮都调用uiautomator等待空闲，试听截图已经到10.960/11.000秒，回到测试时自然结束。保留原退出1；仅移除普通动画阶段多余的系统树读取，播放/暂停断言不变。
2. [第二次](attempts/02-actual-duration/attempt-result.json)：试听/暂停及实际入轨已完成，旧测试固定要求1000ms，真机文件实际998.458ms、应用999ms。现有`LocalAudioImportService._accept`要求实际文件与请求误差≤60ms，`EditorController.newAudioTrack`取选段和实际时长的较小值。测试及driver改为同时核对这些既有条件和原90500–91500ms，未修改媒体、延长音轨或放宽生产门禁。[失败文件独立探测](attempts/02-actual-duration/actual-audio-duration.json)。

之后保留相同自建源和设备锁，逐次核对并移除自装测试包，从未决定权限重新完整复跑，最终通过；没有在未知的音频任务上重复提取/提交。

准备时媒体CLI没有得到脚本预期的插入回执；随后只按本轮唯一名称核实原条目。CLI读取退出0仍返回ENOENT，空文件假设检查拒绝继续；过早恢复也被缺少已验证seed的门禁拒绝。核实原条目后写入同一个自建源一次并回读SHA，没有重复插入或更换源。[准备核对](seed-reconciliation.json)、[恢复](prepared-resume.json)。这些不是App业务方法，不计通过。

## 画面与清理

[8张公开系统图总览](overview.png)包含6张App状态、实际授权及单源删除弹框；详看区间、试听、入轨、授权、删除5张原图，[查看范围](visual-review.json)。7次状态截图握手中另1张相册网格仅留在忽略的originals，避免公开手机其他缩略图。未对最新Figma验收，自建红/蓝样片不代表模型画质。

[清理结果](phone-cleanup.json)：App已实际删除唯一自建源，主机没有再次删除；只卸载初始不存在且APK摘要匹配的测试包，读取权限随之移除，手机回到桌面。原两条转发保留，新增转发和设备锁释放；仅停止有既有祖先身份证据的本轮读取进程，不触碰其他任务进程或用户相册。

## 复现和边界

`run_vivo.py`需要同型已授权测试手机、初始目标App不存在/桌面前台及设备锁，生成双音轨样片并只查询其精确唯一名称；单次安装，通过官方`--use-existing-app`附着，逐图核对PID。`--resume-prepared`仅沿同一锁和已核实的同一源继续，不能重新创建设备数据。实际参数见[构建](build.json)、[驱动](native-command.json)，完整记录与原摘要见[日志索引](raw-log-digests.json)。原会话、APK、原日志和私有选择器图不进Git。

`verify-media.py`独立检查当前实际文件的频率、解码与静音尾段；沿[已有核验器](media-verifier-source.json)，只改平台/证据说明。`verify.py`是只读证据、源码和范围复核，不操作手机、数据库或Git状态。

只给TC-18-08/09/10、TC-X30追加部分证据，正式186条正文与状态保持9通过/172部分/5未执行。T-46仍未完成，47项7完成/38进行中/2待外部保持。云端占位、真实ASR/空间/系统中断、iOS真机和更多Android机型、实际拖拽及最新Figma继续待验。产品/设计/技术/当前产品和上线基线保持。

数据库改动：无。

本轮用量未取得，未额外查询。
