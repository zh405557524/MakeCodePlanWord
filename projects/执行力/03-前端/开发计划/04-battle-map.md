# 执行力 Flutter 模块开发文档 - BattleMap

> 模块编号：`M-04`  
> 对应总体任务：`F-010`  
> 状态：`done`  
> 当前策略：保留现有总览页结构，只在主线卡片语义、视觉态或进入详情链路有问题时修改

---

## 一、模块定位

BattleMap 页负责展示年度主线总览，是 `Plan` 和 `TrackDetail` 之间的中间层。

本模块负责：

- 年度总览 Banner
- 主线卡片列表
- 进度和状态分层
- 进入 `TrackDetail`

本模块不负责：

- 计划编辑表单
- 单主线的完整时间线与执行数据

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/battle_map/index.dart`
- `lib/pages/battle_map/controller.dart`
- `lib/pages/battle_map/view.dart`
- `lib/pages/battle_map/widgets/overview_banner.dart`
- `lib/pages/battle_map/widgets/track_card.dart`

依赖关系：

- `PlanService`
- `PlanStore`
- `RouteName.trackDetail`

---

## 三、当前实现判断

当前 BattleMap 模块已经可用：

- 页面独立存在
- 由 Plan 页进入
- 可以展示总览和主线卡片
- 可以进入 `TrackDetail`

原文档里“待开发”的描述已经不准确。  
当前阶段 BattleMap 的主要问题不在“有没有页面”，而在：

- 主线卡片的信息密度是否够
- 不同主线视觉主题是否与 Figma 完全一致
- 与 `TrackDetail` 的跳转和状态承接是否平滑

这些都属于 `M-10` 的联调与对稿范围。

---

## 四、本轮改造边界

只修改以下问题：

1. 主线卡片信息缺失或误导
2. 点击进入 `TrackDetail` 的参数不对
3. Banner / 卡片层级明显偏离设计稿
4. 空数据或异常状态缺失

本轮不做：

- 为了追求组件拆分而重构当前页面
- 将 BattleMap 和 Plan 合并或改成同页结构

---

## 五、验收标准

- 可从 Plan 稳定进入 BattleMap
- 主线卡片可区分不同主线
- 点击卡片能正确进入对应 `TrackDetail`
- 页面能承接后续 Figma 收口而无需重做骨架

---

## 六、视觉参考

- Figma：`05-BattleMap`
- `01-需求/references/images/18-计划_计划主页_执行力-作战地图1.png`
- `01-需求/references/images/19-计划_计划主页_执行力-作战地图2.png`
- `01-需求/references/images/25-计划_执行力-作战地图.png`
