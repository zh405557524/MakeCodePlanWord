# catsinger Java 开发计划

## 当前任务

| 任务 | 状态 | 依赖 | 验收 |
|---|---|---|---|
| CHG-0020 运营专用账号与每日冻结 | `waiting_review` | 现有用户状态、固定审核登录模式、Admin 鉴权和 App schema 路由 | 实现、构建和定向测试已通过；等待正式发布后验证默认冻结、Admin 解冻和真实登录鉴权 |
| CHG-0021 音乐封面正向提示词禁用文字约束 | `done` | CHG-0018 音乐提示词调用结构 | 封面正向禁字硬约束、最终 Command 回归、构建与差异检查通过 |
| CHG-0018 音乐业务提示词最小收口 | `done` | 现有模型字符串调用、Catsinger 四类提示词调用点 | `MusicPromptBusiness` 统一音乐业务、App 最小映射、非提示词业务行为不变且验证通过 |
| CHG-0015 AI 业务强类型引导词 | `done` | CHG-0013 提示词服务、Catsinger 生成调用点 | 四组业务对象、固定合并顺序、旧 String 兼容和定向测试通过 |
| CHG-0013 AI 模型提示词分层组装 | `done` | 现有 `AiModelCallService`、thirdparty Command 和 Catsinger 生成调用点 | 四层组装、旧方法兼容、非提示词字段不变且定向测试通过 |
| CHG-0012 首页歌曲列表独立编排 | `done` | 现有 `SongHomeModuleService`、标签/歌曲配置和 catsinger schema | 新表、Admin/Public 接口、兼容旧接口和关联保护均通过定向测试 |
| CHG-0014 标签封面与有效封面回退 | `done` | CHG-0012 列表编排、现有资源上传和 V2.6 | 标签封面保存/清空、上传、公开回退与兼容测试通过 |

## 实现顺序

### CHG-0021

1. 在 `MusicPromptBusiness` 将文字、伪文字、乱码及文字排版相关禁用项作为硬性约束写入封面最终正向 `prompt`。
2. 保留既有 `negativePrompt`，不改提示词服务分发、模型调用重载或图片 Provider。
3. 捕获最终 `ImageGenerateCommand`，验证正向禁字约束与 provider/model/`paramsJson` 字段边界。
4. 执行定向测试、全量测试、无测试构建和差异检查。

### CHG-0020

1. 增加安全默认的运营账号配置和独立服务，接入固定验证码登录但保留 ACTIVE 状态门禁。
2. 增加应用启动冻结与每日上海时区零点冻结任务，安全切换并恢复 `AppContext`。
3. 增加 Admin 状态查询与冻结/解冻接口，只返回脱敏手机号。
4. 扩展认证、后台管理和生命周期集成测试，覆盖初始冻结、解冻登录、每日再冻结、Token 失效、错误 App 和审核账号回归。
5. 完成构建、定向/全量测试与差异检查，再注入私有正式配置。

### CHG-0018

1. 新增通用上下文、业务类型、请求、目标与结果契约，并新增只保存歌曲事实的 `MusicPromptContext` 和音乐业务枚举。
2. 新增 `MusicPromptBusiness`，集中实现歌词、音乐、翻唱、歌名和图片封面模板及最小厂商/模型适配；`AIModelPromptService` 只做通用校验与分发，两者均不接触 thirdparty Command。
3. 为 `AiModelCallService` 增加上下文请求重载，由新重载优化提示词后委托原 String 方法；原方法行为不变。
4. 四个 Catsinger Service 保留构造器与业务流程，只把私有提示词方法改为构造 `AIModelPromptRequest<MusicPromptContext>`。
5. 清理失效测试并覆盖字段规范化、内容不重复、未知适配回退、现有 String 调用行为和最终 Command 非提示词字段不变。
6. 执行定向测试、全量测试、构建、依赖扫描与差异检查。

### CHG-0015

1. 新增业务提示词接口、目标枚举和公开片段 record，重构 `AIModelPromptService` 的类型校验与合并顺序。
2. 新增 Catsinger 共享创作输入和歌词、音乐、标题、封面四组强类型提示词。
3. 用业务对象重载替换 `AiModelCallService` 的 `promptCode` 重载，保留原始 String 方法。
4. 迁移歌词辅助、歌曲工作流、标题重生、封面生成和任务 prompt 规范化，删除重复拼接方法与业务码类。
5. 更新单元和调用回归测试，执行定向、全量、构建与差异检查。

### CHG-0013

1. 完善 `AIModelPromptService`，实现文本、图片、音乐、歌词和视频 Command 的固定分层组装。
2. 增加 Catsinger 业务码常量，并为 `AiModelCallService` 增加带 `promptCode` 的兼容重载。
3. 迁移歌词辅助、歌曲生成、翻唱、标题和封面调用点，不改原有业务提示词。
4. 补充提示词服务单元测试和模型调用边界回归，执行定向、全量、构建和差异检查。

### CHG-0012

1. 新增 Flyway、Entity、Repository、DTO/VO。
2. 在 `SongHomeModuleService` 增加逻辑列表合并、显式保存、公开过滤和兼容 `home-modules` 组装。
3. 增加 Admin/Public Controller 方法，保持统一响应、traceId 与 `X-App-Code` 路由。
4. 收紧标签编码更新、歌曲删除和标签关系修改的列表引用校验。
5. 更新 service-data 默认展示数量、README/OpenAPI 注释和集成测试。
6. 执行定向测试、全量测试、构建和差异检查并回写流程。

## 验证结果

- CHG-0021 core 正向/负向提示词与最终图片 Command 参数捕获 2 项回归通过；`./gradlew build -x test` 和 `git diff --check` 通过。
- CHG-0021 全量执行 471 项，剩余 44 项既有基线失败；本轮同步修正 1 条与新行为冲突的封面旧断言，新增最终 Command 用例未失败，未扩散修复无关基线。
- CHG-0018 core 18 项、模型调用 10 项、Catsinger 集成 9 项定向测试通过；覆盖七种音乐业务、上下文规范化、target/context 错误、提示词不重复和最终 Command 字段边界。
- CHG-0018 在仅包含本轮文件的干净基线副本中，`./gradlew build -x test` 通过；全量 466 项仍仅有已登记的 31 项积分基线失败，没有新增失败。
- CHG-0018 依赖扫描确认 framework 未引用 `core.ai.aiprompt`、App 未直接引用 `AIModelPromptService`、aiprompt 未引用 Catsinger 或 thirdparty Command；`git diff --check` 通过。
- 当前主工作区的标准构建受本轮开始前已有的 Admin 未完成改动阻塞：`SongHomeModuleService.uploadTagCover` 与 `SongHomeTagEntity.getCoverUrl` 缺失；本轮相关源码已通过独立编译和定向测试。
- CHG-0015 提示词、八个业务格式、模型调用和 3 项业务集成定向测试通过。
- CHG-0015 `./gradlew build -x test` 与 `git diff --check` 通过；全量 460 项仍仅有已记录的 31 项积分基线失败，没有新增失败。
- CHG-0013 `AIModelPromptServiceTests` 与 `AiModelCallServiceTests` 通过，覆盖四层固定顺序、无业务码原样返回、五类 Command 字段边界和发送前处理。
- CHG-0013 `./gradlew compileJava` 与 `./gradlew build -x test` 通过；全量 453 项仍为已记录的 31 项积分基线失败，没有新增失败。
- CHG-0013 `git diff --check` 通过，未新增数据库、公开接口或 thirdparty Command 结构变更。
- 新增定向集成测试和 OpenAPI 路径断言通过。
- `./gradlew build -x test` 通过。
- 全量 443 项测试完成，本次新增用例全部通过，仅保留工作空间已记录的 31 项积分基线失败。
- `git diff --check` 通过。
- CHG-0014 封面保存/清空、上传校验、配置封面优先、第一首有效歌曲回退、空列表和 OpenAPI 定向测试通过。
- CHG-0014 `./gradlew build -x test` 与差异检查通过；全量 456 项仍仅为已记录的 31 项积分基线失败，没有新增失败。
