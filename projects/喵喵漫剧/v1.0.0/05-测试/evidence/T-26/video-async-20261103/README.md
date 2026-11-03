# T-26/T-27 视频快速受理与后台审核、冻结：开发检查

日期：2026-11-03（America/Los_Angeles）。三批实现及开发检查完成，待用户验收；未推送或部署。

代码：App dev `5fd540c`；服务端 dev `87e21dbb`、补充边界测试 `e94a3044`。保留并行支付、商品价格和 UI 任务的改动。

## 交付行为

- 新 VIDEO/BATCH_VIDEO 固定 `CATDRAMA_VIDEO_ASYNC_V1`，提交不等待第三方审核、模型或 OSS，先原子保存原请求、任务、资源引用及报价消费并返回 QUEUED。步骤台账在后台首次领取时初始化。
- 每个镜头后台审核通过才按原报价冻结；已受理后不因报价到期或后来调价重新报价。冻结订单、任务指针及步骤成功原子提交，重启或重放不再次冻结。
- 未冻结时 `financialState=UNRESERVED`、订单号空、三项积分计数为 0；审核拒绝、重试耗尽或余额不足不扣费、不伪称退款。批量通过项继续，失败项独立收口。
- 回执可靠保存后立即展示任务，历史刷新阻塞不延长提交等待。审核临时异常仍为生成中，明确终态才失败；原编号支持退出重进。
- 保留生成与后处理分离、条件自动应用、手改保护、失败保旧和旧 V3 已冻结任务恢复。图片、其他 App、模型参数、价格、Figma 及本机剪辑绑定未调整。

## 检查结果

| 检查 | 实际结果 | 本机记录 |
|---|---|---|
| Flutter shots/generation/editor video_replace | 308 通过，0 失败 | logs/frontend-final.log |
| flutter analyze --no-pub | No issues found | logs/analyze.log |
| 后端定向回归 | 75 通过，0 失败、0 跳过：Video 26 / Apply 11 / Quote 9 / Workflow 11 / Recovery 18 | logs/backend-delivery-final.log、logs/delivery-results/ |
| 审核前手改、受理事务整批回滚 | 2 通过，0 失败、0 跳过 | logs/final-boundaries.log、logs/final-boundaries-results/ |
| HTTP 性能 | 2 通过，各 20 次采样；不与重复复验累加 | logs/performance-2.log、logs/performance-results/ |
| 审核分段计时复验 | 9 通过，属于上述 75 项的重复验证，不累加 | logs/audit-timing.log、logs/audit-timing-results/ |
| Android arm64 普通 profile 构建与页面 | 构建及下表受控流程通过 | logs/device-build.log、phone-run/ |

后端共 79 个不同的定向用例通过，0 跳过。隔离 PostgreSQL、真实 HTTP/JWT/积分事务及 FFmpeg 文件参与验证，审核、模型和 OSS 使用受控替身。10 秒审核阻塞用例先收到任务响应，阻塞期间冻结及模型调用均为 0；记录到后台审核耗时 10016ms。另覆盖六次临时失败、余额被占用、冻结事务回滚、冻结后中断恢复、同键并发、报价到期及调价、批量部分失败、审核等待期间手改、整批受理回滚。

### 本机 HTTP 性能

预热后各 20 次，只计提交 POST 到响应完整读取；样本间收口本测试未执行、未冻结的排队任务，避免用户批次活动槽位干扰。不是并发吞吐或真实网络测量。

| 镜头数 | p95 | 最大值 | 目标 |
|---|---:|---:|---:|
| 1 | 18ms | 30ms | ≤1000ms |
| 100 | 786ms | 855ms | ≤3000ms |

提交记录 validateMs/saveMs，访问审计记录 HTTP duration，后台记录审核与冻结耗时，不记录用户原文或签名。采样期间未执行付费模型。

### 扩展回归边界

扩展首轮实际执行 156 项、47 项失败。其中 2 项仍期待“提交时审核/冻结”的旧契约，已按本轮批准行为更新并通过。其余失败在修改前业务源码基线中复现：基线 125 项、45 项失败，包含图片报价/批量 25 项、旧恢复夹具 2 项、人工审核/封面/既有视频断言 18 项。视频类复跑 80 项仍有 18 项同名基线失败，没有新增失败；未修改这些范围外业务，也不宣称整个后端套件全绿。

原始失败、修复前源码覆盖方式、同名对照及筛选命令保留于 logs/baseline-regression.log、logs/regression-comparison.json、logs/baseline-build.gradle、logs/delivery-command.json。基线首次源路径配置错误导致的编译失败未计为业务测试结果；修正后才使用上述 125 项结果。

## 固定池 Android 页面核对

设备 Solfeggio_Store_Phone_20261019，API37、1080×2340。桌面 ADB runner 操作普通 profile App，App 内本机 HTTP 夹具供状态；没有 in-app tester 点击。

| 状态 | 实际观察 | 截图 / JSON |
|---|---|---|
| 原视频 | 已应用 801，红色封面和缩略图 | O00004 |
| 受理返回 | 901 QUEUED/UNRESERVED，冻结 0，结束提交等待，submits=1 | O00010、logs/device-accepted.json |
| 审核重试及强制重启 | 原 901 RUNNING/PRE_CREATE_CONTENT_REVIEW/UNRESERVED；waiting=true、failed=false，submits 仍 1 | O00016、logs/device-restored.json |
| 后处理 | source=SUCCEEDED、processing=PROCESSING，继续生成中 | O00018、logs/device-processing.json |
| 交付成功 | 自动应用并预览 8801，蓝色封面/缩略图，结束等待 | O00020、logs/device-success-final.json |
| 再次主动生成后模拟拒绝 | 902 FAILED/UNRESERVED、冻结 0；结束等待，保留 8801 和蓝色缩略图，原失败界面及重试入口正常 | O00028、logs/device-failed-final.json |

审核拒绝均为主动构造的测试结果，不是某条真实用户视频被拒绝。色块用于区别资源身份，不代表真实生成画质。已查看上述成功和失败截图，复用原布局，不新增提示面板或按钮；未做完整 Figma 像素、视频质量或口播验收。

控机用例索引过期后按原生成器重建本地索引，不修改原验收状态。一次终止后的界面树不完整，经 O00013 桌面及进程核对后 reconcile，没有盲目重发；过期坐标动作被工具拦截。phone-run 仅登记 TC-14-04 的 phone_ui 切片，original_case_status 保持 not_assessed，正式整版统计不增加。

## 数据库改动与交付边界

仅在未正式执行的 `catdrama/V4.19__catdrama_episode_cover.sql` 扩展 `catdrama_jobs.financial_state` 约束与注释，允许 UNRESERVED；不增加表列、不回填、删除旧任务或账务。核对的最新正式上传记录为 2026-10-12/e69c75b5，其留存 JAR 无 Catdrama SQL；V4.19 首次提交为 2026-10-26。

本轮只在专用 PostgreSQL `.test/catdrama-tests/pg-video-autoapply-20261102` 的随机隔离 schema 验证。测试 PostgreSQL 已停止并保留数据目录；设备已停止、ADB 转发与 runner 已关闭，原租约已归还。共享服务、现有运行库与正式环境未更新，未清库、未 repair。

启用时须同步更新 App、后端与运行库约束/Flyway 校验和；新流程任务处理完成前，不单独回退不识别该标识的后端。本轮没有真实 Provider/OSS、真实审核、物理设备、iOS 或部署验收。

截图、包、日志、响应及原始 XML 仅在本机保存，不进入 Git；本 Markdown 报告可纳入版本管理。
