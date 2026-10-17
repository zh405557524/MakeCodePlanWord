# T-32 · iOS屏幕键盘、取消保存与文字导出补验

2026-10-17，开发阶段。App `dev`提交`b7335c1ad2dbe9bd09e62dd1a16bb1ffecccd7fc`仅更新进度说明。**本切片通过，T-32整项未完成**；本轮没有修改App生产、测试、驱动、原生、依赖或后台代码，数据库改动无，未推送或部署。

## 实际结果

电脑通过Appium/XCUITest连接自有iPhone 15 Pro Max模拟器（iOS26.4，`E33B4820-6860-419F-8B17-B6A8FA94EA77`），运行既有`integration_test/text_editor_test.dart`及严格`catdrama_business_driver.dart`，两份摘要保持原值。媒体、工程和中文初始文字是自建夹具；编辑页、真实Hive、字体、原生预览和本机导出使用现有实现，无生产账号/Provider/OSS/ASR/积分/相册操作。

| 范围 | 结果 | 证据 |
|---|---|---|
| 既有文字单元/Widget | 27方法通过，0失败/跳过，无新方法 | [JSONL](focused.jsonl) |
| 静态检查 | analyze无问题；无Dart改动，不另作格式修改 | [日志](analyze.log) |
| iOS真实输入及编辑 | 1条完整方法通过，32次唯一AX键点击逐字确认 | [原报告](ios/ios-text-editor-result.json)、[实际操作](ios-os-input.json) |
| 软件键盘布局 | 四阶段真实FlutterView占位均318；无假TextInput，输入/保存/取消在键盘上方 | [控机工具](ios_os_input.py)、[输入前系统图](ios/input-before-save-text.png) |
| 实际媒体 | 20秒320×180、24fps、H264/AAC，完整解码与SHA通过 | [MP4](ios/ios-text-edited.mp4)、[独立核对](ios/media-verification.json) |
| 文字时段与声音 | 同一PNG字层，0.5–7秒烧录；另一条文字及非零声音保留 | [字层](ios/ios-saved-text.png)、[1.5秒帧](ios/frame-1.5.png) |
| 图像复核 | 7张系统握手图、4张输入前Appium图和3张实际视频帧已看 | [图清单](visual-review.json) |
| 正式用例 | TC-19-01至04只补部分证据；186条正文/状态不变 | [逐条范围](case-results.json) |
| 复检与清理 | 5目标guard+audit、保护文档/源码/无关状态核对，自有会话和模拟器已停 | [复核](verification.json)、[清理](cleanup.json) |

四阶段依次为：新增`trial`后取消；将已有文字改成`cancel`并改样式后取消；保留预置中文再输入` edit`并明确保存；输入`leave`后尝试离开并选择继续编辑、取消。已有文字取消保持完整旧快照，保存只增加一次revision；另一条文字不变，只删除选中文字后可完整撤销。未保存稿被导出守卫拒绝，片段保持原样。

真实输入通过屏幕键盘上的小写字母、空格和删除键完成，**不使用物理按键、剪贴板、Dart赋值或tester.enterText**。每次根据新鲜XML重新定位唯一AX键，点击前核对当前App/焦点/阶段，点击后等待真实逐字回显；无自动补输或纠正。删除预置中文不等于通过中文拼音、联想或组合输入验收。样式Slider、位置/时段和部分编辑动作仍沿原测试回调，不能宣称全流程均由手指拖动完成。

## 独立媒体核对

宿主按严格driver返回的长度/SHA取回PNG与MP4，另用FFmpeg/ffprobe完整解码。实际时长20.000000秒，媒体参数与任务一致。561个绿字内部像素用于核对PNG合成与有损编码帧：活动帧相对未出现帧变化约83.04，合成平均误差约21.99；7.5秒该字层已移除（目标区域变化0）。声音RMS约0.0882，不把合成音当成真实对白质量或ASR证明。

- [0.1秒无该字层](ios/frame-0.1.png)。
- [1.5秒两条文字均可见](ios/frame-1.5.png)。
- [7.5秒只剩另一条文字](ios/frame-7.5.png)。

[宿主核对脚本](verify_media.py)复用前轮Android的实际文件/字层/时窗/声音断言，仅按本轮软件键操作回执及iOS平台适配；没有放宽原Dart严格断言。FFmpeg仅在宿主作QA解码，App媒体方案仍为Media3/AVFoundation。

## 首轮失败与边界

[首轮](attempts/01-physical-key-events/)使用XCTest `mobile: keys`物理键盘事件。虽然四阶段文字、取消保存及实际MP4均产生，但软件键盘随后被隐藏，记录占位为约2.04/0/0/0；原严格driver退出1，**不计通过**。原MP4/PNG按摘要备份，报告、截图、输入代码及终态保留。之后只改宿主控机方式为32次屏幕键点击，原App测试/driver和其正占位要求完全不变，最终输入/采集/驱动均退出0。[终态记录](terminal-results.json)。

部分握手截图缺静态头部/底部区域，保存预览、撤销和离开确认图又显示完整区域；这些图不作视觉基准，不能据此声称全App或最新Figma对稿通过。图清单保留观察，未修改页面样式来掩盖。[保存预览](ios/ios-os-text-native-saved-preview.png)、[离开确认](ios/ios-os-text-native-leave-confirm.png)。

夹具未注册HttpService，联网核对原视频版本的日志保留并继续本机固定源，符合本次离线媒体范围，不能证明实际后端或私有OSS联验。首个Appium初始化调用误用不存在的`start`，更正为既有`connect`后才建立会话；无设备业务动作，不计为方法成功。旧公共三夹具和App图标仅作只读核对，未在本轮修改：[后续清单](followups.json)。

## 复现

App目录`/Users/soul/code/lxwx/catdrama`，所有Flutter命令`--no-pub`，目标固定为现有测试。保持软件键盘、`connectHardwareKeyboard=false`；Appium工具沿已有`phone-ui/device_drivers.py`，不安装新依赖。

```sh
flutter analyze --no-pub
flutter test --no-pub --reporter=json test/editor/text_draft_test.dart test/editor/text_editor_widget_test.dart
flutter build ios --simulator --debug --no-pub --target=integration_test/text_editor_test.dart --dart-define=CATDRAMA_CAPTURE_PORT=19163
CATDRAMA_BUSINESS_EVIDENCE_DIR="$TASK_EVIDENCE/ios" CATDRAMA_TEST_PLATFORM=ios CATDRAMA_TEST_SLICE=text-editor flutter drive --no-pub --no-build --keep-app-running --driver=test_driver/catdrama_business_driver.dart --target=integration_test/text_editor_test.dart -d E33B4820-6860-419F-8B17-B6A8FA94EA77 --dart-define=CATDRAMA_CAPTURE_PORT=19163
```

`TASK_EVIDENCE`设为本目录绝对路径。先建立自有Appium会话并保存profile/sessionId；并行启动既有`test_driver/capture_native.py`等待19163、目标设备、ios、输出目录和7张握手图，以及本目录`ios_os_input.py`。两者按实际夹具状态等待，不向Dart接口发送输入。完成后运行`verify_media.py`（环境需既有Pillow/numpy）及`verify.py`。

[App源码冻结](source-freeze.json)、[宿主源码冻结](host-source-freeze.json)记录检测前输入；验证期间没有修改可执行文件。自有Appium会话/4725服务及模拟器已关闭，硬键盘连接选项保持原false，不删除相册、模拟器定义或其他设备。备份/WDA缓存/初始状态文件按`.gitignore`不提交。

真实物理设备、中文IME/组合输入、更多获批字体/底色、最新Figma、同一作品完整T-34/T-35结果和相册链路、真实Provider/OSS继续未完成。本轮不是186条正式phone_test.py执行；47任务保持7完成/38进行中/2待外部，186条保持9通过/172部分/5未执行。1196全套是前轮基线，本轮未重跑，不自动进入测试或上线阶段。

[结果](result.json)、[交付摘要](delivery-manifest.json)列出本切片范围，历史失败不改为通过。
