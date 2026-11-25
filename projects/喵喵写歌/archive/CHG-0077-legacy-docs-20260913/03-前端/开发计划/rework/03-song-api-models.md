# 03 Song API Models 返工模块开发文档

> 关联任务：CHG-0011 / Song API Models  
> 当前状态：done  
> 后端工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/models/data/song.dart`、`lib/apis/song.dart`、`lib/store/song.dart`、必要时 `lib/models/params/song_generation_params.dart`

## 1. 模块目标

补齐 Flutter 侧接口模型和 API 消费能力，让 UI 页面能真实读取后端已有数据，不在页面里写死假业务。

本模块不改 Java 后端；只消费已存在或已规划的接口。

## 2. 现状偏差

| 能力 | 后端当前状态 | Flutter 当前状态 | 返工需要 |
|------|--------------|------------------|----------|
| 模型列表 | 已有 | 已有 | 保留 |
| 情景模板 | 已有 | 已有 | 保留 |
| 示例歌曲 | 已有 | 已有 | 可降级用于热门案例 |
| 灵感速递 | 已有 | 已有 | 保留 |
| 热门案例 | 已有 `/api/song-cases` | 未封装 | 补模型/API/Store |
| 最近作品 | 已有 `/api/song-works/recent` | 未封装 | 补 API/Store |
| AI 帮写 | 已有 `/api/song-lyrics/assist` | 未封装 | 补请求/响应 |
| 生成进度 | 后端响应已有字段 | Flutter 模型缺字段 | 补字段 |
| 作品收藏/分享/重生 | 后端已有 | 主页面暂不强依赖 | 后续播放器/详情补 |

## 3. 模型定义

### 3.1 `SongCase`

字段建议：

- `id`
- `caseCode`
- `title`
- `subtitle`
- `bannerUrl`
- `coverUrl`
- `prompt`
- `styleTags`
- `sceneCode`
- `enabled`

用途：

- 首页热门案例卡
- 案例详情页
- 使用模板回填写歌页

兼容：

- 后端字段缺失时使用空字符串/空数组。
- 首页卡片标题为空时显示 `未命名案例`。

### 3.2 `SongLyricAssistResult`

字段建议：

- `title`
- `lyrics`
- `styleTags`
- `prompt`

用途：

- 高级创作页 AI帮写后回填歌词、标题、曲风标签。

兼容：

- 若只返回 `lyrics`，只回填歌词。
- 若返回空，toast 提示“暂未生成歌词”。

### 3.3 `SongGenerationTask`

补字段：

- `progressPercent`
- `stageText`
- `estimatedRemainingSeconds`

用途：

- 生成中页
- 作品页生成中卡

兼容：

- `progressPercent` 缺失时根据状态降级：创建/冻结 8，生成歌词 25，生成音乐 60，保存资源 88，成功 100。
- `stageText` 缺失时根据状态映射中文阶段。

### 3.4 `SongWorkListItem`

补字段：

- `favorite`
- `createdAtText` 或保留原始 `createdAt`
- `progressPercent`
- `stageText`
- `estimatedRemainingSeconds`

用途：

- 作品页已完成/生成中分组。

兼容：

- 若后端作品列表暂不含生成进度，生成中卡可以使用状态映射默认值。

## 4. API 封装

在 `SongAPI` 增加：

| 方法 | 路径 | 返回 |
|------|------|------|
| `fetchCases()` | `GET /api/song-cases` | `List<SongCase>` |
| `fetchCaseDetail(String id)` | `GET /api/song-cases/{id}` | `SongCase` |
| `fetchRecentWorks({int limit = 3})` | `GET /api/song-works/recent?limit=3` | `List<SongWorkListItem>` |
| `assistLyrics(...)` | `POST /api/song-lyrics/assist` | `SongLyricAssistResult` |

错误处理：

- API 层只解析，不吞异常。
- Controller 捕获 `ApiException` 并展示 `CustomToast.fail` 或进入 error 状态。

## 5. Store 调整

`SongConfigStore`：

- 新增 `cases` 缓存。
- `loadAll()` 可继续加载模型/情景/示例，不强制加载案例，避免首页独立错误影响写歌页。

`SongWorkStore`：

- 新增 `recentWorks`。
- `loadWorksAndAlbums()` 保持不变。
- 新增 `loadRecentWorks()`，首页调用。

## 6. 实现步骤

1. 扩展 `SongGenerationTask` 和 `SongWorkListItem` 字段。
2. 新增 `SongCase`、`SongLyricAssistResult`。
3. 扩展 `SongAPI` 四个方法。
4. 扩展 `SongConfigStore` 和 `SongWorkStore`。
5. 补最小单元测试或现有 model parse 测试，确保缺字段不崩。

## 7. 验收标准

- [ ] 后端已有接口路径在 Flutter API 有封装。
- [ ] JSON 缺字段时模型能安全解析。
- [ ] 首页可拿到热门案例或安全空态。
- [ ] 首页可拿到最近作品或安全空态。
- [ ] 写歌高级页 AI帮写有 API 方法可调用。
- [ ] 生成中进度字段在 Flutter 模型存在。
- [ ] `flutter analyze`、`flutter test` 无新增问题。
