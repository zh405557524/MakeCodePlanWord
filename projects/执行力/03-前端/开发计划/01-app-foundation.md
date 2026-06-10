# 执行力 Flutter 模块开发文档 - App Foundation

> 模块编号：`M-01`
> 对应总体任务：`F-001 ~ F-006`
> 状态：`done`
> 当前策略：基于现有代码增量维护；底座没有明显问题时，不为追求“理想结构”而重构

---

## 一、模块定位

App Foundation 负责整个 Flutter 工程的运行底座，为后续所有页面和业务链路提供统一入口、存储、路由和通用 UI 基础设施。

本模块负责：

- `main.dart`
- `global.dart`
- `theme.dart`
- `RouteName + router + observers`
- `GetStorage`、`Hive` 初始化
- 全局 `Store` 与核心 `Service` 注册
- `CustomScaffold`、按钮、弹框、Toast 等基础 UI 组件

本模块不负责：

- 具体业务页面细节
- Figma 逐页对稿
- 后端真实接口接入

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/main.dart`
- `lib/global.dart`
- `lib/theme.dart`
- `lib/routes/name.dart`
- `lib/routes/router.dart`
- `lib/routes/observers.dart`
- `lib/services/storage.dart`
- `lib/services/installation_service.dart`
- `lib/services/http.dart`
- `lib/services/sync_service.dart`
- `lib/store/config.dart`
- `lib/store/draft.dart`
- `lib/store/notes.dart`
- `lib/store/plan.dart`
- `lib/store/sync.dart`
- `lib/store/user.dart`
- `lib/widgets/custom_scaffold.dart`
- `lib/widgets/custom_button.dart`
- `lib/widgets/dialog.dart`
- `lib/widgets/toast.dart`
- `lib/utils/constants.dart`
- `lib/utils/formatters.dart`

---

## 三、当前实现判断

当前代码已经完成了底座闭环：

- `Global.init()` 已完成 `GetStorage`、安装实例、Hive box、Store、Service 和 bootstrap 注册。
- 公开路由已经预注册到位，包含 `Notes` 相关路由，不需要回退到底座阶段重做。
- 当前 `lib/` 顶层保持 `apis / models / pages / routes / services / store / utils / widgets` 的简洁结构。
- 参考规则中的 `components / enums / l10n / generated / plugins` 是通用扩展位，不是当前项目必须补齐的硬条件。

结论：

- 当前底座实现可继续沿用。
- 除非后续发现启动链路、全局服务、持久化或路由注册存在实际问题，否则本模块不做结构性调整。

### v2 增量影响

v2 不需要推翻底座，但需要调整路由和启动后的默认入口：

- `/` 从旧 `Now / MainShell` 切到 `ChatHomePage`。
- 新增 `/today/focus` 对应 `TodayFocusPage`。
- 新增或兼容 `/plan/create`，可复用 `PlanEditorPage`。
- `ToolMenu` 与 `SideMenu` 是 `ChatHome` 内部 overlay / drawer，不注册独立路由。
- 旧 `MainShell / BottomNav` 不再作为首屏分发结构；如果代码中短期保留，也不能在 v2 首屏展示。

---

## 四、本轮改造边界

本轮如果继续触达本模块，只允许修改以下内容：

1. 启动报错或初始化顺序错误
2. Hive box 未注册导致业务链路不可用
3. 路由常量或路由表与实际页面不一致
4. 通用组件阻塞页面实现
5. v2 `ChatHome / TodayFocus / PlanCreate` 路由缺失或跳转错误

本轮不做：

- 为了和参考工程完全一致而新增空目录
- 无业务收益的基础层重命名
- 将已稳定运行的底座强行拆成更多层次

---

## 五、验收标准

- 工程可稳定启动
- `Global.init()` 可重复执行且不会重复污染状态
- `GetStorage` 与 `Hive` 可被业务模块正常读取
- 路由表包含当前版本所有公开路由
- v2 根路由进入 `ChatHome`
- `TodayFocus` 作为二级全屏页可独立进入和返回
- 通用 UI 组件可承接主壳页与沉浸式二级页

---

## 六、后续关系

- 本模块已完成，后续页面联调或 Figma 对稿如无底座问题，不回退到本模块。
- 若后续接入真实后端接口，只补服务层与同步态，不整体改造 App Foundation。
