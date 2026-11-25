# 09 积分任务、兑换与邀请

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TASK-001 | 积分福利 | 注册用户进入任务中心 | both | P0 | normal | U-NORMAL 已登录 | 后台启用任务 | 1. 从我的点击积分福利 | 显示任务中心、当前积分和启用任务；游客需先绑定 | 读取 catsinger 任务规则和完成状态 | 任务中心截图 | manual |  | task,entry |
| TASK-002 | 每日签到 | 首次签到成功加积分 | both | P0 | paid | 今日未签到 | U-NORMAL | 1. 记录积分<br>2. 点击签到<br>3. 查看积分 | 显示签到成功；积分按规则增加；任务状态变已完成 | 一条签到记录和一条奖励流水 | 前后积分、任务状态、流水 | assisted |  | task,checkin,points |
| TASK-003 | 每日签到 | 当日重复签到不重复奖励 | both | P0 | paid | 今日已签到 | U-NORMAL | 1. 再次点击签到 | 按钮已完成或提示已签到；积分不再增加 | 同日唯一签到记录 | 操作截图、积分流水 | manual |  | task,checkin,idempotent |
| TASK-004 | 每日签到 | 跨日后签到状态重置 | both | P1 | paid | 测试环境切换业务日期 | U-NORMAL | 1. 前一天签到<br>2. 进入下一业务日<br>3. 刷新任务中心 | 新一天可签到；历史奖励不消失 | 新日期生成独立记录 | 两日截图、流水 | assisted |  | task,checkin,date |
| TASK-005 | 任务中心 | 后台停用任务后移动端隐藏 | both | P1 | normal | 某任务当前可见 | 测试任务 | 1. 后台停用任务<br>2. 刷新任务中心 | 停用任务不再展示；其它任务正常 | 不返回停用任务 | 配置前后截图 | assisted |  | task,admin-config |
| TASK-006 | 任务中心 | 任务加载失败可重试 | both | P1 | normal | 模拟网络错误 | 无 | 1. 打开任务中心<br>2. 恢复网络并重试 | 错误提示明确；重试后显示真实状态 | 首次失败、后续成功 | 两阶段截图 | manual |  | task,error |
| TASK-007 | 邀请任务 | 点击邀请任务进入推广素材 | both | P1 | normal | 注册用户、邀请任务启用 | U-NORMAL | 1. 点击去邀请 | 进入邀请/推广素材页面；返回后任务状态可刷新 | 只读取邀请规则 | 素材页截图 | manual |  | task,invite |
| REDEEM-001 | 兑换码 | 注册用户可进入兑换页 | both | P0 | normal | U-NORMAL 已登录 | 无 | 1. 从任务/我的相关入口打开兑换码 | 显示兑换码输入和兑换按钮 | 无兑换记录 | 页面截图 | manual |  | redeem,entry |
| REDEEM-002 | 兑换码 | 有效兑换码成功到账 | both | P0 | paid | 一次性有效兑换码 | VALID-CODE | 1. 输入兑换码<br>2. 点击兑换<br>3. 查看积分明细 | 显示兑换成功；积分或权益按配置到账一次 | 兑换记录标记当前用户，奖励流水一次 | 成功提示、前后资产、兑换码脱敏 | assisted |  | redeem,success |
| REDEEM-003 | 兑换码 | 空兑换码不能提交 | both | P1 | normal | 兑换页 | 空 | 1. 点击兑换 | 按钮不可用或提示请输入兑换码 | 无兑换记录 | 提示截图 | manual |  | redeem,validation |
| REDEEM-004 | 兑换码 | 无效兑换码提示明确 | both | P1 | normal | 兑换页 | INVALID-CODE | 1. 输入无效码<br>2. 点击兑换 | 显示无效或不存在；输入可修改 | 无奖励流水 | 提示截图 | manual |  | redeem,invalid |
| REDEEM-005 | 兑换码 | 过期兑换码不能使用 | both | P1 | normal | 准备过期码 | EXPIRED-CODE | 1. 输入过期码<br>2. 点击兑换 | 显示已过期；资产不变 | 不创建奖励流水 | 提示和资产截图 | assisted |  | redeem,expired |
| REDEEM-006 | 兑换码 | 同一兑换码不能重复使用 | both | P0 | paid | 兑换码已被使用 | USED-CODE | 1. 再次输入同一码<br>2. 点击兑换 | 提示已使用；积分不重复增加 | 唯一兑换记录保持一条 | 提示、积分流水 | assisted |  | redeem,idempotent |
| INVITE-001 | 邀请 | 邀请首页信息完整 | both | P0 | normal | 注册用户已登录 | U-INVITER | 1. 打开邀请入口 | 显示当前已交付的邀请码、邀请人数、素材和规则等入口；不以未交付提现代码骨架作为验收范围 | 返回当前用户邀请概览 | 邀请页截图 | manual |  | invite,overview |
| INVITE-002 | 邀请绑定 | 未绑定用户可输入邀请人邀请码 | both | P0 | normal | U-INVITEE 未绑定 | U-INVITER 邀请码 | 1. 打开绑定邀请人<br>2. 输入邀请码<br>3. 确认 | 显示绑定成功；邀请关系在概览可见 | 建立唯一直接邀请关系 | 成功提示、两账号概览 | assisted |  | invite,bind |
| INVITE-003 | 邀请绑定 | 不能绑定自己的邀请码 | both | P0 | normal | 注册用户未绑定 | 自己的邀请码 | 1. 输入自己的邀请码<br>2. 确认 | 显示不能绑定自己；关系不变 | 不建立自循环关系 | 提示截图 | manual |  | invite,self |
| INVITE-004 | 邀请绑定 | 已绑定后不能更换邀请人 | both | P0 | normal | U-INVITEE 已绑定 | 第二个邀请码 | 1. 再次进入绑定入口<br>2. 尝试提交新邀请码 | 不允许重复/更换；原邀请人保持 | 邀请关系不可变 | 页面和提示截图 | assisted |  | invite,immutable |
| INVITE-005 | 邀请绑定 | 无效邀请码提示明确 | both | P1 | normal | 未绑定用户 | INVALID-INVITE | 1. 输入无效邀请码<br>2. 确认 | 显示邀请码无效；可重新输入 | 不建立关系 | 提示截图 | manual |  | invite,invalid |
| INVITE-006 | 邀请记录 | 邀请记录只显示当前用户邀请链 | both | P0 | normal | U-INVITER 有邀请记录 | 多个被邀请人 | 1. 打开邀请记录<br>2. 滚动列表 | 手机号按规则遮罩；时间、状态正确；无他人记录 | 查询当前邀请人记录 | 列表截图 | manual |  | invite,records |
| INVITE-007 | 邀请收益 | 收益明细金额与来源可理解 | both | P0 | normal | U-INVITER 有收益流水 | 直接/间接收益 | 1. 打开收益明细 | 正负金额、来源、状态和时间可区分；总额与概览一致 | 收益账户和流水一致 | 概览与明细截图 | assisted |  | invite,ledger |
| INVITE-009 | 推广素材 | 推广素材可预览和保存 | both | P1 | external | 后台配置素材 | 海报和文案 | 1. 打开推广素材<br>2. 选择一张海报<br>3. 点击保存/分享 | 预览清晰；按系统权限保存或分享；邀请码对应当前用户 | 只读取素材配置 | 预览、系统结果截图 | manual |  | invite,materials |
| INVITE-010 | 邀请规则 | 规则页面展示当前 App 配置 | both | P1 | normal | 后台配置邀请规则 | catsinger 规则 | 1. 打开邀请规则 | 展示当前已交付的邀请奖励规则；不出现其他 App 文案或未交付提现说明 | 读取 catsinger 规则 | 规则页截图 | manual |  | invite,rules |
