# Admin 情景模板模块开发文档

> 关联任务：T-A004  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

配置情景写歌场景、问题和标签答案。

- 包含：场景列表、问题列表、标签答案、排序、启用/停用。
- 不包含：复杂分支问答和 AI 自动追问。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| 页面 | `lib/pages/song_admin/song_scenarios_page.dart` |
| Model | `song_scenario.dart`, `song_scenario_question.dart` |
| Repository | `AdminSongRepository` |

## 3. 依赖前置

- T-A001 selectedAppCode。
- 后端 T-B010：`/api/admin/song/scenarios`。

## 4. 视觉参考与设计稿分析

App 侧参考 `08-scenario.jpeg`。后台建议左侧场景、右侧问题配置，或场景详情页里维护问题。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `SongScenariosPage` | 场景列表和状态 |
| `ScenarioQuestionEditor` | 问题和标签编辑 |
| `AdminSongRepository` | 情景 API |

## 6. 业务内容与数据流

1. 运营创建场景，如告白、求婚、纪念日。
2. 为场景配置问题和标签。
3. App 拉取启用场景并展示。

## 7. 现有工程参考点

复用后台嵌套表单或详情页编辑模式。

## 8. 建议实现步骤

1. 定义场景和问题模型。
2. 实现场景列表。
3. 实现问题和标签编辑。
4. 接入排序和启用。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A004-01 场景模型 | pending |
| T-A004-02 场景列表 | pending |
| T-A004-03 问题编辑 | pending |
| T-A004-04 标签答案编辑 | pending |
| T-A004-05 排序和启用 | pending |

## 10. 验收标准

- [ ] 可配置场景和多个问题。
- [ ] 每个问题可配置标签答案。
- [ ] 禁用场景 App 不展示。
- [ ] 排序生效。

## 11. 编码注意事项

- 标签建议以数组 JSON 维护，避免逗号字符串解析问题。
- 删除问题需有确认。
