# B006 报价、幂等与不可变快照

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `waiting_review`；`T-B006-S/R` 均 `pending`。依据[总体计划](../java-dev-plan.md)、[技术方案](../../02-技术方案/v2.1-model-driven-params/tech-plan.md)和[B002 有效契约](02-effective-contract.md)。

## 骨架阶段 / `T-B006-S`

- 在现有 Catsinger 价格/积分/任务 Service 周围明确 `loadEffectiveContract` → `validateSubmittedParameters` → `loadCurrentPrice` → `verifyVersions` → `reservePoints` → `persistTaskSnapshot` 的调用边界。写歌、改编、训练、克隆四场景复用该平台链路，但保留各自业务类型和 Controller。
- 正式 DTO/VO 分别携带 `contractVersion`（能力/后台配置）和 `pricingVersion`（价格），不可合成同一字段；旧客户端缺前者时服务端仍重验。集中 Fixture 在 local/test 返回确定的 100/200 积分示例值，绝不代表正式价格；生产配置不能使用 Fixture 或假冻结结果。
- `T-B006-S` 只建可运行高层步骤与契约测试，所有真实冻结、退款、数据库/Entity/Mapper、资源/厂家调用标 `TODO(REAL-IMPLEMENTATION)`；不建迁移。验证“校验失败在任何副作用之前”及同一幂等键不进入重复创建流程。

## 真实实现阶段 / `T-B006-R`

1. 从现有后台模型/计费配置读取价格和当前 `pricingVersion`；检查模型已启用、业务适用、用户权益及余额。未配置价格时返回暂未开放，不用固定示例值。若以后价格依参数组合变化，先回卷 PRD/技术方案，再增加正式报价契约。
2. 使用同一有效契约重新验证厂家硬能力、后台合法子集和用户提交的最小参数；无效/过期 `contractVersion`、过期 `pricingVersion` 在冻结前给可恢复错误。并发提交用现有幂等键约束，重复请求返回同一任务/结果，不重复冻结。
3. 仅在校验成功后沿现有积分账户/流水冻结；保存实际业务类型、具体 `provider/model`、所选音色/来源、有效参数、契约版本、价格版本与金额的**任务创建时快照**。后续后台调价/关模型不得重算进行中的任务或改变历史作品类型。
4. 成功以既有审核及资源可播放门禁确认扣减；提供商失败、审核失败、超时或持久化失败走同一补偿链路释放/退还，不发生双退。排队与厂商接单后的处理时限分别记录，不用排队时间触发厂商超时。
5. **迁移证据门禁**：先核查既有任务 `request_json`/模型、计费及 workflow-step 快照是否足以还原上述事实；若足够，零迁移。确有缺失才新增 `db/migration/catsinger/` 的最小追加版本及回填/兼容测试；不改 V1/V12、common、narrate，也不凭计划预建表。

## 数据、错误与验收

触及现有 `catsinger_song_generation_tasks`、歌曲/训练/克隆任务、`point_accounts`、`point_ledgers`、计费配置与工作流步骤；跨表事务边界沿原 Service。公开接口是四项业务现有创建/查询路径，不发明 `/quote` 或第二套订单接口。失败返回既有 `ApiResponse/ErrorCode`，例如模型禁用/参数无效、`VOICE_QUOTE_EXPIRED`、积分不足、重复请求和任务失败；须有字段级原因供 App 恢复，错误里不回显厂家密钥或私人资源地址。

测试矩阵：四业务 × 支持/未知/禁用模型 × 价格当前/过期 × 幂等首发/重复/并发 × 冻结成功/失败/审核失败/资源转存失败；断言冻结/扣减/释放次数、任务快照不可变、后台调价后旧任务不变、跨 App 隔离及旧客户端缺版本字段时的重验。第 15 步仍需移动端真实作品可播放与积分可观察结果，定向 Service 测试不代替用户验收。
