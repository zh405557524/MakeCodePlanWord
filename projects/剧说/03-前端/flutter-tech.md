# 剧说 Flutter 技术文档与项目开发规则

> 版本：v0.2.0
> 创建日期：2026-05-18
> 关联 PRD：`../01-需求/requirements.md`
> 关联技术方案：`../02-技术方案/tech-plan.md`
> UI 来源：现有 Figma Page 1 frame 索引 + PRD 页面级需求
> 用户约束：不生成 Figma 图；不评估时长
> 后端口径：Java 方案评估中；视频业务处理已确认接入百度智能云智能点播平台 VOD；Flutter 先按 mock / adapter 层开发，不直连 VOD 密钥或 SDK

---

## 1. 当前 Flutter 最终技术路线

| 维度 | 结论 |
|------|------|
| App 框架 | Flutter |
| 状态管理 | GetX |
| 路由 | go_router |
| 网络 | Dio |
| 本地轻量存储 | GetStorage |
| 本地结构化缓存 | Hive |
| 屏幕适配 | flutter_screenutil，设计基准 375 x 812 |
| 全局初始化 | `Global.init()` |
| 页面骨架 | `CustomScaffold` |
| 模块组织 | `pages/{feature}/index.dart + controller.dart + view.dart` |
| UI 真源 | `requirements.md` + `references/README.md` + Figma Page 1 |

不使用 Riverpod / Provider / Drift 作为本项目主路线。

---

## 2. 继承的 Flutter 通用规则

本项目继承以下通用规则：

- `.cursor/rules/flutter/01-项目初始化规则.mdc`
- `.cursor/rules/flutter/02-项目结构目录.mdc`
- `.cursor/rules/flutter/03-编码规范.mdc`
- `.cursor/rules/flutter/04-导航规则.mdc`
- `.cursor/rules/flutter/05-多语言支持.mdc`
- `.cursor/rules/flutter/06-第三方依赖参考.mdc`
- `.cursor/rules/flutter/07-新功能开发.mdc`
- `.cursor/rules/flutter/08-UI处理任务.mdc`
- `.cursor/rules/flutter/09-大功能先规划再编码.mdc`
- `.cursor/rules/flutter/10-编码工作流程.mdc`

当前项目特化点：

- UI 对稿优先看现有 Figma frame 和 PRD，不依赖新生成的 Figma 设计稿。
- 当前没有 `referenceProject`，不引用外部 Flutter 工程。
- 当前跳过工时评估，开发文档只给任务顺序和依赖，不写人天。
- 三个缺失页面邀请好友、我的页更多设置、意见反馈按 PRD 先行定义页面模块。
- 后端建议采用 Java + Spring Boot + Gradle，但接口、字段、状态码和供应商仍待定稿；Flutter 只能先定义前端 Service 抽象和 mock 数据。

---

## 3. 当前项目结构

```text
lib/
├── apis/
├── components/
├── enums/
├── generated/
├── l10n/
├── models/
│   ├── params/
│   ├── responses/
│   └── data/
├── pages/
│   ├── main/
│   ├── auth/
│   ├── creation/
│   ├── works/
│   ├── account/
│   ├── membership/
│   ├── points/
│   ├── invite/
│   ├── settings/
│   ├── feedback/
│   └── webview/
├── plugins/
├── routes/
├── services/
├── store/
├── utils/
├── widgets/
├── global.dart
├── main.dart
└── theme.dart
```

页面模块默认结构：

```text
lib/pages/{feature_name}/
├── index.dart
├── controller.dart
├── view.dart
├── widgets/
└── dialog/
```

---

## 4. 第三方依赖基线

### 4.1 基础必选

- `get`
- `go_router`
- `dio`
- `package_info_plus`

### 4.2 当前启用的通用可选

- `get_storage`
- `hive`
- `flutter_screenutil`
- `flutter_localizations`
- `intl`
- `permission_handler`
- `url_launcher`
- `share_plus`
- `image_picker`
- `file_picker`

### 4.3 业务专用待确认

- 运营商一键登录 SDK
- 短信服务 SDK 或后端短信能力
- 支付宝 / 微信支付 SDK
- 视频播放 SDK 或 Flutter 播放组件
- 上传 SDK 或后端签名直传组件
- APM / 崩溃统计 SDK

业务专用依赖必须在供应商确认后再引入，不在初始化阶段一次性全部安装。

---

## 5. 启动与全局初始化

启动顺序：

1. `WidgetsFlutterBinding.ensureInitialized()`
2. 设置系统状态栏样式。
3. `Global.init()`
4. 初始化 GetStorage / Hive。
5. 注册 `HttpService`、`EventService`、`UserStore`、`ConfigStore`。
6. 启动 `MaterialApp.router`。
7. 初始化 ScreenUtil，设计尺寸固定为 `375 x 812`。

全局 Store：

- `UserStore`：token、用户资料、积分、会员状态、邀请码。
- `ConfigStore`：协议同意、缓存配置、版本信息。
- `CreationStore`：当前创作草稿、已选素材、生成参数。

---

## 6. 状态管理与数据流

页面状态分层：

- 页面 Controller：loading、empty、error、submitting、表单输入、当前页面列表。
- Store：跨页面共享状态，如用户信息、积分余额、会员权益、创作草稿。
- Service：HTTP、上传、支付、分享、缓存、日志等可复用动作。

典型链路：

```text
View -> Controller -> Service / Store -> API -> Model -> Controller.update() -> View
```

约束：

- Controller 不使用 `Get.context`。
- 复杂业务动作不得直接写在 Widget 回调中。
- API 错误必须转成用户可读提示。
- 关键链路必须覆盖 loading / empty / error / success。
- 后端未定稿前，`apis/` 只暴露前端方法名和领域模型，真实路径、字段、错误码通过 adapter 后续替换。

---

## 7. 存储设计

| 存储对象 | 存储方式 | 说明 |
|----------|----------|------|
| token | GetStorage | 登录态轻量保存 |
| 协议勾选状态 | GetStorage | 登录页与充值页使用 |
| 用户基础信息 | GetStorage + 内存 Store | App 启动恢复 |
| 创作草稿 | Hive | 已选素材、风格、配音、语速、更多设置 |
| 素材列表缓存 | Hive | 已上传素材列表的视图缓存 |
| 设置项 | GetStorage | 清理缓存、版本提示等 |

敏感信息不长期明文保存。下载地址、视频源地址等应按需获取，避免长期缓存。

---

## 8. 路由配置

路由名集中维护在 `RouteName`，不得散落裸字符串。

| RouteName | Path | 页面 |
|-----------|------|------|
| `main` | `/` | 主框架 |
| `login` | `/login` | 登录页 |
| `creationVideo` | `/creation/video` | 视频解说创建页 |
| `workDetail` | `/works/:id` | 作品详情 |
| `membership` | `/membership` | VIP 会员页 |
| `pointsRecharge` | `/points/recharge` | 积分充值页 |
| `pointsLedger` | `/points/ledger` | 积分详情 |
| `invite` | `/invite` | 邀请好友 |
| `settings` | `/settings` | 我的页更多设置 |
| `feedback` | `/feedback` | 意见反馈 |
| `webview` | `/webview` | 协议 / 隐私 / 规则页 |

路由守卫：

- 未登录访问创作生成、作品详情、我的页敏感入口时，跳转登录。
- 登录成功后返回原目标页面。
- 协议页面和登录页不需要登录。

---

## 9. UI 基础规范

- 设计基准尺寸：375 x 812。
- 主视觉：深色背景，黄绿色渐变用于主按钮和高亮选择。
- 使用 `flutter_screenutil` 后，尺寸统一用 `.w`、`.h`、`.sp`、`.r`。
- 页面实现按 UI 从上到下拆区块，不先写抽象功能。
- 稳定复用：
  - `CustomScaffold`
  - 主按钮
  - 弹层容器
  - 选项卡 / segmented control
  - 空态组件
  - 错误态组件
  - 视频缩略图卡片
  - 积分 / 会员卡片
- 当前没有新 Figma 图，缺失页按 PRD 页面结构实现，后续若补设计再做 UI 对齐。

---

## 10. 页面实现摘要

| 模块 | 页面 | 来源 | 实现要点 |
|------|------|------|----------|
| main | 创作首页 / 作品 / 我的 tab | Figma 1、4、5、6 | 底部导航、首页案例、作品状态、我的入口 |
| auth | 一键登录 / 验证码登录 | Figma 10、11 | 协议勾选、验证码倒计时、登录态保存 |
| creation | 视频解说创建页 | Figma 12、13 | 上传、已选素材、语速、立即生成 |
| creation | 风格弹层 | Figma 14、15 | 视频解说 / 视频精剪切换和选中态 |
| creation | 配音弹层 | Figma 16 | 试听、选择、情绪标签 |
| creation | 更多设置弹层 | Figma 17 | 多样版本开关、背景音乐入口 |
| creation | 选择视频 / 删除确认 | Figma 18、20 | 素材列表、取消确定、二次确认 |
| works | 作品列表 / 详情 | Figma 4、5、19 | 空态、分类筛选、播放、下载 |
| account | 我的页 | Figma 6 | 用户资料、邀请码、积分、VIP、入口 |
| membership | VIP 会员 | Figma 7 | 权益、套餐、协议、充值 |
| points | 积分充值 / 积分详情 | Figma 8、9 | 套餐、支付方式、流水 |
| invite | 邀请好友 | PRD 缺失页 | 邀请码、分享、规则、记录 |
| settings | 更多设置 | PRD 缺失页 | 协议、版本、缓存、退出、注销 |
| feedback | 意见反馈 | PRD 缺失页 | 类型、描述、附件、联系方式、提交 |

---

## 11. 编码任务清单

任务 ID 与 `tech-plan.md` 中 T-F00x 对齐：

| 任务 ID | Flutter 模块 | 主要文件 |
|---------|--------------|----------|
| T-F001 | 工程骨架 | `main.dart`、`global.dart`、`theme.dart`、`routes/`、`services/`、`store/`、`widgets/` |
| T-F002 | 登录模块 | `pages/auth/`、`apis/auth.dart`、`store/user.dart`，先接 mock |
| T-F003 | 主框架与首页 | `pages/main/`、`pages/main/widgets/` |
| T-F004 | 创作页 | `pages/creation/`、`models/data/creation_*`，先本地草稿 |
| T-F005 | 创作弹层 | `pages/creation/dialog/`、`pages/creation/widgets/` |
| T-F006 | 作品模块 | `pages/works/`、`apis/works.dart`，先 mock 作品 |
| T-F007 | 我的页 | `pages/account/`、`store/user.dart` |
| T-F008 | 会员与积分 | `pages/membership/`、`pages/points/`、`apis/payment.dart`，先 mock 套餐和流水 |
| T-F009 | 邀请好友 | `pages/invite/`、`apis/invite.dart` |
| T-F010 | 更多设置 | `pages/settings/`、`services/storage.dart` |
| T-F011 | 意见反馈 | `pages/feedback/`、`apis/feedback.dart`，先本地提交成功态 |
| T-F012 | 状态与异常补齐 | `widgets/`、各页面 Controller |

---

## 12. 编码注意事项

- 先完成路由、模型、API、Store，再写页面 UI。
- 每个页面必须至少有 loading / empty / error / success 状态。
- 所有弹窗优先放在对应页面模块的 `dialog/`。
- 可复用业务组件放 `components/`，基础 UI 放 `widgets/`。
- 素材上传、支付、登录 SDK 未确认前使用 Service 抽象接口，不在页面写死供应商实现。
- 后端接口待确定时，所有 API 文件必须支持 mock data source，页面不得依赖最终真实路径。
- 积分扣减、创建任务、订单支付等关键动作要支持防重复提交。
- 邀请好友、更多设置、意见反馈是当前缺失页，编码前必须先按 PRD 完成模块计划或页面骨架。

---

## 13. 项目专属开发规则

### 13.1 继承规则

- 目录结构继承通用 `lib/` 分层。
- 页面模块继承 `index.dart + controller.dart + view.dart`。
- 状态管理继承 GetX。
- 路由继承 go_router。
- UI 处理继承先拆区块、再建状态、再补反馈。

### 13.2 裁剪规则

- 当前不引用 `referenceProject`，因为 workflow 未指定参考工程。
- 当前不启用 Riverpod、Provider、Drift。
- 当前不生成新 Figma 图，不把 `figma-design-plan.md` 作为强依赖。
- 当前不输出工时、人天或日历排期。

### 13.3 特化规则

- UI 真源优先级：PRD 页面级需求 -> `references/README.md` frame 索引 -> Figma Page 1 原图。
- 缺失页以 PRD 为准先做页面结构，后续若补 Figma 再对稿。
- 视频生成链路必须保留任务状态抽象，不把状态写死成单一成功流。
- 积分、会员、支付相关 UI 必须支持 submitting / disabled，避免重复提交。

### 13.4 导航规则

- 所有页面走 `RouteName`。
- 主 tab 使用主框架内部状态；详情和二级页使用 `pushNamed`。
- 登录守卫集中在 router，不散落页面。
- 作品详情使用 path 参数；WebView 使用 query 参数传 URL / title。

### 13.5 多语言规则

- 当前默认中文，但保留 `l10n/` 和 `generated/` 目录。
- 用户可见文案优先集中管理，避免在复杂页面里硬编码大量文案。
- 日期、积分数字、价格展示统一走格式化工具。

### 13.6 Flutter 编码推进流程

1. 读取 `workflow.md`、`flutter-tech.md`、后续 `flutter-dev-plan.md`。
2. 确认当前任务 ID 和恢复点。
3. 写最小实现计划，列出本轮文件范围。
4. 按模型、API、Store、Controller、View、状态补齐的顺序实现。
5. 执行 `flutter analyze`。
6. 回写 workflow 和对应开发计划状态。

---

## 14. 下一步

本文件完成后，默认下一步是生成 `projects/剧说/03-前端/flutter-dev-plan.md`。如果直接进入编码，仍需要先补 Flutter 总体开发计划和模块开发文档，避免大功能直接铺开。

---

## 15. CHG-0011 Flutter / 后台 Web 文档审核补充

> 状态：`waiting_review`。邀请好友专题前端开发文档已拆为独立文件，Flutter 技术总文档只保留索引。

独立前端开发文档：`projects/剧说/03-前端/开发计划/07-邀请好友前端开发文档.md`。

该文档覆盖 App Flutter 的登录携带邀请码、绑定邀请人、推广素材、我的收益、邀请列表、收益明细、提现、提现记录，以及后台 Web 的邀请规则配置和提现管理。
