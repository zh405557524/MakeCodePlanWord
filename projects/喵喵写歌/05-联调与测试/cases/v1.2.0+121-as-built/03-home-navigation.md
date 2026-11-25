# 03 主导航、首页与配置歌曲

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| NAV-001 | 主导航 | 当前底部导航仅显示三个 Tab | both | P0 | normal | 已进入首页 | 无 | 1. 查看底部导航 | 只显示首页、作品、我的；不出现旧探索或写歌 Tab | 无业务写入 | Android/iOS 底栏截图、UI XML | automated | main_navigation_labels | smoke,navigation |
| NAV-002 | 主导航 | 三个 Tab 可依次切换并返回首页 | android | P0 | normal | U-NORMAL 已登录 | U-NORMAL | 1. 点击作品<br>2. 点击我的<br>3. 点击首页 | 分别显示我的作品、我的页面和首页；无叠页或错乱 | 只读取对应数据 | 三个页面截图、UI XML | automated | main_navigation_switch | smoke,navigation |
| NAV-003 | 主导航 | 未登录点击作品触发登录门禁 | both | P0 | normal | 未登录 | U-FRESH | 1. 点击作品 | 当前 Tab 不泄露作品；进入登录页 | 无私有作品响应 | 登录页截图 | assisted |  | navigation,auth |
| NAV-004 | 主导航 | 重复点击当前首页刷新数据 | both | P1 | normal | 首页已加载 | 后台更新一条首页数据 | 1. 保持首页<br>2. 后台更新配置<br>3. 再次点击首页 | 首页重新加载并按缓存策略展示新配置；布局不闪退 | 重新读取 catsinger 首页配置 | 刷新前后截图 | assisted |  | navigation,refresh |
| NAV-005 | 主导航 | Android 返回键按页面层级退出 | android | P1 | normal | 从首页进入创作页 | 无 | 1. 在创作页按返回<br>2. 在首页按返回 | 第一次回首页；第二次按系统规则退出或后台化；不进入旧页面 | 无任务创建 | 两阶段截图 | manual |  | navigation,back |
| HOME-001 | 首页 | 首页核心结构显示正确 | both | P0 | normal | 首页配置可读取 | 默认配置 | 1. 冷启动并查看首页 | 显示品牌、宣传卡、AI写歌、改编歌曲、热门案例和三 Tab | 读取首页配置成功 | Android/iOS 首页截图、UI XML | automated | home_layout | smoke,home |
| HOME-002 | 首页 | AI 写歌入口进入专业模式 | both | P0 | normal | U-NORMAL 已登录 | 无 | 1. 点击“AI写歌” | 进入创作页并选中专业模式 | 读取专业场景公开模型和生成选项 | Android/iOS 创作页截图、UI XML | automated | home_ai_write_entry | smoke,home,create |
| HOME-003 | 首页 | 改编歌曲入口进入歌曲改编 | both | P0 | normal | U-NORMAL 已登录 | 无 | 1. 点击“改编歌曲” | 进入创作页并选中歌曲改编 | 读取改编场景公开模型 | Android/iOS 改编页截图、UI XML | automated | home_adapt_entry | smoke,home,cover |
| HOME-004 | 首页 | 未登录点击创作入口先登录 | both | P0 | normal | 未登录且已同意隐私 | U-FRESH | 1. 点击 AI写歌<br>2. 返回首页<br>3. 点击改编歌曲 | 两个入口均进入登录页，不显示可提交表单 | 无生成任务 | 两次登录页截图 | manual |  | home,auth |
| HOME-005 | 首页 | 热门案例正常显示和滚动 | both | P1 | normal | 后台配置多条案例 | 长短标题、不同封面 | 1. 向下滚动热门案例<br>2. 滚动到列表末尾 | 卡片封面和标题对应；可滚动；不重复、不越界 | 返回当前 App 启用案例 | 首尾截图 | manual |  | home,cases |
| HOME-006 | 首页 | 热门案例为空时首页仍可使用 | both | P1 | normal | 后台暂时无启用案例 | 空案例配置 | 1. 打开首页 | 品牌和两个创作入口正常；案例区域为空态或自然收起，不整页报错 | 案例列表为空 | 首页截图 | assisted |  | home,empty |
| HOME-007 | 首页 | 首页配置接口失败局部降级 | both | P1 | normal | 模拟首页配置读取失败 | 无 | 1. 打开首页<br>2. 尝试创作入口 | 首页不白屏；静态主入口仍可使用或给出明确重试 | 错误被记录且无业务写入 | 降级页截图、日志 | assisted |  | home,error |
| HOME-008 | 首页 | 配置歌曲点击后进入播放器 | both | P0 | normal | 后台配置一首可播放歌曲 | HOME-SONG-OK | 1. 点击首页歌曲卡片 | 打开配置歌曲播放器；标题、封面、时长和音频对应 | 只读取配置歌曲，不写用户作品 | 播放器截图 | assisted |  | home,configured-song |
| HOME-009 | 首页 | 配置歌曲资源缺失时提示可理解 | both | P1 | normal | 配置歌曲音频 URL 失效 | HOME-SONG-BROKEN | 1. 点击该歌曲<br>2. 点击播放 | 页面不崩溃；显示播放失败或重试状态；其他歌曲可继续打开 | 资源错误可追踪，不生成用户作品 | 错误提示截图 | assisted |  | home,resource-error |
| HOME-010 | 首页 | 首页长标题与长标签不破坏布局 | both | P2 | normal | 后台配置长标题和长标签 | 超长中文及 emoji | 1. 打开首页<br>2. 查看卡片和列表 | 文字按省略/换行显示；不遮挡封面、按钮和底栏 | 配置原文不被错误截断保存 | 页面截图 | manual |  | home,layout |
| HOME-011 | 首页 | 首页重复刷新不产生重复歌曲 | both | P1 | normal | 首页有多条配置歌曲 | 默认配置 | 1. 下拉或重复进入首页三次 | 同一歌曲不重复堆叠；列表顺序按后台配置 | 读取请求不写重复记录 | 刷新后截图 | manual |  | home,refresh |
| HOME-012 | 配置歌曲播放器 | 配置歌曲只展示允许的操作 | both | P1 | normal | 已打开配置歌曲 | HOME-SONG-OK | 1. 展开更多操作 | 不出现删除私人作品等不适用操作；分享/下载按当前轻实现反馈 | 不修改用户作品 | 操作菜单截图 | manual |  | player,configured-song |
| HOME-013 | 迷你播放器 | 首页播放后切 Tab 显示迷你播放器 | both | P0 | normal | 已播放一首可用歌曲 | HOME-SONG-OK | 1. 开始播放<br>2. 返回首页<br>3. 切到我的 | 迷你播放器显示当前歌曲和播放状态；底栏不被遮挡 | 无重复播放会话 | 首页和我的截图 | assisted |  | player,mini |
| HOME-014 | 迷你播放器 | 点击迷你播放器返回正确播放页 | both | P1 | normal | 迷你播放器已显示 | 当前播放歌曲 | 1. 点击迷你播放器 | 打开对应歌曲播放器；进度与迷你播放器一致 | 不重新创建播放资源 | 播放页截图 | manual |  | player,mini |
| HOME-015 | 首页 | 后台关闭歌曲后移动端不再展示 | both | P1 | normal | 先展示一首后台歌曲 | HOME-SONG-OK | 1. 记录当前首页<br>2. 后台停用该歌曲<br>3. 刷新首页 | 停用歌曲从首页消失；其他内容正常 | 新请求不返回停用项 | 配置前后截图 | assisted |  | home,admin-config |
| HOME-016 | 首页 | 切换其他 App 配置不污染 catsinger | both | P0 | normal | Admin 可切换 App | narrate 与 catsinger 各自首页配置 | 1. 后台只修改其他 App 首页数据<br>2. 刷新喵喵写歌首页 | 喵喵写歌内容不变化，不显示其他 App 数据 | 请求仍按 catsinger schema/config 读取 | 修改前后截图 | assisted |  | home,app-isolation |
