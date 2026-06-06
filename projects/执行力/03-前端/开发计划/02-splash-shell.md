# 执行力 Flutter 模块开发文档 - Splash 与 Main Shell

> 模块编号：`M-02`
> 对应总体任务：`F-007 ~ F-008`
> 状态：`pending`（v2 壳层重构）
> 当前策略：Splash 继续沿用，启动后的主壳从底部 Tab 分发改为 ChatHome 根入口

---

## 一、模块定位

本模块负责启动过渡和主应用壳层，确保用户从启动页顺利进入主导航结构。

本模块负责：

- `SplashPage`
- 启动完成后的自动跳转
- `MainPage`
- v1 底部导航的迁移处理
- v2 `ChatHome` 根入口跳转
- 二级全屏页显示 / 隐藏规则

本模块不负责：

- `ChatHome / TodayFocus / Plan / Notes / Profile` 具体业务内容
- 二级沉浸式页面的内部实现

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/splash/index.dart`
- `lib/pages/splash/controller.dart`
- `lib/pages/splash/view.dart`
- `lib/pages/main/index.dart`
- `lib/pages/main/controller.dart`
- `lib/pages/main/view.dart`
- `lib/pages/main/widgets/bottom_nav.dart`

关键行为：

- `MainPage` 当前用 `IndexedStack` 承载 `Now / Plan / Notes / Profile`
- 底部导航保留 5 个入口位：`Now / Chat / Plan / Notes / Profile`
- 点击 `Chat` 时通过 `context.pushNamed(RouteName.chat)` 进入全屏聊天页

v2 目标行为：

- `Splash` 初始化完成后直接进入 `RouteName.chatHome`。
- `MainPage / BottomNav` 不再出现在首屏。
- `TodayFocus`、`PlanCreate`、`NotesEntry` 等页面从 `ChatHome` 派生进入。

---

## 三、当前实现判断

当前代码与 v1 总计划是一致的：

- `Splash` 独立存在，不与业务页混合。
- `MainShell` 没有把二级页错误塞进壳内。
- `Chat` 是主导航入口，但进入后是独立沉浸式页面，这一点和总技术文档一致。
- `Notes` 已进入主导航，而不是挂在 `Plan` 下面。

结论：

- `Splash` 可沿用。
- `MainShell / BottomNav` 与 v2 信息架构冲突，需要在 `F-024` 中重构或降级。
- 后续重点是根路由、返回栈、二级页沉浸规则和旧入口兼容。

---

## 四、本轮改造边界

本轮只在以下场景修改：

1. v2 根入口仍进入旧 `Now` 或底部 Tab
2. `ChatHome` 入口行为与设计稿冲突
3. `Splash -> MainShell` 跳转链路异常
4. 壳层对 `Notes`、`Profile` 或沉浸页的显示/隐藏规则错误

本轮不做：

- 为了统一风格而重写 Splash
- 在 v2 首屏继续保留底部 Tab 分发

---

## 五、验收标准

- 启动后能稳定进入主壳
- 启动后默认进入 `ChatHome`
- `ChatHome` 首屏没有底部 Tab
- `TodayFocus` 二级全屏页不复用底部导航
- 旧 `Plan / Notes / Profile` 能从 `ChatHome` 派生入口到达

---

## 六、视觉参考

- Figma：`01-SplashScreen`
- Figma：`V2-01-ChatHome-Entry`
- Figma：`V2-02-ChatHome-Active`
- `01-需求/references/images/26-开屏页面_执行力-开屏页.png`
