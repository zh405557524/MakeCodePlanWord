# 喵喵写歌 v1.1 AI 翻唱 Java 开发计划

> V2.1 名称校准：本文件描述的旧链路现称“AI 改编”，不包含声音克隆；仅保留历史实现记录，禁止用于 V2.1 新“AI 翻唱（声音克隆）”编码。
> 版本：`v1.1-ai-cover`
> 变更：`CHG-0013 AI 翻唱功能`
> 状态：`reference-only`
> 执行入口：本文件和 `04-后端/v1.1-ai-cover/开发计划/*.md`

## 任务列表

| 编号 | 模块 | 状态 | 说明 |
|------|------|------|------|
| B-COVER-01 | 数据迁移与实体 | done | catsinger 翻唱字段、音色配置表已落地 |
| B-COVER-02 | 翻唱模型与音色配置 | done | `music-cover` 模型、音色分组、试听资源已对齐 |
| B-COVER-03 | 源音频上传校验 | done | 源音频上传、格式/大小/时长校验已落地 |
| B-COVER-04 | 翻唱创建与查询 | done | `/api/song-covers` 已强制 cover 模式并支持查询 |
| B-COVER-05 | MiniMax Provider 与资源持久化 | done | `music-cover` 请求映射、结果持久化已落地 |
| B-COVER-06 | 积分与幂等 | done | 冻结、扣减、退款、重复提交防重已对齐 |
| B-COVER-07 | Admin 接口 | done | 音色 CRUD、作品类型筛选已对齐 |
| B-COVER-08 | 测试 | done | schema routing、上传校验、积分、Provider mock 和全量测试通过 |
| B-COVER-09 | 天谱乐翻唱取词与历史维护 | waiting_review | CHG-0067：海报后查询原任务歌词，持久化 120 秒截止、暂停恢复与缺词降级；独立 dry-run/apply 工具已实现；无表结构/迁移改动，本轮不写真实历史数据；全量在临时 2GB 测试堆下通过（1477 项、3 跳过、0 失败），待发布验收 |

## 模块文档索引

> 2026-06-25 已完成本版本 Java 编码对账、缺口补齐和命令验证；真实 MiniMax / 云存储联调进入人工验收。

| 模块 | 文档 | 文档状态 |
|------|------|----------|
| 总索引 | `04-后端/v1.1-ai-cover/开发计划/00-cover-module-index.md` | done |
| 数据迁移与实体 | `04-后端/v1.1-ai-cover/开发计划/01-schema-and-entities.md` | done |
| 模型与音色配置 | `04-后端/v1.1-ai-cover/开发计划/02-cover-voice-config.md` | done |
| 源音频上传 | `04-后端/v1.1-ai-cover/开发计划/03-cover-source-audio-upload.md` | done |
| 翻唱任务接口 | `04-后端/v1.1-ai-cover/开发计划/04-cover-task-api-service.md` | done |
| Provider 与资源持久化 | `04-后端/v1.1-ai-cover/开发计划/05-cover-workflow-provider-resource.md` | done |
| 积分与幂等 | `04-后端/v1.1-ai-cover/开发计划/06-points-idempotency.md` | done |
| Admin 接口 | `04-后端/v1.1-ai-cover/开发计划/07-admin-cover-api.md` | done |
| Java 验收 | `04-后端/v1.1-ai-cover/开发计划/08-java-tests.md` | done |
| CHG-0067 歌词补齐维护与验证 | `04-后端/v1.1-ai-cover/开发计划/09-cover-lyrics-backfill.md` | waiting_review |

## 验证

已执行 targeted tests 和 `./gradlew test`，均通过。本轮不自动进入 QA、打包或上架。
