# 喵喵漫剧 Catdrama

Flutter/iOS/Android移动端工程，公共基础来自Catsinger，漫剧业务按获批计划重新实现。

T-27视频历史恢复已补齐（2026-10-16）：刷新失败保留已核实清单，重复/漏页与数量变化拒绝；翻页和重试保留手选。只有有效作品当前引用保护旧成功视频，过期候选不能预览或应用；切号/到期立即禁用，弹层始终可关闭，离页释放播放器和计时器。本机换版仍由用户明确选择后一次保存、可撤销。18新增/128相关、1144全套App、analyze及17文件格式通过；双端各3条实际历史页面/HTTP/KV流程和1条真实本机换版/导出通过，两份MP4已独立完整解码。真实Provider/OSS、物理设备及最新Figma仍待验，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-27/history-safety/README.md)。

T-46已接入相册单视频选取、真实波形/选段试听、指定音轨独立提取，以及原任务/完整结果恢复。使用既有选择插件、Hive账本和ADD_AUDIO链路；源视频不进入画面或后台，50 MiB仅约束提取结果，不设90秒限制。实际iOS相册删除源视频后的混音/导出已检；Android实际媒体、两端真机/云端占位视频与真实ASR仍待联验，整项保持未完成。[检测及进度](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-46/result.json)。

- 工作区：[喵喵漫剧开发文档](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/README.md)。
- 开发计划与进度：[v1.0.0任务列表](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/04-开发计划/开发计划.md)。
- Android applicationId / iOS Bundle ID：`com.lxwx.catdrama`；App Code：`catdrama`。
- Flutter：3.41.6 / Dart 3.11.4；依赖精确版本以`pubspec.lock`为准。
- 默认测试环境：`CATDRAMA_ENV=2`，本地为1，正式为3；开发默认不访问正式服务。
- Android经用户授权复用写歌签名，`android/key.properties`及`android/app/lxwx.jks`仅在本机并由Git忽略。iOS未复制原App证书或描述文件。
- 目标App的一键登录授权通过本机构建参数`CATDRAMA_ALIYUN_IOS_AUTH` / `CATDRAMA_ALIYUN_ANDROID_AUTH`注入；本机授权文件为Git忽略的`local-config/number-auth.local.json`，运行、打包时使用`--dart-define-from-file=local-config/number-auth.local.json`。缺少时沿公共手机号登录兜底。商店未配置前`APPLE_IAP_ENABLED`默认关闭。
- UI以用户Figma为主；公共页面对稿、制作流程、编辑器与后台业务按后续任务实现。初始主壳可启动不代表完整App已完成。
- 本地界面图片采用1x/2x/3x：assets/images/为基础图，2.0x/、3.0x/保存同名倍图，AppAssets只引用基础路径。
- T-16历史切片：资产列表/详情/编辑/历史已接主Tab及实际路由，按稳定作品ID分组并支持个人/系统与三类型筛选；公共GetStorage保稿和原动作恢复，PATCH先核实，引用中禁删、旧请求不回滚新选图。新增32项/全套285项App＋10项插件、analyze与两端各2项流程通过，26张截图见工作区T-16/client。修复同资产新旧路由Controller误释放；受控HTTP/媒体夹具不代表已部署Java或真实Provider/OSS。图片上传/下载、生成参数/失败卡、自动入库、导入竞态及成长仍待对应任务，T-16保持未完成；整项进度以工作区实时列表为准。
- T-15作品封面已补齐：列表与详情使用同一相册选择、预览和确认上传流程；取消不上传，失败保原图，固定打开表单时的作品版本。UploadService复用私有副本/原对象回执，ProjectCoverEdit与作品原操作共用已有GetStorage记录；跨入口恢复不重传，成功已落盘只补清理。封面不创建资产或触发成长奖励，剧集及截止不变。新增25项、全套951项App、31项既有后端、analyze及16文件格式通过；两端模拟器各2项真实相册/HTTP PUT/沙盒服务恢复通过，10张最终截图留证（查看范围见清单）。真实OSS、最新Figma及真机/完整制作剪辑仍待验收，无新API/DDL/依赖。详见[工作区证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-15/cover-upload/README.md)。
- T-17图片下载已补齐：资产详情和历史直接保存选定有效版本，复用resourceId缓存、公共权限及MediaLibrary；不应用候选、不新增业务写入或扣费。取消读取、失败/未知回执、重复操作、切号/离页及到期均保护原图；提示位于实际按钮旁。PNG/JPEG原文件保存，静态WebP按原尺寸/透明度转PNG；iOS经PhotoKit addResource避免UIImage重编码，Android沿既有相册插件。图片、海报与视频写入共用串行保护。新增34项/全套985项App、18项既有资源后端、analyze通过；双端模拟器各2项、8张实际相册文件独立解码和12张最终截图留证。真实OSS、物理机权限/大图及最新Figma待验，不记整项通过。详见[工作区证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-17/image-download/README.md)。
- T-17手机图片上传：相册复用Catsinger的wechat_assets_picker 10.1.2（photo_manager锁定3.10.0），封装在plugins/MediaPicker；图片权限沿Access，仅图片入口不申请视频/音频读取。TXT继续复用file_picker与TextImportService，仅小说入口接受TXT。UploadService把已选图复制至独立沙盒并沿DramaAssetService持久保存上传确认参数；不保存签名URL。超时先确认原对象，保存失败保留表单和旧图；已存在资产通过POST /api/drama/assets/{assetId}/images追加历史并应用。检测及真实OSS待验边界见工作区T-17/mobile-upload/result.json。
- T-28已接本集剧本编辑、差异核对与移出历史恢复。原稿及原操作沿DramaProjectService写盘，未知PATCH先GET核实，POST沿原键；分析沿DramaJobService，不新建轮询。原文/上下文唯一才保留镜头及视频，取消/失败/过时不覆盖；恢复核对同剧情唯一位置，不改本机时间轴。真实模型、最新Figma与两端完整联验待补，[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-28/result.json)。
- T-28导航补齐（2026-10-16）：本集剧本可切集或进入已有素材，先等当前完整改稿实际落盘；失败/切号/到期不跳转，未保存到作品的改稿不隐式PATCH、分析或生成。GetBuilder按路由实例与集身份设置key，防止query变化仍用上一集Controller；深链返回使用公共兜底。新增9项/全套1010项App、56项相关、analyze及8文件格式通过；双端各2项实际作品/剧本/素材页面及公共KV检查，14张最终系统图与6张Widget图留证，关键6张系统图已看。后台/API/DDL/依赖未改，真实模型/OSS、最新Figma及物理设备继续待验。[本轮证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-28/navigation/README.md)。
- T-26已接镜头单/批视频原任务恢复、逐项确认、所选失败项重报及候选/历史试听。列表默认排除已用/候选的自动勾选，活动/未知/保存中禁止重复；同一原任务终态保持，手改输入不被刷新覆盖。试听按resourceId缓存并对照原台词，关闭/切后台暂停释放。视频首成功按后台条件应用，后续留候选；免费手动应用和本机版本修复继续T-27。最新Figma、真实Provider/OSS和两端物理设备媒体验证仍未完成，[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-26/result.json)。
- T-29下载/缓存及准备Service已实现：只读版本清单沿DramaShotsAPI，签名沿公共ResourceAPI；MediaDownloadService并发2路、续传/取消/校验，CacheService以私有文件和Hive维护资源ID/固定版本及预留，不统一预转码。原生deviceState/verifySource读取真实空间/连续时钟并实际解码；完整有效head可不依赖后台恢复。34后端、76App与analyze通过，iOS模拟器真实MP4已测；准备页/M-28及T-30真实工程入口仍未完成，Android/真实OSS待验。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-29/result.json)。
- T-07本机插件位于packages/native_media_engine：Android Media3 1.11.1，iOS AVFoundation/CoreImage；统一组合预览、音轨混音、中文字层烧录和实际MP4导出。随包Noto Sans SC及许可仅用于剪辑文字，不替换界面字体。
- T-18作品详情显示全剧及逐集真实制作进度，明确失败的集可单独重试；原键和版本先写盘，离页/丢回执后由DramaJobService继续查询原任务，成功集不重做。接口沿DramaProjectsAPI，状态与请求模型沿ProductionAction/EpisodeAnalysisAction；不建立页面私有任务轮询。真实AI与最新Figma联验待补，当前结果见[工作区T-18证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-18/result.json)。
- T-19接入本集素材与同类资产导入两页：按角色/场景/道具显示真实绑定，可手动新增、归档和恢复；导入明确选定个人或已发布系统资产的图片历史版本，来源换图不影响作品。DramaAssetBinding/EpisodeAssetAction沿DramaAssetService持久保存原动作，未知回执继续原键，成功写盘失败只补存结果；图片复用resourceId缓存。归档拒绝当前镜头、活动任务及跨集共享引用；共享编辑/本集独立由T-20承接。本轮可执行测试和待验边界见[工作区T-19证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-19/result.json)，最新Figma与两端设备联验待补。
- T-20已接共享范围与仅本集独立：素材卡片可核对资料和历史图，确认弹框显示实际分集、字段/图片及镜头影响；取消不写入，冲突保留手改并要求重读范围，独立后替换当前卡片。原PATCH/应用请求沿EpisodeAssetAction及DramaAssetService持久恢复，未知不换键；未保存修改有返回/切集保护。17项新增、147项相关App及analyze通过，320/430逻辑像素宽布局和30集滚动均有Widget证据；真实Figma、设备及后续收费生成/重分析联验待补。[工作区T-20证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-20/result.json)。

```sh
flutter pub get
flutter analyze
flutter test test packages/native_media_engine/test
flutter build apk --debug
flutter build ios --simulator --debug
```

需要启用本机号码认证配置时：

```sh
flutter run --dart-define-from-file=local-config/number-auth.local.json
flutter build apk --debug --dart-define-from-file=local-config/number-auth.local.json
flutter build ios --simulator --debug --dart-define-from-file=local-config/number-auth.local.json
```

实际检测证据位于工作区`v1.0.0/05-测试/evidence/`，每项任务验证后更新进度；编码规则见本仓库AGENTS.md及分层.cursor/rules。

---

T-19已补齐素材返回剧本与版本提示（2026-10-16）：顶部“本集剧本”进入同一作品、同一集的真实编辑页，恢复本机手改，不隐式保存作品或分析/生成；清单显示已保存剧本版本和素材分析版本，缺失版本不猜测。新增素材及共享资料未保存时保护输入，返回需明确放弃。新增11项、45项相关、全套1021项App及analyze通过；双端各2项实际作品/剧本/素材页面和公共KV检查，16张系统图及9张Widget图留证，关键4张系统图和2张Widget图已查看。后台、契约、依赖及原生实现未变，未重跑后台；真实OSS/AI、最新Figma和物理设备完整链路仍待验，整项保持未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-19/script-return/README.md)。

T-25批次核对与重试恢复已补齐（2026-10-16）：图片历史按完整分页核对，重复/漏项/数量变化不猜成缺图；子任务与父批次总数、唯一任务/目标一致后才展示。打开和取消重试报价保留当前页面的原批次结果与手动选择，新尝试未知按其原报价/任务恢复，不沿用旧终态；查询失败保已核实结果并禁重复生成，错误不再显示为持续加载。8新增/22批次、109相关/1112全套App、analyze及6文件格式通过；双端实际路由/报价/回环HTTP/公共KV各4项通过，28系统图与3Widget图留证。后台与公共账务本轮未改未重跑，真实Provider/OSS、最新Figma、物理机及完整付费链路仍待验，整项未完成。 [证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-25/batch-recovery/README.md)。

T-24资产定位和分类反馈已补齐（2026-10-16）：查看资产按个人素材ID、具体图片版本及原图来源定位，跨页找回后突出目标；展示实际作品名和角色/场景/道具。查看、预览、取消和返回不改个人选图或作品引用；读取失败可重试，缺失不换图，过期缓存不可用。17新增/16定位、122相关/1104全套App、analyze/12文件格式通过；双端实际公共路由/回环HTTP/资源ID缓存各4项通过，34系统图与2Widget图留证。原后台证据保留，本轮未改未重跑；真实Provider/OSS、最新Figma、物理机及完整付费生成仍待验，整项未完成。 [证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-24/library-navigation/README.md)。

T-23历史与候选恢复已补齐（2026-10-16）：刷新按具体版本找回跨页手选图，翻页失败保留原清单，重复/空非末页和串素材响应明确报错；手选图消失提示不可用，不自动换图，用户重新选择后清除对应提示。有效作品当前应用图不受历史第一页和原版本截止影响；未引用过期缓存不能打开预览。历史加载/错误/空态分开，图片迟到能刷新缩略图；路由key/tag包含素材身份，换页释放原Controller。14新增/30工作台、94相关/1087全套App、analyze通过；双端实际公共路由/回环HTTP/文件缓存各4项通过，30系统图和9Widget图留证，全部总览、详看10系统/4Widget。查看、刷新和取消无生成或应用业务写入，私有资源签名POST仍沿公共接口。后台未改未重跑，无新API/DDL/依赖/原生实现；真实Provider/OSS、最新Figma、物理机及首次付费完整链路继续待验，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-23/history-recovery/README.md)。

T-22预算明细已补齐（2026-10-16）：素材清单、镜头清单及生成确认复用同一份本集/全剧预算，列出图片数量、逐镜头秒数/单价/小计、复用/待应用/处理中排除项，以及余额差额。共享图片全剧去重；参数刷新清旧预算，历史/价格未知不显示完整总价，过期候选和报价不作为有效预算，已应用旧版本按有效作品引用保护。分集最多4路读取，同次共享历史合并。20新增/60预算报价、117相关、29设置及1073全套App、analyze/21文件格式通过；双端各5条页面/回环HTTP/公共KV流程，44系统图（含2导航探针）及10Widget图留证。T-42反馈测试等待另以dev f1d8c9d提交，业务代码未改。后台未改未重跑，无API/DDL/依赖/原生实现变更；受控30集读取不代替真实网络性能、真实模型/OSS/支付、最新Figma及物理机完整链路验收，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-22/budget-details/README.md)。

T-22已补齐生成确认与预算门禁（2026-10-16）：坏任务回执不进入补存缓存，后续继续查询原键；快速充值只进入一次，返回重报价且不自动生成。所选范围预算不完整禁止提交，本集完整而其他集未知时须明确选择仅本集；过期图不算可复用，重报价清除旧确认。新增12项、40项报价/69相关/1053全套App、analyze及12文件格式通过；双端各4项实际页面/回环HTTP/公共KV通过。30张系统图（含2张充值导航探针）和8张Widget图留证，总览全部、详看8张系统及4张新增Widget图。后台未改未重跑，无API/DDL/依赖/原生实现变更。完整费用明细、首次付费链路、大规模预算读取性能、真实模型/OSS/支付、最新Figma及物理机仍待验，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-22/confirmation/README.md)。

T-21已补齐镜头导航与手改保护（2026-10-16）：固定本集剧本/素材入口按真实作品和分集ID打开现有页面；离开前冻结输入、等待失焦并实际写盘，输入法末次回写纳入同一保存循环。切换镜头同时更新GetBuilder的key/tag，逐镜头恢复完整描述、口播、引用顺序及参数；写盘失败留页，写盘后切号或到期不跳转，浏览不隐式PATCH或生成。新增11项、54相关/1041全套App、analyze和8文件格式通过（含T-42的TXT测试等待修复）；双端各3项实际页面/回环HTTP/公共KV通过，iOS同源再跑3项通过。18系统图及12Widget图留证，全部总览、8系统图和4新增Widget图详看；重复/失败采集单列。后台未改未重跑，无API/DDL/依赖/原生实现变更；最新Figma、真实模型/OSS及物理设备完整链路仍待验，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-21/navigation/README.md)。

T-14已补齐制作设置返回作品剧本（2026-10-16）：复用现有分集选择弹层和真实编辑页，按稳定ID选择，不返回已转换的只读草稿。离开前等待本机参数写盘，失败留页，切号/到期不跳转；返回刷新作品并保留参数，版本冲突须明确核对。修改稿仅明确保存时PATCH，后续明确分析才使用新稿，不重复创建或重拆。新增9项、64相关/1030全套App、analyze和6文件格式通过；双端各3项实际页面/本机HTTP/公共KV，20张系统图及3张Widget图留证（关键8系统图、全部3Widget图已看）。检测驱动补新截图名称及完整业务报告校验，另一次iOS默认SDK采集3项通过、10份缓冲图仅用于采集传输检查。后台未改未重跑，无API/DDL/依赖/原生实现变更；真实AI/OSS、最新Figma与物理设备完整链路仍待验。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-14/script-return/README.md)。

以下保留建仓时的Codeup使用说明。

### 3 分钟了解如何进入开发

欢迎使用云效代码管理 Codeup，通过阅读以下内容，你可以快速熟悉 Codeup ，并立即开始今天的工作。

### 提交**文件**

Codeup 支持两种方式进行代码提交：网页端提交，以及本地 Git 客户端提交。

* 如需体验本地命令行操作，请先安装 Git 工具，安装方法参见[安装Git](https://help.aliyun.com/document_detail/153800.html)。

* 如需体验 SSH 方式克隆和提交代码，请先在平台账号内配置 SSH 公钥，配置方法参见[配置 SSH 密钥](https://help.aliyun.com/document_detail/153709.html)。

* 如需体验 HTTP 方式克隆和提交代码，请先在平台账号内配置克隆账密，配置方法参见[配置 HTTPS 克隆账号密码](https://help.aliyun.com/document_detail/153710.html)。

现在，你可以在 Codeup 中提交代码文件了，跟着文档「[__提交第一行代码__](https://help.aliyun.com/document_detail/153707.html?spm=a2c4g.153710.0.0.3c213774PFSMIV#6a5dbb1063ai5)」一起操作试试看吧。

<img src="https://img.alicdn.com/imgextra/i3/O1CN013zHrNR1oXgGu8ccvY_!!6000000005235-0-tps-2866-1268.jpg" width="100%" />


### 进行代码检测

开发过程中，为了更好的维护你的代码质量，你可以开启 Codeup 内置开箱即用的「[代码检测服务](https://help.aliyun.com/document_detail/434321.html)」，开启后提交或合并请求的变更将自动触发检测，识别代码编写规范和安全漏洞问题，并及时提供结果报表和修复建议。

<img src="https://img.alicdn.com/imgextra/i2/O1CN01BRzI1I1IO0CR2i4Aw_!!6000000000882-0-tps-2862-1362.jpg" width="100%" />

### 开展代码评审

功能开发完毕后，通常你需要发起「[代码评审并执行合并](https://help.aliyun.com/document_detail/153872.html)」，Codeup 支持多人协作的代码评审服务，你可以通过「[保护分支设置合并规则](https://help.aliyun.com/document_detail/153873.html?spm=a2c4g.203108.0.0.430765d1l9tTRR#p-4on-aep-l5q)」策略及「[__合并请求设置__](https://help.aliyun.com/document_detail/153874.html?spm=a2c4g.153871.0.0.3d38686cJpcdJI)」对合并过程进行流程化管控，同时提供在线代码评审及冲突解决能力，让评审过程更加流畅。

<img src="https://img.alicdn.com/imgextra/i1/O1CN01MaBDFH1WWcGnQqMHy_!!6000000002796-0-tps-2592-1336.jpg" width="100%" />

### 成员协作

是时候邀请成员一起编写卓越的代码工程了，请点击左下角「成员」邀请你的小伙伴开始协作吧！

### 更多

Git 使用教学、高级功能指引等更多说明，参见[Codeup帮助文档](https://help.aliyun.com/document_detail/153402.html)。

T-04已实现短信防重、迟到保护、合法来源恢复与Figma绿色登录页面；44项App回归、4项目标公共后端H2及两端各2项模拟器方法通过。修复iOS原生旧通道名。本次两端目标授权已由用户提供并注入本机忽略配置；253项App＋10项插件、未配置回落22项及两端各4项SDK/登录回归通过。iOS配置返回600000，模拟器预检无SIM；Android预检无法判运营商，短信回落正常。真实SIM/短信/token换登仍未完成，不阻塞后续开发。[结果](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-04/result.json)、[授权复检](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-04/authorization/result.json)。

T-06已补齐首页/案例私有媒体缓存与草稿连续验证（2026-10-16）：封面与视频按resourceId复用本机文件，公开签名不带账号凭证，视频点击后才准备并交给文件播放器；显式重试只清理该坏资源。修复首页封面完成后不刷新的响应式遗漏，以及初始化中切后台/离开后自动播放；签名和实际传输分别去重，缓存仍只有资源ID身份。新增16项、全套1001项App、59项相关回归、32项既有后端、analyze通过；双端各4项真实页面/播放器/公共KV连续检查通过，包含原稿跨四Tab与服务重建恢复、同款独立草稿及原稿保护。20张最终系统截图（关键4张已查看）和4份缓存媒体留证，真实运营案例/OSS、最新Figma与物理设备仍待验收。无接口/DDL/依赖变更。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-06/private-media/README.md)。

T-07可执行检测通过：当前115项App/插件单测、analyze、两端各3项原生集成方法，以及18份实际媒体独立解码检查通过。覆盖720/1080横竖、29.97帧率、500ms片段、混音/静音/150%增益、中文字层和取消/旧文件保护；8张系统预览截图已保存。真机性能、系统强杀及完整编辑工程/相册链路尚未验收，任务保持未完成，不阻塞后续独立开发。[结果](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-07/result.json)。

T-11任务恢复由`DramaJobService`统一管理：业务提交前`rememberRequest`保存原幂等键，返回编号后`bindJob`绑回原关注项；跨页`watchJob`，重新进入/回前台`restore`读取真实状态。三条GET复用公共HTTP，受理恢复带`activeOnly=false`，不遗漏已成功或已失败任务。后台停止轮询、回前台立即查询；网络失败5/10/30秒退避，不把未知/超时改成失败，不自动重新提交。终态定位保留至业务成功消费后`forget`，结果保存失败仍可重取同一任务。KV按账号、环境和后台地址隔离，退出/切换后隐藏旧状态并拒绝迟到回写；剪辑/导出仍在本机。检测与业务接入边界见[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-11/result.json)。

T-09输入页位于`pages/creation/input/`，实际路由`RouteName.creationInput`。默认现成剧本/AUTO，输入不截断，20/10000按runes校验；小说TXT由T-10接入。`DraftSyncService`500ms防抖沿用公共GetStorage，创建前等待实际写盘；固定首次幂等输入、未知保存先核对原草稿、CAS冲突保留本机/云端稿，用户选定后才替换。缓存按账号/环境/后台隔离，做同款带允许风格并强制独立草稿。三种手机尺寸/键盘和两端真实HTTP/沙盒恢复可执行检测见[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-09/result.json)；真实强杀与后续剧本页面仍未完成，T-09保持进行中。

T-10小说入口使用真实FilePicker选择TXT，`TextImportService`读取最多10MiB实际字节，经公共Dio上传既定`POST /api/drama/imports/text`。后台只解码返回候选，用户确认后才写回草稿；空/坏/超限文件、系统取消及过时结果不覆盖原稿。成功保留段落并显示文件名，不保存文件路径、不入资产、不计费。新增14项App方法，全套154项及analyze通过；两端各2项系统选择器→本机真实Spring/PG联验通过，短信为Mock；不等同已部署服务或真实渠道验收。无新图片/依赖/数据库结构改动，1x/2x/3x规范继续有效。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-10/result.json)。

T-44新增`DramaMarkdownContent`组件，封装锁定的[flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus)，不执行HTML、不自动加载任何图片、不跳转外链，传入字符串保持原样。页面编辑继续使用其原始字符串，后续T-12/T-13接入。4项新增组件测试、全套158项App及analyze通过；纯Dart依赖，不新增平台配置或图片。本次后台模板/固定快照/原文恢复组件的检测见[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-44/result.json)，真实Provider及完整页面按后续任务验收。

T-12实际路由为`RouteName.storyReview`，页面与Controller在`pages/creation/story/`。`StoryContent`统一承接梗概、每集标题/方向及Unicode边界；编辑通过既有`DraftSyncService`整稿保存，双份冲突需用户选定。生成提交前把动作和任务定位真实写盘；网络未知继续查询，结果应用/确认失败重取原结果或原动作，不重生成。覆盖弹框只收集选择，成功候选的来源/目标版本匹配后才应用，取消/失败保旧稿。确认后已由T-13接入实际逐集核对页；原T-12记录中的等待项由本切片补齐。历史新增20项故事方法及1项任务定位写盘回归，相关50项包含于当时全套179项；两端各2项故事流程以真实Dio/HTTP和沙盒KV运行，后台是隔离协议夹具，不能替代真实Spring/PG和Provider证明。后台既有60项证据及真实通道缺项分别保留。1x/2x/3x规范复检通过，175个既有图片文件摘要未变，13张旧图缺倍图继续归T-36/T-40。[历史结果和截图](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-12/client/result.json)。

T-13实际路由为`RouteName.screenplayReview`，页面在`pages/creation/screenplays/`；`ScreenplayContent`保存完整逐集稿，`DraftContentController`共用原任务/动作恢复。API独立位于`apis/drama_projects.dart`；确认先保存最终稿，再以原键提交`POST /api/drama/projects`。丢失响应时保留原动作，已转作品的只读草稿仍可恢复相同projectId。制作设置未注册时显示待接入提示并保留作品，不伪造分析或扣费。新增19项App方法，含未知任务、应用/创建丢回执、超限退出恢复、旧稿保护与大小屏键盘；当前全套198项通过。[本轮证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-13/client/result.json)。

T-17私有媒体策略与资源ID图片缓存已通过局部检测：293项App＋10项插件、analyze、80项相关后端和双端各2项资产流程/26张截图通过；同ID反复打开详情只下载1次。以上为2026-10-15历史切片；T-17已补上传与下载、T-06已补案例视频缓存。真实OSS及完整媒体联验按对应任务继续，当前整项统计和前后端/检测/剩余工作以工作区进度表为准。

T-17手机相册/上传及返回刷新已通过本轮验证：306项App、10项插件、60项相关后端及双端各4项实际流程通过；现有资产保存正常返回，公共RouteObserver统一刷新详情。真实OSS、其他媒体入口及完整主流程继续按工作区对应任务验收。[结果](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-17/mobile-upload/result.json)。

### 2026-10-15 T-47实现与检测

T-47免费AI帮写已接入后台任务和资产编辑页：候选需用户确认，手改/切账号保护及原键恢复已实现；写盘失败只恢复原请求或原结果。14项新增、71项相关后端，15项新增、321项全套App及analyze通过；两端各2项页面/HTTP/沙盒流程和12张截图留证。真实AI样例及最新Figma复核待补，整项保持未完成。AssetDescriptionService复用DramaJobService轮询与GetStorage写盘屏障，只持久化原表单请求/消费标记；候选应用仅改本机表单，资产保存仍走原接口。无新依赖，pubspec.lock与T-17保持完全一致。当前6完成/10进行中/2待外部/29未开始。[工作区证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-47/result.json)。

T-27 已接通免费历史视频应用与本机显式换版。镜头原CAS/幂等操作持久化后请求；未知回执恢复原键，应用只改源选择。编辑器只读核对保存上次服务器核对时刻，离线继续原固定源；全部分割片段可分别选择，下载校验后逐片处理越界，明确预览/保存，一次完整快照支持撤销。取消、下载失败或明确未提交的写失败保旧工程；put后回执未知只补存。字幕、文字、封面和音轨按片段锚点映射，真正换版才使成片过时，旧文件及相册保留。检测结论与双端待验收项见工作区 T-27。


## T-39 成长

LocalGrowthFactsService读取同一Hive账本中已有的成功导出事实，仅在任务中心主动领取时提交clientExportId/episodeId。原请求先落盘；未知回执先查原状态，已到账但本机保存失败只补存。工程、媒体和字幕仍在手机，领奖失败不影响成片。成长卡参考Figma5:8073/5:8218，5:8173图标直接导出1x/2x/3x。当前检测及平台联验缺项见工作区T-39证据，未验证部分不记整项完成。

## T-40 设置与正文

设置页使用既有CacheService/MediaCacheScope预览和清理原作用域，显示实际释放量并保护作品/撤销链、活动任务及工程账本；只扫描已登记应用文件，不操作系统相册。共享缓存上限先保存再更新可观察值，写入失败保留原预算。反馈沿POST /api/feedback，500字、原会话保护、真实回执，失败留输入、成功回原来源。原webview路由读取当前App静态正文，Markdown复用现有组件，HTML禁脚本；空配置不放演示内容，版本来自PackageInfo。当前验证和待联验范围见工作区T-40。

## T-41 本机保留边界

作品期限只控制有效作品的剪辑入口，不自动删除手机工程、源文件或相册副本。继续复用EditingPrepareService和LocalEditorStore的固定版本、有效离线租期及显式删除门禁；只有主动清理可释放到期且无活动任务保护的应用文件。新增5项真实私有文件/Hive检测，相关88项App检测及analyze通过；生产Dart/原生/依赖未改，复用T-40两端构建证据。真实两设备、系统相册及云端联验仍待补，详见工作区T-41。

## T-42 会话与设备恢复检测

新增跨制作查询、资产帮写和本机文件的会话竞争检测：账号/后台地址切换拒绝迟到结果，两个表单独立，丢受理回执及断网只恢复原键，明确失败才新提交。921项App测试及analyze通过。设备入口catdrama_recovery_test组合既有真实HTTP/沙盒和原生工程场景，两端模拟器分别write→显式终止进程→recover，通过完整快照/撤销/固定源/离线预览；每端每阶段3项，共12次执行，4图已查看。保留测试App须使用flutter drive --keep-app-running；旧截图夹具补Android Surface转换后的帧刷新，不改媒体业务。真实Provider/OSS、两台真机及系统环境边界仍待联验，详见工作区T-42。

## T-43 两端业务切片与实际成片检测

新增`catdrama_end_to_end_test.dart`和`public_business_test.dart`，按`CATDRAMA_E2E_SLICE`/`CATDRAMA_PUBLIC_SLICE`每进程选择一个场景。三入口连续核对最终稿、唯一作品、独立制作设置与分析失败保稿；公共切片覆盖签到丢回执、邀请原键/分页、流水订单只读和原生HTML。HTTP/模型/ASR使用明确标注的协议夹具，媒体、私有文件及系统相册使用模拟器实际原生实现；各切片不是同一作品的真实Provider全链路，登录/真实支付未在本次默认切片执行。

检测修复四项问题：制作页按路由实例隔离Controller；Android用有理数帧时钟与两帧缓存替代近似丢帧，按素材边界输出；缓存统计仅跳过原子改名产生的ENOENT，其他I/O继续报错；提音保留真实文件时长，默认音轨按用户截取时长应用。没有增加依赖、后台接口、表结构或手机FFmpeg。

最终926项App、23项插件、10项帧时钟协议检测、analyze和14文件格式检查通过；Android/iOS模拟器合计21次有效场景执行，正常应用两端debug构建通过。15份手机实际媒体完整解码，另核对4份横竖成片的时间戳、红绿镜头切换、黑边、文字/字幕时窗、混音及内嵌封面；两端系统相册副本摘要与原文件一致，清理临时成片后仍在。Android自建92秒双音轨视频在90秒后截取，删除测试源后独立音轨仍参与混音和导出，实际频谱为所选880Hz轨。63张最终截图已保存，逐张检查范围见证据清单，未计为Figma整体验收。

采集证据使用`flutter drive --keep-app-running --driver=test_driver/catdrama_business_driver.dart`，设置`CATDRAMA_BUSINESS_EVIDENCE_DIR`、`CATDRAMA_TEST_PLATFORM`、`CATDRAMA_TEST_SLICE`；手机目标与切片通过`--target`和`--dart-define`明确选择。工作站可执行`python3 test_driver/verify_business_media.py <T-43证据目录>`独立解码，FFmpeg只用于工作站检测。实际Provider/OSS、SIM/商店、两端真机、最新Figma及完整业务链仍待验收，T-42的3项旧公共夹具失败继续保留。T-43整项保持未完成，当前仍处于开发阶段。[检测证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-43/README.md)。

T-26生成恢复复检（2026-10-16）：视频历史按完整分页核对，子项须匹配父总数及唯一镜头；打开/取消新报价保留当前页旧报告，新的未知请求不能被旧终态放开。单镜头历史未知/仍生成时禁重复；快速成功移除原勾选，明确重选保留。视频状态独立显示，批次展示真实三类数量。原15项保留、14新增/29专属、128相关/1126全套App及analyze通过；Android/iOS实际路由/候选播放/HTTP断回执/公共KV各4项通过，30系统图和5Widget图留证。T-42旧成长等待另提交。后台/API/DDL/依赖/媒体引擎未改，真实Provider/OSS、最新Figma与物理设备仍待，整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-26/generation-recovery/README.md)。

## T-29 剪辑准备入口与缓存确认复检（2026-10-17）

准备页固定打开时的账号、环境和后台；旧清理确认不能清除新账号文件，切号即清除旧预算并停止迟到跳转。作品/集参数同时进入GetBuilder的key/tag；取消先失效原尝试、停止下载，再返回原入口，重复离开只处理一次。清理仍复用原MediaCacheScope，只清闲置和临时成片，保护有效作品源文件。

16条新增、88条相关、1160条全套App及analyze通过，0失败/跳过。Android/iOS模拟器各1个原生方法覆盖3组实际路由/HTTP/Hive/媒体场景；73352字节原视频校验与预览、固定工程离线再进、取消保留12000字节并Range续传均通过，16张系统图和4张Widget图留证。原后台证据保留，本轮未改API、DDL、依赖或原生媒体引擎；真实OSS、最新Figma和物理设备仍待联验，整项保持未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-29/entry-recovery/README.md)。

## T-30 工程身份与离开回调复检（2026-10-17）

剪辑页key/tag包含路由、作品/分集、账号环境作用域及具体本机Session；同一路由切作品/集或替换Session时释放旧Controller，普通编辑和刷新保留当前Controller。旧账号extra退回真实准备，不显示旧时间轴；暂停、写盘和离开前逐次核对current，关闭/切页后的迟到回调不能授权旧View跳转。

新增9项、303相关、1169全套App（0失败/跳过）、analyze及13文件格式通过。两端模拟器各write/recover两阶段通过：真实红横/蓝竖视频切集、独立编辑及撤销重做；确认PID后各真实终止一次，离线恢复同一UUID、head/undo/selection并继续预览。10系统图及5Widget图留证，Widget原生通道受控、设备媒体为自建样片。完整存储、媒体引擎、路由/API/DDL/依赖未改；真实OSS/Provider、最新Figma、物理设备及写入中强杀/实际磁盘故障仍待验，T-30整项未完成。[证据](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-30/session-lifecycle/README.md)。
