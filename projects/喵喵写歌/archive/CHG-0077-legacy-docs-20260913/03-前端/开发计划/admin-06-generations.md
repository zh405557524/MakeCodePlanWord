# Admin 生成任务模块开发文档

> 关联任务：T-A006  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

后台查看歌曲生成任务、状态、失败原因和 Provider trace。

- 包含：列表、筛选、详情、失败原因、任务状态。
- 不包含：后台手动重试和补偿任务，后续可扩展。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_generations_page.dart` |
| Model | `song_generation_task.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- T-A001 selectedAppCode。
- 后端 T-B010：`GET /api/admin/song/generations`、`GET /api/admin/song/generations/{id}`。

## 4. 视觉参考与设计稿分析

App 侧生成中参考 `05-generating.jpeg`、`06-library-loading.jpeg`。后台以表格为主，重点展示状态和失败原因。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongGenerationsPage` | 任务列表 |
| `SongGenerationDetailDrawer` | 任务详情 |

## 6. 业务内容与数据流

1. 查询当前 App 下任务。
2. 按状态、用户、模型筛选。
3. 查看 Provider trace、失败原因、积分状态。

## 7. 现有工程参考点

复用后台表格筛选和详情抽屉。

## 8. 建议实现步骤

1. 定义任务模型。
2. 实现列表和筛选。
3. 实现详情抽屉。
4. 接入状态颜色和失败原因。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A006-01 任务模型 | pending |
| T-A006-02 列表筛选 | pending |
| T-A006-03 详情抽屉 | pending |
| T-A006-04 状态和失败展示 | pending |

## 10. 验收标准

- [ ] 可查看任务列表。
- [ ] 可按状态筛选。
- [ ] 失败原因和 providerTraceId 可见。
- [ ] 切换 App 后数据隔离。

## 11. 编码注意事项

- 不展示密钥和完整敏感请求。
- trace 只用于排障。
