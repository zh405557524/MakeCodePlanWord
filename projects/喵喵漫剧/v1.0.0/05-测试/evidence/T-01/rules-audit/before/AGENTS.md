# AGENTS.md — 喵喵漫剧 Catdrama

## 工作区与阶段

- 本仓库是 Catdrama Flutter/iOS/Android 工程；文档统一位于 `/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧`，项目登记为 v2。
- 先读工作区及版本 README，再执行已审核的 `v1.0.0/04-开发计划/开发计划.md`；2026-10-14用户已整体批准并授权开发。
- 按任务依赖持续推进、验证并回写结果，不逐文件/逐任务重复请求批准。计划外产品取舍、契约变化或跨 App 影响先报告，继续已明确的独立任务。
- 流程文档不放在代码仓库，不创建 `projects/` 或旧版 workflow/change-log 文件；登记表是路径依据；更新进度文档前运行工作台 scripts/workspace-path-guard.sh check catdrama <绝对路径>，并运行 audit catdrama（2026-10-16已补齐脚本及自检）。

## 工程与规则

- App：`/Users/soul/code/lxwx/catdrama`；公共只读参考：`/Users/soul/code/lxwx/catsinger`。
- 共享后端：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`；修改前读其 AGENTS.md 及相关规范。
- 先读 `.cursor/rules/00-index.mdc`、`20-workflow.mdc`、`02-conventions.mdc`、`90-project.mdc`，再按层补读核心规范及当前任务的一份剧本，不一次读取全部规则。
- 登录、积分、支付、签到、邀请等复用公共实现；漫剧业务重新编写，不接入音乐页面、模型、路由和启动注册。
- Android applicationId/iOS Bundle ID 均为用户确认的 `com.lxwx.catdrama`；App Code、凭证和本机缓存与其他 App 隔离。
- Android签名经用户授权复用写歌证书，仅存于本机忽略文件；iOS不复制原应用证书或描述文件。密码、授权串及私密配置禁止提交或输出。

## 实现边界

- 前端视觉以用户 Figma（当前通道 2puw6spn，2026-10-18已连接；原 rq4owed6/5hl12w7y/hde9npiz/gfm5yvhv/vt5nn8yh 保留历史）为主，节点索引在工作区 `v1.0.0/02-设计/设计说明.md`；业务以已批准产品规则为准，图中演示数据不覆盖业务。UI须按同视口、同状态截图与Figma原图叠图，记录尺寸、间距、字体和颜色差异；测出偏差或缺少同视口证据时不记像素验收通过。
- GetX `.obs/Obx`，页面 index/controller/view 三件套，View不直调API；路由名集中在 RouteName。
- 公共存储沿用 GetStorage；完整本机剪辑快照使用 Hive。源下载、音视频混音、文字字幕合成和导出在手机；后台只做生成与主动字幕识别任务。
- 缺少目标 App 的登录、支付、模型或资源配置时明确不可用，不借用写歌商店身份、授权串或正式环境默认值。
- 保留已有未提交改动。每项任务只修改已列范围；先比较并合并目标初始模板，原文件备份及复制排除清单在工作区任务证据中记录。

## 验证与进度

- Dart改动运行 dart format；Flutter代码至少运行 flutter analyze 及相关 flutter test。
- 原生配置/插件改动执行对应平台构建或设备验证；Mock和桌面检查不能替代真实渠道或手机媒体验收。
- 2026-10-18用户要求：日常构建、安装和UI回归优先使用专用模拟器，由电脑自动完成；不反复要求用户在手机上安装或确认。运营商、性能及真机特有场景集中补验，缺条件先记录未完成。
- 每项任务执行“实现→测试/检测→回写结果”，满足完成标准才显示✅；其余显示未完成并说明阻碍。
- 完成后运行 git diff --check；未跟踪文件单独核对空白。提交仅包含本任务路径，不用 git add -A。

- 2026-10-14用户确认：外部授权/配置/测试支持缺项记录未完成，继续功能开发，不以缺项暂停整个项目。
- 2026-10-15用户确认：前端只使用main与dev分支，日常在dev开发，不另开功能分支；每个开发任务完成单独提交，提交说明带T编号。缺少测试条件的检查可留待最后集中执行，标明待测试，不冒充已验收。
