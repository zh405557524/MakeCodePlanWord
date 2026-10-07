# AGENTS.md — {项目名}（{Flutter App / Java 后端}）

> Codex、Cursor 会自动读取本文件；Claude Code 通过同目录的 `CLAUDE.md` 导入本文件。
> 控制在 200 行以内。详细规范放仓库规范目录（`.cursor/rules/`），在下面的「规范索引」登记。
> 本文件里的规则优先于工作台模板（`MakeCodePlanWord/templates/repo-rules/`）。

## 1. 项目
- 一句话：{这个仓库是什么，给谁用}
- 文档目录：`/Users/soul/work/MakeCodePlanWord/projects/{项目名}/doc/`（产品基线、技术、版本、测试都在这里，不在本仓库）
- 关联仓库：{后端 / App 仓库的绝对路径}。任务涉及那边时，先读那个仓库的 `AGENTS.md`。
- 流程规则：`/Users/soul/work/MakeCodePlanWord/workflow/00-总流程.md`

## 2. 开始任何任务前
1. 读文档目录的 `README.md`，找到开发中版本，读该版本的 `plan.md`（线上问题读 `fix.md`）。
2. **没有已审核的计划，不写业务代码。** 可以读代码、回答问题、帮忙写计划。
3. 按第 5 节「规范索引」读本次任务相关的规范。
4. 在回复或计划里列出已读的规范文件和关键条款。

## 3. 目录结构
```
{按实际填写，例如：
lib/
├── apis/        接口静态方法
├── pages/{feature}/view.dart + controller.dart + index.dart
├── routes/
├── services/
├── store/
├── widgets/
└── main.dart}
```

## 4. 硬规则（违反就返工）
1. {例如：页面必须放在 lib/pages/{feature}/，包含 view / controller / index 三个文件}
2. {例如：View 不直接调用 API，经 Controller → Service}
3. {例如：所有用户可见文案走多语言，不写死中文}
4. {例如：金额用 Decimal / 字符串 + currency，不用 double}
5. 只改计划里列出的文件；需要改其他文件时先停下来说明。
6. 不修改文档目录的 `product/`、`tech/`（发布时统一合并）。

## 5. 规范索引

| 任务涉及 | 必读 |
|---|---|
| 任何代码改动 | `.cursor/rules/03-编码规范.md`、`.cursor/rules/02-项目结构目录.md` |
| 页面 / UI | `.cursor/rules/08-UI处理任务.md`、`.cursor/rules/task-ui_task.md`、设计来源（版本 `scope.md`） |
| 新功能 | `.cursor/rules/07-新功能开发.md`、`.cursor/rules/task-new_feature.md` |
| Bug 修复 | `.cursor/rules/task-bug_fix.md` |
| 改业务规则、状态流转 | `.cursor/rules/task-logic_change.md` |
| 重构 | `.cursor/rules/task-refactor.md` |
| 路由 | `.cursor/rules/04-导航规则.md` |
| 多语言文案 | `.cursor/rules/05-多语言支持.md` |
| 新增依赖 | `.cursor/rules/06-第三方依赖参考.md` |
| 支付 / 会员 / 订单 | {项目自己的支付规范} + 文档目录 `testing/risk-checklist.md` 支付节 |
| {项目特有领域} | {对应规范文件} |

## 6. 执行计划的方式
- 按 `plan.md` 任务顺序逐个做。开始前把任务状态改为"进行中"，完成后改为"完成"，并在"结果"写一行：做了什么、提交号、偏离计划之处。
- 计划没写到的情况：停下来报告，不要自行扩展范围。
- 执行中只更新 `plan.md` 的任务状态和 `test.md` 的执行结果。

## 7. 验证命令（每个任务完成后都要跑）
```bash
{Flutter：flutter analyze && flutter test}
{Java：./gradlew build}
{可选：项目自己的检查脚本，例如 scripts/check_structure.sh}
```

## 8. 构建与运行
```bash
{本地运行、出包命令、环境切换方式}
```

## 9. 常见坑（项目经验，持续补充）
- {例如：统计 SDK 必须在用户同意隐私协议后才初始化，放在 global.dart 的 initAfterConsent()}
