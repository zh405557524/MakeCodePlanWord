# 工作台入口

工作台在 `/Users/soul/work/MakeCodePlanWord`（在 claude.ai 里通过连上的文件夹运行命令时，换成 `$HOME/mnt/MakeCodePlanWord`）。下面四条之外的文件，用到时再读，不用一开始就读。

1. **用户问进度**（“看进度”“喵喵漫剧进度”“某某做到哪了”）：运行 `python3 /Users/soul/work/MakeCodePlanWord/scripts/progress.py [项目名]`，把生成的 `进行中.html`（说了项目是 `进行中-项目名.html`）**作为文件发到对话里，只发这一个**，再用几句话说现在等谁。不要自己去各仓库查一遍再贴表格。
2. **写计划文件之前，必须先运行 `task.py new` 拿任务号**；改任务状态、卡住要用户决定、模块进度有变化，也都用脚本改，不手改表。动手前先读 `/Users/soul/work/MakeCodePlanWord/workflow/参考/任务命令速查.md`，照着做。
3. **要做某个项目的事，或者要改工作台的规则**：先读 `/Users/soul/work/MakeCodePlanWord/AGENTS.md`。
4. **说话**：用中文；时间用洛杉矶时间；交给别的 AI 的计划里，文档和仓库都写绝对路径；说到任务号时后面带上它是做什么的，例如“M03-T027（任务排队）”。
