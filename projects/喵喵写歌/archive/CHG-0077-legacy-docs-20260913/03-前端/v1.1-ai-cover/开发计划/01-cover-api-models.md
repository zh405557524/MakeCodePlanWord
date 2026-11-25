# 01 AI 翻唱 API 与模型模块

- 版本：v1.1-ai-cover
- 对应任务：F-COVER-01
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/catsinger`

## 1. 功能定位

本模块先补齐 Flutter 侧 AI 翻唱所需的模型、API、Store 和路由参数。后续上传、音色、设置、结果页都依赖这里的类型，不先完成会导致页面之间靠散装 Map 传值。

## 2. 需要新增或补齐的模型

| 类型 | 用途 | 关键字段 |
| --- | --- | --- |
| `CoverVoiceConfig` | 翻唱音色配置 | `id/name/group/tags/avatarUrl/previewAudioUrl/enabled/sortOrder` |
| `CoverSourceAudio` | 翻唱源音频 | `assetId/fileName/fileUrl/durationSeconds/sizeBytes/format/sourceType/sourceWorkId` |
| `CreateCoverRequest` | 创建翻唱任务 | `sourceAudioAssetId/sourceWorkId/coverVoiceCode/settings/copyrightConfirmed/idempotencyKey` |
| `CoverTaskDetail` | 翻唱任务详情 | `id/status/progressPercent/stageText/estimatedRemainingSeconds/workId/errorMessage` |
| `CoverWorkDetail` | 翻唱作品详情 | `workId/sourceWorkId/originalAudioUrl/coverAudioUrl/voiceName/settings` |
| `SongWorkListItem` 扩展 | 作品列表类型标签 | `songType/coverVoiceName/sourceTitle/progressPercent/stageText` |

## 3. API 封装

| 方法 | 接口 | 说明 |
| --- | --- | --- |
| `fetchCoverVoices()` | `GET /api/song-cover/voices` | 获取音色分组 |
| `uploadCoverSourceAudio()` | `POST /api/song-assets/cover-source-audios` | 上传本地源音频 |
| `createCover()` | `POST /api/song-covers` | 创建翻唱任务 |
| `fetchCoverTask()` | `GET /api/song-covers/{id}` | 查询任务进度 |
| `fetchWorks()` 扩展 | `GET /api/song-works` | 支持 `songType=COVER` 筛选 |
| `fetchWorkDetail()` 扩展 | `GET /api/song-works/{id}` | 返回翻唱详情字段 |

## 4. Store 设计

- `SongCoverStore`
  - 缓存音色列表和分组。
  - 缓存当前上传源音频。
  - 维护当前翻唱草稿：源音频、音色、设置、版权确认。
  - 负责创建任务后轮询。
- `SongWorkStore` 扩展
  - 支持按 `songType` 加载作品。
  - 最近作品中显示 `原创 / 翻唱 / 纯音乐` 标签。

## 5. 路由参数

| 路由 | 入参 | 来源 |
| --- | --- | --- |
| `/song-cover/upload` | `sourceWorkId?` | 首页、作品页重新翻唱 |
| `/song-cover/voice` | `sourceAudioAssetId/sourceWorkId` | 上传页下一步 |
| `/song-cover/settings` | `sourceAudioAssetId/sourceWorkId/coverVoiceCode` | 音色页下一步 |
| `/song-cover/result` | `taskId/workId?` | 提交任务、作品详情 |

## 6. 实现步骤

1. 在 `models/data/song.dart` 或独立 `models/data/song_cover.dart` 增加 DTO。
2. 在 `apis/song.dart` 增加翻唱接口方法。
3. 新增或扩展 `store/song_cover.dart`，统一管理翻唱流程状态。
4. 给 `SongWorkListItem` 和作品详情补 `songType` 等兼容字段。
5. 所有 JSON 解析必须容错：字段缺失给空值或默认值，不让页面崩溃。

## 7. 验收标准

- DTO 单测覆盖正常 JSON、缺字段、非法枚举。
- Store 能在无网络、空音色、创建失败时返回页面可消费的错误态。
- 所有请求继续自动带 `X-App-Code: catsinger`。
