# 执行力 Kotlin 后端技术文档

> 版本：v1.2
> 更新时间：2026-06-05
> 关联技术方案：../02-技术方案/tech-plan.md  
> 关联需求文档：../01-需求/requirements.md  
> 关联设计计划：../01-需求/figma-design-plan.md  
> 框架：Ktor  
> Kotlin 版本：2.x  
> JVM 版本：17

---

## 1. 项目结构

```text
src/
├── main/
│   ├── kotlin/
│   │   └── com/zhixingli/
│   │       ├── Application.kt
│   │       ├── plugins/
│   │       │   ├── Routing.kt
│   │       │   ├── Serialization.kt
│   │       │   ├── StatusPages.kt
│   │       │   └── Monitoring.kt
│   │       ├── routes/
│   │       │   ├── NowRoutes.kt
│   │       │   ├── PlanRoutes.kt
│   │       │   ├── OverviewRoutes.kt
│   │       │   ├── ChatRoutes.kt
│   │       │   ├── NotesRoutes.kt
│   │       │   ├── ProfileRoutes.kt
│   │       │   └── SettingsRoutes.kt
│   │       ├── services/
│   │       │   ├── InstallationService.kt
│   │       │   ├── NowService.kt
│   │       │   ├── PlanService.kt
│   │       │   ├── ScheduleService.kt
│   │       │   ├── ChatService.kt
│   │       │   ├── NotesService.kt
│   │       │   ├── ProfileService.kt
│   │       │   └── SyncSupportService.kt
│   │       ├── repositories/
│   │       │   ├── InstallationRepository.kt
│   │       │   ├── PlanRepository.kt
│   │       │   ├── TaskInstanceRepository.kt
│   │       │   ├── ChatRepository.kt
│   │       │   ├── NotesRepository.kt
│   │       │   ├── ProfileRepository.kt
│   │       │   └── SettingsRepository.kt
│   │       ├── models/
│   │       │   ├── request/
│   │       │   ├── response/
│   │       │   └── entity/
│   │       ├── tables/
│   │       ├── sync/
│   │       ├── ai/
│   │       └── utils/
│   └── resources/
│       ├── application.conf
│       └── db/migration/
└── test/
    └── kotlin/
```

### 1.1 分层职责

- `routes`：参数解析、调用 service、返回统一响应。
- `services`：业务编排、校验、事务边界。
- `repositories`：Exposed 查询与持久化。
- `tables`：数据库表定义。
- `sync`：版本比对、幂等处理、冲突兜底。
- `ai`：草稿生成适配器，隔离真实 LLM 接入。

---

## 2. 依赖配置

```kotlin
dependencies {
    implementation("io.ktor:ktor-server-core:$ktorVersion")
    implementation("io.ktor:ktor-server-netty:$ktorVersion")
    implementation("io.ktor:ktor-server-content-negotiation:$ktorVersion")
    implementation("io.ktor:ktor-serialization-kotlinx-json:$ktorVersion")
    implementation("io.ktor:ktor-server-status-pages:$ktorVersion")
    implementation("io.ktor:ktor-server-call-logging:$ktorVersion")
    implementation("io.ktor:ktor-server-cors:$ktorVersion")

    implementation("org.jetbrains.exposed:exposed-core:$exposedVersion")
    implementation("org.jetbrains.exposed:exposed-dao:$exposedVersion")
    implementation("org.jetbrains.exposed:exposed-jdbc:$exposedVersion")
    implementation("org.jetbrains.exposed:exposed-java-time:$exposedVersion")

    implementation("org.postgresql:postgresql:42.7.4")
    implementation("org.flywaydb:flyway-core:10.17.0")
    implementation("ch.qos.logback:logback-classic:1.5.7")

    testImplementation("io.ktor:ktor-server-test-host:$ktorVersion")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
}
```

### 2.1 关键说明

- 当前版本不引入 JWT、Session、Refresh Token。
- 当前版本不做账号认证，设备实例通过请求头 `X-Installation-Id` 区分。
- Notes 接口与计划接口同样遵循“设备级隔离 + 幂等写入 + 本地优先”的原则。

### 2.2 v2 ChatHome / TodayFocus 后端影响

- v2 是前端信息架构重构，不要求后端把接口改名为 `ChatHome` 或 `TodayFocus`。
- `ChatHome` 需要复用后端现有能力：对话历史、消息写入、计划草稿、计划库、笔记入口、资料设置。
- `TodayFocus` 需要复用后端现有能力：`GET /api/v1/now` 当前任务校对、`PATCH /api/v1/task-instances/{id}` 执行反馈写回。
- 后端仍以领域接口命名，不以 UI 页面命名，避免 UI 重构导致 API 大面积返工。
- 如果后续需要更贴合 v2 的聚合接口，可以新增轻量 `GET /api/v1/home/bootstrap`，但不能替代现有领域接口。

---

## 3. 数据库表设计

### 3.1 表清单

| 表名 | 说明 | 主键 |
|------|------|------|
| `device_installations` | 设备实例 | `installation_id` |
| `profiles` | 设备级个人资料 | `installation_id` |
| `settings` | 设备级偏好 | `installation_id` |
| `plans` | 计划主表 | `id` |
| `plan_phases` | 阶段表 | `id` |
| `plan_tasks` | 任务定义表 | `id` |
| `task_instances` | 执行实例表 | `id` |
| `chat_messages` | 对话消息表 | `id` |
| `note_folders` | 笔记文件夹表 | `id` |
| `note_files` | 笔记文件表 | `id` |

### 3.2 核心表结构

#### device_installations

```sql
CREATE TABLE device_installations (
    installation_id VARCHAR(64) PRIMARY KEY,
    platform VARCHAR(32) NOT NULL,
    app_version VARCHAR(32),
    timezone VARCHAR(64),
    last_seen_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### profiles

```sql
CREATE TABLE profiles (
    installation_id VARCHAR(64) PRIMARY KEY REFERENCES device_installations(installation_id),
    name VARCHAR(64),
    bio TEXT,
    city VARCHAR(64),
    tags_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### settings

```sql
CREATE TABLE settings (
    installation_id VARCHAR(64) PRIMARY KEY REFERENCES device_installations(installation_id),
    energy_level VARCHAR(16) NOT NULL DEFAULT 'steady',
    mode VARCHAR(16) NOT NULL DEFAULT 'focus',
    timezone VARCHAR(64),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### plans

```sql
CREATE TABLE plans (
    id UUID PRIMARY KEY,
    installation_id VARCHAR(64) NOT NULL REFERENCES device_installations(installation_id),
    title VARCHAR(128) NOT NULL,
    type VARCHAR(32),
    status VARCHAR(16) NOT NULL DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    version BIGINT NOT NULL DEFAULT 1,
    deleted_at TIMESTAMP NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### plan_phases

```sql
CREATE TABLE plan_phases (
    id UUID PRIMARY KEY,
    plan_id UUID NOT NULL REFERENCES plans(id),
    title VARCHAR(128) NOT NULL,
    objective TEXT,
    sort_order INT NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'upcoming',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### plan_tasks

```sql
CREATE TABLE plan_tasks (
    id UUID PRIMARY KEY,
    plan_id UUID NOT NULL REFERENCES plans(id),
    phase_id UUID NULL REFERENCES plan_phases(id),
    title VARCHAR(128) NOT NULL,
    description TEXT,
    task_type VARCHAR(32) NOT NULL,
    priority VARCHAR(16) NOT NULL DEFAULT 'medium',
    estimate_minutes INT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### task_instances

```sql
CREATE TABLE task_instances (
    id UUID PRIMARY KEY,
    task_id UUID NOT NULL REFERENCES plan_tasks(id),
    scheduled_at TIMESTAMP NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'pending',
    resolution VARCHAR(16),
    version BIGINT NOT NULL DEFAULT 1,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### chat_messages

```sql
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY,
    installation_id VARCHAR(64) NOT NULL REFERENCES device_installations(installation_id),
    role VARCHAR(16) NOT NULL,
    content TEXT NOT NULL,
    draft_payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### note_folders

```sql
CREATE TABLE note_folders (
    id UUID PRIMARY KEY,
    installation_id VARCHAR(64) NOT NULL REFERENCES device_installations(installation_id),
    parent_id UUID NULL REFERENCES note_folders(id),
    name VARCHAR(128) NOT NULL,
    version BIGINT NOT NULL DEFAULT 1,
    deleted_at TIMESTAMP NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### note_files

```sql
CREATE TABLE note_files (
    id UUID PRIMARY KEY,
    installation_id VARCHAR(64) NOT NULL REFERENCES device_installations(installation_id),
    folder_id UUID NULL REFERENCES note_folders(id),
    title VARCHAR(128) NOT NULL,
    format VARCHAR(16) NOT NULL DEFAULT 'document',
    content TEXT NOT NULL DEFAULT '',
    version BIGINT NOT NULL DEFAULT 1,
    deleted_at TIMESTAMP NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### 3.3 索引建议

- `plans(installation_id, updated_at desc)`
- `plan_phases(plan_id, sort_order)`
- `plan_tasks(plan_id, phase_id)`
- `task_instances(task_id, scheduled_at)`
- `chat_messages(installation_id, created_at desc)`
- `note_folders(installation_id, parent_id, updated_at desc)`
- `note_files(installation_id, folder_id, updated_at desc)`

---

## 4. API 接口详细设计

### 4.1 统一响应格式

```kotlin
@Serializable
data class ApiResponse<T>(
    val code: Int,
    val message: String,
    val data: T? = null
)
```

### 4.2 错误码规范

| 错误码 | 含义 |
|--------|------|
| 0 | 成功 |
| 1001 | 参数错误 |
| 1004 | 资源不存在 |
| 1008 | installation_id 缺失 |
| 1010 | 版本冲突 |
| 2001 | 草稿生成失败 |
| 5000 | 服务器内部错误 |

### 4.3 请求上下文规则

- 必须读取 `X-Installation-Id`
- 可选读取 `X-App-Version`
- 可选读取 `X-Timezone`
- 进入路由后先确保 `device_installations` 已注册或更新 `last_seen_at`

### 4.4 接口详细说明

#### GET /api/v1/now

- **描述**：返回当前设备视角下的推荐任务与候选任务；v2 中作为 `TodayFocus` 当前任务校对接口
- **响应体要点**：
  - 当前推荐任务
  - 备用任务列表
  - 推荐说明文案

#### PATCH /api/v1/task-instances/{id}

- **描述**：更新执行实例状态；v2 中承接 `TodayFocus` 的完成、推迟、放弃反馈
- **规则**：
  - 支持 `completed / postponed / dropped`
  - 若版本落后，返回 1010

#### GET /api/v1/plans

- **描述**：返回当前设备下计划列表

#### POST /api/v1/plans

- **描述**：创建完整计划

#### PUT /api/v1/plans/{id}

- **描述**：全量更新计划结构
- **规则**：
  - 作为事务处理
  - 当前版本优先采用全量覆盖

#### DELETE /api/v1/plans/{id}

- **描述**：软删除计划

#### GET /api/v1/plans/schedule

- **描述**：返回日 / 周视图数据

#### GET /api/v1/overview/battle-map

- **描述**：返回作战地图聚合信息

#### GET /api/v1/plans/{id}/timeline

- **描述**：返回单条计划详情、阶段和任务

#### GET /api/v1/chat/messages

- **描述**：返回当前设备下对话历史；v2 中供 `ChatHome` 和侧边菜单历史使用

#### POST /api/v1/chat/messages

- **描述**：提交自然语言需求并返回结构化草稿；v2 中由 `ChatHome` composer 触发

#### POST /api/v1/chat/plan-drafts/apply

- **描述**：把草稿转为正式计划结构

#### GET /api/v1/notes

- **描述**：返回当前设备根目录下的文件夹与文件结构
- **响应体要点**：
  - `folders`
  - `files`
  - `updatedAt`

#### POST /api/v1/notes/folders

- **描述**：创建文件夹或子文件夹
- **请求体示例**：

```json
{
  "name": "Android面试",
  "parentId": null
}
```

#### POST /api/v1/notes/files

- **描述**：创建笔记文件
- **请求体示例**：

```json
{
  "title": "Binder.md",
  "folderId": null,
  "format": "markdown",
  "content": ""
}
```

#### PUT /api/v1/notes/files/{id}

- **描述**：更新文件标题、格式与正文
- **规则**：
  - 当前版本支持 `document / markdown`
  - 文件内容采用全量更新

#### DELETE /api/v1/notes/{id}

- **描述**：删除文件夹或文件
- **规则**：
  - 当前版本采用软删除
  - 删除文件夹时需明确处理其子文件夹与文件

#### GET /api/v1/me/profile

- **描述**：获取设备级资料

#### PUT /api/v1/me/profile

- **描述**：更新设备级资料

#### GET /api/v1/me/settings

- **描述**：获取设备级偏好

#### PUT /api/v1/me/settings

- **描述**：更新设备级偏好

---

## 5. 核心服务设计

### 5.1 InstallationService

- 校验 `installation_id`
- 首次请求时注册设备实例
- 更新 `last_seen_at`

### 5.2 PlanService

- 创建、更新、删除计划
- 维护计划、阶段、任务事务一致性
- 提供计划详情聚合

### 5.3 ScheduleService

- 输出日 / 周视图数据
- 生成 BattleMap 和 Timeline 聚合结果

### 5.4 NowService

- 基于 `task_instances` 计算当前推荐任务
- 输出推荐任务、候选任务和推荐原因
- 当前版本为补充校对层，不覆盖前端离线主流程
- v2 中对外仍命名 `NowService`，前端 UI 以 `TodayFocus` 命名呈现

### 5.5 ChatService

- 保存消息历史
- 调用 `DraftGenerator`
- 输出结构化草稿

### 5.6 NotesService

- 读取根目录和指定文件夹下的结构
- 创建文件夹、子文件夹和文件
- 更新文件标题、格式和正文内容
- 处理文件夹树与文件内容的版本校对

### 5.7 ProfileService / SettingsService

- 读写设备级资料和偏好
- 保持字段格式稳定

### 5.8 SyncSupportService

- 比较客户端版本和服务端版本
- 处理幂等重试
- 返回冲突信息或服务端规范化结果

---

## 6. Draft Generator 设计

### 6.1 抽象接口

```kotlin
interface DraftGenerator {
    suspend fun generateDraft(input: DraftInput): DraftOutput
}
```

### 6.2 当前阶段实现

- 可先使用规则生成器或 mock 数据实现
- 保持 `DraftInput / DraftOutput` 结构稳定
- 后续接真实 LLM 时只替换适配层，不改 route 和 service 签名

### 6.3 输出建议结构

- 计划标题
- 阶段列表
- 每阶段任务建议
- 时间安排建议
- 说明文案

---

## 7. 编码任务清单

> 详细断点恢复、任务状态和验收顺序以 [kotlin-dev-plan.md](./kotlin-dev-plan.md) 为准；本节仅保留技术文档中的简表。

- [ ] T-B001：Ktor 项目骨架、插件配置、健康检查
- [ ] T-B002：`installation_id` 上下文、中间件、统一响应结构
- [ ] T-B003：Flyway 初始化迁移、Exposed 表定义
- [ ] T-B004：Profile / Settings 模块
- [ ] T-B005：Plan / Phase / Task CRUD
- [ ] T-B006：Timeline / Schedule / BattleMap 聚合接口
- [ ] T-B007：TaskInstance 更新与版本控制
- [ ] T-B008：Chat 消息与 DraftGenerator
- [ ] T-B009：Notes 文件夹与文件接口
- [ ] T-B010：错误处理、日志、集成测试

---

## 8. 编码注意事项

- `routes` 只做参数解析和响应封装，业务逻辑必须放在 `services`。
- 使用 `StatusPages` 统一异常输出。
- 使用 Exposed 参数化查询，避免拼接 SQL。
- 当前版本虽无登录，但仍要保证 `installation_id` 缺失时返回明确错误。
- 计划更新接口必须具备事务性，避免阶段和任务只更新一半。
- Notes 更新接口应优先保证文件内容不丢失，再处理同步对齐。
- 所有写接口尽量支持幂等重放，适应客户端补偿同步。

---

## 9. 测试建议

### 9.1 单元测试

- PlanService 计划保存与更新
- NowService 推荐逻辑
- NotesService 文件夹树与文件内容更新
- SyncSupportService 版本冲突处理
- ChatService 草稿生成输出结构

### 9.2 集成测试

- `POST /plans` 创建完整计划
- `PUT /plans/{id}` 更新计划并回读详情
- `PATCH /task-instances/{id}` 更新实例状态
- `GET /overview/battle-map` 返回主线聚合
- `POST /chat/messages` 返回草稿
- `GET /notes` 返回根目录结构
- `PUT /notes/files/{id}` 更新文件并回读

### 9.3 边界测试

- installation_id 缺失
- 重复提交同一版本
- 离线重放导致的重复写入
- 删除后的计划仍被详情接口访问
- 删除后的 Notes 资源再次访问

---

*本文件供后续 Kotlin 编码直接使用；当前版本已纳入 Notes 模块，并与 PRD、Figma 和技术方案保持一致。*
