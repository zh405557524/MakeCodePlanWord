# 05 Song Create 写歌页返工模块开发文档

> 关联任务：CHG-0011 / Song Create  
> 当前状态：done  
> 设计稿来源：`01-需求/references/images/v1.0/Ai写歌/*.png`  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/pages/song_create/controller.dart`、`lib/pages/song_create/view.dart`、必要时 `lib/models/params/song_generation_params.dart`

## 1. 模块目标

写歌页是核心创作入口。本模块要把当前偏旧参考图的写歌页重写为新设计稿结构：

- 顶部标题 `AI 写歌`
- `灵感创作 / 高级创作` 分段 Tab
- 灵感创作完整表单
- 高级创作完整表单
- 固定底部 `开始创作` 按钮
- 迷你播放器和底部 Tab 避让

## 2. 现状偏差

| 区块 | 当前实现 | 设计稿要求 |
|------|----------|------------|
| 标题 | 无页面标题 | 顶部 `AI 写歌` |
| 分段 | 有但颜色/高度偏旧 | 深色整宽分段，激活项绿色描边 |
| 灵感描述 | 有大卡，但风格偏旧图 | 新稿深紫黑输入卡，底部灵感速递/字数 |
| 音乐名称 | 只在 custom 中简单输入 | 灵感/高级都需要名称输入 |
| 曲风描述 | custom 简单输入 | 灵感/高级都需要曲风描述和标签 |
| 高级创作 | 只有标题/歌词/风格 | 歌词、AI帮写、名称、曲风、歌手、语言、时长、参考音频、模型 |
| 底部按钮 | 在 ListView 底部 | 固定底部，避让迷你播放器/Tab |

## 3. 页面结构

```text
SongCreatePage
  Stack
    ListView
      PageTitle AI 写歌
      ModeSegmentedTabs
      if simple:
        PromptInputCard
        SongTitleField
        StyleDescriptionField
        StyleTagWrap
        InstrumentalSwitch
      if custom:
        LyricsInputCard
        SongTitleField
        StyleDescriptionField
        StyleTagWrap
        VocalGenderSelector
        LanguageSelector
        DurationSelector
        ReferenceAudioPanel
        ModelSelectorPanel
    FixedBottomCreateButton
    optional MiniPlayerArea
```

## 4. Controller 状态

`SongCreateController` 需要扩展：

- `mode`: simple/custom
- `instrumental`
- `submitting`
- `loadingInspiration`
- `loadingAiLyrics`
- `promptController`、`promptLength`
- `titleController`、`titleLength`
- `lyricsController`、`lyricsLength`
- `styleController`、`styleLength`
- `selectedStyleTags`
- `vocalGender`: default/male/female
- `language`: zh/en/ja/ko/yue
- `durationMinutes`: 1/2/3/5
- `selectedModel`
- `referenceAudioSource/referenceAudioName/referenceAudioAssetId/referenceAudioUploadProgress/referenceAudioError`

需要新增方法：

- `applyPromptFromHome(String prompt)`
- `enableInstrumentalFromHome()`
- `switchToAdvancedForLyricsAssist()`
- `toggleStyleTag(String tag)`
- `fetchInspiration()`
- `assistLyrics()`
- `submit(BuildContext context)`
- `clearPrompt()`
- `clearLyrics()`

## 5. 灵感创作

字段：

| 字段 | 规则 |
|------|------|
| 音乐描述 | 最大 200 字，必填；支持首页回填、灵感速递覆盖 |
| 音乐名称 | 最大 80 字，选填 |
| 曲风描述 | 最大 200 字，选填 |
| 曲风标签 | 多选，点击后同步到 `selectedStyleTags` |
| 纯音乐 | 开关；首页纯音乐入口默认开启 |

输入卡要求：

- `AI写歌-灵感创作1.png` 首屏可见标题、分段和音乐描述卡。
- 描述卡底部左侧是 `灵感速递`，右侧是字数。
- 删除按钮清空描述。
- 灵感速递 loading 时按钮禁用，避免重复请求。

## 6. 高级创作

字段：

| 字段 | 规则 |
|------|------|
| 歌词输入 | 最大 3000 字，必填；AI帮写可回填 |
| AI帮写 | 调用 `/api/song-lyrics/assist`，失败 toast |
| 音乐名称 | 最大 80 字 |
| 曲风描述 | 最大 200 字 |
| 曲风标签 | 同灵感创作 |
| 歌手类型 | 默认、男声、女声 |
| 歌曲语言 | 中文、英文、日文、韩文、粤语 |
| 歌曲时长 | 1、2、3、5 分钟 |
| 参考音频 | 现场录制/导入音频入口；导入音频从系统相册/媒体库查找音频，录制或选择后上传 `/api/song-assets/reference-audios`，上传成功后提交 `referenceAudioAssetId` |
| AI模型 | 从后端模型列表展示默认模型和价格 |

提交参数：

- `mode=custom`
- `lyrics`
- `title`
- `styleTags`
- `instrumental=false`
- `provider/model` 来自后端模型
- `referenceAudioAssetId`：仅在参考音频上传成功后提交
- 后续扩展：`vocalGender/language/durationSeconds`

## 7. 交互规则

- 从首页 prompt 进入：切到灵感创作并回填音乐描述。
- 从首页纯音乐进入：切到灵感创作并开启纯音乐。
- 从首页 AI作词进入：切到高级创作，可展示 AI帮写入口。
- 灵感创作提交时，音乐描述为空且无图片/模板时提示。
- 高级创作提交时，歌词为空提示。
- 模型列表为空时禁用提交并提示“暂无可用模型”。
- 提交成功进入 `RouteName.songGenerating`。

## 8. 固定底部按钮

要求：

- 使用 `AppGradientButton`。
- 高度约 56-60.h，左右边距 20-24.w。
- 位于页面底部，但要避让：
  - 键盘
  - 迷你播放器
  - 底部 Tab
- submitting 时显示 loading，不允许重复点击。

## 9. 实现步骤

1. 扩展 Controller 状态、监听器和 dispose。
2. 补首页回填方法，必要时让 MainController 调用。
3. 重写 View 为 Stack + Scroll + Fixed button。
4. 用公共 `AppSegmentedTabs/AppDarkCard/AppGradientButton` 替换旧样式。
5. 补 AI帮写 API 调用和 loading 状态。
6. 补参考音频录制、相册导入、上传、重试/删除和生成提交状态。
7. 保留现有 `createGeneration` 提交流程，追加新字段时保持后端兼容。
8. 调整底部 padding，避免按钮/Tab 遮挡。

## 10. 验收标准

- [ ] 灵感创作首屏与 `AI写歌-灵感创作1.png` 结构一致。
- [ ] 高级创作首屏与 `AI写歌-高级创作1.png` 结构一致。
- [ ] 字数计数实时变化。
- [ ] 灵感速递成功覆盖音乐描述，失败 toast。
- [ ] AI帮写成功回填歌词，失败 toast。
- [x] AI帮写/智能优化请求等待期间保持屏幕常亮，成功、失败或返回结果后自动释放；校验拦截不启用。
- [ ] 首页 prompt/纯音乐/AI作词入口能正确切到写歌页状态。
- [x] 高级创作参考音频支持现场录制、相册导入、上传成功后提交 `referenceAudioAssetId`，上传中/失败时阻止开始创作。
- [x] 灵感创作/场景创作不提交 `referenceAudioAssetId`，即使本地残留已上传参考音频状态也不会带音频参数。
- [x] AI 模型区改为内联列表，点击可直接选择模型。
- [ ] 固定按钮不遮挡迷你播放器和底部 Tab。
- [x] `flutter analyze`、`flutter test` 无新增问题（2026-06-23 验证 88 项）。

## 11. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-06-22 | 完成高级创作参考音频闭环 | 已实现现场录制、导入音频、上传 `/api/song-assets/reference-audios`、提交 `referenceAudioAssetId`、上传失败/上传中拦截、内联模型选择和相关测试；图片写歌仍待后续单独完成 |
| 2026-06-23 | 调整导入音频来源 | 导入音频改为从系统相册/媒体库选择音频资产，补 Android 音频读取权限、iOS 相册用途说明和权限测试 |
| 2026-06-23 | 修复灵感创作音频参数 | `referenceAudioAssetId` 仅高级创作上传成功时提交；灵感/场景创作请求体不带音频字段 |
| 2026-08-04 | CHG-0056 生成同款专业模式回填 | 新增一次性同款入口意图；风格等待动态配置后映射到当前启用选项 `value`，快照优先且不混入 Provider 结果标签，人声英文标签独立恢复；原模型/配置不可用时回退并合并提示，参考音频优先提交 `assetId`，普通入口保持空白/default |
| 2026-08-05 | CHG-0062 专业模式歌词润色等待防息屏 | 主页面 AI 帮写和全屏歌词编辑页智能优化共用 `assistLyrics()`；输入校验通过后以 `ScreenAwakeCoordinator.keepAwakeWhile()` 包裹真实接口请求，成功/失败自动释放，重复点击沿用既有 loading 防重入；屏幕常亮相关 8 项和歌词请求参数回归通过；V1981A 在 15 秒自动锁屏下验证等待期间不息屏、歌词回填后恢复系统息屏，设备设置已还原 |

## 12. CHG-0056 生成同款回填约束

- 入口只接收路由 `extra` 中已加载的 `SongWorkDetail`，query 只保留 `mode=custom`，不得携带歌词或音频 URL。
- `creationParameters.musicStyleTags` 非空时只使用快照风格，不合并 `detail.styleTags`；旧后端或历史空快照才从结构化“音乐风格”段和详情结果标签降级。
- 风格必须等动态配置加载完成后，依次按启用选项 `code/label/value`、英文词组和固定别名匹配，写入值始终取选项当前 `value`。无法映射或已禁用项不自动创建自定义标签。
- `Mandopop/C-Pop/Chinese Pop` 对应流行，`EDM` 对应电子，`Guofeng/Chinese Traditional` 对应国风，`RNB/Rhythm and Blues` 对应 R&B，`Easy Listening` 对应轻音乐，`Romance` 对应浪漫，`Ballad/Slow Ballad` 对应慢板；`Male/Female Vocal` 只恢复人声参数。
- 风格文本只按逗号、顿号、分号和换行分隔，不按空格拆分多词英文标签；仅自动同款回填过滤未知项，普通专业模式保留手动自定义标签能力。
- 纯音乐作品歌词必须为空；旧后端缺少 `creationParameters` 时仍回填详情歌名、歌词、可映射风格，并根据 `songType` 恢复纯音乐。
- 参考音频有效时恢复名称、时长、预览和移除；生成提交优先发送 `referenceAudioAssetId`，没有素材 ID 时才发送 `referenceAudioUrl`。
- 当前配置已禁用或无法识别的模型/选项回退默认，失效参考音频清空，所有降级合并为一次提示；不新增视觉控件，不复制翻唱专属音频或高级设置。
