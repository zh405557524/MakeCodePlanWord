# T-12 AI 集数多样本与返回自定义联验

2026-10-19，普通 iOS App 与本机正式 DeepSeek 通道。iPhone 17 Pro／iOS 26.5 模拟器，`com.lxwx.catdrama` 1.0.0+1，运行代码 `49c005c`；当前 App HEAD `2fe9855` 的后续差异为规则文字。后台沿用 `6bd40ee6` 隔离构建、本机 8080，实际调用 `api.deepseek.com` 的 `deepseek-flash`，未使用文本夹具。

结论：三组 AUTO 分别为 **12、3、12 集**，返回 CUSTOM 后准确为 **1 集**。本轮界面检查 passed；正式 TC-05-01 保持部分验证，控机原完整状态仍为 not_assessed，不把模拟器当物理真机。47 项仍 7 完成／40 未完成，186 条仍 12 通过／171 部分／3 未执行。

## 三组输入与剧情覆盖

| 样例 | 输入与结果 | 剧情核对 |
|---|---|---|
| A 雨伞店的来信 | 复用上一轮已提交的真实灵感 AUTO 12 集；[输入](../local-ios-creation/sources/original-text.txt)、[原始故事](../local-ios-creation/sources/story-original.md)、[完整链路](../local-ios-creation/README.md) | 旧伞／车票、母亲旧信、老站长误会、修伞送信、重开伞店在 12 个方向中完整承接；没有重新提交本组 |
| B 厨房的小红花 | [74 字灵感](sources/short-inspiration.txt)，AUTO 3 集；[原始输出](sources/short-auto-original.md)、[实际页面](run/observations/O00022.png) | 单一厨房、猫与主人、打翻水杯→擦桌→小红花，未新增角色或支线；整体仍描述一分钟内事件。3 集是本次模型选择，不承诺总片长已达成 |
| C 钟楼最后一班车 | [609 字小说](sources/novel-excerpt.txt)，AUTO 12 集；[原始输出](sources/novel-auto-original.md)、[首页结果](run/observations/O00048.png)、[中段](run/observations/O00054.png)、[最后三集](run/observations/O00057.png) | 三封信分别对应宋云、陈伯和许宁；钥匙冲突、旧桥隐患、封钟楼争议、祖父道歉、设备短路、灯号救援和最后邮车结尾均保留。逐页查看至第 12 集 |

原始输入、完整 Markdown、候选与来源快照逐一比对；序号为 1…N，标题和方向均非空，原文未被字数切片或固定 6 集替代。文学质量仍按样例核对：A 上轮“玉珍三个字”的观察保留；B 将短事件拆为 3 集属于当前允许的模型判断；这些结构验证不等于所有生成内容质量或最终成片验收。

## 返回自定义与旧稿保护

B 从故事页返回输入，选择自定义 1 集：[选项](run/observations/O00026.png)。再次前进时，旧 3 集仍展示但提示来源版本变化、需重新核对，下一步禁用：[旧稿保护](run/observations/O00028.png)。只在主动点击重新生成后创建新任务；真实结果为 1 集：[结果](run/observations/O00031.png)、[原始输出](sources/short-custom1-original.md)。

原文保持 74 字，sourceRevision 从 2 到 3；旧 STORY 候选仍保留在原任务，新 CUSTOM 任务 expected_count=1、targetBaseRevision=1。变更集数到主动重生成之间，没有额外 STORY 提交或正式作品创建。此过程只覆盖 TC-05-02 的合法 1 集与 TC-05-04 的集数变更部分，不替代 0／-1／小数／31／30 边界及已有确认剧本的完整矩阵。

## 数据与实际外呼

- B 草稿 `2112224184358260737`，AUTO 任务 `2112225068609818625`，CUSTOM 任务 `2112226571626074114`；C 草稿 `2112227871185031169`，AUTO 任务 `2112229275727417346`。三个新任务均 SUCCEEDED／FREE，各一次真实 HTTP 200；[外呼元数据](provider-metadata.json)不包含密钥、headers 或原始请求日志。
- [起始投影](data/before.json)、[变更集数后／提交前](data/custom-before-generate.json)、[终态任务与候选](data/final-proof.json)、[全部稿件终态](data/final-detailed.json)可复查。只新增 2 份草稿和 3 个免费任务；旧 2 份草稿逐字段相等，原正式作品的身份、确认快照、参数和截止时间不变。正式作品仍 1 个、分析任务 0 个。
- 可用积分 30／冻结 0、流水 6、资产 1、图片任务 1、图片版本 1 始终保持，无扣分或额外生成。只读 SQL 随投影保存，没有直接业务写库、DDL、配置或服务重启。
- HTTP client callId 与 provider_request_id 是各自本地记录身份；按处理器开始窗口及紧邻唯一 DeepSeek 请求关联，不冒称供应商异步任务号。三个原始请求内容只在本机核对，公开资料仅存白名单字段。

## 范围与复查

57 份原始系统截图及对应树、事件、结果全部保留在 [run](run/)；文件摘要见 [manifest.json](manifest.json)，断言与余项见 [verification.json](verification.json)，[样例索引](samples.json)。Appium 仅负责普通 App 界面控制；每个最终页面均实际查看，未注入 Controller 直接替代用户操作。仅小说文本输入，本轮没有执行 TXT 系统选择器。

控机期间动画／过时观察门禁曾拒绝操作，重拍后继续，没有据此重复提交生成。小说任务在准备中断检查前已成功，因此本轮没有制造额外调用，也不声称验证了活动任务中断。最终 run 已正常关闭。

T-12 完整任务仍待真实设备、Android 登录后流程、完整失败／未知／迟到／写盘中断矩阵及当前 Figma；视频接入仍按用户确认暂缓。未改正式用例的步骤、预期或通过统计，未重跑未变业务源码的 Flutter／Gradle 基线。业务测试范围以本报告实际证据为准。
