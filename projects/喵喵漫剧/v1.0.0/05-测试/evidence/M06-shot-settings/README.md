# M06 视频编辑参数保存范围：开发验证

日期：2026-10-28（用户时区）。功能及本次开发验证完成，待用户验收；未部署。

本地 dev 提交：App `13de940`；后端 `125fccfb`。未推送。

已实现：视频编辑右上角“参数设置”，打开当前镜头的制作设置；保存时默认“仅修改当前镜头”，可选“修改本集全部镜头”。单镜头沿现有 PATCH，整集沿新增 PUT，在同一事务内先校验所有有效镜头再覆盖。失败/冲突保留参数与范围，未知回执先查询；保留描述和素材草稿，清理旧参数覆盖，真实并发冲突继续提示。原创建流程保留“下一步”。无数据库迁移、Figma 修改、任务重生成或历史快照重写。

## 验证结果

| 边界 | 结果 | 证据 |
|---|---|---|
| Flutter 静态分析 | 0 问题 | flutter-analyze.log |
| 制作设置、下一步及镜头回归 | 209 通过、0 失败（含 11 项新增保存范围测试） | flutter-tests.log |
| 后端镜头保存 | CatdramaShotTests 29 通过、0 跳过 | backend-results.json |
| 后端原制作设置/分析回归 | 16 项中 14 通过、2 个既有失败，0 跳过 | backend-results.json |
| 失败基线复测 | 用本次修改前的 Controller/DTO/Service 编译，2 个相同分析用例仍失败 | backend-baseline-results.json |
| Android ARM64 Debug 专用测试入口 | 构建成功 | android-build.log |
| 电脑操作 Android 模拟器 | 4 条桌面用例通过；18 组截图/XML/只读状态 | desktop/desktop-result.json |
| 工作区路径检查 | audit 通过 | workspace-audit.json |

后端两个既有失败：
- duplicateEpisodeIdsNormalizeAndPartialRetryPreservesAlreadyAnalyzedEpisodes
- activeUnknownAndSuccessfulAnalysisCannotBeResubmittedButFailureCan

均在分析重试路径返回 -560001“作品已进入其他阶段，请刷新后操作”，用例期待 200。本次未修改此分析逻辑；没有把后端全套回归记为全部通过。基线将三份改动前源码用于独立构建目录，并排除依赖新 DTO 的新增镜头测试文件；未改动工作树源码。

## 桌面实测与视觉核对

专用 AVD Catdrama_Editor_20261025 / emulator-5570，未操作已连接实体机。实际 Flutter 页面由 ADB 输入、点击和滚动；控制端口 18747 仅 GET 读取状态，不能执行保存。

1. 编辑描述追加 M06-draft，仅留本机；点击右上角入口，初值为当前镜头 720P。制作设置保留模型、分辨率、时长上限、比例和风格，底部显示“保存设置”。
2. 选择高清测试模型/1080P，取消范围弹层后写入数仍为 0，表单不丢失。
3. 默认当前镜头保存仅发 1 个 PATCH，只有 expectedRevision 与 productionSettings。原同集第二镜头独立设置、其他分集、作品默认和云端描述不变；返回原镜头，本机描述保留，费用由 12 刷新为 24 积分。
4. 再次进入后不修改表单，选择整集并确认，仅发 1 个 PUT。两镜头参数统一，覆盖第二镜头原独立设置；其他分集/作品默认不变，返回原镜头，无生成或分析请求。

实读截图并与本次确认的交互、现有视频编辑与制作设置样式比较：入口未遮挡标题；范围弹层首项默认勾选、切换整集勾选正确；表单、按钮与长文案无裁切。费用和描述保留均在页面可见。

重点截图：
- [入口](desktop/01-video-edit.png)
- [制作设置](desktop/05-production-settings.png)
- [默认当前镜头](desktop/09-save-scope.png)
- [费用和描述草稿](desktop/13-current-fee.png)
- [整集选择](desktop/16-whole-episode-selected.png)
- [整集保存后返回](desktop/17-whole-episode-saved.png)

## 复跑

App：运行 flutter analyze --no-pub，以及 flutter test --no-pub test/creation/production_scope_test.dart test/creation/production_test.dart test/creation/production_next_test.dart test/shots。

桌面：用 test_driver/production_scope_desktop.dart 构建专用 debug APK，仅安装隔离模拟器；adb forward tcp:18747 tcp:18747，重新启动该入口后执行 python3 desktop/desktop_check.py --serial emulator-5570。入口每次启动使用新临时存储及受控数据。

后端：在项目 .test/catdrama-tests/pg-* 下新建自有 PostgreSQL 实例，数据库 catdrama_test；设置 CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:<隔离端口>/catdrama_test 后运行 ./gradlew test --tests '*CatdramaShotTests' --tests '*CatdramaProductionSettingsTests'。本轮端口 63654；只操作自有测试实例，测试各自创建、清理随机 schema。

## 验证边界

App 使用受控 HTTP、账号、模型价格与素材；后端使用真实 Spring/JWT/PostgreSQL 事务与权限链，但模型能力为测试数据。未运行真实供应商生成、真实费用扣除、真机联调、共享服务部署、已部署接口联调或生产验收。原始正式验收计数不变。

保留了任务开始前的 iOS 工程修改、工作区未跟踪产品/设计基线和后端并行模型接入改动。代码提交仅含本任务范围；文档本次增量另存 workspace-changes.patch 便于在既有混合工作区审阅。

工作区已跟踪文档仅提交本次追加段落；产品四文档与设计说明在任务开始时已未跟踪，完整文件继续留在原位置，本次增量收录于补丁。未把原有未提交内容合并进本次提交。

验证结束后已停止本任务专用 PostgreSQL 和模拟器，截图与状态文件保留。
