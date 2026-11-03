# T-23/T-24 作品素材生成、应用与框选修复（2026-11-02）

实现与开发检查完成，待用户验收。App dev `f6ae99d`、`645c810`；后端 dev `bc7aaf76`，均未推送。保留共享工作树中的视频、邀请和文档迁移改动，未重启或部署共享业务服务。

## 交付行为

| 条件 | 页面结果 |
|---|---|
| 首次无图且无生成记录 | 底部“生成素材”；来源或报价取消不改变首次状态 |
| 提交未知、生成、保存、审核 | 底部“生成中”并禁用，继续原请求，重复点击不新提交 |
| 明确成功或失败 | 底部“重新生成”；失败保留原应用图 |
| 单张作品首图 | 原输入未改且当前仍为空时，在服务端发布事务内自动应用；已有应用图时新结果为候选 |

右侧框选表示主图当前预览。进入页面默认应用图，新任务默认跟随到真实版本；手选优先。失败项不可应用，成功可用且未应用才开放右上角“应用”。当前引用缺少于历史第一页时补入展示，选中项超出右侧可视区时自动定位，原历史顺序保持。重进页面恢复当前入口的原请求并消费终态回执，避免已完成仍显示生成中。

服务端复用 `FIRST_SUCCESS_IF_EMPTY`，不新增 HTTP 字段或策略枚举；原已受理快照和历史候选不回填。共享素材沿原身份更新引用；发布与应用保留原事务、手改保护、引用保护及账务幂等。

## 自动检查

| 检查 | 实际结果 | 证据 |
|---|---|---|
| 工作台及自动入库 | **74 项通过** | [最终日志](raw/app-final-74.log)，含三类首次、取消、任务转版本、后处理/拒绝、手选/重进、未知提交、分页及长历史选中可见 |
| 末轮排序/原回执定向 | 5 项通过 | [日志](raw/app-final-selection-verified.log)；末轮可见性补丁后重新执行上方完整 74 项 |
| 修改范围 analyze | 无问题 | [最终日志](raw/analyze-complete.log) |
| format / diff | 通过 | [format](raw/format-delivery.log)，提交前 diff/cached diff 检查通过 |
| Android debug 构建 | 通过 | [最终包构建](raw/device-build-rail.log)；[页面源码与包哈希](raw/source-hashes.json) |
| 后端核心 | **23 项通过** | [日志](raw/backend-core-tests.log)、[XML](raw/backend-core/TEST-com.lxwx.narrateservice.CatdramaAssetLibraryTests.xml)；真实 Spring/隔离 PG，模型与 OSS 为受控边界 |
| 后端入库及批量扩大回归 | **58 通过、5 失败** | [日志](raw/backend-final-regression.log)、[XML](raw/backend-final/)；5 个失败在修改前业务源码中复现，未记全套通过 |
| App 资产/报价扩大回归 | **167 通过、1 失败** | [日志](raw/app-final-regression.log)；小屏批量弹框 `pumpAndSettle` 超时与[改前基线](raw/app-baseline-tests.log)一致；之后仅重跑受本轮变化影响的 74 项 |

后端扩大回归的 5 个既有失败：删除作品后原任务预期 FAILED、实际 SUBMIT_UNKNOWN（1 项）；机审通过/等待场景按旧任务关联查询审核记录，预期 2 条、实际 0 条（4 项）。另按计划运行的 `CatdramaImageTests` 为 43 项中 26 项失败，主要包括旧存储元数据 `imageVersionId` 断言及恢复/冻结状态；[修改前隔离源码](raw/backend-baseline/)同样复现这 26 项。本轮没有扩大修改这些业务或放松生产校验。

首次回归暴露旧夹具缺少 MATERIALS 阶段，已仅补入库/批量夹具前置。首图改为自动应用后，旧批量报价因绑定 revision 改变而失效；更新断言并另补旧候选快照继续排除批量的用例。原始失败记录保留在 raw，不把编译、夹具或退出码代作真实渠道验收。

## 电脑控机与实图

实际使用领取的 `Catdrama_Editor_20261025`（Pixel 4，Android 17/API37，1080×2280，无 Play Store），由工作区 `AdbDriver` 点击、返回、启动和截图。运行生产素材页/Controller，HTTP 来自独立本地协议夹具；不是 Widget 截图或真实 Provider 出图。

[可读控机脚本](raw/desktop_check.py)、[HTTP 夹具](raw/desktop_server_test.dart)、[逐步记录](desktop-check/events.jsonl)、[18 项断言](raw/desktop-assertions.json)已保存。四次确认各提交一次，包含两次禁用按钮点击后仍为四次；没有真实收费。

| 检查 | 画面与实际状态 |
|---|---|
| 首次及取消 | [来源取消](desktop-check/S004-cancel-source-keeps-first-action.png)、[报价取消](desktop-check/S007-cancel-quote-keeps-first-action.png)：仍为生成素材，无提交 |
| 正在生成 | [首个真实任务项](desktop-check/S010-first-generating.png)、[重复点击](desktop-check/S011-generating-tap-does-nothing.png)：主图/框选同为任务 901，底部生成中禁用 |
| 首图后台完成 | 在 PROCESSING 时停止 App，再让夹具成功；[重新启动](desktop-check/S014-first-applied-and-ready.png)已应用 5521，回执已消费，底部重新生成 |
| 有旧图重新生成 | [生成中](desktop-check/S017-regenerate-current-task.png)、[处理中](desktop-check/S019-regenerated-processing.png)、[成功候选](desktop-check/S020-regenerated-candidate-keeps-original.png)：任务 902 转版本 5522，原应用 5521 保留 |
| 手选保护 | [生成期间点旧图](desktop-check/S024-manual-old-preview-during-generation.png)、[完成后](desktop-check/S025-success-preserves-manual-preview.png)：主图/框选保持 5521，底部独立显示任务状态 |
| 失败及历史 | [失败](desktop-check/S029-failed-current-item-can-regenerate.png)、[弹窗](desktop-check/S030-history-current-failed-selection.png)：失败 5524 被框选，不能应用，可重新生成；[选历史候选](desktop-check/S031-history-candidate-updates-main-and-border.png)同步主图及框选 |
| 长历史默认项 | [修正前可视区遗漏](desktop-check/S033-final-default-applied-selection.png)、[最终实图](desktop-check/S035-final-visible-applied-border.png)：选中 5521 定位到右侧可视区；原生节点 selected=true，bounds=[824,557][1040,698] |

S001 为启动画面，不算业务通过。S001～S012 在补“重进消费回执”前构建；S013～S033 验证该修正；S034～S035 使用最终可见性补丁构建。末轮五份页面源码与设备构建逐份哈希相同。已查看首次、生成中、首图应用、候选、手选、失败、历史及最终选中可见实图；参考既有留存 Figma 稿和用户截图，未取得当前 Figma 通道，不宣称整页像素验收。

图片是自有产品风格图夹具，多版本复用同图；版本选择以真实页面状态/原生选中节点和回执 ID 核对，不以外观相似推断应用。角色/场景/道具方法检查通过，设备视觉流程使用场景页。

最初领取 Pixel 5 时最终更新包安装因存储不足失败，未清理数据；关闭释放后改领上述 Pixel 4。两台设备均已关闭并释放各自租约，端口转发及本任务服务已停止，无新建、重置、删除设备或扩大池。

## 数据库与交付边界

数据库结构/迁移改动：无。仅新任务发布按现有应用图、revision、绑定和资源引用字段更新；无存量回填、删库、repair 或业务数据修复。测试只使用本任务隔离 PG/schema，测试实例已停止；共享本机业务库、测试服及正式服未执行变更。

本轮已同步产品正文/清单/评审/检测、设计说明、接口和开发/测试记录。共享工作区保留既有文档迁移，报告独立提交，不混入整份迁移文档。截图、安装包、日志、原始响应与临时入口只在本地保留，不进入 Git。

真实 Provider、真实 OSS、真实积分扣费、物理手机及部署未执行。功能修复和开发检查不等同正式业务验收；原正式用例统计保持。
