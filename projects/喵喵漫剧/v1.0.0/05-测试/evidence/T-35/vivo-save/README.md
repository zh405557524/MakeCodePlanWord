# T-35 Android 12 真机导出与相册保存补验

2026-10-17，前端 dev `8047762d79ba4ac07717d068272e1aba66068605`，未推送。本轮只扩展既有集成测试、严格 driver 和说明；业务代码、原生媒体引擎、后台、API、数据库、依赖和已确认产品/设计/技术稿未改。T-35 仍未完成。

## 实际结果

vivo V1981A，Android 12/API31，实际手机，初始未安装目标 App。使用明确启用物理设备的测试包、真实 Media3、Hive 和系统 MediaStore；只创建隔离工程与自建音视频。读取权限 `READ_EXTERNAL_STORAGE` 自始至终未授权。

| 检查 | 本轮证据 |
|---|---|
| 导出后先预览 | 实际 2 秒、320×180、24fps、H264/AAC MP4，439603 字节；编码任务 1 次、成长事实 1 次 |
| 取消用途说明 | 系统写入/相册插件调用均 0，原 MP4 和导出任务保持 |
| 主动重新保存 | 同一 exportId/nativeOperationId/inputHash/attempt1/MP4，只实际写入 1 次；不重新编码 |
| 临时缓存独立 | 应用内临时成片实际删除后，精确定位的自建相册副本仍可读取，SHA-256 与原件一致 |
| 媒体独立核验 | 原件与系统副本均完整解码，实际 H264 视频轨/AAC 音轨可用，内嵌 PNG 封面与原生封面一致 |
| 页面 | 3 张实际系统截图已总览，取消/成功两张原图已查看；未做最新 Figma 对稿 |
| 清理 | 先保留主机证据，仅删除已核对名称/归属/摘要的本轮单条相册资源及新装测试包；恢复桌面，释放设备锁、本轮转发和 driver 日志读进程，原有两个转发及旧日志进程保持 |

![真机三阶段](system-contact-sheet.png)

红色画面是自建原生样片，不代表模型内容或视觉质量。只查询本轮新建视频的精确文件名/URI，没有遍历用户私有相册。

## 自动检查与执行边界

- 64 项既有导出/相册专项、全量 analyze、2 文件格式和 Android 测试包构建通过；没有新增单元方法。
- 1 条实际 App 测试方法与严格 driver 退出 0；Flutter 的 setUpAll/tearDownAll 不另计业务方法。
- 全套 1261 项 App 沿用 T-40 有效基线，本轮未重跑；后台未启动、修改或测试。
- 实际 SDK29–32 读取 `storage` 状态，SDK33 起读取 `photos/videos`；物理设备需 `CATDRAMA_ALLOW_PHYSICAL_TEST=true`，driver 再匹配实际 SDK 和物理设备字段。
- APK 安装一次，读取实际本进程 VM Service，再用当前安装 Flutter 的 `--use-existing-app` 官方连接方式继续；driver 不再重复安装测试包。VM URI 仅保留在不提交的 originals 中。

[检查命令](checks.json)、[构建及源码摘要](build.json)、[App 原报告](vivo-api31/android-android-album-access-result.json)、[系统图握手](vivo-api31/system-captures.json)、[系统文件](gallery-verification.json)、[独立媒体检查](media-verification.json)、[清理结果](phone-cleanup.json)。

## 宿主检查失败及复核

本轮没有重复导出或再次保存。各次原退出码见 [host-exits.json](host-exits.json)，原日志压缩件保留在 logs，未改写为成功。

1. App/driver 已成功后，原宿主要求 Android 权限全部 flags 相等。系统仅新增 `USER_SENSITIVE_WHEN_DENIED/GRANTED` 元数据，授权仍 false，插件前后仍 `storage: denied`。保留原宿主退出 1，通过 [只读复核](host-reconciliation.json) 核对精确差异并继续读取已完成结果。
2. 第一次独立媒体脚本用 `codec_type` 建字典，内嵌 PNG 封面覆盖了 H264 视频项，退出 1。保留 [已执行脚本](executed-reconcile-gallery-01.py) 和 [失败记录](reconcile-attempt-01.json)；修正为按 `attached_pic` 分离真实视频轨/封面，完整解码原件和系统副本通过。FFmpeg 只用于工作站核验，没有加入 App。
3. 清理宿主先错误要求 `content delete` 打印固定文案，实际返回空输出。精确 URI 复查已不存在，不重复删除；接着厂商 `dumpsys window windows` 无焦点字段导致退出 1。保留两次日志/原码；通过完整窗口状态、App 缺席、原转发及自有进程状态只读复查后释放锁。[删除核对](cleanup-delete-reconciliation.json)、[最终清理核对](phone-cleanup.json)。

`run_vivo.py`、`executed-reconcile-gallery-01.py`、`executed-cleanup-phone-01.py` 和 `cleanup_phone.py` 是该次执行记录，保留上述宿主失败；不能据其旧终态盲目重放。`reconcile_gallery.py`/`finalize_cleanup.py` 是本次补核脚本，未重放导出或保存。

## 仍待验收

更多 Android 机型/版本、iOS 真机、真实空间耗尽或进程中断、真实模型/ASR/OSS 完整制作链及最新 Figma。本轮工程来源为隔离夹具，返回作品路由为测试入口；不能当作同一真实作品端到端验收，也没有执行保存权限永久拒绝/设置恢复。

TC-21-03/08、TC-25-02、TC-X29 仅追加局部结果，见 [逐项范围](case-results.json)。47 项仍 7 完成/38 进行中/2 待外部；正式 186 条仍 9 通过/172 部分/5 未执行，不因 1 条方法或 3 张图增加完整通过数。

## 复查

运行 `python3 verify.py` 只读校验清单、实际报告/权限差异/媒体/截图、源与提交范围、12 份受保护文件、后端旧改动和工作区原有状态；不连接手机、不重放任务、不修改进度。`manifest.json` 不包括 originals、临时 Python 缓存和自身/verification 回执。

数据库改动：无。阶段仍为开发。本轮用量未取得，未额外查询。
