# 02 歌曲配置与热门案例模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B002
> 状态：done

## 功能定位

给 App 提供模型、情景、示例、灵感、热门案例、最近作品入口数据。配置由后台维护，App 不写死价格和素材。

## Controller / Service

| 层 | 类 |
|----|----|
| Controller | `SongConfigController`、`SongCaseController` |
| Service | `SongConfigService`、`SongCaseService`、`SongWorkService` |
| Repository | `SongModelConfigRepository`、`SongScenarioRepository`、`SongExampleRepository`、`SongCaseRepository` |

## 接口契约

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/song-config/models` | 返回启用模型、价格、默认模型 |
| GET | `/api/song-config/scenarios` | 返回情景和问题 |
| GET | `/api/song-config/examples` | 返回首页示例歌曲 |
| GET | `/api/song-config/inspiration` | 返回灵感速递 |
| GET | `/api/song-cases` | 返回热门案例 |
| GET | `/api/song-cases/{id}` | 返回案例详情 |
| GET | `/api/song-works/recent` | 返回首页最近作品 |

## 业务规则

- 模型默认价格缺失时使用后台配置默认值，开发期可用 100 积分。
- 示例、案例为空时返回空数组，不抛错。
- 下架模型、案例、示例不返回给用户端。
- 案例详情可带 `prompt`、`styleTags`、`exampleWorkId`。

## 实现步骤

1. 拆分当前 `SongService` 配置查询逻辑。
2. 新增 `SongCaseEntity/Repository/Service/Controller`。
3. 最近作品复用 `SongWorkService.listRecent(userId, limit)`。
4. 补响应 VO 和空态兜底。

## 测试要求

- 模型默认模型仅一个。
- 配置为空时返回空数组。
- 灵感配置非法 JSON 返回内置兜底。
- 案例下架后用户端不可见。

## 验收标准

首页和写歌页所需配置接口都可返回，并且不依赖旧 narrate 数据。
