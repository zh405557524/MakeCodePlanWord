# AI 音乐内容自动生产工具：确认需求清单

> 变更：CHG-0019
> 状态：Python 自动化已实现，等待真实 Catsinger 单曲联调与业务验收
> 实现工程：`/Users/soul/code/lxwx/lxwx_music_factory`

## 1. 项目概述

建设独立 Python 内容工厂，将 Codex 对话形成的公开榜单采集包和显式原创生产方案，转换为可恢复、受限并发的 AI 音乐生产批次。Python 只校验并执行方案，不自行决定首页标签、榜单分组或歌曲提示；真实歌词、音乐、资源、审核和作品仍由 Catsinger Java 后台及其音乐 Provider 完成。

生产运行不调用 OpenAI API，不读取或要求 `OPENAI_API_KEY`。Codex 是人工对话工作面和调试助手，不是 Python 生产依赖。

## 2. 三条链路

1. **Codex 内容准备**：采集公开榜单事实，规划首页业务标签，完成榜单成员分组，输出原创歌曲方案。
2. **Codex 开发调试**：读取 Python 代码、脱敏日志、状态和测试，修复 Bug 后从数据库续跑；不直接改变生产事实状态。
3. **Python 生产执行**：校验方案、准备标签、创建批次、并发调度、轮询、质量门禁、批次审核、首页条目绑定和失败恢复。

数据采集与生产批次继续分离；导入采集包、分析趋势或导入方案都不会自动开始音乐生成。

## 3. Codex 1–4 内容流程

### Codex-1：公开榜单采集

- 每次采集使用独立 `collectionId`，生成 `collection.md`、`collection.json`、`manifest.json`。
- 只保存歌曲名、歌手、平台、榜单、排名、公开热度、榜单日期和来源引用。
- 不下载音频、歌词、旋律、封面或媒体地址；采集完成不触发 Python 生产。

### Codex-2：首页业务标签规划

- 根据一个或多个明确的 `collectionId` 和聚合趋势，规划本批次需要使用的首页模块标签。
- 每个标签给出稳定 `tagCode`、展示名称、排序建议和聚合依据。
- 标签规划只表达市场方向，不把具体榜单歌曲作为模仿目标。

### Codex-3：榜单歌曲分组

- 使用稳定的采集记录引用，把榜单成员归入一个或多个计划标签，用于说明覆盖范围和生产配额。
- 分组引用只用于追溯和聚合，不得进入 Java 音乐生成 prompt。
- 不复制原歌曲歌词、旋律、音频特征或可识别的模仿描述。

### Codex-4：原创歌曲方案

- 为每首计划歌曲生成独立标题、主题、语言、人声、情绪、场景、乐器、速度、结构、`styleTags`、`tagCodes` 和原创生成提示。
- 同一标签下的歌曲也必须有明显不同的主题、编曲或结构。
- 最终只输出严格的 `ProductionPlanDocument`；Python 不再从趋势权重临时生成真实生产歌曲方案。

## 4. ProductionPlanDocument

`ProductionPlanDocument` 是真实生产的唯一业务输入，至少包含：

- 文档字段：`schemaVersion`、`planId`、`createdAt`、`sourceCollectionIds`、`copyrightGuard`。
- 标签白名单：`businessTags[]`，包含 `tagCode`、`tagName` 和 `sortOrder`。
- 榜单分组：`sourceGroups[]`，包含 `groupCode`、`styleTags`、`tagCodes` 和稳定 `sourceEntries`。
- 歌曲计划：`songs[]`，包含稳定 `planSongId`、`sourceGroupCode`、标题、描述、原创 prompt、`styleTags`、`tagCodes`、语言、人声、纯音乐、时长、主题、乐器、BPM 和结构。
- 执行参数：`execution` 明确 Provider、Model、并发、轮询、提交间隔、重试、超时和发布模式。
- 完整性：歌曲 `tagCodes` 必须引用本文档的 `businessTags` 和对应 `sourceGroupCode` 已声明标签；`styleTags` 非空；计划编号、歌曲编号和标签编码不得重复。
- 类型和存储边界：整数、布尔字段必须使用原生 JSON 类型；`planId`、`planSongId`、`groupCode/sourceGroupCode` 最长 64 字符，与任务数据库字段一致。

严格 Schema 拒绝未知字段。标题、描述、Prompt 以及会发送给生成平台的 `styleTags` 均不得包含采集歌曲名、歌手名或正向模仿要求；文档中也不得包含歌词全文、参考音频、媒体下载地址、旋律、音频指纹或显式首页列表的 `itemCodes/displayCount`。

方案导入只校验、计算哈希并保存不可变文档；相同内容幂等返回原记录，内容变化必须使用新 `planId`。

## 5. 三层标签与首页语义

1. **`styleTags`：歌曲内容标签**
   - 描述古风、欧美流行、日韩风格、治愈、女声、短视频等歌曲内容属性。
   - 由 Codex 在歌曲方案中明确，随生成参数和首页歌曲条目保存。
   - 不自动转换为首页模块，也不决定 App 展示顺序。

2. **`tagCodes`：首页模块归属**
   - 指向 Catsinger 首页模块标签，是首页歌曲条目的业务归属。
   - 必须来自 `ProductionPlanDocument.businessTags`，并在真实生成前完成存在性、名称、状态和列表冲突校验。
   - Python 只能使用方案中明确的编码，不能根据 `styleTags` 猜测或自动扩展。

3. **显式 `home-list`：人工编排层**
   - 保存某个 `tagCode` 下有序 `itemCodes` 和 `displayCount`，由现有 Admin 人工维护。
   - 不属于 `ProductionPlanDocument`，Python 不创建、不追加、不排序，也绝不调用 `PUT /api/admin/song/home-lists/{tagCode}`。
   - Python 只读查询列表状态用于生产前阻断；目标标签已经存在持久化显式列表时，整批在任何真实生成请求前停止，等待运营更换标签或人工处理。

初始业务标签映射固定为：`hot_song/热歌`、`new_song/新歌`、`rising_song/飙升`、`original_song/原创`、`guofeng/国风`、`western/欧美`、`japan_korea/日韩`。方案允许一首歌明确配置多个 `tagCodes`，但 Python 不从自由 `styleTags` 自动创建首页标签。

## 6. 标签准备规则

生产启动前必须完成全量预检：

1. 查询所有目标 `tagCodes` 的现有标签和首页列表状态。
2. 标签已存在且启用、没有持久化显式列表时按 `tagCode` 复用；展示名称差异只记录警告并保留后台名称。
3. 标签缺失时，使用现有 Admin 标签接口以 `enabled=false` 创建，并记录为本批次新标签；创建动作必须幂等。
4. 重复/冲突编码、预先处于禁用状态，或已存在持久化显式列表时，批次保留 `READY` 并记录阻断错误，不提交任何真实歌曲生成请求。
5. 因本批次创建且保持禁用的标签是合法准备状态；重启后必须根据本地记录和后台事实继续核对，不重复创建。

## 7. 整批生成、审核与绑定门禁

批次主状态为：

```text
READY → PREPARING_TAGS → TAGS_READY → RUNNING
→ GENERATION_COMPLETE → WAITING_REVIEW → BINDING → COMPLETED
```

旁路状态为 `PAUSED`、`PARTIAL_FAILED` 和 `FAILED`。

1. `ProductionPlanDocument` 导入、批次创建和标签准备均不自动提交音乐生成。
2. 运营确认方案并启动后，Python 才按 Provider + Model 全局并发槽位滚动生成。
3. 任意单曲先完成时，只更新本地作品状态，不创建首页歌曲条目，也不启用新标签。
4. 只有全部计划歌曲均生成成功、存在有效 `workId`、通过质量检查且没有未解决失败时，批次才能进入 `WAITING_REVIEW`。
5. 批次审核通过后，Python 才按每首歌明确的 `styleTags` 和 `tagCodes`，幂等创建 `WORK` 来源首页歌曲条目。
6. 绑定中断时保留已完成结果并从 PostgreSQL 续跑；新标签继续保持禁用。
7. 所有歌曲条目均创建并核对成功后，才启用本批次创建的新标签；复用的既有标签不改变原状态。
8. 全部绑定和新标签启用完成后，生产批次才标记完成。
9. 默认整批成功才允许审核；只有显式使用 `approve-publish --allow-partial`，才能在永久失败后绑定成功部分，且没有发布歌曲的新建标签保持禁用。
10. 部分发布后重新生成失败歌曲时，旧审核、部分发布授权与公开核验失效；人工审核模式必须再次审核。若只重试已有作品的绑定，不重新生成或重复审核，但必须清除旧标签激活/公开核验并在绑定后全量复核。
11. 兼容回退标签保留旧歌曲；最终确认公开歌曲是 Admin 回退顺序的有序有效子序列，并确认本批至少一首歌曲进入 `displayCount` 可见区，允许 Java 过滤禁用或不可用作品后补位。公开查询后再次读取 Admin；本批无可见可用歌曲、顺序不一致或期间出现显式列表时，保存错误并暂停，不写显式列表。

## 8. 调度、持久化与调试

- PostgreSQL 是计划、标签准备、批次、歌曲任务和状态事件的事实源；Redis/Celery 只唤醒短任务。
- 每个平台/模型配置 `maxInFlight`、轮询间隔、提交间隔、最大尝试次数和超时；未知时 `maxInFlight=1`。
- 支持暂停、恢复、失败重试、状态核对和批次审核；重启或修复 Bug 后不重复提交已成功、在途或已绑定歌曲。
- 标签准备完成前，`resume`、`reconcile` 和 Worker 均不得提交歌曲；周期调度按批次隔离异常，单批失败不饿死其他批次。
- 日志包含 plan/collection/batch/job/trace 标识并脱敏，不记录 Token、完整歌词、完整 prompt 或敏感响应。

## 9. 明确不做

- 不开发无人值守榜单爬虫，不逆向平台私有接口。
- 不调用 OpenAI API，不需要 `OPENAI_API_KEY`。
- 不让 Python 重新设计或复制 Java 的歌词、音乐 Provider、OSS、审核和作品逻辑。
- 不修改 Java、Web/Admin 或 Flutter App；只复用现有标签查询/创建/更新、列表查询、歌曲生成/查询和首页条目接口。
- 不修改普通用户鉴权、积分、计费、Provider、数据库或公开接口。
- 不自动操作显式首页列表，不使用 GET/PUT 读改写覆盖运营编排。

## 10. 外部依赖与限制

- 真实生成继续使用现有 Java 用户 Bearer Token 和普通用户积分规则；正式执行前必须确认成本归属和余额。
- 首页标签准备、条目绑定和新标签启用使用现有 Admin Token 与 `X-App-Code`。
- 真实音乐 Provider 的并发、提交间隔和超时需按 Provider + Model 配置。
- 若未来要求对已有启用标签实现整批原子可见、自动追加显式列表或内部免普通积分，必须另立 Java 变更；CHG-0019 本轮不实现。
