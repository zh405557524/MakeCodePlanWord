# 06 MiniMax Provider 模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B006
> 状态：done

## 功能定位

封装 MiniMax 歌词生成和音乐生成接口，同时保留 `SongGenerationProvider` 扩展点。

## 类清单

- `SongGenerationProvider`
- `SongProviderFactory`
- `MiniMaxSongGenerationProvider`
- `MiniMaxLyricsClient`
- `MiniMaxMusicClient`
- `GeneratedAudioPayload`

## 请求映射

音乐生成请求包含：`model`、`prompt`、`lyrics`、`is_instrumental`、`lyrics_optimizer`、`audio_setting`。

歌词生成请求包含：`model`、`prompt`、`mode=write_full_song/edit`。

## 业务规则

- 优先处理 `output_format=hex`，必要时支持临时 URL。
- 超时、限流、余额不足、参数错误映射为业务错误。
- 记录 provider traceId 和耗时。
- 不记录密钥和完整歌词。

## 实现步骤

1. 新增配置属性 `SongProviderProperties`。
2. 封装 WebClient/RestClient 调用，设置超时。
3. 将 MiniMax 响应转成统一 payload。
4. 为测试提供 Mock Provider。

## 测试要求

- 歌词请求字段正确。
- 音乐请求字段正确。
- hex 响应转 payload。
- URL 响应转 temporaryUrl。
- 错误响应映射 `PROVIDER_UNAVAILABLE` 或模型错误。

## 验收标准

生成服务不直接依赖 MiniMax 原始响应结构，后续换平台只新增 Provider。
