# AGENTS.md

## 工程边界

- 当前仓库是 catoutfit Flutter 移动端 App。
- 本仓库规则只约束 Flutter、Android 与 iOS 代码，不承担服务端或管理后台规则。
- 若需求依赖服务端或管理后台变更，只记录接口、字段、行为和验收依赖；未经用户明确授权，不进入其他仓库修改。
- Flutter 工程不直接操作数据库；发现数据库依赖时，只说明外部依赖与风险。

## 规则加载

进入工程后不得一次性读取 `.cursor/rules/` 全部文件。编码前先读取 `10-编码工作流程.mdc` 和 `03-编码规范.mdc`，再按任务类型补充最小规则集：

| 任务类型 | 追加规则 |
|---|---|
| 项目初始化 | `01-项目初始化规则.mdc`、`02-项目结构目录.mdc`、`06-第三方依赖参考.mdc`、`task-project_init.mdc` |
| 新功能 | `02-项目结构目录.mdc`、`07-新功能开发.mdc`、`task-new_feature.mdc` |
| UI 调整 | `08-UI处理任务.mdc`、`task-ui_task.mdc` |
| Bug 修复 | `task-bug_fix.mdc` |
| 逻辑修改 | `task-logic_change.mdc` |
| 重构 | `task-refactor.mdc` |
| 路由 | `04-导航规则.mdc` |
| 多语言 | `05-多语言支持.mdc` |
| 依赖或原生插件 | `06-第三方依赖参考.mdc` |
| 大功能 | `09-大功能先规划再编码.mdc` |
| 测试 | `11-测试规则.mdc` |
| 其他 | `task-other.mdc` |

若必要规则缺失、无法读取或互相冲突，暂停修改并向用户说明。

## 修改前检查

- 确认当前目录和 `git status`，保留用户已有改动。
- 查看受影响的页面、Controller、API、model、service/store、路由和测试；涉及原生能力时继续查看 Android/iOS 配置。
- UI 输入可来自 Figma、截图、PRD、用户说明或现有页面风格。只有用户明确指定 Figma 时才强制读取；指定的 Figma 无法访问且没有替代材料时暂停确认。
- 不凭空新增接口、字段、资源、SDK 或平台配置。

## 移动端重点

- 权限、隐私同意、Deep Link、登录、媒体、文件与分享能力必须同时检查 Dart 层和 Android/iOS 配置。
- 受隐私同意保护的 SDK 不得在用户同意前初始化。
- 页面需考虑安全区、系统栏、键盘遮挡、滚动、返回行为和不同屏幕尺寸。

## 验证

- 修改 Dart 文件后运行 `dart format`。
- 修改 Flutter 代码后至少运行 `flutter analyze`。
- 涉及 Store、路由、API、登录态或生成流程时运行相关 `flutter test`；影响面较大时运行完整测试。
- 修改 Android/iOS 配置或原生插件时，执行对应平台构建或真机验证。
- 完成后运行 `git diff --check`。
