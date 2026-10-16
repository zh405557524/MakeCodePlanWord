# T-19 素材返回剧本、分析版本提示与未保存保护

2026-10-16，保持开发阶段。App dev `4bd45b09`，未推送或部署；本轮只补齐已批准P-14/P-13往返与版本展示，后台、API、DDL、迁移、依赖和原生实现未变。T-19整项及TC-10-02/TC-17-01仍为部分验证。

| 范围 | 实际结果 |
|---|---|
| App自动检查 | 新增11项；素材清单与共享范围相关45项通过，最终全套1021通过、0失败/跳过；analyze及6个Dart文件格式检查通过 |
| 页面入口 | “本集剧本”进入同一作品/集的实际编辑页，恢复本机手稿；核对真实entryState与路由，不隐式保存、分析或生成 |
| 分析版本 | 已保存正文与已分析版本分别显示；未分析、缺少版本、旧分析和一致均测试，缺失版本不猜 |
| 未保存保护 | 新建名称/描述响应式标记，切集/换表单/进剧本不丢输入；共享手改继续受保护，返回取消留稿、明确放弃不创建 |
| Android | 自有API37/16KiB模拟器2个业务方法通过，实际作品/剧本/素材页面和公共GetStorage；8张系统截图 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器同样2个业务方法通过；8张系统截图 |
| 往返数据 | 返回剧本恢复原Unicode手稿，导航0个业务写请求；显式保存才PATCH一次，正文v2/分析v1提示保留，没有分析或生成POST |
| 图片证据 | 16张系统图及9张Widget图；关键4张系统图和2张Widget图已查看，具体尺寸和检查范围见截图清单。Widget新状态图为桌面检测窗口，不能当手机或Figma验收 |
| 未验证 | 真实Spring/OSS/AI、最新Figma、物理设备及完整生成/入库/剪辑链路，系统磁盘耗尽和OS强杀本轮未测；后台未重跑 |

Controller继续沿原路由、DramaProjectService/DramaAssetService及既有公共存储，不新增服务、KV或任务轮询。素材清单始终读取保存到作品的正文；有本机未提交稿时，回到原编辑页恢复它，不把局部稿误用于素材分析。已有持久pending沿原任务恢复；本轮新建表单保护不声称未提交表单已跨进程持久化。

初次路由Widget检测中，首个HTTP在FakeAsync内调用AuthAPI.ensureDeviceId创建设备ID，业务与路由清理已经完成，公共GetStorage队列屏障仍挂起。两次已确认持有的测试进程被中断，均不计通过。夹具改为按真实启动预先完成设备ID及写盘屏障，保留原数据和写盘断言；生产公共存储未改。静态初检的旧Markdown聚合import与测试大括号同时修正。初始/诊断/复检日志原样保留，未只保留成功记录。

Android和iOS均检查原有两份完整业务报告及本轮新增字段：`scriptReturnPreservesLocalDraft`、`outdatedVersionWarningVisible`必须为true；日志中的setup/teardown计数不作为业务方法。采集器每端实收8次系统截图，0退出的空报告不计通过。

[结果](result.json)、[用例边界](case-results.json)、[Android报告](devices/android-episode-navigation-result.json)、[iOS报告](devices/ios-episode-navigation-result.json)、[截图清单](screenshots.json)、[源码摘要](source-hashes.json)、[提交范围](app-commit.json)、[清理](cleanup.json)、[首轮夹具问题](initial-harness-findings.json)、[Figma实际状态](figma-check.json)。

复现自动入口：App的`test/assets/material_list_test.dart`和`test/assets/asset_scope_test.dart`，截图目录通过`CATDRAMA_T19_SCREENSHOTS`指定；原生入口`integration_test/episode_navigation_test.dart`，通用驱动`test_driver/catdrama_business_driver.dart`，设置`CATDRAMA_TEST_PLATFORM`、`CATDRAMA_TEST_SLICE=episode-navigation`及`CATDRAMA_BUSINESS_EVIDENCE_DIR`。App内采集端口由`CATDRAMA_CAPTURE_PORT`指定，Android宿主转发端口与访客端口分开；`capture_native.py`本轮每端预期8图。

[1021项全套机器结果](app-tests.jsonl)、[45项相关](related-boundaries.log.gz)、[静态检查](analyze-verified.log.gz)、[格式](format-verified.log.gz)、[Android](android-drive.log.gz)、[iOS](ios-drive.log.gz)。日志采用gzip无损保存，失败/中断轮次也保留；[归档清单](raw-output-archives.json)核对解压后摘要。`originals/`仅本机恢复、不入提交。最终测试后仅补App说明文档，运行代码与测试保持已测字节。

仅停止本轮启动的两台QA模拟器和采集器；未改相册权限/相册文件、未卸载App、未启动PG或操作生产。Figma rq4owed6实际未连接，沿既有批准参考和公共组件，不称最新视觉验收。47项仍7完成/38进行中/2外部，186条仍9通过/172部分/5未执行，未推进测试阶段。历史3项公共后端夹具失败仍保留。
