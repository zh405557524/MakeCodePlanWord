# Song API 与数据模型模块开发文档

> 关联任务：T-F003  
> 工程：`/Users/soul/code/lxwx/catsinger`  
> 状态：pending

## 1. 功能定位

为新 PRD 和设计稿所需页面提供统一 API、Model、Store。前端不在页面里临时拼接口字段。

## 2. 现有接口继续保留

- `GET /api/song-config/models`
- `GET /api/song-config/scenarios`
- `GET /api/song-config/examples`
- `GET /api/song-config/inspiration`
- `POST /api/song-generations`
- `GET /api/song-generations/{id}`
- `GET /api/song-works`
- `GET /api/song-works/{id}`
- `POST /api/song-works/{id}/download-url`
- `POST /api/song-works/disable`
- `GET/POST /api/song-albums`

## 3. 新增/补强接口

需要与后端对齐：

- 热门案例列表
- 热门案例详情
- 最近作品
- AI帮写歌词
- 图片写歌上传/资源 ID
- 参考音频上传/资源 ID
- 生成任务进度：百分比、阶段、剩余时间
- 分享链接
- 重新生成
- 加入专辑
- 专辑详情、添加歌曲、封面上传
- 会员信息、积分信息、积分明细、积分充值

## 4. Model 扩展

建议补充字段：

- `SongWorkListItem`: `progressPercent`、`remainingSeconds`、`stageText`、`createdAt`、`pricePoints`
- `SongWorkDetail`: `prompt`、`creatorName`、`shareUrl`、`canRegenerate`
- `SongAlbum`: `description`、`coverUrl`、`createdAt`
- `CreateSongGenerationParams`: `styleDescription`、`vocalGender`、`language`、`durationSeconds`、`imageAssetId`、`referenceAudioAssetId`

## 5. 验收

- [ ] 页面不写死模型价格
- [ ] 创建任务带 `idempotencyKey`
- [ ] 上传资源返回后端资源 ID
- [ ] 生成进度字段可驱动生成详情页
- [ ] 接口失败有用户可读提示
