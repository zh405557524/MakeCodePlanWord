# T-26 视频提示词 JSON 换行修复

日期：2026-11-03（America/Los_Angeles）。后端代码与开发检查完成，提交 `61f3765c`，未推送；本轮未重启本地 8080 服务或发起真实模型生成。

## 问题与修复

本地任务 `2117854046725832705` 在 DeepSeek `deepseek-flash` 提示词适配阶段失败：HTTP 200、`finish_reason=stop`，但返回 JSON 的字符串内有 4 个未转义 LF。原解析器返回空，任务在 MiniMax 视频提交前结束。此前只读核查显示该任务 FAILED/REFUNDED，原冻结 12 积分全部退回。

沿用喵喵漫剧已启用的 `tolerateFormatDifferences`，仅在原解析失败时，按 JSON 字符串和转义状态补 LF、CR、Tab 转义，再交给原解析器。内容、引号、反斜杠和既有转义保留；不补括号、字段或缺失正文。截断、字段冲突、错误类型、未转义引号及其他损坏仍拒绝。原有内容可用性检查继续执行。

变化仅作用于显式允许格式差异的来源，当前为喵喵漫剧；Catseller 与直接严格解析保持原行为，不修改共享 ObjectMapper。没有增加模型调用或自动重试，已保存的适配结果继续复用。

## 开发验证

| 检查 | 结果 |
|---|---|
| `VideoPromptRelaxationTests` | 15 通过 |
| `MiniMaxH3PromptTargetTests` | 17 通过 |
| `MiniMaxH3PromptRelaxationTests` | 28 通过 |
| `VideoPromptAdaptServiceTests` | 3 通过 |
| 原失败响应离线回放 | 通过：原严格解析仍失败，漫剧解析成功，正文与负向字段逐字保持，内容检查通过 |
| 冲突标记与 `git diff --check` | 通过 |

共 63 个自动化用例，0 失败、0 错误、0 跳过，其中新增 16 个参数化展开后的用例；另有 1 次原响应离线回放，不计为真实 Provider 验收。编译出现既有音乐接口弃用提示，构建成功。

离线回放调用生产 `MiniMaxH3PromptTarget`，不启动服务、不访问数据库、不调用模型。原响应 SHA-256：`ff510b22ec7a730d1e8dbd024bf27ded3db07bb39967aac2defd5730606d5f09`。原文与回放工具仅留在后端忽略目录 `.test/catdrama-tests/prompt-json-newline-20261103/`，不进入 Git。本目录 `verification.log`、`test-summary.json` 也仅本地保存。

执行命令（后端仓库）：

```sh
./gradlew -I .test/catdrama-tests/prompt-json-newline-20261103/replay.gradle test \
  --tests 'com.lxwx.narrateservice.core.ai.aiprompt.adapter.minimax.*' \
  --tests 'com.lxwx.narrateservice.core.ai.aiprompt.adapter.VideoPromptRelaxationTests' \
  --tests 'com.lxwx.narrateservice.core.ai.aiprompt.adapter.VideoPromptAdaptServiceTests' \
  catdramaPromptJsonReplay
```

## 数据库改动与交付边界

数据库改动：无。没有修改表结构、存量任务、积分、Provider 配置或提示词模板。保留并行修改的 `app-configs.json`；其 SHA-256 在修改前后均为 `121e20876d27a6bd17691dd182f961ea15fc6fe9aa4488d84f57cdc646bedebb`。

本地 8080 服务进程保留，需加载新代码后才可验证新的业务请求。本轮没有重启、重新提交已失败任务、真实 Provider/OSS、设备或成片质量验收；开发检查不能代替这些验收，也不能保证模型永远返回合法格式。
