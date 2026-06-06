# 执行力 Flutter 模块开发文档 - TrackDetail

> 模块编号：`M-05`  
> 对应总体任务：`F-011`  
> 状态：`done`  
> 当前策略：沿用当前单页多视觉态实现，只修正主线主题、时间线、执行数据或去 Now 链路上的实际问题

---

## 一、模块定位

TrackDetail 页负责展示单条主线的推进情况，并把“理解当前阶段”与“进入 Now 执行”串成一条链路。

本模块负责：

- 顶部 Hero 概览
- 阶段时间线
- 当前阶段目标与任务信息
- 执行数据区
- AI 建议区
- `去 Now` CTA

本模块不负责：

- 多主线总览
- 计划编辑器

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/track_detail/index.dart`
- `lib/pages/track_detail/controller.dart`
- `lib/pages/track_detail/view.dart`
- `lib/pages/track_detail/widgets/task_list.dart`
- `lib/pages/track_detail/widgets/timeline.dart`

路由与参数：

- `RouteName.trackDetail`
- `pathParameters.trackId`

---

## 三、当前实现判断

当前实现已经采用了正确的方向：

- `换工作` 与 `恋爱` 没有拆成两个页面目录
- 页面依赖 `trackId` 驱动不同视觉态与内容态
- 页面独立于 `BattleMap` 和 `Now`

旧文档中把它写成“待新建”的口径已经不准确。  
现在更关键的是：

- Hero 的主题色是否足够贴稿
- 时间线是否完整表达阶段感
- 执行数据和 AI 建议是否保留层级
- 去 `Now` 的动作是否形成真实链路

---

## 四、本轮改造边界

只修改以下问题：

1. `trackId` 驱动逻辑错误
2. 主线视觉态没有正确区分
3. 时间线、任务列表或执行数据语义错误
4. 去 `Now` 的链路断裂
5. 空状态、异常态或同步态缺失

本轮不做：

- 把单页多视觉态拆成多个页面
- 无实际收益的组件再拆分

---

## 五、验收标准

- 可从 `BattleMap` 或 `Plan` 进入对应主线详情
- 同一路由能承接不同主线视觉态
- 时间线、任务信息和执行数据结构完整
- 可从详情进入 `Now`

---

## 六、视觉参考

- Figma：`06-TrackDetail-换工作`
- Figma：`07-TrackDetail-恋爱`
- `01-需求/references/images/16-计划_计划详情_执行力-主线详情1.png`
- `01-需求/references/images/17-计划_计划详情_执行力-主线详情2.png`
- `01-需求/references/images/24-计划_执行力-主线详情.png`
