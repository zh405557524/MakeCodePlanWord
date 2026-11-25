# AGENTS.md

开启新对话或接手当前工程时，必须先检查 `.cursor/rules` 目录中的规则文件，并明确以下三点：

1. 当前工作空间属于哪个项目。
2. 当前的工作流程处于哪一步。
3. 如果当前处于编程步骤，必须明确是否已经加载对应工程的规则说明。

读取规则时必须按需读取：
- 根据当前任务类型、技术栈和阶段选择相关规则文件。
- 不要一次性全量读取 `.cursor/rules` 下的所有文件。
- 优先读取 `00-核心工作流程.mdc`、当前流程步骤规则，以及与当前任务最直接相关的规则。
- 如任务涉及 Flutter、Java、需求、设计、测试、构建、发布等专项内容，再读取对应目录或规则文件。
- 如进入 Flutter 或 Java 编码阶段，先读取对应编码索引规则，再根据索引按需读取子规则。
- 如项目 `workflow.md` 指向外部前端、后端或参考工程，还需要按需检查对应工程自己的规则说明。

## 项目工作区路径门禁

- `/Users/soul/work/MakeCodePlanWord/projects` 是唯一流程文档根目录，项目映射以 `workspace-registry.json` 为准。
- 创建或修改流程文档、需求、技术方案、开发计划前，必须先运行 `scripts/workspace-path-guard.sh resolve <项目名或代码别名>`，再对每个目标运行 `check`。
- 禁止按代码工程当前目录解析 `projects/`，禁止创建 `../projects`、仓库内 `projects` 或 `/Users/soul/code/lxwx/projects`。
- 写入完成后必须运行 `scripts/workspace-path-guard.sh audit`；解析不唯一、守卫失败或工作台不可访问时必须停止，不得创建临时替代目录。
