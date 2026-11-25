# 09 翻唱工作流、轮询与超时

> 任务族：`T-B009`
> 骨架任务：`T-B009-S`
> 真实任务：`T-B009-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`08-voice-cover-generation.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B009-S`
- 本阶段交付：建立工作流阶段 DTO、查询 Service 和确定性阶段响应，使 App 可查看平台排队、厂家处理和完成状态；不注册调度器、不轮询厂家、不写 deadline。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B009-R`
- 本阶段交付：接入真实工作流步骤、租约、厂家提交/轮询、接单起算、10 分钟 deadline、重启恢复和补偿。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

在现有 `songworkflow` 中增加 VOICE_COVER 专属步骤，实现平台排队、厂家提交、主动轮询、接单起算的 10 分钟时限、重启恢复和失败补偿。不新建第二套工作流引擎。

## 2. 步骤

- `VOICE_COVER_VALIDATE`：复核来源、音色版本、binding、授权和快照。
- `VOICE_COVER_ROUTE`：验证精确 provider/model 和容量。
- `VOICE_COVER_SUBMIT`：调用 Provider，保存厂家任务 ID。
- `VOICE_COVER_POLL`：主动查询并归一化状态。
- 后续 PERSIST/MODERATE/CREATE_WORK/SETTLE 由模块 10 接入现有服务。

步骤实现放 `app/catsinger/voicecover/workflow/step/`，契约遵循现有 `SongWorkflowStep`。

## 3. 时间规则

- 平台 CREATED/VALIDATING/QUEUED/SUBMITTING 前的容量等待不计入 10 分钟。
- 厂家确认接单并返回可查询任务 ID 时原子写 `providerAcceptedAt`。
- 同时写 `deadlineAt = providerAcceptedAt + 10 minutes`。
- 厂家内部排队、生成、平台持久化、探测、审核和作品创建均受 deadline 约束。
- deadline 到而未形成可播放成功作品时 TIMED_OUT并进入补偿。

## 4. 调度与并发

- 使用现有 workflow lease/锁，同一任务同一步骤只有一个执行者。
- 状态更新带 expected status/version，过期 worker 不覆盖新状态。
- 查询失败按配置退避，但不能越过 deadline。
- 服务重启从任务/步骤/调用台账恢复，不重复厂家提交。
- V2.1 不提供取消任务接口；用户离页无服务端动作。

## 5. SUBMIT_UNKNOWN

提交超时且无法确认是否接单时进入 SUBMIT_UNKNOWN：冻结暂不自动释放，不自动重提，记录告警并由运维确认。若厂家返回可查询 ID再恢复；确认未执行或最终失败后按补偿释放。

## 6. 查询接口

GET `/api/song-voice-covers/{id}` 校验 owner 并返回状态/阶段/进度/错误、时间、路由/价格快照和 workId。

GET `/api/song-voice-covers/active` 仅返回当前用户 VOICE_COVER 非终态任务，不混入 AI 写歌或 AI 改编。

## 7. 实现步骤

1. 在工作流注册专属步骤与状态映射。
2. 实现平台容量等待和提交幂等。
3. 实现接单时间/deadline 原子落库。
4. 实现轮询退避、未知状态和 deadline 判定。
5. 接入失败补偿、事件日志、查询和活动任务恢复。

## 8. 测试要求

- 平台排队 11 分钟不触发生成超时。
- 接单后 10 分钟 deadline 精确写入且不可重置。
- 厂家排队/生成/持久化阶段跨 deadline 失败。
- 重启、租约竞争、重复调度和过期 worker。
- SUBMIT_UNKNOWN 不自动重提或释放。
- active 只返回当前用户 VOICE_COVER。

## 9. 验收标准

- 任务全流程可从数据库恢复且不会重复调用厂家。
- 平台排队和厂家处理时间可分别观测。
- 查询语义与 Flutter 倒计时规则一致。

## 10. 编码注意事项

不要使用任务创建时间计算 10 分钟，也不要在查询 Controller 临时推导/写任务状态。所有终态通过工作流和补偿收敛。
