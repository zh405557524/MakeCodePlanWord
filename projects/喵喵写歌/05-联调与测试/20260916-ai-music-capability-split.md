# Voice 音色创建与 AI 声音克隆：三端纠偏交付记录

## 最终能力契约

本轮按用户确认修改 Java 后端、Flutter 管理后台和 catsinger App。不部署正式服，不调用真实付费训练/生成。业务名称与厂商编码分离：

| 能力 | 场景 | 输入与产物 |
| --- | --- | --- |
| AI 翻唱 | `song.cover.generate` | 保留现有歌曲改编/翻唱链路，不改成 `sovits_cover` |
| AI 声音克隆－训练 | `song.voice.train` | 干声素材生成克隆模型 |
| AI 声音克隆－使用 | `song.voice.cover.generate` | 源歌曲＋兼容克隆模型生成歌曲 |
| Voice 音色创建 | `song.voice.create` | 样本上传、短句验证和本人朗读生成 Voice 音色 |

Voice 音色库只供精确兼容的写歌/改编模型；克隆音色库只供精确兼容的声音克隆使用能力。两库不因 Provider 相同而互通。使用现有表和任务事实识别产物，不增加 `voice_purpose`，不批量回填、复制或删除历史音色。

Voice 最终提交本人朗读前取报价，准备样本、获取短句和查询不收费；克隆训练与克隆使用分别计费。错误能力、模型或产物必须在扣费和 Provider 调用前拒绝。后台配置须显式保存，不在启动或查询时自动改写数据库。

## App 流程与设计

- Voice：业务说明 → 本地版权声明 → 头像/昵称独立审核 → 恰好一份声音样本 → 厂商短句 → 本人朗读 → 报价/创建 → 返回 Voice 音色库并预选。页面不显示模型选择，使用 `song.voice.create` 服务端默认模型。
- 声音克隆：本地版权声明 → 头像/昵称独立审核 → `song.voice.train` 模型选择 → 模型契约规定的干声素材 → 报价/训练 → 返回克隆音色库并预选。它不进入 Voice 短句验证，也不自动生成歌曲。
- 新流程使用显式能力和阶段枚举；录音/上传不再隐式保存资料或触发隐藏审核门禁。模型失败与空配置分别提示并禁用操作；Voice 重录/重传为替换唯一样本。
- 正式任务创建前，顶部返回、Android 系统/边缘返回和 Flutter iOS 边缘返回均走丢弃确认；创建后只退出等待，不提供训练取消。旧 `verification-challenges` 只作历史兼容。
- 当前 Figma 真源为通道 `lgk3swwy`，节点 `148:381`、`148:423`、`148:7293`、`157:3409`、`157:3455`。Voice 介绍页采用 `148:423` 原始导出主视觉；375×812 对比为 SSIM `0.9031`、显著差异 `6.38%`，未冒充达到全局 `0.98` 发布门槛。

## 后端与管理后台

- App/Admin 训练任务响应新增可空 `sceneCode`，仅由服务端根据业务事实推导 `song.voice.create` 或 `song.voice.train`。历史证据冲突返回未知并禁止跨库，不依赖中文名称或模型编码决定页面。
- `/api/song-voices` 按场景、产物类型、Provider 和模型精确兼容性过滤；“已丢弃定制”的临时记录始终隐藏。
- Admin 训练列表直接按 `sceneCode` 展示“Voice 音色创建”或“AI 声音克隆－训练”；声音克隆使用继续位于歌曲生成任务，现有 AI 翻唱保持不变。
- Admin 的三项音色运行配置仍按 `song.voice.create`、`song.voice.train`、`song.voice.cover.generate` 独立维护；模型映射、默认模型、Provider 或计费项缺失均视为未就绪。

## 验证记录

- App：流程矩阵、卡片、版权、退出手势、模型弹框等定向测试 54 项通过，`flutter analyze` 通过。375×812 的 Voice 说明、版权、资料与头像状态截图已生成。
- Java：`VoiceCoverBusinessIntegrationTests`、`AiModelCatalogIntegrationTests`、`AiSceneModelMappingIntegrationTests` 通过，覆盖 `sceneCode`、两库隔离、丢弃隐藏和能力目录。
- Admin：音色模型与计费页面定向测试 22 项通过，`flutter analyze` 通过；后台展示只信任服务端 `sceneCode`。
- Android V1981A 已安装并实际进入版权/资料页；系统返回及真实边缘滑动均出现“继续定制 / 丢弃并退出”。iOS 26.4 的 Catsinger 375×812 模拟器已从最新源码构建、安装并进入资料页；Flutter 指针测试覆盖 iOS 边缘返回，但桌面自动化的鼠标拖动不能作为原生触控手势实证。
- 当前测试环境后端网络不可达，因此没有加载真实模型/报价，也没有验证厂商短句、训练、扣费或成品播放。所有 Provider 结论只来自测试适配器/模拟服务。

## 数据库与发布边界

本轮没有数据库表结构或 SQL 修改；工作区已有迁移脏改动原样保留。未执行正式库 SQL、Flyway repair、清库、部署或付费任务。发布顺序仍为后端先、Admin/App 后；上线前必须显式检查三项音色运行配置，并补可连接测试环境下的 Voice 本人朗读、克隆训练/使用和 iOS 原生触控全链路验收。
