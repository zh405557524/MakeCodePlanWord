# 03 主题与通用组件模块开发文档

> 对应任务：T-F003
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块沉淀喵喵漫画 P0 页面所需的主题 Token 和通用组件。重点服务首页和资产库；其它原工程没有的页面只需要空白展示，不做复杂占位模板、动效或大型组件库重构。

## 2. 入口、路由与页面文件

| 文件 | 处理 |
|------|------|
| `lib/theme.dart` | 补充背景、卡片、文本、主色、危险色等 Token |
| `lib/widgets/*` | 复用/扩展 loading、empty、error、button、toast |
| `lib/components/*` | 必要时放入口卡片、Tab、资产/案例卡片基础组件 |
| 页面 `widgets/` | 只放强页面语义组件 |

## 3. 依赖前置

- 依赖 T-F001 App 身份。
- 被 T-F004、T-F006、T-F008、T-F009 使用。
- Java 无直接依赖。

## 4. 视觉参考与设计稿分析

参考 `figma-design-plan.md` 第 2、6、8 章：

- 深色背景 + 高对比卡片。
- AI 漫剧入口和资产库入口层级更高。
- 分类 Tab 需要选中/未选中态。
- 首页、资产库的空态和错误态必须统一。

当前没有命名样式和本地组件，也没有导出图片文件；Flutter 侧先沉淀稳定 Token，后续可回补 Figma。

## 5. 涉及模块与类

- `CustomTheme`
- `CustomScaffold`
- `AppStateBuilder`
- `AppEmpty`
- `AppError`
- `AppLoading`
- `AppButton`
- `AppConfirmDialog`
- `CustomToast`

## 6. 业务内容与数据流

本模块不直接请求接口。它为首页和资产库提供一致状态承载：

```text
Controller ViewState
  -> AppStateBuilder
  -> loading / empty / error / success
  -> 页面组件
```

## 7. 现有工程参考点

当前工程已有状态组件和深色主题，可先扩展参数，不要另起一套 UI 基础库。

## 8. 建议实现步骤

1. 扫描 `theme.dart` 现有颜色和文本样式。
2. 补充喵喵漫画 P0 Token。
3. 扩展通用空态、错误态、按钮和确认弹窗。
4. 设计入口卡片、案例卡片、资产卡片先抽可复用基础结构。
5. 在首页和资产库模块落地时再微调页面专属组件。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F003-1 | `theme.dart` | Token 能覆盖 P0 页面 |
| T-F003-2 | `widgets/` | 状态组件可复用 |
| T-F003-3 | `components/` 或页面 `widgets/` | 卡片、Tab、入口基础组件稳定 |
| T-F003-4 | 页面联调 | 首页和资产库组件风格一致 |

## 10. 验收标准

- 首页和资产库不散落大量魔法色值。
- loading、empty、error、retry、图片失败有统一样式。
- 按钮、Tab、卡片在小屏不挤压。
- 空白页保持基础背景、标题和返回即可。

## 11. 编码注意事项

- 不为了单个页面大规模重构现有 widgets。
- 字号不要随视口宽度缩放，只使用设计尺寸适配。
- 文案必须能换行，不允许按钮文字溢出。
