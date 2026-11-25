# V2.1 Flutter / Web 模块开发索引

> 2026-09-14 执行结果：F001～F007、W001～W004 已完成本地真实实现并进入 `real_review`。Android 真机和 iOS 模拟器完成关键页面/文件选择验收；真实算道训练、翻唱声音克隆和成品播放仍因配置缺失保持 `BLOCKED/NOT_RUN`。以下 `-S` 状态和旧骨架门禁段落仅作历史记录。

> 版本 `v2.1-model-driven-params` · CHG-0076/0078 第 13 步 `waiting_review`、第 15 步 `in_progress` · 2026-09-14。依据[总体计划](../flutter-dev-plan.md)、[技术文档](../flutter-tech.md)、[当前 PRD](../../01-需求/requirements.md)及当前设计资源。[旧版计划](../../archive/CHG-0077-legacy-docs-20260913/03-前端/)仅 `reference-only`。

## 范围与顺序

三业务分别使用现有 Flutter Controller/API；W01～W07 由现有 Flutter Web/Admin 页面承载。不重建任务、积分、审核、上传、作品或播放器。第 4 步 Figma 计划经用户明确 `skipped`，开发前核对当前线上画面；本地[21 张状态快照](../../01-需求/references/images/v2.1/model-driven-params/README.md)只作辅助。图上积分、时长、容量是动态示例，不能写成业务常量。

以下状态是用户授权前的骨架快照，不是当前编码状态：`T-F001-S=in_progress`；其他 `-S/-R` 曾为 `pending`。当前真实实现进度以本文首页执行覆盖和 `workflow.md` 为准。

| 顺序 | 模块文档 | 任务 | 入口 / 交付 |
|------|----------|------|-------------|
| 1 | [契约与受控固定数据](01-contract-and-fixture.md) | F001-S/R | 四场景模型列表、有效参数、切换清值、旧响应降级 |
| 2 | [简易与专业写歌](02-song-create.md) | F002-S/R | 简易/专业字段置灰、纯音乐、有效载荷、价格 |
| 3 | [歌曲改编](03-song-adaptation.md) | F003-S/R | 来源、歌词策略、模型切换，保留独立改编业务 |
| 4 | [本人音色训练与克隆](04-voice-train-and-clone.md) | F004-S/R | 素材硬限制、精确音色兼容、克隆动态设置 |
| 5 | [任务、作品与播放器](05-task-work-player.md) | F005-S/R | 等待、恢复、重新创作、成品实际可播放 |
| 6 | [后台模型能力](06-admin-capabilities.md) | W001-S/R | 厂家只读能力与后台合法收窄 |
| 7 | [后台配置与运营](07-admin-operations.md) | W002-S/R | App/角色、价格、音色、任务、审核、作品 |
| 8 | [验收与移交](08-acceptance.md) | 覆盖 F001～005、W001～002 | 骨架审阅证据、真实联调与第 15 步移交 |

## CHG-0078 首页与新人权益增量（真实实现进行中）

本专区承接当前[CHG-0078 总体计划第 9 节](../flutter-dev-plan.md)，以[当前 PRD P01/W08/W09](../../01-需求/requirements.md)、[技术文档第 8 节](../flutter-tech.md)和 Figma `xvrgwxfy` 首页/新人礼节点为依据。原 01～08 的 CHG-0076 任务进度不变。四项 `-R` 已开始真实配置/API 接入；定向静态检查通过，T-Q002 仍未验收。下表 `-S` 为历史快照。

| 顺序 | 模块文档 | 任务与状态 | 依赖 / 交付 |
|------|----------|------------|-------------|
| 9 | [首页海报与三业务入口](09-home-carousel.md) | F006-R `in_progress`；S 为历史 | B007；轮播、审核图投影、三独立路由 |
| 10 | [首页新人礼弹窗](10-new-user-gift.md) | F007-R `in_progress`；S 为历史 | B009；资格查询、曝光、稍后、领取、现有任务入口 |
| 11 | [后台首页海报](11-admin-home-banners.md) | W003-R `in_progress`；S 为历史 | B007；资源审核、排序、目标、版本、权限 |
| 12 | [后台新用户权益](12-admin-new-user-benefits.md) | W004-R `in_progress`；S 为历史 | B008/B009；注册赠额与弹窗配置独立保存 |
| 13 | [首页与新人权益验收](13-home-benefit-acceptance.md) | T-Q002 `pending` | Android/iOS、Admin/Java 真实对照，非已测试证明 |

CHG-0078 的历史 `-S` 只在 local/test 走集中固定数据，生产不展示假成功；本版已获用户明确授权跳过骨架评审，现执行 `-R`。三个创作入口分别到 `/api/song-generations`、`/api/song-covers`、`/api/song-voice-covers`，首页导航本身无任务/积分副作用。

## 历史双阶段记录与当前门禁

- 原 `skeleton_first / skeleton_coding` 为用户授权前的历史状态，不是当前执行门禁；当前以 `workflow.md` 的 `direct_implementation / real_coding` 为准。未完成的 `-S` 不伪记为 done。
- `-S`：App/Web 页面、路由、Controller、正式 API 路径和状态完整；固定能力/价格来自 Java local/test 集中 Fixture，不散落在 Widget。现有生产业务不被假数据替换；生产不展示新增未完成功能的伪成功。
- `-R`：本版已明确授权执行；真实模型/配置/报价、上传/审核、任务、作品和可播放音频由原有链路提供，设备与真实环境验收前保持 `in_progress`。
- 每模块记录已完成代码与未验收链路；遇到新字段或接口冲突先同步本版技术文档、Java 对应模块与 CHG，不能在页面临时拼新的 wire shape。

## 跨端契约速查

| 场景 | 模型接口 | 创建接口 | Java 模块 |
|------|----------|----------|-----------|
| AI 写歌 `song.generate` | `GET /api/ai-model-options?sceneCode=song.generate` | `POST /api/song-generations` | [B001/002](../../04-后端/开发计划/02-effective-contract.md)、[B003](../../04-后端/开发计划/03-song-and-adaptation.md) |
| 歌曲改编 `song.cover.generate` | `GET /api/ai-model-options?sceneCode=song.cover.generate` | `POST /api/song-covers` | B002/B003 |
| 本人音色训练 `song.voice.train` | `GET /api/song-config/models?sceneCode=song.voice.train` | `POST /api/song-voice-training-tasks` | [B004](../../04-后端/开发计划/04-voice-training.md) |
| 翻唱声音克隆 `song.voice.cover.generate` | `GET /api/song-config/models?sceneCode=song.voice.cover.generate` | `POST /api/song-voice-covers` | [B005](../../04-后端/开发计划/05-voice-clone-cover.md) |

模型响应保留现有 `operationType/status/parameters`，目标增量为 `musicContract.contractVersion/effectiveParameters/mediaConstraints`；声音模型旧 `capabilityLimits` 只作兼容。`contractVersion` 不等于 `pricingVersion`。`NOT_DECLARED` 时可选项保持可见但置灰，基础操作仅在服务端有独立可执行证据时最小提交。禁用/越界值不得随请求发送，服务端仍在冻结前重验。

## 模块通用验收与恢复点

每份子文档都含入口/设计来源、现状偏差、涉及文件、状态与数据流、`-S/-R` 步骤、错误/空态、测试及完成条件。骨架阶段的 `TODO(REAL-IMPLEMENTATION)` 必须能在对应 `-R` 找到；骨架不做真实上传、积分、审核或厂家请求。App/Web 各模块的 `flutter analyze`、定向 `flutter test` 是编码后验证，不是本次文档阶段已运行结果。Android/iOS 真正成品可播放才可关闭用户链路；iOS 真机优先，模拟器兜底，二者都没有则双平台验收不通过。

当前恢复点：本地真实实现进入 `real_review`。Flutter `analyze` 与 V2.1 定向 22/22 通过，Admin `analyze`、234/234 和 Web 构建通过；Android 真机与 iOS 模拟器已验证首页、登录门禁、翻唱主页、音色库/资料及文件选择。已有 AI 改编播放进度递增通过，但翻唱声音克隆因缺 Provider Account/Token、场景映射、计费和验证短句，未生成成品，不能记为播放通过。Flutter 全量 141 个历史损坏文案断言另行清理。详见[阶段验收记录](../../05-联调与测试/v2.1-voice-clone-ui-and-provider-audit-20260914.md)。
