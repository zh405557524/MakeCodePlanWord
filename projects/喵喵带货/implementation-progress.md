# 邀请好友与银行卡提现：三端编码恢复点

## 2026-09-02 当前增量：邀请记录已开通状态

`GET /api/invite/records` 的真实列表项返回 `memberCommissionStatus=OPENED/NOT_OPENED`，Catseller 原行内标签只识别旧值 `SETTLED`，造成“已开通” Tab 里记录仍标记“未开通”。已在 `InviteRecord` 统一判断当前 `OPENED` 与旧版 `SETTLED`，View 共用该结果；测试夹具同步为真实合同值并保留旧值回归。

本地邀请专项 53 项、指定 Widget 筛选用例、`flutter analyze --no-pub` 和差异检查通过。后端、数据库、配置、运行服务及其他 App 未修改；更新 App 后真实接口/真机复验待执行。

## 2026-09-02 当前增量：邀请记录好友手机号

共享 `GET /api/invite/records` 已增加可空的 `inviteePhoneMasked`：后端按当前页受邀用户 ID，在当前请求 App schema 内批量查询并复用统一脱敏逻辑；不增加 Catseller 分支、App 白名单或跨 schema 扫描。Catseller P03 优先显示“138 **** 1234”，字段为空时保留原 `inviteeName` 兜底；其他 App 客户端未修改。

数据库改动：无。后端邀请集成 69 项、Catseller 邀请页面 48 项和静态分析通过；`06-invite-records` 375×812 Golden 与 Figma `43:2222` 同轮复核通过。后端完整测试仍在无关 `SongWorkLifecycleIntegrationTests` 发生 JVM OOM，并连带无法写出部分 XML 结果；该类随后单独 7 项通过。未部署、未连接线上接口或执行真机验收。

## 2026-09-02 当前增量：佣金明细好友手机号

共享 `GET /api/invite/earnings/ledgers` 已增加可空的 `sourcePhoneMasked`：后端从当前请求 App 的 schema 批量查询来源用户并统一脱敏，不增加 Catseller 白名单、App 分支或跨 schema 扫描。Catseller P04 消费该字段并按 Figma `43:2285` 显示“脱敏手机号 · yyyy.MM.dd”；字段为空时只显示日期。其他 App 客户端未修改。

数据库改动：无。后端邀请集成 64 项、Catseller 邀请页面 41 项和 `flutter analyze --no-pub` 通过；后端全量 1088 项为 1080 通过、7 项无关 `SongWorkLifecycleIntegrationTests` 因 JVM OOM 失败、1 项跳过，该无关类随后单独 7 项通过。未部署、未连接线上接口或执行真机验收。

## 2026-09-01 当前增量：实名电签自动确认修复

Catseller 与共享 Java 后端已同步拆分“状态恢复”和“提交签约”，状态仍为 `waiting_review`：页面加载/手动查询走 `GET .../status`；App 生命周期恢复不再发请求；受控 H5 仅把合法单一 43 位 `state` 返回实名页，只有该路径调用带 body 的 `POST .../confirm`。手动关闭、非法回跳和空 H5 地址只显示可重试状态。

后端创建后复核、合同通知和定时恢复全部只读查合同；仅 App 合法 state 或路由校验后的 `H5_RETURN` Inbox 进入 App+session Redis 锁和 `confirmed_at` 幂等边界。普通状态刷新不写 `confirmed_at`。资格响应排除无合同号及 `CREATING/RETRY`，不删历史会话、不改数据库结构。

恢复时不要重做实名/绑卡拆分，也不要手工修改截图中的 RETRY 行。先同步启动更新后的本地后端与 App，再验证“进入页面/相机相册/前后台/关闭H5均零confirm，合法回跳恰好一次confirm”；真实工猫、双平台真机、部署和生产数据均未执行。详细命令与证据见 [验证记录](./05-联调与测试/invite-identity-bank-split-verification.md#2026-09-01-实名电签自动确认修复)。

## 2026-08-31 当前增量：实名认证与独立绑卡

用户已确认拆分计划，本地实现 `waiting_review`。P06三项资料+两张私有身份证resourceId、18–65周岁校验；P10独立四项绑卡表单。提现页不强跳，点击时先判实名再判ACTIVE卡；认证成功只返回刷新并等待“去绑定”，绑卡成功再返回。后端认证不建卡/不激活旧PENDING；新增POST bank-accounts核对本App资料后调用updateEmployee，明确成功才激活，用户锁/同卡去重/显式未知重试与默认卡规则已实现。

本次App与共享后端一起更新（identityReady替代ready，删除bankAccount），不修改Admin、其他App页面或资金状态机。业务/工猫连接共用，实名、照片、会话、银行卡和资金全部按App隔离；下方历史“敏感资料共享”不再作为当前实现依据。

数据库：有既有持久化行为调整，无新增/修改SQL、表、字段、索引或Flyway；不修复checksum、不清库、不动余额。保持正式SQL冻结基线、此前10元、现有改动和其他CHG状态。本轮没有部署、真实OSS上传、核身签约或提现。

[详细验证、截图与恢复点](./05-联调与测试/invite-identity-bank-split-verification.md)。后续：重启更新后的本地后端、更新App后进行用户复审；真实Android/iOS权限/H5和工猫61–65周岁渠道另行验收，不以离线测试冒充渠道通过。


> 2026-08-28 H5 白名单开关增量：后端和 catseller 已统一接入 `h5AllowedHostsEnabled`，默认开启，仅明确 false 关闭列表检查，TEST/PRODUCTION 均支持；本机私有默认 false，可由 `GONGMALL_H5_ALLOWED_HOSTS_ENABLED` 覆盖。基础 URL/证书/相机/回跳/禁文件仍校验，仅记录域名。后端隔离无关 maintenance 入口后 179 项通过，原全量受该入口 dataSource 冲突阻断；App 和详细验收见 [本次验证](05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-工猫-h5-域名白名单开关)。数据库改动：无；未部署/真实签约/提现，仍 waiting_review。恢复时不重复开发，按运行手册重启并主动发起认证收集/确认域名，随后恢复检查。

> 2026-08-28 规则展示最新修复：规则接口现在复用后台原有/新版规则数据来源，向 Web 返回用户指定的八项积分、比例、升级人数和最低额；正文默认可见，活动或工猫开关、参数更新失败均不阻断阅读。App HTML 与 Web 脚本使用 v=20260828-display 避开旧缓存；登录及提现安全校验不变。Java 全量 1320 通过 / 3 跳过，Web 12 项、App 专项 50 项、Admin 167 项通过；App 全量 286 通过 / 5 项既有失败。未部署，仍 waiting_review，详见本地验证报告最新增量。

> 2026-08-28 最新增量：邀请业务与提现通道已解耦；Java 显式启用保留权限/预检/审计但不依赖工猫，Web 规则可只读展示并单独提示提现状态，App 规则页跟随 API 环境。后端全量 1319 通过 / 3 跳过；Admin 167 和 Web 行为 12 项通过；App 邀请专项 50 项通过，全量 286 通过 / 5 项既有失败。未部署、未动数据库/真实配置/资金开关，状态仍 waiting_review；见 [增量验证](05-联调与测试/invite-withdrawal-local-verification.md#2026-08-28-邀请业务与提现通道解耦)。

> 2026-08-27 / CHG-0068 / `waiting_review`（本地核心代码与 App 对稿可评审，真实渠道/设备及剩余门禁未完成）
> 当前需求 v1.0.3，仅邀请好友与银行卡提现；后端/Admin 多 App 共享，工猫连接平台共用、数据/权限仍隔离。
> 本轮未部署、未启用模式、未迁移真实余额、未连接真实工猫。

## 1. 当前实现（优先于下方历史批次）

| 端/模块 | 当前实现与实际入口 |
|---|---|
| Java 00/01 | Capability/配置版本；首单奖励、N 天快照/到期、累计退款/负余额；DirectRead 用户/佣金/绑定；T-B012 只读 dry-run、checksum/日期、原子期初转入、显式启用和停用 |
| Java 02/03 | GongmallProperties/ConfigurationService、Crypto/Client/Gateway；IdentityService/可逆存储/多银行卡；BankWithdrawalService/FundsService/quote/幂等创建/审核/冻结/异步派发 |
| Java 04/05 | CallbackService/平台 Inbox 唯一路由；原 ID 查单/租约/退票；AdminRead/Application/SensitiveView、权限/查看密码/审计；MonitoringService 聚合指标与告警 |
| Flutter 00～04 | API/Model/整数分；P01真实进度六入口，P02邀请好友，P03记录/计数，P04佣金/空/负余额，P05银行卡提现，P06核身电签容器，P07记录，P08结果/轮询，P09规则 Web |
| Admin 00～03 | 复用邀请收益管理，能力/规则/N/最低额、邀请及佣金查询、审核/查单、工猫状态、受控明文和审计；独立多 App 规则 Web |

关键代码合同以实际 Controller/OpenAPI 为准；原模块中规划的类名可合并到上述职责对应服务，不另建重复同义 DTO 或 Service。

## 2. 本地验证与设计证据

- [三端本地验证报告](./05-联调与测试/invite-withdrawal-local-verification.md)：命令、统计、资金用例、11 项非邀请失败及真实渠道边界。
- [22 状态 App/Figma 对照](./03-前端/design-qa.md)：同轮比较后修正、截图来源、原生操作和保留差异。
- [工猫配置与运行手册](/Users/soul/code/lxwx/lxwx_service/lxwxservice/docs/invite-gongmall-operations.md)：私有 config 字段、开通/迁移/停止、权限、任务、指标与告警。

App 专项 37 项通过；全量 242 通过/11 失败。Admin 163 项、analyze、Web build 通过。Java 1248 项零失败（3 跳过），其中邀请/工猫 67 项全部通过；构建、OpenAPI、隔离 PostgreSQL 重放通过。已清理本轮临时数据库容器，不改既有数据库。

## 数据库改动

有：common V4.5/V4.6/V4.7、platform V4.1。版本化 AES-GCM 加密落库、RSA-2048 传输。SQL 仅在隔离库验证；没有执行真实余额回填或生产迁移。

## 3. 下一步和剩余门禁

1. 用户复审当前页面/本地实现，补充共享工猫私有参数；无需重新生成 PRD/计划，也不得把无凭据当成代码未开发的理由。
2. 使用真实测试环境验收 H5 摄像头/回跳/中断、银行/税费、审核/查单/成功/退票及两平台真机。未执行前不得宣称完整验收或可上线。
3. 处理 App 全量非邀请失败需单独确认范围；其他 CHG 和用户已有改动保持不动。
4. 真实环境启用前确认每个会员支付渠道退款回调、未知金额人工核对、授权与告警接收、容量和历史余额迁移清单。当前已接会员成功及 Apple 精确交易退款；不把内部资金测试当作所有支付渠道通过。
5. 只有显式切换命令能开启 DIRECT_BANK_GONGMALL；配置、页面访问或应用启动不会自动开启。暂停保留历史结算/查单义务，不回 LEGACY、不删除账本。

恢复必须先完整读取各工程入口规则，再读本文及对应模块，核对实际 diff；不要重复从基础骨架开始。

<details>
<summary>历史批次原文（仅追溯，以下“当前/未实现”以本页上方最新记录为准）</summary>

# 邀请好友与银行卡提现：三端编码恢复点

> 更新：2026-08-27 / CHG-0068
> 当前阶段：13 Flutter / 14 Java + Admin/Web 编码
> 状态：`in_progress`；首批基础代码可评审；2026-08-27 用户已确认付款成功后等待 N 天转为可提现，本批实现动态结算配置及资金模块，不再按支付即入账写死。
> 当前需求：v1.0.3；仅邀请好友与银行卡提现；共享后端/Admin 按 App 隔离。
> 数据库改动：有，仅新增迁移并在隔离测试库验证；未改业务库、启用新模式或调用真实工猫。

## 1. 执行方式与批次

### 2026-08-27 三端继续实施（进行中）

用户再次明确要求完成 App、Java、Admin/Web 全部已确认模块，并完成 App 对 Figma 逐页截图及操作验收。真实工猫参数由用户后续补入后端私有 `config`，缺少凭据不阻塞代码开发；不自动部署、启用资金或发起真实打款。当前只登记执行，不把未实现项改为完成。

本次最小文件范围沿用模块 00～06：Java 邀请领域的共享配置/加密/Gateway、身份银行卡、用户查询/绑定/提现/对账、Admin 权限审核与敏感查看、DTO/VO/Controller/Repository/测试；Admin 现有邀请页、API/Model、独立活动规则 Web；Flutter 现有邀请模块、API/Model、P06/P08 路由、测试与截图。其他业务及已有用户改动保持不变。协议实现先核对官方文档；数据结构不足时只追加迁移，所有资金测试使用隔离库和测试专用 Gateway。

验收分层：本地代码/契约/状态机/页面验收与真实工猫/银行验收分别记录；22 张已核对 Figma 导出图作为视觉基线，不能把示例金额、银行卡或结果标题写入业务逻辑。完成所有代码与本地验收前，三端整体保持 `in_progress`。

用户已确认 17 份模块文档，授权前端、后端和 Web 端按模块依赖顺序实施。文档的 `状态：done` 表示文档评审完成，`编码状态` 和任务复选框才表示实现进度。

每批读取必读规则、对应模块和直接接口依赖，登记最小文件清单，编码、测试并回写。保留其他 CHG 和用户未提交改动，不自动部署、切换资金模式或进行真实打款。

| 批次 | 模块/任务 | 当前状态 |
|------|-----------|----------|
| 1 | Java 00 T-B001/T-B002、Java 05 的 capability/rules 权限子集、Flutter 00 枚举/金额、Admin 00 | 本批基础实现及本地验证完成；Admin 00 waiting_review；Flutter 00 API/路由未完成；Java 00 启用迁移未完成 |
| 2 | Java 01 首单佣金/冲正；Flutter 01/02 邀请页与记录；Admin 01 查询 | Java 首单/等待结算/累计退款与 Admin 动态规则已实现；查询与页面待后续；本批验证见下文 |
| 3 | Java 02/03/04/05 实名、工猫、提现、对账与权限；Flutter 03/04；Admin 02 | pending |
| 4 | Admin 03 活动规则 Web；Java 00 T-B012；Flutter 05 / Java 06 / Admin 综合收口 | pending |

T-B012 必须在账本、退款、状态机及对账完成后实施，不能为了文件编号提前切换资金模式。

## 2. 本批完成的代码

### 2.1 Java：能力、数据库与规则

- `InviteBusinessMode/InviteSharedConfig/InviteCapabilityService`：三模式；无配置保留 LEGACY，停用/损坏/未知模式拒绝，不在读取时插入默认配置。
- common `V4.5__invite_direct_bank_withdrawal.sql`：12 张新 App 表，账户、配置版本、首单转化、账本、身份/会话/卡、quote、提现事件、outbox、Provider 事件和审计；扩展原提现表，保留旧记录。
- platform `V4.1__gongmall_callback_routing.sql`：路由、Inbox、查看失败锁定及 `invite_admin_app_permissions` 共 4 张表。全部新表配 Entity/Repository 和字段注释。
- 约束覆盖用户账户唯一、配置/账本事件幂等、活跃卡与默认卡唯一、新模式每日一单、请求/提现号唯一、金额拆分、冻结非负、新模式禁止原提现表存明文收款信息。实体存在不表示相关业务服务已实现。
- `InviteConfigVersionService`：规则行锁、expectedVersion 校验、递增快照/SHA-256 digest、允许项校验和操作审计同事务。固定档位字段拒绝；通用配置写接口禁止绕过专用规则入口。
- `AdminInviteApplicationService/InviteAdminPermissionService`：新增能力查询，升级规则查询/保存。授权同时匹配签名 token 的 loginAppCode、管理员 ID/用户名、目标 App 与权限；无默认超级管理员兜底。旧 token 可继续旧业务，但新模式需重新登录和显式授权。
- 新模式 capability 暂只声明已实现且已授权的 INVITE_VIEW/INVITE_CONFIG_EDIT。旧代理、人工审核/打款入口及用户端旧邀请接口有模式门禁，不能误调用旧资金逻辑。
- `InviteUrlPolicy/InviteProperties`：HTTPS、精确 host 白名单、443 端口限制，拒绝用户信息和 fragment；白名单不取请求 Host，不涉及工猫密钥。
- 错误码：-7101 能力关闭、-7102 配置版本冲突（409）、-7103 App 越权（403）、-7104 当前模式不支持操作。
- 规则金额/版本使用专用整数反序列化器，拒绝浮点、数字字符串和超出安全整数范围的值；AdminInviteController 将非法 JSON/类型映射为 400，不记录或回显请求正文，其他 Controller 行为不变。

### 2.2 Admin/Web：复用邀请收益管理

- `lib/pages/common/invite_page.dart` 先读 capability，无加载期可编辑旧表单闪现；错误/未知能力不回退 legacy。
- 新模式只读 1/10/20 人与 10%/20%/30% 档位；仅保存最低额、落地页、活动规则 URL、协议版本与 expectedVersion。
- 规则保存有二次确认、重复点击保护、服务端版本冲突提示、权限和 HTTPS host 校验。
- ApiClient 仅取消邀请域请求；Repository generation + 页面 epoch 丢弃 App 切换后的迟到成功/失败/保存结果，清空列表、表单、弹框与筛选，避免 A→B→A 回填。
- LEGACY 保留原代理与手工打款。新模式“邀请与佣金查询”“提现管理”当前明确显示尚未开放，不调用旧财务接口；这两页签不计已完成。
- 改动集中于 invite_page、api_client、admin_repository、admin_models；新增 invite_capability Model 与测试。原 Repository/Model 中用户其他改动保留。

### 2.3 Flutter App：契约基础

- 新增 `lib/models/data/invite_contract_types.dart`：三模式、九态、合同状态和正/负向账本类型，未知值安全兜底。
- 新增 `invite_money.dart`：十进制字符串确定性转整数分，拒绝 JSON 浮点金额，支持负余额格式化与跨平台安全整数边界，不用 double 计算资金。
- `invite_withdrawal.dart` 增量识别九态，保留旧 PAID/PAY_FAILED/APPROVED 展示语义；由 data/index.dart 导出新类型。
- 未修改邀请页面视觉、新用户 API、请求参数、银行卡 Model 或 P06/P08 路由。上述事项仍是 T-F001 后续及页面模块任务。

### 2.4 规则与设计来源

- 按用户“继续下一步”的授权，修复 Flutter `task-new_feature.mdc` 对不存在的 `11-业务复用规则.mdc` 的引用，改为读取真实结构、模块文档并检查现有页面/组件/API；未伪造缺失文件。
- 后端数据库规则、结构索引与 README 对齐已确认邀请三模式例外，其他增长业务不变。
- 最新 Figma 通道 `mj5kz8uv` 已连接，页面 `39:95` 的 22 个节点逐一重新导出比较，PNG 与现有素材字节完全一致。仅更新来源与复核日期，不替换图片、不改变产品要求。

### 2.5 第二批：动态结算、累计退款与规则配置

- `InviteSharedConfig/InviteCapabilityService/InviteConfigVersionService` 及 Admin DTO/VO 增加 `settlementDelayDays`：默认 0，0～3650 整数天；旧配置缺省保持 0，非法值关闭能力，旧代理模式不接受新字段。不自动启用任何 App。
- Admin 现有规则页新增结算等待天数，复用已有 `minWithdrawCents` 动态最低额；默认 100 分，可调高/调低。确认弹框明确当前 App、旧值→新值、结算天数仅新订单、最低额仅新申请，权限/版本/防重复/跨 App 迟到响应保护沿用。
- `InviteCommissionMath/Service`：整数向下取整、防溢出、首笔付费事实与直接奖励快照。无绑定、续费、活动停用期仍留存支付事实，禁止事后绑定后补领；历史付费已占用首单，赠送/兑换会员不冒充付费。
- 每单保存付款时间（北京时间）、N、配置版本和预计结算时间。到期前不增加可提现余额；`InviteCommissionSettlementTask` 每分钟分页扫描，每 App 独立短事务结算，可重跑。修改 N 不改变已有订单，暂停活动不取消已有结算义务。
- `InviteAccountService/InviteCommissionGuardService`：App 内数据库串行锁、账户行锁/CAS、追加式正反账本、单用户序号；结算与退款并发收敛，负余额允许，既有冻结不被覆盖。当前不含提现冻结服务，不把模拟已支出/冻结状态等同真实提现验证。
- `PaymentOrderCallbackService/PaymentOrderService` 接入成功会员支付事实，LEGACY 保持原首次权益判断；Apple 已验签 REFUND 只按精确交易号匹配退款，不按订阅原始交易链猜首单，不把到期/REVOKE 当资金退款。
- 累计退款目标向下取整，本次仅冲正差额；全额补齐尾差。结算前只减少净额/全额取消；结算后写负账本。退款先到保存 Inbox 并由后到支付重放；未知/超额金额保留待核对，未结算订单转 `REQUIRES_REVIEW`，不自动支付。
- `common/V4.6__invite_commission_settlement.sql`：转化表追加结算/退款快照与到期索引，新增支付事实、退款 Inbox、App 内锁共 3 表；历史转化默认待核对，不自动回填余额。README、后端结构索引及当前 PRD/技术/模块契约已同步。

## 3. 验证证据

### 第一批历史基线（保留追溯，不作为第二批最新计数）

| 检查 | 结果与范围 |
|------|------------|
| Java 定向测试 | InviteFoundationIntegrationTests 10 项通过：模式、App/权限、版本并发、URL、旧接口拒绝、约束、OpenAPI 等 |
| Java 全量 | `./gradlew test --console=plain`、`./gradlew build --console=plain` 成功；报告 1187 项，0 失败/错误，3 跳过 |
| OpenAPI | 测试上下文通过真实 `/v3/api-docs` 路径验证能力/规则契约；不声称已部署服务已更新 |
| PostgreSQL 16 | 临时无网络、tmpfs 容器顺序重放 common+各 App 全量 SQL；narrate/catsinger/catcomic/catseller/catoutfit 及 platform 均成功；新表字段注释缺失数 0 |
| 测试资源 | PostgreSQL 容器已停止并自动删除；未连接已有业务数据库。此项为 PostgreSQL SQL 重放，非完整 PostgreSQL 应用/Flyway 运行时联调 |
| Admin | analyze 无问题；新增 invite_capability_test 11 项通过；全量 153 项通过；`flutter build web --no-pub` 成功 |
| Flutter App | analyze 无问题；新增 invite_contract_types_test 6 项通过；全量 211 通过、11 失败，不计全量通过 |
| 端到端 | 未启动真实后端/浏览器联调，未进行双平台设备、工猫、银行或生产验证 |
| 文档/路径 | 30 份当前文档、158 个本地链接、22 张嵌入图及 Markdown 围栏检查通过；三端与工作台 git diff --check、工作区守卫 audit 通过 |

App 全量失败位于首页/作品/设置/协议/反馈测试，非本批邀请契约测试；本轮没有改动这些业务。没有在干净基线复跑，故不将其直接宣称为历史已知失败。重复执行确认的失败名称：

- video failed system back falls back to main at route root
- legal page constants expose production catseller urls
- script failed system back falls back to main at route root
- renders catseller shell
- settings logout returns to main home tab
- settings delete account clears session and returns home
- work detail landscape matches the Figma layout
- work detail portrait matches the Figma layout
- work title sheet matches the Figma layout
- script edit state matches the Figma action layout
- feedback page matches the light form and submits with button

其中 shell 单独复现为 `test/widget_test.dart:833` 断言找不到“一键生成”；4 个视觉基线用例位于 work_detail_visual_golden_test.dart。不修改无关业务或重录 golden 来让本批变绿。

### 第二批最新验证（2026-08-27）

| 检查 | 结果与边界 |
|------|------------|
| Java 全量/构建 | 最终默认 `./gradlew test build --console=plain` 成功；202 个测试类、1217 项，其中 1214 通过、3 跳过、0 失败/错误 |
| 资金与配置 | 佣金集成 18 项、金额数学 6 项、基础/配置/OpenAPI 12 项、支付回调 19 项、Apple Provider 10 项通过；覆盖 0/N 天、7→2 天不追溯、到期/退款并发、重复/乱序/部分/全额退款、首单、负余额和最低额 100→2500→1 分的 App 隔离保存 |
| 测试资源修复 | 曾在默认 JVM 全量运行中发生 OOM；临时增容确认后，为两个邀请隔离 Spring 测试类增加结束时释放上下文，随后默认命令全量通过。未改生产 JVM 或 Gradle 构建配置 |
| Admin | `flutter test` 全量 156 项通过，其中 invite_capability_test 14 项；`flutter analyze` 无问题；`flutter build web --no-pub` 成功 |
| PostgreSQL 16 | 隔离临时容器重放 common+各 App 全量 SQL，5 App 与 platform 均成功；5 App 各有 3 张新佣金表，新表列注释缺失 0。容器无主机端口映射，测试完成后已停止并自动删除；未连接业务库 |
| 文档 | 16 份当前文档的 11 节 PRD 结构、101 个本地引用、22 张嵌入图、23 个 Mermaid 围栏闭合检查通过；这是结构/引用检查，不冒充 Mermaid 渲染或人工设计验收 |
| 未执行 | 本批未改移动端业务代码，未复跑移动端全量；新模式用户创建提现/审核、真实支付渠道、工猫、银行和生产环境未联调 |

## 4. 未完成与禁止启用项

1. 首单支付、账本、到期结算及 Apple 退款已接入；用户/Admin 账户与佣金查询、真实人数进度、记录页面、新模式邀请绑定仍待实现。其他真实支付渠道的退款终态和未知金额核对/修复流程未完成，不能启用新模式。
2. 身份可逆加密、核身电签、银行卡、quote、冻结/审核/派发/查单/回调/退票均未实现；目前仅有结构和类型。
3. Admin 查询/审核/对账/密码查看/审计页尚未实现；权限授予 UI/运维流程、旧数据预检/启用/回退工具未实现。
4. 活动规则 Web 页尚未实现，正式文案/品牌/版本/域名须确认后发布。
5. 支付事件已按模式分流；注册绑定仍有旧代理/积分行为，必须在后续新模式绑定模块收口。运行环境不得手工配置 DIRECT_BANK_GONGMALL；待所有模块、真实渠道对账及 T-B012 完成后再显式启用。App 内短事务串行锁还需按实际量级压测。
6. 未变更构建版本、生产配置、业务库、真实余额或工猫连接；本批代码不等于完整功能可上线。

## 5. 下一步最小输入与已确认口径

### 当前最新请求（优先于此前“支付即入账”规则）

- 用户已确认：“好友付款成功后等待 N 天，佣金才变为可提现余额”。按 App 配置等待天数，默认 0 天；订单保存结算规则及预计结算时间快照，配置只影响后续订单；到期前不可提现，退款扣减待结算额，到期后仍按已确认公式冲正。
- 用户补充最低提现金额也需后台动态调整：复用当前 App `minWithdrawCents`，默认 1 元。新申请提交按后端最新值校验，旧单不追溯；新模式完整创建/审核路径仍在 Java 03 待实现，不能声称本批已端到端验收。
- 本批最小范围：Java 01 首单/结算/退款及定时任务、现有 Admin 规则 DTO/版本/表单、对应测试与文档。完整移动端页面和后台佣金查询仍按后续模块实现，不把本次配置完成等同于三端功能完成。
- 上述规则已实现到本地 Java 服务及 Admin 配置；追加 V4.6，但未修改生产数据库或配置。起始红灯“新模式未写新账本”已有实现覆盖，最新验证结果以第 3 节第二批记录为准。

恢复时先按工程 AGENTS 完整读取必读入口规则，再读本文件、CURRENT/workflow、Java 模块 01 与对应 Flutter/Admin 模块。随后核对实际代码、未提交改动和本批 API；不要重新生成需求或计划。

Java [首单佣金模块](./04-后端/开发计划/01-invite-commission-account.md) 金额口径已于 2026-08-27 获用户明确确认：

- 正向奖励：`floor(订单实付分 × 购买时比例 / 100)`，不足 1 分向下取整。
- 部分退款：`floor(原奖励分 × 累计退款分 / 原实付分)` 减去已冲正分，本次只冲正差额；全额退款时补齐原奖励剩余未冲正部分。

上述规则已生效，继续实施 Java 01 → Flutter 邀请/记录 → Admin 查询。生产启用 App 清单、工猫环境、协议税务及敏感权限相关门禁仍留在对应后续模块。每批只报告已验证内容，不把代码入口或本地测试当成真实渠道联调完成。


</details>
