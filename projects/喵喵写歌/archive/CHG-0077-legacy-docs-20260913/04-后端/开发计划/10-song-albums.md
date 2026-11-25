# 10 专辑接口模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B010
> 状态：done

## 功能定位

支持用户创建专辑、查看专辑、添加歌曲、移出歌曲。

## 接口契约

| 方法 | 路径 |
|------|------|
| GET | `/api/song-albums` |
| POST | `/api/song-albums` |
| GET | `/api/song-albums/{id}` |
| POST | `/api/song-albums/{id}/songs` |
| DELETE | `/api/song-albums/{id}/songs/{songId}` |

## 业务规则

- 专辑归属当前用户。
- 同一首歌不能重复加入同一专辑。
- 隐藏作品不能加入新专辑。
- v1 支持封面和简介字段，但高级排序可后续扩展。

## 实现步骤

1. 拆 `SongAlbumService`。
2. 补专辑详情聚合歌曲列表。
3. 添加/移除歌曲写 `catsinger_song_album_items`。
4. 创建专辑支持封面资源可选。

## 测试要求

- 重复添加返回业务错误。
- 越权专辑不可访问。
- 删除关系后详情不再返回该歌曲。

## 验收标准

作品页 Album Tab 和专辑详情可联调。
