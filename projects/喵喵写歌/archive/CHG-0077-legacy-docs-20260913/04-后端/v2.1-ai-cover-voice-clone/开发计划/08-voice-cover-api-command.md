# 08 翻唱声音克隆公开接口与内部命令

> 任务族：`T-B008`
> 骨架任务：`T-B008-S`
> 真实任务：`T-B008-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`03-voice-cover-main-settings.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B008-S`
- 本阶段交付：建立独立 `/api/song-voice-covers` Controller、正式 DTO 和 `VoiceCoverApplicationService` 调用链；按固定顺序调用校验、报价、音色与演示任务方法，返回 200 积分和演示 taskId。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B008-R`
- 本阶段交付：接入真实来源 XOR、owner、审核、音色绑定、模型、授权、幂等、积分和共享任务命令。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

建立独立 `/api/song-voice-covers` 公开门面，完成来源、音色、授权、真实模型、报价和幂等校验后，转换为服务端内部 `VOICE_COVER` 命令并委托共享歌曲任务编排。

## 2. Controller 与 Service

- `SongVoiceCoverController`
- `VoiceCoverApplicationService`
- `VoiceCoverCreateCommand`
- 音色/素材/模型/报价/授权校验器
- 复用现有 `SongGenerationService` 或明确的共享任务创建入口

接口：POST `/api/song-voice-covers`，GET `/{id}` 与 `/active` 查询由模块 09完善。

## 3. 创建契约

请求字段固定为 sourceWorkId/sourceAudioAssetId、voiceModelVersionId、provider、model、modelOptionId、pricingVersion、coverSettings、songRightsConfirmed、voiceConsentConfirmed、idempotencyKey；无 mode。

设置仅允许 transpose/pitch、vocalGain、accompanimentGain 等技术文档白名单，并按当前模型 capabilityLimits 校验。字段命名在编码前与 Flutter 最终统一，不允许任意 JSON 透传厂家。

## 4. 校验顺序

1. `X-App-Code: catsinger`、Token appCode、登录/会员。
2. 来源 XOR、owner/作品使用权、资源 READY + 审核 PASS。
3. voiceModelVersion AVAILABLE，且本人 owner 或官方已发布。
4. 存在精确 provider/model 的 AVAILABLE binding。
5. modelOption/provider/model/pricingVersion 一致且有容量。
6. 两项授权为 true，保存不可变 consent。
7. 幂等创建任务并冻结翻唱积分。

校验失败不得冻结积分或调用 Provider。

## 5. 内部命令

Controller 不接收 mode；ApplicationService 构造 `VoiceCoverCreateCommand`，填入 profile/model/binding/consent IDs、路由快照、来源、settings 和 `creationMode=VOICE_COVER`，再进入共享任务创建。

不得调用 `SongCoverController`、旧 `SongCoverVoiceService` 或使用 coverVoiceCode。

## 6. 响应与幂等

返回平台任务 ID、初始状态、阶段、价格快照、来源/音色/模型摘要和时间。重复 idempotencyKey 返回原任务，不能新建 consent、再次冻结或重复启动工作流。

## 7. 异常与日志

字段、owner、审核、音色、模型、报价、会员、积分和幂等冲突使用稳定错误码。记录 appCode、user/task、来源 ID、voice versions、binding、route/price；不记录授权全文或受控 URL。

## 8. 实现步骤

1. 新建独立 Controller/DTO，不修改旧 API。
2. 实现来源、音色和渠道校验器。
3. 实现授权/报价快照和翻唱幂等作用域。
4. 构造内部 VOICE_COVER 命令并调用共享编排。
5. 返回统一任务 VO并写集成测试。

## 9. 测试要求

- 正常 asset/work 两种来源。
- 来源同空/同填、他人资源、审核未过。
- 本人/官方音色、不可用音色、跨厂家无绑定。
- provider/model 与 option 不一致、价格过期、容量关闭。
- 授权缺失、非会员、积分不足。
- 幂等并发只创建一任务/一冻结。
- 旧 `/api/song-covers` 行为不变。

## 10. 验收标准

- 新公开接口和 `voicecover/` 业务边界独立。
- 底层任务、积分、工作流和作品体系复用而非复制。
- 请求中没有 mode，真实 model 不等于 VOICE_COVER。

## 11. 编码注意事项

若共享 `SongGenerationService` 当前无法接受专属命令，应增加窄适配入口，不把声音克隆校验下沉到旧 Controller，也不复制整个生成 Service。
