# T-27 视频历史、有效引用与本机换版复检

2026-10-16；当前仍为开发阶段，T-27保持进行中。App dev `79605b5ac5554dd0f22c52a4d6f715e14f051c66`，本地提交未推送。没有新增API、数据结构、依赖、路由、存储体系或原生媒体引擎；后台本轮未修改、未重跑，旧68项后台证据保留。

历史刷新先校验完整页及稳定总数，失败保旧清单和页码；更多/重试保手选。过期候选不可播放或应用，有效作品明确当前引用的旧成功视频仍可播放；历史applied标记或缓存不能扩大候选期限。预览及确认绑定原账号/环境和作品期限，失效后保留关闭；弹层Widget释放时清理播放器、计时器和订阅。重分析/移出镜头预览复用相同守卫。

镜头应用继续只改源指针。已有本机Clip保持固定版本，明确换版后按用户所选片段及合法区间一次保存，可单步撤销。本轮复跑原真实媒体用例，没有重写剪辑引擎或改成云端剪辑。

## 检测结果

| 层次 | 实际结果 | 边界 |
|---|---|---|
| 修复前 | 原9条新回归均行为失败 | [before-fix.log.gz](before-fix.log.gz)，编译错误另存attempts，不算行为复现 |
| 新增历史回归 | 18通过 | 原9复现＋当前引用、到期、选择/取消、同token换账号、弹层销毁 |
| 相关检测 | 128通过 | 镜头、历史、免费应用、换版及分析差异 |
| 全套App | 1144通过，181个隐藏生命周期事件不计，0失败/跳过 | 最后原始终态success=true；不等于186条业务验收 |
| 静态/格式 | analyze无问题，17个Dart文件0格式变化 | 源码冻结摘要见source-freeze.json |
| Android / iOS历史 | 各3条实际路由/回环HTTP/公共KV/原文件播放通过 | 有效引用；分页重试和原幂等键恢复；切号关闭 |
| Android / iOS本机媒体 | 各1条原文件换版、非法裁剪保护、撤销和重新导出通过 | 实际Hive/TimelineCommands/原生引擎及成片页；片段选择对话框另有Widget证据 |
| 实际MP4 | Android 12.038095秒、627281字节；iOS 12.012秒、384390字节 | 原生/宿主SHA256一致，H264/AAC完整解码；PNG流为内嵌封面，不是多出的视频片段 |
| 路径检查 | 脚本5项隔离自检通过 | guard的恢复提交为bf956b4c，本轮复跑并用于每份进度文档 |

[result.json](result.json)、[verification.json](verification.json)、[逐用例边界](case-results.json)。`verify.py`复核日志终态、原方法保留、媒体摘要、截图、17份源码及186条用例定义/状态未变。全套命令为`flutter test --no-pub --concurrency=4 --machine`；相关命令覆盖test/shots、三个video_replace测试和analysis_diff_test。原生目标为integration_test/video_history_test.dart、video_replace_test.dart，驱动分别核实video-history、video-replace-media报告，缺任一组报告或成片摘要不符即失败。

## 图片与文件

20张原生图（18张OS截图＋2张实际成片页采集）和8张Widget图已检查总览；10张关键图详看，记录见[visual-review.json](visual-review.json)。最新Figma通道rq4owed6未连接，沿保存的5:10225/5:9112/5:11179参考；不宣称精确视觉验收。未修改原型、产品配图或设计基线。

[Android总览](qa-android-overview.jpg)、[iOS总览](qa-ios-overview.jpg)、[Widget总览](qa-widget-overview.jpg)。[Android实际成片](android-media/android-replaced.mp4)、[iOS实际成片](ios-media/ios-replaced.mp4)。两端ffprobe.json/decode-ok.json记录独立检查。自建红/绿画面与合成音只用来验证文件/播放/换版，不代表漫剧画质、台词完整性或真实ASR效果。相册保存不属于本轮原生用例。

<a id="t42"></a>
## T-42 旧测试等待修正

三个独立提交仅改测试，保留原方法与断言：`469691e`等镜头结果实际进入写盘屏障才释放故障；`a48b10a`等成长卡原领取完成并增加120ms慢写盘；`8eda414`等实际剧本导航并增加120ms慢写盘。专属1/15/37项通过，最终并入1144全套。之前全套的成长固定60ms、制作页固定20ms失败均原样保留。公共生产逻辑、账务及3项旧后台夹具未变。

## 留存与未验收项

attempts保留一次可空token参数导致的测试编译错误、静态提示、原生夹具Map泛型、滚动等待、截图采集计数及沙盒文件拉取失败。原生初轮setup失败曾被SDK打印字符串“All tests passed”，严格驱动已拒绝；未计通过。沙盒取回43字节错误文本也未作为MP4，随后改为测试结束前交付真实文件，驱动核实原生大小和SHA256。原始日志/快照按无损gzip提交并在raw-log-index.json列摘要，未删本机原始文件；verify.py可直接读取对应.gz，无需覆盖或还原旧文件。

真实Provider/私有OSS及账务、最新Figma、物理设备和完整业务链路仍待；正式186条保持9通过/172部分/5未执行，47项状态保持7完成/38进行中/2外部待验。不变更产品/技术/上线基线，不推进测试阶段。只更新进度、结果、风险和执行证据；未处理工作台其他脏改动。
