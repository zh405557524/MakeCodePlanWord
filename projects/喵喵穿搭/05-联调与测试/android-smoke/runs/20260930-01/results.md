# Android 已安装包自动化执行记录

- 设备：`e2b8595a`；安装包：`1.0.2(102)`
- APK SHA-256：`dcbb6d44d3e1487b8f75274d61597ca908893fcd4a9001cb48604510075fbad8`
- 仅为已执行子路径证据；页面入口 PASS 不等于 P01–P30 整页验收通过。
- 截图可能含账号与订单信息，请勿公开传播。

| 用例 | 结果 | 观察 | 证据 |
|---|---|---|---|
| START-001 | PASS | 冷启动后进入四栏主页面 | — |
| ACCOUNT-001 | PASS | 当前登录账号 185****0430；未切换账号 | — |
| HOME-001-visible | PASS | 五个 AI 入口可见；逐项跳转另列子用例 | — |
| PROFILE-001-entry | PASS | 从首页→我的形象，看见 我的档案；未提交 AI 任务 | — |
| TRYON-001-entry | PASS | 从首页→AI试衣，看见 AI试衣；未提交 AI 任务 | — |
| OUTFIT-001-entry | PASS | 从首页→AI帮我搭配，看见 帮我搭配；未提交 AI 任务 | — |
| HAIR-001-entry | PASS | 从首页→发型发色，看见 发型发色；未提交 AI 任务 | — |
| MAKEUP-001-entry | PASS | 从首页→AI妆容，看见 AI妆容；未提交 AI 任务 | — |
| REPORT-001-entry | PASS | 从首页→AI形象测评，看见 AI形象测评；未提交 AI 任务 | — |
| WARDROBE-001-entry | PASS | 衣橱列表入口可达；未上传、编辑或删除衣物 | — |
| WORK-001-entry | PASS | 作品列表及全部筛选可见；未修改作品 | — |
| WORK-002-filter | PASS | 切换帮我搭配→全部；未删除作品，空列表只验筛选入口 | — |
| MEMBER-001-entry | PASS | 会员中心可达；未同意协议或购买 | — |
| MEMBER-004-unchecked | PASS | 显示 4 款商品；未勾协议点击后仍在会员中心，未继续支付 | — |
| POINTS-006-entry | PASS | 从我的→积分充值，看见 充值中心；仅验证入口 | — |
| POINTS-006-unchecked | PASS | 显示 4 款商品；未勾协议点击后仍在充值中心，未继续支付 | — |
| POINTS-005-entry | PASS | 从我的→积分明细，看见 积分明细；仅验证入口 | — |
| PAY-005-list | PASS | 从我的→订单列表，看见 订单列表；仅验证入口 | — |
| PAY-005-filter | PASS | 依次切换会员、积分、全部；未新建或取消订单 | — |
| PAY-005-detail | SKIP | 当前列表无可点订单；详情未运行 | — |
| SETTINGS-004-entry | PASS | 从我的→更多设置，看见 更多设置；仅验证入口 | — |
| LEGAL-001-settings | PASS | 设置关键入口可见，用户协议正文可打开；未退出或注销 | — |
| FEEDBACK-002-entry | PASS | 从我的→意见反馈，看见 意见反馈；仅验证入口 | — |
| FEEDBACK-002-empty | PASS | 空反馈仍留在 0/500 表单；仅验证客户端拦截，未提交有效反馈 | — |
| SERVICE-001-entry | PASS | 从我的→联系客服，看见 联系客服；仅验证入口 | — |
| TASK-005-entry | PASS | 任务中心可达；未签到或邀请 | — |
| AUTH-002 | SKIP | 不退出当前账号，不请求验证码 | — |
| PROFILE-002 | SKIP | 照片及建档由手工测试 | — |
| WARDROBE-003 | SKIP | 选图与上传由手工测试 | — |
| TRYON-001-generate | SKIP | AI 扣分和生成由手工测试 | — |
| REPORT-004 | SKIP | 报告生成及结果由手工测试 | — |
| WORK-003 | SKIP | 下载和分享由手工测试 | — |
| PAY-004 | SKIP | 真实付款由用户完成后再运行 payment-postcheck | — |
