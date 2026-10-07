# MIDI 钢琴练习会员重构技术契约

## 2026-09-26 最终商业定位与体验入口

核心付费价值：连接 MIDI 钢琴，把喜欢的好听曲子完整练会。手机歌曲练习（包括 MIDI 输入）、音符识别、视奏、和弦以及导入/查看/管理，均作为免费辅助功能。

只有非免费歌曲的钢琴模式（mode=piano）检查会员。付费弹窗和会员页都提供可点击的“先体验免费歌曲”：进入 /songs?practice=free，初始只展示现有四首永久免费完整曲目；完整谱面、实时识别与反馈、等待、进度、结果和基础记录均沿用同一练习流程。用户体验后自主开通，不自动购买，也不强制先看套餐。

会员页标题“解锁完整歌曲钢琴练习”，副标题“连接 MIDI 钢琴，把你喜欢的曲子一音一音练会。” 官方普通曲目仍有独立学习等级；会员不替代等级。资源限频对所有账号相同，不能包装成导入付费权益。

未知官方曲目 requiredLevel = max(固定配置默认等级, 目录等级)，不得使用默认0绕过学习等级；固定 key 与显式别名规则优先。服务端开始返回 NEED_LEVEL/NEED_MEMBERSHIP，Flutter 明确停用受限的钢琴会话，网络错误不作为个人授权成功。

本地验收：Flutter96项、Java30项；额外 Flutter→Java HTTP 授权联调1项。见 `../05-联调与测试/midi-practice-membership-2026-09-26.md`。


CHG-20260926-MIDI-PRACTICE / 2026-09-26。依据外部产品真源当前 PRD，用户已授权实施。

## 1. 架构与数据流

Flutter GetX + Hive 本地优先，Java com.soul.service.app.solfeggio + MyBatis + PostgreSQL。拆分内容访问与 MIDI 练习访问。SongSource=OFFICIAL/USER_IMPORT，isFreePractice 是练习属性；旧 accessTier 仅是现有固定配置/API适配，不能被用作内容收费。

- 统一 PracticeAccessManager 产生 ALLOW/NEED_LEVEL/NEED_MEMBERSHIP（内容无效独立 unavailable）。SongAccessPolicy 调用统一判定，并提供 content 判定。
- 内容：可用性→官方免费练习或已达 requiredLevel→免费查看/试听。会员和和弦阶段不影响歌曲内容。
- MIDI：可用性→官方免费歌→普通官方等级→当前有效会员；个人导入不使用 requiredLevel，不信任客户端免费标志。
- 仅 mode=piano 的歌曲钢琴 startSession、详情/分段、直达与续练检查会员。手机歌曲练习（包含 MIDI 输入）、音符识别、视奏、和弦练习免费。会员到期只停止歌曲钢琴模式输入，不影响其他练习。
- 官方服务端曲谱获取仅查内容；创建 PIANO 会话增加会员判定；PHONE 会话及其 MIDI 输入均免费；音符/视奏/和弦亦免费。

## 2. API 契约

统一 ApiResponse 与 X-App-Code: solfeggio；身份使用原 JWT/CurrentUser。

| 方法 | 路径 | 判定/响应 |
|---|---|---|
| GET | /api/v1/songs、/songs/{id} | isUnlocked 只表示等级内容解锁；isFreePractice 与 source=OFFICIAL；普通非会员等级已达 AVAILABLE |
| GET | /api/v1/songs/{id}/arrangements/{arrangementId} | 等级内容检查，不查会员 |
| POST | /api/v1/song-practice/sessions | mode=PIANO：等级→会员；mode=PHONE：等级内容；免费歌直接允许 |
| POST | /api/v1/personal-scores/{scoreId}/practice-access | 无请求体；先校验本人未删 READY 曲谱，再有效会员；data=ALLOW；无权限 FORBIDDEN，他人曲谱 FORBIDDEN(403)，未登录/Token App 不符 401，缺失或已删 404，未就绪 400 |
| GET | /api/v1/personal-scores/{scoreId}、/score-contents/{id}/read-ticket | 保留所有权/内容检查，不查会员 |
| GET | /api/v1/score-imports/eligibility | limit=0 表示不限制保存份数；membershipStatus=NOT_APPLICABLE；所有账号同一资源策略；AVAILABLE/CONCURRENT_LIMIT/HOURLY_LIMIT/DAILY_LIMIT |
| POST | /api/v1/score-imports、/{id}/retry | 登录、文件、幂等、资源频率，不查会员；既有频率事件与故障排除继续 |

个人曲谱 MIDI 开始时调用服务端 practice-access；失败不能静默放行。官方离线练习复用已有有效本地会员与同步等级快照，联网会话按服务端同一规则判断。未知/失效会员不放行。

## 3. 配置、数据库与兼容

数据库改动：无；不修改 Flyway/V3.2，也不迁移或删除已有记录。现有 song-access-policy.json 固定 key/aliases 免费名单保持，requiredChordStage 仅保留适配元数据，歌曲权限不再使用。App 副本须 --check 一致。

score_import.access_policy 改为 shared 资源配置：2 并发、10 次/小时、30 次/自然日，取自旧 member 档，不按会员选择。移除 maxOccupied 商业配额。既有文件大小、任务锁、时区固定及基础设施故障排除不变；返回占用数仅作展示。

## 4. 前后端任务

- T-F014：统一权限、内容状态、个人/官方歌曲钢琴入口、手机 MIDI 免费回归、到期、免费体验入口、三语言文案、Widget/服务/UI 回归。模块：03-前端/开发计划/13-midi-practice-membership.md。
- T-B012：曲库内容与会话分离、个人练习授权、统一资源保护、响应与权限/所有权/接口集成回归。模块：04-后端/开发计划/10-midi-practice-membership.md。

## 5. 验收与风险

六主场景 + 导入多首/到期不删/版权/所有权/直达/续练/手机 MIDI 免费/其他 App 隔离。服务/Widget 自动化与本地接口集成是本地证据；实体琴、实商店购买、真实 OMR 环境需单独明确状态，不把它们写成已验收。不部署、不执行正式数据库脚本。
