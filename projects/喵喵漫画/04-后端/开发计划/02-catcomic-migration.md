# 02 Catcomic 表结构迁移模块开发文档

> 对应任务：T-B002、T-B004
> 目标工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

本模块负责在 `catcomic` schema 下创建首页复用表和资产库表，并补资产库 Entity / Repository 映射。

边界：

- 只在 `src/main/resources/db/migration/catcomic/` 新增 App 专属迁移。
- 迁移脚本只做表结构、索引、约束和注释。
- 不在迁移里直接写首页分类、案例、资产、JSON 配置或运营数据。
- 不执行删表、清空表或业务数据删除操作。

## 2. 涉及清单

| 层级 | 文件 |
|------|------|
| 迁移 | `src/main/resources/db/migration/catcomic/V14__catcomic_home_assets.sql` |
| 资产 Entity | `app/comic/asset/entity/ComicAssetEntity.java` |
| 资产 Repository | `app/comic/asset/repository/ComicAssetRepository.java` |
| 首页复用 Entity | `app/narrate/homecase/entity/*` |
| 首页复用 Repository | `app/narrate/homecase/repository/*` |

## 3. 接口契约

本模块不暴露 HTTP 接口，但为以下接口提供表结构：

| 接口 | 依赖表 |
|------|--------|
| `GET /api/config/home-case-categories` | `home_case_categories` |
| `GET /api/config/home-cases` | `home_hot_cases`、`home_case_categories` |
| `GET /api/comic/assets` | `comic_assets` |
| `GET /api/comic/assets/{assetId}` | `comic_assets` |

## 4. 数据表与迁移

### 4.1 首页表

从 `narrate/V2__narrate_schema.sql` 抽取与现有 Entity 兼容的结构：

- `home_case_categories`
- `home_hot_cases`
- `home_case_operation_logs`

要求：

- 字段与现有 `HomeCaseCategoryEntity`、`HomeHotCaseEntity`、`HomeCaseOperationLogEntity` 一致。
- 保留 `app_code` 字段用于防御校验。
- 列表查询索引覆盖 `app_code`、状态、分类、排序和软删除。

### 4.2 资产表

新增 `comic_assets`：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | BIGSERIAL | 主键 |
| `app_code` | VARCHAR(64) | 当前请求 appCode 防御校验 |
| `user_id` | BIGINT | 空为系统资产，非空为用户资产 |
| `asset_type` | VARCHAR(32) | `ROLE` / `SCENE` / `ITEM` |
| `asset_name` | VARCHAR(128) | 展示名称 |
| `cover_url` | TEXT | 封面 |
| `description` | VARCHAR(512) | 简介 |
| `source_type` | VARCHAR(32) | `SYSTEM` / `USER` / `GENERATED` |
| `status` | VARCHAR(32) | `ACTIVE` / `DISABLED` / `DELETED` |
| `sort_order` | INTEGER | 排序 |
| `metadata_json` | TEXT | 后续扩展字段 |
| `deleted_at` | TIMESTAMP | 软删除时间 |
| `created_at` | TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | 更新时间 |

索引：

- `idx_comic_assets_app_type_sort(app_code, asset_type, status, sort_order, id)`
- `idx_comic_assets_user_app_type(user_id, app_code, asset_type, created_at)`

约束：

- `asset_type` 只允许 `ROLE`、`SCENE`、`ITEM`。
- `source_type` 只允许 `SYSTEM`、`USER`、`GENERATED`。
- `status` 只允许 `ACTIVE`、`DISABLED`、`DELETED`。

## 5. 业务规则与状态

- 首页无业务数据时返回空数组。
- 资产无业务数据时返回空分页。
- `deleted_at IS NULL` 且 `status = ACTIVE` 的资产才可对用户展示。
- 业务写入只能通过后续代码、后台管理、初始化服务或运营导入流程完成。

## 6. 异常处理与日志

- 迁移失败由 Flyway 阻断启动。
- 不在迁移脚本输出敏感信息。
- Entity / Repository 不写业务日志。

## 7. 依赖前置

- T-B001 完成 `catcomic` mapping。
- 现有首页 Entity / Repository 可复用。

## 8. 建议实现步骤

1. 新建 `db/migration/catcomic` 目录。
2. 从 `narrate` 迁移抽取首页三张表 DDL。
3. 编写 `comic_assets` DDL、索引、约束和注释。
4. 新增 `ComicAssetEntity`。
5. 新增 `ComicAssetRepository extends BaseMapper<ComicAssetEntity>`。

## 9. 编码任务清单

| 子任务 | 内容 | 验收 |
|--------|------|------|
| T-B002-1 | 新增 `V14__catcomic_home_assets.sql` | catcomic schema 有首页表和资产表 |
| T-B002-2 | 加表注释和字段注释 | 关键字段说明齐全 |
| T-B004-1 | 新增 `ComicAssetEntity` | 字段显式映射 |
| T-B004-2 | 新增 `ComicAssetRepository` | MyBatis 扫描可用 |

## 10. 测试要求

- schema routing 测试断言 `catcomic` 下存在首页表与 `comic_assets`。
- Repository 映射测试可执行空查询。
- 迁移脚本不包含业务数据写入。

## 11. 验收标准

- `./gradlew test` 通过。
- `catcomic` schema 可执行首页和资产库空查询。
- `common`、`narrate`、`catsinger` 迁移范围未被扩大。

## 12. 编码注意事项

- 不把喵喵漫画业务表放进 `common`。
- 不直接复制旧业务数据。
- 不新增写接口来绕过数据入口评审。
