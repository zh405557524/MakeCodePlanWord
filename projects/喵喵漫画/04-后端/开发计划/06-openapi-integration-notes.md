# 06 OpenAPI 与联调说明模块开发文档

> 对应任务：T-B008

## 1. 功能定位与边界

本模块负责让新增资产接口具备中文 JavaDoc / OpenAPI 可读说明，并沉淀前后端联调口径。

边界：

- 不新增 P0 之外接口。
- 不承诺生成、支付、下载、删除、编辑能力。
- 不在接口文档里给出迁移脚本写入业务数据的方案。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| Controller | `ComicAssetController.java` |
| VO | `ComicAssetTabResponse`、`ComicAssetItemResponse`、`ComicAssetDetailResponse` |
| 文档 | `README.md` 或项目接口说明区域 |
| 验证 | `/v3/api-docs` |

## 3. 接口契约汇总

| 页面 | 接口 | 必须 |
|------|------|------|
| 首页分类 | `GET /api/config/home-case-categories` | 是 |
| 首页案例 | `GET /api/config/home-cases?categoryCode=hot` | 是 |
| 资产 Tab | `GET /api/comic/assets/tabs` | 是 |
| 资产列表 | `GET /api/comic/assets?assetType=ROLE&page=1&pageSize=20` | 是 |
| 资产详情 | `GET /api/comic/assets/{assetId}` | 可选 |

统一请求头：

```text
X-App-Code: catcomic
Authorization: Bearer <token>  # 可选
```

## 4. 数据表与迁移

本模块不改表；仅引用：

- `home_case_categories`
- `home_hot_cases`
- `comic_assets`

## 5. 业务规则

- 首页和资产库读取允许匿名。
- 登录态只扩展资产可见范围。
- 空态用空数组或空分页表达。
- 其它空白页不调用后端真实能力。

## 6. 异常处理与日志

联调错误码：

| 场景 | 表现 |
|------|------|
| 缺少 `X-App-Code` | 400 |
| 未配置 `catcomic` | 400 |
| `assetType` 非法 | 400 |
| 资产不存在或不可见 | 404 语义业务错误 |
| 服务异常 | 5xx |

## 7. 依赖前置

- T-B006 资产接口完成。
- T-B007 测试通过。

## 8. 建议实现步骤

1. 给新增 Controller、VO、Service public 方法补中文 JavaDoc。
2. 确认 `/v3/api-docs` 能暴露新增接口。
3. 在 README 或接口说明中列出喵喵漫画 P0 联调接口。
4. 写明空白页不调用真实后端动作。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B008-1 | JavaDoc / OpenAPI | 新接口说明可读 |
| T-B008-2 | 联调示例 | 前端可按示例请求 |
| T-B008-3 | 文档回写 | P0 边界清晰 |

## 10. 测试要求

- 构建通过后本地访问 `/v3/api-docs`。
- 或在测试中确认 Spring context 能加载新增 Controller。

## 11. 验收标准

- 前端只依赖首页与资产库接口。
- 后端文档不包含 P0 未实现能力的调用承诺。
- 所有新增接口都有中文职责说明。

## 12. 编码注意事项

- 对外文档不要暴露内部表名以外的敏感实现细节。
- 不在示例里写真实 token、手机号、密钥或运营数据。
