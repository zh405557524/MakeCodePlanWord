# T-43 页面主路径：系统TXT到本机成片

2026-10-17。App dev `c4de00f`，后台 dev `20b03409`，均未推送。保持开发阶段：47项仍7完成/38进行中/2待外部；正式186条仍9通过/172部分/5未执行。

本轮Android API37模拟器从首页点击创建、系统选择小说TXT开始，依次核对故事/方向/逐集稿、唯一创建作品、保存制作设置和分析、工作台报价与生图、作品分类/个人历史及作品内应用、镜头生成、原生剪辑、主动字幕/校对、导出预览、相册保存及两项成长领取。页面动作由Flutter integration test点击真实控件；系统TXT选择和截图由ADB执行。登录会话、已同意公共协议和10000积分为明确的合成测试前提，不是正式新账号规则。

## 修复与检测

- **T43-MY-01**：“我的”仍是T-06简版，公共入口不可达且余额停留在旧资料。主导航现接入公共AccountPage；本人资料与PointsAPI分别读取，展示真实可用/冻结积分，读取失败保旧值并提示；切号/环境变化拒绝迟到回写。仅可见时读取，返回子页/恢复前台刷新；不开放会员或提现。菜单及路由继续复用公共实现，默认头像改用既有漫剧品牌图。
- **T43-CFG-01**：镜头详情构建时强制刷新配置，同步通知其他页面的Obx，异常被捕获为能力不可用。刷新现延后当前构建，已离开的详情不再启动。两条旧实现回归均实际失败；修复后的专项和最终Android日志均未再出现该异常。
- 6新增回归，58项首页/详情专项及1项主导航检测通过；1217全套App通过，0失败/跳过。全工程analyze、13个Dart文件格式、Android集成debug与iOS普通模拟器debug构建通过；本轮没有执行iOS的这条完整页面旅程。[测试汇总](test-summary.json)、[检查摘要](checks.json)、[源码固定版本](source.json)。
- 最终Android完整方法1条、实际Servlet/PostgreSQL方法1条通过。AI、ASR、OSS外部边界受控；其余接口、JWT、任务调度、资源记录、账务与SQL断言实际运行。只连接自有测试库和随机schema，结束后已清空并停止实例；无业务数据库结构/接口/依赖/媒体引擎改动。[后台JUnit](backend-junit.xml)、[后台结果](backend-result.json)、[schema清理](schema-cleanup.json)。

图片2次各120积分，视频10秒1200积分；完整预算1440在生成前展示。两张图按作品分类入个人资产，个人角色图经历史应用，项目图经影响范围确认。首个成功视频按R-15自动应用，历史正确标记当前并禁用重复应用，不额外提交一次应用。两项成长奖励各10，最终8580可用/0冻结；图片2、视频1、字幕1次提交，生成资源只转存3次。[页面结果](android/android-ui-journey-result.json)。

## 实际媒体与图片

23张页面状态图＋1张系统TXT选择器图，3张总览全部查看；详看“我的”、图片报价和校对后编辑页原图，以及1秒实际成片帧。不是24张原图逐一或最新Figma验收。[总览一](overview-1.png)、[总览二](overview-2.png)、[总览三](overview-3.png)、[查看范围](visual-review.json)。

手机Media3实际输出1280×720/24fps/约10秒H.264＋AAC。独立完整解码、16kHz单声道10秒WAV、440Hz音轨、手写文字与校对字幕时窗检查通过；相册副本与本机MP4逐字节相同。停止App后再次读回仍一致，保留原17份、修复前本轮1份和最终1份共19份视频，四项读取权限前后不变。未卸载App、清相册或操作其他设备。[媒体检查](media-result.json)、[清理检查](cleanup.json)。

![实际1秒成片帧](android/frame-1.png)

## 失败记录与边界

六轮非通过记录均保留：[数据库启动端口](attempts/01-database-port/failure.json)、[TXT原文CRLF断言及选择器导航](attempts/02-txt-expectation/failure.json)、[真实返回栈](attempts/03-back-navigation/failure.json)、[单集影响范围](attempts/04-single-episode-scope/failure.json)、[首视频自动应用](attempts/05-first-video-auto-apply/failure.json)、[实际公共入口/配置异常](attempts/06-public-entry-and-config/failure.json)。前五轮是测试启动或新增UI测试的错误假设，未据此改业务规则；第六轮发现上述两项实际问题。首轮测试选择器没有选中任何用例、冻结余额标签断言及旧主导航夹具缺失Global依赖/设备ID预置的问题另有原始记录；一次卡住的自有Widget runner经核实后主动中止，不计通过。修复夹具后完整1217项重跑通过。

原始输出/媒体/源码快照在忽略目录`originals/`，摘要保留；公开文件由`manifest.json`固定。`verify.py`只复核证据、固定提交及文档边界，不启动设备或重跑业务。`run_android.py`拒绝覆盖旧server-ready/完成/中止标记，复跑前必须保留原轮结果并确认原进程终态。

真实Provider/OSS/ASR、SIM/商店、物理设备、iOS同路径及最新Figma仍未验收；既有3项其他App公共资源夹具失败本轮未改未重跑。`rq4owed6`返回Not connected，当前也没有get_design_context；“我的”功能接线复用既有布局、公共组件与已批准P-21，不声称精确还原5:1346。历史中的长技术版本编号另记可读性观察。受控色块、正弦音和字幕不证明模型画面、口播质量或ASR准确率。
