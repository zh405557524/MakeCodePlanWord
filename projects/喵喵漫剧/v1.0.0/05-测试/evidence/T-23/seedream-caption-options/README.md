# T-23 / T-08 Seedream 与字幕备选能力

日期：2026-10-19。仅本机开发与自动化回归，未启动/重启共享服务，未部署，没有真实付费模型调用。

- Seedream Flash / Pro：公共图片 Provider 与型号目录已补齐；本机最小配置与两个可直接运行的 main 入口已交付。现有图片标识/存储链路保留；未自动发布 App 默认模型。
- 手动测试按厂商→能力组织，保留用户已填写的本机音频地址；不将这些地址复制进文档。
- 私有配置拆为 9 个厂商文件，主文件相对导入；递归比对原属性值保持。新增图片路径与超时；私有目录 Git 忽略、目录 0700 / 文件 0600。
- 决策：漫剧默认 ASR，保留预存 UUID 与原任务恢复；caption speech 只是独立比较入口，未接入当前漫剧路由。写歌仍默认 singing。caption 提交结果未知且无任务编号时不自动重交。
- 本机回归：112 项通过、0 失败/错误/跳过，见 [机器摘要](results.json)。其中 Seedream Provider 36、图片手动入口 3、caption 客户端 8、caption 手动恢复 3，其余为已有 ASR/模型目录/理解/BigLongXia 回归。数据来自当次 Gradle JUnit XML，不保存日志中的配置或音频地址。
- 测试命令：`./gradlew test` 搭配 `--tests` 选择 `DoubaoImageProviderTests`、`DoubaoSeedreamManualTests`、`DoubaoAsrManualTests`、`DoubaoPropertiesTest`、`AiModelCatalogEnumTests`、`BigLongxiaProviderTests`、`DoubaoImageUnderstandingProviderTest`、`DoubaoVideoUnderstandingProviderTest`、`DoubaoCaptionClientTests`、`DoubaoCaptionSpeechManualTests`。
- 未执行：真实 Seedream 图片、图片作为人物视频参考的接受情况、caption speech 实际效果及计费、完整 App / 云端部署验收。现有授权与素材齐备后再做；不会把缺条件视为通过。

功能开发 45/45、检测验收 7/47 保持；本轮为既有任务的扩展切片，不增加整项验收通过数。

代码提交：后端 dev `b1c9a03c`（未推送）。
