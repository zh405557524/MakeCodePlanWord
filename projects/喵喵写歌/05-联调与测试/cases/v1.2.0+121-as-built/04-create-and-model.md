# 04 简易写歌、专业写歌与模型选择

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CREATE-001 | 专业写歌 | 专业模式主要控件完整 | both | P0 | normal | U-NORMAL 已登录 | 后台有生成选项 | 1. 从首页点击 AI写歌 | 选中专业模式；显示歌曲名称、歌词、男声/女声、音乐风格、音乐场景、歌曲对象、音频参考、创作模型和生成歌曲 | 读取专业模式配置成功 | Android/iOS 页面截图、UI XML | automated | master_layout | smoke,create,professional |
| CREATE-002 | 创作导航 | 从创作页返回首页 | android | P1 | normal | 已进入专业模式 | 无 | 1. 点击返回 | 返回首页；没有提交任务；底部导航正常 | 无生成任务 | 返回后截图、UI XML | automated | master_back | create,back |
| CREATE-003 | 简易写歌 | 从专业模式切换简易模式 | both | P0 | normal | 已进入创作页 | 无 | 1. 点击“简易模式” | 模式高亮切换；显示输入灵感、随机灵感、人声和生成按钮；专业歌词表单不再显示 | 读取简易模式模型和灵感配置 | 简易页截图 | assisted |  | create,simple |
| CREATE-004 | 专业写歌 | 空歌词不能生成普通歌曲 | both | P0 | normal | 专业模式，纯音乐关闭 | 空标题和空歌词 | 1. 点击生成歌曲<br>2. 若出现本次创作模型弹层，保持默认选择并点击确认 | 停留专业模式并显示必填提示；可先完成本次模型选择，但不进入积分确认或生成页 | 无任务、无积分冻结 | Android/iOS 提示截图、UI XML | automated | master_empty_validation | smoke,create,validation |
| CREATE-005 | 模式切换 | 三种模式切换内容对应 | both | P0 | normal | 已进入创作页 | 无 | 1. 点击简易模式<br>2. 点击专业模式<br>3. 点击歌曲改编 | 每个模式高亮和表单正确；切换不叠加三套控件 | 分场景读取模型配置 | 三个模式截图 | manual |  | create,modes |
| CREATE-006 | 模式切换 | 切换模式后返回不提交 | both | P1 | normal | 已在三种模式间切换 | 测试输入 | 1. 在当前模式输入内容<br>2. 切换另一模式<br>3. 点击返回 | 返回首页；没有自动生成；重新进入时按当前产品状态初始化 | 无任务和积分流水 | 返回前后截图 | manual |  | create,state |
| SIMPLE-001 | 简易写歌 | 输入音乐灵感正常显示 | both | P0 | normal | 简易模式 | `夜晚海边的温柔流行歌` | 1. 点击输入框<br>2. 输入测试描述 | 文案完整显示；键盘不遮挡当前输入位置；可继续操作 | 尚未创建任务 | 输入后截图 | manual |  | simple,input |
| SIMPLE-002 | 简易写歌 | 空描述且非纯音乐时阻止提交 | both | P0 | normal | 简易模式，纯音乐关闭 | 空描述 | 1. 清空输入框<br>2. 点击生成歌曲 | 提示“请输入歌曲描述”；不进入确认页 | 无任务、无积分冻结 | 提示截图 | manual |  | simple,validation |
| SIMPLE-003 | 简易写歌 | 描述达到最大长度时安全限制 | both | P1 | normal | 简易模式 | 最大长度及多 1 字符 | 1. 粘贴最大长度文案<br>2. 再输入一个字符 | 输入不超过代码限制；页面不溢出；已有内容不丢失 | 提交时只收到允许长度 | 字数和输入截图 | manual |  | simple,boundary |
| SIMPLE-004 | 简易写歌 | 随机灵感标签可回填描述 | both | P1 | normal | 后台有灵感文案 | 多条灵感标签 | 1. 点击一个随机灵感标签 | 输入框被该灵感内容更新；场景上下文被清理 | 不创建任务 | 回填前后截图 | manual |  | simple,inspiration |
| SIMPLE-005 | 简易写歌 | 换一批灵感更新标签且防重复点击 | both | P1 | normal | 简易模式 | 后台多条灵感 | 1. 点击换一批<br>2. 加载中连续点击 | 显示加载态；完成后标签组更新；不会叠加请求或卡死 | 灵感配置只读请求完成 | 加载和完成截图 | manual |  | simple,inspiration |
| SIMPLE-006 | 简易写歌 | 灵感配置为空时使用可理解降级 | both | P1 | normal | 后台灵感数组为空或非法 | 空配置 | 1. 打开简易模式<br>2. 点击换一批 | 页面不崩溃；展示内置标签、空态或明确提示 | 配置解析失败被记录，不写业务数据 | 降级页截图 | assisted |  | simple,fallback |
| SIMPLE-007 | 简易写歌 | 男声和女声可单选 | both | P1 | normal | 简易模式 | 男声、女声 | 1. 点击女声<br>2. 点击男声 | 每次仅一个选项选中；提交值随最后选择变化 | 最终任务快照保存最后选项 | 两次选中截图 | manual |  | simple,vocal |
| SIMPLE-008 | 简易写歌 | 打开纯音乐后允许空描述提交 | both | P0 | paid | U-NORMAL 积分充足，后台允许纯音乐 | 空描述 | 1. 打开纯音乐<br>2. 点击生成歌曲<br>3. 检查确认页 | 可进入积分确认；生成类型和积分价格正确 | 待确认前不冻结；确认后任务标记纯音乐 | 确认页截图、任务号 | assisted |  | simple,instrumental,paid |
| SIMPLE-009 | 简易写歌 | 后台关闭纯音乐能力时不展示开关 | both | P1 | normal | 后台禁用纯音乐 | 无 | 1. 重新进入简易模式 | 页面不显示不可用开关；布局自然收起 | 读取最新生成选项 | 页面截图 | assisted |  | simple,admin-config |
| SIMPLE-010 | 简易写歌 | 场景上下文卡可退出为普通灵感 | both | P1 | normal | 通过场景意图进入简易页 | 四步场景答案 | 1. 查看场景标签<br>2. 点击移除/切换普通灵感 | 场景标签消失；描述保留或按当前提示处理；提交模式恢复 simple | 后续任务不携带旧 sceneCode/answers | 操作前后截图 | manual |  | simple,scenario-state |
| PROFESSIONAL-001 | 专业写歌 | 歌曲名称正常输入 | both | P1 | normal | 专业模式 | `AUTOTEST_专业歌` | 1. 点击歌曲名称<br>2. 输入名称 | 名称显示完整；字数状态正确；键盘不遮挡 | 尚未创建任务 | 输入截图 | manual |  | professional,title |
| PROFESSIONAL-002 | 专业写歌 | 歌曲名称长度边界正确 | both | P1 | normal | 专业模式 | 50 字和 51 字标题 | 1. 输入 50 字标题<br>2. 再输入 1 字 | 输入按代码上限处理；页面无溢出 | 任务标题不超过上限 | 标题截图 | manual |  | professional,boundary |
| PROFESSIONAL-003 | 专业写歌 | 歌词输入和滚动正常 | both | P0 | normal | 专业模式 | 含主歌、副歌和换行歌词 | 1. 输入多段歌词<br>2. 滚动页面<br>3. 回到歌词区 | 换行保留；滚动后文本不丢失；输入区域可继续编辑 | 尚未创建任务 | 歌词区截图 | manual |  | professional,lyrics |
| PROFESSIONAL-004 | 专业写歌 | 打开歌词编辑页并保存返回 | both | P1 | normal | 专业模式已有歌词 | 测试歌词 | 1. 点击歌词编辑入口<br>2. 修改歌词<br>3. 确认返回 | 返回专业页后显示修改后的歌词；未提交任务 | 无生成任务 | 编辑前后截图 | manual |  | professional,lyrics-editor |
| PROFESSIONAL-005 | AI 帮写 | AI 润色歌词成功回填 | both | P0 | paid | 测试环境文本模型可用 | 合法歌词和主题 | 1. 输入歌词或描述<br>2. 点击润色歌词<br>3. 等待结果 | 显示处理中；结果返回后歌词更新；用户可继续编辑 | 文本模型调用有审计；歌曲任务尚未创建 | 处理中和结果截图 | assisted |  | lyrics,assist,paid |
| PROFESSIONAL-006 | AI 帮写 | AI 润色期间防重复提交 | both | P1 | paid | AI 润色请求进行中 | 测试歌词 | 1. 连续点击润色歌词 | 按钮保持加载；只处理一次；页面不叠加弹层 | 只生成一次文本模型调用 | 加载态截图、调用记录 | manual |  | lyrics,assist,idempotent |
| PROFESSIONAL-007 | AI 帮写 | AI 润色失败保留原歌词 | both | P1 | paid | 模拟文本模型失败 | 原歌词 | 1. 点击润色歌词<br>2. 等待失败提示 | 原歌词不被清空；显示明确错误并允许重试 | 调用失败可追踪，不创建歌曲任务 | 失败提示和原文截图 | assisted |  | lyrics,assist,error |
| PROFESSIONAL-008 | AI 帮写 | AI 润色时切后台再返回 | both | P1 | paid | 润色已开始 | 测试歌词 | 1. 点击润色歌词<br>2. 切到后台<br>3. 返回 App | 页面不重复提交；完成后显示结果，失败则可重试；屏幕常亮策略不影响恢复 | 只有一个调用记录 | 前后台截图 | manual |  | lyrics,assist,lifecycle |
| PROFESSIONAL-009 | 专业写歌 | 男声女声按单选提交 | both | P1 | normal | 专业模式 | 男声、女声 | 1. 依次选择两种人声 | 选中态互斥；最后选择用于确认页 | 任务快照保存最后选择 | 选中态截图 | manual |  | professional,vocal |
| PROFESSIONAL-010 | 专业写歌 | 音乐风格多选和取消正确 | both | P1 | normal | 后台有风格选项 | 流行、民谣 | 1. 打开音乐风格<br>2. 选择两个标签<br>3. 取消其中一个<br>4. 确认 | 页面只显示最终已选标签；顺序稳定 | 任务只携带最终标签 | 选择页和结果截图 | manual |  | professional,style |
| PROFESSIONAL-011 | 专业写歌 | 音乐场景选择正确 | both | P1 | normal | 后台有场景选项 | 夜晚、旅行 | 1. 打开音乐场景<br>2. 选择场景<br>3. 确认 | 专业页显示所选场景；可再次修改 | 任务快照保存场景标签 | 选择结果截图 | manual |  | professional,scene |
| PROFESSIONAL-012 | 专业写歌 | 歌曲对象选择正确 | both | P1 | normal | 后台有对象选项 | 恋人、朋友 | 1. 打开歌曲对象<br>2. 选择对象<br>3. 确认 | 专业页显示最终对象 | 任务快照保存对象标签 | 选择结果截图 | manual |  | professional,target |
| PROFESSIONAL-013 | 专业写歌 | 语言和时长使用后台选项 | both | P1 | normal | 后台配置多语言和时长 | 中文、英文、短/长 | 1. 选择语言<br>2. 选择时长 | 页面显示公开选项；无后台未启用项 | 任务快照保存选项代码 | 页面截图、任务摘要 | manual |  | professional,options |
| PROFESSIONAL-014 | 专业写歌 | 纯音乐开启后歌词不再必填 | both | P0 | paid | 后台允许纯音乐，积分充足 | 空歌词 | 1. 开启纯音乐<br>2. 点击生成歌曲 | 可进入确认页；页面明确纯音乐状态 | 任务标记 instrumental，歌词为空可接受 | 确认页截图 | assisted |  | professional,instrumental,paid |
| AUDIOREF-001 | 参考音频 | 从作品库选择参考音频 | both | P1 | normal | U-NORMAL 有完成作品 | 原创作品一首 | 1. 点击音频参考<br>2. 选择作品库<br>3. 选择歌曲 | 返回专业页并显示歌曲摘要；可试听/移除 | 只保存所属用户作品引用 | 选择前后截图 | manual |  | audio,reference,works |
| AUDIOREF-002 | 参考音频 | 本地选择合法参考音频 | both | P0 | external | 已授予文件权限 | 小于 50MB、5 分钟内音频 | 1. 点击音频参考<br>2. 选择本地文件<br>3. 选择合法音频<br>4. 确认截取 | 显示上传/处理状态；成功后显示文件摘要 | 创建当前用户临时音频资源，未提交前不生成歌曲 | 系统选择器和成功页截图 | manual |  | audio,reference,local |
| AUDIOREF-003 | 参考音频 | 参考音频超过 50MB 被拒绝 | both | P1 | external | 文件可读取 | 50MB 以上音频 | 1. 从本地选择超限文件 | 页面明确提示大小限制；不显示上传成功 | 不创建可用资源 | 提示截图 | manual |  | audio,reference,size |
| AUDIOREF-004 | 参考音频 | 参考音频超过当前时长限制被拒绝 | both | P1 | external | 文件可读取 | 5 分01秒音频 | 1. 选择超时长音频 | 明确提示时长不符合；可重新选择 | 不创建可提交资源 | 提示截图 | manual |  | audio,reference,duration |
| AUDIOREF-005 | 参考音频 | 参考音频截取预览和确认 | both | P1 | external | 选择了可截取长音频 | 合法音频 | 1. 调整截取区间<br>2. 点击播放截取预览<br>3. 点击确认截取 | 预览只播放选择区间；确认后摘要显示截取范围 | 保存处理后的参考资源和时长 | 截取页截图 | manual |  | audio,trim |
| AUDIOREF-006 | 参考音频 | 录音权限允许后可录制参考 | both | P1 | external | 麦克风可用 | 哼唱 10 秒 | 1. 选择录音<br>2. 允许权限<br>3. 开始录制<br>4. 停止并应用 | 显示录制时长；可试听；应用后回到专业页 | 上传录音资源归属当前用户 | 权限、录制、应用截图 | manual |  | audio,record,permission |
| AUDIOREF-007 | 参考音频 | 拒绝录音权限后可恢复 | both | P1 | external | 麦克风权限未授权 | 无 | 1. 选择录音<br>2. 拒绝权限<br>3. 再次点击录音 | 显示权限说明或设置入口；页面不假装录音成功 | 不创建音频资源 | 提示截图 | manual |  | audio,record,denied |
| AUDIOREF-008 | 专业写歌 | 从作品库添加参考音频后完整生成 | both | P0 | paid | U-NORMAL 已登录、积分充足，有本人完成作品 | `AUTOTEST_REF_WORK_{run_id}`、合法歌词、本人完成作品 | 1. 进入专业模式<br>2. 输入歌名和歌词<br>3. 点击音频参考并从作品库选择一首完成作品<br>4. 确认摘要和可试听状态<br>5. 点击生成歌曲并确认积分<br>6. 等待生成终态<br>7. 打开最终作品播放 | 参考音频摘要不丢失；确认页价格与模型一致；只创建一条任务；作品最终成功且可播放 | 任务快照包含参考作品/资源 ID，归属当前用户；积分只结算一次；成品资源持久化 | 选择前后、积分确认、生成进度、作品播放器截图，任务号、作品号 | assisted |  | professional,audio,reference,works,paid,closed-loop |
| AUDIOREF-009 | 专业写歌 | 本地参考音频上传处理后完整生成 | both | P0 | paid | U-NORMAL 已登录、积分充足，系统媒体权限可用 | `AUTOTEST_REF_LOCAL_{run_id}`、合法歌词、MP3 小于 50MB 且在时长上限内 | 1. 进入专业模式并输入歌名和歌词<br>2. 点击音频参考并选择本地音频<br>3. 确认截取区间并等待上传/处理成功<br>4. 试听参考片段<br>5. 点击生成歌曲并确认积分<br>6. 等待生成完成并打开播放器 | 处理前不允许误提交；成功后显示文件名/时长/截取摘要；付费生成成功并可播放 | 临时音频资源归属当前用户；任务提交携带最终参考资源 ID 和截取信息；成品资源持久化 | 系统选择器、截取、上传成功、确认页、播放器截图，任务号、资源 ID | assisted |  | professional,audio,reference,local,paid,closed-loop |
| AUDIOREF-010 | 专业写歌 | 删除或更换参考音频后只提交最终选择 | both | P1 | paid | 专业模式已添加参考音频，积分充足 | 参考音频 A/B、合法歌词 | 1. 添加参考音频 A<br>2. 删除 A 并确认恢复未选状态<br>3. 添加参考音频 B<br>4. 提交并确认积分<br>5. 查看任务结果 | A 删除后不残留摘要或试听；B 显示正确；生成只使用 B；页面其他输入不丢失 | 任务快照不包含 A，只包含 B；删除未提交的临时资源按生命周期回收 | A 删除后、B 选择后、确认页和任务快照证据 | manual |  | professional,audio,reference,replace,paid |
| AUDIOREF-011 | 专业写歌 | 参考音频上传失败可重试且保留表单 | both | P1 | external | 专业模式已填写歌名、歌词和选项 | 损坏音频或可控上传失败，合法重试音频 | 1. 选择失败样本<br>2. 等待失败提示<br>3. 确认歌名、歌词和选项未丢失<br>4. 重新选择合法音频<br>5. 等待成功 | 失败原因可理解且不允许带失败资源提交；主表单不被清空；重试后可恢复 | 失败资源不成为可提交 assetId；重试只使用新资源 | 失败提示、表单保留、重试成功截图和网络日志 | manual |  | professional,audio,reference,error,retry |
| AUDIOREF-012 | 专业写歌 | 带参考音频的作品生成同款正确回填 | both | P1 | normal | AUDIOREF-008 或 AUDIOREF-009 已完成 | 带参考音频的完成作品 | 1. 打开最终作品播放器<br>2. 点击生成同款<br>3. 查看专业模式回填内容<br>4. 不提交并返回 | 歌名/歌词/创作选项按当前规则回填；当原参考资源仍有效且当前用户可访问时回填摘要，失效时安静降级为未选 | 只读加载原作品创作快照；未点击生成不创建任务 | 原作品和回填页截图，有效/失效资源日志 | manual |  | professional,audio,reference,same-song,regression |
| MODEL-001 | 模型选择 | 当前默认模型与价格正确显示 | both | P0 | normal | 当前场景至少两个公开模型 | 后台默认模型 | 1. 打开任一创作模式<br>2. 查看创作模型行 | 显示后台公开名称和默认模型；价格在选择页/确认页一致 | 读取当前场景模型映射和价格 | 模型行和选择页截图 | assisted |  | model,default,price |
| MODEL-002 | 模型选择 | 打开模型选择页显示公开信息 | both | P0 | normal | 模型目录非空 | 两个启用模型 | 1. 点击创作模型 | 底部页显示名称、积分/次、说明、徽标和当前选中态；不泄露密钥 | 只返回公开模型信息 | 模型页截图 | manual |  | model,sheet |
| MODEL-003 | 模型选择 | 取消模型选择不改变当前值 | both | P1 | normal | 模型页已打开 | 选择非默认模型 | 1. 点击另一模型<br>2. 点击取消或遮罩 | 返回创作页后仍是原模型 | 不修改持久配置或任务 | 取消前后截图 | manual |  | model,cancel |
| MODEL-004 | 模型选择 | 确认模型只影响本次任务 | both | P0 | normal | 模型页已打开 | 非默认模型 | 1. 选择另一模型<br>2. 点击确认<br>3. 查看创作页<br>4. 退出并重新进入创作 | 本次页面显示已选模型；重新进入恢复后台默认 | 仅任务提交携带该 optionId，不改后台默认 | 确认和重进截图 | manual |  | model,confirm,scope |
| MODEL-005 | 模型选择 | 后台停用模型后移动端不展示 | both | P0 | normal | 后台有停用模型 | 停用项 | 1. 刷新或重新进入创作<br>2. 打开模型页 | 停用模型不可选；默认自动落到首个有效项 | 公共接口不返回停用项 | 配置前后截图 | assisted |  | model,disabled |
| MODEL-006 | 模型选择 | 模型目录为空时隐藏入口并阻止错误提交 | both | P0 | normal | 当前场景无公开模型 | 空映射 | 1. 打开创作模式<br>2. 尝试生成 | 创作模型行按代码规则隐藏；提交时给出配置不可用提示，不使用伪造模型 | 不创建无模型快照的任务 | 页面和提示截图 | assisted |  | model,empty |
| MODEL-007 | 模型选择 | 超长模型名称不遮挡确认按钮 | both | P2 | normal | 后台配置长公开名称 | 40 字名称和长说明 | 1. 打开模型页<br>2. 滚动列表 | 文案换行或省略；价格、选中态、确认和取消可操作 | 完整公开名称仍可追踪 | 模型页截图 | manual |  | model,layout |
| MODEL-008 | 模型选择 | 三种创作场景模型互相隔离 | both | P0 | normal | 三场景配置不同模型 | 简易、专业、改编映射 | 1. 分别进入三种模式<br>2. 打开模型页 | 每个模式只显示对应场景公开模型；切换不沿用不适用 optionId | 分别读取固定 sceneCode 映射 | 三个模型页截图 | assisted |  | model,scene,isolation |
