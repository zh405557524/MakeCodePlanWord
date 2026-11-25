# 喵喵写歌 V2.1 翻唱声音克隆 Java 总体开发计划

> 文档版本：`v2.1-ai-cover-voice-clone`
> 变更编号：`CHG-0073`
> 状态：`done`
> 实现策略：`skeleton_first`
> 当前实现阶段：`real_review`
> 本轮骨架目标：`flutter,java`
> 骨架运行环境：`local_test_fixed`
> 创建日期：2026-09-09
> 需求真源：`../../01-需求/v2.1-ai-cover-voice-clone/requirements.md`
> 技术方案：`../../02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md`
> 工时评估：`../../02-技术方案/v2.1-ai-cover-voice-clone/effort-estimate.md`
> Java 技术文档：`./java-tech.md`
> Flutter 接口期望：`../../03-前端/v2.1-ai-cover-voice-clone/flutter-tech.md`
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 技术栈：Java 21、Spring Boot 3.3、Gradle、MyBatis-Plus、PostgreSQL、Redis、Flyway、JWT

---

## 0. 文档用途与执行门禁

本文是第 10 步 Java 总体开发计划，负责确定后端实现顺序、数据和接口依赖、工作流接入、Provider、多渠道、审核、积分、Admin API、测试和真实厂家联调边界。

本文通过前仍不编码；通过后先按第 12 步生成全部 Java 模块开发文档。模块文档通过后才进入第 14 步 Java 编码。

不可突破的边界：

1. AI 写歌、AI 改编、翻唱声音克隆是三个独立业务。
2. 新业务公开创建接口固定为 `/api/song-voice-covers`，DTO 不含 `mode`。
3. 服务端固定内部 `VOICE_COVER`，但 `provider/model` 必须是真实厂家和模型。
4. 新建 `app/catsinger/voicecover/`，不向现有 `cover/` 写声音克隆逻辑。
5. 共用当前任务、工作流、模型路由、积分、资源、审核、作品和 Admin 基础设施，不建设平行通用体系。
6. 平台排队不计入 10 分钟；厂家确认接单并返回可查询任务 ID 后才开始。
7. 只有结果已持久化、探测、审核、创建作品且服务端可播放，任务才能成功结算。
8. 本轮先完成 Java `-S` 可运行骨架：正式契约、Controller、Service、高层业务方法与集中固定数据；不创建迁移、实体、仓储或真实副作用。
9. Flutter/Java 骨架整体完成后统一进入 `skeleton_review`；只有用户明确确认骨架后才执行 `-R`。

---

## 1. 当前状态与基线

| 字段 | 当前值 |
|------|--------|
| 当前阶段 | `14 Java 编码` |
| 当前状态 | `waiting_review`（T-B001-R 至 T-B013-R 已本地实现，T-B014-R 待部署） |
| 当前恢复点 | 领域、Provider、工作流、迁移、Admin API 和定向测试已完成；等待目标环境迁移、配置和真实厂家闭环 |
| 下一动作 | 部署 V4.8/V4.9，配置训练/翻唱模型与价格，执行真实音色训练和可播放翻唱验收 |
| Java 基线 | `dev @ 45f0fd2e` |
| Schema | `X-App-Code: catsinger`，执行 `common + catsinger` Flyway locations |
| 首期厂家 | 算道，主动轮询，不接回调 |

### 1.1 现有未提交改动保护

计划生成时 Java 工程已有其他任务修改：

- `SongGenerationService.java`
- `SongGenerationStepSupport.java`
- `AiModelCallService.java`
- `IMusicModelProvider.java`
- `SuandaoMusicProvider.java`
- `MusicModelService.java`
- 对应测试文件

进入编码前必须重新读取这些差异并区分所有权。不得还原、覆盖或格式化无关改动；需要修改同一文件时，先在对应模块文档中写清合并点和受影响测试。

### 1.2 状态枚举

| 状态 | 含义 |
|------|------|
| `pending` | 未开始或依赖未完成 |
| `in_progress` | 当前正在实现 |
| `waiting_review` | 代码和规定验证完成，等待评审或真实环境验收 |
| `blocked` | 厂家、环境、数据或决策阻塞 |
| `done` | 任务完成定义全部满足 |
| `skipped` | 用户明确跳过并记录原因 |

规则：每次只推进依赖已完成的任务；外部调用已返回但资源/审核/作品/结算未闭环时不得标记完成；Mock 通过不能把真实厂家任务标为 `done`。

### 1.3 双阶段状态

| 阶段 | 可执行任务 | 当前状态 | 完成/退出条件 |
|------|------------|----------|---------------|
| 骨架准备 | 模块文档 `-S/-R` 拆分 | `skeleton_pending` | 文档评审通过后进入骨架编码 |
| 骨架编码 | `T-B001-S`～`T-B014-S` | `done` | 正式契约与调用链可运行，固定数据集中管理，生产配置禁用 |
| 骨架评审 | 不编码 | `done` | 用户已明确确认骨架并授权真实实现 |
| 真实实现 | `T-B001-R`～`T-B014-R` | `waiting_review` | T-B001-R 至 T-B013-R 已完成；T-B014-R 等待目标环境和真实厂家 |

---

## 2. 总体开发策略

### 2.1 分层顺序

骨架阶段固定顺序：

```text
正式 DTO/VO 与错误契约
  -> Controller 路由与生产禁用门禁
  -> Service 接口与完整高层步骤方法
  -> 集中 Skeleton Fixture 确定性响应
  -> Flutter 调用链
  -> 编译、契约、调用链和生产禁用检查
  -> skeleton_review
```

骨架阶段禁止 Flyway、Entity、Mapper/Repository、数据库读写、积分、审核、上传、Provider、轮询、资源转存和作品创建。下列真实分层顺序仅属于 `-R`：

```text
基线与契约
  -> Flyway 与 Entity
  -> 音色资料、素材、授权
  -> 训练任务与 Provider 抽象
  -> 算道训练适配和模型持久化
  -> 独立翻唱接口和共享任务命令
  -> 翻唱工作流、轮询、超时与补偿
  -> 输出持久化、审核、作品和积分结算
  -> Admin API、权限和审计
  -> 定向测试、全量回归、部署配置、真实厂家闭环
```

### 2.2 代码所有权

| 目录 | 负责 | 禁止 |
|------|------|------|
| `app/catsinger/voicecover` | 音色、训练、绑定、授权、专属 Controller/DTO/Service/步骤 | 复制积分、资源、审核、作品或通用工作流 |
| `app/catsinger/generation` | 通用歌曲任务创建、冻结和启动 | 暴露声音克隆专属 HTTP DTO |
| `app/catsinger/songworkflow` | 通用步骤引擎、租约、调度、事件和补偿 | 厂家私有协议 |
| `thirdparty/.../voiceclone` | 厂家能力适配、请求映射、提交、查询和状态归一化 | Repository、积分、作品或 App 业务状态 |
| `admin/*` | 现有管理域的配置、查询和操作入口 | 新建第二套 App/角色/审计体系 |

### 2.3 事务和幂等

- 请求校验、授权快照、任务创建和积分冻结形成可恢复一致性边界。
- 厂家 HTTP 调用不放在数据库长事务中。
- 每个工作流步骤采用短事务和预期状态更新。
- 训练、翻唱、厂家提交、资源转存、作品创建和结算分别有唯一业务键。
- `SUBMIT_UNKNOWN` 禁止自动重新提交，避免重复厂家成本。

---

## 3. 工时与里程碑

### 3.1 Java 主编码

- 主编码 12 小时，即 1.5 个 AI 工作日。
- 后端部署配置 4 小时和真实厂家训练/翻唱 4 小时属于总排期独立阶段。
- 完整三端测试 1.5 天、Bug 修改与回归 1.5 天不计入这 12 小时。

| 里程碑 | 包含任务 | 完成定义 |
|--------|----------|----------|
| B-M1 领域基础 | T-B001-T-B004 | 契约、迁移、音色、素材和审核门禁完成 |
| B-M2 训练闭环 | T-B005-T-B007 | 训练提交、查询、模型/配置/试听持久化并可试听 |
| B-M3 翻唱闭环 | T-B008-T-B011 | 独立接口进入共享流程，成品可播放并正确结算 |
| B-M4 后台可运营 | T-B012 | 模型、价格、音色、审核、任务、作品和资源可管理 |
| B-M5 代码验证 | T-B013 | 定向测试、全量测试、build 和旧业务回归通过 |
| B-M6 真实厂家 | T-B014 | 测试环境真实训练和两类音色翻唱作品可播放 |

---

## 4. 详细任务清单

### 4.1 主编码任务，合计 12 小时

| 任务族 | 骨架任务 | 真实任务 | 模块 | 依赖 | 骨架状态 | 真实状态 |
|--------|----------|----------|------|------|----------|----------|
| `T-B001` | `T-B001-S` | `T-B001-R` | 契约与业务类型 | 技术文档 | `done` | `done` |
| `T-B002` | `T-B002-S` | `T-B002-R` | Migration 与 Entity | T-B001 | `done` | `done` |
| `T-B003` | `T-B003-S` | `T-B003-R` | 音色资料 | T-B002 | `done` | `done` |
| `T-B004` | `T-B004-S` | `T-B004-R` | 素材与审核 | T-B002、T-B003 | `done` | `done` |
| `T-B005` | `T-B005-S` | `T-B005-R` | 训练业务 | T-B003、T-B004 | `done` | `done` |
| `T-B006` | `T-B006-S` | `T-B006-R` | Provider 抽象 | T-B001 | `done` | `done` |
| `T-B007` | `T-B007-S` | `T-B007-R` | 算道训练 | T-B005、T-B006 | `done` | `done` |
| `T-B008` | `T-B008-S` | `T-B008-R` | 翻唱公开接口 | T-B003-T-B006 | `done` | `done` |
| `T-B009` | `T-B009-S` | `T-B009-R` | 翻唱工作流 | T-B008 | `done` | `done` |
| `T-B010` | `T-B010-S` | `T-B010-R` | 成品闭环 | T-B009 | `done` | `done` |
| `T-B011` | `T-B011-S` | `T-B011-R` | 作品生命周期 | T-B010 | `done` | `done` |
| `T-B012` | `T-B012-S` | `T-B012-R` | Admin API 契约 | T-B003-T-B011 | `done` | `done` |
| `T-B013` | `T-B013-S` | `T-B013-R` | 双阶段自动化测试 | T-B001-T-B012 | `done` | `done` |

`T-B002-S` 只定义持久化边界和后续调用接口，不创建 Migration/Entity/Repository；所有表结构、审核、积分、Provider 和作品闭环均属于对应 `-R`。

### 4.2 配置和真实厂家，另计 8 小时

| 任务族 | 骨架任务 | 真实任务 | 模块 | 依赖 | 骨架状态 | 真实状态 |
|--------|----------|----------|------|------|----------|----------|
| `T-B014` | `T-B014-S` | `T-B014-R` | 配置门禁与真实联调 | T-B013 | `done` | `waiting_review` |

`T-B014-S` 只验证 local/test 固定模式可启用、生产默认关闭和配置缺失时拒绝伪成功；迁移、算道账号、真实训练/翻唱及积分核对全部属于 `T-B014-R`。

T-B014 的等待厂家、余额、网络或审核服务时间不计入 AI 工时，但必须记录为阻塞，不能跳过后宣称交付完成。

---

## 5. API 接口任务表

| 任务 ID | 接口 | 方法 | 路径 | 依赖表/能力 | Service | 状态 |
|---------|------|------|------|-------------|---------|------|
| T-B001 | 声音翻唱配置 | GET | `/api/song-config/voice-cover` | app config、模型能力 | `SongVoiceCoverConfigService` | `pending` |
| T-B001 | 训练模型列表 | GET | `/api/song-config/models?sceneCode=song.voice.train` | 现有模型/映射/选项/价格 | 现有配置 Service | `pending` |
| T-B001 | 翻唱模型列表 | GET | `/api/song-config/models?sceneCode=song.voice.cover.generate` | 现有模型/映射/选项/价格 | 现有配置 Service | `pending` |
| T-B003 | 音色列表 | GET | `/api/song-voices?scope=MY|OFFICIAL` | voice profiles/versions/models/bindings | `SongVoiceProfileService` | `pending` |
| T-B003 | 音色详情 | GET | `/api/song-voices/{id}` | 同上、受控试听 | `SongVoiceProfileService` | `pending` |
| T-B003 | 新建音色资料 | POST | `/api/song-voices` | profiles/versions/moderation | `SongVoiceProfileService` | `pending` |
| T-B003 | 更新音色资料 | PATCH | `/api/song-voices/{id}` | profile versions、revision | `SongVoiceProfileService` | `pending` |
| T-B003 | 删除音色 | DELETE | `/api/song-voices/{id}` | profiles/models/bindings | `SongVoiceProfileService` | `pending` |
| T-B004 | 绑定训练素材 | POST | `/api/song-assets/voice-materials` | song assets/resources/moderation | `SongVoiceMaterialService` | `pending` |
| T-B004 | 绑定翻唱源歌曲 | POST | `/api/song-assets/voice-cover-sources` | song assets/resources/moderation | `SongVoiceSourceService` | `pending` |
| T-B004 | 素材状态 | GET | `/api/song-assets/{id}` | 现有 asset/resource/moderation | 现有 Asset Service | `pending` |
| T-B004 | 审核重试 | POST | `/api/song-assets/{id}/moderation/retry` | moderation records | 现有审核 Service | `pending` |
| T-B004 | 音色素材列表 | GET | `/api/song-voices/{id}/materials` | voice materials/assets | `SongVoiceMaterialService` | `pending` |
| T-B004 | 添加音色素材 | POST | `/api/song-voices/{id}/materials` | voice materials/assets | `SongVoiceMaterialService` | `pending` |
| T-B004 | 移除音色素材 | DELETE | `/api/song-voices/{id}/materials/{materialId}` | voice materials/training lock | `SongVoiceMaterialService` | `pending` |
| T-B005 | 创建训练 | POST | `/api/song-voice-training-tasks` | training/consent/model option/billing | `SongVoiceTrainingService` | `pending` |
| T-B005 | 查询训练 | GET | `/api/song-voice-training-tasks/{id}` | training/model version/binding | `SongVoiceTrainingService` | `pending` |
| T-B008 | 创建翻唱 | POST | `/api/song-voice-covers` | generation task/consent/model/billing | `VoiceCoverApplicationService` | `pending` |
| T-B009 | 查询翻唱 | GET | `/api/song-voice-covers/{id}` | generation/workflow/work | `VoiceCoverApplicationService` | `pending` |
| T-B009 | 活动翻唱 | GET | `/api/song-voice-covers/active` | generation task/workflow | `VoiceCoverApplicationService` | `pending` |
| T-B011 | 作品列表/详情 | GET | 现有 `/api/song-works/**` | works/resources/voice versions | 现有 Work Service | `pending` |
| T-B012 | Admin 音色 | GET/POST/PATCH | `/api/admin/song/voice-profiles/**` | voice domain/moderation | Admin Song Service | `pending` |
| T-B012 | Admin 训练任务 | GET/POST | `/api/admin/song/voice-training-tasks/**` | training/provider calls | Admin Song Service | `pending` |
| T-B012 | Admin 渠道恢复 | POST | `/api/admin/song/voice-provider-bindings/{id}/recover` | binding/provider | Admin Song Service | `pending` |
| T-B012 | Admin 模型与价格 | 复用 | 现有 `/api/admin/ai-*` | model/mapping/option/billing | 现有 AI Admin Service | `pending` |
| T-B012 | Admin 运维/作品/资源 | 复用扩展 | 现有对应接口 | operations/works/resources/audit | 现有 Admin Service | `pending` |

公开接口不新增训练或翻唱取消；训练恢复通过已知任务 ID/音色详情，翻唱恢复使用已确认的 `/active`。

---

## 6. 数据库实施计划

> 本章全部属于真实实现任务 `-R`。`skeleton_coding` 期间数据库改动为无，不创建迁移、Entity 或 Repository。

### 6.1 迁移前检查

1. 使用 `rg --files src/main/resources/db/migration` 获取真实最大版本。
2. 确认当前开发库是否已执行可能冲突的本地迁移。
3. 新版本号只顺延，不修改已执行历史文件。
4. 用空 schema 验证 `common + catsinger`，并检查 narrate 不出现专属表。

### 6.2 Catsinger 专属表

- `catsinger_song_voice_profiles`
- `catsinger_song_voice_profile_versions`
- `catsinger_song_voice_materials`
- `catsinger_song_voice_model_versions`
- `catsinger_song_voice_provider_bindings`
- `catsinger_song_voice_training_tasks`
- `catsinger_song_voice_consent_records`

### 6.3 现有表最小字段

`catsinger_song_generation_tasks`：

- `voice_profile_version_id`
- `voice_model_version_id`
- `voice_provider_binding_id`
- `consent_record_id`
- `provider_accepted_at`
- `deadline_at`

`catsinger_song_works`：

- `voice_profile_version_id`
- `voice_model_version_id`

`content_moderation_records`（common）：

- `manual_result`
- `manual_reviewer_id`
- `manual_reason`
- `manual_reviewed_at`
- `revision`

不得扩展 `catsinger_song_assets` 保存业务状态，不新增通用任务、作品、资源、审核、模型配置或积分表。新表和新列必须写数据库注释；Entity 每个持久化字段必须写中文注释。

### 6.4 数据验证

- narrate：有 common 表和 narrate 表，没有 `catsinger_song_voice_*`。
- catsinger：有 common 表、现有 Catsinger 表和 V2.1 专属表。
- Flyway 重启幂等，不重复种子数据。
- 新索引支持用户音色、官方音色、活动训练、渠道绑定和幂等查询。
- 旧歌曲、AI 改编任务与作品无需回填声音克隆字段。

---

## 7. 工作流、计费和资源实施计划

### 7.1 训练

```text
校验资料和素材审核
  -> 校验真实模型与报价
  -> 保存授权和训练任务
  -> 冻结积分
  -> 容量排队
  -> 厂家提交/轮询
  -> 模型、配置、试听转存
  -> 试听探测和审核
  -> 建立渠道绑定
  -> AVAILABLE
  -> 确认扣减
```

失败释放积分；提交结果不确定进入 `SUBMIT_UNKNOWN`，不自动重提。

### 7.2 翻唱

```text
VoiceCoverApplicationService 专属校验
  -> 固定内部 VOICE_COVER
  -> 共享任务创建和积分冻结
  -> 平台容量排队
  -> 厂家确认接单并记录 providerAcceptedAt/deadlineAt
  -> 主动轮询
  -> 下载临时结果并平台持久化
  -> 探测实际格式和可播放性
  -> 输出内容审核
  -> 创建/更新现有作品
  -> 积分结算
```

任务成功条件是完整链路完成，不是厂家状态成功。

### 7.3 资源规则

- 输入使用站内资源 ID 或作品 ID，不接受公开外部 URL。
- 对厂家只提供短期受控输入地址。
- 厂家模型、配置、试听和成品全部转存。
- 保存真实 MIME、后缀、大小和时长，不固定 MP3。
- 训练素材最长 30 天；作品第 15 天隐藏、第 30 天物理清理。
- 清理前检查运行中任务、模型和作品引用。

---

## 8. 测试与发布前验证

### 8.1 定向测试

| 模块 | 必测 |
|------|------|
| 契约 | 独立接口、无 mode、真实 provider/model、错误码 |
| Schema | common/catsinger 归属、迁移重启、索引和注释 |
| 音色 | owner、官方发布、版本、删除、不可用和渠道绑定 |
| 素材 | 格式、签名、MIME、100MB、时长、审核和受控访问 |
| 训练 | 授权、报价、幂等、冻结、成功、失败、未知提交和重训 |
| 翻唱 | 来源 XOR、绑定一致性、平台排队、接单起算、10 分钟和恢复 |
| 输出 | 临时 URL、转存、真实格式、损坏文件、审核、作品和结算 |
| Admin | App 切换、角色、人工复核 revision、操作审计 |
| 回归 | `/api/song-generations`、`/api/song-covers`、旧作品和旧计费 |

### 8.2 命令

```bash
./gradlew test --tests '*VoiceCover*'
./gradlew test --tests '*VoiceTraining*'
./gradlew test --tests '*SchemaRouting*'
./gradlew test
./gradlew build
git diff --check
```

只格式化本轮文件。全量测试失败时区分本轮回归和既有失败，并给出复现证据，不能直接忽略。

### 8.3 真实环境门禁

- 算道测试账号和额度可用。
- 两个场景映射到真实模型，价格、容量和超时可查询。
- OSS/本地存储和内容审核可用。
- 本人音色训练后试听实际可播放。
- 本人音色和官方音色各生成一首整曲。
- 成品已转存、审核、进入作品并在 App 播放器进度连续增长。
- 成功任务积分确认，失败任务积分释放，重复提交不重复冻结。

---

## 9. 第 12 步模块开发文档列表

后续必须在 `04-后端/v2.1-ai-cover-voice-clone/开发计划/` 生成：

| 顺序 | 文件 | 覆盖任务 |
|------|------|----------|
| 00 | `00-module-index.md` | 总依赖、状态、恢复点和验证矩阵 |
| 01 | `01-contract-types-errors.md` | T-B001 |
| 02 | `02-schema-entities-repositories.md` | T-B002 |
| 03 | `03-voice-profile-versions.md` | T-B003 |
| 04 | `04-assets-moderation-retention.md` | T-B004 |
| 05 | `05-training-domain-billing.md` | T-B005 |
| 06 | `06-voice-provider-abstraction.md` | T-B006 |
| 07 | `07-suandao-training-persistence.md` | T-B007 |
| 08 | `08-voice-cover-api-command.md` | T-B008 |
| 09 | `09-voice-cover-workflow-timeout.md` | T-B009 |
| 10 | `10-output-persistence-moderation-settlement.md` | T-B010 |
| 11 | `11-works-playback-lifecycle.md` | T-B011 |
| 12 | `12-admin-api-permissions.md` | T-B012 |
| 13 | `13-java-tests-regression.md` | T-B013 |
| 14 | `14-deployment-provider-e2e.md` | T-B014 |

每份文档必须写明：现状代码、目标、非目标、Controller/Service/Mapper/Entity/Migration/Test、接口与表字段、状态转换、事务、幂等、异常、配置、逐步实现、验证命令、完成定义和回滚边界。

---

## 10. 编码约束

- 使用构造器注入；Controller 只做协议层工作。
- DTO、VO、Entity 分离；公开类和公开方法写中文 Javadoc。
- SQL 只通过 Mapper/Repository 参数化执行，不在 Service 拼 SQL。
- Entity 所有持久化字段写注释；Migration 新表和列写数据库注释。
- 外部请求设置连接、读取和总超时；厂家密钥、签名 URL、原始音频和授权文本不写日志。
- 数据库是任务状态真源；Redis 只作锁、限流和调度协助。
- 工作流更新使用预期状态或版本，防止过期执行器覆盖。
- 厂家 Provider 不得调用积分、审核、作品 Repository。
- 不修改历史 Flyway，不回退既有未提交代码。
- 不为赶进度跳过安全审核、资源转存、可播放探测或失败释放。

---

## 11. 风险与回滚

| 风险 | 处理 |
|------|------|
| 算道字段与资料不一致 | 保存脱敏原始摘要并归一化未知状态，必要时阻塞真实联调 |
| 厂家无可靠提交幂等 | 使用 `SUBMIT_UNKNOWN`，禁止自动重提 |
| 模型无法跨渠道迁移 | 音色版本按渠道绑定，不把默认模型切换当自动迁移 |
| 输出格式变化 | 以实际探测为准，资源和作品记录真实类型 |
| 持久化或审核超过 deadline | 任务超时失败并补偿，不先创建可见作品 |
| 现有共享文件有其他改动 | 读取并融合，不重置；必要时缩小改动到新 SPI/新步骤 |
| Migration 已被其他任务占号 | 编码前重扫并顺延版本，不改历史文件 |

回滚策略：

- 关闭两个新场景和专属入口，停止接收新训练/翻唱任务。
- 运行中任务继续由现有工作流收敛，不直接删数据。
- 新表和可空关联字段保留，禁止生产回滚时删除历史训练、授权和作品证据。
- AI 写歌、AI 改编和旧作品无迁移，因此不需要业务回填回滚。

---

## 12. 总体验收标准

- [ ] T-B001-T-B014 与技术文档任务一一对应。
- [ ] API 表覆盖 Flutter 当前依赖，方法和路径无冲突。
- [ ] 新请求没有 mode，服务端固定 VOICE_COVER，厂家模型字段真实。
- [ ] `voicecover/` 与 `cover/` 独立，但不复制通用底座。
- [ ] 数据库只增加声音克隆独有事实和最小关联字段。
- [ ] 平台排队不计时，厂家接单后 10 分钟规则可测试。
- [ ] 图片、音频、文字、试听和成品都进入现有审核体系。
- [ ] 临时 URL 已转存，输出格式按真实探测，损坏文件不能成功。
- [ ] 积分报价、冻结、结算、释放和幂等完整。
- [ ] Admin 配置、权限、任务、作品、资源和人工审核完整。
- [ ] AI 写歌和 AI 改编回归零差异。
- [ ] 模块开发文档未完成前不进入编码。

---

## 13. 执行记录

| 日期 | 动作 | 结果 |
|------|------|------|
| 2026-09-09 | 读取当前 PRD、技术方案、工时、Flutter/Java 技术文档和 Java 实际基线 | 确认独立公开接口/业务目录与共享底层流程；发现既有未提交改动并登记保护边界 |
| 2026-09-09 | 对齐前后端接口 | PATCH 音色更新、`/moderation/retry` 和训练任务恢复方式已与技术方案统一 |
| 2026-09-09 | 生成 Java 总体开发计划 | 状态 `waiting_review`；未生成模块文档，未修改 Java 业务代码 |
| 2026-09-09 | 用户要求继续下一步，进入第 12 步 | 总体计划标记 `done`；`开发计划/00-14` 共 15 份 Java 模块开发文档已生成并进入 `waiting_review`，未修改 Java 代码 |
| 2026-09-09 | 用户明确确认骨架并授权真实实现 | 完成 T-B001-R 至 T-B013-R；12 个关键类 78 项测试与追加上传/业务集成 92 项通过，`build -x test` 通过；T-B014-R 等待迁移、配置和真实算道闭环 |

Java 本地真实实现当前为 `waiting_review`。只有目标环境迁移、真实模型/价格配置、本人音色训练、翻唱成品持久化审核及可播放验证全部通过后，T-B014-R 才能标记 `done`。
