# catsinger Java 后端技术说明

> 补充实现轨迹：2026-07-31 从错误工作区别名 `catsinger` 恢复；CHG 已按 `旧编号 + 14` 重编号。正确项目现有主文档继续优先，本文不得单独覆盖 `CURRENT.md` 指定入口。

## CHG-0034 运营专用账号与每日冻结

- 账号边界：新增 `OperationsAccountService`，与 `ReviewAccountService` 完全独立；只共享现有用户状态、资料和 Token 基础设施，不实现 Apple 审核策略。
- 登录边界：`AuthService` 仅在运营账号配置、AppCode、手机号和固定验证码同时匹配时跳过短信流水校验；命中后仍必须由运营账号服务确认数据库用户状态为 `ACTIVE`。
- 初始门禁：运营账号未创建时先在独立事务中创建完整用户/资料/积分账户并立即冻结，再拒绝本次登录，避免异常回滚后账号消失或首次登录绕过默认冻结。
- 生命周期：应用进入就绪前按配置 AppCode 切换 `AppContext` 并执行一次冻结；首次冻结失败则阻止服务带着未冻结账号就绪。定时任务按配置 cron、`Asia/Shanghai` 时区每日执行，只定位配置中的单个账号，重复执行幂等。
- Token：冻结同时更新 `users` 和 `user_app_profiles`，撤销 Refresh Token；现有 `JwtAuthenticationFilter` 每次请求校验 `users.status=ACTIVE`，因此 Access Token 立即失效。
- Admin：新增 `/api/admin/operations-account` GET/PATCH；响应只返回 `phoneMasked`，不返回固定验证码。PATCH 复用现有原因校验并记录脱敏结构化日志。
- 配置：源码默认关闭且手机号/验证码为空；真实值仅注入 `.local/prod/config/runtime.env`。
- 数据库改动：无。

### CHG-0034 接口契约

| 方法 | 路径 | 鉴权 | 说明 |
|---|---|---|---|
| GET | `/api/admin/operations-account` | 后台 token | 查询当前 App 的运营账号启用、创建、冻结与每日重置策略 |
| PATCH | `/api/admin/operations-account/frozen` | 后台 token | 填写原因后冻结或解冻当前 App 的运营账号 |
| POST | `/api/auth/sms/login` | 匿名 + `X-App-Code` | 运营固定凭证命中后仍校验账号为 ACTIVE |

## CHG-0032 音乐业务提示词最小收口

- 依赖方向：App 同时依赖 `core.ai.aiprompt` 的上下文契约和 `core.ai.aimodel` 的调用入口；`AiModelCallService` 调用 `AIModelPromptService` 后继续委托 thirdparty。禁止新增 `framework -> core.ai.aiprompt` 反向依赖。
- 核心契约：core 定义通用 `AIModelPromptContext`、`AIModelPromptBusinessType`、`AIModelPromptRequest`、目标与结果对象，并提供只表达歌曲事实的 `MusicPromptContext` 和七种 `MusicPromptBusinessType`。
- 调用边界：App 从现有 Request、Task、Work 映射 `MusicPromptContext` 并交给 `AiModelCallService` 新重载；上下文不进入 `userPrompt` 或 `paramsJson`，App 不注入、不调用 `AIModelPromptService`。
- 音乐业务边界：`MusicPromptBusiness` 集中持有七种音乐业务模板，并按业务基础模板、Provider、Model 固定顺序生成最终提示词；后续音乐 App 可复用同一业务能力。
- 通用服务边界：`AIModelPromptService` 只校验 target、业务类型和 context 类型并路由到 `MusicPromptBusiness`，不保存音乐模板，也不接触 thirdparty Command。
- 模型调用边界：`AiModelCallService` 的强类型重载只负责请求优化并委托现有 String 方法创建 thirdparty Command；所有调用最终经过同一条 Command 创建路径，没有重复的提示词实现。
- 业务边界：只改变最终提示词内容，不改变校验、模式判断、模型选择、计费、任务状态、工作流、事务、存储或失败补偿。
- 结构边界：现有 String 方法继续作为直接模型调用能力；不为新旧逻辑建立分支，不修改 REST、数据库、任务表和 thirdparty Command/Provider。
- 数据库改动：无。

## CHG-0027 AI 模型提示词分层组装

- 归属模块：通用能力位于 `core/ai/aiprompt`，Catsinger 只保留带应用前缀的业务码常量。
- 处理时机：`AiModelCallService` 构造 thirdparty Command 之后、调用 Provider Service 之前执行。
- 匹配维度：模型能力、`promptCode`、`providerCode`、`modelCode`；按通用、业务、厂商、模型固定顺序组装。
- 结构边界：不使用责任链、Handler 或 Catalog；提示词规则由 `AIModelPromptService` 内部固定 `switch` 和私有 `PromptFragment` 管理。
- 字段边界：文本只组装 `systemPrompt/userPrompt`，图片和视频只组装 `prompt/negativePrompt`，音乐和歌词只组装 `prompt`。
- 兼容边界：旧方法委托空 `promptCode` 重载；空业务码或无匹配规则时保持 Command 不变。
- 日志边界：不记录完整提示词、歌词、第三方原始请求或响应。
- 数据库改动：无。

## CHG-0029 AI 业务强类型引导词

- 通用契约：`core/ai/aiprompt` 定义业务提示词接口、五类 Command 目标和四字段提示词片段；`AIModelPromptService` 只负责类型校验和固定顺序合并。
- 业务归属：Catsinger 在 `app/catsinger/aiprompt` 按歌词、音乐、标题、封面四个领域定义强类型 record，并保留八个稳定业务编码作为对象内部身份。
- 输入格式：共享 `CatsingerCreativePromptInput` 统一解析 `description/musicStyles/musicScenes/songTargets`，业务 Service 不再维护重复 Map 解析与 StringBuilder 模板。
- 合并顺序：原 Command → 业务片段 → 厂商片段 → 模型片段；没有业务对象时原样返回，目标类型不匹配视为编码错误并立即失败。
- 兼容边界：删除开发期 `promptCode` 重载，保留最早的原始 String 方法；不修改 REST、任务表、模型选择、计费、Provider 和 thirdparty Command 字段。
- 数据库改动：无。

## CHG-0026 首页歌曲列表独立编排

- 归属模块：`app/catsinger/config`；后台入口继续位于 `admin/song`。
- 数据源：普通和后台接口均沿用 `X-App-Code` 路由，数据只写当前 catsinger schema。
- 持久化：新增 `catsinger_song_home_lists`，每个 `tag_code` 唯一保存 `display_count` 和有序 `item_codes_json`。
- 默认回退：没有数据库列表时，按歌曲已有标签和歌曲 `sort_order/item_code` 生成候选顺序；`scene_template` 默认 4、`hot_song` 和其他标签默认 10。
- 显式覆盖：列表一旦保存，只按有序 `itemCodes` 返回；空数组表示显式空列表，不再追加其他同标签歌曲。
- 公开过滤：按列表顺序解析歌曲，过滤禁用、不可播放或不可公开作品后再截取 `displayCount`，后续可用歌曲自动补位。
- 兼容：保留标签表 `display_mode` 和旧 `SongHomeModuleResponse` 字段；旧 `/api/song-config/home-modules` 改为复用新列表结果。
- 稳定键：已持久化标签的 `tagCode` 不可修改；列表引用歌曲时，删除歌曲或移除对应标签必须先清理列表。

## CHG-0028 标签封面与有效封面回退

- 数据库：直接修改开发期 catsinger Flyway V2.6，为 `catsinger_home_song_tags` 增加可空 `cover_url`；不新增迁移、不回填存量数据。
- Admin：标签新增可空 `coverUrl`，并提供 `/api/admin/song/home-tags/covers` 上传接口；清空字段表示恢复自动回退。
- Public：`SongHomeListResponse` 增加有效 `coverUrl`。优先使用标签配置封面，否则按首页列表编排顺序取第一首公开可用歌曲封面；无可用歌曲或封面时返回空字符串。
- 兼容：旧 `home-modules` 结构不增加字段，继续复用首页列表歌曲结果。

## 接口契约

| 方法 | 路径 | 鉴权 | 说明 |
|---|---|---|---|
| GET | `/api/admin/song/home-lists` | 后台 token | 返回所有逻辑列表，包含 `tagCode/tagName/enabled/sortOrder/displayCount/itemCodes/source/persisted` |
| PUT | `/api/admin/song/home-lists/{tagCode}` | 后台 token | 幂等覆盖 `displayCount` 和有序 `itemCodes` |
| POST | `/api/admin/song/home-tags/covers` | 后台 token | 上传标签独立封面并返回资源地址 |
| GET | `/api/song-config/home-lists` | 匿名 + `X-App-Code` | 返回启用标签的 `tagCode/tagName/sortOrder/displayCount/coverUrl` |
| GET | `/api/song-config/home-lists/{tagCode}/songs` | 匿名 + `X-App-Code` | 返回过滤、排序并限量的 `SongHomeItemResponse` 列表 |
| GET | `/api/song-config/home-modules` | 匿名 + `X-App-Code` | 保持原响应结构，items 复用首页列表 |

## 校验与错误

- `displayCount` 必须为 1-100；`itemCodes` 不允许重复。
- 标签必须存在；每个歌曲必须存在且已挂当前标签。
- 未知或禁用标签的公开按标签查询返回 `NOT_FOUND`；有效空列表返回成功空数组。
- 删除列表引用歌曲、移除列表引用标签或修改已持久化 tagCode 返回 `BAD_REQUEST` 和可操作提示。

## 数据库改动

- Flyway：`db/migration/catsinger/V2.6__catsinger_song_home_lists.sql`。
- 新表不设置标签或歌曲外键，以兼容 service-data 默认标签/歌曲；完整性由 Service 校验。
- 不回填、不修改或删除存量标签、歌曲、作品及其他业务数据。
