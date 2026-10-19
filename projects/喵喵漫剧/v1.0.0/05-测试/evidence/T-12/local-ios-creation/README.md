# T-12／T-13 普通 iOS 真实创作联验

2026-10-19。本机正式入口的一组灵感样例，覆盖故事→手改→全剧逐集稿→手改→确认创建→作品入口恢复。App 为普通 `com.lxwx.catdrama` 1.0.0+1，iPhone 17 Pro／iOS 26.5 模拟器；沿用 T-03／T-47 已核验的 `49c005c` 运行包。当前 App HEAD `2fe9855` 的后续差异为规则文字，不作为本轮新运行代码。后台为本机 8080，沿用 `6bd40ee6` 的隔离构建；当前正式 DeepSeek 通道 `deepseek-flash`，不是文本夹具。

结论：本组真实链路通过，完整任务与正式用例仍部分验证。47 项维持 7 完成／40 未完成，186 条维持 12 通过／171 部分／3 未执行。本轮没有业务代码、数据库结构、配置变更，没有重跑有效的 Flutter／Gradle 基线；本报告只证明实际执行的范围。

## 实际操作与证据

| 核对点 | 实际结果与证据 |
|---|---|
| 独立草稿 | 保留旧草稿，实际点击新建；灵感原文以 AI 拆分提交，未创建正式作品。见 [输入](run-creation/observations/O00019.png) |
| 真实故事 | DeepSeek 返回 12 集完整方向。[故事](run-creation/observations/O00022.png)，[原文](sources/story-original.md) |
| 手改与覆盖取消 | 梗概、第一集方向加入蓝灯设定，点击重生出现覆盖提示，取消保持。见 [提示](run-creation/observations/O00034.png)、[取消](run-creation/observations/O00036.png) |
| 一次全剧 | 确认故事 revision 3 后，单个 SCREENPLAYS 任务一次返回 12 集，每集 389–881 字；完整模板输出校验后交付。[结果](run-creation/observations/O00040.png)、[全剧原文](sources/screenplays-original.md) |
| 手改逐集稿 | 第一集标题改为“雨夜旧伞·蓝灯”，正文追加手工校对；取消重新生成保留。[正文](run-creation/observations/O00044.png)、[覆盖提示](run-creation/observations/O00046.png)、[取消后](run-creation/observations/O00049.png) |
| 重启恢复 | 实际终止并重启 App，从首页重新进入原草稿；所有正文、revision 和两个任务身份与重启前完全相等，没有新调用。[终止](run-creation/observations/O00051.png)、[恢复](run-creation/observations/O00059.png) |
| 完整列表 | 逐集滚动核对，能到第 12 集。[末三集](run-creation/observations/O00069.png) |
| 确认创建 | 点击开始制作，仅 1 个正式作品、12 集，标题／正文逐字等于最终手改稿；制作参数可空，不自动分析。[制作设置](run-creation/observations/O00072.png) |
| 继续原作品 | 返回后按钮变为继续制作设置，进入仍为同一作品。[继续](run-reentry/observations/O00004.png) |
| 作品入口恢复 | 再次实际终止、启动，从作品→同一作品详情→制作设置；真实显示待设置、12 集、11月18日到期。[列表](run-reentry/observations/O00012.png)、[详情](run-reentry/observations/O00014.png)、[恢复设置](run-reentry/observations/O00017.png) |

## 数据与实际外呼

- 草稿 `2112182169893457921`，作品 `2112192848956346369`。故事 `2112183364557066241` 与全剧任务 `2112190726672076801` 均 SUCCEEDED／FREE。新任务只有这两个，不把旧草稿的历史任务计入本轮。
- 两个独立 HTTP client callId 各有一条 DeepSeek 请求和 HTTP 200，真实主机均为 `api.deepseek.com`；处理器各记录一次实际调用。元数据见 [provider-metadata.json](provider-metadata.json)。本地 attempt UUID 和 HTTP client callId 分别记录，不冒称厂商异步任务号。
- 全剧输入精确使用完整手改梗概及全部 12 个方向；第一集包含追加的蓝灯特写。生成原文 12 集完整；手改确认后第 1 集正文为 909 字。
- 可用 30／冻结 0、流水 6 始终保持；无新收费、分析任务、资产或图片。旧草稿全文及版本不变。作品、剧集创建后 30 天到期；重进与继续操作不延长。
- [重启前](data/before-restart.json)与[重启后](data/after-restart.json)完整投影相等；[创建后](data/project-created.json)与[作品重进后](data/reentry-final.json)完整投影相等。固定断言及余项见 [verification.json](verification.json)。只读 SQL 随投影留存，无直接业务写库或 DDL。

## 验收边界与剩余项

TC-05-01 要求至少三组不同复杂度和返回自定义，本轮只有一组；TC-09-06 还包含离线媒体和到期入口，本轮仅在线待设置恢复。因此两个控机 run 的完整检查均保留 blocked／original_case_status=not_assessed，表示整条覆盖未齐；已通过的局部步骤在本报告逐项列明，不将局部变成整条通过。

其余入口、完整非法输出／失败矩阵、活动任务中断、写盘中断、普通 App 丢创建回执、Android 登录后流程、物理设备及最新 Figma 仍按原记录待验。视频接入已由用户确认暂缓，设置页真实提示无可用有声模型并禁用开始整理；未伪造模型或参数推进后续分析。

生成质量观察：第 11 集把“玉珍”称为“三个字”，原始文本未自动改写。结构成功不等于全部文学质量通过，后续继续多样本核对。

控机工具曾因动画／过时坐标阻止动作，另有一次输出解析问题已用新截图核实取消完成；旧控制 session 后续过期，已确认 invalid session id，保留原记录并关闭后另建恢复 run。均未据此重新提交生成任务，不计为 App 业务失败或通过。两个 run 已关闭，没有清除 App 数据或重启共享后台。

完整观察、事件与原始结果留在本目录；运行控制 state／profile、私密定义和原始供应商日志不复制。原文件摘要见 [manifest.json](manifest.json)。
