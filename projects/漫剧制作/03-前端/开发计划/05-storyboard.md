# 05 - 分镜处理开发计划

> 覆盖任务：F-019 ~ F-023  
> 状态：`pending`  
> 依赖：F-018  
> Figma：`AI漫剧 / 05-分镜处理`、`AI漫剧 / 08-角色选择（多选）`、`AI漫剧 / 09-场景选择（单选）`

## 目标

实现分镜处理主页面、角色多选页、场景单选页、分镜参数编辑和分镜资源生成。分镜页允许纵向加高，不压缩进 812 高度。

## 任务拆分

| ID | 任务 | 输出 | 接口 / 存储 |
| --- | --- | --- | --- |
| F-019 | 分镜处理基础布局 | 分镜列表、预览图、描述区、参数区 | `GET /works/{workId}/storyboards` |
| F-020 | 分镜描述保存 | `description` 编辑、debounce、切换保存 | `PUT /storyboards/{storyboardId}`、`storyboard_drafts` |
| F-021 | 角色多选页 | 当前分镜选择多个角色 | `PUT /storyboards/{storyboardId}` |
| F-022 | 场景单选页 | 当前分镜选择一个场景 | `PUT /storyboards/{storyboardId}` |
| F-023 | 参数与资源生成 | 风格、配音、音效、单个/批量生成 | `POST /storyboards/{id}/generate`、`POST /storyboards/generate-all` |

## 分镜字段

| 字段 | 规则 |
| --- | --- |
| `description` | 分镜描述，替代“分镜标题” |
| `characterIds` | 多选，可为空 |
| `sceneId` | 单选，可为空 |
| `style` | 画面风格 |
| `voicePreset` | 角色配音 |
| `bgmPreset` | 背景音效 |

## 页面行为

- 切换分镜前先保存当前分镜草稿。
- 描述输入 debounce 保存到 Hive。
- 失焦、切换分镜、点击生成前调用后端保存。
- 角色选择跳转独立多选页。
- 场景选择跳转独立单选页。
- 画面风格、角色配音、背景音效按 Figma 参数区实现。
- 「生成此分镜」创建单分镜异步任务。
- 「一键生成全部」创建批量异步任务。

## 任务轮询

- `queued/running` 显示生成中和进度。
- `succeeded` 刷新分镜列表和当前分镜资产。
- `failed` 保留旧资产，显示重试。
- 同一分镜运行中时不能重复创建同类任务。

## 验收

- 不实现 `title` 字段输入。
- 角色选择多选，场景选择单选。
- 分镜描述、角色、场景、风格、配音、音效都能保存。
- 分镜资源生成失败不清空旧图。
- 页面按 Figma 长页面布局验收。

