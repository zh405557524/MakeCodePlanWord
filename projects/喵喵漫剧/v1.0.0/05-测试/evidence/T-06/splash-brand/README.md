# T-06 系统启动图与背景修复

2026-10-18。App dev `3b2d3a9`，已提交未推送。T06-SPLASH-02在当前Android/iOS模拟器范围关闭；T-06父任务仍未完成。

## 问题、实现与范围

桌面图标此前已修，但系统启动图仍使用复制自写歌的蓝色音符。Android旧系统路径与iOS的1×1启动背景仍是(13,11,20)，与当前#010101主题不同。本轮使用实时Figma通道2puw6spn的5:1055标识，导出3x像素与现有360×276品牌源图逐通道完全一致，[来源核对](figma-source-check.json)。

新增可重跑脚本`tool/generate_splash_images.dart`，复用已有image 4.8.0，不增加依赖。更新21张PNG：Android五密度旧版标识、Android12五密度明暗画布、iOS三倍率标识，以及两端3张背景。保留系统原有居中方式，Android12透明画布288dp、标识120×92dp；iOS同步启动Storyboard的尺寸及背景。源页面图与桌面图标均未改。

Android12画布直接复制RGBA，避免半透明边缘被重复混合。三倍原生标识与Figma源逐像素一致，21图尺寸/透明度/安全圆和三张背景色已检查；明暗各密度字节一致。[资源检查](asset-check.json)。

## 实际截图与检测

![修复前与两端实际冷启动](startup-comparison.png)

| 实际场景 | 采集图片 | 标识轮廓IoU / 平均RGB误差 |
|---|---|---|
| Android API37，浅色系统 | [系统图](android-complete-light.png) | 0.98451 / 2.152 |
| Android API37，深色系统 | [系统图](android-complete-dark.png) | 0.98451 / 2.152 |
| iOS26.5，iPhone 17 Pro模拟器 | [系统图](ios-complete.png) | 0.99993 / 0.1661 |

最后一轮实际采集24/23/45帧，启动画面已显示绿色漫剧标识，原蓝色标识未检出。[帧与测量](startup-measurements.json)、[实际Figma标识](figma-brand-3x.png)。轮廓与色差只比较标识组件；系统栏为动态内容，没有单独启动页Figma稿，不把该结果扩展为整页/全部页面像素验收。原图未修改或拉伸，组合图只用于展示。

6项既有启动/资源方法、全工程analyze、生成脚本格式、Android/iOS普通入口构建通过；没有增加业务用例或重跑全套1273项。[6项实际方法](startup-tests.json)、[命令与退出码](checks.json)。安装由电脑自动完成，Android实际安装APK SHA与构建一致，iOS实际Assets.car与构建一致：[Android](android-artifact.json)、[iOS](ios-artifact.json)。没有使用手机、真实渠道或后台测试。

首次图像检查发现透明边缘混合问题，已改直接RGBA复制；iOS首轮色差检查发现残留紫黑背景，已修3份背景并重建。原失败图和数据保留，最终使用complete轮。一次冷启动层级尚未就绪，未重复操作，capture确认首页后reconcile；一次宿主SHA辅助函数不兼容，改只读分块校验，没有因此重装。它们不计入业务测试通过。

正式TC-01-01控机run保持blocked/original_case_status=not_assessed：本轮只核对启动画面，未完整执行匿名导航/真实案例链路。21图及脚本不改变业务、后端、接口、数据结构或积分；47项7完成/38进行中/2外部，186条10通过/173部分/3未执行保持。

## 复跑与保护

在App根运行`dart run tool/generate_splash_images.dart`，随后按checks.json执行格式、analyze、6项相关测试和平台构建。素材复用当前360×276原切图，不重新设计标识。

Android恢复原浅色模式，保留专用模拟器用于后续UI复检；本轮启动的iOS模拟器已恢复关闭，控机锁已释放。未卸载、清App数据、操作用户手机或更改其他App/相册。[清理](cleanup.json)。

Android≤30实际运行、真机/更多机型和完整首页/案例仍待T-06后续验收，不扩大旧ICON-01结论。[源文件冻结](source-freeze.json)记录23个实际修改文件。原始逐帧图、日志、APK和逐文件备份在Git忽略的originals/；产品/设计/技术与上线基线不变。
