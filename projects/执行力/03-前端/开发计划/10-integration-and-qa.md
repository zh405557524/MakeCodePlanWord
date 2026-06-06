# 执行力 Flutter 模块开发文档 - Integration and QA

> 模块编号：`M-10`
> 对应总体任务：`F-018 ~ F-023`、`F-028 ~ F-030`
> 状态：`pending`
> 当前恢复点：`F-028 v2 主链路联调`

---

## 一、模块定位

本模块负责 Flutter 阶段的收尾与闭环工作。v2 重构后，本模块从旧 `F-018` 状态补齐切到 v2 主链路联调：

- v2 主链路联调
- 空状态、异常态、同步态补齐
- Figma `V2-Chat-First` 对照收口
- 测试人员执行的测试用例整理
- Python 冒烟辅助脚本与验收资料准备

---

## 二、当前依赖前置

以下模块已经完成基本落地：

- `M-01 App Foundation`
- `M-02 Splash / Main Shell`
- `M-03 Plan`
- `M-04 BattleMap`
- `M-05 TrackDetail`
- `M-06 PlanEditor`
- `M-07 Now`
- `M-08 Chat`
- `M-09 Profile / UserProfile`
- `M-11 Notes`

v2 新增依赖：

- `M-12 ChatHome`
- `M-13 TodayFocus`

因此本模块不先执行旧 `F-018`，而是在 `ChatHome / TodayFocus` 主链路落地后做增量收口。

---

## 三、当前任务拆分

### 3.1 F-028 v2 主链路联调

必须点通以下链路：

- `ChatHome -> 开启今天计划 -> TodayFocus -> 完成 / 稍后 -> ChatHome`
- `ChatHome -> + -> ToolMenu -> PlanCreate`
- `ChatHome -> + -> ToolMenu -> NotesEntry`
- `ChatHome -> SideMenu -> 计划库 / 笔记 / 设置`

### 3.2 F-029 v2 Figma 对照与 UI 修正

重点对照：

- `V2-01-ChatHome-Entry`
- `V2-02-ChatHome-Active`
- `V2-03-TodayFocus`
- `V2-04-ToolMenu`
- `V2-05-SideMenu`
- `V2-06-PlanCreate`
- `V2-07-NotesEntry`

最低视觉要求：

- 375x812 首屏无重叠、无溢出。
- 首页像对话 App，不像仪表盘。
- `TodayFocus` 只突出一件任务。
- 不出现底部 Tab。

### 3.3 F-030 v2 测试人员测试用例

需要新增：

- `projects/执行力/05-联调与测试/cases/chat-home.md`
- `projects/执行力/05-联调与测试/cases/today-focus.md`

### 3.4 旧 F-018 状态补齐迁移

当前重点页面：

- `ChatHome`
- `TodayFocus`
- `Profile / UserProfile`
- `Notes / NoteFolder / NoteFile`

最少补齐：

- `loading`
- `empty`
- `error`
- `disabled`
- `pending_sync`
- `sync_failed`
- `not_found`

### 3.5 旧 F-019 主链路联调

必须点通以下链路：

- `ChatHome -> PlanCreate -> Plan -> BattleMap -> TrackDetail -> TodayFocus`
- `Notes -> NoteFolder -> NoteFile`
- `Profile -> UserProfile -> Profile`

### 3.6 旧 F-021 测试人员测试用例

需要产出：

- `projects/执行力/05-联调与测试/qa-plan.md`
- `projects/执行力/05-联调与测试/cases/notes.md`
- `projects/执行力/05-联调与测试/cases/plan.md`
- `projects/执行力/05-联调与测试/cases/profile.md`

### 3.7 F-022 Python 冒烟辅助脚本

只用于：

- 模拟点击、输入、切换、截图
- 复现核心冒烟路径

不用于：

- 替代测试用例文档
- 替代完整人工验收

### 3.8 F-023 联调与验收资料

需要整理：

- 截图点
- 用例执行记录
- 遗留风险清单

---

## 四、本轮改造边界

本模块只做增量修正：

1. 修链路
2. 修状态
3. 修对稿差异
4. 补测试资料

本模块不做：

- 借联调阶段大改工程底座
- 借对稿阶段重做已稳定模块的整体结构

---

## 五、验收标准

- 主链路可点通
- v2 `ChatHome -> TodayFocus -> ChatHome` 可点通
- Notes 链路可点通
- Profile 回写链路可点通
- 关键页面具备空状态、异常态和同步态
- 关键页面与 Figma 的结构层级基本一致
- v2 首屏不显示底部 Tab
- 测试人员可按测试用例文档执行

---

## 六、视觉参考

逐页对照以下 Figma frame：

- `01-SplashScreen`
- `02-Now`
- `03-Chat`
- `04-Plan`
- `05-BattleMap`
- `06-TrackDetail-换工作`
- `07-TrackDetail-恋爱`
- `08-PlanEditor-恋爱`
- `09-PlanEditor-默认`
- `10-Profile`
- `11-UserProfile`
- `12-Notes`
- `13-NoteFolder`
- `14-NoteFile`
- `V2-01-ChatHome-Entry`
- `V2-02-ChatHome-Active`
- `V2-03-TodayFocus`
- `V2-04-ToolMenu`
- `V2-05-SideMenu`
- `V2-06-PlanCreate`
- `V2-07-NotesEntry`
