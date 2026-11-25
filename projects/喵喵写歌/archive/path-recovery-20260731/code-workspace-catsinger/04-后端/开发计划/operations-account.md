# CHG-0020 运营专用账号后端模块计划

## 边界

- 独立于审核账号，不修改 Apple 支付白名单。
- 复用现有用户、资料、积分和 Token 表，不新增数据库迁移。
- 正式凭证只存在于私有环境配置。

## 实现

1. `AuthProperties` 增加运营账号启用、手机号、固定验证码、AppCode、启动冻结和每日冻结配置，源码默认安全关闭。
2. `OperationsAccountService` 负责匹配登录、首次冻结创建、状态快照、Admin 冻结/解冻和 Refresh Token 撤销。
3. `OperationsAccountLifecycle` 在应用进入就绪前和每日定时任务中切换到配置 App schema，幂等冻结账号并恢复原上下文；启动冻结失败时不允许服务带着未冻结账号就绪。
4. `AuthService` 命中运营固定凭证后先执行 ACTIVE 门禁，再沿用原手机号登录和 Token 签发。
5. `AdminOperationsAccountController` 暴露独立 GET/PATCH，响应只含脱敏手机号和重置策略。

## 测试

- 固定凭证不影响测试账号、审核账号和普通短信登录。
- 首次登录创建冻结用户但拒绝签发 Token。
- Admin 解冻后登录成功；冻结后 Access/Refresh Token 立即不可用。
- 启动/每日任务幂等且只影响配置 App 和配置账号。
- 配置缺失、App 不匹配和账号冲突安全失败。

## 状态与验证

- 状态：`waiting_review`。Java 实现与本地自动化已完成，正式部署尚未执行。
- `compileJava`、`build -x test`、CHG-0020/审核账号/OpenAPI 定向测试与 `git diff --check` 通过。
- Java 全量共 470 项，45 项既有基线失败；CHG-0020 用例未失败。
- 下一步：正式发布后先确认账号为冻结状态，再由后台管理员解冻并执行一次真实登录/鉴权冒烟。
