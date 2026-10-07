# 06-chord-practice Flutter 模块开发文档

## 2026-10-04 琴键与进度修复

- FULL-001：C 音范围标签包 IgnorePointer；实际中心和标签区域都可输入 C4，黑键保持优先，连续 C4/E4/G4 判对再推进。不移动点击坐标绕过遮挡。
- FULL-002：顶栏按父约束给进度更大空间，紧凑横屏、英文或大字体采用操作行与全宽进度行；末题 20/20 也覆盖。反馈标题可换行，图例测量使用当前 textScaler、允许增高，大字体反馈区独立滚动并保留琴键。保留 chord_practice_* 原图标/背景和真实题号/总数，三语与 1×/2×检查无截断。
- 全量和弦历史测试通过真实 startSession 建立 owner 后检验失败落盘、重试不重复和原完成日期；不放宽会话归属保护。
- 入口 chord_practice_visual_qa_test、practice_history_service_test；结果与原始失败对照见 `../../05-联调与测试/full-regression-fix-2026-10-04.md`。

> 关联任务：T-F005
> 状态：`done`
> 生成日期：2026-06-20
> 关联后端模块：`04-后端/开发计划/05-chord-practice.md`

---

## 1. 功能定位与边界

本模块负责和弦练习首版钢琴模式。用户通过 MIDI / 真实钢琴输入目标音组，系统判断多按、漏按、错按并同步答题记录。

不支持手机虚拟键盘和弦练习。

---

## 2. 入口、路由与页面文件

| 页面 | 路由 | 文件 |
|------|------|------|
| 和弦练习页：钢琴模式 | `/chord_practice` | `lib/pages/chord_practice/` |

---

## 3. 依赖前置

| 依赖 | 说明 |
|------|------|
| T-F001 | 路由、API、模型 |
| T-B006 | chord-practice session 与 answers 接口 |

---

## 4. 视觉参考与设计稿分析

参考图片：

- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/32-和弦练习页-钢琴模式.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/05-图标与背景图生成计划/assets/32-和弦练习页-钢琴模式/`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/effect-practice-landscape-reference.png`

当前图中表现：横屏练习界面强调目标和弦、谱面 / 音组、输入状态、统计区和控制按钮。当前 PRD 目标版本要求只做钢琴模式，不提供手机虚拟键盘和弦输入。

---

## 5. 涉及模块与类

| 类型 | 建议文件 |
|------|----------|
| API | `ChordPracticeApi.createSession()`、`submitAnswer()` |
| Service | `ChordPracticeService` |
| Model | `ChordPracticeSession`、`ChordQuestion`、`ChordAnswer` |
| Widgets | `ChordStaffView`、`ChordInputStatusPanel`、`ChordStatsPanel` |
| Controller | `ChordPracticeController` |

---

## 6. 业务内容与数据流

1. 进入页面调用 `POST /api/v1/chord-practice/sessions`。
2. Controller 获取目标音组，监听 MIDI / 拾音输入。
3. 用户输入稳定后比对目标音组。
4. 判定结果包含 correct、missingNotes、extraNotes、wrongNotes、durationMs。
5. 调用 `POST /api/v1/chord-practice/sessions/{sessionId}/answers`。
6. 页面更新统计和下一题。

---

## 7. 现有工程参考点

- 现有 `PracticePage` 的 MIDI / 拾音输入和横屏布局可复用。
- 现有练习统计组件可作为结果统计参考。

---

## 8. 建议实现步骤

1. 新增和弦练习模型和 API。
2. 建立横屏页面骨架。
3. 接入目标音组渲染。
4. 复用 MIDI / 拾音输入，完成音组判定。
5. 接答题同步接口。
6. 补异常态：未连接 MIDI、麦克风权限缺失、提交失败。

---

## 9. 详细编码任务清单

| 子任务 | 说明 | 状态 |
|--------|------|------|
| T-F005-01 | ChordPractice 模型与 API | done |
| T-F005-02 | 横屏和弦练习 UI | done |
| T-F005-03 | 音组输入与判定 | done |
| T-F005-04 | 答题提交与统计 | done |
| T-F005-05 | 权限 / 设备 / 离线异常态 | done_with_backend_dependency |

---

## 10. 验收标准

- 只显示钢琴模式，不出现手机模式入口。
- 多按、漏按、错按都有明确反馈。
- 答题记录可提交，失败可重试。
- 横屏 `812 x 375` 无重叠和溢出。

---

## 11. 编码注意事项

- 判定逻辑放 Service，不写在 View。
- 音组比较要忽略输入顺序。
- 后端未就绪时可本地闭环，但接口路径不得变更。

---

## 12. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-06-20 | 扩展 ChordPractice 模型：session、question、answer、missing / extra / wrong notes | `done` |
| 2026-06-20 | 完成 `ChordPracticeService`：session 创建、本地题目降级、音组集合判定、答题提交和失败入待同步队列 | `done` |
| 2026-06-20 | 完成横屏和弦练习 UI：目标和弦、五线谱背景、输入音组、统计、反馈和完成态 | `done` |
| 2026-06-20 | 接入 MIDI note on/off 回调，页面退出时恢复旧回调；无 MIDI 时保留本地判定入口，不显示手机虚拟键盘 | `done_with_device_dependency` |
| 2026-06-20 | 后端 T-B006 未联调前使用本地和弦题闭环，答题记录进入待同步队列；接口路径保持 `/api/v1/chord-practice/*` | `done_with_backend_dependency` |
| 2026-06-20 | `dart format`、`git diff --check`、`flutter analyze --no-fatal-infos --no-fatal-warnings`、`flutter test` | `passed_with_existing_warnings` |
