# 多 App 邀请收益管理与活动规则 Web 总体开发计划

> 2026-08-27 实现回写：三端核心代码、共享工猫私有配置、Admin 增量与 App 22图对稿已完成本地检查，当前 waiting_review。最新真实进度以 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md) 和 [验证报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md) 为准；未自动启用/部署，真实 H5/银行及未勾选任务待验收。下文为已确认技术/任务基线，不用历史“待实现”描述覆盖最新记录。


> 版本：`v1.0.0`
> 日期：2026-08-27
> 状态：`done`
> Admin/Web 工程：`/Users/soul/code/lxwx/lxwx_admin`
> 需求基线：[requirements.md](../01-需求/requirements.md) v1.0.3
> Java 技术文档：[java-tech.md](./java-tech.md) v1.0.0
> Java 开发计划：[java-dev-plan.md](./java-dev-plan.md) v1.0.0
> 工时基线：[effort-estimate.md](../02-技术方案/effort-estimate.md) v1.0.1

---

## 1. 文档用途与范围

本文是 `/Users/soul/code/lxwx/lxwx_admin` 的独立总体开发计划。它把现有“邀请收益管理”页面的复用、增量改造、活动规则 Web 和后台验收拆成 T-A001～T-A007，可独立恢复和评审。

本计划覆盖：

- 复用现有 App 切换、“交易与增长 > 邀请收益管理”和 `InvitePage`。
- capability 驱动 `LEGACY` 与 `DIRECT_BANK_GONGMALL` 两种后台行为。
- 规则配置、邀请/佣金查询、提现列表/详情、审核、主动对账。
- 输入独立平台查看密码、原因和字段后短时查看当前记录明文。
- 活动规则公开静态 Web 页面及 App 级 URL 配置。
- Admin API、Model、Repository、状态清理、权限和自动化回归。

不新建后台系统，不新增重复菜单，不把新模式写成 Catseller 条件分支，不建设活动规则 CMS，不在新模式保留人工“打款成功/失败”终态。

本阶段只生成计划，不修改 Admin/Web 或 Java 代码。

### 1.1 数据库改动

Admin/Web：无数据库改动。后台所需配置版本、提现、审计、密码失败锁定和敏感数据均由 Java/API 与数据库实现；Admin 不直连数据库。

## 2. 当前实现基线

| 现有位置 | 当前能力 | 本次处理 |
|----------|----------|----------|
| `lib/pages/common/invite_page.dart` | 规则配置、用户代理配置、提现管理三页签 | 保留入口与三页签骨架，按 capability 切换内容和动作 |
| `lib/data/admin_repository.dart` | 邀请规则、代理、提现 API 封装 | 增量加入 capability、用户/佣金、详情、对账、敏感查看、审计 |
| `lib/core/api_client.dart` | Admin 网络调用 | 复用统一鉴权、App Code、错误处理 |
| `lib/models/admin_models.dart` | 旧规则、代理、提现模型 | 增量/替换为 capability、九态、详情和审计模型 |
| `shell_page.dart` | App 切换和邀请收益菜单 | 完全复用，不新增重复导航 |
| `web/legal/**/privacy-policy/` | 公开隐私协议页面和发布方式 | 作为活动规则静态页结构参考，不修改隐私协议 |

如果为维护性拆分 785 行 `invite_page.dart`，入口类仍保留 `InvitePage`，子组件放 `pages/common/invite/`，不改变菜单和其他 App 的路由。

## 3. 当前状态与恢复点

| 字段 | 内容 |
|------|------|
| 当前阶段 | `14 Admin/Web 编码` |
| 当前任务 | `首批基础代码可评审；下一佣金模块待金额口径确认` |
| 当前状态 | `in_progress`（总体计划已确认，首批已编码） |
| 当前恢复点 | 能力首请求、切 App 隔离、新模式规则白名单/二次确认完成；其余查询/提现/Web 模块待实现；详见 `../implementation-progress.md` |
| 下一步默认动作 | 确认返佣舍入/部分退款口径后按 Java 01 → Flutter 邀请/记录 → Admin 查询继续，不重复计划评审 |

## 4. 状态枚举与更新规则

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 正在实施并记录恢复点 |
| `waiting_review` | 页面/代码完成，等待接口、权限或人工验收 |
| `done` | 自动化、Web 构建、App 切换和安全门禁通过 |
| `blocked` | 被 Java API、权限、文案、部署 URL 或环境阻塞 |
| `skipped` | 用户明确跳过 |

更新规则：

1. 开始任务前记录当前 App、capability、修改文件和 Fixture/API 依赖。
2. 使用 Fixture 完成页面但 Java API 未联通时状态保持 `waiting_review`。
3. 每完成一个任务同步 T-A 表、模块文档和执行记录。
4. capability、权限或接口字段变化时先同步 Java 技术/开发计划，禁止 Admin 自行兼容另一套合同。
5. 切换 App、退出登录、离开详情和 grant 到期的敏感清理未验证前，T-A005 不得完成。

## 5. 总体开发策略

1. 页面初始化先请求 `GET /api/admin/invite/capabilities`，再决定三页签标签、字段只读性和允许操作。
2. 复用现有 App 切换；切换时取消旧请求并清空规则、用户、佣金、提现详情、敏感 grant 和筛选状态。
3. 先完成共享 Model/Repository/API，再改规则页、查询页、提现页，避免每个页签自造状态。
4. `LEGACY` 保持当前代理和人工打款行为；`DIRECT_BANK_GONGMALL` 使用固定直邀规则、九态和工猫动作。
5. 后台所有列表只显示脱敏值；明文只在当前详情、当前字段、最长 5 分钟内存显示。
6. 活动规则使用 `web/` 静态公开页，不携带 Admin 会话、不读取业务数据库、不建设 CMS。
7. 最后统一执行两模式、多 App、权限、错误、锁定、Web 响应式和回归测试。

## 6. 阶段、工时与里程碑

本计划引用已确认工时：Admin + 活动规则 Web 代码初稿占第一个执行日约 `0.25` 个 AI 工作日；第二个执行日与 Java/Flutter 一起完成测试、构建和集中修复。

| 阶段 | 计划窗口 | 任务 | 退出条件 |
|------|----------|------|----------|
| A1 capability 与数据层 | 第 1 日 | T-A001 | App 切换、模式、API/Model/Repository 基础可用 |
| A2 三页签升级 | 第 1 日 | T-A002～T-A004 | 规则、查询、提现详情/审核/对账可用 |
| A3 敏感查看 | 第 1 日 | T-A005 | 权限、密码、原因、5 分钟、锁定和清理完整 |
| A4 活动规则 Web | 第 1 日 | T-A006 | 公开 HTTPS 静态页、响应式和配置 URL 可用 |
| A5 验证与修复 | 第 2 日 | T-A007 | format/analyze/test/build web、多 App 两模式回归完成 |

## 7. 详细任务清单

| 任务 ID | 业务任务 | Java 依赖 | 主要文件 | 状态 | 完成标准 |
|---------|----------|-----------|----------|------|----------|
| T-A001 | capability 与 App 切换状态重构 | T-B001、T-B010 | `invite_page.dart`、API/Repository/Model、App 切换监听 | `waiting_review` | 页面只按 capability 显示；切 App 清空旧数据与 grant；无 App 名称硬编码 |
| T-A002 | 规则配置页升级 | T-A001、T-B010 | 规则页签、配置 Model/Repository | `waiting_review` | 新模式比例/门槛只读；只保存最低额、落地页、活动规则 URL、协议版本；旧模式不变 |
| T-A003 | 邀请与佣金查询升级 | T-A001、T-B003、T-B004、T-B010 | 第二页签、筛选、分页、详情 | `pending` | 新模式无人工调等级/二级资格；显示首单转化、比例快照、正向和退款冲正 |
| T-A004 | 提现审核、详情、时间线与主动对账 | T-A001、T-B008～T-B010 | 提现页签、详情、确认框、时间线 | `pending` | 九态/金额/费用/卡/工猫时间线正确；新模式隐藏 mark-paid/failed；原 ID 对账 |
| T-A005 | 敏感查看与审计 UI | T-B005、T-B010 | 密码/原因弹框、grant 内存状态、倒计时、审计页 | `pending` | 专用权限；最多 5 分钟；5 次错误锁 30 分钟；切 App/离页/退出立即清理；无复制导出 |
| T-A006 | App 级活动规则静态 Web | T-B001、法务文案 | `web/` 活动规则目录、样式、发布配置 | `pending` | 独立 HTTPS URL、移动端响应式、无 Admin 会话/数据库、CSP/外链安全 |
| T-A007 | Admin/Web 自动化与模式回归 | T-A002～T-A006、T-B013 | Admin 测试、Web 构建检查 | `pending` | LEGACY/新模式、多 App、权限、错误、锁定、活动页及全量回归达到门禁 |

## 8. Admin API 依赖表

| 页面/动作 | 方法 | 路径 | Admin 处理 | 状态 |
|-----------|------|------|------------|------|
| 页面能力 | GET | `/api/admin/invite/capabilities` | 首请求，决定页签和 actions | `pending` |
| 规则读取/保存 | GET/PUT | `/api/admin/invite/rules` | 新模式只提交允许编辑字段 | `pending` |
| 邀请用户 | GET | `/api/admin/invite/users` | 当前 App 筛选、分页、脱敏 | `pending` |
| 佣金流水 | GET | `/api/admin/invite/commissions` | 正向/冲正只读展示 | `pending` |
| 提现列表 | GET | `/api/admin/invite/withdrawals` | 九态、用户、时间筛选 | `pending` |
| 提现详情 | GET | `/api/admin/invite/withdrawals/{id}` | 金额、冻结、身份、脱敏卡、时间线 | `pending` |
| 审核通过 | POST | `/api/admin/invite/withdrawals/{id}/approve` | 二次确认；提交后刷新详情 | `pending` |
| 审核驳回 | POST | `/api/admin/invite/withdrawals/{id}/reject` | 必填安全原因；提交后刷新 | `pending` |
| 主动对账 | POST | `/api/admin/invite/withdrawals/{id}/reconcile` | 仅 availableActions 允许时显示 | `pending` |
| 敏感查看 | POST | `/api/admin/invite/withdrawals/{id}/sensitive-view-grants` | 密码、reason、fields；明文只存内存 | `pending` |
| 审计事件 | GET | `/api/admin/invite/audit-events` | 当前 App 查询，不展示明文 | `pending` |

Admin 只消费 `displayStatus/displayMessage/availableActions` 与稳定枚举，不根据按钮隐藏推断服务端权限；403/409/锁定均显示安全文案并刷新 capability/详情。

## 9. 模块开发文档列表

以下 4 份 Admin/Web 模块文档已随 `12 Java 模块开发文档` 生成并获用户确认；文档状态为 `done`，编码任务仍未开始：

| 顺序 | 计划路径 | 覆盖任务 | 状态 |
|------|----------|----------|------|
| 1 | `04-后端/开发计划/admin/00-admin-capability-rules.md` | T-A001、T-A002 | `done` |
| 2 | `04-后端/开发计划/admin/01-admin-invite-commission.md` | T-A003 | `done` |
| 3 | `04-后端/开发计划/admin/02-admin-withdrawal-security.md` | T-A004、T-A005 | `done` |
| 4 | `04-后端/开发计划/admin/03-activity-rules-web-tests.md` | T-A006、T-A007 | `done` |

模块文档需明确 Widget/Page、Repository、ApiClient、Model、App 切换、权限、内存安全、错误、Java 接口和测试之间的关系。

## 10. 敏感查看专项约束

- 平台查看密码不得保存到浏览器、GetStorage、表单自动填充、日志或错误报告。
- reason 必填；fields 默认最小集合，不提供“一键查看全部用户/全部字段”。
- 返回明文只存在当前详情 State；倒计时到期主动覆盖，切 App/关闭详情/退出登录立即覆盖。
- 禁用页面复制、批量、导出和缓存；不把明文放 URL、浏览器历史、下载和打印。
- 连续 5 次错误后的 30 分钟锁定完全以服务端为准；前端倒计时仅展示。
- 审计页只显示对象 ID、字段类型、原因、操作者、结果和时间，不显示密码或明文。

## 11. 活动规则 Web 计划

- 参考 `web/legal/**/privacy-policy/index.html` 的目录、响应式和部署方式，新建独立活动规则路径。
- 页面正文、版本和生效时间由法务/运营提供；示例金额、银行、税费不得写成业务常量。
- 页面公开访问，不读 Admin Token/Cookie，不发业务 API，不嵌入敏感参数。
- 只允许必要静态资源域名；配置 CSP、HTTPS、缓存版本和移动端 viewport。
- 每个 App 的 `activityRulesUrl` 由规则配置保存，可指向同一模板的不同品牌部署地址。

## 12. 编码与验证约束

### 12.1 编码

1. 保留现有 `InvitePage` 和菜单入口；拆分只为维护性，不改变其他 App 导航。
2. capability 和 availableActions 是唯一显示/操作依据，禁止 `if (appCode == 'catseller')`。
3. 新模式隐藏的旧操作仍需由 Java 拒绝，Admin 隐藏不是安全边界。
4. 列表/日志/错误只用脱敏字段；敏感 grant 只在内存。
5. 切 App 必须取消/忽略旧异步响应，防止旧 App 数据回填当前页面。
6. 不覆盖用户未提交改动，不顺带调整邀请收益以外后台页面。

### 12.2 验证门禁

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- capability、三页签、审核/对账、敏感查看和 App 切换定向测试。
- 全量 `flutter test`。
- `flutter build web`。
- 活动规则静态链接、CSP、响应式和无会话依赖检查。
- `git diff --check`。

## 13. 风险与编码前门禁

- Java capability、availableActions、九态、错误码和敏感查看响应必须在 T-A001 前冻结。
- Admin 权限编码、查看密码托管/轮换和审计期限必须在 T-A005 前确认。
- 活动规则正式文案、App 品牌信息、HTTPS 发布域名在 T-A006 release 验收前提供。
- 其他 App 的 `LEGACY` 回归数据必须可用，避免新模式改造破坏现有代理/人工打款页面。

## 14. 执行记录

| 日期 | 阶段/任务 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-08-27 | 10 Admin/Web 总体开发计划 | 用户明确要求后台也有独立开发计划；基于现有 InvitePage、三页签、App 切换、Java API 与活动规则 Web 需求生成 T-A001～T-A007 | 用户已确认，`done`；未修改 Admin、Web 或 Java 代码 |
| 2026-08-27 | CHG-0068 首批编码 | 能力首请求、切 App 隔离、新模式规则白名单/二次确认完成；其余查询/提现/Web 模块待实现 | analyze、新增 11 项、全量 153 项与 Web build 通过；真实联调和人工验收未执行 |

## 15. 下一步

总体/模块文档已确认，失效规则引用已修复。本批实际完成项见任务表，其余功能保持 pending。下一佣金模块需用户确认金额舍入及部分退款口径；准确代码、验证和恢复顺序见 [implementation-progress.md](../implementation-progress.md)，不以文档 done 代替实现完成。
