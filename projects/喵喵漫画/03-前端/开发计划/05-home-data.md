# 05 首页数据与状态模块开发文档

> 对应任务：T-F005
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责首页分类、案例列表、加载、空态、错误、重试和 mock fallback。它复用已有首页接口代码，不新增首页 API 路径，不调用案例使用统计接口。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/apis/home.dart` | 复用 `fetchCategories`、`fetchCases` |
| `lib/models/data/home_case.dart` | 复用分类和案例模型 |
| `lib/pages/home/controller.dart` | 校准加载、空态、错误、重试和分类切换 |
| `lib/pages/home/view.dart` | 绑定状态展示 |

## 3. 依赖前置

- 依赖 T-F004 首页 UI。
- 依赖 Java T-B003 首页接口联调。
- 后端必须支持 `X-App-Code: catcomic`，无数据时返回空数组。

## 4. 视觉参考与设计稿分析

参考 Figma Frame：`首页` / `97:102`。

状态来自 `figma-design-plan.md` 5.1：

- 案例列表加载态。
- 案例列表空态。
- 案例列表错误态 + 重试。
- 热门分类切换态。

当前无导出图片文件。

## 5. 涉及模块与类

- `HomeAPI`
- `HomeController`
- `HomeCaseCategory`
- `HomeCase`
- `MockService`
- `ConfigStore`
- `AppStateBuilder`

## 6. 业务内容与数据流

```text
HomeController.onInit
  -> load categories
  -> selectedCategoryCode
  -> load cases
  -> ViewState
  -> HomePage UI
```

接口：

| 场景 | 方法 |
|------|------|
| 分类 | `GET /api/config/home-case-categories` |
| 案例 | `GET /api/config/home-cases?categoryCode={code}` |

## 7. 现有工程参考点

当前 `HomeController` 已经有 `categories`、`cases`、`loading`、`errorMessage`、`selectedCategoryCode`、`selectedCategoryIndex` 和 mock fallback，可以保留并调整文案。

## 8. 建议实现步骤

1. 确认 `HomeAPI` 请求头由 `HttpService` 自动携带 `catcomic`。
2. 保留分类失败 fallback。
3. 分类为空时展示首页空态，不崩溃。
4. 案例为空时只展示案例区空态。
5. 错误态提供重试，不清掉入口区。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F005-1 | `apis/home.dart` | 接口路径不变，请求头正确 |
| T-F005-2 | `models/data/home_case.dart` | 字段兼容后端响应 |
| T-F005-3 | `pages/home/controller.dart` | loading/empty/error/retry 稳定 |
| T-F005-4 | `pages/home/view.dart` | 状态区不影响顶部入口 |

## 10. 验收标准

- 接口无分类时页面可用。
- 接口无案例时案例区空态可见。
- 接口失败时可重试。
- 分类切换保持选中态。
- 不把空数组视为错误。

## 11. 编码注意事项

- P0 默认不调用 `POST /api/config/home-cases/{caseId}/use`。
- mock 数据只用于 fallback 或本地演示，不冒充真实后端数据。
- 首页文案必须是喵喵漫画语境。
