# 03 音色资料与不可变版本

> 任务族：`T-B003`
> 骨架任务：`T-B003-S`
> 真实任务：`T-B003-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter 对应：`04-voice-profile-official-voice.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B003-S`
- 本阶段交付：建立音色资料 Controller/Service、高层校验方法和固定本人/官方音色响应；不读写资料表、不创建资源或审核记录。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B003-R`
- 本阶段交付：接入 owner、资料版本、软删除、官方发布、模型版本和受控试听的真实持久化。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

实现本人/官方音色稳定身份、资料不可变版本、发布状态、删除和可用性查询。音色资料不等于厂家模型，不能保存积分或作品生命周期。

## 2. Controller 与 Service

- `SongVoiceController`
- `SongVoiceProfileService`
- profile/version/model/binding Repository
- 音色 VO mapper

用户端接口：GET/POST `/api/song-voices`，GET/PATCH/DELETE `/api/song-voices/{id}`，素材关系接口由模块 04 实现。

## 3. 业务规则

- MY 只返回当前用户音色；OFFICIAL 只返回已审核、已发布且当前模型组合可用的官方音色。
- 创建本人音色默认 DRAFT；默认资料可继续，自定义文字/头像进入审核。
- PATCH 必须带 revision，创建新资料版本，不覆盖旧版本。
- 官方已发布版本编辑形成草稿，旧版本在新版本发布前继续可用。
- 删除为软删除，先阻止新任务；历史作品按自身规则保留。
- 厂家绑定失效返回 availability=UNAVAILABLE 和统一用户文案，不删除用户音色。

## 4. 权限与安全

- 用户只能查看/编辑自己的音色和公开官方音色。
- 官方音色写操作仅 Admin 专属权限。
- 私有头像/试听通过资源服务返回短期受控地址。
- 响应不包含 provider model URL/config URL、密钥或长期签名 URL。

## 5. 状态

资料建议：DRAFT、REVIEWING、READY_TO_TRAIN、QUEUED、TRAINING、AVAILABLE、UNAVAILABLE、FAILED、DELETED。资料状态与模型版本/审核状态分别保存，Service 组合为前端可用性。

AVAILABLE 要求当前模型版本、有效渠道绑定和可播放审核通过试听同时成立，不能由单字段直接写入。

## 6. 异常与日志

- 非 owner 返回统一无权/不存在语义，避免枚举他人音色。
- revision 冲突返回 409 和当前 revision。
- 运行中任务阻止删除，返回状态冲突。
- 记录 appCode、user/admin、profile/version、动作、前后 revision；不记私有 URL。

## 7. 实现步骤

1. 实现 owner/官方作用域查询和 VO 脱敏。
2. 实现创建及默认资料版本。
3. 实现 revision 更新、新版本和审核触发。
4. 实现软删除、任务引用检查和可用性组合。
5. 接入资源短期访问和官方排序。

## 8. 测试要求

- 本人/他人/官方查询边界。
- 创建、版本递增、revision 冲突和旧发布版本保留。
- 资料审核各状态与可用性组合。
- 软删除后新任务禁止、历史作品仍可查。
- 无有效绑定或试听时不能 AVAILABLE。

## 9. 验收标准

- 音色身份、资料版本和模型版本职责分离。
- App 无法看到厂家私有资源；Admin 权限仍由后端校验。
- 不引用旧 `SongCoverVoiceEntity` 或 `coverVoiceCode`。

## 10. 编码注意事项

资料名称和头像是平台内容，需要审核；厂家试听是资源内容，也需要审核。不要以一个 `enabled` 布尔值替代这些状态。
