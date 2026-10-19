# T-23 本地签名配置生效与原图片任务恢复

2026-10-19。用户明确批准应用已备好的三项本机签名配置并重启共享8080；同时选择保留720P/1080P，暂缓视频接入，不增加768P或调用H3。

## 当前结果

本地DeepSeek文本与BigLongXia图片入口均已启用，视频仍关闭。原IMAGE任务`2112121671146860545`由数据库调度器恢复到`SUCCEEDED / IMAGE_READY / SETTLED`，原Provider请求号与收费订单号保持，原报价只有1个Job。没有重新生成图片、人工改Job终态或手工结算积分。[实际任务](job-after.json)、[数据库与账务](database-after.json)、[当前配置](public-config-after.json)。

原`120`冻结正常结算一次，按原两批次30+90产生两条CONFIRM流水，合计120，非重复扣费；当前可用30、冻结0。原120测试积分发放沿[上一轮证据](../local-image-pipeline/README.md)，本轮未再次赠额、充值或修改单价。图片成功时间仍为`2026-10-19T10:00:53.899Z`，到期为`2026-11-18T10:00:53.899Z`，不是重启或保存时间加30天。

成功结果保存为本人PERSONAL/ROLE资产；客户端按原版本主动应用，当前图及历史只有1个版本，resourceId为`1`。[资产列表](personal-assets-after.json)、[图片历史](image-history-after.json)。这是个人资产路径，未冒充作品内图片自动分组、作品引用禁删或完整手机业务验收。

## 真实私有文件验证

通过正式资源接口换签后实际读取OSS返回200，去掉查询签名后返回403；匿名换签被拒绝，实际HTTP400/业务码-401，不能误写成401或403。访问响应有no-store，临时URL和token均未复制到工作区。[HTTP核对](http-verification.json)。

[实际交付图片](generated-delivery.png)为1254×1254 PNG、1,841,388字节，SHA-256为`ccd41f843dffdb60647f0d22d5fca967afe39eafd3469917642d2f454e97f8fb`，与数据库最终文件摘要一致，已实际解码并查看。公共文件读取器读出7个AIGC字段，实际签名Service验签通过、追踪编号与数据库一致。[文件验证](delivered-image-verification.json)。沿用源码既有LXWX平台默认值，仅证明本地元数据/签名链路，不宣称完成外部审核或正式主体配置验收。

资源技术状态`LOCAL_RETAINED`表示当前还保留临时本机副本；实际OSS签名读取及摘要已独立核对，不能把状态名当作OSS上传失败。原暂存成功时间、源摘要与实际资源台账匹配，未用未标识原图充当交付文件。

## 配置、重启与数据库改动

只在Git忽略的本机`config/application.yml`新增`app.resource.trace.key-id/signing-private-key-path/signing-public-key-path`，原值和注释保留；PEM、完整YAML、进程参数均仍在后端私有目录，未提交。三项差异沿[已审补丁](../local-image-pipeline/signing-config.patch)，没有修改源码默认密钥或云端配置。

已正常停止原IDE进程85890，沿相同180项classpath和已有编译产物启动本地服务89236，移除IDE agent，不编译或带入其他对话源码改动；本地8080公开配置已实读正常。[重启状态](restart.json)。重启前后7个schema待执行迁移与校验和差异均0，实际启动日志均为No migration necessary；没有DDL、repair、清库或部署。[迁移只读核对](migration-preflight.json)。当前服务是独立本地进程；IDE下次启动前应先停止此进程，避免8080冲突。

数据库：仅本机catdrama的`drama.features.materialGeneration`从false恢复true，其他配置键不动，`videoGeneration=false`。采用原暂停值的CAS定向事务，[SQL](resume-images.sql)、[写入范围](image-submission-restored.json)。原任务通过现有Service正常写入1资源/1追踪/1图片版本、原Job与订单结算及主动应用回执；不手改业务状态、不改其他App、远程环境、历史订单或用户数据。

## 检测边界与原始失败

本轮执行真实本机HTTP、后台调度恢复、OSS和账务核对；不是Mock或仅SDK独立生图。App/Java业务源码和依赖未改，未重复全套构建/单测；新的手机业务、Figma像素、作品自动分类、批次和异常矩阵仍待，47项仍7整项完成/40未完成，186条仍12通过/171部分/3未执行。

准备检测脚本首次没有解析schema占位符、使用旧Ruby不支持的filter_map，均在只读预检阶段失败并修正；只读SQL曾将订单status写成state而被拒；HTTP检查曾误写不存在的points/balance路径及假定匿名状态为401/403，核对实际Controller后改为points/account与真实400/-401。以上均没有业务写入或模型重交，未计作通过；最终证据为修正后实际执行结果。没有改动产品规格、调用视频、进行新的充值或操作用户手机/相册。
