# 剧说 技术方案计划

> 版本：v0.2.0
> 创建日期：2026-05-18
> 关联需求文档：`../01-需求/requirements.md`
> 关联设计来源：`../01-需求/references/README.md` 中的 Figma Page 1 frame 索引
> 用户约束：不生成 Figma 图；不评估时长
> 后端口径：已进入方案评估；建议 Java 21 + Spring Boot 3.x + Gradle，供应商和最终接口仍待确认
> 关联后端评估：`./backend-evaluation.md`

---

## 0. 后端方案评估说明

用户已要求继续推进“剧说”的后端方案评估。当前后端主线建议收敛为 Java 21 + Spring Boot 3.x + Gradle，详细评估见 `./backend-evaluation.md`。

当前阶段已经明确：

- 后端语言建议使用 Java。
- 框架建议使用 Spring Boot 3.x。
- 构建工具建议使用 Gradle。
- 数据库建议使用 PostgreSQL，缓存 / 幂等建议使用 Redis。
- 后端应统一承接登录、支付、积分账本、视频生成任务、素材和作品数据。
- 本轮已补充接口契约草案、生成任务状态机、积分账本规则、支付幂等和 Provider Adapter 设计。
- 视频业务处理已确认接入百度智能云智能点播平台 VOD，后端通过 `BaiduVodProvider` 承接上传、媒资处理、视频生成、回调和播放地址签发。

当前阶段仍未最终锁定：

- 短信、一键登录、支付供应商。
- 百度 VOD 的账号区域、工作流 / 模板、回调签名、自定义域名、播放鉴权和生成结果存储策略。
- 最终 API 路径、请求体、响应体、错误码和任务状态枚举。
- 是否需要后台管理端、运营配置端和财务对账工具。

Flutter 开发仍只能依赖前端业务契约与 mock 数据，不得把本文候选接口当成最终接口。

---

## 1. 系统架构概述

### 1.1 整体架构

剧说采用前端先行、Java 后端方案评估中的分层方案：

- Flutter App 负责登录、创作配置、素材选择、任务状态展示、作品播放下载、会员积分和我的页二级功能。
- 后端建议采用 Java + Spring Boot + Gradle：账号鉴权、积分账务、会员订单、素材与作品元数据、生成任务编排、反馈与邀请数据由后端统一承接。
- 视频上传、转码、生成、存储、播放、支付、短信等外部能力后续由后端或服务适配层统一确认，Flutter 端不直连核心密钥。
- 当前阶段视频业务已绑定百度智能云智能点播平台 VOD；短信和支付供应商仍未绑定，前端只保留 Service 抽象层。

### 1.2 技术栈选型

| 层级 | 技术 | 选型理由 |
|------|------|----------|
| 前端 | Flutter | 单套移动端 UI，适配 iOS / Android |
| 状态管理 | GetX | 与本项目 Flutter 通用规则库一致，页面 Controller 清晰 |
| 路由 | go_router | 路由集中配置，支持主导航与子流程 |
| 网络 | Dio | 统一拦截器、鉴权、错误处理，支持 mock / real 切换 |
| 本地存储 | GetStorage + Hive | GetStorage 保存轻量配置，Hive 缓存草稿和素材视图数据 |
| 后端 | Java 21 + Spring Boot 3.x + Gradle | 适合登录、支付、积分账本、任务回调和第三方 SDK 集成 |
| 数据库 | PostgreSQL | 适合用户、订单、账本、任务、作品等关系型数据 |
| 缓存 | Redis | 用于验证码、限流、幂等、支付回调锁和任务短期状态 |
| 文件 / 视频 | 百度智能云智能点播平台 VOD | 后端承接上传参数、媒资 ID、视频生成回调、播放 / 下载地址签发；Flutter 端仍走抽象能力 |
| 支付 | 待确定 | Flutter 端先抽象订单创建与支付结果承接 |

---

## 2. 领域模型设计（最终接口待确定）

### 2.1 前端关注模型

| 领域对象 | 说明 | 前端关注字段 |
|----------|------|--------------|
| User | 用户账号 | `id`、`phoneMasked`、`inviteCode`、`vipStatus`、`pointsBalance` |
| InviteRecord | 邀请记录 | `id`、`nicknameMasked`、`rewardStatus`、`createdAt` |
| MembershipPlan | 会员套餐 | `id`、`name`、`periodLabel`、`priceText`、`benefits` |
| PointLedger | 积分流水 | `id`、`title`、`dateText`、`amount`、`direction` |
| MediaAsset | 视频素材 | `id`、`name`、`durationText`、`thumbUrl`、`uploadedAt`、`status` |
| CreationDraft | 创作草稿 | `id`、`assets`、`mode`、`style`、`voiceRole`、`speed`、`settings` |
| GenerationTask | 生成任务 | `id`、`status`、`pointCost`、`errorMessage`、`workId` |
| Work | 作品 | `id`、`title`、`coverUrl`、`videoUrl`、`status`、`expireAt` |
| Feedback | 意见反馈 | `id`、`type`、`content`、`contact`、`status` |

### 2.2 关系说明（待确定）

- 一个用户拥有积分、会员、邀请、素材、草稿、任务、作品等业务数据。
- 一个创作草稿可关联多个素材。
- 一个生成任务来源于一个创作草稿，成功后生成作品。
- 邀请、积分、会员、支付关系待后端方案确认；Flutter 先按领域模型组织 Store 与 mock 数据。

---

## 3. 前端接口契约规划（最终接口待确定）

### 3.1 Service 方法列表

| 模块 | 前端 Service / API 方法 | 真实后端路径 | 描述 |
|------|-------------------------|--------------|------|
| 认证 | `AuthApi.oneClickLogin()` | 待确定 | 运营商一键登录 |
| 认证 | `AuthApi.sendSmsCode()` | 待确定 | 发送短信验证码 |
| 认证 | `AuthApi.smsLogin()` | 待确定 | 手机号验证码登录 |
| 用户 | `UserApi.profile()` | 待确定 | 获取我的页用户信息 |
| 用户 | `UserApi.logout()` | 待确定 | 退出登录 |
| 用户 | `UserApi.requestDelete()` | 待确定 | 注销账号申请 |
| 邀请 | `InviteApi.overview()` | 待确定 | 邀请码、规则和记录 |
| 积分 | `PointsApi.ledger()` | 待确定 | 积分流水分页 |
| 会员 | `MembershipApi.plans()` | 待确定 | 会员套餐和权益 |
| 订单 | `PaymentApi.createMembershipOrder()` | 待确定 | 创建会员订单 |
| 订单 | `PaymentApi.createPointsOrder()` | 待确定 | 创建积分充值订单 |
| 素材 | `MediaApi.assets()` | 待确定 | 已上传视频列表 |
| 创作 | `CreationApi.estimate()` | 待确定 | 生成前积分预估 |
| 创作 | `CreationApi.saveDraft()` | 待确定 | 保存创作草稿 |
| 任务 | `GenerationApi.createTask()` | 待确定 | 创建生成任务 |
| 任务 | `GenerationApi.taskDetail()` | 待确定 | 查询任务状态 |
| 作品 | `WorksApi.list()` | 待确定 | 作品列表 |
| 作品 | `WorksApi.detail()` | 待确定 | 作品详情 |
| 作品 | `WorksApi.download()` | 待确定 | 获取下载地址 |
| 反馈 | `FeedbackApi.submit()` | 待确定 | 提交意见反馈 |

### 3.2 前端请求封装规范

- `apis/` 层先按方法名和领域模型建立占位封装，真实路径、请求体、响应体后续替换。
- `services/http.dart` 统一承接 baseUrl、token、错误转换和 mock / real 切换。
- 关键动作保留幂等参数位，但具体 header 或字段名等待 Java 后端接口定稿。
- 分页模型先统一为 `items`、`total`、`hasMore`，后端定稿后再适配。
- 错误码先映射为前端枚举：未登录、无权限、参数错误、积分不足、会员权益不足、资源不存在、任务失败、支付失败、服务繁忙。

---

## 4. 前端模块划分（Flutter）

### 4.1 页面路由规划

| 路由 | 页面 | 说明 |
|------|------|------|
| `/` | 主框架 | 创作 / 作品 / 我的 tab |
| `/login` | 登录页 | 一键登录与验证码登录 |
| `/creation/video` | 视频解说创建页 | 上传素材与配置生成参数 |
| `/works/:id` | 作品详情 | 播放预览和下载 |
| `/membership` | VIP 会员页 | 套餐和权益 |
| `/points/recharge` | 积分充值页 | 积分套餐和支付方式 |
| `/points/ledger` | 积分详情 | 积分流水 |
| `/invite` | 邀请好友 | 当前缺失页 |
| `/settings` | 我的页更多设置 | 当前缺失页 |
| `/feedback` | 意见反馈 | 当前缺失页 |
| `/webview` | 协议 / 隐私 / 规则页 | 通用承载页 |

### 4.2 核心模块列表

| 模块 | 功能描述 | 优先级 |
|------|----------|--------|
| `auth` | 登录、验证码、协议勾选、会话保存 | P0 |
| `main` | 底部导航与三大 tab 容器 | P0 |
| `creation` | 视频上传、素材选择、参数配置、生成任务 | P0 |
| `works` | 作品列表、空态、详情、下载 | P0 |
| `account` | 我的页、会员、积分、邀请、反馈、设置 | P0 |
| `payment` | 会员订单、积分充值、支付状态承接 | P1 |
| `media` | 素材上传、缩略图、时长、缓存 | P0 |
| `common` | 弹窗、按钮、toast、loading、empty、error | P0 |

### 4.3 状态管理方案

- 页面局部状态放 `GetxController`，通过 `GetBuilder` 或响应式变量驱动 UI。
- 登录态、用户信息、会员权益、积分余额放 `UserStore` / `AccountStore`。
- 创作草稿、已选素材、生成配置放 `CreationStore` 或页面 Controller，并通过 Hive 做草稿缓存。
- 网络请求通过 `services/http.dart` 封装 Dio，统一处理 token、错误码、mock 数据和后续真实接口适配。

### 4.4 设计约束引用

- 本轮不生成新 Figma 图，也不生成新的 `figma-design-plan.md`。
- UI 事实来源按顺序引用：`requirements.md`、`references/README.md` 的 Figma frame 索引、Figma Page 1 原始 frame。
- Flutter 实现必须覆盖 PRD 中页面级需求，特别是 3 个缺失页：邀请好友、我的页更多设置、意见反馈。

---

## 5. 后端能力清单（Java 方案评估版）

| 能力 | 功能描述 | 建议优先级 |
|------|----------|------------|
| Auth | 一键登录、短信验证码、token | P0 |
| User | 用户资料、邀请码、设置、注销 | P0 |
| Points | 积分账户、流水、冻结 / 扣减 / 退回 | P0 |
| Payment | 支付订单、回调、到账补偿、幂等 | P0 |
| Media | 上传凭证、素材元数据、视频解析状态 | P0 |
| Creation | 草稿、参数配置、积分预估 | P0 |
| Generation | 任务创建、状态查询、失败处理 | P0 |
| Works | 作品列表、详情、下载、过期 | P0 |
| Membership | 会员套餐、权益、有效期 | P1 |
| Invite | 邀请规则、邀请记录、奖励 | P1 |
| Feedback | 意见反馈提交和后台查看 | P1 |
| Config | 风格、音色、背景音乐、协议等配置 | P1 |

---

## 6. 开发任务拆分

> 用户明确要求本轮不评估时长，因此本节只拆任务、优先级和依赖，不输出人天或日历排期。后端任务用于 Java 后端方案评估和后续技术文档输入，不进入当前 Flutter 编码计划。

### 6.1 前端任务（Flutter）

| 任务 ID | 任务 | 描述 | 优先级 |
|---------|------|------|--------|
| T-F001 | 工程骨架 | main/global/theme/routes/services/store/widgets 基础设施 | P0 |
| T-F002 | 登录模块 | 一键登录、验证码登录、协议勾选、登录态存储，先接 mock | P0 |
| T-F003 | 主框架与首页 | 底部导航、创作首页、热门案例、会员入口 | P0 |
| T-F004 | 创作页 | 上传区域、已选视频、参数区、立即生成，先本地草稿 | P0 |
| T-F005 | 创作弹层 | 风格、配音、更多设置、选择视频、删除确认 | P0 |
| T-F006 | 作品模块 | 作品空态、列表、详情、播放预览、下载入口，先 mock 作品 | P0 |
| T-F007 | 我的页 | 用户信息、邀请码、积分、VIP、功能入口 | P0 |
| T-F008 | 会员与积分 | VIP 页、积分充值、积分详情、支付状态承接，先 mock 套餐 | P1 |
| T-F009 | 邀请好友 | 邀请码、分享、规则、邀请记录 | P1 |
| T-F010 | 更多设置 | 协议、隐私、版本、清理缓存、退出登录、注销账号 | P1 |
| T-F011 | 意见反馈 | 类型、描述、附件、联系方式、提交状态，先本地提交成功态 | P1 |
| T-F012 | 状态与异常补齐 | loading、empty、error、disabled、submitting、not_found | P0 |

### 6.2 后端任务（Java 方案评估版）

| 任务 ID | 任务 | 描述 | 建议优先级 |
|---------|------|------|------------|
| T-B001 | Java 工程基础设施 | Spring Boot、统一响应、异常、日志、配置、Flyway、Redis | P0 |
| T-B002 | 账号鉴权 | 一键登录适配、短信验证码、token、用户资料 | P0 |
| T-B003 | 积分账务 | 账户、流水、冻结、扣减、退回、幂等 | P0 |
| T-B004 | 支付与会员 | 套餐、订单、支付回调、权益更新、到账补偿 | P0 |
| T-B005 | 素材服务 | 上传凭证、素材列表、视频元数据、删除 | P0 |
| T-B006 | 创作与生成 | 草稿、积分预估、任务创建、状态查询、失败处理 | P0 |
| T-B007 | 作品服务 | 列表、详情、下载、过期处理 | P0 |
| T-B008 | 邀请好友 | 邀请码、记录、奖励发放 | P1 |
| T-B009 | 意见反馈 | 反馈提交、附件、处理状态 | P1 |
| T-B010 | 通用配置与预设 | 风格、音色、背景音乐、协议、静态配置 | P1 |
| T-B011 | 外部服务适配层 | 百度 VOD、短信、支付、对象存储 / CDN Provider Adapter | P0 |

---

## 7. 开发阶段规划

| 阶段 | 前端任务 | 后端依赖 | 里程碑 |
|------|----------|----------|--------|
| 阶段 1 基础闭环 | T-F001、T-F002、T-F003、T-F007 | T-B001、T-B002；前端先用 mock 登录与用户信息 | 登录后可进入主框架和我的页 |
| 阶段 2 创作闭环 | T-F004、T-F005、T-F012 | T-B003、T-B005、T-B006；前端先用本地素材与 mock 预估 | 可完成素材选择、积分预估、创建任务前端流 |
| 阶段 3 作品闭环 | T-F006 | T-B006、T-B007；前端先用 mock 作品数据 | 可查看作品列表、详情和下载入口 |
| 阶段 4 商业化与二级页 | T-F008、T-F009、T-F010、T-F011 | T-B003、T-B004、T-B008、T-B009、T-B010 | 会员积分、邀请、设置、反馈前端闭合 |

本表只定义顺序与依赖，不包含时长估算。

---

## 8. 风险与应对

| 风险 | 影响 | 应对方案 |
|------|------|----------|
| 部分后端供应商待确定 | 短信、支付等接口无法最终联调 | Java 后端先按 Provider Adapter 设计，Flutter 继续使用 Service 抽象和 mock data source |
| 百度 VOD 接入细节未确认 | 上传、媒资处理、生成回调、播放 / 下载地址仍需联调 | Flutter 不直连 VOD，后端通过 `BaiduVodProvider` 统一承接 |
| 支付渠道未确认 | 充值和会员开通无法落地 | 先实现套餐 UI、订单提交占位和支付结果状态承接 |
| 生成任务状态未完整设计 | 影响作品状态和积分补偿 | Flutter 先定义通用前端状态枚举，后端定稿后映射 |
| 3 个缺失页无 Figma 独立稿 | Flutter 对稿依据不足 | 以 PRD 页面结构为先，后续若补设计再调整 UI |
| 不做工时评估 | 后续排期缺少量化依据 | 当前只输出阶段顺序，排期另行确认 |

---

## 9. CHG-0011 邀请好友、收益与提现技术方案补充

> 状态：`waiting_review`。邀请好友专题技术方案已拆为独立文件，主技术方案只保留索引。

独立技术文档：`projects/剧说/02-技术方案/邀请好友技术文档.md`。

该文档覆盖邀请关系、注册积分、会员返佣、收益账本、提现记录、后台规则配置、公开落地页接口、`V10__invite_commission_withdrawals.sql` 迁移计划和审核门禁。
