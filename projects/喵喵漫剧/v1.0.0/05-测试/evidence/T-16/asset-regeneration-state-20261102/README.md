# T-16 资产重新生成状态显示修正（2026-11-02）

App dev `94856af`，未推送。用户反馈“重新生成时列表与详情都不显示正在生成”；本轮实现及开发检查完成，待用户验收。前轮入口拦截与创建页取消帮写见[原报告](../asset-entry-form-20261102/README.md)，历史记录保留。

## 根因与行为

旧图文件在 `AssetMedia` 中先于任务状态渲染，遮住重新生成/后处理。详情只读资产资源，原生成所有者仅在完成时通知资源变化，开始和处理中没有展示通知。

本轮为列表与详情传入图片展示阶段，活动阶段优先于旧图；现有图片生成所有者发布开始、后处理和结束的只读阶段，页面被动接收。查看或重开已有详情不创建任务所有者、不查询或恢复历史任务。明确拒绝或任务消费完成后清除，未知提交继续原请求。原图文件保留供失败回退；手选历史图保持所选图，底部显示阶段并禁止重复生成。后端、数据接口、计费及生成提交/应用规则保持原范围。

## 自动检查

| 检查 | 结果 | 证据 |
|---|---|---|
| 修改前复现 | 3条失败，均缺少生成/处理文字 | [修复前日志](raw/before-tests.log) |
| 旧图展示与详情受理回归 | 通过 | 合入最终资产/报价套件；覆盖列表RUNNING/PROCESSING和详情实际报价入口 |
| 生命周期定向 | 3项通过 | [日志](raw/lifecycle-tests.log)：成功、后处理失败、明确拒绝后可再试 |
| 资产+报价模块串行 | **392通过、4失败** | `flutter test --no-pub --concurrency=1 test/assets test/generation/quote_test.dart`，[日志](raw/regression-serial.log) |
| 首轮并发差异复核 | 六种创建单独与最终串行通过 | 首轮391通过、5失败，另有角色创建手稿时序失败；[首轮](raw/regression-tests.log)、[创建复跑](raw/creation-rerun.log)，不隐去初次失败 |
| 全项目analyze | 无问题 | [日志](raw/analyze-final.log) |
| format / diff检查 | 通过 | 13份修改Dart文件格式无变化，提交前diff与暂存diff检查通过 |
| Android debug最终构建 | 通过 | [日志](raw/device-build-final.log)，本地受控入口复用生产页面 |

4项与前轮隔离源码对照相同的既有失败：`sound_profile_test` 报价夹具Map类型；`auto_library_test` 新结果预览5514/5512差异和失败任务保护两项；`image_batch_test` 小屏弹框pumpAndSettle超时。本次未扩大到这些独立问题，不将全套记为通过。[前轮对照记录](../asset-entry-form-20261102/README.md)。

新增生命周期Widget用例同时验证：原图存在、生成/后处理占位、返回列表禁入、重进详情只读阶段、成功选新图/失败保旧图、一次提交，以及详情资源请求继续使用 `includeGeneration=false`。既有历史手选、会话隔离、未知请求与资源独立读取回归也在本次套件内通过。

## 固定池电脑控机

实际业务页面运行在领取的 `Catdrama_Editor_20261025`，Pixel 4 / Android 17 API37，1080×2280，ADB emulator-5554。电脑通过工作区 `phone-ui/device_drivers.py` 的 AdbDriver 点击、返回和截图，逐步[操作记录](desktop-check/events.jsonl)与[可读脚本](raw/desktop_check.py)保留。数据来自本地协议夹具，点击真实的“重新生成”及积分确认按钮；非Widget截图。两轮各确认一次，提交计数均为1。

| 检查 | 实际结果 | 页面证据 |
|---|---|---|
| 旧图重新生成详情 | 主图显示生成中，底部生成中且禁用；旧图版本5511仍保留 | [最终构建详情生成中](desktop-check/S021-final-detail-generating.png) |
| 返回资产库 | 卡片显示角色生成中，点击仍停留资产库 | [生成状态](desktop-check/S012-library-generating.png)、[点击后](desktop-check/S013-library-generating-blocked.png) |
| 列表后处理 | 卡片显示图片处理中，点击仍停留资产库 | [处理状态](desktop-check/S014-library-processing.png)、[点击后](desktop-check/S015-library-processing-blocked.png) |
| 成功后恢复 | 自动选用5512，列表恢复图片，实际点击可进入详情 | [列表](desktop-check/S016-library-succeeded.png)、[详情](desktop-check/S017-detail-after-success.png)、[版本回执](raw/detail-after-success.json) |
| 详情后处理 | 主图和底部均显示图片处理中 | [最终构建处理中](desktop-check/S022-final-detail-processing.png) |
| 失败后恢复 | 旧图5511恢复、重新生成按钮可用；返回列表并再次点击可进入 | [详情恢复](desktop-check/S023-final-detail-failed-old-image.png)、[列表恢复](desktop-check/S024-final-library-after-failure.png)、[重进详情](desktop-check/S025-final-detail-reopened-after-failure.png) |

[11项稳定状态/请求断言](raw/assertions.json)通过；覆盖确认前无提交/任务查询、生成中保留旧版本、列表后处理、成功/失败恢复及每轮仅一次提交。控制接口响应可能在异步页面通知前捕获旧阶段：详情PROCESSING即时响应仍为generating，随后S022已显示处理中；[即时差异](raw/immediate-processing-observation.json)保留，不把该即时快照记为通过，页面阶段以随后实图核验。

S008～S017为首轮构建，S018～S025为最终构建。最终构建保持所有activeJob均拦截的既有口径；两轮使用相同展示逻辑。新旧图片复用同一张自有素材作为夹具，选图成功依据真实页面状态与版本回执，不以图片外观差异推断。构建与生产源码[哈希](raw/source-hashes.json)保留，安装包仅在App `.test/asset-regeneration-state-20261102/`本地保存。

首次领取Pixel_9_Pro_XL后，App无法解析启动Activity，设备停在RUNNING_LOCKED；同设备冷启动仍未恢复。S001～S006保留为环境尝试，不记业务通过。已关闭释放后按池轮转领取上述Pixel 4，未创建、重置或删除设备。两台设备均已关闭并按各自owner/token释放；App已停止，端口转发已删除。

## 交付边界

本轮完成代码、产品正文/清单/评审、设计说明及开发/测试文档同步。共享工作区仍有既有文档迁移及其他任务改动，正文同步保留在工作树，本报告独立提交，未将整份迁移文档混入。App已有 `.gitignore` 改动保留；截图、日志、接口响应、临时入口和APK不进入Git。

已检查实际页面的生成、处理与恢复状态，复用现有Figma来源占位组件和文案，不新增图标或说明。本轮不宣称全页Figma像素验收；真实Provider、OSS、真实扣费、真机、正式渠道和生产部署未执行，原186条正式用例的验收统计保持。
