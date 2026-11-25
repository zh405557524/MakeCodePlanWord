# 接口、数据一致性与安全测试用例

> 代码依据：Flutter `lib/apis/song.dart`、`lib/services/http.dart`，Java catsinger controller/service/provider/schema routing 与现有集成测试。

| 用例 ID | 模块 | 标题 | 优先级 | 前置条件 | 测试步骤 | 预期结果 | 测试数据/备注 |
|---------|------|------|--------|----------|----------|----------|---------------|
| API-HEADER-001 | 请求头 | Flutter 请求统一带 catsinger appCode | P0 | 抓包代理 | 执行登录、配置、写歌、作品、支付请求 | 除明确排除项外均带 `X-App-Code: catsinger`；受保护请求带 Bearer Token | `AppConstants.appCode=catsinger` |
| API-AUTH-001 | 鉴权 | Token appCode 与请求头不一致被拒绝 | P0 | 获取 narrate Token | 使用 narrate Token + catsinger 头访问作品 | 返回401/403；不切换 schema 读取数据；有安全审计日志 | - |
| API-AUTH-002 | 越权 | 跨用户作品和专辑操作被拒绝 | P0 | U-NORMAL/U-OTHER | 用 U-NORMAL 请求 U-OTHER 详情、下载、删除、收藏、加专辑、翻唱源 | 全部拒绝且不泄露资源 URL；对方数据不变 | - |
| API-SCHEMA-001 | Schema | catsinger 只创建公共表和歌曲专属表 | P0 | 干净数据库执行 Flyway | 查询 catsinger/narrate schema 表 | catsinger 有 common + catsinger_song_*，无 narrate_*/home_case_*；narrate 反向成立 | 回归 V1/V12 重写 |
| API-SCHEMA-002 | Schema | 两 App 同 ID 数据互不污染 | P0 | 两 schema 建同手机号/同业务ID测试数据 | 分别带两种 appCode 查询和修改 | 只命中目标 schema；一侧修改不影响另一侧 | - |
| API-CONFIG-001 | 配置 | 模型、场景、首页和灵感契约可被 Flutter 解析 | P0 | Admin 已配置完整/缺字段数据 | 请求所有 song-config 接口 | 字段命名与 Flutter model 一致；可选字段缺失安全降级；非法核心字段返回校验错误 | - |
| API-GEN-001 | 写歌 | 三种写歌请求映射正确 | P0 | Mock Provider | 分别提交 simple/custom/scenario | Provider/model/prompt/lyrics/style/instrumental/scene/reference 字段正确；任务状态机启动 | - |
| API-GEN-002 | 写歌 | 同一幂等键只创建一次 | P0 | 同用户同 payload | 并发提交同 idempotencyKey 5 次 | 返回同一任务或幂等结果；只冻结/扣减一次；无重复作品 | - |
| API-POINTS-001 | 积分 | 创建前冻结、成功后确认扣减 | P0 | 余额1000，价格100 | 创建并成功完成歌曲 | 可用余额先减少/冻结100；成功后转正式扣减；总账、账户和任务一致 | - |
| API-POINTS-002 | 积分 | Provider 失败全额退款 | P0 | 余额1000，Mock失败 | 创建任务并等待失败 | 冻结100释放；最终余额恢复1000；退款流水只一条；重复回调不重复退 | - |
| API-POINTS-003 | 积分 | 余额不足并发请求不能透支 | P0 | 余额100，仅够1次 | 并发两个100积分任务 | 最多一个成功冻结；另一个返回积分不足；余额不为负 | - |
| API-COVER-001 | 翻唱 | `/api/song-covers` 强制 mode=cover | P0 | 登录用户 | 请求体故意传 mode=simple | 后端仍按 cover 创建并校验翻唱字段；不会调用普通写歌 Provider 路径 | 已有集成测试 |
| API-COVER-002 | 翻唱 | 来源二选一和版权校验 | P0 | 合法作品/资源 | 分别提交两者都空、两者都有、copyright=false、合法单一来源 | 非法请求400且不冻结积分；仅单一来源且版权true可创建 | 重点弥补 Flutter硬编码 |
| API-ASSET-001 | 上传 | 参考音频和翻唱源服务端二次校验 | P0 | AUDIO-EDGE | 绕过前端直接上传伪格式、超限、时长缺失/越界 | 服务端拒绝；合法资源绑定当前用户/appCode；失败不落孤儿业务记录 | - |
| API-RESOURCE-001 | 资源 | Provider 临时音频转存自有存储 | P0 | 真实或可过期 Mock URL | 完成生成，记录第三方URL；等待/模拟第三方URL失效后播放下载 | 作品使用自有 URL；第三方失效不影响；对象 key、MIME、大小正确 | 发布强门禁 |
| API-RESOURCE-002 | 资源 | 转存失败任务失败并退款 | P0 | 模拟存储上传失败 | 让 Provider 成功但持久化失败 | 不把临时 URL 当最终结果；任务失败或可重试；积分按失败退款；无成功作品 | - |
| API-TIMELINE-001 | 歌词时间轴 | 时间轴合法、有序且可降级 | P1 | Provider 返回正常/乱序/空时间轴 | 完成任务并查询详情 | 合法行按 lineNo/start/end 有序；非法数据被校验/归一；空时保留静态歌词 | - |
| API-WORK-001 | 作品 | 列表、详情、最近作品状态一致 | P0 | 多状态作品 | 请求 list/recent/detail | 同一作品 ID 的 status/songType/音色/资源一致；隐藏作品不返回；recent 限制数量 | - |
| API-ADMIN-001 | 管理权限 | 受限管理员 API 权限生效 | P0 | A-LIMITED | 直接请求未授权配置、积分、作品接口 | 返回403；允许的 catsinger 模块正常；不靠前端隐藏代替权限 | - |
| API-LOG-001 | 安全日志 | 响应和日志不泄露密钥与敏感信息 | P0 | 触发登录、Provider、支付、上传错误 | 检查 App 日志/后端日志/响应 | 不出现 MiniMax Key、短信/支付密钥、完整 Token、验证码和本地绝对敏感路径 | - |
| API-CONTENT-001 | 内容安全 | 输入和成品审核失败处理 | P1 | 开启 catsinger 审核，准备违规文本/音频 | 提交创作与等待成品审核 | 创建前拒绝或任务失败原因明确；成品不发布；积分规则一致；Admin 可追溯审核步骤 | - |

