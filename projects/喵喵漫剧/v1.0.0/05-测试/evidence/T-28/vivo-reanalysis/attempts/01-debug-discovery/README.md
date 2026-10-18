# 首轮调试服务观察失败

手动启动的App没有取得可连接的VM URI，宿主观察到期后退出。原启动回执与日志留存，但不足以确定具体原因；0条手机业务方法执行，不能记业务恢复失败或通过。App已按安装包摘要核对移除，原转发/设备锁恢复，隔离PG停止。

同时App检查命令误加不存在的`test/projects/episode_script_test.dart`而退出1，后续只运行计划中的实际文件`analysis_diff_test.dart`，30项通过。19项后端差异测试在本轮独立通过；手机旅程因abort失败，整轮退出1。后续源代码未变，复用这19项结果，只重跑真实手机旅程。

下一轮改用现有Flutter二进制启动和严格driver，型号由实际设备前检与完整报告核对；修正宿主预期了观察接口不存在字段的问题。没有修改生产代码或弱化原镜头/视频/工程断言。

[失败摘要](failure.json)、[后端原结果](backend-tests.json)、[App原命令](focused-tests.json)、[手机清理](phone-cleanup.json)、[PG停止](support-cleanup.json)。原APK和原始日志在本机忽略的originals中；含系统原始启动日志的私密文件不作为公开压缩日志交付。[最终结果](../../README.md)。
