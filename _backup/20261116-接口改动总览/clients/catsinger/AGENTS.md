# AGENTS.md

## 项目流程工作区路径门禁

- 当前代码别名 `catsinger` 的唯一流程工作区由 `/Users/soul/work/MakeCodePlanWord/scripts/workspace-path-guard.sh resolve catsinger` 解析，当前应为 `/Users/soul/work/MakeCodePlanWord/projects/喵喵写歌`。
- 修改流程文档、需求、技术方案或开发计划前，必须对目标绝对路径运行同一脚本的 `check catsinger <目标>`；完成后运行 `audit`。
- 禁止创建 `../projects`、本仓库内 `projects` 或 `/Users/soul/code/lxwx/projects`。守卫失败或工作台不可访问时必须阻塞，不能创建替代目录。

## 工程边界

- 当前仓库是 catsinger Flutter 移动端 App。
- 本仓库规则只约束 Flutter、Android 与 iOS 代码，不承担服务端或管理后台规则。
- 若需求依赖服务端或管理后台变更，只记录接口、字段、行为和验收依赖；未经用户明确授权，不进入其他仓库修改。
- Flutter 工程不直接操作数据库；发现数据库依赖时，只说明外部依赖与风险。

## 固定工程地址

- 前端 App 工程：`/Users/soul/code/lxwx/catsinger`
- 后端服务工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
- Web/Admin 工程：`/Users/soul/code/lxwx/lxwx_admin`

需要定位前端、后端或 Web/Admin 时，直接使用以上路径，不为寻找工程反复全盘搜索。若任务明确包含跨仓库修改，进入目标工程后必须先读取目标工程自己的 `AGENTS.md` 和相关规则；当前移动端规则不能替代目标工程规则。

## 规则加载

进入工程后不得一次性读取 `.cursor/rules/` 全部文件。先读 `00-index.mdc`、`20-workflow.mdc`、`02-conventions.mdc` 和 `90-project.mdc`；按改动层补充 `01-architecture.mdc`、`03-getx.mdc`、`04-routing.mdc`、`05-ui.mdc`、`06-i18n.mdc`、`07-deps.mdc` 中的必要规则，再按 `00-index.mdc` 的分派表只选一份任务剧本：

| 任务类型 | 追加规则 |
|---|---|
| 项目初始化 | `10-task-init.mdc` |
| 新功能 | `11-task-feature.mdc` |
| UI 调整 | `12-task-ui.mdc` |
| Bug 修复 | `13-task-bugfix.mdc` |
| 逻辑修改 | `14-task-logic.mdc` |
| 重构 | `15-task-refactor.mdc` |
| 大功能 | `16-task-plan.mdc` |
| QA 用例文档 | `21-qa-cases.mdc`；Dart 测试仍按下方验证要求执行 |
| 其他 | 仅加载必要的核心规范层规则 |

若必要规则缺失、无法读取或互相冲突，暂停修改并向用户说明。

## 修改前检查

- 确认当前目录和 `git status`，保留用户已有改动。
- 查看受影响的页面、Controller、API、model、service/store、路由和测试；涉及原生能力时继续查看 Android/iOS 配置。
- UI 输入可来自 Figma、截图、PRD、用户说明或现有页面风格。只有用户明确指定 Figma 时才强制读取；指定的 Figma 无法访问且没有替代材料时暂停确认。
- 不凭空新增接口、字段、资源、SDK 或平台配置。

## 移动端重点

- 权限、隐私同意、Deep Link、支付、登录、媒体、文件与分享能力必须同时检查 Dart 层和 Android/iOS 配置。
- 受隐私同意保护的 SDK 不得在用户同意前初始化。
- 页面需考虑安全区、系统栏、键盘遮挡、滚动、返回行为和不同屏幕尺寸。

## 验证

- 修改 Dart 文件后运行 `dart format`。
- 修改 Flutter 代码后至少运行 `flutter analyze`。
- 涉及 Store、路由、API、登录态、支付或生成流程时运行相关 `flutter test`；影响面较大时运行完整测试。
- 修改 Android/iOS 配置或原生插件时，执行对应平台构建或真机验证。
- 完成后运行 `git diff --check`。
