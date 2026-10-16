# T-06 首页、案例资源缓存与草稿连续恢复

2026-10-16，仍在开发阶段。App dev 功能提交 `37948821`，旧分析测试等待修正单独提交 T-42 `28efa442`，截图数量核实另提交 `b5472d1e`。没有推送、部署、后台代码、接口、DDL、迁移或依赖变更。T-06 整项及 TC-01-01/02/03 保持部分验证。

| 范围 | 本次结果与边界 |
|---|---|
| App自动检测 | 新增16项：案例媒体15项和封面实际解码1项。最终全套1001通过，0失败/跳过；相关59项、analyze及13文件格式检查通过 |
| 既有后端 | CatdramaConfigTests 14、CatdramaResourceTests 18，共32通过。前者使用H2及真实公共服务，后者使用Mockito OSS；没有真实云端资源联验 |
| Android | 自有API37/16KiB模拟器，4个业务方法通过；实际本机文件交给原生播放器解码、暂停及释放，重开不重复签名或传输 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器，同样4个业务方法通过；没有把setup/teardown计入业务方法 |
| 草稿 | 实际MainPage四Tab往返、公共GetStorage及DraftSyncService重建后恢复同一原稿ID101/revision2，创建仅一次。同款另建ID102，只带允许风格ANIME，原稿不变 |
| 文件 | 两端各一份实际缓存视频和封面，共4份媒体。视频11884字节、H264/AAC、160×90/24fps/2秒，SHA与夹具原文件一致，宿主独立完整解码通过 |
| 图像证据 | 最终20张系统截图，每端10个状态；其中首页成功及恢复原稿的两端4张已查看。系统采集模式没有同时调用Flutter截图，不能重复计为40张；清单记录了此项草稿统计修正 |
| 视觉依据 | rq4owed6实际返回Not connected to Figma。沿已缓存首页5:780及获批P-02参考，不改设计；最新Figma未验收。案例封面刻意复用本包已有首页图，视频为自制诊断片，均不证明运营内容或AI画质 |

封面和视频统一通过 `ResourceService.localFile`，磁盘身份按资源ID、账号、环境和后台隔离，签名不写持久缓存。公开签名请求不带账号凭证；公开与私有签名请求独立核实，同一文件的实际传输合并。视频在点击播放后才准备，重开读同一缓存文件；显式重试只移除损坏的具体资源，活动文件与其他媒体保留。401/403最多重新签名一次。

实际发现并修正：

- 首页卡片外层Obx没有监听AppStateBuilder内部迟到的文件结果，文件就绪后仍显示“正在加载案例”。卡片增加独立Obx，Widget及双端测试均要求RawImage已经实际解码，最终首页截图已核实。[失败图](failures/home-cover-not-refreshed.png)、[修正记录](cover-render-correction.json)。
- 视频初始化期间切后台或离开，旧初始化完成可能自动播放。控制器增加前台状态和代次保护；测试覆盖迟到结果。此处生命周期为方法调用，不冒充OS实际切后台验证。
- 原“未知分析重进”测试等到diff发布就检查pending为空，早于持久化和原任务收尾。只调整等待条件，保留原幂等键和一次分析断言；不修改生产业务以迁就测试。首次全套997通过/1失败保留，最终1001通过。
- iOS截图最初包含导航转场，采集前等待布局稳定。另一次封面测试因FakeAsync等待帧的测试写法停滞而被主动中断，该轮不计通过；修正检测等待后59项相关及1001项全套通过，没有关闭原断言。

案例页进入真实创建页后，新草稿只接收允许风格，名称和原文为空；保存新稿不会改写旧稿或复制案例视频、生成记录及作品归属。双端使用真实页面、GetStorage、资源文件缓存及原生视频插件，HTTP和草稿服务响应为受控夹具。服务重建不是OS强杀，草稿夹具ID也不是实际服务端数据库凭据。

[最终结果](result.json)、[逐条用例范围](case-results.json)、[Android结果](devices/android-case-cache-result.json)、[iOS结果](devices/ios-case-cache-result.json)、[媒体核验](media-verification.json)、[截图清单](screenshots.json)、[源文件摘要](source-hashes.json)、[运行环境清理](cleanup.json)。

复现入口为App仓库的 `test/pages/case_media_test.dart`、`test/pages/home_test.dart`、`test/projects/analysis_diff_test.dart`，集成入口 `integration_test/home_flow_test.dart`，驱动 `test_driver/catdrama_business_driver.dart`。集成检测使用 `CATDRAMA_TEST_PLATFORM=android/ios`、`CATDRAMA_TEST_SLICE=case-cache`、指定证据目录和 `CATDRAMA_CAPTURE_PORT`，由 `test_driver/capture_native.py` 按10个状态采集系统图。公开媒体与草稿使用专用测试夹具，不修改生产配置。集成构建不当作正常App入口构建；本轮没有另跑正常App构建。

最终原始机器输出为 [App全套](app-tests-cover-fixed.jsonl)，最终人读日志为 [相关59项](cover-render-tests-final.log.gz)、[Android](android-drive-cover-fixed.log.gz)、[iOS](ios-drive-cover-fixed.log.gz)、[analyze](analyze-cover-fixed.log.gz)、[格式检查](format-verified.log.gz)和[后台](backend-tests.log.gz)。日志及XML使用gzip原样压缩，初始失败和中断日志也保留，原始摘要及还原核对见[归档清单](raw-output-archives.json)。JSONL保持原始机器输出；本机恢复用的 `originals/` 不入提交。

真实运营案例、私有OSS、最新Figma、物理设备和同一作品完整制作/剪辑链路仍未验收；历史3项旧公共后端夹具失败没有在本轮修复。整项统计仍为7完成/38进行中/2待外部，186条用例仍为9通过/172部分/5未执行。只停止本轮启动的两个QA模拟器，采集进程及转发已结束；没有改相册权限、删除相册文件、启动PostgreSQL或触碰其他设备。测试KV临时目录由tearDown清理，诊断资源缓存留在QA应用中。
