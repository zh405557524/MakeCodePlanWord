# V2.1 移动端覆盖矩阵

| 页面/能力 | 用户可见入口与关键状态 | 用例编号 |
|---|---|---|
| 首次安装、隐私与更新 | 首开、拒绝/同意、冷启、前后台、升级 | V21-START-001, V21-START-002, V21-START-003, V21-START-004, V21-START-005, V21-START-006 |
| Android/iOS 登录 | 手机号、验证码、一键登录、游客、绑定、恢复购买 | V21-AUTH-001, V21-AUTH-002, V21-AUTH-003, V21-AUTH-006, V21-AUTH-007, V21-AUTH-008, V21-AUTH-009 |
| 会话与账户隔离 | Token、换号、退出和私有资源 | V21-AUTH-004, V21-AUTH-005, V21-AUTH-010, V21-WORK-019 |
| P01 首页三业务与主 Tab | AI 写歌、改编、翻唱声音克隆、三 Tab/登录 | V21-HOME-001, V21-HOME-002, V21-HOME-003, V21-SONG-001, V21-ADAPT-001, V21-VOICE-COVER-001 |
| P01 海报轮播 | 自动/手动、目标/静态、单张与失效 | V21-HOME-004, V21-HOME-005, V21-HOME-006 |
| P01 案例歌曲与迷你播放器 | 案例正常/空/失败、配置歌曲与 Tab 间播放 | V21-HOME-007, V21-HOME-008, V21-HOME-009 |
| P01 新人礼与注册赠额 | 建号赠一次、金额改动/回退、弹窗稍后/领取/频次/人群 | V21-GIFT-001, V21-GIFT-002, V21-GIFT-003, V21-GIFT-004, V21-GIFT-005, V21-GIFT-006, V21-GIFT-007, V21-GIFT-008, V21-GROW-006 |
| P02 简易写歌 | 灵感、清空、纯音乐和系统人声 | V21-SONG-002, V21-SONG-003, V21-SONG-004, V21-SONG-005, V21-SONG-016 |
| P03 专业写歌 | 歌名歌词、全屏、润色、系统人声、风格/高级项 | V21-SONG-006, V21-SONG-007, V21-SONG-008, V21-SONG-009, V21-SONG-010, V21-SONG-014, V21-SONG-015 |
| P03 参考音频 | 本人作品、本地、截取、替换和删除 | V21-SONG-011, V21-SONG-012, V21-RESOURCE-007 |
| P03/P04 指定音色延期 | 两业务本期无入口、无 P07 跳转或提交参数 | V21-SONG-013, V21-ADAPT-011, V21-SMOKE-003 |
| P04 改编歌曲与 P06 来源 | 本人作品、本地、相册、空态、损坏与取消 | V21-ADAPT-001, V21-ADAPT-002, V21-ADAPT-003, V21-ADAPT-004, V21-ADAPT-005 |
| P04 歌词和模型 | 保留原词默认关、识别三态、新歌词与动态参数 | V21-ADAPT-006, V21-ADAPT-007, V21-ADAPT-008, V21-ADAPT-009, V21-ADAPT-010 |
| P04 提交及权利 UI | 无勾选、可播放成功和防重复 | V21-ADAPT-012, V21-ADAPT-013, V21-ADAPT-014 |
| P05 翻唱歌曲来源 | 本人作品、本地、视频提取、整曲及模型硬约束 | V21-VOICE-COVER-002, V21-VOICE-COVER-003, V21-VOICE-COVER-004, V21-VOICE-COVER-005, V21-VOICE-COVER-006 |
| P05/P07 翻唱目标音色 | 本人、官方、试听、训练/失败/下架、不兼容 | V21-VOICE-COVER-007, V21-VOICE-COVER-008, V21-VOICE-COVER-009, V21-VOICE-COVER-010 |
| P05 设置和报价 | 已上线动态参数、无权利勾选、会员/积分与实时报价 | V21-VOICE-COVER-011, V21-VOICE-COVER-012, V21-VOICE-COVER-013 |
| P05 翻唱生成和重做 | 本人/官方可播放，失败释放及重新翻唱 | V21-VOICE-COVER-014, V21-VOICE-COVER-015, V21-VOICE-COVER-016, V21-VOICE-COVER-017 |
| P08 资料与本人确认 | 头像昵称本地预览、继续后审核、本人声明和离开 | V21-VOICE-TRAIN-001, V21-VOICE-TRAIN-002, V21-VOICE-TRAIN-003, V21-VOICE-TRAIN-004, V21-VOICE-TRAIN-005 |
| P09 录音与素材 | 五态录音、麦克风、本地/相册、硬限制、删除/审核 | V21-VOICE-TRAIN-006, V21-VOICE-TRAIN-007, V21-VOICE-TRAIN-008, V21-VOICE-TRAIN-009, V21-VOICE-TRAIN-010 |
| P09 本人验证与训练报价 | 验证失败/过期、训练模型、会员和价格 | V21-VOICE-TRAIN-011, V21-VOICE-TRAIN-012 |
| P10 训练任务与音色管理 | 成功可用、失败重训、删除与旧作品 | V21-VOICE-TRAIN-013, V21-VOICE-TRAIN-014, V21-VOICE-TRAIN-015 |
| 模型合同跨三业务 | 场景隔离、支持/不支持、清值、静默默认、主动提醒 | V21-MODEL-001, V21-MODEL-002, V21-MODEL-003, V21-MODEL-004, V21-MODEL-005 |
| 模型未声明及故障 | 最小参数、下架/缺价、后台能力上限 | V21-MODEL-006, V21-MODEL-007, V21-MODEL-008 |
| 本地资源上传前查重 | 命中、最终字节、私有隔离、查询失败、审核、并发 | V21-RESOURCE-001, V21-RESOURCE-002, V21-RESOURCE-003, V21-RESOURCE-004, V21-RESOURCE-005, V21-RESOURCE-006, V21-RESOURCE-007, V21-RESOURCE-008 |
| P11 生成与积分 | 报价、余额/会员、结算/退款、幂等、三业务类型 | V21-GEN-001, V21-GEN-002, V21-GEN-003, V21-GEN-004, V21-GEN-005, V21-GEN-006, V21-GEN-007 |
| P11 进度与成功门槛 | 离页恢复、排队计时、资源持久、五秒播放、失败重试 | V21-GEN-008, V21-GEN-009, V21-GEN-010, V21-GEN-011, V21-GEN-012 |
| P12 作品列表 | 空、生成中、失败、长标题、三业务类型 | V21-WORK-001, V21-WORK-002, V21-WORK-003, V21-WORK-004 |
| P12 详情与操作 | 提示词歌词、下载、分享收藏、删除、再创作、封面/歌词重做、专辑 | V21-WORK-005, V21-WORK-011, V21-WORK-012, V21-WORK-013, V21-WORK-014, V21-WORK-015, V21-WORK-016, V21-WORK-017, V21-WORK-018 |
| P13 现有播放器 | 原创/改编/克隆播放、切曲、静态/时间轴歌词 | V21-WORK-006, V21-WORK-007, V21-WORK-008, V21-WORK-009, V21-WORK-010 |
| 会员/积分/订单 | 商品、Android 支付、iOS Sandbox、充值、明细、继续/取消订单 | V21-PAY-001, V21-PAY-002, V21-PAY-003, V21-PAY-004, V21-PAY-005, V21-PAY-006, V21-PAY-007, V21-PAY-008, V21-PAY-009 |
| 签到、任务、兑换、邀请 | 签到幂等、跨日、兑换码、邀请关系/收益/素材 | V21-GROW-001, V21-GROW-002, V21-GROW-003, V21-GROW-004, V21-GROW-005 |
| 我的、反馈、设置、注销 | 三态资产、菜单、反馈、协议/版本、缓存、账号安全 | V21-PROFILE-001, V21-PROFILE-002, V21-PROFILE-003, V21-PROFILE-004, V21-PROFILE-005, V21-PROFILE-006 |
| 设备权限与网络 | Android/iOS 文件、麦克风、断网、资源失效、后台恢复 | V21-ENV-001, V21-ENV-002, V21-ENV-003, V21-ENV-004, V21-ENV-005, V21-ENV-006, V21-ENV-007 |
| 配置联动与屏幕适配 | App 隔离、动态配置、375/390/414 与大字体 | V21-ENV-008, V21-ENV-009 |
| 双平台只读冒烟 | 启动、导航、三业务、模型、作品播放、新人礼、iOS 门禁 | V21-SMOKE-001, V21-SMOKE-002, V21-SMOKE-003, V21-SMOKE-004, V21-SMOKE-005, V21-SMOKE-006, V21-SMOKE-007, V21-SMOKE-008 |

**不作为 V2.1 可达正向功能**：P03/P04 独立「使用指定音色」音色库路由、旧版三步 AI 翻唱/版权勾选、历史场景写歌四步、旧专辑主 Tab、旧视频创作页，以及尚未交付的提现。代码里留有路由或兼容字段不等于用户能从当前页面进入；若执行时实际出现，应先登记需求与实现差异，不伪造通过。
