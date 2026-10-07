# 代码仓库编码规范模板

这里是**新项目用的模板**。新建仓库时，把对应技术栈的目录复制到仓库的规范目录（建议 `.cursor/rules/`，和现有项目一致），按项目实际修改，再在仓库根 `AGENTS.md` 的「规范索引」登记。

**复制进仓库之后，以仓库里的规范为准。** 这里的模板之后再改，不会自动同步到已有项目；AI 编码时也不读这里。

## Flutter（`flutter/`）

| 文件 | 内容 |
|---|---|
| `02-项目结构目录.md` | 工程和 `lib/` 分层骨架 |
| `03-编码规范.md` | 命名、导入、状态管理、错误处理 |
| `04-导航规则.md` | go_router 路由结构与传参 |
| `05-多语言支持.md` | 多语言目录与约束 |
| `06-第三方依赖参考.md` | 按类别的依赖选型 |
| `07-新功能开发.md` | 模块结构、Controller 职责、路由接入 |
| `08-UI处理任务.md` | 对稿流程、适配、状态、资源 |
| `task-new_feature.md` | 新建功能模块的详细模板 |
| `task-ui_task.md` | UI 任务的详细做法 |
| `task-bug_fix.md` | 定位、最小修复、验证 |
| `task-logic_change.md` | 业务规则、状态流转修改 |
| `task-refactor.md` | 不改行为的结构整理 |
| `task-other.md` | 其他代码任务 |
| `init/01-项目初始化规则.md`、`init/task-project_init.md` | 只在新建工程时使用 |

## Java（`java/`）

| 文件 | 内容 |
|---|---|
| `02-项目结构目录.md` | Spring Boot + MyBatis-Plus 分层骨架 |
| `03-编码规范.md` | 分层、命名、空值、异常、日志 |
| `04-路由与控制器规则.md` | Controller → Service → Mapper 职责 |
| `05-数据库与持久化.md` | MyBatis-Plus、迁移脚本、事务、缓存、索引 |
| `06-第三方依赖参考.md` | 按类别的依赖选型 |
| `07-新接口开发.md` | 新接口的标准步骤 |
| `08-鉴权与安全.md` | JWT、密码、注入防护、限流、敏感数据 |
| `init/01-项目初始化规则.md` | 只在新建工程时使用 |

## 和 v1 相比去掉了什么

- v1 的 `09-大功能先规划再编码`、`10-编码工作流程`、Flutter `11-测试规则`、`13/14 编码索引` 由工作台 `workflow/04-开发计划.md`、`05-开发执行.md`、`06-测试验收.md` 取代，原文件在 `legacy/v1/`。
- 文件开头的 Cursor frontmatter（`description` / `globs` / `alwaysApply`）已删除。现在由仓库根 `AGENTS.md` 的规范索引决定什么时候读哪份规范，Codex、Claude Code、Cursor 都能用。
