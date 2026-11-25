# {模块名} 模块开发文档

> 规则来源：`.cursor/rules/12-Java模块开发文档.mdc`
> 用途：单个后端模块的详细开发指南，可直接驱动 AI 编码。
> 路径：`projects/{currentProject}/04-后端/开发计划/{module-name}.md`

---

## 1. 功能定位与边界

- 模块名：`{module-name}`
- 功能定位：`{一句话说明这个模块在做什么}`
- 边界：
  - 包含：
  - 不包含：

---

## 2. 涉及的 Controller / Service / Mapper / Entity

| 类型 | 类名 | 文件路径 | 状态 |
|------|------|----------|------|
| Controller | `XxxController.java` | `controller/XxxController.java` | pending |
| Service | `XxxService.java` | `service/XxxService.java` | pending |
| Mapper | `XxxMapper.java` | `mapper/XxxMapper.java` | pending |
| Entity | `XxxEntity.java` | `domain/entity/XxxEntity.java` | pending |
| Migration | `V{N}__xxx.sql` | `resources/db/migration/V{N}__xxx.sql` | pending |

---

## 3. 接口契约

### 3.1 POST /api/xxx

- **描述**：
- **鉴权**：必须 / 可选
- **请求体**：
  ```json
  { "field": "string" }
  ```
- **成功响应**：
  ```json
  { "code": 0, "message": "ok", "data": {} }
  ```
- **错误码**：1001 / 2001 / ...
- **前端引用**：`projects/{currentProject}/03-前端/开发计划/{对应模块}.md` §X.Y

---

## 4. 数据表与迁移

### 4.1 涉及表

| 表名 | 字段 | 索引 | 是否新增 |
|------|------|------|----------|
| `xxx` | id, name, created_at | uniqueIndex(name) | 新增 |

### 4.2 迁移脚本

```sql
-- V{N}__create_xxx.sql
CREATE TABLE xxx (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 5. 业务规则与状态流转

- 规则 1：`{描述}`
- 规则 2：`{描述}`
- 状态流转：

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Activated: activate()
    Activated --> Archived: archive()
    Archived --> [*]
```

---

## 6. 异常处理与日志要求

- 参数错误：`throw IllegalArgumentException(...)`
- 资源不存在：`throw NotFoundException(...)`
- 业务规则错误：`throw new BusinessException(2xxx, "...")`
- 日志：关键操作必须 `log.info(...)`，异常必须 `log.error("context", e)`

---

## 7. 依赖前置

- 其他模块：`auth`（提供 JWTPrincipal）
- 外部 SDK：无
- 配置项：`application.properties` 中的 `xxx.enabled`

---

## 8. 建议实现步骤

1. 写迁移脚本，本地启动验证
2. 写 Entity
3. 写 Mapper + 单元测试
4. 写 Service + 单元测试
5. 写 Request / Response 模型
6. 写 Controller 并注册路由映射
7. 写集成测试

---

## 9. 详细编码任务清单

| 任务 ID | 名称 | 状态 | 备注 |
|---------|------|------|------|
| T-B020 | 创建 `xxx` 表迁移脚本 | pending | |
| T-B021 | 实现 `XxxMapper` | pending | |
| T-B022 | 实现 `XxxService` | pending | |
| T-B023 | 实现 `XxxController` | pending | |
| T-B024 | 编写集成测试 | pending | |

---

## 10. 测试要求

- 单元测试：Service 关键方法 + Mapper 自定义查询
- 集成测试：每个接口至少 1 个正常路径 + 1 个错误路径
- 契约测试：与前端模块文档对齐

---

## 11. 验收标准

- [ ] 所有任务 `done`
- [ ] `./gradlew build` 通过
- [ ] 单元测试覆盖率达到约定（默认 60%+）
- [ ] 集成测试全部通过
- [ ] 接口契约与前端模块文档一致
- [ ] `change-plan.md` 中本模块相关变更条目已归档

---

## 12. 编码注意事项

- `{该模块特有的注意点}`
- 不允许在 Controller 中写业务逻辑
- 数据库写操作必须在事务内
- 敏感字段不入日志
