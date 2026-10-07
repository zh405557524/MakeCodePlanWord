# 02-home-progress-profile Flutter 模块开发文档

## 2026-10-04 修复增量

- FULL-010：首页与我的显示当前账号已通过挑战等级，未通过 Lv0；共同通过 AchievementGoalService 读取，升级/同步/账号切换自动刷新，离线不丢等级。SongAccessPolicy 的内容访问最低 Lv1 规则保持，推荐使用独立 contentLevel。
- FULL-011：底栏三项 Expanded；空周统计由固定高度改最小高度，允许正文增高；首页入口按实际文字高度分配，会员横排不足时竖排。原图标/背景及 ScreenUtil 基准不改。
- 回归：account_level_consistency_test 覆盖初始化、升级、同步、账号/游客隔离、旧值迁移与重建；home_history_page_test 覆盖三语、1×/2×、隐藏主页面、568×320/932×430/320×568/1024×768/375×812 转场及返回后的 Tab 点击。
- 专用 iOS QA 真路由补充首页→横屏练习→取消/确认停止→竖屏恢复，并验证进程重启保留两页 Lv4。证据见 `../../05-联调与测试/full-regression-fix-2026-10-04.md`；不代表用户真机或全部人工通过。

> 关联任务：T-F003
> 状态：`done`
> 生成日期：2026-06-20
> 关联后端模块：`04-后端/开发计划/06-learning-sync.md`

---

## 1. 功能定位与边界

本模块负责 v2.0 首页、进度页、我的页的信息架构和三栏底部导航。首页必须直接承载音符识别、视奏挑战、和弦练习、歌曲练习，不新增独立练习中心。

---

## 2. 入口、路由与页面文件

| 页面 | 文件 |
|------|------|
| 主框架 | `lib/pages/main/index.dart`、`controller.dart`、`view.dart` |
| 首页 | `lib/pages/home/index.dart`、`controller.dart`、`view.dart` |
| 进度页 | `lib/pages/progress/index.dart`、`controller.dart`、`view.dart` |
| 我的页 | 现有 `lib/pages/settings/` 改造成“我的”语义 |

底部导航固定为：首页 / 进度 / 我的。

---

## 3. 依赖前置

| 依赖 | 说明 |
|------|------|
| T-F001 | 路由、API、Store 基础 |
| T-F002 | 账号态、同步态 |
| T-B007 | `/api/v1/learning/overview` |

---

## 4. 视觉参考与设计稿分析

参考图片：

- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/02-首页.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/04-进度页.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/05-我的页.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/effect-home-reference.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/effect-progress-reference.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/effect-settings-reference.png`

当前图中表现：首页从上到下为问候与状态、四个练习入口、继续练习 / 最近曲目、底部导航；进度页为统计卡、图表、成就和下一目标；我的页为账户卡、设置入口和帮助信息。当前 PRD 目标版本要求首页不出现练习中心概念。

---

## 5. 涉及模块与类

| 类型 | 建议文件 |
|------|----------|
| API | `SolfeggioApi.getLearningOverview()` |
| Store | `SolfeggioSyncStore`、`AuthStore` |
| Controller | `HomeController`、`ProgressController`、`SettingsController` |
| Widgets | `V20ModeEntryCard`、`LearningStatCard`、`ProfileMenuTile` |

---

## 6. 业务内容与数据流

1. 首页和进度页优先读 `GET /api/v1/learning/overview`。
2. 游客或离线时使用本地 Hive / GetStorage 聚合降级。
3. 首页四入口分别进入 `/practice`、视奏挑战模式、`/chord_practice`、`/songs`。
4. 我的页展示账号状态、同步状态、设置入口和版本信息。
5. 云端数据带 `updatedAt/version` 时，Store 以服务端为准合并本地未同步记录。

---

## 7. 现有工程参考点

- 当前已有 `home`、`progress`、`settings`、`main` 页面。
- v1.2 已有底部导航和统计卡，需要改文案、入口和数据来源。
- 现有 Settings 命名在产品层改为“我的”，代码目录可先保持 `settings` 以减少扩散。

---

## 8. 建议实现步骤

1. 改底部导航文案与图标。
2. 首页改成四入口结构并接路由。
3. 接学习概览接口和本地降级数据。
4. 改进度页统计卡、趋势、成就、下一目标。
5. 改我的页账户卡与菜单入口。
6. 补空态、未登录态、同步失败态。

---

## 9. 详细编码任务清单

| 子任务 | 说明 | 状态 |
|--------|------|------|
| T-F003-01 | Main 三栏导航改造 | done |
| T-F003-02 | 首页四入口和学习状态 | done |
| T-F003-03 | 进度页学习聚合 | done |
| T-F003-04 | 我的页账号与设置入口 | done |
| T-F003-05 | 游客 / 离线 / 同步失败状态 | done |

---

## 10. 验收标准

- 首页四入口明确且可点击。
- 底部导航无 Settings 文案，统一为“我的”。
- 进度页能在登录和游客状态下展示数据。
- 所有统计文案支持本地化，不硬编码长段中英文。

---

## 11. 编码注意事项

- 不新增独立练习中心页。
- 不把学习数据写死在 UI。
- 避免英文长文案导致卡片 overflow。

---

## 12. 编码执行记录

| 时间 | 范围 | 结果 | 状态 |
|------|------|------|------|
| 2026-06-20 | Main 三栏导航 | 底部导航文案调整为首页 / 进度 / 我的，代码目录继续复用 `settings` | `done` |
| 2026-06-20 | 首页四入口 | 首页练习模式改为音符识别、视奏挑战、和弦练习、歌曲练习 2x2 入口，分别连接既有练习、挑战、和弦、曲库路由 | `done` |
| 2026-06-20 | 学习概览 | Home / Progress 先用本地记录聚合，登录态下尝试 `GET /api/v1/learning/overview` 字段级覆盖，接口失败保持本地降级 | `done` |
| 2026-06-20 | 我的页账号状态 | 我的页增加登录态、游客态、待同步记录和登录入口，保留原设置项 | `done` |
| 2026-06-20 | 验证 | `dart format`、`git diff --check`、`flutter analyze --no-fatal-infos --no-fatal-warnings`、`flutter test` 通过；仍打印既有资源目录缺失提示 | `done_with_existing_warnings` |
