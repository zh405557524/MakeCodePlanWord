# 喵喵写歌 v1.2.0+121 用户功能测试执行记录

> 执行日期：2026-09-05  
> 关联变更：CHG-0069  
> 设备：Android `e2b8595a`  
> 安装包：`com.lxwx.catsinger` / `1.2.0`  
> 环境：测试环境 `http://120.25.199.191:8080`

## 1. 目录与框架

| 检查 | 结果 | 说明 |
|---|---|---|
| Markdown 动态目录 | PASS | 338 条；P0 177、P1 155、P2 6 |
| 平台分布 | PASS | Android 25、iOS 18、双平台 295 |
| 自动化分布 | PASS | automated 14、assisted 107、manual 217 |
| 覆盖矩阵 | PASS | 无悬空用例编号、无未关联覆盖行 |
| Python compileall | PASS | `main.py`、`catsinger_test`、`tools`、`tests` |
| 框架自检 | PASS | 23/23 |

框架自检只验证测试工程本身，不代表 App 用户功能通过。

## 2. Doctor

| 检查 | 结果 | 说明 |
|---|---|---|
| ADB 设备 | PASS | `e2b8595a` 在线 |
| App 安装与版本 | PASS | `com.lxwx.catsinger` / `1.2.0` |
| 用例目录 | PASS | 动态加载 338 条 |
| 后端健康 | PASS | health 返回 UP |
| catsinger schema routing | BLOCKED | 测试服务器返回 HTTP 400 `Unsupported X-App-Code` |

结论：设备和只读 UI 可执行；依赖用户接口的登录写入、积分、生成、翻唱和资源闭环不能在该服务器形成通过结论。

## 3. Smoke

- 命令：`python3 main.py run --suite smoke --mode balanced`
- 结果：10 PASS / 0 FAIL / 0 BLOCKED / 0 NOT_RUN。
- 总耗时：71.27 秒。
- 覆盖：冷启动、三 Tab、首页、AI 写歌、改编歌曲、专业模式、空歌词校验、作品、我的和更多设置。
- 报告：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260905-173315-7c670a/`

首轮 smoke 曾因测试处理器仍按旧交互查找控件而出现 3 条失败：模型选择弹层未处理、更多设置未滚动。核对截图和 UI XML 后只修改测试工程与用例步骤，未修改 App；复跑 10/10 通过。

## 4. Core

- 命令：`python3 main.py run --suite core --mode balanced`
- 结果：12 PASS / 0 FAIL / 1 BLOCKED / 0 NOT_RUN。
- 总耗时：96.93 秒。
- BLOCKED：`WORK-004`，当前账号没有生成中作品。
- 证据：13 条自动化用例均生成截图和 UI XML；没有缺失证据的自动化结果。
- 报告：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260905-174217-05dcb7/`

`WORK-004` 处理器已修正为只匹配“生成中”，不再把完成作品的“AI生成”类型标签当成任务状态。最终 Core 报告中的该用例为 BLOCKED，并保存阻塞现场截图和 UI XML。

## 5. 未执行范围

- `paid` 套件在不提供 `--allow-paid` 的情况下做过安全门禁抽查：57 条中 56 条人工/半自动为 NOT_RUN，唯一自动生成闭环为 BLOCKED；总耗时 2.86 秒，没有创建任务或扣积分。报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260905-174119-0dd08d/`。
- `destructive` 当前共 16 条，全部为 manual/assisted，不会由 ADB 自动触发；执行时仍需分别满足删除、提现和注销安全条件。
- 338 条目录中的 assisted/manual 用例未由本轮 ADB 自动执行，状态仍为 NOT_RUN。
- 未执行 iOS、Apple Sandbox、外部支付宝、真实 Provider、真实翻唱、支付、提现、删除、隐私撤回和账号注销。
- 未验证第三方临时音频/封面过期后的平台资源持久化。
- 未修改 Flutter、Java 后端或 Web/Admin 业务代码。

## 6. 当前结论

CHG-0069 的测试设计、动态目录、风险门禁和报告能力已完成并通过框架验证；Android 只读 smoke 通过。整 App QA 仍为 `in_progress`，原因是测试服务器 catsinger 路由未部署、账号缺少生成中作品，以及 iOS/付费/破坏性/真实 Provider 用例尚未实际执行。

## 7. 2026-09-07 安全全量执行

- 命令：`python3 main.py run --suite full --mode balanced`
- Run ID：`20260907-100315-200a49`
- 设备：Android `e2b8595a`
- App：`com.lxwx.catsinger` / `1.2.0`
- 结果：338 条中 12 PASS、0 FAIL、2 BLOCKED、324 NOT_RUN；自动执行项通过率 85.71%。
- BLOCKED：`FLOW-CREATE-001` 缺少 `--allow-paid`；`WORK-004` 当前测试账号没有生成中作品。
- 安全边界：未提供 `--allow-paid`、`--allow-delete`、`--allow-withdrawal`、`--allow-account-delete`，未创建付费生成任务、未扣积分、未删除作品、未提现、未注销账号。
- Doctor：设备、App、338 条目录及后端 health 正常；catsinger appCode 路由仍返回 HTTP 400 `Unsupported X-App-Code`。
- 证据：14 条自动化结果（12 PASS、2 BLOCKED）均生成截图和 UI XML；完整 HTML、JSON、JUnit XML 和文本报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-100315-200a49/`。
- 未执行边界：324 条 assisted/manual、iOS、Apple Sandbox、外部支付、真实 Provider、真实翻唱、提现、删除、隐私撤回、注销及专用配置/数据用例仍为 NOT_RUN。

本轮没有发现自动执行范围内的 FAIL，但不能据此判定全量用户测试通过；CHG-0069 继续保持 `in_progress`。

## 8. 2026-09-07 付费、删除作品与提现授权执行

### 8.1 付费套件

- 命令：`python3 main.py run --suite paid --mode balanced --allow-paid`
- Run ID：`20260907-100829-008373`
- 结果：57 条中 0 PASS、1 FAIL、0 BLOCKED、56 NOT_RUN。
- FAIL：`FLOW-CREATE-001` 返回 HTTP 400 `Unsupported X-App-Code`。执行器在 API 登录/作品快照阶段失败，尚未进入专业写歌页面与任务提交步骤，因此未创建任务、未扣减积分、未进入 Provider。
- 证据：失败截图、UI XML、logcat、HTML、JSON、JUnit XML 和文本报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-100829-008373/`。
- 其余 56 条需要专用账号、测试数据、后台配置、外部支付或人工确认，保持 NOT_RUN。

### 8.2 删除作品与提现套件

- 命令：`python3 main.py run --suite destructive --mode balanced --allow-delete --allow-withdrawal`
- Run ID：`20260907-100902-07efab`
- 结果：16 条中 0 PASS、0 FAIL、0 BLOCKED、16 NOT_RUN。
- 当前 destructive 目录全部是 manual/assisted，用例执行器没有自动执行删除作品或提现；本轮没有删除作品、没有产生提现单。
- 账号注销未授权，未提供 `--allow-account-delete`，也未执行注销。
- 报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-100902-07efab/`。

授权本身已生效，但环境和自动化等级仍不满足真实执行条件。发布级 QA 状态继续为 `in_progress`。

## 9. 2026-09-07 提现范围纠正

- 用户确认：当前版本没有提现业务。
- 根因：测试基线从 Flutter 仓库发现提现页面、路由、model 和候选 API 代码后，错误地将代码骨架识别为已交付、用户可验收业务。
- 修正：从当前执行目录删除 `WITHDRAW-001`～`WITHDRAW-008`，同时删除依赖提现页的 `INVITE-008`，并移除覆盖矩阵、测试数据和风险门禁中的提现项。
- 当前 catalog：329 条；P0 169、P1 154、P2 6；automated 14、assisted 104、manual 211；覆盖矩阵和 23 项框架自检通过。
- 修正后 destructive 复跑：Run ID `20260907-101115-edeea1`，11 条均为 manual/assisted，因此 11 NOT_RUN；目录中已无提现用例，未发生删除或注销操作。
- 先前 Run ID `20260907-100315-200a49` 和 `20260907-100902-07efab` 的 338/16 条统计保留为修正前历史证据，不作为当前有效总量。

## 10. 2026-09-07 纠正后全量执行

- 命令：`python3 main.py run --suite full --mode balanced --allow-paid --allow-delete`
- Run ID：`20260907-102144-fa0cbd`
- 当前有效总量：329 条。
- 结果：12 PASS、1 FAIL、1 BLOCKED、315 NOT_RUN；14 条自动化结果均生成截图和 UI XML。
- FAIL：`FLOW-CREATE-001`，测试服返回 HTTP 400 `Unsupported X-App-Code`；失败发生在任务创建前，未创建作品/任务、未扣积分、未进入 Provider。
- BLOCKED：`WORK-004`，当前测试账号没有生成中作品。
- 删除授权已提供，但删除相关用例均为 manual/assisted 且缺少专用运行数据，本轮没有删除任何作品。
- 提现已从当前范围移除；账号注销未授权且未执行。
- 完整证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-102144-fa0cbd/`。

当前有效结论以本节为准：存在 1 个 P0 FAIL、1 个 P0 BLOCKED 和 315 个 NOT_RUN，发布级 QA 不通过并继续保持 `in_progress`。

## 11. 2026-09-07 专业模式专项复测

- 完整闭环复测：`python3 main.py case FLOW-CREATE-001 --allow-paid`，Run ID `20260907-102622-flow-create-001`，结果 FAIL；测试执行器在点击“AI写歌”之前先执行 API 登录/作品快照，测试服即返回 HTTP 400 `Unsupported X-App-Code`，失败截图仍为首页。因此该结果证明生成闭环环境前置失败，不代表专业模式页面失败。
- 专业模式页面复测：`python3 main.py case CREATE-001`，Run ID `20260907-102655-create-001`，结果 1/1 PASS；真机成功进入“专业模式”，歌曲名、歌词、润色歌词、创作模型、人声、纯音乐、音乐风格、音乐场景和生成歌曲等主要控件可见。
- 专业模式证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-102655-create-001/`。
- 边界：本次只证明专业模式页面和主要控件可达；提交、扣积分、生成进度、Provider 和最终作品仍因测试服 catsinger 路由未部署而未通过。

## 12. 2026-09-07 三种创作模式独立完整复测

- 专业模式：`FLOW-CREATE-001` 按“输入歌词 → 润色歌词 → 生成歌曲”的真实业务流程重写并复跑。Run ID `20260907-104945-flow-create-001`，结果 PASS，耗时 318.73 秒；润色后歌词、提交页和最终播放器均有截图/UI XML 证据。作品 ID 无法可靠唯一匹配，为避免误删保留测试作品。
- 开启付费和删除授权的当前目录全量执行：`python3 main.py run --suite full --mode balanced --allow-paid --allow-delete`，Run ID `20260907-012107-ba444e`；329 条中 10 PASS、4 FAIL、315 NOT_RUN、0 BLOCKED。专业生成闭环 PASS。`WORK-001`、`WORK-004`、`PROFILE-002`、`PROFILE-014` 均在生成后会话仍停留播放器时因测试执行器恢复首页超时而级联 FAIL，不作为 4 个独立产品缺陷结论。报告：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-012107-ba444e/`。
- 歌曲改编/翻唱：用户在真机选择源音频后，ADB 继续输入改编要求和歌名，确认 Suno V5.5 模型及 100 积分，完成“上传成功 → 创建任务 → 生成音频/海报 → 播放器”。最终播放器显示歌名、歌词段落、`0:59` 总时长和“生成同款”，结果 PASS。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/manual-cover-20260907/`。
- 简易模式：成功切换简易模式，随机灵感、女声和模型选择均可操作；默认高级模型提交显示“权益不足”。切换到 `MiniMax Music 2.6 / 100 积分` 后再提交仍被同一会员权益门禁拦截，未创建任务、未扣积分，结果 BLOCKED（测试账号缺会员权益），不记为路由或 Provider FAIL。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/manual-simple-20260907/`。
- 当前三模式结论：专业模式 PASS，歌曲改编/翻唱 PASS，简易模式 BLOCKED。移动端发布级全量 QA 仍为 `in_progress`，不宣称全量通过。

## 13. 2026-09-07 切换测试服务器后全量、模型和购买复测

- 环境：Android `e2b8595a`，App `1.2.0+121`，`https://test.lxwanxiang.com`，catalog 329 条。Doctor 的后端响应不是合法 JSON，但真机 App 页面和后续业务请求可达。
- 全量：`python3 main.py run --suite full --mode balanced --allow-paid --allow-delete`，Run ID `20260907-021240-a11317`，12 PASS、1 FAIL、1 BLOCKED、315 NOT_RUN，耗时 257.21 秒。报告：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-021240-a11317/report.html`。
- `FLOW-CREATE-001` 的 FAIL 来自 Python 辅助 API 校验的 `SSLV3_ALERT_HANDSHAKE_FAILURE`；现场截图显示 App 已创建专业任务并进入 65% “生成音频”，故不等于 App 路由或任务创建失败。`WORK-004` 因当时没有可打开的生成中作品 BLOCKED。
- 模型选择：简易/专业为“轻量模型 100 积分/次”、“默认模型 20 积分/次”；歌曲改编为“轻量模型 100 积分/次”、“默认模型 100 积分/次”。选择、确认、回显及场景价格隔离 PASS。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-model-selection/`。
- 会员购买：月卡 0.01 元通过微信支付成功，有效期更新至 `2026-10-07`，积分 10770 → 11570，与月赠 800 一致，PASS。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-membership-purchase/`。
- 积分购买：800 积分 / 0.01 元通过微信支付成功，余额 11570 → 12370，PASS。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-points-purchase/`。
- 简易模式补跑：选择随机灵感、女声和默认模型，确认消耗 20 积分，完成任务创建、音频/海报生成并进入播放器，PASS。证据：`/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-simple-after-payment/`。
- 本轮仍不宣称 329 条全通过：315 条人工/专用数据/iOS 手工与外部能力用例保持 NOT_RUN，Python TLS 校验和 `WORK-004` 数据前置仍待处理。

## 14. 2026-09-07 iOS 真机自动化与双平台门禁

- 测试工程新增 Appium 3.7.0 和 XCUITest Driver 12.10.0；Python 主入口仍为 `main.py`，不修改 App 业务代码。
- 设备选择规则：优先 CoreDevice 可访问的已配对真机；没有真机才启动可用 iPhone Simulator；两者都没有时写入 `IOS-DEVICE-GATE=FAIL`，报告总体结论为 FAIL，命令退出码非 0。
- 本次实际设备：`Soul`，iPhone 14 Pro，iOS 26.3，UDID `00008120-0016253A2208201E`；使用已签名 `com.lxwx.catsinger 1.2.0 (121)` Debug 包。
- iOS 单平台 smoke：`python3 main.py run --suite smoke --platform ios --mode balanced`，Run ID `20260907-191052-0d1f10`，10 PASS、0 FAIL、0 BLOCKED、0 NOT_RUN，耗时 63.29 秒。
- 默认双平台 smoke：`python3 main.py run --suite smoke --mode balanced`，Run ID `20260907-191206-ec0c6c`，Android 10/10 PASS、iOS 10/10 PASS，合计 20 PASS、0 FAIL、0 BLOCKED、0 NOT_RUN，耗时 133.20 秒。
- iOS 单平台 full：`python3 main.py run --suite full --platform ios --mode balanced`，Run ID `20260907-192730-0befea`，314 条适用用例中 10 PASS、304 NOT_RUN、0 FAIL、0 BLOCKED，耗时 62.25 秒；总体为 `INCOMPLETE` 且命令返回非零，未执行项没有计为通过。
- 证据：双平台报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-191206-ec0c6c/`；Android 与 iOS 截图/UI XML 分目录保存，iOS 失败时额外保存 Appium/XCUITest 日志。
- iOS full 报告位于 `/Users/soul/code/lxwx/test/catsinger/artifacts/20260907-192730-0befea/`，包含 HTML、JSON、JUnit XML、纯文本汇总及已执行用例的截图/UI XML。
- 首轮 iOS 执行暴露测试执行器把创作页 App 名误判为首页，以及 XCUITest 元素缓存过期；两项均在测试工程修正。最终 10/10 结果为修正后的独立复跑，不覆盖或删除历史失败报告。
- 边界：本节证明 iOS 真机 P0 安全冒烟和默认双平台门禁可执行；iOS full 当前明确为 `INCOMPLETE`。StoreKit、系统文件选择器、首次权限、播放听感、后台回收及其余 manual/assisted 用例尚未全部执行，发布级整 App QA 继续为 `in_progress`。

## 15. 2026-09-17 音色素材本地暂存与服务端异步审核训练

- App 流程已纠正为：录音/选择文件仅生成本地素材卡片；用户点击继续/训练后才执行 MD5 查重、缺失资源直传和任务创建。通用 `LoadingDialog` 只显示一个动画和单行“正在加载中...”，且不可通过遮罩、系统返回或边缘返回关闭；任务 ID 返回后立即退出提交页，不在客户端等待素材审核或训练。
- App 定向执行：`flutter test test/song_voice_local_material_submission_test.dart test/song_voice_material_recording_page_test.dart test/song_voice_flow_matrix_test.dart test/song_voice_cards_test.dart`，30/30 PASS；覆盖暂停/继续、超短或超长录音仍能本地完成但提交被阻断、录音完成零网络、相同字节仅做卡片去重、失败重试时全部素材重新请求后端查重、后端命中后不重复 OSS 直传、本次返回资源 ID 写入 `materialResources`、任务成功不轮询、播放按钮状态和返回拦截。`flutter analyze` PASS。
- 后端执行：`./gradlew test --tests 'com.lxwx.narrateservice.VoiceCoverBusinessIntegrationTests'` PASS。新增证据覆盖原始 READY 资源创建任务后才审核、拒绝进入 `REJECTED` 并释放积分、审核异常进入 `FAILED`，且两种异常均未调用训练 Provider；旧素材 ID 与新资源输入继续兼容。
- Admin 定向执行：`flutter test test/song_voice_async_status_test.dart test/admin_song_voice_model_test.dart`，6/6 PASS；`flutter analyze` PASS。后台可筛选并区分“素材审核中”和“审核不通过”，不会将内容拒绝显示为训练系统失败。
- 数据库结论：本轮无表结构、字段、Flyway 或 SQL 改动；新增状态继续由现有 VARCHAR 字段承载。工作区中其他既有迁移改动未被覆盖或执行。
- 设备与边界：最新 Android Debug 包已构建并安装到 V1981A，当前账号按正确门禁停在“昵称审核中”，未绕过审核进入录音或提交；最新 iOS 375×812 模拟器包已构建、安装并启动。暂停/继续和超短录音本地完成由 375×812 Widget 测试验证。未部署正式环境、未执行正式 SQL、未发起真实上传或付费训练；系统文件选择、上传失败重试、列表实时状态及真实审核/Provider 仍须在资料审核通过且测试环境可用后单独验收，不能由 Widget/MockMvc 结果代替。

## 16. 2026-09-17 头像昵称仅在继续时上传送审

- 资料页选择头像、输入昵称和昵称失焦均只更新本地状态，不产生资源上传、审核提交或审核查询请求；“继续”是唯一网络提交入口。
- 点击“继续”后，可选头像先上传，再与必填昵称分别送审；两项通过后保存音色资料。头像上传失败保留本地预览，审核/查询失败后按钮恢复可用，再次点击“继续”复用正确的审核或查询语义。
- 头像与昵称定义为本次音色卡片资料。训练任务请求只携 `voiceProfileId`，测试断言其关联已保存的资料 ID；昵称、头像素材 ID及两项审核任务 ID由资料保存请求提交，避免训练请求重复信任客户端文本和 URL。
- App 定向执行：`flutter test test/song_voice_cards_test.dart test/song_voice_flow_matrix_test.dart test/song_voice_local_material_submission_test.dart test/song_voice_material_recording_page_test.dart test/song_voice_creation_flow_test.dart test/song_voice_profile_exit_gesture_test.dart test/song_voice_profile_rights_test.dart`，49/49 PASS；`flutter analyze` PASS；`git diff --check` PASS。当前源码 `flutter build ios --simulator --debug` PASS，并已安装、启动到 iOS 26.4 的 375×812 模拟器。
- 数据库、SQL、后端接口无改动。测试使用 HTTP 夹具证明客户端时序与请求归属，不代表真实头像存储、真实审核 Provider、训练厂商或训练完成列表回显已联调。

## 17. 2026-09-17 头像昵称审核单一通用加载框

- 当前视觉真源为 Figma `MXPuoHXZFWWks8vjkJjsEg` / `181:282`，并通过通道 `lgk3swwy` 核对。Flutter 375×812 证据为 App `artifacts/voice-profile-loading-qa/implementation/181-282-profile-loading.png`。
- 点击“继续”后，头像上传、两项送审/查询和资料保存始终保持一个不可退出 Dialog；页面本体没有头像上传中、头像/昵称审核中或按钮 loading 的第二套动画。
- 全局组件已正式命名为 `LoadingDialog`，未传文案时默认显示“正在加载中...”；业务可传入静态单行文案，或在同一个弹框内动态更新该行文字。素材、资料、最终朗读和支付阻塞过程统一复用；旧两行“上传中 / 请勿退出”、旧支付标题框及业务专属包装均已删除。
- App 执行 `flutter test --no-pub test/app_loading_test.dart test/song_voice_local_material_submission_test.dart test/song_voice_cards_test.dart test/payment_ui_test.dart`，`46/46` PASS；资料页和支付加载截图用例各 `1/1` PASS；`flutter analyze --no-pub` PASS。
- iOS 26.4 `Catsinger 375x812` 已完成当前源码 Debug 构建、安装和启动；没有发起真实支付、审核或训练任务。
- 后端接口、数据库和 SQL 均无改动。
