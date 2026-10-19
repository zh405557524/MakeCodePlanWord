# T-23 本地真实图片链路与保存阶段恢复准备

2026-10-19。按用户授权推进本地接入，当前未完成，不进入上线或宣称完整资产交付。

## 实际执行

本地自建游客1原有30积分；通过原公共`PointsService.grantPermanent`及真实MyBatis/事务补120测试积分，使用固定`ADJUSTMENT/CATDRAMA-LOCAL-IMAGE-20261019`流水。没有手写SQL改账户/流水，也没有修改生成单价、支付订单或真实用户。随后真实HTTP建立个人角色素材、报价120并提交一次IMAGE任务，当前Job `2112121671146860545`。

后台实际调度调用BigLongXia/gpt-image-2，已取得并保留1840431字节原图。任务进入`FINALIZING / SAVE_IMAGE / 75%`，资源记录仍0，未发布图片版本或结算。当前可用30、冻结120，冻结按30+90两个积分批次分配，非重复冻结。原图与Provider请求身份保持，恢复只继续原任务。[报价](quote.json)、[实际任务](job-observation.json)、[数据库与流水](database-observation.json)、[原图留存摘要](source-retention.json)。

## 保存阻碍与已准备的修复

本机私有`app.resource.trace`只有`staging-root`，缺少`key-id/signing-private-key-path/signing-public-key-path`，源码默认值亦为空；实际进程参数和环境未发现对应覆盖。公共`ResourceTraceCryptography.sign`在缺失时拒绝保存，与原图已取得、资源记录未创建及Worker持续保存恢复的现场一致。[配置检查](signing-inputs.json)。尚未通过恢复成功证明完整修复，不能把配置检查当交付成功。

已创建仅本机开发使用的Ed25519密钥对，并调用实际公共Service签名、验签及JSON往返校验通过。[自检](signing-self-check.json)。密钥和完整私有配置均只在后端Git忽略目录，不进入本工作区。已准备[仅新增3项的配置补丁](signing-config.patch)及完整YAML解析验证，当前私有配置保持原摘要，未应用、未重启。

已询问是否应用补丁并重启用户IDE启动的共享8080后端，因为会中断其他本地App请求和当前调试连接。得到确认后先核对配置基线、应用缺失项，再恢复此原Job，不新建任务或再次生图。

等待期间已暂停新的图片提交，原任务和原图继续保留；文本创作仍可用，图片模型绑定/能力保留。[当前开关](current-image-config.json)、[暂停事务](pause-new-images.sql)。没有把未发布图片开放为成功资产，也没有手动释放/结算未知任务的冻结。

## 并行验证与待确认事项

- DeepSeek官方`deepseek-flash`的免费资产描述任务 `2112123845633437697` 成功，场景候选保留输入车站、木椅、拱窗、青色山脉，长度1–500；未自动修改资产、生成图片或增加扣费。[真实结果](deepseek-description.json)。完整手机表单及其他类型仍按T-47待验。
- BigLongXia公开价格目录本轮只匹配到MiniMax-H3视频候选，当前后端适配声明仅768P；目录/代码声明不证明当前账号可生成或包含正确语音。[目录投影](video-pricing-discovery.json)。因产品当前生成选项为720P/1080P，已询问是否增加768P并实跑H3有声样片；尚未增加规格、修改代码或提交H3任务。
- 之前Grok503记录保留，未重复请求。没有将其他视频型号当作兼容占位，也未构造样片阈值。

## 数据库与范围

仅当前电脑`catdrama`：新增`drama.production`图片能力；原`drama.features.materialGeneration`开启验证后恢复关闭。图片报价只使用真实已验证风格，现有API复用的组合中720P/10秒/16:9字段不是本次图片输出尺寸或时长承诺；本次图片参数仍使用Provider实际默认值。视频能力仍为空。[能力初始化](enable-image.sql)、[能力说明](image-capability-enabled.json)。

真实业务接口新增1个个人资产、1个报价、1个图片Job和对应公共120积分订单/冻结，公共Service新增1次120测试积分发放及原批次流水。原图由现有暂存机制持久保留，未手改Job终态/资源或补造成功；无DDL、迁移或其他App数据写入。用于测试的公共Service装配器在[LocalImageTestPoints.java](LocalImageTestPoints.java)，仅本机专用账号门禁、三Mapper和外层事务，不启动Web、Flyway、定时器或业务应用。

本轮没有修改App/Java业务源码或依赖，无需重复沿用代码基线的构建与单测。实际配置/HTTP/Service/目录/数据库/签名自检为本轮证据，不增加自动化用例数量或手机通过数。47任务仍7完成/40未完成，186正式用例仍12通过/171部分/3未执行。没有推送、部署、共享服务重启、原图外泄或相册操作。
