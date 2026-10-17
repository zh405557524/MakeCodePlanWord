# T-35 · iOS真实相册拒绝、设置授权与原文件重存

2026-10-17，开发阶段。App `dev`提交`86dd1ea2ff3bda733d1c64d3c212887035396d32`，未推送。**本切片通过，T-35整项仍未完成**。仅扩展既有测试、驱动和进度说明；生产Dart、原生引擎、API、数据库、依赖及图片未改。

## 实际验证

使用电脑端Appium/XCUITest操作自有iPhone 15 Pro Max模拟器（iOS26.4，`E33B4820-6860-419F-8B17-B6A8FA94EA77`）。使用自建本机媒体、真实Hive、真实原生导出与生产保存页面；不接真实Provider/OSS。权限模式禁用原失败注入及Access调试钩子，WidgetTester不代点保存/权限/设置按钮。

1. 导出2秒成片，未点击时无相册调用。电脑点击保存、用途说明后，实际iOS对话框选择“不允许”。相册状态为FAILED，原任务及MP4保留，MediaLibrary调用和系统写入均0。
2. 电脑点击重新保存/去设置。冷启动落设置首页，实际经“App→搜索喵喵漫剧→照片”进入目标设置，选择“仅添加照片”。这是实际系统UI操作，未通过simctl授予成功权限。iOS随TCC变化终止旧App进程，旧驱动退出1，不计通过。
3. 以`restoreOnly`重新启动，核对原marker、Hive、任务和原文件；无自动编码、无自动相册保存。电脑点击“重新保存”，真实系统写入1次才显示“已保存到相册”。exportId、nativeOperationId、inputHash、MP4摘要及编码attempt1保持；首次导出事实仍1次，照片读取权限仍拒绝。
4. 电脑点击返回，测试核对夹具作品路由后清理应用闲置临时片。独立读取模拟器系统相册副本，确认原28份视频未变，只新增`100APPLE/IMG_0052.MP4`；原片/副本SHA-256相同，完整解码、H264/AAC、320×180、24fps、2秒和内嵌封面一致。临时成片已移除，源视频仍受保护，相册副本仍在。
5. 再独立回归默认模式：首调用注入明确失败，第二次真实系统保存同一MP4；编码任务1、调用2、实际写入1。新增`IMG_0053.MP4`独立完整解码和摘要核对通过，前29份视频不变。此模式不算第二次真实OS拒绝。

[结论](result.json)、[真实UI核对](ui-flow-verification.json)、[拒绝回执](permission-denied.json)、[系统终止与文件保留](permission-transition.json)、[实际恢复报告](ios/ios-album-permission-result.json)、[系统副本](gallery-verification.json)、[原模式回归](classic-verification.json)。原生报告中的`host_pending`是设备生成时的阶段字段，宿主独立结论以本目录两份verification为准。

## 检测结果和证据层次

| 范围 | 本轮结果 | 证据 |
|---|---|---|
| 既有App单元/Widget专项 | 64方法，0失败/跳过；前后各跑一次，不累加 | [最终原始JSONL](focused-final.jsonl) |
| analyze /格式 | 0问题；2文件0变化 | [analyze](analyze-final.log)、[format](format.log) |
| iOS真实权限恢复 | 1方法通过，设备报告及宿主严格断言 | [驱动日志](ios-drive.log)、[原文件](ios/ios-album-original.mp4) |
| 默认失败注入模式 | 1实际回归方法通过，1次真实Photos写入 | [日志](ios-classic-drive.log)、[报告](classic/ios-album-classic-result.json) |
| 媒体独立验证 | 两种模式系统文件同原片摘要、完整解码 | [相册原模式后快照](gallery-after-classic.json)、[宿主脚本](verify_gallery.py) |
| 真实UI观察 | 24张Appium系统图、3张SDK支持图已查看；过渡图不作视觉基准 | [图清单](visual-review.json)、[实际操作JSONL](ui-actions.jsonl) |
| 正式用例 | 只补TC-21-03/08、TC-25-02、TC-X29的部分证明，不新增完整通过数 | [逐条范围](case-results.json) |
| 路径/文档/改动范围 | 5目标guard+audit、12保护文档及186正文检查 | [guard](guard-check.log)、[最终复核](verification.json) |

全App1196方法为前轮基线，本轮未重跑；本轮没有新单元方法，64项为已有专项。Android本轮未启动。47任务保持7完成/38进行中/2待外部；186条保持9通过/172部分/5未执行，不能用方法数折算业务验收。

主要实际截图：

- [系统“不允许”](ui/P05.png) / [拒绝后本机文件保留](ui/P07b.png)。
- [目标App照片设置](ui/P17.png) / [仅添加照片已选中](ui/P19.png)。
- [重进后未自动保存](ui/P20.png) / [点击后实际保存成功](ui/P21b.png)。
- [原模式失败态](classic/ios-album-classic-album-injected-save-failed.png) / [原模式成功态](classic/ios-album-classic-album-system-saved.png)。

Flutter此夹具的外部AX树仅根节点；Flutter按钮依据刚查看的系统截图和当时窗口坐标点击，`ui_step.py`核对截图时间、视口和当前任务/状态。系统弹窗及Settings使用重新核对的唯一AX节点。原始XML、截图、节点、时刻和SHA保留在`ui/`，无代码按坐标自动遍历用户相册。

## 复现方式

App目录`/Users/soul/code/lxwx/catdrama`，保留锁定依赖，全程`--no-pub`。默认模式与权限模式分别构建，禁止验证中修改可执行源码。[源码冻结](source-freeze.json)记录两份已检测Dart文件；[终态](terminal-results.json)记录实际退出码。

```sh
flutter analyze --no-pub
dart format --output=none --set-exit-if-changed integration_test/save_video_test.dart test_driver/catdrama_business_driver.dart
flutter test --no-pub --reporter=json test/editor/local_export_test.dart test/editor/local_export_widget_test.dart test/editor/local_export_album_test.dart test/editor/local_export_album_widget_test.dart
flutter build ios --simulator --debug --no-pub --target=integration_test/save_video_test.dart --dart-define=CATDRAMA_ALBUM_PERMISSION_FLOW=true --dart-define=CATDRAMA_CAPTURE_PORT=19173
```

以`CATDRAMA_TEST_SLICE=album-permission`、`CATDRAMA_TEST_PLATFORM=ios`和指定证据输出目录启动既有`test_driver/catdrama_business_driver.dart`的`flutter drive --no-pub --no-build --keep-app-running`，目标与dart-define同上。电脑启动自有Appium会话后，先采集/查看截图，再执行上述真实UI步骤；HTTP19173仅只读观察状态，不控制权限或业务。若OS因权限变化终止App，继续同一沙盒的恢复模式，不重新创建夹具或导出。实际输出目录变量名见该driver的环境读取，避免使用正式账号/远端服务。

默认回归用`CATDRAMA_ALBUM_PERMISSION_FLOW=false`构建同一测试，slice为`album-classic`，与权限模式输出分开。系统相册媒体通过宿主FFmpeg/ffprobe**只作独立QA解码**，生产App仍为Media3/AVFoundation，没有接入FFmpeg。

## 未通过尝试、清理和待验

- [初次设备指针未开放](attempts/pointer-disabled/)：控机点击未进入Flutter，退出1。之后仅修正测试binding；旧证据保留，不计通过。
- [权限变更前驱动](ios-denial-settings-drive.log)：真实系统变更终止App造成退出1，是恢复前置，不能当成功方法；[恢复驱动](ios-drive.log)终态0。
- [宿主解析修正](attempts/host-verifier/)：FFmpeg时间字符串及多段fixture字串解析的初次检查失败保留，修正后独立检查通过，不记App缺陷。
- [phone-ui目录检查](phone-catalog-check.log)退出1，提示需刷新；本轮保留目录与其他未跟踪内容，仅复用已有driver工具，未执行完整正式phone_test.py流程。
- 夹具源版本核对日志中HttpService未注册/离线提示保留，不能证明真实后端、模型或OSS已联验。默认回归重新安装测试App，其系统副本验证为另一个本机夹具切片，不作跨重装恢复保证。
- [清理](cleanup.json)：关闭本次Appium会话及自有4725服务，恢复仅目标App照片读/添加权限至原先空记录，停止仅自有模拟器；不删系统视频、不删模拟器定义、不碰其他App权限。备份、WDA缓存及初始状态文件按`.gitignore`不提交。
- [观察清单](observations.json)：设置冷启动落首页，直达目标设置待真机核对；App列表音乐图标按既有设计另核对。尚未在本轮修改品牌图或公共设置插件。
- 物理设备、最新Figma、小屏/字体矩阵、真实空间故障、完整生产作品入口、Android权限恢复矩阵及真实Provider/OSS继续未完成。返回作品为夹具路由，不能当全App业务验收。

此目录不替代正式186条业务验收，也不推进阶段。[交付文件摘要](delivery-manifest.json)用于核对证据/进度/已提交App文件；不包含它自身及Git提交后结果，避免自引用。
