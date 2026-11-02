# UI性能分析报告（PERF-01）

结论：已确认返回前的同步数据处理和整块重建开销；同时复现了两类“点了没反应”：加载遮罩拦截返回，以及编辑器返回后仍显示已关闭Controller的详情。**本轮仅添加诊断代码，没有实施性能优化。**

实测对象为vivo V1981A（Android 12 / API 31，60Hz），现有账号、作品及缓存，profile构建1.0.1+101、CATDRAMA_ENV=1。诊断实现已本地提交App `b31ad26`（未推送）；采样工作区基于App `66a3085`，包含用户原有作品列表改动及版本号改动。本地开发环境不是正式发布包的验收结论。

## 1. 计时边界与证据

- 性能值来自设备内Timeline.now、FrameTiming、原生System.nanoTime和Perfetto时钟快照。ADB只触发操作/搬运日志，**没有使用命令往返、电脑时间或日志到达时间计算耗时**。
- 原生入口是Activity收到UP；Dart入口是Binding收到UP。系统返回通过原生Key UP投递与flutter/navigation消息配对。24/24次原生时钟落在Dart请求起止区间内；Perfetto与MONOTONIC的快照偏差变化为157–314ns。
- “UI完成”是目标页当前路由实际参与paint的帧构建结束；“Raster完成”是同一帧的光栅化结束，**不是屏幕物理呈现时间**。帧号和页面快照在回调前保存，批量回调迟到不按当时当前页重新贴标签。
- 阈值严格为大于16000µs，等于16ms不超标。60Hz物理帧预算约16.67ms；本报告按用户16ms阈值保留。UI、Raster、vsync等待、累计流水线、响应延迟和异步阶段分别分类，累计流水线超过16ms不能单独证明丢帧。
- 截图/界面树在响应观察后采集。全量文件仍保留探索过程和截图附带帧；主点击表使用通过页面校验的操作编号，不能把全量行数当生产卡顿率。

原始材料：[设备日志](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/raw)、[受控步骤](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/guarded-steps.jsonl)、[CPU与Timeline目录](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2)、[用例统计](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/analysis/case-metrics.csv)。原始材料仅本地保存。

## 2. 启动与恢复

冷启动为force-stop后启动Activity，缓存和账号保留；不包含从启动器点击到Activity入口之前的系统调度。每项10次，P95采用nearest-rank，小样本P95可能等于最大值。各阶段包含/重叠，不能相加。

| 设备内阶段（ms） | N | 中位数 | P95 | 最大 |
|---|---:|---:|---:|---:|
| Activity入口→Dart main | 10 | 127.42 | 791.30 | 791.30 |
| configureFlutterEngine聚合段 | 10 | 15.19 | 76.46 | 76.46 |
| Dart main→Flutter首帧Raster | 10 | 838.56 | 993.54 | 993.54 |
| Activity入口→onFlutterUiDisplayed回调 | 10 | 965.45 | 1785.24 | 1785.24 |
| 首次Flutter UI warm-up构建 | 10 | 101.46 | 110.87 | 110.87 |
| 恢复回调→首帧UI完成 | 10 | 4.45 | 12.23 | 12.23 |
| 恢复回调→首帧Raster完成 | 10 | 7.71 | 14.99 | 14.99 |

| Dart启动子阶段（ms） | N | 中位数 | P95 | 最大 |
|---|---:|---:|---:|---:|
| startup.orientation | 10 | 553.35 | 614.01 | 614.01 |
| startup.global | 10 | 148.89 | 203.65 | 203.65 |
| startup.packageInfo | 10 | 7.90 | 33.26 | 33.26 |
| startup.storage | 10 | 93.40 | 110.95 | 110.95 |
| storage.public | 10 | 26.89 | 28.27 | 28.27 |
| storage.secureSession.1 | 10 | 32.10 | 48.30 | 48.30 |
| storage.secureSession.2 | 10 | 16.47 | 16.72 | 16.72 |
| storage.secureSession.3 | 10 | 16.60 | 16.70 | 16.70 |
| startup.resourceCache | 10 | 42.06 | 58.36 | 58.36 |

方向设置的553ms是等待Future完成的阶段时长，包含平台消息排队；不能说它阻塞UI线程553ms。底层原因待定位，也没有证据承诺取消await就能节省同样时间。额外1次CPU定位启动测得413.55ms，使用本轮浏览后的缓存状态，不混入上述10次基线。

首次warm-up构建约101ms是真实同步UI阶段；首个引擎FrameTiming并不完整反映warm-up，因此额外记录了Binding.drawFrame。额外启动的main isolate中，GetStorage._readFile出现26个采样点，与缓存读取阶段相符；其余启动成本尚未定位到足以直接修改的函数。

## 3. 视频页与返回专项

分开统计分镜视频页（shots）与时间轴视频编辑器（editor）。下面均使用设备内起点；数据准备/未完成生成状态不冒充UI线程阻塞。

| 操作→目标首帧Raster（ms） | N | 中位数 | P95 | 最大 |
|---|---:|---:|---:|---:|
| 分镜页稳定后点击页面返回→作品详情 | 10 | 191.86 | 244.87 | 244.87 |
| 分镜页稳定后系统返回→作品详情（完整配对） | 7 | 159.19 | 196.40 | 196.40 |
| 刚进入分镜页就系统返回→作品列表 | 10 | 90.63 | 121.94 | 121.94 |
| 时间轴编辑器系统返回→作品详情（辅助trace） | 3 | 320.72 | 324.19 | 324.19 |
| 时间轴编辑器页面返回→作品详情（重复进入） | 4 | 304.76 | 317.16 | 317.16 |
| 分镜页打开参数设置（稳定后） | 10 | 147.03 | 175.85 | 175.85 |
| 参数设置返回分镜页（稳定后） | 10 | 92.76 | 111.93 | 111.93 |
| 打开历史视频弹窗 | 10 | 156.23 | 261.26 | 261.26 |
| 01/02分镜点击后的首个UI反馈 | 20 | 54.66 | 64.49 | 67.98 |

专项事实：

1. **刚进入分镜页点击页面返回，10/10次仍留原页**；对应截图可见loading遮罩，[CustomToast.loading](/Users/soul/code/lxwx/catdrama/lib/widgets/custom_toast.dart:152)明确设置userInteractions=false，[ShotDetailController.load](/Users/soul/code/lxwx/catdrama/lib/pages/projects/shot_detail/controller.dart:680)在初次加载期间启用它。它拦截点击，与UI帧是否超过16ms是不同问题。
2. 同阶段系统返回10/10次回到作品列表，稳定后两种返回均回作品详情。日志出现main.tab与navigation.pop，结合[back/returnWaiting分支](/Users/soul/code/lxwx/catdrama/lib/pages/projects/shot_detail/controller.dart:252)支持走了等待/失败返回分支。videoWaiting包含videoHistoryBusy；旧装机包没有当时各布尔值快照，具体触发条件仍需新回调日志确认，不能直接断言生成任务失败。
3. 稳定分镜返回时，CPU样本大量落在_videoPage、videoInProgress、current/hasSession等逐镜头状态查询。返回经过[navigate](/Users/soul/code/lxwx/catdrama/lib/pages/projects/shots/page_state.dart:47)和back中的两次endOfFrame，以及pause/flush链。7个完整系统返回窗口里，Android进程主线程在首个UI完成前累计运行109.74–150.54ms，支持实际CPU工作过重，而非ADB耗时。
4. 时间轴编辑器的重复页面返回中，Dart输入→导航提交约217–225ms，目标详情帧UI仅1.18–1.83ms。CPU栈落在[EditorProjectStore保存链](/Users/soul/code/lxwx/catdrama/lib/pages/projects/editor/logic/project_store.dart:640)、[_readLedger](/Users/soul/code/lxwx/catdrama/lib/pages/projects/editor/logic/media_cache.dart:336)、_persistSession及GetStorage编码；_readLedger每次执行jsonEncode/jsonDecode整份ledger。**主要等待发生在返回前处理，不能只看目标帧UI时间。**
5. 编辑器返回后，分集再次点击在两轮复核中被拒绝；退回列表重进恢复。VM只读对象检查显示：返回前已初始化Controller的_isClosed=false，返回后同作品已初始化实例_isClosed=true，另一个新建实例未初始化且没有project。[返回前对象快照](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/controller-before-editor-back.json)、[返回后对象快照](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/controller-after-editor-back.json)。[详情GetBuilder仅使用projectId作tag](/Users/soul/code/lxwx/catdrama/lib/pages/projects/detail/view.dart:10)、[openEpisode的canEdit守卫](/Users/soul/code/lxwx/catdrama/lib/pages/projects/detail/controller.dart:376)与[编辑器goNamed返回](/Users/soul/code/lxwx/catdrama/lib/pages/projects/editor/view.dart:1325)支持控制器归属/复用时序问题。失效现场已证实，根本修复方案仍需回归；未在关闭探针的安装包上复现，不能直接认定正式包同样存在。

分镜01/02另有实际2/19与1/19画面核对；20次压力点击表测的是首反馈，不代表20次目标分镜内容都已加载完成。新代码增加了targetState与目标paint匹配，未为它再次重装手机。

分镜稳定系统返回共执行10次，完整输入端点配对7次，其余3次仅保留导航提交后的阶段。时间轴系统返回3次的输入/导航/帧端点均可配对，但该系统trace报告6个负时间戳事件丢弃及CPU6的ftrace丢事件；表内320ms级数据只作辅助，不能据此计算完整调度分布。对应[配对明细](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/back-trace-derived.json)和原始trace均保留。

## 4. 页面响应：首次与重复分开

下表为受控点击使该页成为目标后的原生App UP→首帧Raster，单位ms。“首次”是当前采样进程首次测得，保留已有缓存，不是首次安装。重复P95仅对后续样本计算，N包含首次。表内没有样本的字段保持空缺，不填0。

| 页面/目标 | N | 首次 | 重复中位数 | 重复P95 | 全部最大 |
|---|---:|---:|---:|---:|---:|
| `accountSecurity` | 1 | 110.73 | — | — | 110.73 |
| `assetDetail` | 3 | 61.08 | 55.95 | 57.08 | 61.08 |
| `assetImport` | 1 | 50.67 | — | — | 50.67 |
| `assetNew` | 2 | 161.88 | 71.34 | 71.34 | 161.88 |
| `feedback` | 10 | 86.53 | 51.13 | 56.82 | 86.53 |
| `inviteBind` | 10 | 78.70 | 72.17 | 75.87 | 78.70 |
| `inviteMaterials` | 21 | 52.98 | 51.08 | 89.72 | 92.42 |
| `inviteRecords` | 10 | 50.84 | 49.31 | 76.45 | 76.45 |
| `main:account` | 75 | 22.95 | 49.72 | 79.01 | 83.15 |
| `main:assets` | 19 | 18.99 | 32.44 | 158.91 | 158.91 |
| `main:home` | 10 | 37.17 | 28.28 | 50.14 | 50.14 |
| `main:projects` | 23 | 17.84 | 37.62 | 55.85 | 84.83 |
| `materialWorkbench` | 3 | 92.31 | 85.40 | 86.89 | 92.31 |
| `materials` | 15 | 143.75 | 142.11 | 179.36 | 179.36 |
| `paymentOrders` | 10 | 52.15 | 52.30 | 58.38 | 58.38 |
| `pointsLedger` | 10 | 49.09 | 51.81 | 56.72 | 56.72 |
| `pointsRecharge` | 10 | 49.95 | 52.94 | 65.30 | 65.30 |
| `popup:ModalBottomSheetRoute<VideoHistoryAction>` | 10 | 160.11 | 152.34 | 261.26 | 261.26 |
| `productionSettings` | 11 | 134.44 | 147.03 | 175.85 | 175.85 |
| `projectDetail` | 55 | 36.05 | 54.16 | 301.49 | 317.16 |
| `scriptAnalysis` | 1 | 30.50 | — | — | 30.50 |
| `settings` | 23 | 80.58 | 50.88 | 62.38 | 80.58 |
| `shots` | 96 | 64.21 | 54.50 | 99.71 | 132.47 |
| `taskCenter` | 10 | 51.65 | 51.77 | 61.72 | 61.72 |
| `webview` | 10 | 247.12 | 76.02 | 86.78 | 247.12 |
| `editorPrepare`（进入准备页） | 9 | 177.18 | 96.44 | 131.16 | 177.18 |
| `editor`（含异步准备的完整进入） | 9 | 1663.39 | 1398.02 | 1460.56 | 1663.39 |

GoRouter同Page key的replaceNamed没有触发旧观察器的didReplace，因此Editor进入没有独立导航事件。上述9条editor完整进入值根据原始帧中editorPrepare→editor的首次当前页paint、对应准备动作输入、且中间没有其他输入还原；包含异步文件准备，**不是1.4秒主线程阻塞**。[派生输入/帧明细](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/editor-entry-derived.json)独立保存，CSV中以derived.editor_ready标明。原始日志没有被改写。新代码已增加RouterDelegate配置监听。

独立projects页由系统返回/程序导航触达，8条导航提交→Raster阶段中位数33.18ms、最大129.06ms；没有完整原生输入起点，不能拿它与上表点击指标直接比较。

## 5. 超过16ms的全部记录

[完整异常CSV](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/analysis/over-16ms.csv)共5279行：3256条帧记录、1470条具名同步/异步阶段、553条响应记录（包含9条明确标注的派生进入记录）。每行有页面、操作/来源/目标、操作和输入编号、帧号、UI/Raster/等待/响应时间、分类、相交CPU线索、证据级别、建议和优先级；无法确定的具体函数标“待定位”（208行）。

原始20934帧中，UI超过16ms为1233帧、Raster为150帧、vsync等待为1622帧，累计流水线为3256帧；分类重叠不能相加。存在46条未匹配动作，不能据此编造目标页耗时。[汇总JSON](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/analysis/summary.json)保留统计分母和类别。

原始旧包在短间隔系统返回时可能沿用最近一次触摸的inputId。统计器根据受控系统返回操作剔除了该错误关联，再用系统trace起点配对；保留attribution_note。schema1早期采集有页面归属问题，未纳入本报告主统计，仍留在上级本地目录。

## 6. 有证据的原因、修改方案和优先级

| 优先级 | 已有证据 | 对应修改方案（本轮未实施） |
|---|---|---|
| P1 | 视频初次加载全屏遮罩拦截返回，10/10复现 | 初始加载使用页面内状态，保留返回可用；离开时取消/失效旧加载，按页面代次关闭所属loading，防止迟到回调影响新页。 |
| P1 | 编辑器返回后已关闭的详情Controller仍被界面引用，原guard拒绝后续点击 | 以路由实例隔离详情GetBuilder的key/tag及释放归属；验证goNamed回同作品、push/pop、连续返回时旧实例不会删除/覆盖新实例。先在关闭探针的包上对照。 |
| P1 | 时间轴返回前217–225ms；ledger读/保存及GetStorage栈重复出现 | 一次保存操作复用只读ledger快照，避免每个media getter整份JSON深拷贝；选择/位置未变时跳过重复保存，按实际变化保存。保留账号作用域、版本与可靠写盘屏障。 |
| P1 | GetStorage默认盒约2.05MB，flush/备份分别全量JSON编码；主线程相交采样和多页长vsync等待反复出现 | 把大体积业务缓存从轻量KV迁出，按域/记录拆分；普通缓存合并写入，耗时编码放后台isolate。支付、凭证和幂等输入仍等待可靠持久化，不能简单删await。 |
| P1/P2 | 分镜返回期间_videoPage与逐镜头状态getter大量采样；两次endOfFrame | 收敛离开流程的帧等待和重复flush，保留失焦末次输入与可靠保存；镜头状态按版本/会话生成一次快照，横向列表按需构建，缩小Obx刷新范围。 |
| P2 | main:home帧977 UI34.864ms，CPU仍出现隐藏资产页构建；资产页帧165 UI35.111ms、visibleItems/current反复出现 | 主壳固定子页，缩小选中态刷新；一轮build只计算一次visibleItems/canCreate，避免每个网格单元重复过滤及账号状态读取；保留会话变化的失效机制。 |
| P2 | 首次UI warm-up约101ms、公共盒读取约27ms，CPU读缓存采样 | 进一步拆分启动UI与缓存解码；评估首屏前必需依赖和可延后工作。方向设置等待与原生插件聚合段先补底层证据，不承诺未经验证的节省量。 |
| P2-待定位 | 少量Raster超16ms，Dart采样不能解释GPU | 使用对应帧的引擎栅格/纹理追踪定位后再决定图片尺寸、图层或缓存调整；本轮不根据单帧猜测shader/图片根因。 |
| P3 | UI/Raster/vsync各自未超16ms但累计流水线超阈值 | 保留延迟记录，结合输入响应判断，不据此单独认定丢帧或要求修改。 |

GetStorage源码证据为[StorageImpl.flush/_madeBackup](/Users/soul/.pub-cache/hosted/pub.dev/get_storage-2.1.1/lib/src/storage/io.dart:35)。盒大小在诊断安装前约2,050,033字节，已存在于原数据，不能归因于本轮日志增长。上述方案还需实现和同数据真机复测，表中没有“已优化”的条目。

## 7. 43路由覆盖与未测清单

全部43个路由已接入诊断构建；本轮有当前页paint证据的路由为24/43，四个主导航与弹窗另列。接入代码不等于已实测全部状态。

| 路由 | 本轮设备覆盖 |
|---|---|
| `privacyConsent` | 未测：保持已同意隐私的当前数据，不重置同意状态。 |
| `privacyBrowse` | 未测：当前已同意且已登录，未切换隐私浏览状态。 |
| `main` | 四个主导航各10轮切换；恢复/点击样本另有追加。 |
| `home` | 未测独立/home别名；首页UI由main:home覆盖。 |
| `caseDetail` | 未测：首页当前没有运营案例。 |
| `creationInput` | 未测：未创建新作品或更改既有作品阶段以补齐输入状态。 |
| `storyReview` | 未测：本轮未触达处于故事确认阶段的既有作品。 |
| `storyProgress` | 未测：本轮未触达对应生成中作品；未发起生成。 |
| `screenplayReview` | 未测：本轮未触达逐集确认状态。 |
| `screenplayProgress` | 未测：本轮未触达对应生成中作品；未发起生成。 |
| `productionSettings` | 已触达并保存当前页paint/帧证据。 |
| `scriptAnalysis` | 既有失败作品只读状态，未重试生成。 |
| `projects` | 已触达并保存当前页paint/帧证据。 |
| `assets` | 未测独立/assets入口；资产主导航UI已覆盖。 |
| `assetNew` | 已触达并保存当前页paint/帧证据。 |
| `assetDetail` | 已触达并保存当前页paint/帧证据。 |
| `assetEdit` | 未测：现行详情使用行内编辑；未走工作台的独立编辑入口。 |
| `assetHistory` | 未测独立历史路由；历史视频弹窗另有10轮样本。 |
| `assetGenerate` | 未测：未启动生成/支付恢复流程。 |
| `materialWorkbench` | 已触达并保存当前页paint/帧证据。 |
| `projectDetail` | 已触达并保存当前页paint/帧证据。 |
| `episodeScript` | 未测：未进入原文修改流程，未改剧本。 |
| `materials` | 已触达并保存当前页paint/帧证据。 |
| `assetImport` | 已触达并保存当前页paint/帧证据。 |
| `shots` | 19镜头集及3镜头集；分镜/分集切换和返回专项。 |
| `shotDetail` | 未测独立兼容入口；相同ShotDetailPage通过shots路由实测。 |
| `editorPrepare` | 真实本机准备；准备等待和UI反馈分别记录。 |
| `editor` | 完整3/3集，本机时间轴进入与页面/系统返回；未修改剪辑内容。 |
| `export` | 未测：未启动导出，未进入已有结果页。 |
| `login` | 未测：保持当前登录状态。 |
| `paymentWebPay` | 未测：现有订单已关闭，未创建/支付订单。 |
| `taskCenter` | 已触达并保存当前页paint/帧证据。 |
| `paymentOrders` | 已触达并保存当前页paint/帧证据。 |
| `redeemCode` | 未测：本轮当前导航未触达兑换入口。 |
| `pointsRecharge` | 已触达并保存当前页paint/帧证据。 |
| `pointsLedger` | 已触达并保存当前页paint/帧证据。 |
| `inviteBind` | 已触达并保存当前页paint/帧证据。 |
| `inviteRecords` | 已触达并保存当前页paint/帧证据。 |
| `inviteMaterials` | 已触达并保存当前页paint/帧证据。 |
| `settings` | 已触达并保存当前页paint/帧证据。 |
| `accountSecurity` | 只打开账号安全页，未提交注销。 |
| `feedback` | 已触达并保存当前页paint/帧证据。 |
| `webview` | 仅测Flutter容器/标题首帧；正文为空白/加载状态，原生网页正文完成未测。 |

部分资产图片处于不可读状态，覆盖的是现存UI状态；两集已存在视频用于真实预览/剪辑准备。没有生成新视频、支付、签到、绑定、提交表单、修改剧本/素材、裁剪保存或导出；正常页面加载和剪辑准备产生的缓存保留。没有清缓存、清数据、重新登录或重置隐私状态来凑覆盖。

## 8. 代码交付与验证边界

- 默认关闭：`--dart-define=CATDRAMA_PERF=true`才安装Binding/帧订阅/写日志worker及原生通道；不新增监控平台或第三方依赖。路径见[performance.dart](/Users/soul/code/lxwx/catdrama/lib/utils/performance.dart)、[路由适配](/Users/soul/code/lxwx/catdrama/lib/routes/performance.dart)、[原生探针](/Users/soul/code/lxwx/catdrama/android/app/src/main/kotlin/com/lxwx/catdrama/PerformanceProbe.kt)。
- JSON编码/追加文件在独立isolate，UI采集回调不逐帧同步打印或写盘；原生输入日志仅按输入事件记录。工作区原有列表代码与版本号改动保留，未做业务优化、后端改动或部署。
- 真机采样包为schema2，SHA256 `cc34a772c060567e17d691d4f409ae3456d1ea404dd89a532f6d7eb21fdc4e83`。按“不再重装”的后续约束，schema3新增的系统返回新输入编号、同Page key配置更新、目标分镜状态帧及回调/guard字段只做了自动检查与构建，**没有在手机上安装验证**。
- schema3诊断ON：18项Dart专项通过；Python汇总6项通过；静态检查无问题。默认分支回归156通过、1跳过。编辑器专项26通过、2失败；在隔离的未加探针基线（保留原列表/版本改动）得到同样26通过、相同2个失败，均为旧时间文本`00:00.000/00:01.000`断言不匹配。见[基线对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/validation-baseline-comparison.json)，不记作全部测试通过。
- ON/OFF profile包完成构建；**没有做vivo开关关闭对照**，无法量化采集本身额外开销，也没有证明诊断包的生命周期问题在原发布包同样发生。未测iOS、release、真实支付/生成渠道及所有业务状态。

复算命令（所有输入材料仅本地）：

```sh
python3 /Users/soul/code/lxwx/catdrama/tool/performance_report.py \
  --logs "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/raw" \
  --cpu "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2" \
  --native "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/native-log.jsonl" \
  --startup-manifest "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/sample-manifest.json" \
  --steps "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/guarded-steps.jsonl" \
  --back-events "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/back-trace-derived.json" \
  --supplement "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/supplemental-rows.json" \
  --out "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/ui-performance-20261101/v2/analysis"
```

API定义以[Flutter帧耗时](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html)、[FrameTiming](https://api.flutter.dev/flutter/dart-ui/FrameTiming-class.html)、[Dart单调时钟](https://api.dart.dev/dart-developer/Timeline/now.html)为依据；profile真机边界见[Flutter性能分析](https://docs.flutter.dev/perf/ui-performance)。
