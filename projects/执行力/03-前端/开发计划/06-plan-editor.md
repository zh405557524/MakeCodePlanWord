# 执行力 Flutter 模块开发文档 - PlanEditor

> 模块编号：`M-06`  
> 对应总体任务：`F-012`  
> 状态：`pending`

---

## 一、功能定位与边界

PlanEditor 负责计划的新建、编辑和草稿校对。

本模块负责：

- 新建计划
- 编辑计划
- Chat 草稿预填充
- 阶段与任务编辑
- 本地校验、本地保存、实例重建

本模块不负责：

- Now 推荐逻辑
- BattleMap 详情页展示

---

## 二、入口、路由与页面文件

**入口**：

- Plan 页新增按钮
- Plan / TrackDetail 的继续编辑动作
- Chat 草稿应用入口

**路由**：

- `RouteName.planEditorCreate`
- `RouteName.planEditorEdit`

**参数**：

- 编辑态：`pathParameters.id`
- 草稿态：`extra.draftId`

**页面文件**：

- `lib/pages/plan_editor/view.dart`
- `lib/pages/plan_editor/controller.dart`
- `lib/pages/plan_editor/index.dart`
- `lib/pages/plan_editor/widgets/basic_info_section.dart`
- `lib/pages/plan_editor/widgets/time_plan_section.dart`
- `lib/pages/plan_editor/widgets/phase_section.dart`
- `lib/pages/plan_editor/widgets/task_list_section.dart`
- `lib/pages/plan_editor/dialog/task_editor_dialog.dart`

---

## 三、依赖前置

- Plan 模块已可进入编辑器
- Hive 中计划、任务、草稿 box 可用
- `PlanService`、`TaskInstanceService`、`DraftStore`、`SyncStore` 可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`08-PlanEditor-恋爱`
- Figma：`09-PlanEditor-默认`
- `01-需求/references/images/13-计划_计划编辑_执行力-计划编辑器-新建计划1.png`
- `01-需求/references/images/14-计划_计划编辑_执行力-计划编辑器-新建计划2.png`
- `01-需求/references/images/04-计划_计划编辑_执行力-计划编辑器-编辑计划1.png`
- `01-需求/references/images/09-计划_计划编辑_执行力-计划编辑器-编辑计划6-阶段目标-添加任务弹框.png`

### 页面结构结论

- `默认` 与 `恋爱` 共用一个编辑器页面，不拆目录
- 页面必须保留卡片分区和固定底部 CTA
- 新增 / 编辑任务通过弹框完成，不在整页散落输入控件

---

## 五、业务内容与数据流

1. 进入页面后识别模式：`create / edit / draft`
2. 初始化表单状态
3. 编辑基础信息、时间规划、阶段、任务
4. 点击保存后执行：
   - 表单校验
   - `PlanService` 本地保存
   - `TaskInstanceService.rebuildForPlan()`
   - 更新 `PlanStore`
   - 写入 `SyncStore`

---

## 六、验收标准

- 新建、编辑、草稿校对三种模式可用
- 固定底部 CTA 存在且状态正确
- 卡片分区清晰
- 保存后 Plan / BattleMap / TrackDetail / Now 都能读到最新本地数据

---

## 七、编码注意事项

- `PlanEditor` 是“单页多视觉态”
- 表单状态统一由主 Controller 管理
- 任务编辑优先走弹框，不散写在页面各处
