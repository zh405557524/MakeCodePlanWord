# 执行力 Flutter 模块开发文档 - Now

> 模块编号：`M-07`
> 对应总体任务：`F-013 ~ F-014`
> 状态：`done`（v1 实现）
> 当前策略：作为 v2 `TodayFocus` 的业务迁移来源保留，不再作为一级首页继续扩展

---

## 一、模块定位

Now 页负责在当前时刻给出最值得执行的一件事，并承接专注与反馈动作。

v2 中，用户可见的“现在执行”入口迁移到 `TodayFocus`：

- `ChatHome` 负责展示轻量今日建议和进入按钮。
- `TodayFocus` 负责全屏执行当前一件任务。
- 旧 `NowPage` 的推荐、切换和反馈逻辑可复用，但旧卡片堆叠 UI 不继续沿用。

本模块负责：

- 顶部时间与状态栏
- AI 建议卡
- 推荐任务卡
- 备用任务列表
- `开始专注 / 换一个`
- 专注弹层
- `完成 / 推迟 / 放弃`

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/now/index.dart`
- `lib/pages/now/controller.dart`
- `lib/pages/now/view.dart`
- `lib/pages/now/widgets/top_status_bar.dart`
- `lib/pages/now/widgets/ai_suggestion_card.dart`
- `lib/pages/now/widgets/recommend_task_card.dart`
- `lib/pages/now/widgets/backup_task_item.dart`
- `lib/pages/now/dialog/focus_dialog.dart`

依赖关系：

- `NowService`
- `TaskInstanceService`
- `PlanStore`
- `SyncStore`

---

## 三、当前实现判断

当前 Now 页已具备页面闭环，不再是待开发模块：

- 有主推荐区和备用列表
- 有反馈动作
- 有专注交互承接

当前真正需要迁移的是：

- 当前任务推荐算法
- 候选任务切换
- 反馈后的本地写回
- 空状态、异常态、同步态

这些工作优先迁移到 `M-13 TodayFocus`，不是回到 `M-07` 按旧首页从头重做。

---

## 四、本轮改造边界

只修改以下问题：

1. 推荐任务逻辑无法被 `TodayFocus` 复用
2. `开始专注 / 换一个 / 完成 / 推迟 / 放弃` 行为不对
3. 空状态、异常态、同步态无法迁移
4. 旧 Now 路由仍作为 v2 首屏出现

本轮不做：

- 把 Now 降级成普通待办列表
- 继续沿旧 Now 首页结构做 v2 首屏

---

## 五、验收标准

- 推荐任务能被 `TodayFocus` 正确读取
- 反馈动作能写回本地状态
- `换一个 / 完成 / 推迟 / 放弃` 能迁移到全屏专注页
- 空状态、异常态和同步态可在 v2 联调阶段闭合

---

## 六、视觉参考

- Figma：`02-Now`
- Figma：`V2-03-TodayFocus`
- `01-需求/references/images/28-主页_执行力-Now 页.png`
