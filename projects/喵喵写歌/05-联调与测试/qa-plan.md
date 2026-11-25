# 喵喵写歌移动端全量用户功能测试计划

> 2026-09-20 [双端测试环境功能执行记录](v2.1-dual-functional-20260920.md)：原创写歌和专业写歌已完成算道真实生成、积分扣减、双端播放；歌曲改编可播放但韩文演唱 FAIL（DEF-V21-002），首页无真实案例却展示不可点击演示卡 FAIL（DEF-V21-003）。翻唱声音克隆缺可用测试音色，仍 BLOCKED。当前 182 条 V2.1 用例未逐条执行，QA 保持 `in_progress / FAIL`，不得据此进入正式包验收。

> V2.1 新需求执行入口（CHG-0084）：[独立全量用例目录](cases/v2.1-model-driven-params/README.md)、[覆盖矩阵](cases/v2.1-model-driven-params/coverage-matrix.md)、[测试数据和安全门禁](cases/v2.1-model-driven-params/test-data-and-safety.md)。2026-09-19 已进行[双端安全冒烟抽查](v2.1-dual-smoke-20260919.md)；2026-09-20 用[独立 V2.1 双端脚本自动复测](v2.1-auto-smoke-20260920.md)，18 个平台检查点 16 PASS / 2 FAIL，整曲来源弹层双端仍 FAIL（DEF-V21-001）。完整 V2.1 用例仍未逐条执行或验收。需求仍 `waiting_review`，翻唱声音克隆厂家闭环未执行。专业写歌/改编指定音色按 CHG-0085 延期，本期只验入口不可见和请求无指定音色；翻唱声音克隆音色选择仍必测。以下章节保留 V1.2 并行测试基线及历史结果，不作为 V2.1 当前预期。

> 测试版本：`v1.2.0+121-as-built`  
> 测试类型：Android/iOS 移动端用户功能测试  
> 当前状态：`in_progress`  
> 最近校准：2026-09-07  
> 关联变更：`CHG-0069`、`CHG-0071`

V1.2 历史/并行执行入口：`05-联调与测试/cases/v1.2.0+121-as-built/`。`v1.1.0-as-built` 和 `cases/00-10` 均为 `reference-only`，不得与 V2.1 目录混跑。

## 1. 测试目标

- 依据当前 Flutter、Java 后端和 Web/Admin 工作区代码，验证用户在 Android/iOS App 中实际可达的页面、入口、按钮和状态。
- 覆盖启动、登录、首页、写歌、改编、AI 翻唱、生成、作品、播放、后处理、会员积分、订单、任务邀请、设置和账号安全。
- 后端和后台只用于准备数据、切换配置及观察结果，不以接口直调或后台页面操作代替移动端步骤。
- 对未执行、环境不满足和高风险门禁分别报告 `NOT_RUN`、`BLOCKED`，不得伪报 PASS。

## 2. 不在范围

- 不编写或执行 App 业务单元测试、接口测试、源码测试和性能测试。
- 不单独验收 Web/Admin 页面；只验证其配置对移动端可见结果的影响。
- 不把代码中存在但当前用户没有入口的页面写成正常主链路。
- 不在本任务中修复发现的业务缺陷；缺陷单独登记并走新的 CHG。

## 3. 当前基线

- 代码快照：`05-联调与测试/mobile-code-test-baseline-v1.2.0+121.md`。
- App：`/Users/soul/code/lxwx/catsinger`，版本 `1.2.0+121`。
- Java 后端：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`。
- Web/Admin：`/Users/soul/code/lxwx/lxwx_admin`。
- Android/iOS Python 测试工程：`/Users/soul/code/lxwx/test/catsinger`；Android 使用 ADB，iOS 使用 Appium/XCUITest。
- 当前主导航：`首页 / 作品 / 我的` 三个 Tab。
- 当前首页入口：`AI写歌` 进入专业模式，`改编歌曲` 进入歌曲改编。
- 当前不可达能力：场景写歌四步、作品页草稿/喜欢主 Tab、专辑主 Tab、旧视频创作页。

## 4. 用例目录

| 文档 | 范围 |
|---|---|
| `01-startup-privacy-update.md` | 安装、升级、首次启动、隐私和版本更新 |
| `02-auth-session-platform.md` | Android/iOS 登录、游客、绑定和会话 |
| `03-home-navigation.md` | 三 Tab、首页、配置歌曲和迷你播放器 |
| `04-create-and-model.md` | 简易/专业写歌、AI 帮写、参考音频和模型选择 |
| `05-adaptation-and-cover.md` | 歌曲改编、AI 翻唱和音频边界 |
| `06-generation.md` | 生成确认、积分、幂等、进度和恢复 |
| `07-works-player-detail.md` | 作品、播放、歌词、后处理和专辑操作 |
| `08-commerce.md` | 会员、积分充值、流水、订单和恢复购买 |
| `09-growth.md` | 签到、任务、兑换和邀请；提现业务未交付，不纳入当前版本 |
| `10-profile-settings-account.md` | 我的、反馈、设置、隐私撤回、退出和注销 |
| `11-permission-network-config.md` | 权限、网络、中断、资源和后台配置联动 |
| `12-smoke-regression.md` | 快速冒烟、Core、付费和破坏性套件顺序 |
| `coverage-matrix.md` | 当前入口、按钮、状态到用例编号的映射 |
| `test-data-and-safety.md` | 账号、作品、音频、配置和危险操作门禁 |

V1.2 历史目录共 334 条用例：P0 171、P1 157、P2 6；自动 14、半自动 106、手工 214。数量由 Markdown 动态生成，后续代码变化时允许随用例增减，不写死固定总数。

Catalog 数量表示用例定义数；`platform=both` 的条目在默认双平台套件中分别生成 Android 和 iOS 执行结果，所以报告结果总数可以大于 334。

## 5. 用例结构

每条用例必须包含：

- 用例编号、模块、标题、平台、优先级、风险等级。
- 前置条件、后台配置、账号和资源数据。
- 一步一个动作的移动端操作步骤，以及对应的页面可见结果。
- 积分、订单、作品、任务等后端可观察结果。
- 截图、UI XML、订单号、任务号或作品号等证据。
- `automated / assisted / manual` 自动化等级。

## 6. 测试数据

- 账号：未登录设备、普通账号、低积分账号、会员账号、另一隔离账号、邀请人/被邀请人、iOS 游客、Apple Sandbox 和一次性注销账号。
- 作品：原创、纯音乐、翻唱、生成中、失败、静态歌词、时间轴歌词、无封面和失效资源。
- 音频：MP3/WAV/M4A/AAC/FLAC/MP4 合法文件，以及 5 秒、6 秒、6 分钟、6 分 01 秒、50MB、50MB+1、损坏和伪扩展名文件。
- 后台配置：启用/禁用模型、不同积分价格、默认模型、翻唱音色、首页歌曲、商品、任务、邀请规则和版本更新。

详细准备规则见 `cases/v1.2.0+121-as-built/test-data-and-safety.md`。

## 7. 风险门禁

| 风险 | 执行条件 | 自动化开关 |
|---|---|---|
| 普通只读/校验 | 测试或允许的只读环境 | 无 |
| 生成与支付 | 仅测试环境、测试积分、支付宝测试链路或 Apple Sandbox | `--allow-paid` |
| 删除作品 | 只删本次运行记录的测试作品 | `--allow-delete` |
| 注销账号 | 一次性账号 | `--allow-account-delete` |

隐私撤回、支付、作品删除和账号注销必须由执行人确认环境。正式环境禁止自动写入。

## 8. Android/iOS 自动化套件

| 套件 | 行为 |
|---|---|
| `smoke` | 默认 Android 10 条 + iOS 10 条快速只读冒烟；各平台平衡模式复用 App 会话 |
| `core` | 当前 `automated + P0/P1 + normal` 全部无风险主流程 |
| `paid` | 生成、充值等付费风险用例；无开关时 BLOCKED |
| `destructive` | 删除和注销用例；分别检查独立开关 |
| `full` | 汇总当前所有条目；手工/半自动显示 NOT_RUN |

常用命令：

```bash
cd /Users/soul/code/lxwx/test/catsinger
python3 main.py sync
python3 main.py catalog
python3 main.py ios-setup
python3 main.py doctor
python3 main.py run --suite smoke
python3 main.py run --suite core
python3 main.py run --suite smoke --mode isolated
python3 main.py run --suite smoke --platform ios
```

默认平台范围为 `all`。iOS 设备选择顺序固定为：已配对可用真机、可用 iPhone Simulator；真机和模拟器都不存在时必须生成 `IOS-DEVICE-GATE=FAIL` 并返回非零退出码。`--platform android/ios` 只用于单平台排障，不能替代发布级双平台结论。

每条自动执行用例保存截图和 UI XML，失败时 Android 额外保存 logcat、iOS 额外保存 Appium/XCUITest 日志。每次运行输出 HTML、JSON、JUnit XML、`summary.txt` 和按模块统计，控制台实时打印用例编号、标题、平台、风险、状态、耗时和失败原因。

总体结论：存在 `FAIL/BLOCKED` 时为 `FAIL`；无失败但仍有 `NOT_RUN` 时为 `INCOMPLETE`；所有目标执行结果均为 PASS 时才为 `PASS`。前两者均返回非零退出码，防止把尚未执行的 iOS/外部能力误报为全量通过。

## 9. 手工执行

- iOS 稳定 P0 主链路使用 Appium/XCUITest 自动执行；其余用例继续依据同一目录在真机手工或半自动执行，StoreKit 必须使用 Apple Sandbox。
- Android/iOS 系统文件选择、支付 App 返回、权限首次授权、音频焦点、后台回收等以手工、ADB 或 XCUITest 辅助执行。
- 支付、隐私撤回和账号注销不得混用日常账号。
- 当前不可达能力只记录缺口，不通过深链或调试路由伪造成用户可达。

## 10. 通过标准

- 当前每个用户可见入口、按钮和状态至少关联一条用例，覆盖矩阵无悬空编号。
- 核心业务覆盖成功、校验失败、服务失败和恢复状态。
- P0/P1 实际执行项必须 100% 通过；未执行项保持 NOT_RUN，环境阻塞项保持 BLOCKED。
- Android 与 iOS 都完成 `doctor`、`smoke` 和无风险 `core`，并生成完整证据报告；iOS 缺少真机和模拟器时测试直接不通过。
- iOS 其余手工清单逐项保留真实状态；StoreKit 明确 Sandbox 条件。
- 歌曲改编正向生成用例必须等待本次任务生成目标作品，并实际播放且进度连续增长至少 5 秒后才可 PASS；提交成功、进入生成页或仅显示任务成功均不构成通过。任务失败/取消、超时、作品或音频缺失、资源失效、无法播放或进度不增长均判定 FAIL。
- 至少一次真实写歌、真实翻唱及自有音频/封面资源持久化验收，才能关闭整 App QA。

## 11. 当前验证记录

- 2026-09-05：代码基线和 338 条模块化用例已生成，覆盖矩阵校验通过。
- 2026-09-05：Python `compileall`、23 项框架自检通过；目录动态读取，不再依赖旧 147 条固定数量。
- 2026-09-05：Android smoke 10/10 PASS；core 12 PASS、0 FAIL、1 BLOCKED，阻塞原因为账号没有生成中作品。
- 2026-09-05：doctor 的设备、App 版本、目录和后端健康通过；测试服务器 catsinger 路由返回 `Unsupported X-App-Code`，依赖业务接口的闭环保持阻塞。
- 2026-09-07：执行无高风险授权的安全全量套件，338 条中 12 PASS、0 FAIL、2 BLOCKED、324 NOT_RUN；`FLOW-CREATE-001` 因未授权付费被安全门禁阻断，`WORK-004` 因账号没有生成中作品阻断。测试服务器 catsinger 路由仍返回 `Unsupported X-App-Code`。
- 2026-09-07：用户随后授权付费、删除作品和提现。付费套件 57 条中 1 FAIL、56 NOT_RUN；唯一自动闭环 `FLOW-CREATE-001` 在进入创作提交前即因 catsinger 路由 HTTP 400 失败，未创建任务或扣减积分。destructive 套件 16 条均为 manual/assisted，因此 16 NOT_RUN，未删除作品、未提现；账号注销仍未授权。
- 2026-09-07：用户纠正“提现业务并未实现”。确认此前基线误把仓库中的页面/API 代码骨架当成已交付业务；移除 `WITHDRAW-001`～`WITHDRAW-008` 及依赖提现页的 `INVITE-008`，动态目录更新为 329 条。此前 338 条报告保留为历史执行证据，不再代表当前有效用例范围。
- 2026-09-07：按纠正后的 329 条目录执行 `full --allow-paid --allow-delete`，结果为 12 PASS、1 FAIL、1 BLOCKED、315 NOT_RUN。`FLOW-CREATE-001` 因测试服 `Unsupported X-App-Code` FAIL，未创建任务或扣积分；`WORK-004` 因账号没有生成中作品 BLOCKED；删除项需要人工/专用数据，未发生删除。
- 2026-09-07：CHG-0071 接入 Appium/XCUITest 和真机优先/模拟器兜底门禁；31 项测试工程自检、329 条 catalog 校验通过。iOS 真机 smoke 10/10 PASS（`20260907-191052-0d1f10`）；默认 Android+iOS smoke 20/20 PASS（`20260907-191206-ec0c6c`）。
- 2026-09-07：iOS 真机 `full` 运行 314 条适用用例，结果 10 PASS、304 NOT_RUN、0 FAIL、0 BLOCKED（`20260907-192730-0befea`），总体为 `INCOMPLETE` 并返回非零；304 条仍需专用数据、系统/外部能力或人工执行。
- 2026-09-09：补齐专业模式“歌词 + 参考音频 + 付费生成 + 成品播放”组合缺口，新增 `AUDIOREF-008`～`AUDIOREF-012`，覆盖作品库和本地音频闭环、删除/更换、上传失败重试及生成同款回填。Catalog 更新为 334 条，31 项测试工程自检通过；新用例尚未真机执行。
- 完整命令、报告路径和边界见 `test-execution-record.md`。
- iOS 自动 smoke 已执行；iOS manual/assisted 全量、Apple Sandbox、外部支付、真实 Provider、删除与注销尚未执行。

## 12. 缺陷处理

发现问题时记录：缺陷编号、版本、平台/机型、账号数据、前置配置、逐步复现、实际/预期、截图/UI XML/logcat、任务/作品/订单号、严重度和关联用例。P0/P1 修复必须另建 CHG，并重跑受影响模块；本任务不顺手修改三端业务代码。

## 13. 当前结论

`in_progress`。当前 334 条全量用户功能测试只有在对应条目真实执行并留存证据后才能形成发布级 QA 结论；提现不属于本版本验收范围。
