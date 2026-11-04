# T-18 整体剧本语法解析开发检查

日期：2026-11-03（America/Los_Angeles）。后端提交：`a61bbe3d`。本切片完成源码修改、离线回放和独立数据库开发检查，未推送、未部署；正式测试及设备验收计数保持原状态。

## 用户要求与检查范围

用户要求检查整个剧本解析链，按语法结构处理格式差异。检查了故事大纲、逐集剧本、现成剧本标题预读、素材清单、镜头清单，以及下游对白、时间段和时长选择。

主要问题集中在 `DramaMarkdownContentReader`：标题标点、数字写法、标题层级、固定字段顺序、单行字段和整篇 Markdown 围栏会使含义相同的输出失败。`DramaExistingScriptOutline` 另有一套标题规则，现已复用统一标题语法。对白和时间段已有结构提取逻辑，本次纳入回归。

## 解析规则与边界

统一按“文档 → 条目 → 字段 → 字段值”读取，随后校验编号、必需内容、素材身份和数值范围。格式识别保留原始字符串位置，不先全局替换剧本。

| 层次 | 本次支持的等价写法 |
|---|---|
| 文档包装 | LF/CRLF、BOM、空行；模型文档可整体包一层 Markdown/text 代码围栏，嵌套代码块内标题不参与结构识别 |
| 结构标题 | `#` 层级差异、缩进、标题空格、加粗标题、末尾闭合 `#`；识别结构关键字后确定其语法层次 |
| 集号与镜头号 | 阿拉伯数字、全角数字、前导零、中文数词；`第 １ 集 : 标题`、`第一集：标题`、`镜头 1`、`第一个镜头` 等 |
| 字段 | 按字段名称取值，允许交换顺序；允许标签和值写在同一行，支持标签或整个标题加粗，正确区分字段和值各自的强调边界 |
| 素材与声音引用 | 无序/有序列表、裸标记、额外一层方括号、单值加粗或代码标记；单独的 `无` 和 `- 无` 表达空引用 |
| 建议时长 | 数值与单位分开识别，例如 `8秒`、`8 秒`、`８秒`、`08秒`、`8.0秒`、`八秒钟`、`8s`；结果必须是 1–999 的整数秒 |
| 原文依据 | 先精确定位；临时匹配视图可解包整段引用、强调及代码围栏，返回锚点仍指向实际原文 |
| 上传现成剧本 | 普通标题和 Markdown 标题复用相同集号、标点及强调语法；围栏内示例继续忽略 |

原始模型响应、摘要、正文片段和 UTF-16 偏移保留；名称及引用不通过相似度猜测身份。字段内容和原文不会为了通过校验而截断、改写或补写。

仍校验缺失/重复字段、缺集/重复集/乱序、错误镜头编号、未知/重复素材、混用“无”和引用、无效或非整数秒、截断围栏及无法定位的原文。素材标记先精确命中注册表，再接受额外的一层方括号；声音类型仍由业务层校验。素材单项失败的原有跳过策略、既有原文模糊定位和对白辅助绑定策略沿用，本次没有扩大这些语义策略。

这是一套明确的文档结构语法，不承诺任意自由格式、任意字段同义词或缺失内容都可恢复。JSON 外层包裹、额外说明前言、含义不确定的身份和结构继续明确失败；格式恢复不会触发额外模型生成。

## 验证结果

最终 11 个相关测试类共 **246 项通过，0 失败，0 跳过**。其中新的文档语法测试 63 项，覆盖四类文档、v1/v2 声音版本、组合格式、字段顺序、原文切片/锚点和错误边界。

| 测试类 | 项数 |
|---|---:|
| CatdramaDocumentGrammarTests | 63 |
| CatdramaReferenceGrammarTests | 31 |
| CatdramaMarkdownTests | 12 |
| CatdramaSoundProfileTests | 6 |
| CatdramaAnalysisFailureReasonTests | 3 |
| CatdramaMarkdownPersistenceTests | 8 |
| CatdramaAnalysisTests | 32 |
| CatdramaScreenplayTests | 15 |
| DramaShotDescriptionTests（原入口） | 6 |
| app.catdrama.shot.domain.DramaShotDescriptionTests | 63 |
| DramaShotTimingTests | 7 |

数据库流程新增检查：格式变化后的故事原始响应和 SHA-256 原样持久化，检查点为 VALID 且仅一个尝试；全剧素材及两个分集镜头可解析、保存、应用并从接口读回，确认原文保持，AI mock 调用数为素材一次、分集各一次，没有自动重新生成。

测试服任务 `2117618696363073538` 首次失败的原始输出未经替换，离线解析出 4 个镜头；原始 SHA-256 为 `fd3d415bf54e8ac4e65ef69739e5699bde7c29294c6a261622d7576c6124498d`。标准写法与列表写法的原文、描述、锚点、引用顺序及建议时长一致；真实成功重试输出仍可解析，未知素材副本仍被拒绝。离线回放真实 Provider 调用 0 次、业务数据库写入 0 次。

两项已在修改前解析器上复现的既有失败显式排除，没有计入 246 项通过：

1. `CatdramaMarkdownTests.toleratesAmbiguousOrUnlocatableAssetEvidence`：既有模糊定位与空锚点预期不同。
2. `CatdramaSoundProfileTests.speechBindingUsesStableIdentityAndRejectsOnscreenAudioOnlyRole`：既有对白辅助绑定与预期抛错不同。

其基线复现过程见[引用语法检查](../reference-grammar-20261103/README.md)。本次没有放宽这两项断言。

扩大回归时另发现两条既有恢复测试偶发领取不到任务：`persistedFullDramaRecoversWithoutAnotherGeneration` 和 `reconstructedServicesResumePendingRawWithoutGenerationAndPublishExactSource`。门面的模拟时钟没有传到实际执行领取的运行时，1ms 延迟尚未到期时可能返回空租约；前一条在修改前解析器单独运行时通过，不能把这次偶发失败归因于解析器。已在这两条测试的独立数据库夹具中将本测试任务设为到期，再执行原恢复断言。最终两条均通过，生产任务调度代码未改。

Git 空白与冲突标记检查通过。其他会话的配置及工作区改动保留。

## 复现产物与交付边界

本机忽略目录：后端 `.test/catdrama-tests/script-grammar-20261103/`。`test-command.json` 保存完整范围命令，`final-verification.log`、`test-summary.json`、`final-results/` 保存最终结果；早期失败、修改前对照和时序夹具调整前结果分别保存。回放继续使用 `.test/catdrama-tests/analysis-reference-20261103/replay.gradle` 及受限权限的原始输入。

范围命令使用 `-PcatdramaExcludeKnownBaselines` 排除上述两项既有失败；运行表中 11 类测试及 `catdramaAnalysisReferenceReplay`，并将 `CATDRAMA_TEST_POSTGRES_URL` 指向本任务独立数据库。

数据库结构/迁移无改动。集成测试使用本任务独立 PostgreSQL 的随机 schema，结束后剩余测试 schema 为 0，所属实例已停止、数据目录保留。没有修改本地业务库、测试服任务、私有配置或历史结果，没有重启共享服务，也没有触发付费生成。

部署到测试服及部署后的真实业务复验尚未执行；本报告不等同于设备、Provider 内容质量或正式版本验收。
