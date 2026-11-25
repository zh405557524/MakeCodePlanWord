# Admin 模块 02：提现审核、对账、敏感查看与审计

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-A004`、`T-A005`
> 工程：`/Users/soul/code/lxwx/lxwx_admin`

## 1. 功能定位与边界

升级 InvitePage 提现管理页签，实现九态、金额/冻结/费用、脱敏银行卡、工猫/查单时间线、审核、原 ID 对账，以及输入平台查看密码后短时查看当前记录所选明文。新模式隐藏 `mark-paid/mark-failed`，不提供导出/批量/复制明文。

数据库改动：无；Admin 不直连数据库、不自行解密。

## 2. 入口与文件

- 入口：现有 InvitePage 第三页签。
- 页面/组件：`lib/pages/common/invite_page.dart`，必要时拆 `invite/withdrawal_tab.dart`、`withdrawal_detail.dart`、`sensitive_view_dialog.dart`。
- 数据：`AdminRepository`、`ApiClient`、`admin_models.dart` 的九态、详情、grant 和审计 Model。

## 3. 依赖前置

- [00-admin-capability-rules.md](./00-admin-capability-rules.md) 完成 App 切换和 capability。
- Java [05-invite-admin-security.md](../05-invite-admin-security.md) 提供权限、审核、对账、敏感查看、锁定和审计。

## 4. 视觉参考与设计稿分析

后台无 Figma，复用现有表格、详情面板和确认框。详情从上到下：单号/状态/可操作项、金额/冻结/费用/到账、认证/脱敏卡、审核/工猫/查单时间线、安全原因与审计入口。

敏感查看弹框：密码、必填原因、最小字段选择、确认/取消；成功后只在当前详情显示明文和倒计时。

## 5. API 与 Model 合同

| API | 处理 |
|-----|------|
| `GET /api/admin/invite/withdrawals` | 九态/用户/时间筛选、服务端分页 |
| `GET /api/admin/invite/withdrawals/{id}` | 详情与 `displayStatus/displayMessage/availableActions` |
| `POST .../{id}/approve` | 二次确认，提交后刷新详情，不当作到账 |
| `POST .../{id}/reject` | 必填安全原因，提交后刷新 |
| `POST .../{id}/reconcile` | 只有 availableActions 允许时可操作，不传新 requestId |
| `POST .../{id}/sensitive-view-grants` | `password,reason,fields`；返回当前记录短期 grant 与所选明文 |
| `GET /api/admin/invite/audit-events` | 当前 App 审计，不含明文/密码 |

403、409、`SENSITIVE_VIEW_PASSWORD_INVALID`、`SENSITIVE_VIEW_LOCKED` 分别显示安全提示，必要时刷新 capability/详情。

## 6. 业务内容与数据流

- 九态：`PENDING_REVIEW/REJECTED/APPROVED/SUBMITTING/PROCESSING/RECONCILING/SUCCEEDED/FAILED/RETURNED`。不把 `APPROVED` 当已打款。
- 审核/对账按钮依赖权限与 availableActions；操作中禁用重复点击，完成后重读详情。
- 平台查看密码不保存到浏览器/自动填充/GetStorage/日志；请求结束后立即清理输入。
- 明文只存当前详情 State，最长 5 分钟；过期、切 App、关闭详情、离页和退出登录立即覆盖清理。
- 5 次错误锁 30 分钟以服务端为准，前端倒计时仅展示。

## 7. 建议实现步骤

1. 实现九态/详情/审计/grant Model 与 Repository。
2. 升级提现列表/详情和时间线，隐藏新模式人工打款终态。
3. 实现审核/驳回/对账与二次确认。
4. 实现敏感查看弹框、倒计时、锁定、清理和审计查询。

## 8. 详细编码任务清单

- [x] `T-A004-01` 完成九态列表、详情、金额/费用/时间线。
- [x] `T-A004-02` 完成审核、驳回、原 ID 对账和状态冲突恢复。
- [x] `T-A005-01` 完成密码/原因/字段、短时明文和审计 UI。
- [ ] `T-A005-02` 完成全部敏感查看操作验收。本地已验证 5 分钟清空、5 次/30 分钟锁定、切 App/退后台清理、无权限与不可选取明文；真实登录会话的离页/退出及浏览器无复制/导出完整操作仍待验收，不用局部测试勾销全项。

## 9. 测试与验收

1. 新模式不显示 `mark-paid/mark-failed`，LEGACY 保持原行为。
2. 审核/对账不在前端修改终态，只刷新服务端真值。
3. 明文不出现在存储/日志/URL/错误报告/打印/下载中。
4. grant 过期、App 切换、离页和退出后详情明文立即消失。
5. 未授权、密码错误、锁定、网络失败和重复点击均有正确反馈。

## 10. 编码注意事项

前端禁复制不代表绝对防截图或防手工转录，不宣称其为安全边界。主要安全保证是服务端最小记录/字段、短时授权和全程审计。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
