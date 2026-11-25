# V2.1 Java 模块开发索引

> 2026-09-14 执行结果：B001～B009 已完成本地真实实现并进入 `real_review`；全量 Java 1956 项测试通过。目标环境的迁移、算道账号/场景/计费配置及真实训练翻唱仍未验收，以下 `-S` 状态和旧骨架门禁段落仅作历史记录。

> 版本 `v2.1-model-driven-params` · CHG-0076/0078 第 14 步 `waiting_review`、第 15 步 `in_progress` · 2026-09-14。依据[总体计划](../java-dev-plan.md)、[Java 技术文档](../java-tech.md)、[当前 PRD](../../01-需求/requirements.md)和[Flutter 模块索引](../../03-前端/开发计划/00-module-index.md)。[旧版 Java 模块](../../archive/CHG-0077-legacy-docs-20260913/04-后端/)仅 `reference-only`。

## 模块执行顺序

以下状态是用户授权前的骨架快照：`T-B001-S=done`、`T-B002-S=in_progress`，其余当时 `pending`。当前真实实现进度以本文首页执行覆盖和 `workflow.md` 为准；本轮新增 Catsinger 专属 V4.10 迁移，未部署。

| 顺序 | 模块文档 | 任务 | 关键产物 / 依赖 |
|------|----------|------|-----------------|
| 1 | [Provider 精确能力](01-provider-capabilities.md) | B001-S/R | 四操作、真实模型硬限制、未知 `NOT_DECLARED` |
| 2 | [有效契约与模型目录](02-effective-contract.md) | B002-S/R | 厂家与后台交集、原因、版本、公开响应/脱敏；依赖 B001 |
| 3 | [写歌与改编](03-song-and-adaptation.md) | B003-S/R | 两入口创建前参数/互斥复核，旧改编不改型；依赖 B002/B006 |
| 4 | [本人音色训练](04-voice-training.md) | B004-S/R | 素材厂家硬条件、效果建议、本人/审核；依赖 B001/B002/B006 |
| 5 | [声音克隆翻唱](05-voice-clone-cover.md) | B005-S/R | 音色精确兼容、整曲、可选设置、独立接口；依赖 B001/B002/B006 |
| 6 | [价格与不可变快照](06-pricing-snapshot.md) | B006-S/R | 当前价/能力版本、幂等和冻结前拒绝；必要迁移须先有证据 |
| 7 | [Admin 与安全](07-admin-and-security.md) | B002/B006 配套 | 后台合法收窄、App/角色与资源安全，无新业务体系 |
| 8 | [验证与 QA 移交](08-verification.md) | B001～B006 | 契约、骨架生产禁用、四业务回归与成品可播放 |

第 6 项 B006 的定价/版本校验应在第 3～5 项真实实现前准备好；文档阅读顺序不等于编码可忽略依赖。每份子文档分别列 `T-Bxxx-S` 和 `T-Bxxx-R`、正式接口与响应、现有表/迁移判定、Controller → Service → Provider/旧平台调用、失败边界和测试。公共代码改动先核对其他 App 和旧客户端，不修改 narrate schema。

## CHG-0078 首页配置与新人权益增量（真实实现进行中）

本专区承接[CHG-0078 Java 总体计划第 9 节](../java-dev-plan.md)、[当前 PRD P01/W08/W09](../../01-需求/requirements.md)和[Java 技术文档第 9 节](../java-tech.md)。原 B001～B006 进度不变；B007～009 的 `-R` 已接入真实配置/审核/状态存储，定向测试通过，部署及跨端验收未做。下表 `-S` 为历史快照。

| 顺序 | 模块文档 | 任务与状态 | 数据/依赖 |
|------|----------|------------|-----------|
| 9 | [首页海报与共校验](09-home-banners.md) | B007-R `in_progress`；S 为历史 | Catsinger `app_configs`、审核资源、Admin 专用/通用入口同验；无新表 |
| 10 | [新账号赠额](10-new-user-points.md) | B008-R `in_progress`；S 为历史 | 原建号赠额与 `NEW_USER:{userId}`；坏配置回退 30、DB 故障不兜底；无新表 |
| 11 | [新人礼资格/频次](11-new-user-gift-state.md) | B009-R `in_progress`；S 为历史 | Catsinger-only V4.10 迁移未部署；领取不发积分 |
| 12 | [后端与跨端验证](12-home-benefit-verification.md) | T-Q002 `pending` | local/test 骨架隔离；真实配置、Android/iOS 新账号双证据 |

前端对应[新增 09～13 模块](../../03-前端/开发计划/00-module-index.md)。原 `skeleton_coding` 只作历史记录；本版已获用户明确授权跳过骨架评审并执行 `-R`。本 CHG 不触碰旧歌曲/改编/克隆 API 或旧积分流水。

## 共用业务与历史骨架边界

- AI 写歌 `/api/song-generations`、歌曲改编 `/api/song-covers`、翻唱声音克隆 `/api/song-voice-covers` 是三项独立业务；本人音色训练走 `/api/song-voice-training-tasks`。声音克隆公开请求无 `mode`，服务端固定 `VOICE_COVER`；旧改编 `COVER` 不迁移、不改名、不改型。四场景共用现有任务、审核、积分、资源和作品流程。
- 原 `skeleton_first / skeleton_coding` 是用户授权前的历史状态；当前以 `workflow.md` 的 `direct_implementation / real_coding` 为准，未完成的 `-S` 不伪记为 done。
- `-S` 只建/扩正式 DTO/VO、Controller、Service 高层步骤与集中 Skeleton Fixture；可编译调用链只在 local/test 返回确定值。禁止 Flyway、Entity、Repository/Mapper、真实数据库/积分/审核/上传/Provider/轮询/转存/作品副作用。现有生产路径保持原状；生产默认关闭新增未完成功能，不得伪造成功。
- `-R` 已获本版明确授权；优先接精确厂家能力、合成契约、Admin 合法配置、创建前复核，再接原平台副作用和联调。local/test Fixture 保持生产禁用，不能用它证明真实业务成功。
- 训练、生成或翻唱的 200/任务成功不等于交付成功：第三方临时资源须沿现有台账转存、审核且在目标设备真实可播放。整 App `v1.2.0+121-as-built` QA 并行，不把其旧 PASS 当本版验收。

## 模块共用接口契约

| 场景 | 公开模型目录 | 创建与查询 | 当前鉴权 |
|------|--------------|------------|----------|
| 写歌 | `GET /api/ai-model-options?sceneCode=song.generate` | `POST /api/song-generations`、`GET /api/song-generations/{id}` | `X-App-Code: catsinger`，创建/查询用户 JWT |
| 改编 | `GET /api/ai-model-options?sceneCode=song.cover.generate` | `POST /api/song-covers`、`GET /api/song-covers/{id}` | 同上 |
| 训练 | `GET /api/song-config/models?sceneCode=song.voice.train` | `POST /api/song-voice-training-tasks`、`GET /api/song-voice-training-tasks/{id}`、`/active` | 同上 |
| 克隆 | `GET /api/song-config/models?sceneCode=song.voice.cover.generate` | `POST /api/song-voice-covers`、`GET /api/song-voice-covers/{id}`、`/active` | 同上 |
| 后台 | 现有 `/api/admin/ai-scene-model-mappings` 及模型/价格/音色/任务/作品接口 | 读/保存/审核沿现有方法 | Admin token、`X-App-Code`、角色管理块 |

目标响应与[Flutter 契约模块](../../03-前端/开发计划/01-contract-and-fixture.md)一致：保留 `operationType/status/parameters`，增量 `contractVersion/effectiveParameters/mediaConstraints`；声音模型追加同义 `musicContract`。`contractVersion` 与 `pricingVersion` 独立。字段级错误使用现有 `ApiResponse/ErrorCode` 类别，详细响应/错误归对应模块；任何新公开字段先回卷本版技术文档，不在模块里单独发明。

当前恢复点：B001～009 本地真实实现完成，`./gradlew test` 全量 1956 项、0 失败、0 错误、3 跳过；此前 15 条旧回归已修复。算道 `sovits_train/sovits_cover` 请求、查询和动态输出字段已与适配器对账，作品音轨按转存后的真实格式落快照。测试环境仍缺真实算道 Token、声音场景映射、计费和验证短句，目标迁移、资源转存、审核、积分及最终可播放闭环未验收。详见[阶段验收记录](../../05-联调与测试/v2.1-voice-clone-ui-and-provider-audit-20260914.md)。
