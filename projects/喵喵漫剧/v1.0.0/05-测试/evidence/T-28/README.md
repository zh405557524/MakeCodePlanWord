# T-28 实施与检测证据

本轮实现本集改稿、原文稳定身份、分析差异确认和移出恢复。源码按任务分别提交，详见[result.json](result.json)、[源码摘要](source-manifest.json)、[用例](case-results.json)。整项仍未完成，下一步按原计划T-36；未推送、部署或推进阶段。

- 后端最终134项，0失败/错误/跳过；其中T-28新增19项，原JUnit以gz逐字节保留[junit](junit/)，XML展示副本仅清理行尾空白。[统计](backend-summary.json)、[日志](backend-final.log)。
- App相关112项，T-28新增18项；最终聚焦18项重验不重复累加。[统计](flutter-summary.json)、[相关日志](flutter-related.jsonl)、[最终聚焦](flutter-targeted.jsonl)、[analyze](flutter-analyze.log)、[格式](flutter-format.log)。
- 初始编译/夹具/业务缺陷与修复前日志保留在[failures](failures/)。恢复时重复NULL赋值为实际PG缺陷；原文覆盖、旧稿/视频、幂等和断言均未放松。
- App无依赖或原生配置变更，不因此重复打包；未执行真实模型/OSS和两端完整流程。后台测试使用真实Spring/JWT及自有PG，文本/媒体为受控边界，不能充当Provider证明。

源码工作目录为App `/Users/soul/code/lxwx/catdrama`、后端 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，分支均dev。后端命令需自建隔离PG环境：

```sh
./gradlew test --offline --tests '*CatdramaAnalysisDiffTests' --tests '*CatdramaAnalysisTests' --tests '*CatdramaShotTests' --tests '*CatdramaProjectManageTests' --tests '*CatdramaProjectCreateTests' --tests '*CatdramaMarkdownTests' --tests '*CatdramaMarkdownPersistenceTests' --tests '*CatdramaVideoTests' --tests '*CatdramaAssetScopeTests'
flutter test --no-pub test/projects/analysis_diff_test.dart test/projects/project_detail_test.dart test/creation/production_test.dart test/shots/shot_detail_test.dart test/shots/video_generation_test.dart
flutter analyze --no-pub
```

三张图为实际Widget，已逐张查看。测试加载随包Noto Sans SC供CJK渲染，未改变生产界面字体；不视为Figma批准或手机验收。

![本集改稿](episode-script-375.png)
![分析差异明细](analysis-diff-375.png)
![320宽过时差异禁应用](analysis-stale-320.png)

数据库改动：无DDL、迁移或存量修复。自有随机schema结束清理后0，自有PG已停止；没有清理别的数据库或schema。
