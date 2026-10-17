# T-42 旧反馈用例等待复检

2026-10-16，开发阶段。App dev独立提交 `f1d8c9d9cdf26c1e83b682d2323dceba8633b4f5`，仅修改 `test/settings/settings_test.dart`、`test/support/settings_fixture.dart`，未推送。

T-22全套回归中，“等待期间连点仅一个公共POST”实际期望1却读到0，见[原失败](failure-summary.json)。HTTP服务在进入适配器前异步取得公共设备标识，固定10ms不保证请求已进入；此证据不代表重复提交业务失败。

夹具在真正收到公共 `/api/feedback` POST并累计次数后发出Completer信号，仍保留原响应释放门。重复点击、迟到手改、切号三条既有用例改为有5秒上限地等待该信号；原一次POST、输入保护、切号隔离等断言均保留，不改反馈或HTTP运行代码，不新增测试方法。

29项设置方法通过，[原输出](settings-final.log.gz)。与T-22改动合并的最终全套1073项通过、0失败/跳过，见[完整输出](../../T-22/budget-details/full-tests-final.jsonl.gz)和[方法统计](../../T-22/budget-details/full-suite-summary.json)；1073不是本任务新增方法。最终analyze通过，两文件格式0改动，详见[结果](result.json)、[提交](app-commit.json)、[输出字节清单](raw-output-manifest.json)。

可在App仓库运行 `flutter test test/settings/settings_test.dart` 复检；全套用 `flutter test --machine`。本轮没有重跑后台，不改变已有3项旧公共后端夹具失败结论；T-42完整隔离/恢复及真实渠道验收仍未完成。原文件与工作区快照只留本地originals。
