# T-23 素材历史、候选与固定引用恢复复检

2026-10-16，开发阶段。T-23保持“未完成（历史与候选恢复已检；真实渠道待验）”。App使用dev分支，实际提交见[提交记录](app-commit.json)，未推送。原T-23/T-24的后台证据保留历史，本轮没有重跑后台。

## 本轮交付

依据已批准R-11、R-12、R-26及API §7：

- 刷新按具体图片版本ID继续读取到用户手选所在页；暂存核对完整后才替换清单。翻页失败保留旧清单和选择，重复页、空非末页、跨素材响应明确报错，不猜测缺图。
- 读取期间新手选优先；完整核对后仍缺失的版本保留原ID并提示不可用，不自动换图。用户明确重新选择后清除该条过时提示；切号不展示迟到结果。
- 当前应用版本不在历史第一页时仍可从真实Asset快照展示。有效作品固定引用的旧图继续预览；未引用的过期候选即使已缓存，也不能打开原文件预览或应用。保留原缓存文件，不扩大期限。
- 图片历史区分加载、错误和成功空态；弹层自己的Obx观察文件Map快照，迟到图片实际更新缩略图。
- 实际公共路由tag包含素材身份，页面GetBuilder同步key；换素材释放旧Controller，避免沿用另一素材页面。
- 候选仍须明确应用，共享范围先确认；查看、刷新及取消无生成/应用业务写入。签名URL仍走公共只读POST，不能把这类POST统计为付费任务。

只修改既有工作台、图片历史、路由身份及相应检测；没有新增HTTP契约、表、依赖、原生媒体实现或生产配置。

## 自动检测

| 范围 | 终态结果 |
|---|---|
| 本轮新增App方法 | 14项，原16项工作台方法全部保留 |
| 工作台 | 30项通过 |
| 五套相关测试 | 94项通过 |
| 全套App | 1087项通过，0失败、0跳过 |
| 隐藏框架事件 | 175项未计为业务方法 |
| 静态检查 | analyze无问题 |
| 格式 | 7个实际改动Dart文件，0改动 |

[方法与归属统计](full-suite-summary.json)、[全套原始输出](full-tests-final.jsonl.gz)、[相关输出](related-final.log.gz)、[analyze](analyze-final.log.gz)、[格式](format-final.log.gz)。方法归属使用suiteID关联suite.path，不依赖可缺省的test.url。

新方法覆盖：跨页手选刷新、当前应用不在首屏、加载不伪空、页面Controller换身份、缺失版本不替换与重新选择、翻页失败保留/重试、重复页、空非末页、串素材、读取中改选、读取中切号、保护引用缩略图、过期缓存预览及迟到缩略图。

## 两端实际页面检测

Android/iOS均用实际CustomRouter、MaterialWorkbenchPage、共享确认弹层及ResourceService；回环HTTP提供受控素材/时间/媒体，文件真实下载到缓存。没有真实Java/Provider/OSS外呼。

每平台4个业务方法、4组完整报告及15张OS截图通过；日志“+6”含setup/teardown，不计6个业务方法。驱动检查四组具体业务断言，空报告或仅SDK退出0不能算通过。

1. 从历史第2页选6020，实际下拉刷新仍为6020；当前应用5511不变。共享弹层列两集，取消后无业务写入。
2. 当前有效作品的旧应用5511可打开全屏预览；候选5512曾已下载，过期后不能再打开预览或应用，原文件仍在，当前指针不变。
3. 用真实同一路由从个人资产301换303，旧Controller关闭，标题和类型随实际素材变化。
4. 初次历史响应等待时显示加载，失败后显示错误/重试；用户重试成功后才显示真实空历史，无自动生成。

[Android终态](devices/android-completion.json)、[iOS终态](devices/ios-completion.json)、[Android日志](android-drive.log.gz)、[iOS日志](ios-drive.log.gz)、[Android四组报告](devices/android-material-history-result.json)、[iOS四组报告](devices/ios-material-history-result.json)。

驱动内部“writes”指生成/应用等业务写入，明确排除公共 `POST /api/resources/{id}/access-url` 只读签名；资源HTTP与图片均为本机夹具。此轮不宣称真实计费/图片生成/自动入库、原任务进程恢复、实际30天清理或物理设备验收。两端drive构建了调试测试入口，本轮没有另重跑普通main入口App构建。

## 图片证据

30张系统图＋9张Widget图，共39张已总览；单独详看10张系统图、4张Widget图，具体尺寸、SHA256及查看范围在[图片清单](images.json)。[Android总览](review/android-contact.png)、[iOS总览](review/ios-contact.png)、[Widget总览](review/widget-contact.png)。

Widget图片是本轮本机生成的色块圆形测试图；原生测试读取现有App风格图，由回环HTTP交付，不是模型生成样片。Android启动桌面图只作诊断，不计产品截图。当前Figma通道实际断开，见[连接记录](figma-check.json)，不宣称最新对稿。

## 失败与修正记录

[各次执行](attempts.json)及原始压缩输出保留，不删除失败来只展示全绿：

- 初始四条复现全部失败，分别为错换手选、应用图缺失、加载伪空、旧Controller复用，见[初始复现](before-fix.log.gz)。
- 过期候选已缓存仍返回可读File、图片文件到达后缩略图仍不刷新，两条分别在修复前失败：[过期缓存](expired-preview-before-fix.log.gz)、[迟到图片](late-thumbnail-before-fix.log.gz)。
- 新缩略图用例初写将Semantics存在误判为失败，改用实际FileImage断言；延迟缓存用例初写误将两次签名POST当业务写入，改为严格要求只有两个正确签名路径。原16项测试的断言保留。
- 新原生辅助方法缺括号的info已修正。第一次全套1087通过后，补“明确重新选择清除旧缺失提示”断言和行为，再跑最终全套1087通过。
- 两端原生均首次通过，没有因观察超时另起重复测试。自有模拟器、采集器和转发已停止/释放，临时UI层级文件已按精确路径移除，[清理记录](devices/cleanup.json)。

日志仅按原字节gzip保存，压缩往返与摘要见[原始输出清单](raw-output-manifest.json)；本地originals保存原文档/源码及原日志，不提交备份目录。

## 复现命令

在App仓库依次执行；测试或构建活动期间不编辑源文件：

```sh
flutter test --no-pub test/assets/image_workbench_test.dart test/assets/auto_library_test.dart test/assets/asset_scope_test.dart test/assets/image_variants_test.dart test/assets/asset_test.dart
flutter test --no-pub --machine
flutter analyze --no-pub
```

原生目标为 `integration_test/material_workbench_history_test.dart`，driver为 `test_driver/catdrama_business_driver.dart`。设置 `CATDRAMA_TEST_SLICE=material-history`、`CATDRAMA_TEST_PLATFORM=android或ios` 和新 `CATDRAMA_BUSINESS_EVIDENCE_DIR`，用 `flutter drive --no-pub --driver=... --target=... -d <自有设备ID> --dart-define=CATDRAMA_CAPTURE_PORT=<设备侧端口>` 运行。同期开 `python3 test_driver/capture_native.py <主机端口> <设备ID> <平台> <新截图目录> 15` 并确认15帧；Android先做自有端口转发，重新选择空闲端口。实际参数见[Android](devices/android-run.json)、[iOS](devices/ios-run.json)。

## 验收边界

真实Provider/私有OSS、最新Figma、物理机、首次实际付费生成到自动入库及完整制作链路仍待。产品/设计/技术和上线基线没有修改，阶段保持开发；原3项旧公共后端夹具失败未重跑或宣称修复。

47项仍7完成/38进行中/2外部；186用例仍9通过/172部分/5未执行。五条受影响用例追加局部结果，见[用例记录](case-results.json)。[源码核对](source-verification.json)包含精确范围及SHA256；未改的计划内index文件不纳入源码提交。
