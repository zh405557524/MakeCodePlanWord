# 执行力 Flutter 总体开发计划文档

> 版本：v3.1  
> 更新时间：2026-05-12  
> 关联技术文档：[`flutter-tech.md`](./flutter-tech.md)  
> 关联设计真源：Figma `执行力设计稿 / 手机版`  
> 参考工程：`G:\code\soul\Solfeggio`  
> 文档状态：`approved`  
> 编码状态：`in_progress`

---

## 1. 文档用途

本文件用于驱动 Flutter 编码执行，负责明确：

- 当前恢复点是什么
- 下一步先做什么
- 阶段之间的依赖如何闭合
- 哪些模块文档是重点同步对象
- 联调和 Figma 对照时看什么

使用方式：

- 每次开始编码前先读本文件，再读对应模块文档
- 模块完成后必须回写状态和执行记录
- 中断后不重新推演方案，直接从恢复点续跑
- 模块实现细节以 `开发计划/` 下文档为准，但若与 [`flutter-tech.md`](./flutter-tech.md) 冲突，先修文档再编码

---

## 2. 当前状态与恢复点

### 2.1 当前文档状态

- 总技术文档：已重写为 Figma 驱动版
- Figma 设计计划：已补齐到仓库
- 总体开发计划：已同步到 Notes 新口径
- 模块开发文档：已更新 Notes 相关模块与联调口径
- Flutter 编码：主壳、计划链路、Notes 链路与辅助页面已落地，当前进入联调与状态补齐

### 2.2 当前恢复点

当前恢复点：`F-018 补齐同步态与异常态`

下一步默认动作：

1. 先补齐 `Notes / Now / Chat / Profile` 的空状态、异常态和缺省提示
2. 验证 `Notes -> NoteFolder -> NoteFile` 闭环是否稳定
3. 验证 `Chat -> PlanEditor -> Plan -> BattleMap -> TrackDetail -> Now` 与 `Profile -> UserProfile -> Profile` 链路
4. 对照 `references/images` 与当前 Figma 做逐页 UI 细修
5. 将联调结果回写到 `10-integration-and-qa.md` 与 `workflow.md`

### 2.3 恢复规则

1. 先看“执行记录”
2. 优先继续 `in_progress` 任务
3. 若没有 `in_progress`，从第一个依赖已满足的 `pending` 任务继续
4. 若有 `blocked`，先解除阻塞再往下推进

---

## 3. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 执行中 |
| `done` | 已完成 |
| `blocked` | 被阻塞 |
| `waiting_review` | 结果待确认 |

规则：

- 同一时刻只允许一个主任务处于 `in_progress`
- 模块文档与总计划必须同步推进
- 如果实现中发现 Figma / PRD / 总技术文档冲突，先明确以 Figma 驱动版总技术文档为准，再统一修订

---

## 4. 总体开发策略

开发顺序按“先底座、再壳层、再主链路、再 Notes、再联调”推进：

1. 运行底座
   - `main.dart`
   - `Global.init()`
   - `GetStorage`
   - `Hive`
   - `RouteName + router`
   - `theme.dart`
   - `CustomScaffold`
2. 应用骨架
   - `SplashScreen`
   - `MainShell`
   - 底部导航
   - 一级页占位承接
3. 计划主链路
   - `Plan`
   - `BattleMap`
   - `TrackDetail`
   - `PlanEditor`
4. 笔记链路
   - `Notes`
   - `NoteFolder`
   - `NoteFile`
5. 当前执行链路
   - `Now`
6. 辅助链路
   - `Chat`
   - `Profile`
   - `UserProfile`
7. 联调与 Figma 对照
   - 同步态 / 异常态
   - 主链路联调
   - 逐页视觉修正

硬依赖：

- 未完成 `Global.init + Storage + Hive`，不进入业务页面编码
- 未完成 `MainShell + RouteName`，不进入主导航联调
- 未完成 `Notes` 路由与本地存储，不进入 `NoteFolder / NoteFile`
- 未完成 `PlanEditor + task_instances` 重建，不进入 `Now`
- 未完成 `PlanEditor`，不闭合 `Chat -> 草稿 -> 编辑器` 链路
- 未完成 `UserProfile`，不闭合 `Profile -> 资料编辑 -> 回写` 链路

---

## 5. 总体阶段划分

| 阶段 | 名称 | 目标 | 状态 |
|------|------|------|------|
| A | 运行底座 | 工程可启动，全局初始化、存储、路由和主题就位 | `done` |
| B | 应用骨架 | Splash、MainShell、底部导航和一级页容器完成 | `done` |
| C | 计划主链路 | Plan、BattleMap、TrackDetail、PlanEditor 完成 | `done` |
| D | 笔记链路 | Notes、NoteFolder、NoteFile 完成 | `done` |
| E | 当前执行链路 | Now 页面与推荐/反馈逻辑完成 | `done` |
| F | 辅助链路 | Chat、Profile、UserProfile 完成 | `done` |
| G | 联调与走查 | 同步态、异常态、Figma 对照修正完成 | `in_progress` |

---

## 6. 详细任务清单

| ID | 阶段 | 任务 | 依赖 | 主要输出 | 状态 |
|----|------|------|------|---------|------|
| F-001 | A | 创建工程骨架与目录 | 无 | `apis / models / pages / routes / services / store / widgets / utils / global.dart / theme.dart` | `done` |
| F-002 | A | 建立 `main.dart` 与 `Global.init()` | F-001 | 启动入口、依赖注入、初始化链路 | `done` |
| F-003 | A | 接入 `GetStorage` 与 `StorageService` | F-002 | 安装实例、轻量设置、启动标记 | `done` |
| F-004 | A | 接入 `Hive` 与核心 box | F-002 | 计划、任务实例、消息、草稿、资料、同步记录 | `done` |
| F-005 | A | 建立 `RouteName + router + observers` | F-001 | 路由常量、主路由表、观察器 | `done` |
| F-006 | A | 建立通用 UI 基础设施 | F-001 | `CustomScaffold / Theme / Button / Dialog / Toast` | `done` |
| F-007 | B | 实现 Splash 页面 | F-002、F-005、F-006 | 品牌启动页、自动跳转 | `done` |
| F-008 | B | 实现 MainShell 与底部导航 | F-005、F-006 | `IndexedStack` 主壳、Tab 入口、隐藏导航规则 | `done` |
| F-009 | C | 实现 Plan 页面 | F-004、F-008 | BattleMap Hero、计划卡片列表、新建入口 | `done` |
| F-010 | C | 实现 BattleMap 页面 | F-009 | 年度 Banner、五条主线卡片、状态和节奏 | `done` |
| F-011 | C | 实现 TrackDetail 页面 | F-010 | Hero、时间线、执行数据、AI 建议、去 Now CTA | `done` |
| F-012 | C | 实现 PlanEditor 页面 | F-004、F-009 | 新建/编辑/草稿预填充/本地保存/重建 `task_instances` | `done` |
| F-012A | D | 实现 Notes 数据模型与本地服务 | F-004、F-005 | `NoteFolder / NoteFile` 模型、Hive box、NotesService / Store | `done` |
| F-012B | D | 实现 Notes 与 NoteFolder 页面 | F-008、F-012A | 根目录、子文件夹、创建入口、导航高亮 | `done` |
| F-012C | D | 实现 NoteFile 页面 | F-012A、F-012B | 编辑 / 预览、路径、正文保存与回写 | `done` |
| F-013 | E | 实现 Now 业务服务 | F-004、F-012 | 推荐、候选切换、反馈写回、同步编排 | `done` |
| F-014 | E | 实现 Now 页面 | F-008、F-013 | 顶部状态、建议卡、推荐任务、专注交互 | `done` |
| F-015 | F | 实现 Chat 页面 | F-004、F-008、F-012 | 消息流、草稿卡、应用到编辑器 | `done` |
| F-016 | F | 实现 Profile 页面 | F-004、F-008 | Hero、能量/模式/AI 模型、资料入口 | `done` |
| F-017 | F | 实现 UserProfile 页面 | F-016 | 头像/昵称/标签/数据卡/固定保存栏 | `done` |
| F-018 | G | 补齐同步态与异常态 | F-014、F-015、F-017、F-012C | `pending_sync / sync_failed / empty / loading / error` | `in_progress` |
| F-019 | G | 主链路联调 | F-012C、F-014、F-015、F-017 | `Chat -> PlanEditor -> Plan -> BattleMap -> TrackDetail -> Now`、`Notes -> NoteFolder -> NoteFile`、`Profile -> UserProfile -> Profile` | `pending` |
| F-020 | G | Figma 对照与 UI 修正 | F-019 | 对照 `references/images` 和 Figma 逐页细修 | `pending` |

---

## 7. 模块开发文档列表

### 7.1 重点重写同步

- [`03-plan.md`](./开发计划/03-plan.md)
- [`05-track-detail.md`](./开发计划/05-track-detail.md)
- [`09-profile.md`](./开发计划/09-profile.md)

### 7.2 轻量同步

- [`01-app-foundation.md`](./开发计划/01-app-foundation.md)
- [`02-splash-shell.md`](./开发计划/02-splash-shell.md)
- [`04-battle-map.md`](./开发计划/04-battle-map.md)
- [`06-plan-editor.md`](./开发计划/06-plan-editor.md)
- [`07-now.md`](./开发计划/07-now.md)
- [`08-chat.md`](./开发计划/08-chat.md)
- [`10-integration-and-qa.md`](./开发计划/10-integration-and-qa.md)

### 7.3 新增模块

- [`11-notes.md`](./开发计划/11-notes.md)

---

## 8. 编码约束

编码时必须同时遵守：

- [`flutter-tech.md`](./flutter-tech.md)
- `.cursor/rules/flutter/01-项目初始化规则.mdc`
- `.cursor/rules/flutter/02-项目结构目录.mdc`
- `.cursor/rules/flutter/03-编码规范.mdc`
- `.cursor/rules/flutter/04-导航规则.mdc`
- `.cursor/rules/flutter/06-第三方依赖参考.mdc`
- `.cursor/rules/flutter/07-新功能开发.mdc`
- `.cursor/rules/flutter/08-UI处理任务.mdc`
- `.cursor/rules/flutter/09-大功能先规划再编码.mdc`
- `.cursor/rules/flutter/10-编码工作流程.mdc`

强约束：

- 使用 `GetX`
- 使用 `GetStorage + Hive`
- 不引入 `Riverpod + Drift`
- 不使用 `Get.context`
- 页面目录与导出方式对齐 `Solfeggio`
- 没有可直接读取的 Figma 上下文时，必须优先读取 `figma-design-plan.md`，再对照 `references/images`

---

## 9. 审核关注点

- 任务顺序是否符合真实工程依赖
- 页面边界是否与 Figma frame 对应
- `TrackDetail`、`PlanEditor` 是否按单页多视觉态实现
- `Profile` 与 `UserProfile` 是否职责分离
- `Notes / NoteFolder / NoteFile` 是否形成独立闭环且不误入 Plan 链路
- 联调链路是否能从 Chat 和 Profile 两端闭合

---

## 10. 执行记录

| 日期 | 操作 | 结果 | 当前恢复点 | 备注 |
|------|------|------|-----------|------|
| 2026-04-03 | 生成 Flutter 总体开发计划文档 | 完成 | `F-001` | 初版文档 |
| 2026-04-03 | 生成 Flutter 模块开发文档 | 完成 | `F-001` | 已生成 `开发计划/` 下模块文档 |
| 2026-04-04 | 对齐 `Solfeggio` 重写 Flutter 文档体系 | 完成 | `F-001` | 切换至 `GetX + GetStorage + Hive + Global.init()` |
| 2026-04-20 | 按 Figma 设计稿联动重构总文档、开发计划与模块文档 | 完成 | `F-001` | 统一到 Figma 驱动版口径 |
| 2026-05-12 | 同步 Notes 版本文档体系 | 完成 | `F-001` | 新增 Notes 任务、模块文档与联调链路 |
| 2026-05-12 | 回写 DoFlow 当前实现进度 | 完成 | `F-018` | 已完成 A-F 阶段落地，Notes 三页、主壳、计划链路、Now、Chat、Profile 已进入联调与状态补齐阶段 |

---

*本文件是 Flutter 编码阶段的总控文档。后续每次开始或继续编码时，先更新本文件，再进入具体页面实现。*
