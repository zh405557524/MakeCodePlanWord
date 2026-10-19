# T-09 系统剪贴板、Unicode边界和三入口补验

2026-10-19，开发阶段。App dev `d7fc4fc`、后台 dev `2f16f00a`已提交，未推送；仅新增测试入口/严格驱动，以及原隔离测试服务的受限证据路径。普通App业务、公开接口、数据库结构、依赖和模型配置未改。

## 已执行及结果

| 层 | 实际结果 | 证据 |
|---|---|---|
| App专项 | 24方法通过，0失败/跳过 | [结构汇总](frontend-tests.json)、[命令与退出码](frontend-verification.json) |
| 后台 | 13个真实Spring/MockMvc/JWT/隔离PG方法通过，0失败/错误/跳过 | [逐方法摘要](backend-tests.json) |
| Android | API37专用模拟器1个完整页面方法/严格宿主通过，6系统截图 | [报告](attempts/android-01/android-result.json)、[宿主](attempts/android-01/outcome.json) |
| iOS | iOS26.5专用模拟器1个完整页面方法/严格宿主通过，6系统截图 | [报告](attempts/ios-02/ios-result.json)、[宿主](attempts/ios-02/outcome.json) |
| 静态/构建 | 最终全工程analyze、两文件格式和两端实际测试构建通过；iOS另构建普通main.dart恢复基线 | [静态退出码](final-static-checks.json)、两端宿主记录 |
| 数据 | 两账号各仅1稿/revision8/sourceRevision8；清空后正文0、名称20；0作品、0任务；可用30/冻结0 | [实际PG断言](database-assertions.json) |

两端均调用真实系统Clipboard.setData/getData，再点击实际“粘贴”按钮。未替换剪贴板MethodChannel；名称通过框架编辑输入，不作为真机IME验收。后台只模拟短信，使用实际Servlet、公共认证、Mapper/事务与PG；没有AI、OSS、支付或生成扣费。

检测从测试目标直接定位实际创建页；未绕过或改变普通App首页的生产守卫。日常测试后台目前制作/创作关闭且可用模型为空，见[独立只读排查](../../T-06/runtime-availability/README.md)。本轮通过不代表那个环境已可创作。

## 逐项核对

- 默认现成剧本；20/21标量名称含Emoji，超限不截断，服务端保留20字。
- 原生剪贴板完整往返空白、9,999/10,000/10,001标量；包含中文、Emoji、CRLF和换行，UTF16长度与标量数不同。
- 9,999/10,000可保存且下一步可用；10,001显示红色说明/计数，下一步禁用，本机保留全部新输入，后台仍是上次10,000字，未提交非法写入。
- 灵感→小说→现成剧本切换保留同一10,000字全文，实际响应sourceRevision逐次递增；只有小说出现TXT入口。
- 后台本轮13方法中的sourceChangesKeepHandEditsAndInvalidateBothConfirmationsAndUpstreamIdentity验证已有手改/确认稿失效但不删除正文；unicodeScalarsAndAllThreeEntrancesKeepOriginalWhitespaceAndRejectOverflow验证三个来源及数据库CHAR_LENGTH。
- “清空”后正文、实际本机文件和后台一致为空，下一步禁用；未生成正式作品。

因此TC-04-01、TC-04-02在其“双端自动＋数据链路”定义范围内通过；原验证记录保留为历史。TXT两条继续引用已通过的T-10，不重复计数。T-09整项保持未完成，TC-09-01及真实写盘中断/容量故障、跨设备冲突和完整设备矩阵仍待，不以新增两条通过覆盖其他用例。

## 截图复核

已查看双端各6图总览和Android超限原图。超限计数、提示、禁用/启用和小说TXT状态与断言一致；Android系统剪贴板预览会临时遮挡底部，该系统浮层留在原图中。不用本轮截图宣称全页Figma像素通过。

![Android系统图](android-overview.png)

![iOS系统图](ios-overview.png)

## 准备失败及环境恢复

首轮iOS在App测试启动前发现旧安装注册指向不存在的mobileinstallation.placeholder；[失败记录](attempts/ios-01/outcome.json)保留，不计业务失败或通过。宿主只在专用模拟器构建并安装普通main.dart作为明确的恢复基线，第二轮完整通过。另一次初始analyze因测试入口错误的按钮import失败，修正为实际widgets聚合后重验通过；无App业务修复。

两端测试结束恢复普通App、借用前原生安全会话和剪贴板；Android已装APK与备份摘要相同，iOS与本轮明确构建的普通基线相同，iOS恢复关机状态。用户手机只用于另一个入口问题的只读诊断，未启动/点击/安装或改会话。宿主锁/端口转发释放；专属Servlet退出并清掉自身随机schema，PG停止、空socket目录移除，见[清理](cleanup.json)。

数据库改动：无业务DDL/迁移和既有数据变更；验证仅新建本轮专用PG与随机测试schema，按已有迁移执行，终态已清理并停库。[保护范围](scope-check.json)确认私密配置、锁文件、其他对话脏文件及产品/设计/技术/上线基线保持。

## 复跑

使用项目锁定Flutter和镜像，所有Flutter命令带--no-pub。先以原CatdramaTextImportDeviceServer启动新的专用回环PG/角色catdrama_test/schema，CATDRAMA_TEXT_IMPORT_EVIDENCE_DIR必须为本目录；只采用本轮新server.json及仍存活的PID。Gradle定向执行CatdramaDraftTests，并通过sourceSets.test.runtimeClasspath启动该测试main；环境不得指向已有业务库。

随后在App仓库运行 `python3 "/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-09/native-clipboard/run_devices.py" android --attempt 03` 及对应ios命令。每次使用新编号，不覆盖attempts；宿主验证固定专用设备，建立本次端口、随机检测身份并保存实际系统截图，再核对严格报告和恢复普通App。授权串只从原本机忽略文件读取，不写进命令文本或证据。原始日志、JUnit、classpath和普通包备份放本地忽略的originals，不提交。普通用户启动不执行测试目标。
