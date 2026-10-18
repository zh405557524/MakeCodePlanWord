# T-46 iOS有限相册访问补验

最终第3轮通过。App dev `bcc7dc8432b6de37864b88b88d29ec84f8992d9f`，只改既有集成测试、严格驱动和App说明，未推送。生产Dart/原生引擎、API、数据库、依赖及后台均未改；本轮未启动或重跑后台。

## 检测范围和结果

在自有 iPhone 15 Pro Max / iOS 26.4 模拟器，系统真实点击“限制访问”，只选择自建92秒双音轨视频。实际TCC返回limited（auth_value=3），App可见视频仅1条；通过Asset ID及源文件SHA-256再次核实。复用原插件“继续访问部分资源”，没有改为全量授权。

实际AVFoundation探测两音轨、波形/试听，确认第二音轨90500–91500ms，独立音轨写入原Hive工程；原视频不进入画面片段，clips/时长保持，声音修订只加一次。系统删除仅针对这条SHA核对的自建源，之后仍生成真实PCM16k单声道混音及本机MP4。精确毫秒通过RangeSlider原回调输入，不能据此宣称真实手势验收。

- 40项既有相关单元/Widget测试、analyze、两文件格式、iOS debug集成构建全部通过，见[命令与退出码](checks.json)、[格式](format.json)。1261全套沿T-40有效基线，本轮未重跑。
- 最终完整原生方法1条通过，不把方法数折算成正式用例数。见[实际报告](ios/ios-source-audio-result.json)、[最终命令](native-command.json)、[7次实时截图握手](ios/system-captures.json)及[实际系统动作](ios/os-actions.json)。
- 3份真实M4A/WAV/MP4的大小及摘要经严格驱动核对，并在电脑独立完整解码；三者主频均880Hz，非被弃的440Hz。混音与成片2秒后PCM为静音，无短轨循环。M4A容器1.045秒包含AAC编码尾垫，逻辑导入段1000ms；14.004秒时间轴不延长。见[独立媒体核对](media-check.json)、[复检脚本](verify-media.py)。电脑FFmpeg仅作独立检测，不引入App。
- 15张真实系统PNG（含7张状态图）已总览，5关键原图已查看，见[总览](screens-contact.jpg)、[视觉记录](visual-review.json)。红/绿纯色来自既有自建媒体夹具，非实际模型画质。未与最新Figma比较。

## 两次未接收尝试

[第1轮](attempt-01/outcome.json)实际有限授权和源摘要已成功，但旧测试跳过Wechat有限权限引导，误点遮挡后的确认按钮。修正为先操作“继续访问部分资源”并要求唯一可命中确认按钮。

[第2轮](attempt-02/outcome.json)已完成实际提音、混音和导出，但未恢复Flutter测试指针开关，触发框架收尾不变量；不计为通过。最终在finally恢复原值，重新构建并完整重跑，第3轮严格驱动与宿主退出码均0。两轮原测试源码按当时构建摘要保留；失败日志和图没有覆盖。

## 保护与边界

[69份原媒体文件](ios/gallery-before.json)在[检测后](ios/gallery-after.json)逐份大小/摘要保持。两条本轮自建源因失败重跑分别进入系统“最近删除”，没有永久删除或清空相册。初始无Photos/PhotosAdd授权记录，现已恢复原状态；自有App/Appium/模拟器停止，三个端口释放，USB真机未操作。见[清理](cleanup.json)、[只读清理复核](post-cleanup.json)。初始68文件过滤漏掉HEIC的问题在权限操作前已扩充为69份完整DCIM基线，记录在[环境](device-start.json)，原过滤快照私有留存。

本轮使用本机隔离的测试工程/账号、自建正弦源、真实系统Photos及原生媒体通道。未配置HTTP服务，页面联网核对提示是已知夹具边界；没有AI、ASR、OSS或云端工程请求。`eng/zho`只是音轨元数据，正弦样本不构成语音识别证据。真实ASR/云端占位、旧Android、两端物理设备、真实空间/中断与最新Figma继续待验。

T-46整项保持未完成；47任务7完成/38进行中/2待外部，正式186条9通过/172部分/5未执行保持。四条仅追加部分证据，见[逐条范围](case-results.json)。产品/设计/技术、上线基线及正式用例正文不改。

[只读验证](verify.py)检查公开证据摘要、命令/产物、保护文件、提交范围与统计；[manifest](manifest.json)不含私有originals及自身输出。公开日志压缩并隐藏临时本机VM服务路径，原日志和会话私有保留，见[日志索引](public-logs.json)。
