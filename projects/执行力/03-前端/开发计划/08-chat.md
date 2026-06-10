# 执行力 Flutter 模块开发文档 - Chat

> 模块编号：`M-08`
> 对应总体任务：`F-015`
> 状态：`done`（v1 实现）
> 当前策略：作为 v2 `ChatHome` 的消息、composer 和草稿能力迁移来源保留

---

## 一、模块定位

Chat 页负责消息交互、草稿生成和把草稿送入 `PlanEditor`。

v2 中，聊天能力从独立沉浸式子页升级为根入口 `ChatHome`：

- 用户打开 App 后直接进入对话主页面。
- composer 固定在 `ChatHome` 底部。
- 草稿、计划创建、笔记入口从对话和工具菜单派生。
- 旧深色沉浸式 Chat 视觉不作为 v2 首屏继续沿用。

本模块负责：

- 消息流
- 快捷回复
- 草稿卡
- 输入栏
- 发送与本地落库
- 应用草稿到 `PlanEditor`

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/chat/index.dart`
- `lib/pages/chat/controller.dart`
- `lib/pages/chat/view.dart`
- `lib/pages/chat/widgets/message_bubble.dart`
- `lib/pages/chat/widgets/draft_card.dart`
- `lib/pages/chat/widgets/chat_input_bar.dart`

依赖关系：

- `ChatService`
- `DraftStore`
- `RouteName.planEditorCreate`

---

## 三、当前实现判断

Chat 模块已经完成独立全屏页承接：

- 从主导航入口进入
- 沉浸式全屏展示
- 可承接草稿卡并跳转编辑器

当前不需要按旧 `ChatPage` 继续扩展底部导航入口。
后续重点迁移到 `M-12 ChatHome`：

- 本地消息与草稿的稳定性
- composer 输入和发送体验
- 草稿跳转编辑器的链路
- 空状态、错误态、发送反馈
- 与 Figma `V2-Chat-First` 的浅色极简对话入口对齐

---

## 四、本轮改造边界

只修改以下问题：

1. 消息流展示错误
2. 草稿卡不可用或跳转参数错误
3. 输入区行为异常
4. 旧 Chat 路由仍作为底部导航入口出现
5. 旧深色沉浸式层级误用于 v2 首页

本轮不做：

- 将 Chat 继续挂在 MainShell 底部 Tab
- 为了复用旧视觉而牺牲 v2 对话主入口

---

## 五、验收标准

- 打开 App 后可稳定进入 `ChatHome`
- 消息流可读本地历史
- 草稿卡能进入 `PlanEditor`
- composer、工具菜单和侧边菜单符合 v2 首页结构

---

## 六、视觉参考

- Figma：`03-Chat`
- Figma：`V2-01-ChatHome-Entry`
- Figma：`V2-02-ChatHome-Active`
- `01-需求/references/images/27-主页_执行力-Chat 页.png`
