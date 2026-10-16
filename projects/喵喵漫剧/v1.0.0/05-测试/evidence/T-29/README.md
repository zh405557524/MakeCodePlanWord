# T-29 下载、缓存与准备 Service 检测

2026-10-15。**核心实现通过本机检测，T-29仍未完成。** 准备页、M-28超限界面、作品全部剪辑入口和T-30真实工程的接通尚未实现；不能将这些内部缺项记成外部阻塞或用假编辑器代替。

34项相关后端（新增15）、76项相关App（新增51）、静态检查及22个Dart文件格式检查通过，0失败/错误/跳过。iOS 26.4的iPhone 15 Pro Max模拟器运行1项实际集成场景，测试框架另显示tearDownAll，不能计成第二项业务测试。方法数与186条验收用例分开统计：TC-16-04/05新增部分验证，TC-X14继续部分；没有新增完整通过。

## 实现范围

- 后台只读清单校验本人有效作品/剧集；默认当前可用已应用视频，显式请求只返回对应固定版本。原能力快照、原文、字节及摘要沿原记录，未请求的C镜头不构成A/B门槛；不返回签名、不依赖最新模型、不创建云端剪辑、不收费或延期。
- 手机按resourceId与视频版本核对身份，同一作用域内以SHA去重文件。并发2路、有效分段续传、Range不支持时单文件重下、401/403最多换签一次；取消保留分段，校验失败不发布READY，完整文件留在本机可重试核验/保存。
- 默认500MiB和1/2/5/10GiB设置，实际已占+其他源预留+本次仍缺量核算缓存，真实磁盘另保护各批次的处理空间；写入消耗预留，空间变化及时停止。只清实际闲置文件/应用临时成片，保护有效作品、活动文件及账号/环境隔离；删除失败不虚报腾出容量。
- 准备Service首次按当前已应用可用视频初始化，恢复只用调用方提供的head固定源及实际音频/封面。完整有效本机输入不请求配置/清单/签名；缺源按最多100个ID分批核实，不把接口批大小变成时间轴上限。原生连续时钟锚定服务器期限，日历回拨不续期、跨重启不确定须联网。剧本重排只改镜头位置，不能让固定原视频失效或改本机顺序。
- Android读取真实可用空间和elapsedRealtime/boot count，实际验证首画面及首音频解码；iOS读取真实可用空间和mach连续时钟/开机标识，使用AVAssetReader验证实际样本。支持的原文件直接使用，不产生统一转码副本。

## 命令与边界

App目录 `/Users/soul/code/lxwx/catdrama`，Flutter `/Users/soul/data/flutter/flutter/bin/flutter`；依赖锁SHA256保持 `479d15709891ae79244f8bd8aa76431a21a2ad4bbfe87a46ab65d6edd04a62ca`。

```sh
flutter test --no-pub --reporter=json \
  test/services/editing_prepare_test.dart \
  test/services/media_download_test.dart \
  test/services/editing_cache_test.dart \
  test/services/resource_identity_test.dart \
  test/services/storage_isolation_test.dart \
  packages/native_media_engine/test/native_media_engine_test.dart
flutter analyze --no-pub
```

[76项方法与结果](flutter-summary.json)、[最终原始事件](app-final.jsonl)、[静态检查](analyze-final.log)、[格式检查](format-result.json)。单元测试使用实际临时文件、Hive和回环HTTP；设备空间、原生探测和后台返回在单元层为受控边界，不能替代设备、OSS或Provider验收。

后端目录 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`，Android Studio JBR，Gradle离线执行；PG为专用端口56284、用户/库catdrama_test，空密码，只创建测试自有schema。

```sh
./gradlew test --offline --console=plain \
  --tests com.lxwx.narrateservice.CatdramaDownloadManifestTests \
  --tests com.lxwx.narrateservice.CatdramaShotTests
```

[34项方法](backend-summary.json)、[Gradle日志](backend-attempt-1.log)、[新清单XML](CatdramaDownloadManifestTests.xml.gz)、[镜头回归XML](CatdramaShotTests.xml.gz)。元数据与资源记录为受控夹具，真实Spring/JWT/PG验证；未访问OSS或Provider。检测后[自有schema剩余0](schemas-after-backend.txt)，[专用PG已停止](postgres-stop.log)。无表/列/索引、迁移或生产修改。

Android原生 `:native_media_engine:compileDebugKotlin --offline` [通过](android-native-compile.log)；[iOS原生目标编译](ios-native-compile.log)通过，Podfile.lock未变。已有SDK/AGP及Swift未来版本警告未扩展到本任务修改。CocoaPods未在默认PATH，使用本机已安装 `/Users/soul/.gem/ruby/2.6.0/bin/pod`，未安装新工具或依赖。

```sh
flutter drive --no-pub --driver=test_driver/cache_prepare_driver.dart \
  --target=integration_test/cache_prepare_test.dart \
  -d E33B4820-6860-419F-8B17-B6A8FA94EA77
```

执行时设置 `CATDRAMA_MEDIA_EVIDENCE_DIR` 指向本证据目录、`CATDRAMA_TEST_PLATFORM=ios-simulator`，将CocoaPods及Flutter目录加入本次PATH。最终[实际构建与运行日志](ios-final.log)、[设备返回](ios-simulator-device-result.json)证明：73,352字节MP4从24,450字节续传，SHA256与原样片一致，真实24fps原文件可解码；重开Hive保持localMediaId，完整固定head准备不访问后台/签名。源文件未修改，无统一转码、导出或上传。

设备检测只使用独立App私有目录和测试账号/后台命名空间，不触碰生产数据或真实安全存储。最终版Hive也在本次独立目录下；清理前期检测明确自有的editing.test用户1 Box，不清理其他账号。原始失败尝试保留：单元环境切换应重新登录、测试缺枚举import、格式提示等已修复；最终结果以上述最终日志为准。

## 尚未完成

准备页、M-28数字/清理/调上限/取消的实际界面及所有作品入口守卫；T-30工程完整快照/undo/redo和真实编辑器导航。后续继续T-29/T-30接通，不因缺测试设备跳过内部实现。

Android当前无连接设备，仅原生编译通过。两端真机、真实OSS签名/下载、最新Figma、实际相册/缓存权限、强杀/重启、完整音轨封面及导出联验待补；不得以模拟器或Service检测替代。后台Provider样片、T-27版本更新提示、T-31添加原镜头、T-33主动字幕及T-34/35真实成片按对应任务继续。

[机器结果](result.json)、[验收映射](case-results.json)、[源码与提交](source-manifest.json)。仅本地dev提交，无推送、部署或真实付费。本轮用量未取得，未额外查询。

提交：前端dev `2f300676f6a4ba8dc6f6d38a13ef26e78cc63766`，后端dev `c939bd5cc58760bc0163393a7d752b8afe7f8afd`。源码SHA与具体文件见source-manifest.json；整项缺项仍以上文为准。
