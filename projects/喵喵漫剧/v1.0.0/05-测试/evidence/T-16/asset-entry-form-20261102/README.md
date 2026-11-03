# T-16 / T-47 资产入口与创建表单修正（2026-11-02）

代码已提交 App dev `3e6a0ef`，未推送。生成/后处理期间禁入详情（含旧图重生）；三类资产的AI与相册创建页取消帮写及恢复，已有资产编辑保留帮写。产品、评审、设计说明和开发/测试文档已同步，历史记录保留。

## 自动检查

| 检查 | 结果 | 证据 |
|---|---|---|
| Flutter / Dart | 3.41.6 / 3.11.4 | 本机SDK版本文件 |
| 全项目 analyze | 无问题 | [日志](analyze-final.log) |
| 定向资产列表/表单（首轮修正后） | 103项通过；后续另补当前版本状态用例 | [日志](targeted-tests.log) |
| 最终资产模块 | 328通过、4失败 | [日志](assets-tests-final.log) |
| 本次修改前实现对照 | 同4项失败；隔离复制lib，仅还原本切片4份生产源码为当时HEAD，不覆盖共享工作树 | [日志](baseline-tests.log) |
| format / diff / 工作区audit | 通过 | 交付命令及本地记录 |

覆盖排队/RUNNING/SUBMIT_UNKNOWN/FINALIZING/后处理、有无旧图、成功/失败恢复、旧卡片回调和无任务摘要的当前版本；六种创建表单恢复旧候选不查询/提交帮写、手改持久化；已有资产编辑的候选/手改保护、原生成/上传和编辑态选择按现有套件回归。

4项既有失败：`sound_profile_test`报价夹具Map类型；`auto_library_test`的新结果预览版本与失败任务保护两项；`image_batch_test`小屏弹框pumpAndSettle超时。均在还原本次修改前的生产源码副本中复现，未扩大本轮修复范围，不将资产全套记作全绿。初轮新增用例的字数预期与编辑夹具缓存准备失败已修正，原失败日志保留。

## 电脑控机

设备为固定池领取的 `Solfeggio_Store_Phone_20261019`，Pixel 5 / Android 17，1080×2340，ADB `emulator-5554`；受控Debug包1.0.1(101)，生产AssetsPage/AssetEditPage/AssetDetailPage与本机存储实际运行。界面数据和HTTP回执为明确标注的协议夹具，未连接真实Provider或扣费。

状态：本切片电脑控机检查完成，待用户验收；三类AI与三类相册创建均已实际打开，描述和字数统计保留，无帮写/候选。进入六种表单的帮写查询与提交均为0。首轮使用[既有电脑控机工具事件](phone-run-ready/events.jsonl)，仅借用TC-03-01执行器，未完成原综合分类用例，原用例保持not_assessed。后续复用同工具AdbDriver并逐步保存[坐标操作事件](desktop-check/events.jsonl)与原尺寸截图，按本次ASSET用例单独验收。

受控包重装时初始夹具只在内存保留任务，准备阶段恢复旧夹具任务失败；保留日志/旧数据后跳过重复种数，直接打开已保存表单，受控入口恢复。此为本地测试准备问题，不归为产品缺陷。早期启动截图/未匹配定位/禁用控件拒点与过时坐标拦截保留为工具记录，未据此记业务通过。

## 本次实页结果与截图

| 本次检查 | 结果 | 原尺寸截图 |
|---|---|---|
| 首次生图禁入 | 点击后仍在资产库；无障碍disabled | [生成中](phone-run-ready/observations/O00002.png)、[点击后](phone-run-ready/observations/O00004.png) |
| 旧图重新生成禁入 | 旧图可见，点击不进入详情 | [禁用](phone-run-ready/observations/O00006.png)、[点击后](phone-run-ready/observations/O00008.png) |
| 后处理禁入 | 最新构建实点后画面不变，无详情跳转 | [处理状态](desktop-check/S007-final-processing.png)、[点击后](desktop-check/S008-final-processing-blocked.png) |
| 自动恢复入口 | 不强制刷新，记录到下一次列表读取，成功后点击进入详情 | [恢复详情](desktop-check/S035-final-detail-restored.png)、[轮询记录](final-auto-refresh.json) |
| 角色 / 场景 / 道具 AI创建 | 均无帮写、候选或进度，旧描述3/500保留 | [角色](phone-run-ready/observations/O00022.png)、[场景](phone-run-ready/observations/O00033.png)、[道具](desktop-check/S001-prop-ai.png) |
| 角色 / 场景 / 道具相册创建 | 从实际相册选择本次自有图片后进入描述页，均无帮写；名称4/20、描述3/500保留 | [角色](desktop-check/S018-role-album-confirm.png)、[场景](desktop-check/S025-scene-album-confirm.png)、[道具](desktop-check/S032-prop-album-confirm.png) |

相册仅授权本次自有图片的有限访问，原生选择器和受限资源继续入口均实操；本次只检查创建表单，未点击确定上传，实际OSS上传不据此记通过。三类AI页图来自并行相册布局调整前的本切片构建，三类相册页与后处理实点图来自包含并行布局的后续构建；两轮都使用真实生产页面，由电脑点击，不是Widget截图。控机原始事件与全部过程图保留。设备已关闭，本任务固定池租约已按原owner/token归还。

受控状态接口的route字段没有反映GoRouter的imperative push，因此不单凭route字段判定页面跳转；禁入/可入均以实际PNG/XML及路由Widget回归为准。HTTP记录只用于确认帮写读取/提交0、未创建付费任务，以及列表自动刷新发生。

## 验证边界

已查看留存设计参考图，按用户明确要求移除创建页帮写，并检查实际页面；实时Figma通道读取超时，本轮不宣称全页Figma像素或用户视觉验收。相册布局存在并行修改，仅保留其工作树内容，App提交通过单独暂存本切片差异避免混入。截图、安装包、响应、日志和本地入口均不进入Git。

本轮不执行真实Provider/OSS、生产部署、真机或正式渠道验收，不改变原186条正式用例及全项目验收统计。

工作区已有文档迁移尚未全部纳入HEAD；本次产品、评审、设计及计划/测试同步保留在共享工作树，不将整份迁移文档混入提交。本报告单独纳入版本管理，原始证据仍仅本地保存。
