# 10 我的、反馈、设置与账号安全

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| PROFILE-001 | 我的 | 未登录我的页结构正确 | android | P1 | normal | 已清除登录态但保留隐私同意 | U-FRESH | 1. 点击我的 | 显示立即登录、积分/会员入口和当前公共菜单；私有数据不伪造 | 不读取私有资产 | 页面截图、UI XML | assisted |  | profile,guest |
| PROFILE-002 | 我的 | 已登录我的页主要菜单完整 | both | P0 | normal | U-NORMAL 已登录 | U-NORMAL | 1. 点击我的<br>2. 向上滚动菜单 | 首屏显示积分福利、积分充值、订单列表、积分明细、邀请好友、联系客服和意见反馈；滚动后可见更多设置 | 读取当前用户资料、积分和权益 | Android/iOS 首屏与滚动后截图、UI XML | automated | profile_layout | smoke,profile |
| PROFILE-003 | 我的 | 用户头像名称和手机号展示正确 | both | P1 | normal | 注册用户已登录 | U-NORMAL | 1. 打开我的 | 头像/占位、昵称或脱敏手机号与账号对应；不显示完整敏感手机号 | 用户资料属于当前 appCode | 页面截图 | manual |  | profile,identity |
| PROFILE-004 | 我的 | 下拉刷新更新积分和会员状态 | both | P1 | normal | 我的页已打开 | 后台调整测试账号资产 | 1. 记录当前状态<br>2. 下拉刷新 | 余额和会员状态更新；页面不闪成错误账号 | 重新读取当前用户 profile | 刷新前后截图 | assisted |  | profile,refresh |
| PROFILE-005 | 我的 | 未登录点击私有菜单统一进入登录 | both | P0 | normal | 未登录 | U-FRESH | 1. 点击积分充值<br>2. 返回并点击订单列表<br>3. 返回并点击积分明细 | 每个入口都进入登录；返回关系正确 | 无私有数据和订单查询结果展示 | 各入口截图 | manual |  | profile,auth |
| PROFILE-006 | 我的 | 游客点击注册专属菜单提示绑定 | ios | P0 | normal | U-GUEST-IOS 已登录 | 游客账号 | 1. 点击积分福利<br>2. 点击邀请好友 | 显示绑定手机号后使用；提供可达绑定入口 | 不创建任务或邀请关系 | 门禁提示截图 | manual |  | profile,ios,guest |
| PROFILE-007 | 我的 | PRO 卡根据会员状态变化 | both | P1 | normal | U-NORMAL 与 U-VIP | 两个账号 | 1. 分别登录两个账号<br>2. 查看会员卡 | 非会员显示开通入口；会员显示有效状态/有效期；点击均进入会员页 | 权益状态与账号一致 | 两账号截图 | manual |  | profile,membership |
| PROFILE-008 | 我的 | 联系客服入口有明确反馈 | both | P1 | external | 后台配置客服链接或未配置 | 客服配置 | 1. 点击联系客服 | 有配置时打开对应客服；未配置时显示明确提示，不无反应 | 只读取客服配置 | 结果截图 | manual |  | profile,support |
| PROFILE-009 | 意见反馈 | 反馈页面结构完整 | both | P1 | normal | 可进入我的 | 无 | 1. 点击意见反馈 | 显示反馈内容、联系方式等当前字段和提交按钮 | 无反馈记录 | 页面截图 | manual |  | feedback,layout |
| PROFILE-010 | 意见反馈 | 空反馈不能提交 | both | P1 | normal | 反馈页 | 空内容 | 1. 点击提交 | 显示必填提示；停留页面 | 无反馈记录 | 提示截图 | manual |  | feedback,validation |
| PROFILE-011 | 意见反馈 | 合法反馈提交成功 | both | P0 | normal | U-NORMAL 已登录或当前允许匿名 | `AUTOTEST_反馈内容` | 1. 输入反馈内容<br>2. 输入合法联系方式<br>3. 点击提交 | 显示提交成功；防止重复点击；按当前规则返回/清空 | 创建一条反馈，敏感信息脱敏存储/展示 | 成功提示、反馈编号 | assisted |  | feedback,submit |
| PROFILE-012 | 意见反馈 | 反馈网络失败保留输入 | both | P1 | normal | 已输入反馈，模拟断网 | 测试反馈 | 1. 点击提交<br>2. 恢复网络<br>3. 再次提交 | 首次提示失败且内容保留；重试成功 | 首次无记录或失败记录不重复，最终一条 | 失败和成功截图 | manual |  | feedback,network |
| PROFILE-013 | 我的 | 每个菜单返回后仍停留我的 Tab | both | P1 | normal | U-NORMAL 已登录 | 菜单列表 | 1. 依次进入订单、积分、反馈和设置<br>2. 每次点击返回 | 返回我的页且滚动/Tab 状态合理；不跳首页或旧页面 | 无额外业务写入 | 返回后截图 | manual |  | profile,navigation |
| PROFILE-014 | 更多设置 | 从我的进入更多设置 | both | P0 | normal | 已进入我的 | 无 | 1. 若入口不在首屏则向上滚动<br>2. 点击更多设置 | 打开设置页，显示协议、隐私、版本、缓存和登录态相关操作 | 读取版本/静态配置 | Android/iOS 设置页截图、UI XML | automated | open_settings | smoke,settings |
| SETTINGS-001 | 更多设置 | 用户协议可打开并返回 | both | P1 | normal | 设置页 | 后台用户协议 | 1. 点击用户协议<br>2. 等待加载<br>3. 返回 | 正文可读；返回设置页 | 只读取静态页面 | 协议和返回截图 | manual |  | settings,agreement |
| SETTINGS-002 | 更多设置 | 隐私政策可打开并返回 | both | P1 | normal | 设置页 | 后台隐私政策 | 1. 点击隐私政策<br>2. 等待加载<br>3. 返回 | 正文可读；返回设置页 | 只读取静态页面 | 政策和返回截图 | manual |  | settings,privacy |
| SETTINGS-003 | 更多设置 | 算法备案页面可打开 | both | P2 | normal | 设置页配置入口可见 | 算法备案 URL | 1. 点击算法备案 | 页面或外部浏览器打开合法地址；失败时提示 | 不写业务数据 | 页面截图 | manual |  | settings,algorithm |
| SETTINGS-004 | 更多设置 | 当前版本号与安装包一致 | both | P0 | normal | 设置页 | 1.2.0+121 | 1. 查看当前版本 | 页面显示版本信息与实际安装包一致，不继续显示旧 1.1.0 | 无业务写入 | 设置页和系统包版本截图 | manual |  | settings,version |
| SETTINGS-005 | 更多设置 | 手动检查更新反馈明确 | both | P1 | external | 后台无更新或有更新 | 两种版本配置 | 1. 点击检查更新 | 无更新时提示已是最新；有更新时显示对应更新弹层 | 读取 catsinger 版本配置 | 两种结果截图 | assisted |  | settings,update |
| SETTINGS-006 | 缓存 | 清理缓存后数值更新且作品仍可用 | both | P1 | delete | 已播放/下载产生缓存 | U-NORMAL | 1. 记录缓存大小<br>2. 点击清理缓存<br>3. 确认<br>4. 打开作品播放 | 缓存数值降低；账号、作品和服务端资源不被删除；音频可重新加载 | 不删除业务作品 | 前后缓存和播放器截图 | manual |  | settings,cache |
| SETTINGS-007 | 缓存 | 取消清理缓存不改变数据 | both | P2 | normal | 有缓存 | 无 | 1. 点击清理缓存<br>2. 在确认框取消 | 缓存大小不变；设置页保持 | 无删除行为 | 确认框和取消后截图 | manual |  | settings,cache,cancel |
| SETTINGS-008 | 缓存 | 修改缓存上限即时显示 | both | P1 | normal | 设置页 | 不同缓存上限 | 1. 点击缓存上限<br>2. 选择新值<br>3. 重新进入设置 | 选择值即时更新并在重进后保持；不会删除业务数据 | 无服务端写入 | 选择前后截图 | manual |  | settings,cache-limit |
| SETTINGS-009 | 更多设置 | 已登录注册用户显示账号与安全 | both | P0 | normal | U-NORMAL 已登录 | 注册账号 | 1. 打开设置 | 显示账号与安全和退出登录；不显示游客绑定入口 | 用户状态识别为 registered | 设置页截图 | manual |  | settings,registered |
| SETTINGS-010 | 更多设置 | iOS 游客显示可选绑定手机号 | ios | P0 | normal | U-GUEST-IOS 已登录 | 游客账号 | 1. 打开设置 | 显示绑定手机号（可选）、恢复购买和退出登录；不显示注册账号安全入口 | 用户状态识别为 guest | 设置页截图 | manual |  | settings,ios,guest |
| SETTINGS-011 | 退出登录 | 取消退出保留当前会话 | both | P1 | normal | 已登录 | U-NORMAL | 1. 点击退出登录<br>2. 取消确认 | 仍在设置或我的；资产和作品可访问 | Token 保持有效 | 取消前后截图 | manual |  | settings,logout,cancel |
| SETTINGS-012 | 退出登录 | 确认退出回首页并清会话 | both | P0 | normal | 已登录 | U-NORMAL | 1. 点击退出登录<br>2. 确认<br>3. 点击作品 | 回到首页；作品要求登录；播放器私有状态清理 | Token/刷新凭据按策略失效 | 退出前后截图 | assisted |  | settings,logout |
| SECURITY-001 | 账号安全 | 注册账号进入账号与安全 | both | P0 | normal | U-NORMAL 已登录 | 注册账号 | 1. 点击账号与安全 | 显示绑定手机号/账号信息和注销账号等当前安全操作 | 查询当前账号安全状态 | 页面截图 | manual |  | security,entry |
| SECURITY-002 | 账号注销 | 注销前展示不可逆说明和短信校验 | both | P0 | account_delete | U-DISPOSABLE 已登录 | 一次性账号 | 1. 点击注销账号 | 显示数据影响、不可恢复说明和验证码要求；默认不直接注销 | 未创建注销动作 | 注销说明截图 | manual |  | account-delete,confirm |
| SECURITY-003 | 账号注销 | 错误验证码不能注销 | both | P0 | account_delete | 注销确认页 | 错误验证码 | 1. 输入错误验证码<br>2. 确认注销 | 显示验证失败；仍可登录；数据保留 | 用户状态不变 | 提示和重新进入截图 | manual |  | account-delete,validation |
| SECURITY-004 | 账号注销 | 取消注销保留账号数据 | both | P0 | account_delete | 注销最终确认已显示 | U-DISPOSABLE | 1. 点击取消 | 返回账号安全；作品、积分和订单仍可查看 | 无注销记录或状态变化 | 取消后截图 | manual |  | account-delete,cancel |
| SECURITY-005 | 账号注销 | 一次性账号确认注销闭环 | both | P0 | account_delete | 测试环境、U-DISPOSABLE、无需保留数据 | 正确验证码 | 1. 输入正确验证码<br>2. 确认最终注销<br>3. 尝试重新访问作品<br>4. 尝试原凭证登录 | 显示注销完成并退出；私有入口需登录；原账号按规则不可继续使用 | 用户注销状态、Token、资料和业务数据按规则处理且可审计 | 全流程截图、脱敏用户 ID | manual |  | account-delete,destructive |
| SECURITY-006 | 账号注销 | 重复注销请求不产生异常数据 | both | P1 | account_delete | U-DISPOSABLE 已完成注销 | 原手机号/验证码 | 1. 再次尝试原会话操作或登录 | 显示账号不可用/按产品规则重新注册；不恢复已注销私有数据 | 注销动作幂等，无重复清算 | 提示截图、脱敏审计号 | manual |  | account-delete,idempotent |
