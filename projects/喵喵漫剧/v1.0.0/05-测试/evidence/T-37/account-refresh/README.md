# T-37 我的页面：并发刷新与迟到回执

2026-10-17，App dev `c550bb6`。修复 T37-REFRESH-01：第一次读取尚未完成时，从子页返回、切回“我的”或恢复前台的刷新被 `loading` 提前返回拦截，积分可能停留在操作前。范围是已有公共账户摘要的读取协调，未改后台、账务、接口、存储、依赖或原生媒体引擎。

主动刷新现在开启新一轮读取，两路资料/账户回执沿原代次和会话守卫。旧回执不能覆盖新结果或结束新一轮加载；新账户读取失败保留已核实余额并提示。首次初始化的延后读取与已经启动的主动读取合并；隐藏、未登录和关闭页面的守卫保留。

## 实际检测

- 修复前最终复现：5项中4项失败、隐藏页面控制项通过；失败分别是子页返回、Tab返回、恢复前台丢刷新，以及新读取未启动。初次测试的路由等待和隐藏页错误定位另保留为测试错误，没有据此改业务。
- 新增5项 Widget 回归；首页及账号27项通过，完整App **1222项通过、0失败、0跳过**。原账户读取失败重试及退出后的迟到隔离也在本轮专项内。首载与主动读取不重复请求的断言加在既有用例中，不另算新方法。[逐项结果](test-summary.json)。
- 实际挂载 MainPage/AccountPage，通过公共入口和 BackButton 返回；使用生产 RouteObserver、Tab事件及由测试触发的框架生命周期通知。Dio适配器控制资料迟到及账户失败；合成账户从3137变为8580只表示接口输入，不代表实际充值或领奖。
- 全工程analyze无问题，2个Dart文件格式检查无变化，diff空白检查通过。[检查结果](checks.json)、[固定提交与源码摘要](source.json)。

本轮没有运行移动设备、系统前后台、原生构建、真实Java服务或支付渠道，也没有新增页面或视觉验收；前轮的构建/设备结果保持历史范围。既有真实Provider/OSS/ASR、支付、最新Figma及真机待验项不因此关闭。

## 复现与边界

在 `/Users/soul/code/lxwx/catdrama` 使用既有Flutter和锁定依赖：

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn /Users/soul/data/flutter/flutter/bin/flutter test --no-pub test/pages/home_test.dart --reporter json
PUB_HOSTED_URL=https://pub.flutter-io.cn /Users/soul/data/flutter/flutter/bin/flutter test --no-pub --concurrency=1 --reporter json
PUB_HOSTED_URL=https://pub.flutter-io.cn /Users/soul/data/flutter/flutter/bin/flutter analyze --no-pub
/Users/soul/data/flutter/flutter/bin/dart format --output=none --set-exit-if-changed lib/pages/account/controller.dart test/pages/home_test.dart
```

当前源码已修复；修复前生产实现由 `baseline.json` 的App提交固定，失败原始输出和源码快照留在本切片忽略的 `originals/`，不会切换或回写工作树。`verify.py`仅核对固定证据、提交及文档边界，不重跑业务。[原始文件摘要](raw-manifest.json)、[路径检查](guard-result.json)、[范围复检](scope-check.json)。

仅补充 [TC-22-05](../../../测试.md#tc-22-05) 当前账户读取的部分证据；正式186条正文及9通过/172部分/5未执行保持。47项仍7完成/38进行中/2待外部，T-37整项未完成，阶段仍开发。12份产品/设计/技术及基线文件摘要保持，其他仓库已有改动保留；本轮只提交前端4文件和工作区本切片，未推送。
