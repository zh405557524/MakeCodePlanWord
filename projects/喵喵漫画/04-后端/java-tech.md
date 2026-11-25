# 喵喵漫画 Java 后端技术文档

> 版本：v1.0
> 生成日期：2026-06-10
> 关联 PRD：../01-需求/requirements.md
> 关联 Figma 设计计划：../01-需求/figma-design-plan.md
> 关联技术方案：../02-技术方案/tech-plan.md
> 关联工时评估：../02-技术方案/effort-estimate.md
> 目标工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
> 框架：Java 21 + Spring Boot 3.3.0 + Gradle + MyBatis-Plus + PostgreSQL + Redis

---

## 1. 当前后端最终技术路线

喵喵漫画后端不新建服务，基于现有 Spring Boot 工程新增 App 接入、数据迁移和资产库读取接口。

| 领域 | 最终口径 |
|------|----------|
| App 名称 | `喵喵漫画` |
| appCode | `catcomic` |
| schema | 默认 `catcomic`，通过 `CATCOMIC_DB_SCHEMA` 可覆盖 |
| 请求头 | 用户端 `/api/**` 必须携带 `X-App-Code: catcomic` |
| 后端工程 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| 基础包名 | `com.lxwx.narrateservice` |
| 启动入口 | `ServerApplication.java` |
| 构建工具 | Gradle / Gradle Wrapper |
| P0 范围 | AppCode 接入、首页数据、资产库读取、隔离测试 |
| P0 不做 | 真实 AI 生成、支付、会员扣点、作品生成、删除/下载真实动作 |

---

## 2. 通用规则继承

本阶段已按规则读取 `.cursor/rules/java/` 下 Java 技术文档要求的通用规则。进入真实编码阶段前，还必须重新从 `.cursor/rules/14-Java编码索引.mdc` 进入 Java 编码流程。

| 通用规则 | 当前项目采用方式 |
|----------|------------------|
| `01-项目初始化规则.mdc` | 不重建工程；沿用 Java 21、Spring Boot、Gradle、MyBatis-Plus、Flyway |
| `02-项目结构目录.mdc` | 包名固定 `com.lxwx.narrateservice`，新增业务包放到 `app/comic/asset` |
| `03-编码规范.mdc` | public 类和 public 方法写中文 Javadoc；Controller / Service / Repository 分层 |
| `04-路由与控制器规则.mdc` | Controller 只处理参数、鉴权对象和统一响应，业务下沉 Service |
| `05-数据库与持久化.mdc` | Flyway 新增迁移脚本；Mapper 使用 MyBatis-Plus 参数化查询 |
| `06-第三方依赖参考.mdc` | 不新增依赖，复用现有 Spring Boot、MyBatis-Plus、Redis、JWT、OpenAPI |
| `07-新接口开发.mdc` | 先确认接口契约，再写 VO / Entity / Repository / Service / Controller / Test |
| `08-鉴权与安全.mdc` | 资产读取允许匿名，仍必须通过 `X-App-Code`；登录态只扩展用户资产可见范围 |
| `09-大功能先规划再编码.mdc` | 本文档只规划 P0，不提前实现生成、作品、支付等大功能 |
| `10-编码工作流程.mdc` | 仅进入 Java 编码阶段后生效，本阶段不改后端代码 |

---

## 3. 真实工程现状

### 3.1 工程与依赖

| 文件 / 位置 | 现状 |
|-------------|------|
| `build.gradle` | Java toolchain 21，Spring Boot `3.3.0`，MyBatis-Plus `3.5.7`，JJWT `0.12.5`，springdoc `2.6.0` |
| `application.yml` | 已有 `app.schema-routing.mappings.narrate`、`catsinger`；需新增 `catcomic` |
| `application-test.yml` | 测试映射保留 `narrate`、`catsinger`，并新增 `catcomic` |
| `common/context/AppCodeFilter.java` | `/api/**` 用户端接口校验 `X-App-Code`，不支持的 appCode 直接 400 |
| `common/context/AppContext.java` | 通过 ThreadLocal 暴露当前 appCode |
| `common/config/SchemaRoutingDataSourceConfig.java` | 按 appCode 映射创建 schema 和数据源，并执行 `common + {appCode}` 迁移 |
| `common/security/SecurityConfig.java` | `/api/config/**` 匿名；其它未显式保护接口当前 `anyRequest().permitAll()` |
| `common/response/ApiResponse.java` | 统一响应：`{ code, message, data, traceId }`，成功码为 `200` |
| `common/response/PageResult.java` | 分页响应：`{ items, page, pageSize, total, hasMore }` |
| `app/narrate/homecase` | 已有首页分类与热门案例公共接口，可复用 Service 逻辑 |
| `app/catsinger/song` | 已有按 App 新增业务包的参考结构，可参考包组织方式 |

### 3.2 关键差异

当前 `home_case_categories`、`home_hot_cases`、`home_case_operation_logs` 表在 `db/migration/narrate/V2__narrate_schema.sql` 中，不在 `common` 迁移里。因此只在 `application.yml` 增加 `catcomic` mapping 不足以让首页接口可用。

后续编码必须为 `catcomic` 新增 App 专属迁移，至少包含：

- 首页三张表：`home_case_categories`、`home_hot_cases`、`home_case_operation_logs`
- 资产库表：`comic_assets`
- 必要索引、约束和字段注释

迁移脚本只负责表结构，不在 SQL 迁移中直接插入业务数据、JSON 配置、首页分类、示例案例或示例资产。业务数据可以通过后端代码、后台接口、初始化服务或运营导入流程添加；应用运行时正常写入数据不受此限制。

---

## 4. 后端目录规划

### 4.1 不改动的现有目录

```text
src/main/java/com/lxwx/narrateservice/
├── common/
│   ├── config/
│   ├── context/
│   ├── exception/
│   ├── response/
│   └── security/
├── app/narrate/
│   ├── config/
│   └── homecase/
└── app/catsinger/
```

### 4.2 新增喵喵漫画资产库目录

```text
src/main/java/com/lxwx/narrateservice/app/comic/asset/
├── controller/
│   └── ComicAssetController.java
├── entity/
│   └── ComicAssetEntity.java
├── repository/
│   └── ComicAssetRepository.java
├── service/
│   └── ComicAssetService.java
└── vo/
    ├── ComicAssetDetailResponse.java
    ├── ComicAssetItemResponse.java
    └── ComicAssetTabResponse.java
```

命名说明：

- 目录使用 `app/comic/asset`，表示漫画资产业务域。
- 真实数据隔离仍以 `AppContext.appCode()` 和 schema routing 为准，不在业务代码里写死 `catcomic`。
- 不新增 `generation`、`work`、`payment` 等包；这些属于后续版本。

---

## 5. 配置设计

### 5.1 `application.yml`

新增 mapping：

```yaml
app:
  schema-routing:
    mappings:
      narrate: ${NARRATE_DB_SCHEMA:narrate}
      catsinger: ${CATSINGER_DB_SCHEMA:catsinger}
      catcomic: ${CATCOMIC_DB_SCHEMA:catcomic}
```

注意：

- `DEFAULT_APP_CODE` 保持 `narrate`，避免后台任务和老回调默认行为改变。
- `catcomic` 必须全小写，符合 `AppSchemaRoutingProperties` 的 appCode 校验。
- 生产环境如需不同 schema 名，配置 `CATCOMIC_DB_SCHEMA`。

### 5.2 `application-test.yml`

新增测试 mapping：

```yaml
app:
  schema-routing:
    mappings:
      narrate: narrate
      catsinger: catsinger
      catcomic: catcomic
```

测试同步点：

- `SchemaRoutingIntegrationTests` 增加 `catcomic` 断言。
- 确认 `catcomic` schema 有 `users`、`app_configs`、`home_case_categories`、`home_hot_cases`、`comic_assets`。
- 确认 `narrate` 和 `catsinger` 不会被意外创建 `comic_assets`。

---

## 6. 数据库设计

### 6.1 迁移脚本位置

建议新增：

```text
src/main/resources/db/migration/catcomic/
└── V14__catcomic_home_assets.sql
```

选择 `V14` 的原因：当前仓库已有 `catsinger/V13__catsinger_song.sql`，新增脚本用下一个全局版本号更利于人工检索。Flyway 会在 `catcomic` schema 上执行 `common/V1` 和 `catcomic/V14`。

### 6.2 首页表

`catcomic` schema 需要拥有与现有首页 Service 兼容的表：

| 表名 | 用途 | 复用代码 |
|------|------|----------|
| `home_case_categories` | 首页分类 Tab | `HomeCaseCategoryEntity` / `HomeCaseService.publicCategories()` |
| `home_hot_cases` | 热门案例列表与详情 | `HomeHotCaseEntity` / `HomeCaseService.publicCases()` |
| `home_case_operation_logs` | 后台操作日志预留 | `HomeCaseOperationLogEntity` |

这些表的 DDL 可以从 `narrate/V2__narrate_schema.sql` 中抽取并放入 `catcomic` 迁移。不要把它们移入 `common`，否则会影响 `catsinger` 等 App schema 的现有测试预期。

### 6.3 资产库表

```sql
CREATE TABLE IF NOT EXISTS comic_assets (
    id BIGSERIAL PRIMARY KEY,
    app_code VARCHAR(64) NOT NULL,
    user_id BIGINT,
    asset_type VARCHAR(32) NOT NULL,
    asset_name VARCHAR(128) NOT NULL,
    cover_url TEXT,
    description VARCHAR(512),
    source_type VARCHAR(32) NOT NULL DEFAULT 'SYSTEM',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER NOT NULL DEFAULT 0,
    metadata_json TEXT,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_comic_assets_app_type_sort
    ON comic_assets (app_code, asset_type, status, sort_order, id);

CREATE INDEX IF NOT EXISTS idx_comic_assets_user_app_type
    ON comic_assets (user_id, app_code, asset_type, created_at);
```

字段约定：

| 字段 | 说明 |
|------|------|
| `app_code` | 当前固定 `catcomic`，查询必须带 `AppContext.appCode()` |
| `user_id` | 空表示系统资产；非空表示用户资产，P0 只预留 |
| `asset_type` | `ROLE`、`SCENE`、`ITEM` |
| `source_type` | `SYSTEM`、`USER`、`GENERATED`，P0 主要用 `SYSTEM` |
| `status` | `ACTIVE`、`DISABLED`、`DELETED` |
| `metadata_json` | 未来保存角色设定、场景描述、道具参数等扩展 JSON |

### 6.4 数据写入边界

数据库迁移脚本只允许做结构变更：

- 创建表：`CREATE TABLE`
- 修改表：`ALTER TABLE`
- 创建索引、唯一约束、检查约束和注释

数据库迁移脚本不得直接内置业务数据：

- 不在 SQL 迁移里写首页分类、示例案例、示例资产或运营配置
- 不在 SQL 迁移里写 `app_configs.config_value_json` 这类 JSON 配置内容
- 不在 SQL 迁移里通过 `INSERT`、`UPDATE`、`DELETE` 直接改业务数据
- 不执行 `DROP TABLE`、`TRUNCATE` 或其它删除表/清空表操作，除非后续用户明确提出并重新走变更评审

说明：这里限制的是表结构/迁移脚本，不禁止后端业务代码、后台管理接口、初始化服务或测试代码在运行时写入数据。首页分类、首页案例、资产库示例资产如需首期内容，应通过代码或后台流程添加；若暂未添加，接口必须稳定返回空数组或空分页。

---

## 7. API 接口设计

### 7.1 统一约定

| 项 | 约定 |
|----|------|
| 统一响应 | `ApiResponse<T>(code, message, data, traceId)` |
| 成功码 | `200` |
| 通用错误 | `-400` 参数错误，`-401` 未授权，`-403` 无权限，`-404` 不存在，`-500` 服务异常 |
| 分页 | `PageResult<T>(items, page, pageSize, total, hasMore)` |
| AppCode | `/api/**` 请求必须带 `X-App-Code: catcomic` |
| 鉴权 | 首页和资产库读取允许匿名；登录后资产列表可额外返回当前用户资产 |
| 空态 | 返回 `[]` 或空分页，不用异常表达无数据 |

### 7.2 复用首页接口

#### GET `/api/config/home-case-categories`

描述：返回当前 appCode 的首页分类。

响应示例：

```json
{
  "code": 200,
  "message": "成功",
  "data": [
    {
      "id": "1",
      "categoryCode": "hot",
      "categoryName": "热门",
      "sortOrder": 1,
      "hotTab": true
    }
  ],
  "traceId": "trace-id"
}
```

#### GET `/api/config/home-cases?categoryCode=hot`

描述：返回当前分类下的热门案例；无案例时返回空数组。

#### GET `/api/config/home-cases/{caseId}`

描述：案例详情。P0 前端可进入占位，不强制依赖详情。

#### POST `/api/config/home-cases/{caseId}/use`

描述：现有使用次数统计接口。P0 可不调用，避免误导为真实创作。

### 7.3 新增资产库接口

#### GET `/api/comic/assets/tabs`

描述：返回资产库三类 Tab 配置。

响应：

```json
{
  "code": 200,
  "message": "成功",
  "data": [
    {
      "assetType": "ROLE",
      "title": "角色资产",
      "description": "管理常用角色形象",
      "sortOrder": 1
    },
    {
      "assetType": "SCENE",
      "title": "场景资产",
      "description": "管理常用场景画面",
      "sortOrder": 2
    },
    {
      "assetType": "ITEM",
      "title": "物品资产",
      "description": "管理道具与关键物品",
      "sortOrder": 3
    }
  ],
  "traceId": "trace-id"
}
```

#### GET `/api/comic/assets`

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
    "items": [
      {
        "id": "1001",
        "assetType": "ROLE",
        "assetName": "热血少年主角",
        "coverUrl": "/uploads/catcomic/assets/role-hero.png",
        "description": "适合短剧与冒险题材",
        "sourceType": "SYSTEM",
        "createdAt": "2026-06-10T18:44:00"
      }
    ],
    "page": 1,
    "pageSize": 20,
    "total": 1,
    "hasMore": false
  },
  "traceId": "trace-id"
}
```

查询规则：

- `app_code = AppContext.appCode()`
- `asset_type = assetType`
- `status = ACTIVE`
- `deleted_at IS NULL`
- 匿名用户只返回 `user_id IS NULL`
- 登录用户返回 `user_id IS NULL OR user_id = currentUser.userId()`
- 排序：`sort_order ASC, created_at DESC, id DESC`

#### GET `/api/comic/assets/{assetId}`

描述：资产详情；校验 appCode、状态和可见性。

错误：

| 场景 | 响应 |
|------|------|
| `assetType` 非法 | `400 / code=-400` |
| 资产不存在或不可见 | `400 / code=-404`，沿用当前 `BizException` 状态策略 |
| 缺少或不支持 `X-App-Code` | `400 / code=-400` |

### 7.4 App 配置接口

当前工程实际已有 `/api/config/presets`、`/api/config/styles`、`/api/config/voices`、`/api/config/static-page/{key}`、`/api/config/version-update`，但没有统一的 `/api/config/app`。

P0 首页和资产库不强依赖 `/api/config/app`。若前端总体开发计划确认需要聚合配置，可在 `AppConfigController` 新增：

```text
GET /api/config/app
```

返回 app 名称、协议链接、占位开关和基础配置。否则本期只通过代码或后台维护现有配置表数据，不新增聚合接口。

---

## 8. Service 与持久化设计

### 8.1 `ComicAssetEntity`

实体映射 `comic_assets`，字段保持 Java `camelCase` + `@TableField` 显式映射。

关键字段：

```text
id, appCode, userId, assetType, assetName, coverUrl, description,
sourceType, status, sortOrder, metadataJson, deletedAt, createdAt, updatedAt
```

### 8.2 `ComicAssetRepository`

```java
@Mapper
public interface ComicAssetRepository extends BaseMapper<ComicAssetEntity> {
}
```

P0 不需要 XML SQL；复杂查询用 `Wrappers.lambdaQuery` 和参数绑定。

### 8.3 `ComicAssetService`

核心方法：

| 方法 | 职责 |
|------|------|
| `tabs()` | 返回 ROLE / SCENE / ITEM 三类静态配置 |
| `list(String assetType, Long userId, long page, long pageSize)` | 校验类型，分页查询可见资产 |
| `detail(Long assetId, Long userId)` | 校验 appCode、状态、可见性并返回详情 |

约束：

- Service 内部读取 `AppContext.appCode()`。
- `assetType` 统一转大写并校验，不接受自由字符串。
- 写操作本期不开放；不提供创建、编辑、删除接口。
- `metadata_json` 对前端可原样返回为字符串，后续再升级为结构化对象。

### 8.4 可选登录态

Controller 可使用：

```java
@AuthenticationPrincipal CurrentUser currentUser
```

由于资产读取接口允许匿名，`currentUser` 可能为空。Service 只接收 `Long userId`，避免在业务层依赖 Spring Security 上下文。

---

## 9. 安全与隔离

| 项 | 规则 |
|----|------|
| AppCode | 所有资产接口必须通过 `AppCodeFilter`，缺失 `X-App-Code` 返回 400 |
| schema | `catcomic` 使用独立 schema，不读取 `narrate` 或 `catsinger` 表 |
| app_code | 查询仍带 `app_code = AppContext.appCode()`，作为 schema 之外的二次隔离 |
| 匿名访问 | `/api/comic/assets/**` 允许匿名读取系统资产 |
| 登录访问 | Bearer token 与请求 appCode 不一致时，`JwtAuthenticationFilter` 不注入用户 |
| 越权 | 登录用户只能看到 `user_id IS NULL` 或自己的资产 |
| 敏感数据 | 不返回手机号、token、内部任务 ID、支付字段 |

`SecurityConfig` 当前 `anyRequest().permitAll()` 会让新增资产读取接口匿名可访问。为便于后续收紧安全策略，建议编码时显式加入：

```java
".requestMatchers(\"/api/comic/assets/**\").permitAll()"
```

---

## 10. OpenAPI 与 Javadoc

新增 public 类和 public 方法必须写中文 Javadoc，至少说明：

- 接口用途
- 入参含义
- 返回数据
- 匿名和登录态差异
- appCode 隔离约束

springdoc 已接入，编码后需要确认 `/v3/api-docs` 能暴露新增接口说明。

---

## 11. 编码任务清单

| 任务 ID | 名称 | 输出文件 / 动作 | 验收 |
|---------|------|-----------------|------|
| T-B001 | AppCode 接入 | `application.yml`、`application-test.yml` 新增 `catcomic` mapping | `X-App-Code: catcomic` 不再返回 Unsupported |
| T-B002 | Catcomic 表结构迁移 | `db/migration/catcomic/V14__catcomic_home_assets.sql` | schema 有首页表、资产表、索引和约束；迁移脚本不内置业务数据 |
| T-B003 | 首页接口联调 | 复用 `HomeCasePublicController` / `HomeCaseService` | 分类可返回 `catcomic` 数据，案例空态稳定 |
| T-B004 | 资产实体与 Repository | `ComicAssetEntity`、`ComicAssetRepository` | MyBatis 映射通过测试 |
| T-B005 | 资产 Service | `ComicAssetService` | 类型校验、分页、匿名/登录可见性正确 |
| T-B006 | 资产 Controller / VO | `ComicAssetController`、3 个 Response record | 三个接口返回统一 `ApiResponse` |
| T-B007 | 安全与隔离测试 | 集成测试覆盖缺头、错 appCode、匿名、跨 appCode | `./gradlew test` 通过 |
| T-B008 | OpenAPI 与联调说明 | Javadoc / 接口示例 / 文档回写 | `/v3/api-docs` 暴露新增接口 |

---

## 12. 测试计划

### 12.1 建议新增测试类

```text
src/test/java/com/lxwx/narrateservice/CatcomicAssetIntegrationTests.java
```

覆盖用例：

- `GET /api/comic/assets/tabs` 带 `X-App-Code: catcomic` 返回三类 Tab。
- `GET /api/comic/assets` 匿名返回系统资产或空分页。
- `GET /api/comic/assets/{assetId}` 对可见资产返回详情。
- 缺少 `X-App-Code` 返回 400。
- `X-App-Code: unknown` 返回 400。
- `X-App-Code: narrate` 不可读取 `catcomic` 资产。
- 登录用户只能读取系统资产和自己的资产。

### 12.2 需要更新的现有测试

| 测试 | 更新点 |
|------|--------|
| `SchemaRoutingIntegrationTests` | mapping 增加 `catcomic`，断言 `catcomic` 表存在 |
| `CommonRequestHeaderIntegrationTests` | 可补一个 `catcomic` 请求头合法用例 |
| 首页相关集成测试 | 增加 `catcomic` 分类读取用例 |

### 12.3 验证命令

```bash
./gradlew test
./gradlew build
git diff --check
```

本阶段只生成文档，不运行后端测试。进入编码阶段并修改 Java 代码后必须执行上述验证。

---

## 13. 联调契约

前端请求头：

```text
X-App-Code: catcomic
Authorization: Bearer <token>   # 可选
```

首期前端只依赖：

| 前端页面 | 后端接口 |
|----------|----------|
| 首页分类 | `GET /api/config/home-case-categories` |
| 首页案例 | `GET /api/config/home-cases?categoryCode=hot` |
| 资产 Tab | `GET /api/comic/assets/tabs` |
| 资产列表 | `GET /api/comic/assets?assetType=ROLE&page=1&pageSize=20` |
| 资产详情占位 | `GET /api/comic/assets/{assetId}`，可选 |

占位页面不得调用真实生成、下载、删除、支付、扣点接口。

---

## 14. 风险与处理

| 风险 | 影响 | 处理 |
|------|------|------|
| 只加 mapping 没有 catcomic 迁移 | 首页表不存在，接口 500 | T-B002 必须建首页表和资产表 |
| 把首页表移入 common | 影响 `catsinger` 等非漫画 App schema 和现有测试 | 使用 `catcomic` app 专属迁移 |
| 资产接口未显式 appCode 查询 | 可能跨 App 读数据 | 所有查询必须带 `AppContext.appCode()` |
| 匿名和登录资产混杂 | 越权看到他人资产 | `user_id IS NULL OR user_id = currentUser.userId()` |
| P0 误接真实生成/支付 | 产生扣点或脏数据 | 本期不新增相关接口，不调用旧生成接口 |
| `/api/config/app` 真实工程不存在 | 前端误依赖未实现接口 | 开发计划阶段确认是否新增，默认不阻塞 P0 |

---

## 15. 编码前检查清单

- [ ] 确认当前工作目录为 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`
- [ ] 读取后端工程 `AGENTS.md`
- [ ] 进入 Java 编码阶段后读取 `.cursor/rules/14-Java编码索引.mdc`
- [ ] 按索引读取数据库、新接口、鉴权安全相关规则
- [ ] 确认 `appCode=catcomic` 未变更
- [ ] 确认是否需要 `/api/config/app`
- [ ] 确认首页和资产库示例素材是否已有真实 URL
- [ ] 确认 SQL 迁移脚本只做表结构变更，不直接插入业务数据、JSON 配置或示例数据
- [ ] 修改代码后执行 `./gradlew test`、`./gradlew build`、`git diff --check`
