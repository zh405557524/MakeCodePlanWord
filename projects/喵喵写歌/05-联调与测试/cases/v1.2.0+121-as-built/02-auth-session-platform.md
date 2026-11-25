# 02 登录、会话与平台账号

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AUTH-001 | 登录门禁 | 未登录进入作品时跳转登录 | both | P0 | normal | 已同意隐私，未登录 | U-FRESH | 1. 点击底部“作品” | 不展示他人作品；进入登录页；返回后回到首页 | 不创建匿名作品会话 | 登录页截图 | assisted |  | auth,gate |
| AUTH-002 | 登录门禁 | 未登录点击 AI 写歌时跳转登录 | both | P0 | normal | 已同意隐私，未登录 | U-FRESH | 1. 点击首页“AI写歌” | 进入登录页；登录完成后可重新进入创作，不自动提交 | 无生成任务 | 登录页截图 | assisted |  | auth,create |
| AUTH-003 | 手机登录 | 非法手机号不能发送验证码 | both | P1 | normal | 在手机号登录页 | `12345` | 1. 输入非法手机号<br>2. 点击获取验证码 | 显示手机号格式错误；验证码按钮不进入倒计时 | 不创建短信码 | 错误提示截图 | manual |  | auth,validation |
| AUTH-004 | 手机登录 | 未勾选协议不能登录 | both | P0 | normal | 手机号和验证码正确 | U-NORMAL | 1. 输入手机号<br>2. 输入验证码<br>3. 保持协议未勾选<br>4. 点击登录 | 显示需同意协议的提示；停留登录页 | 不签发 Token | 提示截图 | manual |  | auth,agreement |
| AUTH-005 | 手机登录 | 获取验证码成功 | both | P0 | external | 测试短信方案可用 | U-NORMAL 手机号 | 1. 输入手机号<br>2. 点击获取验证码 | 显示发送成功并开始倒计时；手机号输入状态正确 | 当前 App 下生成一条有效短信码 | 发送后截图、脱敏短信记录 | assisted |  | auth,sms |
| AUTH-006 | 手机登录 | 验证码倒计时期间不能重复发送 | both | P1 | normal | AUTH-005 已执行 | 同一手机号 | 1. 倒计时期间再次点击验证码按钮 | 不重复发送；按钮显示剩余秒数 | 短信记录不重复增加 | 倒计时截图 | manual |  | auth,sms,idempotent |
| AUTH-007 | 手机登录 | 错误验证码登录失败 | both | P0 | normal | 已获取验证码 | 错误验证码 `000000` | 1. 输入错误验证码<br>2. 勾选协议<br>3. 点击登录 | 显示验证码错误；仍在登录页；可重新输入 | 不签发 Token | 错误提示截图 | manual |  | auth,error |
| AUTH-008 | 手机登录 | 验证码过期后登录失败 | both | P1 | normal | 已准备过期验证码 | 过期短信码 | 1. 输入过期验证码<br>2. 勾选协议<br>3. 点击登录 | 显示验证码失效并允许重新获取 | 不签发 Token；旧码不可复用 | 提示截图 | assisted |  | auth,expired |
| AUTH-009 | 手机登录 | 注册用户登录成功 | both | P0 | normal | 已同意协议 | U-NORMAL | 1. 输入正确手机号<br>2. 输入正确验证码<br>3. 勾选协议<br>4. 点击登录 | 返回首页或来源页；“我的”显示该账号资产；作品为该账号数据 | 当前 catsinger 用户会话有效 | 登录后首页、我的截图 | assisted |  | auth,success |
| AUTH-010 | 手机登录 | 快速重复点击登录不产生重复会话 | both | P1 | normal | 正确登录数据已填 | U-NORMAL | 1. 连续点击登录按钮多次 | 按钮进入处理中；只完成一次跳转；不出现多层首页 | 只建立有效会话，不重复注册用户 | 操作录像或连续截图 | manual |  | auth,idempotent |
| AUTH-011 | 手机登录 | 登录网络失败可重试 | both | P1 | normal | 登录页，模拟断网 | U-NORMAL | 1. 断开网络<br>2. 点击登录<br>3. 恢复网络<br>4. 再次点击登录 | 失败时有可读提示且输入不丢失；恢复后可成功登录 | 首次无 Token，重试建立会话 | 失败和成功截图 | manual |  | auth,network |
| AUTH-012 | 会话 | Token 过期后引导重新登录 | both | P0 | normal | 登录 Token 已过期 | U-NORMAL | 1. 打开作品或积分页 | 不展示旧私有数据；跳转登录或完成刷新；失败时提示重新登录 | 过期 Token 被拒绝，不跨账号返回数据 | 登录页截图、脱敏日志 | assisted |  | auth,token |
| AUTH-013 | 会话 | 刷新 Token 后保持来源页面 | both | P1 | normal | Access Token 过期、Refresh Token 有效 | U-NORMAL | 1. 在作品页触发刷新<br>2. 等待请求完成 | 用户无感刷新或短暂加载；仍在作品页；列表正常 | 刷新后的 Token 仍属于 catsinger 和当前用户 | 作品页截图、脱敏日志 | assisted |  | auth,refresh |
| AUTH-014 | 会话 | 取消登录返回原入口 | both | P1 | normal | 从首页创作入口进入登录 | U-FRESH | 1. 点击返回 | 返回首页；不进入空白创作页；底部 Tab 正常 | 无会话和任务创建 | 返回后截图 | manual |  | auth,cancel |
| AUTH-015 | 账号隔离 | 切换账号后不显示前一账号作品 | both | P0 | normal | U-NORMAL 与另一账号均有作品 | 两个注册账号 | 1. 登录账号 A 并记录作品<br>2. 退出登录<br>3. 登录账号 B<br>4. 打开作品 | B 只看到自己的作品；迷你播放器不残留 A 的歌曲 | 用户和作品按 appCode、userId 隔离 | 两账号作品截图 | assisted |  | auth,isolation |
| AUTH-ANDROID-001 | Android 登录 | 一键登录可用时完成登录 | android | P1 | external | Android 测试卡和一键登录配置可用 | 测试手机号 | 1. 进入登录页<br>2. 同意协议<br>3. 点击本机号码登录 | 登录成功；手机号按隐私规则遮罩；进入来源页面 | 当前 App 建立该手机号会话 | 授权页和登录后截图 | manual |  | android,one-tap |
| AUTH-ANDROID-002 | Android 登录 | 一键登录不可用时可切手机号登录 | android | P0 | normal | 无 SIM 或一键登录初始化失败 | U-NORMAL | 1. 进入登录页<br>2. 点击其他手机号登录 | 进入手机号和验证码表单；页面不持续卡在检测中 | 不产生错误用户 | 手机登录页截图 | manual |  | android,fallback |
| AUTH-IOS-001 | iOS 登录 | iOS 登录方式选择完整 | ios | P0 | normal | iOS 未登录 | 无 | 1. 进入登录页 | 显示游客登录、手机号登录；恢复购买在当前设计位置可达 | 未选择前不创建会话 | iOS 登录页截图 | manual |  | ios,auth |
| AUTH-IOS-002 | iOS 游客 | 新用户游客登录成功 | ios | P0 | normal | 新设备、无历史游客凭证 | U-GUEST-IOS | 1. 点击游客登录<br>2. 完成必要协议确认 | 获得真实游客会话并进入首页；“我的”显示游客状态和积分 | 新建 catsinger 游客用户，注册奖励只发一次 | 首页和我的截图 | manual |  | ios,guest |
| AUTH-IOS-003 | iOS 游客 | 同一设备重新游客登录恢复原账号 | ios | P0 | normal | 已存在游客账号并退出 | U-GUEST-IOS | 1. 重新进入登录页<br>2. 点击游客登录<br>3. 打开作品 | 恢复原游客身份、积分和作品，不创建新的空账号 | 设备游客标识映射到原用户 | 退出前后资产截图 | manual |  | ios,guest,recovery |
| AUTH-IOS-004 | iOS 游客绑定 | 游客绑定未注册手机号成功 | ios | P0 | normal | 游客已登录 | 未注册测试手机号 | 1. 打开更多设置<br>2. 点击绑定手机号<br>3. 输入手机号和验证码<br>4. 确认绑定 | 账号转为注册状态；积分、会员和作品保留；注册功能可进入 | 原 userId 或业务资产按方案保留，手机号建立绑定 | 绑定前后我的和作品截图 | manual |  | ios,guest,bind |
| AUTH-IOS-005 | iOS 游客绑定 | 游客不能绑定已注册手机号 | ios | P1 | normal | 游客已登录 | 已属于另一用户的手机号 | 1. 发起绑定<br>2. 输入已注册手机号和验证码<br>3. 确认 | 显示该手机号不可绑定或需按当前安全流程处理；游客资产不丢失 | 不合并两个用户，不迁移他人资产 | 提示和游客资产截图 | manual |  | ios,guest,conflict |
| AUTH-IOS-006 | iOS 游客门禁 | 游客进入注册专属功能时提示绑定 | ios | P0 | normal | 游客已登录 | U-GUEST-IOS | 1. 打开积分福利、兑换码或邀请入口 | 不直接进入注册专属页面；提示“绑定手机号后使用”并提供绑定入口 | 不创建任务、邀请或兑换记录 | 门禁提示截图 | manual |  | ios,guest,gate |
| AUTH-IOS-007 | iOS 登录 | iOS 手机号登录成功 | ios | P0 | normal | 注册账号可用 | U-NORMAL | 1. 选择手机号登录<br>2. 输入正确数据<br>3. 勾选协议<br>4. 点击登录 | 登录成功；资产和作品正确 | 建立注册用户会话 | 登录后截图 | manual |  | ios,phone |
| AUTH-IOS-008 | iOS 恢复购买 | 登录页可发起恢复购买 | ios | P1 | external | Apple Sandbox 有历史订阅 | Sandbox Apple ID | 1. 点击恢复购买<br>2. 完成系统验证 | 页面显示处理中和明确结果；成功后进入/恢复对应账号状态 | 恢复记录幂等，不重复创建权益 | 系统弹层和结果截图 | manual |  | ios,restore |
| AUTH-IOS-009 | iOS 恢复购买 | 恢复订阅不恢复消耗型积分 | ios | P1 | external | 同一 Apple ID 有订阅和积分购买历史 | Sandbox Apple ID | 1. 执行恢复购买<br>2. 查看会员<br>3. 查看积分 | 有效订阅恢复；消耗型积分不因恢复再次到账 | 权益恢复幂等；积分流水无重复入账 | 会员和积分截图 | manual |  | ios,restore,points |
| AUTH-016 | 退出登录 | 退出登录清除私有页面与播放器 | both | P0 | normal | U-NORMAL 已登录并播放歌曲 | U-NORMAL | 1. 进入更多设置<br>2. 点击退出登录<br>3. 确认<br>4. 打开作品 | 回到首页；作品需重新登录；迷你播放器不保留私有歌曲 | 当前 Token/刷新凭据失效 | 退出前后截图 | assisted |  | auth,logout |

