# 钢琴视奏全量回归执行报告（2026-10-02）

状态：**测试执行完成，未全通过（waiting_review）**。用户授权测试当前前后端工作树；本轮不等同发布验收。

结论：Flutter 主工程 1188 通过 / 9 失败 / 1 条件跳过；9 个失败均串行复现。Java 402 条中最终 399 通过 / 3 外部条件未执行 / 0 失败。内部乐谱包 65、前端 Python 工具 19、后端脚本 9 通过；Android / iOS 主入口 / service / Worker 构建通过。双模拟器账号四段通过；新增原生回归的页面/数据断言通过，但旋转布局异常导致整条集成测试失败且重启复现。另有真机等级口径差异待确认。109 条人工用例和真实商店等未全验收，不进入发布。

## 范围与执行计划

项目工作区：`/Users/soul/work/MakeCodePlanWord/projects/钢琴视奏`。前端：`/Users/soul/code/soul/Solfeggio`；后端：`/Users/soul/code/soul/service`。当前步骤为 15 联调与测试 QA，两工程规则已加载。现有待审核会员 UI、T-F012 和独立未闭合任务保留原状态。

数据库结构改动：无。自动化使用测试内存库或隔离测试环境；不连接生产数据库执行测试写入。设备个人数据、已有登录和代码改动保留。

| 层级 | 执行内容 | 状态 |
| --- | --- | --- |
| Flutter 自动化 | 全部 `test/`、内部乐谱包测试、静态分析、权限配置同源检查 | 已执行：1188 通过 / 9 失败 / 1 条件跳过；乐谱包 65 通过；失败串行复现 |
| Java 自动化 | 强制重新执行全部 Gradle 单元与集成测试，核对跳过项和失败原因 | 已执行：402 条，补真实 MIDI 后 399 通过 / 3 未执行 / 0 失败 |
| 构建验证 | Android Debug、iOS 模拟器 Debug、服务与 Worker 打包检查 | Android / iOS 主入口 / service / Worker 构建通过；不作为正式发布验收 |
| 真实本地 HTTP | Flutter→Java 权限契约；隔离测试账号注册、退出、升级及双客户端数据隔离 | 权限契约、四段账号 E2E 与保留安装数据的重启通过；Google 使用测试 provider |
| 页面与状态 | 启动、协议、导航、练习与中断、曲库、设置、进度、支付门禁；保存截图与设备日志 | Android 只读抽检已执行；iOS 页面/状态断言通过，增加竖屏恢复等待后捕获 3 处布局异常，原生整条测试失败 |
| 外部条件验收 | 实体 MIDI、真实 OAuth、商店购买/恢复/续订、真实 OMR、最低版本设备 | pending（缺实体琴、真实提供方/商店环境确认及对应设备验收） |

依据：`manual-test-cases.md` 的 109 条人工用例、当前技术契约与实际实现。自动化、模拟器、实体设备、真实支付分别报告，不用单元测试结果代填人工通过。

## 环境与证据

原始日志目录：`evidence/full-regression-2026-10-02/`。执行时记录 Git HEAD、脏文件基线、工具与设备版本、测试数量和命令退出码。

| 项目 | 本轮环境 |
| --- | --- |
| App 源码 | `/Users/soul/code/soul/Solfeggio`；HEAD `0f7bcdbe24a17aae9498fedb498103542dd4af7b`，含用户现有未提交支付/歌曲手机练习改动；版本 `2.1.0+210` |
| 服务源码 | `/Users/soul/code/soul/service`；HEAD `8a1548772143e3a8096eff1a891aa0566335b651`；原有 `docs/google-play-local-testing.md` 修改保留 |
| 工具 | Flutter 3.41.6 / Dart 3.11.4；OpenJDK 21.0.9；Xcode 26.6（17F113） |
| 本地 HTTP | 专用账号 QA `http://127.0.0.1:31090`，内存 H2；已有用户服务 `127.0.0.1:8081` 不停服、不重启、不写入测试数据 |
| iOS | 新建两台 iPhone 13 / iOS 26.4 专用模拟器，分别执行 writer / reader / verify-reader / guest-upgrade；Google 为确定性测试 provider |
| Android | Pixel / Android 10 / API 29，既有安装包 `com.soul.solfeggio`、`2.1.0 (210)`；保留真实登录/历史，仅页面抽检，不重装、不购买、不练习结算 |
| 其他设备 | 已检测到实体 iPhone，但未在其上执行用例；不能将模拟器结果计为 iPhone 真机通过 |

Android 已安装包的源码快照未确认与本轮工作树完全一致；本轮新 APK 的构建成功与旧安装包页面抽检分别统计。测试进程、商店商品显示、网络连接均不是生产部署或真实交易证明。

## 执行结果

原始 `flutter analyze --no-pub` 失败：52 个 error 均来自既有 `build/song_phone_render_qa/original_practice_melody_staff.dart` 孤立源码副本。仅分析 `lib test integration_test tool` 无 error，仍有 1 warning / 2 info；不删除用户既有构建目录来隐藏原始结果。内部乐谱包 65 条、Python 工具 19 条和权限配置同源检查均通过。

账号测试命令需使用 `flutter drive --keep-app-running`。本机 Flutter SDK 的 `flutter test` 以及默认 `flutter drive` 均在结束时卸载 App；初次 verify-reader 的空数据失败因此不能判定为 App 重启丢数据。保留最初失败日志，使用新的隔离身份与保留安装数据的驱动重新执行，并以最终证据判定。

### 自动化与构建

| 检查 | 命令 / 结果 | 证据 |
| --- | --- | --- |
| Flutter 全量 | `flutter test --no-pub --reporter expanded`；1188 通过、9 失败、1 跳过；退出 1；通过率 99.25%（跳过不计） | [全量日志](evidence/full-regression-2026-10-02/flutter-test.log) |
| 失败独立复现 | 五个测试文件、按失败名称筛选，`--concurrency=1`；17 通过、同 9 失败；退出 1，不是并行偶发失败 | [复跑日志](evidence/full-regression-2026-10-02/flutter-failures-retest.log) |
| 内部乐谱包 | `packages/simple_sheet_music` 下 `flutter test --no-pub --reporter expanded`；65 通过 | [日志](evidence/full-regression-2026-10-02/sheet-music-test.log) |
| 前端工具 | `python3 -m unittest discover -s test -p '*test.py'`；19 通过 | [日志](evidence/full-regression-2026-10-02/python-tool-tests.log) |
| 权限同源 | `python3 tool/sync_song_access_policy.py --check`；匹配后端固定配置，未改写配置 | 执行输出：`Song access policy matches backend source` |
| Java 全量 | `./gradlew test --rerun-tasks --console=plain`；91 个 suite / 402 条；398 通过、4 跳过、0 失败/错误 | [日志](evidence/full-regression-2026-10-02/java-test.log)、[逐例快照](evidence/full-regression-2026-10-02/java-results.json) |
| 实际 MIDI 文件 | `RUN_SCORE_IMPORT_E2E=true`，指定曲库 `L2-01_beethoven_fur_elise_woo59.mid`，运行 `ScoreImportRealFixtureTest.parsesRealMidiIntoPracticeScore`；1 通过 | [日志](evidence/full-regression-2026-10-02/real-midi-import-test.log) |
| 后端脚本 | `python3 .local/prod/tests/test_prod_db_migrate.py`；9 通过；命令桩和临时目录测试，不操作真实服务器/数据库 | [日志](evidence/full-regression-2026-10-02/migration-script-tests.log) |
| Android Debug | `flutter build apk --debug --no-pub`；退出 0；未安装到用户 Pixel | [日志](evidence/full-regression-2026-10-02/android-build.log) |
| iOS 主入口 Debug | `flutter build ios --simulator --debug --no-pub`；退出 0，主入口构建通过；最终恢复正常主入口产物，测试入口构建与正式入口分开记录 | [首轮](evidence/full-regression-2026-10-02/ios-main-build.log)、[最终恢复](evidence/full-regression-2026-10-02/ios-main-build-restored.log) |
| Java / Worker | `./gradlew build -x test scoreWorkerZip --console=plain`；退出 0；未部署 | [日志](evidence/full-regression-2026-10-02/java-build.log) |
| 新测试入口 | `dart format` 两个新增 Dart 文件；仅分析新增集成测试/驱动，无 issue | [日志](evidence/full-regression-2026-10-02/native-test-analyze-final.log) |

真实 MIDI 补测属于原 402 条之一，因此后端唯一用例最终为 **399 通过 / 3 未执行**，不能累计成 403 条。仍未执行的是真实图片/PDF Audiveris 识别及私有 OSS 云端传输。Gradle 后续定向运行会覆盖 `build/test-results`，全量原始逐例结果已单独保存。

Flutter 跳过项为 `live_song_membership_contract_test.dart` 的条件用例；Java 全量中的 `SolfeggioPracticeMembershipIntegrationTests` 已启用实际 Flutter→Java HTTP 契约（随机端口、测试身份）。这不是对线上服务的契约验收。

全量已覆盖当前支付映射/补单、歌曲手机布局/渲染缓存、个人曲谱缓存等测试文件，但缓存离线/弱网、商店凭证、实际音频/MIDI 仍需设备和提供方验收。下面的失败项没有被删掉、改成跳过或降低断言。

### 静态分析

- 根目录 `flutter analyze --no-pub`：退出 1，52 个 error 来自既有构建目录孤立 Dart 副本；另外 1 warning、2 info。证据：[原始分析](evidence/full-regression-2026-10-02/flutter-analyze.log)。
- `flutter analyze --no-pub lib test integration_test tool`：0 error / 1 warning / 2 info，仍退出 1。证据：[源码分析](evidence/full-regression-2026-10-02/flutter-source-analyze.log)。
- 存量 warning：`lib/pages/practice/view.dart:627` 未使用 `_buildCurrentTargetPill`；info：`test/solfeggio_sync_service_test.dart:110,142` 大括号风格。没有通过删除用户构建文件或关闭检查掩盖这些结果。

### 真实本地 HTTP

手工只读 HTTP 检查均在专用 H2 服务执行：不传 `X-App-Code` 的商品查询返回 400；`X-App-Code: solfeggio` 的商品查询返回 200、三档会员商品；未授权会员状态和订单入口分别返回 401。无订单创建/确认请求。证据：[HTTP 结果](evidence/full-regression-2026-10-02/local-http-readonly.json)。

### 双 iOS 模拟器账号 E2E

最终四段使用全新隔离身份 `qa_persist_20261002`，四次命令均退出 0。每段之间先终止 App 进程，不卸载；实查 App 数据容器仍存在，再执行下一段。测试在真实 Flutter 页面与本地 Java HTTP 服务间运行，并保存 18 张最终截图。记录由测试夹具写入，不等于真实答题或真实 OAuth。

| 角色 | 验证结果 | 证据 |
| --- | --- | --- |
| A writer | 未知用户名登录不自动注册；注册绑定当前本地账号；首次退出建立空白账号；登录原云账号后退出恢复本地记录/设置，互不串数据 | [日志](evidence/full-regression-2026-10-02/persisted-writer.log) |
| B reader | 同账号拉取 A 云记录；B 本地记录不混入；新增云记录上传；退出恢复 B 原本地记录 | [日志](evidence/full-regression-2026-10-02/persisted-reader.log) |
| A verify-reader | 进程重启后本地记录仍在；登录后可拉取 B 上传记录；云数据与未绑定本地数据隔离；退出恢复原本地 | [日志](evidence/full-regression-2026-10-02/persisted-verify-reader.log) |
| A guest-upgrade | 游客恢复；升级不换账号、不丢记录；升级旧凭证清理；退出/新游客隔离；模拟断网退出后排队撤销、离线登录不切换本地、恢复网络后补发撤销 | [日志](evidence/full-regression-2026-10-02/persisted-guest-upgrade.log) |

复跑命令模板（按角色串行，设备 A/B 如上）：

```sh
SOLFEGGIO_QA_SCREENSHOTS='<本报告 evidence 绝对目录>/ios-account-persisted' \
flutter drive --keep-app-running --no-pub \
  --driver=test_driver/full_app_smoke_driver.dart \
  --target=integration_test/account_auth_test.dart -d '<模拟器 UUID>' \
  --dart-define=ACCOUNT_QA_USERNAME=qa_persist_20261002 \
  --dart-define=ACCOUNT_QA_ROLE='<writer|reader|verify-reader|guest-upgrade>'
```

截图示例：[注册绑定](evidence/full-regression-2026-10-02/ios-account-persisted/writer-bound-current.png)、[重启后云同步](evidence/full-regression-2026-10-02/ios-account-persisted/writer-pulled-reader-record.png)、[游客升级](evidence/full-regression-2026-10-02/ios-account-persisted/guest-upgrade-kept-account.png)、[离线退出](evidence/full-regression-2026-10-02/ios-account-persisted/offline-logout-pending-revocation.png)。最初卸载型 runner 的实验日志另存 `e2e-*.log` / `drive-*.log`，不作为最终数据丢失缺陷，也不和最终四段重复计数。

### iOS 主 App 原生冒烟

新增 `integration_test/full_app_smoke_test.dart` 使用真实 `MyApp` 与生产路由/服务，Dart HTTP 只允许本地 QA 地址，其他请求通过无服务代理阻断。使用专用第三台 iPhone 13 模拟器 `692A31F4-A36B-43A2-94CE-D3944565345A`，没有个人账号；不购买、不真实 OAuth。隐私/教学标记的后段设置只是隔离夹具，不代表真实同意或完成教学。

执行观察：启动拒绝协议保留首页；未同意直达练习被守卫拦截；三 Tab 可达；空目标为 5；练习/音符/音效/语言设置、帮助、关于、MIDI、曲库、会员、登录等 10 个真实页面能打开且对应阶段无布局异常。零题停止后取消仍保留题号，确认停止返回 MainPage、不生成成绩/记录且保留断点，这些**状态检查点通过**。

首轮脚本直接 `goNamed` 替换根路径，退出时报 `There is nothing to pop`；已按生产首页的 `pushNamed` 入栈方式修正测试。随后遇到同目录其他 iOS Archive 在运行，生成入口被改为 `lib/main.dart`、缺少 Flutter 模块，等待该任务自行完成后构建正常恢复；没有停止别人的打包，也没有 `flutter clean` 或删除用户构建资料。上述试验日志均保留，不用作最终业务缺陷。

仅检查路由/数据以及转场结束时的前两次复跑曾通过，但画面仍在横屏，不能视作完整方向恢复验收。最终测试增加最多 10 秒等待真实竖屏视口；尺寸和上述状态检查通过，但旋转阶段产生首页/底栏 3 处 RenderFlex overflow，末尾无异常断言失败，故**本原生集成用例整体失败**（FULL-011）。不丢弃该断言或使用较早的绿色日志覆盖最终结果。

最终证据：[原生含竖屏等待日志](evidence/full-regression-2026-10-02/native-app-smoke-portrait.log)、[退出截图](evidence/full-regression-2026-10-02/ios-native-portrait/native-after-interruption.png)、[协议](evidence/full-regression-2026-10-02/ios-native-portrait/native-privacy.png)、[空进度](evidence/full-regression-2026-10-02/ios-native-portrait/native-empty-progress.png)、[会员页](evidence/full-regression-2026-10-02/ios-native-portrait/native-payment.png)。每轮 16 张截图分别存储；中间 `ios-native*` 转场/未等待方向的图是参考证据，不当最终视觉通过图。

复跑命令：在前端目录，设置 `SOLFEGGIO_QA_SCREENSHOTS` 指向独立证据目录，执行 `flutter drive --keep-app-running --no-pub --driver=test_driver/full_app_smoke_driver.dart --target=integration_test/full_app_smoke_test.dart -d '<专用模拟器 UUID>'`。未操作真实 iPhone；这些检查只对应 109 条用例的部分子预期，不代填整条人工通过。

### Android 已安装包抽检

- 首页、进度、我的、练习设置、MIDI 设备、会员页、全部/免费曲库、歌曲详情、我的曲谱、曲谱导入入口均已打开；没有保存设置或修改账号数据。
- Google Play 页显示月/季/年商品与商店美元价格；未勾选协议时点击开通未调起支付。没有发起真实购买、恢复、续订或权益结算，故不将 PAY-001～008 全量判为通过。
- 免费筛选显示四首体验曲。歌曲详情试听时间从 `0:00` 推进到 `0:21`，暂停后显示 `0:40` 和播放按钮；这里只验证 UI 和时间轴，不证明声学输出、音质或低延迟。
- 我的曲谱真实空态可显示；没有上传文件，也不表示已验证系统文件选择、识别、持久缓存或离线内容。
- MIDI 页可列出 Android native 外设端口，未连接实体钢琴；不能视作实体 MIDI 输入通过。
- 当前进程缓存日志出现一次 `Skipped 37 frames`，未匹配到 FATAL / ANR；未限定完整性能采样窗口，不能据此判为无 ANR、性能通过。

关键截图：[首页](evidence/full-regression-2026-10-02/pixel-home.png)、[我的](evidence/full-regression-2026-10-02/pixel-initial.png)、[进度](evidence/full-regression-2026-10-02/pixel-progress.png)、[设置](evidence/full-regression-2026-10-02/pixel-practice-settings-loaded.png)、[支付](evidence/full-regression-2026-10-02/pixel-payment.png)、[免费曲库](evidence/full-regression-2026-10-02/pixel-free-catalog.png)、[歌曲详情](evidence/full-regression-2026-10-02/pixel-song-detail.png)、[播放](evidence/full-regression-2026-10-02/pixel-score-playing.png)、[暂停](evidence/full-regression-2026-10-02/pixel-score-paused.png)、[我的曲谱](evidence/full-regression-2026-10-02/pixel-personal-scores.png)、[导入入口](evidence/full-regression-2026-10-02/pixel-import-entry.png)、[运行日志](evidence/full-regression-2026-10-02/pixel-runtime-findings.log)。点击后尚未完成转场的 `pixel-practice-settings.png` 不作为设置页证据。

## 缺陷与未覆盖项

### 9 个可重复失败

以下均在全量和串行定向测试各复现一次。本轮为测试授权，只登记未修改业务或既有测试断言。

| 编号 | 优先级 / 归类 | 复现位置与实际结果 | 后续处理 |
| --- | --- | --- | --- |
| FULL-001 | P2 / 界面点击缺陷候选 | `test/chord_practice_visual_qa_test.dart:154`：小屏安全区下点击 C4/E4/G4，实际仅 `[64,67]`；C4 命中装饰文字而未命中 WhiteKey，日志有 hit-test missed | 核查标签遮挡与琴键点击区域，补原生紧凑横屏复测；不能直接推断实体 MIDI 丢音 |
| FULL-002 | P2 / 界面截断 | 同文件 `:201`：932×430、左右安全区 59、底部 21，和弦进度文字 `didExceedMaxLines=true` | 调整约束/排版后复跑各语言、紧凑横屏 |
| FULL-003 | P2 / 界面溢出 | `test/recheck_20_layout_test.dart:161`：scene 26（麦克风权限弹框），320×568、英文、2 倍文字，底部溢出 5.7px | 修复弹框可滚动/高度约束并复跑字体与尺寸矩阵 |
| FULL-004 | P2 / 旧文案断言 | `test/settings_page_layout_test.dart:195` 仍查找“解锁高级歌曲完整练习”，当前文案/会员边界已改变 | 按现行业务与获准 UI 基线更新测试，不能恢复旧付费规则来过测 |
| FULL-005 | P2 / 会话计数断言 | `test/payment_contract_test.dart:57` 期望 sessionRevision=1，实际=2；此前游客/已注册判定断言通过 | 明确修订次数契约；不能仅凭次数差判为游客误注册 |
| FULL-006 | P2 / 测试生命周期 | `test/home_history_page_test.dart` 手机完成用例留有 SolfeggioSyncService 30 秒周期 timer | 按 Service 生命周期补清理后重测，不是已证实的业务导航缺陷 |
| FULL-007 | P2 / 夹具与完成契约 | 同文件 `:126` 钢琴用例未自然完成，直接调用 complete 后期望结果页，实际未显示 | 按完整完成前置条件补夹具；再判定返回栈是否真正回归 |
| FULL-008 | P2 / 已移除筛选断言 | `test/recheck_20_layout_test.dart:509` 调用旧 `member` 筛选期望仅非免费曲；现行筛选为全部/免费/继续/收藏 | 更新筛选契约与测试输入；当前真机免费筛选另有通过证据 |
| FULL-009 | P2 / 已移除付费入口断言 | 同文件 `:584` 查找旧 `songViewMembership` 并要求手机练习付费，触发 `Bad state: No element` | 按手机免费、歌曲钢琴 MIDI 会员的当前边界重写用例 |

### 真机观察

FULL-010（P2，待确认统一等级口径）：同一 Pixel / 同一账号，首页 Lv2、我的 Lv0。首页通过 `AchievementGoalService.getCurrentChallengeLevel()` 计算，设置页直接读 `challengeLevelKey`；有两处数据源。需确认是否应表示同一等级，再修复/明确 UI；不在本测试轮改动产品规则。

### 原生新增缺陷

FULL-011（P2，iOS 原生旋转布局回归失败，业务缺陷候选）：专用 iPhone 13 / iOS 26.4 模拟器，真实 MyApp 首页→横屏音符练习→取消停止→确认停止→等待竖屏。视口最终回到竖屏，记录仍不误计完成，但测试过程产生以下异常：

- `lib/pages/home/view.dart:831` Row 右侧溢出 90px。
- `lib/pages/home/view.dart:1105` Row 右侧溢出 110px。
- `lib/pages/main/view.dart:75` 底栏 Row 右侧溢出 341px。

独立终止/重启后使用相同已编译测试包 `flutter drive --no-build --keep-app-running ...` 复跑，同样的 3 个源码位置和溢出值再次出现，退出 1。证据：[重启复跑日志](evidence/full-regression-2026-10-02/native-app-smoke-portrait-retest.log)。共两次复现；未降低末尾 `tester.takeException()==null` 门禁。应排查方向切换时 ScreenUtil 尺度、隐藏首页与底栏宽度约束的更新顺序，并用普通入口包/真机进一步区分测试泵帧因素与生产表现。本轮未擅自改业务视图，不能声称已有 iPhone 真机缺陷证据。

### 仍未完成的验收

- 109 条人工用例未全部逐步执行，不更新原执行表为全通过；本轮增量证据以本报告为准，首轮/部分复测历史保留。
- iOS Sandbox / Play 内部测试账号与测试交易条件尚未获确认；购买、取消、补单、恢复、到账、账号切换、续订、回调均无真实商店验收。
- 真实 Google OAuth、实体 MIDI 钢琴/USB/蓝牙/踏板、实际音色与延迟、真机练习完成闭环仍待验收。
- 图片/PDF 的 Audiveris 实际识别、私有 OSS 传输、Worker 云端端到端与生产 PostgreSQL/Flyway 未执行；真实 MIDI 仅解析层通过，不等于 App 文件选择/校对/保存完整闭环。
- 已打开个人曲谱的真机离线/弱网/重启、最低版本/平板、多网络性能和长时间稳定性仍待验收。单元测试通过不替代这些条件。
- 不进入发布，现有 CHG-20260927-PAID-UI waiting_review 与 T-F012 in_progress 不因本轮测试而关闭。

## 收尾与下一步

本轮只新增原生集成测试及截图驱动、补充前端结构索引与 QA 流程记录，没有修改业务视图/Store/API、迁移、配置或既有失败用例。前端/后端和文档的既有未提交文件保留；无暂存、提交、发布、真实收费或正式数据库操作。

专用 H2 QA 服务已结束，`31090` 无监听，内存测试账号随进程销毁；用户既有 `8081` 服务仍为 UP。三台本轮专用模拟器已关闭但未删除，截图和测试数据容器可追溯。Pixel 回到原“我的”页面，登录与会员保留，临时 UI XML 已移除；最终 iOS 构建恢复正常 `lib/main.dart` 入口，未留下测试入口作为当前主包。

`dart format`、新增测试静态检查、前端/后端/文档 `git diff --check` 和工作区路径审计通过。完整分析/全量 Flutter/最终原生测试的非零结果仍按上方保留，不能用这些收尾检查覆盖。

下一步先确认 FULL-010 的等级语义，修复 FULL-001～003 和 FULL-011，按当前契约处理 FULL-004～009 的测试失配/夹具；再重跑受影响模块及全量回归。真实商店、实体 MIDI、OMR/OSS、真机网络/缓存和性能需补齐条件独立验收。IOS-QA-001/002 的当前子项结果有增量证据，但教学中断、刷新/重启、自然完成等完整用例未闭合，不擅自关闭历史缺陷。
