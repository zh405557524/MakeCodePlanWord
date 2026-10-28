# T-23 图片误报“已到期”与 OSS 上传阻塞修复

2026-10-28，用户截图并明确要求修复。源码与开发检查完成，App dev `6f96fe1`、共享后台 dev `080c778e`，均未推送。运行中共享后台未重启，用户实体机未安装新包，原图真实交付尚未确认。

## 现场与原因

素材“林晚记忆中老家客厅（十六年前）”的原生成任务 `2115380370103685121` 已生成图片，但独立保存任务 `2115382383545765889` 仍在 `STORE_MEDIA_RESOURCE`。只读查询显示版本是 `PROCESSING`，资源未落库、成功时间和到期时间均为空，不能判定为到期。原始白名单字段见 [live-readonly.json](live-readonly.json)。查询采用 PostgreSQL 只读事务，无业务写入。

前端原来把“不可应用”统一当作“已到期”，并把来源生成任务的 `SUCCEEDED` 当成整个交付结束；保存阶段没有 activeJob 时重进页面不会恢复订阅，处理结果改变也不能触发重新读取历史。

运行日志有 OSS `Broken pipe` 和 `Resetting to invalid mark`。10:59 UTC 的线程快照显示 `catdrama-job` 在 `NioSocketImpl.implWrite → OSSClient.putObject → AliyunOssChannelProvider.uploadLocalFile → DramaImageProcessService.store` 阻塞，相关线程已存在约 1,487 秒。现有连接/读取超时没有覆盖该网络写入；普通文件 InputStream 的重试缓冲也无法重放较大请求体。

## 修复

- 图片预览、缩略图、历史统一区分处理中、审核拒绝、失败、真正到期和资源不可用。处理中展示加载提示，禁用重复生成/应用。
- 重进页面依据 `latestGeneration` 或图片原 jobId 继续查询同一任务；以 `job.terminal` 等待处理结果，处理状态/版本/原因变化会刷新。处理成功自动显示候选，保留用户主动选择的历史图和当前应用关系。
- OSS 使用 SDK 的文件上传请求，重试能从文件开头读取，原私有 ACL 和对象 key 保持。仅服务器上传开启请求总超时，默认单次请求 300,000 毫秒，可通过 `app.oss.aliyun.upload-request-timeout-ms` 调整；签名读取和直传配置保持。超时返回原上传失败边界，由既有任务机制恢复，不另发 AI 生成请求。
- 使用本机依赖 `aliyun-sdk-oss 3.18.5` 源码核实文件重放和 `TimeoutServiceClient` 的请求取消行为；SDK 参数说明参见[官方 ClientConfiguration 文档](https://gosspublic.alicdn.com/AliyunJavaSDK/3.13.2/javadoc/com/aliyun/oss/ClientConfiguration.html)。

## 验证

| 范围 | 结果与证据 |
|---|---|
| 修前前端复现 | 2 条处理恢复用例失败，未找到应继续跟踪的原任务；[日志](flutter-before.log) |
| 前端相关回归 | 工作台、素材、列表、自动入库及定位共 192 项通过；[日志](flutter-regression.log) |
| 最终文案复检 | 审核缩略图使用短文案避免孤字换行后，52 项工作台回归通过；[日志](flutter-final-workbench.log) |
| 静态与构建 | format/diff 检查通过，完整 analyze 0 问题；[analyze](flutter-analyze.log)、[普通 main.dart APK](android-main-build.log)、[隔离页面 APK](android-fixture-build.log) |
| 桌面 ADB 控机 | 5 条实际页面操作通过，截图/XML/控制器状态逐步记录；[脚本](desktop_check.py)、[结果](desktop-result.json)、[日志](desktop.log) |
| 修前后台复现 | 实际 SDK + 本机 HTTP：大文件重放、写入停滞两项失败，原有 9 项通过；[日志](oss-before.log)、[XML](oss-before.xml) |
| 修后后台回归 | OSS 11 项、签名 URL 14 项、生成图暂存恢复 12 项，共 37 项通过；[日志](oss-after.log)及同目录 JUnit XML |

前端命令：

```sh
flutter test --no-pub test/assets/image_workbench_test.dart test/assets/asset_test.dart test/assets/material_list_test.dart test/assets/auto_library_test.dart test/assets/image_library_focus_test.dart --reporter expanded
flutter analyze --no-pub
flutter build apk --debug --no-pub -t lib/main.dart
```

后台命令：

```sh
./gradlew test --tests '*AliyunOssChannelProviderTests' --tests '*ManagedOssReadUrlServiceTests' --tests '*AiGeneratedImageStagingTests'
```

桌面使用独立只读 Android AVD `Catdrama_T17_QA_20261015`、`emulator-5580`，运行正式页面与控制器，数据/图片/HTTP 受控。用 ADB 点击重新生成和图片历史，通过回环控制接口改变服务结果；成功转换由正常轮询触发，未强制刷新。原生入口为 App `test_driver/material_processing_desktop.dart`。完成后移除端口映射并关闭本轮模拟器，没有操作连接着的实体手机。

| 用例 | 核查点 | 图 |
|---|---|---|
| IP-01 | 处理中不显示到期，应用禁用，点击重新生成不提交 | [处理中](01-processing.png)、[点击后](02-processing-no-resubmit.png) |
| IP-02 | 图片历史中的处理中版本不显示到期 | [历史](03-processing-history.png) |
| IP-03 | 同一生成任务只改变处理状态，页面自动显示可应用候选 | [成功](04-success-auto-refresh.png) |
| IP-04 | 审核拒绝显示原因，允许重新生成 | [拒绝](05-rejected.png) |
| IP-05 | 确实过期仍显示到期，全程业务写入数为 0 | [过期](06-expired.png) |

上述系统截图均目视检查；成功图片是应用自带的受控示例，不是用户那张生成图。视口为 1344×2992，不宣称与 375×812 Figma 像素对齐。

## 过程中修正与验证边界

早期测试辅助函数顺序、休眠计时器的初次刷新，以及单次命令误引用不存在的测试文件均已纠正。补充旧用例发现成功夹具仍只返回旧 result、未声明 processing 终态；按当前实际后端契约补齐处理成功及版本 ID 后，192 项全部通过。此失败日志保留在 [flutter-initial-contract-fixture-failure.log](flutter-initial-contract-fixture-failure.log)。原生 driver 的一项花括号 lint 已修正，最终 analyze 通过。

后台失败复现是 2 MiB 请求体读完后返回一次 503，以及 16 MiB 请求体被对端停止读取；修后重试全文及私有 ACL 一致、阻塞请求受限并保留源文件。它证明实际 SDK 的本地网络行为，不代表真实阿里云网络已恢复。

现场最后一次查询仍未取得资源。新后端代码需要更新运行进程，新前端需要更新安装包才能生效；本轮未重启共享服务、未部署、未新建生成、未人工改任务状态或补扣积分，未进行真实 Provider/OSS/实体机交付验收。正常 Android 测试包位于 `/Users/soul/code/lxwx/catdrama/build/app/outputs/flutter-apk/app-debug.apk`，已在隔离入口验证后重新按 `lib/main.dart` 构建。

数据库改动：无。无迁移、私有配置、接口契约或依赖变更。原 App iOS 工程和后台并行工作保持，正式任务/用例计数不调整。
