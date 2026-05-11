# 执行力 Flutter 模块开发文档 - TrackDetail

> 模块编号：`M-05`  
> 对应总体任务：`F-011`  
> 状态：`pending`

---

## 一、功能定位与边界

TrackDetail 页负责展示单条主线的长期推进情况，并把“理解当前阶段”与“去 Now 页面执行”闭合成一条链路。

本模块负责：

- 顶部 Hero 概览区
- 阶段时间线
- 当前阶段目标与任务
- 执行数据 / 节奏区
- AI 建议卡
- `去 Now 页面立刻执行` CTA

本模块不负责：

- 计划编辑表单
- Now 页推荐逻辑
- BattleMap 多主线总览

---

## 二、入口、路由与页面文件

**入口**：`BattleMap` 主线卡、Plan 页可进入详情的计划卡  
**路由**：`RouteName.trackDetail`

**参数协议**：

- `pathParameters.trackId`

**页面文件**：

- `lib/pages/track_detail/view.dart`
- `lib/pages/track_detail/controller.dart`
- `lib/pages/track_detail/index.dart`
- `lib/pages/track_detail/widgets/hero_section.dart`
- `lib/pages/track_detail/widgets/timeline_section.dart`
- `lib/pages/track_detail/widgets/execution_metrics_card.dart`
- `lib/pages/track_detail/widgets/ai_advice_card.dart`

---

## 三、依赖前置

- `BattleMap` 已可进入详情
- `PlanService` 已支持主线详情聚合
- `PlanStore` 已可缓存当前主线详情
- `RouteName.now` 已可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`06-TrackDetail-换工作`
- Figma：`07-TrackDetail-恋爱`
- `01-需求/references/images/16-计划_计划详情_执行力-主线详情1.png`
- `01-需求/references/images/17-计划_计划详情_执行力-主线详情2.png`
- `01-需求/references/images/24-计划_执行力-主线详情.png`

### 页面结构结论

- 顶部必须是带主线主题色的 Hero，而不是简单标题栏
- 中段必须是完整阶段时间线，不可简化成平铺列表
- 当前阶段需要单独强调：节点、卡片描边、说明文案、当周目标
- 页面底部要有执行数据 / AI 建议 / CTA，不能只停在“看详情”
- `换工作` 与 `恋爱` 是同一路由的两种视觉态：
  - `换工作`：蓝紫职业主题
  - `恋爱`：粉红关系主题

---

## 五、涉及模块与类

| 类型 | 文件 / 类 | 说明 |
|------|-----------|------|
| 页面 | `TrackDetailPage` | 主线详情页 |
| 控制器 | `TrackDetailController` | 详情加载、主题状态、跳转 |
| 组件 | `HeroSection` | 顶部主线概览 |
| 组件 | `TimelineSection` | 阶段时间线 |
| 组件 | `ExecutionMetricsCard` | 节奏 / 指标 / 当前阶段提示 |
| 组件 | `AiAdviceCard` | AI 建议卡 |
| 服务 | `PlanService` | 主线详情聚合 |
| Store | `PlanStore` | 当前主线详情缓存 |

Controller 至少包含：

- `trackId`
- `trackTheme`
- `trackDetail`
- `currentPhase`
- `isLoading`

---

## 六、业务内容与数据流

1. 根据传入的 `trackId` 读取本地主线详情
2. `PlanService` 聚合出：
   - Hero 所需指标
   - 阶段时间线
   - 当前阶段目标
   - 执行节奏 / AI 建议
3. `Controller` 根据 `trackId` 派生主题色、按钮渐变、节点高亮样式
4. 页面渲染 Hero、时间线、执行卡、AI 建议卡、底部 CTA
5. 点击 CTA 跳转 `RouteName.now`

可选二级动作：

- 若存在编辑入口，应收口为二级操作，不得打断 Hero → 时间线 → 执行 CTA 的主阅读路径

---

## 七、实现步骤建议

1. 创建 `TrackDetailPage / Controller / index`
2. 搭 Hero 概览区
3. 实现阶段时间线
4. 实现当前阶段提示与执行数据卡
5. 实现 AI 建议卡
6. 接入去 `Now` 的 CTA
7. 完成 `trackId` 驱动的多视觉态切换

---

## 八、详细编码任务清单

- [ ] 创建 `pages/track_detail/` 三件套
- [ ] 接入 `trackId` 与主线详情读取
- [ ] 实现 Hero 概览区
- [ ] 实现阶段时间线
- [ ] 实现当前阶段目标 / 执行数据区
- [ ] 实现 AI 建议卡
- [ ] 实现去 `Now` 的 CTA
- [ ] 实现 `换工作 / 恋爱` 主题切换

---

## 九、验收标准

- 根据不同 `trackId` 能切换不同主题色和文案
- 阶段时间线能区分 `completed / active / upcoming`
- 当前阶段信息突出且可读
- AI 建议卡与 CTA 在页面下半部完整闭合
- 从详情进入 `Now` 可用

---

## 十、编码注意事项

- 聚合逻辑放 `Service`，不放 `Widget`
- `TrackDetail` 是“单页多视觉态”，不是“两页两套实现”
- 不要把时间线、执行数据和 CTA 简化掉
