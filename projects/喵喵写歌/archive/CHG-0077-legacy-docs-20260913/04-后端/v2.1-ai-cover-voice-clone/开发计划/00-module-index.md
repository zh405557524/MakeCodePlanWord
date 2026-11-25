# V2.1 Java 模块开发索引

> 版本：`v2.1-ai-cover-voice-clone`
> 变更：`CHG-0073`
> 状态：`waiting_review`
> 实现策略：`skeleton_first`
> 当前实现阶段：`real_review`
> 骨架目标：`flutter,java`
> 总体计划：`../java-dev-plan.md`
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 目标与边界

本目录是翻唱声音克隆 Java 编码前的唯一模块级执行输入。新业务在 `app/catsinger/voicecover/` 中拥有音色、训练、渠道绑定和专属编排，但继续复用现有歌曲任务、工作流、模型、积分、资源、审核、作品和 Admin 基础设施。

现有 AI 写歌 `/api/song-generations`、AI 改编 `/api/song-covers` 和 `app/catsinger/cover/` 零修改语义。

## 2. 模块顺序

| 顺序 | 文档 | 骨架任务 | 真实任务 | 依赖 | 当前状态 |
|------|------|----------|----------|------|----------|
| 01 | `01-contract-types-errors.md` | T-B001-S | T-B001-R | 技术文档 | done |
| 02 | `02-schema-entities-repositories.md` | T-B002-S | T-B002-R | 01 | done |
| 03 | `03-voice-profile-versions.md` | T-B003-S | T-B003-R | 02 | done |
| 04 | `04-assets-moderation-retention.md` | T-B004-S | T-B004-R | 02、03 | done |
| 05 | `05-training-domain-billing.md` | T-B005-S | T-B005-R | 03、04 | done |
| 06 | `06-voice-provider-abstraction.md` | T-B006-S | T-B006-R | 01 | done |
| 07 | `07-suandao-training-persistence.md` | T-B007-S | T-B007-R | 05、06 | done |
| 08 | `08-voice-cover-api-command.md` | T-B008-S | T-B008-R | 03-06 | done |
| 09 | `09-voice-cover-workflow-timeout.md` | T-B009-S | T-B009-R | 08 | done |
| 10 | `10-output-persistence-moderation-settlement.md` | T-B010-S | T-B010-R | 09 | done |
| 11 | `11-works-playback-lifecycle.md` | T-B011-S | T-B011-R | 10 | done |
| 12 | `12-admin-api-permissions.md` | T-B012-S | T-B012-R | 03-11 | done |
| 13 | `13-java-tests-regression.md` | T-B013-S | T-B013-R | 01-12 | done |
| 14 | `14-deployment-provider-e2e.md` | T-B014-S | T-B014-R | 13 | waiting_review（部署与真实厂家） |

## 3. 依赖图

```text
01 契约 ── 02 数据 ── 03 音色 ── 04 素材审核 ── 05 训练业务
    └──────────────── 06 Provider ── 07 算道训练
03-07 ── 08 翻唱门面 ── 09 工作流 ── 10 成品闭环 ── 11 作品
03-11 ── 12 Admin
全部代码 ── 13 自动化验证 ── 14 部署配置和真实厂家联调
```

## 4. 全局技术约束

- 所有用户接口继续校验 `X-App-Code: catsinger`、Token appCode 和资源 owner。
- `CreateSongVoiceCoverRequest` 不含 `mode`；Controller 在服务端固定内部 `VOICE_COVER`。
- `provider/model` 是真实厂家编码；业务类型、sceneCode 和展示名不得写入 model。
- Provider 只做厂家协议映射和状态归一化，不访问 Repository、积分、审核或作品。
- 外部调用不置于长事务；工作流采用短事务、幂等落结果和现有租约。
- 厂家接单并返回可查询任务 ID 后才写 providerAcceptedAt/deadlineAt；平台排队不计入 10 分钟。
- 厂家临时 URL 必须平台持久化、真实格式探测、输出审核并通过服务端可播放门禁后才能创建成功作品和结算。
- 数据迁移按真实最大版本顺延，只在 common/catsinger 对应目录新增，不改历史 Flyway。
- Entity 持久化字段逐字段注释，Controller/DTO/Entity/Repository 边界遵循现有工程。

## 5. 编码恢复规则

1. 编码前读取本索引、目标模块文档、Java 技术文档及对应 Flutter 模块文档。
2. Flutter/Java 骨架已经用户确认，T-B001-R 至 T-B013-R 已完成本地编码与定向验证。
3. 记录 Java 分支、commit 和 dirty diff；现有未提交修改一律保留并协同处理，尤其不得覆盖线上 Bug 修复。
4. 当前进入 `real_review`；T-B014-R 只有在目标环境完成迁移、模型/价格配置和真实厂家闭环后才能标记 `done`。
5. 新字段、新接口或厂家能力与文档不符时先登记 CHG 并回卷契约。
6. Flutter/Java 所有骨架完成后统一进入 `skeleton_review`；明确确认前不得执行 `-R`。
7. Mock 通过不代表真实 Provider、迁移、配置或作品可播放验收通过。

## 7. 真实实现记录

- Java 基线：`dev @ 45f0fd2e`，保留进入任务前已有未提交修改。
- 已新增 `voicecover/` 独立领域、7 张 catsinger 专属表、公开 `/api/song-voice-covers`、音色资料/素材/训练、算道 Provider、共享歌曲工作流步骤、积分幂等、审核、资源持久化、作品及 Admin API。
- `VOICE_COVER` 不提供公开 `mode` 映射；通用 `/api/song-generations` 无法创建该类型，新门面在服务端固定业务类型并校验真实 `provider/model`。
- 12 个关键测试类共 78 项通过；追加源音频上传与业务集成 92 项通过；`./gradlew build -x test` 和 `git diff --check` 通过。
- 全量 Java 测试本轮未重跑；已知既有基线受会员时间边界和后续 JVM 内存级联失败影响，不能据此宣称全量回归通过。
- 目标环境尚未执行 V4.8/V4.9 迁移、模型/价格/音色配置和真实算道训练/翻唱；T-B014-R 保持待验收。

## 6. 总体验收

- 15 份模块文档与 T-B001-S/R 至 T-B014-S/R 完整对应。
- 用户端与 Flutter 模块契约一致，Admin 接口复用当前管理域。
- 7 张专属表及现有表最小扩展均有业务理由和测试。
- AI 写歌、AI 改编、旧作品和积分流程纳入回归。
- 真实本人音色训练、本人/官方音色翻唱和作品可播放完成前不得宣称交付完成。
