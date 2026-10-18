# T-32 Android 真机中文输入与文字成片

2026-10-18，前端 dev `4901c7c`，未推送。仅测试入口、严格 driver 和说明；业务、原生引擎、后台、API、数据库及依赖保持。

vivo V1981A / Android12 / API31，沿手机当前百度输入法九宫格，不更换默认输入法。电脑根据实际键盘截图点按36次，输入拼音并逐组选取“中文、取消、测试、离开”候选；四阶段最终文字为“中文、取消、原文字测试、离开”。没有剪贴板、Dart赋值、tester.enterText、ADB text或自动重输。

1条完整实际方法及严格 driver、27项既有文字专项、analyze、格式与Android debug构建通过。四次软件键盘原始占位均285逻辑像素，输入框及保存/取消均在键盘上方，假TextInput未注册。新增取消不落正文，已有修改取消还原完整旧快照，保存只增加一次revision，离开需明确处理，只删除选中文字并可完整撤销；片段和另一条文字保持。

20秒320×180 H264/AAC成片已独立完整解码，MP4/PNG实际长度和SHA与App输出一致。绿字在0.5–7秒烧录，1.5秒相对PNG组合误差19.05、相对出现前变化99.09，7.5秒移除后的变化0.33。另一个白字层独立存在，声音RMS约0.124。FFmpeg仅在宿主做QA解码，App继续使用原Media3方案。[媒体核对](android/media-verification.json)、[第二字层](android/second-layer-verification.json)。

[7张系统图总览](overview.png)、[原键盘](android/ime-original-keyboard.png)、[中文候选](android/ime-new-trial-candidates.png)、[取消候选](android/ime-cancel-candidates.png)、[测试候选](android/ime-save-candidates.png)、[离开候选](android/ime-leave-candidates.png)已查看；总览中的保存预览另看原图，0.1/1.5/7.5秒媒体帧均已检。[36次操作](os-input-actions.json)保留每次真实回显、截图摘要及取点依据，完整原始观察在忽略的originals/。

百度九宫格把拼音预编辑留在自己的IME视图，App的composing范围实际均为-1。本次证明该手机的真实中文候选输入，不证明其他IME向Flutter提交非空composing范围时的兼容性。样式Slider/时段等仍由原测试回调操作，不将其描述为真实拖拽验收。

账户/初始工程/源片受控，实际Hive、软件键盘、原生预览与编码执行。夹具未注册HttpService，版本核对失败日志保留，固定本机版本仍可继续剪辑；不计真实登录、模型、OSS或ASR。没有走成片结果页或相册，没有启动后台/数据库。iOS真机、更多机型/输入法、Figma字体/底色和完整结果/相册链保持待验；最新Figma通道仍断开。四条文字用例保持部分验证，正式186条10通过/173部分/3未执行、47项7完成/38进行中/2外部不变。

本轮自有且最初不存在的APK经摘要核对后已移除；手机返回桌面，原转发和设备锁恢复，默认IME不变，没有改相册。完整套件沿`f399154`的1269项有效基线，本轮未重跑。准备过程的相对路径与基线包含自有备份/活动设备锁的检查问题单独保留，均不计作业务失败；本轮实际业务仅提交执行1次并通过。[准备记录](preparation-notes.json)、[清理](cleanup.json)。

[结果](result.json)、[严格复核](verify.py)、[独立媒体复现](verify_media.py)。`python3 verify.py`只读检查公开文件、实际输入、媒体、提交范围、186条正文与受保护文档；媒体脚本使用工作区既有Python运行时及宿主ffmpeg/ffprobe。

数据库改动：无。本轮用量未取得，未额外查询。
