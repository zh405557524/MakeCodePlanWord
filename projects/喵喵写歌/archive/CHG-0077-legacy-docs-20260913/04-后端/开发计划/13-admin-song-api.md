# 13 Admin Song API 模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B013
> 状态：done

## 功能定位

给运营后台维护和查看喵喵写歌业务数据：模型、案例、情景、示例、灵感、任务、作品、专辑、商品。

## 接口范围

| 模块 | 路径 |
|------|------|
| 模型 | `/api/admin/song/models` |
| 案例 | `/api/admin/song/cases` |
| 情景 | `/api/admin/song/scenarios` |
| 示例 | `/api/admin/song/examples` |
| 灵感 | `/api/admin/song/inspirations` |
| 任务 | `/api/admin/song/generations` |
| 作品 | `/api/admin/song/works` |
| 专辑 | `/api/admin/song/albums` |
| 商品 | `/api/admin/products` |

## 业务规则

- 后台请求按 `X-App-Code` 操作对应 schema。
- 配置保存失败时返回字段级错误，不吞异常。
- 任务/作品/专辑查询支持状态、用户、时间范围过滤。
- 隐藏作品、上下架配置需要写操作日志。

## 实现步骤

1. 扩展 `AdminSongConfigController` 到案例和灵感。
2. 新增任务、作品、专辑 Admin Controller。
3. 接入权限模块。
4. 补列表分页和筛选。

## 测试要求

- App 切换后数据不串。
- 无权限访问被拒绝。
- 上下架后用户端不可见。
- 任务失败原因和 provider trace 后台可见。

## 验收标准

运营可用后台配置首页和写歌页素材，并查看生成任务和作品。
