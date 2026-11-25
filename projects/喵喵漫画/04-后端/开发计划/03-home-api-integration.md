# 03 首页接口联调模块开发文档

> 对应任务：T-B003
> 前端引用：`03-前端/开发计划/05-home-data.md`

## 1. 功能定位与边界

本模块负责确认现有首页接口在 `X-App-Code: catcomic` 下可用。

边界：

- 复用现有 `HomeCasePublicController` 和 `HomeCaseService`。
- 不新建首页 Controller。
- 不新增首页写接口。
- 不强制首页有运营数据；无数据返回空数组。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| Controller | `app/narrate/homecase/controller/HomeCasePublicController.java` |
| Service | `app/narrate/homecase/service/HomeCaseService.java` |
| Entity | `HomeCaseCategoryEntity`、`HomeHotCaseEntity` |
| Repository | `HomeCaseCategoryRepository`、`HomeHotCaseRepository` |
| 迁移 | `db/migration/catcomic/V14__catcomic_home_assets.sql` |
| 测试 | 首页 catcomic 集成测试 |

## 3. 接口契约

### GET `/api/config/home-case-categories`

请求头：

```text
X-App-Code: catcomic
```

响应：

```json
{
  "code": 200,
  "message": "成功",
  "data": [],
  "traceId": "trace-id"
}
```

有数据时数组项：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string / number | 沿用现有返回 |
| `categoryCode` | string | 分类编码 |
| `categoryName` | string | 分类名 |
| `sortOrder` | number | 排序 |
| `hotTab` | boolean | 是否热门 Tab |

### GET `/api/config/home-cases?categoryCode=hot`

响应无数据时 `data=[]`，不报错。

### GET `/api/config/home-cases/{caseId}`

P0 前端可不依赖详情。不存在或不可用返回统一业务错误。

### POST `/api/config/home-cases/{caseId}/use`

P0 前端默认不调用，避免误导为真实创作或生成。

## 4. 数据表与迁移

依赖 `catcomic` schema 中：

- `home_case_categories`
- `home_hot_cases`
- `home_case_operation_logs`

迁移脚本只建表和索引，不插入首页分类或示例案例。

## 5. 业务规则

- `HomeCaseService` 通过 `AppContext.appCode()` 读取 `catcomic`。
- 分类只返回 `status=ACTIVE`。
- 案例只返回 `status=PUBLISHED`、未软删除、未到定时发布时间之后的数据。
- 找不到分类时案例列表返回空数组。

## 6. 异常处理与日志

- 首页列表空态不记错误日志。
- 详情不可用返回 `NOT_FOUND` 业务错误。
- 不输出 SQL 细节给前端。

## 7. 依赖前置

- T-B001：`catcomic` mapping 生效。
- T-B002：首页表在 `catcomic` schema 存在。

## 8. 建议实现步骤

1. 确认 `HomeCasePublicController` 仍在 `/api/config`。
2. 编写 catcomic 空态集成测试。
3. 如现有 Service 对空分类已有返回空数组逻辑，保持不改。
4. 确认没有调用使用统计接口的前端强依赖。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B003-1 | 分类接口 catcomic 空态测试 | 返回 `200` 和空数组 |
| T-B003-2 | 案例接口 catcomic 空态测试 | 返回 `200` 和空数组 |
| T-B003-3 | 详情不可用测试 | 返回统一错误 |

## 10. 测试要求

- 带 `X-App-Code: catcomic` 请求分类和列表。
- 缺少 `X-App-Code` 返回 400。
- `X-App-Code: catsinger` 不读取 catcomic 首页数据。

## 11. 验收标准

- 首页前端 T-F005 可直接联调分类和案例列表。
- 无数据时不阻塞首页展示。
- 复用接口不影响 `narrate` 现有首页行为。

## 12. 编码注意事项

- 首页接口继续保留在现有模块，避免复制一套 Controller。
- 不在本模块扩展生成、作品、会员或支付能力。
