# 08 翻唱生成任务与状态恢复

> 任务族：`T-F007`
> 骨架任务：`T-F007-S`
> 真实任务：`T-F007-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 页面：P10
> Java 对应：`08-voice-cover-api-command.md`、`09-voice-cover-workflow-timeout.md`、`10-output-persistence-moderation-settlement.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-F007-S`
- 本阶段交付：完成平台排队、厂家处理中、持久化、审核、成功和失败状态页；通过正式查询路径读取确定性的演示任务阶段，不启动真实轮询或倒计时副作用。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-F007-R`
- 本阶段交付：接入真实活动任务恢复、服务端 deadline 轮询、失败恢复和成功 workId 跳转。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

展示翻唱声音克隆任务从平台排队到成品完成的真实状态，并支持离页、切后台和进程重启恢复。页面不取消任务，不创建作品，不执行退款。

## 2. 入口与路由

- P02 创建成功后以 taskId 进入 P10。
- P02/P11 发现活动任务可恢复进入 P10。
- 路由只携带平台 taskId；展示内容重新查询后端。
- 成功后使用响应 workId 打开现有 `SongPlayerPage`。

## 3. 状态映射

| 后端阶段 | 页面 |
|----------|------|
| CREATED/VALIDATING_INPUT/QUEUED | 平台排队，不显示倒计时 |
| SUBMITTING | 正在提交厂家 |
| PROVIDER_QUEUED/GENERATING | 厂家处理中；有 deadlineAt 才倒计时 |
| PERSISTING_OUTPUT | 正在保存成品 |
| PROBING_OUTPUT | 正在检查音频 |
| REVIEWING_OUTPUT | 正在安全审核 |
| CREATING_WORK/SETTLING | 正在完成作品 |
| SUCCEEDED | 取得 workId 后打开播放器 |
| FAILED/TIMED_OUT/SUBMIT_UNKNOWN | 显示后端错误与恢复动作 |

## 4. 倒计时规则

- `providerAcceptedAt/deadlineAt` 任一为空：显示“排队中”，不显示 10 分钟。
- 字段齐全：按服务端 deadlineAt 与当前时间计算。
- 倒计时为展示，不在本地切换任务终态；到 0 立即刷新。
- 厂家排队、生成、持久化、探测、审核和作品创建均可能发生在倒计时内。

## 5. 轮询与并发

- 轮询参数使用 config，失败有限退避。
- 每个 taskId 同时只有一个页面轮询所有者；epoch 丢弃过期响应。
- 切后台暂停高频轮询，回前台立即刷新。
- 离页保留 taskId；终态后清除活动 ID并刷新积分/作品。
- 用户再次点击提交时由后端幂等返回旧任务，App 直接恢复。

## 6. 失败恢复

- 参数/授权错误返回 P02 定位字段。
- 音色或模型不可用返回 P02 重新选择。
- 审核拒绝返回源歌曲/音色资料处理。
- TIMED_OUT/FAILED 可重新翻唱，生成新 idempotencyKey。
- SUBMIT_UNKNOWN 只显示“处理中，请稍后查看”，不提供再次提交厂家按钮。

## 7. 影响文件

建议新增 `lib/pages/song_voice_cover/generating/`，复用现有 `song_create/generating` 的生命周期和布局思想，但不复用其业务 Controller。进度、阶段和失败卡可做本业务 widgets。

## 8. 实现步骤

1. 建立任务状态到 UI 状态的总映射和未知状态兜底。
2. 接入 taskId 恢复、轮询所有权和生命周期暂停。
3. 实现服务端 deadline 倒计时。
4. 实现错误动作和重新翻唱回填。
5. 成功时锁定本次 workId，停止页面试听后打开播放器。

## 9. 测试与验收

- 平台排队超过 10 分钟仍不被客户端判失败。
- providerAcceptedAt 出现后才展示倒计时。
- 切后台/杀进程恢复同一任务，不重复创建或扣费。
- 成功无 workId、work 不可访问或音频不可播放时不误报完整通过。
- 未知状态显示可恢复错误，不崩溃。
- P10 固定元素在三种目标屏幕和系统大字体下不重叠。

## 10. 编码注意事项

不提供取消按钮；“退出等待”只导航。任务进度和剩余时间不得由页面虚构，任何退款或结算文案都以刷新后的后端事实为准。
