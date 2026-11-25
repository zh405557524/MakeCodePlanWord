# 09 Scenario Flow 场景写歌流程返工文档

> 关联任务：CHG-0011 / T-F008  
> 当前状态：done  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> UI 真源：`01-需求/references/images/v1.0/首页/情景写歌1.png`、`情景写歌2.png`、`情景写歌3.png`、`情景写歌.png`、`情景写歌4.png`、`情景写歌5.png`

## 1. 返工背景

当前 `song_scenario` 仍是旧流程：

- 点击选项后自动跳下一题。
- 完成后停在“情景已整理 / 复制并返回写歌页”中间页。
- 没有按设计稿展示累计选择标签。
- 写歌页提交没有带 `sceneCode` 和 `sceneAnswers`。
- 漏了第 3 步「想表达什么？」。

本轮只修正场景写歌流程，不改 Java 后端接口。

## 2. 目标流程

场景写歌固定为 4 步：

| 步骤 | 问题 | 选项 |
|------|------|------|
| 1 | 这首歌送给谁？ | 恋人、朋友、父母、孩子、自己 |
| 2 | 什么场景？ | 表白、求婚、订婚、结婚、纪念日、复合、生日、毕业 |
| 3 | 想表达什么？ | 爱意、感谢、思念、遗憾、祝福、陪伴 |
| 4 | 喜欢什么风格？ | 流行、民谣、摇滚、国风、钢琴、电子 |

接口仍优先读取 `/api/song-config/scenarios`；若接口缺失、无场景或问题不足 4 步，前端使用以上默认配置兜底。

## 3. 页面结构

- 顶部返回按钮 + 标题「场景写歌」。
- 4 段进度条，已完成和当前步骤高亮。
- 步骤提示：`第 N 步，共 4 步`。
- 当前问题标题。
- 两列选项卡片。
- 选项区下方展示已选答案小标签。
- 底部固定按钮。

## 4. 交互规则

- 点选选项只改变选中态，不自动跳题。
- 当前步骤未选择时，底部按钮置灰且不可提交。
- 第 1-3 步按钮文案为「下一步」。
- 第 4 步按钮文案为「开始创作 ✨」。
- 返回按钮：第 1 步退出页面，第 2-4 步回上一题。
- 完成第 4 步后，拼装音乐描述并返回首页，由首页切到写歌 Tab。

## 5. 数据流

- `SongScenarioPage` 结束时返回 `SongScenarioCreateIntent`。
- `SongHomePage` 接收结果后调用 `onScenarioCreate`。
- `MainController.showCreateFromScenario` 切到写歌 Tab。
- `SongCreateController.applyScenarioFromHome` 回填音乐描述并保存 `sceneCode`、`sceneAnswers`。
- `SongCreateController.submit` 若存在场景上下文，则提交：
  - `mode=scenario`
  - `sceneCode`
  - `sceneAnswers`

## 6. 影响文件

| 文件 | 调整 |
|------|------|
| `lib/models/data/song.dart` | 新增场景结果传递模型 |
| `lib/pages/song_home/view.dart` | 接收场景页返回结果并回填写歌 Tab |
| `lib/pages/main/controller.dart` | 新增场景回填入口 |
| `lib/pages/main/view.dart` | 将场景回填入口传给首页 |
| `lib/pages/song_create/controller.dart` | 保存场景上下文并提交给后端 |
| `lib/pages/song_scenario/controller.dart` | 固定 4 步、选中态、返回、完成 |
| `lib/pages/song_scenario/view.dart` | 按设计稿重写 UI |

## 7. 验收标准

- [x] 第 1 步展示「这首歌送给谁？」。
- [x] 第 2 步展示「什么场景？」。
- [x] 第 3 步展示「想表达什么？」。
- [x] 第 4 步展示「喜欢什么风格？」。
- [x] 点选选项不自动跳题。
- [x] 未选择时按钮置灰；选择后按钮高亮。
- [x] 已选答案累计显示为绿色小标签。
- [x] 第 4 步完成后切到写歌 Tab 并回填音乐描述。
- [x] 生成请求包含 `mode=scenario`、`sceneCode`、`sceneAnswers`。
- [x] `flutter analyze` 和 `flutter test` 通过。

## 8. 验证记录

| 时间 | 命令 | 结果 |
|------|------|------|
| 2026-06-12 | `flutter analyze` | 通过 |
| 2026-06-12 | `flutter test` | 50 项通过 |
