# 执行力 Flutter 模块开发文档 - App Foundation

> 模块编号：`M-01`  
> 对应总体任务：`F-001 ~ F-006`  
> 状态：`pending`

---

## 一、功能定位与边界

App Foundation 负责为后续所有 Figma 页面提供统一运行底座。

本模块负责：

- `lib/` 目录骨架
- `main.dart`
- `global.dart`
- `theme.dart`
- `RouteName + router + observers`
- `StorageService`
- Hive box 初始化
- Store 与核心 Service 注册
- `CustomScaffold` 和基础通用组件

本模块不负责：

- Splash 视觉细节
- MainShell 导航交互
- 任何业务页面

---

## 二、入口、路由与关键文件

**启动入口**：

- `lib/main.dart`
- `lib/global.dart`

**关键文件**：

- `lib/routes/name.dart`
- `lib/routes/router.dart`
- `lib/routes/observers.dart`
- `lib/theme.dart`
- `lib/services/storage.dart`
- `lib/widgets/custom_scaffold.dart`

首个可运行目标：

- 完成初始化后可进入最小 Splash / MainShell 流程

---

## 三、依赖前置

- 已有 [`flutter-tech.md`](../flutter-tech.md)
- 已有 [`flutter-dev-plan.md`](../flutter-dev-plan.md)
- 当前实现路线已锁定为 `GetX + GetStorage + Hive + Global.init()`

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`01-SplashScreen`
- Figma：底部导航相关 frame
- `01-需求/references/images/26-开屏页面_执行力-开屏页.png`
- `01-需求/references/images/31-主页_执行力-底部导航栏.png`

### 底座结论

- 底座模块必须保证 Splash 和 MainShell 能被无缝承接
- `theme.dart` 需要预置品牌主色、页面背景、主线渐变和按钮渐变能力
- `router` 需要预先注册全部公开路由，哪怕页面先占位
- Notes 相关路由和本地 box 也必须在底座阶段完成预注册，不留到业务页临时补

---

## 五、业务内容与数据流

1. `main()` 调用 `WidgetsFlutterBinding.ensureInitialized()`
2. `Hive.initFlutter()`
3. `await Global.init()`
4. 注册 `StorageService / Store / Core Services`
5. 启动 `MaterialApp.router`
6. 进入 `Splash` 或 `MainShell`

存储边界：

- `GetStorage`：安装实例、轻量设置、启动标记
- `Hive`：计划、任务实例、消息、草稿、资料、Notes 文件夹、Notes 文件、同步记录

---

## 六、建议实现步骤

1. 创建目录骨架与 `index.dart`
2. 配置依赖：`get / get_storage / hive / hive_flutter / go_router / dio / flutter_screenutil`
3. 实现 `main.dart`
4. 实现 `Global.init()`
5. 实现 `StorageService`
6. 打开 Hive box 并注册 Store / Service
7. 建立路由表和通用主题
8. 提供最小 `CustomScaffold`
9. 预注册 `Notes / NoteFolder / NoteFile` 公开路由与本地 box

---

## 七、验收标准

- Flutter 工程可启动
- 全局初始化完整可追踪
- 路由表已覆盖公开页面
- 主题与基础容器可以承接 Figma 页面的品牌色和背景层级

---

## 八、编码注意事项

- 不引入 `Riverpod + Drift`
- 不把页面业务逻辑提前塞进底座模块
- 路由、主题、存储初始化必须先于业务页面落地
