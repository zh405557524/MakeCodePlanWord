# T-09 API31 真机草稿与安全会话恢复

2026-10-18，vivo V1981A / Android 12 / API31，设备 `e2b8595a`。前端 `dev` 提交 `7137e9e10c165d571b3e5a80596b885400e4f209`；后台仅测试入口提交 `9ddd0628e30acb0a4cb0d87d92d9fb4913ad808a`。未推送或部署，当前仍为开发阶段。

本轮只扩展已有草稿恢复 support、严格 driver、App README，并给原 `CatdramaTextImportDeviceServer` 增加一个受限证据目录。生产业务、接口、迁移、数据库结构和依赖未改。实际使用全新临时 PostgreSQL database、随机 schema 与真实 Servlet；短信提供方为测试替身，没有发送真实短信或调用 AI。

## 三个真实进程

| 阶段 | PID | 实际观察 |
|---|---|---|
| synced-seed | 28193 | 小说入口、自定义2集，含换行与 emoji 的原文已保存；实读 KV/检查点及摘要后系统终止 |
| unknown-seed | 28486 | 原会话及原草稿恢复；PUT 已在后台成功，但代理丢弃回执；随后继续手改并保存到本机，保留旧待核对输入；再次系统终止 |
| pending-recover | 28768 | 读取原 KV 和原生安全会话，先核对旧保存，保留最新手改；实际点击“重试”后保存成功 |

同一个已校验 APK 只安装一次，三相之间没有重装、清数据或重造原稿。每次终止前核对新鲜探针、实际 OS PID、KV 摘要及检查点；终止后确认原 PID 消失。前两阶段驱动因真实终止退出 1，属于前置，**不计通过方法**。最后阶段 App 与严格 driver 退出 0，计 1 条完整恢复方法。

[最终报告](android/android-pending-recover-result.json)、[第一次系统回执](android/synced-seed-host.json)、[第二次系统回执](android/unknown-seed-host.json)、[三相结果](outcome.json)。

原生安全存储没有 Mock；三个进程只登录一次，原 token 摘要在两个检查点保持，最终恢复测试借用前的安全键。原 KV、token、APK 和日志只保存在忽略的 `originals/`，公开记录不含登录凭证。

## 独立核对

- [数据库](database-assertions.json)：只有1份原草稿，原 `clientDraftId/serverId/userId` 保持，最终正文为后来手改，revision=3；没有正式作品，公共积分30、冻结0。
- [网络](network-assertions.json)：一次草稿创建、一次登录；已提交但丢回执1次、后续阻断写入1次；最终保存沿原草稿，没有重建或重新登录。
- [本机文件](disk-assertions.json)：已同步正文、未知保存时“最新手改＋旧保存意图”、最终已同步正文分别实读；最终文件 SHA 与 App 报告相同，原保存意图在确认成功后清除。
- 3张实际系统图已查看，未同步与最终保存两图另看原图。正文、emoji、换行与保存提示一致；顶部名称/来源/集数因滚动未完整入图，另由 Controller、磁盘和数据库核对，不算完整 Figma 对稿。

![三个真实状态](system-overview.png)

## 检测与用例状态

24项既有 App 草稿测试、13项真实 PG 草稿测试、`flutter analyze --no-pub`、两文件格式与 Android debug 构建通过。13项后台测试无失败/跳过，强制实际执行；完整 Servlet/PG 手机链路与这些测试分开记录。1269项全套 App 沿 `f399154` 有效基线，本轮未重跑。

正式 `TC-09-01 创作自动保存真实恢复` 由未执行改为部分验证：本轮只覆盖原文和输入参数，草案、逐集稿及制作参数的完整恢复仍待。其他185条状态及全部步骤/预期保持，统计为 **9通过/173部分/4未执行**；47项仍为7完成/38进行中/2待外部，T-09整项未完成。

[命令](checks.json)、[后台测试](backend-tests.json)、[构建指纹](build.json)、[用例状态修订](formal-case-update.json)、[逐项边界](case-results.json)。

## 保留的准备问题

1. 首次 PG 启动因 macOS Unix socket 路径超过103字节而明确退出。确认失败 PID 消失、`pg_ctl status=3` 后，保留同一已初始化数据目录，改用本轮新建的短 socket 目录；没有重新初始化或使用其他数据库。[失败记录](preparation-failure.json)。
2. 13项 PG 测试通过、原 Java 启动后，宿主恰在 `server.json` 创建但尚未写完时读取，JSON 解析失败。实查同一 PID 31879、所属 loopback 监听与完整 JSON 后继续原服务，没有重跑测试或重启 Java。[实际状态核对](backend-ready-verification.json)。读取等待已补齐，最终修补只做语法检查。
3. 代理身份检查初次按 `python3` 名称判断，与 macOS 实际 `Python` 可执行名不符；核实原 PID 31931 的脚本、工作目录和监听后继续原代理，没有重启。[观察记录](preparation-proxy-observation.json)。

初始及第二版实际准备脚本分别在 `prepare_backend-executed-initial.py`、`prepare_backend-executed-before-readiness-fix.py` 留存；[prepare_backend.py](prepare_backend.py) 为修补后的重现脚本。PG失败、测试与服务原日志私有保留并提供脱敏 gzip；JSON解析及代理断言异常有工具回执和结构化记录，完整原始 Python stderr 未另存。准备问题不计为 App 用例通过。

## 重现与清理范围

[host_proxy.py](host_proxy.py) 复用原网络边界，只改为单 Android 端口和新合成账号；回执丢弃与阻断逻辑不变。[run_vivo.py](run_vivo.py) 复用既有真机安装/通知/进程观察助手，入口仍是 `integration_test/draft_flow_test.dart`。真机必须显式带 `CATDRAMA_ALLOW_PHYSICAL_TEST=true` 和恢复开关；driver 核对 SDK31、V1981A、本轮 runId 及完整恢复字段。

目标 App 初始必须不存在，前台为桌面且成功取得 phone-ui 设备锁。构建一次，安装一次，以 `--use-existing-app` 和 `--keep-app-running` 连续三次启动；探针/回执未知时观察原进程，不重新开始。后台只允许新建 `.local/catdrama-tests/pg-*` 下的 `catdrama_test` 测试库及随机 schema，不连接现有开发/测试/正式环境。

独立核对后只移除本轮摘要匹配的测试包，恢复原 forward/reverse、桌面和设备锁；没有访问相册。停止已核对身份的原代理/Java；原 shutdown hook 删除自己的随机 schema，确认无非系统 schema 后停止本轮 PG，仅移除空的自有 socket 目录。初始化数据目录私有保留供追溯。[手机清理](phone-cleanup.json)、[测试服务清理](support-cleanup.json)。

尚未验证：真实输入法/剪贴板、草案/逐集稿/制作参数、写盘中强杀/真实满盘、跨设备冲突、iOS真机及最新Figma。输入由实际 Controller 设置，第二阶段显式暂停同步；不冒充系统后台生命周期或物理键盘验收，也不代表真实手机号渠道验证。

数据库改动：无；只在新建临时测试库执行既有迁移和合成数据，已清理自有 schema，现有业务库未改。本轮用量未取得，未额外查询。

提交复检时发现 JUnit 原输出含行尾空白，现以脱敏 gzip 按原字节保留，不删改原日志；启动入口生成但本轮未使用的4个 TXT 夹具仅留私有 originals，不计 TXT 导入验收。见 [证据打包记录](evidence-packaging.json)。
