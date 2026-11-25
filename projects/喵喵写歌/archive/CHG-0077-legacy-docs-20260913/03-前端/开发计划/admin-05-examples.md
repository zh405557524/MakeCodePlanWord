# Admin 示例歌曲模块开发文档

> 关联任务：T-A005  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

配置首页歌曲示例，包括封面、音频、标题、风格标签、歌词和时间轴。

- 包含：示例列表、新增/编辑、上下架、歌词时间轴录入。
- 不包含：大文件上传服务本身的底层实现。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_examples_page.dart` |
| Model | `song_example.dart`, `lyric_timeline_line.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- T-A001 selectedAppCode。
- 后端 T-B010：`/api/admin/song/examples`。
- 如果音频/封面需要上传，依赖现有上传接口或后端补充资源接口。

## 4. 视觉参考与设计稿分析

App 侧参考：

- `02-explore.jpeg`：示例歌曲展示形态。
- `09-player-song.jpeg`、`10-player-lyrics.jpeg`：播放和歌词效果。

后台表单要让运营能填出这些展示数据。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongExamplesPage` | 示例歌曲列表 |
| `SongExampleForm` | 示例编辑 |
| `LyricTimelineEditor` | 时间轴录入 |

## 6. 业务内容与数据流

1. 运营录入示例歌曲素材。
2. 后端保存示例并返回给 App 首页。
3. App 可播放示例和展示歌词。

## 7. 现有工程参考点

复用后台文件选择、表单校验、标签输入组件。

## 8. 建议实现步骤

1. 定义示例歌曲模型。
2. 实现列表和上下架。
3. 实现表单。
4. 实现歌词和时间轴编辑。
5. 验证 App 首页展示。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A005-01 示例模型 | pending |
| T-A005-02 列表和状态 | pending |
| T-A005-03 编辑表单 | pending |
| T-A005-04 时间轴编辑 | pending |
| T-A005-05 素材字段校验 | pending |

## 10. 验收标准

- [ ] 可录入标题、封面、音频、风格标签。
- [ ] 可录入歌词和逐句时间轴。
- [ ] 上架示例在 App 首页展示。
- [ ] 无示例时 App 首页显示空态。

## 11. 编码注意事项

- v1 运营提供真实素材，开发期可 Mock。
- 时间轴格式必须与 App `LyricTimelineLine` 一致。
