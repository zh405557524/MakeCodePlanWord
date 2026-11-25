# 07 Web/Admin 翻唱管理接口模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-07
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块为 `/Users/soul/code/lxwx/lxwx_admin` 提供翻唱模型、音色和作品管理接口。

## 2. 模型配置接口

建议接口：

- `GET /admin/song-cover/models`
- `POST /admin/song-cover/models`
- `PUT /admin/song-cover/models/{id}`
- `POST /admin/song-cover/models/{id}/enable`
- `DELETE /admin/song-cover/models/{id}`

字段：

- `provider`
- `model`
- `displayName`
- `pricePoints`
- `enabled`
- `sortOrder`

## 3. 音色配置接口

建议接口：

- `GET /admin/song-cover/voices`
- `POST /admin/song-cover/voices`
- `PUT /admin/song-cover/voices/{id}`
- `POST /admin/song-cover/voices/{id}/enable`
- `DELETE /admin/song-cover/voices/{id}`

字段：

- `name`
- `group`
- `tags`
- `avatarUrl`
- `previewAudioUrl`
- `promptTemplate`
- `enabled`
- `sortOrder`

## 4. 作品管理接口扩展

现有作品管理补：

- 筛选：`songType=ORIGINAL/COVER/INSTRUMENTAL`。
- 返回：来源作品、目标音色、消耗积分、任务状态。
- 详情：翻唱设置、Provider 信息、资源持久化地址。

## 5. 权限规则

- 超级管理员可管理所有 App。
- 普通管理员根据角色授权查看对应模块。
- App 切换后只操作当前 App schema。
- 所有写操作记录操作日志。

## 6. 实现步骤

1. 增加 Admin Controller。
2. 复用用户端 Service，增加后台专用查询。
3. 接入角色权限点，例如 `catsinger:cover:config`。
4. 作品管理接口补筛选字段。
5. 补操作日志。

## 7. 验收标准

- Admin 切到 catsinger 后能维护翻唱音色。
- 停用音色后用户端不再返回。
- 作品管理能筛选翻唱作品。
