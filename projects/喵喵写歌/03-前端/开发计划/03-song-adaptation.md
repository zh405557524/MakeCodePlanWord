# F003 歌曲改编的逐模型设置

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `waiting_review`；`T-F003-S/R` 均 `pending`。业务真源[PRD P04/P06](../../01-需求/v2.1-model-driven-params/requirements.md)，依赖[契约模块](01-contract-and-fixture.md)和[Java B003](../../04-后端/开发计划/03-song-and-adaptation.md)。

## 骨架阶段 / `T-F003-S`

- **入口**：首页“歌曲改编”进入现有 `SongCoverController`/`lib/pages/song_cover/view.dart`，选择歌曲从现有作品库或本地音频返回本页；不进入 `song_voice_cover/`。公开创建仍是 `POST /api/song-covers`，模型场景 `song.cover.generate`。
- **画面**：[改编默认](../../01-需求/references/images/v2.1/model-driven-params/148-5350-adapt-default.png)、[歌词](../../01-需求/references/images/v2.1/model-driven-params/148-5548-adapt-lyrics.png)、[歌词识别中](../../01-需求/references/images/v2.1/model-driven-params/148-5750-adapt-recognition-loading.png)、[识别失败](../../01-需求/references/images/v2.1/model-driven-params/148-5647-adapt-recognition-failed.png)、[作品选择](../../01-需求/references/images/v2.1/model-driven-params/148-7058-work-picker.png)。当前 Figma 控件位置不因动态参数重排；不可用设置留位置灰。
- **文件/状态**：现有 `lib/pages/song_cover/controller.dart` 的 `modelOptions`、`selectModelOption()`、`preserveOriginalLyrics` 继续作为状态入口，能力来自 F001，识别加载/失败仍用既有页面状态。只补模型切换、禁用理由、报价与提交按钮投影，不另造改编业务类型。
- **调用链**：选择来源 → 读取改编模型与契约 → 按源/歌词策略派生支持状态 → 确认价格 → 原 `SongAPI` 改编创建方法。Java local/test Fixture 提供固定能力/报价；禁用旧值不得被骨架拼入请求。`TODO(REAL-IMPLEMENTATION)` 对应 F003-R 的真实来源、歌词与模型复核。
- **安全/完成**：骨架不调用真实上传、歌词识别、审核、冻结或厂家；已有生产改编保持旧行为。375×812 识别三态及选模弹层可见，置灰点按有原因，`flutter analyze` 和定向 Widget/Controller 测试通过。

## 真实实现阶段 / `T-F003-R`

1. 用真实 `song.cover.generate` 有效契约过滤保留歌词、伴奏及可选调节项。所选模型不支持时保持控件位置但禁用；切模型清掉旧值，原来源素材只取消不兼容的本次引用。
2. “保留原歌词”开启：沿现有来源歌词/识别结果规则；关闭：不得暗传旧歌词，必须走新词输入或已完成的明确 AI 补词结果。识别中、失败与人工歌词编辑不因模型切换被静默覆盖。
3. 创建沿现有 `CreateSongGenerationRequest` 及后端强制 cover 语义，不在 App 传声音克隆 `mode`、`voiceModelVersionId` 或训练数据。有效可选字段才序列化；价格/契约过期重取并重新确认，重复提交使用原幂等策略。
4. 后端 B003 冻结前拒绝禁用/越界参数；App 展示字段级原因而不把真实失败处理成成功任务。来源审核事实沿原改编链路，不新增第二条审核业务逻辑。
5. 完成定向回归：保留歌词开/关、新词/识别失败、来源作品/本地音频、模型切换清值、缺价、旧改编历史作品与“重新改编”入口。第 15 步需设备实际可播放才判正向生成通过。

## 不返工范围

现有 `SongCoverController` 代码和后台历史名称中可能仍出现旧“AI 翻唱”字样，本轮只按产品业务边界消费，不将其迁移为翻唱声音克隆，也不修改旧任务/作品类型。无本版新 UI 设计的弹层沿当前工程样式；动态价格、时长与 Figma 示例不要求一致。
