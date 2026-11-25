# 喵喵穿搭 AI 辅助测试执行记录

> 执行日期：2026-09-28（PDT）  
> 执行方式：Codex 终端自动化 + Flutter 测试 + iOS 模拟器只读 UI 冒烟 + Android 真机素材链路  
> 参考基线：喵喵写歌 `05-联调与测试/qa-plan.md`、`test-execution-record.md`、`21-qa-cases.mdc`  
> 当前结论：`FAIL / INCOMPLETE`，不是正式第15阶段全量验收

## 1. 执行基线

| 项 | 本轮基线 |
|----|----------|
| App 工程 | `/Users/soul/code/lxwx/catoutfit` |
| 分支 / commit | `dev@fd77afd`，执行前后 Git 工作树干净 |
| App 版本 | `1.0.0+1` |
| Flutter / Dart | Flutter `3.41.6` stable / Dart `3.11.4` |
| 后端工程 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，`dev@2dcd82ad` |
| iOS 设备 | `Catsinger 375x812` 模拟器，iOS 26.4；以独立包名安装 `com.lxwx.catoutfit` |
| Android | Debug APK 构建；CHG-0007 使用 Android 12 真机 `V1981A` 完成测试用户登录与素材链路 |
| 测试文档 | `qa-plan.md` v0.1.0-test-design.3，152条设计用例 |

后端工作树在本轮开始前已有 `README.md`、`ServerApplication.java` 和 `ServerApplicationStartupTests.java` 相关改动；本轮未覆盖、回退或修改这些内容。

## 2. 安全边界

CHG-0005 仅执行安全、非付费、非破坏性测试；CHG-0007 在用户明确授权测试账号并增加测试积分后，补充执行 TEST 环境真实 AI 素材链路：

- CHG-0005 未传入 `QA_ACCESS_TOKEN`，当时没有执行真实 AI 生成和积分消耗；CHG-0007 通过 App 使用测试用户真实执行了两次衣橱解析和一次首次免费搭配生成。
- 未开启支付、删除作品、删除账号、注销、真实短信或生产写入；CHG-0007 的 AI 调用仅发生在 TEST 环境。
- iOS 集成冒烟使用 `PRIVATE_IMAGE_LOCAL_UPLOAD=true`；测试在登录提交前因脚本错误终止，没有上传真实用户照片。
- 手工冒烟只进行页面导航、协议接受/拒绝和空表单校验，没有提交账号凭据。

数据库改动：无。前端、后端和测试源码改动：无。

## 3. Flutter 代码测试

### 3.1 全量单元与 Widget 测试

- 命令：`flutter test --no-pub`
- 结果：**268 PASS / 1 FAIL，共269条**。
- 失败：`test/app_identity_test.dart` 中“debug builds keep the local service environment by default”。
- 稳定复跑：单独执行同一用例仍为 `Expected: 1 / Actual: 2`。
- 根因证据：`Global.currentServerAddressType` 当前为 `2`（测试服务器），测试与同文件注释仍要求 `1`（本地服务）。
- 缺陷：[DEF-0002](defects/DEF-0002.md)。

测试中打印的 StoreKit、网络失败、缓存损坏等错误日志均来自异常分支断言；除上述环境断言外，其余用例最终通过，不能把预期异常日志误记为新增失败。

### 3.2 静态分析

- 命令：`flutter analyze --no-pub`
- 结果：**PASS**，`No issues found`，耗时4.6秒。

### 3.3 构建

| 平台 | 命令 | 结果 |
|------|------|------|
| Android Debug | `flutter build apk --debug --no-pub` | PASS；生成 `app-debug.apk` |
| iOS Simulator Debug | `flutter build ios --simulator --debug --no-pub` | PASS；生成 `Runner.app` |

构建通过只证明可编译打包，不代表业务链路通过。

## 4. iOS 自动集成冒烟

- 命令：`flutter test --no-pub integration_test/pre_release_smoke_test.dart -d 874D1488-95E5-4C7B-870B-8E799442EA5E --dart-define=PRIVATE_IMAGE_LOCAL_UPLOAD=true`
- 结果：**0 PASS / 1 FAIL**；Xcode 构建成功，测试在登录表单阶段失败。
- 实际失败：`integration_test/pre_release_smoke_test.dart:98` 用 `find.byType(AppAgreementIcon)` 查找协议控件，得到 `Bad state: No element`。
- 代码现状：登录页已使用私有 `_AuthAgreementIcon`，稳定语义入口为 `ValueKey('auth-agreement-row')`。
- 判定：**测试脚本过期，不足以证明登录功能失败**。随后 AI 只读冒烟验证登录选择页、手机号表单、协议门禁和空手机号提示均可见可操作。
- 缺陷：[DEF-0003](defects/DEF-0003.md)。

## 5. AI 只读 UI 冒烟

| 检查点 | 操作 | 可观察结果 | 状态 |
|--------|------|------------|------|
| PRIVACY-RO-001 | 首次启动点击“不同意” | 进入可浏览首页；登录、创作仍受协议门禁保护 | PASS |
| HOME-RO-001 | 检查首页和底部导航 | 首页、衣橱、作品、我的四个 Tab 可见；AI搭配、试衣、妆容、发型、测评入口可见 | PASS |
| WARDROBE-RO-001 | 打开空衣橱 | 展示空态、分类、搜索、筛选和添加入口；当前容量显示 `0/100件` | PASS（实现现状） |
| WORK-RO-001 | 游客打开作品 | 展示“登录后查看作品”和“立即登录”，未泄露作品 | PASS |
| ACCOUNT-RO-001 | 游客打开我的 | 会员卡、积分充值、订单、流水、邀请、反馈、客服、设置入口可见 | PASS |
| SETTINGS-RO-001 | 打开更多设置 | 权限、协议、退款、算法备案、版本、更新、缓存入口可见 | PASS |
| AUTH-RO-001 | 从我的进入登录 | 拒绝协议后重新触发协议门禁；同意后展示游客登录、手机号登录、恢复购买 | PASS |
| AUTH-RO-002 | 切到手机号登录并空提交 | 协议未勾选提示“请先阅读并同意…”；勾选后提示“请输入手机号” | PASS |
| MEMBER-RO-001 | 检查未开通会员卡 | 页面宣称“高清保存 · 优先生成”，后端商品/权益没有对应字段 | **FAIL** / DEF-0001 |

### 5.1 页面证据

![会员卡未受后端权益支撑的文案](artifacts/20260928/ios-account-membership.png)

![衣橱当前后端与客户端统一显示100件](artifacts/20260928/ios-wardrobe-capacity.png)

衣橱 `100件` 与当前实现一致：后端 `CatoutfitApp.WARDROBE_CAPACITY=100`，客户端安全回退同为100。它与 PRD 中仍待选择“10或30”的 `TBD-P0-01` 不一致，属于需求文档待同步，不按本轮产品缺陷重复登记。

## 6. Java 后端定向测试

- 命令：`./gradlew test --tests 'com.lxwx.narrateservice.app.catoutfit.*' --tests 'com.lxwx.narrateservice.core.product.service.CatoutfitProductCatalogTest' --tests 'com.lxwx.narrateservice.core.resource.service.CatoutfitPrivateImageRetryTests'`
- 结果：**BLOCKED，喵喵穿搭用例实际执行0条**。
- 阻塞点：Gradle 在过滤执行前仍需编译全量测试源码；`SellerProductPitchRoundOneTests` 有5处调用旧版 `CatsellerVoiceoverPolicy.maximumCharacters(int)`，而当前签名需要3个参数，导致 `compileTestJava` 失败。
- 边界：这是共享后端的喵喵带货测试编译阻塞，不能据此判定喵喵穿搭后端失败；本轮没有修改或绕过该测试。

## 7. 需求与实现对账发现

| 项 | 当前实现证据 | 文档状态 | 处理结论 |
|----|--------------|----------|----------|
| 衣橱容量 | 后端/客户端均为100件 | `TBD-P0-01` 仍问10或30 | 后续按“已完成业务以后端为准”同步需求，当前不再向产品询问10/30 |
| 档案容量 | 后端 `PROFILE_CAPACITY=5` | P0-01与衣橱合并提问 | 应拆分并按后端现状同步 |
| 作品留存 | 后端 `WORK_RETENTION_DAYS=15` | `TBD-P1-01` 仍待确认起算点 | 15天数值可视为已实现，起算事件仍需核对服务实现 |
| 会员商品 | 当前 `products.json` 已有月/季/年卡与积分商品 | Review仍记录过“商品为空”的历史基线 | 应按当前后端刷新文档，不把旧快照当现状 |
| 会员权益展示 | 客户端写死高清保存、优先生成、衣橱100/500 | 后端商品只定义周期积分等商品数据 | 产品误导风险，登记 DEF-0001 |

该表是测试发现，不在本轮静默修改 PRD/Review；同步需求时还需核对当前后端 commit 和服务实现，避免只看常量或默认 JSON。

## 8. 未执行范围

- Android 已覆盖一台 Android 12 真机的测试用户登录、档案照片预检、衣橱解析、首次免费搭配和作品落库；仍未覆盖更多机型、系统版本及 iOS 真机完整链路。
- 真实短信登录、游客账号服务端创建、跨设备会话。
- 真实会员/积分商品加载、Apple Sandbox、微信/支付宝支付、回调和补单。
- 已覆盖一次真实 TEST 环境搭配生成、两次衣橱解析及成功扣分；仍未覆盖 AI 试衣、发型、彩妆、报告、失败/取消/超时退款和作品到期清理。
- 已上传 AI 合成人物和衣物；未使用真人照片，未覆盖彩妆商品和保存到系统相册。
- 152条 QA 设计用例逐条执行、性能、弱网、无障碍和Figma像素级验收。

未执行项保持 `NOT_RUN`，环境或测试工程阻塞项保持 `BLOCKED`，不得计入通过率。

## 9. 当前结论

本轮结论为 **FAIL / INCOMPLETE**：

- Flutter代码测试大部分通过，但存在1个稳定环境断言失败。
- 静态分析、Android Debug和iOS Simulator Debug构建通过。
- iOS自动冒烟被过期测试选择器阻断；AI只读冒烟证明当前登录表单本身可操作。
- 发现1个用户可见的会员权益文案缺陷。
- Java喵喵穿搭定向测试被共享工程其他模块的测试编译错误阻断。
- Android TEST 环境已打通一条代表性真实 AI 闭环并发现 DEF-0004，但失败退款、支付、删除、跨端和其他 AI 模块仍未执行，因此不能进入发布级 QA，更不能据此推进构建打包阶段。

项目总流程继续保持 `02 需求文档生成 / waiting_review`，第15阶段继续为 `pending`。

## 10. Android 真机素材链路补充执行

- 完整记录：[material-test-execution-record.md](material-test-execution-record.md)。
- 登录：使用后台创建的 TEST 测试用户及本地验证码通道成功登录；敏感登录信息未进入文档。
- 人物：正脸与全身正向素材通过；面部遮挡和双人负向素材均被准确拦截；档案保存成功。
- 衣橱：白衬衫识别1件，多单品平铺图识别4件；两张原图各扣5积分，余额 `1030 → 1025 → 1020`。
- 搭配：首次免费生成成功，使用4件衣橱单品，作品列表新增1件并显示15天留存；余额保持1020。
- 缺陷：衣橱缩略图保存后不会自动加载，单张手动重试可恢复，登记 [DEF-0004](defects/DEF-0004.md)。
- 结论：本批次核心链路通过但有P1缺陷；不改变整轮 `FAIL / INCOMPLETE` 和正式 QA `pending` 状态。
