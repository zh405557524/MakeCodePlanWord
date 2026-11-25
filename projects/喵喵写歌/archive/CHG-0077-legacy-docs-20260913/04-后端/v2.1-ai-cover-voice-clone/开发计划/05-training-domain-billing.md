# 05 音色训练领域、授权与计费

> 任务族：`T-B005`
> 骨架任务：`T-B005-S`
> 真实任务：`T-B005-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`07-voice-training.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B005-S`
- 本阶段交付：建立训练 Controller/Service 及校验输入、读取报价、检查音色、创建演示任务等高层方法；固定返回 100 积分和演示训练任务，不冻结积分。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B005-R`
- 本阶段交付：接入真实授权、报价、幂等、训练任务、积分冻结/结算/释放和模型版本状态。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

创建并管理音色训练任务，冻结独立训练积分，保存每次授权和报价快照，并将厂家训练结果归入新的音色模型版本。训练任务不使用歌曲生成任务表，也不创建歌曲作品。

## 2. Controller 与 Service

- `SongVoiceTrainingController`
- `SongVoiceTrainingService`
- consent、training task、profile/model Repository
- 复用现有模型选项/报价、积分冻结/结算/释放、调用台账和任务调度能力

接口：`POST /api/song-voice-training-tasks`、`GET /api/song-voice-training-tasks/{id}`。

## 3. 创建请求和校验

请求包含 voiceProfileId、materialAssetIds、真实 provider/model、modelOptionId、pricingVersion、rightsConfirmed、riskConsentConfirmed、qualityWarningConfirmed、idempotencyKey。

创建前依次校验：appCode/登录、owner、资料版本、素材审核与质量、累计时长/容量、授权 true、模型能力/渠道、报价版本、会员、余额和用户并发限制。

任何前置失败返回 4xx，不创建任务、不冻结积分、不调用厂家。

## 4. 事务与幂等

同一用户 + TRAINING + idempotencyKey 唯一。短事务内：锁定报价快照、创建不可变 consent、创建训练任务、冻结积分并记录业务引用。外部提交在事务外由工作执行器完成。

重复键返回原任务和原价格快照；不能重复冻结。若任务创建后工作流启动失败，进入可恢复状态而不是丢失任务。

## 5. 状态流转

```text
CREATED -> VALIDATING -> QUEUED -> SUBMITTING -> PROVIDER_QUEUED
-> TRAINING -> SAVING_MODEL -> SAVING_CONFIG -> REVIEWING_AUDITION
-> AVAILABLE
-> FAILED / SUBMIT_UNKNOWN / TIMED_OUT
```

AVAILABLE 由后续持久化和试听审核共同决定。失败释放冻结；成功模型可用后确认训练积分扣减。SUBMIT_UNKNOWN 不自动重提。

## 6. 查询响应

返回平台任务 ID、状态/阶段/进度、错误、provider/model/modelOption/pricingVersion/pricePoints、profile/version、产出 modelVersionId、创建/更新时间。不得返回厂家模型文件地址、配置地址或长期试听 URL。

## 7. 异常与日志

- 报价过期、余额不足、模型停用和素材变化分别返回稳定错误码。
- 积分冻结/释放失败进入现有补偿，不隐瞒任务状态。
- 记录 appCode、taskId、用户脱敏 ID、模型/报价、素材数量/总时长、consent ID；不记录授权全文或资源 URL。

## 8. 实现步骤

1. 建立训练状态和创建校验器。
2. 实现不可变授权记录和幂等任务。
3. 接入训练场景报价与积分冻结。
4. 接入异步执行入口和查询 VO。
5. 实现失败释放、成功确认和补偿事件。

## 9. 测试要求

- 正常创建、重复幂等、并发双击。
- 非 owner、素材审核未过、时长边界、质量告警未确认。
- 非会员、余额不足、报价过期、模型停用/能力错误。
- 冻结失败、工作流启动失败、最终失败释放和成功扣减。
- 新训练不覆盖历史成功模型版本。

## 10. 验收标准

- 训练和翻唱使用不同计费场景与幂等作用域。
- 每个任务有独立授权事实和报价快照。
- 外部调用不在长事务，任务可从数据库恢复。

## 11. 编码注意事项

不要创建训练取消接口；不要把训练任务塞入 `catsinger_song_generation_tasks`。积分状态与训练状态分别记录并通过补偿收敛。
