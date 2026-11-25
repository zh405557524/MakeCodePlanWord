# 04 翻唱任务接口与服务模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-04
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块打开 `mode=cover` 的用户端创建与查询能力。v1.0 里若存在“翻唱暂未开放”的占位，本模块需要改为真实创建任务。

## 2. 接口

### 2.1 创建翻唱任务

`POST /api/song-covers`

请求：

```json
{
  "sourceWorkId": 1001,
  "sourceAudioAssetId": null,
  "coverVoiceCode": "gentle_male",
  "copyrightConfirmed": true,
  "settings": {
    "keepLyrics": true,
    "keepInstrumental": true,
    "pitchShift": 0,
    "emotionStrength": 50,
    "reverb": 30
  },
  "idempotencyKey": "uuid"
}
```

### 2.2 查询任务

`GET /api/song-covers/{id}`

响应：

```json
{
  "id": 2001,
  "status": "RUNNING",
  "progressPercent": 40,
  "stageText": "正在生成翻唱",
  "estimatedRemainingSeconds": 60,
  "workId": null,
  "errorMessage": null
}
```

## 3. 创建校验

- `copyrightConfirmed=true` 必填。
- `sourceWorkId` 和 `sourceAudioAssetId` 至少有一个。
- `coverVoiceCode` 必须存在且启用。
- 源作品必须属于当前用户或当前用户有权限使用。
- 源音频必须是当前用户上传或可使用的作品资源。
- 模型配置必须启用。

## 4. 任务状态

| 状态 | 含义 |
| --- | --- |
| `PENDING` | 已创建，等待执行 |
| `RUNNING` | Provider 生成中 |
| `SUCCEEDED` | 已生成作品 |
| `FAILED` | 失败，积分已退款 |

## 5. 实现步骤

1. 新增 `SongCoverController`。
2. 新增 `SongCoverService.createCover()`。
3. 复用或扩展歌曲任务表，写入 `mode=COVER`。
4. 创建后进入异步执行队列或现有任务执行器。
5. 查询接口返回进度字段。

## 6. 验收标准

- 合法请求能创建翻唱任务。
- 缺版权确认返回业务错误。
- 重复 idempotencyKey 返回同一任务。
- 查询任务只允许当前用户访问。
