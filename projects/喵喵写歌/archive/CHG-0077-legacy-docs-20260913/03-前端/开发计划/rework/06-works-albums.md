# 06 Works Albums 作品与专辑返工模块开发文档

> 关联任务：CHG-0011 / Works Albums  
> 当前状态：done  
> 设计稿来源：`01-需求/references/images/v1.0/作品/作品-作品.png`、`作品-专辑.png`、`专辑创建*.png`、`专辑详情.png`  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/pages/song_works/controller.dart`、`lib/pages/song_works/view.dart`

## 1. 模块目标

作品页负责管理用户歌曲、生成中任务和专辑。本模块要将当前默认 Material 列表重写为设计稿结构：

- 顶部标题 `作品`
- 歌曲/专辑分段 Tab
- 生成中歌曲分组
- 已完成歌曲分组
- 专辑卡
- 创建专辑入口

## 2. 现状偏差

| 区块 | 当前实现 | 设计稿要求 |
|------|----------|------------|
| 分段 | Material `SegmentedButton` | 自定义深色分段，激活绿色描边 |
| 生成中 | 无独立分组 | `生成中 · N 首`，卡片含进度条、百分比、模型、剩余时间 |
| 已完成 | `ListTile` | 深色卡片，封面、标题、风格/模型/时长、时间、播放按钮 |
| 专辑 | 普通 Grid 卡 | 大封面专辑卡 + 创建专辑渐变按钮 |
| 空态 | 整页 `AppStateBuilder` | 分区空态，专辑空态仍展示创建入口 |

## 3. 页面结构

```text
SongWorksPage
  SafeArea
  Column/ListView
    PageTitle 作品
    AppSegmentedTabs 歌曲/专辑
    if song:
      GeneratingSection
      CompletedSection
    if album:
      AlbumGridOrEmpty
      CreateAlbumButton
```

## 4. Controller 状态

`SongWorksController` 需要：

- `selectedTab`
- `loading`
- `errorMessage`
- `works`
- `albums`
- `generatingWorks`
- `completedWorks`
- `creatingAlbum`

分组规则：

- `generatingWorks`: `status` 非 `SUCCEEDED` 且非失败/隐藏，可包括 `CREATED/POINTS_FROZEN/LYRICS_GENERATING/MUSIC_GENERATING/RESOURCE_SAVING`。
- `completedWorks`: `playable == true`。
- `failed/hidden` 本页 v1 可不展示，后续作品详情再处理。

## 5. 歌曲 Tab UI

生成中分组：

- 标题：`生成中 · N 首`。
- 卡片高度约 76-92.h。
- 左侧封面占位：圆角方块，深色圆点。
- 标题：单行省略。
- 进度条：使用 `AppGradientProgressBar`。
- 百分比：绿色文字。
- 模型和剩余时间：紫灰文字，如 `Mureka V7 · 剩余1分18秒`。

进度降级：

- `progressPercent` 有值：直接展示。
- 无值：根据状态映射默认百分比。
- `estimatedRemainingSeconds` 无值：不展示剩余时间或显示 `生成中`。

已完成分组：

- 标题：`已完成 · N 首`。
- 卡片：封面渐变占位/网络图、标题、风格/模型/时长、时间、圆形播放按钮。
- 点击整卡进入播放器；点击播放按钮也进入播放器或启动播放。

## 6. 专辑 Tab UI

有数据：

- 两列或单列卡片按设计稿优先一列左对齐展示。
- 封面区域使用渐变和音符占位。
- 标题、歌曲数量、创建日期。
- 点击进入专辑详情。

无数据：

- 显示 `暂无专辑` 空态。
- 保留醒目的 `创建专辑` 渐变按钮。

创建专辑：

- 当前可保留 Dialog，但视觉要更接近设计稿：深色背景、输入框、取消/创建按钮。
- 字段：专辑名称；简介/封面可在后续详情模块补。
- 成功后切到专辑 Tab 并插入新专辑。

## 7. 交互规则

| 操作 | 行为 |
|------|------|
| 切歌曲/专辑 | 更新 `selectedTab`，不重复请求 |
| 下拉/重试 | 调用 `load()` 重新加载作品和专辑 |
| 生成中卡 | 进入生成详情或生成中页 |
| 已完成卡 | 进入播放器 |
| 创建专辑 | 调用 `SongAPI.createAlbum` |
| 作品空态去写歌 | 调用 `onCreateTap` 切写歌 Tab |

## 8. 实现步骤

1. 扩展 Controller 作品分组 getter。
2. 替换 Material `SegmentedButton` 为 `AppSegmentedTabs`。
3. 重写歌曲 Tab：生成中分组 + 已完成分组。
4. 重写专辑 Tab：专辑卡 + 创建专辑按钮。
5. 调整 Dialog 样式或创建底部 Sheet。
6. 补列表底部 padding，避让底部 Tab。

## 9. 验收标准

- [ ] 375x812 下作品页结构与 `作品-作品.png` 一致。
- [ ] 歌曲/专辑分段样式与写歌页一致。
- [ ] 生成中和已完成可同时展示。
- [ ] 生成中卡有进度条和百分比。
- [ ] 专辑页与 `作品-专辑.png` 主结构一致。
- [ ] 创建专辑入口始终可见或易发现。
- [ ] 空态不会让整页空白。
- [ ] `flutter analyze` 无新增问题。

## 10. CHG-0056 播放器“生成同款”入口

- 播放器按钮在隐私与登录门禁通过后重新读取完整作品详情；失败时留在当前页并提示，不用列表壳数据直接进入。
- 成功后以 `mode=custom` 和路由 `extra=SongWorkDetail` 打开写歌页；歌词、参考音频 URL 等私有内容不得进入 query。
- 配置歌曲或公开可读作品继续使用相同入口，但仅消费详情接口允许返回的数据；非所有者不会收到私有参考音频。
- “生成同款”只创建可编辑的新表单，提交创建新作品；不得修改、重新生成或覆盖来源作品。

## 11. CHG-0060 播放器歌词时间轴异步轮询

- App 通过 `POST /api/song-works/{id}/timeline-regeneration-tasks` 创建或复用活动任务，不再由播放器调用同步时间轴重生接口。
- `PENDING/RUNNING` 期间每 3 秒查询指定任务；`SUCCEEDED` 后重拉作品详情并同步播放缓存、当前作品与列表。
- `FAILED` 展示后端失败摘要；连续轮询最长 15 分钟，超时后告知用户任务仍在生成，页面销毁时取消当前 Controller 轮询。
- 已有真实时间轴仍先确认积分；无时间轴或估算时间轴不额外加载计费配置。

## 12. CHG-0061 封面海报异步任务轮询

- 播放器与作品详情通过 `POST /api/song-works/{id}/cover-regeneration-tasks` 创建或复用活动任务，不再从页面等待同步封面接口返回。
- `PENDING/RUNNING` 期间每 3 秒查询 `/api/song-works/cover-regeneration-tasks/{taskId}`；`SUCCEEDED` 后重拉作品详情并失效稳定封面缓存键。
- 播放器成功后同步播放缓存、当前作品与列表；作品详情沿用原同步边界，只更新详情和作品 Store，不重写正在播放的旧缓存。
- `FAILED` 展示后端失败摘要；连续轮询最长 15 分钟，超时提示稍后再试，Controller 销毁时取消轮询。
- 已有封面仍先按当前计费配置确认积分；缺失封面直接创建任务，重复点击和同作品活动任务保持幂等。
