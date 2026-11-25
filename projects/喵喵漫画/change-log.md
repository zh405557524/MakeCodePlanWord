# 喵喵漫画研发变更日志

> 说明：本文件记录研发面向的跨迭代变更。用户面向版本日志后续在 `08-发布版本/changelog.md` 中维护。

---

## v0.1.0

| 日期 | 类型 | 变更 | 关联文件 |
|------|------|------|----------|
| 2026-06-10 | init | 初始化喵喵漫画项目流程工作空间并生成需求清单 | `workflow.md`、`01-需求/requirements-list.md`、`01-需求/references/README.md` |
| 2026-06-10 | docs | 根据已确认需求清单生成 PRD | `01-需求/requirements.md`、`workflow.md` |
| 2026-06-10 | docs | 完成 PRD 检测，结论 PASS | `01-需求/detection-report.md`、`01-需求/detection-feedback.md`、`workflow.md` |
| 2026-06-10 | docs | 生成 Figma 设计稿计划 | `01-需求/figma-design-plan.md`、`workflow.md` |

## v0.1.1

| 日期 | 类型 | 变更 | 关联文件 |
|------|------|------|----------|
| 2026-06-10 | feature_modify | 应用名称统一更新为 `喵喵漫画`，并同步 appCode 候选为 comic 口径 | `workflow.md`、`change-plan.md`、`change-log.md`、`01-需求/*.md`、`01-需求/references/README.md` |
| 2026-06-10 | docs | 生成技术方案，默认 appCode 收口为 `catcomic`，拆分前端与后端任务 | `02-技术方案/tech-plan.md`、`workflow.md` |
| 2026-06-10 | docs | 生成工作时长评估，输出三点估计、关键路径、里程碑和缓冲策略 | `02-技术方案/effort-estimate.md`、`workflow.md` |
| 2026-06-10 | docs | 生成 Flutter 技术文档，明确前端技术路线、路由、状态、UI、编码任务和项目专属规则 | `03-前端/flutter-tech.md`、`workflow.md` |
| 2026-06-10 | docs | 生成 Java 后端技术文档，明确 `catcomic` 接入、迁移脚本、资产库接口、安全隔离和测试计划 | `04-后端/java-tech.md`、`workflow.md` |

## v0.1.2

| 日期 | 类型 | 变更 | 关联文件 |
|------|------|------|----------|
| 2026-06-10 | feature_modify | 明确 SQL 表结构/迁移脚本只做创建表、修改表、索引、约束和注释，不直接内置业务数据、JSON 配置或示例数据；数据允许通过代码、后台接口、初始化服务或运营导入添加 | `02-技术方案/tech-plan.md`、`02-技术方案/effort-estimate.md`、`03-前端/flutter-tech.md`、`04-后端/java-tech.md`、`workflow.md`、`change-plan.md` |

## v0.1.3

| 日期 | 类型 | 变更 | 关联文件 |
|------|------|------|----------|
| 2026-06-10 | feature_modify | 移除 Java 后端技术文档中的测试 appCode 干扰项，避免误解为喵喵漫画真实 App 或需要新增的 appCode | `04-后端/java-tech.md`、`workflow.md`、`change-plan.md` |
| 2026-06-10 | docs | 生成 Flutter 总体开发计划，拆分 T-F001~T-F010、业务接口约束、模块文档清单和验证计划 | `03-前端/flutter-dev-plan.md`、`workflow.md` |
| 2026-06-10 | docs | 生成 Java 总体开发计划，拆分 T-B001~T-B008、API 任务表、模块文档清单和验证计划 | `04-后端/java-dev-plan.md`、`workflow.md` |
| 2026-06-10 | docs | 生成 Flutter 模块开发文档，按 Figma 当前稿校准首页与资产库；其它原工程没有的页面收口为空白展示 | `03-前端/开发计划/*.md`、`03-前端/flutter-dev-plan.md`、`workflow.md` |
| 2026-06-10 | docs | 清理剩余旧分镜英文命名，统一改为 `shot-plan` / `comic_shot_plans` 口径 | `02-技术方案/tech-plan.md`、`03-前端/flutter-tech.md` |
| 2026-06-10 | docs | 生成 Java 模块开发文档，拆分 AppCode、迁移、首页接口、资产库接口、安全隔离和 OpenAPI 联调说明 | `04-后端/开发计划/*.md`、`04-后端/java-dev-plan.md`、`workflow.md` |
| 2026-06-10 | code | 完成 Flutter P0 编码：首页、资产库、空白页占位、名称与 appCode 调整，并通过 `flutter analyze`、`flutter test` | `/Users/soul/code/lxwx/make_drama`、`workflow.md` |
| 2026-06-10 | code | 完成 Java P0 编码：`catcomic` schema routing、专属迁移、首页表复用、资产库读取接口与隔离测试，并通过 `./gradlew test`、`./gradlew build` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice`、`04-后端/java-dev-plan.md`、`workflow.md` |
| 2026-06-11 | feature_modify | 原生应用包名 / Bundle Identifier 统一改为 `com.lxwx.makedrama`，Dart 内部 `package:narrate` 导入名保持不变 | `/Users/soul/code/lxwx/make_drama/android`、`ios`、`macos`、`windows`、`README.md`、`workflow.md`、`change-plan.md` |
| 2026-06-11 | code_quality | 按用户要求为 `ComicAssetEntity` 每个字段补充中文语义注释，不改变表结构、迁移脚本或接口契约 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/comic/asset/entity/ComicAssetEntity.java`、`workflow.md`、`change-plan.md` |
| 2026-06-11 | feature_modify | 底部 Tab “我的”接回旧 `AccountPage`，完整复用登录态、用户信息、积分、VIP、邀请、反馈、设置、订单和充值等二级入口；“作品”仍保持空白占位 | `/Users/soul/code/lxwx/make_drama/lib/pages/main/**`、`/Users/soul/code/lxwx/make_drama/test/widget_test.dart`、`03-前端/flutter-dev-plan.md`、`03-前端/开发计划/02-routing-shell.md`、`03-前端/开发计划/08-placeholder-pages.md`、`workflow.md`、`change-plan.md` |
