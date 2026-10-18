# T-46 短选段与 Android 真机手势

2026-10-18，App dev `c99483d`，未推送。关闭 **T46-RANGE-01**：Material RangeSlider 默认8逻辑像素间距会按长音轨换算成数秒，真实Widget拖动120秒音轨时，目标不足1秒却被限制为3344.948ms。仅提音弹层设置`minThumbSeparation: 0`，原非空时段校验、媒体协议和布局保持。新增真实指针回归修前失败，修后41专项、1270全套、analyze、格式和Android构建通过。

vivo V1981A/API31，沿真实相册用途说明和系统允许，从本轮唯一自建92秒双音轨视频选择第二轨。电脑实际触摸滑动5次，分别操作起点、终点；测试端只观察真实Widget值，确认握手不传入区间值。原回调精确90500–91500ms回归保留，手势模式没有调用该分支。

| 阶段 | 实际区间 |
|---|---|
| 初次短选段 | 90633–92023ms |
| 试听/暂停 | 79982–91978ms |
| 最终试听/提取 | 90745–91978ms |

音轨实际时长92023ms，视频呈现92000ms，两者分别核对。最终请求1233ms，真实AAC文件1230.658ms、登记/入轨1231ms，符合原60ms门禁，未延长或循环音轨。确认入轨后，通过系统删除本轮精确自建源，再使用独立音轨生成14.004秒混音WAV和14.041667秒MP4，画面clips和工程时长保持。

三份实际文件均完整解码，主频880Hz，与默认第一轨440Hz有约99–107dB差；混音及MP4三秒后RMS=0。长度、SHA和App探测一致。[媒体核对](media-check.json)、[独立核验脚本](verify_media.py)。FFmpeg仅在宿主做QA，App继续Media3方案，没有改原生引擎、后台、API、数据库或依赖。

[11张公开系统图总览](overview.png)、[初次短段](android/gesture-initial.png)、[试听区间](android/gesture-audition.png)、[最终区间](android/gesture-final.png)已检，三张区间原图已看；相册网格仅留私有originals，避免公开其他缩略图。[实际触摸](gestures.json)、[只读确认](gesture-acknowledgements.json)、[最终App报告](android/android-source-audio-result.json)。首次手势的第一份回执还在UI更新中，随后核对新鲜帧确认最终值，保留前后两次观察，未重发手势；后续采样等待新帧和稳定值。

准备失败保留：第一轮HTTP观察器与WidgetTester.pump并发读Widget，被框架拦截；第二轮没有开放测试绑定的设备触摸，滑动被忽略，区间断言失败。两轮均未提取，不计通过。修正为帧内采样和显式物理触摸后，最终1条完整实际方法及严格driver通过；同一相册源、ID和SHA始终保留，没有重复创建源。[观察器记录](observer-failure.json)、[触摸准备记录](attempts/02-pointer-disabled/reason.json)。最早Widget探针只有一次大步移动，未形成有效拖动，另留`short-range-probe`；补逐帧连续移动后才得到3344.948ms业务回归失败，未将探针误当业务缺陷。

账户、源片和初始工程受控；只证明当前手机手势与本机媒体链，未调用真实ASR、未保存成片到相册，不替代iOS真机、其他机型、云端占位、真实空间/中断或最新Figma验收。TC-18-08/10和TC-X30仅追加部分证据，全部186条状态保持10通过/173部分/3未执行，47项仍7完成/38进行中/2外部。相邻clip_tools/video_replacement滑块仍继承默认间距，已登记待单独手势核对，本轮未修改。[同类排查](related-range-review.json)。

系统删除后只核对精确自建源已不可查询，不二次删除。自装且最初不存在的APK按摘要核对后移除，手机返回桌面，原转发和设备锁恢复；原始日志/APK、源片和修改前副本留在忽略的originals。[清理](cleanup.json)、[结果](result.json)。`python3 verify.py`只读核对证据、提交范围、3条用例新增记录和受保护文档；媒体脚本使用工作区既有Python运行时的numpy及宿主ffmpeg/ffprobe。

数据库改动：无。本轮用量未取得，未额外查询。
