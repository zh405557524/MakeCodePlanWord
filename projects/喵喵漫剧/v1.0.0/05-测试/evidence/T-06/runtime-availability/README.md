# T-06 日常创作入口不可用排查

2026-10-19用户反馈“创建漫剧”无响应，截图显示“制作暂不可用，请稍后再试”。本轮只读检测，未修改服务开关、模型配置、设备或数据库。

[实时配置观测](runtime-config-observation.json)为测试服务实际HTTP 200结果：制作总开关和创作开关均关闭；图片、视频的可用能力列表均为空，没有制作默认参数。接口响应成功不代表制作功能开放。

App默认连接测试环境（Global.currentServerAddressType默认2）；首页以ConfigStore.canCreateDrama禁用入口，CustomRouter.openCreation再次防护。该条件为enabled和features.creation同时为true；所以当前截图对应禁用状态，不是跳转处理中。后端创建能力还检查三个文本场景是否就绪。公开返回不能证明具体哪个渠道密钥或后台配置缺失。

创作流程已有实现和隔离环境测试，不能据此宣称日常包真实创作可用。待补：核对该测试环境的制作开关、三个文本场景、图片/视频模型及计费能力；按已批准参数形成具体配置，再进行环境接入与完整真实链路验证。不能仅取消前端守卫或使用演示模型冒充可用。

数据库改动：无。无部署、外部写入或收费模型请求。用户手机仅只读核对前台App/包版本和公开偏好；未启动、点击、安装或更改其会话。当前47任务及186用例通过数不变。

## 2026-10-19 续查：五个业务场景均未提供启用模型

逐项实际调用公共 `GET /api/config/models`，带 `X-App-Code: catdrama`、`sceneCode` 和必填 `capabilityType`，五项均 HTTP 200 / code 200 / 空数组。见[脱敏观测](scene-model-observation.json)。首次漏传必填能力参数的 HTTP 错误不作为可用性结论。

| 场景 | 能力 | 当前公开启用列表 | 接通要求 |
|---|---|---|---|
| drama.story.generate | TEXT | 0 | 故事草案文本模型及启用 Provider |
| drama.screenplays.generate | TEXT | 0 | 全剧逐集剧本文本模型及启用 Provider |
| drama.script.analyze | TEXT | 0 | 全剧素材/逐集镜头分析文本模型及启用 Provider |
| drama.asset.image.generate | IMAGE | 0 | 图片模型、真实图片规格及对应计费项 |
| drama.shot.video.generate | VIDEO | 0 | 含声音视频模型、真实规格、计费项及样片验收依据 |

这证明当前有效目录没有这些模型，不能区分后台记录不存在还是被停用，亦不证明某个 API Key 无效。源码默认 `ai-billing.json` 的 providers/modelConfigs 也是空列表，但数据库同场景优先；不能用源码默认值代替部署数据库事实。

### 环境接通顺序及现有入口

1. 在目标测试环境、catdrama App 下读取管理端现有配置和模型，保留当前值、状态、ID及版本。复用 `GET /api/admin/configs/{configKey}`、`GET /api/admin/ai-models`、`GET /api/admin/model-providers`；本轮没有登录管理端或调用这些管理接口。
2. 三个文本场景分别绑定真实 `providerCode/modelCode/paramsJson/chargeItemCode`，启用当前 Provider 和模型；沿对应场景的公共零积分计费项。既往隔离环境 DeepSeek Pro 的两份短稿可作为候选依据，但不代表该测试服务器已配置，也不构成复制本机密钥或重交未知长稿的授权。模型列表就绪还不等于真实外呼成功，需另验任务入队、Worker、结果校验与保存。
3. 确认以上可用后，才将测试环境 `drama.features` 中 `enabled/creation` 设为 true；保留其余键和值。该动作仍待目标环境授权和管理端原值核对，本轮未执行。只开总开关无法补齐三个空文本场景。
4. 图片/视频继续分别核对 `drama.production.imageModels/videoModels`、`available`、`contractVersion`、`combinations`、`maxReferenceImages` 与真实模型身份；视频须 `supportsAudio=true`，默认设置须属于有效组合。计费仍由现有公共目录提供，不将客户端演示价格写回。
5. 视频收费前还需同一组合的 `videoAcceptance`：验证版本、样片依据、时长区间、实际输出格式和音频阈值；未取得样片不能随意填值。模型、资源私有保存、任务恢复及报价通过后才分别开放 materialGeneration/videoGeneration。不能把启用文本创作称为完整出片可用。
6. App下拉首页沿既有刷新入口重新取配置；从普通首页走真实草稿、剧本、制作、生成到本机剪辑与保存，记录真实任务/资源/积分结果。当前此普通测试环境链路仍未验收。

复用的写入口为 `POST/PUT /api/admin/ai-models`、`POST/PUT /api/admin/model-providers` 和 `PUT /api/admin/configs/{configKey}`。后者请求字段为 `configValueJson/status`，不是 JSON Patch；需合并原对象后提交。公共 `AppConfigStoreService.upsert` 会补齐当前 App 缺失默认配置快照，所以正式实施前必须核对这项数据库副作用，不能声称仅修改两个布尔值。没有新接口、DDL或迁移需求，不直接写 SQL、覆盖整组私有配置或修改其他 App。

源码依据：`DramaConfigService.runtime/effectiveModels/textSceneReady/videoAcceptance`、`AiModelConfigService.publicModels/chooseEnabledModel/ensureProvider`、`AppConfigStoreService.activeJson/upsert`、现有 Admin Controller/DTO。管理端当前值、真实厂商可用性和视频样片仍待，未编造可直接发布的模型参数。

## 点击无反馈修复与验证

首页原来将 GestureDetector.onTap 设为空，导致公共路由已有的“制作暂不可用”提示无法触发。现点击交给原 `HomeController → CustomRouter.openCreation`，由原守卫决定提示或导航；整张入口卡命中，正常页面布局和文案保持。未取消开关检查，也没有自动重试生成或更改登录会话。

- [验证汇总](home-feedback/verification.json)：新增总开关关闭、创作关闭、加载中、读取失败四种点击回归；旧源码4项均失败，修后首页33项通过，analyze和四文件格式检查通过。
- [Android实际报告](home-feedback/android-home-flow.json)、[运行及恢复](home-feedback/android-outcome.json)：专用 API37 模拟器4个完整方法通过，严格driver检查不可用点击提示且无请求/导航/登录副作用、配置可用后的入口、案例播放缓存、草稿恢复及制作同款。12张系统图，已查看[点击反馈截图](home-feedback/android-os-home-unavailable-feedback.png)。数据与API为受控夹具，播放器/文件/KV及页面为真实App；不是日常测试服务器创作链路。
- [复跑脚本](home-feedback/run_android.py)：只允许专用模拟器，备份与恢复普通APK，恢复摘要一致，移除本次转发和锁；没有操作用户手机。原始驱动日志仅留本机临时目录，未提交授权参数或凭据。
- 本次未新增iOS设备运行或Figma像素结论，既有证据仍保留；没有后台代码/配置/数据库修改、推送或部署。T-06仍未完成，47任务仍7完成/40未完成，186正式用例仍12通过/171部分/3未执行。
