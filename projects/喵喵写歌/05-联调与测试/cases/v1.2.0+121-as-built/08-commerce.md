# 08 会员、积分、订单与支付

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MEMBER-001 | 会员 | 未登录点击会员卡进入登录 | both | P0 | normal | 未登录 | U-FRESH | 1. 点击我的<br>2. 点击会员卡 | 进入登录页；不展示他人权益 | 不创建订单 | 登录页截图 | manual |  | membership,auth |
| MEMBER-002 | 会员 | 会员商品正常展示 | both | P0 | normal | U-NORMAL 已登录，后台有商品 | 启用会员商品 | 1. 打开会员页 | 商品名称、价格、周期、权益和默认选中项与后台一致 | 只返回 catsinger 启用商品 | 会员页截图 | manual |  | membership,product |
| MEMBER-003 | 会员 | 会员商品为空时给出明确空态 | both | P1 | normal | 后台停用会员商品 | 空配置 | 1. 打开会员页 | 不出现可误购按钮；显示暂不可购买或空态 | 返回空商品列表 | 空态截图 | assisted |  | membership,empty |
| MEMBER-004 | 会员 | 会员协议未勾选不能付款 | both | P0 | paid | 商品已选择 | 任一会员商品 | 1. 保持协议未勾选<br>2. 点击购买 | 提示需同意协议；不进入支付 | 无订单或按当前策略无可支付订单 | 提示截图 | manual |  | membership,agreement,paid |
| MEMBER-005 | 会员 | 会员协议页面可打开并返回 | both | P1 | normal | 会员页已打开 | 用户协议、自动续费协议 | 1. 点击协议链接<br>2. 阅读<br>3. 返回 | 正文可读；返回后商品选择保持 | 只读取静态页面 | 协议页截图 | manual |  | membership,agreement |
| MEMBER-006 | 会员 | Android 会员支付宝测试支付成功 | android | P0 | paid | 测试支付宝链路可用 | 测试会员商品 | 1. 勾选协议<br>2. 点击购买<br>3. 选择支付宝<br>4. 在测试链路完成付款<br>5. 返回 App | 显示支付成功；我的页会员状态和有效期更新 | 订单 PAID；权益只发一次；回调幂等 | 支付前后截图、订单号 | manual |  | membership,android,alipay |
| MEMBER-007 | 会员 | Android 外部支付取消可回到 App | android | P1 | paid | 已创建待支付订单 | 测试会员商品 | 1. 进入支付宝/Web 支付<br>2. 取消支付<br>3. 返回 App | 显示未完成/已取消；可从订单继续；会员不生效 | 订单保持待支付或取消，无权益 | 返回结果截图、订单号 | manual |  | membership,android,cancel |
| MEMBER-008 | 会员 | iOS StoreKit 沙箱购买会员成功 | ios | P0 | paid | Apple Sandbox 商品有效 | Sandbox Apple ID | 1. 勾选协议<br>2. 点击购买<br>3. 完成系统支付 | 系统购买成功；会员状态更新；重复回调不重复发权益 | Apple 交易绑定当前账号，订单 PAID | 系统弹层、会员页、订单号 | manual |  | membership,ios,storekit |
| MEMBER-009 | 会员 | iOS StoreKit 取消购买不发权益 | ios | P1 | paid | 已拉起 StoreKit | Sandbox 商品 | 1. 在系统支付中取消 | 返回会员页并显示取消/未完成；会员状态不变 | 无已支付订单和新权益 | 返回页截图 | manual |  | membership,ios,cancel |
| MEMBER-010 | 会员 | 会员到期状态显示正确 | both | P1 | normal | 测试账号会员已到期 | U-NORMAL | 1. 打开我的<br>2. 打开会员页 | 不显示有效会员标识或显示已到期；可以重新购买 | 权益状态为过期 | 我的和会员页截图 | assisted |  | membership,expired |
| POINTS-001 | 积分充值 | 积分商品正常展示 | both | P0 | normal | 后台有启用积分商品 | 多档积分商品 | 1. 从我的点击积分充值 | 商品积分数、价格、赠送说明与后台一致 | 返回 catsinger 商品 | 充值页截图 | manual |  | points,product |
| POINTS-002 | 积分充值 | 顶部积分入口和菜单都进入充值页 | both | P1 | normal | 已登录 | U-NORMAL | 1. 点击顶部积分胶囊<br>2. 返回<br>3. 点击积分充值菜单 | 两个入口都进入当前积分充值页 | 只读取商品 | 两次页面截图 | manual |  | points,entry |
| POINTS-003 | 积分充值 | Android 积分支付宝测试支付成功 | android | P0 | paid | 测试支付可用 | 最低积分商品 | 1. 选择商品<br>2. 同意协议<br>3. 完成测试支付宝支付<br>4. 返回 App | 显示成功；积分余额按商品增加一次 | 订单 PAID；积分入账流水一次 | 支付结果、前后余额、订单号 | manual |  | points,android,alipay |
| POINTS-004 | 积分充值 | iOS 消耗型积分购买成功 | ios | P0 | paid | Apple Sandbox 商品有效 | 最低积分商品 | 1. 选择商品<br>2. 完成 StoreKit 购买 | 积分增加一次；订单可查看 | 交易幂等入账；不可通过恢复再次领取 | 系统结果、余额、订单号 | manual |  | points,ios,storekit |
| POINTS-005 | 积分充值 | 支付回调重复不重复加积分 | both | P0 | paid | 测试环境可重放回调 | 已支付测试订单 | 1. 完成一次支付<br>2. 由测试环境重复送达相同回调<br>3. 刷新积分 | 移动端余额不重复增长；订单仍只有一个成功状态 | 同一渠道交易号幂等 | 前后余额、订单号、流水 | assisted |  | points,idempotent |
| POINTS-006 | 积分充值 | 商品下架后旧页面不能继续购买 | both | P1 | paid | 充值页已打开 | 随后停用的商品 | 1. 保持商品页<br>2. 后台停用商品<br>3. 点击购买 | 提示商品不可用并刷新；不按旧价格支付 | 不创建有效订单或订单不可支付 | 提示截图 | assisted |  | points,product,stale |
| LEDGER-001 | 积分明细 | 积分明细入口和余额一致 | both | P0 | normal | U-NORMAL 有流水 | 多种积分流水 | 1. 从我的点击积分明细 | 页面余额与我的一致；流水按时间显示 | 查询当前用户积分账户与流水 | 两页截图 | manual |  | points,ledger |
| LEDGER-002 | 积分明细 | 充值、生成、退款流水文案可区分 | both | P1 | normal | 账号有三种流水 | 充值、扣减、退款 | 1. 打开积分明细<br>2. 查看各类型 | 正负号、金额、业务文案和时间可理解；退款能关联失败业务 | 流水金额与业务记录一致 | 流水截图 | manual |  | points,ledger,type |
| LEDGER-003 | 积分明细 | 空流水显示空态 | both | P1 | normal | 新账号无流水或测试空数据 | 空账号 | 1. 打开积分明细 | 显示空态且余额不为异常负数 | 返回空流水 | 空态截图 | manual |  | points,ledger,empty |
| ORDER-001 | 订单 | 订单列表只显示当前账号订单 | both | P0 | normal | 两个账号都有订单 | U-NORMAL、U-OTHER | 1. 登录账号 A 查看订单<br>2. 切换账号 B 查看订单 | 两账号订单不混合；金额和商品正确 | 订单按 appCode、userId 隔离 | 两账号截图 | assisted |  | orders,isolation |
| ORDER-002 | 订单 | 待支付订单可继续付款 | android | P0 | paid | 有未过期待支付订单 | 测试订单 | 1. 打开订单列表<br>2. 点击继续支付<br>3. 完成测试付款 | 拉起当前支付链路；返回后订单更新为已支付，权益到账 | 复用原订单或按当前规则处理，不重复建权益 | 操作前后截图、订单号 | manual |  | orders,resume |
| ORDER-003 | 订单 | 取消待支付订单 | both | P1 | paid | 有待支付订单 | 测试订单 | 1. 点击取消订单<br>2. 确认 | 状态变为已取消；不能继续付款；不发权益 | 订单取消一次 | 前后状态截图、订单号 | manual |  | orders,cancel |
| ORDER-004 | 订单 | 取消订单时选择返回保留订单 | both | P1 | normal | 有待支付订单 | 测试订单 | 1. 点击取消订单<br>2. 在确认框点击返回 | 订单仍为待支付；可继续付款 | 订单状态未改 | 确认框和列表截图 | manual |  | orders,cancel-dialog |
| ORDER-005 | 订单 | 已支付订单不能再次支付 | both | P0 | paid | 有已支付订单 | PAID-ORDER | 1. 打开订单详情/列表<br>2. 尝试继续支付 | 不显示可重复支付入口或提示已完成；权益不重复 | 已支付状态不可回退 | 订单页截图 | manual |  | orders,paid,idempotent |
| ORDER-006 | 订单 | 支付结果未知时可刷新最终状态 | both | P1 | paid | 支付返回中断或网络异常 | 测试订单 | 1. 完成支付后断网返回 App<br>2. 恢复网络<br>3. 刷新订单 | 页面先显示处理中/未知，恢复后展示服务端最终状态；不重复支付 | 订单按回调/主动查询收敛 | 中断和恢复截图、订单号 | assisted |  | orders,recovery |
| ORDER-007 | 订单 | 订单列表为空时显示空态 | both | P1 | normal | 账号无订单 | 新账号 | 1. 打开订单列表 | 显示空态，不出现其它账号数据 | 返回空列表 | 空态截图 | manual |  | orders,empty |
| RESTORE-001 | 恢复购买 | iOS 设置页恢复有效订阅 | ios | P0 | external | 已登录原购买账号 | Sandbox Apple ID | 1. 打开更多设置<br>2. 点击恢复购买<br>3. 完成系统验证 | 显示处理中和成功反馈；会员权益恢复 | 同一订阅交易幂等恢复 | 设置和会员截图 | manual |  | ios,restore,membership |
| RESTORE-002 | 恢复购买 | 无可恢复购买时反馈明确 | ios | P1 | external | Apple ID 无历史订阅 | 新 Sandbox ID | 1. 点击恢复购买 | 显示没有可恢复项目或恢复完成但无权益变化；不永久加载 | 无新订单或权益 | 结果截图 | manual |  | ios,restore,empty |

