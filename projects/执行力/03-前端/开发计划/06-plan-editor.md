# 执行力 Flutter 模块开发文档 - PlanEditor

> 模块编号：`M-06`  
> 对应总体任务：`F-012`  
> 状态：`done`  
> 当前策略：保持当前编辑器单页结构，只修正表单行为、草稿承接、实例重建和视觉细节中的真实问题

---

## 一、模块定位

PlanEditor 负责计划的新建、编辑和草稿承接，是计划链路最核心的写入入口。

本模块负责：

- 新建计划
- 编辑计划
- Chat 草稿预填充
- 阶段与任务编辑
- 本地校验、本地保存
- 保存后重建 `task_instances`

本模块不负责：

- Now 推荐逻辑本身
- BattleMap 展示逻辑

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/plan_editor/index.dart`
- `lib/pages/plan_editor/controller.dart`
- `lib/pages/plan_editor/view.dart`
- `lib/pages/plan_editor/widgets/basic_info_section.dart`
- `lib/pages/plan_editor/widgets/phase_section.dart`
- `lib/pages/plan_editor/widgets/task_item.dart`
- `lib/pages/plan_editor/dialog/task_editor_dialog.dart`

路由与参数：

- `RouteName.planEditorCreate`
- `RouteName.planEditorEdit`
- 创建态支持 `extra.draftId`
- 编辑态支持 `pathParameters.id`

---

## 三、当前实现判断

当前 PlanEditor 已经完成基本闭环：

- 可从 Plan 页新建
- 可从已有计划继续编辑
- 可承接 Chat 草稿
- 保存后可重建 `task_instances`

旧文档里的某些“建议文件”现在并不存在，比如：

- `time_plan_section.dart`
- `task_list_section.dart`

这些不应该再作为“必须补齐”的结构要求。  
当前文档应以现有代码真实文件为准，不因为规则库里存在通用模板就倒逼现有代码改形态。

---

## 四、本轮改造边界

只修改以下问题：

1. 创建 / 编辑 / 草稿态入口不对
2. 保存后计划或任务实例未正确回写
3. 表单校验不准确
4. Figma 中的重要区块、底部 CTA、弹框行为明显不一致

本轮不做：

- 为了和模板完全一致而新增无用 section 文件
- 将当前已稳定运行的编辑器重新拆成更多层

---

## 五、验收标准

- 新建、编辑、草稿承接都可用
- 保存后数据能回到 Plan、Now 等后续链路
- 编辑器保持单页多视觉态，而不是拆成多个页面
- 任务编辑弹框和主表单交互稳定

---

## 六、视觉参考

- Figma：`08-PlanEditor-恋爱`
- Figma：`09-PlanEditor-默认`
- `01-需求/references/images/13-计划_计划编辑_执行力-计划编辑器-新建计划1.png`
- `01-需求/references/images/14-计划_计划编辑_执行力-计划编辑器-新建计划2.png`
- `01-需求/references/images/04-计划_计划编辑_执行力-计划编辑器-编辑计划1.png`
- `01-需求/references/images/09-计划_计划编辑_执行力-计划编辑器-编辑计划6-阶段目标-添加任务弹框.png`
