# T-32 系统输入与本机文字导出复检

2026-10-17。Android本轮通过；iOS系统输入控制未完成，T-32整项继续进行中。只扩展既有原生检测及驱动，不修改业务、字层契约、存储、引擎、接口或依赖。App在dev，未推送。

## 实际结果

| 范围 | 结果与证据 |
|---|---|
| 既有文字单元/Widget | 27项通过，0失败/跳过；本轮没有新增单元方法，[原日志](focused.jsonl) |
| 静态/格式 | analyze及2份Dart格式通过，[analyze](analyze.log)、[格式](format.log) |
| Android实际页面/Hive/原生媒体 | 1条完整方法通过；四阶段系统输入均有焦点、就绪及选择反馈，[严格报告](android/android-text-editor-result.json)、[操作记录](android-os-input.json)、[终态](terminal-results.json) |
| 系统键盘 | 四次原始FlutterView占位均为336逻辑像素；输入框/保存/取消在键盘上方且可点击，未注册假TextInput。后代MediaQuery为0属于占位被消费，不等于系统键盘未显示 |
| 本机实际产物 | [20.026秒MP4](android/android-text-edited.mp4)与[保存字层PNG](android/android-saved-text.png)长度/SHA核对，完整视频/音频解码及字层时窗通过；[独立检测](android/media-verification.json) |
| 图像检查 | 7张最终系统图及0.1/1.5/7.5秒实际成片帧均已查看，[总览](contact-sheet.png)、[观察记录](visual-review.json) |
| iOS | 本轮0条完整方法通过；系统输入未稳定送达字段，尝试均中断。[未完成记录](ios-status.json)，不使用SDK退出0代替通过 |
| 路径门禁 | 已补脚本的5项隔离自测重新通过；5份进度目标check及当前项目audit通过，[自测](guard-tests.log)、[校验](guard-check.log) |

最终文件为320×180、24fps、H.264/AAC，实际20.025805秒。试写、保存及原生计划字层SHA一致；文字“原文字 edit”使用真实随包Noto Sans SC、26号、绿色、800/1000透明度和左对齐，生效区间500–7000ms。0.1秒尚未出现，1.5秒与另一条文字同时出现，7.5秒只剩另一条文字。独立检测在602个绿字内部像素上核对PNG合成与有损编码帧，并检查非零原声音频；不是宣称逐像素无损一致或真实对白质量通过。

实际过程包含新增试写取消、已有文字/样式取消保持完整旧快照、保存只增一次revision、另一条文字不变、离开需明确处理、只删选中项与完整撤销。未保存试写仍被导出守卫拒绝。保存后直接调用现有LocalExportService生成实际成片；没有走成片结果页或写入相册，不能由本轮替代T-35验收。

## 检测改动与尝试保留

- [原生检测](/Users/soul/code/lxwx/catdrama/integration_test/text_editor_test.dart)读取真实FlutterView占位，使用系统输入和截图握手；增加实际PNG/MP4取回。字号/透明度沿既有Slider回调，位置/时段沿既有Controller测试调用；不宣称所有样式均由手指拖动验证。
- [严格驱动](/Users/soul/code/lxwx/catdrama/test_driver/catdrama_business_driver.dart)先保原报告，再核实四阶段、旧稿保护与实际文件摘要，缺项直接失败。
- [Android输入工具](android_os_input.py)只处理四个固定夹具阶段；等待真实键盘就绪、焦点和全选/光标反馈后才发系统按键，收到完整文字确认才继续，不自动纠正或重输。
- 初轮辅助代码分析错误、iOS中文/大小写/软件及硬键盘控制中断、Android一次“cancel”变为“ancel”的现场均保留在[attempts](attempts/)。输入阶段曾早于键盘就绪暴露，宿主也未等待全选反馈；加屏障后最终四次完整确认通过。这个结果只支持本轮工具时序修正，不凭一次现象认定或排除所有产品输入问题。
- 独立检测初版误把内嵌PNG封面算作运动视频轨，原失败保留在attempts/07；改为单独识别attached_pic后重新检测同一文件，未重做或替换成片。

## 复现与边界

在自有Android QA模拟器安装此检测包，保留真实软件键盘；宿主60685转发到访客19163。分别启动系统截图采集、flutter drive和输入工具：

```sh
python3 /Users/soul/code/lxwx/catdrama/test_driver/capture_native.py 60685 emulator-5554 android "$TASK_EVIDENCE/android" 7
CATDRAMA_BUSINESS_EVIDENCE_DIR="$TASK_EVIDENCE/android" CATDRAMA_TEST_PLATFORM=android CATDRAMA_TEST_SLICE=text-editor flutter drive --no-pub --driver=test_driver/catdrama_business_driver.dart --target=integration_test/text_editor_test.dart -d emulator-5554 --dart-define=CATDRAMA_CAPTURE_PORT=19163
python3 /Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-32/keyboard-export/android_os_input.py 60685
```

`TASK_EVIDENCE`设为本目录绝对路径；Flutter命令在App仓库执行。完成后使用带Pillow/numpy的Python执行[verify.py](verify.py)。宿主FFmpeg仅用于独立解码检测，App媒体实现保持原方案。

本轮仅Android模拟器、自建红蓝视频及合成音。没有生产账号、Provider、OSS、ASR、扣费或相册操作；保留Chinese前缀后追加ASCII，不代表拼音、联想、粘贴、组合输入及物理设备验收。iOS最终严格版本未完成执行；之前iOS字层结果仍属历史证据。更多Figma字体未提供、底色缺既定Style字段；当前Figma连接不可用，这些继续待补，不改产品/技术原稿或伪造字体。

正式186条定义和状态不变：9通过、172部分、5未执行；TC-19-01至04仅补部分证据。47项保持7完成、38进行中、2待外部。全套1185项保留T-46的历史基线，本轮未重跑；生产与单元源码摘要未变。原始失败/中断不计通过，原备份只在本机originals目录保留，不纳入交付。

[复核结果](verification.json)核对固定检测源码、12份受保护文档、186条正文、47项任务及无关工作区状态。测试结束后已恢复Android键盘选项、移除本轮显式转发并停自有模拟器；模拟器进程关闭返回134单列为退出记录，Android drive/采集/输入三项均为0，不混算业务失败。[清理记录](cleanup.json)。
