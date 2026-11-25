# Admin 作品管理模块开发文档

> 关联任务：T-A007  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

后台查看和管理用户歌曲作品。

- 包含：作品列表、详情、隐藏作品、资源信息查看。
- 不包含：编辑用户生成歌词和音频。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_works_page.dart` |
| Model | `song_work.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- 后端 T-B010：`GET /api/admin/song/works`、`POST /api/admin/song/works/{id}/hide`。

## 4. 视觉参考与设计稿分析

App 侧参考 `03-library-empty-song.jpeg`、`06-library-loading.jpeg`、`09-player-song.jpeg`。后台重点看数据和资源状态。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongWorksPage` | 作品列表 |
| `SongWorkDetailDrawer` | 作品详情和资源 |

## 6. 业务内容与数据流

1. 按 selectedAppCode 查询作品。
2. 查看音频资源、自有 URL、storageProvider、resourceKey。
3. 可隐藏违规或无效作品。

## 7. 现有工程参考点

复用现有作品管理列表和确认弹窗。

## 8. 建议实现步骤

1. 定义作品模型。
2. 实现列表和详情。
3. 实现隐藏操作。
4. 展示资源字段。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A007-01 作品模型 | pending |
| T-A007-02 列表查询 | pending |
| T-A007-03 详情展示 | pending |
| T-A007-04 隐藏操作 | pending |

## 10. 验收标准

- [ ] 可查看作品状态和资源信息。
- [ ] 隐藏作品需要确认。
- [ ] 操作后写入后台日志。

## 11. 编码注意事项

- 不暴露第三方临时 URL。
- 隐藏不是物理删除。
