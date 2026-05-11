# 执行力 Flutter 模块开发文档 - Chat

> 模块编号：`M-08`  
> 对应总体任务：`F-015`  
> 状态：`pending`

---

## 一、功能定位与边界

Chat 页负责消息交互、草稿生成和把草稿送入 PlanEditor。

本模块负责：

- 消息流
- 快捷回复
- 草稿卡
- 输入栏
- 发送与本地落库
- 应用草稿到 `PlanEditor`

---

## 二、入口、路由与页面文件

**入口**：底部导航 Chat 入口位  
**路由**：`RouteName.chat`

**页面文件**：

- `lib/pages/chat/view.dart`
- `lib/pages/chat/controller.dart`
- `lib/pages/chat/widgets/message_bubble.dart`
- `lib/pages/chat/widgets/draft_card.dart`
- `lib/pages/chat/widgets/chat_input_bar.dart`

---

## 三、视觉参考与 Figma 对齐

### 参考设计

- Figma：`03-Chat`
- `01-需求/references/images/27-主页_执行力-Chat 页.png`

### 页面结构结论

- 页面是深色沉浸式全屏页，进入后隐藏底部导航
- 输入区是底部毛玻璃条
- 草稿卡应嵌在消息流上下文中，而不是跳到页面外展示

---

## 四、业务内容与数据流

1. 进入页先读本地消息
2. 发送消息后先写本地
3. 请求 AI 返回消息和草稿
4. 草稿写入本地 draft box
5. 点击应用草稿后跳转 `PlanEditor`，通过 `extra.draftId` 传递

---

## 五、验收标准

- 消息流可持续显示本地历史
- 快捷回复和输入栏交互可用
- 草稿卡可见且能进入 `PlanEditor`
- 页面整体保持沉浸式深色结构

---

## 六、编码注意事项

- 消息先落本地再请求远端
- 草稿必须先落本地再跳转
- Chat 不驻留在 MainShell 内部做深色子页
