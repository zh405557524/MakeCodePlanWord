# Flutter 模块 05：邀请提现自动化与对稿回归

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-F009`
> 工程：`/Users/soul/code/lxwx/catseller`

## 1. 功能定位与边界

为 T-F001～T-F008 建立 Model/API/Controller/Widget/WebView/导航/构建门禁，并对照 22 张 Figma 素材检查主状态。本模块不用截图比对替代业务断言，不把工猫 Mock 通过宣称为真实渠道验收完成。

数据库改动：无。

## 2. 测试入口与文件

- `test/apis/invite_test.dart`：合同、幂等键和错误映射。
- `test/models/invite/`：九态、未知态、负金额、脱敏卡和空字段。
- `test/pages/invite/`：P01～P09、D01～D03 的 Controller/Widget/导航/WebView 测试。
- 真机验收：Android/iOS 相机权限、H5 回跳和系统返回。

## 3. 依赖前置

- [00-invite-contract-routing.md](./00-invite-contract-routing.md) 至 [04-invite-withdrawal-results-web.md](./04-invite-withdrawal-results-web.md) 均已实现并可注入 fixture/mock transport。
- Java OpenAPI 与稳定错误码已冻结。
- 22 张素材与 [figma-design-plan.md](../../01-需求/figma-design-plan.md) 为视觉基线。

## 4. 视觉参考与设计稿分析

遍历 [invite-withdrawal 素材目录](../../01-需求/references/images/invite-withdrawal/) 的 22 张 PNG，对照页面从上到下的导航、卡片、进度、金额、按钮、底部弹层、列表/空态和安全区。Figma 未覆盖的人工审核、待查单、冲正、负余额、失败、退票、加载和错误状态以 PRD 为必测项。

## 5. 涉及模块与类

- 覆盖 `InviteAPI`、邀请 data/params Model、P01～P09 的 GetX Controller/View 与路由。
- WebView 测试使用可替换的平台适配器；fixture 不包含真实身份、卡号、密码或工猫密钥。

## 6. 业务数据流与测试矩阵

| 层级 | 必测内容 |
|------|------------|
| Model/API | JSON 缺省/未知值、分页、整数分、稳定错误、敏感值不出现 |
| P01/P02 | 0/1/9/10/11/19/20 真实进度、六入口、负余额、复制/分享/保存失败 |
| P03/P04 | 服务端筛选、快速切 Tab、分页、冲正、空态；月/季/年卡标题、缺失 `productName` 兜底及旧标题消失 |
| P05/P06 | 资格阻断、debounce、quote 过期、重复提交、H5 拒绝/中断/回跳/resume |
| P07/P08 | 九态、未知态、轮询生命周期、失败返余额、退票 |
| P09 | HTTPS host 白名单、未知 scheme、证书错误、无 JWT/敏感注入 |
| 导航 | P01 六入口、P05→P06、P05/P07→P08、P09 |
| 可访问性/适配 | 小屏、字体放大、键盘、安全区、语义标签 |

## 2026-09-02 P04 卡种标题回归

- fixture 的直接奖励分别提供年卡、月卡快照；Model 单测覆盖月卡、季卡、年卡、空值/空白值兜底，并确认退款冲正和期初余额标题不受 `productName` 影响。
- P04 Widget 断言“好友开通年卡/好友开通月卡”可见且“直接邀请首单奖励”不可见；只更新 `07-commission-list` Golden，目视确认金额、状态、手机号、日期和布局不变。
- `flutter test --no-pub test/invite_bank_flow_test.dart` 共 49 项通过，`flutter analyze --no-pub` 通过。本地自动化只验证 Flutter 解析与渲染，不代替线上接口、真实历史订单或真机字体/安全区验收。

## 7. 现有工程参考点与安全扫描

复用 Catseller 现有测试初始化、fake transport、GetX 生命周期和页面测试辅助；`referenceProject` 仅作测试风格对照，不引入喵喵写歌业务断言。按“API fixture → Model → Controller 状态 → Widget/导航 → 清理生命周期”验证完整数据流。

- 扫描 GetStorage/Hive/日志/路由/错误上报，不得有姓名、身份证、完整手机、完整卡号、平台密码、工猫密钥。
- 断言创建提现不上传姓名/卡号，H5/Web 不注入 JWT。
- 断言未知状态不显示成功，网络超时不更换同次幂等键。

## 8. 建议实现步骤

1. 按模块建立 fixture 和 fake API，先跑小范围失败测试。
2. 补全 Model/API/Controller/Widget/WebView/导航自动化。
3. 执行 format/analyze/定向/全量测试并修复本次回归。
4. Android/iOS Debug 构建，再做 22 图对稿和真机 H5 验收。

## 9. 详细编码任务清单

- [x] `T-F009-01` 完成 API/Model 契约与安全测试。
- [x] `T-F009-02` 完成 P01～P09/D01～D03 Controller/Widget/导航测试。
- [ ] `T-F009-03` 完成弱网、竞态、生命周期和 WebView 安全测试。
- [x] `T-F009-04` 完成 22 图对稿、小屏/大字体和双平台构建。

## 10. 验收标准

1. `dart format --set-exit-if-changed .`、`flutter analyze`、定向测试、全量 `flutter test`、`git diff --check` 达标。
2. Android/iOS Debug 至少各构建一次。
3. 22 图对稿无阻断级差异，PRD 补充状态均有自动化或明确手工用例。
4. 真实工猫 H5 未就绪时单列外部阻塞，不影响本地 Mock 结论的真实表达。

## 11. 编码注意事项

保留用户现有未提交改动；全量测试的既有无关失败必须有可复现证据，不能静默忽略或顺手修改无关页面。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
