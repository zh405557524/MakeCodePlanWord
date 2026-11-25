# 07 资产库数据与状态模块开发文档

> 对应任务：T-F007
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责资产库 API、模型、Controller、分页、空态、错误态和重试。只做读取能力，不做创建、编辑、删除、生成或上传。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/apis/comic_assets.dart` | 新增资产库 API |
| `lib/apis/index.dart` | 导出新 API |
| `lib/models/data/comic_asset.dart` | 新增资产模型 |
| `lib/models/data/index.dart` | 导出新模型 |
| `lib/pages/asset_library/controller.dart` | 接 Tab、列表、分页、重试 |
| `lib/pages/asset_library/view.dart` | 绑定状态 |

## 3. 依赖前置

- 依赖 T-F006 资产库 UI。
- 依赖 Java T-B005、T-B006。
- 后端接口：`GET /api/comic/assets/tabs`、`GET /api/comic/assets`、`GET /api/comic/assets/{assetId}`。

## 4. 视觉参考与设计稿分析

参考 Figma Frame：`资产库` / `97:2345`。

状态要求来自 `figma-design-plan.md` 5.2：Tab 切换、加载、空态、错误、图片失败。当前无导出图片文件。

## 5. 涉及模块与类

- `ComicAssetAPI`
- `ComicAsset`
- `ComicAssetType`
- `ComicAssetTab`
- `AssetLibraryController`
- `PageResult`
- `MockService`

## 6. 业务内容与数据流

```text
进入资产库
  -> fetch tabs
  -> 默认 ROLE
  -> fetch list
  -> PageResult
  -> grid / empty / error
```

接口参数：

| 参数 | 默认 | 说明 |
|------|------|------|
| `assetType` | `ROLE` | `ROLE`、`SCENE`、`ITEM` |
| `page` | `1` | 最小 1 |
| `pageSize` | `20` | 默认 20 |

## 7. 现有工程参考点

- `HttpService.get` 支持 `query`。
- `models/responses/page_result.dart` 已存在分页模型。
- `MockService` 可用于接口未就绪时 fallback。

## 8. 建议实现步骤

1. 新增 `ComicAssetTab`、`ComicAsset`、`ComicAssetType`。
2. 新增 `ComicAssetAPI.tabs/list/detail`。
3. Controller 初始化加载 tabs 和默认列表。
4. Tab 切换时重置分页并刷新。
5. 支持空态、错误重试、分页 hasMore。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F007-1 | `models/data/comic_asset.dart` | 字段兼容后端 |
| T-F007-2 | `apis/comic_assets.dart` | 三个接口可调用 |
| T-F007-3 | `controller.dart` | Tab、列表、分页状态稳定 |
| T-F007-4 | `view.dart` | loading/empty/error/retry 正确 |

## 10. 验收标准

- 三类 Tab 都能加载列表或空态。
- 后端无数据时显示空态。
- 接口失败时可重试。
- 匿名状态可访问系统资产。
- 前端不本地伪造真实资产。

## 11. 编码注意事项

- 本地 mock 只用于 fallback。
- 详情接口 P0 可选，列表为强依赖。
- 不新增写接口按钮。
