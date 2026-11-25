# Admin 专辑管理模块开发文档

> 关联任务：T-A008  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

后台查看用户创建的专辑和专辑内歌曲。

- 包含：专辑列表、详情、用户维度查询。
- 不包含：后台替用户创建专辑、公开专辑运营位。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_albums_page.dart` |
| Model | `song_album.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- 后端 T-B010：`GET /api/admin/song/albums`、`GET /api/admin/song/albums/{id}`。

## 4. 视觉参考与设计稿分析

App 侧参考 `04-library-album.jpeg`。后台使用表格和详情抽屉，展示专辑基础信息和歌曲列表。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongAlbumsPage` | 专辑列表 |
| `SongAlbumDetailDrawer` | 专辑详情 |

## 6. 业务内容与数据流

1. 查询当前 App 专辑列表。
2. 按用户或关键词筛选。
3. 查看专辑内歌曲。

## 7. 现有工程参考点

复用后台表格、分页、详情抽屉。

## 8. 建议实现步骤

1. 定义专辑模型。
2. 实现列表。
3. 实现详情。
4. 接入筛选。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A008-01 专辑模型 | pending |
| T-A008-02 列表查询 | pending |
| T-A008-03 详情展示 | pending |
| T-A008-04 用户筛选 | pending |

## 10. 验收标准

- [ ] 可查看专辑列表。
- [ ] 可进入专辑详情。
- [ ] 可看到专辑内歌曲。

## 11. 编码注意事项

- v1 不做公开展示、排序和封面上传。
- 保留后续扩展字段展示空间。
