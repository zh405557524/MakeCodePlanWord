# CHG-20260926-REVIEW 练习完成评价邀请

状态：done（本地实现、针对性验证）。13 Flutter / 14 Java 工程规则已加载；发布与真实商店验收 pending，其他任务和脏改动保留。

## 已批准需求与 Product Review

首次：上线后完整练习 10 次，跨 7 个非连续练习日。第二次：至少 90 天且新增 5 次完整练习。最多 2 次，账号跨设备同步；游客按设备保存。旧历史、中止、新手教学不计入。不按高分筛选。在完成结果确认返回后的稳定节点请求原生评价，再练/错题重练跳过。设置提供我已评价不再提醒、不再邀请评价，均永久停止。商店无提交回执，只记录请求。以上用户已全部确认，无待决事项；外部 PRD 保持产品基线，本文件是用户新批准的增量契约和 Review，不复制外部资料。

## 技术契约与最小改动

Flutter 新 services/review_prompt 模块：原生 adapter、账号隔离持久化、幂等请求、游客合并；Global 注册；现有设置行增加入口，三种 ARB。模型新增 reviewEligible/practiceDay/reviewCompletedAt（冻结 UTC 完成时间），通过完成记录 payload 同步。稳定会话 ID 去重；识谱完成/挑战、和弦完成、歌曲结果返回传入当前记录。新手/中断和重开结果不能触发。账号/页面迟到响应保护。登录需联网且完成同步；不补弹离线历史。

后端 app/solfeggio/reviewprompt：GET /api/v1/review-prompt/state；POST /claim（recordId、idempotencyKey）；POST /suppress（REVIEWED/OPT_OUT）；POST /merge（游客事件、停止原因）。全部鉴权，X-App-Code=solfeggio；用户级事务锁、资格校验、唯一事件键和跨设备并发限制。状态额外返回 eligible，由服务端时间与所有设备的完成记录计算；第二次只累计最近请求之后实际完成的练习，旧离线记录晚同步不能冒充新增练习。停止只升级不可恢复；本机停止先持久化，失败待同步。

数据库改动：新增 solfeggio_review_prompt_states 和 solfeggio_review_prompt_events；user_id 唯一状态及 user_id/event_key 唯一事件；保存次数、最近请求时间、当时完成次数、停止原因。扩展未发布活动迁移 V3.3，保留账号绑定段和已冻结迁移。账号删除补专属表清理。

## 顺序、测试与回滚

完成标记与同步 -> 后端表/接口 -> Flutter 原生及设置 -> 针对性验证。阈值、90 天、5 次、上限、重复保存/同步/结果重开、中途退出/保存失败、游客合并去重、双设备并发、跨 App、主动停止、离线/迟到/原生异常必须覆盖。Flutter analyze、针对性 Flutter/Java 测试、迁移验证及 iOS 模拟器构建。真实商店展示、提交、双真机验证单列未验证，不以测试回调替代。

回滚：撤回调用和接口，保留停止/请求事实，不删除练习数据或重置次数。不部署、不覆盖其他工作。


## 本地完成记录

已落地上述模块、四种练习路径、同步、设置入口、英文/简体/繁体文案和活动 V3.3 迁移。游客设备状态独立于本地档案，保留稳定邀请事件，登录合并不删除设备事实；服务端按账号/事件去重。次数、UTC 完成时间和日期跨升级持久化。手动停止先落盘，再同步账号，不依赖整份偏好覆盖保存。

验证与待验收证据：[评价邀请验证记录](../05-联调与测试/review-invitation-2026-09-26.md)。110 项针对性 Flutter 用例、16 项 Java 用例通过；Flutter 静态分析没有 error，既有 warning/info 单列。iOS 模拟器与 Android Debug 原生插件构建通过。本轮未发布、未更改正式数据库；正式 flyway-check 因 SSH 认证失败不能取得最新状态，真实商店显示/提交与两台真实设备仍待验收。

产品需求独立登记：[评价邀请需求增量](../01-需求/review-invitation.md)。


## CHG-20260926-REVIEW-TEST 测试开关

用户已授权，Flutter 编码 done（本地实现与验证）。Global.reviewPromptTestEnabled 默认 false；true 时成功保存当前完整练习并确认返回后直接请求原生评价，跳过正式频率、停止和联网领取，不消耗正式邀请次数。成功保存、稳定页面、原生可用、重复事件和迟到保护保留。关闭恢复原规则；无法强制商店绕过系统展示配额。最小代码范围：Global、review_prompt index/service 与针对性测试。

本轮 21 项评价 Service 测试通过（新增：游客/账号绕过资格且不改正式状态、保留有效完成与页面/平台检查）；静态分析无 error，4 项既有 warning/info。启用方式：Global.reviewPromptTestEnabled = true，重启 App；设回 false 恢复正式策略。未发布，未将测试请求称为实际显示或已评价。
