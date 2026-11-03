# T-26/T-27 视频完整状态与自动应用：开发检查

日期：2026-11-02～03（America/Los_Angeles）。状态：两批实现与开发检查完成，待用户验收；未推送或部署。

代码提交：App `7b40778`；服务端 `30d8fa76`、`8bd081c1`，均在 dev。本轮提交已排除并保留并行生成按钮、Toast、图片自动应用等任务的改动。

## 交付行为

- 首次、重新生成、批量每个镜头均在校验、OSS、审核、保存后由服务端条件自动应用。新任务冻结原应用 ID、原有效制作参数；发布时保护镜头、引用、剧本和绑定/图片版本，期间修改保留，新结果进入历史。
- 手动应用相同当前视频的新键推进一次 revision；原键重放不推进。已发布版本不重复应用或覆盖后来的选择。旧 FIRST_SUCCESS_IF_EMPTY / CANDIDATE_ONLY 任务继续原策略，历史不回填。
- 页面联合源任务、processing、latestGeneration 及同任务版本判断状态，后处理变化也刷新，重进恢复原编号；批量展示和原回执消费等待原子项完整终态。
- 自动换片后旧视频只留历史，不再触发“新版本待应用”；修改保护下的新候选仍走原历史入口。本机剪辑工程仍固定原版本。

## 自动化结果

| 检查 | 实际结果 | 原始记录 |
|---|---|---|
| Flutter shots/generation/editor video_replace | 289 通过，0 失败 | logs/frontend-final.log |
| 视频核心、应用、报价定向检查 | 37 通过，0 失败，0 跳过（16+11+10） | logs/backend-delivery-2.log、backend-delivery-results/ |
| flutter analyze --no-pub | No issues found | logs/analyze-delivery.log |
| Android 普通 profile App 构建 | arm64 构建通过，由电脑 ADB 操作实际页面 | logs/device-profile-build-4.log |

后端使用本任务专用 `.test/catdrama-tests/pg-video-autoapply-20261102` 和随机隔离 schema。测试执行真实 PostgreSQL、FFmpeg、文件标识和存储字节核验；Provider/OSS 和模型提交是受控替身。

首轮旧夹具缺少新解析/提交接口的桩及当前制作阶段，测试在进入视频业务前失败。仅在本次视频测试文件内修正夹具后，目标链路通过，失败日志保留。另将修改前保留的业务文件复制到隔离源码目录，使用修正后的夹具运行诊断基线：80 项中 22 项失败，包含既有人工审核、封面及提示词/并行规则差异。扩展视频回归中的人工审核、封面失败在该基线复现；没有修改其业务逻辑或宣称整套全绿。本轮交付测试计数只采用上述定向 37 项。

最终补充生成期间保存新剧本版本的保护用例：发布比较分集当前 scriptRevision，不能被原分析版本掩盖。用例通过，保留旧应用，新结果正常交付为历史。最后一轮首次启动专用 PostgreSQL 时遗漏端口参数，产生连接失败；日志保留为 backend-delivery.log，按专用 URL 端口重启后实际执行 37 项全通过，未将连接失败或跳过计为通过。

## 桌面设备路径

固定池 `Solfeggio_Store_Phone_20261019`，Android API 37，1080×2340，普通 profile App 的本机 HTTP 夹具承接真实视频编辑页。所有按钮和滚动由 `phone_test.py` 的 ADB runner 执行，没有 in-app tester 点击。

| 步骤 | 实际观察 | phone-run-2/observations/ 证据 |
|---|---|---|
| 旧视频 | 已应用 801，红色封面，原生播放至 00:10 | O00004、O00006 |
| 重新生成并确认 | 只受理 901，等待中禁止重复生成 | O00010、O00012 |
| 模型成功、后处理未完 | source=SUCCEEDED / processing=PROCESSING，继续等待 | O00014、logs/device-processing.json |
| 强制关闭重启 | 恢复 901，提交次数仍为 1 | O00015、logs/device-restarted.json |
| 后处理成功 | 自动应用及预览 8801，蓝色封面，结束等待 | O00017、logs/device-success.json |
| 旧历史提示 | 801 保留历史，不再被提示为新候选 | O00017 |
| 再次主动生成后失败 | 902 后处理失败，显示原因和重试；旧应用及预览 8801、蓝色缩略图保留 | O00024、O00026、logs/device-failed.json |

同视口检查既有生成中、完成、失败布局，色块及失败原因为夹具动态数据。未修改 Figma 或新增页面、按钮；不记完整 Figma 像素、真实视频质量或口播验收通过。runner 关联 TC-14-04 的 `phone_ui` 切片，只登记以上 UI 路径，完整用例的并发、账务与真实回调仍独立验收。

第一台 Pixel_9_Pro_XL 因既有图案锁屏未执行业务，记录于 phone-run/；没有清数据或绕过锁屏，已归还。第二台 debug 安装受剩余空间限制，改用同代码 arm64 profile 包完成，没有删除旧数据。两台设备已停止、租约已归还；本任务 PostgreSQL 已停止并保留数据目录。

## 数据库改动与边界

无结构变更、迁移、回填；只增加既有任务 JSON 字段并更新应用指针、revision 和就绪状态。未重启共享服务，未操作正式数据库、调用真实 Provider/OSS、外发安装包或部署。iOS 界面、物理机及正式环境未验证。

截图、包、运行日志、响应和夹具仅在本机保存，不进入 Git；本 Markdown 报告可纳入版本管理。
