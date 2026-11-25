# 06 生成确认、积分、进度与恢复

| ID | 模块 | 标题 | 平台 | 优先级 | 风险 | 前置条件 | 测试数据 | 测试步骤 | 预期结果 | 后端观察 | 证据 | 自动化 | Handler | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| GEN-001 | 生成确认 | 取消积分确认不创建任务 | both | P0 | paid | 创作表单完整 | 任一非默认模型 | 1. 点击生成歌曲<br>2. 查看积分价格<br>3. 点击取消 | 返回原表单且输入保留；没有进度页和扣分 | 无任务、无冻结流水 | 确认页和返回页截图 | assisted |  | generation,cancel,paid |
| GEN-002 | 生成确认 | 确认价格与模型选择一致 | both | P0 | paid | 后台模型价格不同 | 模型 A、模型 B | 1. 选择模型 B<br>2. 点击生成歌曲 | 确认页显示模型 B 的公开名称和实时积分价格，不显示模型 A 价格 | 读取并快照选中 optionId 的价格 | 模型页与确认页截图 | assisted |  | generation,model,price |
| FLOW-CREATE-001 | 生成闭环 | Android 专业写歌润色后完整生成闭环 | android | P0 | paid | 测试环境、U-NORMAL 积分充足、歌词润色与歌曲 Provider 可用 | `AUTOTEST_{run_id}` 和合法歌词 | 1. 从首页进入 AI写歌的专业模式<br>2. 填写歌名和原始歌词<br>3. 点击润色歌词<br>4. 等待润色歌词回填并保存证据<br>5. 选择男声<br>6. 点击生成歌曲<br>7. 点击立即生成<br>8. 等待作品终态 | 润色歌词替换原始歌词；进入生成页；作品最终成功并可在作品列表找到；未开启删除时保留 | 提交后再登录辅助 API 核验；创建一条任务、一次积分结算和一条作品；资源地址持久化 | 润色、提交、完成截图、UI XML、任务号、作品号 | automated | create_song_closed_loop | generation,paid,polish,closed-loop |
| GEN-003 | 积分 | 生成前只冻结一次积分 | both | P0 | paid | U-NORMAL，表单完整 | 当前模型价格 | 1. 记录余额<br>2. 确认生成<br>3. 立即查看积分明细 | 余额/明细按冻结展示；快速操作不会出现多笔同额冻结 | 同一幂等键只有一条冻结记录 | 前后余额、流水、任务号 | assisted |  | generation,points,freeze |
| GEN-004 | 积分 | 生成成功后确认扣减 | both | P0 | paid | 任务最终成功 | GEN-003 任务 | 1. 等待生成成功<br>2. 查看积分明细 | 余额最终减少当前价格；流水显示明确业务说明 | 冻结转确认，不额外再扣一次 | 完成页、余额和流水 | assisted |  | generation,points,settle |
| GEN-005 | 积分 | 生成失败后退款 | both | P0 | paid | 测试环境模拟生成失败 | 任一模式 | 1. 记录余额<br>2. 提交生成<br>3. 等待失败<br>4. 查看余额和明细 | 失败原因可见；余额恢复；退款/释放说明明确 | 冻结释放或退款且只发生一次 | 失败页、前后余额、流水 | assisted |  | generation,points,refund |
| GEN-006 | 积分 | 积分不足时进入充值引导 | both | P0 | paid | U-LOW | 价格高于余额的模型 | 1. 填写合法表单<br>2. 点击生成<br>3. 确认 | 显示积分不足；可进入积分充值；不显示生成中 | 无任务和积分流水 | 提示和充值入口截图 | assisted |  | generation,points,insufficient |
| GEN-007 | 幂等 | 确认按钮连点不重复创建任务 | both | P0 | paid | 确认弹层已显示 | 合法请求 | 1. 快速连续点击立即生成 | 只进入一个进度页；不会出现重复作品 | 同一 idempotencyKey 一条任务、一次冻结 | 页面录像、任务号、流水 | assisted |  | generation,idempotent |
| GEN-008 | 生成进度 | 六阶段进度页面结构正确 | both | P0 | paid | 已创建任务 | 正常生成任务 | 1. 查看生成页<br>2. 等待阶段变化 | 显示准备创作、生成歌词、生成音频、生成歌名、生成海报、保存作品；当前阶段和百分比合理 | 查询同一任务返回阶段、进度和剩余说明 | 多阶段截图、任务号 | assisted |  | generation,progress |
| GEN-009 | 生成进度 | 服务端未完成时不显示 100% 成功 | both | P1 | paid | 任务仍在运行 | 慢任务 | 1. 等待本地动画接近完成 | 进度最多保持等待状态；不提前跳播放器或伪报成功 | 任务非终态时不返回成功作品 | 99%/等待截图 | manual |  | generation,progress,state |
| GEN-010 | 生成进度 | 退出生成页不取消任务 | both | P0 | paid | 任务生成中 | 任一任务 | 1. 点击返回或退出等待<br>2. 打开作品 | 生成中作品仍在并继续更新；没有取消提示误导 | 任务继续执行，无退款 | 退出前后截图、任务号 | assisted |  | generation,background |
| GEN-011 | 生成进度 | 重新进入生成中作品恢复正确阶段 | both | P0 | paid | 作品列表有生成中项 | GENERATING-WORK | 1. 打开作品<br>2. 点击生成中作品 | 打开对应任务进度；阶段和百分比来自当前任务，不从零伪重播 | 查询正确 generationTaskId | 列表和进度页截图 | assisted |  | generation,recovery |
| GEN-012 | 生成进度 | App 进程重启后任务可恢复 | both | P0 | paid | 任务生成中 | 当前任务号 | 1. 强制终止 App<br>2. 重新启动<br>3. 登录并打开作品<br>4. 打开任务 | 任务仍存在；显示当前真实状态；不重复创建 | 原任务继续，幂等键不变 | 重启前后截图、任务号 | manual |  | generation,restart |
| GEN-013 | 生成失败 | Provider 失败显示可读原因和重试路径 | both | P0 | paid | 测试环境可注入 Provider 失败 | 合法请求 | 1. 提交生成<br>2. 等待失败 | 页面显示失败而非永久加载；可返回或重新生成 | 任务 FAILED，失败代码可追踪，积分退款 | 失败页、任务号 | assisted |  | generation,provider,error |
| GEN-014 | 生成失败 | 内容审核拒绝时不生成作品 | both | P0 | paid | 测试环境审核启用 | 明确违规测试词 | 1. 在输入中填写审核测试词<br>2. 提交生成 | 显示内容不符合规范；不进入正常生成或不产出可播放作品 | 审核记录可追踪；不调用音乐 Provider；积分不扣或退回 | 提示截图、脱敏审核编号 | assisted |  | generation,moderation |
| GEN-015 | 生成失败 | 配置模型不可用时提示明确 | both | P0 | paid | 选择后后台关闭该模型 | 已失效 optionId | 1. 保持创作页<br>2. 后台停用模型<br>3. 点击生成 | 提示模型不可用并要求重新选择；不使用其它模型静默替换 | 不创建错误模型任务 | 提示和模型页截图 | assisted |  | generation,model,stale |
| GEN-016 | 生成恢复 | 网络中断后恢复轮询 | both | P1 | paid | 任务生成中 | 当前任务 | 1. 断开网络<br>2. 等待错误反馈<br>3. 恢复网络<br>4. 点击重试或等待恢复 | 页面不退出任务；恢复后继续显示真实阶段和结果 | 同一任务继续，不重复执行 | 断网和恢复截图 | manual |  | generation,network |
| GEN-017 | 生成完成 | 完成后进入对应播放器 | both | P0 | normal | 任务生成成功 | SUCCESS-WORK | 1. 在完成页点击查看作品 | 打开该作品播放器；标题、封面、音频和歌词对应 | 查询新作品详情成功 | 完成页和播放器截图 | assisted |  | generation,success,player |
| GEN-018 | 生成完成 | 新作品及时出现在我的作品 | both | P0 | normal | 刚生成成功 | SUCCESS-WORK | 1. 返回主页面<br>2. 打开作品 | 新作品出现在列表合适位置；无需杀进程才看见 | 作品列表返回新记录 | 列表截图、作品号 | assisted |  | generation,works,refresh |
| GEN-019 | 生成完成 | 生成后模型恢复默认供下一次选择 | both | P1 | normal | 上一次使用非默认模型并成功提交 | 模型 B | 1. 完成或提交上一任务<br>2. 返回首页<br>3. 重新进入同一创作模式 | 新任务默认回到后台默认模型，不永久沿用模型 B | 只保留上一任务模型快照 | 新旧任务模型页截图 | manual |  | generation,model,reset |
| GEN-020 | 数据隔离 | 其他用户不能打开当前生成任务 | both | P0 | normal | 两个账号可切换 | 账号 A 任务号 | 1. 账号 A 创建任务并记录<br>2. 切换账号 B<br>3. 从 B 的作品页查看 | B 不显示 A 的任务；无法通过残留页面进入 A 的进度 | 任务查询按 userId 和 catsinger 拒绝 | 两账号页面、脱敏日志 | assisted |  | generation,isolation |
