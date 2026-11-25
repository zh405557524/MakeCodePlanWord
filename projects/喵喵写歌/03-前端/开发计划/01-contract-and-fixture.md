# F001 模型能力契约与切换状态

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `done`（编码依据）；`T-F001-S=in_progress`、`T-F001-R=pending`。依据[前端技术文档](../flutter-tech.md)、[Java B002](../../04-后端/开发计划/02-effective-contract.md)、PRD §7.1～7.3 和[模型截图索引](../../01-需求/references/images/v2.1/model-driven-params/README.md)。

## 骨架阶段 / `T-F001-S`

- **入口与范围**：所有创作页的模型选择，不增加新路由。沿用 `SongAPI.fetchModelOptions(sceneCode)`、`SongVoiceCoverAPI.fetchModels(sceneCode)`、`SongConfigStore`/`SongVoiceCoverStore` 和现有 Controller。正式路径分别是 `GET /api/ai-model-options?sceneCode=...` 与 `GET /api/song-config/models?sceneCode=...`。
- **文件**：`lib/models/data/song.dart`、`lib/models/data/song_voice_cover.dart`、`lib/apis/song.dart`、`lib/apis/song_voice_cover.dart`、`lib/store/song.dart`、`lib/store/song_voice_cover.dart`；共享解析模型放现有 `lib/models/data/`，不造新状态框架。参考现有 `SongModelOption` 和 `SongVoiceModelOption` 的 `fromJson`。
- **调用链**：API 收包络 → 共享解析 `musicContract` → 场景 Controller 构建固定字段目录投影 → Widget 显示可编辑/置灰/原因 → 选择新模型后清除失效值并触发报价状态。`TODO(REAL-IMPLEMENTATION)` 对应 `T-F001-R`：真实目录及版本变化时完整状态迁移。
- **固定来源**：仅 Java local/test 集中 Skeleton Fixture；返回两个确定模型（一个明确支持、一个部分禁用）、未声明契约、缺价格、旧响应各一份。Flutter Widget/Controller 不埋模型硬限制、固定积分或伪任务。
- **安全门禁**：生产新增能力未完成时不显示伪成功；旧写歌/改编已有功能保持原状。只调正式读取 API，不触上传、冻结、审核或厂家。检查新客户端收到旧响应时可选项置灰。
- **验证/完成**：`flutter analyze`、模型解析与选模 Controller 定向测试通过；缺字段/错误类型不崩溃；`effectiveParameters` 未声明时全部可选设置禁用，基础操作只在服务端有独立可执行证据时可最小提交。

## 真实实现阶段 / `T-F001-R`

- 在整体三端骨架获用户明确确认后，接真实 `musicContract.operationType/status/parameters/contractVersion/effectiveParameters/mediaConstraints`；声音模型旧 `capabilityLimits` 只兼容不授权编辑。解析未知 `key`、未知状态、空约束和非法数字时默认禁用，不自行推断厂家能力。
- 切模型以选中 `modelOptionId` 和请求序号锁定最新响应：保留新模型仍支持且在范围内的用户值；禁用、越界、音色/资源不兼容的值**清空**并合并提示，不夹取到范围边界，不删除已上传资源。纯音乐互斥草稿另存，不混作切模型清理。
- 报价/能力版本独立：`contractVersion` 变更要求重新确认设置，`pricingVersion` 变更要求重新确认价格；旧网络响应不能覆盖新选择。`NOT_DECLARED` 可选项一律置灰，基础提交条件由服务端证据决定。
- **完成**：两模型切换、返回前台、后台停用、价格变化、请求竞态和旧响应定向测试通过；提交序列化层只保留业务必填与有效可选键，Java B002/B006 契约核对无差异。

## 页面与视觉对账

P02 [简易模型弹层](../../01-需求/references/images/v2.1/model-driven-params/148-1404-simple-model.png)、P03 [专业模型](../../01-需求/references/images/v2.1/model-driven-params/148-1934-pro-model.png)、P04 [改编默认](../../01-需求/references/images/v2.1/model-driven-params/148-5350-adapt-default.png)与 P05/P09 当前 Figma 为字段位置和灰态参考；第 4 步 `figma-design-plan.md` 已明确跳过。模型卡加载/空/失败/停用均要保留布局，禁用项可点击原因说明而不可修改。截图中的分数、时长、滑杆数是示例，实际显示由服务端决定。

## 异常与测试数据

| 场景 | 页面结果 | 请求结果 |
|------|----------|----------|
| 契约缺失/解析错 | 基础输入保留，可选项可见置灰；显示“当前模型暂不支持此设置” | 不发送禁用参数 |
| 新模型范围收窄 | 清空不合法草稿并提示，资源本体不删除 | 旧值不能进入新请求 |
| 选模竞态/离页 | 只应用最后一次选择，已销毁页面不回写 | 不使用过期价格 |
| 模型整体下架/缺价 | 创建按钮禁用，草稿可恢复 | 不提交/不冻结 |

`T-F001-S/R` 状态逐项回写[模块索引](00-module-index.md)和[总体计划](../flutter-dev-plan.md)；没有 Java B001/B002 的目标响应契约时不得猜字段。

## 2026-09-14 骨架恢复点

已新增 `MusicContract` 安全解析并接入 `SongModelOption` / `SongVoiceModelOption`，旧响应、缺版本、未知状态与不支持项均不授权编辑。`flutter analyze --no-pub` 和模型定向测试通过。页面 Controller 的动态投影、切模清值和服务端 Fixture 正式路径联调尚未完成，故 F001-S 仍 `in_progress`；未改创作提交、生产开关和图片/音频上传。
