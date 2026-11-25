# 08 空白页集合模块开发文档

> 对应任务：T-F008
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责所有非首页、非资产库、非旧“我的”页且原工程没有的页面空白展示。最新口径：Figma 本期只严格参考首页与资产库；“我的”完整复用旧 `AccountPage`；其它页面不按 Figma 细节还原，只保证入口可达、页面为空白或极简标题页、不触发真实动作。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/pages/blank_feature/index.dart` | 新增聚合 |
| `lib/pages/blank_feature/view.dart` | 统一空白页 |
| `lib/pages/blank_feature/controller.dart` | 可选，通常不需要 |
| `lib/routes/name.dart` | 占位路由名 |
| `lib/routes/router.dart` | 占位路由 |

## 3. 依赖前置

- 依赖 T-F002 路由。
- 依赖 T-F003 主题组件。
- Java 无依赖。

## 4. 视觉参考与设计稿分析

本模块不再按除首页、资产库之外的 Figma Frame 还原。其它页面仅使用全局背景、可选标题和返回按钮；旧“我的”页例外，按用户确认完整复用 `AccountPage` 及其二级入口。

## 5. 涉及模块与类

- `BlankFeaturePage`
- `BlankFeatureConfig`
- `CustomToast`
- `CustomScaffold`
- `RouteName`

## 6. 业务内容与数据流

```text
入口点击
  -> BlankFeaturePage(title)
  -> 空白内容
  -> 返回
```

覆盖入口：除首页、资产库和旧“我的”页外，原工程没有或不属于 P0 的入口统一走空白页或 Toast。

## 7. 现有工程参考点

- 可复用 `CustomScaffold`。
- 页面组织使用 `index.dart + controller.dart + view.dart`。
- 旧 `creation` 页只作为视觉结构参考，不可接真实生成流程。

## 8. 建议实现步骤

1. 定义最小 `BlankFeatureConfig` 或直接使用路由参数标题。
2. 统一空白页只保留标题、返回和空内容区域。
3. 每个路由通过 query 或 extra 传入标题。
4. 作品作为底部 Tab 内容时保持导航选中态；我的不走空白页，接回旧 `AccountPage`。
5. 不实现后续 Frame 的输入框、按钮、列表、弹层和生成态。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F008-1 | `blank_feature/index.dart` | 页面可编译 |
| T-F008-2 | `view.dart` | 空白页覆盖标题和返回 |
| T-F008-3 | `routes/*` | 所有占位入口可达 |
| T-F008-4 | 首页/资产库/底部导航 | 作品及其它占位入口进入空白页；我的展示旧账号页 |

## 10. 验收标准

- 所有后续功能入口打开空白页，不崩溃；旧“我的”页入口除外。
- 空白页不展示后续真实功能表单。
- 不调用后端生成、下载、删除、支付、会员接口。
- 返回能力稳定。

## 11. 编码注意事项

- 空白页可以只显示标题，也可以标题都不显示，按编码阶段与设计统一。
- 不暴露未确认复用的旧业务入口；旧“我的”页已确认完整复用。
- 不再按 AI 漫剧、分镜、预览、下载、重绘等 Figma Frame 做细节还原。
