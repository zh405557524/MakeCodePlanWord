# 提现协议版本与后台密码加款增量

> 2026-08-31；状态：`waiting_review`。Java / Admin 本地代码完成，为全部 App 共用能力；本地后台账号授权仍待用户确认。本工作区只承载需求与实施记录。

## 1. 变更契约

- 补齐随包 `invite.rules.agreementVersion=v1`；后台明确展示、解释和校验协议版本。已有有效版本不覆盖，配置读取不自动写库。
- 协议版本用于记录本平台认证用途/协议确认版本，并校验旧页面的提交；不是工猫 `templateId`，不生成合同、不修改工猫模板或已签合同。
- 本地 Catseller 缺失版本按用户授权显式修复；不操作服务器配置。
- 后台新增“增加可提现金额”：当前 App + 指定活动用户 + 正整数分 + 必填原因 + 每次输入现有查看密码 + 二次确认。
- 独立权限 `INVITE_BALANCE_CREDIT`，同时要求 `INVITE_VIEW` 和目标 App 显式授权；复用已有 BCrypt 哈希、失败次数与锁定策略，不新增第二套密码配置。
- 使用同一钱包追加 `MANUAL_CORRECTION` 账本；不伪造会员订单，不直接覆盖余额，不修改冻结额。不跳过实名、最低提现额和每日限制。
- 幂等键与管理员来源身份绑定，同键改变用户、金额或原因报冲突；并发加款、返佣和提现在原有账户锁/版本下串行化。
- App 界面、工猫签约/打款、会员退款与其他模块不变。不部署、不真实签约/打款、不重复增加此前 10 元。

## 2. 数据库改动

- 有数据写入逻辑；复用 `app_configs`、`invite_config_versions`、`invite_accounts`、`invite_wallet_ledgers`、`invite_admin_operation_logs` 和 `platform.gongmall_sensitive_view_failures`。
- 无新表、字段或结构迁移，不修改任何既有 Flyway SQL，尤其不修改正式已执行 SQL。
- 加款只在管理员明确确认后写入目标 App 的账户与账本；密码失败计数独立提交，业务事务失败不得把失败次数回滚。
- 本地协议版本修复需留前后快照与记录；新后台授权只在用户确认账号/范围后写 `platform.invite_admin_app_permissions`。
- 当前本地唯一管理员为 `narrate/admin`（ID 1），邀请显式授权为空；已向用户询问是否授予 Catseller 的查看/规则编辑/加款/审计权限，尚未获确认，未写授权或擅自批量授权。

## 3. 接口与职责

- `GET /api/admin/invite/accounts/{userId}`：当前 App 的脱敏用户与钱包快照，只读且不初始化账户。
- `POST /api/admin/invite/accounts/{userId}/credits`：新增金额、原因、密码；要求 `Idempotency-Key`，返回本笔账本回执。不返回或记录密码。
- 规则仍用现有 `GET/PUT /api/admin/invite/rules`；补必填版本校验和后台用途说明。
- Admin 沿用 API Client → Repository → 页面分层；切 App 关闭对话框、清空密码、丢弃旧 App 响应，不把旧请求改发到新 App。
- 成功后刷新余额与审计；不确定结果保留原幂等键重试，禁止用户不知情地重新生成键加款。未确认草稿仅在当前管理员会话内存按 App 保存，不含密码；切 App 返回后可继续，刷新/关闭浏览器导致会话丢失时先查原账本与审计，不能另建请求盲目重做。

## 4. 实施顺序与验收

1. 默认配置缺版本的失败测试；保留现有佣金、提现、敏感查看特征测试。
2. 配置与后台必填/说明；本地显式修复。
3. 提取共用密码校验，实现独立权限、原子记账、幂等、安全错误响应；保留原敏感查看流程。
4. 后台加款对话框、账户核对、提交确认、结果与跨 App 状态隔离。
5. 后端 `./gradlew test`、OpenAPI 契约；Admin format/analyze/test/build web；两端 diff 检查，工作区守卫 audit。

覆盖：无权限、错误/空密码、第五次失败锁定、事务回滚不清失败次数、用户不存在/停用、负数/零/小数/溢出金额、重复/并发请求、改参重试、负余额抵扣、冻结不变、App 隔离、密码不入日志/返回体、协议版本缺失/清空/旧版本提交、后台切 App 与网络不确定重试。

## 5. 验证与恢复点

- 本地实际配置：`catseller.app_configs` 的 `invite.rules.agreementVersion=v1`、`version=1`；除这两个字段外，修复前后其他规则值完全一致。追加1份配置快照和1条审计，维护身份为 `local-maintenance` / ID0，未冒用真实后台账号。
- 修复前快照：后端 `.local/records/invite-agreement-version-20260831-before.json`，权限600；执行 SQL：`.local/records/invite-agreement-version-20260831.sql`。均为Git忽略的本地记录，不是发布迁移，不应到服务器执行。
- 实际只读核验：本地 `GET /api/config/invite-rules`（`X-App-Code: catseller`）返回 `agreementVersion=v1`；原用户ID3的已结算余额仍1000分，未加款；`platform.invite_admin_app_permissions` 仍0行。
- 已核对此前用户提供的查看密码与本地 BCrypt 哈希匹配；没有重设密码，不把明文或哈希写入本文。不能据此断言生产配置一致。
- 先用5个随包默认值测试复现缺版本，再补默认值；更新原规则保存测试的有效协议版本样例，另测缺失版本必须显式修复，不用默认值掩盖历史数据。
- 后端定向：新密码加款/配置、原基础配置及工猫提现测试通过；最后完整运行中 Invite/Gongmall 共204项全部通过（0跳过）。新增接口及 password `writeOnly` 已在隔离 MockMvc `/v3/api-docs` 契约验证。
- 后端完整 `./gradlew test -I tools/invite-verification.gradle` 已执行；修正相关测试样例后再执行 `./gradlew build -I tools/invite-verification.gradle`，完整1519项为1515通过、1失败、3跳过。唯一失败为既有 `QuickBatchAnalyzingIntegrationTests.analyzingBatchShouldReturnWorkIdAndContinueInBackendPolling`：返回 `-4202 内容安全审核暂不可用`，期望200实际400，未修改该模块。`bootJar` / `jar` / `assemble` 成功，**整体build因该测试失败，不宣称全量通过**。
- Admin：`dart format`、`flutter analyze` 无问题；完整 `flutter test` 179项通过；`flutter build web --no-wasm-dry-run --no-web-resources-cdn` 成功。覆盖专用权限入口、二次确认、0.29元精确29分、超时原键重试/重开对话框、跨App取消与密码清理、成功后余额刷新失败不重复加款。
- 两端及本次流程文档 `git diff --check` 通过；工作区守卫逐路径check、最终audit均通过。保留已有未提交修改与未跟踪文件，不stage/commit，不改任何SQL迁移。
- 当前运行中的本地后端 `/v3/api-docs` 还没有新增加款API；需重启更新后的后端，更新/刷新Admin页面。未登录真实后台操作加款，未发起真实工猫H5/签约/提现，不部署；不得将自动化测试当成真实银行验收。
- 不修改其他 CHG 状态，本增量 `waiting_review`。下一步等待本地后台账号授权确认及用户复审。

## 6. 代码与手工复审入口

- 后端：`admin/invite/controller/InviteAdminBalanceController`、`InviteAdminBalanceService`、`InviteAdminPasswordService`、`InviteAdminAuditService`；复用 `InviteAccountService` 追加账本，账户锁顺序与规则编辑一致，密码失败计数使用独立事务。
- 规则：`InviteConfigVersionService`、5个App的 `service-data/apps/*/app-configs.json`，保留当前数据库版本优先且只校验明确修改的URL。
- Admin：`lib/pages/common/invite_page.dart` 展示协议版本/帮助文案及专用加款入口；`invite_balance_credit_dialog.dart` 实现账户核对与密码二次确认；API/Repository/模型沿用现有分层。
- 测试：后端 `InviteAdminBalanceIntegrationTests`、`InviteAgreementDefaultsTests`、`InviteFoundationIntegrationTests`；后台 `test/invite_balance_credit_test.dart`、`test/invite_capability_test.dart`。
- 用户确认权限后，按指定登录来源 `narrate`、账号 `admin`、ID1，仅对目标 `catseller` 授予 `INVITE_VIEW`、`INVITE_CONFIG_EDIT`、`INVITE_BALANCE_CREDIT`、`INVITE_AUDIT_VIEW`。无额外授权不改生产、不授权其他App。
- 复审：重启后端并刷新后台，选择喵喵带货 → 交易与增长 → 邀请收益管理 → 规则配置查看 `v1`；加款入口先核对用户，输入金额/原因、二次确认和查看密码。实际加款只由管理员明确提交，当前开发验证不代替该授权。
