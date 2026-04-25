# 漫剧制作 App Flutter 总体开发计划文档

> 版本：v1.1  
> 更新日期：2026-04-25  
> 关联前端技术文档：[flutter-tech.md](./flutter-tech.md)  
> 关联后端技术文档：[../04-后端/kotlin-tech.md](../04-后端/kotlin-tech.md)  
> 关联业务流程图：[../02-技术方案/app-flow.md](../02-技术方案/app-flow.md)  
> 设计真源：Figma 手机端 UI 稿，主尺寸 375 x 812  
> 技术栈：GetX + GetStorage + Hive + go_router + Dio + ScreenUtil  
> 文档状态：`regenerated`  
> 编码状态：`pending`

---

## 1. 文档用途

本文档是 Flutter 编码阶段的总控计划，用于明确：

- 当前恢复点和可继续执行的下一步。
- 前端页面、Controller、Service、API、Store、本地缓存的开发顺序。
- 与后端接口一致的业务逻辑，不另行发明接口。
- Figma 设计稿逐页实现和验收要求。
- 需要拆分到模块计划文档的编码任务。

使用规则：

- 编码前先读本文档，再读 [flutter-tech.md](./flutter-tech.md) 和对应模块计划。
- 同一时刻只允许一个主任务处于 `in_progress`。
- 每完成一个任务，回写“执行记录”和“当前恢复点”。
- 若 Figma、前端技术文档、后端接口冲突，先修订文档再编码。

---

## 2. 当前状态与恢复点

### 2.1 当前状态

| 项目 | 状态 |
| --- | --- |
| PRD | 已完成 |
| Figma UI 稿 | 已完成，375 x 812，分镜页允许纵向加高 |
| 业务流程图 | 已确认并更新 |
| 后端技术文档 | 已按同步解析 + 异步生成任务重写 |
| Flutter 技术文档 | 已按后端接口和 Figma 规则重写 |
| Flutter 总体开发计划 | 当前文档已重写 |
| Flutter 模块开发计划 | 已同步重写 |
| Flutter 编码 | 未开始 |

### 2.2 当前恢复点

当前恢复点：`F-001 工程骨架与目录初始化`

下一步默认动作：

1. 审核本文档和 `开发计划/` 下的模块计划。
2. 审核通过后，从 `开发计划/01-app-foundation.md` 开始编码。
3. 编码过程中每完成一个任务，更新任务状态和执行记录。

---

## 3. 状态枚举

| 状态 | 含义 |
| --- | --- |
| `pending` | 未开始 |
| `in_progress` | 执行中 |
| `done` | 已完成 |
| `blocked` | 被阻塞 |
| `waiting_review` | 待审核 |
| `skipped` | 本轮明确跳过 |

恢复规则：

1. 优先查找 `in_progress` 任务并继续。
2. 没有 `in_progress` 时，从第一个依赖满足的 `pending` 任务开始。
3. 存在 `blocked` 时，先处理阻塞原因。
4. UI 任务必须先确认 Figma Frame，再进入编码。

---

## 4. 总体开发策略

开发顺序按“底座 -> 设计系统 -> 同步解析主入口 -> 角色/场景图片任务 -> 分镜资源任务 -> 视频任务 -> 联调验收”推进。

硬依赖：

- 未完成 `main.dart / Global.init()`，不进入页面开发。
- 未完成 `HttpService`，不进入接口联调。
- 未完成 `GetStorage + Hive`，不进入草稿、缓存、任务恢复。
- 未完成 `RouteName + go_router`，不进入主链路跳转。
- 未完成通用组件，不进入 Figma 页面还原。
- 未完成同步解析接口，不进入角色页正式链路。
- 未完成角色/场景图片任务轮询，不进入分镜完整联调。

业务硬约束：

- 点击「开始解析」前没有正式 `workId`。
- `POST /api/v1/works/parse` 是同步接口，成功后返回 `workId` 和角色步骤数据。
- 角色、场景、分镜资源、视频是异步任务，统一通过 `GET /api/v1/tasks/{taskId}` 轮询。
- 页面数据按 `workId + step` 获取，不要求接口返回作品全量。
- 角色/场景不展示「已生成」文案，有 `imageUrl` 就是有图，没有 `imageUrl` 就是无图。
- 角色/场景存在 `queued/running` 图片任务时，禁止进入下一步。
- 分镜字段统一使用 `description`，不实现 `title` 输入。
- 分镜角色多选，分镜场景单选。

UI 硬约束：

- Flutter UI 必须按照 Figma 手机端设计稿实现。
- 375 x 812 是主验收尺寸；390 x 844、430 x 932 是补充验收尺寸。
- 分镜处理页允许纵向长页面。
- 宽屏参考图只作颜色和流程参考，不作为移动端布局依据。

---

## 5. 阶段划分

| 阶段 | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| A | 工程底座 | 工程可启动，路由、网络、存储、模型完成 | `pending` |
| B | 设计系统 | 深色主题、通用组件、任务状态组件完成 | `pending` |
| C | 首页与同步解析 | 首页、作品列表、作品创建、同步解析完成 | `pending` |
| D | 角色与场景 | 角色/场景步骤数据、图片任务、下一步禁用完成 | `pending` |
| E | 分镜处理 | 分镜描述、角色多选、场景单选、参数和资源任务完成 | `pending` |
| F | 视频预览 | 视频预览、播放、视频任务、分享完成 | `pending` |
| G | 联调验收 | 主链路、异常态、任务恢复、Figma 验收完成 | `pending` |

---

## 6. 详细任务清单

| ID | 阶段 | 任务 | 依赖 | 主要输出 | 接口 / 存储 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| F-001 | A | 创建工程骨架与目录 | 无 | `apis/models/pages/routes/services/store/widgets` | 无 | `pending` |
| F-002 | A | 建立启动与全局初始化 | F-001 | `main.dart`、`global.dart`、依赖注册 | GetStorage、Hive init | `pending` |
| F-003 | A | 建立网络与统一响应 | F-002 | `HttpService`、错误处理、请求头 | `X-Installation-Id`、`Idempotency-Key` | `pending` |
| F-004 | A | 建立路由 | F-001 | `RouteName`、`go_router`、按 `currentStep` 跳转 | `workId` 参数 | `pending` |
| F-005 | A | 建立模型与枚举 | F-001 | Work、Character、Scene、Storyboard、Task | 后端响应模型 | `pending` |
| F-006 | A | 建立本地存储服务 | F-002 | `StorageService`、Box、草稿、缓存 | `works_cache`、`step_cache`、`generation_tasks` | `pending` |
| F-007 | B | 建立主题 Token | F-001 | 深色主题、颜色、字号、圆角 | 无 | `pending` |
| F-008 | B | 建立页面容器 | F-004、F-007 | `CustomScaffold`、安全区、底部栏 | 无 | `pending` |
| F-009 | B | 建立通用组件 | F-007 | TopBar、按钮、卡片、Chip、弹层 | 无 | `pending` |
| F-010 | B | 建立任务状态组件 | F-009 | 生成中、失败、进度、重试组件 | `GenerationTask` | `pending` |
| F-011 | C | 实现首页与作品列表 | F-003、F-004、F-009 | 首页、作品卡、空态、续作路由 | `GET /api/v1/works`、`works_cache` | `pending` |
| F-012 | C | 实现作品创建页 | F-006、F-009 | 文本输入、草稿、开始解析按钮 | `story_drafts` | `pending` |
| F-013 | C | 接入同步解析 | F-003、F-012 | 同步创建作品、返回 `workId`、进入角色页 | `POST /api/v1/works/parse` | `pending` |
| F-014 | D | 实现角色生成页 | F-013、F-010 | 角色卡片、有图/无图/生成中/失败 | `GET /works/{workId}/characters` | `pending` |
| F-015 | D | 接入角色图片任务 | F-014 | 生成角色、重新生成、轮询刷新 | `POST /characters/{id}/image-task`、`GET /tasks/{id}` | `pending` |
| F-016 | D | 实现角色确认推进 | F-015 | 生成中禁用下一步，保存选择进入场景 | `PUT /characters/selection` | `pending` |
| F-017 | D | 实现场景生成页 | F-016 | 场景卡片、有图/无图/生成中/失败 | `GET /works/{workId}/scenes` | `pending` |
| F-018 | D | 接入场景图片任务与确认 | F-017 | 生成场景、重新生成、轮询、进入分镜 | `POST /scenes/{id}/image-task`、`PUT /scenes/selection` | `pending` |
| F-019 | E | 实现分镜处理基础布局 | F-018、F-009 | 分镜列表、预览、描述、参数区 | `GET /works/{workId}/storyboards` | `pending` |
| F-020 | E | 实现分镜描述保存 | F-019、F-006 | `description` 编辑、debounce、切换保存 | `PUT /storyboards/{id}`、`storyboard_drafts` | `pending` |
| F-021 | E | 实现分镜角色多选页 | F-019 | 多选角色，应用到当前分镜 | `PUT /storyboards/{id}` | `pending` |
| F-022 | E | 实现分镜场景单选页 | F-019 | 单选场景，应用到当前分镜 | `PUT /storyboards/{id}` | `pending` |
| F-023 | E | 实现分镜参数与资源生成 | F-020 | 风格、配音、音效、单个/批量生成 | `POST /storyboards/{id}/generate`、`POST /storyboards/generate-all` | `pending` |
| F-024 | F | 实现视频预览页 | F-023 | 播放器、字幕、胶片列表、返回编辑 | `GET /works/{workId}/video` | `pending` |
| F-025 | F | 接入视频生成与分享 | F-024 | 视频任务轮询、分享链接 | `POST /video/generate`、`POST /share` | `pending` |
| F-026 | G | 主链路联调 | F-011 ~ F-025 | 首页到视频完整闭环 | 全链路接口 | `pending` |
| F-027 | G | 异常态与任务恢复 | F-010、F-026 | 失败重试、后台恢复、重复任务处理 | `generation_tasks`、`GET /tasks/{id}` | `pending` |
| F-028 | G | 多尺寸适配 | F-026 | 375/390/430 宽度检查 | Figma 对照 | `pending` |
| F-029 | G | Figma 视觉验收 | F-028 | 逐页修正布局、颜色、间距、状态 | 全部 Frame | `pending` |

---

## 7. 模块开发文档列表

| 文件 | 覆盖任务 | 状态 |
| --- | --- | --- |
| `开发计划/01-app-foundation.md` | F-001 ~ F-006 | `regenerated` |
| `开发计划/02-design-system.md` | F-007 ~ F-010 | `regenerated` |
| `开发计划/03-home-story.md` | F-011 ~ F-013 | `regenerated` |
| `开发计划/04-character-scene.md` | F-014 ~ F-018 | `regenerated` |
| `开发计划/05-storyboard.md` | F-019 ~ F-023 | `regenerated` |
| `开发计划/06-video-preview.md` | F-024 ~ F-025 | `regenerated` |
| `开发计划/07-integration-qa.md` | F-026 ~ F-029 | `regenerated` |

---

## 8. 编码约束

技术约束：

- 使用 `GetX` 管页面状态。
- 使用 `go_router` 收口路由。
- 使用 `Dio` + `HttpService` 统一请求。
- 使用 `GetStorage + Hive` 做轻量配置、草稿、缓存和任务恢复。
- 不引入 `Riverpod / Provider / Drift` 作为主方案。
- 不使用 `Get.context!`。

业务约束：

- 不在前端发明与后端文档不一致的接口。
- 文本解析同步处理，不加入任务轮询。
- 图片、分镜资源、视频生成全部走异步任务轮询。
- 角色/场景的生成状态由 `imageUrl` 和 `runningTaskId` 推导。
- 生成失败保留旧资产。
- 生成中不能重复提交同一个目标任务。

UI 约束：

- 每个页面实现前必须确认对应 Figma Frame。
- 页面结构、组件顺序、按钮位置、底部安全区、卡片层级必须对齐 Figma。
- 分镜页可以纵向滚动，不压缩内容。
- 文案溢出必须处理，不能遮挡 UI。

---

## 9. 审核关注点

- 同步解析接口是否已经和后端文档一致。
- 角色/场景是否彻底去掉「已生成」字段依赖。
- 生成中禁用下一步的规则是否足够明确。
- 分镜 `description`、角色多选、场景单选是否落实到任务。
- 模块计划是否能直接交给编码执行。

---

## 10. 执行记录

| 日期 | 操作 | 结果 | 当前恢复点 | 备注 |
| --- | --- | --- | --- | --- |
| 2026-04-25 | 重写 Flutter 总体开发计划 | 完成 | `F-001` | 对齐同步解析、异步生成任务、Figma 优先 |
| 2026-04-25 | 同步重写模块开发计划 | 完成 | `F-001` | 7 个模块计划已更新 |

---

*本文件是 Flutter 编码阶段的总控文档。审核通过后，从 `开发计划/01-app-foundation.md` 开始编码。*
