# 12 Admin API、权限与审计

> 任务族：`T-B012`
> 骨架任务：`T-B012-S`
> 真实任务：`T-B012-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> Flutter Web 对应：`11-admin-navigation-model-pricing.md`、`12-admin-voice-moderation.md`、`13-admin-tasks-works-resources.md`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B012-S`
- 本阶段交付：建立 Java Admin DTO/Controller/Service 契约和固定查询响应；Web/Admin 前端仍 deferred，不写权限、配置、审核或任务数据。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B012-R`
- 本阶段交付：接入真实 App 切换、角色权限、模型价格、音色、人工审核、任务、作品、资源和审计。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

在现有 Admin App 切换、AI 模型、计费、运维、歌曲、资源、角色和审计模块中增加声音克隆能力。只为音色资料和训练补必要接口，不建设 `/api/admin/voice-cover/**` 大而全平行后台。

## 2. 模型与价格复用

复用：

- `/api/admin/model-providers`
- `/api/admin/ai-models`
- `/api/admin/ai-scene-model-mappings`
- `/api/admin/ai-model-options`
- 现有积分价格接口

新增配置场景 `song.voice.train` 与 `song.voice.cover.generate`，保存真实 provider/model、能力限制、默认模型、容量和价格。修改只影响新任务。

## 3. 音色接口

- `GET /api/admin/song/voice-profiles`
- `POST /api/admin/song/voice-profiles/official`
- `PUT /api/admin/song/voice-profiles/{id}`
- `POST /api/admin/song/voice-profiles/{id}/publish`
- `POST /api/admin/song/voice-profiles/{id}/disable`
- `GET /api/admin/song/voice-training-tasks`
- `POST /api/admin/song/voice-training-tasks/{id}/retry`
- `POST /api/admin/song/voice-provider-bindings/{id}/recover`

所有写操作使用当前 AppCode、权限、状态、revision、原因和审计。发布前复核资料/头像/试听审核、模型/配置持久化和有效 binding。

## 4. 任务、作品和资源

- AI Operations 增加 VOICE_TRAINING/VOICE_COVER 筛选、阶段、时间、路由、积分和错误。
- 作品管理增加 VOICE_COVER、音色/来源和生命周期。
- 资源管理增加训练素材、模型、配置、试听、源歌曲和成品分类。
- 审核记录支持人工结果、处理人、原因、时间和 revision。

不提供取消任务、强制成功、修改厂家状态或任意重放厂家调用。

## 5. 权限

编码前按当前权限注册方式落地：

- `song.voice.profile.read/write`
- `song.voice.training.read/operate`
- `song.voice.cover.read/operate`
- `song.voice.official.publish`
- `song.voice.provider.recover`
- `content.moderation.manual-review`

超级管理员可分配；普通角色只获得授权管理块。每个写接口服务端校验，不能只依赖前端按钮隐藏。

## 6. App 与数据隔离

- App 列表读取服务端配置。
- catsinger 专属接口要求 `X-App-Code: catsinger` 并路由 catsinger schema。
- 其他 App 请求返回明确不支持/拒绝，不读取 catsinger 数据。
- Admin 切 App 后的旧请求即使返回，服务端结果也带当前 app 上下文供前端校验。

## 7. 审计与安全

记录操作人、AppCode、权限、对象、业务类型、原因、前后 revision/状态和时间。敏感音频/模型只返回受控预览；普通管理员不得获取永久 URL、密钥或用户原始私密素材。

## 8. 实现步骤

1. 扩展权限注册和 Admin VO/DTO。
2. 扩展模型/价格/运维/作品/资源现有查询。
3. 新增音色资料与训练专属 Controller/Service。
4. 实现发布、下架、重试、恢复和人工复核状态校验。
5. 接入操作审计和受控资源访问。

## 9. 测试要求

- catsinger/其他 App schema 与接口隔离。
- 各角色 read/write/publish/recover/manual-review 权限矩阵。
- 官方发布门禁、revision 冲突、原因必填。
- 任务/作品/资源筛选和脱敏。
- 快速切 App、越权、手工请求和审计记录。

## 10. 验收标准

- W01-W12 可由现有 Admin 管理域和音色最小子模块覆盖。
- 模型、价格、音色、任务、资源、审核和权限均可运营。
- 后台不能绕过用户端相同的审核/状态/授权事实。

## 11. 编码注意事项

Admin 重试只允许技术文档明确可重试的状态；不得重新确认用户授权或篡改厂家事实。个人音色查询默认脱敏。
