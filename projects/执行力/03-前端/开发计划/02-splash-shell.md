# 执行力 Flutter 模块开发文档 - Splash 与 Main Shell

> 模块编号：`M-02`  
> 对应总体任务：`F-007 ~ F-008`  
> 状态：`pending`

---

## 一、功能定位与边界

本模块负责启动过渡与主应用壳层。

本模块负责：

- SplashScreen
- 自动跳转逻辑
- MainShell
- 底部导航
- 一级页容器与 Chat 入口位

本模块不负责：

- Now / Plan / Profile 的具体业务
- Chat 的消息流实现
- 二级详情页

---

## 二、入口、路由与页面文件

**路由**：

- `RouteName.splash`
- `RouteName.now`
- `RouteName.chat`
- `RouteName.plan`
- `RouteName.notes`
- `RouteName.profile`

**页面文件**：

- `lib/pages/splash/view.dart`
- `lib/pages/splash/controller.dart`
- `lib/pages/main/view.dart`
- `lib/pages/main/controller.dart`
- `lib/pages/main/widgets/bottom_nav.dart`

---

## 三、依赖前置

- `01-app-foundation` 已完成
- `Global.init()`、路由表、`CustomScaffold` 可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`01-SplashScreen`
- Figma：底部导航相关结构
- `01-需求/references/images/26-开屏页面_执行力-开屏页.png`
- `01-需求/references/images/31-主页_执行力-底部导航栏.png`

### 页面结构结论

- Splash 是品牌启动页，深色渐变背景 + Logo + 文案 + 加载点
- MainShell 是浅色底部导航壳，不承载二级页
- 底部导航需要保留 5 个入口位：Now / Chat / Plan / Notes / Profile
- Chat 入口位点击后进入全屏 `ChatPage`，不是在壳内长期展示深色聊天页

---

## 五、业务内容与数据流

1. 进入 `Splash`
2. `SplashController` 确认初始化完成并等待展示时长
3. 跳转到 `MainShell`
4. `MainController` 管理当前壳页索引
5. 点击 Chat 入口时 push 到 `RouteName.chat`

`MainShell` 负责承接的一级页：

- `Now`
- `Plan`
- `Notes`
- `Profile`

---

## 六、建议实现步骤

1. 创建 `SplashPage / Controller`
2. 创建 `MainPage / Controller`
3. 建最小壳页容器
4. 实现底部导航
5. 接入 Splash 自动跳转
6. 接入 Chat 全屏入口

---

## 七、验收标准

- 启动先进入 Splash
- Splash 能自动跳转 MainShell
- 底部导航 5 个入口位完整
- Chat 入口进入全屏路由
- MainShell 不承担二级页面

---

## 八、编码注意事项

- Splash 只做品牌和启动过渡
- MainShell 只做壳层，不写业务
- 不把 BattleMap / TrackDetail / UserProfile 放进壳层
