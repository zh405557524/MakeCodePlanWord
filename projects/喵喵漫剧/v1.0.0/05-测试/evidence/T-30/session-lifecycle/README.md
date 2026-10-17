# T-30 本机工程身份、离开保存与进程恢复

2026-10-17；App `dev` 提交 `501e76c8064f347ffa3541b2722f4512237f3611`。保持开发阶段；本轮完成生命周期修复与受控双端验证，整项保留待真机、真实业务链及写入故障验收。

## 修改与依据

沿已审核T-30及R-18/R-26执行。修正前新页面继续持有旧作品/集的LocalEditorSession，关闭后的Controller还会执行保存选择并返回true；[原源码](originals/app)、[3条有效红灯](before-fix.log)已保存。

- EditorPage的key/tag同时包含路由前缀、作品/集、scope.key/sessionEpoch、工程UUID及Session实例身份。Tag只用于UI生命周期，不进Hive或后台，不改变持久UUID；正常编辑和刷新保留Controller。
- 旧账号Session不能作为有效extra显示时间轴，转原准备页。关闭、切号或换页后，返回动作在暂停、flush和保存选择之后再次核对current，迟到回调不授权旧View导航。
- 原LocalEditorStore、EditorFileRefs、本地模型、注册路由和原生引擎逐文件保持。7份旧用例改为通过公开页面身份及test/support/editor_binding.dart定位，业务断言不删减；[旧定位基线](originals/app/test/editor/local_export_widget_test.dart)保留；没有新API、存储、数据库迁移或依赖。
- 原生恢复检测沿生产CustomRouter及实际页面；按具体作品/集定位转场中的新页面，等待旧Controller释放；实际历史按钮可点后才真实点击。驱动保存原报告后再检查完整性，不能把缺报告、SDK返回0或中断当通过。

## 实际检测

| 检查 | 已执行结果 |
|---|---|
| 修正前回归 | 原源码上3/3失败，均为行为断言，不是缺导入或挂载失败；[日志](before-fix.log) |
| 新增边界 | 9条：作品/集切换、关闭后保存拒绝、同工程刷新、返回恢复自身历史、旧账号extra、暂停/落盘晚到及失败原候选重试 |
| 页面配套回归 | 9新增＋原5条导出页面＝14通过；[日志](boundaries.log) |
| 剪辑相关 | 303/303，0失败/跳过；[事件](related.jsonl) |
| 全套App | 1169/1169，0失败/跳过；187条隐藏夹具结果不计业务方法数；[事件](full.jsonl) |
| 静态与格式 | analyze无问题；13份代码格式0改动；[analyze](analyze.log)、[格式](format.log) |
| 原生与进程 | 两端各write/recover，共4次有效方法执行、2次实际终止；[Android写入](android-write/android-write-result.json)、[Android恢复](android-recover/android-recover-result.json)、[iOS写入](ios-write/ios-write-result.json)、[iOS恢复](ios-recover/ios-recover-result.json) |

Widget使用真实Hive、私有文件、公共KV与明确受控原生通道。设备执行使用真实H.264/AAC自建样片、原生预览/缩略图、Hive和宿主实际进程控制；项目/清单为隔离协议夹具，不访问真实Provider或OSS。

write阶段从真实作品入口打开第一集横向红色视频，按生产路由进入第二集纵向蓝色视频。第二集音量改650、真实点击撤销回1000、重做650、定位400ms；第一集完整快照不被改写。回第一集后旧Controller关闭、原工程及第二集已存head各自保留；第一集继续实际播放、暂停、撤销、重做及定位。

保存后宿主先确认实际PID及expected.json存在、记录其UUID和SHA-256，再仅终止自有模拟器中的com.lxwx.catdrama，确认进程消失：[Android进程证据](android-process-stop.json)、[iOS进程证据](ios-process-stop.json)。recover实际重新启动后比对同一UUID、revision、document、undo和selection，沿作品入口离线准备并继续原生预览/撤销/重做。准备阶段项目/清单/签名计数均为0；独立只读版本核对仍可失败并保固定工程，不宣称App所有HTTP都没有尝试。

保留10张系统图和5张375宽Widget图，均已总览；[Widget](widget-contact.jpg)、[Android](android-contact.jpg)、[iOS](ios-contact.jpg)。另详看Android第二集原生视频及iOS恢复后的预览与位置。Widget未提供真实视频帧，设备红蓝样片也不代表漫剧模型画质；本轮未做最新Figma在线对稿。

## 复现与源冻结

在 `/Users/soul/code/lxwx/catdrama` 使用工程Flutter：

```sh
flutter test --no-pub test/editor test/services/editing_cache_test.dart test/services/editing_prepare_test.dart test/services/media_download_test.dart
flutter test --no-pub --reporter json test
flutter analyze --no-pub
```

原生目标为 `integration_test/editor_recovery_test.dart`，驱动 `test_driver/editor_recovery_driver.dart`。每平台先以 `EDITOR_RECOVERY_PHASE=write` 和 `--keep-app-running` 执行；宿主验证PID/文件后实际停止，再用 `EDITOR_RECOVERY_PHASE=recover` 启动。驱动环境 `CATDRAMA_EDITOR_PHASE` 与dart-define一致，证据目录用 `CATDRAMA_MEDIA_EVIDENCE_DIR`，平台用 `CATDRAMA_TEST_PLATFORM`。

系统截图采集设置 `CATDRAMA_CAPTURE_PORT`，Android访客19155映射宿主端口，iOS用19156；`test_driver/capture_native.py`预期write为4张、recover为1张，不把采集缺项当通过。两端write保存的原UUID不同，recover各自恢复本设备原快照，不涉及跨设备工程同步。

[源冻结](source-freeze.json)为13份代码。全套结束后只调整原生检测的转场定位和按钮等待，生产及单元/Widget文件摘要保持；最终四次原生执行沿当前冻结源码。[verify.py](verify.py)复核实际终态、13份源文件、两次进程终止、15张图、原正式用例、受保护文档及无关工作区状态。

## 失败记录和边界

- `attempts/01-widget-await`是主动停止的未完成检测，退出0也没有记通过；最初怀疑直接await，未据此认定业务失败。
- `attempts/02-interrupted-capture`在回合中断后句柄缺失、无存活进程，日志无终态；检查发现图片转换在FakeAsync等待，改为整个截图放runAsync，与已有准备页测试一致。
- `attempts/03-native-position-precondition`为7通过/2失败：只设Flutter位置却没有设置受控原生回执，暂停正确读取0；补全原生位置400ms，保留原400ms断言。
- `attempts/04-analyze-style.log`保留3条括号风格提示，现已修正。
- `attempts/05-native-route-transition`为生产转场时新旧EditorPage并存，泛查找.single失败；按具体作品/集等待实际Controller，保留旧Controller关闭断言。
- `attempts/06-native-button-frame`为测试在直接提交后、按钮尚未重建为可用时点击，版本断言超时；补实际IconButton可点击等待，仍真实点击并核对版本/音量。两轮原生失败均未记通过，失败截图没有混入最终10张。

本轮未改/重跑后端，原后端与其他任务证据保留。写入中强杀、真实Hive损坏/磁盘耗尽、物理设备以及真实OSS/Provider完整业务链仍待；本轮实际终止发生于已保存快照之后，不能称为正在put/flush时中断。正式186条维持9通过/172部分/5未执行，未推进测试/上线阶段。没有推送、部署或生产配置操作；两个自有运行设备已停止，明确自有的5个ADB映射已移除。
