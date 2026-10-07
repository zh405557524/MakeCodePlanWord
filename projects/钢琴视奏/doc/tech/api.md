# 接口契约

> 基线文档：线上（v2.1.0 + 2026-10-06 后端修复）App 使用的接口。前后端共用这一份。
> 2026-10-07 迁移时生成：接口清单从 service 仓库 Controller 源码和 App `lib/apis/` 实际调用的路径自动提取，说明列取自旧工作区的技术契约。
> 字段明细以源码 DTO / VO 为准；以后修改接口时，在版本 `plan.md` 第 3 节写清字段，发布时把字段明细补进这里。

## 1. 通用约定

| 项 | 约定 |
|---|---|
| 正式环境 | `https://www.lumentrain.com`（App 可用编译参数 `SOLFEGGIO_API_BASE_URL` 覆盖） |
| App 标识 | 所有 App 接口带请求头 `X-App-Code: solfeggio`，后端据此路由到 PostgreSQL schema `solfeggio` |
| 鉴权 | `Authorization: Bearer <accessToken>`；刷新用 `POST /api/auth/refresh` |
| 响应结构 | `ApiResponse<T>`：`{ code, message, data, traceId }` |
| 路径风格 | App 专属接口用 `/api/v1/**`；公共能力（认证、商品、订单、会员、资源上传）用 `/api/**` |
| 金额 | `amountCents`（整数，币种主单位的百分之一）+ `currency`（ISO 4217）。已核验的商店订单返回商店实际交易金额；内部定价只用于后台财务口径 |
| 权限拒绝 | 歌曲钢琴练习等返回 `NEED_LEVEL` / `NEED_MEMBERSHIP`；网络错误不能当作授权成功 |
| 幂等 | 账号认证用 `Idempotency-Key` 请求头；导入任务用 `idempotency_key` |

## 2. 接口清单（按模块）

### 账号与认证

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/auth/account/login` | `AuthController.loginByAccount` |  |
| POST | `/api/auth/account/register` | `AuthController.registerByAccount` |  |
| POST | `/api/auth/google/login` | `AuthController.loginByGoogle` |  |
| POST | `/api/auth/guest/apple-subscription/restore` | `GuestAuthController.restoreAppleSubscription` | 游客恢复 Apple 订阅 |
| POST | `/api/auth/guest/session` | `GuestAuthController.session` |  |
| POST | `/api/auth/refresh` | `AuthController.refresh` |  |
| POST | `/api/v1/account/auth/google-login` | `SolfeggioAccountAuthController.authenticate` | 按已验证的 Google subject 识别，不按邮箱关联 |
| POST | `/api/v1/account/auth/guest-login` | `SolfeggioAccountAuthController.authenticate` | 游客登录（游客凭证） |
| POST | `/api/v1/account/auth/logout` | `SolfeggioAccountAuthController.logout` | 撤销当前会话；客户端离线时稍后重试 |
| POST | `/api/v1/account/auth/password-login` | `SolfeggioAccountAuthController.authenticate` | 用户名/历史邮箱 + 密码；transition = BOUND_CURRENT / EXISTING_ACCOUNT |
| POST | `/api/v1/account/auth/register` | `SolfeggioAccountAuthController.authenticate` | 用户名注册；绑定当前本地账号。请求带 localProfileId、Idempotency-Key（只用于关联和幂等，不是凭证）；响应 session + transition |
| POST | `/api/v1/account/auth/upgrade` | `SolfeggioAccountAuthController.upgrade` | 游客升级为正式身份，要求当前是游客会话；同一 userId；transition = UPGRADED_CURRENT |

### 用户与反馈

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/feedback` | `FeedbackController.submit` |  |
| POST | `/api/user/delete-request` | `UserController.deleteRequest` |  |

### 学习进度与同步

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| GET | `/api/v1/learning/capability` | `SolfeggioLearningController.capability` |  |
| PUT | `/api/v1/learning/capability` | `SolfeggioLearningController.updateCapability` |  |
| GET | `/api/v1/learning/overview` | `SolfeggioLearningController.overview` |  |
| GET | `/api/v1/practice-records` | `SolfeggioLearningController.records` |  |
| POST | `/api/v1/practice-records:sync` | `SolfeggioLearningController.sync` |  |
| GET | `/api/v1/preferences` | `SolfeggioLearningController.preferences` |  |
| PUT | `/api/v1/preferences` | `SolfeggioLearningController.updatePreferences` |  |

### 官方曲库

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| GET | `/api/v1/songs` | `SolfeggioCatalogController.list` | isUnlocked 只表示等级内容解锁；isFreePractice、source=OFFICIAL |
| GET | `/api/v1/songs/{songId}` | `SolfeggioCatalogController.detail` |  |
| GET | `/api/v1/songs/{songId}/arrangements/{arrangementId}` | `SolfeggioCatalogController.arrangement` | 谱面内容；只查等级/内容，不查会员 |

### 歌曲练习

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/v1/song-practice/sessions` | `SolfeggioSongPracticeController.start` | mode=PIANO：先查等级再查会员；mode=PHONE：只查等级/内容；免费体验歌直接允许。拒绝返回 NEED_LEVEL / NEED_MEMBERSHIP |
| PUT | `/api/v1/song-practice/sessions/{sessionId}` | `SolfeggioSongPracticeController.update` |  |
| POST | `/api/v1/song-practice/sessions/{sessionId}/complete` | `SolfeggioSongPracticeController.complete` |  |

### 和弦练习

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/v1/chord-practice/sessions` | `SolfeggioChordPracticeController.start` |  |
| POST | `/api/v1/chord-practice/sessions/{sessionId}/answers` | `SolfeggioChordPracticeController.answer` |  |

### 曲谱导入与个人曲谱

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/resources/direct-upload/complete` | `ResourceController.complete` |  |
| POST | `/api/resources/direct-upload/prepare` | `ResourceController.prepare` |  |
| POST | `/api/resources/exists` | `ResourceController.exists` |  |
| GET | `/api/v1/personal-scores` | `ScoreImportController.center` |  |
| DELETE | `/api/v1/personal-scores/{scoreId}` | `ScoreImportController.deletePersonalScore` |  |
| GET | `/api/v1/personal-scores/{scoreId}` | `ScoreImportController.personalScore` |  |
| PATCH | `/api/v1/personal-scores/{scoreId}` | `ScoreImportController.renamePersonalScore` |  |
| POST | `/api/v1/personal-scores/{scoreId}/practice-access` | `ScoreImportController.authorizeMidiPractice` | 个人曲谱 MIDI 钢琴练习授权：本人、未删除、READY，再查有效会员。他人曲谱 403，未登录 401，不存在/已删 404，未就绪 400 |
| POST | `/api/v1/score-contents/{contentId}/read-ticket` | `ScoreImportController.readScoreContent` |  |
| POST | `/api/v1/score-imports` | `ScoreImportController.create` |  |
| GET | `/api/v1/score-imports/eligibility` | `ScoreImportController.eligibility` | 导入资格；所有账号同一资源策略（AVAILABLE / CONCURRENT_LIMIT / HOURLY_LIMIT / DAILY_LIMIT） |
| GET | `/api/v1/score-imports/{taskId}` | `ScoreImportController.detail` |  |
| POST | `/api/v1/score-imports/{taskId}/cancel` | `ScoreImportController.cancel` |  |
| POST | `/api/v1/score-imports/{taskId}/confirm` | `ScoreImportController.confirm` |  |
| POST | `/api/v1/score-imports/{taskId}/result-upload/prepare` | `ScoreImportController.prepareResultUpload` |  |
| POST | `/api/v1/score-imports/{taskId}/retry` | `ScoreImportController.retry` |  |
| PUT | `/api/v1/score-imports/{taskId}/review` | `ScoreImportController.saveReview` |  |

### 会员与支付

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| GET | `/api/membership/status` | `MembershipController.status` |  |
| GET | `/api/payments/callback` | `PaymentCallbackController.alipayReturn` |  |
| POST | `/api/payments/callback/google_play/notifications` | `GooglePlayNotificationController.notification` | Google Play RTDN（含退款） |
| POST | `/api/payments/callback/ios/notifications` | `PaymentCallbackController.appleIapNotification` | App Store Server Notifications（续期等） |
| POST | `/api/payments/callback/{channel}` | `PaymentCallbackController.callback` |  |
| POST | `/api/payments/callback/{channel}/notify` | `PaymentCallbackController.callback` |  |
| GET | `/api/payments/orders` | `OrderController.list` | 订单列表；已核验订单的 amountCents/currency 为商店实际交易金额（2026-10-06 起） |
| POST | `/api/payments/orders` | `OrderController.createOrder` |  |
| DELETE | `/api/payments/orders/{orderNo}` | `OrderController.delete` |  |
| GET | `/api/payments/orders/{orderNo}` | `OrderController.detail` | 订单详情；金额口径同上 |
| PATCH | `/api/payments/orders/{orderNo}/cancel` | `OrderController.cancel` |  |
| POST | `/api/payments/orders/{orderNo}/confirm` | `OrderController.confirm` | 提交商店凭证确认；服务端验真后结算，金额取商店交易价格 |
| GET | `/api/products` | `ProductController.list` | 会员商品：月/季/年卡，id = productCode = 商店商品 ID（com.soul.solfeggio.vip.*.v1） |

### 评价邀请

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/v1/review-prompt/claim` | `ReviewPromptController.claim` |  |
| POST | `/api/v1/review-prompt/merge` | `ReviewPromptController.merge` |  |
| GET | `/api/v1/review-prompt/state` | `ReviewPromptController.state` |  |
| POST | `/api/v1/review-prompt/suppress` | `ReviewPromptController.suppress` |  |

### 钢琴音色包

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| GET | `/api/v1/piano-soundfont/current` | `PianoSoundfontController.current` |  |

### 后台管理（Admin）

| 方法 | 路径 | 后端 | 说明 |
|---|---|---|---|
| POST | `/api/admin/solfeggio/arrangements` | `AdminSolfeggioCatalogController.createArrangement` |  |
| POST | `/api/admin/solfeggio/arrangements/validate` | `AdminSolfeggioCatalogController.validateArrangement` |  |
| PUT | `/api/admin/solfeggio/arrangements/{arrangementId}` | `AdminSolfeggioCatalogController.updateArrangement` |  |
| PUT | `/api/admin/solfeggio/arrangements/{arrangementId}/publish` | `AdminSolfeggioCatalogController.publishArrangement` |  |
| POST | `/api/admin/solfeggio/seed/default-catalog` | `AdminSolfeggioCatalogController.seedDefaultCatalog` |  |
| GET | `/api/admin/solfeggio/songs` | `AdminSolfeggioCatalogController.songs` |  |
| POST | `/api/admin/solfeggio/songs` | `AdminSolfeggioCatalogController.createSong` |  |
| PUT | `/api/admin/solfeggio/songs/{songId}` | `AdminSolfeggioCatalogController.updateSong` |  |
| GET | `/api/admin/solfeggio/songs/{songId}/arrangements` | `AdminSolfeggioCatalogController.arrangements` |  |
| PUT | `/api/admin/solfeggio/songs/{songId}/publish` | `AdminSolfeggioCatalogController.publishSong` |  |
| GET | `/api/admin/solfeggio/songs/{songId}/publish-check` | `AdminSolfeggioCatalogController.songPublishCheck` |  |
| GET | `/api/admin/solfeggio/soundfonts` | `AdminPianoSoundfontController.list` |  |
| POST | `/api/admin/solfeggio/soundfonts/uploads/prepare` | `AdminPianoSoundfontController.prepare` |  |
| POST | `/api/admin/solfeggio/soundfonts/{id}/publish` | `AdminPianoSoundfontController.publish` |  |
| POST | `/api/admin/solfeggio/soundfonts/{id}/upload-complete` | `AdminPianoSoundfontController.complete` |  |
| POST | `/api/admin/solfeggio/soundfonts/{id}/upload-failed` | `AdminPianoSoundfontController.failUpload` |  |
| GET | `/api/admin/solfeggio/summary` | `AdminSolfeggioCatalogController.summary` |  |

## 3. 待确认

- ⚠️ App `lib/apis/auth_api.dart` 里仍有旧认证接口 `/api/auth/account/*`、`/api/auth/google/login` 的调用。新账号模型使用 `/api/v1/account/auth/*`，旧接口是否还在用、能否下线，待确认。
- 导入统一资源保护的当前配置（后端 `src/main/resources/service-data/apps/solfeggio/app-configs.json`）：并发 2、每小时 10 次、每自然日 30 次，所有账号相同；导入原文件本地保留 7 天。产品总纲第 13 章待确认第 1、2、12、13 项与此有关，确认后回写产品文档。

## 4. 相关资料

- 订单金额口径：service 仓库 `docs/store-order-amount.md`
- 会员商品编码：service 仓库 `docs/solfeggio-vip-product-identity.md`
- IAP 确认与补单：service 仓库 `docs/solfeggio-iap-confirmation.md`
- 曲谱导入 Worker：service 仓库 `worker/README.md`
