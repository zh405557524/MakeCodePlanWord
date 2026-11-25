# M04 AI 识别形象（素材分析、拆片段、生成提示词）

> 给执行者：**开工前读完 §0～§5；遇到计划没写到的情况、产品规则不清楚，停下报告，不自己定。** 本模块只有后端任务和联调，没有界面改动。
> 执行方式：B-01～B-05 → J-01，任务之间不停；停下报告的三种情况同 M02。**不提交、不推送**；后端在原目录 `dev` 上改，网页端 / 手机端在 v1.1.0 工作区里改（总计划 §0）。
> **两套提示词（`ai-prompts.json` 正剧、`ai-prompts-short.json` 短剧）一起改，写法一致**（D-06）。用户平时在调短剧提示词：开工时对比工作区和 `dev` 上这两个文件，有不一致先停下问用户以哪份为准。

## 接口改动总览

本模块的范围：后端 `app/catdrama/analysis`（主体）、`app/catdrama/creation` 的 Markdown 读取器（第 4 行）、`app/catdrama/asset` 的登记方法（第 5 行）、`app/catdrama/shot` 的发声人解析（第 6 行）、喵喵漫剧提示词文件。网页端、手机端不改。

| # | 类别 | 接口或位置 | 改动 | 改之前 | 改之后 | 影响到谁 |
|---|---|---|---|---|---|---|
| 1 | 对外接口 | 素材分析 `POST /projects/{id}/analysis-tasks`、重新分析本集 `POST /episodes/{id}/asset-analysis-tasks`（K-25，api.md §7.11） | 行为变化（请求、返回不变） | 角色换装写在描述的“另有：…”里；多空间场所建“××俯视图”+ 描述写“关联主场景” | 角色多出别名和形象（只在剧本写明时建）；多空间场所建主场景 + 子场景；单空间场景不变；登记时挂主体、按出现集数关联 | 网页端、手机端（看到的素材变多了，结构见 K-15） |
| 2 | 对外接口 | 批量生成提示词 `POST /episodes/{id}/analysis-tasks`、生成提示词 `POST /shots/{id}/description-tasks`（K-25） | 行为变化 | 素材表里没有形象 | 素材表里形象写成“江敏·婚纱”并带外观差异；有子场景的主场景不进片段；同一片段同一角色可以用两个不同形象 | 同上 |
| 3 | 配置 | 两套提示词：`drama.script.analyze.assets`、`drama.script.analyze.shots`、`drama.script.shot.description`（各带 `.short`） | 修改 | 见第 1、2 行 | 见 B-01、B-04 | 所有新分析 |
| 4 | 模块外 Service | `DramaMarkdownContentReader#assets`（creation 包） | 修改 | 认“角色 / 场景 / 道具”三种标题 | 多认“角色形象”“子场景”两种标题和“别名”“所属主体”两个小节；`AssetSection` 加字段（保留现有构造器） | analysis 包（唯一调用方）；creation 包自己的“剧本 / 分集”读取不受影响 |
| 5 | 模块外 Service | `DramaAssetProjectService#registerAnalysisAssets`（asset 包） | 修改 | 只建平铺素材 | 多写 `parent_asset_id`、`aliases`；已有主体的别名只补不删 | analysis 包（唯一调用方） |
| 6 | 模块外 Service | `DramaShotDescription` 发声人解析（shot 包） | 修改 | 发声人按名字找素材 | 发声人写的是别名或“主名·形象名”时归到主体，声音用主体的音色 | 片段描述、视频生成 |
| 7 | 内部接口 | `DramaAnalysisContent.RegisteredAsset`（analysis 包） | 修改 | 10 个字段 | 加 `parentMarker`、`lookName`、`aliases`（保留现有构造器） | analysis 包内 |
| 8 | 数据结构 | — | 无改动 | — | 用 M02 加的两列 | — |
| 9 | 流程由谁推进 | — | 无改动 | — | — | — |

## 0. 基本信息

| 项 | 值 |
|---|---|
| 状态 | 后端代码完成、已提交（`8186bbfc`），单测 / PG 测试和 J-01 交给 Codex（2026-11-24） |
| 对应需求 | R-01：AC-01-4、AC-01-5（AI 建形象部分）、AC-01-6（AI 选形象部分）、AC-01-8（提示词每处指向各自形象）；D-03、D-06、D-12、D-22、D-24 |
| 依赖模块 | M02（两列、`DramaAssetNames`、`DramaSceneAnchor` 已删老逻辑） |
| 涉及仓库 | 后端 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，原目录，分支 `dev` |
| 执行者 | Opus |

## 1. 开工条件

| 条件 | 结果 | 依据 |
|---|---|---|
| 产品 | 满足 | AC-01-4～6、8；D-03、D-12、D-22、D-24 |
| 设计 | 满足 | 无界面 |
| 技术契约 | 满足 | api.md §7.11；技术方案 §5、§7 |
| 外部条件 | 满足 | 本机后端能调通文本模型（J-01 调 2 次素材分析、1 次批量生成提示词，免费） |
| 前置模块 | 等 M02 联调通过 | |
| 工具 | 待执行者确认 | |

## 2. 本次要读的规范

同 M02 §2 的后端部分；另读后端 `16-厂商请求参数可见性.mdc`（提示词里不写厂商、模型名）。

## 3. 现状摘要

1. 素材分析提示词 `drama.script.analyze.assets(.short)` 的 `userPrompt`：输出 `## 角色：名称`、`## 场景：名称`、`## 道具：名称`，每个下面固定小节（角色：外观描述、声音描述、原文依据、已有素材标记、出现集数）；角色换装用“另有：…”写在行末；同场所多空间建“<场所名>俯视图”（描述带“场景类型：俯视总图。”），其余空间描述写“关联主场景：<场所名>俯视图。”。
2. 解析：`creation/service/DramaMarkdownContentReader#assets(raw, sourceText, existingMarkers, soundVersion)`（约第 147～220 行）→ `AssetSection(kind, name, description, evidence, existingMarker, anchor, sound, episodes)`；`analysis/service/DramaAnalysisService#parseAssets`（约第 997 行）把它们换成 `RegisteredAsset`（约第 1020、1037 行带上出现集数）。
3. 登记：`asset/service/DramaAssetProjectService#registerAnalysisAssets`（约第 96 行）建 PROJECT 素材；按集关联由 `analysis/domain/DramaEpisodeAssetMatcher#match`（本集清单里的名字 ∪ 出现集数含本集的）算出。
4. 素材表 Markdown：`DramaAnalysisService#registryMarkdown`（约第 1527 行，每条：标记、类型、名称、描述、声音设定）；拆片段用 `shotRegistryMarkdown` → `shootableAssets`（M02 后暂时不过滤）。
5. 片段描述里的素材引用按名字匹配：`shot/domain/DramaShotDescriptionAssets`（长名字优先，“@名称”或唯一注册名）；发声人解析在 `shot/domain/DramaShotDescription`。
6. 测试：`DramaMarkdownContentReaderTests`、`DramaAnalysisServiceTests`、`DramaAnalysisServiceParseShotsTests`、`DramaShotDescriptionAssetsTests`、`DramaShotDescriptionTests`、`CatdramaPromptSnapshotTests`、`DramaPromptCatalogStartupCheckTests`、`CatdramaAssetReanalysisTests`。

## 4. 界面与设计依据

无界面。素材在界面上怎么显示由 M02、M03、M05 负责。

## 5. 契约

api.md §7.11（K-25）；data-model.md“漫剧素材：主图 + 形象”；技术方案 §5、§7。接口变化清单同总览第 1～7 行。

## 6. 任务列表（后端）

#### B-01 素材分析提示词改格式（两套）
- 关联：AC-01-4、AC-01-5；D-03、D-22；总览第 3 行
- 文件：`src/main/resources/service-data/apps/catdrama/ai-prompts.json`、`ai-prompts-short.json` 的 `drama.script.analyze.assets(.short)`
- 做法（两份文字一致，只改下面几处，其余不动）：
  1. 输出格式加两种条目：`## 角色形象：主名·形象名`（小节：外观差异、原文依据、已有素材标记、出现集数，外加 `### 所属主体`，内容是主名）；`## 子场景：场所名·空间名`（小节：外观描述、原文依据、已有素材标记、出现集数、所属主体）。角色条目加 `### 别名`（顿号分隔；没有写“无”），放在“声音描述”后面。
  2. 删掉角色四行格式里“另有：…”的写法，改为：剧本**明确写了**换装、换发型、换装饰（婚纱、短发、校服等），且在画面里出现时，建一个“角色形象”条目：形象名 1～10 字、只写和主外观不同的地方、原文依据逐字复制、出现集数只写该形象出现的集；剧本没写明的不建（宁少勿多）；同一造型只建一次。伤势、年龄阶段这类状态同样建形象。
  3. 场景：删掉“<场所名>俯视图”“关联主场景：”“场景类型：俯视总图”三处写法，改为：同一处封闭建筑 / 住宅 / 院落里拆出 2 个以上相连空间时，建一个 `## 场景：场所名`（外观描述按现有“俯视总图”要求写空间关系、统一硬装，开头写“场景类型：俯视总图。”），每个实际拍摄空间建一个 `## 子场景：场所名·空间名`；单个空间的场所只建 `## 场景：`，不建子场景。
  4. 别名：剧本里同一个人物有其他称呼（昵称、职务称呼等）且确定是同一人时，写进“别名”，不另建角色；不能确定的不写。注意：现有规则“同一人物以不同署名发声（如伪装身份）时分别建素材”保留，伪装身份不算别名。
  5. “已有素材标记”回填规则对两种新条目同样适用。
- 验证：`./gradlew test --tests '*DramaPromptCatalogStartupCheckTests' --tests '*CatdramaPromptSnapshotTests'`（快照测试按新文字更新期望）；用例 TC-M04-01
- 结果：（Claude，2026-11-24，提交 `8186bbfc`）两套 `drama.script.analyze.assets(.short)` 一起改，新加的文字两份逐字一致。① 输出格式：角色加 `### 别名`（声音描述后面，没有写“无”），角色改成“六个子标题”；加 `## 角色形象：主名·形象名`（外观差异、原文依据、已有素材标记、出现集数、所属主体）和 `## 子场景：场所名·空间名`（外观描述、原文依据、已有素材标记、出现集数、所属主体），两者不写声音字段、声音沿用主体。② 删掉角色“另有：…”写法，改为剧本写明换装 / 换发型 / 换装饰 / 伤势 / 年龄阶段才建形象（1～10 字、只写不同之处、宁少勿多、同一造型只建一次）。③ 场景：短剧删掉“<场所名>俯视图”“关联主场景”，改成主场景 `## 场景：场所名`（写“场景类型：俯视总图。”，环境声音写整个场所共用的）+ 每个拍摄空间一条子场景；单空间场所不建子场景。**正剧原来没有俯视图这条规则**，把同一段新规则加进去（两份一致）。④ 别名规则放在“身份归并”后面，伪装身份不算别名；对白署名是别名的归到这个角色。⑤ 回填规则加一句“角色形象和子场景同样回填”。另外：短剧第 40 行“拆分为两个独立场景条目”改成“拆分为两个独立条目（同一场所内的相连空间按下文写成两个子场景）”，交付前核对的场景一句换成主场景 / 子场景 / 形象 / 别名的写法。快照测试没有断言提示词正文，没改。测试没跑。 Codex（2026-11-24）：相关自动或人工证据已核对，覆盖详情见总检验清单。

#### B-02 解析新格式
- 关联：总览第 4、7 行
- 文件：`creation/service/DramaMarkdownContentReader.java`、`analysis/domain/DramaAnalysisContent.java`、`analysis/service/DramaAnalysisService.java#parseAssets`
- 做法：
  1. `assets(...)`：认 `角色形象`、`子场景` 两种标题（类型分别记成 ROLE、SCENE，另带 `look = true`）；小节表多“外观差异”（形象用它当描述）、“别名”、“所属主体”；`AssetSection` 加 `boolean look`、`String parentName`、`List<String> aliases`（新构造器；现有构造器补默认值）。
  2. 名字拆分：形象 / 子场景标题里的名字按第一个“·”拆成主名和形象名；拆不开、或“所属主体”和拆出的主名不一致 → 这一条丢掉并记 `LOG.warn`（不让整次分析失败）。形象名超过 10 字截掉并记日志。别名用 M02 的 `DramaAssetAliasRules#normalize` 同样的规则清洗（超出的丢掉、记日志）。
  3. `RegisteredAsset` 加 `parentMarker`（所属主体的标记；本次新建的主体用它的临时标记）、`lookName`、`aliases`；`parseAssets` 里按主名在“本次条目 ∪ 已有注册表”中找主体（同类型、名字全等），找不到 → 丢掉这条形象并记日志（同 2026-11-16“对不上只记录、不自动建空素材”）。
- 验证：`./gradlew test --tests '*DramaMarkdownContentReaderTests' --tests '*DramaAnalysisServiceTests'`，`DramaMarkdownContentReaderTests` 加：角色 + 2 个形象 + 别名；多空间场所 + 子场景；形象名对不上主体被丢掉；旧格式（没有新条目）结果和现在一样；用例 TC-M04-02
- 结果：（Claude，2026-11-24）`DramaMarkdownContentReader`：素材清单多认“角色形象”“子场景”标题和“外观差异”“别名”“所属主体”三个小节（只在读素材清单时认，`fieldNames(rootTitle)`）；`AssetSection` 加 `look`、`parentName`、`aliases`，原 7 参、8 参构造器保留。形象条目的 `name` 是形象名（不带主名）、`kind` 是角色 / 场景。和计划的出入：① 拆名字时先看“所属主体”——名字以“所属主体·”开头就按它拆（主名本身带“·”也能拆对），否则按第一个“·”拆再比对；“·•・‧”都当分隔符；“所属主体”没写也行。② 已有素材标记的类型按标题比：注册表里形象写“角色形象”/“子场景”，主体标记不能回填到形象上（反过来也一样），对不上按原来的规则只跳过这一条。③ `RegisteredAsset` 除了计划的 `parentMarker`、`lookName`、`aliases`，**多加了 `hasLooks`**（场景主体下面有子场景，B-04 用；只在注册表里流转）；形象的 `name` 存“主名·形象名”（素材表、清单匹配、片段 @ 引用都直接用），`lookName` 存形象名。④ `parseAssets` 改成包内可见（测试直接调）；同一主体下已有同名形象时沿用它（不重复建），本次重名的只留第一条；别名已属于别的角色的丢掉、记日志。测试：`DramaMarkdownContentReaderTests` 加 4 个（形象 + 别名、子场景、对不上被丢、旧格式不变），`DramaAnalysisServiceTests#parseAssetsShouldAttachLooksToSubjects`。本机用临时程序跑过同样的输入，结果对；JUnit 没跑。 Codex（2026-11-24）：相关自动或人工证据已核对，覆盖详情见总检验清单。

#### B-03 登记：挂主体、别名、按形象出现集数关联
- 关联：AC-01-4、AC-01-5；总览第 1、5 行
- 文件：`asset/service/DramaAssetProjectService.java#registerAnalysisAssets`、`analysis/domain/DramaEpisodeAssetMatcher.java`、`analysis/service/DramaAnalysisService.java`（`registryMarkdown`）
- 做法：
  1. 登记：先建主体、再建形象（`parentAssetId` = 主体 ID，`name` = 形象名）；已有主体的 `aliases` 只补不删（合并去重，超过 10 个的丢掉）；新建主体的别名查重用 M02 的 `checkProjectConflict`，冲突的别名丢掉并记日志（不让分析失败）。
  2. `DramaEpisodeAssetMatcher#match`：本集清单里的名字，除了等于主名，等于某个角色的别名也算这个角色（AC-01-4）；形象按自己的出现集数关联。
  3. `registryMarkdown`：主体条目多一行“别名：小敏、江老师”（没有写“无”）；形象条目“类型”写“角色形象”/“子场景”，“名称”写“主名·形象名”，多一行“所属主体：江敏”。素材分析和重新分析本集两条路径都用它。
- 验证：`./gradlew test --tests '*CatdramaAssetReanalysisTests' --tests '*DramaAnalysisServiceTests'`，加：第 3、4 集出现的“婚纱”只关联到 3、4 集；清单里写“小敏”关联到江敏；重新分析本集不删已有别名；用例 TC-M04-03
- 结果：（Claude，2026-11-24）`DramaAssetProjectService#registerAnalysisAssets`：先建主体、再建形象（`parentAssetId`、`name` = 形象名、`aliases = []`）；形象的主体不在这份注册表里时按“[素材:ID]”找已有素材，主体不对 → `CATDRAMA_REFERENCE_INVALID`。别名：新建角色直接写，已有角色只补不删，补了就把版本号加一（打开着的编辑页再保存会提示冲突，不会悄悄盖掉）；每个别名用 M02 的 `checkProjectConflict` 查重，重复的丢掉记日志。**模块外 Service 多了两处**（计划没写到，记在这里）：构造器加 `DramaAssetAliasRules`；新增 `static registered(...)`（作品素材 → 注册项，带形象信息）和 `subjectsWithLooks(...)`（只读）。`analysisSeed`、`refreshRegistry`、`episodeRegistry` 都带上形象 / 别名 / `hasLooks`。重新分析本集：本集要用的形象，它的主体就算本集不用也先登记（不关联），形象才挂得上。`DramaEpisodeAssetMatcher`：清单名字按主名对不上时再按角色别名找。`registryMarkdown`：角色主体加“别名：…”，形象写“类型：角色形象 / 子场景”“名称：主名·形象名”“所属主体：主名”，声音写主体的（没有写“同所属主体”）。测试：`DramaAnalysisServiceTests#matcherShouldMatchAliasesAndLooksByOwnEpisodes`、新建 `CatdramaAnalysisLookRegistrationTests`（PG，没跑）。计划写的 `CatdramaAssetReanalysisTests` 没加用例（它是 mock 的，登记逻辑放在 PG 测试里测）。 Codex（2026-11-24）：相关自动或人工证据已核对，覆盖详情见总检验清单。

#### B-04 拆片段、生成提示词：素材表带形象（两套提示词）
- 关联：AC-01-6、AC-01-8；D-12、D-22；总览第 2、3 行
- 文件：`analysis/service/DramaAnalysisService.java`（`shootableAssets`、`shotRegistryMarkdown`）、两个提示词 JSON 的 `drama.script.analyze.shots(.short)`、`drama.script.shot.description(.short)`
- 做法：
  1. `shootableAssets`：去掉**剧本建的（来源 `ANALYSIS`）、带子场景**的场景主体（它的图是俯视总图，D-22）；手动建 / 资产库 / 导入 / 官方的场景主体照留（主图是普通场景图，片段里主图和子场景都能用）。2026-11-25 收窄，用户决定，后端 `3d7b8a72`。
  2. 本集素材表里形象条目按 B-03 第 3 步的写法（名称“江敏·婚纱”、所属主体、外观差异）。
  3. 两个提示词各加一段（文字一致）：“同一角色有多个形象时，看片段原文和形象的外观差异选；原文没写明是哪种样子的用主名（如 @江敏）。同一片段里同一角色可以出现两个形象（如回忆和现在），每一处 @ 写清是哪一个（@江敏·婚纱 / @江敏），不能混写。有子场景的场所只能用子场景。”
- 验证：`./gradlew test --tests '*DramaAnalysisServiceParseShotsTests' --tests '*CatdramaShotDescriptionPromptTests' --tests '*CatdramaPromptSnapshotTests'`，加：素材表里有形象条目、主场景（有子场景的）不在表里；用例 TC-M04-04
- 结果：（Claude，2026-11-24）`shootableAssets`：去掉 `hasLooks` 为真、或注册表里有子场景指向它的场景主体。两套 `drama.script.analyze.shots(.short)`、`drama.script.shot.description(.short)` 在“引用素材只列……”后面加同一段：选形象的规则、同片段两个形象各写各的、有子场景只用子场景。**例子用“@某角色”“@某角色·婚纱”**（计划里写的江敏是测试用名字，不放进提示词）。原来被跳过的 `layoutOverviewSceneShouldBeExcludedFromShotRegistryAndParsing` 改写成 `sceneWithSubScenesShouldBeExcludedFromShotRegistryAndParsing`，另加 `plainScenesShouldStayShootable`。计划写的 `CatdramaShotDescriptionPromptTests` 没加用例（素材表用的是同一个方法，已在上面测）。测试没跑。 Codex（2026-11-24）：第3集真实生成， 第4集缺图拦截。

#### B-05 片段引用和发声：认“主名·形象名”和别名
- 关联：AC-01-8；总览第 6 行
- 文件：`shot/domain/DramaShotDescriptionAssets.java`、`shot/domain/DramaShotDescription.java`
- 做法：
  1. 引用匹配：“江敏·婚纱”比“江敏”长，现有长名字优先已经能分开；补测试确认 `@江敏·婚纱` 不会被当成 `@江敏`，两个同时出现时两个都引用。
  2. 发声人：对白署名是某个形象的名字（“江敏·婚纱：……”）或某个别名时，声音引用落到主体（音色共用，D-10）。
- 验证：`./gradlew test --tests '*DramaShotDescriptionAssetsTests' --tests '*DramaShotDescriptionTests'`；用例 TC-M04-04
- 结果：（Claude，2026-11-24）改在 `DramaShotDescriptionAssets`（发声人对到素材是在这里做的；`DramaShotDescription` 只按文字拆署名，“·”本来就认，没改）：`AssetEntry` 加 `parentKey`、`aliases`（3 参构造器保留）；发声人署名是形象 → 画面用形象、声音用主体；署名是别名（几个角色共用、或和角色名相同的不认）→ 都落到主体；主体不在候选里时声音退回形象自己。调用方 `DramaAnalysisService#assetEntries` 和 **`DramaShotService#syncUsagesFromDescription`（shot 包的 service，计划没列）** 传上主体和别名。画面里写“@别名”不认（提示词要求写注册名）。测试：`DramaShotDescriptionAssetsTests` 加 2 个。本机临时程序跑过，结果对。 Codex（2026-11-24）：相关自动或人工证据已核对，覆盖详情见总检验清单。

## 6.3 联调

#### J-01 本机跑一次真实分析
- 前置：B-01～B-05 完成；M02 已通过
- 准备：本机新建一部短剧作品，剧本用 `05-测试/evidence/M04/剧本-婚礼.txt`（执行者照下面要点写一份 3 集的短剧本存进去：第 1 集江敏在家，家里有客厅、阳台两个空间；第 3 集写明“江敏穿着婚纱”；第 2 集有人叫她“小敏”；第 4 集回忆镜头里江敏穿便装），**不用用户的真实作品**。
- 做法：素材分析（文本模型，免费；失败不重试，记下原始返回）→ 看素材：江敏有别名“小敏”、形象“婚纱”（出现集数 3）；“江敏家”有子场景“客厅”“阳台”；→ 第 3 集确认素材、批量生成提示词 → 片段里写婚纱的那段引用 `@江敏·婚纱`。截图和接口返回存 `05-测试/evidence/M04/`。
- 问题记录（同一个问题最多修 3 次；提示词效果不好不算代码问题，记下现象交用户）：

  | 序号 | 现象 | 属于 | 第几次修 | 结果 |
  |---|---|---|---|---|
  | 1 | 剧本第4集明确写婚纱，和验收只关联第3集的预期冲突；第4集留无图便装后不能进入分镜。 | 联调 | 0 | 见总检验 |

- 结果：有问题（见问题表）。解析单测及形象登记测试已执行；实际模型识别出小敏、婚纱、便装和子场景。 证据：`05-测试/evidence/M04/`。未做，交给 Codex 按总检验计划跑（不调付费生成；文本模型失败不重试）。 复检（2026-11-24）：第4集真实首次生成8段，回忆段同时引用江敏便装和主体。

## 7. 不改动范围

- 不改剧本生成、分集（`drama.screenplays.*`）、故事提示词；不改 `core/`；不改每集素材清单 `asset_plan` 的格式。
- 不碰网页端、手机端。

## 8. 模块验收路径（都由【系统】推进，用户只点“分析”“批量生成提示词”）

1. 素材分析完成 → 江敏有别名“小敏”（AC-01-4）。
2. 剧本写了婚纱 → 有形象“江敏·婚纱”，没有图、带原文依据、出现集数只有第 3 集；剧本没写的造型没有建（AC-01-5）。
3. “江敏家”是主场景，“客厅”“阳台”是子场景；单空间的“婚礼现场”没有子场景（D-22）。
4. 第 3 集批量生成提示词 → 写婚纱的片段引用 `@江敏·婚纱`，没写的用 `@江敏`；主场景俯视图没进任何片段（AC-01-6）。
5. 第 4 集回忆片段同时引用 `@江敏` 和 `@江敏·婚纱`（如果模型这样写了），两个都进出场素材（AC-01-8）。

## 9. 风险与回滚

- 提示词效果要靠真实跑来看，J-01 只跑一遍；不理想时记下来交用户调提示词，不在本模块反复改。
- 回滚：提示词和代码一起回退即恢复旧格式；已建的形象数据不删（显示成普通素材）。

## 10. 调整记录

| 日期 | 改了什么 | 原因 |
|---|---|---|
| 2026-11-24 | 后端：DramaAnalysisService.java 裁掉解析后音色字段尾部换行。 | M01 至 M06 总检验 |
| 2026-11-24 | 建立 | 技术方案确认后写开发计划 |
| 2026-11-24 | 审核通过；设计缺失行改为“沿用”（用户“G 全部同意”）；后端改为原目录 `dev` | 用户：“1.G 全部同意 2.计划通过 3.可以，但是后端直接dev开始开发” |
| 2026-11-24 | 开发时的出入（详见各任务“结果”）：正剧提示词补上主场景 / 子场景规则；`RegisteredAsset` 多加 `hasLooks`；`DramaAssetProjectService` 多了构造参数和两个方法（`registered`、`subjectsWithLooks`）；发声人归主体改在 `DramaShotDescriptionAssets`，并改了 `DramaShotService` 的调用；提示词例子用“某角色” | 实现时发现计划没写到；用户要求一口气做完、交 Codex 统一检测 |
| 2026-11-24 | 代码提交 `8186bbfc`（不推送）；J-01 和全部测试交给 Codex | 用户：“写完代码 记得 git提交一下” |
| 2026-11-24 | 联调后：素材分析音色字段去掉首尾空白（Codex 修，后端 `79b8902e` 一起提交）；验收路径第 2 步“婚纱只在第 3 集”是检验剧本写错（第 4 集也写了穿婚纱），以模型和剧本一致为准 | 联调问题 3；M04-2 |
