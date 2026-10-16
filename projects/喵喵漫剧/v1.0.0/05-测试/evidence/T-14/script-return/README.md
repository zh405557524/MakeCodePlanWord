# T-14 制作设置返回作品剧本与参数保留

2026-10-16，保持开发阶段。App dev `7bb692ce`，未推送或部署。本轮补齐已批准制作设置的返回改稿路径；后台、API、DDL/迁移、依赖及原生实现均未修改，未重跑后台。T-14及TC-08-01/04保持部分验证。

| 范围 | 已核实结果 |
|---|---|
| 自动检查 | 新增9项，制作设置/改稿相关64项与全套1030项App通过，0失败/跳过；analyze和6个Dart文件格式通过 |
| 分集入口 | 复用原选择弹层和episodeScript，稳定ID、真实标题和不可访问原因；取消不改内容，30集末项可选，不返回只读创作草稿 |
| 参数保护 | 原公共GetStorage队列先落盘；失败留页/重试，重复动作、切号及到期不跳转，返回刷新并保留原选择 |
| 版本与提交 | 剧本保存导致作品revision变化时沿既有明确核对；参数保存与分析独立，实际受理快照逐字使用新保存稿，第一集/期限保持 |
| Android | 自有API37/16KiB模拟器3项业务方法通过；真实页面、本机HTTP、公共KV，10张系统截图 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器同样3项业务方法通过，10张系统截图 |
| 驱动复检 | 新截图名称和完整业务报告守卫已补；iOS默认SDK模式另跑3项通过，10份SDK缓冲图只验证采集传输，不作为最终系统图或视觉验收 |
| 图像 | 最终20张系统图与3张375×812 Widget图，关键8张系统图和全部3张Widget图已查看；另查看1份SDK缓冲图，其取帧不作为滚动后状态证明 |
| 待验范围 | 真实Java/AI/OSS、最新Figma、物理设备和完整分析执行链；正常App入口构建、OS磁盘耗尽及强杀本轮未测 |

实际流程为制作设置选择第二集→真实剧本页输入Unicode正文→明确保存→返回设置保留1080P/15秒/9:16原选择→按新revision明确核对→独立保存设置并提交一次分析。导航本身无作品创建、重拆或分析提交。两端各核实一次剧本PATCH、一次设置PATCH、一次分析POST及最终稿快照；未知原任务及缺配置恢复继续沿既有Job服务，不新建任务。

未新建页面、路由、Service、KV或任务轮询。选择器只回传ID，Controller处理范围、实际写盘和返回刷新；忙碌期间冻结变更，写盘后重新检查账号/期限。设置冲突沿既有确认，不自动覆盖服务器或丢弃本机参数。

初检与修正均留证：

- 首轮编译失败是测试局部pumpIO声明在引用之后，另一次格式检查发现async import位置错误；均在设备测试前修正。
- 选择器初始没有选中集，测试连续点击选项和确认时尚未经过一帧重建，确认按钮仍禁用；现在等待真实选中状态刷新后点击，没有去掉禁用或业务断言。单独诊断失败也保留。
- 原多路由Widget用例固定等80ms后进入runAsync，首次加载/写盘未结束时挂起。两次确认持有的进程中断，不计通过；改为等待两个真实loading状态结束，独立选择、释放旧实例和真实保存断言不变。诊断1项及最终64相关/1030全套通过，临时trace已去掉。
- 驱动原截图白名单不包含新增四种状态，已补齐；空报告或缺少三份业务结果时必须失败，不能用SDK的0退出证明通过。更新后iOS默认SDK模式实际复检通过；原两端OS模式报告也分别核实。

[结果](result.json)、[自动汇总](app-test-summary.json)、[用例范围](case-results.json)、[Android报告](devices/android-production-device-result.json)、[iOS报告](devices/ios-production-device-result.json)、[SDK复检](devices/sdk-ios/ios-production-device-result.json)、[截图清单](screenshots.json)、[源码摘要](source-hashes.json)、[提交范围](app-commit.json)、[清理](cleanup.json)、[初检记录](initial-findings.json)、[Figma实际状态](figma-check.json)。

复现自动入口：App的`test/creation/production_test.dart`和`test/projects/analysis_diff_test.dart`，设置`CATDRAMA_T14_SCREENSHOTS`保存Widget图。原生入口为`integration_test/production_flow_test.dart`和`test_driver/production_driver.dart`；设置`CATDRAMA_PRODUCTION_EVIDENCE_DIR`、`CATDRAMA_TEST_PLATFORM`。默认SDK采集接受10种名称；系统截图通过`CATDRAMA_CAPTURE_PORT`和既有`capture_native.py`握手，每平台预期10图。Android宿主转发端口与访客端口分开。

[1030项机器结果](app-tests.jsonl)、[64项相关](related-final.log.gz)、[最终analyze](analyze-driver.log.gz)、[格式](format-verified.log.gz)、[Android](android-drive.log.gz)、[iOS](ios-drive.log.gz)、[SDK驱动](ios-sdk-driver.log.gz)。日志gzip无损保留，失败/中断轮次也归档；[归档清单](raw-output-archives.json)附还原摘要，JSONL原样保存。`originals/`仅本机恢复，不入提交。最终全套之后只有驱动和说明文件改变，运行代码/单元测试字节不变，更新驱动已实际复检。

真实HTTP仅连接测试App内的协议服务器，受理快照不是实际Java调度或Provider分析执行；注入写盘错误不代表系统磁盘耗尽。Figma rq4owed6实际未连接，沿已批准P-10/5:6503、原选择弹层及公共主题，不记最新对稿通过。只停止本轮QA设备/采集器，未改相册权限/相册文件、未卸载App、未启动PG或操作生产。47项仍7完成/38进行中/2外部，186条仍9通过/172部分/5未执行；未推进测试阶段，历史3项公共后端夹具失败保留。
