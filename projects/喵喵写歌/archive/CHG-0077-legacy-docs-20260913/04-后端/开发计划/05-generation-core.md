# 05 生成任务核心模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B005
> 状态：done

## 功能定位

创建歌曲生成任务，处理幂等、参数校验、积分冻结、状态机和轮询进度。

## 接口契约

| 方法 | 路径 |
|------|------|
| POST | `/api/song-generations` |
| GET | `/api/song-generations/{id}` |

`CreateSongGenerationRequest` 字段以 `java-tech.md` 第 7.1 节为准。

## 状态机

`CREATED -> POINTS_FROZEN -> PROMPT_PREPARING -> LYRICS_GENERATING -> MUSIC_GENERATING -> RESOURCE_SAVING -> SUCCEEDED`

失败走 `FAILED -> REFUNDED`。

## 业务规则

- `idempotencyKey` 按 `(user_id, idempotency_key)` 唯一。
- 模型价格从 `catsinger_song_model_configs` 读取，前端不传价格。
- 积分不足直接失败，不创建生成中任务。
- 积分冻结成功后才进入 Provider。
- 资源保存成功后才确认扣减积分。

## 实现步骤

1. 拆 `SongGenerationService`。
2. 补生成请求校验。
3. 接入积分冻结/扣减/退款。
4. 写入进度字段和阶段文案。
5. 轮询接口返回任务和关联作品。

## 测试要求

- 重复幂等键返回同一任务。
- 积分不足不冻结。
- Provider 失败退款。
- 资源保存失败退款。

## 验收标准

App 能创建任务、看到进度、失败有退款状态、成功有 `workId`。
