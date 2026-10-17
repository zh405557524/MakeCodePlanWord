# T-43 同作品双端本机后台与原生媒体联测

2026-10-17，本批受控联测通过，T-43整项仍未完成，阶段保持**开发**。App dev `a791820`，后台 dev `5a0aa63a`，均未推送。

同一作品贯通实际Dio、Servlet/JWT、随机PostgreSQL schema、公共资源/积分、原任务调度、手机缓存/Hive、Media3或AVFoundation、主动字幕、成片预览和系统相册。AI、ASR、OSS外部边界是本机替身；鉴权会话由测试环境建立，不证明短信、真实模型、真实Bucket或商店。

## 本批修复

公共资源策略`OSS_WITH_TEMP_LOCAL`成功后返回`LOCAL_RETAINED`，表示OSS已写入且保留临时本地副本。漫剧原来仅接受`READY`，无法记录原资源编号，导致重复转存。[修复前证据](before-fix-resource-status.json)显示1次图片模型调用产生39次转存、39条已含OSS对象的资源记录。

只在漫剧范围新增`DramaResourceAvailability`，并接入图片、视频、资源引用、视频历史读取四条路径；继续核对当前App、所有者、用途、权限、实际元数据和期限，不放开待上传、失败、已删或纯本地保留状态。公共资源、其他App、API、Entity/Repository、数据库结构均未改。

修复后，两平台总计4张图、2个视频仅6次服务端私有转存，另2条为手机主动上传的字幕混音；最终每人可用8580、冻结0。每端从测试预置10000扣1440，再领取两项各10的一次成长奖励，不涉及真实充值。[后台断言](backend-result.json)、[回归结果](backend-regression-result.json)。

## 覆盖与边界

每端各创建1作品/1集/1镜头：现成剧本输入 → 手动核对最终稿 → 确认创建 → 制作设置 → 实际分析任务 → 角色/场景首图及作品名称分类 → 实际视频任务 → 作品入口下载并进入剪辑 → 文字保存 → 主动字幕及本机校对 → 1280×720、24 fps原生导出 → 预览 → 手动保存相册 → 两项成长各一次。

创作、作品入口、剪辑、字幕和成片流程使用实际页面；素材及视频任务由手机实际Service/API提交，未覆盖全部工作台按钮。样片是本机生成的10秒H.264/AAC色块和440 Hz合成音，不是真实模型画面或对白。ASR返回受控文本，因此只证明混音上传、原任务、时间戳和本机校对接线，不证明识别准确率。

三文件analyze、格式检查通过。iOS/Android严格driver各1条完整方法通过；Flutter额外统计tearDownAll，不计作另一业务方法。Java真实Servlet/PG旅程1条通过，10类相关后端回归183条全部通过（包含7条资源状态单测，无跳过）。1196全套App是前轮基线，本轮未重跑。正式186条正文、9通过/172部分/5未执行以及47任务7完成/38进行中/2待外部验证均保持。

## 实际媒体和相册

独立ffprobe及完整解码确认两份实际MP4有H.264、AAC、1280×720、24 fps和约10秒时长；上传混音均为16000 Hz单声道16位WAV、160000采样。频率检查确认原440 Hz声音进入混音和成片；0.25/1/2秒帧确认文字和字幕按各自时段烧录。[验证脚本](verify_media.py)、[实际结果](media-result.json)。这些宿主检测工具不是手机媒体引擎。

两端均按本轮新增相册文件核对，摘要与各自导出MP4逐字节一致，正常终止App后仍完整且包保持安装；未删除任何相册内容。iOS系统副本435350字节，Android系统副本796077字节。[iOS回执](ios/system-album.json)、[Android回执](android/system-album.json)。

Flutter默认drive收尾会卸载App。一次Android测试在工具卸载后读到零字节，该轮保留于`attempts/14-driver-uninstalled-android`，不能作为正常退出的产品结论。最终改用`--keep-app-running`并在仍安装时读取文件、正常force-stop后再读。另一次截图ACK超时源于启动时forward被工具清除，保留于`attempts/15-flutter-cleared-capture-forward`；最终只恢复本批自有54344端口，未放宽业务断言。

## 页面证据与尚存问题

14张系统截图总览已查看；另详看iOS校对后页面、Android相册成功页及双端1秒实际视频帧。下图仅供本批状态复核，最新Figma通道未连接，不能视为设计验收。

![双端七个页面状态](system-screens-overview.png)

| 状态 | iOS | Android |
|---|---|---|
| 输入 | [截图](ios/ios-os-01-input.png) | [截图](android/android-os-01-input.png) |
| 最终确认稿 | [截图](ios/ios-os-02-final-script.png) | [截图](android/android-os-02-final-script.png) |
| 制作设置（分析后） | [截图](ios/ios-os-03-analyzed.png) | [截图](android/android-os-03-analyzed.png) |
| 作品进入剪辑 | [截图](ios/ios-os-04-editor.png) | [截图](android/android-os-04-editor.png) |
| 字幕校对后 | [截图](ios/ios-os-05-corrected.png) | [截图](android/android-os-05-corrected.png) |
| 成片预览 | [截图](ios/ios-os-06-export-preview.png) | [截图](android/android-os-06-export-preview.png) |
| 相册成功 | [截图](ios/ios-os-07-album.png) | [截图](android/android-os-07-album.png) |

- **T43-PREVIEW-01，待定位**：1秒时剪辑预览中文字的位置与实际导出帧不同。烧录内容及时间验证通过，不等于预览布局一致，TC-X06不能据此判通过。见[iOS预览](ios/ios-os-05-corrected.png)、[iOS实际帧](ios/frame-1.png)、[Android实际帧](android/frame-1.png)。
- **T43-SUBTITLE-01，待定位**：校对后实际本机字幕`reviewed=true`，页面仍提示“未校对”。字幕内容已进入成片，但提示状态需复检。
- 真实AI/ASR/OSS、SIM/商店/支付、物理设备、完整三入口和工作台按钮、最新Figma、性能和空间故障仍待。3条旧公共资源夹具失败本轮未重跑，不计入183条。

## 复跑及清理

复跑前先归档本批证据及忽略的finish标记，重新准备专用测试目录，避免混入旧报告；不清除系统相册。后端入口是`CatdramaMobileJourneyIntegrationTests`，须显式设置`CATDRAMA_MOBILE_JOURNEY=true`、`CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:<专用端口>/catdrama_test`和`CATDRAMA_MOBILE_JOURNEY_EVIDENCE=<本目录绝对路径>`，以专用随机schema运行，不连接正式数据库。服务就绪后从`server-ready.json`取动态桥接端口；分别构建`CATDRAMA_E2E_SLICE=server-journey`测试二进制，并将`CATDRAMA_JOURNEY_BRIDGE_PORT`、`CATDRAMA_CAPTURE_PORT`与本轮端口一致。

驱动沿`test_driver/catdrama_business_driver.dart`，环境显式设置`CATDRAMA_TEST_SLICE=server-journey`、平台和证据目录。使用`--keep-app-running`；iOS仅添加相册权限需在启动前设置，Android截图forward需在Flutter安装启动后确认仍有效。原始报告及四份媒体摘要通过严格driver、媒体和相册独立检查后，才写入忽略目录`originals/finish.json`供Java最终断言。

本轮专用schema全部清理，剩余0；Java/桥接服务和专用PostgreSQL已停止，两个自有QA模拟器已停止，iOS本App添加相册权限恢复原空记录，临时打标签密钥已删除，其他数据库、相册文件和应用未清除。[运行清理](runtime-cleanup.json)、[设备清理](device-cleanup.json)。

原始日志、临时令牌、数据库及测试密钥不提交；发布日志已脱敏。失败轮留在`attempts/`，不能与最终报告混算。仅复检现有证据可运行`python3 verification.py`；[manifest](manifest.json)记录公开文件摘要，[verification](verification.json)记录范围、冻结源文件、正式用例和跨文档保护检查。
