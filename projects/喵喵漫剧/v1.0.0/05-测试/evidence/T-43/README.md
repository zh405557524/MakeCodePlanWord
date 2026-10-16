# T-43 两端业务切片与实际媒体检测

2026-10-16；当前仍在开发阶段。**可执行检测已交付，整项未完成。** 三入口到分析受理连续执行；字幕、导出和相册使用独立工程切片。HTTP、AI、ASR为隔离协议夹具，原生媒体和系统相册为模拟器实际实现。没有把多个独立切片拼称同一作品的真实Provider全链路，TC-X20保持未执行。

## 最终结果

| 范围 | 实际结果 | 证据 |
|---|---|---|
| App普通测试方法 | 926通过，0失败/跳过；新增5项已包含 | [原始JSONL](app-all-final.jsonl)、[方法清单](app-summary.json) |
| 原生插件Dart协议 | 23通过，0失败/跳过 | [原始JSONL](plugin-final.jsonl)、[方法清单](plugin-summary.json) |
| Android帧时钟 | 10通过，使用本轮编译的生产类和假纹理池，非GPU像素证明 | [协议源码](ConstantFrameRateProtocol.java)、[命令](native-clock-command.json)、[输出](native-clock-protocol.log) |
| 两端模拟器 | 11个最终场景/21次普通方法执行；不计加载/收尾/重复或失败 | [平台汇总](devices/device-summary.json) |
| 手机实际媒体 | 15文件完整解码；4份横竖成片独立核对包时间戳、切镜、黑边、文字/字幕时窗、混音、内嵌封面 | [媒体核对](media-verification.json)、[命令输出](media-verification-final.log) |
| Android提音 | 自建92秒双轨，选第二轨90500–91500ms；源删除后独立混音/导出，实际880Hz且段外静音 | [原生结果](devices/android-source-audio-result.json)、[独立频谱](source-audio-verification.json) |
| 系统相册 | 两端系统副本与原MP4同SHA；清应用临时成片后副本仍在 | [Android](android-gallery-verification.json)、[iOS](ios-gallery-verification.json) |
| 图像 | 63张最终原生截图保存，13张关键及负证据实际查看；没有声称逐张/Figma通过 | [查看清单](image-evidence.json) |
| 静态/格式 | analyze无问题，14份Dart格式0改动；Python语法通过 | [analyze](analyze-final.log)、[格式](format-final.log) |
| 正常App构建 | Android debug APK、iOS模拟器debug App成功；不是商店/真机包证明 | [构建信息与摘要](build-artifacts.json)、[Android](android-app-build.log)、[iOS](ios-app-build.log) |

最终App日志为`app-all-final.jsonl`；922/924项先前回归只作历史，不累计到926。iOS公共最终有效日志保留首次文件名`ios-public-attempt-1.log`，它已通过且公共源码后来未改。Android字幕最终有效日志同理为`android-subtitles-attempt-1.log`。场景到日志/报告的一一对应以平台汇总为准。

## 检测发现与修复

1. 制作页返回动画尚未结束就重新进入时，旧页会删除新页共享的GetX Controller。生产页按路由实例加tag，新增重叠页面回归并调整旧集成查找；真实两端三入口连续流程重跑通过。
2. Android原FrameDropEffect是近似采样，实际24fps目标曾输出26.7027fps；改用整数有理数时钟及两纹理缓存，保持背压/释放顺序。首版修复虽然回执成功，但独立像素检查发现第二镜头仍是首段红色；实际Media3为各素材创建Shader且PTS为全局时钟，进一步按源边界填帧，最后红→绿、24与30000/1001实际包时间戳均通过。未放宽帧率门禁、未预转码源或改变音频速度。
3. Android真实导出在.part原子改名时，与缓存stat竞争产生ENOENT。仅跳过该错误，下次扫描重读；权限/空间等其他错误继续抛出且保持原统计。新增2项真实文件边界检测。
4. Android AAC提取1秒区间，真实容器1045ms，原默认把补齐部分一起入轨。保留真实文件探测，将默认逻辑音轨限制为用户所选1000ms（源较短时限制为实际时长）；新增2项回归，90秒后实际提音和删除源后混音/导出通过。

公共权限流程和插件继续复用；相册测试实际点击Android说明弹框，没有跳过生产权限层。没有新增依赖、后台接口、表结构、迁移或手机FFmpeg，其他App和后台原有改动保持。[源码清单](final-source-manifest.json)、[执行者复检](review.json)、[保留核对](preservation.json)。

## 有效平台范围

- Android：自有AVD `Catdrama_T17_QA_20261015`，emulator-5554，Android17/API37、arm64、16KiB，1344×2992。
- iOS：iPhone15 Pro Max模拟器，iOS26.4，1290×2796，UDID见平台汇总。
- 每端创作3、公共4、字幕1、导出1、相册1；Android另有提音1，共21次。登录/真实支付、description/assets/prepare设备切片本轮未执行；原有效证明另行引用，不重复累计。
- 创作实际检查最终手改正文逐字承接、唯一创建、参数独立保存及分析明确失败保稿；公共实际检查丢回执只查原签到、邀请原键/分页、流水订单只读、原生HTML与未配置重试。真实后端业务事务证明来自T-38/T-39/T-42，T-43没有重跑后台。
- 提音仅操作本次自建视频，SHA见[source setup](android-source-setup.json)；系统删除提示指向该唯一文件，确认见[记录](android-source-delete-confirmation.json)。没有删除用户原有相册内容，系统输出副本保留。

## 复现

在App仓库运行以下模板，明确选择设备及一个切片；每个进程只跑一个切片，避免测试全局存储互相污染。`--keep-app-running`用于防止drive默认卸载影响后续恢复；本次T-43不宣称跨进程恢复，跨进程有效证据见T-42。

```sh
export CATDRAMA_BUSINESS_EVIDENCE_DIR="<本轮证据目录>/devices"
export CATDRAMA_TEST_PLATFORM="android"
export CATDRAMA_TEST_SLICE="creation"
flutter drive --no-pub --keep-app-running -d emulator-5554 \
  --driver=test_driver/catdrama_business_driver.dart \
  --target=integration_test/catdrama_end_to_end_test.dart \
  --dart-define=CATDRAMA_E2E_SLICE=creation
```

创作入口还可选`assets/description/prepare/subtitles/export/album/source-audio`；公共入口使用`integration_test/public_business_test.dart`及`CATDRAMA_PUBLIC_SLICE=public`（默认）。`auth/payment`是明确选择的独立入口，不能将默认公共切片说成执行过真实登录或支付。iOS替换设备ID与平台环境值。提音切片需要按源码前置准备自建92秒双音轨源及系统权限，不能用用户视频替代。

```sh
flutter analyze
flutter test --no-pub --machine
cd packages/native_media_engine
flutter test --no-pub --machine
```

回到App仓库，可在工作站运行`python3 test_driver/verify_business_media.py <本轮证据目录>`；本目录再运行`python3 verify-source-audio.py`核对第二音轨及段外静音。这里FFmpeg/ffprobe只用于工作站独立解码，App没有FFmpeg依赖。Android帧时钟协议的完整javac/java命令和环境见命令JSON。

## 负证据与待办

初始错误枚举/页面等待、Controller真实销毁、近似帧率不符、首段红色误填整集、原子改名ENOENT、相册测试漏说明弹框/Surface刷新、AAC补齐及Java夹具环境错误均保留原日志。`android-export-attempt-4/5`即便测试收到成功回执，仍因像素错误不计成片通过；`android-album-attempt-1-interrupted`被SIGINT中止，即便退出0也不计通过。

真实Provider/私有OSS/ASR、SIM/商店、两端物理设备及权限/低空间/云端占位/长片/活动编码中断待验收；最新Figma rq4owed6返回`Not connected to Figma`。同一作品的完整生成、账务、成长、下载、字幕与成片链路仍待验收；TC-X20保持未执行。T-42三项旧公共夹具失败保留，本轮没有改旧预期或降低私有/所有者门禁。邀请落地页与更多文字预设等内部待办继续保留，不能称为外部支持缺失。

47任务当前7完成/38进行中/2待外部/0未开始；186验收用例9通过/172部分/5未执行，未按方法数转换验收通过数。[逐条范围](case-results.json)、[汇总](result.json)、[文档核对](document-check.json)、[路径门禁](workspace-gate.json)、[提交](commits.json)。本轮未推送、部署或推进测试/上线阶段；`originals/`只保留本机备份，不纳入提交。
