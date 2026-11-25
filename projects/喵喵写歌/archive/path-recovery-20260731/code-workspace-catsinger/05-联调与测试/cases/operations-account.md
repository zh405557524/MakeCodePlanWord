# CHG-0020 运营账号 QA 用例

1. 配置关闭时 Admin 显示未启用，固定凭证不能绕过短信校验。
2. 配置启用且账号不存在时，首次生命周期/登录触发创建，最终状态为 FROZEN 且登录失败。
3. Admin 解冻后固定凭证登录成功；普通用户与审核账号登录行为不变。
4. Admin 冻结后旧 Access Token 请求返回未授权，旧 Refresh Token 不能续期。
5. 每日冻结任务重复执行无副作用，并在解冻后重新把账号设为 FROZEN。
6. 服务启动冻结已处于 ACTIVE 的运营账号。
7. 错误 AppCode、缺少配置或与审核账号手机号冲突时不修改任何用户。
8. Admin 页面只显示脱敏手机号；切换 App 后旧缓存和延迟响应不会显示在新 App。
9. 正式配置注入后先验证账号仍冻结，再由后台解冻并完成一次登录/鉴权烟测。

数据库改动：无。

## 自动化结果（2026-07-20）

| 检查项 | 结果 | 备注 |
|---|---|---|
| Java 编译 | `passed` | `compileJava` 通过 |
| Java 无测试构建 | `passed` | `build -x test` 通过 |
| Java 定向回归 | `passed` | CHG-0020、审核账号回归与 OpenAPI 路径检查通过 |
| Java 全量测试 | `baseline_failed` | 共 470 项，45 项既有基线失败；CHG-0020 用例未失败 |
| Web/Admin 测试 | `passed` | 53 项通过 |
| Web/Admin 静态检查 | `passed` | `flutter analyze` 无问题 |
| Web/Admin 正式构建 | `passed` | `flutter build web` 通过 |
| 两工程差异检查 | `passed` | `git diff --check` 通过 |
| 数据库迁移 | `not_required` | 未新增表、字段或迁移 |
| 正式环境冒烟 | `pending` | 本机正式 SSH 身份不可用，尚未发布；取得安全凭据后执行默认冻结、后台解冻、真实登录与鉴权检查 |

## 验收状态

当前为 `waiting_review`。自动化覆盖已完成；第 9 项正式环境用例未执行前，不关闭 CHG-0020，也不把账号视为正式可用。
