# 执行力 Flutter 模块开发文档 - Plan

> 模块编号：`M-03`  
> 对应总体任务：`F-009`  
> 状态：`pending`

---

## 一、功能定位与边界

Plan 页是计划总入口，负责回答三件事：

- 当前有哪些计划
- 现在能从哪里进入年度作战地图
- 如何快速新建或继续一个计划

本模块负责：

- 顶部标题区与新增入口
- `BattleMap` Hero 卡
- 今日 / 本周切换区与进度摘要
- 计划卡片列表
- 空状态
- 进入 `BattleMap / TrackDetail / PlanEditor`

本模块不负责：

- `BattleMap` 主线结构详情
- `TrackDetail` 时间线和执行数据
- `PlanEditor` 表单逻辑

---

## 二、入口、路由与页面文件

**入口**：`MainShell` 中的 Plan Tab  
**路由**：`RouteName.plan`

**页面文件**：

- `lib/pages/plan/view.dart`
- `lib/pages/plan/controller.dart`
- `lib/pages/plan/index.dart`
- `lib/pages/plan/widgets/battle_map_hero.dart`
- `lib/pages/plan/widgets/plan_summary_tabs.dart`
- `lib/pages/plan/widgets/plan_card.dart`
- `lib/pages/plan/widgets/plan_empty_state.dart`

---

## 三、依赖前置

- `01-app-foundation`
- `02-splash-shell`
- `PlanStore` 与计划相关 Hive box 可读写
- `RouteName.battleMap / trackDetail / planEditorCreate / planEditorEdit` 已可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`04-Plan`
- `01-需求/references/images/29-主页_执行力-Plan 页.png`

### 页面结构结论

- 页面是浅色背景，不是纯列表页
- 顶部存在标题与右上角新增按钮
- 第一视觉是 `BattleMap` 深色 Hero 卡，不可降级成普通跳转行
- Hero 卡下方有“今日 / 本周”切换和进度摘要区
- 计划内容用白色卡片列表承接，卡片内部承载计划摘要与进入详情动作

---

## 五、涉及模块与类

| 类型 | 文件 / 类 | 说明 |
|------|-----------|------|
| 页面 | `PlanPage` | Plan 主页面 |
| 控制器 | `PlanController` | 计划列表、摘要、跳转 |
| 组件 | `BattleMapHero` | 年度作战地图 Hero 卡 |
| 组件 | `PlanSummaryTabs` | 今日 / 本周切换区 |
| 组件 | `PlanCard` | 计划卡片 |
| 服务 | `PlanService` | 计划读取、摘要聚合 |
| Store | `PlanStore` | 本地计划与摘要状态 |

Controller 至少应管理：

- `selectedSummaryTab`
- `planCards`
- `todaySummary`
- `weekSummary`
- `hasPlans`

---

## 六、业务内容与数据流

1. 页面进入时先从 `PlanStore` 读取本地计划列表
2. `PlanService` 聚合出今日 / 本周摘要
3. `Controller` 组装 Hero、摘要区、计划卡片列表
4. 点击 Hero 进入 `RouteName.battleMap`
5. 点击卡片主区域进入 `RouteName.trackDetail`
6. 点击新增按钮进入 `RouteName.planEditorCreate`
7. 点击继续编辑或二级动作进入 `RouteName.planEditorEdit`

参数约定：

- 进入 `TrackDetail` 时统一使用 `trackId`
- 对于来自自定义计划的详情入口，业务层统一负责把页面需要的详情主键映射为 `trackId`

---

## 七、实现步骤建议

1. 创建 `PlanPage / Controller / index`
2. 搭页面骨架：标题栏、Hero、摘要区、列表区
3. 接入本地计划列表和摘要聚合
4. 实现今日 / 本周切换
5. 实现卡片列表与空状态
6. 接入 `BattleMap / TrackDetail / PlanEditor` 跳转

---

## 八、详细编码任务清单

- [ ] 创建 `pages/plan/` 三件套
- [ ] 实现标题栏和新增按钮
- [ ] 实现 `BattleMapHero`
- [ ] 实现今日 / 本周摘要切换区
- [ ] 实现计划卡片列表
- [ ] 实现空状态
- [ ] 接入 `BattleMap / TrackDetail / PlanEditor` 跳转

---

## 九、验收标准

- `BattleMap` Hero 卡在首屏清晰可见
- 今日 / 本周摘要区可切换且不丢状态
- 计划卡片列表可展示本地数据
- 新建、查看详情、继续编辑入口都可用
- 空状态下仍保留 `BattleMap` 与新建计划入口

---

## 十、编码注意事项

- 不在 `View` 中直接查询 Hive
- 不把 Plan 页做成 BattleMap 的缩略版
- Hero、摘要区、列表区必须保持三段式结构
