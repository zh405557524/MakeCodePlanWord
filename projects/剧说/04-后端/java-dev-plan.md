# 剧说 Java 总体开发计划

> 版本：v0.5.0  
> 创建日期：2026-05-19  
> 关联技术文档：`./java-tech.md`  
> 关联后端评估：`../02-技术方案/backend-evaluation.md`  
> 当前要求：忽略前端开发，继续推进 Java 后端编码。  
> 说明：本计划不输出工时、人天或日历排期。

---

## 1. 文档用途

本文用于把 `java-tech.md` 转成可恢复、可分模块执行的 Java 后端开发计划。后续编码应先读取本文和对应模块文档，再按任务进入 `14 Java 编码`。

当前已在后端工程完成 T-B001 至 T-B011 Java 后端编码，后续默认进入联调与测试 QA。

---

## 2. 当前状态与恢复点

| 项 | 内容 |
|----|------|
| 当前阶段 | `14 Java 编码（done，下一步进入 15 联调与测试 QA）` |
| 当前恢复点 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| 后端工程路径 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| 技术栈 | Java 21 + Spring Boot 3.x + Gradle + PostgreSQL + Redis + MyBatis-Plus + Flyway |
| 视频平台 | 百度智能云智能点播平台 VOD |
| 本轮边界 | 不处理 Flutter 编码，不输出工时 |

---

## 3. 状态枚举

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `ready` | 文档齐备，可进入编码 |
| `in_progress` | 编码中 |
| `blocked` | 被外部条件阻塞 |
| `done` | 已完成并通过验证 |

任务状态更新规则：

- 文档生成完成后，模块状态为 `ready`。
- 后端工程路径未指定前，不进入 `in_progress`。
- 涉及真实百度 VOD、短信、支付供应商的任务，真实联调部分可标记为 `blocked`，mock provider 部分仍可编码。

---

## 4. 总体开发策略

开发顺序采用“基础设施 -> 核心账务 -> 百度 VOD 生成闭环 -> 商业化 -> 辅助模块”的路径：

1. 先搭建工程、统一响应、错误码、配置、Flyway、Redis、鉴权过滤器。
2. 再实现账号、用户聚合、积分账户和积分流水。
3. 接着实现素材、创作、生成、百度 VOD Provider、作品服务，跑通最小创作闭环。
4. 再实现支付、会员、邀请、反馈和配置。
5. 最后补集成测试、回调幂等测试、迁移脚本验证和运行文档。

---

## 5. 阶段划分

| 阶段 | 目标 | 产物 | 状态 |
|------|------|------|------|
| B-Stage-01 | 工程基础设施 | Spring Boot + Gradle 工程骨架、通用响应、异常、日志、Flyway、Redis | done |
| B-Stage-02 | 账号与用户 | 短信登录、一键登录占位、JWT、用户资料 | done |
| B-Stage-03 | 积分账务 | 积分账户、流水、冻结、扣减、退回、幂等 | done |
| B-Stage-04 | 百度 VOD 创作闭环 | 上传参数、素材、预估、任务、VOD 回调、作品 | done |
| B-Stage-05 | 支付会员 | 套餐、订单、支付回调、会员权益、到账补偿 | done |
| B-Stage-06 | 辅助能力 | 邀请、反馈、配置、协议静态页 | done |
| B-Stage-07 | 验证收口 | 单元测试、集成测试、回调幂等、构建验证 | done |

---

## 6. 详细任务清单

| 任务 ID | 模块 | 描述 | 依赖 | 状态 |
|---------|------|------|------|------|
| T-B001 | infrastructure | 工程骨架、统一响应、异常、日志、配置、Flyway、Redis | 无 | done |
| T-B002 | auth-user | 短信验证码、一键登录占位、JWT、用户资料、注销 | T-B001 | done |
| T-B003 | entitlement | 积分账户、流水、冻结、扣减、退回、会员权益校验 | T-B001、T-B002 | done |
| T-B004 | product-order-payment | 商品套餐、订单、支付回调、会员权益、到账补偿 | T-B001、T-B002、T-B003 | done |
| T-B005 | app/media | 百度 VOD 上传参数、素材列表、元数据、删除 | T-B001、T-B002、T-B011 | done |
| T-B006 | app/creation + app/generation | 草稿、积分预估、任务创建、状态查询、失败处理 | T-B003、T-B005、T-B011 | done |
| T-B007 | app/works | 作品列表、详情、播放 / 下载地址、过期处理 | T-B006、T-B011 | done |
| T-B008 | app/invite | 邀请码、邀请记录、奖励发放 | T-B002、T-B003 | done |
| T-B009 | app/feedback | 反馈提交、附件占位、处理状态 | T-B002 | done |
| T-B010 | app/config + admin | 风格、音色、背景音乐、协议、静态配置和后台管理预留 | T-B001 | done |
| T-B011 | auth/infra + payment/channel + app/generation/infra | 百度 VOD、短信、支付 Provider Adapter | T-B001 | done |

---

## 7. API 接口任务表

| 任务 ID | 接口 | 方法 | 路径 | 依赖表 | Service | 状态 |
|---------|------|------|------|--------|---------|------|
| T-B002 | 发送验证码 | POST | `/api/auth/sms/send` | `sms_codes` | `AuthService` | done |
| T-B002 | 验证码登录 | POST | `/api/auth/sms/login` | `users`、`sms_codes`、`refresh_tokens` | `AuthService` | done |
| T-B002 | 一键登录 | POST | `/api/auth/one-click-login` | `users`、`refresh_tokens` | `AuthService` | done |
| T-B002 | 我的页聚合 | GET | `/api/user/profile` | `users`、`point_accounts`、`user_memberships` | `UserService` | done |
| T-B002 | 退出登录 | POST | `/api/user/logout` | `refresh_tokens` | `AuthService` | done |
| T-B002 | 注销申请 | POST | `/api/user/delete-request` | `users` | `UserService` | done |
| T-B003 | 积分账户 | GET | `/api/points/account` | `point_accounts` | `PointsService` | done |
| T-B003 | 积分流水 | GET | `/api/points/ledger` | `point_ledgers` | `PointsService` | done |
| T-B004 | 会员套餐 | GET | `/api/membership/plans` | `membership_plans` | `MembershipService` | done |
| T-B004 | 会员状态 | GET | `/api/membership/status` | `user_memberships` | `MembershipService` | done |
| T-B004 | 创建订单 | POST | `/api/payments/orders` | `payment_orders` | `PaymentService` | done |
| T-B004 | 支付回调 | POST | `/api/payments/callback/{channel}` | `payment_orders`、`provider_events`、`point_ledgers` | `PaymentCallbackService` | done |
| T-B005 | 上传参数 | POST | `/api/media/upload-token` | `media_assets` | `MediaService` | done |
| T-B005 | 素材列表 | GET | `/api/media/assets` | `media_assets` | `MediaService` | done |
| T-B005 | 删除素材 | DELETE | `/api/media/assets/{id}` | `media_assets` | `MediaService` | done |
| T-B006 | 积分预估 | POST | `/api/creation/estimate` | `media_assets`、`app_configs` | `CreationService` | done |
| T-B006 | 保存草稿 | POST | `/api/creation/drafts` | `creation_drafts` | `CreationService` | done |
| T-B006 | 创建任务 | POST | `/api/generation/tasks` | `generation_tasks`、`point_accounts`、`point_ledgers` | `GenerationService` | done |
| T-B006 | 查询任务 | GET | `/api/generation/tasks/{id}` | `generation_tasks` | `GenerationService` | done |
| T-B006 | 百度 VOD 回调 | POST | `/api/providers/baidu-vod/callback` | `provider_events`、`generation_tasks`、`works`、`point_ledgers` | `VodCallbackService` | done |
| T-B007 | 作品列表 | GET | `/api/works` | `works` | `WorksService` | done |
| T-B007 | 作品详情 | GET | `/api/works/{id}` | `works` | `WorksService` | done |
| T-B007 | 下载地址 | POST | `/api/works/{id}/download-url` | `works` | `WorksService` | done |
| T-B008 | 邀请概览 | GET | `/api/invite/overview` | `users`、`invite_records` | `InviteService` | done |
| T-B008 | 邀请记录 | GET | `/api/invite/records` | `invite_records` | `InviteService` | done |
| T-B009 | 提交反馈 | POST | `/api/feedback` | `feedbacks` | `FeedbackService` | done |
| T-B010 | 预设配置 | GET | `/api/config/presets` | `app_configs` | `AppConfigService` | done |
| T-B010 | 静态协议 | GET | `/api/config/static-page/{key}` | `app_configs` | `AppConfigService` | done |
| T-B010 | 后台配置列表 | GET | `/api/admin/configs` | `app_configs` | `AdminConfigService` | done |
| T-B010 | 后台配置详情 | GET | `/api/admin/configs/{configKey}` | `app_configs` | `AdminConfigService` | done |
| T-B010 | 后台配置更新 | PUT | `/api/admin/configs/{configKey}` | `app_configs` | `AdminConfigService` | done |

---

## 8. 模块开发文档列表

| 文件 | 覆盖任务 | 状态 |
|------|----------|------|
| `开发计划/01-基础设施.md` | T-B001 | done |
| `开发计划/02-账号鉴权与用户.md` | T-B002 | done |
| `开发计划/03-积分账务.md` | T-B003，落到 `entitlement/` | done |
| `开发计划/04-支付会员.md` | T-B004，落到 `product/`、`order/`、`payment/`、`entitlement/` | done |
| `开发计划/05-百度VOD素材与生成.md` | T-B005、T-B006、T-B011，落到 `app/media/`、`app/creation/`、`app/generation/` | done |
| `开发计划/06-作品服务.md` | T-B007，落到 `app/works/` | done |
| `开发计划/07-邀请反馈配置.md` | T-B008、T-B009、T-B010，落到 `app/invite/`、`app/feedback/`、`app/config/`、`admin/` | done |

---

## 9. 编码约束

- Controller 只做参数解析、鉴权上下文、响应封装。
- Service 处理事务、状态流转、幂等、账本和 Provider 调用。
- Repository 只处理数据访问，禁止写业务判断。
- Provider Adapter 屏蔽百度 VOD、短信、支付供应商差异。
- 关键写接口必须支持 `Idempotency-Key`。
- 积分账本只追加，不修改历史流水。
- 支付和百度 VOD 回调必须验签、幂等、保存原始 payload。
- 所有敏感配置通过环境变量或配置中心注入。
- 每次提交前至少跑 `./gradlew build`；必要时跑 `./gradlew test`。

---

## 10. 未决事项

| 事项 | 处理方式 |
|------|----------|
| 百度 VOD 账号、区域、工作流 / 模板、回调签名 Token 未提供 | 先实现 `MockVodProvider` 和 `BaiduVodProvider` 接口骨架 |
| 短信、一键登录、支付供应商未定 | 先实现 mock provider，真实 provider 后续替换 |
| iOS 支付合规未确认 | 支付模块保留 Apple IAP 适配位，不先锁死渠道 |

---

## 11. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-05-19 | 根据用户要求忽略前端开发，推进 Java 总体开发计划 | 已生成本文，下一步生成 Java 模块开发文档 |
| 2026-05-19 | 在 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 执行 T-B001 基础设施编码 | 已完成 Java 21 + Spring Boot 3.3 + Gradle 8.8 工程基础设施，`./gradlew build` 通过 |
| 2026-05-19 | 执行 T-B002 账号鉴权与用户编码 | 已完成 mock 短信验证码、短信登录、一键登录占位、JWT 鉴权、用户资料、退出登录、注销申请和集成测试；`./gradlew build` 通过 |
| 2026-05-19 | 执行 T-B003 至 T-B011 剩余 Java 后端编码 | 已完成积分账务、支付会员、百度 VOD 素材与生成、作品、邀请、反馈、配置、后台配置预留、幂等字段迁移和跨模块集成测试；`./gradlew build` 通过 |

---

## 12. CHG-0011 Java 文档审核补充

> 状态：`waiting_review`。本节只登记 T-B012 任务索引，不进入编码。

### 12.1 新增任务

| 任务 ID | 模块 | 描述 | 依赖 | 状态 |
|---------|------|------|------|------|
| T-B012 | app/invite + admin/invite | 邀请链接注册、App 内绑定、注册送积分、会员返佣、收益账本、提现审核、公开落地页 | T-B002、T-B003、T-B004、T-B010 | waiting_review |

### 12.2 新增接口

| 任务 ID | 接口 | 方法 | 路径 | Service | 状态 |
|---------|------|------|------|---------|------|
| T-B012 | 绑定邀请人 | POST | `/api/invite/bind` | `InviteService` | waiting_review |
| T-B012 | 推广素材 | GET | `/api/invite/materials` | `InviteMaterialService` | waiting_review |
| T-B012 | 收益汇总 | GET | `/api/invite/earnings/summary` | `InviteEarningService` | waiting_review |
| T-B012 | 收益明细 | GET | `/api/invite/earnings/ledgers` | `InviteEarningService` | waiting_review |
| T-B012 | 发起提现 | POST | `/api/invite/withdrawals` | `InviteWithdrawalService` | waiting_review |
| T-B012 | 提现记录 | GET | `/api/invite/withdrawals` | `InviteWithdrawalService` | waiting_review |
| T-B012 | 邀请落地页 | GET | `/invite/{inviteCode}` | `InviteLandingController` | waiting_review |
| T-B012 | 后台邀请规则 | GET / PUT | `/api/admin/invite/rules` | `AdminInviteService` | waiting_review |
| T-B012 | 后台提现审核 | POST | `/api/admin/invite/withdrawals/{id}/approve` 等 | `AdminInviteWithdrawalService` | waiting_review |

### 12.3 审核门禁

- 审核通过前不修改 Java 代码、不新增 Flyway 迁移、不运行 `./gradlew build`。
- 审核通过后从 `projects/剧说/04-后端/开发计划/08-邀请好友后端开发文档.md` 进入 T-B012 编码。
