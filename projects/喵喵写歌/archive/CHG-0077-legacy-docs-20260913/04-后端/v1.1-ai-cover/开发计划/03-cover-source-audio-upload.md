# 03 翻唱源音频上传模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-03
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块负责上传用户用于翻唱的源音频。后端必须完成格式、大小、时长校验，并把源音频持久化到本地上传目录或云存储。

## 2. 接口

`POST /api/song-assets/cover-source-audios`

请求：

- multipart file：`file`
- 可选：`sourceTitle`

响应：

```json
{
  "assetId": 123,
  "fileName": "demo.mp3",
  "fileUrl": "/uploads/...",
  "durationSeconds": 180,
  "sizeBytes": 1234567,
  "format": "mp3"
}
```

## 3. 校验规则

| 校验 | 规则 |
| --- | --- |
| 格式 | `MP3/WAV/M4A/AAC/FLAC` |
| 大小 | 最大 `50MB` |
| 时长 | `6秒 - 6分钟` |
| 时长无法识别 | 拒绝上传 |
| 空文件 | 拒绝上传 |

## 4. 技术实现

- 文件大小先通过 multipart 元数据校验。
- 音频时长使用现有媒体解析能力；若没有现成工具，需要引入轻量解析或调用已有 ffprobe 封装。
- 上传成功后写入 `catsinger_song_assets`，`asset_usage=COVER_SOURCE`。
- 存储路径按 appCode 和日期分目录，例如 `catsinger/cover-source/yyyyMMdd/`。

## 5. 异常返回

| 场景 | message |
| --- | --- |
| 格式不支持 | 当前仅支持 MP3/WAV/M4A/AAC/FLAC |
| 文件过大 | 音频不能超过 50MB |
| 时长过短 | 音频至少需要 6 秒 |
| 时长过长 | 音频最长支持 6 分钟 |
| 时长识别失败 | 无法识别音频时长，请更换文件 |

## 6. 验收标准

- 合法音频上传成功并返回 assetId。
- 超过 6 分钟的音频被拒绝。
- 时长无法识别不允许进入翻唱任务。
- 上传资源不是 Provider 临时 URL。
