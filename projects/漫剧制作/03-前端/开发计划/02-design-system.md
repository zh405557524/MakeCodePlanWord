# 02 - 设计系统与通用组件开发计划

> 覆盖任务：F-007 ~ F-010  
> 状态：`pending`  
> 依赖：F-001 ~ F-006  
> Figma：`AI漫剧 / 07-组件与状态`

## 目标

按 Figma 手机端设计稿建立深色主题、页面容器、通用组件和任务状态组件。后续页面不得在业务代码中重复硬编码颜色、圆角、按钮和卡片样式。

## 任务拆分

| ID | 任务 | 输出 | 验收 |
| --- | --- | --- | --- |
| F-007 | 建立主题 Token | `theme.dart`、颜色、字体、圆角 | 与 Figma 深色视觉一致 |
| F-008 | 建立页面容器 | `CustomScaffold`、安全区、底部操作区 | 375 x 812 下不遮挡底部按钮 |
| F-009 | 建立通用组件 | TopBar、按钮、卡片、Chip、弹层 | 对照组件状态稿 |
| F-010 | 建立任务状态组件 | 生成中、失败、进度、重试 | 可用于角色/场景/分镜/视频 |

## 组件清单

- `AppTopBar`
- `StepProgressBar`
- `PrimaryGradientButton`
- `SecondaryButton`
- `BottomActionBar`
- `AssetCard`
- `WorkCard`
- `ParamChip`
- `TaskStatusBadge`
- `GenerationProgress`
- `RetryAction`
- `BottomSheetPanel`

## 状态要求

组件必须支持：

- 默认
- 选中
- 禁用
- 加载中
- 生成中
- 失败
- 按压反馈

## 视觉约束

- UI 第一真源是 Figma。
- 375 x 812 为主验收尺寸。
- 分镜页通用组件必须支持长页面滚动。
- 角色/场景卡片不实现「已生成」标签组件；状态由图片和生成中覆盖层表达。

