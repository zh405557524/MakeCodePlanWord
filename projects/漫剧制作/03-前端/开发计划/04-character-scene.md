# 04 - 角色与场景开发计划

> 覆盖任务：F-014 ~ F-018  
> 状态：`pending`  
> 依赖：F-013  
> Figma：`AI漫剧 / 03-角色生成`、`AI漫剧 / 04-场景生成`

## 目标

实现角色和场景步骤。页面状态不依赖「已生成」字段：有 `imageUrl` 显示图片，无 `imageUrl` 显示占位，存在 `runningTaskId` 或运行中任务时禁用下一步。

## 任务拆分

| ID | 任务 | 输出 | 接口 |
| --- | --- | --- | --- |
| F-014 | 角色生成页 | 角色列表、有图/无图/生成中/失败状态 | `GET /api/v1/works/{workId}/characters` |
| F-015 | 角色图片任务 | 生成角色、重新生成、轮询刷新 | `POST /characters/{characterId}/image-task`、`GET /tasks/{taskId}` |
| F-016 | 角色确认推进 | 生成中禁用确认，保存选择进入场景 | `PUT /characters/selection` |
| F-017 | 场景生成页 | 场景列表、有图/无图/生成中/失败状态 | `GET /api/v1/works/{workId}/scenes` |
| F-018 | 场景图片任务与确认 | 生成场景、重新生成、轮询、进入分镜 | `POST /scenes/{sceneId}/image-task`、`PUT /scenes/selection` |

## 角色卡片规则

| 数据 | UI | 操作 |
| --- | --- | --- |
| `imageUrl != null` | 显示角色图片 | 重新生成 |
| `imageUrl == null` 且无运行任务 | 显示占位 | 生成角色 |
| `runningTaskId != null` | 显示生成中 | 禁止进入下一步 |
| 任务失败 | 保留旧图或占位 | 重试 |

## 场景卡片规则

| 数据 | UI | 操作 |
| --- | --- | --- |
| `imageUrl != null` | 显示场景图片 | 重新生成 |
| `imageUrl == null` 且无运行任务 | 显示占位 | 生成场景 |
| `runningTaskId != null` | 显示生成中 | 禁止进入下一步 |
| 任务失败 | 保留旧图或占位 | 重试 |

## 下一步限制

- 角色页：`hasRunningImageTask=true` 时主按钮禁用。
- 场景页：`hasRunningImageTask=true` 时主按钮禁用。
- 禁用按钮文案按 Figma 最新稿表达“生成中，请稍候”。
- 生成失败不能清空旧图片。

## 验收

- 页面不显示「已生成」标签。
- 有图/无图/生成中三种状态清晰。
- 生成中无法进入下一步，后端也会返回状态冲突兜底。
- 角色页确认后进入场景页；场景页确认后进入分镜页。

