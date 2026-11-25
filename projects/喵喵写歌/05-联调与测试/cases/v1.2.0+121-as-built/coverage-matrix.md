# v1.2.0+121 移动端用户功能覆盖矩阵

> 范围：用户在 Android/iOS App 中可见、可点击或可感知的页面、入口和状态。后端与 Admin 只作为数据准备和观察手段，不作为独立测试对象。

| 页面/能力 | 当前可见入口、按钮或状态 | 关联用例 |
|---|---|---|
| 安装与首次启动 | 首次安装、升级、重装、冷启动、后台恢复、进程恢复 | APP-001、APP-002、APP-003、APP-004、APP-005、APP-006 |
| 首次隐私弹层 | 用户协议、隐私政策、拒绝、同意、遮罩、SDK 初始化边界 | PRIV-001、PRIV-002、PRIV-003、PRIV-004、PRIV-005、PRIV-006、PRIV-007 |
| 隐私撤回 | 设置撤回、再次同意 | PRIV-008、PRIV-009 |
| 版本更新 | 无更新、可选更新、强制更新、错误下载地址 | UPDATE-001、UPDATE-002、UPDATE-003、UPDATE-004 |
| 登录门禁 | 未登录进入作品、AI 写歌、取消登录返回 | AUTH-001、AUTH-002、AUTH-014 |
| 手机号登录 | 手机号、验证码、协议、倒计时、错误和过期验证码、重复提交、网络重试 | AUTH-003、AUTH-004、AUTH-005、AUTH-006、AUTH-007、AUTH-008、AUTH-009、AUTH-010、AUTH-011 |
| 会话恢复 | Token 失效、刷新 Token、切换账号、退出登录 | AUTH-012、AUTH-013、AUTH-015、AUTH-016 |
| Android 登录 | 一键登录、手机号登录兜底 | AUTH-ANDROID-001、AUTH-ANDROID-002 |
| iOS 登录与游客 | 登录方式、游客创建/恢复、绑定手机号、游客门禁、手机号登录 | AUTH-IOS-001、AUTH-IOS-002、AUTH-IOS-003、AUTH-IOS-004、AUTH-IOS-005、AUTH-IOS-006、AUTH-IOS-007 |
| iOS 登录页恢复购买 | 恢复订阅、不恢复消耗型积分 | AUTH-IOS-008、AUTH-IOS-009 |
| 主导航 | 首页、作品、我的三个 Tab，重复点击与 Android 返回 | NAV-001、NAV-002、NAV-003、NAV-004、NAV-005 |
| 首页结构 | 标题、AI 写歌、改编歌曲、热门案例、配置歌曲区域 | HOME-001、HOME-005、HOME-006、HOME-007、HOME-010、HOME-011 |
| 首页创作入口 | AI 写歌、改编歌曲、未登录门禁 | HOME-002、HOME-003、HOME-004 |
| 首页配置歌曲 | 打开播放器、资源缺失、后台上下架、App 配置隔离 | HOME-008、HOME-009、HOME-012、HOME-015、HOME-016 |
| 迷你播放器 | 跨 Tab 显示、点击返回播放器 | HOME-013、HOME-014、PLAYER-005 |
| 创作模式导航 | 简易、专业、歌曲改编切换与返回 | CREATE-002、CREATE-003、CREATE-005、CREATE-006 |
| 简易写歌 | 音乐灵感、空值、长度、随机灵感、换一批、配置降级 | SIMPLE-001、SIMPLE-002、SIMPLE-003、SIMPLE-004、SIMPLE-005、SIMPLE-006 |
| 简易写歌选项 | 男/女声、纯音乐、后台能力开关、场景上下文退出 | SIMPLE-007、SIMPLE-008、SIMPLE-009、SIMPLE-010 |
| 专业写歌基础 | 页面控件、歌名、歌词、歌词编辑、歌手、风格、场景、对象、语言、时长、纯音乐 | CREATE-001、CREATE-004、PROFESSIONAL-001、PROFESSIONAL-002、PROFESSIONAL-003、PROFESSIONAL-004、PROFESSIONAL-009、PROFESSIONAL-010、PROFESSIONAL-011、PROFESSIONAL-012、PROFESSIONAL-013、PROFESSIONAL-014 |
| AI 帮写 | 成功回填、防重复、失败保留、切后台恢复 | PROFESSIONAL-005、PROFESSIONAL-006、PROFESSIONAL-007、PROFESSIONAL-008 |
| 专业参考音频基础 | 作品库、本地文件、大小/时长、截取、录音和权限恢复 | AUDIOREF-001、AUDIOREF-002、AUDIOREF-003、AUDIOREF-004、AUDIOREF-005、AUDIOREF-006、AUDIOREF-007 |
| 专业参考音频生成闭环 | 作品库/本地参考音频随专业任务提交、付费生成、作品播放、删除/更换、失败重试和生成同款回填 | AUDIOREF-008、AUDIOREF-009、AUDIOREF-010、AUDIOREF-011、AUDIOREF-012 |
| 模型选择 | 默认模型、列表、取消、确认、停用、空目录、长名称、场景隔离 | MODEL-001、MODEL-002、MODEL-003、MODEL-004、MODEL-005、MODEL-006、MODEL-007、MODEL-008 |
| 歌曲改编音源 | 页面初态、作品库、空库、不可用作品、本地、录音、删除音源 | ADAPT-001、ADAPT-002、ADAPT-003、ADAPT-004、ADAPT-005、ADAPT-006、ADAPT-007 |
| 歌曲改编提交与成品播放 | 改编要求、歌名、模型价格、处理失败、重复点击、生成终态、持久音频和实际播放门禁 | ADAPT-008、ADAPT-009、ADAPT-010、ADAPT-011、ADAPT-012 |
| AI 翻唱入口与第一步 | 从作品详情进入、页面结构、选作品、版权确认、下一步门禁 | COVER-001、COVER-002、COVER-003、COVER-004、COVER-005、COVER-006、COVER-007 |
| AI 翻唱本地音频 | 合法音频、MP4 兼容、最小时长、最大时长、大小和损坏文件 | COVER-008、COVER-009、COVER-010、COVER-011、COVER-012、COVER-013 |
| AI 翻唱音色 | 分组排序、试听、选择、空音色 | COVER-014、COVER-015、COVER-016、COVER-017 |
| AI 翻唱高级设置 | 保留歌词/伴奏、音高、情感、混响、返回保留 | COVER-018、COVER-019 |
| AI 翻唱提交和结果 | 价格摘要、任务、低积分、失败退款、AB 播放、重新翻唱 | COVER-020、COVER-021、COVER-022、COVER-023、COVER-024、COVER-025 |
| 生成确认 | 取消、价格和模型一致 | GEN-001、GEN-002 |
| 完整生成闭环 | Android 专业写歌无参考音频闭环，以及作品库/本地参考音频闭环 | FLOW-CREATE-001、AUDIOREF-008、AUDIOREF-009 |
| 生成积分与幂等 | 冻结、成功扣减、失败退款、余额不足、连点幂等 | GEN-003、GEN-004、GEN-005、GEN-006、GEN-007 |
| 生成进度 | 六阶段、非终态进度、退出、重新进入、进程恢复 | GEN-008、GEN-009、GEN-010、GEN-011、GEN-012 |
| 生成失败和恢复 | Provider、内容审核、模型失效、断网恢复 | GEN-013、GEN-014、GEN-015、GEN-016 |
| 生成完成 | 打开播放器、作品出现、模型恢复默认、用户隔离 | GEN-017、GEN-018、GEN-019、GEN-020 |
| 我的作品列表 | 页面、空态、开始创作、生成中、轮询、离页停止、失败、完成、刷新、重试、长标题、类型、账号缓存 | WORK-001、WORK-002、WORK-003、WORK-004、WORK-005、WORK-006、WORK-007、WORK-008、WORK-009、WORK-010、WORK-011、WORK-012、WORK-013 |
| 作品更多与详情 | 更多、Prompt/歌词、复制、播放、下载、分享、删除、重新生成 | WORK-014、DETAIL-001、DETAIL-002、DETAIL-003、DETAIL-004、DETAIL-005、DETAIL-006、DETAIL-007、DETAIL-008、DETAIL-009、DETAIL-010 |
| 播放器 | 播放、暂停、拖动、上下首、迷你播放器、常亮 | PLAYER-001、PLAYER-002、PLAYER-003、PLAYER-004、PLAYER-005、PLAYER-006 |
| 歌词 | 静态歌词、逐句时间轴、手动滚动、点击行跳转 | PLAYER-007、PLAYER-008、PLAYER-009、PLAYER-010 |
| 作品后处理 | 时间轴重做、封面重做、同款、重新翻唱 | PLAYER-011、PLAYER-012、PLAYER-013、PLAYER-014、PLAYER-015、PLAYER-016 |
| 专辑操作 | 加入、创建、重复加入、移出 | ALBUM-001、ALBUM-002、ALBUM-003、ALBUM-004 |
| 会员 | 登录门禁、商品、空态、协议、Android 支付、取消、iOS StoreKit、到期 | MEMBER-001、MEMBER-002、MEMBER-003、MEMBER-004、MEMBER-005、MEMBER-006、MEMBER-007、MEMBER-008、MEMBER-009、MEMBER-010 |
| 积分充值 | 商品、两个入口、Android/iOS 支付、重复回调、下架 | POINTS-001、POINTS-002、POINTS-003、POINTS-004、POINTS-005、POINTS-006 |
| 积分明细 | 余额、流水类型、空态 | LEDGER-001、LEDGER-002、LEDGER-003 |
| 订单 | 当前账号、继续付款、取消/返回、已支付、结果恢复、空态 | ORDER-001、ORDER-002、ORDER-003、ORDER-004、ORDER-005、ORDER-006、ORDER-007 |
| 设置恢复购买 | 有效订阅、无可恢复项目 | RESTORE-001、RESTORE-002 |
| 积分任务和签到 | 任务中心、签到、重复、跨日、后台停用、失败重试、邀请任务 | TASK-001、TASK-002、TASK-003、TASK-004、TASK-005、TASK-006、TASK-007 |
| 兑换码 | 入口、成功、空值、无效、过期、重复使用 | REDEEM-001、REDEEM-002、REDEEM-003、REDEEM-004、REDEEM-005、REDEEM-006 |
| 邀请 | 首页、绑定、自邀、换绑、无效码、记录、收益、素材、规则 | INVITE-001、INVITE-002、INVITE-003、INVITE-004、INVITE-005、INVITE-006、INVITE-007、INVITE-009、INVITE-010 |
| 我的页 | 登录态、用户信息、刷新、门禁、游客门禁、PRO、客服、返回保持 Tab | PROFILE-001、PROFILE-002、PROFILE-003、PROFILE-004、PROFILE-005、PROFILE-006、PROFILE-007、PROFILE-008、PROFILE-013 |
| 意见反馈 | 页面、空校验、成功、网络失败保留 | PROFILE-009、PROFILE-010、PROFILE-011、PROFILE-012 |
| 更多设置 | 入口、协议、政策、算法备案、版本、检查更新 | PROFILE-014、SETTINGS-001、SETTINGS-002、SETTINGS-003、SETTINGS-004、SETTINGS-005 |
| 缓存 | 清理、取消、上限设置 | SETTINGS-006、SETTINGS-007、SETTINGS-008 |
| 账号与安全 | 注册账号入口、游客绑定入口 | SETTINGS-009、SETTINGS-010、SECURITY-001 |
| 退出登录 | 取消、确认和清除会话 | SETTINGS-011、SETTINGS-012、AUTH-016 |
| 注销账号 | 说明、短信、错误验证码、取消、成功、重复请求 | SECURITY-002、SECURITY-003、SECURITY-004、SECURITY-005、SECURITY-006 |
| 文件与麦克风权限 | Android 文件权限、iOS 文件取消、录音允许/拒绝 | PERM-001、PERM-002、PERM-003、PERM-004、PERM-005 |
| 下载与分享系统交互 | 保存权限、取消系统分享 | PERM-006、PERM-007 |
| 网络异常 | 启动、首页、作品、播放、提交、支付 | NET-001、NET-002、NET-003、NET-004、NET-005、NET-006 |
| 中断恢复 | 表单后台恢复、音频焦点、完成事件幂等 | STATE-001、STATE-002、STATE-003 |
| 音频和封面资源 | 临时资源持久化、失效反馈、封面缓存更新 | RESOURCE-001、RESOURCE-002、RESOURCE-003、RESOURCE-004 |
| 后台配置联动 | 模型、价格、名称、默认、音色、商品、任务、邀请规则 | CONFIG-001、CONFIG-002、CONFIG-003、CONFIG-004、CONFIG-005、CONFIG-006、CONFIG-007 |
| App 与管理权限隔离 | catsinger 配置不串 App、受限角色不可误改 | CONFIG-008、CONFIG-009、HOME-016 |
| 屏幕与文字适配 | 375x812、390x844、414x896、大字体 | UI-001、UI-002、UI-003、UI-004 |

## 当前不可达功能

- 场景写歌四步：路由和 Controller 存在，但当前首页没有稳定用户入口。只登记产品缺口，不构造正常用户步骤。
- 草稿、喜欢 Tab：作品页代码保留分支，但当前 `visibleValues` 不向用户展示。
- 专辑主 Tab：当前作品页没有主入口，专辑只从作品操作链路验证。
- 旧视频创作页：仍有历史路由和代码，但不属于喵喵写歌当前用户流程。

这些能力在入口恢复前不得作为主链路 PASS 条件；入口变化后必须重新生成代码基线并新增或回卷用例。
