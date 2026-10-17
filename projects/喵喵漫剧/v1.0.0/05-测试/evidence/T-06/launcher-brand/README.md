# T-06 漫剧平台图标补齐

2026-10-17。App dev `134b011`，未推送/部署。T-06/43-ICON-01（旧别名T06-43-ICON-01）在本轮双端模拟器范围修复；整体仍开发，47任务7完成/38进行中/2待外部，186条9通过/172部分/5未执行保持。

原AppIcon/mipmap仍显示复制自写歌的蓝色音符。本轮复用已保存的Figma 5:1055漫剧绿色猫耳M/播放标识和`CustomTheme.background`的#010101背景，等比放入平台画布，没有重新画logo或修改页面三倍率图片。

| 对比 | 图片 |
|---|---|
| 原写歌图标 | [原文件](before-icon.png) |
| 原Figma漫剧页面标识 | [原切图](source-brand.png) |
| 当前平台图标 | [生成结果](after-icon.png) |
| iOS实际桌面 | [系统图](ios-launcher.png)、[实际可见节点](ios-icon-node.json) |
| Android实际圆形图标 | [应用抽屉](android-launcher.png)、[目标App系统信息](android-app-info.png)、[实际节点](android-icon-node.json) |

## 实现与验证

复用现有开发依赖`image 4.8.0`和`flutter_launcher_icons 0.14.4`。`tool/generate_launcher_icons.dart`先生成1024正方形透明前景和RGB背景图，再按`pubspec.yaml`生成两端平台资源；原横向标识不拉伸、不裁切。`assets/branding`只是平台构建输入，不进Flutter页面资源清单；页面仍沿现有1x/2x/3x原切图。

- 21张iOS PNG和5张Android旧版图标全部替换原音符，iOS资源表仍保留原21个文件/25个槽位；iOS PNG为不带Alpha的RGB，由系统处理外角。
- 新增5密度Android透明前景、API26+自适应XML和原主题背景，16%inset后标识完全在66dp安全圆中。旧API仍有48/72/96/144/192五种图标。
- [独立PNG检查](asset-check.json)核对31张实际平台PNG的尺寸、颜色、不透明度、源图保留和安全半径，26张旧图摘要均变化；[脚本](verify_icons.py)用宿主Pillow读取，不参与App运行。
- 6项既有启动/资源选择测试、全工程analyze、1个Dart生成脚本格式、两个普通入口debug构建通过。没有增加业务测试方法，没有重跑前轮1205全套或后台测试。[终端结果](terminal-results.json)、[测试](flutter-test.log)、[analyze](analyze.log)、[iOS构建](ios-build.log)、[Android构建](android-build.log)。
- 正常入口`lib/main.dart`构建后的两个包标识均为com.lxwx.catdrama；已读取[实际iOS图标目录](ios-assets-car.json)、[实际Bundle信息](ios-bundle.json)、[APK manifest](android-badging.txt)及[产物摘要](build-artifacts.json)。这是模拟器/开发debug产物，不是正式签名发布包，构建没有注入第三方渠道授权参数。
- 两端保留安装数据进行更新安装。实际iOS桌面绿色标识和“喵喵漫剧”节点可见；Android圆形抽屉图标及明确目标包的系统信息页显示同一标识。查看范围见[记录](visual-review.json)，未声称最新Figma/全设备样式验收。
- 上轮矩阵的12个系统相册文件在本轮更新安装后全部重新实读，大小与SHA保持一致。[文件保护](prior-albums-preserved.json)。没有重编码、删除相册、卸载或启动目标App，也没有新增相册权限。

首次QA角落亮度检查假定每个缩小图都精确为(1,1,1)，4个小尺寸经原工具浮点平均后截断为(0,0,0)。读取固定版本`copyResize`实现后，PNG检查允许每通道最多1阶量化误差；不透明度仍严格255，1024标准源背景仍精确(1,1,1)。生产图片/算法没有因该QA断言修改。[自审与诊断](review.json)。

初次主页截图未包含目标图标，Android早期探针只拿到dump回执、一次命令参数被拒绝，均保留为诊断，不当成功证据。最终通过实际层级与系统截图定位；iOS沿原XCUITest会话等待26.6秒启动完成，没有因初始连接拒绝重复创建。自有Appium端口4737、两个自有模拟器已停止，临时UI dump移除，目标Photos权限仍为空。[清理](device-cleanup.json)。

## 复跑及边界

在App工程根运行`dart run tool/generate_launcher_icons.dart`，再运行`flutter analyze`及`flutter test test/app_bootstrap_test.dart test/assets/image_variants_test.dart`。平台验证分别使用`flutter build ios --simulator --debug --no-codesign --no-pub`、`flutter build apk --debug --no-pub`，更新安装自有QA设备后查看真实系统图标，保留原数据与相册。

原品牌切图只有360×276，本轮等比放大装入标准画布，没有取得独立高清Figma AppIcon稿；当前Figma通道rq4owed6仍断开。真实设备及其他系统图标显示风格未验收。后台、运行中的App业务、API、DDL、依赖、产品/设计/技术文档均未改；T-42的3个其他App旧资源测试失败继续保持原记录，不借图标任务修改。

只读归档复检：`python3 verify.py`；独立图片复检用带Pillow的工作区Python执行`verify_icons.py`。原先`creation-matrix/pending-brand`中的历史文件不修改，由本轮[finding](finding.json)覆盖其未修复结论。原始日志、Appium会话及旧文件在忽略的`originals/`；发布日志已脱敏并保留[原摘要](raw-log-provenance.json)。[范围](baseline.json)、[冻结](source-freeze.json)、[复检](verification.json)、[发布摘要](manifest.json)。
