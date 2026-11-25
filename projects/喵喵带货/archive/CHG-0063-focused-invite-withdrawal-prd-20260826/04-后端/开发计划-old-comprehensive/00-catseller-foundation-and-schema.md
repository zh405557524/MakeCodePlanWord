# Java 模块开发文档：数据隔离与基础结构

> 版本：`v1.0`  
> 日期：2026-07-21  
> 状态：已完成  
> 对应任务：`T-B001 数据隔离`  
> 目标工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`  

---

## 1. 功能定位与边界

本模块把 `catseller` 注册为现有 Java 多 App 服务中的独立 App，建立后续作品、脚本、分镜图片、视频、计费和后台业务共同依赖的数据与安全基础。

本模块完成：

- 注册 `X-App-Code: catseller` 到 PostgreSQL `catseller` schema。
- 建立 `db/migration/catseller` 专属 Flyway 迁移目录。
- 建立 `service-data/apps/catseller` 默认配置目录。
- 建立 `com.lxwx.narrateservice.app.catseller` 业务包骨架。
- 建立技术方案已经确认的 catseller 专属表和关键约束。
- 明确公开接口和私有接口的 Spring Security 边界。
- 验证 catseller、catsinger、catcomic、narrate 数据互不串用。
- 为资源、用户、积分、支付、审核和 AI 配置等公共能力保留复用入口，不建立同义副本。

本模块不完成：

- 不实现首页、案例、作品、脚本、图片或视频 Controller。
- 不实现生成任务 Worker、视频 Provider、积分扣费和审核流程。
- 不新增登录、会员、积分、支付、订单、任务中心或兑换码接口。
- 不修改现有 App 的业务数据和迁移历史。
- 不在本模块决定视频模型、单图积分价格或失败扣费策略的最终配置值。

## 2. 涉及的类与文件

### 2.1 现有文件修改

| 类型 | 文件/类 | 处理方式 |
|------|---------|----------|
| 配置 | `src/main/resources/application.yml` | 在 `app.schema-routing.mappings` 增加 `catseller` |
| 测试配置 | `src/test/resources/application-test.yml` | 增加 catseller 测试 schema 映射 |
| 安全 | `framework/security/SecurityConfig.java` | 显式声明 catseller 公开与私有路径，不依赖 `anyRequest().permitAll()` |
| Schema 测试 | `SchemaRoutingIntegrationTests.java` | 增加 catseller 公共表、专属表和跨 App 隔离断言 |
| App 上下文测试 | `AppCodeFilter` 相关测试 | 覆盖缺失、未知和合法 catseller 请求头 |

### 2.2 新增目录与包骨架

```text
src/main/java/com/lxwx/narrateservice/app/catseller/
├── config/
├── home/
├── work/
├── persona/
├── content/
├── storyboard/
├── video/
├── billing/
├── moderation/
├── task/
└── workflow/

src/main/resources/
├── db/migration/catseller/
└── service-data/apps/catseller/
```

本模块只建立必要目录、领域常量和迁移；业务 Controller、Service、Repository/Mapper、Entity 在对应后续模块中新增，避免空实现类。

### 2.3 本模块类清单

| 分层 | 类/组件 | 处理 |
|------|---------|------|
| Controller | 无新增业务 Controller | 本模块不暴露新业务接口 |
| Service | 无新增业务 Service | 继续复用 Schema 路由、App 配置和资源公共服务 |
| Mapper/Repository | 无新增业务 Mapper | 表对应 Repository 在所属业务模块实现 |
| Entity | 无新增业务 Entity | 表对应 Entity 在所属业务模块实现 |
| Framework | `AppSchemaRoutingProperties` | 无需改类；通过配置增加映射 |
| Framework | `SchemaRoutingDataSourceConfig` | 无需改类；自动为 catseller 创建连接池并运行 common + catseller 迁移 |
| Framework | `AppCodeFilter` | 原逻辑应自动接受 catseller；通过测试验证 |
| Security | `SecurityConfig` | 增加 catseller 明确授权规则 |

## 3. 接口契约

### 3.1 本模块接口范围

本模块不新增业务接口。它为后续接口建立统一的请求头、鉴权、Schema 路由和错误响应契约。

### 3.2 请求头契约

| 请求头 | 要求 | 处理 |
|--------|------|------|
| `X-App-Code` | App API 必填，固定 `catseller` | 缺失或不支持时按现有统一错误结构返回失败，不进入 Controller |
| `X-App-Version` | App 请求携带 | 写入 `AppContext` 客户端信息，供配置和兼容判断使用 |
| `X-OS-Type` | `ios` 或 `android` | 非法值按现有统一错误结构返回失败 |
| `Authorization` | 私有接口携带 Bearer Token | JWT 用户和 App 必须与当前 catseller 请求一致 |
| `Idempotency-Key` | 后续创建/提交/重生成接口必填 | 由对应业务模块实现，本模块只保留横向约束 |

统一响应继续使用现有结构：

```json
{
  "code": "业务错误码",
  "message": "用户可理解的处理建议",
  "data": null,
  "traceId": "服务端追踪标识"
}
```

不在本模块新增另一套响应包装。

### 3.3 安全路径契约

| 路径 | 鉴权要求 | 说明 |
|------|----------|------|
| `GET /api/catseller/home` | 游客可读 | 由首页模块实现 |
| `GET /api/catseller/config` | 游客可读 | 由首页/配置模块实现 |
| 其他 `/api/catseller/**` | 必须登录 | 统一由 Spring Security 拦截 |
| `/api/admin/catseller/**` | 管理员角色 | 继续沿用 `/api/admin/**` 管理员规则 |

`SecurityConfig` 当前存在 `anyRequest().permitAll()`，因此必须在兜底规则之前显式加入上述 catseller 规则。Controller 内的用户校验不能替代 Spring Security 鉴权。

### 3.4 错误处理

本模块只使用技术文档中已经确认或现有框架已有的错误语义：

| 场景 | 对外结果 |
|------|----------|
| 缺少 `X-App-Code` | 现有 `BAD_REQUEST` 统一响应 |
| 不支持的 `X-App-Code` | 现有 `BAD_REQUEST` 统一响应 |
| 非法 `X-OS-Type` | 现有 `BAD_REQUEST` 统一响应 |
| 私有接口未登录或 Token 失效 | `AUTH_REQUIRED` 语义，由安全处理器统一返回 |
| JWT App 与请求 App 不一致 | 拒绝访问，不切换或扫描其他 schema |

与 Flutter 基础模块的关系：`03-前端/开发计划/00-app-foundation-and-tabs.md` 负责客户端路由门禁；本模块负责服务端最终鉴权，二者必须同时存在。

## 4. 数据表与迁移

### 4.1 Schema 与 Flyway

在 `application.yml` 和测试配置中增加：

```yaml
app:
  schema-routing:
    mappings:
      catseller: ${CATSELLER_DB_SCHEMA:catseller}
```

测试配置使用：

```yaml
app:
  schema-routing:
    mappings:
      catseller: catseller
```

`SchemaRoutingDataSourceConfig` 会自动：

1. 创建 catseller 数据源。
2. 设置当前连接 schema。
3. 为 catseller 执行 `db/migration/common`。
4. 再执行 `db/migration/catseller`。

编码开始前必须重新检查仓库中 Flyway 版本。当前候选首个文件为 `V2.7__catseller_foundation.sql`；如果已有更高版本，使用下一可用版本，禁止复用已存在版本号。

### 4.2 专属表

基础迁移按 `java-tech.md` 已确认模型建立以下表。后续模块可以增加技术字段或索引，但新增产品字段必须先登记变更。

| 表 | 作用 | 已确认字段/约束 |
|----|------|-----------------|
| `catseller_works` | 作品聚合根 | 用户、状态、当前输入/脚本/视频版本、最后使用时间、隐藏/删除时间、乐观锁 |
| `catseller_work_inputs` | 填写信息版本 | 作品、商品描述、比例、时长、形象、版本、输入快照 |
| `catseller_work_assets` | 商品图和排序 | 作品、resourceId、类型、顺序、主图、审核状态；同作品顺序唯一 |
| `catseller_personas` | 用户/平台/AI 形象 | owner、来源、resourceId、授权、AI 标记、有效期、状态 |
| `catseller_script_versions` | 脚本历史 | 作品、版本号、Schema 版本、来源、当前标记；同作品版本唯一 |
| `catseller_shots` | 镜头 | 脚本版本、顺序、画面、可选口播、建议时长、乐观锁 |
| `catseller_storyboard_images` | 分镜图片历史 | 镜头、resourceId、版本、来源、审核、AI 标记、当前标记 |
| `catseller_video_snapshots` | 视频不可变输入 | 作品、脚本/图片快照、snapshotHash、报价、失败策略版本 |
| `catseller_videos` | 视频版本 | 快照、resourceId、状态、审核、AI 标记、有效期 |
| `catseller_generation_tasks` | 统一生成任务 | 类型、业务对象、状态、步骤、Provider、租约、幂等键、错误 |
| `catseller_generation_task_steps` | 工作流步骤实例 | taskId、步骤编码、状态、顺序、重试、请求/结果摘要、错误、起止时间；taskId+stepCode 唯一 |
| `catseller_generation_task_events` | 任务事件日志 | taskId、事件类型、步骤、脱敏消息、数据摘要和时间 |
| `catseller_generation_compensations` | 失败补偿记录 | taskId、步骤、补偿类型、状态、重试和错误；同一补偿动作唯一 |
| `catseller_cases` | 首页与更多案例 | 封面、视频、排序、上下线、AI 标记 |
| `catseller_billing_quotes` | 视频报价 | 图片数、单价、总价、价格版本、snapshotHash、失败规则、过期时间 |

### 4.3 关键索引和唯一约束

- 作品按用户、状态、更新时间查询的组合索引。
- 同一作品同一阶段最多一个活动任务。
- 同一脚本版本镜头顺序唯一。
- 同一作品脚本版本号唯一，且最多一个当前脚本。
- 同一镜头图片版本号唯一，且最多一个当前图片。
- Provider 任务 ID 在 Provider 范围内唯一。
- 幂等键与请求摘要建立可校验约束。
- 报价按 `snapshotHash` 和过期时间查询。
- 案例按启用状态和后台排序查询。
- 隐藏/删除定时任务按状态和时间查询。

PostgreSQL 的“最多一个当前版本”“最多一个活动任务”等约束优先使用部分唯一索引，不能只依赖 Java 代码判断。

### 4.4 公共表复用

catseller schema 会执行 common 迁移并继续复用以下公共表：

- 用户、Token、用户 App 资料。
- 会员、积分账户、积分流水和扣费订单。
- 支付订单、商品、任务中心、兑换码和邀请。
- 资源台账、内容审核记录和 AI 模型配置。
- 反馈、静态内容和 App 配置。

不得建立 `catseller_users`、`catseller_points_accounts`、`catseller_payment_orders` 等同义副本。

### 4.5 默认配置目录

建立 `src/main/resources/service-data/apps/catseller/`，首批只放技术文档已经确认的配置类别：

- `app-configs.json`：图片限制、比例/时长、功能开关、7 天隐藏/30 天删除、首页文案。
- `products.json`：复用会员/积分商品体系所需的 catseller App 商品配置。
- AI 与计费配置继续服从现有通用配置结构；真实密钥只通过私有配置或环境变量注入。

配置值未最终确认时使用后台可修改的安全默认值，不把暂定单图积分写死到 Java 常量。

## 5. 业务规则与状态流转

本模块不执行作品状态流转，但数据库必须能承载以下已确认状态：

```text
DRAFT
  → CONTENT_RUNNING
  → EDITING
  → VIDEO_RUNNING
  → COMPLETED

异常/生命周期：FAILED、HIDDEN、DELETED
```

统一生成任务状态：

```text
PENDING → RUNNING → SUCCEEDED / FAILED
```

基础约束：

- 运行中作品不能取消、编辑、删除、隐藏或清理。
- `FAILED` 必须保存失败阶段和可恢复状态。
- 7 天隐藏、30 天删除字段由数据库持久化，不用缓存作为真源。
- Redis 只做短期幂等、锁和缓存，不作为作品、任务或扣费终态真源。
- 所有用户私有对象必须保存可校验的用户归属。
- 公共资源表保存资源实体，业务表只保存 `resource_records.id` 等稳定引用，不保存永久签名 URL。

## 6. 异常处理与日志要求

- Schema 注册失败、Flyway 失败或默认 App 映射错误时，服务启动失败，不能跳过迁移继续运行。
- 请求头缺失/非法只记录 path、method、appCode 摘要和 traceId，不记录 Token。
- JWT App 与 `X-App-Code` 不一致时记录安全告警，禁止退回默认 App。
- 后台任务没有请求头时必须显式设置 `AppContext`；处理完必须在 `finally` 中清理。
- 不记录完整手机号、Prompt、签名 URL、支付凭证或人像原始信息。
- 数据隔离测试失败视为发布阻塞，不允许仅标记为普通测试问题。

## 7. 依赖前置

- Java 总体开发计划 v1.0 已确认。
- 继续使用现有 Spring Boot 3.3.0、Java 21、Gradle、MyBatis-Plus、PostgreSQL、Redis 和 Flyway。
- 本地/测试数据库账号有创建 catseller schema 和执行迁移权限。
- catseller App code、schema 名、管理后台标签和权限命名固定为 `catseller`。
- 后续资源模块复用现有 `ResourceRecordService` 和阿里 OSS/审核能力。
- 本模块不依赖 Flutter 页面完成，但完成后是所有 catseller Java 业务的前置条件。

## 8. 现有工程参考点

| 参考点 | 复用内容 | 本模块动作 |
|--------|----------|------------|
| `AppSchemaRoutingProperties` | App code → schema 映射校验 | 通过配置加入 catseller，不修改路由算法 |
| `SchemaRoutingDataSourceConfig` | 每 App 连接池、common + App Flyway | 验证自动创建和迁移 catseller |
| `AppCodeFilter` | 请求头校验、`AppContext` 建立和清理 | 增加 catseller 集成测试，无需新增平行 Filter |
| `SecurityConfig` | JWT/Admin Filter 和统一异常处理 | 显式保护 `/api/catseller/**` |
| `SchemaRoutingIntegrationTests` | 多 schema 表存在/不存在断言 | 增加 catseller 并验证不串 catsinger |
| `service-data/apps/catsinger` | App 专属配置目录组织 | 只复用结构，不复制写歌文案、音乐配置和资源类别 |
| `db/migration/catsinger` | App 专属迁移组织 | 只复用迁移方式，不复制歌曲表 |
| `app/catsinger/songworkflow` | 任务主表、步骤定义/实例、调度执行、PAUSED 等待、事件日志和补偿模式 | 建立 catseller 自己的 `SellerWorkflow*` 结构；不引用歌曲枚举、Entity、Repository 或表 |

## 9. 建议实现步骤

1. 记录 Java 工程当前工作区状态，确认没有覆盖用户修改。
2. 在生产和测试配置的 schema mappings 中增加 catseller。
3. 新建 catseller 迁移目录和下一可用 Flyway 文件。
4. 建立已确认的专属表、主外键、乐观锁、时间字段和关键唯一索引。
5. 建立 catseller service-data 目录及首批 App 配置。
6. 新建 `app/catseller` 包目录，只放确有实现的基础领域常量，避免空类。
7. 在 `SecurityConfig` 中显式加入两个公开 GET 路径和其余私有路径规则。
8. 扩展 `SchemaRoutingIntegrationTests`，验证 common、catseller 专属表和跨 App 不存在断言。
9. 增加请求头、安全路径和 JWT App 不一致测试。
10. 在空库和已有开发库执行迁移，最后运行完整测试和构建。

## 10. 详细编码任务清单

| 子任务 | 业务名称 | 主要修改 | 状态 | 完成结果 |
|--------|----------|----------|------|----------|
| T-B001-01 | 注册 catseller | 修改生产/测试 schema mapping | done | `X-App-Code: catseller` 能正确路由 |
| T-B001-02 | 建立专属迁移 | 新建 `db/migration/catseller` 和基础迁移 | done | common 与 catseller 专属表创建成功 |
| T-B001-03 | 建立默认配置 | 新建 `service-data/apps/catseller` | done | App 配置可按 catseller 独立加载 |
| T-B001-04 | 建立业务包 | 新建 `app/catseller` 分层目录 | done | 后续模块有统一包入口，无第二个启动类 |
| T-B001-05 | 保护私有接口 | 修改 `SecurityConfig` | done | 仅首页和公开配置匿名可读，其余需要登录 |
| T-B001-06 | 验证请求头 | 扩展 AppCode/Security 测试 | done | 缺失、未知、非法 OS、合法 catseller 行为正确 |
| T-B001-07 | 验证数据隔离 | 扩展 Schema 路由集成测试 | done | catseller、catsinger、catcomic、narrate 不串表 |
| T-B001-08 | 验证迁移 | 空库、已有库测试并运行完整构建 | done | Flyway 无冲突、可重复启动、全部测试通过 |

## 11. 测试要求

### 11.1 单元测试

- `AppSchemaRoutingProperties` 接受 `catseller → catseller`。
- 大写、非法字符、空 schema 和未在 mappings 中的默认 App 继续被拒绝。
- `AppCodeFilter` 对合法 catseller 设置并在请求后清理 `AppContext`。
- 无 App 请求头、未知 App 和非法 OS 类型返回现有统一错误结构。

### 11.2 集成测试

- 启动后 catseller schema 存在。
- catseller schema 包含 common 表和全部 catseller 专属表。
- catseller schema 不包含 `catsinger_song_works`、`comic_assets`、`narrate_works` 等其他 App 专属表。
- catsinger、catcomic、narrate schema 不包含任何 `catseller_*` 表。
- `X-App-Code: catseller` 写入/查询只命中 catseller。
- `GET /api/catseller/home` 和 `GET /api/catseller/config` 不因未登录被安全层拒绝。
- 其他 `/api/catseller/**` 未登录被拒绝，管理员接口仍要求管理员角色。
- JWT App 与请求 App 不一致时拒绝访问。

### 11.3 迁移验证

- 空数据库启动迁移成功。
- 包含 narrate、catsinger、catcomic 的已有开发库升级成功。
- 服务重复启动不会重复建表或重复导入配置。
- 所有唯一索引和外键可创建，没有 Flyway 版本冲突。

至少执行：

```bash
./gradlew test
./gradlew build
```

## 12. 验收标准

- `application.yml` 和测试配置均注册 `catseller`。
- 服务启动时为 catseller 执行 common + catseller 专属迁移。
- catseller 专属表、索引和约束与已确认技术文档一致。
- 公共用户、积分、支付、资源和审核表没有建立 catseller 同义副本。
- App 请求头、JWT App 和 schema 路由三者一致。
- 仅首页和公开配置允许游客访问，其余 catseller 接口受保护。
- 多 App 隔离集成测试通过，其他 App 回归不受影响。
- 空库、已有开发库、`./gradlew test` 和 `./gradlew build` 均通过。

## 13. 编码注意事项

- 编码开始前必须读取 Java 编码索引规则和 lxwxservice 工程自身规则；本文档确认不等于已经授权编码。
- 不新建独立 Spring Boot 服务、启动类、数据源路由或鉴权 Filter。
- 不把 `default-app-code` 改成 catseller；缺少上下文时不能误进入 catseller。
- 不通过跨 schema 扫描查找用户或作品。
- 不修改已经执行过的 Flyway 文件；只新增下一可用版本。
- 不把真实密钥、Provider 地址、支付凭证或固定积分价格写进仓库。
- 不依赖 `anyRequest().permitAll()`；新增私有接口必须显式保护。
- 不在本模块发明接口字段；业务接口请求/响应由后续模块按 `java-tech.md` 细化。
- 配置导入必须按 App 幂等，不能覆盖其他 App 的同名配置。

## 14. 实现结果

- 已注册 catseller 生产/测试 Schema、公开与登录接口边界，并新增 `V2.7` 专属迁移。
- 已建立作品、版本、镜头、图片、视频、任务、步骤、事件、补偿、案例和报价等完整表结构。
- 已为 15 张 catseller 业务表和全部 211 个字段补充数据库注释；状态、积分、Provider、幂等、生命周期和审计字段均写明业务含义。
- 已增加 Schema 路由集成测试，自动检查全部 `catseller_*` 表和字段的数据库注释，存在任一遗漏时测试失败。
- 已加入 catseller 默认配置、商品、计费场景和跨 App 隔离测试；H2 PostgreSQL 模式与临时 PostgreSQL 15 实例迁移均通过。

## 15. 恢复点

本模块文档完成后，恢复点为：

```text
04-后端/开发计划/00-catseller-foundation-and-schema.md
```

Java 00～09 已全部完成，恢复点为前后端联调与验收。
