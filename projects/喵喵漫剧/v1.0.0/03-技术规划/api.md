# 喵喵漫剧接口契约

> 2026-10-15 T-37-IF-01：用户确认“补齐只读字段”。§3.2 的订单积分快照及流水原始操作/业务编号已实施并做本机检测；其余接口实施状态以开发计划和测试证据为准。没有新增支付路径、数据库结构或结算规则。

> 2026-10-14补充S-28至S-32：Catsinger工程基础与分层规则迁移、Figma视觉主依据、相册视频提取音频、免费资产描述帮写。当前仅文档，未实现接口或数据库；设计节点见[索引](../02-设计/设计说明.md#figma-pages)。

> v1.0.0 现行规划契约，本轮已确认规则已同步（尚未实现），2026-10-13；新增接口尚未实现。公共接口按当前Controller/DTO保留，字段只在本文件定义；其他技术文档引用小节。
> 接口表引用的请求/响应类型由本节或§12字段表定义；`—`表示无请求体，`Ack`表示标准确认结果。示例JSON均为示意数据，不代表真实账号、价格配置或渠道已经接入。

<a id="api-1"></a>
## 本轮已确认规则同步（2026-10-13）

S-21的39条逐项确认及S-22作品名称分类，已按S-23同步到本文正文。对应[现行产品需求](../01-产品/requirements.md)、[155条AC与确认记录](../01-产品/requirements-list.md)及[第14轮文档检测](../01-产品/detection-feedback.md#review-round-14)。现有编号保持，受影响任务/用例同步；文档定义不代表代码、数据库或真实媒体测试已完成。用户S-24已批准产品文档；S-25的11项技术规则已同步并复检，S-26在完整技术稿交付后授权“继续下一步”，当前为开发计划·待整体审核。字幕改为手机抽取实际混音后上传、后台异步识别，剪辑与音视频字幕合成仍在本机；全剧剧本一次生成。逐项确认见技术方案§10，开发任务保持待开始。

| 范围 | 现行约束 |
|---|---|
| 创建/导入 | 确认逐集剧本创建作品；制作参数保存与分析独立；仅小说支持TXT |
| 资产 | 先来源作品名称分组，再按类型；固定版本引用，被引用禁止删除；删作品保有效资产 |
| 剪辑/导出 | 当前时间轴必需原文件下载校验后进入；主动字幕为后台识别，校对及合成在本机；识别/导出处理中弹框不可关闭，导出成功先预览再手动存相册 |
| 保留/缓存 | 视频成功以真实最近成功时刻重设作品30天；到期隐藏；图片自身30天；清闲置缓存和应用临时成片，保护有效作品引用和相册 |

## 1. 通用约定

> 本版改动：R-01至R-26。

| 项 | 契约 |
|---|---|
| Base URL | 本地/test/prod由App环境配置指定，参考地址见architecture§5；无统一 `/api/v1` 前缀 |
| 普通请求头 | 必须 `X-App-Code: catdrama`；App同时发送 `X-App-Version: 1.0.0`、`X-OS-Type: ios/android`、公共设备ID头 `X-Device-Id` |
| 鉴权标记 | **P**：允许匿名；**A**：Bearer accessToken必需，真实游客session也算A。所有A接口必须校验同App、本人，客户端不传userId选择所有者 |
| 请求体 | 默认application/json；文件导入为multipart。未知字段拒绝或按DTO既有规则处理，不将未知字段保存为自由业务JSON |
| 模型文本 | 文本模型直接返回Markdown字符串，格式见§5.1；本文件中的HTTP JSON是后端组装的接口包络/业务DTO，不是要求模型输出的JSON |
| ID | 新接口ID一律十进制正整数字符串；clipId/textId/cueId/commandId/clientDraftId/clientExportId为UUID；caseId、taskCode、configVersion为独立稳定字符串。禁止按数组下标识别对象 |
| 时间 | 新接口Time为ISO 8601 UTC毫秒字符串，例如 `2026-10-12T12:00:00.000Z`；签到自然日Asia/Shanghai。旧公共LocalDateTime仍可能无偏移，按首次联调核对的真实服务端时区解释，不能直接当UTC；该时区为接入待验证项 |
| 积分 | Points为非负JSON整数、单位积分，服务端long；有符号流水金额单独说明。App不用Double计算；不超JSON安全整数范围 |
| 金额 | 新Money为 `{amount:"10.00",currency:"CNY"}`，字符串十进制恰两位。公共旧接口保留amountCents整数分，配套currency或商品/订单详情核对CNY；不改公共已用字段 |
| 时长/位置 | 编辑时段统一整数毫秒；区间 `[startMs,endMs)`。生成时长durationSeconds为整数秒；禁止秒和毫秒混用 |
| 长度 | 字数按Unicode标量计数，前端runes与后端codePointCount一致；不静默截断。不修剪或替换保存的原文，只用全空白校验非空 |
| 分页QPage | query page int默认1、≥1；pageSize int默认20、1–100；新列表稳定按createdAt DESC,id DESC，剧集/镜头按ordinal ASC,id ASC |
| `Page<T>` | items:T[]非空数组、page:int、pageSize:int、total:int≥0、hasMore:bool；无结果items=[]。公共PageResult保留既有分页行为 |
| 版本 | 写入用Revision=正整数；草稿尚未生成内容时storyRevision/screenplaysRevision可为0。新写请求必须带expectedRevision或明确来源版本。CAS冲突读取最新状态，保留本机改稿，不自动重放覆盖 |
| 幂等 | 标记**I**的写接口必须携带Idempotency-Key（UUID/16–64字母数字短横线）；同用户/动作/键+同hash返回既有结果，异hash报冲突。普通CAS更新用revision；本机时间轴命令使用commandId且不发送后台 |
| 失效/删除 | 主动删除或无权限的新接口资源返回-404；作品列表排除已到期对象；旧作品详情请求报-560004并返回作品列表，不提供本机独立入口；图片历史可展示EXPIRED及expiresAt，新增导入被拒绝。对象ID不被重复创建复活 |
| 图片/视频 | 响应保存resourceId和真实Media信息，通过公共access-url临时取地址；不把ProviderURL或signedURL作为持久输入 |

统一响应沿用实际 `ApiResponse<T>`：

```json
{"code":200,"message":"成功","data":{"id":"10001","revision":2},"traceId":"example-trace"}
```

| 包络字段 | 类型/可空 | 语义 |
|---|---|---|
| code | int/否 | 成功200；错误负码，HTTP状态按现有全局异常处理保留；App先判断code，不只看HTTP |
| message | string/否 | 中文可展示说明，不用文字匹配业务分支 |
| data | T/错误时null | 错误附加状态通过重新GET获取，不能假定错误body含最新业务对象 |
| traceId | string/是 | 排障编号，无凭据和原文；新入口沿用现有TraceIdFilter |

公共 `Ack` 字段为 `{id:Id,revision:Revision}`，均非空。新删除操作响应data=null；未完成异步响应仍为code200，Job.state表达任务状态，不把受理当完成。

<a id="api-2"></a>
## 2. 错误码与交互

> 本版改动：R-02、R-04至R-26。

| code | 枚举/现有或拟新增 | 前端表现 |
|---|---|---|
| -400/-401/-403/-404/-500 | 现有BAD_REQUEST/UNAUTHORIZED/FORBIDDEN/NOT_FOUND/SERVER_ERROR | 参数纠正、公共登录、权限/无对象提示、保留输入重试 |
| -1001至-1008、-1101/-1102、-1201 | 现有短信/一键/token错误 | 倒计时按服务端；一键回短信；明确凭证无效才清会话，网络失败不清 |
| -1301至-1307 | 现有游客绑定/凭证/限流/平台/Apple恢复错误 | 不新建伪恢复账号；已有手机号拒绝绑定；原绑定账号走手机号；歧义联系客服 |
| -2001/-2002 | 积分不足/账户锁定 | 展示充值，保存返回位置；不自动生成或用缓存余额放行 |
| -3001/-3002 | 公共订单过期/支付校验失败 | 读真实订单，保持待确认或失败；不伪报到账 |
| -4001/-4002/-4003/-4004 | 文件过大/格式/上传/产物处理待恢复 | 保留原应用/表单；文件保存处理重试沿用原产物，不重新收费 |
| -560001 | CATDRAMA_REVISION_CONFLICT（拟新增） | 读取最新内容，保留本地副本和过时候选，用户重新核对 |
| -560002 | CATDRAMA_CONTENT_INCOMPLETE | 定位空白/超限集、未确认稿或Markdown格式错误的步骤，不进入下一步；生成错误记入Job并保留旧稿 |
| -560003 | CATDRAMA_IDEMPOTENCY_CONFLICT | 保留原请求结果；新动作生成新键，不盲目自动重试 |
| -560004 | CATDRAMA_OBJECT_EXPIRED | 作品已到期：隐藏列表项，保留本机改稿后回作品页，不再进入编辑；图片到期不得新增导入，相册文件不受影响 |
| -560005 | CATDRAMA_TASK_BUSY | 查询原活动任务；不重复提交扣费 |
| -560006 | CATDRAMA_QUOTE_EXPIRED | 重新报价和完整确认；价格变化不能自动扣款 |
| -560007 | CATDRAMA_REFERENCE_INVALID | 返回缺图/失效引用/参数页，旧视频仍能回看 |
| -560008 | CATDRAMA_DESCRIPTION_ACK_REQUIRED | 显示素材变化和描述冲突，明确核对后再报价/提交 |
| -560009 | CATDRAMA_SCOPE_CHANGED | 展示当前关联集范围，重确认共享修改 |
| -560012 | CATDRAMA_MEDIA_UNAVAILABLE | 资源不可读/探测失败，保留历史状态并恢复处理 |
| -560013 | CATDRAMA_CAPABILITY_UNAVAILABLE | 隐藏/禁用不可用能力，说明原因，不用样例冒充结果 |
| -560014 | CATDRAMA_IMPORT_FAILED | 明确TXT编码/读取/空内容/超限或不支持格式原因，保留原输入 |
| -560015 | CATDRAMA_GROWTH_NOT_QUALIFIED | 不领取，不改变资格或余额 |

新码段实施前在ErrorCode核对占用；本轮不改枚举。各模块表“错误”列列出业务码后缀，如`001/005`表示-560001/-560005；全部接口共同包含参数、鉴权、归属和服务异常。供应商明确拒绝、传输失败、提交结果未知在Job.errorCode/phase中区分，不能全部包装成同一失败。

<a id="api-3"></a>
## 3. 公共业务接口（复用）

> 本版改动：R-02、R-22、R-23、R-24、R-25、R-26。

### 3.1 登录与资料

以下路径/字段来自现有AuthController、GuestAuthController、UserController；不另建漫剧登录接口。示例公共phone/code/token为占位值，不能作为实际可用凭据。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 关键错误 / 示例 |
|---|---|---|---|
| POST /api/auth/sms/send | P；SmsSend | SmsSent | 短信-100x；请求`{"phone":"手机号"}`，响应`{"cooldownSeconds":60}` |
| POST /api/auth/sms/login | P；SmsLogin | Session | -1007；`{"phone":"手机号","code":"验证码"}`→E-PUBLIC |
| POST /api/auth/one-click-login | P；OneClick | Session | -110x；`{"provider":"ALIYUN","providerToken":"SDK凭证"}`→E-PUBLIC |
| POST /api/auth/guest/session | P；GuestSession，iOS+设备头 | Session | -1302/03/04；`{"guestCredential":"客户端安全生成的32至256字凭证"}`→E-PUBLIC |
| POST /api/auth/guest/apple-subscription/restore | P；RestorePurchase，iOS | Session | -1305/06/07；`{"transactions":[{"transactionId":"Apple交易编号","signedTransactionInfo":"StoreKit签名数据"}]}`→E-PUBLIC |
| POST /api/auth/refresh | P；Refresh | Session | -1201；`{"refreshToken":"已有刷新凭证"}`→E-PUBLIC |
| GET /api/user/profile | A；— | Profile | —；响应E-PUBLIC.profile |
| POST /api/user/guest/bind-phone | A；SmsLogin（同字段类型） | Session | -1301；同SmsLogin示例，成功userId不变 |
| POST /api/user/logout | A；— | PublicStatus | —；响应`{"status":"OK"}`，公共服务撤销当前App会话 |
| POST /api/user/delete-verification-code | A；— | SmsSent | 已有公共校验；响应`{"cooldownSeconds":60}`，实际游客资格由公共服务决定 |
| POST /api/user/delete-request | A；DeleteAccount | PublicStatus | 公共校验；请求`{"code":"验证码"}`→`{"status":"DELETE_REQUESTED"}` |

| 类型 | 字段、类型、必填/可空、约束 |
|---|---|
| SmsSend | phone:string必填非空；大陆手机号由公共服务规范化和校验 |
| SmsSent | cooldownSeconds:int非空≥0，单位秒 |
| SmsLogin | phone:string、code:string必填非空；inviteCode:string可空，4–32字母数字的公共有效码 |
| OneClick | provider:string、providerToken:string必填非空；inviteCode同上；SDK凭证只发送服务端，不打印 |
| GuestSession | guestCredential:string必填32–256，高熵、本App命名空间，由安全存储保持 |
| RestorePurchase | transactions:RestoreEntry[]必填1–20；RestoreEntry.transactionId:string必填非空≤128，signedTransactionInfo:string必填非空≤20000；不能只传本机声称的交易编号 |
| Refresh | refreshToken:string必填非空 |
| PublicStatus | status:string非空；退出OK，注销DELETE_REQUESTED |
| DeleteAccount | code:string，手机号注销按公共短信校验；游客注销行为严格使用源Service规则，不新增跨App删除 |
| Session | accessToken:string、refreshToken:string、profile:Profile均非空；不增加未经源码证明的expiresIn字段 |
| Profile | id:Id非空；phoneMasked:string可空；inviteCode:string非空；pointsBalance:int非空，表示可用余额；vipStatus:string非空，endAt:string可空（旧公共时间）；cardType:int可空；accountType:string非空GUEST/REGISTERED按公共枚举 |

### 3.2 积分、商品与订单

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/points/account | A；— | PointAccount | -2002；`{"availablePoints":1500,"frozenPoints":1200}` |
| GET /api/points/ledger | A；QPage | `Page<Ledger>` | —；`?page=1&pageSize=20`，响应items包含E-LEDGER |
| GET /api/products | P；QPage+type=POINTS | `Page<Product>` | —；`?type=POINTS`，响应items包含E-PRODUCT |
| POST /api/payments/orders | A/I；OrderCreate | OrderPayment | -200x/300x；`{"productType":"POINTS","productId":"points_1000","channel":"ios"}`，channel使用公共实际编码，响应E-ORDER |
| GET /api/payments/orders | A；QPage+status:string可空 | `Page<Order>` | —；`?page=1`→items包含E-ORDER_DETAIL |
| GET /api/payments/orders/{orderNo} | A；orderNo:string公共稳定订单号 | Order | -404；响应E-ORDER_DETAIL |
| POST /api/payments/orders/{orderNo}/pay-params | A；— | OrderPayment | -3001；只允许公共服务可续付状态，响应E-ORDER |
| POST /api/payments/orders/{orderNo}/confirm | A；OrderProof可空，Apple时必填 | Order | -3002；Apple签名/支付宝微信真实查询按公共流程，响应E-ORDER_DETAIL |
| PATCH /api/payments/orders/{orderNo}/cancel | A；— | Order | 状态冲突；响应E-ORDER_DETAIL，失败读最新订单 |
| DELETE /api/payments/orders/{orderNo} | A；— | bool | 仅公共允许隐藏状态；示例true，不删除账务 |

| 类型 | 字段、类型、可空、单位 |
|---|---|
| PointAccount | availablePoints:int、frozenPoints:int均非空≥0 |
| Ledger | id:Id、title:string、amount:int、direction:string、createdAt:公共时间均非空；amount为带符号整数积分。只读可空operation:string、bizType:string、bizId:string来自原聚合流水；非catdrama省略。direction仍按公共IN/OUT等实际映射，不能用符号猜冻结/结算/退回 |
| Product | id:string（公共原ID格式）、appCode:string、productCode:string、productName:string、productType:string、purchaseType:string非空；requiresActiveSubscription:bool非空（本AppPOINTS为false）；amountCents:int非空≥0分；priceText:string非空；priority:int非空；pointsAmount:int非空≥0；vipDays:int、pointsCycleDays:int、status:int可空；source:string、persisted:bool、editable:bool非空；publishedAt/createdAt/updatedAt:公共时间可空 |
| OrderCreate | productType:string必填POINTS；productId:string必填服务端productCode/ID；channel:string必填ios/alipay/alipay_web/wechat的有效渠道，响应可能为公共存储码IOS/ZFB/ZFB_WEB/WX，前端统一解析；价格/积分不由请求提交 |
| OrderProof | storeProductId:string、transactionId:string、signedTransactionInfo:string、iapAccountToken:string在Apple确认时均必填非空，直接采用StoreKit真实交易及已保存订单绑定；其他渠道body可空，由公共服务可信主动查询，不提交客户端success布尔 |
| OrderPayment | orderNo:string、channel:string、amountCents:int非空；payParams:object非空；currency未在旧创建响应出现，App取得Order.currency并与配置CNY和StoreKit商品价格核对后发起支付 |
| Order | orderNo:string、appCode:string、userId:int（旧公共）、productId/productCode/productType/productName:string、amountCents:int、currency:string、channel:string、status:string非空；只读pointsAmount:int可空，为购买时积分快照，非catdrama或旧单未捕获时省略；cardType:int、providerOrderNo:string可空；payParams:object可空；paidAt/expiresAt/createdAt/updatedAt:公共时间按原VO可空；userId不作为访问入参 |

T-37-IF-01（2026-10-15已确认）：新建catdrama积分订单时将购买时积分数保存到既有订单JSON，续取支付参数保留该快照。响应只暴露顶层pointsAmount，内部快照不作为SDK参数返回。旧单缺失时不补0、不读最新商品推算；可查看，若本机也没有原购买意图则不能盲目续付。跨设备对当前本人PENDING原单保存本机恢复记录后回统一充值页，重新核对真实状态、协议与平台能力；不创建第二笔订单。存在另一未结束意图时先核对原意图。

聚合流水沿用原金额、方向、排序与合并算法：operation取原展示行的FREEZE/FREEZE_ADJUST、CONFIRM/DEDUCT、REFUND、GRANT等实际值，分别展示冻结、结算、退回及充值/奖励。PAYMENT的bizId为原订单号，可打开同一订单详情；GENERATION/CREATEIMAGE编号是计费业务编号，只展示并回作品入口，不猜成项目或镜头ID。未知操作保留业务说明和公共方向，旧字段不改。检测及授权见[T-37证据](../05-测试/evidence/T-37/result.json)。

旧Public Product未提供currency，catdrama公开运行配置声明CNY，付款以Order.currency和商店真实币种为权威。公共 `payParams` 不二次发明全渠道结构，其SDK类型定义/字段见§3.5对应现有模型；新App只开放服务端+平台共同可用渠道。公共订单状态为PENDING/PAID/FAILED/CANCELLED/CLOSED/EXPIRED；只以PAID判到账。客户端取消不覆盖晚到的可信成功交易。

### 3.3 签到、邀请、反馈

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/tasks/center | A；— | PublicTaskCenter | —；见E-TASK_CENTER；前端与§11成长结果组合 |
| POST /api/tasks/check-in | A；— | CheckInResult | 重复返回旧结果；`{"signedToday":true,"firstTime":true,"rewardPoints":3,"totalPoints":33,"consecutiveDays":1,"cycleDay":1,"days":[]}` |
| GET /api/invite/materials | A；— | InviteMaterials | 活动门禁；`{"inviteCode":"ABCD1234","inviteLink":"当前App服务端链接","posterTitle":"邀请好友","ruleText":"有效邀请奖励10积分","landingDownloadUrl":"当前App下载链接"}` |
| GET /api/invite/records | A；QPage，keyword:string可空，memberStatus:string可空 | `Page<InviteRecord>` | —；本App不传现金筛选；items见§3.5公共VO |
| POST /api/feedback | P或A；FeedbackSubmit | FeedbackResult | -400；`{"type":"PRODUCT","content":"建议内容","contact":null,"attachmentAssetIds":[]}`→`{"id":"8001","status":"PENDING","createdAt":"旧公共时间"}`，状态值由公共返回 |

| 类型 | 字段、类型、可空/范围 |
|---|---|
| PublicTaskCenter | enabled:bool、totalPoints:int、checkIn:CheckIn、dailyTasks:PublicTask[]均非空 |
| CheckIn | signedToday:bool、consecutiveDays:int≥0、cycleDay:int1–7、todayRewardPoints:int≥0、days:CheckInDay[]均非空 |
| CheckInDay | day:int1–7、rewardPoints:int≥0、checked:bool、current:bool均非空 |
| PublicTask | code/title/description/rewardText/actionText/routeName:string、target/progress:int≥0、completed/enabled:bool均非空；routeName为源语义，App映射到自己的命名路由，不直接执行服务端任意路由 |
| CheckInResult | signedToday/firstTime:bool、rewardPoints/totalPoints:int、consecutiveDays/cycleDay:int、days:CheckInDay[]均非空；同一次重试firstTime可能false但rewardPoints表示当日记录，不额外到账 |
| InviteMaterials | inviteCode/inviteLink/posterTitle/ruleText:string非空，landingDownloadUrl:string可空；不在客户端拼写歌域名/品牌链接 |
| InviteRecord | id/inviteeUserId:公共string ID、inviteeName:string、rewardStatus/memberCommissionStatus/bindSource:string、boundAt/createdAt:公共时间非空；inviteePhoneMasked:string、rewardPoints:int可空；只展示有效邀请和积分，不发起现金业务 |
| FeedbackSubmit | type:string必填≤32；content:string必填1–500（catdrama产品限额，公共DTO最大1000不改变）；contact:string可空≤128；attachmentAssetIds:公共Long[]可空，本版默认[]无附件UI |
| FeedbackResult | id:Id、status:string、createdAt:公共时间非空 |

现有 `/api/invite/bind` 响应依赖现金overview，不作为catdrama积分绑定入口；§11薄门面仍调用公共绑定Service，未重写发奖逻辑。公共接口不废弃、不改写其他App响应。

### 3.4 公共资源上传与访问

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| POST /api/resources/direct-upload/prepare | A；UploadPrepare | UploadTicket | -4001/02；E-UPLOAD_REQUEST→E-UPLOAD_TICKET |
| OSS PUT UploadTicket.uploadUrl | 临时ticket.headers；原文件字节 | OSS成功状态 | 非业务ApiResponse；上传失败保留文件/表单，不调用应用 |
| POST /api/resources/direct-upload/complete | A；UploadComplete | ResourceResult | -4003；E-UPLOAD_COMPLETE→返回resourceId |
| POST /api/resources/{resourceId}/access-url | OWNER=A，已发布PUBLIC=P；— | AccessUrl | -404/-401；`{"resourceId":"9001","accessUrl":"临时签名URL","expiresAt":"2026-10-12T18:00:00Z"}` |

| 类型 | 字段、类型、约束 |
|---|---|
| UploadPrepare | filename:string必填非空≤255（App限制）；sizeBytes:int必填>0；resourceType:string必填；contentType:string可空；assemType:int、ossType:int可空按公共默认；uploadMode:string必填OSS_PUT_SIGNED_URL；contentMd5:string可空32HEX |
| UploadTicket | uploadToken/uploadMode/uploadUrl/method/objectKey/status:string非空；headers:`map<string,string>`、formFields:`map<string,string>`非空；expiresAt:公共时间非空；message:string可空；App要求method=PUT、status=UPLOAD_PENDING（凭证已就绪，尚未完成资源上传） |
| UploadComplete | uploadToken/resourceType/objectKey:string必填与prepare一致；sizeBytes:int必填>0；ossUrl/contentType/contentMd5:string可空。服务端验证对象真实大小/类型/所有者，不信任客户端声明 |
| ResourceResult | resourceId:string成功时非空；operation/resourceType/storageTarget/status/resourceKey:string非空；localPath/localUrl/ossObjectKey/ossUrl/publicUrl/storageProvider/storageBucket/storageRegion/filename/contentType/metaJson/message:string可空；sizeBytes:int非空。字段保留旧VO；App只持resourceId，私有返回不得含可长期公开访问URL |
| AccessUrl | resourceId:Id、accessUrl:string、expiresAt:Time均非空；有效期以响应为准，旧普通媒体当前12小时，不当作永久地址 |

拟新增资源类型为drama/asset-images、drama/shot-videos、drama/cover-images及drama/subtitle-audio。个人/项目图片和字幕临时音频沿用公共直传；字幕音频仅OWNER可访问，不进入图片资产分类，供应商读取使用短期签名。原始导入音轨、剪辑封面、工程和成片不上传；用户主动识别时仅上传按实际播放效果生成的混音副本。图片上传PNG/JPEG/WebP≤10MiB规则保留。

字幕上传格式为WAV（PCM signed 16-bit little-endian、单声道、16000Hz），MIME audio/wav；服务端探测格式、实际字节与时长，不信任客户端声明。初始上限50MiB，超限在识别前明确提示，保留工程、不截断音频；只有支持该输入与时间戳输出的ASR绑定才启用。未关联任务的已完成上传从完成起24小时可清理；已关联任务按§9.1终态与活动引用规则清理。

### 3.5 公共契约源码索引

所有路径以下均为 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/` 下的现有文件，开发时核对变化；这里只对本App用到的原契约建立引用，不创建另一份公共协议。

| 未展开的公共细节 | 唯一实现依据 / 接入核对 |
|---|---|
| Logout/注销回执 | core/user/controller/UserController.java及其dto；游客分支核对UserService；本轮不承诺不存在的昵称编辑API |
| Apple证明、渠道枚举和payParams | core/auth/dto/AppleSubscriptionRestoreEntry.java；core/payment/domain/；core/order/controller/OrderController.java；App catsinger/lib/models/及services/payment_gateway.dart中对应渠道模型 |
| 邀请列表所有字段 | app/growth/invite/vo/InviteRecordItem.java：id/inviteeUserId/name/masked、rewardStatus/rewardPoints、memberCommissionStatus、bindSource、boundAt/createdAt。App只展示邀请人数/积分，不引出现金流程 |
| 公共静态页面/版本 | 沿用已有配置读取Service，catdrama对外字段在§4；不让App调用narrate/catsinger专属config路径 |

<a id="api-4"></a>
## 4. 配置、首页与案例（新增）

> 本版改动：R-01、R-08、R-23、R-25。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/config | P；— | RuntimeConfig | 013；响应E-CONFIG |
| GET /api/drama/home | P；categoryCode:string可空 | Home | —；响应`{"categories":[],"cases":[],"configVersion":"cfg-1"}`，空态不造案例 |
| GET /api/drama/cases/{caseId} | P；caseId:string1–64 | Case | -404；响应E-CASE |
| GET /api/drama/static-pages/{pageCode} | P；USER_AGREEMENT/PRIVACY/RECHARGE/ALGORITHM/ABOUT | StaticPage | 013；`{"code":"ABOUT","title":"关于","contentFormat":"MARKDOWN","content":"已配置正文","version":"1"}` |

| 类型 | 字段、类型、可空/范围 |
|---|---|
| RuntimeConfig | configVersion:string、appCode:string=catdrama、currency:string=CNY、enabled:bool、features:FeatureFlags、limits:Limits、videoModels:ModelCapability[]、imageModels:ModelCapability[]、styles:Style[]均非空；defaults:ProductionSettings、version:VersionPolicy可空（无有效配置）；retentionDays:int=30；publicTimestampZone:string可空（未核实旧时间时区不能伪填） |
| FeatureFlags | creation/materialGeneration/videoGeneration/guestLogin/oneClickLogin/recharge:bool非空；只控制需要后台的公共及创作/生成业务。仍有效作品的本机剪辑处理不受这些开关、enabled或配置接口结果限制；本机能力见data-model§2 |
| Limits | sourceChars:int10000、nameChars:int20、episodeMin:int1、episodeMax:int30、scriptChars:int10000、descriptionChars:int500、shotPromptChars:int1000、imageBytes:int10485760、importBytes:int10485760、quoteSeconds:int默认300、batchTargets:int默认100均非空 |
| ModelCapability | providerCode/modelCode/contractVersion/displayName:string非空；available:bool非空；combinations:ProductionSettings[]非空；maxReferenceImages:int≥0、supportsAudio:bool、unitPrice:UnitPrice均非空；disabledReason:string可空。只声明已配置和可验证组合，不用厂商名称推断支持 |
| Style | code/name:string非空，referenceResourceId:Id可空 |
| VersionPolicy | latestVersion:string、forceUpdate:bool、downloadUrl:string可空；无配置返回null，不用样例版号 |
| Home | categories:Category[]、cases:Case[]、configVersion:string非空；Category={code:string,name:string}非空 |
| Case | id/title/categoryCode:string非空；cover:Media、video:Media、description:string、styleCode:string可空；reusableStyle:bool非空；不能把案例视频资源赋给用户镜头成功版本 |
| StaticPage | code/title/contentFormat/content/version:string非空；contentFormat=MARKDOWN/HTML；仅可信已配置正文，HTML禁动态脚本 |
| ProductionSettings | providerCode/modelCode/contractVersion:string必填非空；resolution:string取当前模型原生清晰度；durationSeconds:正整数、须位于当前模型单次生成能力范围；aspectRatio:string16:9/9:16；styleCode:string非空。组合必须在当前有效能力列表中 |
| UnitPrice | points:int≥0、unit:stringIMAGE/SECOND、pricingVersion:string非空；图片初120/IMAGE，视频120/SECOND；720/1080等不自行增加未确认倍率 |
| Rational | numerator/denominator:int>0，表示精确帧率，不以四舍五入整数替代实际时间基准 |
| GenerationCapabilitySnapshot | providerCode/modelCode/contractVersion:string、capturedAt:Time、supportsAudio:bool、outputFormats:VideoFormat[]均非空；视频生成时锁定的已验证能力，后续配置变更不修改旧快照 |
| VideoFormat | width/height:int>0、frameRate:Rational、codec:string非空；具体允许值来自实际模型验证，不承诺全模型固定档位 |
| Media | resourceId:Id非空；state:string非空；sizeBytes:int>0、sha256:string64HEX、durationMs/width/height:int、frameRate:Rational、hasAudio:bool可空；succeededAt/expiresAt:Time可空；成功视频必须有真实大小/摘要/探测字段，非视频的duration/尺寸/音轨按类型可空；公共旧资源VO不改字段，新业务投影补齐元数据 |

S-20/D-31：本配置接口不返回剪辑/导出开关、字体渲染或本机音频导入限额；字幕识别服务在提交时校验自身配置；这些随App发布并由手机探测。进入已有完整本机工程不请求或等待本配置。服务端模型能力仅用于AI生成选择，具体源版本的生成能力快照和媒体规格供下载后在本机使用。

<a id="api-5"></a>
## 5. 创作草稿、免费内容任务与确认（新增）

> 本版改动：R-04、R-05、R-06、R-07、R-08、R-09、R-26。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| POST /api/drama/imports/text | A；multipart sourceType必填NOVEL、file必填TXT≤Limits.importBytes | ImportedText | 014/-4001/02；响应`{"filename":"节选.txt","text":"正文第一段\n正文第二段","charCount":11}`；非小说或非TXT拒绝 |
| POST /api/drama/drafts | A/I；DraftCreate | Draft | 002；E-DRAFT_CREATE→E-DRAFT |
| GET /api/drama/drafts | A；QPage+state:string可空 | `Page<Draft>` | —；`?state=EDITING`→items包含E-DRAFT |
| GET /api/drama/drafts/{draftId} | A；— | Draft | —；E-DRAFT |
| PUT /api/drama/drafts/{draftId} | A；DraftSave | Draft | 001/004；E-DRAFT_SAVE→E-DRAFT |
| DELETE /api/drama/drafts/{draftId} | A；expectedRevision:Revision query必填 | null | 001；只删除草稿，PROJECT_CREATED不删除正式项目 |
| POST /api/drama/drafts/{draftId}/content-tasks | A/I；ContentTaskCreate | Job | 001/002/005/013；E-CONTENT_TASK→E-JOB |
| POST /api/drama/drafts/{draftId}/content-results/{jobId}/apply | A/I；ContentApply | Draft | 001/002；`{"expectedRevision":4,"overwriteConfirmed":true}`→E-DRAFT |
| POST /api/drama/drafts/{draftId}/confirm | A/I；DraftConfirm，仅STORY | Draft | 001/002；`{"expectedRevision":5,"stage":"STORY","contentRevision":2}`；SCREENPLAYS改由确认创建作品端点原子处理 |

| 类型 | 字段、类型、必填/可空与约束 |
|---|---|
| ImportedText | filename/text:string、charCount:int非空，text1–10000；仅TXT，识别UTF-8/BOM及可识别GB18030，不能把乱码当成功。失败不替换App原输入；不解包DOCX |
| DraftCreate | clientDraftId:UUID必填；name:string可空/空草稿；sourceType:string可空默认EXISTING_SCRIPT；originalText:string可空/空；splitMode:string可空默认AUTO；requestedEpisodeCount:int可空，CUSTOM需1–30；importFilename:string可空≤255 |
| DraftSave | expectedRevision:Revision必填；name:string必填≤20，originalText:string必填≤10000（编辑态可空）、sourceType:INSPIRATION/NOVEL/EXISTING_SCRIPT、splitMode:AUTO/CUSTOM必填；requestedEpisodeCount:int可空但CUSTOM必填1–30；importFilename:string可空；story:Story、screenplays:Screenplay[]、productionSettings:ProductionSettings可空。全量保存当前已获服务端结果，不接受客户端伪造确认版本；为空保留空草稿状态 |
| Story | synopsis:string1–10000；episodeCount:int1–30；directions:Direction[]数量相同且顺序1…N；Direction={ordinal:int,title:string1–20,direction:string1–10000}必填。编辑态允许暂空，确认/生成必须完整 |
| Screenplay | ordinal:int1–30、title:string1–20、text:string1–10000均必填；数组1–30，无空集/重复ordinal。现成剧本保持剧情、原标题顺序，超30不得静默丢集 |
| Draft | id:Id、clientDraftId:UUID、name/originalText:string、sourceType/splitMode/state:string、revision/sourceRevision/storyRevision/screenplaysRevision:int、expiresAt/createdAt/updatedAt:Time非空；requestedEpisodeCount:int、importFilename:string、story:Story、screenplays:Screenplay[]、productionSettings:ProductionSettings、storyConfirmedRevision/screenplaysConfirmedRevision:int、projectId:Id可空；storyValid/screenplaysValid/storyManualEdited/screenplaysManualEdited:bool、activeJobs:Job[]非空 |
| ContentTaskCreate | expectedRevision:Revision必填；target:STORY/SCREENPLAYS；overwriteConfirmed:bool必填（已有手改需true）；内容读取服务端已保存稿，不重传/偷偷改变原文 |
| ContentCandidate | target:string、draftId:Id、sourceRevision/targetBaseRevision:int、story:Story或screenplays:Screenplay[]、stale:bool、markdownDocuments:MarkdownDocument[]必填，互斥内容仅一项非空；markdownDocuments按步骤保留原始输出，成功候选至少一项；存于Job.result.document；生成失败不写Draft旧稿 |
| ContentApply | expectedRevision:Revision、overwriteConfirmed:bool必填；jobId属于当前草稿成功候选，输入/目标基版本与当前匹配，否则001 |
| DraftConfirm | expectedRevision:Revision、stage:STORY、contentRevision:Revision必填；只确认完整且来源有效的故事草案，重复同revision返回现确认。逐集稿确认使用POST /api/drama/projects |

返回修改原文/内容类型/拆分选择时服务端递增sourceRevision并取消下游有效确认；草案手改递增storyRevision使逐集确认失效；仅productionSettings变化不递增这两层正文版本。免费任务仅限流、防重复，积分账户不冻结。模型输出不满足1–30、非空、正文边界时任务失败，不能截断生成结果。

<a id="api-markdown"></a>
### 5.1 模型文本输出约定（Markdown v1）

> 本版改动：R-05、R-06、R-07、R-10、R-17。

以下约定适用于草案、分集剧本、素材提取、镜头拆分这6份文本模板。输入允许模板变量；输出直接为Markdown正文，禁止JSON包裹、整篇代码围栏、额外前言/总结。正常调用不配置JSON输出模式或JSON Schema，不对生成文本执行JSON反序列化；模型SDK本身的响应包络照常由适配层读取。

| 类型 | 字段、类型与约束 |
|---|---|
| MarkdownDocument | stepKey:string非空，由后端按任务步骤生成且同任务内唯一；formatVersion:string固定`markdown-v1`；markdown:string非空，为该步骤完整原始模型文本。全部只读，非模型返回字段；模板/变量/版本另在任务输入快照保留 |

后端先保存每次返回的原文，再用固定标题分段形成Story/Screenplay/素材/镜头候选。`markdownDocuments`只承载生成来源，不接收用户修改；当前正文以DraftSave、ScriptEdit或素材/镜头编辑接口保存的业务字段为准。Story.synopsis、Direction.direction、Screenplay.text、素材/镜头description允许Markdown文本，前端直接渲染/编辑字符串。手工编辑这些独立字段不要求补齐整篇生成文档的结构标题。

结构标题使用行首ATX标题、固定层级与下表写法；数字用阿拉伯数字，N和名称/标题是待填值。分段定位记录原文范围，结构标题整行及其行结束符不计入对应字段值，其余片段原样保留，不改写或静默截断。字段长度按保存片段的Unicode标量计算，Markdown符号也计数。仅识别约定的结构标题；正文中的普通标题、列表、对白不是新对象，代码围栏内的文字也不能被误识别为结构标题。模型不得在正文中重复使用保留的结构标题制造歧义。

| 文本用途 | 必需结构 | 拆分与校验 |
|---|---|---|
| 故事草案（灵感/小说） | `# 故事草案`；`## 故事梗概`；依次`## 第N集：标题`，各集下面为剧情方向 | 映射Story；1–30集、序号连续不重复，CUSTOM与已确认集数相等；标题/梗概/方向遵守Story上限 |
| 逐集剧本（现成整理/全剧一次生成） | `# 逐集剧本`；`## 第N集：标题`，各集下面为完整剧本文本 | 一次请求返回1…N全集；数量与已确认集数一致，每集完整非空且不超10000。缺集、截断、重复、格式错误均为整次失败，保留旧稿，不按集补调用或交付部分结果 |
| 素材提取 | `# 素材清单`；每项`## 角色：名称`、`## 场景：名称`或`## 道具：名称`；各项包含`### 外观描述`、`### 原文依据`、`### 已有素材标记` | 名称≤20、描述1–500；原文依据必须能在输入找到；已有标记只可填写输入提供的一个标记，无已有对象填`无`。无任何素材时正文仅为`无`；不能省略失败项冒充空清单 |
| 镜头拆分 | `# 镜头清单`；依次`## 镜头N`；各项包含`### 对应原文`、`### 引用素材`、`### 视频描述` | 镜头序号从1连续、不重复；视频描述1–1000；原文非空且能定位输入，引用逐项校验；完整非空剧本不能返回空镜头清单 |

素材提取完成后，后端为可引用项生成本次快照内唯一标记（如`asset_001`），与真实assetId/bindingId或待创建候选关联，再把清单传给镜头步骤。`引用素材`每行`- asset_001`；确无引用时只写`无`。模型不能生成业务ID或杜撰标记，未知/重复标记不能悄悄丢弃；已有素材回填标记仍须校验同项目、身份依据及手工独立约束。相同名称不自动合并；同类型同名但不同身份由上下文说明并使用不歧义名称。

原文依据/对应原文使用输入中的连续原文片段，后端计算来源锚点及指纹；定位时只允许忽略结构段落边界的空行，检查点原文保持不变。重复片段不能唯一定位时保留为失败待重试，不按数组位置绑定旧镜头。素材候选通过后才运行依赖它的镜头步骤；只有所有必需段落、长度及引用都合法才可提交该候选。结构缺失、歧义、截断或超限记-560002，引用无效记-560007；Job.errorMessage包含步骤和可定位的段落说明，不在日志输出整篇用户原文。

模型原始输出示例（下面围栏仅用于文档展示，真实模型返回不带围栏）：

```markdown
# 逐集剧本
## 第1集：车站重逢
少女在车站等待。
**少女：** 你终于来了。
```

分段后标题为“车站重逢”，text为标题行之后的原始正文，ordinal为1；episodeId在正式创建时由后端分配。现成剧本整理须保留原标题和剧情，用户确认后保存的正文不因Markdown格式重新润色。

流式返回须结束且检查完整后才有成功候选，中断不交付半篇；格式失败保存原文，不自动切JSON、不调用额外模型抽取或修复。检查点落库后可重新分段，只有明确失败的生成步骤才通过现有重试入口重新调用模型。图片/视频任务输出媒体，不套用本节文本格式；后台ASR只产出识别文字和时间戳，不属于提示词任务。

<a id="api-6"></a>
## 6. 正式项目、剧集和重新分析（新增）

> 本版改动：R-09、R-10、R-16、R-17、R-26。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| POST /api/drama/projects | A/I；ProjectCreate；触发“确认剧本，设置制作参数” | ProjectCreated | 001/002/004；原子确认逐集稿并唯一创建作品/剧集，制作参数可未设置，不入队分析 |
| GET /api/drama/projects | A；QPage | `Page<Project>` | 只列未删除且未到期作品；服务端真实截止，缓存列表进入前也需核对有效性 |
| GET /api/drama/projects/{projectId} | A；— | Project | —；E-PROJECT |
| PATCH /api/drama/projects/{projectId} | A；ProjectEdit | Project | 001/004/012；`{"expectedRevision":1,"name":"新名称","description":"简介","coverResourceId":null}`→E-PROJECT |
| DELETE /api/drama/projects/{projectId} | A/I；DeleteObject | null | 001；`{"expectedRevision":2,"confirmed":true}` |
| GET /api/drama/episodes/{episodeId} | A；— | Episode | —；E-EPISODE |
| PATCH /api/drama/episodes/{episodeId}/script | A；ScriptEdit | Episode | 001/002/004；`{"expectedRevision":2,"title":"第一集","text":"最终逐字保存正文"}`→E-EPISODE |
| DELETE /api/drama/episodes/{episodeId} | A/I；DeleteObject | Project | 001/-400（最后一集）；同删除示例，返回重排后的显示集号 |
| POST /api/drama/projects/{projectId}/analysis-tasks | A/I；ProjectAnalysisCreate | Job | 001/004/005；`{"expectedRevision":2,"episodeIds":["2002"]}`→E-JOB，重试指定失败集 |
| POST /api/drama/episodes/{episodeId}/analysis-tasks | A/I；EpisodeAnalysisCreate | Job | 001/004/005；`{"expectedRevision":3,"scriptRevision":2}`→E-JOB |
| GET /api/drama/analyses/{analysisId} | A；— | AnalysisDiff | —；E-ANALYSIS |
| POST /api/drama/analyses/{analysisId}/apply | A/I；AnalysisApply | Episode | 001/009；`{"expectedEpisodeRevision":3,"scriptRevision":2,"confirmed":true}`→E-EPISODE |
| POST /api/drama/shots/{shotId}/restore-analysis | A/I；expectedEpisodeRevision:Revision必填body | Episode | 001/004；`{"expectedEpisodeRevision":4}`，只恢复移出身份/历史，不插时间轴 |

| 类型 | 字段、类型、必填/可空与约束 |
|---|---|
| ProjectCreate | draftId:Id、expectedDraftRevision:Revision、screenplaysRevision:Revision必填；校验最终正文完整、来源有效，同事务确认稿并创建项目/剧集。重复草稿只返回原projectId；失败保草稿，不要求productionSettings |
| ProjectEdit | expectedRevision:Revision必填；name:string1–20、description:string0–500、coverResourceId:Id可空，提供字段才修改；若改制作参数另传productionSettings有效组合，不重拆正文 |
| DeleteObject | expectedRevision:Revision、confirmed:bool=true必填；面板已说明删除范围后调用 |
| ScriptEdit | expectedRevision:Revision、title:string1–20、text:string1–10000必填；保存后旧分析可看、新生成必须显示实际script版本 |
| ProjectAnalysisCreate | expectedRevision:Revision必填，episodeIds:Id[]可空（默认需分析集），非空时去重1–30且本人同项目；已有成功结果不由重试覆盖 |
| EpisodeAnalysisCreate | expectedRevision:Revision、scriptRevision:Revision必填；生成候选差异不覆盖应用结果 |
| AnalysisApply | expectedEpisodeRevision/scriptRevision:Revision、confirmed:true必填；服务端按候选稳定匹配应用；部分匹配不自动按数组绑定 |
| ProjectCreated | project:Project非空；不返回analysisJob，分析在制作设置保存后由analysis-tasks另行提交 |
| Project | id/name:string、revision:int、state:ACTIVE/EXPIRED/DELETED、episodeCount:int1–30、createdAt/expiresAt:Time、episodes:Episode[]、progress:Progress非空；description/cover可空；productionSettings可空（待设置）；latestVideoSucceededAt:Time可空；无作品completed/exported字段，列表排除删除/到期 |
| Episode | id/projectId:Id、ordinal/displayNumber:int、title/text:string、revision/scriptRevision:int、analysisOutdated:bool、state:string、progress:Progress、expiresAt:Time非空；analyzedScriptRevision:int、analysisId:Id可空；activeJobs:Job[]非空；entryState:object非空，script/materials/shots/editor各键固定可访问及reason，不按备用缺图隐藏入口 |
| Progress | stage:SETTINGS/ANALYSIS/MATERIALS/VIDEOS、total/ready/running/failed:int≥0、canGenerate/hasReadyVideo:bool非空；仅推荐制作入口，无作品完成或导出状态 |
| AnalysisDiff | id/episodeId:Id、scriptRevision/baseEpisodeRevision:int、state:string、added/kept/removed:ShotDiff[]、assetChanges:AssetDiff[]、counts:object（added/kept/removed:int）、markdownDocuments:MarkdownDocument[]非空；baseAnalysisId:Id可空；计数必须等于数组长度；生成中原文列表可为空，完成后包含本次候选依赖的素材/镜头步骤原文 |
| ShotDiff | action:ADD/KEEP/REMOVE、candidateKey:string、sourceText:string、description:string、ordinal:int非空；existingShotId:Id可空（KEEP/REMOVE必填）；appliedVideo:VideoVersion可空；references:Reference[]非空 |
| AssetDiff | action:ADD/KEEP/DETACH/ARCHIVE、candidateKey:string、kind/name:string、affectedEpisodeIds:Id[]非空；existingBindingId:Id可空；说明手工独立关系是否保留 |

正式首次分析读取创建时已确认的全部正文，成功子集可直接应用首次结果；新旧存在正式镜头/素材时一律差异候选确认。取消只是关闭候选面板，不改变旧分析或伪取消服务端任务。删除父对象时已受理任务完成补偿，不能因找不到业务行漏退款。

**作品生命周期**：创建截止=createdAt+30天。每次VIDEO子任务真实成功、交付/结算完成时，同事务更新latestVideoSucceededAt=max(旧值,该任务真实succeededAt)，expiresAt=max(createdAt,latestVideoSucceededAt)+30天；不取重试当前时间。同步子集与项目引用保护截止；只图片生成、失败、应用历史或编辑不续期。到期前已受理任务成功可据真实成功时间恢复有效性；DELETED永不复活。查询与生成提交以服务端期限为准，作品不提供已导出/完成标识。

<a id="api-7"></a>
## 7. 素材、图片历史和共享范围（新增）

> 本版改动：R-03、R-10、R-11、R-12、R-13、R-22、R-24、R-26。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/assets | SYSTEM=P，PERSONAL=A；QPage、scope必填，kind/source/originProjectId可空，personalOnly:bool可空 | `Page<Asset>` | originProjectId筛来源作品分类；personalOnly=true取无作品归属的个人资产，两参数互斥 |
| GET /api/drama/asset-groups | A；QPage | `Page<AssetGroup>` | 同App本人作品分类，按originProjectId聚合有效个人资产；不要求来源作品仍存在；首张成功入库后出现 |
| POST /api/drama/assets | A/I；PersonalAssetCreate | Asset | 002/012；`{"kind":"ROLE","name":"小喵","description":"少女","imageResourceId":null}`→E-ASSET |
| GET /api/drama/assets/{assetId} | 已发布SYSTEM=P，其他A；— | Asset | —；E-ASSET |
| PATCH /api/drama/assets/{assetId} | A；AssetEdit，仅PERSONAL | Asset | 001/004；`{"expectedRevision":1,"name":"小喵","description":"黄色外套"}`→E-ASSET |
| DELETE /api/drama/assets/{assetId} | A/I；DeleteObject，仅PERSONAL | null | 007引用中、005图片任务活动中：不删除且data=null；App重新GET该Asset，用referencingProjects/activeJob展示阻断原因；同资源锁内重核，未引用且无活动图片任务才允许删除 |
| GET /api/drama/assets/{assetId}/images | 同Asset鉴权；QPage | `Page<ImageVersion>` | —；items包含E-IMAGE |
| POST /api/drama/assets/{assetId}/images | A/I；ImageUploadApply，仅PERSONAL | Asset | 001/012；`{"expectedRevision":2,"resourceId":"9001","apply":true}`→E-ASSET，真实上传检查后应用 |
| POST /api/drama/assets/{assetId}/images/{versionId}/apply | A/I；expectedRevision:Revision必填body | Asset | 001/012；`{"expectedRevision":3}`→E-ASSET，历史应用免费 |
| GET /api/drama/episodes/{episodeId}/assets | A；kind:string可空、includeArchived:bool默认false | Binding[] | —；响应E-BINDINGS |
| POST /api/drama/episodes/{episodeId}/assets | A/I；EpisodeAssetCreate | Binding | 001/002；`{"expectedEpisodeRevision":2,"kind":"PROP","name":"信封","description":"旧信封"}`→E-BINDING |
| POST /api/drama/episodes/{episodeId}/assets/import | A/I；AssetImport | Binding | 001/007/012；`{"expectedEpisodeRevision":2,"sourceAssetId":"3001","sourceImageVersionId":"3101","kind":"ROLE"}`→E-BINDING |
| GET /api/drama/episode-assets/{bindingId}/impact | A；— | ScopeImpact | —；E-SCOPE |
| PATCH /api/drama/episode-assets/{bindingId} | A/I；ScopedAssetEdit | ScopeApplied | 001/009；E-SCOPED_EDIT→E-SCOPE_APPLIED |
| POST /api/drama/episode-assets/{bindingId}/images | A/I；ScopedImageUpload | ScopeApplied | 001/009/012；`{"resourceId":"9001","scope":"CURRENT_EPISODE","expectedRevision":2,"scopeVersion":"scope-2","affectedEpisodeIds":["2001"]}`→E-SCOPE_APPLIED |
| POST /api/drama/episode-assets/{bindingId}/images/{versionId}/apply | A/I；ScopeConfirm | ScopeApplied | 001/009/012；E-SCOPE_CONFIRM→E-SCOPE_APPLIED，历史免费 |
| POST /api/drama/episode-assets/{bindingId}/archive | A/I；expectedRevision:Revision、confirmed:bool=true必填body | Binding | 001/005/007；引用/生成中不能归档；共享项先独立，仅本集影响 |
| POST /api/drama/episode-assets/{bindingId}/restore | A/I；expectedRevision:Revision必填body | Binding | 001/004；恢复归档清单，不重新生成 |

| 类型 | 字段、类型、必填/可空与约束 |
|---|---|
| PersonalAssetCreate | kind:ROLE/SCENE/PROP、name:string1–20、description:string0–500必填；imageResourceId:Id可空，给出时须当前App本人已完成私有可用图；为空返回DRAFT不满足成长 |
| AssetEdit | expectedRevision:Revision必填；name:string1–20、description:string0–500可选；不通过编辑字段悄悄换应用图 |
| EpisodeAssetCreate | expectedEpisodeRevision:Revision、kind/name/description同创建规则必填；新增只属当前集，不自动与同名素材合并 |
| AssetImport | expectedEpisodeRevision:Revision、sourceAssetId/sourceImageVersionId:Id、kind必填；同类型、本人/已发布SYSTEM且图版本可用。PROJECT对象保存资料快照和来源版本固定引用，版本关系行仅作固定引用，沿用源resourceId/成功时间/期限，不复制媒体或另起30天；个人源换图不更新此引用 |
| ImageUploadApply | expectedRevision:Revision、resourceId:Id、apply:bool必填true；保存可用图及应用同事务，失败保留旧图 |
| ScopeConfirm | expectedRevision:Revision、scope:SHARED/CURRENT_EPISODE、scopeVersion:string、affectedEpisodeIds:Id[]必填；数组须等于服务端重新算出的影响范围；CURRENT_EPISODE只有当前集 |
| ScopedAssetEdit | ScopeConfirm的全部字段 + name:string1–20、description:string0–500可选至少一项 |
| ScopedImageUpload | ScopeConfirm + resourceId:Id必填；参考图片类型/大小和所有者校验同个人上传 |
| ScopeImpact | bindingId/assetId:Id、revision:int、scopeVersion:string、shared:bool、episodes:EpisodeLabel[]、affectedShotIds:Id[]非空；EpisodeLabel={id:Id,displayNumber:int,title:string}；currentImage:ImageVersion可空；fields:string[]说明同步的资料/图片范围 |
| ScopeApplied | binding:Binding、affectedEpisodeIds:Id[]、affectedShotIds:Id[]、detached:bool非空；每项引用revision更新，历史视频快照保持 |
| Asset | id/name/description/scope/kind/state/sourceType:string、revision:int、createdAt:Time非空；expiresAt:Time系统可空（个人为聚合最大有效截止）；appliedImage/activeJob/sourceAssetId可空；originProjectId:Id、originProjectName:string仅来源作品资产非空；canImport/canDelete:bool、referencingProjects:ProjectRef[]非空；后端确认删除时重新核验 |
| Binding | id/episodeId/assetId:Id、revision:int、shared:bool、detached:bool、archived:bool、asset:Asset非空；sharingGroupId:string可空；affectedEpisodeIds:Id[]非空；requiredByShotIds:Id[]非空 |
| AssetGroup | originProjectId:Id、name:string、assetCount/availableImageCount:int非空；名称保存快照，项目改名同步、删除后保留；id按作品身份，不按名称去重，无需额外分组表 |
| ProjectRef | projectId:Id、name:string非空；只返回当前用户/App有效引用作品 |
| ImageVersion | id/assetId:Id、sourceType/state:string、createdAt:Time、applied:bool非空；media:Media、jobId:Id、provider/model:string、succeededAt/expiresAt:Time可空；libraryAssetId/libraryImageVersionId:Id可空（PROJECT生成交付成功时必有自动入库目标，其他来源可空）；sourceImageVersionId:Id导入引用时必填；新导入仅选未到期且资源可读版本，既有有效作品引用仍保护文件，应用历史须资源可用 |

首图批量生成自动应用的范围/条件在报价里显示并固定；生成其他候选本身不修改共享图片。仅本集操作返回新bindingId/assetId，App替换本集状态并使相关镜头描述确认失效。素材资料/应用变化不重复生成旧视频或重复扣费。

T-16幂等落实：个人创建键/摘要及图片应用、删除回执随资产持久化，并与业务变更同事务。重放保持原资产身份，不重复建卡、不再次切换后续已经选定的图片，不复活已删资产；到期/删除状态仍按真实生命周期校验。普通资料PATCH只使用CAS版本。该内部存储补齐不新增接口或计费。

新上传绑定读取公共资源台账的真实`DIRECT_OSS_UPLOAD`来源，要求本人、OWNER、READY和`drama/asset-images`用途；不能把服务端生成的`DIRECT_BYTES`资源当作一次新上传来重设图片期限。已有生成/导入版本的读取和应用仍按原版本来源与独立截止执行。T-17继续负责真实上传完成、对象探测和字节校验，不以此元数据检查替代文件验收。

<a id="asset-library"></a>
**自动保存与分类**：项目素材图片成功交付包含自动个人入库，保存来源作品身份/名称并归入作品分类，组内沿用ROLE/SCENE/PROP与当前用户/App，不新增保存调用。查询资产列表/历史即可看到PROJECT_GENERATION来源和新版本；任务IMAGE结果仍指原项目图片版本，并从ImageVersion取得个人目标。UI分别展示“已保存到资产”与“待应用到本集”，查看资产跳转目标个人资产/图片历史。个人首图选用、同素材后续历史/去重、分类名称快照、失效不复活见[data-model自动入库](data-model.md#asset-library)。提交生成前提示自动入库，批量每项遵守同样规则；中途保存失败维持任务FINALIZING和进度，后台worker按已有检查点自动重试保存；App的“刷新保存进度”只查询原任务，不新发生成请求或增加人工重试任务接口。已终态失败并退回的任务不能借刷新重新生成或复活，需新一次生成时按原报价确认流程处理。任务尚未持久入库前不得返回已成功入库；后台原资源检查和公共账务补偿规则不变。

<a id="api-asset-description"></a>
### 7.1 免费资产描述帮写

> 本版增量：S-31/S-32，R-03，AC-03-09/10；T-47。只形成候选，不创建或修改Asset。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 恢复 |
|---|---|---|---|
| POST /api/drama/assets/description-jobs | A/I；AssetDescriptionJobCreate | Job，kind=ASSET_DESCRIPTION、financialState=FREE | 输入无效、同表单活动任务冲突、能力不可用及限流沿用§2；同键同请求返回原任务，同键异参冲突 |

| 类型 | 字段及约束 |
|---|---|
| AssetDescriptionJobCreate | clientFormId:UUID、formRevision:int≥1、kind:ROLE/SCENE/PROP、name:string1–20、description:string0–500均必填；description可空串；retryOfJobId:Id可空，仅明确FAILED后手动重试填写 |
| AssetDescriptionCandidate | clientFormId:UUID、formRevision:int、inputHash:string64HEX、description:string1–500；来源为提交时固定输入/模板；按Unicode标量计数，空白和超限结果失败，不截断 |

请求示例：
```json
{"clientFormId":"9a650ae2-599b-4b22-9c87-b6d1035d6b72","formRevision":3,"kind":"ROLE","name":"小白","description":"银白短发，黑色外套","retryOfJobId":null}
```

请求头携带独立UUID Idempotency-Key及X-App-Code: catdrama。成功Job.result.type=ASSET_DESCRIPTION，result.id为jobId，result.assetDescription为AssetDescriptionCandidate；inputHash使用实际SHA-256。既有Job成功结果仍可重复读取。

不要求先保存资产：job.targetType=USER、targetId从当前登录身份取得，不能由客户端指定；request_scope=clientFormId。同用户同表单同kind最多一个活动任务，不影响另一表单、图片任务或其他App。重复键恢复原任务；不同键但同表单已有活动任务返回活动冲突，App按kind=ASSET_DESCRIPTION、clientFormId、activeOnly=false查询恢复，不另建资产规避去重。

App提交前持久化原请求/键，受理后保存jobId；回执丢失先按原键查终态，后台确认未受理才重发原键原请求。已受理处理中/断网/未知仅续查；FAILED才允许手动新尝试，retryOfJobId须属于本人同表单FAILED任务。正常成功后主动再次帮写属于新请求；成功结果本机保存失败仅重取/重存。复用既有外呼未知、租约及检查点恢复，不能把查询失败或超时观测当明确FAILED后重复外呼。

模型只接收类型、名称、当前描述及固定模板，不分析参考图；复用公共AI通道，返回描述正文字符串（Markdown普通段落，不要求模型JSON或全剧结构标题）。先保存原文再校验候选；保存失败恢复检查点，不重调模型。免费任务quoteId/chargeOrderNo为空、financialState=FREE，复用现有限流。

候选只读。确认应用时App核对环境/账号/sessionEpoch、clientFormId、formRevision及类型/名称/原描述快照均一致，才替换表单并递增revision；输入变化令候选STALE，不能自动覆盖。取消保旧，保存资产仍走原创建/编辑及引用/共享规则，不应用图片、不触发成长、不续期作品。关闭表单不取消后台任务，重开同表单恢复；新表单/切账号不能混用。


<a id="api-8"></a>
## 8. 镜头、视频应用、报价与生成（新增）

> 本版改动：R-08、R-11、R-13、R-14、R-15、R-16、R-22、R-26。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/episodes/{episodeId}/shots | A；includeRemoved:bool默认false | Shot[] | —；响应数组包含E-SHOT |
| PATCH /api/drama/shots/{shotId} | A；ShotEdit | Shot | 001/007；`{"expectedRevision":2,"description":"少女在车站等待","bindingIds":["4001"],"productionSettings":null}`→E-SHOT |
| POST /api/drama/shots/{shotId}/description-ack | A/I；DescriptionAck | Shot | 001/008；`{"expectedRevision":3,"referencesRevision":2,"confirmed":true}`→E-SHOT |
| GET /api/drama/shots/{shotId}/videos | A；QPage | `Page<VideoVersion>` | —；items包含E-VIDEO |
| POST /api/drama/shots/{shotId}/videos/{versionId}/apply | A/I；VideoApply | VideoApplyResult | 001/012；确认后只更新源镜头指针 |
| POST /api/drama/generation/quotes | A；QuoteCreate | Quote | 001/013；E-QUOTE_REQUEST→E-QUOTE，可包含阻塞项但不冻结 |
| POST /api/drama/generation/tasks | A/I；GenerationCreate | Job | 001/005/006/007/008/009/-2001；`{"quoteId":"7001","inputHash":"64位SHA256","acknowledgedShotIds":[],"confirmed":true}`→E-JOB |

| 类型 | 字段、类型、必填/可空与约束 |
|---|---|
| SpeechSpec | mode:SPOKEN/NONE、utterances:Utterance[]非空；SPOKEN至少一条，NONE为空数组；镜头核对并保存，对白/旁白随视频生成，不另建TTS任务 |
| Utterance | speakerKind:CHARACTER/NARRATOR、text:string非空；CHARACTER的speakerName必填，tone:string可空；内容来自确认剧本及用户明确修改，声音描述不表示跨镜头音色一致性保证 |
| ShotEdit | expectedRevision:Revision必填；description:string1–1000、bindingIds:Id[]、speech:SpeechSpec、productionSettings:ProductionSettings可空/可选，至少改一项；bindingIds去重，提交后referencesManual=true，后续自动匹配不得覆盖；所有引用属于当前episode；server计算冲突，不接受客户端标记已核对 |
| DescriptionAck | expectedRevision:Revision、referencesRevision:Revision、confirmed:true必填；只确认当前描述/引用组合，之后变化立即失效 |
| Reference | bindingId/assetId:Id、kind/name:string、revision:int、available:bool非空；imageVersionId:Id、image:Media可空；缺图实际阻塞本次生成 |
| Shot | id/episodeId:Id、ordinal:int、sourceText/description:string、revision/referencesRevision:int、state:string、references:Reference[]、referencesManual:bool、speech:SpeechSpec、requiresDescriptionAck:bool、descriptionWarnings:string[]、canGenerate:bool非空；productionSettings:ProductionSettings可空；appliedVideo:VideoVersion、activeJob:Job可空；analysisScriptRevision:int非空 |
| VideoVersion | id/shotId/jobId:Id、state:string、applied:bool、inputSnapshot:VideoInput、createdAt:Time非空；media/cover:Media可空，SUCCEEDED时media和capabilitySnapshot:GenerationCapabilitySnapshot必填；provider/model/providerRequestId:string、succeededAt/expiresAt:Time可空 |
| VideoInput | shotRevision/referencesRevision/scriptRevision:int、sourceText/description:string、speech:SpeechSpec、references:Reference[]、productionSettings:ProductionSettings、pricingVersion:string非空；speech及能力版本参与inputHash；运行时签名地址不出现在此快照 |
| VideoApply | expectedRevision:Revision、confirmed:true必填；只更新镜头应用指针，本机剪辑修复由App处理 |
| VideoApplyResult | shot:Shot非空；无timeline/export响应，本机影响由App计算 |
| QuoteCreate | kind:IMAGE/VIDEO必填；targets:QuoteTarget[]去重1–Limits.batchTargets；productionSettings:ProductionSettings可空（视频必填或明确使用各shot保存值）；imageModel:ModelSelection可空（用服务端有效默认）；imageSettings:ImageSettings可空（由当前素材/项目风格或配置有效默认补齐并在报价展示）；QuoteTarget={type:ASSET/BINDING/SHOT,id:Id,expectedRevision:Revision}。mode:SINGLE/BATCH必填；SINGLE仅一目标，BATCH允许去重后只剩一目标，不能按数量猜应用规则，同共享asset去重成一项 |
| ImageSettings | styleCode:string非空且有效风格；尺寸/参考格式取有效图片模型配置，不把视频durationSeconds当图片参数；用户选择风格固定到本次图版本快照 |
| ModelSelection | providerCode/modelCode/contractVersion:string必填非空，必须有效场景，不允许任意厂商URL/密钥 |
| Quote | id:Id、kind:string、inputHash:string64HEX、pricingVersion:string、expiresAt:Time、items:QuoteItem[]、totalPoints:int≥0、canSubmit:bool非空；同次报价固定能力/价格/输入/共享影响范围 |
| QuoteItem | target:QuoteTarget、eligible:bool、blockers:Blocker[]、affectedEpisodes:EpisodeLabel[]、applyPolicy:FIRST_SUCCESS_IF_EMPTY/CANDIDATE_ONLY、unitPrice:UnitPrice、quantity:int>0、points:int≥0非空；sourceText/description:string、speech:SpeechSpec可空（VIDEO必填）；references:Reference[]非空；settings:ProductionSettings可空（VIDEO必填）；imageSettings:ImageSettings可空（IMAGE必填）；imageModel:ModelSelection可空（IMAGE必填，为服务端实际选定的供应商/型号/能力版本）；descriptionAckRequired:bool非空；IMAGE quantity=1，VIDEO quantity=请求秒数，points=unitPrice.points×quantity |
| Blocker | code:int、message:string、targetId:Id非空；只标参与镜头的实际引用；未使用无图素材不成为blocker |
| GenerationCreate | quoteId:Id、inputHash:string64HEX、confirmed:true、acknowledgedShotIds:Id[]必填；需要描述核对的shot必须全包含且revision未变；不接收客户端价格/素材地址 |

IMAGE批量只允许无已应用可用图、无可用待应用候选、无生成或入库保存中任务的去重目标；有效候选引导查看/应用，不重复收费。IMAGE单项即使首图也用CANDIDATE_ONLY；批量首图可FIRST_SUCCESS_IF_EMPTY，保存时核对输入/应用revision未变，避免覆盖后来手改。已用图重新生成必须单项明确确认并返回候选。所有报价有硬阻塞项时canSubmit=false，提交不冻结。描述核对用descriptionAckRequired提示确认页，提交必须提供对应acknowledgedShotIds，不将可当场确认的提醒混作永久硬阻塞。移除硬阻塞项重新报价，不能自动忽略或部分扣费。受理整批时同一事务锁定所有目标、核验余额、逐子项调用PointChargeService冻结，任一受理失败整批回滚；受理后各子任务独立结算/退回。

镜头应用只更新源版本，本机片段保持绑定旧视频；App提示新版本，由用户明确更新、处理裁剪越界后一次保存，可撤销。VIDEO首成功应用仍需输入版本一致且无当前应用。对白旁白随视频生成，报价冻结speech快照；需要口播而能力不支持时禁止提交，无音轨/损坏/全静音结果按失败处理，不以音轨存在冒充台词完整。


**2026-10-19 图片模型选择与默认视频：**图片确认页读取`RuntimeConfig.imageModels`，首次报价不指定时使用有效默认，之后按实际返回的`imageModel`展示选择。用户切换型号时重新报价并清空此前确认；配置失效不能静默改用另一型号。个人素材、作品素材及批量补图共用该入口。已提交或结果未知时继续恢复原任务，不允许以切换型号重新提交。后台以当前App默认项及启用的公开映射交叉校验型号；任务执行使用原型号/参数摘要，复用公共提示词、控制面、隐式标识、私有存储和账务。接口字段不新增。

默认视频由当前后台配置决定；本机改为`doubao-seedance / doubao-seedance-2-0-mini-260615`，规格来自Provider契约，当前为720P、4–15秒，初始10秒/16:9。H3保留为可选映射；原模型参数、能力版本和120积分/秒保持，已保存作品/旧任务不批量改写。Seedance尚无漫剧`videoAcceptance`样片依据时仍拒绝对应报价，不凭“已选默认”跳过生成验收门禁。

<a id="api-9"></a>
## 9. 剪辑准备与主动字幕识别

> 本版改动：R-16、R-18、R-20、R-21、R-26；S-25仅新增字幕音频识别。剪辑工程、字幕校对、撤销及成片留在手机，不提供后台剪辑保存或导出接口。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/episodes/{episodeId}/video-download-manifest | A；videoVersionIds:Id[] query可空，最多100个去重ID；不传时取本集当前可用已应用视频 | VideoDownloadManifest | 004/012；只返回本人本集源视频元数据，不保存本机时间轴或下载状态 |

| 类型 | 字段、约束 |
|---|---|
| VideoDownloadManifest | episodeId:Id、episodeRevision:int、manifestHash:string64HEX、videos:DownloadVideo[]、issuedAt:Time非空；无可用视频videos=[]。指定历史版本时校验有效作品归属/实际可下载性，单独标明不可用项 |
| DownloadVideo | shotId/videoVersionId/resourceId:Id、ordinal:int、sourceText:string、sizeBytes:int>0、sha256:string64HEX、durationMs:int>0、width/height:int>0、frameRate:Rational、capabilitySnapshot:GenerationCapabilitySnapshot、hasAudio:bool、available:bool非空；expiresAt:Time、unavailableReason:string可空。下载签名通过公共access-url取得，不保存签名URL为源身份 |

App先读取本机工程和文件索引。首次创建本机工程按当前可用已应用镜头的原剧本顺序准备源视频，至少一个片段；未生成镜头不阻止编辑；恢复已有工程仅核对该时间轴绑定的具体视频版本及其音轨/封面，确认作品仍有效且文件完整时进入P-19；已有有效作品快照可离线使用，不等待剪辑配置或本下载清单。只在必需源文件缺失、用户主动添加原镜头或确认更新视频版本时，联网取得所需源版本的元数据/签名并下载；下载接口只读源媒体，不接收/保存时间轴。删除后未被时间轴使用的可恢复镜头不构成进入门槛，添加时再下载。空间核算/进度/续传/取消及完整文件校验均在手机。

P-19只在主动获取字幕时上传混音并提交识别任务；P-19/P-20不读写后台时间轴、不初始化服务端剪辑、不发后台导出任务或上传成片。有效作品内已有完整本机工程可离线恢复、编辑和导出；源文件缺失时停在准备步骤，不用样例补齐。具体本机对象、命令及保存定义见[data-model§2](data-model.md#2-app-本地存储)。

<a id="api-subtitles"></a>
### 9.1 主动字幕识别任务

> 本版改动：R-20、R-26；S-25覆盖旧“端侧识别/不上传识别音频”，其他剪辑数据仍留本机。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| POST /api/drama/episodes/{episodeId}/subtitle-jobs | A、I；SubtitleJobCreate | Job（kind=SUBTITLE_RECOGNITION） | 003/004/005/012/013；E-SUBTITLE。先持久化任务与音频引用，再由worker执行，受理不代表完成 |

| 类型 | 字段、类型、可空与范围 |
|---|---|
| SubtitleJobCreate | audioResourceId:Id必填，为本人catdrama已完成上传的drama/subtitle-audio；clientEditorId:UUID必填，为本机工程身份而非工程内容；inputHash:string64HEX必填，为实际音轨及其版本快照指纹；speechRevision:int必填≥1，baseSubtitleRevision:int必填≥0；retryOfJobId:Id可空，仅失败后手动重试填写，须为同账号/同集/同clientEditorId的FAILED字幕任务 |
| SubtitleResult | jobId/episodeId:Id、clientEditorId:UUID、inputHash:string64HEX、speechRevision:int≥1、baseSubtitleRevision:int≥0、audioDurationMs:int>0、outcome:TRANSCRIBED/NO_SPEECH、cues:RecognizedCue[]、finishedAt:Time，均非空；TRANSCRIBED至少一cue，NO_SPEECH为空数组，属于识别结束而非可重提的FAILED |
| RecognizedCue | ordinal:int≥1且连续；text:string非空且≤500 Unicode标量；startMs/endMs:int，0≤startMs<endMs≤audioDurationMs，统一为音频起点后的毫秒，按startMs排序；不携带clipId、样式或客户端文件路径。过长文本按供应商有效分段规范拆分，无有效时段则结果校验失败，不凭剧本造时段 |

后台依据实际音频摘要固定任务输入与ASR模型，免费（financialState=FREE，所有扣费字段为空）。复用公共音频识别服务，不调用唱歌歌词业务或新增积分订单。同幂等键同请求返回原任务（先查既有键，再选新模型）；异请求报003。同一账号/集/clientEditorId只允许一个活动字幕任务，不同手机本机工程独立；重复动作查原任务，不能替换正在识别的输入。

App在第一次发请求前持久化原请求和幂等键；取得Job.id后只查询该任务。响应丢失时用§10的kind+idempotencyKey精确查询并包含终态；仅同schema主库查询明确未受理时允许补送原键原请求以恢复受理，不创建新逻辑请求，晚到并发由唯一键合并。已有任务的断网、查询超时、RUNNING、SUBMIT_UNKNOWN均继续查原任务；不得换键或重新提交Provider。只有服务端记录FAILED后，用户点击重试才使用新键及retryOfJobId；原任务/原结果保留。同输入再次请求但已有SUCCEEDED时直接恢复结果；用户编辑音轨形成新输入后再次主动获取属于新动作，仍须先结束旧活动任务。

字幕处理中使用不可关闭加载弹框，显示音频准备/上传/后台识别/获取结果阶段；没有真实百分比时只显示阶段，不虚构进度。尚未受理后台任务时，抽音频或上传失败结束当前等待并保留输入，重试只恢复失败准备/上传步骤；不据此创建第二个后台任务。OS切后台暂停页面查询，回前台/重启先恢复原任务号和弹框。成功先把SubtitleResult保存为本机候选；校验账号、clientEditorId、inputHash与两个revision再应用，跨切点由本机映射锚点。旧候选不能覆盖新音轨或手改，NO_SPEECH/失败保留旧字幕。取结果或本机保存失败只重取/重存同一结果，不再识别。无网时可继续编辑已有字幕和导出，不能新获取字幕。

上传音频从最后一个引用任务finishedAt起保留24小时；活动任务（含SUBMIT_UNKNOWN）始终保护，FAILED重试引用同文件后重新按最后终态计时。音频清理不删除已持久化SubtitleResult，结果在所属作品有效期间可重复获取；取回已受理任务允许读取必要终态，过期作品不能重新进入编辑或新建任务。任务终态幂等和必要审计元数据继续保留。音频/结果均不进入作品成片状态、不延长作品30天。

#### E-SUBTITLE

请求示例（Idempotency-Key为独立UUID请求头）：

```json
{"audioResourceId":"9101","clientEditorId":"56f6deba-6c8b-4f73-8cac-671db8f17751","inputHash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","speechRevision":3,"baseSubtitleRevision":1,"retryOfJobId":null}
```

任务成功后GET /api/drama/jobs/9201返回Job.result.type=SUBTITLE、id="9201"，subtitle包含：

```json
{"jobId":"9201","episodeId":"2001","clientEditorId":"56f6deba-6c8b-4f73-8cac-671db8f17751","inputHash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","speechRevision":3,"baseSubtitleRevision":1,"audioDurationMs":10000,"outcome":"TRANSCRIBED","cues":[{"ordinal":1,"text":"你终于来了。","startMs":800,"endMs":2100}],"finishedAt":"2026-10-13T12:00:00.000Z"}
```

### 9.2 公共ASR内部接口的兼容补强（拟实施，非HTTP）

> 本版改动：R-20、R-26。源码依据：DoubaoAsrModelProvider.submit当前在调用内随机生成UUID；AiControlPlaneExecutor在响应或AsrSubmissionUncertainException后保存任务号/账号映射。已具备查询与异常恢复入口，但尚未消除进程终止窗口。

保留现有AiModelCallService.submitAudioRecognition(model,audioUrl,language,paramsJson)签名和旧行为，新增带requestId的重载；AudioRecognizeCommand新增可空requestId并保留现有八参数构造兼容，AsrModelService向控制面及Provider透传。requestId为内部UUID字符串：catdrama必填并先写入自己的Job；旧调用为空时保持原行为，不作为HTTP客户端自选供应商任务号。

控制面增加可接受预分配requestId的submitAsrAsync重载。外呼前在短事务内登记当前App、已选provider/model、原账号/调用与requestId关联并提交，再执行网络请求；相同App/provider/requestId已有映射时恢复原调用，不重新分配账号或重复外呼。返回结果/未知提交异常须携带相同任务身份，queryAudioRecognition沿原映射查询。已有公共表/列承接，先核对现有唯一性与路由，不另建漫剧账号池或请求网关。

启用此路径的Provider必须支持预分配请求标识或等效的可靠查询身份；不支持时本App不启用该绑定，不能退回随机不可恢复提交。适配器须区分明确任务失败与查询/未知错误，不能把查询失败或未识别状态简单归为任务FAILED。旧公共调用及其他App用例必须回归；具体字段映射只在此处定义，技术方案和T-08引用本节。

验证中断位置：Job请求身份落库后、控制面原账号映射落库后、Provider受理后但响应未落库、标准化结果落库后但App未收到。重启均恢复相同身份，已受理识别只查询；不以缺少响应记录判定可以新提交。

<a id="api-10"></a>
## 10. 后台制作任务查询

> 本版改动：R-20、R-26。后台任务包含免费内容、资产描述帮写、素材分析、图片/镜头视频及字幕识别；音频准备/上传进度由App报告，合成编码进度只来自本机任务。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/jobs/{jobId} | A；— | Job | —；E-JOB |
| GET /api/drama/jobs | A；QPage、targetType:string可空、targetId:Id可空、activeOnly:bool默认true；kind:string（取data-model§3的JobKind枚举）、idempotencyKey:string（同提交键规则）、clientEditorId:UUID、clientFormId:UUID均可空 | `Page<Job>` | 本人任务恢复；精确恢复字幕必须kind=SUBTITLE_RECOGNITION且activeOnly=false；clientEditorId仅字幕筛选；clientFormId仅ASSET_DESCRIPTION按request_scope筛选。帮写恢复也须activeOnly=false；键对应无受理记录返回空items |
| GET /api/drama/jobs/{jobId}/children | A；QPage | `Page<Job>` | —；逐项结果/账务 |

| 类型 | 字段、约束 |
|---|---|
| Job | id:Id、kind/state/phase:string、targetType:string、targetId:Id、inputRevision:int、progress:int0–100、financialState:FREE/FROZEN/SETTLED/REFUNDED/RECONCILING、createdAt:Time、childSummary:ChildSummary非空；parentJobId/quoteId:Id、chargeOrderNo:string、reservedPoints/settledPoints/refundedPoints:int、startedAt/finishedAt:Time、errorCode:int/errorMessage:string、result:JobResult可空 |
| ChildSummary | total/running/succeeded/failed:int≥0非空；单任务全0，不重复累计父子账务 |
| JobResult | type:CONTENT_CANDIDATE/ANALYSIS/IMAGE/VIDEO/SUBTITLE/ASSET_DESCRIPTION、id:Id非空；document:ContentCandidate可空；subtitle:SubtitleResult仅SUBTITLE成功时非空，此时id为jobId；assetDescription:AssetDescriptionCandidate仅ASSET_DESCRIPTION成功时非空，id亦为jobId；其余GET读取正式对象 |

后台任务前台轮询初2秒，弱网退避5/10/30秒；App后台停止页面轮询，回前台查状态。后台AI任务不因OS切后台中止；字幕识别面板处理中不可关闭。手机剪辑任务以原生事件和本机持久记录恢复，不能用本节Job捏造本机进度。

<a id="api-11"></a>
## 11. 公共成长领取与邀请积分门面（新增）

> 两项成长和公共邀请继续按既有10积分/一次规则；剪辑器只在本机完成，本节不上传媒体或剪辑工程。

| 方法 / 路径 | 鉴权 / 请求 | data响应 | 错误 / 示例 |
|---|---|---|---|
| GET /api/drama/growth/tasks | A；— | GrowthTask[] | —；服务端已领状态与App本机首次导出事实组合展示 |
| POST /api/drama/growth/tasks/{taskCode}/claim | A/I；GrowthClaimRequest；FIRST_EXPORT/FIRST_PERSONAL_ASSET | GrowthClaim | 015；成功后刷新公共余额，领取网络失败不影响本机导出 |
| GET /api/drama/invite/points | A；— | InvitePoints | —；直接复用公共邀请积分进度 |
| POST /api/drama/invite/bind | A/I；InviteBind | InvitePoints | 公共无效码/关系冲突，失败保输入 |

| 类型 | 字段、约束 |
|---|---|
| GrowthTask | code:string、state:NOT_QUALIFIED/CLAIMABLE/CLAIMED、rewardPoints:int≥0非空；qualifiedAt/claimedAt:Time可空；FIRST_EXPORT未领取时App结合本机成功事实显示可领，不伪造服务端已领 |
| GrowthClaimRequest | FIRST_EXPORT带clientExportId:UUID、episodeId:Id，只有本机真实文件成功后任务入口才提交最小事实；FIRST_PERSONAL_ASSET无请求体。不传时间轴/字幕/音频/成片，后台不宣称校验了本机成片画面 |
| GrowthClaim | task:GrowthTask、account:PointAccount非空；每账号/taskCode一次，重复请求返回已领取 |
| InvitePoints | newInvitedCount/rewardedInviteCount/inviteRewardPoints:int≥0、registerRewardEnabled:bool非空，映射公共InviteTaskProgress |
| InviteBind | inviteCode:string4–32字母数字；用户/App由token决定，调用现有InviteDirectReadService.bind及InviteService.taskProgress |

首导出领取只校验账号、源episode归属及一次性奖励，资格申报/领取同事务；源已到期不抹掉曾成功的本机资格。账号taskCode唯一及稳定PointBizType/bizId保证不重复发奖。个人素材沿用后台真实保存应用事实，金额和资格不因删除或媒体到期重置。

邀请关系/发奖对象不改：首次有效绑定给邀请者10，当前请求用户不因此加10；分享/海报走公共materials/records，只展示积分，不新增现金流程。

<a id="api-12"></a>
## 12. 请求/响应示例与契约校验

> 本版改动：R-01至R-26。

示例为端到端主流程的代表对象；接口表中的E名称引用下面同名示例或相应类型，不要求重复定义字段。示例可省略可空/可选字段；返回必填字段由类型表要求，实施时OpenAPI及契约测试必须包含，不能把精简示例当完整返回字段集合。

### E-PUBLIC、E-LEDGER、E-PRODUCT、E-ORDER、E-ORDER_DETAIL、E-TASK_CENTER

```json
{
  "session":{"accessToken":"access-token-example","refreshToken":"refresh-token-example","profile":{"id":"101","phoneMasked":null,"inviteCode":"ABCD1234","pointsBalance":30,"vipStatus":"NONE","endAt":null,"cardType":null,"accountType":"GUEST"}},
  "ledger":{"id":"102","title":"首次创建账号","amount":30,"direction":"IN","createdAt":"2026-10-12T20:00:00","operation":"GRANT","bizType":"NEW_USER","bizId":"101"},
  "product":{"id":"points_1000","appCode":"catdrama","productCode":"points_1000","productName":"1000积分","productType":"POINTS","purchaseType":"CONSUMABLE","requiresActiveSubscription":false,"amountCents":1000,"priceText":"10元","priority":1,"pointsAmount":1000},
  "orderPayment":{"orderNo":"063000000000000000000000000001","channel":"IOS","amountCents":1000,"payParams":{"productId":"本App真实StoreKit商品ID"}},
  "orderDetail":{"orderNo":"063000000000000000000000000001","appCode":"catdrama","userId":101,"productId":"points_1000","productCode":"points_1000","productType":"POINTS","productName":"1000积分","pointsAmount":1000,"amountCents":1000,"currency":"CNY","channel":"IOS","status":"PENDING"},
  "taskCenter":{"enabled":true,"totalPoints":30,"checkIn":{"signedToday":false,"consecutiveDays":0,"cycleDay":1,"todayRewardPoints":3,"days":[]},"dailyTasks":[]}
}
```

### E-CONFIG、E-CASE

```json
{
  "config":{"appCode":"catdrama","configVersion":"cfg-1","currency":"CNY","retentionDays":30,"enabled":true,"videoModels":[],"imageModels":[],"styles":[],"defaults":null,"publicTimestampZone":null},
  "case":{"id":"example-case","title":"案例标题","categoryCode":"COMEDY","description":"演示内容","styleCode":"ANIME","reusableStyle":true,"video":null,"cover":null}
}
```

### E-DRAFT_CREATE、E-DRAFT_SAVE、E-DRAFT、E-CONTENT_TASK

```json
{
  "create":{"clientDraftId":"11111111-1111-4111-8111-111111111111","sourceType":"EXISTING_SCRIPT","name":"车站重逢","originalText":"第一集\n少女在车站等待。","splitMode":"AUTO"},
  "save":{"expectedRevision":1,"name":"车站重逢","sourceType":"EXISTING_SCRIPT","originalText":"第一集\n少女在车站等待。","splitMode":"AUTO","requestedEpisodeCount":null,"story":null,"screenplays":null,"productionSettings":null},
  "draft":{"id":"1001","clientDraftId":"11111111-1111-4111-8111-111111111111","revision":2,"sourceRevision":1,"storyRevision":0,"screenplaysRevision":0,"name":"车站重逢","sourceType":"EXISTING_SCRIPT","originalText":"第一集\n少女在车站等待。","splitMode":"AUTO","state":"EDITING","storyValid":false,"screenplaysValid":false,"activeJobs":[],"expiresAt":"2026-11-11T12:00:00Z"},
  "contentTask":{"expectedRevision":2,"target":"SCREENPLAYS","overwriteConfirmed":false}
}
```

### E-CONTENT_CANDIDATE（HTTP响应中的data.result.document）

以下JSON由后端组装；模型只输出其中markdown字符串的实际多行内容。

```json
{
  "target":"SCREENPLAYS",
  "draftId":"1001",
  "sourceRevision":1,
  "targetBaseRevision":0,
  "stale":false,
  "screenplays":[{"ordinal":1,"title":"车站重逢","text":"少女在车站等待。\n**少女：** 你终于来了。"}],
  "markdownDocuments":[{"stepKey":"screenplays_all","formatVersion":"markdown-v1","markdown":"# 逐集剧本\n## 第1集：车站重逢\n少女在车站等待。\n**少女：** 你终于来了。"}]
}
```

### E-PROJECT_CREATE、E-PROJECT、E-EPISODE、E-ANALYSIS

E-PROJECT_CREATE：

```json
{"draftId":"1001","expectedDraftRevision":3,"screenplaysRevision":2}
```

重复确认返回同一ProjectCreated，不自动受理analysisJob。以下示例为字段节选，实际响应遵守上文完整类型。

E-ANALYSIS仅展示差异字段，省略`markdownDocuments`的原文展开；真实完成响应必须包含候选所依赖的有效MarkdownDocument。

```json
{
  "project":{"id":"2000","name":"车站重逢","revision":1,"state":"ACTIVE","episodeCount":1,"episodes":[],"expiresAt":"2026-11-11T12:10:00Z"},
  "episode":{"id":"2001","projectId":"2000","ordinal":1,"displayNumber":1,"title":"第一集","text":"少女在车站等待。","revision":1,"scriptRevision":1,"analyzedScriptRevision":null,"analysisOutdated":true,"state":"ACTIVE","activeJobs":[]},
  "analysis":{"id":"2101","episodeId":"2001","scriptRevision":2,"baseEpisodeRevision":3,"state":"CANDIDATE","added":[{"action":"ADD","candidateKey":"new-shot-1","sourceText":"信封落在地上。","description":"信封落地特写","ordinal":2,"existingShotId":null,"appliedVideo":null,"references":[]}],"kept":[],"removed":[],"assetChanges":[],"counts":{"added":1,"kept":0,"removed":0}}
}
```

### E-ASSET、E-IMAGE、E-BINDING、E-BINDINGS、E-SCOPE、E-SCOPED_EDIT、E-SCOPE_CONFIRM、E-SCOPE_APPLIED

```json
{
  "asset":{"id":"3001","scope":"PERSONAL","kind":"ROLE","name":"小喵","description":"黄色外套少女","state":"READY","sourceType":"UPLOAD","revision":3,"canImport":true,"canDelete":false,"referencingProjects":[{"id":"2000","name":"车站重逢","expiresAt":"2026-11-11T12:10:00Z"}],"appliedImage":{"id":"3101","assetId":"3001","state":"SUCCEEDED","sourceType":"UPLOAD","applied":true,"media":{"resourceId":"9001","state":"SUCCEEDED"}}},
  "binding":{"id":"4001","episodeId":"2001","assetId":"3002","revision":2,"shared":true,"detached":false,"archived":false,"sharingGroupId":"shared-1","affectedEpisodeIds":["2001","2002"],"requiredByShotIds":["5001"]},
  "scope":{"bindingId":"4001","assetId":"3002","revision":2,"scopeVersion":"scope-2","shared":true,"episodes":[{"id":"2001","displayNumber":1,"title":"第一集"},{"id":"2002","displayNumber":2,"title":"第二集"}],"fields":["name","description","appliedImage"],"affectedShotIds":["5001"]},
  "scopedEdit":{"expectedRevision":2,"scope":"CURRENT_EPISODE","scopeVersion":"scope-2","affectedEpisodeIds":["2001"],"description":"红色外套少女"},
  "scopeConfirm":{"expectedRevision":2,"scope":"SHARED","scopeVersion":"scope-2","affectedEpisodeIds":["2001","2002"]},
  "scopeApplied":{"affectedEpisodeIds":["2001"],"affectedShotIds":["5001"],"detached":true}
}
```

E-IMAGE取asset.appliedImage，E-BINDINGS为Binding数组；ScopeApplied.binding按完整Binding类型返回。示意shared-1在实际sharingGroupId使用服务端UUID。

### E-SHOT、E-VIDEO、E-QUOTE_REQUEST、E-QUOTE

以下为字段节选；720P/24fps是示例文件规格，实际值按所用版本能力快照核对，不是统一承诺。

```json
{
  "quoteRequest":{"kind":"VIDEO","mode":"SINGLE","targets":[{"type":"SHOT","id":"5001","expectedRevision":3}],"productionSettings":{"providerCode":"配置中的真实渠道","modelCode":"配置中的真实模型","contractVersion":"cap-1","resolution":"720P","durationSeconds":10,"aspectRatio":"16:9","styleCode":"ANIME"}},
  "quote":{"id":"7001","kind":"VIDEO","inputHash":"0000000000000000000000000000000000000000000000000000000000000000","pricingVersion":"price-1","expiresAt":"2026-10-12T12:05:00Z","totalPoints":1200,"canSubmit":true,"items":[{"target":{"type":"SHOT","id":"5001","expectedRevision":3},"eligible":true,"blockers":[],"sourceText":"少女在车站等待。","description":"少女侧身站在站台","references":[],"affectedEpisodes":[],"applyPolicy":"FIRST_SUCCESS_IF_EMPTY","unitPrice":{"points":120,"unit":"SECOND","pricingVersion":"price-1"},"quantity":10,"points":1200,"descriptionAckRequired":false}]},
  "shot":{"id":"5001","episodeId":"2001","ordinal":1,"sourceText":"少女在车站等待。","description":"少女侧身站在站台","revision":3,"referencesRevision":2,"referencesManual":false,"speech":{"mode":"NONE","utterances":[]},"state":"ACTIVE","references":[],"requiresDescriptionAck":false,"descriptionWarnings":[],"canGenerate":true,"analysisScriptRevision":1},
  "video":{"id":"6001","shotId":"5001","jobId":"7101","state":"SUCCEEDED","applied":true,"media":{"resourceId":"9101","state":"SUCCEEDED","sizeBytes":20000000,"sha256":"2222222222222222222222222222222222222222222222222222222222222222","durationMs":10000,"width":1280,"height":720,"frameRate":{"numerator":24,"denominator":1},"hasAudio":true}}
}
```

### E-JOB、E-GROWTH

```json
{
  "job": {
    "id": "7101",
    "kind": "VIDEO",
    "state": "RUNNING",
    "phase": "POLL_PROVIDER",
    "targetType": "SHOT",
    "targetId": "5001",
    "inputRevision": 3,
    "progress": 40,
    "financialState": "FROZEN",
    "createdAt": "2026-10-13T12:00:00Z",
    "childSummary": {
      "total": 0,
      "running": 0,
      "succeeded": 0,
      "failed": 0
    }
  },
  "growth": [
    {
      "code": "FIRST_EXPORT",
      "state": "NOT_QUALIFIED",
      "rewardPoints": 10,
      "qualifiedAt": null,
      "claimedAt": null
    }
  ]
}
```

### E-UPLOAD_REQUEST、E-UPLOAD_TICKET、E-UPLOAD_COMPLETE

```json
{
  "prepare":{"filename":"role.png","contentType":"image/png","sizeBytes":102400,"resourceType":"drama/asset-images","uploadMode":"OSS_PUT_SIGNED_URL"},
  "ticket":{"uploadToken":"临时上传票据","uploadMode":"OSS_PUT_SIGNED_URL","uploadUrl":"OSS短期签名上传地址","method":"PUT","headers":{"Content-Type":"image/png"},"formFields":{},"objectKey":"private/catdrama/当前用户/drama/asset-images/随机文件.png","expiresAt":"2026-10-12T20:10:00","status":"READY"},
  "complete":{"uploadToken":"临时上传票据","resourceType":"drama/asset-images","objectKey":"private/catdrama/当前用户/drama/asset-images/随机文件.png","sizeBytes":102400,"contentType":"image/png"}
}
```

### 开发阶段契约验证

OpenAPI为完整定义，前后端模型由本契约对照；验证所有新ID字符串、空值/单位/时区/分页/错误码、Quote实际参与项与总价、CAS/幂等冲突、所有者和App校验、旧公共响应解析。真实渠道验证分别留证，Mock或schema生成不证明SMS、StoreKit、Provider、ASR或导出成功。

文本任务另验证：6份模板均直接返回Markdown；标题层级/必需段落/重复编号/空白/超限/截断拒绝；单集与多集结果数量正确；来源锚点歧义和杜撰引用不应用；原文留存及正文字符一致；全剧剧本不按集拆请求，失败整次重试；分析才按成功步骤复用；重试固定原模板；迟到结果不覆盖手改；App渲染后再保存不改正文。

字幕契约验证：原键受理恢复、同工程活动任务互斥、不同设备工程隔离、FAILED手动新尝试、未知状态只查、NO_SPEECH保旧、成功结果可重取、时间戳单位/边界、音频24小时及活动引用保护、无积分订单。字段和示例只在本文件维护。

本轮追加契约验证：帮写500字边界、同表单并发、同键异参、原键恢复终态、FAILED新尝试、成功保存失败、跨App/用户/表单隔离、手改保护；见T-47及TC-03-09/10、TC-X31。相册视频提取仅有本机接口[data-model§2.3](data-model.md#source-audio-extraction)，不添加HTTP上传或提取路由。

### 2026-10-15 私有媒体及缓存补充（S-33/D-52）

喵喵漫剧的图片、视频和音频在OSS统一使用私有对象，包括已发布系统素材及案例。PUBLIC仅表示业务上允许公开获取，不代表OSS公共读；客户端经现有资源访问接口取得临时签名，签名过程不探测OSS对象。缓存以resourceId作为资源身份，目录继续隔离App、环境、服务端及账号；签名URL和有效期变化不重复缓存。缓存未命中或文件失效才下载，过期签名重新取签名，不重建资源。资源ID与内容版本一一对应，替换媒体产生新的resourceId；业务保留期和引用校验不因存在本机缓存而绕过。

复用ResourceServiceImpl、ResourceAccessUrlService及App ResourceService；不另建签名API。签名URL只保留当次读取/下载会话，不进业务快照或缓存账本。上传完成、源媒体交付时的实际内容/归属校验仍执行，不能因签名无需访问OSS而省略。资源版本保持不可变；不得覆盖同resourceId所指文件。旧公开对象如需调整实际ACL，需具备本项目资源台账及目标环境后另执行，不在本轮静默修改生产Bucket或其他App。


### T-17 图片上传实现核对（2026-10-15）

`drama/asset-images`与`drama/cover-images`已登记到公共prepare/complete校验与OpenAPI。只在catdrama受理，私有PUT，完成前按10MiB限量读取并真实解码PNG/JPEG/WebP、核对大小/MIME及可选MD5；返回resourceId。相同objectKey重复完成返回同一资源与原创建时间，声明变化拒绝；新objectKey即新资源，即使字节相同也不跨用户共享。图片有效期由版本规则控制，重复确认不重设。其他媒体类型按后续任务登记，不能据此将字幕/镜头直传标为完成。

### T-08字幕契约实现核对（2026-10-15）

§9.1的POST与SubtitleJobCreate/SubtitleResult/RecognizedCue已实现，继续复用本人Job查询。严格字符串ID/UUID/64HEX/整数版本，未知字段或JSON类型错误返回400；目标或资源归属/用途不符不受理。同键先恢复旧请求，再判断当前配置与媒体；同输入已成功可重取，不再识别。固定实际WAV摘要/字节/时长、原模型与本机版本；后台不读取或应用工程。公共门面追加只读`supportsRecoverableSubtitleRecognition`检查异步身份及毫秒分段能力，旧公共调用兼容。

本轮26项新增、214项相关后端通过，0失败/跳过。真实ASR/OSS和手机T-33仍待验收；默认发布开关关闭。此前“拟实施”属于成稿时状态，当前以[T-08实际检测](../05-测试/evidence/T-08/result.json)与[T-45公共恢复](../05-测试/evidence/T-45/result.json)为准，无新增其他HTTP路由。

**2026-10-19 T-26 技术同步（U-20261019-VIDEO）：**`DramaVideoModelOptionsService`只读复用公共模型配置/场景映射及`AiModelCallService.describeVideoGeneration`，不依赖带货业务类、不按本机默认密钥目录硬编码全部平台模型。合法组合和契约摘要按真实Provider能力、有效风格及参考图边界形成，公开响应不带渠道私密参数；报价与原任务恢复按冻结模型身份核实。现有`ProductionSettings`字符串/整数类型保持，取消720P/1080P与10/15/30秒固定枚举。原生P类清晰度对应真实短边像素；内部样片验收允许显式、据样片确定的`maximumAspectErrorPixels`，旧快照缺失取0，仍精确核对已验证的尺寸、编码和帧率，不转成虚假高清。对白/旁白以有序确认清单拼入捕获提示词，无口播不重建原文台词；不增加AI请求、独立TTS或字幕前置生成。原任务未知状态只查询原任务。

本地配置：H3/768P/10秒/16:9/ANIME已接通，样片实际1344×768、24fps、10.125秒及AAC音轨；像素对齐值22仅对应该样片配置。其他模型/规格依各自配置与验收依据开放，完整App和逐字声音验收仍未完成。数据库结构/Entity/迁移无改动；本地只新增catdrama视频绑定、更新drama.production与drama.features，私密配置及积分账务未改。


## 视频编辑参数保存范围（2026-10-28）

当前镜头沿用 `PATCH /api/drama/shots/{shotId}`，body 仅 expectedRevision（镜头正整数版本）和 productionSettings。新增 `PUT /api/drama/episodes/{episodeId}/shot-settings`，body 为 expectedRevision（分集聚合正整数版本）和非空 productionSettings，响应 `ApiResponse<List<DramaShotResponse>>` 按镜头顺序返回全部有效镜头。参数复用 providerCode/modelCode/contractVersion/resolution/durationSeconds/aspectRatio/styleCode，durationSeconds 是上限。

登录和 X-App-Code: catdrama 沿既有机制。父作品事务锁下校验归属、有效分集及版本，验证全部镜头模型/声音/明确参考图上限，再统一保存覆盖及核对状态，一次更新分集版本；异常全部回滚。复用 BAD_REQUEST、NOT_FOUND、CATDRAMA_REVISION_CONFLICT、CATDRAMA_OBJECT_EXPIRED、CATDRAMA_CAPABILITY_UNAVAILABLE、CATDRAMA_REFERENCE_INVALID，提示具体镜头和修正方式。

客户端草稿隔离账号/环境/作品/集/镜头。未知结果先查询；冲突保留选择并再次确认；成功清除受影响镜头的旧参数草稿，保留描述/素材草稿和既有真实冲突。原视频和任务快照不变。
