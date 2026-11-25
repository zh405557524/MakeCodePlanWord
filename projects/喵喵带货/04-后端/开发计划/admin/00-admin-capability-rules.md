# Admin 模块 00：多 App 能力与规则配置

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-A001`、`T-A002`
> 工程：`/Users/soul/code/lxwx/lxwx_admin`
> 总体计划：[admin-web-dev-plan.md](../../admin-web-dev-plan.md)

## 2026-09-02 六档佣金配置增量

- InvitePage 将非佣金规则与“佣金比例配置”拆页；佣金页分别编辑一级关系 L1/L2/L3、二级关系 L1/L2/L3 六个 0～100 整数百分比，各组三档非递减。
- `PUT /api/admin/invite/rules` 版本化提交两组完整 Map；缺字段、多字段、小数、字符串、越界或倒挂均回显失败。保存后按服务端响应刷新当前 App，切 App 丢弃旧响应。
- 规则能力面向所有 App，但配置版本、六档比例和审计始终按当前 `X-App-Code` 隔离。公开规则 Web 仅展示一级三档，不泄露二级后台规则。

## 1. 功能定位与边界

复用“交易与增长 > 邀请收益管理”、`InvitePage` 和三页签，先读当前 App capability，再决定页签标签、字段只读和动作。不新建后台系统/菜单，不使用 `appCode == catseller` 分支。

数据库改动：Admin/Web 无；配置版本和权限由 Java 实现。

## 2. 入口与现有文件

- 入口：`lib/pages/shell_page.dart` 的现有邀请收益管理菜单。
- 页面：`lib/pages/common/invite_page.dart`，保留 `InvitePage` 入口类。
- 数据：`lib/data/admin_repository.dart`、`lib/core/api_client.dart`、`lib/models/admin_models.dart`。
- 必要时拆子组件到 `lib/pages/common/invite/`，不改菜单和其他 App 路由。

## 3. 依赖前置

- Java `T-B001/T-B010` capability/rules/availableActions 与 App 范围权限。
- 对应 [00-invite-capability-migrations.md](../00-invite-capability-migrations.md) 与 [05-invite-admin-security.md](../05-invite-admin-security.md)。

## 4. 视觉参考与设计稿分析

后台暂无 Figma。使用现有 InvitePage 的三页签、表单、表格、筛选、保存按钮、加载和错误风格；不用移动端 Figma 图片冒充后台设计。

页面从上到下：当前 App/能力说明、三页签、当前页签内容、允许的保存操作。当 capability 未加载时不显示可编辑旧规则，避免短暂暴露错误操作。

## 5. API 与 Model 合同

| API | 请求 | 响应/处理 |
|-----|------|-----------|
| `GET /api/admin/invite/capabilities` | 当前 App Header | `mode`、可见页签、`availableActions` |
| `GET /api/admin/invite/rules` | 无 | 当前规则、版本、允许编辑字段 |
| `PUT /api/admin/invite/rules` | 只提交结算等待天数、最低额、落地页、活动规则 URL、协议展示版本等允许项 | 完成后以服务端新版本刷新 |

模型对齐 Java capability/rules DTO/VO；错误包含 403/App 范围拒绝、参数错误、版本冲突，不吞掉保存失败。

## 6. 业务内容与数据流

- `LEGACY`：规则、用户代理配置、人工打款保持原行为。
- `DIRECT_BANK_GONGMALL`：规则页固定 1/10/20 人和 10%/20%/30% 只读；第二页签改“邀请与佣金查询”；第三页签为九态工猫提现。
- App 切换时取消旧请求并递增 generation；清空规则、用户、佣金、提现、详情、筛选和敏感 grant，旧响应不得回填。
- `settlementDelayDays`：0～3650 的整数（技术防误填上限），默认 0；仅新模式展示，保存前明确当前 App、旧值→新值及“仅影响新订单”。
- `minWithdrawCents`：当前 App 正整数分，默认 100 分（1 元），可动态调高/调低。保存确认显示旧值→新值及“仅新申请”，不追溯已创建申请；后端创建时按最新门槛校验，前端缓存不能代替后端判断。
- URL 只允许 HTTPS 和允许 host；不提供工猫 secret/私钥/公钥编辑表单。

## 7. 建议实现步骤

1. 先扩展 capability/rules Model 和 Repository。
2. 实现页面首请求 capability、App 切换清理和旧响应丢弃。
3. 实现新旧模式三页签和规则只读/编辑分支。
4. 补保存中/失败/冲突、权限和 URL 校验。

## 8. 详细编码任务清单

- [x] `T-A001-01` 完成 capability Model/Repository 与首请求。
- [x] `T-A001-02` 完成 App 切换清理和旧响应丢弃。
- [x] `T-A002-01` 完成新模式固定档位只读/允许配置保存。
- [x] `T-A002-02` 完成 LEGACY 规则回归、URL/权限/保存错误测试。

## 9. 测试与验收

1. capability 加载前不能编辑错误模式的规则。
2. 快速切 App 不会回填旧 App 数据，敏感 grant 立即清理。
3. 新模式只保存允许项，固定档位不可编辑；LEGACY 原行为不变。
4. 无 Catseller 名称硬编码，所有动作以 capability/权限为准。

## 10. 编码注意事项

复用现有 ApiClient 的 Admin Token、App Header 和错误处理，不新建平行网络层。保存不改当前 App 以外配置，不把平台工猫密钥暴露到 UI。

## 11. 2026-08-27 编码结果（CHG-0068）

本模块四项本地任务完成，编码 waiting_review；暂无真实服务/浏览器联调或人工验收。首请求 capability、三模式、取消邀请请求/generation 与页面 epoch、App 切换清理、固定档位只读、允许项保存/二次确认、权限/URL/版本冲突/重复点击均已实现；未知或加载失败不回退旧模式。新增结算天数和最低额动态生效范围说明，保持当前 App 版本化保存。新模式另外两个页签明确显示尚未开放，不调用旧资金接口；敏感 grant 尚未实现，不据此宣称 grant 清理验收完成。invite_capability_test 14 项、全量 156 项、analyze、flutter build web --no-pub 全部通过。

当前代码、文件范围、验证与下一步统一见 [三端编码恢复点](../../../implementation-progress.md)。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
