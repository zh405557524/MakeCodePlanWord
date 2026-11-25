# 07 作品、播放器、详情、后处理与专辑

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| WORK-001 | 我的作品 | 作品页当前结构显示正确 | both | P0 | normal | U-NORMAL 已登录 | 有作品账号 | 1. 点击底部作品 | 显示“我的作品”和“我的音乐”；不要求显示未开放的草稿/喜欢/专辑主 Tab | 返回当前用户作品列表 | Android/iOS 页面截图、UI XML | automated | works_layout | smoke,works |
| WORK-002 | 我的作品 | 空作品页提供开始创作入口 | both | P0 | normal | 当前用户无作品 | 空账号 | 1. 打开作品 | 显示无作品插图、提示和开始创作按钮；底栏无遮挡 | 返回空列表 | 空态截图 | manual |  | works,empty |
| WORK-003 | 我的作品 | 空态开始创作进入创作页 | both | P0 | normal | WORK-002 页面 | 无 | 1. 点击开始创作 | 进入当前创作页，不跳旧页面 | 读取创作配置 | 创作页截图 | manual |  | works,create-entry |
| WORK-004 | 我的作品 | 生成中作品可打开进度页 | android | P0 | normal | 用户有生成中作品 | GENERATING-WORK | 1. 刷新作品页<br>2. 点击生成中作品 | 打开对应任务进度并显示真实阶段 | 查询对应 generationTaskId | 列表和进度截图、UI XML | automated | open_generating_work | works,generating |
| WORK-005 | 我的作品 | 生成中作品进度自动更新 | both | P1 | normal | 作品页可见且有生成中项 | GENERATING-WORK | 1. 保持作品页可见<br>2. 等待任务状态变化 | 进度条和状态更新；完成后转为可播放项；不重复出现 | 周期刷新或事件刷新同一作品 | 状态变化截图 | assisted |  | works,auto-refresh |
| WORK-006 | 我的作品 | 离开作品页后停止无意义刷新 | both | P2 | normal | 有生成中作品 | GENERATING-WORK | 1. 打开作品<br>2. 切回首页<br>3. 等待一轮刷新周期<br>4. 返回作品 | 首页不被作品加载打扰；返回后恢复最新状态 | 不在不可见状态持续重复请求 | 前后截图、脱敏日志 | assisted |  | works,visibility |
| WORK-007 | 我的作品 | 失败作品显示失败状态 | both | P0 | normal | 用户有失败作品 | FAILED-WORK | 1. 打开作品 | 失败项显示失败文案而非播放按钮；可打开失败详情或更多操作 | 返回 FAILED 和失败阶段 | 失败项截图 | manual |  | works,failed |
| WORK-008 | 我的作品 | 完成作品显示标题封面和操作入口 | both | P0 | normal | 用户有完成作品 | SUCCESS-WORK | 1. 打开作品<br>2. 查看完成项 | 标题、封面/占位、歌手元信息和更多按钮显示正确 | 返回完成作品摘要 | 列表截图 | manual |  | works,success |
| WORK-009 | 我的作品 | 下拉刷新保留列表直到新数据到达 | both | P1 | normal | 已有作品列表 | U-NORMAL | 1. 下拉刷新 | 刷新过程中不闪成空态；完成后数据更新，顺序稳定 | 重新查询作品列表 | 刷新前后截图 | manual |  | works,refresh |
| WORK-010 | 我的作品 | 列表加载失败可重试 | both | P1 | normal | 模拟作品接口失败 | 无 | 1. 打开作品<br>2. 点击重试 | 显示作品加载失败和重试；恢复网络后列表加载成功 | 首次失败、重试成功 | 失败和成功截图 | assisted |  | works,error |
| WORK-011 | 我的作品 | 超长歌名不遮挡更多按钮 | both | P2 | normal | 有长标题作品 | 80 字标题 | 1. 查看作品列表 | 标题按省略显示；封面和更多按钮可点击；行高稳定 | 原标题详情仍完整 | 列表截图 | manual |  | works,layout |
| WORK-012 | 我的作品 | 不同作品类型资源均可打开 | both | P1 | normal | 原创、纯音乐、翻唱作品可用 | 三种作品 | 1. 依次点击三种作品 | 每首打开自己的播放器；纯音乐无伪歌词；翻唱有正确源关系 | 详情返回正确 songType 和资源 | 三个播放器截图 | manual |  | works,type |
| WORK-013 | 我的作品 | 切换账号后清除旧列表缓存 | both | P0 | normal | 两个账号作品不同 | U-NORMAL、U-OTHER | 1. 查看账号 A 作品<br>2. 退出并登录 B<br>3. 打开作品 | 不闪现或保留 A 的列表；只显示 B 数据 | 按用户隔离返回 | 两账号截图 | assisted |  | works,isolation |
| WORK-014 | 更多操作 | 更多弹层显示详情和删除 | both | P1 | normal | 完成作品存在 | SUCCESS-WORK | 1. 点击作品右侧更多 | 弹层显示查看详情、删除歌曲和关闭；背景页面不乱跳 | 无写入 | 弹层截图 | manual |  | works,more |
| DETAIL-001 | 作品详情 | 查看详情弹层首帧有内容 | both | P0 | normal | 完成作品存在 | SUCCESS-WORK | 1. 点击更多<br>2. 点击查看详情 | 弹层显示封面、标题、时长和加载后的信息；不出现真机空白 | 查询作品详情 | 首帧和完整弹层截图 | manual |  | detail,sheet |
| DETAIL-002 | 作品详情 | 详情展示 Prompt 和歌词 | both | P1 | normal | 作品含 Prompt 和歌词 | SUCCESS-WORK | 1. 打开详情<br>2. 向下滚动 | 创作 Prompt、歌词内容完整可读；空字段显示明确空文案 | 返回当前作品完整详情 | 内容截图 | manual |  | detail,content |
| DETAIL-003 | 作品详情 | 复制 Prompt 和歌词成功 | both | P1 | external | 详情有内容 | 测试 Prompt/歌词 | 1. 点击复制 Prompt<br>2. 粘贴到测试输入框<br>3. 点击复制歌词<br>4. 再粘贴 | 两次复制内容分别正确；有成功反馈 | 无业务写入 | 提示和粘贴内容截图 | manual |  | detail,copy |
| DETAIL-004 | 作品详情 | 详情弹层播放打开对应歌曲 | both | P0 | normal | 详情弹层已打开 | SUCCESS-WORK | 1. 点击详情顶部播放 | 先关闭弹层再打开播放器；没有被弹层退场带回列表 | 播放资源属于该作品 | 播放器截图 | manual |  | detail,player |
| DETAIL-005 | 作品详情 | 详情下载成功或给出明确失败 | both | P1 | external | 作品有下载资源 | SUCCESS-WORK | 1. 点击下载<br>2. 处理系统权限 | 显示获取地址和保存结果；无地址时明确提示；不永久加载 | 获取当前用户下载地址 | 结果提示和系统文件截图 | manual |  | detail,download |
| DETAIL-006 | 作品详情 | 分享轻实现反馈明确 | both | P1 | external | 作品可分享或未开放 | SUCCESS-WORK | 1. 点击分享 | 已开放时复制/拉起系统分享；未开放时明确提示“分享能力待开放”；点击有反馈 | 可能创建分享链接但不修改作品 | 结果截图 | manual |  | detail,share |
| DETAIL-007 | 作品详情 | 删除取消时保留作品 | both | P0 | delete | 完成作品存在 | DISPOSABLE-WORK | 1. 点击删除歌曲<br>2. 在确认框点击取消 | 弹层关闭或返回；作品仍在列表且可播放 | 作品未隐藏/删除 | 取消前后截图 | manual |  | detail,delete,cancel |
| DETAIL-008 | 作品详情 | 确认删除后作品不可再访问 | both | P0 | delete | 专用可删除作品 | DISPOSABLE-WORK | 1. 点击删除歌曲<br>2. 确认删除<br>3. 刷新作品 | 显示删除成功；列表移除；迷你播放器若为该曲则清理 | 作品隐藏/删除只执行一次，资源按生命周期处理 | 删除前后截图、作品号 | assisted |  | detail,delete |
| DETAIL-009 | 作品详情 | 重新生成显示当前模型价格 | both | P0 | paid | 可重新生成作品、积分充足 | SUCCESS-WORK | 1. 点击重新生成<br>2. 查看确认弹层 | 显示当前可用模型和实时价格；取消不改变旧作品 | 无新任务直至确认 | 确认页截图 | assisted |  | detail,regenerate,paid |
| DETAIL-010 | 作品详情 | 确认重新生成进入任务页 | both | P0 | paid | DETAIL-009 条件满足 | SUCCESS-WORK | 1. 点击立即生成 | 进入新任务进度；旧作品仍可追溯；成功后按当前规则更新/新增 | 新任务保存来源和模型快照，只扣一次 | 任务页、任务号、作品号 | assisted |  | detail,regenerate,paid |
| PLAYER-001 | 播放器 | 点击完成作品开始播放 | both | P0 | normal | 有可播放作品 | SUCCESS-WORK | 1. 点击作品 | 打开播放器并开始或准备播放；标题、封面、总时长正确 | 获取平台持久音频资源 | 播放器截图 | manual |  | player,play |
| PLAYER-002 | 播放器 | 播放暂停按钮只控制音频 | both | P0 | normal | 播放器已打开 | SUCCESS-WORK | 1. 点击暂停<br>2. 点击播放 | 图标和音频状态同步；不切换封面/歌词页 | 无业务写入 | 两种状态截图 | manual |  | player,pause |
| PLAYER-003 | 播放器 | 拖动进度条跳转到目标位置 | both | P1 | normal | 音频已加载 | 中长音频 | 1. 拖动到中间位置 | 当前时间跳转且继续按原播放状态运行；不越界 | 无业务写入 | 前后时间截图 | manual |  | player,seek |
| PLAYER-004 | 播放器 | 上一首下一首切换正确 | both | P1 | normal | 列表至少三首完成作品 | 三首作品 | 1. 点击下一首<br>2. 点击上一首 | 标题、封面、音频和歌词同时切换；不会混用前一首资源 | 查询对应作品详情 | 三个状态截图 | manual |  | player,queue |
| PLAYER-005 | 播放器 | 返回后继续通过迷你播放器控制 | both | P0 | normal | 正在播放 | SUCCESS-WORK | 1. 返回作品页<br>2. 点击迷你播放器暂停<br>3. 点击迷你播放器进入 | 迷你播放器状态同步；重新进入保持进度 | 不重新创建播放会话 | 作品页和播放器截图 | manual |  | player,mini |
| PLAYER-006 | 播放器 | 播放期间屏幕保持唤醒并在暂停后释放 | both | P1 | normal | 设备自动锁屏时间较短 | 可播放歌曲 | 1. 开始播放<br>2. 等待超过系统锁屏时间<br>3. 暂停播放<br>4. 再等待 | 播放期间不自动锁屏；暂停/离开后恢复系统策略 | 无业务写入 | 两阶段录像或照片 | manual |  | player,wakelock |
| PLAYER-007 | 歌词 | 静态歌词完整展示 | both | P1 | normal | 作品只有静态歌词 | STATIC-LYRICS-WORK | 1. 打开播放器<br>2. 切换/滑到歌词详情 | 歌词按段落可滚动；不伪造逐句高亮 | 返回歌词文本，无时间轴 | 歌词页截图 | manual |  | lyrics,static |
| PLAYER-008 | 歌词 | 时间轴歌词随播放逐句高亮 | both | P0 | normal | 作品有有效时间轴 | TIMELINE-WORK | 1. 开始播放<br>2. 观察多句切换 | 当前句按时间高亮并自动滚动；相邻句不同时高亮 | 返回时间轴与音频对应 | 多时点截图或录像 | manual |  | lyrics,timeline |
| PLAYER-009 | 歌词 | 用户拖动歌词时不被立即抢回 | both | P1 | normal | 时间轴歌词播放中 | TIMELINE-WORK | 1. 手动向上拖动歌词<br>2. 短暂停留 | 拖动过程中不强制跳回；恢复自动跟随符合当前交互 | 无业务写入 | 操作录像 | manual |  | lyrics,scroll |
| PLAYER-010 | 歌词 | 点击歌词行按当前能力跳转播放 | both | P1 | normal | 时间轴歌词可交互 | TIMELINE-WORK | 1. 点击后段歌词行 | 若支持点击跳转则时间和高亮同步；若仅浏览则不出现错误跳转 | 无重复播放会话 | 点击前后截图 | manual |  | lyrics,seek |
| PLAYER-011 | 后处理 | 重新生成歌词时间轴成功 | both | P0 | paid | 作品有歌词、缺失或需重做时间轴 | STATIC-LYRICS-WORK | 1. 打开更多<br>2. 点击重新生成歌词时间轴<br>3. 确认积分<br>4. 等待结果 | 显示提交/生成中；成功后切换为逐句时间轴；可离开等待 | 创建异步时间轴任务并按价格结算一次 | 多阶段截图、任务号、流水 | assisted |  | lyrics,timeline,paid |
| PLAYER-012 | 后处理 | 时间轴重做失败保留原歌词 | both | P1 | paid | 模拟时间轴任务失败 | STATIC-LYRICS-WORK | 1. 提交时间轴重做<br>2. 等待失败 | 显示失败且可重试；原静态歌词仍可查看 | 任务失败并退款/释放；旧歌词不覆盖 | 失败和歌词截图 | assisted |  | lyrics,timeline,error |
| PLAYER-013 | 后处理 | 无封面作品可重新生成封面 | both | P0 | paid | 作品无封面、积分充足 | NO-COVER-WORK | 1. 点击重新生成封面<br>2. 确认<br>3. 等待完成 | 显示封面生成中；成功后当前页和列表更新同一新封面 | 异步封面任务成功，资源持久化，积分结算一次 | 前后封面、任务号、流水 | assisted |  | cover-image,paid |
| PLAYER-014 | 后处理 | 已有封面时给出当前规则反馈 | both | P1 | normal | 作品已有封面 | SUCCESS-WORK | 1. 点击封面重做入口 | 按当前代码显示“当前歌曲已有封面”或明确允许重做；不无反馈 | 未允许时不创建封面任务 | 提示截图 | manual |  | cover-image,state |
| PLAYER-015 | 后处理 | 生成同款回填原作品参数 | both | P0 | normal | 可读取作品参数 | SUCCESS-WORK | 1. 点击生成同款 | 进入创作页并回填可复用的歌词/风格/场景/对象等；不会自动提交 | 尚未创建新任务 | 原详情与回填页截图 | manual |  | same-style,prefill |
| PLAYER-016 | 后处理 | 翻唱作品重新翻唱入口正确 | both | P0 | normal | 已完成翻唱作品 | COVER-WORK | 1. 打开作品详情<br>2. 点击重新翻唱 | 进入 AI 翻唱并带入源和现有设置；仍需用户确认 | 不立即创建任务 | 入口和回填页截图 | manual |  | cover,recover |
| ALBUM-001 | 专辑 | 作品详情可加入已有专辑 | both | P1 | normal | 用户有专辑和完成作品 | ALBUM-A、SUCCESS-WORK | 1. 打开完整作品详情<br>2. 点击加入专辑<br>3. 选择 ALBUM-A | 显示加入成功；进入专辑后可看到该歌曲 | 建立当前用户专辑歌曲关系且不重复 | 成功提示和专辑截图 | manual |  | album,add |
| ALBUM-002 | 专辑 | 可创建专辑后加入作品 | both | P1 | normal | 当前用户无可用专辑 | 专辑名 `AUTOTEST_专辑` | 1. 从加入专辑流程创建专辑<br>2. 输入名称<br>3. 确认 | 新专辑创建并包含目标作品；名称正确 | 创建专辑和成员关系 | 创建前后截图、专辑号 | manual |  | album,create |
| ALBUM-003 | 专辑 | 重复加入同一专辑不产生重复歌曲 | both | P1 | normal | 作品已在专辑中 | ALBUM-A | 1. 再次将同一作品加入 ALBUM-A | 显示已加入或幂等成功；专辑中只出现一次 | 唯一关系不重复 | 操作结果和专辑截图 | manual |  | album,idempotent |
| ALBUM-004 | 专辑 | 从专辑移出歌曲不删除原作品 | both | P1 | delete | 专辑中有歌曲 | ALBUM-A | 1. 打开专辑详情<br>2. 点击移出专辑<br>3. 确认 | 歌曲从专辑消失，但仍在我的作品并可播放 | 只删除专辑关系，不删除作品 | 专辑和作品页截图 | manual |  | album,remove |
