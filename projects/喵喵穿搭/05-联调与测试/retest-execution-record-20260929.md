# 喵喵穿搭前置复测记录（QA-RUN-20260929-01）

> 结论：`FAIL / INCOMPLETE`。这是第02阶段中的前置复测，不是第15阶段正式 QA 验收，也不是 P01～P30 全量通过报告。

## 1. 基线与范围

| 项 | 本轮记录 |
|----|----------|
| 时间 | 2026-09-29，Android 本机页面约 16:48～17:02（设备时钟） |
| Flutter 工程 | `/Users/soul/code/lxwx/catoutfit`，HEAD `fd77afd`，已有未提交改动；未修改代码 |
| Java 工程 | `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，HEAD `2dcd82ad`，已有未提交改动；未修改代码 |
| 手机与安装包 | Android 12 真机 `V1981A`，设备 `e2b8595a`；包 `com.lxwx.catoutfit`，`1.0.0+1`，系统记录更新于 2026-09-29 10:17:20 |
| 环境/账号 | TEST 已登录测试账号；复测开始和结束积分均为 1020；验证码和手机号未写入本记录 |
| 版本边界 | 未重建/重装 App，不能证明已安装包包含当前工作树的全部未提交改动；手机结果与当前源码自动测试分开评价 |
| 安全边界 | 仅页面浏览、空反馈提交拦截、未勾协议购买拦截、一次强制停止后冷启动；未新增 AI 任务、扣分、支付订单、提交反馈、删除内容、改数据库或生产环境 |

页面状态口径：`FAIL` 是本轮有可复现偏差；`PARTIAL` 只证明所述子路径；`NOT_RUN` 是本轮未验证，不能当作合格；`BLOCKED` 是测试未能进入目标检查点。

## 2. 直接不合格项

| 影响页面 | 缺陷 | 本轮证据 | 结论 |
|----------|------|----------|------|
| P08 衣橱列表、P11 AI 试衣选衣 | [DEF-0004](defects/DEF-0004.md) P1 | 5 件中 4 件图片已显示，但绿色上衣在衣橱等待后仍为“重新加载”；试衣选衣弹层同一单品也无法显示。较 2026-09-28 的 5/5 失败有所改善，**仍未修复**。[衣橱](artifacts/20260929/wardrobe-reload.png) / [试衣弹层](artifacts/20260929/tryon-picker-reload.png) | FAIL |
| P20 我的、P21 会员中心 | [DEF-0001](defects/DEF-0001.md) P1 | 会员界面仍宣称“500 件衣橱、高清保存、优先生成”；当前后端 `CatoutfitWardrobeService` 对所有用户统一限制 100 件，未见该三项对应的穿搭权益执行契约。至少“500 件”与已实现限制直接冲突。[会员权益截图](artifacts/20260929/membership-benefits.png) | FAIL |
| P09 衣物编辑 | [DEF-0005](defects/DEF-0005.md) P2（新增） | 已有衣物打开为“编辑单品”，主按钮却写“加入衣橱”；当前源码保存分支实际更新旧记录，因此仅判定文案不符，不判定重复新增。[编辑页截图](artifacts/20260929/wardrobe-edit-label.png) | FAIL |

上述是 **3 个缺陷影响 5 个页面/子入口**，不是 5 个独立缺陷。DEF-0003 iOS 冒烟脚本过期沿用 open，本轮未重跑，不能称本轮复现。

## 3. P01～P30 逐页复测索引

| 页面 | 本轮状态 | 实际测到的边界 |
|------|----------|----------------|
| P01 启动 | PARTIAL | Android 强制停止后冷启动，登录态恢复到首页；首装、协议升级、弱网未测 |
| P02 登录注册 | NOT_RUN | 沿用已登录会话；未重新获取验证码或登录 |
| P03 协议 | NOT_RUN | 未测首次同意、拒绝和版本更新 |
| P04 首页 | PARTIAL | 首页与 AI 工具入口可浏览；新人礼、异常恢复未测 |
| P05 档案列表 | PARTIAL | 已有测试档案可见；空态、新建和切换未测 |
| P06 档案创建/编辑 | NOT_RUN | 本轮未修改档案；前轮素材测试不能算本轮通过 |
| P07 档案详情 | PARTIAL | 已有档案的全身照、正脸照可显示；编辑/删除未测 |
| P08 衣橱列表 | FAIL | 5 件数据可列出，但 1 件图片在等待与再次进入后仍需手动重新加载，见 DEF-0004 |
| P09 衣物新增/编辑 | FAIL | 已有单品的编辑页可打开，但按钮文案误写“加入衣橱”，见 DEF-0005；保存未测 |
| P10 衣物详情 | NOT_RUN | 点卡片实际进入编辑表单；未验证独立详情、删除与关联操作，不据此判缺陷 |
| P11 AI 试衣 | FAIL | 表单/选衣弹层可打开，同一绿色上衣缩略图失败，见 DEF-0004；生成未测 |
| P12 AI 搭配 | PARTIAL | 入口和表单可打开，已用首免后显示 20 积分；本轮未生成/扣分 |
| P13 发型 | PARTIAL | 表单与已有正脸照可显示；生成未测 |
| P14 彩妆 | PARTIAL | 表单与已有正脸照可显示；识别、试妆生成未测 |
| P15 报告列表 | NOT_RUN | 本轮未找到/验证独立列表路径 |
| P16 报告生成 | PARTIAL | 已有全身/正脸照片回填；生成按钮前置条件未满足，未发任务 |
| P17 报告详情 | NOT_RUN | 无本轮报告结果可查看 |
| P18 作品列表 | PARTIAL | 前轮生成的 1 件作品仍列出、缩略图可显示；筛选/删除未测 |
| P19 生成结果 | PARTIAL | 打开既有搭配作品，生成图和所用 4 件单品可显示；下载/分享/过期未测 |
| P20 账户 | FAIL | 资料/积分入口可见，但会员卡权益文案与已实现规则冲突，见 DEF-0001 |
| P21 会员 | FAIL | 商品页能打开，未勾服务协议点击购买会提示先同意；权益表仍错误，见 DEF-0001；未创建订单/支付 |
| P22 积分充值 | PARTIAL | 商品列表/余额可见；未下单，不评价定价或支付 |
| P23 积分流水 | PARTIAL | 流水页与 1020 余额可见；未发新扣分/退款交易 |
| P24 任务中心 | NOT_RUN | 本轮未进入签到/邀请路径 |
| P25 订单列表 | PARTIAL | 空订单列表可显示；状态筛选、刷新与分页未测 |
| P26 订单详情 | NOT_RUN | 无本轮订单可查看 |
| P27 支付结果 | NOT_RUN | 本轮未发起支付，成功/取消/超时恢复均未测 |
| P28 设置 | PARTIAL | 设置页可打开；清缓存、退出/注销未测 |
| P29 反馈 | PARTIAL | 页面可打开，空内容提交被“请输入反馈内容”拦截；有效提交未测 |
| P30 客服 | PARTIAL | 客服页可打开并加载联系方式；外部联络和失败降级未测，联系方式不落盘 |

P31 下载候选页不在用户本次 P01～P30 范围；本轮也未验证。上表的 PARTIAL 不计为整页 PASS，正式 152 个检查点未逐条裁决。

## 4. 自动测试与阻塞

| 检查 | 命令/结果 | 解释 |
|------|-----------|------|
| Flutter 全量测试 | `flutter test --no-pub`；退出码 1；269 PASS / 1 FAIL | 唯一失败为 [DEF-0002](defects/DEF-0002.md)：`test/app_identity_test.dart:68` 仍期望 Debug 默认本地环境 `1`，实际为 TEST `2`。当前源码测试总数 270；不能宣称全通过 |
| Flutter 定向复现 | `flutter test --no-pub test/app_identity_test.dart -r expanded`；退出码 1；2 PASS / 1 FAIL | 重现同一环境口径冲突，无新失败类型 |
| Flutter 静态分析 | `flutter analyze --no-pub`；退出码 0，No issues found | 只证明静态分析通过，不证明功能通过 |
| Java 穿搭定向测试 | `./gradlew test --tests 'com.lxwx.narrateservice.app.catoutfit.CatoutfitProfilePhotoUploadValidatorTests' --tests 'com.lxwx.narrateservice.app.catoutfit.CatoutfitWardrobeServiceTests' --tests 'com.lxwx.narrateservice.app.catoutfit.CatoutfitResourceGuardTests' --tests 'com.lxwx.narrateservice.app.catoutfit.CatoutfitGenerationServiceTests'`；退出码 1 | `compileJava` 通过，但 `compileTestJava` 被共享工程 `SellerProductPitchRoundOneTests` 的 5 处旧方法签名调用挡住；**穿搭定向用例执行 0 条**，属于 BLOCKED，不是后端业务用例失败 |
| iOS 冒烟 | 本轮未执行 | 旧 [DEF-0003](defects/DEF-0003.md) 保持 open，但不能写成此次复现 |

## 5. 结论与后续门禁

- 当前明确不合格：P08、P09、P11、P20、P21；源码自动测试还有 DEF-0002。既有 DEF-0003 未回归，Java 穿搭测试被共享测试编译错误阻断。
- 本轮未运行真实 AI 生成、失败退分、支付、下载、删除、登录验证码、跨端、弱网、性能、无障碍或 Figma 像素对比；这些均是**未验证**，不是“通过”。
- 未修改 Flutter/Java 工程、TEST 用户数据、商品配置、数据库；积分维持 1020。修复后需在可追溯提测包上重跑相关页面及支付/积分等高风险主链路。
- 项目仍为 `02 / waiting_review`；第15阶段保持 `pending`，正式验收不得标 PASS。

## 6. 同日独立维护后续记录（不覆盖上述已安装包结论）

| 范围 | 源码检查结果 | 设备/完整用例结论 |
|------|--------------|-------------------|
| P20/P21 · DEF-0001 | 无后端依据的权益文案已从源码移除；商品加载/切换/空态/缺字段 Widget 用例通过 | 本节前述 Android 安装包仍为 FAIL；新可追溯包未安装复测 |
| P09 · DEF-0005 | 新增“加入衣橱”、编辑“保存修改”的 Widget 断言通过；保存实现仍走更新接口 | 未在新包点击编辑保存并核对列表件数；不能判定整页通过 |
| 默认 TEST · DEF-0002 | 环境常量未改，身份测试断言已对齐；Flutter 全量串行复跑退出码0 | 新提测包实际连接目标未核对 |
| iOS 协议定位 · DEF-0003 | 稳定 Key 和当前勾选状态操作已实现 | 独立 iOS 26.4 模拟器已越过旧定位点、测试登录进入试衣页；后续约4分钟未结束，人工中止，整条 `INCOMPLETE`；[截图](artifacts/20260929/ios-isolated-smoke-past-login.png) |

本节仅描述 CHG-0010～0013 的源码/隔离模拟器后续证据。全量测试有一次通过、两次各失败1项；单并发定位为 `generation_recovery_test.dart` 的发型模板私有上传凭证校验失败（271 PASS / 1 FAIL），经过并行图片/上传修复所改的服务文件，本轮不跨范围修复。五个相关定向测试文件 61 PASS，`flutter analyze --no-pub` 和 `git diff --check` 通过。原 Android 安装包的 P08/P11/09/20/21 结果、Java 测试阻塞和第15阶段 `pending` 状态均不被本节改写；详见 [QA 计划第19节](qa-plan.md#19-2026-09-29-独立缺陷维护后的源码回归chg-0010-0013)。
