# {项目名称} 研发变更日志

> 规则来源：`.cursor/rules/00-核心工作流程.mdc` 第五步「变更管控与版本化记录」
> 用途：跨迭代累积「面向研发」的变更日志，按 semver 版本号汇总。
> 与项目下 `08-发布版本/changelog.md`（面向用户）的关系：
> - 本文件保留 CHG-id、影响文件路径、技术细节，用于研发追溯与回滚。
> - `08-发布版本/changelog.md` 由本文件按版本号筛选 user-visible 变更后改写而成，不直接复制研发条目。
>
> 维护规则：
> - `change-plan.md` 顶部「进行中变更」中状态变为 `done` 的条目，必须立即追加到本文件对应版本号块。
> - 已发布版本不允许再追加变更；如有需要，请创建新的 patch/minor/major 版本块。
> - 回滚的变更（状态 `rolled_back`）也要记录，写明回滚原因。

---

## 版本号规则

采用 semver（`major.minor.patch`）：

- `patch++`：编码期局部修改、缺陷修复、文案 / 资源调整
- `minor++`：新增功能 / 模块，无破坏性
- `major++`：架构调整、不兼容改动、推翻重做

每个版本块固定三段：

- **Added**：新增（feature_add）
- **Changed**：修改（feature_modify / refactor）
- **Removed**：删除（feature_remove）

---

## v0.1.0 - YYYY-MM-DD

> 关联里程碑：（如 Alpha / 内部预览）
> 关联 QA 报告：`projects/{currentProject}/05-联调与测试/qa-plan.md` 中 v0.1.0 区段
> 关联工时评估版本：`projects/{currentProject}/02-技术方案/effort-estimate.md` v1.0

### Added

- [CHG-0001] {一句话描述} - 影响文件：`lib/pages/settings/widgets/theme_switch.dart` 等

### Changed

- （暂无）

### Removed

- （暂无）

### Rolled back

- （暂无）

---

## v0.0.1 - YYYY-MM-DD

> 项目初始版本，骨架搭建完成。

### Added

- 工程骨架（Flutter + Kotlin）
- 基础规则与流程文档

### Changed

- （暂无）

### Removed

- （暂无）
