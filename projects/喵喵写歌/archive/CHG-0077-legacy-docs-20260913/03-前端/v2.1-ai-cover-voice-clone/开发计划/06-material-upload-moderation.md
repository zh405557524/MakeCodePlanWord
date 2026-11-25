# 06 素材上传、安全审核与质量状态

> 任务族：`T-F005`（上传与审核）
> 骨架任务：`T-F005-S`
> 真实任务：`T-F005-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 页面：P07、P08 与 P02 源歌曲卡
> Java 对应：`04-后端/.../开发计划/04-assets-moderation-retention.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-F005-S`
- 本阶段交付：完成上传、处理、审核、质量和失败重试的全部 UI 状态；调用正式素材 API，但不选择真实文件、不直传 OSS、不触发真实审核。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-F005-R`
- 本阶段交付：接入真实直传、资源绑定、探测、审核轮询、质量结果和受控 URL 生命周期。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

把本地候选音频上传到平台资源体系，绑定为训练素材或翻唱源歌曲，并展示技术状态、内容审核和质量结论。上传完成不等于可训练或可翻唱。

## 2. 数据流

```text
本地候选
  -> ResourceAPI.prepareDirectUpload
  -> OSS 上传
  -> completeDirectUpload
  -> bindVoiceMaterial 或 bindCoverSource
  -> GET /api/song-assets/{id}
  -> READY + moderation PASS
  -> 进入训练累计或翻唱提交门禁
```

签名 URL 只存在上传调用栈中，不进入路由、日志、持久 Store 或错误上报。

## 3. 状态模型

技术状态和审核状态分开展示：

- 技术：PREPARING、UPLOADING、PROCESSING、READY、FAILED。
- 审核：PENDING、PASS、REVIEW、REJECT、ERROR。
- 质量：PASS、WARNING、BLOCKED、UNKNOWN。

未知状态按不可用处理。只有技术 READY、审核 PASS 且质量不是 BLOCKED 的素材才进入业务可用集合。

## 4. 页面交互

- P02 源歌曲卡展示上传百分比、解析中、审核中、通过、拒绝、异常和重新选择。
- P08 素材行显示来源、时长、大小、审核、质量、试听和删除。
- ERROR 且后端 `retryable=true` 才显示审核重试。
- REJECT 只能更换内容或重新录制，不能重复提交原内容绕过审核。
- 训练运行中锁定的素材不能删除；冲突响应后刷新列表。

## 5. 限制与文案

- 翻唱源：MP3/WAV/M4A/FLAC/OGG/AAC、<=100MB、<=10 分钟。
- 训练单段：1-5 分钟；累计 1-10 分钟且 <=100MB。
- 累计不足 5 分钟允许训练，但显示效果风险确认。
- 限制从 config 渲染，客户端只做快速预检，不能写死旧 Figma 数值。

## 6. 影响文件

建议新增：

- `lib/pages/song_voice_cover/media/material_upload_controller.dart`
- `lib/pages/song_voice_cover/widgets/material_status_tile.dart`
- `lib/pages/song_voice_cover/widgets/moderation_status_badge.dart`
- `lib/pages/song_voice_cover/widgets/quality_warning_dialog.dart`

复用现有资源直传、私有资源换签、Toast 和进度组件。

## 7. 实现步骤

1. 将本地候选转换为当前直传参数，业务资源类型严格区分训练/源歌曲。
2. 接入 prepare、上传、complete 三阶段进度和可取消页面展示。
3. 绑定业务素材后切换为服务端 assetId，并清理签名 URL。
4. 轮询 asset 状态，页面 epoch 防止旧响应覆盖新上传。
5. 实现审核错误重试、拒绝替换、质量告警确认和删除冲突。
6. 上传/轮询完成后通知 P02/P08 重算 blockingReason。

## 8. 定向测试

- prepare、上传、complete、绑定任一步失败均可恢复，且不重复绑定。
- 旧上传响应不会覆盖用户后来选择的新文件。
- READY + PENDING 仍不可提交；ERROR 仅在可重试时显示按钮。
- 截取内容改变后使用新 asset，不沿用旧审核 PASS。
- 签名 URL 不出现在 Store 和持久化草稿。

## 9. 验收标准

- 所有图片、音频和可展示文字都能看见审核状态。
- 审核未通过时训练/翻唱按钮明确禁用并说明原因。
- 上传者试听自有音频仍走当前 OWNER 受控访问，不生成永久公共 URL。
- App 不重复送审已通过的站内 asset，但最终判断由后端完成。

## 10. 编码注意事项

不要把技术上传状态和内容审核状态合并成一个布尔值；不要在客户端实现审核放行策略。上传页面退出不取消服务端已创建的审核任务。
