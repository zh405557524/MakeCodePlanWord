# 01 - 工程底座开发计划

> 覆盖任务：F-001 ~ F-006  
> 状态：`pending`  
> 依赖：无  
> 关联：[../flutter-dev-plan.md](../flutter-dev-plan.md)、[../flutter-tech.md](../flutter-tech.md)

## 目标

建立 Flutter 工程的基础可运行骨架，为后续页面、接口、缓存、任务轮询提供统一底座。

## 任务拆分

| ID | 任务 | 输出 | 验收 |
| --- | --- | --- | --- |
| F-001 | 创建工程目录 | `apis/models/pages/routes/services/store/widgets` | 目录与技术文档一致 |
| F-002 | 建立启动入口 | `main.dart`、`global.dart` | App 可启动，`Global.init()` 可注册服务 |
| F-003 | 建立网络基础 | `HttpService`、统一响应、错误解析 | 请求头包含 `X-Installation-Id`、`X-App-Version`、`X-Timezone` |
| F-004 | 建立路由基础 | `RouteName`、`go_router` | 支持 `workId` 参数和 `currentStep` 路由 |
| F-005 | 建立模型枚举 | Work、Character、Scene、Storyboard、Task | 字段与后端文档一致 |
| F-006 | 建立存储服务 | GetStorage、Hive Box | 支持草稿、步骤缓存、任务恢复 |

## 模型范围

必须先建立以下模型：

- `WorkModel`：`id / name / status / currentStep / coverUrl / durationSeconds / updatedAt`
- `CharacterModel`：`id / name / roleTag / description / imageUrl / runningTaskId / selected`
- `SceneModel`：`id / name / description / tags / imageUrl / runningTaskId / selected`
- `StoryboardModel`：`id / sortOrder / description / characterIds / sceneId / style / voicePreset / bgmPreset / imageUrl / status / runningTaskId`
- `GenerationTaskModel`：`taskId / workId / taskType / targetType / targetId / status / progress / errorMessage / pollingIntervalMs`

## 存储范围

| 存储 | 用途 |
| --- | --- |
| `installation_id` | 设备级身份 |
| `last_work_id` | 最近编辑作品 |
| `works_cache` | 首页作品缓存 |
| `story_drafts` | 未解析前的文本草稿 |
| `step_cache` | `workId + step` 的页面数据缓存 |
| `storyboard_drafts` | 分镜描述和参数草稿 |
| `generation_tasks` | 未完成任务恢复 |

## 注意事项

- 不实现业务页面 UI。
- 不引入 `Provider / Riverpod / Drift`。
- 不使用 `Get.context!`。
- 后续所有 API 路径必须以 [../../04-后端/kotlin-tech.md](../../04-后端/kotlin-tech.md) 为准。

