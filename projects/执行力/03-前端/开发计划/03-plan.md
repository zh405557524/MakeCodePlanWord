# 执行力 Flutter 模块开发文档 - Plan

> 模块编号：`M-03`
> 对应总体任务：`F-009`
> 状态：`done`
> 当前策略：保留现有计划链路能力，v2 中从 ChatHome 的工具菜单、侧边菜单或对话草稿进入

---

## 一、模块定位

Plan 页在 v1 中是计划主链路的总入口；v2 中它降级为从 `ChatHome` 派生进入的计划库 / 能力页，负责承接：

- 当前有哪些计划
- 从哪里进入 `BattleMap`
- 如何新建或继续编辑计划

本模块负责：

- 顶部标题与新增入口
- `BattleMap` Hero
- 今日 / 本周摘要区
- 计划卡片列表
- 空状态
- 跳转到 `BattleMap / TrackDetail / PlanEditor`

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/plan/index.dart`
- `lib/pages/plan/controller.dart`
- `lib/pages/plan/view.dart`
- `lib/pages/plan/widgets/battle_map_hero.dart`
- `lib/pages/plan/widgets/plan_card.dart`
- `lib/pages/plan/widgets/plan_empty_state.dart`
- `lib/pages/plan/widgets/plan_summary_tabs.dart`

依赖关系：

- `PlanStore`
- `PlanService`
- `RouteName.battleMap`
- `RouteName.trackDetail`
- `RouteName.planEditorCreate`
- `RouteName.planEditorEdit`

---

## 三、当前实现判断

当前代码已经完成 Plan 页的主职责：

- 作为可路由的 `Plan` 入口页存在
- 提供 `BattleMap Hero`
- 提供计划列表与空状态
- 提供新建计划和进入详情/编辑的入口

当前文档里原来那种“从零新建 Plan 页”的口径已经过期。
现在更准确的描述应该是：

- Plan 模块已落地
- v2 首屏不再通过底部 Tab 进入 Plan
- `PlanCreate` 优先从 `ChatHome -> ToolMenu` 或对话草稿进入
- 后续主要在 `M-10` 中做空状态、异常态、联调和 Figma 收口

---

## 四、本轮改造边界

当前只修改以下类型问题：

1. 入口语义不对
2. `BattleMap / TrackDetail / PlanEditor` 跳转关系不对
3. 计划列表状态展示不正确
4. 空状态、同步态或视觉层级明显偏离 Figma
5. v2 中仍把 Plan 暴露为底部 Tab 一级入口

本轮不做：

- 把已可用的 Plan 页重新拆成全新结构
- 仅为“看起来更像参考工程”而重写 Controller 或 Service
- 把 Plan 重新放回 v2 首屏分发

---

## 五、验收标准

- Plan 可作为计划库 / 能力页稳定使用
- 可从 `ChatHome` 到达 Plan 和创建计划
- 可进入 `BattleMap`
- 可新建计划、继续编辑、查看详情
- 空状态与已有计划状态都可正确展示
- 后续对稿仅在 `M-10` 中继续修正

---

## 六、视觉参考

- Figma：`04-Plan`
- Figma：`V2-06-PlanCreate`
- `01-需求/references/images/29-主页_执行力-Plan 页.png`
