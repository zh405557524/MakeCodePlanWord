# 11 权限、网络、中断、资源与后台配置联动

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| PERM-001 | 文件权限 | Android 首次选择音频权限允许 | android | P0 | external | 清除文件/媒体权限 | 合法音频 | 1. 在参考音频或翻唱页点击本地上传<br>2. 允许系统权限<br>3. 选择文件 | 系统选择器可用并返回 App；文件进入处理状态 | 仅在用户选择后上传资源 | 权限弹层和返回页截图 | manual |  | permission,android,file |
| PERM-002 | 文件权限 | Android 拒绝文件权限后可再次操作 | android | P1 | external | 权限未授权 | 无 | 1. 点击本地上传<br>2. 拒绝权限<br>3. 再次点击 | 显示可理解说明或再次请求；不无响应、不崩溃 | 不创建资源 | 提示截图 | manual |  | permission,android,denied |
| PERM-003 | 文件权限 | iOS 文件选择器取消后返回原表单 | ios | P1 | external | iOS 创作表单 | 无 | 1. 点击本地上传<br>2. 在系统选择器点击取消 | 返回原页面；输入和已选模式保持；不显示上传成功 | 不创建资源 | 系统选择器和返回页截图 | manual |  | permission,ios,file |
| PERM-004 | 麦克风 | iOS 首次录音权限允许后可录制 | ios | P0 | external | 麦克风权限未决定 | 10 秒哼唱 | 1. 点击录音<br>2. 允许权限<br>3. 开始并停止录音 | 录音状态和时长正常；可试听/应用 | 只在应用后创建当前用户资源 | 权限和录音截图 | manual |  | permission,ios,microphone |
| PERM-005 | 麦克风 | 永久拒绝麦克风后提供设置入口 | both | P1 | external | 麦克风已永久拒绝 | 无 | 1. 点击录音 | 显示权限被拒和系统设置入口；返回后页面仍可操作 | 不创建空音频 | 提示和设置页截图 | manual |  | permission,microphone,denied |
| PERM-006 | 下载保存 | 首次下载权限处理正确 | both | P1 | external | 下载权限未授权 | 可下载作品 | 1. 点击下载<br>2. 允许权限/选择保存位置 | 下载完成并提示保存位置；拒绝时有明确反馈 | 获取一次下载地址，不改变作品 | 系统权限和结果截图 | manual |  | permission,download |
| PERM-007 | 分享 | 系统分享取消后回到播放器 | both | P1 | external | 分享能力可用 | SUCCESS-WORK | 1. 点击分享<br>2. 在系统面板取消 | 回到原播放器；播放状态按当前规则保持；不显示成功误导 | 分享链接最多创建一次 | 分享面板和返回截图 | manual |  | permission,share |
| NET-001 | 网络异常 | 冷启动断网显示可恢复首页 | both | P0 | normal | 已同意隐私并有缓存 | 断网 | 1. 断开网络<br>2. 冷启动 App | App 不白屏/崩溃；静态首页和缓存内容可显示，远程区有错误/空态 | 无业务写入 | 断网页截图 | manual |  | network,startup |
| NET-002 | 网络异常 | 首页分区失败不影响创作入口 | both | P0 | normal | 首页配置/案例请求失败 | 无 | 1. 打开首页<br>2. 点击 AI写歌 | 首页远程区降级；创作入口仍可进入或明确提示网络问题 | 请求失败可追踪 | 首页和创作页截图 | assisted |  | network,home |
| NET-003 | 网络异常 | 作品刷新失败保留已有列表 | both | P1 | normal | 已加载作品后断网 | U-NORMAL | 1. 断网<br>2. 下拉刷新 | 旧列表保留；显示刷新失败；不闪成空态 | 无作品状态被覆盖 | 刷新失败截图 | manual |  | network,works |
| NET-004 | 网络异常 | 播放中断网后恢复或明确失败 | both | P0 | normal | 正在播放未完整缓存音频 | SUCCESS-WORK | 1. 断网<br>2. 继续播放/拖动<br>3. 恢复网络 | 已缓存部分按能力播放；需要网络时提示；恢复后可继续，不跳到别的歌 | 同一资源地址重试 | 中断和恢复截图 | manual |  | network,player |
| NET-005 | 网络异常 | 提交请求中断不产生重复任务 | both | P0 | paid | 测试环境，提交确认时断网 | 合法创作数据 | 1. 点击立即生成时断网<br>2. 恢复网络<br>3. 按页面提示重试 | 页面明确未知/失败；重试后最多一条任务，不重复扣分 | 幂等键收敛为一条任务和流水 | 提示、任务号、流水 | assisted |  | network,generation,idempotent |
| NET-006 | 网络异常 | 支付返回网络异常后订单可恢复 | both | P0 | paid | 沙箱支付已完成，App 返回时断网 | 测试订单 | 1. 付款完成后断网返回<br>2. 恢复网络<br>3. 刷新订单 | 不要求重复付款；最终显示服务端支付结果 | 回调/查询将订单收敛一次 | 订单前后截图 | assisted |  | network,payment |
| STATE-001 | 中断恢复 | 创作表单切后台保持输入 | both | P1 | normal | 创作页已输入多项 | 标题、歌词、标签 | 1. 切到后台<br>2. 返回 App | 当前表单、模式和选项保持；不自动清空或提交 | 无任务 | 前后台截图 | manual |  | state,create |
| STATE-002 | 中断恢复 | 播放时来电/音频焦点中断处理正确 | both | P1 | external | 正在播放 | 系统来电或其它音频 | 1. 触发音频中断<br>2. 结束中断 | 播放按平台规范暂停/恢复；不会并播或进度错乱 | 无业务写入 | 操作录像 | manual |  | state,audio-focus |
| STATE-003 | 中断恢复 | 生成完成事件不重复插入作品 | both | P0 | paid | 任务生成中且 App 前后台切换 | 当前任务 | 1. 切后台等待完成<br>2. 返回作品<br>3. 多次切 Tab | 作品只出现一次；状态为完成 | 同一 task/work 唯一 | 列表截图、作品号 | assisted |  | state,event,idempotent |
| RESOURCE-001 | 资源持久化 | 第三方临时音频过期后作品仍可播放 | both | P0 | normal | 已完成转存且 Provider 临时 URL 失效 | PERSISTED-WORK | 1. 在临时 URL 失效后打开作品<br>2. 点击播放 | 从平台地址正常播放；用户不感知第三方过期 | 作品保存自有持久 URL | 播放器截图、脱敏资源域名 | assisted |  | resource,persistence |
| RESOURCE-002 | 资源持久化 | 第三方临时封面过期后仍显示平台封面 | both | P1 | normal | 临时封面 URL 失效 | PERSISTED-WORK | 1. 清理本地缓存<br>2. 打开作品列表和播放器 | 封面仍可重新加载；不是永久占位 | 封面使用平台持久 URL | 列表和播放器截图 | assisted |  | resource,cover,persistence |
| RESOURCE-003 | 资源错误 | 平台音频失效时不永久加载 | both | P0 | normal | 准备持久资源失效样本 | BROKEN-WORK | 1. 打开作品<br>2. 点击播放<br>3. 点击重试 | 显示播放失败/重试；页面可返回；不影响其它歌曲 | 资源失败可追踪，不修改作品归属 | 提示截图、日志 | assisted |  | resource,error |
| RESOURCE-004 | 资源缓存 | 同曲封面更新后不继续显示旧缓存 | both | P1 | normal | 作品封面重做成功 | SUCCESS-WORK | 1. 记录旧封面<br>2. 完成封面重做<br>3. 返回列表并重新进入播放器 | 列表、详情和播放器显示同一新封面 | updatedAt/资源版本驱动缓存更新 | 前后截图 | assisted |  | resource,cache |
| CONFIG-001 | 后台配置联动 | 模型公开开关在移动端生效 | both | P0 | normal | 当前模型可见 | 启用/停用模型 | 1. 记录模型页<br>2. 后台关闭公开展示<br>3. 重新进入创作 | 关闭项不再展示；重新开启后恢复 | 公共模型接口按场景返回启用项 | 三阶段截图 | assisted |  | config,model |
| CONFIG-002 | 后台配置联动 | 模型价格修改只影响新任务 | both | P0 | paid | 一个旧任务已创建 | 价格 A 改为 B | 1. 记录旧任务价格<br>2. 后台改价<br>3. 新建任务并查看确认 | 新任务显示 B；旧任务/流水仍为 A | 任务价格快照不可被后改覆盖 | 旧任务和新确认截图 | assisted |  | config,price,snapshot |
| CONFIG-003 | 后台配置联动 | 模型公开名称和说明更新 | both | P1 | normal | 模型可见 | 新名称、徽标、长说明 | 1. 后台保存展示配置<br>2. 重新打开模型页 | 显示新公开信息；不显示内部密钥；布局正常 | 公开配置生效 | 前后模型页截图 | assisted |  | config,model,display |
| CONFIG-004 | 后台配置联动 | 默认模型变化用于下一次创作 | both | P0 | normal | 场景有两个启用模型 | 默认 A 改 B | 1. 后台修改默认<br>2. 退出并重新进入创作 | 新页面默认选择 B；当前已打开页面不被突然替换 | 新请求读取新默认，旧任务保持原快照 | 前后截图 | assisted |  | config,model,default |
| CONFIG-005 | 后台配置联动 | 翻唱音色停用后不可新选 | both | P0 | normal | 音色当前可见 | VOICE-A | 1. 后台停用 VOICE-A<br>2. 重新进入音色页 | VOICE-A 不显示；已有作品详情仍可显示历史音色名称 | 新列表不返回停用项，历史快照保留 | 音色页和历史作品截图 | assisted |  | config,voice |
| CONFIG-006 | 后台配置联动 | 商品价格和上下架在移动端生效 | both | P0 | paid | 商品当前可见 | 测试会员/积分商品 | 1. 后台改价或下架<br>2. 刷新购买页 | 新价格显示正确；下架商品不可购买；旧订单金额不变 | 新订单用新配置，旧订单保留快照 | 前后商品页、旧订单截图 | assisted |  | config,product |
| CONFIG-007 | 后台配置联动 | 任务和邀请规则修改后展示一致 | both | P1 | normal | 后台可编辑规则 | 测试规则文案和奖励 | 1. 后台发布规则<br>2. 刷新任务/邀请规则页 | 移动端展示新规则；已完成历史奖励不被追溯修改 | 新业务按新配置，历史流水保留 | 前后规则页截图 | assisted |  | config,task,invite |
| CONFIG-008 | App 隔离 | Admin 切换 App 后配置不串数据 | both | P0 | normal | Admin 有两个 App 权限 | catsinger/narrate 不同配置 | 1. 只修改 narrate 模型或首页<br>2. 刷新喵喵写歌 | 喵喵写歌模型、首页、商品和任务均不变化 | X-App-Code catsinger 路由对应 schema/config | 移动端前后截图、后台配置摘要 | assisted |  | config,app-isolation |
| CONFIG-009 | 权限隔离 | 受限管理员不能误改 catsinger 数据 | both | P1 | normal | A-LIMITED 无 catsinger 配置权限 | 受限管理员 | 1. 管理员尝试改其它 App 配置<br>2. 移动端刷新 | catsinger 移动端数据不受未授权操作影响 | 后台拒绝未授权 App/模块修改 | 移动端截图、后台拒绝截图 | assisted |  | config,admin-role |
| UI-001 | 屏幕适配 | 375x812 核心页面无重叠 | both | P0 | normal | 375x812 逻辑尺寸 | 首页、创作、作品、我的、播放器 | 1. 逐页打开核心页面<br>2. 滚动到底部 | 状态栏、安全区、底栏和固定按钮不遮挡；文字可读 | 无业务写入 | 全页面截图 | manual |  | ui,375x812 |
| UI-002 | 屏幕适配 | 390x844 核心页面可操作 | both | P1 | normal | 390x844 逻辑尺寸 | 核心页面 | 1. 逐页打开并操作底部按钮 | 页面稳定；长列表可到底；键盘弹起不遮挡提交 | 无业务写入 | 核心页截图 | manual |  | ui,390x844 |
| UI-003 | 屏幕适配 | 414x896 长内容不溢出 | both | P1 | normal | 414x896 逻辑尺寸 | 长歌词、长标题、长模型名 | 1. 打开相关页面<br>2. 滚动和输入 | 长内容换行/省略/滚动正确；按钮仍可点击 | 无业务写入 | 页面截图 | manual |  | ui,414x896 |
| UI-004 | 无障碍文字 | 系统大字体下核心操作可见 | both | P1 | normal | 系统字体调大 | 核心页面 | 1. 调大系统字体<br>2. 打开首页、创作、支付确认和设置 | 关键文案不裁掉业务含义；提交、取消和返回仍可操作 | 无业务写入 | 页面截图 | manual |  | ui,font-scale |

