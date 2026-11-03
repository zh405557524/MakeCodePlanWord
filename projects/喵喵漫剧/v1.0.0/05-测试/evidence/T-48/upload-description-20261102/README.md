# T-48 上传形象－填写描述对稿

日期：2026-11-02（用户时区）。状态：代码已提交 `882d5a5`，静态检查、iOS/Android 开发流程及375×812同视口视觉自检完成，待用户验收；不提高正式测试统计。

## 已实现

相册上传模式独立布局；角色标题“形象描述”，场景/道具保留类型标题；名称框343×56、描述框343×202（375×812设计基准），圆角10、输入提示/计数12；角色提示按稿。底部343×50“确定上传”脱离表单滚动，适配安全区和键盘。描述500字、免费保存并应用、原提交及恢复逻辑保持；创建页帮写限制沿并行提交3e6a0ef，已有资产编辑帮写保留。

Figma：本轮实读 tcbn1478 / 43:2690，原图 `figma-43-2690@2x.png`（750×1624）。代码复用对应返回图标与已比对一致的 primary_action_bg，未新增图片资源或手绘图标。

## 验证

| 检查 | 实际结果 |
|---|---|
| `flutter analyze` | No issues found，33.7秒 |
| `flutter test test/assets/upload_test.dart test/assets/asset_test.dart test/assets/asset_description_test.dart` | 115项通过；包含故障注入日志及既有坏图片夹具解码日志，无失败 |
| 隔离副本 iOS simulator debug / Android debug 构建 | 均通过，见 ios-build.log / android-build.log；副本在App仓库 `.test/upload-description-native` |
| iPhone SE / iOS 26.5 桌面 Appium | 375×667、750×1334截图，23个逐步观察，16项断言通过；实际页面和Controller，HTTP与直传为本机隔离夹具 |
| Android Pixel 9 Pro XL / API 37 | APK 1.0.1+101安装成功，但系统无法解析/启动App及io.appium.settings活动；重启后仍失败。包内launchable-activity与已安装包均有MainActivity。不能记Android页面通过 |
| Android Pixel 5 / API 37 桌面 Appium | 原持有任务释放后经固定池领取；1080×2340截图、逻辑392.73×850.91；14项断言通过，见android/及desktop-checks-android.json |
| iPhone 13 mini / iOS 26.5 / 375×812 | 等待原任务释放后正式领取；原图1124×2436（@3x），仅归一化密度为750×1624（@2x）后与Figma同列检查，见comparison-mini-full.png、comparison-mini-fields.png、comparison-mini-button.png |

## 桌面控机步骤

桌面入口 `desktop_control.py` 复用工作区 phone-ui 的 AppiumDriver。HTTP端点仅准备隔离路由/注入失败和读取状态；输入、点击保存及截图均通过原生Appium完成。每步含PNG、原生节点、XML、状态及steps.jsonl，不以内置Widget交互替代手机操作。

| 观察 | 检查与结果 |
|---|---|
| ios/01-empty | 空表单、无帮写、名称必填、描述可选、底部按钮；原生截图已查看 |
| ios/02-name-keyboard、03-description-keyboard | 桌面输入中文；键盘弹出，按钮从y608.38移至375.38；名称/描述框宽度和高度保持 |
| ios/04-submitting | busy=true，上传prepare=1，提交中截图保留 |
| ios/05-failure-keeps-form | 注入prepare失败；原“林晚”及16字描述、所选图片保留，created=0，可重试 |
| ios/06-retry-submitting、07-success-detail | 重试沿原逻辑；进入真实AssetDetailPage /asset/700；夹具created=1、put=1、complete=1，已应用resource90002 |
| ios/08-long-name、09-long-description-keyboard、10-long-description-restored | 桌面输入500字，框内滚动，500/500可见；重开表单文字保留，描述框仍174.14高（SE适配值） |
| ios/11-scene-empty、12-prop-empty | 类型标题与提示正确；相同上传布局，无帮写 |
| ios/13-ai-creation、14-existing-edit | AI创建保持原布局；已有资产编辑仍显示帮写、成品图与保存资料。仅检查页面，不执行真实模型调用 |
| ios/15-name-over-limit、16-description-over-limit | 超20字名称和501字描述保留输入，valid=false，无新增上传/保存 |
| ios/17～19 | 场景“客厅”不填描述，提交成功进入/asset/701 |
| ios/20～22 | 道具“折扇”不填描述，提交成功进入/asset/702 |

设备均通过固定池领取。Pixel 9 Pro XL启动失败保留原始环境记录；未擦除数据或新建设备。其关闭释放后，复用新释放的Pixel 5完成Android检查。SE已关闭释放；Pixel 5和Mini在收尾时关闭并释放，最终状态见cleanup.json。

## 视觉边界

`comparison-se-adaptation.png` 把Figma原图与SE真实空表单同列比较，未拉伸截图。SE与Figma高度不同，只证明小屏适配观察，不作同视口像素结论。已检查：字体层级、表单顺序和留白、背景/边框/提示色、原图标/按钮资源、业务文案；500字计数与原稿0/20的差异由用户明确确认。原生系统栏、安全区保留。

Mini同视口检查已完成。名称/描述框及按钮实测343×56、343×202、343×50；相对Figma表单整体下移6dp（系统顶部安全区50而非44），按钮上移16dp（保留34dp底部安全区而非稿中18dp）。这两项为已批准的原生安全区适配；字段对照图只对齐该6dp系统差异，没有改变视口或拉伸图像。500字计数为用户明确确认差异。

真实相册、OSS、Java服务、供应商、支付、真机及更新用户手机包未验证。本轮没有真实上传或扣费，不提高正式用例统计。

## 字体复检与Android补测

首轮并排发现标签/输入字重与主按钮偏粗，已将上传页标签和输入改为400、主按钮改为600；ios/23-final-empty.png及comparison-se-fields-final.png为修正后原生证据，Mini同视口三张对照为最终结果。字体调整后范围analyze无问题（final-analyze.log），两端再次构建通过（ios-build-final.log / android-build-final.log）。

Android补测：android/01为空表单；05～06为中文输入与键盘；07～10为提交中/失败保稿/重试详情；11～13为500字描述与系统返回收键盘；14～17为场景/道具/AI创建/已有编辑。最初未聚焦的输入没有写入表单，键盘动画中的严格坐标定位也曾中止，原尝试保留；最终按刚观察到的两个原生EditText定位并聚焦输入，控制器与屏幕文字一致。iOS16项、Android14项，共30项断言通过。

代码仅三个文件独立提交，未推送；源文件摘要见source-sha256.json。其他并行工作保留。详细视觉检查见[design-qa.md](design-qa.md)。
