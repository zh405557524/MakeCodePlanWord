# 07 Profile 个人页 Figma 对齐模块开发文档

> 关联任务：CHG-0011 / CHG-0044  
> 当前状态：done  
> 当前视觉真源：Figma 节点 `81:559「个人」`，通道 `izgtjar9`（替代原节点 `67:90`）  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/pages/account/view.dart`、`lib/utils/assets.dart`、`assets/images/icon_home_points_*.png`、`test/widget_test.dart`

## 1. 模块目标

仅调整个人页内容，保持共享三 Tab 底部导航、现有积分/会员/profile 数据链路、隐私同意和登录门禁不变，不新增接口、Controller、Model 或路由。

## 2. 视觉结构

- 页面宽度基准：375，背景 `#010101` 并复用现有个人页背景资源。
- 顶部操作：积分胶囊和设置按钮高 28，右边距 18，间距 15。
- 用户信息：头像 `83 × 83`，左 23、上 95；用户名 24 px。
- VIP 卡：左/右边距 15，主体 `345 × 83`，圆角 12；VIP 标识保持向上探出效果。
- 菜单从 y=328 开始，每项 `345 × 60`，圆角 18，间距 13。
- 底部保留 124 px 内容避让，确保共享底部导航不遮挡末项。

## 3. 菜单与交互

| 顺序 | 菜单 | 图标 | 行为 |
|---|---|---|---|
| 1 | 积分充值 | Figma 导出 PNG | `RouteName.pointsRecharge` |
| 2 | 积分福利 | 复用既有图标 | `RouteName.taskCenter` |
| 3 | 订单列表 | 复用既有订单图标 | `RouteName.paymentOrders` |
| 4 | 积分明细 | Figma 导出 PNG | `RouteName.pointsLedger` |
| 5 | 邀请好友 | 复用既有图标 | 保持当前推广素材入口行为 |
| 6 | 联系客服 | 复用既有图标 | 保持当前客服静态页行为 |
| 7 | 意见反馈 | 复用既有图标 | `RouteName.feedback` |
| 8 | 更多设置 | 复用既有图标 | `RouteName.settings` |

顶部积分余额与“积分充值”统一进入 `pointsRecharge`；“订单列表”进入 `paymentOrders`；“积分明细”进入原积分详情 `pointsLedger`。顶部积分、积分充值、积分福利、订单列表、积分明细和邀请入口继续通过 `_openWhenLoggedIn` 复用隐私同意与登录校验。

## 4. 图片资源

- `icon_home_points_recharge.png`：22 px 设计尺寸，提供 1x/2x/3x。
- `icon_home_points_ledger.png`：24 px 设计尺寸，提供 1x/2x/3x。
- 两组资源直接从 Figma 节点导出，并在 `AppAssets` 注册；其他五个菜单图标不重复制作。

## 5. 业务边界

- 保留 `AccountController.loadProfile()`、`UserStore` 积分/会员状态和现有刷新逻辑。
- 保留用户已有 `AppRefreshIndicator` 修改。
- 不改积分充值页、积分明细页、任务中心、会员页自身 UI。
- 不改共享底部导航，不增加兑换码可见入口；订单列表仅复用现有页面和深层路由。

## 6. 验证与结果

- [x] `375x812` 与 Figma 同视口比较，头像、顶部操作、VIP 卡、菜单尺寸和间距无 P0/P1/P2 差异。
- [x] `390x844`、`414x896` 八项菜单可滚动到达，无溢出。
- [x] 登录用户点击顶部积分、积分充值、订单列表、积分明细、积分福利进入正确页面。
- [x] 游客点击顶部积分、积分充值、订单列表、积分明细统一进入登录页。
- [x] `flutter analyze` 通过。
- [x] 个人页 4 项定向 Widget 测试通过。
- [x] 完整 `flutter test` 已启动；仓库既有 `????` 占位断言首先失败，随后持续产生 `pumpAndSettle` 连锁超时，运行 5 分 13 秒后终止；该基线不属于 CHG-0044。
- [x] Design QA 报告：`/Users/soul/code/lxwx/catsinger/design-qa.md`，`final result: passed`。
