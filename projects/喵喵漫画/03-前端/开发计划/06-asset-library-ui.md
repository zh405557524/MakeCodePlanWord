# 06 资产库 UI 模块开发文档

> 对应任务：T-F006
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责资产库页面 UI：标题、角色/场景/物品设计入口、资产 Tab、资产网格、管理入口和基础状态容器。数据请求由 T-F007 承接。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/pages/asset_library/index.dart` | 新增页面聚合 |
| `lib/pages/asset_library/controller.dart` | 基础 tab 和 UI 状态 |
| `lib/pages/asset_library/view.dart` | 页面布局 |
| `lib/pages/asset_library/widgets/*` | 设计入口、资产 Tab、资产卡片 |
| `lib/routes/*` | 路由 `/assets` |

## 3. 依赖前置

- 依赖 T-F002 路由。
- 依赖 T-F003 主题组件。
- 数据依赖 T-F007。

## 4. 视觉参考与设计稿分析

参考当前 Figma Frame：`资产库` / `97:2345`。

从上到下区块：

1. 375 x 812 深色背景。
2. 顶部居中标题 `资产库`。
3. 三个设计入口：`角色设计`、`场景设计`、`物品设计`。
4. 资产 Tab：`角色资产`、`场景资产`、`物品资产`，默认选中角色资产。
5. 右侧 `管理` 文案入口。
6. 双列资产卡片，卡片文案为 `角色名称`，图片上有圆角封面。
7. 底部导航：`创作`、`作品`、`我的`。

状态来自 `figma-design-plan.md` 5.2：默认、Tab 切换、加载、空态、错误、图片失败、管理占位。

## 5. 涉及模块与类

- `AssetLibraryPage`
- `AssetLibraryController`
- `ComicAsset`
- `ComicAssetType`
- 设计入口组件
- 资产 Tab 组件
- 资产卡片组件

## 6. 业务内容与数据流

```text
AssetLibraryPage
  -> 选择 ROLE / SCENE / ITEM
  -> 展示对应资产网格
  -> 设计入口跳空白页
  -> 管理入口只提示或进入空白页
```

## 7. 现有工程参考点

- 页面结构沿用 `pages/{feature}/index.dart + controller.dart + view.dart`。
- 状态组件复用 `AppStateBuilder`、`AppEmpty`、`AppError`、`AppLoading`。
- 路由和返回策略复用 `go_router` 与 `CustomRouter.popOrMain`。

## 8. 建议实现步骤

1. 新建 `asset_library` 页面目录。
2. 先实现静态三入口和三 Tab。
3. 资产网格接空列表。
4. 设计入口跳统一空白页。
5. 管理入口 Toast 或空白页。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F006-1 | `pages/asset_library/index.dart` | 页面可编译 |
| T-F006-2 | `view.dart` | 视觉区块完整 |
| T-F006-3 | `widgets/*` | 入口、Tab、卡片可复用 |
| T-F006-4 | 路由回调 | 三类设计入口可达空白页 |

## 10. 验收标准

- 资产库可从首页打开。
- 三类 Tab 可切换。
- 资产网格在空数据时不崩。
- 图片失败有占位。
- 管理入口不执行删除；其它页面不按后续 Figma Frame 细化。

## 11. 编码注意事项

- 不把角色/场景/物品设计做成真实生成。
- 网格尺寸要稳定，避免图片加载导致跳动。
- 资产库页面文案统一使用喵喵漫画语境。
