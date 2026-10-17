# T-09 草稿真实进程恢复

本轮补齐双端模拟器上的草稿进程恢复，并修复 iOS 原生钥匙串缺少访问组导致的 `-34018`。当前阶段仍为开发；T-09整项及正式186条的状态不据此全部通过。

## 场景与实测结果

两端均使用实际输入页、DraftSyncService、隔离目录中的真实GetStorage文件、原生安全存储，以及本机Spring/PostgreSQL。只有短信提供方模拟；没有AI、OSS或生成扣费。

1. 小说入口、自定义2集，保存包含换行和Emoji的原文，核对后台及实际KV后，由宿主执行系统终止。
2. 新进程从原KV和原生安全会话恢复原稿、原clientDraftId/serverId及参数。一次PUT已在后台成功，但网络代理丢弃响应；随后断写期间手改正文，核对磁盘仍保留旧待核对输入和最新正文，再执行系统终止。
3. 第三进程读取同一文件，核对原保存结果，保住后来的正文；通过实际页面“重试”保存新稿。严格驱动必须收到完整成功报告，退出0。

最终每端3次启动、2次实际系统终止，共6个进程、4次终止；两端最终恢复方法均通过。准备阶段因系统终止而驱动退出1是预期中断，不计为通过方法。最终一轮无需人工接续准备阶段。

[数据库断言](database-assertions.json)显示每账号只有1份原草稿，revision=3、最新正文完全一致，无正式作品；公共30积分和0冻结保持。[网络断言](network-assertions.json)分别核对一次创建、一次已提交但丢回执、一次最终更新；未重复创建。两端结束时均恢复本次借用前的原生安全键。

## 修复与验证范围

iOS Debug/Profile/Release绑定 `Runner/Runner.entitlements`，访问组使用 `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`。不写死团队前缀，不改Android会话、接口、业务表、依赖或媒体引擎。模拟器生成的权限在Mach-O `__TEXT,__entitlements`中；[提取结果](ios-simulator-embedded-entitlements.plist)和[权限核对](native-keychain-check.json)对应实际跨进程读写，不作为正式签名或Team ID配置依据。平台核对依据：[Apple缺失权限说明](https://developer.apple.com/documentation/security/errsecmissingentitlement)、[插件配置文档](https://github.com/juliansteenbakker/flutter_secure_storage)。

- 锁定依赖下1205项App全量测试、全量analyze和3文件格式检查通过；[完整结果](frontend-full-results.json)、[汇总](frontend-full-summary.json)。24项草稿专项包含在本轮全量回归中。
- 13项真实PostgreSQL草稿后端测试通过，无跳过；[JUnit](backend-draft-tests.xml)。后台只扩展现有独立设备测试入口的证据目录及schema前缀，生产代码未改。未重跑后端整套，T-42原3项公共失败仍按原记录处理。
- 双端锁定依赖debug构建和实际最终恢复通过；[构建指纹](binary-fingerprints.json)、[两端结果](outcomes.json)、[iOS](ios/outcome.json)、[Android](android/outcome.json)。
- 6张系统截图总览及iOS未同步/Android已保存两张原图已查看；滚动到正文后上方表单不在截图中，参数另由实际控制器、磁盘及数据库核对。不是最新Figma视觉终审。
- 工作区路径脚本已于先前提交 `bf956b4c` 补齐，本轮5项自检及目标路径/项目audit再次通过；见[path-guard.json](path-guard.json)。

![双端三个状态](screenshots-overview.png)

## 失败记录与复跑

首轮iOS钥匙串失败是实际配置缺陷，修复后通过。早期宿主把带Flutter参数的完整进程命令误当作纯路径，现按拆分后的可执行路径核对；其失败报告及接续记录保留于[attempts](attempts/ios-keychain/failure.json)。该首轮完整原始iOS驱动日志曾被重试覆盖，保留的是失败报告和观测记录，不宣称原日志完整。

一次未带 `--no-pub` 的analyze触发不同源下的自动依赖刷新，相关锁文件和原始日志已私有保留。恢复干净初始锁文件，使用原镜像执行 `pub get --enforce-lockfile`，随后双端重新构建、从全新测试schema完整重跑全部6阶段，以及1205项全量回归和analyze。[锁文件核对](lock-verification.json)证明最终无依赖变更。此前结果保留于 `attempts/pre-lock-recheck/`，不作为最终锁定环境结果。工具路径、PG端口/就绪顺序及记录器字段的准备失败不记成业务通过。

## 可重复执行

使用原Flutter SDK `/Users/soul/data/flutter/flutter` 和锁文件的 `https://pub.flutter-io.cn` 源；所有后续Flutter命令带 `--no-pub`。仅启用自有iOS模拟器 `E33B4820-6860-419F-8B17-B6A8FA94EA77` 与Android AVD `Catdrama_T17_QA_20261015` / `emulator-5556`。

1. 按现有 `CatdramaTextImportDeviceServer` 启动独立回环测试库与服务，输出目录须为本目录，等待新 `server.json`，不能使用旧ready文件。测试库数据目录必须为 `.local/catdrama-tests/pg-*`，库名/角色 `catdrama_test`，显式指定端口51346。
2. 运行 `python3 host_proxy.py`，等待新 `proxy-ready.json`；原始会话和日志只保存在本机私有 `originals/`。
3. 同一 `integration_test/draft_flow_test.dart` 编译两端debug，设置 `CATDRAMA_DRAFT_PROCESS_RECOVERY=true`；iOS recovery/capture端口54371/54361，Android54372/54362。iOS使用正常模拟器构建，不能关掉签名；CocoaPods路径使用已安装的 `~/.gem/ruby/2.6.0/bin`。
4. 运行 `python3 run_recovery.py`，使用预构建二进制及 `--keep-app-running` 保留安装和沙盒。宿主核对新鲜探针、实际OS PID、KV摘要后才终止，最终阶段截系统图并回执，严格驱动必须退出0。
5. 在本次随机schema内只读核对数据库，再停止自有App/代理/Java；Java关闭钩子移除自身schema。最后停止本次启动的PG及两个模拟器，仅移除本次forward/reverse。不卸载、不清App数据、不改相册权限。

## 保留的验收边界

这不是完整普通启动入口或真实手机号渠道验收。输入由实际控制器更新，测试KV为同一沙盒内的隔离目录；第二阶段为持久化检查显式调用服务的paused回调，未验证真实系统后台事件。强杀发生在已核对写盘后，未覆盖写盘中强杀、真实满盘/设备故障、物理机、跨设备冲突以及最新Figma。正式186条及47任务7完成/38进行中/2待外部保持，阶段不推进。

[终态](terminal.json)记录安全键恢复、自有服务和设备停止、随机schema清理；[范围复检](scope-check.json)核对原有脏文件、产品/设计/技术/上线基线及任务文件范围。[文档复检](review.json)与[摘要清单](manifest.json)随最终提交生成。
