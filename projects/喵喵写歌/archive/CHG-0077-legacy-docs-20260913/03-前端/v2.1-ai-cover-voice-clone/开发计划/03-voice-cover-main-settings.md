# 03 翻唱主页与设置

> 任务族：`T-F003`
> 骨架任务：`T-F003-S`
> 真实任务：`T-F003-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 页面：P02、P03
> 设计节点：`114:4065`、`114:4163`、`114:4281`、`114:4391`、`114:4501`-`114:5767`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-F003-S`
- 本阶段交付：完成 P02/P03 全部页面、来源/音色/模型/授权/设置状态和按钮调用；提交调用正式 `/api/song-voice-covers`，由测试后端返回固定报价与演示任务。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-F003-R`
- 本阶段交付：接入真实来源校验、审核事实、音色绑定、实时报价、会员积分门禁和翻唱提交。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

实现翻唱声音克隆主页面和设置页，完成“源歌曲 + 可用音色 + 厂家模型 + 授权 + 实时报价”的提交前闭环。该页面不得使用旧 AI 改编三步 `SongCoverPage`。

## 2. 页面结构

P02 从上到下：

1. 返回、标题「翻唱声音克隆」。
2. 源歌曲卡：作品库或本地上传，显示解析/审核状态。
3. 翻唱设置摘要及进入 P03 的入口。
4. 我的音色/官方音色分段 Tab。
5. 音色列表、试听、选中状态、定制音色入口。
6. 歌曲合法使用权确认及使用规范入口。
7. 当前模型、实时报价和阻断原因。
8. 固定底部「开始翻唱」按钮。

P03：三个配置范围由后端返回，使用滑杆或步进控件编辑 pitch、vocalVolume、accompanimentVolume；保存回 P02，系统返回不保存。

## 3. 设计稿状态

- `01`：我的音色、歌曲已上传、可提交。
- `02`：翻唱报价确认。
- `03/04`：非会员、积分不足。
- `05-07`：格式、容量、解码失败。
- `08`：使用协议。
- `09-15`：官方音色上传中、列表、不可用、加载、空态和失败重试。
- `16`：设置页。

Figma 中 30 积分、45/50MB、90 秒等均是旧占位；页面必须显示后端 100MB、10 分钟和实时价格。

## 4. Controller 状态

建议 `SongVoiceCoverController` 持有：

- config/models/selectedModel；
- sourceWork/sourceAsset/sourceStatus，严格 XOR；
- myVoices/officialVoices/selectedVoice；
- settings/editingSettings；
- rightsConfirmed、quote、blockingReason；
- 各分区 loading/error、uploadBusy、submitBusy；
- idempotencyKey 和 entrySource。

模型切换后立即重新校验音色渠道绑定；不匹配时清空音色并显示原因，不能静默换音色。

## 5. 提交门禁

按钮仅在以下条件同时满足时启用：

- 功能启用、用户已登录且满足会员条件；
- 源作品或源 asset 恰有一个，技术状态 READY、审核 PASS；
- 音色模型版本 AVAILABLE，且匹配所选 provider/model；
- 歌曲权利和声音授权为 true；
- 报价存在、未过期，pricingVersion 与当前模型一致；
- 非 busy。

按钮禁用时在页面展示首个阻断原因，不允许“点击无反应”。

## 6. 接口和数据流

进入页面并行请求 config、翻唱模型、我的音色、官方音色和 active 任务。源文件先走公共直传，再 `POST /api/song-assets/voice-cover-sources` 并轮询 asset；作品库来源保存 sourceWorkId。

提交前刷新报价，确认弹窗展示真实积分；随后 `POST /api/song-voice-covers`。成功保存 taskId 并进入 P10；幂等返回旧任务时直接恢复。

## 7. 影响文件

建议新增 `lib/pages/song_voice_cover/main/`、`settings/`、`widgets/source_song_card.dart`、`voice_picker.dart`、`quote_bar.dart`、`rights_checkbox.dart`。复用 `AppButton`、现有分段控件、资源选择器、错误提示和 loading 组件。

## 8. 实现步骤

1. 建立 Controller 的单一表单状态和 blockingReason 计算。
2. 实现源作品选择与本地上传入口，不同时保留两个来源。
3. 实现我的/官方音色局部加载和单播放器试听。
4. 实现 P03 编辑副本、范围限制、保存/返回语义。
5. 接入授权协议、模型报价、会员/积分回跳。
6. 提交时锁按钮、刷新报价、复用幂等键并跳 P10。

## 9. 测试与验收

- 每个设计状态都有 Widget 用例或截图落点。
- 来源 XOR、审核中、音色不可用、模型切换、价格过期、非会员、积分不足均不能提交且原因可见。
- 连点只产生一次请求；失败保留表单。
- 设置页返回不保存，保存后摘要立即更新。
- 375x812 固定按钮不遮内容；长文件名、长维护文案和键盘状态不溢出。
- 创建请求无 `mode`，包含真实 provider/model、voiceModelVersionId、settings、授权和幂等键。

## 10. 编码注意事项

页面不得自行判断积分冻结、审核通过或任务成功；作品库来源的权属和可用性仍由后端最终校验。试听切换时先停止上一条，进入主播放器前释放页面试听。
