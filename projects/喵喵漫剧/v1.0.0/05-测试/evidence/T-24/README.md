# T-24 自动入库检测

功能及任务范围见[result.json](result.json)，代码在两个仓库dev各单独提交。当前仍为开发，真实渠道/两端缺项保持未完成，不推进上线。

- 新增23项后端；相关312项中288通过、24跳过、0失败。跳过为未开启CATDRAMA_ASR_POSTGRES_URL的独立ASR控制面恢复套件，未计通过；本次已跑字幕Job与原Job、故事/剧本/分析/作品及图片/公共标识相关测试。
- 新增11项App；9个相关文件共158方法通过。setup/load/teardown的27个隐藏事件不计方法；重复截图不累计。analyze无问题、6文件格式检查0变更。
- 后端实际Spring/JWT、本机独占PostgreSQL和原文件，模型/OSS边界使用替身；App实际Controller/Widget与沙盒文件，HTTP为协议夹具。没有真实Provider、部署或手机验收。

[后端方法](backend-summary.json)、[Gradle输出](backend-test.log)、[App方法](flutter-summary.json)、[App原始事件](flutter-test.jsonl)、[静态检查](flutter-analyze.log)、[格式](dart-format.log)、[逐用例](case-results.json)、[源码和提交摘要](source-manifest.json)。日志仅去除行尾空白，无改动结论。

实际发布服务复用T-23内部publish接口；原图片、PERSONAL副本、双版本引用、原Job的实际入库目标和公共结算同事务。已有Entity/VO字段直接复用，无新HTTP或迁移。计划外必要协作映射见任务结果；不直写其他模块Repository，不复制公共账务。

检测覆盖：三类型、稳定作品分组/同名不合并、同源历史及共享去重、个人手改/选图保护、首图策略、原Job并发恢复、提交前不可见、入库/结算回滚、坏归属、删除与到期旧任务不复活、新有效结果换目标而旧图保旧目标、引用禁删、原成功+30天和图片不续作品、超期原产物失败退回。批量父任务聚合仍归T-25。

验证中修正删除作品返回语义、实际检查点写入和首屏资产入口。最初微秒时间断言错把API毫秒当数据库精度；现分别断言API、数据库原成功与截止，未修改既有输出精度。T-23缺发布者套件显式装配保护边界，T-24使用完整Spring Bean，不使用假成功替代发布。

[候选实际Widget图](screenshots/saved-candidate-375.png)已查看：已保存到作品分类、待应用本集及查看资产入口独立。图片为本机测试生成PNG，无后期编辑。[图证据](image-evidence.json)另记录动态图层离屏截图缺字，不作整页视觉通过；[不完整抓图](attempts/library-saving-capture-incomplete.png)保留排障。Figma 5hl12w7y返回Not connected，最新视觉和两端仍由T-43补验。

数据库改动：无表/列/索引/迁移变更，只有现有表正常业务写入。临时schema在夹具结束清理后剩余0，自有PG已停止；未推送或部署。保留他人改动，仅提交本任务路径。
