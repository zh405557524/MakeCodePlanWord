# 漫剧制作 App Flutter 前端技术文档

> 版本：v1.1  
> 更新日期：2026-04-25  
> 关联流程图：[../02-技术方案/app-flow.md](../02-技术方案/app-flow.md)  
> 关联后端文档：[../04-后端/kotlin-tech.md](../04-后端/kotlin-tech.md)  
> 目标平台：iOS / Android  
> 设计尺寸：375 x 812，分镜处理页允许纵向加高  
> 技术栈：Flutter + GetX + go_router + Dio + GetStorage + Hive + ScreenUtil

---

## 0. 文档定位

本文档用于约束漫剧制作 App 的 Flutter 端实现，重点明确：

- UI 必须按 Figma 手机端设计稿实现。
- 文本解析是同步任务，点击「开始解析」成功后才产生 `workId`。
- 角色、场景、分镜资源、视频生成是异步任务，需要创建任务并轮询。
- 后续页面都基于 `workId` 获取当前步骤数据，不要求接口每次返回作品全量。
- 角色/场景不展示「已生成」文案：有图片即已生成，无图片即未生成，生成中禁止进入下一步。

---

## 1. 技术路线

| 层级 | 方案 | 说明 |
| --- | --- | --- |
| 页面组织 | `pages/{feature}/view.dart + controller.dart + index.dart` | 与参考 Flutter 工程风格一致 |
| 状态管理 | `GetX` | 页面状态由 Controller 管理，全局状态由 Store / Service 管理 |
| 路由 | `go_router` | 使用路由名统一收口 |
| 网络 | `dio` | 统一请求头、错误处理、超时、重试 |
| 轻量存储 | `GetStorage` | 保存设备 ID、最近偏好、最近作品 |
| 结构化缓存 | `Hive` | 缓存作品列表、草稿、任务状态、步骤数据 |
| UI 适配 | `flutter_screenutil` | 设计基准固定 `375 x 812` |
| 图片 | `cached_network_image` | 角色、场景、分镜、封面缓存 |
| 视频 | `video_player` | 预览页播放控制 |

启动时必须完成：

1. `WidgetsFlutterBinding.ensureInitialized()`。
2. `Hive.initFlutter()`。
3. 初始化 `GetStorage`。
4. 注册 `HttpService / StorageService / WorkStore / TaskStore`。
5. `ScreenUtilInit(designSize: Size(375, 812))`。
6. `MaterialApp.router` 接入 `go_router`。

---

## 2. 目录结构

```text
lib/
├── apis/
│   ├── work_api.dart
│   ├── character_api.dart
│   ├── scene_api.dart
│   ├── storyboard_api.dart
│   ├── video_api.dart
│   ├── task_api.dart
│   └── index.dart
├── models/
│   ├── work.dart
│   ├── character.dart
│   ├── scene.dart
│   ├── storyboard.dart
│   ├── generation_task.dart
│   └── index.dart
├── pages/
│   ├── home/
│   ├── story_input/
│   ├── character_generate/
│   ├── scene_generate/
│   ├── storyboard_edit/
│   ├── storyboard_character_select/
│   ├── storyboard_scene_select/
│   └── video_preview/
├── routes/
├── services/
│   ├── http_service.dart
│   ├── storage_service.dart
│   ├── work_service.dart
│   ├── task_polling_service.dart
│   └── draft_service.dart
├── store/
│   ├── app_store.dart
│   ├── work_store.dart
│   └── task_store.dart
├── widgets/
│   ├── app_top_bar.dart
│   ├── primary_button.dart
│   ├── work_card.dart
│   ├── asset_card.dart
│   ├── step_progress_bar.dart
│   ├── param_chip.dart
│   └── bottom_action_bar.dart
├── global.dart
├── main.dart
└── theme.dart
```

页面目录固定为：

```text
pages/{feature}/
├── view.dart
├── controller.dart
├── widgets/
└── index.dart
```

---

## 3. UI 实现原则

Flutter UI 的第一真源是 Figma 手机端设计稿。编码时不能只根据文字 PRD 重新设计页面。

| 优先级 | 来源 | 用途 |
| --- | --- | --- |
| 1 | Figma 设计稿 | 页面布局、间距、字号、颜色、圆角、组件状态 |
| 2 | [app-flow.md](../02-技术方案/app-flow.md) | 业务流程、步骤入口、同步/异步边界 |
| 3 | [requirements.md](../01-需求/requirements.md) | 需求背景、验收口径 |
| 4 | 宽屏参考图 | 仅参考色彩和氛围，不作为移动端布局依据 |

适配规则：

- 基准尺寸固定 `375 x 812`。
- 分镜处理页可超过 812 高度并纵向滚动。
- 底部主操作按钮必须避开安全区。
- 所有长文本必须支持换行或省略，禁止横向溢出。
- 角色/场景卡片状态必须按 Figma 最新稿实现：有图、无图、生成中、失败、选中。

---

## 4. 路由设计

| 页面 | 路由 | 参数 | 入口 |
| --- | --- | --- | --- |
| 首页 | `/` | 无 | App 启动 |
| 作品创建页 | `/create/story` | `workId?` | 首页开始创作、作品列表新建 |
| 角色生成页 | `/create/characters` | `workId` | 文本解析成功、作品列表续作 |
| 场景生成页 | `/create/scenes` | `workId` | 角色确认、作品列表续作 |
| 分镜处理页 | `/create/storyboards` | `workId`, `storyboardId?` | 场景确认、作品列表续作 |
| 分镜角色选择页 | `/create/storyboards/:storyboardId/characters` | `workId` | 分镜处理页 |
| 分镜场景选择页 | `/create/storyboards/:storyboardId/scene` | `workId` | 分镜处理页 |
| 视频预览页 | `/create/preview` | `workId` | 分镜处理页、作品列表续作 |

作品列表点击已有作品时，前端按 `currentStep` 路由：

| currentStep | 跳转 |
| --- | --- |
| `draft` | 作品创建页 |
| `characters` | 角色生成页 |
| `scenes` | 场景生成页 |
| `storyboards` | 分镜处理页 |
| `preview` | 视频预览页 |
| `completed` | 视频预览页 |

---

## 5. 状态与缓存

### 5.1 全局状态

| Store | 职责 |
| --- | --- |
| `AppStore` | 安装 ID、启动状态、网络状态、全局 loading |
| `WorkStore` | 当前作品、作品列表缓存、当前步骤 |
| `TaskStore` | 正在轮询的图片/音频/视频任务 |

### 5.2 本地存储

| 存储 | Key / Box | 用途 |
| --- | --- | --- |
| GetStorage | `installation_id` | 设备级身份标识 |
| GetStorage | `last_work_id` | 最近编辑作品 |
| GetStorage | `last_style / last_voice_preset / last_bgm_preset` | 参数偏好 |
| Hive | `works_cache` | 首页作品列表缓存 |
| Hive | `story_drafts` | 作品创建页文本草稿 |
| Hive | `step_cache` | 按 `workId + step` 缓存当前步骤数据 |
| Hive | `storyboard_drafts` | 分镜描述和参数草稿 |
| Hive | `generation_tasks` | 未完成任务和轮询恢复 |

### 5.3 数据流

```text
View -> Controller -> Service -> Api
                   -> Hive / GetStorage
                   -> Store
Store / Controller -> Obx -> View
```

原则：

- 页面进入时先展示本地缓存，再请求服务端当前步骤数据。
- 用户输入先写本地草稿，再按业务时机提交服务端。
- 生成任务创建后写入 `TaskStore`，由统一轮询服务刷新结果。
- 失败时保留旧图片、旧视频、用户编辑文本和本地草稿。

---

## 6. 核心业务流程

### 6.1 作品创建与文本解析

入口：

- 首页「开始创作」。
- 作品列表「新建漫剧」。

流程：

1. 用户在作品创建页输入故事文本。
2. 点击「开始解析」。
3. 前端调用同步接口 `POST /api/v1/works/parse`。
4. 后端创建 `workId`、记录作品状态、同步解析文本。
5. 接口成功返回 `workId`、`currentStep=characters`、角色页所需数据。
6. 前端保存 `workId`，跳转角色生成页。

注意：

- 点击「开始解析」前没有 `workId`。
- 文本解析不是轮询任务，失败直接在当前页显示错误。
- 如果用户退出页面，只能保存本地草稿；未解析成功前不进入作品列表的正式作品。

### 6.2 角色生成页

入口：

- 文本解析成功后自动进入。
- 作品列表点击 `currentStep=characters` 的作品。

页面数据：

- 调用 `GET /api/v1/works/{workId}/characters`。
- 响应只需要返回角色步骤数据，不要求返回作品全量。

角色卡片规则：

| 数据状态 | UI 表现 | 操作 |
| --- | --- | --- |
| `imageUrl != null` | 显示角色图片 | 重新生成 |
| `imageUrl == null` 且无运行任务 | 显示占位 | 生成角色 |
| 存在 `queued/running` 图片任务 | 显示生成中 | 禁止进入下一步 |
| 任务失败 | 保留旧图或占位，显示失败 | 重试 |

下一步规则：

- 任一相关角色图片任务处于 `queued/running` 时，确认按钮禁用。
- 无生成中任务时，点击确认调用 `PUT /api/v1/works/{workId}/characters/selection`。
- 成功后跳转场景生成页。

### 6.3 场景生成页

入口：

- 角色页确认后进入。
- 作品列表点击 `currentStep=scenes` 的作品。

页面数据：

- 调用 `GET /api/v1/works/{workId}/scenes`。

场景卡片规则：

| 数据状态 | UI 表现 | 操作 |
| --- | --- | --- |
| `imageUrl != null` | 显示场景图片 | 重新生成 |
| `imageUrl == null` 且无运行任务 | 显示占位 | 生成场景 |
| 存在 `queued/running` 图片任务 | 显示生成中 | 禁止进入下一步 |
| 任务失败 | 保留旧图或占位，显示失败 | 重试 |

下一步规则：

- 任一相关场景图片任务处于 `queued/running` 时，确认按钮禁用。
- 无生成中任务时，点击确认调用 `PUT /api/v1/works/{workId}/scenes/selection`。
- 成功后跳转分镜处理页。

### 6.4 分镜处理页

入口：

- 场景页确认后进入。
- 作品列表点击 `currentStep=storyboards` 的作品。

页面数据：

- 调用 `GET /api/v1/works/{workId}/storyboards`。
- 返回分镜列表、当前分镜详情、角色候选、场景候选、参数候选。

当前分镜字段：

| 字段 | 规则 |
| --- | --- |
| `description` | 分镜描述，替代原“分镜标题” |
| `characterIds` | 角色多选 |
| `sceneId` | 场景单选 |
| `style` | 画面风格 |
| `voicePreset` | 角色配音 |
| `bgmPreset` | 背景音效 |

操作：

- 分镜描述本地 debounce 保存，失焦或切换分镜时提交。
- 角色选择进入独立多选页。
- 场景选择进入独立单选页。
- 画面风格、角色配音、背景音效使用当前 Figma 参数卡片或底部弹层。
- 「生成此分镜」创建异步任务并轮询。
- 「一键生成全部」创建批量异步任务并展示批量进度。

### 6.5 视频预览页

入口：

- 分镜处理页进入预览。
- 作品列表点击 `currentStep=preview/completed` 的作品。

页面数据：

- 调用 `GET /api/v1/works/{workId}/video`。

操作：

- 未生成视频时显示「生成视频」。
- 生成中时显示进度，禁止重复生成。
- 成功后播放视频、显示胶片列表、支持分享链接。
- 失败时显示失败状态，允许重试。

---

## 7. 异步任务轮询

### 7.1 需要轮询的任务

| 任务 | 创建接口 | 查询接口 | 成功后刷新 |
| --- | --- | --- | --- |
| 角色图片 | `POST /works/{workId}/characters/{characterId}/image-task` | `GET /tasks/{taskId}` | 角色列表 |
| 场景图片 | `POST /works/{workId}/scenes/{sceneId}/image-task` | `GET /tasks/{taskId}` | 场景列表 |
| 单分镜资源 | `POST /works/{workId}/storyboards/{storyboardId}/generate` | `GET /tasks/{taskId}` | 分镜列表 |
| 批量分镜资源 | `POST /works/{workId}/storyboards/generate-all` | `GET /tasks/{taskId}` | 分镜列表 |
| 视频 | `POST /works/{workId}/video/generate` | `GET /tasks/{taskId}` | 视频预览 |

### 7.2 前端任务模型

```dart
enum GenerationStatus {
  queued,
  running,
  succeeded,
  failed,
  cancelled,
}

class GenerationTask {
  final String id;
  final String workId;
  final String targetType;
  final String? targetId;
  final String taskType;
  final GenerationStatus status;
  final int progress;
  final String? errorMessage;
  final int pollingIntervalMs;
}
```

### 7.3 轮询规则

- 创建任务后立即加入 `TaskStore`。
- `queued/running` 按后端返回 `pollingIntervalMs` 继续轮询。
- `succeeded` 停止轮询，并刷新目标步骤数据。
- `failed` 停止轮询，保留旧资产，展示重试入口。
- App 进入后台时降低轮询频率；回到前台后恢复并刷新当前步骤。
- 同一 `targetType + targetId + taskType` 只保留一个运行中任务。

---

## 8. API 封装

统一请求头：

```text
X-Installation-Id
X-App-Version
X-Timezone
Idempotency-Key
```

核心接口：

| 模块 | 方法 | 用途 |
| --- | --- | --- |
| WorkApi | `listWorks()` | 首页作品列表 |
| WorkApi | `parseAndCreateWork(content)` | 同步创建作品并解析文本 |
| WorkApi | `getWorkStep(workId, step)` | 按步骤获取数据 |
| CharacterApi | `getCharacters(workId)` | 获取角色步骤数据 |
| CharacterApi | `createImageTask(workId, characterId)` | 创建角色图片任务 |
| CharacterApi | `saveSelection(workId, payload)` | 保存角色选择并推进步骤 |
| SceneApi | `getScenes(workId)` | 获取场景步骤数据 |
| SceneApi | `createImageTask(workId, sceneId)` | 创建场景图片任务 |
| SceneApi | `saveSelection(workId, payload)` | 保存场景选择并推进步骤 |
| StoryboardApi | `getStoryboards(workId)` | 获取分镜步骤数据 |
| StoryboardApi | `updateStoryboard(workId, storyboardId, payload)` | 保存分镜描述与参数 |
| StoryboardApi | `generateStoryboard(workId, storyboardId)` | 生成单分镜 |
| StoryboardApi | `generateAll(workId)` | 一键生成全部 |
| VideoApi | `getVideo(workId)` | 获取视频预览 |
| VideoApi | `generateVideo(workId)` | 创建视频任务 |
| TaskApi | `getTask(taskId)` | 查询异步任务 |
| TaskApi | `retryTask(taskId)` | 重试失败任务 |

---

## 9. 页面 Controller 职责

| 页面 | Controller 重点 |
| --- | --- |
| `HomeController` | 拉取作品列表、按 `currentStep` 路由、新建作品入口 |
| `StoryInputController` | 文本草稿、同步解析提交、错误展示、保存 `workId` |
| `CharacterGenerateController` | 获取角色、生成/重生成图片、轮询、禁用下一步 |
| `SceneGenerateController` | 获取场景、生成/重生成图片、轮询、禁用下一步 |
| `StoryboardEditController` | 分镜切换、描述保存、参数保存、单个/批量生成 |
| `StoryboardCharacterSelectController` | 当前分镜角色多选，确认后回写 |
| `StoryboardSceneSelectController` | 当前分镜场景单选，确认后回写 |
| `VideoPreviewController` | 视频信息、播放控制、视频生成轮询、分享 |

---

## 10. 错误与边界

| 场景 | 前端处理 |
| --- | --- |
| 同步解析失败 | 停留作品创建页，保留故事文本 |
| 作品不存在 | 返回首页并刷新作品列表 |
| 图片任务运行中进入下一步 | 主按钮禁用，提示等待生成完成 |
| 重复点击生成 | 如果已有运行中任务，继续轮询已有任务 |
| 生成失败 | 保留旧资产或占位，显示重试入口 |
| 网络断开 | 展示缓存数据，禁止提交关键动作 |
| 参数保存失败 | 保留本地草稿，提示稍后重试 |

---

## 11. 验收清单

- [ ] Figma 375 x 812 页面逐一对齐：首页、作品创建、角色、场景、分镜、预览、角色选择、场景选择。
- [ ] 点击「开始解析」同步返回 `workId` 后进入角色页。
- [ ] 未解析成功前，不产生正式作品入口。
- [ ] 角色有图显示图片和「重新生成」，无图显示占位和「生成角色」。
- [ ] 场景有图显示图片和「重新生成」，无图显示占位和「生成场景」。
- [ ] 角色/场景任一相关图片任务生成中时，不能进入下一步。
- [ ] 分镜字段使用 `description`，不实现独立 `title` 输入。
- [ ] 分镜角色选择多选，场景选择单选。
- [ ] 图片、分镜资源、视频生成均通过任务轮询刷新。
- [ ] 生成失败不清空旧资产。
- [ ] App 前后台切换后能恢复未完成任务轮询。

---

## 12. 编码任务

| 编号 | 内容 |
| --- | --- |
| F-001 | 初始化 Flutter 工程依赖、主题、路由、全局服务 |
| F-002 | 建立模型、枚举、统一响应和 API 封装 |
| F-003 | 实现首页作品列表和 `currentStep` 路由 |
| F-004 | 实现作品创建页和同步解析接口 |
| F-005 | 实现角色生成页、图片任务创建、轮询和禁用下一步 |
| F-006 | 实现场景生成页、图片任务创建、轮询和禁用下一步 |
| F-007 | 实现分镜处理页、参数编辑、单分镜/批量生成 |
| F-008 | 实现角色多选页和场景单选页 |
| F-009 | 实现视频预览页、视频任务、播放和分享 |
| F-010 | 完成缓存、草稿、任务恢复和错误处理 |
| F-011 | 按 Figma 完成视觉验收和多机型检查 |
