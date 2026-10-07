# 钢琴视奏回归缺陷修复与复测

变更：CHG-20261004-FULL-REGRESSION。用户已批准实施；2026-10-04 实施，2026-10-05 收尾。本地修复与复测 done，QA15 供用户审核，本报告不代替发布验收。

## 范围与基线

- 代码工程：`/Users/soul/code/soul/Solfeggio`。流程文档唯一根目录：`/Users/soul/work/MakeCodePlanWord/projects/钢琴视奏`，写入前已 resolve/check。
- 已加载工作台核心、Flutter 索引、测试/QA/构建规则，以及前端自身工作流程、UI、GetX、路由和对应模块计划。运行既有 Java QA 夹具前也加载了后端工作流程，但不修改后端。
- [2026-10-02 原报告](full-regression-2026-10-02.md)及其 1188 通过 / 9 失败 / 1 跳过、旋转失败与等级差异证据完整保留。批准实施时五文件基线为 501 通过 / 7 失败，FULL-004/006 已通过。
- 当前工作树还有其他反馈音效、国际化等已有增量，所以最终全量数量与旧报告不同，不能把数量增长全部算成本轮新增用例。
- 后端实际路径仍为 `/Users/soul/code/soul/service`；接口、数据库字段、支付商品、会员规则、正式服务和用户真机均不改动。未暂存、提交、购买或发布；会员 UI waiting_review 和 T-F012 保持原状态。

## 逐项修复

| 编号 | 处理及验证 | 结果 |
|---|---|---|
| FULL-001 | C 音装饰标签 IgnorePointer；原 C4/E4/G4 点击位置不移动，覆盖白键中心、标签中心、黑键中心及连续和弦判对后推进 | 通过 |
| FULL-002 | 宽屏减少装饰留白；紧凑屏、英文/大字体将操作与全宽进度分行；末题 20/20 覆盖三语、1×/2×。反馈标题可换行，大字体反馈区限高滚动且保留琴键 | 通过 |
| FULL-003 | 真正溢出节点在权限弹框下方的设置页。大字体标题随正文滚动；按钮按文字增高，安全区底栏按父约束限高、独立滚动。既有权限弹框自身已有滚动，不改权限流程 | 通过 |
| FULL-004 | 保留已修会员文案测试和当前收费边界，不恢复旧文案或待审 UI | 通过 |
| FULL-005 | 以初始 revision 为基线，验证切换开始/提交完成两次修订，旧 revision 响应不能覆盖当前账号 | 通过 |
| FULL-006 | 保留已有清理并加强 teardown + finally；即使断言失败也在 Widget 定时器检查前释放同步服务 | 通过 |
| FULL-007 | 手机/钢琴通过真实启动入口建立 owner，实际 MIDI 测试事件完成全部目标，再验证结果、历史和回栈；新增两模式空会话无结果/无历史，保留钢琴零答题/部分中断反向断言 | 通过 |
| FULL-008 | 全部、免费、继续、收藏与搜索/难度组合均保留关键结果断言，不恢复已移除会员筛选 | 通过 |
| FULL-009 | 手机练习免费；受限钢琴入口会员提示、MIDI 硬件说明、会员页和返回详情逐段验证；以上等级缺口不转支付 | 通过 |
| FULL-010 | 两页共用 AchievementGoalService 当前账号已通过等级，未通过 Lv0。展示与 SongAccessPolicy 访问最低 Lv1 分离；初始化、升级、同步、切号、游客、离线、旧值迁移、重建及原生进程重启覆盖 | 通过 |
| FULL-011 | 底栏三项 Expanded；首页空周统计按内容增高、装饰柱按约束缩放，入口按实际文字高度计算；会员窄横排采用既有紧凑布局。保持 ScreenUtil 375×812，隐藏主页面与转场异常不屏蔽 | 通过 |

全量还发现一个现有和弦历史重试夹具未建立 session owner。仅改测试经真实 startSession 启动，保留空历史、写入失败、重试次数、完成日期断言，未放宽生产归属保护。

## 资源与布局

本轮没有搬动/替换切图，没有新增整页截图 UI。和弦继续引用 `assets/images/chord_practice_background.png`、`chord_practice_back.png`、`chord_practice_usb.png`、`chord_practice_progress.png`、`song_phone_pause.png` 和 `song_phone_next.png`。首页/设置原背景、入口图标与其他旧资源全部保留。

| 验证面 | 实际覆盖 |
|---|---|
| 设置与 scene 26 | 320×568、375×812、430×932 原竖屏矩阵；新增 568×320、932×430、1024×768，均 zh/zh_TW/en × 1×/2×。滚动关闭权限弹框后，恢复默认按钮仍可命中 |
| 和弦 | 原手机/平板布局及 C4/E4/G4；新增 568×320、932×430、1024×768 × 三语 × 1×/2×，检查末题暂停/进度段落无截断、无布局异常；刘海左右 44/59、底部 21 |
| 隐藏首页与底栏 | 覆盖路由遮住主页面后逐段切换 568×320、932×430、320×568、1024×768、375×812；三语 × 1×/2×；返回后 Tab 仍可点击 |
| 账号等级 | Lv0、4、7、同步防降级、注册 A/B 切换、新本地游客/服务端游客、离线加载失败、旧数据仅迁入首次 owner、Controller 重建；两页与既有内容访问分别断言 |

“我的”保持现有未登录隐藏等级徽章的规则，本轮不改资料页可见性。原生可见标签证明使用本机隔离 QA 游客登录；未登录/本地游客的数值一致性由自动化断言覆盖。

## 自动化与构建

所有日志在 [新证据目录](evidence/full-regression-fix-2026-10-04/)，旧失败记录不覆盖。

| 命令/批次 | 当前结果 | 证据 |
|---|---|---|
| 首轮受影响九文件 | 611 通过 | affected-modules.log |
| 设置最终全文件 | 416 通过，含新增 18 个横屏/平板组合及操作可达性 | settings-accessibility-complete.log |
| 和弦最终矩阵 | 5 通过；一个用例循环 18 个字体/语言/尺寸组合 | chord-accessibility-final.log |
| 首页/历史最后补充 | 60 通过，含两模式空会话反向用例 | home-history-final.log |
| 账号等级加严复跑 | 4 通过；在显式 reload 前断言两页自动刷新，退出后即时 Lv0 | level-consistency-final.log |
| Flutter 最终全量 | exit 0；1388 通过 / 0 失败 / 1 既有条件跳过 | flutter-full-serial.log |
| 内部 simple_sheet_music | 65 通过 | sheet-music-complete.log |
| scoped analyze（lib/test/integration_test） | exit 0；0 error，1 warning/2 info 存量 | analyze-scoped-complete.log |
| root analyze，允许存量 warning/info | 最终 exit 0；0 error，1 warning/2 info；早轮额外生成目录告警另留日志 | analyze-serial.log；analyze-accepted.log |
| 严格 root analyze | 最终 exit 1；同上 3 条存量，不能记“全通过”；早轮 4 条记录保留 | analyze-strict-serial.log；analyze-strict-complete.log |
| Android Debug | 最终串行 exit 0，APK 生成且保留 | android-debug-serial.log |
| iOS 主入口 Debug | 独立 QA DerivedData 构建 exit 0，BUILD SUCCEEDED；标准目录缓存失败另留证据 | ios-isolated-debug-final.log；ios-main-complete.log |
| iOS 原生旋转/中断/等级 | 完整流程通过，包含所有无异常/无误计完成/断点断言 | ios-native-complete.log |
| iOS 同一安装进程重启 | 通过，直接断言两页可见 Lv4 标签，测试后退出 QA 游客 | ios-restart-complete.log |

既有跳过项为 `live_song_membership_contract_test.dart`：需要 Java 专项注入 PIANO_CONTRACT_* 合成账号与临时 READY 曲谱，常规 Flutter 全量不提供该环境；未新加 skip，原失败项没有跳过。

最终 3 条存量分析结果：`lib/pages/practice/view.dart` 的 `_buildCurrentTargetPill` 未用；`test/solfeggio_sync_service_test.dart` 两处 if 缺花括号。早轮另有 `build/visual_qa/piano_practice/pixel_comparison_test.dart` 的 dart:io 未用，生成目录失效后未再出现，早轮 4 条日志仍保留。未为静态检查主动清理用户产物或无关源文件。

## 原生证据

专用 iPhone 13 / iOS 26.4：`692A31F4-A36B-43A2-94CE-D3944565345A`。真实 MyApp 路由和服务；唯一 HTTP 目标 `127.0.0.1:31090`，其他域名在测试中阻断；既有 AccountQaServer 使用 test profile 和内存 H2，不连正式库、不执行购买。

1. 拒绝协议仍可回首页；协议前练习路由受守卫拦截，空进度目标为 0/5。
2. 首页进入原生横屏音符练习，零答题后取消停止保留 playing / 第 1 题；确认停止回首页并等待真实竖屏视口。
3. 全阶段保留无 Flutter 异常断言；无完成页、历史数量不变、断点不为空。稳定帧截图检查布局不拉伸。
4. 本地 QA 游客登录后升级到 Lv4，两页不仅控制器数值一致，可见文本也分别断言。
5. 使用 `--keep-app-running` 保留同一安装，simctl terminate 后重新启动测试；不重新写入等级，验证持久化 Lv4 并截图，最后退出 QA 身份。

最终图：

- [取消停止](evidence/full-regression-fix-2026-10-04/ios-native-complete/native-stop-cancel.png)、[确认停止](evidence/full-regression-fix-2026-10-04/ios-native-complete/native-stop-confirm.png)、[恢复竖屏且无误计完成](evidence/full-regression-fix-2026-10-04/ios-native-complete/native-after-interruption.png)。
- [重启后的“我的” Lv4](evidence/full-regression-fix-2026-10-04/ios-restart-complete/native-restarted-profile-level4.png)、[重启后的首页 Lv4](evidence/full-regression-fix-2026-10-04/ios-restart-complete/native-restarted-home-level4.png)。

原生复跑命令：在前端目录设置 SOLFEGGIO_QA_SCREENSHOTS 为新证据子目录，执行 `flutter drive --no-pub --keep-app-running --driver=test_driver/full_app_smoke_driver.dart --target=integration_test/full_app_smoke_test.dart -d 692A31F4-A36B-43A2-94CE-D3944565345A`；进程重启追加 `--no-build`。最终 20 张原生图和 2 张重启图，共 22 张。没有操作用户 iPhone 或其他模拟器。

iOS 最终构建命令为 `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/solfeggio-regression-qa-20261004-deriveddata CODE_SIGNING_ALLOWED=NO build`。产物 `/tmp/solfeggio-regression-qa-20261004-deriveddata/Build/Products/Debug-iphonesimulator/Runner.app`，编译入口仍为 lib/main.dart，不是集成测试入口；此构建不包含真机签名或 Archive 验收。

Android 最终产物 `/Users/soul/code/soul/Solfeggio/build/app/outputs/flutter-apk/app-debug.apk`，SHA-256 `7e08f86d1c5dbe179da4f5b357f567e3d81f2282f4194a090de030766d8cc473`。iOS Runner 可执行文件 SHA-256 `157e5a2ccedbb230d38fe41a46ea795c2d88a2b005b905cf8b552a0e484bad5c`，仅用于本轮构建识别，不代表整个 App 的哈希或 Dart 内容校验。

## 过程失败与恢复

- 最初新增大字体矩阵发现和弦反馈标题、末题进度及设置安全区底栏问题，持续修正并保留 accessibility/chord/settings 中间失败日志，未删关键断言。
- `ios-native-final/` 的早期旋转图有尚未稳定的图层，未登录资料页也没有可见等级。改为等待弹框动画/方向稳定、断言按钮可命中，并使用隔离 QA 游客补可见等级验证；以 `ios-native-complete/` 和 `ios-restart-complete/` 为最终图，不把早期图当通过图。
- 最后一次同时构建/测试期间，出现 Xcode `XCBuildData/build.db: disk I/O error`，随后包配置 `.dart_tool/package_config.json` 缺失、图片/着色器资源缓存不可读。源图仍在，磁盘约 111 GiB 可用；不能据此判定磁盘损坏或业务回归。受影响轮日志为 flutter-full-accepted.log，未作为验收结果。
- 使用普通 `flutter pub get` 恢复生成元数据，pubspec.lock 无 diff；未清理既有 DerivedData、用户资源或脏文件。最终串行测试 1388/0/1。独立 iOS 构建还发现 Pods/Manifest.lock 缺失，执行 `pod install --deployment` 恢复既有锁定依赖，两个 lock 文件均无源码 diff；保留该失败与后续构建日志，不跳过 Pods 校验。

## 收尾与未验收

- 专用 31090 QA 服务已正常中断退出，端口无监听；本轮专用模拟器已关闭，未抹除数据。8081 当前无监听，未对其执行启动/停止操作，不声称既有服务健康检查通过。
- iOS 生成配置已恢复 `FLUTTER_TARGET=lib/main.dart`；最终双端 Debug、16 个本轮 Dart 文件格式检查（0 改动）、前端/工作台 git diff --check 与路径 audit 通过。新增文件另做 whitespace 检查，无错误。锁文件未改，既有 iOS/Android 源文件与未跟踪音效文件保留；本轮没有主动清理或回滚用户文件。
- 不关闭完整 109 条人工验收，不证明实体 MIDI 丢音/响应、真机旋转、真实 Apple/Google 商店购买/恢复、OAuth、OMR/OSS、生产同步/网络、性能或发布合格。待审会员 UI 与 T-F012 继续独立处理。
