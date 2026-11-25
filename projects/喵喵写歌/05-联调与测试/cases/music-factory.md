# CHG-0033 AI 音乐内容工厂 QA 与验收矩阵

> 路径恢复：2026-07-31 从错误工作区别名 `catsinger` 迁入；本文 CHG 已按 `旧编号 + 14` 重编号，原文保存在 `archive/path-recovery-20260731/`。

> 日期：2026-07-21
> Python 工程：`/Users/soul/code/lxwx/lxwx_music_factory`
> 当前说明：本地 `.env`、独立 PostgreSQL/Redis 和迁移已就绪；运营账号自动登录/续期与环境诊断反馈已完成自动化。正式控制面、账号解冻和积分已就绪，真实单曲仍需在首次提交时验证 Provider/Model 配额。

## 1. 当前自动化结果

以下结果来自业务标签自动化实现后的完整 Python 工程：

- `uv run pytest`：113 项通过。
- `uv run ruff check .`：通过。
- `uv run ruff format --check .`：通过。
- `uv run python -m compileall -q src tests`：通过。
- Alembic SQLite `upgrade head → downgrade base → upgrade head`：通过。
- `alembic check`：无待生成迁移。

当前自动化覆盖采集与方案幂等、严格类型/数据库长度、全部生成可见字段版权隔离、标签预检/禁用创建/续跑、显式列表阻断、滑动窗口、整批生成屏障、部分发布后重新审核、部分激活后的绑定重试核验失效、首页条目不确定响应恢复、Java 不可用作品过滤、兼容回退相对顺序、公开后 Admin 二次快照、新标签最终启用、公开反查及跨批次异常隔离。

模拟主流程为：

```text
collection-import
→ plan-import
→ batch-create
→ prepare
→ start
→ GENERATION_COMPLETE
→ WAITING_REVIEW
→ approve-publish
→ BINDING
→ COMPLETED
```

## 2. 验收状态定义

| 状态 | 含义 |
|---|---|
| `AUTOMATED_PASS` | 已有自动化测试通过 |
| `PARTIAL_AUTOMATION` | 核心行为已覆盖，仍有补充故障注入场景 |
| `TODO_AUTOMATION` | 尚未自动化覆盖 |
| `TODO_REAL_ENV` | 需要真实 Catsinger Token、积分和 Provider 配额联调 |
| `NOT_APPLICABLE` | 明确不进入本变更代码范围 |

## 3. P0 验收矩阵

| ID | 能力 | 场景/操作 | 预期结果 | 验收方式 | 当前状态 |
|---|---|---|---|---|---|
| P0-01 | Codex-1 | 导入只包含公开榜单字段的采集包 | 只创建 `CollectionBatch`，不分析、不建标签、不生成歌曲 | pytest + CLI | `AUTOMATED_PASS` |
| P0-02 | Codex-1 | 采集包包含歌词、音频、旋律、指纹或媒体下载地址 | Schema 拒绝，且无外部调用 | pytest | `AUTOMATED_PASS` |
| P0-03 | Codex-2/3 | 榜单分组引用未知 collection 或榜单记录 | `plan-import` 返回稳定引用错误，不创建生产批次 | pytest | `AUTOMATED_PASS` |
| P0-04 | Codex-4 | 合法歌曲方案包含唯一 planSongId、原创 prompt、styleTags 和 tagCodes | 严格导入为不可变 `ProductionPlanDocument`，不触发 Java/Admin | pytest + CLI | `AUTOMATED_PASS` |
| P0-05 | 方案幂等 | 相同 planId、相同内容重复导入 | 返回原 plan 记录，不重复写入 | pytest | `AUTOMATED_PASS` |
| P0-06 | 方案冲突 | 相同 planId 使用不同内容 | 拒绝并要求新 planId | pytest | `AUTOMATED_PASS` |
| P0-07 | 严格 Schema | 方案含未知字段、字符串数字/布尔、超长任务 ID、歌词/参考音频、正向模仿要求或 home-list 字段 | 导入失败；无 Java/Admin 外部调用 | pytest | `AUTOMATED_PASS` |
| P0-08 | 三层语义 | styleTags 为古风/治愈，tagCodes 为 guofeng | 两组字段分别保存；Python 不由 styleTags 推导、创建或扩展 tagCodes | pytest | `AUTOMATED_PASS` |
| P0-09 | 三层语义 | 方案歌曲引用未在 businessTags 或对应 sourceGroup 声明的 tagCode | 方案导入失败 | pytest | `AUTOMATED_PASS` |
| P0-10 | 标签复用 | `hot_song` 已启用但后台名称为“热门歌曲”、计划名称为“热歌” | 按 tagCode 复用，记录名称警告，不修改后台标签 | pytest | `AUTOMATED_PASS` |
| P0-11 | 标签创建 | 目标标签缺失，其他目标标签均无阻断 | 使用现有 Admin POST 以 `enabled=false` 创建；第一个生成请求前完成 | pytest + MockTransport | `AUTOMATED_PASS` |
| P0-12 | 创建恢复 | 标签 POST 结果不确定，或远端成功后进程立即退出 | 按创建意图与 tagCode 找回，不重复创建 | pytest 故障注入 | `AUTOMATED_PASS` |
| P0-13 | 标签冲突 | Admin 返回重复 tagCode 或创建结果字段不一致 | 保留 `READY` 并记录错误，不创建歌曲任务请求 | 代码审查 | `PARTIAL_AUTOMATION` |
| P0-14 | 预先禁用标签 | 目标标签已禁用且不是本批次创建 | 保留 `READY` 并记录错误，Python 不接管、不启用、不生成 | pytest | `AUTOMATED_PASS` |
| P0-15 | 续跑标签 | 本批次先前创建的标签保持 disabled | 识别为合法准备事实，不阻断、不重复创建 | pytest | `AUTOMATED_PASS` |
| P0-16 | 显式列表阻断 | 任一目标 tagCode 的 home-list 为 `persisted=true` | 在第一条真实生成请求前停止，批次保留 `READY` | pytest | `AUTOMATED_PASS` |
| P0-17 | 禁止列表写入 | 查询列表与完整模拟生产 | 后端协议无列表写方法，请求中没有 home-list PUT | MockTransport + 代码审查 | `AUTOMATED_PASS` |
| P0-18 | 生成启动门禁 | 标签准备未完成时执行 start/resume/reconcile/worker tick | 不推进 `RUNNING`、不认领槽位、不调用 `POST /api/song-generations` | pytest | `AUTOMATED_PASS` |
| P0-19 | 滑动窗口 | 5 首、maxInFlight=3，任一任务完成 | 同时在途不超过 3，完成一首先补下一首；已完成批次不压低其他批次上限 | pytest | `AUTOMATED_PASS` |
| P0-20 | 整批门禁 | 第一首或部分歌曲已成功并有 workId | 只保存单曲结果，不创建任何 home-item，不启用新标签 | pytest | `AUTOMATED_PASS` |
| P0-21 | 整批失败 | 任一歌曲仍在途或永久失败 | 不进入普通审核绑定；永久失败进入 `PARTIAL_FAILED` | pytest | `AUTOMATED_PASS` |
| P0-22 | 整批就绪 | 所有计划歌曲成功、有 workId 且质量检查通过 | 先进入 `GENERATION_COMPLETE`，下一 tick 进入 `WAITING_REVIEW`，仍不创建 home-item | pytest | `AUTOMATED_PASS` |
| P0-23 | 未审核发布 | 对非 `WAITING_REVIEW` 批次执行 approve-publish | 返回 `BATCH_NOT_REVIEWABLE`，无首页条目调用 | pytest + CLI | `AUTOMATED_PASS` |
| P0-24 | 审核后绑定 | 审核整批后执行 worker/tick | 每首歌以稳定 itemCode、WORK/sourceWorkId、原 styleTags 和明确 tagCodes 创建首页条目 | pytest + MockTransport | `AUTOMATED_PASS` |
| P0-25 | 绑定幂等 | home-item POST 返回不确定 5xx/无效 JSON 但后台已创建 | 通过稳定 itemCode 核对恢复，不重复条目 | MockTransport | `AUTOMATED_PASS` |
| P0-26 | 绑定中断 | 部分条目成功、部分失败 | 已成功结果保留，只重试绑定、不重新生成；本批次新标签保持禁用 | pytest 故障注入 | `AUTOMATED_PASS` |
| P0-27 | 新标签启用门禁 | 尚有任一计划歌曲未完成绑定 | 不启用标签，批次不完成 | pytest | `AUTOMATED_PASS` |
| P0-28 | 全部绑定后启用 | 所有选定条目已绑定并核对成功 | 只启用 `createdByBatch=true` 标签；既有标签不修改 | pytest + MockTransport | `AUTOMATED_PASS` |
| P0-29 | 启用恢复 | 标签启用响应不确定，后台事实已启用 | 后续 tick 按事实状态继续，不重复启用或覆盖其他字段 | pytest 故障注入 | `AUTOMATED_PASS` |
| P0-30 | 最终完成 | 条目绑定、新标签启用、公开标签与歌曲反查均成功 | 公开歌曲是最终 Admin 回退顺序的有序有效子序列，且本批至少一首可用歌曲可见后进入 `COMPLETED` | pytest | `AUTOMATED_PASS` |
| P0-31 | 部分发布后重试 | 已发布成功部分，再重试生成失败歌曲 | 清除旧审核/部分授权/公开核验；新结果整批完成后再次进入人工审核与公开反查 | pytest | `AUTOMATED_PASS` |
| P0-32 | 兼容回退旧歌 | 既有启用标签已有旧歌，新批追加歌曲 | 保留旧歌；允许 Java 过滤禁用/不可用旧作品并补位，但公开相对顺序必须与最终 Admin 一致且本批有歌可见，否则保存错误并 `PAUSED` | pytest | `AUTOMATED_PASS` |
| P0-33 | 部分发布后绑定重试 | 已部分激活/核验，一首已有作品的绑定永久失败后重试 | 不重新生成或重复审核；清除旧激活/核验，新增绑定后重新核验全部已发布歌曲 | pytest | `AUTOMATED_PASS` |
| P0-34 | 核验期间显式列表竞态 | 第一次 Admin 快照后出现 persisted list | 公开查询后的 Admin 二次快照发现变化，保存错误并 `PAUSED` | pytest | `AUTOMATED_PASS` |
| P0-35 | 运营用户自动登录 | 未配置静态用户 JWT，但私有 `.env` 有完整运营账号固定凭证 | 首次用户请求先登录；Access/Refresh Token 只保存在内存，请求使用用户 Token | MockTransport | `AUTOMATED_PASS` |
| P0-36 | 长批次用户续期 | 用户请求返回 401，Refresh 成功/失败或账号冻结 | 优先 Refresh；失败后重新登录；原请求最多重放一次；冻结时安全停止且不泄露凭证 | MockTransport | `AUTOMATED_PASS` |

## 4. P1 验收矩阵

| ID | 能力 | 场景/操作 | 预期结果 | 验收方式 | 当前状态 |
|---|---|---|---|---|---|
| P1-01 | 生成字段隔离 | sourceGroups 含榜单引用，采集事实含歌曲名/歌手 | 标题、描述、Prompt、styleTags 及 Java 请求不包含 sourceGroups、来源歌曲名、歌手或正向模仿 | pytest | `AUTOMATED_PASS` |
| P1-02 | 多标签 | 一首歌曲含多个 tagCodes | Schema 保留明确顺序，绑定前去重且不由 styleTags 推导 | pytest | `AUTOMATED_PASS` |
| P1-03 | 运行中漂移 | 生成或公开核验期间运营新增显式列表 | 绑定/公开核验阶段重新读取 Admin 并暂停，不覆盖运营配置；最后一次读取后的理论竞态需由运营冻结或未来 Java 原子版本解决 | pytest + 人工控制 | `PARTIAL_AUTOMATION` |
| P1-04 | 暂停 | 批次有在途任务时 pause | 停止新提交，继续轮询；不提前审核、绑定或启用 | pytest | `AUTOMATED_PASS` |
| P1-05 | 重启恢复 | 标签创建、生成、绑定、启用阶段发生中断 | 从 PostgreSQL 当前步骤继续，无重复外部副作用 | pytest 故障注入 | `AUTOMATED_PASS` |
| P1-06 | Codex 调试 | pause 后修改 Python、跑测试、reconcile、resume | 原批次继续，已完成步骤不重做 | 人工演练 | `TODO_REAL_ENV` |
| P1-07 | 日志脱敏 | 执行 plan-import、start、approve-publish 和 reconcile | 日志无 Token、完整歌词、完整 prompt 或大响应 | pytest + 人工检查 | `PARTIAL_AUTOMATION` |
| P1-08 | 无 OpenAI 依赖 | 不配置 `OPENAI_API_KEY` 执行 doctor 和模拟 E2E | doctor 不报缺少 OpenAI key；全部 Python 功能可运行 | pytest + CLI | `AUTOMATED_PASS` |
| P1-09 | 配额安全 | 平台限制未知 | 环境默认并发为 1；Codex 方案必须显式写 `maxInFlight=1` | pytest + 配置检查 | `AUTOMATED_PASS` |
| P1-10 | 外部工程边界 | 检查本变更差异 | Java、Web/Admin、Flutter 无本变更代码改动；只复用现有 API | git diff + 人工审查 | `NOT_APPLICABLE`，交付时确认 |
| P1-11 | 批次异常隔离 | 一个活动批次在标签启用/公开核验时抛错 | `tick_all` 返回该批错误并继续处理后续批次 | pytest | `AUTOMATED_PASS` |
| P1-12 | 环境诊断反馈 | `doctor` 全部通过，或数据库/Redis/后端/鉴权任一失败 | 成功输出 `ok=true` 和中文总结；失败输出 `ok=false`、问题/建议清单并以退出码 1 结束 | pytest + CLI 故障注入 | `AUTOMATED_PASS` |
| P1-13 | 数据库升级反馈 | 执行 `db-upgrade` 成功或 Alembic 抛错 | 成功明确输出已升级到 `head`；失败返回脱敏类型和 PostgreSQL 配置建议 | pytest + 本地 PostgreSQL CLI | `AUTOMATED_PASS` |

## 5. 模拟端到端验收

已使用独立 SQLite 测试库和模拟 Catsinger 后端完成：

```text
collection-import
→ plan-import（Codex 1–4 形成的 ProductionPlanDocument）
→ batch-create（2 首，1 个新标签，maxInFlight=2）
→ 标签/列表全量预检
→ 缺失标签以 disabled 创建
→ start
→ 第一轮提交 2 首
→ 单曲完成期间 home-item 调用数始终为 0
→ 全部成功后 GENERATION_COMPLETE → WAITING_REVIEW
→ approve-publish
→ 2 个 WORK 首页条目幂等绑定
→ 第 2 个绑定成功前新标签始终 disabled
→ 全部绑定后启用新标签
→ 公开结果保持最终 Admin 兼容回退相对顺序，允许过滤不可用作品，且本批歌曲可见
→ COMPLETED
```

5 首、`maxInFlight=3` 的滑动补位及跨批次全局并发另由调度器测试覆盖。

同时执行阻断分支：

```text
目标标签存在 persisted 显式列表
→ batch-create / 标签预检
→ 保留 READY 并记录 HOME_LIST_EXPLICIT_BLOCK
→ song-generation POST 调用数为 0
→ home-list PUT 调用数为 0
```

## 6. 真实环境联调矩阵

| ID | 场景 | 前置条件 | 预期 | 状态 |
|---|---|---|---|---|
| REAL-01 | 真实歌曲创建与轮询 | 导入 `2026-07-20-hot-song-smoke-v1`，运营账号已解冻且积分充足 | 自动登录，仅生成 1 首，按 `maxInFlight=1` 得到 workId | `TODO_REAL_ENV` |
| REAL-02 | 缺失首页标签禁用创建 | 有效 Admin Token、X-App-Code | 后台可见新标签但保持停用，App 不提前展示 | `TODO_REAL_ENV` |
| REAL-03 | 批次审核后 WORK 条目绑定 | 全批真实作品成功、有效 Admin Token | home-item 的 workId、styleTags、tagCodes 正确 | `TODO_REAL_ENV` |
| REAL-04 | 全部绑定后标签启用 | 所有条目已核对 | 新标签在最后一步统一启用，列表使用现有兼容回退 | `TODO_REAL_ENV` |
| REAL-05 | 显式列表阻断 | 测试标签存在 persisted 列表 | 生成前阻断且无任何 home-list PUT | `TODO_REAL_ENV` |
| REAL-06 | 成本与并发 | 明确积分归属、MiniMax 配额 | 无超额并发，失败按策略恢复 | `TODO_REAL_ENV` |
| REAL-07 | 既有兼容回退标签 | 已有旧歌，部分旧作品可能不可用 | 旧歌绑定保留；公开有效子序列与最终 Admin 相对顺序一致，且本批至少一首可用歌曲可见 | `TODO_REAL_ENV` |

真实联调前先运行 `db-upgrade` 和 `doctor`。当前音乐工厂 PostgreSQL、Redis 和迁移均正常，环境诊断成功/失败分支已自动化验证。用户身份与 Admin JWT 必须分开；正式 Admin 控制面、运营账号解冻和积分已就绪，保持 `maxInFlight=1` 联调一首，在首个真实提交时最终确认 Provider/Model 配额。

## 7. 范围确认

- 本轮不要求或读取 `OPENAI_API_KEY`。
- 本轮不修改 Java、Web/Admin、Flutter 或 Catsinger 数据库；真实联调只验证现有接口。
- Python 不得调用显式首页列表 PUT，也不自动维护 `itemCodes/displayCount`。
- 若真实验收要求内部免普通积分、已有启用标签的整批原子可见或自动追加显式列表，必须另立 Java 变更，不得在 CHG-0033 Python 中绕过。
