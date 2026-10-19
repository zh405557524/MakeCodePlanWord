# T-17 修后期限、真实签名到期与进程重启缓存

2026-10-18，本轮新增 1 项真实后台方法及 18 项相关 App 检测通过，App 静态检查、格式、独立 QA APK 构建通过。后台 dev `5a22b9de`、App dev `3517187` 已提交未推送；仅扩展测试夹具及只读观察字段，生产实现沿已修复的 `492b62a0`。[汇总](result.json)。

电脑通过正式 `phone-ui/phone_test.py` 控制 vivo V1981A / Android 12 API31，只在真实相册选择本轮自建 PNG。准备账号和能力目录、一次完成回执丢失仍为受控前提；上传、Servlet、独立 PostgreSQL、OSS 及手机文件缓存均使用真实实现，没有调用 AI。

- **修后期限**：后台默认时区实际为 America/Los_Angeles，手机为 UTC+8。上传成功 `2026-10-19T03:02:27.715Z`，到期 `2026-11-18T03:02:27.715Z`，间隔 2592000 秒。手机详情及历史实际显示“保留至2026-11-18 11:02”，创建时间显示 11:02，已补齐上一轮修后界面验证。[日期及独立文件](utc-and-first-cache.json)。
- **真实签名到期**：仅在独立测试的 SDK spy 中将本轮客户端读取签名缩短为 30 秒，仍由真实 OSS SDK 签名；正式签名时长和接口响应保持原实现。上传内容校验使用的 300 秒签名保持。原客户端 URL 真实 GET 返回 403 / AccessDenied，已核对错误消息为请求过期，未更改手机或服务器时钟。[到期结果](expired-signature.json)。
- **实际进程恢复**：确认原 PID 20611 运行，终止并核对 PID 消失；没有重装或清理数据，重新启动后 PID 为 22460。详情及历史仍显示原资源/原缓存路径，独立读取的两份手机文件与源图、云端 SHA-256 一致。新进程的访问签名和上传请求均为 0；后台在最终独立取证前仅签发过 1 个客户端地址。[终止证据](process-termination.json)、[重启结果](phone-restart-result.json)。
- **原资源恢复与隔离**：总计 1 次 prepare、2 次原 complete，仅 1 资源/1 版本、0 生成订单。后台重新签发可用 URL 后 GET 200，匿名 GET 403，另一账号不能取访问地址；最后仅删除本轮自建 OSS 对象并核对不存在。[真实云端及 SQL](attempts/01/backend-result.json)、[实际方法 XML 摘要](attempts/01/backend-tests.json)。

这不是完整离线验收：重启后仍正常读取后台资产元数据，只是已有图片字节不再请求签名或下载。也没有声称资源缺失、清理缓存后的重新下载、iOS 真机或其他格式/大图已在本轮验证。

| 真实页面 | 截图 |
|---|---|
| 修后实际上传的截止时间 | [查看](screenshots/utc-deadline-after-upload.png) |
| 签名到期、进程重启后命中原图 | [查看](screenshots/cached-image-after-restart.png) |
| 重启后的当前图片历史及期限 | [查看](screenshots/history-after-restart.png) |

两个测试方法中的 8 个时区参数场景及共 54 项旧回归按未变更的 Service/测试源码摘要有效复用，本轮没有重跑或重复计数；1273 项 App 全套沿原有效运行基线。新的 18 项只覆盖资源身份和上传测试，不替代手机业务。首次 profile 使用错误字段的准备失败发生在启动前，原回执保留；修正测试配置后复用同一后台等待任务，未重新建上传或调用 AI。

正式 TC-03-03 仍保留部分验证，控机整条为 `blocked` / `original_case_status=not_assessed`：JPEG/WebP、10MiB、坏图等原要求不在本轮范围。47 项继续为 7 完成/38 进行中/2 外部，186 条继续为 10 通过/173 部分/3 未执行。真实 AI 产物交付、iOS 真机/更多机型、缺缓存及换签失败、更多格式/大图和最新 Figma 继续按原任务补验。

数据库改动：无表、字段或迁移变更。临时 schema 已清理，自有 PG 已停止；原 APK 按原摘要恢复、未卸载/清账号。只清理本轮自建相册图、缓存、隔离 KV、转发和设备锁，原有转发保留。[手机清理](phone-cleanup.json)、[数据库](attempts/01/database-cleanup.json)、[进程](attempts/01/support-cleanup.json)。

本机配置未改，其他 App 的脏文件保留；原始相册截图、令牌、签名 URL、完整 XML/日志及 APK 均位于 Git 忽略的 `originals/`。[源码范围](final-source.json)。`run_backend.py` 在已有阶段记录时拒绝重跑，不因等待超时建立第二轮；`verify.py` 只读复检已有证据和源码，不发起云端请求或操控手机。
