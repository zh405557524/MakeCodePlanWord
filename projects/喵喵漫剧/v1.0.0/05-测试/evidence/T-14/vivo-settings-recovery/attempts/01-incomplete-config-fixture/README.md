# 首轮受控配置夹具失败

真实作品读取成功，但后端测试目录的`limits`为null。实际客户端按现有严格契约拒绝配置，测试随后解引用空的选择，首阶段失败；尚未选择参数、保存或提交分析，不能据此判定恢复业务失败。

原完整App报告和后端旅程均未通过，另16项既有后端测试通过。该批不计手机恢复通过或完整业务验收，没有系统阶段截图。修正只涉及新测试：提供既有DramaLimits字段，并在手机测试解引用前明确检查配置与选择；生产实现保持。

[失败摘要](failure.json)、[App驱动](driver-selection-seed.json)、[后端方法数](backend-tests.json)、[手机报告](android/selection-seed-result.json)、[手机清理](phone-cleanup.json)、[自有数据库清理](database-cleanup.json)、[PG停止](support-cleanup.json)。原始APK、日志、JUnit XML及修正前源码保留在本机忽略的`originals/`；未覆盖或删除失败证据。修正后使用新建临时数据库及重新构建的测试APK，完整通过记录见[最终结果](../../README.md)。
