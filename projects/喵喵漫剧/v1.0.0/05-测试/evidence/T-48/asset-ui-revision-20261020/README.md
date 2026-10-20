# T-48 资产创建UI修订开发检查

按用户最终批准计划落实。App提交 `6261697`，后端提交 `b958137d`；未推送、未部署。

- 产品最多9张，模型自身能力独立保留。配置返回有效数量，App/报价/提交执行同一上限；0/1/9通过，第10张拒绝，较低上限同样约束。
- 移除计数、编号、排序、能力说明和独立预览；按选择顺序提交，切模型保留图片，不合规Toast并阻止生成；不支持时禁用上传。
- 风格默认不选，选中加框，再次点击取消，“应用”提交、关闭取消；移除“不指定风格”项。创作模型和风格面板依据Figma现稿核对。
- AI帮写保持原流程，失败Toast；使用现有相册插件、AssetImagePreviewDialog、AppDesignedConfirmDialog和历史形象。费用来自后端，取消、异常保留表单，未知任务沿原身份恢复。

## 验证

App相关155项全部通过（[日志](app-tests.log)）；限定范围analyze无问题（[日志](app-analyze.log)）。后端54项通过（[结果](backend-result.json)）：能力4、真实资源校验8、配置17、图片报价/任务25。测试覆盖顺序、切模型、取消风格、无默认风格、报价取消/失效、候选应用、历史和删除保护。

App命令：`flutter test --no-pub --concurrency=2 test/assets/asset_test.dart test/assets/asset_description_test.dart test/assets/upload_test.dart test/assets/image_model_options_test.dart test/assets/image_workbench_test.dart test/generation/quote_test.dart --reporter expanded`。

后台独立构建目录 `.local/catdrama-tests/asset-ui-revision-build`，执行上述4个测试类，使用自己创建的隔离PostgreSQL，结束后停止。首轮共享构建目录发生类加载错误，原记录保留于后台 `.local/catdrama-tests/asset-ui-revision-20261020/`；独立复检记录在 `asset-ui-revision-20261020-recheck/`，没有重启共享8080。

## 截图与边界

截图见[screenshots](screenshots)。375×812组件环境；已检查创建选项、模型及风格面板，修正“创作模型”文案和无预览图时选中仅加框。Figma通道9cr1hh85，节点43:2604/3324/3416/3505/3601/3727。没有伪造缺失的风格预览图。

这是代码与组件开发检查，不代表真机、已部署端到端或用户视觉验收。本次没有新增供应商调用，既有四次豆包调用保留历史记录；没有声称真实九图生成通过。GPT Image 2能力核验、新风格样图及后台新增UI仍按原边界处理，本次不扩展。原45项基线、正式186条统计及并行T-49～56未改。

[机器摘要](result.json)
