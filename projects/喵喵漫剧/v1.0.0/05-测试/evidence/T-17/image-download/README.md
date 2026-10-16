# T-17 图片下载与相册原文件验证

2026-10-16，仍在开发阶段。资产详情和图片历史的下载已由占位提示接成实际保存。App dev `0727ef96`；旧分析测试的异步等待修正另属T-42，dev `1df60481`。未推送、部署或改后台/API/DDL/依赖；整项T-17及TC-03-07/08保持部分验证。

| 验证范围 | 实际结果与边界 |
|---|---|
| App自动检测 | 新增34项（控制器/缓存/版本15、真实图片解码/保存边界19）；全套985通过、0失败/跳过。最终相关52项、analyze及17文件格式通过 |
| 既有资源后端 | CatdramaResourceTests 18通过；Java及Mockito OSS，未改后台，无真实OSS/数据库联验 |
| Android | 自有API37模拟器，2个业务方法通过；实际MediaStore中4份图片独立读取/解码 |
| iOS | 自有iPhone15ProMax/iOS26.4模拟器，2个业务方法通过；仅添加照片权限、无读取权限下，4份真实相册文件独立读取/解码 |
| 文件身份 | 两端PNG/JPEG相册原字节一致；静态WebP按原尺寸24×18转PNG，Alpha一致。与桌面解码RGB最大差2，为Flutter透明通道整数舍入；Flutter内解码像素比较一致 |
| 缓存与副作用 | 每资源缓存命中，无重复签名/文件读取；下载不应用历史候选、不修改资料/引用、不生成或扣费。每端仅主动删除本次4个源缓存后，4份相册副本仍可读 |
| 图与环境 | 12张最终截图，关键4张已查看；测试夹具是自制24×18诊断图，不证明生成画质。rq4owed6实际未连接，沿缓存P-06 5:2354及已确认下载规则，最新Figma未验收 |

本次覆盖：详情PNG/JPEG/WebP保存；旧当前图过期、有效历史仍可下载；系统图；读取取消；权限拒绝；明确失败后用缓存重试；未知回执不自动重存；重复点击及图片/海报/视频互斥；切号、关页、途中到期/换版；文件丢失、坏图片、动画WebP明确拒绝。异常主要为App协议/方法通道替身，双端原生实测覆盖成功与只添加权限，未执行物理机拒绝后设置恢复、空间耗尽或大图性能。

实际发现并修正：

- 成功反馈移到按钮旁后，Widget测试原先停在首屏；改为滚动到真实按钮后检查。设备首跑的ensureVisible也未构建下方按钮，改为真实滚动到可点击位置。初始失败日志保留，未关闭断言。
- 旧剧本分析测试在候选发布后、落盘和原任务收尾前检查canApply；等待pending清空及working结束，原一次分析/一次应用断言保持。无业务代码变化，独立提交T-42。
- iOS既有相册插件经UIImage重编码。实际JPEG出现字节及像素差异，已改为AppDelegate内PhotoKit `addResource(fileURL)`复制文件，不fetchAssets或返回相册路径；PNG/JPEG最终原字节校验通过。Android继续现有相册插件，所有入口共用MediaLibrary互斥。

[最终结果](result.json)、[Android相册核验](android-album-verification.json)、[iOS相册核验](ios-album-verification.json)、[实际请求/回执](devices/ios-image-download-result.json)、[重编码前证据](original-copy-regression.json)、[清理与权限恢复](cleanup.json)。

复现入口位于App仓库：`test/plugins/media_library_image_test.dart`、`test/assets/image_download_test.dart`、`integration_test/asset_image_download_test.dart`，设备驱动为`test_driver/catdrama_business_driver.dart`。选择`CATDRAMA_TEST_PLATFORM=android/ios`和`CATDRAMA_TEST_SLICE=image-download`，指定`CATDRAMA_BUSINESS_EVIDENCE_DIR`后运行flutter drive，保留App安装；相册提取必须只针对本次版本501/502/503/511的自有测试图。

宿主对已提取文件的只读复核：使用含Pillow的Python执行[verify_album.py](verify_album.py)。日志/XML以gzip原样压缩，原始摘要见[归档清单](raw-output-archives.json)，原始失败不隐去；JSONL保持原始机器输出。`originals/`只作本机恢复，不入本次提交。

真实Provider/OSS、物理设备、系统拒绝/空间、最新Figma及完整业务链路仍未验收，历史3项旧公共后端夹具失败未修复。自有测试临时副本清零，原相册读权限恢复，仅停止本轮启动的两个QA模拟器。没有启动PostgreSQL或触碰生产。
