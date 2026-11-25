# 05 安全隔离与测试模块开发文档

> 对应任务：T-B007

## 1. 功能定位与边界

本模块负责覆盖 `catcomic` 请求头、schema 路由、匿名读取、登录读取和跨 App 隔离测试。

边界：

- 只补测试和必要的安全配置。
- 不改变现有 token 签发逻辑。
- 不放宽需要登录的旧接口。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| 安全配置 | `common/security/SecurityConfig.java` |
| AppCode | `common/context/AppCodeFilter.java` |
| JWT | `common/security/JwtAuthenticationFilter.java` |
| 测试 | `CatcomicAssetIntegrationTests`、`SchemaRoutingIntegrationTests`、`CommonRequestHeaderIntegrationTests` |

## 3. 接口契约

测试覆盖接口：

- `GET /api/config/home-case-categories`
- `GET /api/config/home-cases`
- `GET /api/comic/assets/tabs`
- `GET /api/comic/assets`
- `GET /api/comic/assets/{assetId}`

## 4. 数据表与迁移

测试依赖 `catcomic` schema 中：

- `users`
- `app_configs`
- `home_case_categories`
- `home_hot_cases`
- `comic_assets`

测试可通过 Repository 或 JdbcTemplate 写入测试数据；这属于测试运行时数据，不属于迁移脚本内置业务数据。

## 5. 业务规则与状态流转

- 缺少 `X-App-Code` 拦截在 AppCodeFilter。
- 未知 appCode 拦截在 AppCodeFilter 或 schema routing 属性校验。
- `catcomic` 与 `narrate`、`catsinger` 相互隔离。
- token appCode 与请求头不一致时，不扩展用户资产可见范围。

## 6. 异常处理与日志要求

- 断言错误响应不泄露数据库信息。
- 测试日志不输出 token 明文。

## 7. 依赖前置

- T-B001~T-B006 完成。

## 8. 建议实现步骤

1. 补测试配置 `catcomic` mapping。
2. 编写资产接口 MockMvc 集成测试。
3. 补 schema 表存在性断言。
4. 覆盖缺头、未知 appCode 和非法 assetType。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B007-1 | 请求头测试 | 缺头、未知、合法覆盖 |
| T-B007-2 | schema 测试 | `catcomic` 表存在且不污染其它 schema |
| T-B007-3 | 资产测试 | tabs/list/detail/非法参数覆盖 |
| T-B007-4 | 可见性测试 | 不可见资产按不存在处理 |

## 10. 测试要求

必须运行：

```bash
./gradlew test
```

代码完成后再运行：

```bash
./gradlew build
git diff --check
```

## 11. 验收标准

- 关键集成测试通过。
- appCode 隔离失败时测试能暴露问题。
- 不破坏旧测试。

## 12. 编码注意事项

- 普通 API 测试必须带 `X-App-Code`。
- 不跨所有 schema 扫描数据。
- 测试插入数据只在测试事务或测试 schema 内完成。
