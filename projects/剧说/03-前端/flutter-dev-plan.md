# 剧说 Flutter 总体开发计划

> 版本：v0.2.0
> 创建日期：2026-05-18
> 关联文档：`flutter-tech.md`、`../02-技术方案/tech-plan.md`、`../01-需求/requirements.md`
> 当前状态：T-F001 至 T-F013 Flutter 前端编码与包名配置已完成；T-F014 Figma REST 图标导出方案已撤销
> 用户约束：不生成 Figma 图；不评估时长；后端 Java 方案评估中，最终接口与供应商待确定

---

## 1. 文档用途

本文用于指导后续 AI 或开发者按阶段实施剧说 Flutter 前端。它只负责 Flutter 总体开发顺序、恢复点、任务边界、模块计划清单和编码约束。

当前已按用户要求一次性生成全部 Flutter 模块开发文档，并已在 `/Users/soul/code/lxwx/narrate` 完成 T-F001 至 T-F012 前端编码与 T-F013 包名配置；T-F014 Figma REST 图标资源导出因限流已撤销。本文继续作为编码阶段的总体任务索引，不输出工时，不锁定后端接口。

---

## 2. 当前状态与恢复点

| 字段 | 当前值 |
|------|--------|
| 当前阶段 | `13 Flutter 编码` |
| 当前状态 | `done` |
| 当前恢复点 | `/Users/soul/code/lxwx/narrate` |
| Flutter 工程路径 | `/Users/soul/code/lxwx/narrate` |
| 参考工程 | 无 |
| 后端接口 | Java 方案评估中，真实接口待定 |
| 当前执行策略 | 前端先行已落地，使用 mock / adapter 层承接后续真实接口 |

`T-F001` 至 `T-F013` 已完成，`T-F014` 已撤销。Flutter 工程内已写入 `.cursor/rules/`，后续代码编写以工程内规则为准。下一步恢复点为 Flutter 验收、真实接口定稿后的 adapter 替换或 QA。

---

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 正在执行 |
| `waiting_review` | 等待用户审核 |
| `done` | 已完成 |
| `blocked` | 被缺失信息阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

- 每个任务开始前，把状态从 `pending` 改为 `in_progress`。
- 任务完成并验证后，改为 `done`。
- 若任务需要用户确认或设计 / 接口补充，改为 `waiting_review` 或 `blocked`。
- 任务状态变更必须同步回写本文档和 `workflow.md`。
- 后端接口待确定期间，所有 API 任务只能完成 mock / adapter 层，不得宣称真实联调完成。

---

## 4. 总体开发策略

### 4.1 技术路线

- Flutter + GetX
- go_router
- Dio
- GetStorage + Hive
- Global.init()
- CustomScaffold
- flutter_screenutil，设计基准 375 x 812

### 4.2 前端先行原则

- UI 和交互以 `requirements.md`、`references/README.md`、Figma Page 1 为准。
- 后端建议采用 Java + Spring Boot + Gradle，但最终接口与供应商仍待定稿；前端先建立 `apis/` 方法、领域模型、mock data source 和 Service adapter。
- 页面不得直接依赖真实接口路径。
- 生成任务、支付、积分扣减等高风险链路先实现前端状态与占位流程，真实联调后再收敛。

### 4.3 不做事项

- 不生成 Figma 图。
- 不输出人天、日历排期或工时估算。
- 不在 Flutter 计划内生成后端 Java 技术文档。
- 不在未确认 `frontendRepo` 的情况下进入 Flutter 编码。
- 不把 `tech-plan.md` 中的后端占位契约当作最终后端实现。

---

## 5. 总体阶段划分

> 用户已明确跳过工时评估，因此本节只说明顺序、依赖和验收目标。

| 阶段 | 任务范围 | 依赖 | 阶段目标 |
|------|----------|------|----------|
| F0 基础设施 | T-F001 | 无 | 工程骨架、路由、主题、服务、存储、通用状态完成 |
| F1 登录与主框架 | T-F002、T-F003、T-F007 | F0 | 可进入登录、主 tab、创作首页、作品页、我的页 |
| F2 创作前端闭环 | T-F004、T-F005、T-F012 | F0、F1 | 可完成素材选择、参数配置、积分预估占位、生成确认前端流 |
| F3 作品前端闭环 | T-F006、T-F012 | F0、F1 | 可查看作品空态、列表、详情、播放占位和下载入口 |
| F4 商业化与我的二级页 | T-F008、T-F009、T-F010、T-F011、T-F012 | F0、F1 | VIP、积分、邀请好友、更多设置、意见反馈前端闭合 |
| F5 联调准备 | 全部 T-F | 后端接口定稿后 | 替换 mock、补真实接口映射、整理联调清单 |

---

## 6. 详细任务清单

### T-F001 工程骨架

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 创建 Flutter 基础结构与全局能力 |
| 涉及目录 | `.cursor/rules/`、`lib/main.dart`、`global.dart`、`theme.dart`、`routes/`、`services/`、`store/`、`widgets/`、`utils/` |
| 业务边界 | 不做具体业务页面，只提供壳和基础服务 |
| 后端依赖 | 无 |
| 验收 | Flutter 工程内 `.cursor/rules/` 已写入；App 可启动，主路由可进入，基础主题和 toast / loading 可用 |

### T-F002 登录模块

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现一键登录和验证码登录前端流程 |
| 涉及目录 | `pages/auth/`、`apis/auth.dart`、`store/user.dart`、`models/` |
| 业务边界 | 协议勾选、验证码倒计时、登录成功写入 mock 用户态 |
| 后端依赖 | 待确定；先用 mock 登录响应 |
| 验收 | 登录页两种状态可切换，未勾选协议有提示，mock 登录后进入主框架 |

### T-F003 主框架与首页

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现底部导航、创作首页、热门案例 |
| 涉及目录 | `pages/main/`、`pages/main/widgets/` |
| 业务边界 | 创作 / 作品 / 我的三 tab；创建项目入口跳创作页 |
| 后端依赖 | 待确定；热门案例先 mock |
| 验收 | 三个 tab 可切换，首页视觉结构与 Figma frame 1 对齐 |

### T-F004 创作页

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现视频解说创建页默认态和已选视频态 |
| 涉及目录 | `pages/creation/`、`models/data/creation_*`、`store/creation.dart` |
| 业务边界 | 上传入口、已选素材、本地草稿、语速选择、立即生成入口 |
| 后端依赖 | 待确定；素材和积分预估先 mock / 本地 |
| 验收 | 默认态、已选态、限制提示、总时长展示、按钮状态完整 |

### T-F005 创作弹层

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现风格、配音、更多设置、选择视频、删除确认 |
| 涉及目录 | `pages/creation/dialog/`、`pages/creation/widgets/` |
| 业务边界 | 选择结果回填创建页；取消不保存；确定保存 |
| 后端依赖 | 待确定；风格、配音、素材列表先 mock |
| 验收 | Figma frame 14-18、20 对应弹层状态可点通 |

### T-F006 作品模块

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现作品空态、列表、详情、播放预览和下载入口 |
| 涉及目录 | `pages/works/`、`apis/works.dart`、`models/data/work.dart` |
| 业务边界 | 分类筛选、草稿 / 完成 / 失败等前端状态、详情页参数标签 |
| 后端依赖 | 待确定；作品列表和详情先 mock |
| 验收 | Figma frame 4、5、19 关键结构完整，空态可跳创作 |

### T-F007 我的页

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现我的页账号、邀请码、积分、VIP 和入口 |
| 涉及目录 | `pages/account/`、`store/user.dart` |
| 业务边界 | 复制邀请码、进入邀请 / 积分 / 充值 / 反馈 / 设置 |
| 后端依赖 | 待确定；用户信息先 mock |
| 验收 | Figma frame 6 结构完整，所有入口有路由 |

### T-F008 会员与积分

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 实现 VIP 会员、积分充值、积分详情 |
| 涉及目录 | `pages/membership/`、`pages/points/`、`apis/payment.dart` |
| 业务边界 | 套餐选择、协议勾选、支付提交占位、积分流水 |
| 后端依赖 | 待确定；套餐、订单、流水先 mock |
| 验收 | Figma frame 7、8、9 关键结构完整，提交状态可见 |

### T-F009 邀请好友

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 补齐用户确认缺失页：邀请好友 |
| 涉及目录 | `pages/invite/`、`apis/invite.dart` |
| 业务边界 | 邀请码、复制、分享、规则、记录 / 空态 |
| 后端依赖 | 待确定；邀请数据先 mock |
| 验收 | 从我的页进入，复制和分享有反馈，空态和记录态完整 |

### T-F010 更多设置

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 补齐用户确认缺失页：我的页更多设置 |
| 涉及目录 | `pages/settings/`、`services/storage.dart`、`pages/webview/` |
| 业务边界 | 协议、隐私、版本、清理缓存、退出登录、注销账号 |
| 后端依赖 | 待确定；注销账号先做确认流程占位 |
| 验收 | 设置项可点击，退出登录二次确认，协议入口可打开 |

### T-F011 意见反馈

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 补齐用户确认缺失页：意见反馈 |
| 涉及目录 | `pages/feedback/`、`apis/feedback.dart` |
| 业务边界 | 类型、描述、附件、联系方式、提交状态 |
| 后端依赖 | 待确定；提交先本地成功态 |
| 验收 | 描述为空不可提交，提交中 / 成功 / 失败状态完整 |

### T-F012 状态与异常补齐

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 补齐全局 loading / empty / error / disabled / submitting / not_found |
| 涉及目录 | `widgets/`、`components/`、各页面 Controller |
| 业务边界 | 不新增业务，仅补状态组件和页面接入 |
| 后端依赖 | 无 |
| 验收 | 所有页面至少覆盖 loading、empty、error、success |

### T-F013 包名配置

| 字段 | 内容 |
|------|------|
| 状态 | `done` |
| 目标 | 将 Android 包名和 iOS Bundle Identifier 统一为 `com.lxwx.narrate` |
| 涉及目录 | `android/app/build.gradle.kts`、`android/app/src/main/kotlin/`、`ios/Runner.xcodeproj/project.pbxproj`、`README.md` |
| 业务边界 | 只调整包名 / Bundle Identifier，不调整签名、证书、商店配置 |
| 后端依赖 | 无 |
| 验收 | `flutter analyze`、`flutter test`、`plutil -lint ios/Runner.xcodeproj/project.pbxproj` 通过；Android debug 构建已尝试但 Gradle `assembleDebug` 长时间无输出被中断 |

### T-F014 Figma 图标资源导出

| 字段 | 内容 |
|------|------|
| 状态 | `cancelled` |
| 目标 | 原计划从 Figma 导出所有 `icon_` 前缀节点到 Flutter 本地资源 |
| 涉及目录 | `.cursor/rules/08-UI处理任务.mdc`、`pubspec.yaml`、`lib/utils/assets.dart`、`README.md` |
| 业务边界 | 不再使用 Figma REST API 下载资源；相关规则、配置和本地导出文件已清理 |
| 后端依赖 | 无 |
| 验收 | REST API 导出方案已撤销，当前不注册 `icon_` 本地资源 |

---

## 7. 模块开发文档列表

模块开发文档已按用户要求一次性生成。编码阶段按下表选择当前任务文档作为恢复点。

| 模块文档 | 覆盖任务 | 输出路径 | 文档状态 |
|----------|----------|----------|----------|
| 工程骨架模块 | T-F001 | `projects/剧说/03-前端/开发计划/01-工程骨架.md` | `done` |
| 登录与主框架模块 | T-F002、T-F003、T-F007 | `projects/剧说/03-前端/开发计划/02-登录主框架我的页.md` | `done` |
| 创作模块 | T-F004、T-F005 | `projects/剧说/03-前端/开发计划/03-创作流程.md` | `done` |
| 作品模块 | T-F006 | `projects/剧说/03-前端/开发计划/04-作品模块.md` | `done` |
| 商业化与二级页模块 | T-F008、T-F009、T-F010、T-F011 | `projects/剧说/03-前端/开发计划/05-商业化与我的二级页.md` | `done` |
| 状态与验收模块 | T-F012 | `projects/剧说/03-前端/开发计划/06-状态与验收.md` | `done` |

---

## 8. 编码约束

- 编码前必须确认 `frontendRepo`。
- 进入 T-F001 后必须先把 Flutter Cursor 规则写入 `frontendRepo/.cursor/rules/`。
- 工程内 `.cursor/rules/` 写入后，后续代码编写以工程内规则为准；外层规则只作为首次落地来源。
- 编码前必须读取 `workflow.md`、`flutter-tech.md`、`flutter-dev-plan.md` 和当前模块文档。
- 不允许跳过模块文档直接实现复杂业务。
- 不允许把尚未定稿的真实接口路径写死到页面层。
- `apis/` 只暴露方法和模型；真实路径放 adapter 或后续接口配置。
- 页面 Controller 不使用 `Get.context`。
- UI 改动必须同步检查 Controller 状态。
- 所有用户可见失败必须有 toast、错误态或可重试入口。
- 每完成一个 Flutter 模块或关键修复，必须同步更新 `/Users/soul/code/lxwx/narrate/README.md` 中的工程目录、业务功能、开发进度或待联调事项，保证用户能直接从工程 README 了解当前开发进度。
- 每轮编码完成至少执行 `flutter analyze`，无法执行时必须说明原因。

---

## 9. 真实接口待确定下的前端联调策略

| 场景 | 当前做法 | 后端确定后 |
|------|----------|------------|
| 登录 | mock token 和用户信息 | 替换 AuthApi adapter |
| 用户资料 | mock UserStore | 对接 profile 接口 |
| 素材列表 | mock / 本地素材模型 | 对接素材列表和上传凭证 |
| 生成预估 | 本地按总时长估算展示 | 对接真实预估接口 |
| 创建任务 | 前端创建 mock taskId | 对接任务创建接口 |
| 作品列表 | mock 作品列表 | 对接作品分页接口 |
| 会员套餐 | mock 套餐 | 对接套餐配置接口 |
| 支付 | 提交占位状态 | 对接支付 SDK 和订单接口 |
| 邀请好友 | mock 邀请码和记录 | 对接邀请概览接口 |
| 意见反馈 | 本地成功 / 失败状态 | 对接反馈提交接口 |

---

## 12. CHG-0011 邀请收益与提现文档审核补充

> 状态：`waiting_review`。本节新增任务只用于文档审核，不进入 Flutter / 后台 Web 编码。

### 12.1 新增任务

| 任务 ID | 任务 | 描述 | 状态 |
|---------|------|------|------|
| T-F015 | 邀请收益与提现 App 页面 | 绑定邀请人、推广素材、我的收益、邀请列表、收益明细、提现、提现记录 | waiting_review |
| T-F016 | 后台 Web 邀请收益管理 | 邀请规则配置、提现申请列表、审核 / 驳回 / 打款状态 | waiting_review |

### 12.2 模块文档

| 模块文档 | 覆盖任务 | 输出路径 | 文档状态 |
|----------|----------|----------|----------|
| 邀请好友前端开发文档 | T-F015、T-F016 | `projects/剧说/03-前端/开发计划/07-邀请好友前端开发文档.md` | waiting_review |

### 12.3 审核门禁

- 审核通过前不修改 `/Users/soul/code/lxwx/narrate`。
- 审核通过前不修改 `/Users/soul/code/lxwx/lxwx_admin`。
- 审核通过后再按模块文档进入编码，并执行对应 Flutter analyze / test / build。

---

## 10. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-05-18 13:53 | 根据用户要求生成 Flutter 总体开发计划 | 已生成，状态 `waiting_review` |
| 2026-05-18 14:04 | 生成 Flutter 模块开发文档：工程骨架 | 已生成 `开发计划/01-工程骨架.md` |
| 2026-05-18 14:18 | 按用户要求一次性生成剩余 Flutter 模块开发文档 | 已生成 `02-登录主框架我的页.md`、`03-创作流程.md`、`04-作品模块.md`、`05-商业化与我的二级页.md`、`06-状态与验收.md` |
| 2026-05-18 14:30 | 根据用户要求补充工程骨架规则落地要求 | 已明确 T-F001 首步写入 `frontendRepo/.cursor/rules/`，后续编码以工程内规则为准 |
| 2026-05-18 14:42 | 执行 T-F001 工程骨架编码 | 已在 `/Users/soul/code/lxwx/narrate` 完成工程内规则、依赖、`lib/` 分层骨架、路由、服务、Store、通用组件和主框架占位页；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 15:55 | 实现 API 与 SDK 编码方案调整 | 已落地 mock / real adapter、10 个 API、DTO / 领域模型、统一错误转换和 API adapter 测试；未引入未确认业务 SDK |
| 2026-05-18 16:12 | 执行 T-F002/T-F003/T-F007 | 已完成登录、主框架 / 创作首页、我的页与路由接入；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:19 | 执行 T-F004/T-F005 | 已完成创作页与创作弹层闭环；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:26 | 执行 T-F006 | 已完成作品列表、空态、详情、状态标签和下载占位；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:32 | 执行 T-F008 | 已完成 VIP 会员、积分充值、积分流水和支付占位流程；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:38 | 执行 T-F009/T-F010/T-F011 | 已完成邀请好友、更多设置、意见反馈和协议静态页；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 16:40 | 执行 T-F012 | 已完成 `ViewState`、`AppStateBuilder`、`AppButton`、校验器、keyed mock 空态 / 失败开关与主要页面状态接入；`flutter analyze`、`flutter test` 均通过 |
| 2026-05-18 17:49 | 执行 T-F013 | 已将 Android `namespace/applicationId/MainActivity` 和 iOS Runner `PRODUCT_BUNDLE_IDENTIFIER` 统一为 `com.lxwx.narrate`；`flutter analyze`、`flutter test`、`plutil -lint` 通过；Android debug 构建卡在 Gradle `assembleDebug` 长时间无输出，已中断 |
| 2026-05-19 10:23 | 撤销 T-F014 | 因 Figma REST API 限流，不再使用 REST API 下载图标；已清理 REST 下载规则、本地 MCP 配置和导出资源记录 |

---

## 11. 下一步

当前 `T-F001` 至 `T-F013` Flutter 前端编码与包名配置已完成，`T-F014` REST 图标资源导出已撤销。下一步进入 Flutter 验收、QA 或在正式接口文档提供后替换 API adapter / DTO mapper；后端真实接口、支付 / 短信 / 一键登录 / 视频 / 对象存储等业务 SDK 仍待确定。
