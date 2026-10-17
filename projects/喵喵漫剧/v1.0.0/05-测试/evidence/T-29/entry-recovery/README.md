# T-29 剪辑准备入口、下载取消与缓存确认

2026-10-17；App `dev` 提交 `dedb157e7bc1085ebddd87c99fe2a717483bec26`。当前仍为开发阶段；本轮补完入口安全与受控双端场景，T-29整项仍待真实OSS、最新Figma和物理设备联验。

## 修改与覆盖

- 准备页复用UserPageScope，固定账号、环境及实际后台。切换后清除旧预算和私有视图，停止原尝试；旧清理弹框不能删除另一个账号的文件，也不能改上限、重试或迟到进入编辑。
- 清理须先预览，再确认同一个MediaCacheScope；取消不删文件。有效作品引用的源视频继续受保护；上限校验复用CacheService，不新增存储或公共账务。
- GetBuilder的key/tag同时含作品和分集ID，换集释放旧Controller。每次尝试只释放自己的进度Worker。
- 取消先冻结离开并使旧回调失效，等待原下载停止，再返回原入口；重复点击只离开一次。源文件和断点仍由已有下载/缓存服务管理。
- 原型、设计、产品/技术/上线文档、接口、数据库、公共下载/缓存账本和原生引擎未改。本轮没有引入手机FFmpeg。

## 实际结果

| 检查 | 结果与证据 |
|---|---|
| 修正前有效回归 | 原源码上8条均失败；[红灯](before-fix.log)、[原稿](originals/app) |
| 新增回归 | 16/16，含账号/环境/后台、未预览禁止删、取消、过时结果、路由身份、正常清理保护与上限；[日志](boundaries.log) |
| 相关回归 | 88/88，含准备服务、缓存、下载、Hive工程及页面；[日志](related.log) |
| 全套App | 1160/1160，失败0、跳过0；184条隐藏夹具终态不计业务方法数；[JSON事件](full.jsonl) |
| 静态与格式 | analyze无问题；7文件格式0改动；[analyze](analyze.log)、[格式](format.log) |
| Android/iOS | 各1个原生方法覆盖3组场景，退出码0；[Android](android/android-editor-preparation-result.json)、[iOS](ios/ios-editor-preparation-result.json) |
| 路径门禁 | 重建脚本已有提交bf956b4c；5条自测、语法、逐路径check及工作区audit通过；[日志](path-guard-selftest.log) |

三组原生场景沿生产CustomRouter和实际页面，使用真实回环HTTP、私有文件、Hive、设备空间读取和原生媒体引擎。后台项目/清单及账号采用隔离协议夹具，媒体为受控H.264/AAC样片，不代表真实AI/OSS或物理设备验收。

1. 600MiB当前必需源超过默认500MiB时显示真实预算和清理确认；取消保文件，切换账号再确认保两个账号的文件、隐藏旧预算且不重试原请求。
2. 73352字节原视频下载后摘要与原生校验一致，320×180预览显示实际样片；保存的固定工程离线再进时，不追加项目/清单查询或媒体下载，不因未引用的600MiB镜头阻塞。
3. 活动下载实际收到12000字节后取消，返回同一作品Controller；等待旧准备页释放，确认无迟到编辑/工程、空间预留释放且部分文件保留。用户显式再进发送Range `bytes=12000-`，实际第二次HTTP后原生预览成功。

保存16张系统截图和4张375宽Widget截图；[Widget总览](widget-contact.jpg)、[Android总览](android-contact.jpg)、[iOS总览](ios-contact.jpg)。20张已总览，另详看iOS清理确认、Android字节进度和iOS续传后编辑器。未发现此范围内的文案截断、旧预算泄漏或缺失预览；未将这些截图记为最新Figma通过。

## 复现

在 `/Users/soul/code/lxwx/catdrama` 使用工程Flutter运行：

```sh
flutter test --no-pub test/editor/preparation_entry_test.dart test/editor/preparation_ui_test.dart test/services/editing_prepare_test.dart test/services/editing_cache_test.dart test/services/media_download_test.dart test/editor/local_store_test.dart
flutter test --no-pub --reporter json test
flutter analyze --no-pub
```

原生目标为 `integration_test/editor_preparation_test.dart`，驱动为 `test_driver/catdrama_business_driver.dart`，`CATDRAMA_TEST_SLICE=editor-preparation`。以 `--target`、`-d`、`CATDRAMA_TEST_PLATFORM`、`CATDRAMA_BUSINESS_EVIDENCE_DIR` 和 `CATDRAMA_CAPTURE_PORT` 明确选择；系统采集器 `test_driver/capture_native.py` 的预期截图数必须为8。Android访客19153映射到宿主端口；iOS使用19154。驱动核对三组报告，缺失报告或失败不能以SDK退出码替代通过。

[源码冻结](source-freeze.json)涵盖本轮7份代码/检测文件；全套1160结束后仅调整了原生测试的流式响应、错误Zone和实际释放等待，生产代码与单元/Widget源码未再改。最终原生检查沿当前冻结源码执行。[复核脚本](verify.py)核对终态、文件摘要、截图、186条正式定义、受保护文档及无关工作区状态；运行 `python3 verify.py`。

## 失败记录与限制

`attempts/01`至`06`保留Widget挂载/路由参数、缺失import、账号前置及格式检查的实际失败；最终before-fix为已补齐前置的8条行为红灯。原文件与修正前后日志均保留。

`attempts/07-android-slow-response`：8192字节测试响应缓冲导致未获得部分进度，2组成功、取消前等待失败；驱动退出1、采集器停止130，未记通过。改为关闭缓冲、12000字节显式flush。

`attempts/08-native-test-zone`：静态生产路由把后续取消错误投递给已结束的首个测试，断言失败后跨错误Zone的Future阻滞清理；保存报告/日志后停止原驱动。SIGINT后驱动返回0也没有算通过。改为一个有效testWidgets错误Zone内依次初始化三组场景。

`attempts/09-pop-transition`：原页面出现时退出动画尚未释放旧Controller；保留关闭断言，改为等待实际isClosed，不用固定延时。最终两端均完整通过，失败截图没有混入最终16张。

本轮未运行后端测试，原T-29后端证据保留。Figma rq4owed6返回Not connected，记录于[连接结果](figma.json)。物理设备、真实私有OSS/Provider、真实网络性能与完整业务链待后续验收；正式186条仍为9完整通过/172部分/5未执行。本轮未写生产配置、推送、部署或推进阶段。自有Android AVD和iOS模拟器均已恢复停止，5个明确自有ADB映射已移除。
