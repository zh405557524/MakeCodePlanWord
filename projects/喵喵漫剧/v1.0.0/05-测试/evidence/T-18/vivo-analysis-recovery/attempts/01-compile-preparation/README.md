# 检测代码准备失败记录

新后端测试的预置参数PATCH表达式多了一个右括号，首次compileTestJava退出1，未执行测试方法；新手机测试有3处if缺少花括号，静态检查退出1。二者均只在新检测代码中，修正后实际构建及完整测试通过，未修改生产实现。

[失败摘要](failure.json)、[后端检查](backend-tests.json)、[自有数据库清理](database-cleanup.json)、[PG停止](support-cleanup.json)。当时没有构建、安装或启动手机测试包，没有业务验收通过记录。修正前源码和原始构建日志保留在本机忽略的`originals/`，后续完整通过见[最终证据](../../README.md)。
