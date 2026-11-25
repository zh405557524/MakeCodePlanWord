# 04 资产库读取接口模块开发文档

> 对应任务：T-B005、T-B006
> 前端引用：`03-前端/开发计划/07-asset-library-data.md`

## 1. 功能定位与边界

本模块负责新增喵喵漫画资产库读取接口：Tab、分页列表、详情。

边界：

- 只开放读取接口。
- 不新增创建、编辑、删除、上传、生成接口。
- 管理入口前端只空白页或 Toast，不调用后端删除。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| Controller | `app/comic/asset/controller/ComicAssetController.java` |
| Service | `app/comic/asset/service/ComicAssetService.java` |
| Entity | `app/comic/asset/entity/ComicAssetEntity.java` |
| Repository | `app/comic/asset/repository/ComicAssetRepository.java` |
| VO | `ComicAssetTabResponse`、`ComicAssetItemResponse`、`ComicAssetDetailResponse` |
| 安全 | `common/security/SecurityConfig.java` |
| 测试 | `CatcomicAssetIntegrationTests` |

## 3. 接口契约

### GET `/api/comic/assets/tabs`

鉴权：匿名可访问，但必须带 `X-App-Code`。

响应：

```json
{
  "code": 200,
  "message": "成功",
  "data": [
    {"assetType": "ROLE", "title": "角色资产", "description": "管理常用角色形象", "sortOrder": 1},
    {"assetType": "SCENE", "title": "场景资产", "description": "管理常用场景画面", "sortOrder": 2},
    {"assetType": "ITEM", "title": "物品资产", "description": "管理道具与关键物品", "sortOrder": 3}
  ],
  "traceId": "trace-id"
}
```

### GET `/api/comic/assets`

查询参数：

| 参数 | 类型 | 必填 | 默认 | 说明 |
|------|------|------|------|------|
| `assetType` | string | 否 | `ROLE` | `ROLE` / `SCENE` / `ITEM` |
| `page` | long | 否 | `1` | 最小 1 |
| `pageSize` | long | 否 | `20` | 1 到 100 |

响应：

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "items": [],
    "page": 1,
    "pageSize": 20,
    "total": 0,
    "hasMore": false
  },
  "traceId": "trace-id"
}
```

列表项字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | number | 资产 ID |
| `assetType` | string | 资产类型 |
| `assetName` | string | 展示名称 |
| `coverUrl` | string | 封面 |
| `description` | string | 简介 |
| `sourceType` | string | 来源 |
| `createdAt` | string | 创建时间 |

### GET `/api/comic/assets/{assetId}`

响应字段在列表项基础上增加：

| 字段 | 类型 | 说明 |
|------|------|------|
| `metadataJson` | string | 扩展配置，P0 原样返回字符串 |
| `updatedAt` | string | 更新时间 |

错误：

| 场景 | 响应 |
|------|------|
| `assetType` 非法 | `400` / `code=-400` |
| 资产不存在或不可见 | `400` / `code=-404` |
| 缺少或不支持 `X-App-Code` | `400` / `code=-400` |

## 4. 数据表与迁移

依赖 `comic_assets`。

查询条件：

- `app_code = AppContext.appCode()`
- `asset_type = ROLE | SCENE | ITEM`
- `status = ACTIVE`
- `deleted_at IS NULL`
- 匿名：`user_id IS NULL`
- 登录：`user_id IS NULL OR user_id = currentUser.userId()`
- 排序：`sort_order ASC, created_at DESC, id DESC`

## 5. 业务规则

- `assetType` 统一转大写并校验。
- `page < 1` 按参数错误处理，或按实现统一兜底到 1；编码时保持测试一致。
- `pageSize` 最大 100，避免大分页。
- `tabs()` 使用静态枚举，不依赖数据库。
- 登录态为可选；Controller 只传 `userId` 给 Service。

## 6. 异常处理与日志

- 参数错误抛 `BizException(ErrorCode.BAD_REQUEST, "...")`。
- 不可见资产按不存在处理。
- 列表空态不记错误日志。
- 不返回内部字段或敏感信息。

## 7. 依赖前置

- T-B002 / T-B004：表结构、Entity、Repository 完成。
- Security 允许 `/api/comic/assets/**` 匿名读取。

## 8. 建议实现步骤

1. 新增 VO record，并写中文 JavaDoc。
2. 新增 `ComicAssetService`，实现 tabs/list/detail。
3. 新增 `ComicAssetController`。
4. 在 `SecurityConfig` 显式 permit `/api/comic/assets/**`。
5. 补集成测试。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B005-1 | 实现 `tabs()` | 返回三类资产 Tab |
| T-B005-2 | 实现分页列表 | 匿名空分页稳定 |
| T-B005-3 | 实现详情可见性 | 不存在和不可见不泄露 |
| T-B006-1 | Controller 暴露三接口 | 返回 `ApiResponse` |
| T-B006-2 | VO 字段对齐前端 | Flutter 模型可直接消费 |

## 10. 测试要求

- tabs happy path。
- list 空态。
- assetType 非法。
- detail 不存在。
- 缺少 `X-App-Code`。
- 未知 `X-App-Code`。

## 11. 验收标准

- 前端资产库 T-F007 可联调。
- 三个接口均出现在 OpenAPI。
- 不提供任何写入、删除或生成能力。

## 12. 编码注意事项

- Controller 不查库。
- Service 读取 `AppContext.appCode()`。
- Repository 只继承 `BaseMapper`，简单查询不写 XML。
