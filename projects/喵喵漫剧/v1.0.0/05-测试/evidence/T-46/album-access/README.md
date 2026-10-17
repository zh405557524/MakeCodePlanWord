# T-46 相册读取权限取消、拒绝与本机编辑

状态：本切片通过；这里只补相册提音的权限异常证据，T-46整项仍未完成。

App提交：`a5f067426cefb67256a763a7f59c8f2a4fdde12b`，仍在`dev`，未推送。运行时代码沿`c550bb6`；本轮只新增集成测试、严格驱动检查和说明。原1222项全套为有效前轮基线，本轮未重跑，不重复计数。

范围：App `dev`，新增 `integration_test/source_audio_access_test.dart` 与原严格驱动的独立 `source-audio-access` 分支。业务、公共权限实现、原生引擎、依赖、后台与数据库均不改。独立测试工程使用已有真实AVFoundation预览、Hive和公共MediaLibrary入口；不注册后台HttpService，源版本联网核对会保留原固定版本并提示，不能当作在线后台证据。

前置条件：只使用自有iPhone 15 Pro Max模拟器 `E33B4820-6860-419F-8B17-B6A8FA94EA77`，初始关闭，Catdrama的照片读取和仅添加权限均未决定；保留已安装App与原相册全部视频。公共协议同意使用已接受的测试夹具，不伪造系统权限、不预先授权、不覆盖Access调试入口。

| 用例 | 关联 | 优先级 | 步骤 | 可观察预期 | 实际结果 |
|---|---|---|---|---|---|
| T46-ACCESS-01 取消用途说明保留工程 | TC-18-08、TC-X30（部分） | P1 | 编辑页点音频→从相册视频提取→取消 | 返回可编辑页；未弹系统权限；完整工程head和持久化快照不变，不创建提音任务或音轨 | 通过，状态图2–3；完整head与持久化快照相等 |
| T46-ACCESS-02 拒绝系统读取保留工程 | 同上 | P1 | 重试相册入口→继续→电脑点当前App照片读取弹框“不允许”→取消设置指引 | 显示“权限提示／请允许访问您的视频／去设置”；真实Photos权限为permanentlyDenied；旧工程及音轨完整保留，无提音任务 | 通过，系统授权图与状态图5–6；TCC实际auth_value=0，未增加仅添加权限 |
| T46-ACCESS-03 拒绝后仍可本机编辑 | 同上、T-32回归（部分） | P1 | Photos仍拒绝时点文本，输入“拒绝相册权限后仍可编辑”，点✓保存 | 保存一个文字层且只增加一次工程修订，原画面片段、声音修订、音轨和总时长不变；持久化快照与页面head一致 | 通过，状态图7；revision 1→2，旧片段、音轨、声音修订与14.004秒总时长不变 |

执行：`run_ios.py` 构建专用iOS测试包后用原严格驱动运行。每张App状态图由当前进程通过序号握手申请，宿主核对真实模拟器App可执行文件PID后系统截图，再确认同一序号。系统授权图另由当前WDA原生节点定位；只匹配本App、照片读取用途和唯一“不允许”，不点其他App或仅添加弹框。

初轮发现测试按完整含换行文案定位，实际公共用途说明将标题和正文拆成两个Text。保留该轮运行日志和现场图；修正测试定位后再完整复跑，不改公共权限UI。

结果：34项既有提音测试、完整analyze、两文件格式、iOS模拟器debug构建及1条完整原生页面方法通过。该方法包含上述3个场景，不冒充3次设备方法。宿主对实际读取弹框、其他App及实际仅添加弹框的3项定位检查通过，宿主在实际设备运行后未修改；没有额外手动补点。首轮75秒超时和驱动拒收保留于`attempt-01-ios/`与忽略的`originals/attempt-01/`，不累计为通过。

证据：最终[7状态图](ios/system-captures.json)与[实际系统授权](ios/read-permission.png)、[严格驱动报告](ios/ios-source-audio-access-result.json)、[授权记录](ios/permissions-after-denial.json)、[结果](outcome.json)、[清理复检](cleanup-recheck.json)。8图已总览，授权、设置指引与已存文字3图详检；详见[图像核对](visual-review.json)。截图中系统图库的39个视频资产与磁盘42份视频文件为不同统计口径，本次只按完整文件集合与摘要核对“不新增、不删除”。

运行结束：42份既有视频文件摘要完全保持，Photos/PhotosAdd恢复初始无记录；不卸载App，不清空数据或相册。自有模拟器关闭，54393/4731/8115三个自有端口均关闭；未启动后台或数据库。生产代码、原生引擎、API、DDL、依赖及12份保护文档不变，47项仍7完成/38进行中/2待外部；186条仍9通过/172部分/5未执行。

独立待办：最新Figma通道仍返回`Not connected to Figma`，当前工具也没有`get_design_context`。依[Figma设计转代码技能](/Users/soul/.codex/plugins/cache/openai-curated/figma/bd2122cb/skills/figma-design-to-code/SKILL.md)“You MUST call `get_design_context` on the target node before writing any code.”，T-32更多字体和底色本轮未实施，没有修改已批准的字体契约或以近似字体替代；记录于[外部缺项](external-blockers.json)。

本轮未覆盖：iOS有限照片访问、Android读取拒绝、iCloud未下载视频、真机、真实空间不足和真实ASR。测试文字用tester输入，不当作系统键盘验收。不改原186条用例定义、正式执行状态、产品/设计/技术和上线基线。
