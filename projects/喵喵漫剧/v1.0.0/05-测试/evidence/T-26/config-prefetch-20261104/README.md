# T-26 / M08 生成按钮复用预加载配置

状态：实现与本地开发检查完成，待用户验收。2026-11-04（America/Los_Angeles）。用户确认：配置可以提前加载，点击生成不应先等一次完整配置请求。

## 实现

App dev `dda2b4e`。现有视频页进入时已通过 `_loadConfig` 预加载配置；原 `generateVideoBatch` 每次点击仍直接请求 `/api/drama/config`，且早于加载面板。现在从 `ConfigStore.currentDramaConfig` 读取当前环境缓存，只检查批量数量上限；缓存为空时直接正式报价，沿后端现有 `DramaQuoteService` 数量限制校验。正式报价、确认、任务、幂等流程和价格规则保持。

只改 shots/index.dart、shots/generation.dart 和 video_generation_test.dart。保留原有失败展示等未提交工作。本切片无后端、数据库、接口结构、依赖或布局修改。

## 验证

| 检查 | 结果与边界 |
|---|---|
| dart format / flutter analyze --no-pub | 通过，无问题 |
| flutter test --no-pub test/shots/video_generation_test.dart | 79 项通过，包含本地已有失败恢复用例 |
| 本次提交独立源码快照 | 5 项定向通过：缓存+慢报价、配置加载中、配置失败、数量超限、受理后原任务保护；analyze 无问题 |
| Android profile 构建 | 通过；生产页面/控制器，HTTP 与素材为受控夹具 |
| 固定池 Android 桌面 ADB | CP-01～06 通过，界面由桌面点击，未通过控制器方法代替点击 |
| 视觉核对 | 已查看原加载面板、稳定24积分确认与报价错误截图；未改视觉稿，不宣称 Figma 像素验收 |

新增用例验证缓存读不会重发配置；配置加载中或失败仍能报价；慢报价完成前已有原加载面板。已有超限、取消、未知任务与防重复提交检查继续通过。首轮 analyze 的两个测试代码样式提示已修复，复检无问题。

## 桌面用例

前置：固定池 Android 手机，进入受控视频编辑页；进页配置响应延迟2秒。报价由夹具闸门挂起，桌面可解除；测试中不提交真实任务。

| 用例 | 操作 | 预期与实际 |
|---|---|---|
| CP-01 | 打开页面，等预加载完成 | 配置请求1次，未创建报价或任务 |
| CP-02 | 点击“生成全部2个镜头”，保持报价挂起 | 原加载面板可见；配置仍1次；任务0 |
| CP-03 | 解除报价闸门 | 24积分正式确认可见，配置仍1次 |
| CP-04 | 点击取消 | 返回可生成状态，任务0 |
| CP-05 | 再点击全部，保持新报价挂起 | 再次显示加载面板，配置仍1次 |
| CP-06 | 解除闸门并返回受控报价失败 | 显示原错误提示，释放生成入口，配置仍1次，任务0 |

被动观察记录：两次从 Flutter 收到按钮 pointer-down 到 EasyLoading show 完成后的帧回调分别为389ms、301ms，均发生在报价被挂起时。该数值包含加载进场动画和帧回调开销，是本次模拟器受控观测，不等同于真实手机首帧或线上接口性能。

截图：[加载中](03-loading-before-quote.png)、[稳定积分确认](05-cancel.png)、[报价失败](09-quote-error.png)。04-confirm-24-points.png 是加载退场与确认进场的过渡帧，稳定态以05为准。完整操作及请求序列见 device-events.json。

设备：池内 Catdrama_Editor_20261025，Pixel 4、API37、1080×2280；租约 owner 为本聊天本切片，ADB序列号经AVD名核对。结束后已停止本任务App、移除18349转发、关闭设备并归还原租约，未新建或重置设备。

## 复核入口与未验边界

- App：`/Users/soul/code/lxwx/catdrama/.test/config-prefetch-20261104/` 内 desktop_app.dart、run_phone.py、独立源码 commit-check/ 与日志。
- 截图、原始日志、接口记录、APK、夹具与快照仅本地；仅本说明参与Git。
- 本次未改后端，未重新执行后端数据库测试。数量限制已从正式报价源码核对。
- 未推送、未部署、未更新用户物理手机。真实服务、Provider、OSS、扣费、物理设备及iOS未验；整版正式验收计数不变。
