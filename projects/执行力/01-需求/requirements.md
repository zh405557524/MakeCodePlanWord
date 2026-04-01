# 执行力 产品需求文档（PRD）

> 版本：v1.3（恢复重建）  
> 创建日期：2026-04-01  
> 更新说明：v1.3 含四阶段闭环、PlanEditor 独立详述、§4.0 统一约定、注册/登出、master-plans、终止计划、GET profile；本文档为误删后根据会话记录重建。  
> 状态：草稿  
> 设计 Token：见 `01-需求/references/docs/执行力-颜色文档-v1.1.md`  
> 交付形态：**Flutter + Kotlin 后端**（源原型为 Web，仅供参考）。

---

## 1. 项目概述

### 1.1 背景与目标

用户困境：**有目标有计划，却不知道现在该做什么、没做完该怎么办**。产品像 **课程表** 一样管理：每天怎么排、现在该做哪一段；掉队时可 **推迟** 或 **放弃本条**。

核心闭环：

> **输入计划 → 规划计划 → 执行计划 → 结果处理（成功 / 失败）**

### 1.2 四阶段工作流（摘要）

1. **输入**：Chat 自然语言或 PlanEditor 手动 → 结构化计划草案/草稿。  
2. **规划**：拆阶段与任务（课程块 / 打卡）；挂 `master_plan`；在 **Plan 日/周** 与 **BattleMap** 确认。  
3. **执行**：**Now** 按 **当前时间** 筛出「此刻应执行」；专注、完成。  
4. **结果**：成功则更新进度；失败则 **推迟 / 放弃本次 / 终止计划**；记录结果并可提示对整体目标影响。

### 1.3 领域模型

- **总体计划 MasterPlan** → **计划 Plan**（可选 `plan_archetype`）→ **阶段 Phase** → **任务 PlanTask**（`task_kind`：scheduled_block / recurring_checkin）→ **实例 task_instances**。  
- 计划气质：课程型 / 打卡型 / 目标型（阶段强弱不同）。

### 1.4 目标用户与定位

需要可视化排期、多线并行、对话降门槛的用户。差异化：**计划为核心 + 时间驱动 Now + 对话改计划 + 完整结果处理**。

---

## 2. 功能需求

### 2.1 功能模块列表

| 模块 | 描述 | 优先级 |
|------|------|--------|
| 开屏 | 品牌动画约 2s | 高 |
| Now | 当前时刻可执行集；专注；推迟/放弃 | 高 |
| Chat | 生成/改计划；草案确认落库 | 高 |
| Plan | 日/周课表视图 | 高 |
| BattleMap | 总体+年度计划一览 | 高 |
| TrackDetail | 单计划时间线 `planId` | 高 |
| PlanEditor | 创建/更新计划树 | 高 |
| 执行反馈 | 推迟、放弃、可行性提示 | 中高 |
| Profile / UserProfile | 设置、资料、统计 | 高 |
| 账号 | 注册、登录、登出、刷新 | 高 |
| 产品说明（可选） | 内置文档页 | 低 |

### 2.2 核心功能详述

#### 开屏 Splash

- **用户故事**：作为用户，我希望启动时有品牌反馈。  
- **验收**：冷启动展示；约 2s 后进主页或登录；低端机可降级动效。

#### Now 当前执行

- **用户故事**：作为用户，我希望知道 **此刻** 该执行哪一段并可诚实反馈未完成。  
- **描述**：`GET /api/v1/now`；课程块+打卡；pending/in-progress/completed；推迟/放弃；专注全屏。  
- **验收**：与接口一致；变更反映到 Plan/周视图；重叠任务排序规则待实现约定。  
- **边界**：空状态引导 Chat/Plan。

#### Chat 计划对话

- **用户故事**：作为用户，我希望说话就能新建或改计划。  
- **描述**：草案 JSON；**确认应用** `plan-drafts/apply`；可 Mock LLM。  
- **验收**：不得静默覆盖；消息分页；草案校验失败可解释。

#### Plan 计划展示（日/周）

- **用户故事**：作为用户，我希望像课表一样看今天和本周。  
- **描述**：`GET /plans/schedule`；栅格+打卡列表；进编辑器/作战地图。  
- **验收**：与 Now 共用实例语义。

#### 计划编辑器 PlanEditor

- **用户故事**：作为用户，我希望 **创建或修改** 计划（阶段、课程块、打卡、挂总体计划）。  
- **描述**：保存 `POST/PUT /plans`；`plan_archetype`；`master_plan_id`；阶段与任务 CRUD；与 Chat 草案衔接预填。设计稿 03–14。  
- **验收**：新建返回 `plan_id`；编辑与 GET 详情一致；校验失败字段级提示；未保存离开可确认（可选）。  
- **边界**：大量节点性能二期；离线 Backlog。

#### 年度作战地图与 TrackDetail

- **用户故事**：作为用户，我希望看到总体与年度下有哪些计划，并点进某一计划看完整时间线。  
- **描述**：BattleMap 聚合；TrackDetail=`plan_id`；模板五条可为示例非唯一模型。  
- **验收**：数据来自用户 plans+master；`GET .../timeline` 一致。  
- **边界**：游离计划展示待确认。

#### 执行反馈

- **用户故事**：作为用户，我希望明确推迟还是不做，并知对排期的影响。  
- **描述**：Now/日视图操作；审计 resolution；可选可行性提示（二期增强）。  
- **边界**：重复任务推迟单次 vs 改规则待确认。

#### Profile 与个人信息

- **用户故事**：作为用户，我希望设置节奏与展示身份。  
- **用户故事（UserProfile）**：作为用户，我希望编辑头像、标签、座右铭等并看统计。  
- **验收**：设置同步；清空数据二次确认与不可恢复提示。

#### 账号与鉴权

- **用户故事**：登录、**注册**、安全会话。  
- **验收**：注册后可登录；登出清 Token 后 401；未登录不可进业务；Token 可刷新。

---

## 3. UI 页面流

> 对照 `references/images/` 与颜色文档。

**设计稿序号 26（原「其他页面」）**：MVP 可并入 Plan 扩展区或 Profile；若需独立路由在实现阶段命名，本期不强制单独成章。

### 3.1 流转

```
Splash → 登录/注册 → 主框架（Now / Chat / Plan / Profile）
  Plan → BattleMap → TrackDetail(planId)
  Plan → PlanEditor（新建/编辑）
  Profile → UserProfile
```

Chat、BattleMap、TrackDetail、PlanEditor、UserProfile **隐藏底部 Tab**。

### 3.2 各页结构（摘要）

各页含：入口、顶/中/底区块、可交互项、出口。详见设计稿：Now/Chat/Plan/Profile（27–31）、PlanEditor（04–15）、BattleMap（18–19）、UserProfile（01–03）。

---

## 4. 前后端交互说明

### 4.0 统一响应、加载与错误

- 除注册/登录/刷新/开屏外带 `Authorization: Bearer <token>`。  
- `{ code, message, data }`；**code===0** 成功；失败 Toast/内联 `message`。  
- 网络超时/离线区分提示；列表骨架屏；提交按钮 loading 防抖。  
- **401**：尝试 refresh，失败跳转登录。

### 4.1 账号

**注册**：填因子+密码 → `POST /api/v1/auth/register` → 成功进登录或自动登录。  
**登录**：`POST /api/v1/auth/login` → 存 Token。  
**刷新**：`POST /api/v1/auth/refresh`。  
**登出**：`POST /api/v1/auth/logout` → 清本地 Token → 登录页。

### 4.2 Now

**拉取**：`GET /api/v1/now?at=&tz=` → 渲染列表。  
**更新**：`PATCH /api/v1/task-instances/{id}`，`resolution`：done/postponed/dropped 等。

### 4.3 Chat

**发送**：`POST /api/v1/chat/messages`（可返 `plan_draft`）。  
**应用**：`POST /api/v1/chat/plan-drafts/apply`。  
**历史**：`GET /api/v1/chat/messages?cursor=`。

### 4.4 排期

`GET /api/v1/plans/schedule?scope=day|week&anchor=YYYY-MM-DD`。

### 4.5 总体与作战地图

**列表**：`GET /api/v1/master-plans`。  
**创建**：`POST /api/v1/master-plans`。  
**作战地图**：`GET /api/v1/overview/battle-map?year=` 或 `master_plan_id`。  
**时间线**：`GET /api/v1/plans/{id}/timeline`。  
**勾选**：`PATCH` plan-task 或 task-instance。

### 4.6 Plan CRUD

**保存**：`POST/PUT /api/v1/plans`。  
**删除**：`DELETE /api/v1/plans/{id}` 软删。  
**终止（归档）**：`PATCH /api/v1/plans/{id}` `{ "lifecycle": "archived" }` 或 `POST .../terminate`（技术方案锁定）；停生成未来实例，历史保留。

### 4.7 用户资料

**拉取**：`GET /api/v1/me/profile`。  
**设置**：`PUT /api/v1/me/settings`。  
**更新资料**：`PUT /api/v1/me/profile`。  
**清空**：`POST /api/v1/me/purge`。

---

## 5. 非功能与安全

- 首屏可交互 &lt;3s（4G）；列表流畅；HTTPS；密码哈希；LLM 仅后端。  
- iOS/Android；离线 MVP 轻量缓存。

---

## 6. 技术约束

Flutter + GetX；Ktor + PostgreSQL；LLM 后端代理。

---

## 7. 里程碑

| 阶段 | 内容 |
|------|------|
| MVP | 鉴权、/now、schedule、BattleMap、timeline、PlanEditor、Chat 草案 Mock、推迟/放弃、开屏 |
| 二 | 真 LLM、流式、冲突/可行性 |
| 三 | 推送、深色、离线冲突、拖拽排课 |

---

## 8. 待确认

- 登录因子：邮箱/手机/双持。  
- purge 是否保留账号。  
- 多总体计划与是否按自然年。  
- 推迟：单次实例 vs 改重复规则。  
- 五条示例模板策略。  
- 产品说明内置页。  
- 时区：设备 vs 用户配置。

---

## 附录 A

MasterPlan、Plan、PlanTask、TaskInstance、Phase、ChatMessage（含 plan_draft）等字段与 `references/docs` 源 TS 模型对齐；补充 `user_id`、审计字段。

## 附录 B

设计稿索引见 [references/README.md](references/README.md)。
