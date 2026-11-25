# Admin/Web 模块 03：活动规则静态页与综合回归

> 2026-08-28 最新用户澄清：规则正文默认可见，接口只异步补充有效参数；任何活动/通道状态及请求失败均不得阻断正文，保留非阻断重试和通用参数说明。App 规则入口及 Web 脚本增加显示版本以区分旧缓存，其他业务门禁不变。该条覆盖此前依赖接口成功才展示的约束；验证见 workflow.md「规则正文先显示、动态参数异步补充」。

> 2026-08-28 用户已授权的最新增量约束：规则查看不受工猫就绪影响；enabled=false 展示明确标注的规则说明而非整页错误，不冒充规则已生效。withdrawalEnabled=false 仅提示银行卡提现不可用；真实网络/格式错误仍显示错误与重试。 实施与验收记录见工作区 `workflow.md`「邀请业务与提现通道解耦」；主流程保持 waiting_review。

> 状态：`done`（用户已确认模块文档）
> 编码状态：`waiting_review`（本地核心实现已回写；未勾选项为外部验收或尚未覆盖的专项测试，不等同于全部完成）
> 任务：`T-A006`、`T-A007`
> 工程：`/Users/soul/code/lxwx/lxwx_admin`

## 1. 功能定位与边界

在 Admin 工程 `web/` 下参考隐私协议页实现公开活动规则静态 Web，供各 App 通过自己的 HTTPS URL 打开。不建 CMS，不读取 Admin 会话或业务数据库，不修改现有隐私协议。同时收口 T-A001～T-A005 自动化与双模式回归。

数据库改动：无。

## 2. 入口与文件

- 参考：`web/legal/catseller/privacy-policy/index.html`、`web/legal/catsinger/privacy-policy/index.html`、`web/site.css`。
- 新增静态目录建议：`web/legal/{appCode}/invite-rules/index.html`，具体品牌目录与发布环境对齐。
- App 入口：P01 活动规则→P09 受控 WebView；URL 由当前 App 规则配置返回。
- 测试：Admin Repository/Widget/App 切换/敏感查看与静态链接检查。

## 3. 依赖前置

- 法务/运营确认正式规则正文、协议版本、生效时间、品牌和联系信息。
- Java `T-B001/T-B010` 保存每 App 的 `activityRulesUrl`。
- Flutter [04-invite-withdrawal-results-web.md](../../../03-前端/开发计划/04-invite-withdrawal-results-web.md) 对齐 HTTPS host 与外链策略。

## 4. 视觉参考与设计稿分析

P09 参考 [19-activity-rules.png](../../../01-需求/references/images/invite-withdrawal/19-activity-rules.png)，Figma `43:3167`，只用于移动端内容层级和排版。图中从上到下：奖励规则、有效邀请、结算与退款、提现说明、其他说明、联系客服；目标 Web 页另补版本/生效时间。图中“超过退款期后转为可提现”与当前 PRD 不一致，目标按用户最新确认显示支付成功后等待按 App 动态配置的 N 天再转为可提现、后续退款负向冲正；N=0 才立即入账，不得写死等待天数或承诺到账短信。

Admin 综合回归无 Figma，以现有 InvitePage 与本次多 App 行为约束为准。

## 5. Web 实现合同

- 公开 HTTPS 静态页，不请求后台登录，不携带 JWT/Cookie/用户 ID 或敏感查询参数。
- 必要静态资源域名最小化；CSP、HTTPS、viewport、缓存版本和外链安全检查完整。
- 每 App 可复用同一模板部署不同品牌内容，但配置和 URL 按 App 管理。
- 页面不读业务数据库，不新增规则编辑 CMS。

## 6. Admin 综合测试矩阵

| 场景 | 验收 |
|------|------|
| capability 与双模式 | 新模式固定规则/只读查询/九态；LEGACY 不变 |
| App 切换 | 清空筛选/列表/详情/grant，旧响应不回填 |
| 审核/对账 | 二次确认、重复点击、状态冲突、原 ID 查单 |
| 敏感查看 | 权限/密码/原因/字段、5 分钟、5 次/30 分钟、全路径清理 |
| 安全 | 普通响应/日志/存储/URL/审计无明文 |
| 活动 Web | 移动响应式、HTTPS、链接、CSP、无会话依赖 |

## 7. 建议实现步骤

1. 复用隐私协议目录与样式骨架，生成独立活动页。
2. 输入已确认正文、版本/生效日期，不写示例为正式规则。
3. 配置 HTTPS URL/CSP/缓存并验证 App WebView。
4. 补 Admin 契约/页面/敏感查看测试和双模式回归。
5. 执行全量测试和 Web 构建，记录未就绪的法务/部署阻塞。

## 8. 详细编码任务清单

- [x] `T-A006-01` 完成 App 级活动规则静态页和响应式样式。
- [x] `T-A006-02` 完成 HTTPS URL、CSP、缓存、外链和无会话检查。
- [x] `T-A007-01` 完成 Admin Repository/Widget/App 切换/权限/敏感查看本地测试；真实登录会话端到端操作见 T-A005-02 待验收项。
- [x] `T-A007-02` 完成 LEGACY/新模式、Web 构建和活动页回归。

## 9. 命令与验收门禁

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- 邀请收益定向测试与全量 `flutter test`
- `flutter build web`
- 静态链接/CSP/响应式/无会话依赖检查
- `git diff --check`

## 10. 编码注意事项

正式规则文案和发布域名未确认时可完成模板与本地验证，但不宣称 release 就绪。不修改旧隐私协议、邀请落地页或其他 Admin 业务。

## 本轮实现回写（2026-08-27）

三端代码已按职责落在现有邀请模块，合并后的实际服务/页面入口见 [编码恢复点](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/implementation-progress.md)。上文类名/路径属于规划清单，若与实际命名不同，以恢复点和真实代码/OpenAPI 为准，不新增重复同义类型。

本地验证见 [三端报告](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/05-联调与测试/invite-withdrawal-local-verification.md)，页面对稿见 [22图对照](/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/03-前端/design-qa.md)。勾选表示已实现并完成相应本地检查，不表示生产部署、权限授予、真实 H5/工猫/银行或全部设备验收。未勾选的渠道退款、原生权限/分享、WebView中断/真机、完整操作专项按报告继续，不回退重做基础。
