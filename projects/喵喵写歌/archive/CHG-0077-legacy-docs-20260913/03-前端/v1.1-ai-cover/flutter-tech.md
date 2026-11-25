# 喵喵写歌 v1.1 AI 翻唱 Flutter 技术文档

> V2.1 名称校准：本文件描述的旧链路现称“AI 改编”，不包含声音克隆；仅作实现差异参考，禁止用于 V2.1 新“AI 翻唱（声音克隆）”编码。
> 版本：`v1.1-ai-cover`
> 变更：`CHG-0013 AI 翻唱功能`
> 状态：`reference-only`
> 创建日期：2026-06-25
> 关联需求：`../../01-需求/v1.1-ai-cover/requirements.md`
> 关联技术方案：`../../02-技术方案/v1.1-ai-cover/tech-plan.md`
> 目标工程：`/Users/soul/code/lxwx/catsinger`

---

## 1. 当前 Flutter 技术路线

当前 App 继续复用 `/Users/soul/code/lxwx/catsinger` 工程。

| 项 | 方案 |
|----|------|
| SDK | Flutter / Dart `^3.11.4` |
| 状态管理 | GetX，页面状态放 Controller |
| 路由 | go_router，路由名集中在 `RouteName` |
| 网络 | Dio，接口封装在 `lib/apis/` |
| 本地存储 | GetStorage + Hive |
| UI 适配 | flutter_screenutil，375x812 基准 |
| 音频播放 | audioplayers |
| 录音/媒体能力 | record、image_picker、wechat_assets_picker、permission_handler |
| 本地音频选择 | v1.1 可引入 `file_picker`；如不引入，则使用系统媒体选择能力并记录限制 |

---

## 2. 项目结构与落点

```text
lib/
├── apis/
│   └── song.dart
├── models/
│   ├── data/
│   │   └── song.dart
│   └── params/
│       └── song_generation_params.dart
├── pages/
│   ├── song_home/
│   ├── song_cover/
│   │   ├── index.dart
│   │   ├── controller.dart
│   │   ├── view.dart
│   │   └── widgets/
│   ├── song_works/
│   └── main/
├── routes/
├── store/
└── widgets/
```

模块职责：

- `song_home`：展示 AI 翻唱入口卡。
- `song_cover`：AI 翻唱三步流程、生成中、结果页。
- `song_works`：展示 `songType` 和重新翻唱入口。
- `apis/song.dart`：封装翻唱相关接口。
- `models/data/song.dart`：补充音色、任务、作品字段。
- `store/song.dart`：缓存模型配置、音色列表、作品刷新状态。

---

## 3. 路由设计

### 3.1 路由清单

| 路由名 | 路径 | 页面 | 参数 |
|--------|------|------|------|
| `RouteName.songCover` | `/song/cover` | AI 翻唱页 | `extra` 传初始来源 |
| 既有作品详情 | 既有 | 作品详情 / 播放页 | 传 `workId` |

### 3.2 路由参数

进入 `/song/cover` 时支持 `extra`：

```dart
{
  'initialSourceWorkId': 'work id',
  'initialSourceTitle': '作品标题',
  'from': 'home|work_detail|cover_result'
}
```

规则：

- 首页进入时不传来源。
- 作品详情或结果页重新翻唱时，传 `initialSourceWorkId`。
- Controller 初始化时读取 extra，若存在源作品，自动选中作品来源。

---

## 4. 页面状态设计

### 4.1 `SongCoverController` 状态

| 状态字段 | 类型建议 | 说明 |
|----------|----------|------|
| `step` | int | 1 上传歌曲、2 选择音色、3 高级设置 |
| `sourceMode` | enum | `work` 或 `localAudio` |
| `selectedSourceWork` | SongWorkListItem? | 作品库来源 |
| `uploadedSourceAsset` | SongAsset? | 本地上传来源 |
| `copyrightConfirmed` | bool | 版权确认 |
| `voices` | List<CoverVoiceConfig> | 启用音色 |
| `selectedVoice` | CoverVoiceConfig? | 当前音色 |
| `preserveOriginalLyrics` | bool | 默认 true |
| `preserveOriginalAccompaniment` | bool | 默认 true |
| `pitchShift` | int | -6 到 +6 |
| `emotionIntensity` | String | soft/standard/passionate |
| `reverb` | String | off/studio/concert |
| `estimatedPointCost` | int | 默认 150，后端配置优先 |
| `isLoadingWorks` | bool | 作品库 loading |
| `isUploading` | bool | 上传中 |
| `isLoadingVoices` | bool | 音色 loading |
| `isSubmitting` | bool | 创建任务中 |
| `task` | SongGenerationTask? | 当前任务 |
| `resultWork` | SongWorkDetail? | 成功后的作品详情 |
| `playerMode` | enum | 原版/翻唱版 |

### 4.2 按钮可用性

| 页面 | 按钮 | 可用条件 |
|------|------|----------|
| 第 1 步 | 下一步 | 已有源作品或已上传音频，且版权确认 |
| 第 2 步 | 下一步 | 已选择启用音色 |
| 第 3 步 | 开始翻唱 | 未提交中，源音频、版权、音色均有效 |
| 生成中 | 查看作品 | 任务成功 |
| 结果页 | 下载 | 翻唱音频资源可用 |
| 结果页 | 重新翻唱 | 当前作品有音频资源 |
| 结果页 | 删除 | 当前作品存在且归属当前用户 |

---

## 5. 页面实现摘要

### 5.1 首页 AI 翻唱入口

入口来源：

- App 默认进入首页。
- 底部 Tab 返回首页。

技术实现：

- 在首页快捷功能区上方或设计稿指定位置加入 `AI 翻唱` 横向卡。
- 点击卡片调用 `MainController.openCover(context)` 或直接 `context.pushNamed(RouteName.songCover)`。
- 未登录时走现有登录守卫。

按键交互：

- 卡片和右箭头点击行为一致。
- 功能开关关闭时卡片置灰并 toast。

### 5.2 第 1 步：上传歌曲

入口来源：

- 首页 AI 翻唱。
- 作品详情重新翻唱。
- 结果页重新翻唱。

UI 区块：

- 顶部返回。
- 步骤条。
- 作品库选择框。
- 本地上传框。
- 版权确认。
- 底部下一步。

技术实现：

- 作品库读取已完成作品，优先复用 `SongWorkStore` 或新增 `fetchCoverSourceWorks`。
- 本地上传先做扩展名和大小预校验，再调用后端上传接口。
- 上传成功后保存 `sourceAudioAssetId`。
- 作品库来源和本地上传来源互斥。

状态：

- loading：作品库加载中、上传中。
- empty：作品库为空。
- error：作品库加载失败、上传失败。
- disabled：下一步不可用。

### 5.3 第 2 步：选择音色

入口来源：

- 第 1 步下一步。
- 第 3 步返回。

技术实现：

- 页面进入时调用 `SongAPI.fetchCoverVoices()`。
- 按 `groupCode` 分组展示。
- 点击试听播放 `auditionAudioUrl`。
- 点击卡片选择音色。

状态：

- 音色列表为空时展示空态。
- 试听失败只 toast，不影响选择。
- 禁用音色不展示。

### 5.4 第 3 步：高级设置

入口来源：

- 第 2 步下一步。

技术实现：

- 所有设置先保存在 Controller 本地状态。
- 积分消耗从模型配置读取，缺失时兜底显示 150。
- 点击开始翻唱生成 idempotencyKey，调用 `SongAPI.createCover()`。
- 创建成功进入生成中。

提交参数：

- `mode=cover`
- `provider=minimax`
- `model=music-cover`
- `sourceWorkId/sourceAudioAssetId`
- `copyrightConfirmed`
- `coverVoiceCode`
- `preserveOriginalLyrics`
- `preserveOriginalAccompaniment`
- `pitchShift`
- `emotionIntensity`
- `reverb`
- `idempotencyKey`

### 5.5 生成中页面

入口来源：

- 第 3 步创建任务成功。
- 作品列表点击生成中任务。

技术实现：

- 轮询 `GET /api/song-covers/{id}`。
- 状态成功时获取作品详情并进入结果页。
- 状态失败时展示失败原因。
- 用户关闭页面后任务继续，作品页展示生成中卡片。

### 5.6 翻唱结果页

入口来源：

- 生成中成功。
- 作品列表点击翻唱作品。
- 通知入口。

技术实现：

- 默认选中翻唱版。
- 原版/翻唱版切换维护当前播放器 URL。
- 下载、分享、收藏、删除复用作品接口。
- 重新翻唱带当前作品作为 `initialSourceWorkId` 进入 `/song/cover`。

### 5.7 作品联动

技术实现：

- `SongWorkListItem` 和 `SongWorkDetail` 增加 `songType`。
- 作品卡展示类型标签。
- 翻唱作品展示 `coverVoiceName`。
- 生成中卡展示 `stageText`、`progressPercent`、`estimatedRemainingSeconds`。

---

## 6. 数据模型

### 6.1 `CoverVoiceConfig`

```dart
class CoverVoiceConfig {
  final String voiceCode;
  final String displayName;
  final String groupCode;
  final List<String> tags;
  final String? iconUrl;
  final String? auditionAudioUrl;
  final String? promptTemplate;
  final bool enabled;
  final int sortOrder;
}
```

### 6.2 `CreateCoverRequest`

可复用 `CreateSongGenerationParams`，补充 cover 字段；或单独建 `CreateCoverRequest` 后由 API 转换。

关键字段：

- `sourceWorkId`
- `sourceAudioAssetId`
- `copyrightConfirmed`
- `coverVoiceCode`
- `preserveOriginalLyrics`
- `preserveOriginalAccompaniment`
- `pitchShift`
- `emotionIntensity`
- `reverb`
- `idempotencyKey`

### 6.3 作品字段

`SongWorkListItem` / `SongWorkDetail` 增加：

- `songType`
- `sourceWorkId`
- `sourceAudioAssetId`
- `originalAudioUrl`
- `coverVoiceCode`
- `coverVoiceName`
- `coverSettingsJson`
- `pointCost`

---

## 7. API 封装

`lib/apis/song.dart` 增加：

| 方法 | HTTP | 路径 |
|------|------|------|
| `fetchCoverVoices()` | GET | `/api/song-cover/voices` |
| `uploadCoverSourceAudio(file)` | POST multipart | `/api/song-assets/cover-source-audios` |
| `createCover(params)` | POST | `/api/song-covers` |
| `fetchCoverTask(id)` | GET | `/api/song-covers/{id}` |

错误处理：

- 401：走登录。
- 400：展示后端校验文案。
- 402/积分不足：打开充值或会员引导。
- 网络错误：toast + 保留页面状态。

---

## 8. UI 适配与视觉口径

设计稿实际约 392x846 到 402x848，开发按 375x812 主基准适配。

规则：

- 统一使用 `.w/.h/.sp/.r`。
- 底部固定按钮避让安全区。
- 作品库展开后列表滚动，不遮挡版权确认和底部按钮。
- 长标题最多两行，结果页操作栏不溢出。
- 页面背景、卡片、绿色高亮、紫灰文字沿用 v1.0 UI foundation。
- 文案统一显示“最长 6 分钟”，不沿用设计稿中的 10 分钟。

---

## 9. 项目专属开发规则

继承规则：

- 目录结构：`pages/{feature}/index.dart + controller.dart + view.dart`。
- 状态管理：GetX Controller。
- 路由：go_router + RouteName。
- 网络：API 静态方法封装。
- 测试：改动后至少 `flutter analyze`，关键链路 `flutter test`。

项目特化：

- v1.1 不读取 CHG-0011 旧 rework 文档作为 AI 翻唱执行依据。
- UI 真源为 `01-需求/references/images/v1.1/ai翻唱/`。
- 本地音频选择若现有依赖不足，新增依赖必须先回写技术文档和开发计划。
- Provider 价格和音色均以后端配置为准，App 不写死生产数据。

---

## 10. 测试建议

### 10.1 Widget / Controller 测试

- 第 1 步按钮状态：无来源、未勾选版权、满足条件。
- 第 2 步音色分组和选中。
- 第 3 步参数变化和提交防重复。
- 结果页原版/翻唱版切换。

### 10.2 手动截图验收

- 375x812：入口、第 1 步三态、第 2 步、第 3 步、生成中、结果页。
- 390x844 / 414x896：底部按钮、长标题、操作栏、作品库展开。

### 10.3 命令验证

```bash
flutter analyze
flutter test
git diff --check
```
