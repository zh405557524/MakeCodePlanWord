# 喵喵写歌 V2.1 翻唱声音克隆 Flutter 总体开发计划

> 文档版本：`v2.1-ai-cover-voice-clone`
> 变更编号：`CHG-0073`
> 状态：`done`
> 实现策略：`skeleton_first`
> 当前实现阶段：`real_review`
> 本轮骨架目标：`flutter,java`；Web/Admin `deferred`
> 骨架运行环境：`local_test_fixed`
> 创建日期：2026-09-09
> 需求真源：`../../01-需求/v2.1-ai-cover-voice-clone/requirements.md`
> 技术方案：`../../02-技术方案/v2.1-ai-cover-voice-clone/tech-plan.md`
> 工时评估：`../../02-技术方案/v2.1-ai-cover-voice-clone/effort-estimate.md`
> Flutter 技术文档：`./flutter-tech.md`
> Java 接口文档：`../../04-后端/v2.1-ai-cover-voice-clone/java-tech.md`
> Figma 真源：通道 `p354jft5`，文件「working」，页面 `working (91:106)`，38 个有效 Frame
> App 工程：`/Users/soul/code/lxwx/catsinger`
> Web/Admin 工程：`/Users/soul/code/lxwx/lxwx_admin`

---

## 0. 文档用途与执行门禁

本文是第 9 步总体开发计划，负责确定 Flutter App 与 Flutter Web/Admin 的实现顺序、任务依赖、恢复点、模块文档目录和验收门槛。本文不是模块实现说明，也不是编码授权。

执行规则：

1. 本计划评审通过后，先按第 11 步生成全部当前版本模块开发文档。
2. 模块文档通过后，才进入 Flutter 编码。
3. 编码只能读取 `v2.1-ai-cover-voice-clone` 当前版本文档，旧 `v1.1-ai-cover` 只用于差异核对。
4. 三业务保持隔离：AI 写歌、AI 改编不改变；新功能单独使用 `song_voice_cover` 模块与 `/api/song-voice-covers`。
5. P12 不新建结果页、不重做播放器，直接接入现有 `SongPlayerPage`。
6. 页面、接口、状态或安全规则有变化时，先登记新 CHG 并回卷文档，禁止在编码中静默改需求。
7. Flutter App 与 Java 先完成全部 `-S` 可运行骨架，再统一进入 `skeleton_review`；用户明确确认骨架后才执行 `-R`。
8. 本轮 `skeletonTargets` 不包含 Web/Admin，所有 `T-Wxxx-S/T-Wxxx-R` 均保持 `deferred`，不得顺带创建后台代码。
9. 骨架页面调用正式 API 路径，固定数据由 local/test 后端集中提供；正式构建默认隐藏翻唱声音克隆入口。

---

## 1. 当前状态与恢复点

| 字段 | 当前值 |
|------|--------|
| 当前阶段 | `13 Flutter 编码` |
| 当前状态 | `waiting_review`（T-F001-R 至 T-F010-R 已本地实现） |
| 当前恢复点 | Flutter 真实实现和本地构建已完成；Web/Admin 继续暂缓，等待部署后的双端联调和真实作品播放验收 |
| 下一动作 | 部署 V2.1 Java 与配置后，执行上传、训练、积分、翻唱、审核、持久化和播放器完整闭环 |
| App 基线 | `dev @ a57551c8`，计划生成时工作区干净 |
| Admin 基线 | `main @ 741995a`，计划生成时工作区干净 |
| 后端契约基线 | `java-tech.md` 当前接口和状态定义 |
| 视觉基线 | Figma `p354jft5`，38 个有效 Frame；产品展示文案按 PRD 校准为「翻唱声音克隆」 |

编码开始前重新记录三端分支、commit 和 dirty diff。若基线变化涉及本计划任务，先回卷相应模块文档；不得覆盖用户或其他任务已有修改。

### 1.1 状态枚举

| 状态 | 含义 |
|------|------|
| `pending` | 尚未开始，前置依赖可能未完成 |
| `in_progress` | 当前唯一正在执行的任务 |
| `waiting_review` | 产物已生成，等待人工确认或视觉验收 |
| `blocked` | 外部接口、设备、账号或决策导致无法继续 |
| `done` | 代码和该任务规定的验证均完成 |
| `skipped` | 经用户明确决定跳过，必须记录原因 |

### 1.2 更新规则

- 开始模块前将该模块和唯一任务改为 `in_progress`，并写明基线。
- 完成代码但未完成规定验证时不得标记 `done`。
- Mock、接口 200、任务状态成功均不能代替真实音频可播放验收。
- 阻塞时记录失败命令、页面、接口、环境和恢复条件，不通过占位数据伪造完成。
- 每完成一个模块，更新模块文档、本文任务状态、`workflow.md` 恢复点和执行记录。

### 1.3 双阶段状态

| 阶段 | 可执行任务 | 当前状态 | 完成/退出条件 |
|------|------------|----------|---------------|
| 骨架准备 | 模块文档 `-S/-R` 拆分 | `skeleton_pending` | 文档评审通过后进入骨架编码 |
| 骨架编码 | `T-F001-S`～`T-F010-S` | `done` | Flutter/Java 目标骨架全部可编译、可运行且生产禁用 |
| 骨架评审 | 不编码 | `done` | 用户已明确确认骨架并授权真实实现 |
| 真实实现 | `T-F001-R`～`T-F010-R` | `waiting_review` | 本地代码、定向测试、双平台构建和 iOS 375x812 页面检查完成；等待部署联调 |
| Web/Admin | `T-W001-S/R`～`T-W008-S/R` | `deferred` | 不属于本轮 `skeletonTargets`，后续另行解除暂缓 |

---

## 2. 总体开发策略

### 2.1 实现顺序

```text
冻结契约与基线
  -> 数据模型/API/Store
  -> 首页入口与路由
  -> 翻唱主页和设置
  -> 音色资料与素材采集
  -> 音色训练与状态恢复
  -> 翻唱任务与状态恢复
  -> 作品和现有播放器
  -> Web/Admin 配置与运营
  -> 三端联调、双平台测试和修复
```

先实现稳定契约和状态映射，再实现页面。不得先画完整页面、最后再补接口而形成无法恢复的局部状态。

### 2.2 复用与隔离

| 范围 | 复用 | 必须独立 |
|------|------|----------|
| App 基础能力 | GetX、go_router、Dio、GetStorage/Hive、OSS 直传、私有资源换签、录音、媒体转换、播放服务、会员积分 | `pages/song_voice_cover/`、专属 Controller/Store/API/DTO |
| 作品 | 现有作品列表、详情、收藏、下载、删除和播放队列 | `songType=VOICE_COVER` 标签、音色摘要、重新翻唱入口 |
| 播放器 | `SongPlayerPage`、歌词、播放、下载、分享、收藏 | 不新建 V2.1 结果播放器 |
| Admin | Shell、App 切换、Repository、模型、价格、AI 运维、资源、作品、角色 | Catsinger 音色资料和声音训练管理子模块 |
| AI 改编 | 完全保留现状 | 不得将 `SongCoverPage` 或 `coverVoiceCode` 改造成声音克隆 |

### 2.3 状态真源

- 后端是模型可用性、审核、价格、积分、任务状态和作品生命周期真源。
- App 本地只保存未提交草稿、最近任务 ID 和 UI 恢复信息，不本地推导服务端成功。
- `providerAcceptedAt` 为空时展示“排队中”，不显示 10 分钟倒计时。
- 倒计时只使用服务端 `deadlineAt`，不能用进入页面时间计算。
- App 收到任务成功后仍需用返回的 `workId` 打开目标作品，并等待播放器实际开始、进度增长后才完成用户验收。

### 2.4 错误处理

- 使用现有 `ApiException` 和错误码映射，不通过中文字符串包含关系判断业务状态。
- 表单错误定位到字段；会员限制进入会员页；积分不足进入充值页；报价过期刷新模型和价格；音色不可用要求重新选择。
- 审核 `PENDING/REVIEW/REJECT/ERROR` 分开展示，`ERROR` 只有后端允许时显示重试。
- 页面离开不取消训练或翻唱；重新进入从后端恢复任务。

---

## 3. 工时与里程碑

本计划只分配前端主编码工时。完整功能测试、真实厂家联调和 Bug 回归仍按总工时文档单独计算，不能把它们藏进页面编码时间。

| 范围 | 主编码时长 | 日历位置 | 完成定义 |
|------|------------|----------|----------|
| Flutter App | 8 小时 | 2026-09-10 至 2026-09-14 跨模块穿插 | P01-P11、任务恢复、作品和播放器接入完成，代码级验证通过 |
| Web/Admin | 4 小时 | 2026-09-10 至 2026-09-14 与后端并行 | W01-W12 对应能力可从 catsinger App 管理，代码级验证通过 |
| 配置与真实联调 | 参与总计划 1 天 | 2026-09-15 至 2026-09-16 | 页面读取真实配置，真实训练和翻唱可观察 |
| 完整测试与修复 | 参与总计划 3 天 | 2026-09-17 至 2026-09-18 | Android/iOS/Admin 和受影响回归完成 |

里程碑：

| 里程碑 | 前端完成条件 |
|--------|--------------|
| M1 契约可用 | API/DTO/Store 完成，无 `mode`，真实 `provider/model` 可提交 |
| M2 素材可用 | 本地文件、录音、相册视频提取、截取、上传和审核状态闭环 |
| M3 训练可用 | 本人音色创建、报价、提交、轮询、试听和失败恢复闭环 |
| M4 翻唱可用 | 整曲来源、音色、设置、报价、任务恢复和倒计时闭环 |
| M5 作品可用 | 目标作品进入现有播放器并真实播放，重新翻唱可回填 |
| M6 后台可运营 | 模型、价格、音色、审核、任务、作品、资源和权限可配置 |

---

## 4. Flutter App 详细任务

总计 8 小时主编码时间。时间是 AI 直接实现的工作量，不改变每项完成门槛。

| 任务族 | 骨架任务 | 真实任务 | 任务 | 依赖 | 骨架状态 | 真实状态 |
|--------|----------|----------|------|------|----------|----------|
| `T-F001` | `T-F001-S` | `T-F001-R` | 契约与数据层 | Java 契约 | `done` | `done` |
| `T-F002` | `T-F002-S` | `T-F002-R` | 首页入口和路由 | T-F001 | `done` | `done` |
| `T-F003` | `T-F003-S` | `T-F003-R` | P02/P03 翻唱主页和设置 | T-F001、Java 配置接口 | `done` | `done` |
| `T-F004` | `T-F004-S` | `T-F004-R` | P04/P05 音色资料与来源 | T-F001 | `done` | `done` |
| `T-F005` | `T-F005-S` | `T-F005-R` | P06-P08 采集、截取和素材 | T-F004 | `done` | `done` |
| `T-F006` | `T-F006-S` | `T-F006-R` | P09 音色训练 | T-F001、T-F005、Java 训练 | `done` | `done` |
| `T-F007` | `T-F007-S` | `T-F007-R` | P10 翻唱任务 | T-F003、Java 翻唱 | `done` | `done` |
| `T-F008` | `T-F008-S` | `T-F008-R` | P11/P12 作品和播放器 | T-F007 | `done` | `done` |
| `T-F009` | `T-F009-S` | `T-F009-R` | 会员、积分、草稿和恢复 | T-F001-T-F008 | `done` | `done` |
| `T-F010` | `T-F010-S` | `T-F010-R` | 双阶段代码验证 | T-F001-T-F009 | `done` | `waiting_review` |

`-S` 完成定义是完整 UI/调用链、local/test 固定响应和生产禁用通过；原表中的真实上传、审核、任务恢复、真实播放和业务闭环完成定义全部归入对应 `-R`。

### 4.1 页面交付矩阵

| PRD 页面 | 入口 | 核心任务 | 退出/下一跳 |
|----------|------|----------|-------------|
| P01 首页 | 首页快捷入口 | T-F002 | 进入 P02；返回首页不影响旧入口 |
| P02 翻唱主页 | P01、重新翻唱 | T-F003 | 进入音色/来源/设置；成功进入 P10 |
| P03 翻唱设置 | P02 设置按钮 | T-F003 | 保存回 P02，不单独提交厂家 |
| P04 音色资料 | 我的音色新建/编辑 | T-F004 | 保存资料后进入来源选择或返回 |
| P05 训练来源 | P04 创建流程 | T-F004 | 录音、本地文件或相册视频 |
| P06 录音 | P05 | T-F005 | 试听、继续录制或保存素材 |
| P07 上传与截取 | P05 文件/相册 | T-F005 | 生成新素材版本并进入审核 |
| P08 素材与提交 | P04/P07 | T-F005、T-F006 | 训练报价确认后进入 P09 |
| P09 训练状态 | 创建训练/恢复 | T-F006 | 成功试听，失败重试，离页任务继续 |
| P10 翻唱状态 | P02 提交/恢复 | T-F007 | 成功按 workId 打开 P12 |
| P11 作品 | 作品 Tab | T-F008 | 点击作品进入 P12，重新翻唱回 P02 |
| P12 播放器 | P10/P11 | T-F008 | 复用当前播放器，无新页面布局 |

### 4.2 App API 依赖

| 客户端方法 | 方法与路径 | 任务 | 关键约束 |
|------------|------------|------|----------|
| `fetchConfig` | `GET /api/song-config/voice-cover` | T-F001/T-F003 | 后端返回限制和功能开关 |
| `fetchModels` | `GET /api/song-config/models?sceneCode=...` | T-F001/T-F003/T-F006 | 使用真实 provider/model 和实时报价 |
| `fetchVoices/fetchVoice` | `GET /api/song-voices`、`/{id}` | T-F004 | 本人/官方作用域和可用性 |
| `createVoice/updateVoice/deleteVoice` | `POST/PATCH/DELETE /api/song-voices/**` | T-F004 | PATCH 带 revision；删除二次确认 |
| `bindVoiceMaterial` | `POST /api/song-assets/voice-materials` | T-F005 | 绑定上传资源并启动审核 |
| `bindCoverSource` | `POST /api/song-assets/voice-cover-sources` | T-F003/T-F005 | 整曲最多 10 分钟、100MB |
| `fetchAsset/retryModeration` | `GET /api/song-assets/{id}`、`POST /moderation/retry` | T-F005 | 状态分层，只有 ERROR 可重试 |
| `add/removeMaterial` | `POST/DELETE /api/song-voices/{id}/materials/**` | T-F005 | 审核通过后绑定，运行中不可删 |
| `create/fetchTraining` | `POST/GET /api/song-voice-training-tasks/**` | T-F006 | 本地保存任务 ID，不发明 active 接口 |
| `create/fetch/activeVoiceCover` | `POST/GET /api/song-voice-covers/**` | T-F007 | 创建无 mode；active 只返回 VOICE_COVER |
| 作品接口 | 现有 `/api/song-works/**` | T-F008 | 新增类型和音色摘要，播放仍走现有链路 |

---

## 5. Web/Admin 详细任务

总计 4 小时主编码时间。Web/Admin 不建设第二套管理后台，只在现有管理域扩展。

| 任务族 | 骨架任务 | 真实任务 | 任务 | 当前状态 | 说明 |
|--------|----------|----------|------|----------|------|
| `T-W001` | `T-W001-S` | `T-W001-R` | 导航、App 和权限 | `deferred` | 本轮不编码 Web/Admin |
| `T-W002` | `T-W002-S` | `T-W002-R` | 模型与价格 | `deferred` | 本轮不编码 Web/Admin |
| `T-W003` | `T-W003-S` | `T-W003-R` | 官方音色 | `deferred` | 本轮不编码 Web/Admin |
| `T-W004` | `T-W004-S` | `T-W004-R` | 本人音色 | `deferred` | 本轮不编码 Web/Admin |
| `T-W005` | `T-W005-S` | `T-W005-R` | 安全审核 | `deferred` | 本轮不编码 Web/Admin |
| `T-W006` | `T-W006-S` | `T-W006-R` | 训练/翻唱任务 | `deferred` | 本轮不编码 Web/Admin |
| `T-W007` | `T-W007-S` | `T-W007-R` | 作品、资源和审计 | `deferred` | 本轮不编码 Web/Admin |
| `T-W008` | `T-W008-S` | `T-W008-R` | 代码级验证 | `deferred` | 本轮不编码 Web/Admin |

### 5.1 Admin 页面映射

PRD W01-W12 映射到现有 Shell、模型管理、价格、AI 运营、歌曲、资源、角色与审计页面。模块文档必须逐页列出：入口、筛选字段、编辑字段、按钮权限、提交接口、成功刷新、失败恢复和只读状态。没有权限时后端仍需拒绝，不能只隐藏按钮。

---

## 6. 跨端依赖和并行顺序

| 顺序 | 前端动作 | 后端前置 | 可并行内容 |
|------|----------|----------|------------|
| 1 | 冻结 DTO/枚举/API | T-B001 契约 | App 模型类、Admin 路由骨架 |
| 2 | 完成资料/素材 UI | T-B002-T-B004 | 原生录音、文件选择、视频提取和静态对稿 |
| 3 | 完成训练 UI | T-B005-T-B007 | 训练等待页、状态 Widget、错误映射 |
| 4 | 完成翻唱 UI | T-B008-T-B010 | 翻唱等待页、倒计时和播放器接入 |
| 5 | 完成 Admin | T-B012 Admin API | 列表、筛选、表单和权限 UI |
| 6 | 联调与验收 | 后端测试环境配置完成 | 双平台、浏览器和旧业务回归 |

前端不得为了等待接口而提交生产 Mock。开发态 fixture 只能存在测试目录或显式 debug 注入，并在联调前关闭。

---

## 7. 编码约束

### 7.1 Flutter App

- 继续使用 GetX Controller/Store、go_router、Dio、GetStorage/Hive、`Global.init()` 和当前主题组件。
- 新模块使用 `song_voice_cover`，不复用 `song_cover` Controller。
- 375x812 为主基准，390x844 和 414x896 抽查；使用 `.w/.h/.sp/.r`，不按宽度动态缩放字体。
- 页面可滚动，底部按钮避让安全区、键盘、底部导航和迷你播放器。
- 原生媒体优先扩展现有 MethodChannel；引入新依赖前先验证现有能力不能覆盖。
- 所有订阅、Timer、播放器试听和轮询在 Controller 销毁时释放。
- 私有资源只通过现有换签和缓存服务访问，不能缓存长期厂家 URL。

### 7.2 Web/Admin

- 沿用 `core/data/models/pages` 和当前 `AdminRepository` 边界，不在页面直接拼 HTTP。
- 表格、筛选、分页、表单、空态、加载、失败和权限样式继承现有后台。
- 所有查询带当前 App 上下文；App 切换清理旧请求、选中项和分页状态。
- 音色头像、试听和素材使用受控预览，不向无权限角色泄露永久 URL。

### 7.3 不得改动

- 不重命名或迁移现有 AI 改编。
- 不修改 `/api/song-generations`、`/api/song-covers` 的现有客户端契约。
- 不新建 V2.1 播放器或作品体系。
- 不在前端写死 100/200 积分、厂家模型、超时起点或审核结论。
- 不把任务提交成功、状态成功或下载成功当成声音可播放通过。

---

## 8. 第 11 步模块开发文档列表

后续必须在 `03-前端/v2.1-ai-cover-voice-clone/开发计划/` 生成：

| 顺序 | 文件 | 覆盖任务 |
|------|------|----------|
| 00 | `00-module-index.md` | 全部任务、依赖图、状态和恢复点 |
| 01 | `01-contract-model-store.md` | T-F001 |
| 02 | `02-home-route-entry.md` | T-F002 |
| 03 | `03-voice-cover-main-settings.md` | T-F003 |
| 04 | `04-voice-profile-official-voice.md` | T-F004 |
| 05 | `05-record-file-video-trim.md` | T-F005 媒体采集 |
| 06 | `06-material-upload-moderation.md` | T-F005 上传、审核和质量规则 |
| 07 | `07-voice-training.md` | T-F006 |
| 08 | `08-voice-cover-generation.md` | T-F007 |
| 09 | `09-works-player-regenerate.md` | T-F008 |
| 10 | `10-membership-points-draft-recovery.md` | T-F009 |
| 11 | `11-admin-navigation-model-pricing.md` | T-W001、T-W002 |
| 12 | `12-admin-voice-moderation.md` | T-W003-T-W005 |
| 13 | `13-admin-tasks-works-resources.md` | T-W006、T-W007 |
| 14 | `14-flutter-admin-validation.md` | T-F010、T-W008 |

每份模块文档必须包括：设计稿节点、现状差异、目标结构、接口和字段、Controller/Store/Service、交互状态、异常恢复、影响文件、逐步实现、定向测试、截图验收和完成定义。

---

## 9. 验证计划

### 9.1 编码期间

```bash
dart format <本次修改的 Dart 文件>
flutter analyze
flutter test
git diff --check
```

App 与 Admin 分别执行。模块测试优先，公共层或共享播放器有改动时扩大受影响回归。

### 9.2 联调与用户验收

- 375x812 完整验收 P01-P11，390x844/414x896 抽查。
- Android 真机与 iOS 真机优先；无 iOS 真机用模拟器，二者都没有则 iOS 不通过。
- 文件选择、麦克风、相册视频、权限拒绝、切后台和进程恢复必须实际操作。
- 本人音色训练必须得到平台持久化且真实可播放的试听。
- 本人音色和官方音色各完成一条真实翻唱作品。
- 翻唱作品必须在现有播放器开始播放且进度连续增长，才能判定正向流程通过。
- Web/Admin 验证 catsinger App 切换、角色权限、模型价格、音色、审核、任务、作品和资源。
- 回归 AI 写歌和 AI 改编入口、创建、作品类型与计费没有变化。

### 9.3 高风险操作

付费训练、付费翻唱、删除音色、删除作品和后台下架分别使用测试账号和显式授权开关。没有测试环境或授权时标为 `BLOCKED/NOT_RUN`，不伪报 PASS。

---

## 10. 风险与恢复

| 风险 | 处理 |
|------|------|
| 后端 DTO 在编码期间变化 | 先回卷 Java/Flutter 模块文档，再同步 API 层 |
| 算道真实状态与资料不一致 | 保留未知状态和原始错误摘要，不在页面猜成功 |
| 音色无法跨厂家使用 | 模型切换时重新校验绑定并清空不可用选择 |
| iOS 媒体格式或权限差异 | 真机优先验证，失败保留原素材和可恢复提示 |
| 长任务离页或进程退出 | 本地保存任务 ID，服务端详情恢复，不重复提交 |
| 旧播放器被当前播放状态覆盖 | 路由 workId 优先，沿用现有目标作品锁定逻辑 |
| 后台 App 切换串数据 | 切换时取消旧请求并清空页面状态，响应校验 appCode |

回滚只移除新入口、新路由和新业务模块，不改旧 AI 写歌、AI 改编、共享播放器和既有作品。已经创建的服务端任务和作品由后端生命周期继续处理，客户端回滚不能擅自删除。

---

## 11. 总体验收标准

- [ ] 任务 ID 与 `T-F001-T-F010`、`T-W001-T-W008` 完整对应。
- [ ] 每项任务都有依赖、时长、状态和完成定义。
- [ ] P01-P12 与 W01-W12 均能映射到任务和后续模块文档。
- [ ] App 请求 `/api/song-voice-covers` 时不发送 `mode`，并发送真实 `provider/model`。
- [ ] AI 写歌与 AI 改编入口、接口、作品类型和页面均不改变。
- [ ] 平台排队不显示倒计时，厂家接单后才使用服务端 deadline。
- [ ] 审核、价格、积分、音色可用性和任务成功均以后端为真源。
- [ ] P12 复用当前播放器，翻唱作品实际播放后才通过。
- [ ] Admin 使用当前 App、模型、计费、审核、资源、作品和角色体系。
- [ ] 模块文档未完成前不进入编码。

---

## 12. 执行记录

| 日期 | 动作 | 结果 |
|------|------|------|
| 2026-09-09 | 读取当前版本 PRD、技术方案、工时、Flutter/Java 技术文档并核对 App/Admin 基线 | 三业务边界、接口、状态和 7 天总排期一致 |
| 2026-09-09 | 读取 Figma 通道 `ujnpl6tr` | 文件「音乐」、页面 `working (91:106)` 可访问；38 个 Frame 和 1 个非页面 Group 与本地索引一致 |
| 2026-09-09 | 生成 Flutter 总体开发计划 | 状态 `waiting_review`；未生成模块文档，未修改 App/Admin 代码 |
| 2026-09-09 | 用户要求继续下一步，进入第 11 步 | 总体计划标记 `done`；`开发计划/00-14` 共 15 份 Flutter/Web 模块开发文档已生成并进入 `waiting_review`，未修改 App/Admin 代码 |
| 2026-09-09 | 用户明确确认骨架并授权真实实现 | 完成 T-F001-R 至 T-F010-R；`flutter analyze`、新增功能 7 项测试、Android Debug APK、iOS no-codesign Debug 构建通过；iOS Simulator 已检查 375x812 主页面与音色资料页，等待部署联调和 Android 真机验收 |

Flutter App 真实实现当前为 `waiting_review`。Web/Admin 仍为 `deferred`；目标环境真实接口、积分、训练、翻唱与成品播放闭环通过前，不进入发布完成状态。
