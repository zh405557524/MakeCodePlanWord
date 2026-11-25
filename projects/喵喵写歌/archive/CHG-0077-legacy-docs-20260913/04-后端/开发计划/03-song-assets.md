# 03 资源上传模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B003
> 状态：done

## 功能定位

管理图片写歌、参考音频、专辑封面、示例素材上传。上传后生成自有资源记录，生成任务只引用 `assetId`。

## 接口契约

| 方法 | 路径 | 资源类型 |
|------|------|----------|
| POST | `/api/song-assets/images` | `IMAGE_PROMPT` |
| POST | `/api/song-assets/reference-audios` | `REFERENCE_AUDIO` |

请求使用 multipart。响应返回 `assetId`、`publicUrl`、`contentType`、`sizeBytes`、`durationMs`、`status`。

## 表与字段

表：`catsinger_song_assets`

关键字段：`user_id`、`asset_type`、`biz_type`、`original_filename`、`content_type`、`size_bytes`、`duration_ms`、`storage_provider`、`resource_key`、`public_url`、`meta_json`、`status`。

## 业务规则

- 图片：jpg/png/webp，大小按产品限制配置。
- 音频：mp3/wav/m4a/aac，最大 20MB，最长 5 分钟。
- 资源必须绑定当前用户。
- 生成任务使用资源前再次校验归属和状态。

## 实现步骤

1. 新增 `SongAssetController`。
2. 新增 `SongAssetService`，负责校验和调用存储服务。
3. 复用或接入 `SongResourceStorageService`。
4. 保存 `catsinger_song_assets`。

## 测试要求

- 文件类型非法返回 `SONG_ASSET_INVALID`。
- 超大小或超时长返回错误。
- 其他用户资源不能被当前用户使用。

## 验收标准

图片写歌和参考音频可上传并得到稳定 `assetId`。
