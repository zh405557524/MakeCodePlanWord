# T-26 / M08 批量跳过处理中镜头

状态：实现与本地开发检查完成，待用户验收。日期：2026-11-03（America/Los_Angeles）。用户确认：生成全部跳过正在提交及生成中的镜头，其余正常提交，按实际集合计费，同镜头不重复。

## 实现与提交

- App dev：`30db2ce`，5 个文件。过滤单项和批次的提交未知、排队、生成、后处理目标；按钮估算、报价与提交 targets 使用实际集合。保存每组目标的独立原请求与 targetIds，兼容旧根 context，重进恢复全部原批次；部分失败可重试空闲项。
- 后端 dev：`0f3a5a85`，2 个文件。BATCH_VIDEO 聚合父任务不再占据整位用户的唯一活动槽；VIDEO 单镜头、BATCH_IMAGE 和请求幂等约束保持。
- 其他并行工作的已暂存/未提交变更保留。本次提交分离了原有失败状态修复；该修复仍在工作区。取消和批次完成用例改为等待实际恢复完成后断言。
- 产品补充写入现有 01-产品四文档；这些文档原先未跟踪，本轮不把整份历史文档混入提交。M08 计划完整记录本次已确认范围。

## 实际验证

| 检查 | 结果与边界 |
|---|---|
| 工作区 Dart format / 全项目 analyze | 通过，无问题 |
| 工作区 `flutter test --no-pub test/shots test/generation` | 306 项通过，包含此前未提交的失败状态测试 |
| 本次提交独立源码快照 | 304 个不同用例通过：首次 302 通过、2 个旧用例尚未等恢复完成；补状态等待后这 2 项复测通过。快照 analyze 无问题；原错误日志保留 |
| 后端 Java 编译及隔离 PG 定向测试 | 1 项通过，0 跳过。两个不同镜头批次并发受理，原键重放同编号，重复镜头拒绝，2 个 VIDEO 子项、0 个重复订单；VIDEO/BATCH_IMAGE 活动唯一索引实际拒绝重复插入 |
| Android profile 普通 App 构建 | 通过；App 页面/控制器/持久化为生产实现，账号/HTTP/模型/积分为受控夹具 |
| 固定池 Android 桌面 ADB | VBS-01～05 通过。滚动至按钮、报价、取消、双击确认、全忙再点、强制关闭及重进均由电脑执行 |
| 视觉核对 | 已查看剩余 2 个/24 积分、24 积分确认、重进后 3 个运行状态截图，无本轮布局变更；未作 iOS/Figma 像素验收 |
| diff / 工作区路径审核 | 通过；原始产物仅本地保存 |

VBS-06/07 覆盖单项/批次未知提交、QUEUED/RUNNING/PROCESSING、部分失败并行重试、保留两个批次及新旧原键；全忙无新报价或提交，双击只受理一次。内容资格错误仍保留正式反馈。

设备：固定池 `Solfeggio_Store_Phone_20261019`，Pixel 5、API 37、1080×2340；领取 owner 为本聊天 ID，ADB emulator-5554 经 AVD 名核对。测试后已停止本任务 App、关闭模拟器并成功归还原租约。独立 PostgreSQL 49335 已停止，数据目录保留。

## 页面证据

- [01 忙碌镜头保留，其余 2 个共 24 积分](01-two-remaining.png)
- [03 正式确认 24 积分，可取消](03-cancel-quote.png)
- [06 三个原任务分别运行](06-all-running.png)
- [08 强制关闭重进，无重复提交](08-relaunch-running.png)

`device-events.json` 保留逐步操作、实际 targets、quotes、jobs/children 与提交次数。05 截图处于加载动画，金额依据 03 稳定截图与实际报价响应。初次截图按钮尚未滚入视口，修正桌面脚本滚动定位后整条用例重跑通过；夹具无可读素材图片时的 Toast 不作为真实资源缺陷。

## 数据库、发布与剩余边界

数据库改动：仅在现有 catdrama/V4.19__catdrama_episode_cover.sql 重建 `uq_catdrama_job_active_object` 排除 BATCH_VIDEO，无新增字段和账务回填。本地最近正式发布记录为 2026-10-12 e69c75b5，正式包不含 Catdrama SQL，V4.19 于其后新增，因此复用未正式执行版本。当前运行库未核验或修改，未执行 repair。

本轮只对本任务新建的隔离 PostgreSQL 执行迁移，未升级任何运行库、未部署、未推送、未更新用户真机包。后续发布需同步后端索引与 App；已有执行过 V4.19 的运行环境需按发布流程核对处理，不能直接当作已生效。

无真实 Provider、OSS 或实际扣费调用；不代表真实渠道、iOS 或用户最终验收完成，不提高整版正式验收计数。

## 本地复核入口

- App：`/Users/soul/code/lxwx/catdrama/.test/skip-busy-20261103/`，包含 `analyze.log`、`regression-final.log`、`commit-check-tests.log`、`commit-check-retest.log`、`commit-check-analyze.log`、`phone-build-final.log`、`phone-run.log`、`desktop_app.dart`、`run_phone.py` 与独立源码快照。
- 后端：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/.test/skip-busy-20261103/`，包含 `backend.log` 与 JUnit XML。
- 后端命令：隔离 `CATDRAMA_TEST_POSTGRES_URL` 下运行 `./gradlew test --tests '*CatdramaQuotePerformanceTests.disjointVideoBatchesAcceptConcurrentlyWhileSameShotAndReplayStayUnique'`，构建目录与 Gradle 项目缓存隔离。
