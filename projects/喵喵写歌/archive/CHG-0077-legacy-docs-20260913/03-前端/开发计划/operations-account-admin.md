# CHG-0034 运营账号 Web/Admin 模块计划

> 路径恢复：2026-07-31 从错误工作区别名 `catsinger` 迁入；本文 CHG 已按 `旧编号 + 14` 重编号，原文保存在 `archive/path-recovery-20260731/`。

## 变更点

- 新增独立 `BackendOperationsAccount`、API Client 与 Repository 状态。
- 用户列表页增加运营账号卡片、脱敏状态与冻结/解冻操作。
- 切换 App 清理审核/运营账号缓存，并阻止旧请求结果回写。

## 验收

- 两类账号加载和操作互不影响。
- 页面、确认弹窗和错误信息不出现完整手机号、验证码或 Token。
- 未配置/未创建、加载失败和操作失败均有明确状态。
- 冻结与解冻要求原因，成功后刷新账号和用户列表。

## 状态与验证

- 状态：`waiting_review`。Web/Admin 实现与本地自动化已完成，正式发布尚未执行。
- `flutter test` 53 项、`flutter analyze` 与 `git diff --check` 通过。
- 下一步：随 Java 正式发布后，在用户管理页确认默认冻结、执行带原因的解冻，并配合真实登录冒烟。
