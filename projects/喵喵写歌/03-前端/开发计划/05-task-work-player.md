# F005 报价、任务恢复、作品与播放器

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `waiting_review`；`T-F005-S/R` 均 `pending`。依赖[写歌](02-song-create.md)、[改编](03-song-adaptation.md)、[声音克隆](04-voice-train-and-clone.md)、[Java B006](../../04-后端/开发计划/06-pricing-snapshot.md)与[PRD P11～P13](../../01-需求/v2.1-model-driven-params/requirements.md)。

## 骨架阶段 / `T-F005-S`

- **入口/页面**：三业务的提交按钮到各自现有生成等待；任务恢复进入现有 `lib/pages/song_create/generating/` 或 `song_voice_cover/generating/`；作品 Tab 保留 `lib/pages/song_works/`，播放复用 `song_works/player/` 的 `SongPlayerPage`。不新建声音克隆结果页，也不改原改编作品归类。
- **视觉**：[作品画面](../../01-需求/references/images/v2.1/model-driven-params/148-5115-works.png)、[播放器](../../01-需求/references/images/v2.1/model-driven-params/146-7543-player.png)、[歌词](../../01-需求/references/images/v2.1/model-driven-params/148-7238-lyrics.png)。图中示例价格/时长与运行时不同不改稿；状态、按钮和底部小播放器须避让安全区。
- **调用链**：当前模型契约/价格 → 提交前确认 → 业务创建 API → 现有任务查询/active → 作品 Store 刷新 → 现有播放器。Java local/test Fixture 仅用于显示确定的排队/处理中/失败/成功状态，不创建真实订单或作品；骨架不把固定“成功”当可播放验收。
- **按钮/异常**：价格变化重新确认、缺价禁用；离开等待页后任务仍可恢复；网络失败保留任务 ID、下次重试查；“重新改编”回改编、“重新翻唱”回声音克隆。`TODO(REAL-IMPLEMENTATION)` 对应 F005-R 的真实任务/作品/播放。
- **完成**：375×812 和 390/414 宽度无底部遮挡，三业务任务路由互不串；Controller 测试覆盖过期报价、任务空/失败/恢复、错误作品类型；`flutter analyze` 通过，生产没有伪造成功音频。

## 真实实现阶段 / `T-F005-R`

1. `contractVersion` 与 `pricingVersion` 分开处理；模型或计价设置变化重取报价，用户取消不创建任务，过期重确认不沿旧价格继续。重复点按沿现有幂等键、防双提交。
2. 成功创建任务后按原业务类型查询，切后台/重启后沿各自 active 和作品链路恢复；任务失败展示真实原因和积分释放状态，不把临时网络错误当“已退款”。
3. 成功作品必须是平台自有持久化资源，音频真实格式/MIME/时长来自作品详情；复用播放器的播放、歌词、下载/分享/收藏/删除，不重新设计结果页。重新创作入口按 `ORIGINAL/COVER/VOICE_COVER` 回到正确页，切换模型时仅回填仍有效的参数。
4. 定向测试确认 App 请求没有置灰旧参数、作品/任务状态按后端同步；第 15 步 Android/iOS 用户测试在目标作品播放器持续播放并有进度变化后才判正向闭环 PASS。iOS 无真机也无模拟器则双端验收不通过。

**不变项**：旧 `SongPlayerPage`、作品生命周期、会员积分余额和下载/分享通用组件继续复用；本模块只是逐模型参数改变后的衔接与回归，不重做播放器 UI 或计费服务。
