# Admin 模型价格配置模块开发文档

> 关联任务：T-A003  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

配置歌曲生成模型、provider、价格、默认模型和上下架状态。

- 包含：列表、新增/编辑、默认模型、上下架、价格积分。
- 不包含：真实 MiniMax 密钥配置。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_models_page.dart` |
| Model | `song_model_config.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- T-A001 selectedAppCode。
- 后端 T-B010：`/api/admin/song/models`。

## 4. 视觉参考与设计稿分析

后台无截图，沿用表格 + 抽屉/弹窗表单。价格字段明确显示“积分/首”。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongModelsPage` | 模型配置列表 |
| `SongModelForm` | 新增/编辑模型 |
| `AdminSongRepository` | 模型 API |

## 6. 业务内容与数据流

1. 根据 selectedAppCode 拉模型。
2. 新增或编辑 provider/model/价格。
3. 设置默认模型。
4. 上下架后 App 模型列表即时变化。

## 7. 现有工程参考点

复用后台表格、分页、表单校验和操作列样式。

## 8. 建议实现步骤

1. 新增模型配置 model。
2. 新增列表页面。
3. 新增编辑表单。
4. 接入上下架和默认状态。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A003-01 模型配置模型 | pending |
| T-A003-02 列表查询 | pending |
| T-A003-03 新增编辑表单 | pending |
| T-A003-04 默认/上下架 | pending |

## 10. 验收标准

- [ ] 可配置 MiniMax `music-2.6`。
- [ ] 默认价格可配置为 100 积分/首。
- [ ] 禁用模型后 App 不展示。
- [ ] 切换 App 后数据隔离。

## 11. 编码注意事项

- 前端不写死 100，只作为表单默认值或后端返回。
- provider/model 唯一约束错误要友好提示。
