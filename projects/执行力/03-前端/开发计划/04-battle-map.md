# 执行力 Flutter 模块开发文档 - BattleMap

> 模块编号：`M-04`  
> 对应总体任务：`F-010`  
> 状态：`pending`

---

## 一、功能定位与边界

BattleMap 页负责展示年度主线总览。

本模块负责：

- 年度总览 Banner
- 五条主线卡片
- 状态徽章
- 7 日执行节奏
- AI 建议摘要
- 进入 `TrackDetail`

本模块不负责：

- 单主线时间线详情
- PlanEditor 表单

---

## 二、入口、路由与页面文件

**入口**：Plan 页中的 `BattleMap` Hero  
**路由**：`RouteName.battleMap`

**页面文件**：

- `lib/pages/battle_map/view.dart`
- `lib/pages/battle_map/controller.dart`
- `lib/pages/battle_map/index.dart`
- `lib/pages/battle_map/widgets/overview_banner.dart`
- `lib/pages/battle_map/widgets/track_card.dart`

---

## 三、依赖前置

- Plan 模块已完成入口页
- 主线聚合查询可用
- `RouteName.trackDetail` 已可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`05-BattleMap`
- `01-需求/references/images/18-计划_计划主页_执行力-作战地图1.png`
- `01-需求/references/images/19-计划_计划主页_执行力-作战地图2.png`
- `01-需求/references/images/25-计划_执行力-作战地图.png`

### 页面结构结论

- 页面由年度 Banner + 主线卡片列表组成
- 五条主线有独立渐变主题，不共享一个卡片配色
- 每张卡片至少展示：当前阶段、进度、状态、7 日节奏、AI 建议

---

## 五、业务内容与数据流

1. 读取本地主线与阶段摘要
2. 聚合出年度 Banner 数据
3. 组装五条主线卡片
4. 点击卡片进入 `RouteName.trackDetail`，参数为 `trackId`

---

## 六、验收标准

- 五条主线都能清楚区分
- 状态 `active / blocked / idle` 清晰可读
- 每张卡片都可进入 `TrackDetail`
- 页面整体更像“年度局势总览”，而不是普通列表

---

## 七、编码注意事项

- 主题色必须跟随主线
- 不把 BattleMap 做成 TrackDetail 缩略版
