# T-19 素材页“等待生成”返回（2026-11-02）

App dev `1072ea5`，已提交、未推送。用户已明确批准本轮单批次计划；实现及开发检查完成，待用户验收。

## 交付行为

素材页底部使用原有 `readyCount < requiredCount` 条件：显示“等待生成”时复用左上角 `_back(context, c)`，就绪时沿用 `_shots(context, c)`。原未保存确认、操作中保护及无上一页时回主页面的行为均保留；按钮文案、样式与加载状态沿用现状。代码只修改 `lib/pages/projects/materials/view.dart`，3行增加、1行删除，无API、数据结构、数据库、依赖或后端改动。

## 自动检查

| 检查 | 结果 | 本地记录 |
|---|---|---|
| Dart format | 1份文件无格式变化 | `dart format lib/pages/projects/materials/view.dart` |
| 全项目analyze | 无问题 | [日志](raw/analyze.log) |
| 现有素材页测试 | 45项通过 | [日志](raw/material-list-test.log) |
| Android debug受控入口构建 | 通过 | [日志](raw/device-build.log) |
| diff / 暂存diff检查 | 通过 | 生产代码仅上述按钮回调变化 |

测试日志含既有1像素夹具图片的解码提示，套件最终45项通过；未把这些提示当作真实图片验收。没有为本次低风险回调调整新增仓库测试。

## 固定池电脑控机

领取 `Catdrama_Editor_20261025`，Pixel 4配置 / Android 17 API37，1080×2280，ADB `emulator-5554`。[设备信息](raw/device.json)。生产 `MaterialsPage`、`ProjectDetailPage`、`ShotsPage` 在本地debug安装包中运行，电脑通过现有 `phone-ui/device_drivers.py` 的ADB驱动完成点击及截图。

接口数据来自隔离协议夹具；未保存草稿和操作中状态由控制端准备，其后点击及返回确认均走真实页面逻辑。无上一页时的主页面为路由探针，仅用于核对 `RouteName.main`。受控[入口源码](raw/main.dart)、[可读控机脚本](raw/desktop_check.py)、[逐步记录](desktop-check/events.jsonl)及[12项结果断言](raw/assertions.json)仅在本地保存。

| 场景 | 实际结果 | 截图 |
|---|---|---|
| 等待状态底部返回 | 返回作品201详情，素材确认和写请求均为0 | [等待页](desktop-check/S003-waiting-stable.png)、[底部返回后](desktop-check/S002-wait-return.png) |
| 左上角返回对照 | 与底部返回同为 `projectDetail` / `/projects/201` | [对照](desktop-check/S004-header-return.png) |
| 未保存修改 | 弹出原放弃确认；取消留页且草稿仍在 | [确认](desktop-check/S006-dirty-confirmation.png)、[取消留页](desktop-check/S007-dirty-cancel-stays.png) |
| 确认放弃修改 | 返回作品详情，无写请求 | [结果](desktop-check/S009-dirty-discard-returns.png) |
| 素材就绪 | 3/3显示“进入镜头制作”；点击进入真实视频编辑页，仅1次原素材确认 | [就绪页](desktop-check/S015-ready-final-stable.png)、[镜头页](desktop-check/S011-ready-enter-shots.png) |
| 无上一页 | 返回 `RouteName.main` | [结果](desktop-check/S013-standalone-fallback-main.png) |
| 操作中保护 | 底部显示原加载态；点击底部或左上返回均留页，无新增写请求 | [加载态](desktop-check/S016-working-protected.png)、[底部点击后](desktop-check/S017-working-bottom-stays.png)、[返回点击后](desktop-check/S018-working-header-stays.png) |

S001为启动屏，S010为切页绘制中的不完整帧，均保留但不作为页面通过证据；就绪状态以随后稳定截图S015为准。已实际查看等待、确认、取消、就绪、镜头及加载状态截图。本轮只调整点击行为，不宣称全页Figma像素验收。

## 验证与交付边界

受控请求记录证明上述返回操作未触发新的生成、素材确认或取消请求；没有运行真实云端任务，云端持续执行仍沿用现有返回处理，不将本次结果扩展为真实Provider、OSS、计费、真机或正式渠道验收。未部署、未更新用户真机包；正式验收统计保持。

本轮App进程已停止、18759端口转发已移除、模拟器已关闭并按原owner/token释放。[释放回执](raw/release.json)。首次释放遇到模拟器退出瞬间的识别错误，待设备列表确认关闭后使用同一租约重试成功，未改池配置或其他租约。

当前版本产品四文档、开发计划和测试记录已同步。共享工作区仍有迁移及并行文档改动，本轮不把整份既有修改混入提交；测试截图、原始响应、日志、脚本和APK保持本地，未提交Git。
