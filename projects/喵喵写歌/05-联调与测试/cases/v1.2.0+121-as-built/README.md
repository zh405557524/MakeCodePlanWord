# v1.2.0+121-as-built 移动端全量用户测试

本目录是当前执行入口。用例依据为 `../../mobile-code-test-baseline-v1.2.0+121.md` 和三端当前工作区代码，不读取旧 `v1.1.0-as-built` 用例作为预期真源。

## 用例字段

每个模块表固定使用 15 列：ID、模块、标题、平台、优先级、风险、前置条件、测试数据、测试步骤、预期结果、后端观察、证据、自动化、Handler、标签。

- 平台：`android / ios / both`
- 风险：`normal / paid / external / delete / account_delete`
- 自动化：`automated / assisted / manual`
- 多步骤用 `<br>` 分隔，执行时一行只做一个动作。

## 模块索引

| 文件 | 内容 |
|---|---|
| `01-startup-privacy-update.md` | 安装、升级、首次启动、隐私、更新 |
| `02-auth-session-platform.md` | Android/iOS 登录、游客、绑定、会话 |
| `03-home-navigation.md` | 三 Tab、首页、配置歌曲 |
| `04-create-and-model.md` | 简易/专业写歌、歌词、参考音频、模型选择 |
| `05-adaptation-and-cover.md` | 歌曲改编、AI 翻唱、音频边界 |
| `06-generation.md` | 生成确认、积分、进度、失败恢复 |
| `07-works-player-detail.md` | 作品、播放器、歌词、后处理、专辑 |
| `08-commerce.md` | 会员、积分、订单、支付与恢复购买 |
| `09-growth.md` | 任务、兑换与邀请；提现业务未交付，不属于当前版本测试范围 |
| `10-profile-settings-account.md` | 我的、反馈、设置、账号安全和注销 |
| `11-permission-network-config.md` | 权限、网络、中断、资源、后台配置联动 |
| `12-smoke-regression.md` | P0/P1 冒烟执行顺序，不重复定义用例 |
| `coverage-matrix.md` | 当前可达页面/动作与用例映射；不可达能力单列 |
| `test-data-and-safety.md` | 账号、作品、音频、后台配置和危险操作门禁 |

## 执行说明

- Android 稳定 P0/P1 通过 ADB 执行；iOS 稳定 P0/P1 通过 Appium/XCUITest 执行，统一入口为 `/Users/soul/code/lxwx/test/catsinger`。
- iOS 优先真机、无真机时使用模拟器；两者均不可用时测试 FAIL。系统选择器、StoreKit、首次权限和注销仍以手工/半自动执行为准。
- `paid/destructive` 用例必须使用测试环境和一次性数据；没有危险开关时自动化只能报告 `BLOCKED/NOT_RUN`。
- 用例未实际执行时不得填写 PASS。
