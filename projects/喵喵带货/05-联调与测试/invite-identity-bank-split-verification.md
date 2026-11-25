# 实名认证与独立绑定银行卡：开发及验证记录

## 2026-09-02 P06 协议区按 Figma 修正

- 根因：实现仍沿用旧 D02 弹窗，点击“同意并开始”会自动把页面协议状态设为同意；同时把 Figma 原文改成“完整协议将在工猫页面阅读”，导致页面复选框不是实际门禁。
- 修正：以通道 `x5x4ir6u` 的 `66:120` 为真源，恢复完整协议原文和布局；复选框默认未选且为唯一确认入口，移除二次弹窗和自动勾选。按钮统一进入 Controller 校验，未勾选、资料/照片/配置不完整均不发送认证 POST；失败保留本页勾选状态，离页不持久化。
- `flutter test --no-pub test/invite_identity_split_test.dart test/invite_contract_types_test.dart test/invite_bank_flow_test.dart test/invite_h5_policy_test.dart test/invite_rules_url_test.dart --reporter compact`：86 项全部通过。覆盖未勾选零请求、已勾选但表单不完整零请求、主动勾选后单次创建、失败保留、H5关闭和合法回跳。
- `flutter analyze --no-pub`：No issues found。4 张实名认证本地 Golden 已更新并目视复核；工程既有 `.gitignore` 不跟踪 `test/goldens/`，截图作为本机验收证据，不冒充仓库提交产物。
- 数据库改动：无。后端接口、P10、其他 App、真实工猫和服务器均未修改或调用；双平台真机/H5仍待用户验收。

> 2026-08-31 / 本地实现 `waiting_review`
> 授权范围：Catseller App与必要共享后端。Admin、其他App页面、SQL/Flyway、数据库数据、余额、佣金/退款/打款不改。
> 数据库：有既有持久化行为调整，无表/字段/索引/迁移新增。认证会话bank_account_id已允许NULL，不清理或激活历史记录。

## 2026-09-01 实名电签自动确认修复

### 根因与修复

- Catseller 原先在 P06 加载 `pendingSessionId`、页面重新 resumed、H5关闭后都会调用空body `POST .../confirm`；共享后端该方法同时执行 `signContract` 和合同查询。资格又会返回 `CREATING/PENDING/RETRY`，因此无合同号 RETRY 会话仅进入页面就产生503，具备合同号时还存在未经合法回跳提交签约的风险。
- 新契约将恢复改为 `GET .../status`，只查合同。`POST .../confirm` 必须提交 `{state}`，服务端校验43位格式及会话state_hash；只有受控WebView合法回跳或已按摘要路由的H5_RETURN Inbox可提交签约。合同通知、创建后复核和定时任务只读。
- App移除resumed自动确认。WebView严格匹配HTTPS returnUrl并只接受一个43位state；手动关闭、非法/缺失state、空H5地址和相机/相册恢复均不提交，只提示重试。
- 后端资格只返回PENDING且已有provider_flow_id的会话。RETRY记录不删、不改库；用户同主体重新提交时按原prepare逻辑SUPERSEDED。普通状态刷新不写confirmed_at；合法提交在外部调用前占位，并与App+session锁共同保证最多一次。

### 接口与错误语义

| 接口 | 合同 |
|---|---|
| `GET /api/invite/identity-sessions/{sessionId}/status` | 只查合同；未完成200 + identityReady=false；无合同号/不可确认409；工猫故障503 |
| `POST /api/invite/identity-sessions/{sessionId}/confirm` | body `{state}`；格式错误400；摘要不匹配、过期、无合同号或不可确认409；工猫故障503；重复请求不重复signContract |

### 本地验证与边界

- 后端新增并通过：状态查询/合同通知/定时任务零签约且confirmed_at为空；缺失/格式/错误/合法state；重复与并发确认最多一次；过期会话只恢复不签；H5_RETURN一次；RETRY/无合同号资格排除及同主体重提；OpenAPI新契约。最终 `InviteBankWithdrawalIntegrationTests` 64项、`InviteFoundationIntegrationTests` 15项，共79项通过；`git diff --check`通过。
- App相关三文件测试共68项通过：历史PENDING仅status、生命周期恢复零confirm、手动关闭/空H5零confirm、非法state不返回、合法回跳恰好一次并校验body；`flutter analyze --no-pub`通过。
- 后端完整命令 `./gradlew test` 已执行，但测试JVM在 `SongWorkLifecycleIntegrationTests` 创建Spring上下文时发生 `OutOfMemoryError` 和 Java instrument断言，执行到1184项：1176通过、7失败、1跳过；首项为OOM，其余6项因同一上下文失败阈值连锁失败。该无关类随后单独运行7项全部通过，证明不是本次实名变更的业务失败；因全量进程未正常完成，不能宣称全量通过。
- 本轮未修改数据库结构或现有会话，未自动重启/部署，未调用真实工猫、真实身份证、银行或资金接口。Widget/MockMvc不能代替Android/iOS真机WebView、运行服务和工猫测试合同验收。
- 恢复点：同步更新后端与App后退出重进P06，用Network验证普通进入/相机/相册/前后台/关闭H5均无confirm；完成合法H5回跳应恰好一次带state的confirm。运行中旧服务和旧App不能混用新契约。

## 2026-08-31 补充：OSS 签名地址重复编码修复

用户确认修复后，仅修改共享后端 `framework/http` 发送逻辑、相关测试与文档；不改工猫配置、App/Admin、认证/绑卡/资金业务。数据库改动：无，未改 SQL、数据或余额。

- 原因：`RestClientHttpCallClient` 的 `execute`、`executeToFile` 均通过 `.uri(String)` 处理已经编码的完整地址，再次编码 `%`，将示例签名 `%2B/%2F/%3D` 改为 `%252B/%252F/%253D`。实际故障日志为 `gongmall-id-photo` 的 OSS 403 / EC `0002-00000040`；照片读取先于工猫模板查询、员工同步，故不是工猫拒绝实名认证。
- 修复：两处发送入口改为 `.uri(URI.create(request.url()))`。不解码、不排序查询参数、不改写签名，不增加重试，不改变请求头/正文/响应读取/重定向及日志策略；`HttpCallRequest.url` 明确为已编码完整地址，不是 URI 模板。
- 回归：新增8项——普通/文件下载原样传输签名、编码路径、中文百分号字节、大小写转义、已有双层编码、`+`、重复键及空值；重定向开关四种组合；非法转义在发送前拒绝且不泄露签名。使用本机模拟服务器比对实际收到的 raw URI，不连接 OSS/工猫；签名不一致时模拟403。
- 红绿验证：仅新增测试时，两种发送模式均因收到二次编码地址而失败；修复后 `HttpCallClientTests` 36项及 HTTP/工猫/邀请照片/提现集成/飞书/FunASR 专项总301项、14类全部通过。
- 专项命令：`./gradlew test -I tools/invite-verification.gradle --tests '*HttpCallClientTests' --tests 'com.lxwx.narrateservice.framework.http.*' --tests '*Gongmall*Tests' --tests '*InviteIdentityPhotoServiceTests' --tests '*InviteBankWithdrawalIntegrationTests' --tests '*FeishuNotificationTests' --tests '*FunAsrProviderTests' --console=plain`。
- 全量命令：`./gradlew test -I tools/invite-verification.gradle --console=plain`，228类、1672项，1668通过、1失败、3跳过；init脚本只控制测试堆/分叉/上下文缓存，不过滤测试或改变运行服务配置。
- 唯一失败为此前已记录的 `QuickBatchAnalyzingIntegrationTests.analyzingBatchShouldReturnWorkIdAndContinueInBackendPolling`，第207行创建视频批次预期200、实际400。本轮未修改该用例或视频业务，不能宣称全量测试通过。报告：后端 `build/reports/tests/test/index.html` 与 `build/test-results/test/`。
- `git diff --check`、流程文档守卫check/audit通过；本地修复状态 `waiting_review`，不自动git add/commit，保留用户其他修改。
- 恢复点：本次没有自动重启服务、部署或调用真实身份证/工猫接口。重启更新后的后端再复验；不要求重传已完成上传的照片，也不更换工猫密钥。真实渠道结果仍需用户复验。

## 2026-08-31 补充：姓名中文输入修复

范围仅为 Catseller 两处“真实姓名”输入框，无后端、Admin 或数据库改动。此前完整拆分验证结果保留在下文，不将它们作为本轮重新执行的结果。

- 根因证据：本机 Flutter 引擎 `TextInputPlugin.java` 在 `enableSuggestions=false` 时添加 `TYPE_TEXT_FLAG_NO_SUGGESTIONS` 与 `TYPE_TEXT_VARIATION_VISIBLE_PASSWORD`；共用组件原先对姓名也固定关闭候选词。[Flutter 已知问题](https://github.com/flutter/flutter/issues/156801) 同样记录了该配置影响 Android 输入法语言切换。原姓名正则允许中文，并非校验拒绝中文。
- 实现：`InviteIdentityField` 支持候选词参数，两处姓名启用候选词并用 `TextInputType.name`。仍禁用个性化学习、系统自动填充和自动纠错，其他字段不变，不修改页面布局和 golden 基线。
- 红绿验证：新增 `name IME supports Chinese composition identity/bank-bind` 两项用例，修复前均因平台输入类型仍为 text 而失败；修复后验证姓名输入类型、候选词、隐私配置、拼音组合区、中文姓名及中间点输入，并确认没有发送 POST。
- `dart format --output=none --set-exit-if-changed lib/pages/invite/widgets/identity_fields.dart lib/pages/invite/withdrawal_auth/view.dart lib/pages/invite/bank_bind/view.dart test/invite_identity_split_test.dart`：4 文件无格式差异。
- `flutter analyze --no-pub`：No issues found；过程中新增测试的一处花括号 lint 已修正后重跑。
- `flutter test --no-pub test/invite_identity_split_test.dart test/invite_contract_types_test.dart test/invite_bank_flow_test.dart test/invite_h5_policy_test.dart test/invite_rules_url_test.dart --reporter expanded`：79 项通过（含新增两项）。
- 本轮未重新运行全量 App/后端测试、Android/iOS 构建，不部署、不操作数据库、不调用真实认证/绑卡/提现。Widget 测试模拟输入法编辑值，不代表 Gboard/搜狗或 iOS 真机已验收。
- 用户复验：更新运行中的 App，退出并重进实名认证、绑定银行卡页面，使用中文输入法输入姓名，确认拼音候选、选字和删除正常。状态保持 `waiting_review`。

## 1. 当前实现与恢复点

提现页打开只加载；用户点击时根据最新资格走 **未实名→实名认证 / 已实名无ACTIVE卡→绑定银行卡 / 已实名有卡→原提现**。认证成功自动返回刷新，等待用户点击“去绑定”；绑卡成功提示后返回刷新。取消不改变服务端状态。

- P06：三项本人资料与两面私有身份证resourceId，18–65周岁/真实日期/校验码，压缩≤3MiB；相机/相册、预览/替换、进度/重试、只清理流程临时副本。
- P10：独立 `/invite/bank-bind`，重新填写姓名、身份证、银行卡、手机号，协议沿用既有版本；无照片/H5/SMS。
- 后端：认证不建卡、不以登记代替成功；仅主动合同查询2/3返回identityReady。绑定先核对当前App资料，Redis用户锁/同卡HMAC去重，短事务准备→事务外updateEmployee→明确success=true后激活。未知PENDING可显式同卡重试，拒绝INVALID，有效同卡复用，首张有效卡默认。
- 同一工猫配置/业务流程，各App独立身份、照片、会话、卡和资金；保留原银行卡ID解析修复与H5安全规则。

恢复：重启更新后的本地后端并更新App，再进入提现页复审。前后端合同需一起更新，旧App的合并认证表单不能作为新接口的兼容调用方。运行中的服务没有被本次自动重启，不部署，不主动发起真实签约/提现。

## 2. 接口合同

普通请求继续JWT、X-App-Code及本人归属校验；敏感输入不进持久化客户端缓存、路由或日志。

| 接口 | 入参/响应 |
|---|---|
| POST /api/invite/identity-sessions | name、identity、mobile、identityFrontResourceId、identityBackResourceId、agreementVersion、agreementConfirmed；无银行卡 |
| GET /api/invite/identity-sessions/{sessionId}/status | 无body；只查合同；与创建同型响应，无ready/bankAccount |
| POST /api/invite/identity-sessions/{sessionId}/confirm | body为43位state；仅合法回跳提交一次签约，再查合同；与创建同型响应，无ready/bankAccount |
| POST /api/invite/bank-accounts | name、identity、mobile、bankAccountNo、agreementVersion、agreementConfirmed；仅明确业务成功返回ACTIVE脱敏卡，无银行名时“银行卡” |
| 资格/卡列表/选卡/试算/提现 | 原合同与金额、次数、幂等、人工审核、工猫/人工执行规则保持不变 |

工猫官方核对：[syncInfo中bankAccountNo可选](https://opendoc.gongmall.com/merchant/dian-qian-he-tong/yuan-gong-tong-bu-merchant.html)、[更新银行卡用updateEmployee且返回success](https://opendoc.gongmall.com/merchant/dian-qian-he-tong/gen-xin-account-merchant.html)。后端照片继续转换为工猫要求的Base64，不把resourceId或临时地址当照片参数。

工猫 [GM_API_BUS_000074](https://opendoc.gongmall.com/merchant/overview/yi-chang-dai-ma.html) 仍描述未成年/超过60岁不可认证。平台18–65规则已实现；61–65是否通过须商户渠道验收，拒绝不能绕过或伪装成功。

## 3. 实际命令与结果

后端工作目录：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`。

- `./gradlew test -I tools/invite-verification.gradle --tests '*InviteBankWithdrawalIntegrationTests' --tests '*GongmallGatewayTests' --console=plain`：123项通过（57集成+66 Gateway）。
- `./gradlew test -I tools/invite-verification.gradle --console=plain`：1664项，1660通过、1失败、3跳过。沿用已有验证init控制测试堆/分叉；不是改业务库、启动真实渠道或忽略失败。
- 唯一失败 `QuickBatchAnalyzingIntegrationTests.analyzingBatchShouldReturnWorkIdAndContinueInBackendPolling`：内容审核返回400，断言200失败，既有失败单列；未修复内容审核模块。
- `./gradlew build -x test --console=plain`：通过；仅编译/打包，不代表全量测试通过。
- OpenAPI通过MockMvc实际读取 `/v3/api-docs` 检查新POST、必填照片、identityReady布尔字段及旧bankAccountNo/ready/bankAccount删除；不代表运行中旧服务已加载新合同。
- 测试证据：`build/test-results/test/` 与 `build/reports/tests/test/index.html`。

App工作目录：`/Users/soul/code/lxwx/catseller`。

- `dart format` 及最终格式检查：通过。
- `flutter analyze --no-pub`：No issues found。
- `flutter test --no-pub test/invite_identity_split_test.dart test/invite_contract_types_test.dart test/invite_bank_flow_test.dart test/invite_h5_policy_test.dart test/invite_rules_url_test.dart --reporter expanded`：77项全部通过。
- `flutter test --no-pub --reporter expanded`：317通过、5项既有失败；总322。失败为legal page constants（静态URL断言）与work_detail_visual_golden_test中4项作品详情/标题/编辑态golden，本轮未修改相关业务或更新这些golden。
- `flutter build apk --debug --no-pub`：成功生成debug APK；工具提示现有compileSdk36与flutter_secure_storage要求37的警告，未顺带升级依赖/SDK。未安装/发布此包。
- 两端 `git diff --check` 通过；未git add/commit，保留已有用户修改和新文件。
- 本次日志位于 `/tmp/catseller-split-{invite-final,full-test,analyze}.log`、`/tmp/catseller-identity-apk-build.log`；日志临时文件不是永久证据，以上结果和截图已回写本工作区。

## 4. 覆盖矩阵

| 场景 | 本地证据 |
|---|---|
| 未实名/已实名无卡/已实名有卡 | 提现三分支；仅点击推进；三状态截图 |
| 认证成功/取消/未签署/已有会话恢复 | Widget路由与Controller，ready旧字段不能放行；成功返回后不自动绑卡 |
| 认证不要求银行卡、不创建/激活卡 | 服务集成、HTTP/OpenAPI；旧PENDING保持待确认 |
| 未实名绑卡/姓名证件手机号不匹配 | 拒绝且verify工猫零调用；当前App查询边界 |
| 重复同卡/并发用户锁/默认卡 | 有效同卡直接返回；锁忙不调provider；新卡不覆盖默认 |
| 绑定拒绝/未知/重试 | 不激活，不改变已认证档案；同卡记录复用，严格布尔success=true |
| 两私有照片 | 无public exists/URL；complete READY resourceId；压缩超限拒绝、失败重试、替换/离页清理、保留相册原图 |
| 跨App/用户/类型资源 | 服务端既有照片校验回归；错误不建档、不发起签署 |
| H5策略/权限/回跳 | 既有白名单默认/开关、HTTPS/凭据URL拒绝、相机来源、返回确认相关测试 |
| 选卡/试算/提现幂等 | 原资金流程集成及App专项回归；不实际调用资金渠道 |
| 小屏/键盘/错误 | 320×640、1.3倍文本、260键盘占位及错误截图；错误固定在认证CTA前，避免长表单隐藏反馈 |

## 5. Figma及页面证据

按image-to-code/design-qa流程，用同一比较输入打开原稿与真实生产Widget截图，修正卡片高度/间距、输入字重以及认证错误反馈位置后重新比较。新图直接嵌入 [PRD的P06/P10详细页面](../01-需求/requirements.md)。旧图和旧记录保留，未改设计稿。

- [完整Design QA](/Users/soul/code/lxwx/catseller/design-qa.md)：五类复核、残余P3与有意差异。
- [实名认证](../03-前端/references/identity-bank-split-20260831/split-identity.png)
- [独立绑卡](../03-前端/references/identity-bank-split-20260831/split-bank-bind.png)
- [提现未实名](../03-前端/references/identity-bank-split-20260831/08-withdrawal-unbound.png)、[已实名无卡](../03-前端/references/identity-bank-split-20260831/split-withdrawal-identity-ready.png)、[已有卡](../03-前端/references/identity-bank-split-20260831/16-withdrawal-form.png)
- [认证小屏键盘](../03-前端/references/identity-bank-split-20260831/split-identity-keyboard.png)、[绑卡小屏键盘](../03-前端/references/identity-bank-split-20260831/split-bank-bind-keyboard.png)
- [认证错误](../03-前端/references/identity-bank-split-20260831/split-identity-error.png)、[绑卡错误](../03-前端/references/identity-bank-split-20260831/split-bank-bind-error.png)

## 6. 明确未执行与下一步

- 未部署、未改服务器配置、未跑真实OSS上传/工猫签约/绑卡/提现、未改SQL或数据库余额。
- 未进行Android/iOS真机相机/相册授权、后台截图保护、真实H5导航、相机、外部回跳；Widget平台替身不能取代原生SDK验收。未进行iOS构建。
- Android debug构建成功不是生产签名/渠道发布验收。
- 61–65周岁和实际合同/银行卡通道能力需要商户确认后测试，不以HTTP200认定任何业务成功。
- 进入用户复审；真实渠道验证需在用户准备好环境并授权后进行。旧银行卡PENDING不自动处理，10元余额不重复添加。
