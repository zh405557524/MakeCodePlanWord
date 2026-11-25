# 05 MiniMax Provider 与资源持久化模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-05
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块把翻唱任务真正接到 MiniMax `music-cover`，并把 Provider 返回的音频下载持久化。不能依赖第三方临时 URL 作为最终作品资源。

## 2. Provider 抽象

扩展现有 `SongGenerationProvider`：

```java
SongGenerationResult generateCover(SongCoverGenerationCommand command);
```

Command 字段：

- `sourceAudioUrl`
- `voicePrompt` 或 `voiceConfig`
- `model=music-cover`
- `settings`
- `callbackContext/taskId`

## 3. MiniMax 调用规则

- provider：`minimax`
- model：`music-cover`
- 源音频必须可被 Provider 读取。
- 如果本地资源无法公网访问，需要先上传到可访问的对象存储或使用已有代理方案。
- 失败时记录 Provider 错误码和错误信息。

## 4. 资源持久化

生成成功后：

1. 读取 Provider 返回的音频 URL。
2. 下载到服务端临时文件。
3. 校验文件大小和基本音频信息。
4. 上传到本地上传目录或云存储。
5. 写入 `catsinger_song_assets`：
   - `asset_usage=COVER_AUDIO`
   - `provider=minimax`
   - `provider_model=music-cover`
6. 更新作品表持久化资源 URL。

## 5. 作品生成

- 生成完成后创建 `song_type=COVER` 的作品。
- 作品标题默认：
  - 来源作品标题 + `（翻唱版）`
  - 或上传文件名去扩展名 + `（翻唱版）`
- 保存音色快照和翻唱参数快照。

## 6. 失败处理

- Provider 调用失败：任务 `FAILED`。
- 下载临时 URL 失败：任务 `FAILED`。
- 上传持久化失败：任务 `FAILED`。
- 失败后由积分模块退款。

## 7. 验收标准

- Mock MiniMax 成功时能生成 COVER 作品。
- 作品音频 URL 是本系统持久化 URL。
- Provider 失败能记录原因，用户端能查询到错误。
