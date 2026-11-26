@AGENTS.md

# 先读这几条（上面那一行如果没有自动展开，这里就是全部入口）

工作台在 `/Users/soul/work/MakeCodePlanWord`。开始任何事之前，**先打开并读完 `/Users/soul/work/MakeCodePlanWord/AGENTS.md`**，它写着怎么确定项目、读哪份流程细则、改规则要同步哪些文件。

下面三条不用等读完别的文件，直接照做：

1. **用户问进度**（“看进度”“喵喵漫剧进度”“某某做到哪了”）：先运行 `python3 /Users/soul/work/MakeCodePlanWord/scripts/progress.py`（说了项目就在后面加项目名，例如 `… progress.py 喵喵漫剧`），**把生成的 `进行中.html`（或 `进行中-项目名.html`）作为文件发到对话里**，再用几句话说现在等谁。不要自己去各个仓库里查一遍再贴表格。
2. **改了任何模块的进度**（写完后端或前端、自己审核完、检验完、卡住了）：马上运行一次
   `python3 /Users/soul/work/MakeCodePlanWord/scripts/set-status.py <项目> <版本> <模块号> 栏=值`
   例如 `… set-status.py 喵喵漫剧网页端 v1.1.0 M08 后端=完成`。不要手改总计划里的模块清单表。能填的词运行 `… set-status.py` 不带参数可以看到。
3. **用中文回答；说时间用洛杉矶时间；交给 Codex 的计划里，文档和仓库都写绝对路径。**
