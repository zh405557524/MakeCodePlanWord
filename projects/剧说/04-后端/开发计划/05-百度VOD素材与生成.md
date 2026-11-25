# 剧说 Java 模块开发文档：05-百度 VOD 素材与生成

> 版本：v0.5.0  
> 创建日期：2026-05-19  
> 对齐总体任务：T-B005、T-B006、T-B011  
> 依赖模块：01-基础设施、02-账号鉴权与用户、03-积分账务  
> 状态：done

---

## 1. 功能定位与边界

本模块负责素材、草稿、积分预估、生成任务、百度 VOD Provider、VOD 回调和任务状态推进，是剧说后端的核心业务链路。

Flutter 只通过后端 API 获取上传参数、创建任务和查询状态，不直连百度 VOD SDK、AK/SK、上传密钥或回调地址。

---

## 2. 代码清单

| 类型 | 建议类 |
|------|--------|
| Controller | `app/media/controller/MediaController`、`app/creation/controller/CreationController`、`app/generation/controller/GenerationController`、`app/generation/controller/BaiduVodCallbackController` |
| Service | `app/media/service/MediaService`、`app/creation/service/CreationService`、`app/generation/service/GenerationService`、`app/generation/service/VodCallbackService` |
| Infra | `app/generation/infra/VodProvider`、`app/generation/infra/MockVodProvider`、`app/generation/infra/BaiduVodProvider` |
| Repository | `app/media/repository/MediaAssetRepository`、`app/creation/repository/CreationDraftRepository`、`app/generation/repository/GenerationTaskRepository`、`payment/repository/ProviderEventRepository` |
| Entity | `app/media/entity/MediaAssetEntity`、`app/creation/entity/CreationDraftEntity`、`app/generation/entity/GenerationTaskEntity`、`payment/entity/ProviderEventEntity` |
| DTO | `app/media/dto/*`、`app/creation/dto/*`、`app/generation/dto/*` |
| VO | `app/media/vo/UploadCredentialResponse`、`app/creation/vo/GenerationEstimateResponse`、`app/generation/vo/GenerationTaskResponse` |

---

## 3. 接口契约

### POST `/api/media/upload-token`

鉴权：必须登录。关键写接口，支持 `Idempotency-Key`。

请求：

```json
{
  "fileName": "video.mp4",
  "fileSize": 10485760,
  "contentType": "video/mp4",
  "durationSeconds": 120
}
```

响应：

```json
{
  "assetId": "10001",
  "provider": "BAIDU_VOD",
  "uploadUrl": "https://...",
  "uploadHeaders": {},
  "expiresAt": "2026-05-19T10:00:00+08:00"
}
```

### GET `/api/media/assets`

返回当前用户素材分页列表。

### DELETE `/api/media/assets/{id}`

软删除当前用户素材。已被生成任务使用的素材不物理删除。

### POST `/api/creation/estimate`

根据素材总时长和参数预估积分，默认按每分钟 20 积分，取整规则在业务确认前先向上取整。

### POST `/api/creation/drafts`

保存草稿参数快照。

### POST `/api/generation/tasks`

鉴权：必须登录。关键写接口，必须支持 `Idempotency-Key`。

创建任务时冻结积分，然后调用 `VodProvider.submit()`。

### GET `/api/generation/tasks/{id}`

返回任务状态、进度、失败原因、作品 ID。

### POST `/api/providers/baidu-vod/callback`

接收百度 VOD 原始回调。必须验签、幂等、保存原文。

---

## 4. 数据表与迁移

| 表 | 关键字段 |
|----|----------|
| `media_assets` | `user_id`、`provider`、`provider_media_id`、`duration_seconds`、`status` |
| `creation_drafts` | `user_id`、`params_json`、`status` |
| `generation_tasks` | `user_id`、`status`、`points_cost`、`provider_task_id`、`provider_status`、`work_id` |
| `provider_events` | `provider_event_id`、`event_type`、`raw_payload`、`process_status` |
| `works` | 生成成功时创建 |
| `point_ledgers` | 冻结、扣减、退回流水 |

---

## 5. 业务规则与状态流转

生成任务状态：

```text
CREATED -> POINTS_FROZEN -> SUBMITTED -> QUEUED / PROCESSING -> SUCCEEDED
                                               └──────────────-> FAILED / TIMEOUT
```

积分规则：

- 创建任务前必须先调用预估逻辑。
- 创建任务时冻结积分。
- VOD 成功回调后冻结转扣减并创建作品。
- VOD 失败回调或补偿确认失败后退回积分。

VOD 回调规则：

- 以 `provider_events(provider, provider_event_id)` 幂等。
- `VIDEO_GENERATE_COMPLETE` 成功时创建作品。
- 回调 DTO 必须兼容未知字段。
- 原始 payload 必须保存。

---

## 6. 百度 VOD Provider 约束

```java
public interface VodProvider {
    UploadCredential createUploadCredential(MediaAsset asset);
    GenerationSubmitResult submit(GenerationTask task, GenerationInput input);
    GenerationQueryResult query(String providerTaskId);
    VodCallbackEvent verifyCallback(String rawBody, Map<String, String> headers);
    SignedUrl createPlaybackUrl(String providerMediaId, Duration ttl);
}
```

真实实现需要配置：

- 百度 VOD AK/SK。
- 区域。
- 工作流 / 模板。
- 回调签名 Token。
- 自定义域名与播放鉴权策略。
- 视频生成结果存储策略。

---

## 7. 依赖前置

- 积分账务模块可用。
- 用户鉴权可用。
- 百度 VOD 参数待真实联调时补齐。

---

## 8. 实现步骤

1. 实现素材 Entity / Repository / Service。
2. 实现上传参数接口，先接 `MockVodProvider`。
3. 实现积分预估和草稿保存。
4. 实现创建生成任务：校验素材、冻结积分、提交 VOD。
5. 实现任务查询。
6. 实现 VOD 回调：验签、幂等、推进状态、创建作品、扣减或退回积分。
7. 补超时补偿查询任务。

---

## 9. 任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-B005-01 | `MediaService` | `done`：上传参数、素材列表、软删除和上传幂等可用 |
| T-B006-01 | `CreationService` | `done`：积分预估和草稿保存可用 |
| T-B006-02 | `GenerationService` | `done`：创建任务、任务幂等并冻结积分 |
| T-B011-01 | `VodProvider` | `done`：mock 与百度骨架实现同接口 |
| T-B011-02 | `VodCallbackService` | `done`：回调幂等、作品创建、账本扣减 / 退回 |
| T-B006-03 | 测试 | `done`：成功、失败、重复回调、积分退回覆盖 |

---

## 10. 测试要求

- 上传参数接口创建素材记录。
- 积分不足时创建任务失败。
- 创建任务成功后积分冻结。
- VOD 成功回调后任务成功、作品创建、积分扣减。
- VOD 失败回调后任务失败、积分退回。
- 重复 VOD 回调不重复创建作品、不重复扣减。

---

## 11. 验收标准

- mock VOD 能跑通“上传 -> 创建任务 -> 回调成功 -> 作品生成”闭环。
- 真实百度 VOD 接入只修改 Provider 配置和实现，不影响 Controller / Service 契约。
- 任务状态、作品状态、积分账本三者一致。

---

## 12. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-05-19 | 落地 T-B005/T-B006/T-B011 百度 VOD 素材与生成 | 已实现上传凭证、素材列表、草稿、积分预估、生成任务、百度 VOD Provider 骨架、VOD 回调幂等、成功扣减和失败退回；`./gradlew build` 通过 |
