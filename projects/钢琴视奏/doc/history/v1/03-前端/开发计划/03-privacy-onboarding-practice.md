# 03-privacy-onboarding-practice Flutter 模块开发文档

> 关联任务：T-F004
> 状态：`done`
> 生成日期：2026-06-20

---

## 1. 功能定位与边界

本模块负责协议守卫、首次同意后的 20 题临时新手引导，以及音符识别 / 视奏挑战现有练习链路的 v2.0 校准。

---

## 2. 入口、路由与页面文件

| 页面 / 弹框 | 文件 |
|-------------|------|
| 首页可浏览 | `lib/routes/router.dart` redirect / guard |
| 音符识别练习 | `lib/pages/practice/` |
| 新手引导状态 | `lib/pages/practice/` 或独立 guide state |
| 协议弹框 | 现有协议弹框组件 |
| Web 协议页 | `lib/pages/web/` |

---

## 3. 依赖前置

| 依赖 | 说明 |
|------|------|
| T-F001 | 路由和本地存储基础 |
| T-F002 | 登录态不应影响协议本地状态 |

---

## 4. 视觉参考与设计稿分析

参考图片：

- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/03-横屏音符识别练习页.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/17-隐私协议与用户协议弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/18-练习设置弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/19-钢琴录音音域说明弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/20-停止练习确认弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/21-普通练习完成弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/22-视奏挑战结果弹框.png`
- `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/04-ChatGPT图片生成计划/images/38-新手引导练习状态.png`

当前图中表现：横屏练习页以谱面、键盘、输入状态和右侧控制为主；协议弹框为轻量确认；新手引导用进度提示和点击/输入指引。当前 PRD 目标版本要求未同意协议仍可浏览首页，进入二级页面才拦截。

---

## 5. 涉及模块与类

| 类型 | 建议文件 |
|------|----------|
| Guard | `PrivacyGuard` / router redirect |
| Store | `PrivacyStore`、现有练习设置 Store |
| Controller | `PracticeController` |
| Widgets | 协议弹框、练习设置弹框、新手引导 overlay |

---

## 6. 业务内容与数据流

1. 启动后允许进入首页。
2. 用户进入受保护二级页面时检查协议状态。
3. 未同意则弹协议；不同意中止导航。
4. 首次同意且未完成新手引导时，进入 `/practice` 并设置 `autoStart=true`、`tempNotesCount=20`。
5. 临时题量不写回用户长期练习设置。
6. 引导完成后写入本地 `onboardingPracticeDone=true`。

---

## 7. 现有工程参考点

- 当前已有 `PracticePage` 和 `Global.newbiePracticeNotesCount`。
- 当前已有练习设置、停止确认、完成弹框和权限弹框。
- 优先复用既有练习状态机，不另造一套练习引擎。

---

## 8. 建议实现步骤

1. 梳理现有协议弹框和 router guard。
2. 调整首页放行、二级页拦截策略。
3. 增加首次同意后自动引导触发。
4. 改 PracticeController 支持临时题量。
5. 补引导 overlay 和完成记录。
6. 回归权限、停止、完成、挑战结果弹框。

---

## 9. 详细编码任务清单

| 子任务 | 说明 | 状态 |
|--------|------|------|
| T-F004-01 | 协议状态存储与二级路由守卫 | done |
| T-F004-02 | 首次同意后 20 题引导触发 | done |
| T-F004-03 | Practice 临时题量与 autoStart | done |
| T-F004-04 | 引导状态 UI 和完成记录 | done |
| T-F004-05 | 练习相关弹框回归 | done |

---

## 10. 验收标准

- 未同意协议可进入首页。
- 未同意进入二级页会弹协议，不同意不跳转。
- 首次同意自动进入 20 题引导。
- 引导题量不污染长期设置。

---

## 11. 编码注意事项

- 协议状态应本地持久化。
- 不要在 Splash 放协议入口。
- 引导只触发一次，用户重新安装或清数据除外。

---

## 12. 编码执行记录

| 时间 | 范围 | 结果 | 状态 |
|------|------|------|------|
| 2026-06-20 | 路由与守卫 | 保持首页放行，二级页通过 `PrivacyGuard.require` 拦截，未同意时中止原动作 | `done` |
| 2026-06-20 | 首次同意引导 | `PrivacyGuard` 首次同意后跳转 `/practice`，传入 `autoStart=true`、`newbieGuide=true`、`tempNotesCount=20` | `done` |
| 2026-06-20 | Practice 临时题量 | `PracticeController` 使用临时题量生成本局题目，不写回长期练习设置 | `done` |
| 2026-06-20 | 完成记录 | 新手引导完成标记改为练习自然完成后写入，手动停止不再误标记完成 | `done` |
| 2026-06-20 | 验证 | `dart format`、`git diff --check`、`flutter analyze --no-fatal-infos --no-fatal-warnings`、`flutter test` 通过；仍打印既有资源目录缺失提示 | `done_with_existing_warnings` |
