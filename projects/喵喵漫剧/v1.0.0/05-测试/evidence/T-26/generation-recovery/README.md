# T-26 视频生成核对与恢复

已修复视频完整分页、单项/批次未知门禁、取消重试丢报告、快速完成遗留勾选以及视频状态误用图片文案。当前仍处于开发，T-26整项未完成。

14个新增方法与15个原方法全部保留，29专属、128相关、1126全套App通过，0失败/跳过；178个隐藏框架项排除。analyze无问题，T-26八个及T-42一个Dart文件格式0变更。Android/iOS模拟器各4条实际公共路由、候选播放、回环HTTP与GetStorage读盘流程通过。SDK各+6包含setup/teardown，只计4个业务方法。

- 视频历史须完整核对稳定total和唯一版本，子项须匹配原父total、quote、类型及唯一镜头；失败保已核实数据，禁止盲发，不持续显示加载。
- 未应用过期视频不充当候选。单镜头历史未知/孤立生成中禁重复；旧终态不能解除另一报价的新未知任务。
- 打开/取消报价保留当前页面旧批次报告和手动选择；新父真实受理后才换子项，不增加终态批次历史存储。新尝试丢回执只恢复同一键/报价/任务，子查询失败可再查。
- 默认不选已应用或有效候选，快速成功也移除旧勾选；用户随后明确重选可以保留。视频部分失败、成功、未知、保存中各显示对应文案，并显示真实三类数量。

[结果](result.json) · [逐例](case-results.json) · [原/新增方法](method-diff.json) · [全套/源码/边界复核](verification.json) · [复核脚本](verify.py)。[完整日志](full.jsonl.gz)、[相关](related.log.gz)、[静态](analyze.log.gz)、[格式](format.log.gz)。

双端四组：默认排除/明确重选/单项取消及候选原生播放；一成功两失败→取消报价保报告→只重试702；重复历史页立即停止和明确刷新；新902断回执→原键恢复→服务重建后子查询失败→同902恢复。候选播放使用既有10秒320×180红色H264/AAC夹具，真实文件下载/解码不证明模型画面、说话者、台词或音色质量。任务POST数仅是客户端协议证据，不是公共冻结/结算证明。

[Android报告](native/android-video-generation-result.json) · [iOS报告](native/ios-video-generation-result.json) · [Android日志](android-drive.log.gz) · [iOS日志](ios-drive.log.gz)。最终30系统图和5Widget图全部总览，详看8系统及5Widget；4张Widget与先前详看图字节一致。[Android总览](android-overview.jpg) · [iOS总览](ios-overview.jpg) · [Widget总览](widget-overview.jpg) · [图像清单](image-review.json)。原系统截图未后期修改，总览为派生排版。

初次回归11处失败、快速成功2处失败、文案1处失败均有原日志。前两轮Android是测试脚本的Map类型/纵横滚动定位错误；第三轮脚本通过，但截图发现真实文案问题，修复后同一最终源码双端各4条通过。失败和修正前的原图/脚本留在attempts，不计最终截图数。第一次全套1124通过/1失败属于旧成长测试固定25ms等待；60ms写盘确定复现，T-42单独提交并以15项及本次全套复检，[说明](../../T-42/growth-wait/README.md)。没有降低断言或改生产领取。

原后台149项等历史证据保留，本轮未改未重跑。没有新接口、数据库、依赖或原生引擎实现。真实Provider/私有OSS/计费与样片质量、最新Figma及物理设备完整链路继续待验；Figma rq4owed6本轮Not connected。正式47任务/186用例及开发阶段不变。自有模拟器和转发已清理，[记录](runtime-cleanup.json)。

App dev `f9b173bfe1844d2f906dbc3978193db8324849a9`；T-42 dev `d9eaedc`，均未推送。原文件与原日志gzip可逐字节恢复，[归档校验](archive-manifest.json)。
