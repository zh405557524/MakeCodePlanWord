# T-33 主动字幕与本机校对

2026-10-15，App dev `15234119a1bf4f35299b2e5ce26b0ec0653ddde4`。功能切片已提交；真实ASR/OSS、Android实际媒体及两端真机仍未验收，整项保持进行中。后台、数据库、依赖和上线基线没有改动。

## 已检结果

- 新增30项App、1项插件。最终199项相关App、13项插件通过，0失败/跳过；analyze无问题，29个Dart文件格式检查0变化。机器方法以suite所属文件归属，避免Widget用例被误归到flutter_test。
- 只有用户主动确认才创建原动作；同一编辑器的原动作/请求/幂等键、上传完成参数及候选写同一个Hive ledger。上传沿UploadService/ResourceAPI，状态查询沿DramaJobService，不保存签名URL，不上传工程或成片。
- 网络未知、RUNNING及丢回执只恢复原请求。包含终态精确查原键，主库明确无记录才补送原键原body；明确FAILED且手动操作才带retryOfJobId创建新键。能力-560013是在受理事务前拒绝，可结束等待继续本机编辑；重进不自动POST，手动恢复仍用原请求，不伪装FAILED。
- 候选先保存再原子应用。成功后Hive保存失败只重取/重存原结果或同一完整工程，旧字幕在NO_SPEECH、失败和STALE时保留。音轨/字幕revision、编辑器及账号不匹配时不覆盖；跨切点映射稳定源锚点。
- 校对面板可修改文字和毫秒时段；取消不写工程，重新获取前确认且取消保局部输入。未改时段保原不连续锚点。校对及统一PNG排版、原生预览/烧录留在手机。
- 活动任务WAV跨重开仍受缓存保护；抽音容量不足提示清理闲置文件，释放预留后按原逻辑键恢复。私有PUT/完成回执未知先确认原对象，不重复PUT。
- iOS真实模拟器流程1项、4张原始截图通过。真实两镜头裁剪/音量/静音及独立音轨混音生成4秒WAV：16000Hz、单声道、16位、128044字节。静音窗RMS=0，导入轨道和后续镜头非零。预览实际750ms可见校对字层；只采可见红源区域，排除标题栏/编辑控件，有6884个亮文字像素。
- 离线原生MP4独立解码：4秒H264/AAC、320×180。0.25秒无字，0.75秒校对字层199亮像素，2.5秒跨切点字层172亮像素。此处验证统一render snapshot，不把直接调用原生编码当T-34/T-35导出/保存页面验收。
- Android debug APK已构建，包名com.lxwx.catdrama，原生PCM转换与旧M4A入口均编译通过。当前Android设备被其他工作使用，没有中断其前台，没有把构建当Android实际媒体验收。
- Figma通道rq4owed6，页面5:11388/11499/11718/11822；5:11276字幕图标原样导出1x/2x/3x。按已批准业务替换演示的“收起等待/根据镜头原文造字幕”。校对文字来自协议夹具，不声称是实际语音识别结果。

## 实际文件与支持落点

[源码清单及摘要](source.json)包含36个任务文件。请求模型使用工程既有models/params，响应与本机对象分开；没有平行models/requests目录。除计划中的字幕Service/API/模型/面板/Controller/命令/测试外，聚合入口、Global生命周期、UploadService、同库缓存保护、工具栏/时间轴、统一文案/资源常量及原生PCM输出是必要接入。

原生extractAudio新增可选pcmWav，原AAC/M4A默认保留。iOS直接复用同composition/audioMix输出PCM；Android复用同拓扑AAC混音后流式解码与采样转换，缓冲写WAV，不逐采样执行文件写入。后台接口和已确认参数没有变化。

## 命令

在App仓库使用本机Flutter，不更新依赖：

```sh
flutter test --no-pub --reporter json test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart test/services/timeline_preview_test.dart test/services/drama_jobs_test.dart test/assets/upload_test.dart test/app_bootstrap_test.dart
flutter analyze --no-pub
dart format --output=none --set-exit-if-changed <source.json中的29个Dart文件>
flutter drive --no-pub --driver=test_driver/editor_recovery_driver.dart --target=integration_test/local_subtitle_flow_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --keep-app-running
flutter build apk --debug --no-pub
```

插件目录另跑flutter test。iOS驱动使用CATDRAMA_MEDIA_EVIDENCE_DIR指向本目录、CATDRAMA_TEST_PLATFORM=ios、CATDRAMA_EDITOR_PHASE=subtitle；设备为iPhone 15 Pro Max/iOS26.4模拟器。Flutter3.41.6，CocoaPods路径沿既有本机配置；Android使用Studio JBR及已配置SDK。独立媒体检查使用内置Python/Pillow运行[verify_media.py](verify_media.py)，依赖本机ffprobe/ffmpeg；它只读取截图，不编辑截图。

## 首轮问题与复检

- 混音原输出M4A与后台要求PCM WAV不衔接，已补两端可选PCM输出及真实iOS验证。
- 原动作防重清理回调错误返回自身Future，导致等待不结束；已改为void清理，重复点击及恢复用例通过。
- 测试HTTP夹具误使用含域名的path匹配任务路径，已改uri.path；首轮回归命令含不存在的test/editing目录导致加载失败，改为实际Service用例路径。最终199项全通过；[路径错误原记录](initial-path-failure.jsonl)不计通过。
- 等待层Widget夹具的Stack未铺满屏幕，造成小容器溢出，已按真实约束修正；覆盖取消仍保局部校对输入，点击遮罩不会穿透。
- 首轮已保存图在0ms，不能证明时段内字层。强化用例等待真实750ms、记录Texture位置；滚动裁切时仅取实际可见红源，排除标题栏白字。旧图/报告在before-preview-check，仅用于追溯，最终以[媒体检查](media-check.json)及当前报告为准。

## 未完成

真实识别Provider与私有OSS、真实对白/旁白/环境样本准确率、Android实际WAV/音视频执行、双端真机软键盘/性能、OS进程终止恢复仍待验证。T-34/T-35完整导出与相册交互、T-46相册提音继续按原任务推进。没有把受控ASR/上传当真实渠道，不新增产品取舍，不改变上线基线。

[机器结果](result.json)、[App方法](flutter-summary.json)、[插件方法](plugin-summary.json)、[iOS报告](ios-subtitle-result.json)、[媒体检查](media-check.json)、[APK记录](android-artifact.json)、[Figma来源](figma-source.json)。
