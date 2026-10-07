# 05-song-practice Flutter 模块开发文档

## 2026-10-04 完成回栈回归

FULL-007 的歌曲钢琴夹具经公开 startPractice/startSession 建立有效 owner，会话完成全部目标后才验证结果页、历史写入和返回历史栈；手机也以测试 MIDI 事件作答完成目标。同步服务同时登记 teardown 并在 finally 清理，确保断言失败时仍释放，满足 Widget 测试在 teardown 前检查定时器的生命周期。新增手机/钢琴空会话无法导航结果或写入历史的反向断言，保留 song_practice_piano_score_test 的零答题、部分中断边界，不修改生产完成机制。测试 MIDI 不代替实体琴验证。证据：`../../05-联调与测试/full-regression-fix-2026-10-04.md`。

## 2026-09-26 当前权限修订

本模块歌曲内容解锁仅取决于等级（免费体验优先）；和弦和会员不锁曲谱。会员只校验 MIDI 钢琴练习；PHONE 屏幕免费，同页 MIDI 输入也免费。个人曲谱无等级、MIDI 需会员。以 `../../02-技术方案/midi-practice-membership.md` 为当前契约。


> 关联任务：T-F007、T-F008、T-F009
> 状态：`done`
> 生成日期：2026-06-20
> 关联后端模块：`04-后端/开发计划/04-song-practice.md`

## 2026-09-26 MIDI 默认输入增量

- CHG-20260926-MIDI-DEFAULT：用户已授权，状态 done（本地验证；未发布、未真机 MIDI 验收）。
- `lib/pages/song/practice/phone/` 在进入时绑定 MIDI 回调；已连接或页内连接后直接接收真实琴键，不需要切换输入，不跳转或重开歌曲会话，继续使用 `phoneMelody` 与 `mode=phone`。
- 屏幕和 MIDI 共用音高/八度判定、键盘反馈和进度保存；MIDI 连奏在反馈期间排队，Note Off 不答题，持续按住不重复答题；暂停、重开、跳小节和退出取消旧反馈。
- MIDI 最后一音完成后由 View 使用有效上下文进入现有结果页；关闭页面释放连接监听并恢复此前 MIDI 回调。
- 视奏与和弦、歌曲钢琴已有无需手动切换的行为继续沿用。验证入口：`05-联调与测试/midi-default-2026-09-26.md`；48 项相关测试通过。

---

## 1. 功能定位与边界

本模块负责歌曲练习闭环：手机模式、钢琴模式和歌曲结果页。手机模式只练右手旋律；钢琴模式使用大谱表和同一时间点目标音组；结果页展示完成度、准确率、错音小节和片段重练。

不包含手机模式双手、多音同时输入、AI 曲谱或上传曲谱。

---

## 2. 入口、路由与页面文件

| 页面 | 路由 | 文件 |
|------|------|------|
| 手机歌曲练习 | `/song_practice_phone` | `lib/pages/song_practice_phone/` |
| 钢琴歌曲练习 | `/song_practice_piano` | `lib/pages/song_practice_piano/` |
| 歌曲结果 | `/song_result` | `lib/pages/song_result/` |

---

## 3. 依赖前置

| 依赖 | 说明 |
|------|------|
| T-F006 | 进入练习前需要 songId / arrangementId / mode |
| T-B005 | song-practice session、progress、complete 接口 |
| T-B007 | 结果更新学习快照 |

---

## 4. 视觉参考与设计稿分析

参考图片：

- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/35-歌曲练习页-手机模式.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/36-歌曲练习页-钢琴模式.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/37-歌曲结果页.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/song-practice-phone-reference.jpg`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/01-需求分析/inputs/images/song-practice-piano-reference.jpg`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/05-图标与背景图生成计划/assets/35-歌曲练习页-手机模式/`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/05-图标与背景图生成计划/assets/36-歌曲练习页-钢琴模式/`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/05-图标与背景图生成计划/assets/37-歌曲结果页/`

当前图中表现：手机模式展示右手旋律、局部键盘和播放控制；按当前需求口径，手机模式与钢琴模式进入后均使用横屏沉浸布局。钢琴模式为横屏大谱表和状态控制，结果页为成绩、错误小节、片段重练和下一首。当前 PRD 目标版本要求钢琴模式不显示屏幕虚拟键盘。

---

## 5. 涉及模块与类

| 类型 | 建议文件 |
|------|----------|
| API | `SongPracticeApi.createSession()`、`updateSession()`、`completeSession()` |
| Service | `SongPracticeService` |
| Model | `SongPracticeSession`、`SongPracticeProgress`、`SongPracticeResult` |
| Widgets | `PhoneMelodyStaff`、`GrandStaffView`、`PracticePlaybackBar`、`MistakeMeasureList` |
| Controller | `SongPracticePhoneController`、`SongPracticePianoController`、`SongResultController` |

---

## 6. 业务内容与数据流

1. 进入练习页先调用 `POST /api/v1/song-practice/sessions`。
2. 手机模式读取谱面 JSON 的 `phoneMelody`。
3. 钢琴模式读取 `grandStaff` 和目标音组。
4. 练习中定期调用 `PUT /api/v1/song-practice/sessions/{sessionId}` 保存进度。
5. 完成时调用 `POST /api/v1/song-practice/sessions/{sessionId}/complete`。
6. 结果页读取提交响应或本地结果缓存展示。
7. 内置编配在进入练习时按需加载构建期生成的 `sheetJson`，App 运行时不解析 MusicXML。
8. `measureBeats` 保存逐小节拍数映射，钢琴模式优先使用该映射处理变拍。
9. 进入任一练习模式前停止详情页录音，录音不与练习评分时间轴同步。

---

## 7. 现有工程参考点

- 音符识别练习页已有横屏布局、MIDI、拾音、键盘反馈。
- `simple_sheet_music` 可作为谱面渲染基础。
- 需要扩展而不是复制已有输入判定逻辑。

---

## 8. 建议实现步骤

1. 定义谱面 JSON 模型：phoneMelody、grandStaff、segments。
2. 实现练习 session 创建与恢复。
3. 实现手机模式右手旋律和局部键盘。
4. 实现钢琴模式大谱表和目标音组判定。
5. 实现片段进度上传和离线保存。
6. 实现结果页、错音小节、片段重练。

---

## 9. 详细编码任务清单

| 子任务 | 说明 | 状态 |
|--------|------|------|
| T-F007-01 | 手机模式谱面模型与页面骨架 | done |
| T-F007-02 | 手机模式单音推进与控制栏 | done |
| T-F008-01 | 钢琴模式大谱表渲染 | done |
| T-F008-02 | 目标音组和 MIDI / 拾音判定 | done_with_backend_dependency |
| T-F009-01 | 结果提交与结果页 | done |
| T-F009-02 | 错音小节和片段重练 | done |
| T-F007-03 | 内置右手最高音谱面与逐小节拍数 | done |
| T-F008-03 | 内置双手同时间点音组、延音合并和变拍支持 | done |

---

## 10. 验收标准

- 手机模式进入后切换为横屏沉浸布局，只练右手旋律，不显示大谱表。
- 手机模式退出后恢复应用默认竖屏和系统栏。
- 钢琴模式显示大谱表，不显示屏幕虚拟键盘。
- session 进度可恢复，complete 后生成结果页。
- 片段重练能回到对应小节范围。
- 30 首内置曲目可同时提供手机 / 钢琴练习，34 份乐章谱面按需加载。
- 休止符和装饰音不产生强制目标，延音线只要求一次击键。

---

## 11. 编码注意事项

- 谱面和判定逻辑不要写在 View。
- 横屏页面必须按 `812 x 375` 验收。
- 弱网下进度提交失败要保留本地待同步。
- MusicXML 转换是构建期步骤；运行时不得解析 XML，也不得加载整套谱面到列表或详情页。

---

## 12. 执行记录

| 时间 | 操作 | 结果 |
|------|------|------|
| 2026-06-20 | 扩展歌曲练习谱面模型：`phoneMelody`、`grandStaff`、目标音组、进度和结果 DTO | `done` |
| 2026-06-20 | 完成 `SongPracticeService` session 创建、进度保存、完成提交和失败入本地待同步队列 | `done` |
| 2026-06-20 | 完成手机模式右手旋律页：单音推进、局部键盘、进度、统计、空态 | `done` |
| 2026-06-20 | 完成钢琴模式页：横屏大谱表、目标音组推进、统计和完成提交；屏幕内不显示虚拟键盘 | `done_with_backend_dependency` |
| 2026-06-20 | 完成结果页：分数、准确率、完成度、错音小节、片段重练入口和本地待同步状态 | `done` |
| 2026-06-20 | 后端 T-B005 / T-B007 未联调前不伪造谱面；无真实谱面时显示空态，接口失败时走本地 session 与待同步队列 | `done_with_backend_dependency` |
| 2026-06-20 | `dart format`、`git diff --check`、`flutter analyze --no-fatal-infos --no-fatal-warnings`、`flutter test` | `passed_with_existing_warnings` |
| 2026-07-25 | 将 34 份 MusicXML 构建为手机右手最高音与钢琴双手目标音组 `sheetJson`，补齐 `measureBeats` 变拍映射并按入口懒加载 | `done` |
| 2026-07-25 | L2-02 / L2-03 保留三个乐章；L1-08 待审 MusicXML 不进入安装包且练习入口禁用 | `done` |
| 2026-07-28 | 修复手机模式方向生命周期：Android / iOS 进入后锁定双横屏，iOS 同步原生方向 mask；退出后恢复双竖屏与系统栏，桌面端跳过移动端方向 API | `done_with_manual_device_qa` |
