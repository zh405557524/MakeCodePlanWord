# 04 AI 帮写与图片描述模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B004
> 状态：done

## 功能定位

支持高级创作中的 AI 帮写歌词，以及图片写歌入口的图片转音乐描述。图片 Provider 未最终确认前必须用抽象隔离。

## 接口契约

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/song-lyrics/assist` | 根据主题、情绪、风格生成歌词 |

请求字段：`topic`、`mood`、`styleTags`、`language`、`durationMinutes`、`provider`、`model`。

响应字段：`title`、`lyrics`、`styleTags`、`provider`、`model`、`traceId`。

## 服务

- `SongLyricAssistService`
- `SongImagePromptProvider`
- `MiniMaxLyricsClient`

## 业务规则

- AI 帮写可以复用 MiniMax lyrics_generation。
- 图片写歌先保存图片资源，再由 `SongImagePromptProvider` 产出 prompt。
- Provider 失败时返回友好错误，后台记录 trace。

## 实现步骤

1. 新增 lyrics assist DTO/VO。
2. 封装 MiniMax lyrics 请求映射。
3. 定义图片 prompt Provider 接口和 Mock 实现。
4. 生成任务创建时支持 `imageAssetId` 转 prompt。

## 测试要求

- AI 帮写成功返回歌词。
- Provider 超时映射 `PROVIDER_UNAVAILABLE`。
- 图片资源不存在或越权返回 `SONG_ASSET_INVALID`。

## 验收标准

App 可以通过 AI 帮写拿到歌词，图片写歌具备可插拔后端能力。
