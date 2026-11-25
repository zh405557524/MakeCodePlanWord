# 剧说 Java 后端技术文档

> 版本：v0.5.0  
> 创建日期：2026-05-19  
> 关联 PRD：`../01-需求/requirements.md`  
> 关联技术方案：`../02-技术方案/tech-plan.md`  
> 关联后端评估：`../02-技术方案/backend-evaluation.md`  
> 说明：用户要求忽略前端开发；当前已完成 T-B001 至 T-B011 Java 后端编码；不输出工时、人天或日历排期。  
> 框架：Java 21 + Spring Boot 3.x  
> 构建工具：Gradle  
> 数据库 / 缓存：PostgreSQL + Redis  
> 视频业务平台：百度智能云智能点播平台 VOD

---

## 1. 技术结论

剧说后端采用模块化单体优先：

| 维度 | 方案 |
|------|------|
| 语言 | Java 21 |
| Web 框架 | Spring Boot 3.x |
| 构建 | Gradle |
| 数据访问 | MyBatis-Plus |
| 数据库 | PostgreSQL |
| 迁移 | Flyway |
| 缓存 / 幂等 | Redis |
| 鉴权 | JWT Bearer Token |
| 视频平台 | 百度智能云智能点播平台 VOD |
| 外部服务 | Provider Adapter 隔离短信、一键登录、支付、百度 VOD |

后端必须统一承接登录、Token、积分账本、会员订单、支付回调、素材元数据、百度 VOD 任务、作品播放 / 下载地址、邀请、反馈和配置。Flutter 不直连百度 VOD SDK、AK/SK、上传密钥、支付密钥或短信密钥。

---

## 2. 工程结构

项目目录按“基础业务能力 + 具体业务 + 后台管理”拆分。启动入口按本项目 Java 技术口径使用 `ServerApplication.java`。

```text
build.gradle
settings.gradle
gradlew
gradlew.bat
src/
├── main/
│   ├── java/
│   │   └── com/lxwx/narrateservice/
│   │       ├── ServerApplication.java
│   │       ├── common/
│   │       │   ├── response/
│   │       │   ├── exception/
│   │       │   ├── config/
│   │       │   ├── security/
│   │       │   ├── util/
│   │       │   └── constants/
│   │       ├── auth/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── dto/
│   │       │   └── infra/
│   │       ├── user/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── domain/
│   │       │   ├── repository/
│   │       │   ├── entity/
│   │       │   ├── dto/
│   │       │   └── vo/
│   │       ├── product/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── domain/
│   │       │   ├── repository/
│   │       │   ├── entity/
│   │       │   ├── dto/
│   │       │   └── vo/
│   │       ├── order/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── domain/
│   │       │   ├── repository/
│   │       │   ├── entity/
│   │       │   ├── dto/
│   │       │   └── vo/
│   │       ├── payment/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── channel/
│   │       │   │   ├── apple/
│   │       │   │   ├── google/
│   │       │   │   ├── wechat/
│   │       │   │   ├── alipay/
│   │       │   │   └── stripe/
│   │       │   ├── domain/
│   │       │   ├── repository/
│   │       │   ├── entity/
│   │       │   └── dto/
│   │       ├── entitlement/
│   │       │   ├── controller/
│   │       │   ├── service/
│   │       │   ├── domain/
│   │       │   ├── repository/
│   │       │   ├── entity/
│   │       │   └── dto/
│   │       ├── app/
│   │       │   ├── media/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   └── vo/
│   │       │   ├── creation/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   └── vo/
│   │       │   ├── generation/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   ├── vo/
│   │       │   │   └── infra/
│   │       │   ├── works/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   └── vo/
│   │       │   ├── invite/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   └── vo/
│   │       │   ├── feedback/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── repository/
│   │       │   │   ├── entity/
│   │       │   │   ├── dto/
│   │       │   │   └── vo/
│   │       │   └── config/
│   │       │       ├── controller/
│   │       │       ├── service/
│   │       │       ├── repository/
│   │       │       ├── entity/
│   │       │       ├── dto/
│   │       │       └── vo/
│   │       └── admin/
│   │           ├── controller/
│   │           ├── service/
│   │           ├── dto/
│   │           └── vo/
│   └── resources/
│       ├── application.yml
│       └── db/migration/
└── test/
    └── java/
```

目录归属说明：

| 目录 | 职责 |
|------|------|
| `common` | 公共响应、异常、配置、安全、工具和常量 |
| `auth` | 登录、短信验证码、一键登录、Token，外部登录 / 短信 Provider 放在 `auth/infra` |
| `user` | 用户资料、邀请码、账号状态 |
| `product` | 会员套餐、积分商品、后续可售卖商品 |
| `order` | 订单创建、订单状态、订单查询 |
| `payment` | 支付回调、支付渠道适配，渠道实现放在 `payment/channel/*` |
| `entitlement` | 积分账户、积分流水、会员权益和权益校验 |
| `app/*` | 剧说具体业务，包含素材、创作、生成、作品、邀请、反馈、配置 |
| `admin` | 后台管理接口，MVP 可先只保留目录和接口规划 |

`repository` 目录承载 MyBatis-Plus Repository 接口；XML 如确有需要再放到 `resources/mybatis/`。

---

## 3. Gradle 依赖基线

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.0'
    id 'io.spring.dependency-management' version '1.1.5'
}

group = 'com.lxwx'
version = '0.5.0'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

ext {
    mybatisPlusVersion = '3.5.7'
    jjwtVersion = '0.12.5'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation "com.baomidou:mybatis-plus-spring-boot3-starter:${mybatisPlusVersion}"
    implementation 'org.flywaydb:flyway-core'
    implementation "io.jsonwebtoken:jjwt-api:${jjwtVersion}"
    runtimeOnly 'org.postgresql:postgresql'
    runtimeOnly 'org.flywaydb:flyway-database-postgresql'
    runtimeOnly "io.jsonwebtoken:jjwt-impl:${jjwtVersion}"
    runtimeOnly "io.jsonwebtoken:jjwt-jackson:${jjwtVersion}"
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
    testRuntimeOnly 'com.h2database:h2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

tasks.named('test') {
    useJUnitPlatform()
}
```

百度 VOD SDK 是否直接引入，由 `BaiduVodProvider` 实现阶段按官方 Java SDK 与接口可用性确认；业务层不得直接依赖 SDK。

---

## 4. 通用 API 规范

### 4.1 响应格式

```java
public record ApiResponse<T>(
    String code,
    String message,
    T data,
    String traceId
) {
    public static <T> ApiResponse<T> ok(T data, String traceId) {
        return new ApiResponse<>("OK", "success", data, traceId);
    }
}
```

### 4.2 分页格式

```java
public record PageResult<T>(
    List<T> items,
    long page,
    long pageSize,
    long total,
    boolean hasMore
) {}
```

### 4.3 通用约定

| 项 | 约定 |
|----|------|
| API 前缀 | `/api` |
| 鉴权 Header | `Authorization: Bearer {accessToken}` |
| 幂等 Header | `Idempotency-Key`，关键写接口必传 |
| 时间格式 | ISO-8601 字符串 |
| 金额单位 | 后端内部使用分 |
| 积分单位 | 整数积分 |
| Trace | 每次请求生成 `traceId` 并写日志 |

### 4.4 错误码

| 分类 | 错误码 |
|------|--------|
| 通用 | `BAD_REQUEST`、`UNAUTHORIZED`、`FORBIDDEN`、`NOT_FOUND`、`SERVER_ERROR` |
| 认证 | `SMS_TOO_FREQUENT`、`SMS_CODE_INVALID`、`TOKEN_EXPIRED` |
| 积分 / 权益 | `POINTS_NOT_ENOUGH`、`POINTS_ACCOUNT_LOCKED`、`ENTITLEMENT_REQUIRED` |
| 支付 | `PAYMENT_ORDER_EXPIRED`、`PAYMENT_VERIFY_FAILED`、`PAYMENT_DUPLICATED_CALLBACK` |
| 素材 | `MEDIA_TOO_LARGE`、`MEDIA_FORMAT_UNSUPPORTED`、`MEDIA_UPLOAD_FAILED` |
| 生成 | `GENERATION_PROVIDER_BUSY`、`GENERATION_FAILED`、`GENERATION_TIMEOUT` |

---

## 5. 数据库设计

### 5.1 表清单

| 表 | 模块 | 说明 |
|----|------|------|
| `users` | user | 用户基础信息、手机号、邀请码、状态 |
| `sms_codes` | auth | 验证码发送和使用记录 |
| `refresh_tokens` | auth | 可撤销刷新令牌 |
| `point_accounts` | points | 可用积分和冻结积分 |
| `point_ledgers` | points | 积分收入、冻结、扣减、退回流水 |
| `membership_plans` | membership | 会员套餐配置 |
| `user_memberships` | membership | 用户会员权益 |
| `payment_orders` | payment | 订单、渠道、状态、金额、幂等 |
| `media_assets` | media | 素材与百度 VOD 媒资映射 |
| `creation_drafts` | creation | 创作草稿和参数快照 |
| `generation_tasks` | generation | 生成任务与百度 VOD 任务映射 |
| `works` | works | 作品、结果媒资、播放下载状态 |
| `provider_events` | provider | 百度 VOD / 支付等回调原文和幂等 |
| `invite_records` | invite | 邀请关系与奖励状态 |
| `feedbacks` | feedback | 意见反馈 |
| `app_configs` | config | 风格、音色、背景音乐、协议等配置 |

### 5.2 关键表字段

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    phone_hash VARCHAR(128) UNIQUE,
    phone_masked VARCHAR(32),
    invite_code VARCHAR(32) NOT NULL UNIQUE,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE point_accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    available_points BIGINT NOT NULL DEFAULT 0,
    frozen_points BIGINT NOT NULL DEFAULT 0,
    version BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE point_ledgers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    biz_type VARCHAR(32) NOT NULL,
    biz_id VARCHAR(64) NOT NULL,
    operation VARCHAR(32) NOT NULL,
    direction VARCHAR(16) NOT NULL,
    amount BIGINT NOT NULL,
    balance_after BIGINT NOT NULL,
    frozen_after BIGINT NOT NULL,
    remark VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (biz_type, biz_id, operation)
);

CREATE TABLE media_assets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    provider VARCHAR(32) NOT NULL DEFAULT 'BAIDU_VOD',
    provider_media_id VARCHAR(128),
    file_name VARCHAR(255),
    file_size BIGINT,
    duration_seconds INT,
    cover_url TEXT,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE generation_tasks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    draft_id BIGINT,
    status VARCHAR(32) NOT NULL,
    points_cost BIGINT NOT NULL,
    provider VARCHAR(32) NOT NULL DEFAULT 'BAIDU_VOD',
    provider_task_id VARCHAR(128),
    provider_status VARCHAR(64),
    failure_code VARCHAR(64),
    failure_message TEXT,
    work_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE provider_events (
    id BIGSERIAL PRIMARY KEY,
    provider VARCHAR(32) NOT NULL,
    provider_event_id VARCHAR(128) NOT NULL,
    event_type VARCHAR(64) NOT NULL,
    biz_id VARCHAR(128),
    raw_payload TEXT NOT NULL,
    process_status VARCHAR(32) NOT NULL,
    failure_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (provider, provider_event_id)
);
```

---

## 6. Redis Key 规范

| 场景 | Key | TTL |
|------|-----|-----|
| 短信限流 | `jushuo:sms:rate:{phone}` | 60 秒 |
| 验证码 | `jushuo:sms:code:{scene}:{phone}` | 5 分钟 |
| 接口幂等 | `jushuo:idempotency:{key}` | 10 分钟到 24 小时 |
| 支付回调锁 | `jushuo:pay:callback:{orderNo}` | 5 分钟 |
| VOD 回调锁 | `jushuo:vod:event:{eventId}` | 10 分钟 |
| 任务短缓存 | `jushuo:generation:task:{taskId}` | 30 秒 |

Redis 只用于短期锁、缓存和限流。积分余额、订单状态、任务终态必须以 PostgreSQL 为准。

---

## 7. 接口设计

### 7.1 P0 接口

| 模块 | 方法 | 路径 | 说明 |
|------|------|------|------|
| Auth | POST | `/api/auth/sms/send` | 发送短信验证码 |
| Auth | POST | `/api/auth/sms/login` | 手机号验证码登录 |
| Auth | POST | `/api/auth/one-click-login` | 一键登录服务端换取用户态 |
| User | GET | `/api/user/profile` | 我的页聚合 |
| User | POST | `/api/user/logout` | 退出登录 |
| User | POST | `/api/user/delete-request` | 注销账号申请 |
| Points | GET | `/api/points/account` | 积分账户 |
| Points | GET | `/api/points/ledger` | 积分流水 |
| Membership | GET | `/api/membership/plans` | 会员套餐 |
| Membership | GET | `/api/membership/status` | 会员状态 |
| Payment | POST | `/api/payments/orders` | 创建订单 |
| Payment | POST | `/api/payments/callback/{channel}` | 支付回调 |
| Media | POST | `/api/media/upload-token` | 获取百度 VOD 上传参数 |
| Media | GET | `/api/media/assets` | 素材列表 |
| Media | DELETE | `/api/media/assets/{id}` | 删除素材 |
| Creation | POST | `/api/creation/estimate` | 生成积分预估 |
| Creation | POST | `/api/creation/drafts` | 保存草稿 |
| Generation | POST | `/api/generation/tasks` | 创建生成任务 |
| Generation | GET | `/api/generation/tasks/{id}` | 查询任务 |
| Works | GET | `/api/works` | 作品列表 |
| Works | GET | `/api/works/{id}` | 作品详情 |
| Works | POST | `/api/works/{id}/download-url` | 获取下载地址 |
| Provider | POST | `/api/providers/baidu-vod/callback` | 百度 VOD 回调 |

### 7.2 关键请求 / 响应

`POST /api/media/upload-token`

```json
{
  "fileName": "video.mp4",
  "fileSize": 10485760,
  "contentType": "video/mp4",
  "durationSeconds": 120
}
```

```json
{
  "assetId": "10001",
  "provider": "BAIDU_VOD",
  "uploadUrl": "https://...",
  "uploadHeaders": {},
  "expiresAt": "2026-05-19T10:00:00+08:00"
}
```

`POST /api/creation/estimate`

```json
{
  "assetIds": ["10001"],
  "mode": "NARRATION",
  "style": "FAST",
  "voiceRole": "MALE_A",
  "speed": 1.0,
  "settings": {
    "multiVersion": false,
    "backgroundMusic": "NONE"
  }
}
```

```json
{
  "pointsCost": 40,
  "enoughPoints": true,
  "entitlementRequired": false,
  "message": "预计消耗 40 积分"
}
```

`POST /api/generation/tasks`

```json
{
  "assetIds": ["10001"],
  "mode": "NARRATION",
  "style": "FAST",
  "voiceRole": "MALE_A",
  "speed": 1.0,
  "settings": {
    "multiVersion": false,
    "backgroundMusic": "NONE"
  }
}
```

```json
{
  "taskId": "20001",
  "status": "CREATED",
  "pointsCost": 40
}
```

`POST /api/providers/baidu-vod/callback`

```json
{
  "eventId": "vod-event-001",
  "eventType": "VIDEO_GENERATE_COMPLETE",
  "taskId": "baidu-task-id",
  "mediaId": "baidu-result-media-id",
  "status": "SUCCESS"
}
```

---

## 8. 状态机

### 8.1 生成任务状态

| 状态 | 含义 | 终态 |
|------|------|------|
| `CREATED` | 本地任务已创建 | 否 |
| `POINTS_FROZEN` | 积分已冻结 | 否 |
| `SUBMITTED` | 已提交百度 VOD | 否 |
| `QUEUED` | VOD 排队中 | 否 |
| `PROCESSING` | 生成中 | 否 |
| `SUCCEEDED` | 生成成功，作品已创建 | 是 |
| `FAILED` | 生成失败，积分已退回 | 是 |
| `TIMEOUT` | 超时待补偿确认 | 否 |
| `CANCELED` | 用户或系统取消 | 是 |

### 8.2 支付订单状态

| 状态 | 含义 |
|------|------|
| `CREATED` | 订单已创建 |
| `PAYING` | 客户端已调起支付 |
| `PAID` | 服务端验签确认支付成功 |
| `CLOSED` | 订单关闭或超时 |
| `FAILED` | 支付失败 |
| `REFUNDED` | 已退款，后续版本再实现权益冲正 |

### 8.3 素材 / 作品状态

| 对象 | 状态 |
|------|------|
| 素材 | `UPLOAD_PENDING`、`UPLOADED`、`READY`、`FAILED`、`DELETED` |
| 作品 | `READY`、`EXPIRED`、`DELETED` |

---

## 9. Provider Adapter

```java
public interface SmsProvider {
    SendSmsResult sendCode(String phone, String scene, String code);
}

public interface OneClickLoginProvider {
    PhoneVerifyResult verifyToken(String providerToken);
}

public interface PaymentProvider {
    PaymentPrepareResult prepare(PaymentOrder order);
    PaymentCallbackResult verifyCallback(String rawBody, Map<String, String> headers);
}

public interface VodProvider {
    UploadCredential createUploadCredential(MediaAsset asset);
    GenerationSubmitResult submit(GenerationTask task, GenerationInput input);
    GenerationQueryResult query(String providerTaskId);
    VodCallbackEvent verifyCallback(String rawBody, Map<String, String> headers);
    SignedUrl createPlaybackUrl(String providerMediaId, Duration ttl);
}
```

实现类：

| 接口 | 默认实现 | 用途 |
|------|----------|------|
| `SmsProvider` | `MockSmsProvider` | 供应商未确认前跑通登录 |
| `OneClickLoginProvider` | `MockOneClickLoginProvider` | 一键登录占位 |
| `PaymentProvider` | `MockPaymentProvider` | 供应商未确认前跑通订单闭环 |
| `VodProvider` | `MockVodProvider`、`BaiduVodProvider` | 本地闭环和百度 VOD 真实接入 |

---

## 10. 鉴权与安全

- Access Token 使用 JWT，服务端保留可配置过期时间。
- Refresh Token 可落库，支持主动注销和账号注销申请。
- 手机号只保存脱敏展示值与哈希值，避免明文散落。
- 支付、短信、百度 VOD 密钥全部通过环境变量或配置中心注入。
- Controller 不打印敏感字段；Provider 原始回调可落库，但日志中必须脱敏。
- 支付回调和 VOD 回调必须验签、幂等、记录原文、再推进状态。

---

## 11. 业务一致性规则

### 11.1 积分账本

- 创建生成任务时先冻结积分。
- 百度 VOD 生成成功后冻结转扣减。
- 生成失败、超时确认失败、供应商拒绝时退回冻结积分。
- `point_ledgers` 只追加，不物理修改历史流水。
- 同一 `biz_type + biz_id + operation` 只能生成一组账本动作。

### 11.2 支付到账

- 支付成功以服务端回调验签或服务端主动查询为准。
- 客户端支付成功只作为 UI 状态，不直接发放积分或会员。
- 重复回调必须返回成功但不重复发放权益。

### 11.3 百度 VOD 回调

- 以 `provider_events(provider, provider_event_id)` 幂等。
- 回调 DTO 兼容未知字段。
- 保存原始 payload，便于供应商排查。
- 作品创建、任务状态推进、积分扣减必须在事务内完成。

---

## 12. 编码任务清单

截至 v0.5.0，以下任务均已在 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 落地并通过 `./gradlew build`。真实百度 VOD、短信、一键登录和支付渠道仍保留为 Provider Adapter 联调替换点。

| 任务 ID | 任务 | 说明 | 状态 |
|---------|------|------|------|
| T-B001 | Java 工程基础设施 | Spring Boot、统一响应、异常、日志、配置、Flyway、Redis | done |
| T-B002 | 账号鉴权 | 短信验证码、一键登录适配、JWT、用户资料 | done |
| T-B003 | 积分账务 | 账户、流水、冻结、扣减、退回、幂等 | done |
| T-B004 | 支付与会员 | 套餐、订单、支付回调、权益更新、到账补偿 | done |
| T-B005 | 素材服务 | 百度 VOD 上传参数、素材列表、元数据、删除 | done |
| T-B006 | 创作与生成 | 草稿、积分预估、任务创建、状态查询、失败处理 | done |
| T-B007 | 作品服务 | 列表、详情、播放 / 下载地址、过期处理 | done |
| T-B008 | 邀请好友 | 邀请码、记录、奖励发放开关 | done |
| T-B009 | 意见反馈 | 反馈提交、附件占位、处理状态 | done |
| T-B010 | 通用配置与预设 | 风格、音色、背景音乐、协议、静态配置和后台配置预留 | done |
| T-B011 | 外部服务适配层 | 百度 VOD、短信、支付 Provider Adapter | done |

---

## 13. 验证要求

- 每个 Controller 至少有成功路径和一个错误码路径集成测试。
- 积分冻结、扣减、退回必须有 Service 单元测试。
- 支付回调和 VOD 回调必须有重复回调测试。
- Flyway 迁移脚本应能在空 PostgreSQL 数据库完整执行。
- 每次后端改动至少执行 `./gradlew build`，必要时执行 `./gradlew test`。

---

## 14. 未决事项

| 事项 | 影响 |
|------|------|
| 百度 VOD 账号、区域、工作流 / 模板、回调签名 Token | 影响 `BaiduVodProvider` 真实实现 |
| 百度 VOD 自定义域名、播放鉴权、下载 URL 有效期 | 影响作品详情和下载接口 |
| 短信 / 一键登录供应商 | 影响 Auth Provider 真实实现 |
| 支付渠道 | 影响 `PaymentProvider` 和 iOS 合规 |

---

## 15. CHG-0011 邀请好友、返佣与提现 Java 技术审核补充

> 状态：`waiting_review`。邀请好友专题后端技术和开发文档已拆为独立文件，Java 技术总文档只保留索引。

独立技术文档：`projects/剧说/02-技术方案/邀请好友技术文档.md`。

独立后端开发文档：`projects/剧说/04-后端/开发计划/08-邀请好友后端开发文档.md`。

上述文档覆盖 T-B012 的接口契约、表结构、迁移计划、支付回调返佣、提现审核状态流和审核门禁。审核通过前不创建 `V10__invite_commission_withdrawals.sql`，不修改 Java 代码。
