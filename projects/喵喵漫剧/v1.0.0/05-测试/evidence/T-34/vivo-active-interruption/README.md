# T-34 API31 真机活跃编码中断恢复

2026-10-18，vivo V1981A / Android 12 / API31，设备 `e2b8595a`。App `dev` 提交 `68864c38b969e14b5f7c5d58c89d5410cdfbd157`，未推送。当前仍为开发阶段，T-34 整项未完成。

本轮只扩展既有 `integration_test/local_export_test.dart`、严格业务 driver 和 App README。生产业务、原生 Media3/AVFoundation、接口、数据库及依赖未改。App 没有新增 FFmpeg；工作站 FFmpeg 只做独立媒体检查。

## 实际结果

| 检查 | 观察及结果 |
|---|---|
| 编码中断 | 同一次 HTTP 核实原生 `RUNNING / 39%`，staging 421388 字节，持久状态为 ENCODING；截图后重查仍在编码，才执行一次 `am force-stop` |
| 进程 | 原 PID 23751 确认消失；恢复 PID 26489 |
| 沙盒 | 初始没有目标 App；仅对自建测试安装执行 `adb install -r` 更新恢复入口，UID、firstInstallTime 与原 active-ready 保持；中间没有卸载、清数据或重新造源 |
| 原输入 | 恢复仅读取原 Hive、租约、完整工程和 4 份源文件；固定输入、工程、来源摘要均保持；旧原生操作为 UNKNOWN_OPERATION |
| 清缓存保护 | 恢复前实际执行闲置清理，源片和非空 staging 受保护，0 失败 |
| 页面 | 先显示“本机导出已中断，工程已保留，可手动重试原输入”；观察期间不自动编码 |
| 明确重试 | 实际点击“重试此版导出”后，同任务 attempt1→2，使用新原生编号；等待时禁止编辑和离开 |
| 完成事实 | 导出与首次导出事实各 1；相册仍为 NOT_SAVED，无后台导出、成片上传或相册写入 |
| 成片 | 1556122 字节、320×180 / 24fps、60 秒 H264/AAC MP4；中文文字、字幕、混音、黑边及内嵌封面独立核验通过 |

[中断回执](android/interruption.json)、[保留沙盒](sandbox-preserved.json)、[严格报告](android/android-export-active-result.json)、[实际媒体检查](android/media-verification.json)。

实际 MP4 完整解码通过。导入轨与原声均为自建 880Hz，后段 50% 原声音量与导入轨的 RMS 比为 0.499/0.503；开头和指定末段静音保持。6 个时点分别核对原镜头、黑边和字层时窗，后续重复片段没有重复文字。内嵌封面与单独 PNG 摘要相同。4 张系统图已在总览查看，中断结果和成功预览另看原图；6 帧和封面已查看。

中断前截图有 vivo 通知弹框遮挡，App 进度文字仍为 0%；39% 取自截图后再次读取的原生操作与非空文件，**没有以截图文字证明 39%**。本轮没有接受最新 Figma 对稿、跨引擎色彩保真或高分辨率长片性能。

## 测试与边界

- 既有 4 份导出/相册测试文件共 64 项通过，0 跳过；`flutter analyze --no-pub`、两文件格式及两阶段 Android debug 构建通过。
- `seed-active` 因实际终止进程而退出 1，是中断前置，**不计通过**。`recover-active` 与严格 driver 退出 0，计 1 条完整恢复方法；没有把两个阶段算成两条成功业务。
- 本轮没有新增单元测试方法。1269 项全套 App 沿 `f399154` 有效基线，生产代码未改，本轮未重跑。
- 测试使用自建低分辨率媒体和受控模型能力；手机没有切飞行模式，不据此声称系统断网测试。没有真实模型、OSS、ASR、支付、iOS 真机、真实磁盘耗尽、长片压力或完整手势验收。
- 本轮只给 TC-21-02/05/06、TC-26-01、TC-X16/X25 增加 API31 局部证据；原正式 186 条状态仍为 9 通过/172 部分/5 未执行。47 项仍为 7 完成/38 进行中/2 待外部。

[命令与退出码](checks.json)、[格式复核](format-check.json)、[逐条范围](case-results.json)、[图片复核](visual-review.json)。

## 保留的宿主问题

第一次安装及启动产生的系统通知弹框在终止后仍存在，阻塞恢复 APK 的同一次更新安装。初次 helper 调用没有动作回执，后续电脑从当时的新鲜原生 XML 直接定位并点击一次“禁止”；[动作回执](notification-actions.json)及[观察更正](install-notification-handoff.json)保留。没有重新提交安装、重做 seed 或清理沙盒；随后原更新完成，UID、firstInstallTime 和原 active-ready 一致。

[executed-run_vivo.py](executed-run_vivo.py) 是本轮实际执行的宿主源码；[run_vivo.py](run_vivo.py) 补齐了安装等待和连接前的通知处理，使用同一次新鲜 XML 的唯一节点。修补后仅做语法检查，没有为这个宿主改进重复执行已成功的业务流程。首条错误的“已补点”观察以及无动作的 helper 尝试说明保留在本机忽略的 originals；公开记录以实际唯一动作回执为准。

## 重现与清理

原生入口为 `integration_test/local_export_test.dart`。真机必须显式带 `CATDRAMA_ALLOW_PHYSICAL_TEST=true`，两阶段分别使用 `CATDRAMA_EXPORT_PHASE=seed-active/recover-active` 及独立控制端口。严格 driver 同时核对物理设备、SDK31、V1981A、进程变化、原任务及真实媒体摘要。默认入口仍检查模拟器，不能无意覆盖真机沙盒。

重现脚本仅用于当前设备初始没有目标 App、前台为桌面、端口空闲且成功取得 phone-ui 设备锁的场景。脚本每相构建一次、安装一次、以 `--use-existing-app` 连接并带 `--keep-app-running`；第二相只更新原测试安装。初始已有用户安装时拒绝继续。`phone-preflight.json` 存在则拒绝覆盖旧证据；失败或观察未知时应核对原进程/任务，不重新开始。

[seed 构建](build-seed-active.json)、[recover 构建](build-recover-active.json)、[前置状态](phone-preflight.json)、[seed 终态](driver-seed-active.json)、[recover 终态](driver-recover-active.json)。原始构建/驱动日志、VM nonce、APK 及备份只在本机忽略的 `originals/`；公开日志为去除凭证和 VM nonce 后的 gzip，原件及公开件各自留 SHA-256。

独立媒体与截图核验后，只移除摘要匹配且最初不存在的测试包；没有枚举、创建或删除用户相册内容。原有两条 forward、原 reverse、桌面和设备锁均恢复。[清理结果](phone-cleanup.json)。仅更新指定的 5 份工作区进度文件，产品/设计/技术/上线基线及其他仓库未提交改动保持。

数据库改动：无。本轮用量未取得，未额外查询。
