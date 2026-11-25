# F002 简易与专业写歌参数适配

> 2026-09-19 CHG-0086：P03/P04 共用现有上传弹框，入口改为我的创作、相册视频、本地文件。选择器不预过滤时长；选择后按 10 秒至 10 分钟和当前模型更短上限报错重选，不自动截取或清除旧源；合法素材继续走现有截取、提取与资源查重链路。此为并行移动端修复，不改变本文件历史阶段状态。

> 2026-09-17 模型校正提示修复：默认选模和程序化同步静默清理不受当前模型支持的参数，隐藏模式不向当前页面发 Toast；用户在当前可见模式主动换模且实际清值时，改为列出具体字段。模型契约判断、清值和请求过滤不变。新增两条 Widget 回归、模型契约 8 项测试及静态分析通过。

> 2026-09-15 交互修复：P03 音频参考与 P04 歌曲改编共用入口弹框移除撑满屏幕的透明内容层，并显式允许遮罩点击和下滑关闭；录音、裁剪、处理中弹框规则未改。375×812 及 390×844/414×896 布局、遮罩关闭和无溢出定向测试通过。

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `waiting_review`；`T-F002-S/R` 均 `pending`。依据[PRD P02/P03](../../01-需求/v2.1-model-driven-params/requirements.md)、[F001](01-contract-and-fixture.md)、[Java B003](../../04-后端/开发计划/03-song-and-adaptation.md)。

## 骨架阶段 / `T-F002-S`

- **入口/路由**：首页 AI 写歌进入现有写歌 Tab；简易/专业在 `lib/pages/song_create/` 内切换，不建二次创作业务。继续复用 `SongCreateController`、`inspiration/`、`master/`、`widgets/model_option_row.dart`、`instrumental_row.dart`、`vocal_row.dart`、`create_submit_button.dart`。
- **视觉**：[简易页](../../01-需求/references/images/v2.1/model-driven-params/148-1287-simple.png)及[模型弹层](../../01-需求/references/images/v2.1/model-driven-params/148-1404-simple-model.png)为 P02；[专业禁用](../../01-需求/references/images/v2.1/model-driven-params/148-1674-pro-disabled.png)、[高级设置](../../01-需求/references/images/v2.1/model-driven-params/148-2068-pro-settings.png)、[音色选择](../../01-需求/references/images/v2.1/model-driven-params/148-2205-pro-voice.png)为 P03。区块顺序和设置位置以当前 Figma 为准，数值由接口替换。
- **调用链**：页面选择 `song.generate` 模型 → F001 有效能力投影 → 纯音乐/歌词/人声/参考音频互斥投影 → 价格/提交状态 → `SongAPI` 既有 `POST /api/song-generations` 方法。固定支持/禁用/缺价数据仅来自 Java local/test Fixture；不在 View 手写 JSON 或分数。
- **骨架控件**：每个不支持设置保持原位置、灰态、点击给原因；纯音乐开启时人声与歌词可见但不可提交；创建按钮随基础输入、有效模型、报价、提交中状态变化。长价格文案与安全区、键盘、底部 Tab/迷你播放器不重叠。
- `TODO(REAL-IMPLEMENTATION)`：真实模型切换后的字段过滤、歌词/音色/参考音频有效性、价格复核与任务结果，由 `T-F002-R` 完成。骨架不发真实生成、不上传/审核/冻结积分。
- **完成**：375×812 页面状态可操作，390×844/414×896 无遮挡；`flutter analyze`、Controller/Widget 置灰与按钮测试通过；生产仍走旧功能，不返回测试成功作品。

## 真实实现阶段 / `T-F002-R`

1. 对现有简易/专业 Controller 逐字段核对后台 `effectiveParameters`。`generation-options` 仅做运营展示标签，实际选项须取当前模型允许集合；指定本人/官方音色仅在该精确模型与音色已证明兼容时开放。
2. 切模型沿 F001 清空无效值；纯音乐开启保留本地歌词草稿但序列化时省略歌词、人声及其他互斥参数，关闭后可恢复。参考音频不兼容时仅取消本次引用，不删资源。
3. 请求沿旧 `CreateSongGenerationRequest`、现有 `modelOptionId` 和价格版本；拟增可选 `contractVersion` 前先与 Java B003/B006 对齐。只送当前有效的 `prompt/lyrics/title/styleTags/instrumental` 等业务字段和有意义的可选字段；不发送置灰旧值、空高级对象或超出模型约束的值。
4. 模型或影响价格设置变化后重取服务端报价，缺价/版本失效先刷新确认；提交后原有任务页、积分及作品流保持不变。重复点击必须复用现有防重/幂等，不建立第二套创建入口。
5. 完成定向回归：简易/专业两个模型、纯音乐开关与人声/歌词、参考音频清理、音色兼容、禁用项点击、缺价、超长文案、后台调价与提交失败。任务成功仍须第 15 步设备真实可播放，不由本模块虚报。

## 现状与边界

现有 `SongCreateController.modelOptions/selectModelOption` 已做选模，`SongGenerationOptions` 仍是 App 级选项；现状未解释逐模型能力。`SongAPI.fetchModelOptions` 已走正式模型目录，本轮补的是消费和安全序列化，不新增同义接口。P03 的 [歌词画面](../../01-需求/references/images/v2.1/model-driven-params/148-7238-lyrics.png)只改受支持状态，不重做歌词编辑或时间轴。

`T-F002-S/R` 独立记录影响文件、验证和剩余 TODO；后端返回字段若与技术文档不一致，先同步[跨端契约](01-contract-and-fixture.md)，不在 UI 本地猜支持能力。
