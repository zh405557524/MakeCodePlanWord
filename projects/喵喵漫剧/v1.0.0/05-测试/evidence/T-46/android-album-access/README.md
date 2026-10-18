# T-46 Android 相册读取拒绝与本机编辑

2026-10-17：最终自动运行通过。本轮补齐 API37 模拟器上的实际系统拒绝；T-46 整项继续进行中。

App dev 提交 `dbfe05ebbd28ec7fd8f2ebb1f07be946e390d1e5`，未推送。只扩展既有 `source_audio_access_test.dart`、严格业务驱动及项目说明；业务代码、公共权限实现、原生引擎、接口和依赖保持。后台及数据库本轮未启动或修改，数据库改动：无。

测试保留 iOS 原有 permanentlyDenied 断言，Android 单独核对视频权限及实际 denied/permanentlyDenied 状态，不把有限访问当拒绝。Android 测试要求 SDK≥33、自有模拟器，实际执行为 `Catdrama_T17_QA_20261015`、`emulator-5556`、API37；USB 真机 `e2b8595a` 没有操作。

| 检查 | 实际结果 |
|---|---|
| 取消用途说明 | 不进入系统授权；完整 head、Hive 已存快照、audioImports 均保持，无导入任务 |
| 拒绝实际系统读取 | 电脑根据新鲜原生 XML，点击当前 App 的唯一 Don’t allow；视频权限为 denied，显示“请允许访问您的视频文件／设置／取消”；取消后原工程保持 |
| 拒绝后继续编辑 | 原生预览可用，保存“拒绝相册权限后仍可编辑”；只增加一个文字层、一次 revision，原片段、音轨、声音修订和 14.004 秒总时长保持，Hive 与当前 head 一致 |

以上是 **1 条完整设备方法内的 3 个场景**。34 项既有提音专项、完整 analyze、两文件格式检查、Android debug 构建通过。严格驱动同时核对平台、权限、7 份状态图、旧稿保护和真实保存结果；SDK 退出码不能代替报告。命令见 `checks.json`、`native-command.json`；实际结果在 `android/android-source-audio-access-result.json`。

7 张状态图和 1 张实际系统授权图已总览；系统授权、设置指引和已存文字 3 张原图已详看，见 `contact-sheet.png`、`visual-review.json`。红色视频为自建夹具，不代表模型产物；未注册后台服务，所以“尚未成功联网核对”的版本提示是本机夹具边界。文字用 tester 输入，只验证权限拒绝后的编辑与持久化，不作真机输入法结论。本轮没有进行音频提取、ASR、成片导出或相册写入，既有成功提取证据保持。

准备与失败均保留：

- `attempt-01/`：宿主初版只识别 AOSP 权限控制器，实际为 Google 包。电脑按新鲜 XML 补点一次，App 与严格驱动通过，但宿主拒收；不作为最终自动通过。后来按实际节点修正定位器，并用两种包名、其他 App、非视频权限共 6 个正反例核对。
- `attempt-02/`：第一次真实拒绝在 permission_handler 内保存了拒绝历史，恢复 OS 用户标记不能消除它；未决定状态断言正确失败。已核对本机锁定版本 13.0.1 的 `PermissionUtils`，只重置本次拒绝产生的单个视频权限历史标记。没有清 App 数据、卸载或改其他偏好；原 XML 保留在忽略的 originals 中。最终开始前该标记为 false，结束后精确恢复同一份字节，见 `permission-history-preparation.json`、`permission-history-restoration.json`。
- 准备时 ADB 标准输入没有结束，已停止确切自有 ADB 进程并从留存字节恢复指定 XML，改用正确引用的 printf；没有重启 App 测试来掩盖此准备错误。

最终全流程自动运行没有补点，实际拒绝回执在 `android/permission-denial.json`。35 份原有相册媒体的路径、大小及 SHA-256 完全一致，OS 授权状态恢复，插件标记恢复为本轮准备值；转发和自有模拟器已关闭，见 `gallery-before.json`、`gallery-after.json`、`cleanup.json`。没有触及其他设备或相册文件。

全套 1261 App 测试沿 T-40 的有效基线，本轮未重跑；iOS 拒绝证据沿既有记录，本轮没有运行 iOS。正式 186 条定义与统计不变（9 通过、172 部分、5 未执行），只为 TC-18-08、TC-X30 及文字保存提供部分佐证。47 项仍为 7 完成、38 进行中、2 待外部。

进度主表中 T-32、T-43 仍有旧的 iOS 待办，已根据既有补验回执校正；不重复执行或计作本轮新测试。引用文件及摘要在 `progress-corrections.json`，原历史记录保持。

待补：iOS 有限访问、旧 Android 与真机、未下载的云端媒体、实际空间不足、真实 ASR 和最新 Figma。产品、设计、技术及上线基线未改。

`run_android.py` 只面向上述自有模拟器，会核对实际 APK/源码摘要、原生弹框和当前 PID；再次运行前须将现有尝试归档，不能覆盖证据。只读复核可执行 `python3 verify.py`，不会开设备或改权限。
