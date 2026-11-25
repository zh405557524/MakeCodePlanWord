# CHG-0063 变更前需求归档

- 归档时间：2026-08-26
- 来源版本：v0.2.0
- 状态：`reference-only`
- 归档范围：变更前完整 `01-需求/` 目录，以及后续从当前主路径移出的旧综合项目排期、Flutter/Java 技术文档、总体开发计划和模块文档；包括综合需求清单、综合 PRD、视频带货流程、历史检测反馈、恢复材料、旧素材索引和旧七天排期。
- 归档原因：当前主需求改为仅针对“邀请好友 + 银行卡提现”的独立需求包，避免视频生成、作品、积分、登录和其他旧需求进入后续技术方案。
- 使用边界：仅用于追溯、差异对比和回滚，不得作为 CHG-0063 后续技术方案、工时、前后端计划或编码依据。

## 后续移入的旧综合文档

- `effort-estimate-v1.8-old-comprehensive.md`：视频/脚本/作品等旧综合七天排期。
- `03-前端/flutter-tech-old-comprehensive.md`：原 Catseller 全量 Flutter 技术文档，SHA-256 `948c6ce8f836a75c5f390947e91a5124d24493830af1e5c70d87db6353a09f24`。
- `04-后端/java-tech-old-comprehensive.md`：原 Catseller 全量 Java 技术文档，SHA-256 `504052aa13690da7a0bc30c6c91d1c3f7a0e124dd500643a38f0caa19e1516d8`。
- `03-前端/flutter-dev-plan-old-comprehensive.md`：原 Catseller 全量 Flutter 总体开发计划，SHA-256 `93a045db3f3465003df76c046b1e165bc10db685cac95f6f1d43672cfa5b7643`。
- `04-后端/java-dev-plan-old-comprehensive.md`：原 Catseller 全量 Java 总体开发计划，SHA-256 `90ac1d880ea80d095858255ad075f32d2e08588fd63883056d84b742591f61c7`。

## 2026-08-27 模块文档归档

| 原目录 | 当前归档目录 | 文件数 | 边界 |
|--------|--------------|--------|------|
| `03-前端/开发计划/` | [03-前端/开发计划-old-comprehensive/](./03-前端/开发计划-old-comprehensive/) | 13 | 旧全量 Flutter 模块，原样移动、可恢复 |
| `04-后端/开发计划/` | [04-后端/开发计划-old-comprehensive/](./04-后端/开发计划-old-comprehensive/) | 10 | 旧全量 Java 模块，原样移动、可恢复 |

- 本次未删除这些文件；当前主目录重新生成的 17 份模块文档仅覆盖邀请好友与银行卡提现，不与旧模块混用。
- 历史 CHG/执行记录中的旧模块相对路径保持历史事实；需要追溯时，按上表目录映射查找同名文件，不把新目录的不同模块当作历史证据。
- CHG-0019、CHG-0020 等其他进行中事项保持原状态并 defer；本归档不表示这些事项已完成或取消。
- 恢复旧文档前须单独确认目标范围并重新执行路径守卫，不得覆盖当前邀请提现模块。

当前需求真源：`/Users/soul/work/MakeCodePlanWord/projects/喵喵带货/01-需求/requirements.md`。
