# 01 AppCode 与 Schema Routing 模块开发文档

> 对应任务：T-B001
> 目标工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 当前阶段：12 Java 模块开发文档

## 1. 功能定位与边界

本模块负责让后端接受 `X-App-Code: catcomic`，并把请求路由到 PostgreSQL schema `catcomic`。

边界：

- 只新增配置映射、测试映射和启动校验。
- 不修改 `DEFAULT_APP_CODE`，避免影响老后台任务、后台管理和回调默认行为。
- 不新增业务接口。
- 不写入业务数据。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| 配置 | `src/main/resources/application.yml` |
| 测试配置 | `src/test/resources/application-test.yml` |
| 上下文 | `common/context/AppCodeFilter.java`、`common/context/AppContext.java` |
| Schema | `common/config/AppSchemaRoutingProperties.java`、`common/config/SchemaRoutingDataSourceConfig.java` |
| 测试 | `SchemaRoutingIntegrationTests`、`CommonRequestHeaderIntegrationTests` 或现有等价测试 |

## 3. 接口契约

本模块不新增接口，只影响所有 `/api/**` 的请求头校验。

| 场景 | 请求头 | 期望 |
|------|--------|------|
| 喵喵漫画请求 | `X-App-Code: catcomic` | 通过过滤器，进入 `catcomic` schema |
| 缺少请求头 | 无 | `400` / `code=-400` |
| 未配置 appCode | `X-App-Code: unknown` | `400` / `code=-400` |

与前端引用：

- `03-前端/开发计划/01-project-identity.md`
- `03-前端/开发计划/05-home-data.md`
- `03-前端/开发计划/07-asset-library-data.md`

## 4. 数据表与迁移

本模块不直接新增表。它要求后续 `02-catcomic-migration.md` 在 `db/migration/catcomic` 中补齐表结构。

## 5. 业务规则

- `application.yml` 增加：

```yaml
app:
  schema-routing:
    mappings:
      catcomic: ${CATCOMIC_DB_SCHEMA:catcomic}
```

- `application-test.yml` 增加：

```yaml
app:
  schema-routing:
    mappings:
      catcomic: catcomic
```

- `AppContext.appCode()` 在请求期应返回 `catcomic`。
- token appCode 与请求头不一致时，不认证为当前用户，保持现有 `JwtAuthenticationFilter` 行为。

## 6. 异常与日志

- 缺少或不支持 appCode 使用现有 `BizException` / `ErrorCode.BAD_REQUEST` 策略。
- 不在日志输出 Authorization、token 或敏感请求头。
- 可在测试断言中验证响应 `traceId` 存在。

## 7. 依赖前置

- `java-tech.md` 已确认 appCode 默认 `catcomic`。
- 后端工程已具备 schema routing 机制。

## 8. 建议实现步骤

1. 修改 `application.yml` mappings。
2. 修改 `application-test.yml` mappings。
3. 运行或补充 schema routing 相关测试。
4. 确认 `DEFAULT_APP_CODE` 仍为 `narrate`。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B001-1 | 主配置加入 `catcomic` mapping | `X-App-Code: catcomic` 不再 unsupported |
| T-B001-2 | 测试配置加入 `catcomic` mapping | 测试环境可创建 `catcomic` schema |
| T-B001-3 | 补请求头合法性测试 | 缺头、未知、`catcomic` 三类路径覆盖 |

## 10. 测试要求

- `GET /api/config/home-case-categories` 带 `X-App-Code: catcomic` 不因 appCode 被拒绝。
- 缺少 `X-App-Code` 返回 400。
- 未知 appCode 返回 400。

## 11. 验收标准

- `catcomic` 出现在主配置和测试配置中。
- 启动后 schema routing 能创建或访问 `catcomic` schema。
- 不影响 `narrate`、`catsinger` 现有映射。

## 12. 编码注意事项

- 不修改默认 AppCode。
- 不新增 `/api/{appCode}/...` 路径。
- 普通接口继续通过请求头完成 App 隔离。
