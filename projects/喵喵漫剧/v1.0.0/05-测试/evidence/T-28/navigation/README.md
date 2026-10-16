# T-28 本集切换、素材入口与改稿保护

2026-10-16，仍在开发阶段。App dev `959f64f8`；旧缓存弹框测试等待修正独立提交 T-42 `f3573cdb`。本次补齐获批P-13的切集和进入本集素材，未改后台、API、DDL、迁移、依赖或原生媒体实现，未推送、部署。T-28整项及TC-17-01继续部分验证。

| 范围 | 实际结果与边界 |
|---|---|
| App自动检测 | 新增9项；本集剧本27项、含设置回归共56项通过；最终全套1010通过、0失败/跳过。analyze及8文件格式检查通过 |
| Android | 自有API37/16KiB模拟器，2个业务方法通过；实际作品详情→剧本→素材三页及公共GetStorage，逐集手改互不覆盖 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器，同样2个业务方法通过；显式保存后scriptRevision=2，原素材仍可查看 |
| 导航副作用 | 切集和查看素材只存本机稿，0个业务写请求；只有点击保存作品剧本才PATCH一次，始终没有分析或生成POST |
| 异常与恢复 | 真正等待KV队列屏障；写失败留页保稿、重复跳转不改目的地、晚到输入一并保存；切号、到期、未知剧集/不可访问入口及深链返回已测 |
| 图像 | 最终14张系统截图，每端7张，关键6张已查看；另6张Widget截图。OS模式没有同时调用SDK截图，计数不重复 |
| 外部边界 | HTTP为Dio边界夹具；实际页面、路由及公共KV在手机模拟器执行。没有实际Java部署、AI/OSS、物理设备、OS磁盘耗尽或进程强杀证明 |

新增剧集选择与素材按钮复用现有路由和Figma公共组件。导航前等待完整本机稿实际落盘，不隐式提交作品正文、分析或生成；未提交的手改明确说明素材仍对应上次保存的版本。写盘期间冻结输入和重复动作，晚到输入也会保存。写失败保留表单，账号和期限变化后不跳转；进入素材和切集按真实项目中的集ID/entryState核对。返回使用公共popOrMain。

实际测试发现query变化时GetBuilder可能沿用上一集Controller；现在同时按路由实例及集身份设置key/tag。双端来回切集均恢复各自本机正文，原服务端正文不变。显式保存时才更新作品正文和scriptRevision，并保留“旧分析尚未更新”提示；导航不消费候选、替换视频或改本机时间轴。

初始问题和失败保留：

- 首轮路由测试验证出缺少GetBuilder key；另一次人为磁盘屏障被FakeAsync测试区阻塞，确认持有进程后中断，不计通过。调整检测执行区，没有关闭持久化断言。
- 边界夹具最初只有7800码点，已改为10200；存储队列包装底层FileSystemException，检测仍核实原注入错误。新路由采集器缺RepaintBoundary导致3项截图失败，补齐测试容器后27项通过。
- 首次全套1009通过/1错误：旧缓存清理测试只等固定50ms，弹框读取实际磁盘尚未完成。改为有上限地等真实弹框，原范围、取消不删和清理量断言不变；最终1010全过，生产缓存实现不改。
- iOS首轮故障注入前，键盘收起已触发500ms自动保存，因此没有待写稿可失败。将最后一次输入明确放到故障屏障后，保持失败必须留页的断言；最终两端通过。
- Android一次setUpAll采集端口占用，业务方法执行0次，SDK却返回0并打印成功。该轮报告为空，未计通过；改为独立宿主转发端口和低位访客端口。通用驱动新增本切片的两份完整报告检查；最终Android执行该守卫，iOS原报告另逐字段核实。

[结果](result.json)、[用例范围](case-results.json)、[Android报告](devices/android-episode-navigation-result.json)、[iOS报告](devices/ios-episode-navigation-result.json)、[截图清单](screenshots.json)、[源码摘要](source-hashes.json)、[清理](cleanup.json)、[故障注入复检](native-fault-injection-correction.json)、[端口及误报记录](capture-port-correction.json)。

复现入口为App仓库 `test/projects/analysis_diff_test.dart`、`test/settings/settings_test.dart` 和 `integration_test/episode_navigation_test.dart`。设备驱动沿 `test_driver/catdrama_business_driver.dart`，设置 `CATDRAMA_TEST_PLATFORM=android/ios`、`CATDRAMA_TEST_SLICE=episode-navigation` 与证据目录。`CATDRAMA_CAPTURE_PORT`为App内采集端口；Android应将宿主端口forward到访客端口，再把宿主端口传给 `test_driver/capture_native.py`，每端预期7张。不能把宿主空闲端口当作访客同号端口空闲。

最终日志：[全套机器结果](app-tests-final.jsonl)、[56项相关](related-final.log.gz)、[Android](android-drive.log.gz)、[iOS](ios-drive.log.gz)、[analyze](analyze-driver-guard.log.gz)、[格式](format-verified.log.gz)。本轮未重跑正常App入口构建或后端；集成构建不当作正常App构建。最终全套之后只修改设备检测的故障注入、宿主报告守卫和说明文档，App运行代码及单元测试保持该轮已测版本。

日志gzip无损归档，原始失败/中断也保留，JSONL原样保存；[归档清单](raw-output-archives.json)附原始摘要和还原核实。`originals/`仅为本机恢复，不入提交。rq4owed6实际未连接，P-13索引无独立Frame；沿获批旧参考/公共组件，不称最新Figma验收通过。真实AI/OSS、物理设备及完整重新分析仍待验收，历史3项公共后端夹具失败保留。整项统计7完成/38进行中/2外部，186条用例9通过/172部分/5未执行；未推进测试阶段。
