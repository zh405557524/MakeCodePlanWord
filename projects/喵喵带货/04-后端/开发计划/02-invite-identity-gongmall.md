# Java 模块 02：实名电签、银行卡加密与共享工猫适配

## 2026-09-02 灵活用工协议只读接口

- 新增共享 `GET /api/invite/agreements/flexible-employment`，要求 JWT、`X-App-Code` 和当前邀请能力；每次复用现有 `GongmallGateway → GongmallClient → HttpCallClient` 调用 `contract/getList`，不增加 API PATH 白名单、网络框架或配置。
- 模板解析统一读取 `templateId/templateName/platformCompanyName/contractAddr`；实名创建继续使用同次查询的 `templateId`。查看接口要求唯一模板和安全 HTTPS 地址，相对地址按当前工猫网关解析。
- 响应只含标题、短期 URL 和 `expiresInSeconds=3600`，设置 `Cache-Control: no-store`。空/多模板、业务失败、地址缺失或危险 URL 继续返回 `-7117 / HTTP 503`；短期地址及查询参数不写普通日志。
- 接口只读，不创建认证会话、不写数据库、不缓存或回退历史地址。数据库改动：无；本轮不改工猫配置、不部署、不真实签约。

## 2026-09-01 实名电签自动确认修复

- 新增 `GET .../status`，并将创建后复核、合同回调、定时任务全部改为只查合同状态；这些路径不调用signContract、不写confirmed_at。
- `POST .../confirm` 改为必填43位state，摘要匹配当前App/用户会话后才签约；合法H5_RETURN Inbox复用同一App+session锁及confirmed_at幂等边界，重复/并发最多提交一次。
- 资格排除CREATING/RETRY和无provider_flow_id会话；失败会话保留，同主体重试按原逻辑SUPERSEDED。400/409/503及未完成200语义已写入Controller/OpenAPI测试。
- 数据库结构与存量数据不改，不清会话、不部署、不调用真实工猫；真实渠道和双平台回跳仍为waiting_review。

## 2026-08-31 OSS 签名地址读取修复

- 共享 HTTP 的普通/文件发送入口改用 `URI.create` 后的 URI，防止 Spring 字符串模板重复编码已签名地址；不修改 OSS/工猫配置和认证、绑卡、资金规则。数据库改动：无。
- 图片仍为当前App本人私有资源；HTTPS、大小/MIME/ETag校验、禁止重定向和敏感日志限制保留。读取照片的网络日志标识为 `gongmall-id-photo`，与后续工猫 `gongmall` 区分。
- 状态 `waiting_review`；新增8项回归，HTTP/工猫/邀请等专项301项通过；全量1672项中1668通过、1项既有视频批次失败、3跳过，不能宣称全量通过。详细验证和复验边界见 [本次验证记录](../../05-联调与测试/invite-identity-bank-split-verification.md#2026-08-31-补充oss-签名地址重复编码修复)。未自动重启或部署，其他CHG和此前拆分状态不变。

## 2026-08-31 最新增量：实名认证与银行卡绑定拆分

用户已确认本次计划并授权开发，本地实现状态 `waiting_review`。本节优先于下方历史合并认证说明，其他CHG及已确认基线状态不变。

- Figma通道 `eeis7852`：P06 `66:120`，P10 `66:198`。P05打开不跳页；用户点击后按最新资格：未实名→P06、已实名无ACTIVE卡→P10、有卡→原提现。
- P06只填写姓名、大陆身份证、手机号及两面私有照片，类型 `invite/id-card-images`，≤3MiB，complete=READY后只提交resourceId。支持相机/相册、预览/替换、进度/重试；只清理本流程临时副本，不删相册、不长期缓存。
- 校验真实出生日期、身份证校验码、18–65周岁；61–65仍需工猫商户渠道验收，不绕过渠道拒绝。
- 认证只维护实名和会话，不建银行卡；syncInfo不传卡号。创建/确认返回 `identityReady` 替代 `ready`，删除 `bankAccount`；主动查合同2/3才成功，旧PENDING卡不自动激活。
- 认证成功自动返回提现页并刷新，等待用户点击“去绑定”。P10 `/invite/bank-bind` 重填四项资料、同意当前协议；不重复照片、H5或短信。
- POST bank-accounts先核对当前App的姓名、身份证和手机号；不一致不调用工猫。用户级Redis锁+同卡HMAC去重，短事务准备→事务外updateEmployee→严格success=true后短事务激活；有效同卡直接返回，未知PENDING可显式重试同卡，不自动重试；首张有效卡默认，新增不覆盖默认。
- 绑卡只接受ACTIVE为成功，提示后返回P05刷新；失败保留可编辑表单，成功/离页清除敏感输入。未签署、仅登记或PENDING绝不显示成功。
- H5权限、白名单开关、回跳查询和银行卡ID解析修复保留；不变更Admin、其他App页面、佣金/退款/打款。
- 业务与工猫配置共享，所有实名/照片/银行卡/会话/资金按App隔离。数据库：有持久化行为调整，但无新增表、字段、索引或SQL/Flyway；bank_account_id已可空。不处理历史数据、不调整余额、不部署或真实签约/提现。


验证、截图与真实渠道边界见 [拆分验证](../../05-联调与测试/invite-identity-bank-split-verification.md)。


## 2026-08-28 H5 开关实现增量

- 新增平台共享 `app.gongmall.h5-allowed-hosts-enabled`，默认 true；TEST/PRODUCTION 可显式 false；环境变量 `GONGMALL_H5_ALLOWED_HOSTS_ENABLED`。本机私有配置默认 false，服务器不改。
- `GongmallConfigurationService` 的配置就绪检查和 URL 检查使用同一开关；关闭只跳过列表检查，HTTPS、合法域名、443、无用户信息/fragment 以及其他凭据、BANK、业务资格不变。
- 原创建/确认认证接口和工猫连接状态新增布尔 `h5AllowedHostsEnabled`，关闭时 session 返回空 `allowedHosts`。启动警告不调用工猫；获得 `authUrl` 后只记录域名，不记 URL/令牌/个人资料，不自动追加名单。
- 数据库改动：无。未修改正常认证持久化、合同确认和资金状态机，未部署、未真实签约/提现。配置、离线 HTTP/OpenAPI、日志及回归结果见 [本次验证](../../05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-工猫-h5-域名白名单开关)。当前 waiting_review，不将已有其他 CHG 状态覆盖。

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-B005`、`T-B006`
> 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位与边界

建立可逆加密的实名档案、认证会话、多银行卡档案和平台共享工猫 Gateway，支持员工同步、H5 电签、合同查询、试算、BANK 提现与原 requestId 查单。不实现银行卡短信验证码，不在 App 配置存商户 secret，不将工猫原始状态泄漏到 Controller。

## 2. Controller / Service / Mapper / Entity 清单

- 业务：`InviteIdentityApplicationService`、`InviteSensitiveDataService`、`InviteBankAccountService`。
- 基础设施：`GongmallClient`、`GongmallSignatureService`、`GongmallEncryptionService`、`GongmallIdentityGateway`、`GongmallWithdrawalGateway`。
- Entity/Repository：`InviteIdentityProfile`、`InviteIdentitySession`、`InviteBankAccount`、平台 `GongmallRouteBinding`。
- HTTP Controller 由 [03-invite-user-api-withdrawal.md](./03-invite-user-api-withdrawal.md) 提供；本模块不直接返回 provider DTO。

## 3. 接口合同

用户端契约（由 T-B007 暴露）：

所有用户请求要求 JWT 与 `X-App-Code`，并校验 session/card 的当前 App、当前用户归属；普通错误复用 `BAD_REQUEST/UNAUTHORIZED`。Flutter 对应：[实名电签、银行卡与提现申请](../../03-前端/开发计划/03-invite-withdrawal-auth.md)。

| 方法与路径 | 请求 | 响应 | 错误 |
|------------|------|------|------|
| `GET /api/invite/agreements/flexible-employment` | JWT + `X-App-Code` | 标题、一小时HTTPS地址、3600秒 | 模板/地址不可用统一-7117/503；no-store |
| `POST /api/invite/identity-sessions` | 姓名/身份证/手机、两私有照片resourceId、协议 | session/H5/contractStatus/identityReady | 不建银行卡；格式/资源/年龄/主体/配置错误拒绝 |
| `GET /api/invite/identity-sessions/{sessionId}/status` | 无 | 只查合同；2/3才identityReady，无卡依赖 | 无合同号/不可确认409，工猫故障503 |
| `POST /api/invite/identity-sessions/{sessionId}/confirm` | 43位state | 摘要匹配后最多签约一次，再查合同 | 格式400；不匹配/过期/不可确认409；工猫故障503 |
| `GET /api/invite/bank-accounts` | 无 | ID、银行、尾号、脱敏卡号、默认标记 | 不返回密文/明文 |
| `POST /api/invite/bank-accounts` | 四项本人资料及协议 | 明确成功才ACTIVE脱敏卡 | 未实名/不匹配/并发/拒绝或未知；不调用H5 |

Gateway 业务契约：

```java
interface GongmallIdentityGateway {
    EmployeeSyncResult syncEmployee(EmployeeSyncCommand command);
    ContractSessionResult createContractSession(ContractSessionCommand command);
    ContractStatusResult queryContract(String providerSessionId);
    ContractStatusResult confirmReturnedContract(String providerSessionId, String state);
}

interface GongmallWithdrawalGateway {
    WithdrawalQuoteResult quote(WithdrawalQuoteCommand command);
    WithdrawalSubmitResult submit(WithdrawalSubmitCommand command);
    WithdrawalQueryResult queryByOriginalRequestId(String requestId);
}
```

## 4. 数据表与迁移

原模块建表已存在。本次只有持久化行为调整，无SQL/Flyway改动；复用下列表，认证会话bank_account_id为NULL，绑定阶段才维护卡；不处理存量数据。

- `invite_identity_profiles`：用户唯一，实名/合同状态、provider 标识、协议版本/时间、姓名/证件/手机信封密文、mask、HMAC、key version。
- `invite_identity_sessions`：业务 session、随机 state/摘要、H5 URL 摘要、过期/确认时间。
- `invite_bank_accounts`：卡号密文/HMAC/mask、银行、provider 标识、active/default；同 profile 活跃卡 HMAC 唯一。
- `platform.gongmall_route_bindings`：合同 session/state 绑定 App Code 与业务 ID。

## 5. 业务规则与状态流转

1. 敏感请求入参通过格式/业务校验后，用 AES-256-GCM 信封加密落库，HMAC+pepper 做精确去重，普通响应只用 mask。
2. 调工猫时将姓名/证件/手机/卡号按协议 RSA-2048 加密，与数据库静态加密分开。
3. 先员工同步、再创建合同H5；页面/回调/定时恢复只查合同，只有合法state回跳confirm可提交签约，仍不信任页面成功文案。
4. 本地合同态：未同步、待签署、合同生成中、已完成；工猫 2/3 映射为可提现候选，正式环境是否只放行 3 由上线合同确认。
5. 实名完成后主体锁定；新增卡仍必须属于同一 profile。

## 6. 工猫协议与异常处理

- 表单 POST `application/x-www-form-urlencoded`；参数按官方规范拼接，加平台共享 `appSecret`，输出大写 MD5。
- 请求有效期 5 分钟；NTP/时钟偏移异常时禁止盲目提交资金请求。
- 状态集中映射为 `ACCEPTED/PROCESSING/SUCCEEDED/DEFINITIVE_FAILED/UNKNOWN/RETURNED`；未知不等于失败。
- 日志只记接口名、requestId/sessionId、耗时、HTTP/业务码和脱敏摘要，禁止待签名原串、secret、私钥和敏感参数。

## 7. 依赖前置

- 平台商户号、appSecret、私钥、工猫公钥、主体与key version通过既有安全配置注入；模板实时getList查询，不新增template-id配置。
- 需确认官方字段、签名串、RSA 分段/编码和状态映射，不以文档猜测值上线。

## 8. 建议实现步骤

1. 实现 AES-GCM 信封加密/HMAC/mask 与 key version 轮换测试。
2. 实现 identity/session/bank Repository 和领域状态。
3. 用官方向量实现表单、大写 MD5、RSA 和安全日志。
4. 实现 Identity/Withdrawal Gateway 及统一 provider 状态映射。
5. 实现员工同步、H5 session、confirm/query 和路由绑定。

## 9. 详细编码任务清单

- [x] `T-B005-01` 实现可逆加密、HMAC、脱敏、密钥版本与严禁明文日志。
- [x] `T-B005-02` 实现 identity/session/bank 档案、默认卡与软停用。
- [x] `T-B006-01` 实现工猫签名/RSA/时钟/安全 HTTP 客户端。
- [x] `T-B006-02` 实现员工、合同、quote、提现和查单 Gateway。

## 10. 测试要求

- 单元：AES-GCM 篡改拒绝、HMAC、mask、签名顺序/大写 MD5、RSA key version、5 分钟。
- 集成：重复建 session、H5 confirm、合同生成中、同卡去重、跨用户/App 拒绝。
- 安全：响应/日志/OpenAPI 无明文、密钥和原始报文。

## 11. 验收标准

1. 普通数据库查询只得到密文/mask，只有受权服务可解密。
2. 多 App 共用一套工猫连接，但每个 session/requestId 都有明确 App 路由。
3. 合同数字状态只在 Gateway 映射，业务层无散落判断。
4. 官方向量、超时/未知、密钥轮换和日志脱敏测试通过。

## 12. 编码注意事项

工猫 DTO 只存在适配层，网络异常不得直接转为资金失败。密钥不写代码、文档、普通配置、测试 fixture 或错误输出。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
