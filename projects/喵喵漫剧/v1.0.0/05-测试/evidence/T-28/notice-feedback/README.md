# T28-NOTICE-01 本集通知与原操作恢复

2026-10-17，开发阶段。App dev `4630cd623d909c4cc761ebd963834903463bdb5f`，父提交 `384ebb0`，未推送或部署。后台、API、DDL、迁移、依赖与媒体实现未改，本轮未运行后台测试。上一轮[完整重分析联测](../reanalysis-journey/README.md)保留。

本集页面此前给所有message都绑定`onRetry=c.load`，成功保存、应用分析和取消核对也显示重试。旧代码在实际双端图中已观察，本轮先增加取消后的真实Widget断言，再在未改生产代码时[复现失败](red-test.json)：发现1个本应不存在的“重试”。

现在Controller单独记录可重读的读取错误。开始重读清除旧错误，普通刷新保留成功/取消信息；读取中、操作中、离页或身份变化时不提供重试。保存、分析就绪、应用、恢复和取消都不提供通用加载按钮。未知动作沿原记录恢复；保存/应用/恢复使用“继续原操作”，分析仍使用“继续查询本集分析”。保存PATCH沿既有expectedRevision CAS，丢回执时先GET核实同一集；没有新增幂等头或第二次提交。

| 检查 | 实际结果 |
|---|---|
| App专项 | 3个新增Widget场景，原取消场景补实际按钮断言；最终39相关通过，0失败/跳过 |
| 全套与静态 | 最终1249项通过，0失败/跳过；analyze与5个Dart文件格式检查通过 |
| Android | 自有API37/16KiB模拟器，3个实际作品/剧本/素材方法；13张带当前PID校验和序号确认的系统截图 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器，同样3个方法及13张系统截图 |
| 原请求恢复 | 同一表单保存成功后丢回执；原key在公共KV保持，点击继续后GET核实，PATCH始终1次、生成/分析POST为0 |
| 原候选与导航 | 取消保候选ID和原镜头；逐集本机稿、素材读取保存版本、写盘失败留页等既有导航回归通过 |
| 环境恢复 | 自有模拟器停止；Android21个/iOS43个原相册视频及权限完全保持；未卸载App，未操作USB物理机 |

四个可执行切片场景的前置、数据、步骤、预期、实际与证据见[case-results.json](case-results.json)。这只补TC-17-01/02/04的部分证明，正式186条正文/状态未改，父任务仍未完成。HTTP为Dio受控适配器，未声称本轮有真实Java、AI/OSS、物理设备或最新Figma验收。

可直接查看的页面证据：

- [读取失败仍可重试](native-01/android/android-script-read-failed-os.png)、[读取恢复并清除旧错误](native-02/ios/ios-script-read-recovered-os.png)。
- [未知保存显示继续原操作](native-01/android/android-script-original-save-recovery-os.png)、[恢复后只显示成功信息](native-02/ios/ios-script-save-recovered-os.png)。
- [取消候选保原结果且无重试](native-02/ios/ios-script-cancel-info-os.png)。全部26张原系统图见[screenshots.json](screenshots.json)，均已通过联系表查看。

检测修正没有改变生产契约或放松业务断言：

- 第一轮专项误写了旧视频测试路径，产生1个加载错误；另2个新Widget在enterText后未重建按钮便点击了旧禁用组件。改为等待一帧再点，最终39项通过，原失败输出保留。
- Android宿主初版预期12张，实际为13张，因计数退出1；SDK的+5包含两个全局hook，实际业务方法3个。iOS宿主又误要求CAS PATCH携带POST幂等头，退出1。两端App自身测试和严格driver均退出0，三份完整报告及26张系统图存在。纠正宿主校验后，对原成功报告、请求顺序、图片摘要和恢复结果做只读复核，未重跑成功场景；原宿主失败和cleanup中的testPassed=false均保留，未改成成功退出。
- Widget第一次读取恢复截图取到了过渡帧。补稳态等待与实际输入框/作品标题断言后专项和全套重新通过；原11张图保留。最终Widget `episode-script-375`仍有局部未绘制，桌面字体也无emoji；它们不作为外观结论，页面外观以26张实际系统图为依据。

[最终专项](related-final.json)、[最终全套](full-verified.json)、[静态检查](analyze-verified.json)、[格式](format-final.json)、[Android只读复核](native-01/android/host-recheck.json)、[iOS只读复核](native-02/ios/host-recheck.json)、[宿主/截图修正](test-harness-corrections.json)、[原始输出归档](log-archives.json)、[源码](source.json)、[范围核对](scope-check.json)、[环境复检](cleanup-recheck.json)。日志gzip无损保存，原始摘要可核实；私有originals仅作本机恢复，不提交。

复现入口为App `test/projects/analysis_diff_test.dart`、`test/editor/video_replace_test.dart`、`integration_test/episode_navigation_test.dart`及`test_driver/catdrama_business_driver.dart`。本目录的`run_app_checks.py`执行related/full/analyze；`run_native.py`只允许指定自有模拟器、新目录运行，并复用上一轮冻结的只读设备工具，不启动后台。`verify.py`只读检查已交付证据，不执行业务或操作设备。

T28-NOTICE-01在本机与模拟器范围关闭，覆盖上一轮待修状态。47任务仍为7完成/38进行中/2外部，186条仍9通过/172部分/5未执行；保持开发阶段。本轮用量未取得，未额外查询。
