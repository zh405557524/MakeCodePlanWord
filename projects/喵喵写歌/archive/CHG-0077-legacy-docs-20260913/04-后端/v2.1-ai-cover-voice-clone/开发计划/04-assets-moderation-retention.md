# 04 素材、审核、质量与保留

> 任务族：`T-B004`
> 骨架任务：`T-B004-S`
> 真实任务：`T-B004-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`05-record-file-video-trim.md`、`06-material-upload-moderation.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B004-S`
- 本阶段交付：建立素材绑定/查询 Controller、Service 步骤和固定 READY/PASS/质量通过响应；不上传文件、不探测媒体、不调用审核或保留策略。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B004-R`
- 本阶段交付：接入真实资源绑定、文件探测、内容审核、质量判断、owner 和保留清理。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

将现有平台资源绑定为训练素材或完整翻唱源歌曲，执行真实格式/时长/容量探测、内容审核、质量判断和保留策略。该模块复用现有资源/审核表，不复制资源对象或审核结论。

## 2. 接口与类

- `POST /api/song-assets/voice-materials`
- `POST /api/song-assets/voice-cover-sources`
- `GET /api/song-assets/{id}`
- `POST /api/song-assets/{id}/moderation/retry`
- `GET/POST/DELETE /api/song-voices/{id}/materials/**`
- `SongVoiceMaterialService`、`SongVoiceSourceService`
- 复用 `ResourceRecordService`、`AudioContentFormatDetector`、`ContentModerationService`。

## 3. 请求校验

业务绑定请求只接收平台 resourceId/assetId、来源类型和必要截取范围，不接受任意外部 URL。

- 训练单段 1-5 分钟，累计 1-10 分钟，总量 <=100MB。
- 源歌曲格式 MP3/WAV/M4A/FLAC/OGG/AAC，<=100MB，<=10 分钟。
- 后端按文件签名、真实 MIME、媒体探测、时长和大小联合判断。
- 客户端 duration/扩展名只作提示，不能绕过服务端。

## 4. 审核和质量

READY 仅表示资源可读；审核 PASS 后才可进入训练/翻唱。PENDING/REVIEW/REJECT/ERROR 分别保留。

训练质量返回 PASS/WARNING/BLOCKED 及原因。累计不足 5 分钟是 WARNING，用户可明确确认；明显不可用音频为 BLOCKED。

修改文字、头像、音频或截取范围必须形成新资源/审核快照。已通过上传阶段审核的站内 asset/work 在任务阶段不重复源审核，但任务 Service 仍复核当前事实和 owner。

## 5. 保留与访问

- 原始训练素材最长 30 天，使用现有资源生命周期按引用清理。
- 训练素材、模型、配置、未发布试听使用 OWNER/INTERNAL。
- 删除素材前检查运行中训练锁；不级联删除 profile/work。
- 用户试听自己的音频使用受控 URL；无 owner 或后台权限拒绝。

## 6. 异常与日志

- 无法探测、解码或无音轨：技术失败，不送厂家。
- 审核 REJECT：不可重试原内容；ERROR 且策略允许才重试。
- 资源/asset 不属于用户：拒绝且不泄露存在性。
- 日志记录资源 ID、探测摘要和审核 record ID，不记签名 URL或音频内容。

## 7. 实现步骤

1. 扩展资源类型和业务绑定 DTO。
2. 读取资源记录并执行 owner、HEAD、魔数和媒体探测。
3. 建立/复用 asset 与审核记录。
4. 实现素材关系、累计统计、质量和运行锁。
5. 接入审核重试、受控访问和 30 天保留策略。

## 8. 测试要求

- 格式伪装、超大、过短/过长、损坏、无音轨和探测失败。
- READY 但审核未通过不可用于业务。
- REVIEW/REJECT/ERROR 和重试权限。
- 截取变化产生新审核事实。
- 跨用户/跨 App 资源拒绝。
- 清理任务不会删除仍被运行任务或历史作品引用的资源。

## 9. 验收标准

- 所有上传图片、音频和展示文字进入现有审核体系。
- 任务创建前能验证素材当前可用事实。
- 不新增平行资源表、审核状态机或永久公共 URL。

## 10. 编码注意事项

文件解析和第三方审核不得放在数据库长事务内。重试必须幂等，旧异步审核结果不能覆盖新 revision。
