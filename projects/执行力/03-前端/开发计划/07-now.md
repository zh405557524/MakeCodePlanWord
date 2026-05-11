# 执行力 Flutter 模块开发文档 - Now

> 模块编号：`M-07`  
> 对应总体任务：`F-013 ~ F-014`  
> 状态：`pending`

---

## 一、功能定位与边界

Now 页负责在当前时刻给出最值得执行的一件事，并承接专注与反馈动作。

本模块负责：

- 顶部时间与状态徽章
- AI 建议卡
- 推荐任务卡
- 备用任务列表
- `开始专注 / 换一个`
- 专注弹框或专注层
- `完成 / 推迟 / 放弃`

---

## 二、入口、路由与页面文件

**入口**：`MainShell` 中的 Now Tab  
**路由**：`/`

**页面文件**：

- `lib/pages/now/view.dart`
- `lib/pages/now/controller.dart`
- `lib/pages/now/widgets/top_status_bar.dart`
- `lib/pages/now/widgets/ai_suggestion_card.dart`
- `lib/pages/now/widgets/recommend_task_card.dart`
- `lib/pages/now/widgets/backup_task_item.dart`
- `lib/pages/now/dialog/focus_dialog.dart`

---

## 三、视觉参考与 Figma 对齐

### 参考设计

- Figma：`02-Now`
- `01-需求/references/images/28-主页_执行力-Now 页.png`

### 页面结构结论

- 页面是纵向结构：时间状态区 → 建议卡 → 主任务操作区 → 备用任务列表
- 深色 AI 主卡和浅色备用列表同时存在，不能只保留其一
- 页面背景和按钮渐变需要跟颜色文档一致

---

## 四、业务内容与数据流

1. 读取 `task_instances`
2. 由 `NowService` 生成推荐任务和备选任务
3. 渲染建议文案和主任务卡
4. 用户可执行 `开始专注 / 换一个 / 完成 / 推迟 / 放弃`
5. 所有反馈先写本地，再写同步状态

---

## 五、验收标准

- 推荐任务和备用任务同时可见
- 专注动作可触发独立交互层
- 任务反馈后页面能刷新推荐结果
- Figma 中的层级关系和主 CTA 保持完整

---

## 六、编码注意事项

- Now 不负责首次生成 `task_instances`
- 不把页面降级成普通待办列表
