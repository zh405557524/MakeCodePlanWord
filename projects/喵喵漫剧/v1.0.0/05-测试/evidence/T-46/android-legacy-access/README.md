# T-46 Android旧版存储权限补验

实际 vivo V1981A / Android 12（API31）完成1条原生App方法，严格Flutter驱动退出0。自建媒体、隔离Hive工程、真实Media3/系统存储权限；未读取用户相册或调用后台、AI、OSS、ASR。App业务与原生引擎没有修改。

## 结果与证据

- 34项既有提音专项＋3项公共权限包装测试通过；analyze、两文件格式和Android debug构建通过。[命令](checks.json)、[公共权限检查](permission-unit.json)、[构建](build.json)、[宿主驱动补检](host-driver-check.json)。1261全套沿T-40有效基线，本轮未重跑。
- 原测试新增实际SDK分界：33及以上检查videos，24–32检查storage；iOS保留photos。默认仍限自有模拟器，真机必须显式构建开启并在严格驱动核对实际physicalDeviceUsed及指定SDK，避免把模拟器报告混作真机。
- [真实App报告](vivo-api31/android-source-audio-access-result.json)证明：取消说明和系统拒绝均保持完整工程/原账本，不创建提音任务；拒绝后保存文字只增一次revision，原片段、声音修订及总时长保持。最终为实际permanentlyDenied，原生文字与时间轴可见。对照[7次实时截图](vivo-api31/system-captures.json)、[OS拒绝回执](vivo-api31/permission-denial.json)、[8图总览](screens-contact.jpg)。精确输入由tester完成，不作为真机中文输入法验收。
- 宿主与原驱动核实真实App PID；当前手机实际安装APK摘要与本轮构建一致，见[安装核实](physical-installed-build.json)。[15项定位检查](locator-checks.json)覆盖两个真实拒绝文案、错误App/权限、禁用/重复按钮与背景含App名，通知询问不能误算存储拒绝。

## 失败和控机回执

[第1次](physical-attempt-01/outcome.json)到达真实原生预览并通过取消说明，但厂商另一个通知询问挡住权限请求；实际存储拒绝文字为“禁止”，原宿主未识别，App方法超时失败，原报告/图/日志保留。单独关闭通知后遗留的已停止App权限请求也经真实节点拒绝，属于准备清理，不计为最终存储拒绝。

第2次使用同一构建重新完成全部App断言，严格驱动退出0。vivo按先前询问记录显示“禁止且不再询问”，电脑依据当前原生XML及真实App PID补点一次，保存独立回执。原采集宿主没有将该外部回执放入内存，因而退出1；没有把这个退出码改成0。完整App报告、7系统图、实际按钮XML/PNG和对应动作已独立只读复核通过，见[复核](physical-receipt-verification.json)。成功方法没有重跑或重复计数。宿主后续补上该真实节点和外部回执核验入口，见[修正边界](host-correction.json)；[实际执行宿主](executed-run-vivo.py)保留原版本。

## 设备保护和范围

测试前手机在桌面、目标App未安装且无其它本工具设备会话；安装/驱动重装只确认本测试App自身的厂商安装提示，未改变全局安全开关。见[前置核实](physical-preflight.json)、[安装回执](physical-install-actions.json)。测试后先核对已装APK摘要，再只卸载本轮新装的测试App，恢复桌面并释放共享设备锁、转发及本轮孤立日志进程，见[清理](physical-cleanup.json)。未扫描手机相册文件，也未改其他App。

最初准备API32模拟器时下载过官方镜像，因已有API31真机可验证同一旧版权限分支，已停止可选下载并私有保留已收部分。API32镜像未安装、未运行，不计通过；源码依赖未变，见[sdk传输停止记录](sdk-transfer-stopped.json)。`run_android.py`的API32入口尚未运行，当前构建显式为真机模式；今后跑模拟器须按默认关闭真机开关重新构建。SDK缓存、完整原始日志、会话和安装准备图仅在忽略的originals中。

本次只补TC-X30等的权限/工程保护部分。Android24–30/32及更多机型、允许后的真实相册提取/云端占位、大文件/实际空间、完整真实ASR/成片链路、最新Figma继续待验。T-46整项未完成；47任务7完成/38进行中/2待外部，正式186条9通过/172部分/5未执行保持。当前仍为开发阶段，产品/设计/技术和上线基线不改。
