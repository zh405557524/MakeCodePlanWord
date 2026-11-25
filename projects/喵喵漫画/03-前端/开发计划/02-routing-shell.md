# 02 路由与主框架模块开发文档

> 对应任务：T-F002
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责注册资产库、统一空白页和底部导航行为。P0 只按 Figma 细化首页与资产库；“我的”完整复用旧 `AccountPage`；其它原工程没有的页面先空白展示，保证入口可达且不会进入旧真实生成/作品详情链路。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/routes/name.dart` | 新增 `assetLibrary` 和统一空白页路由名 |
| `lib/routes/router.dart` | 注册 `/assets` 与统一空白页路由 |
| `lib/pages/main/controller.dart` | 保留创作、作品、我的三项；作品切到占位内容，我的切到旧 `AccountPage` |
| `lib/pages/main/view.dart` | 底部导航保持三项，资产库从首页入口进入，我的复用旧账号页 |
| `lib/pages/asset_library/*` | 资产库页面 |
| `lib/pages/feature_placeholder/*` | 统一占位页 |

## 3. 依赖前置

- 依赖 T-F001 项目标识迁移。
- 占位页依赖 T-F008；本模块先预留路由。
- Java 无直接依赖。

## 4. 视觉参考与设计稿分析

参考当前 Figma：

- 首页 `97:102`：AI 漫剧入口、资产库入口、底部导航。
- 资产库 `97:2345`：顶部标题、设计入口、资产 Tab、管理入口、底部导航。
- 其它 Frame 本期不按细节还原；原工程没有的页面先空白展示。

当前无导出图片文件，视觉以 Figma Frame 名称和状态清单为准。

## 5. 涉及模块与类

- `RouteName`
- `CustomRouter`
- `MainController`
- `MainPage`
- `AccountPage`
- `AssetLibraryPage`
- `BlankFeaturePage`

## 6. 业务内容与数据流

```text
首页入口点击
  -> go_router named route
  -> 资产库 / 空白页
  -> 空白页不调接口
```

作品底部 Tab 保持占位。我的底部 Tab 完整复用旧 `AccountPage`，并保留旧页面内登录态、积分、VIP、邀请、反馈、设置、订单和充值等二级入口。

## 7. 现有工程参考点

- `lib/routes/index.dart` 已通过 `part 'name.dart'`、`part 'router.dart'` 组织。
- `lib/pages/main/view.dart` 已使用 `IndexedStack` 和 `BottomNavigationBar`。
- 当前已有旧 `/creation/video`，首页 AI 漫剧入口不得继续跳到该真实创建页。

## 8. 建议实现步骤

1. 在 `RouteName` 增加资产库和占位页命名。
2. 在 `CustomRouter.config` 增加对应 `GoRoute`。
3. 首页入口接新路由。
4. 作品 Tab 保持空白页。
5. 我的 Tab 接回旧 `AccountPage`，完整复用二级入口。
6. 其它后续功能入口点击进入空白页或保持空白内容。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F002-1 | `routes/name.dart` | 路由名完整且不含混淆命名 |
| T-F002-2 | `routes/router.dart` | 资产库和空白页路由可打开 |
| T-F002-3 | `pages/main/*` | 底部导航三项稳定 |
| T-F002-4 | 首页入口 | AI 漫剧不进入旧创建页，资产库进入新页面 |

## 10. 验收标准

- `/assets` 可打开资产库。
- 首页和资产库按 Figma 可达；其它入口可打开空白页。
- 作品保持空白占位；我的展示旧账号页，并保留旧页面内二级入口真实行为。
- 返回策略稳定，不出现黑屏或路由异常。

## 11. 编码注意事项

- 其它页面先走统一空白页，不按后续 Figma Frame 细化。
- 不删除旧路由，先断开 P0 用户入口。
- 涉及路由后执行 `flutter analyze`，必要时补路由测试。
