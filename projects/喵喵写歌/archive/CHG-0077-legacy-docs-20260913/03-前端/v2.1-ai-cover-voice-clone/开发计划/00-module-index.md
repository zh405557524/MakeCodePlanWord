# V2.1 Flutter/Web 模块开发索引

> 版本：`v2.1-ai-cover-voice-clone`
> 变更：`CHG-0073`
> 状态：`waiting_review`
> 实现策略：`skeleton_first`
> 当前实现阶段：`real_review`
> 骨架目标：Flutter App 与 Java；Web/Admin `deferred`
> 总体计划：`../flutter-dev-plan.md`
> 视觉真源：Figma 通道 `p354jft5`，文件「working」，页面 `working (91:106)`

## 1. 目标与边界

本目录是 V2.1「翻唱声音克隆」进入 Flutter App 与 Flutter Web/Admin 编码前的唯一模块级输入。现有 AI 写歌和 AI 改编保持原样；旧 `v1.1-ai-cover` 文档仅用于差异核对。

Flutter App 已按本索引完成 `-R` 真实实现和本地验证；Web/Admin 本轮仍不编码。部署环境、真实厂家任务、付费结算和成品可播放闭环进入联调验收，不以本地编译结果替代。

## 2. 模块顺序

| 顺序 | 文档 | 骨架任务 | 真实任务 | 依赖 | 当前状态 |
|------|------|----------|----------|------|----------|
| 01 | `01-contract-model-store.md` | T-F001-S | T-F001-R | Java 契约 | done |
| 02 | `02-home-route-entry.md` | T-F002-S | T-F002-R | 01 | done |
| 03 | `03-voice-cover-main-settings.md` | T-F003-S | T-F003-R | 01、Java 配置 | done |
| 04 | `04-voice-profile-official-voice.md` | T-F004-S | T-F004-R | 01 | done |
| 05 | `05-record-file-video-trim.md` | T-F005-S 媒体 UI | T-F005-R 媒体能力 | 04 | done |
| 06 | `06-material-upload-moderation.md` | T-F005-S 状态 UI | T-F005-R 上传审核 | 05、Java 素材 | done |
| 07 | `07-voice-training.md` | T-F006-S | T-F006-R | 01、06、Java 训练 | done |
| 08 | `08-voice-cover-generation.md` | T-F007-S | T-F007-R | 03、Java 翻唱 | done |
| 09 | `09-works-player-regenerate.md` | T-F008-S | T-F008-R | 08、现有播放器 | done |
| 10 | `10-membership-points-draft-recovery.md` | T-F009-S | T-F009-R | 01-09 | done |
| 11 | `11-admin-navigation-model-pricing.md` | T-W001-S、T-W002-S | T-W001-R、T-W002-R | Java Admin | deferred |
| 12 | `12-admin-voice-moderation.md` | T-W003-S-T-W005-S | T-W003-R-T-W005-R | Java 音色/审核 | deferred |
| 13 | `13-admin-tasks-works-resources.md` | T-W006-S、T-W007-S | T-W006-R、T-W007-R | Java 任务/作品/资源 | deferred |
| 14 | `14-flutter-admin-validation.md` | T-F010-S；T-W008-S deferred | T-F010-R；T-W008-R deferred | 全部模块 | waiting_review（部署联调） |

## 3. 依赖图

```text
01 契约
  ├─ 02 首页入口
  ├─ 03 翻唱主页与设置 ── 08 翻唱任务 ── 09 作品/播放器
  └─ 04 音色资料 ── 05 媒体采集 ── 06 上传审核 ── 07 音色训练

01-09 ── 10 会员/积分/草稿恢复
Java Admin ── 11 模型价格 ── 12 音色审核 ── 13 任务作品资源
全部模块 ── 14 验证
```

## 4. 全局实现约束

- App 新业务目录固定为 `lib/pages/song_voice_cover/`，不得复用 `pages/song_cover/` 的 Controller 或业务模型。
- 创建翻唱只调用 `/api/song-voice-covers`，请求不得包含 `mode`；`provider/model` 必须是后端模型选项返回的真实厂家值。
- P12 复用现有 `SongPlayerPage`，不创建新结果页，不重做播放器布局。
- 资源、审核、价格、积分、音色可用性、任务终态和作品生命周期均以后端为真源。
- 平台排队阶段不显示 10 分钟倒计时；只使用服务端 `deadlineAt`。
- 所有异步区块具备 loading、empty、content、error、retry；禁用按钮必须显示首个阻断原因。
- 375x812 为主验收，390x844、414x896 抽查；固定按钮避让安全区、键盘、底部导航和迷你播放器。
- App 切换、账号切换、退出登录和隐私撤回不得遗留另一 App/账号的草稿、试听或请求结果。

## 5. 编码恢复规则

1. 编码前读取本索引、目标模块文档、同版本技术文档和对应 Java 模块文档。
2. Flutter/Java 骨架已经用户确认，真实实现已经完成本地编码；Web/Admin 任务继续保持 `deferred`。
3. 当前进入 `real_review`，不得把部署缺口或真实 Provider 未执行写成通过。
4. 页面或接口与文档不一致时先登记 CHG 并回卷文档，不在代码中静默改契约。
5. Flutter/Java 所有 `-S` 完成后统一进入 `skeleton_review`，输出代码地图、调用图、固定数据和 TODO 清单并停止。
6. 只有用户明确确认“骨架已确认，开始真实实现”后才能执行 `-R`；“继续/下一步”不解除门禁。
7. Mock、接口 200 或任务成功字段不等于真实播放通过；真实联调与 QA 只在 `-R` 后执行。

## 7. 真实实现记录

- Flutter 基线：`dev @ a57551c8`，保留进入任务前已有未提交修改。
- 已完成独立 API、模型、Store、首页入口、翻唱主页、本人/官方音色、录音/文件/视频素材、1-5 分钟截取、上传审核、训练、翻唱、任务恢复、作品标签和现有播放器复用。
- `flutter analyze` 通过；`test/song_voice_cover_models_test.dart` 7 项通过；Android Debug APK 与 iOS no-codesign Debug 构建通过。
- 已在 iOS Simulator 验收 375x812 主页面、音色资料页、设置、作品来源、官方音色空态和授权勾选；Android 真机安装被设备用户拒绝，未形成 Android 页面通过结论。
- 当前部署服务未开放 V2.1 接口，页面可正确显示配置/资源错误，但真实上传、训练、积分与成品播放仍待部署后联调。

## 6. 总体验收

- 15 份模块文档齐全，每个 T-F/T-W 任务均有 `-S/-R` 映射，Web/Admin 明确 `deferred`。
- P01-P12、W01-W12 均有入口、状态、接口、异常、返回和下一跳说明。
- Figma 38 个 Frame 全部映射到模块或明确由现有页面复用。
- 前后端契约名称一致，未新增未经技术方案确认的接口或字段。
- 旧 AI 写歌、AI 改编和现有播放器列入回归边界。
