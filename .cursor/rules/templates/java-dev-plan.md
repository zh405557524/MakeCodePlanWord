# {项目名称} Java 总体开发计划

> 规则来源：`.cursor/rules/10-Java开发计划文档.mdc`
> 用途：把 `java-tech.md` 拆成可执行、可断点恢复的后端任务总表。
> 维护规则：任务完成后回写状态；变更影响任务时同步更新。

---

## 1. 文档用途

- 给 AI / 开发者按序执行 Java 后端编码
- 支持中断恢复（每个任务有恢复点字段）
- 与 `effort-estimate.md` 对齐排期

---

## 2. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `第 X 阶段` |
| 当前任务 | `T-Bxxx` |
| 当前任务状态 | `pending` |
| 恢复点 | `{文件:行号 或 任务起点}` |
| 下一步默认动作 | |

---

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 进行中 |
| `waiting_review` | 待用户审核 |
| `done` | 已完成 |
| `blocked` | 被阻塞 |
| `skipped` | 用户跳过 |

更新规则：每次完成 / 暂停一个任务，必须更新状态并写入「执行记录」。

---

## 4. 总体开发策略

分层顺序：

1. 基础设施（Application、config、DB、Redis、配置）
2. 鉴权模块
3. 数据库表与 Mapper 层
4. 业务接口（按模块）
5. 集成测试与契约验证
6. 部署配置（Docker、CI）

---

## 5. 总体阶段划分

引用 `effort-estimate.md` 中的阶段汇总：

| 阶段 | 任务范围 | 工时（人天） | 起止日期 |
|------|----------|--------------|----------|
| 第一阶段 | 基础设施 + 鉴权 | | |
| 第二阶段 | 核心业务模块 | | |
| 第三阶段 | 集成测试 + 部署 | | |

---

## 6. 详细任务清单

| 任务 ID | 名称 | 依赖任务 | 状态 | 工时（E） | 关联模块文档 | 备注 |
|---------|------|----------|------|-----------|--------------|------|
| T-B001 | 搭建 Spring Boot + MyBatis-Plus 基础结构 | - | pending | | `04-后端/开发计划/infrastructure.md` | |
| T-B002 | 实现鉴权模块 | T-B001 | pending | | `04-后端/开发计划/auth.md` | |

---

## 7. API 接口任务表

| 任务 ID | 接口 | 方法 | 路径 | 依赖表 | Service | 状态 |
|---------|------|------|------|--------|---------|------|
| T-B010 | 用户注册 | POST | /api/auth/register | users | AuthService | pending |
| T-B011 | 用户登录 | POST | /api/auth/login | users | AuthService | pending |

---

## 8. 模块开发文档列表

| 模块名 | 文档路径 | 当前状态 | 关联任务 |
|--------|----------|----------|----------|
| infrastructure | `04-后端/开发计划/infrastructure.md` | pending | T-B001 |
| auth | `04-后端/开发计划/auth.md` | pending | T-B002, T-B010, T-B011 |

---

## 9. 编码约束

- 默认 `Java + Spring Boot + Gradle + MyBatis-Plus + PostgreSQL + Redis + JWT + 自定义 ApiResponse`
- 分层：Controller → Service → Mapper，禁止跨层
- 接口契约必须与 `java-tech.md` 一致；若需变更先走 `change-plan.md`

---

## 10. 执行记录

| 时间 | 任务 ID | 操作 | 结果 |
|------|---------|------|------|
| YYYY-MM-DD | T-B001 | 创建 Application.java | done |
