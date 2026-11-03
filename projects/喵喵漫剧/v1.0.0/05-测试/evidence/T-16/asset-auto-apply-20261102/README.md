# T-16 / T-47 个人资产生成后自动应用

执行日期：2026-11-02（本机时区）。用户已批准的单批次实现；开发验证不等于用户、真实供应商、真机或上线验收。

## 实现与根因

此前个人资产生成只入库为候选，自动应用依赖 App 的本机授权和完成回调；创建入口还遗漏了授权。旧回调把入库后 revision 与生成前 revision 直接比较，而入库本身会增加一次版本，导致没有用户修改时也跳过应用。

- 个人角色、场景、道具创建和重新生成报价均显式传 `autoApplyAssetResult: true`。旧请求缺省 false，不改历史任务快照。
- 后端冻结 `REPLACE_IF_UNCHANGED`，完成校验、审核、存储后的入库事务持有资产锁，同时核对原 revision 和原应用图片。未修改才设置当前图及 READY，入库与应用只增加一次 revision；修改过则仅保存历史。重复发布提前返回，失败不替换旧图。
- 手选其他图或重新确认当前图均调用原 apply 接口。每个新幂等键推进一次 revision，原键重放不推进；失败不会假装本机已应用。
- 新策略 App 只刷新；旧任务仍按原策略恢复，仅对持有本机授权的任务按“原 revision + 1”核验，再用核实后的 revision 提交原应用流程。
- 无数据库字段、迁移、接口路径、模型调用、审核或计费流程改动。不批量回填旧候选；旧图可在历史免费应用。

App 提交：`74ed821`（dev，未推送）。后端提交：`cbb24d90`（dev，未推送）。工作区需求、评审、设计、接口及计划已同步；保留历史确认记录。产品四文档和设计文件原本属于尚未提交的工作区迁移，本批保留其本地更新，不将整份迁移夹带提交；已跟踪的接口/计划/测试文档只提交本批追加章节。

## 自动检查

| 检查 | 已执行结果 | 说明 |
|---|---|---|
| Dart format | 通过 | 本批 11 个 Dart 文件，最后一次 0 个格式变化 |
| Flutter analyze | 通过 | 最终全项目 No issues found；并行邀请模块修改曾短暂出现编译/分析错误，最后已消失；本批 11 文件单独分析也通过 |
| 创建/资产/报价定向回归 | 156 通过 | `test/generation/quote_test.dart`、`test/assets/asset_test.dart` 串行最终复跑；含三类真实创建表单的报价/提交授权、旧任务版本变化、重开恢复、新策略不补发 apply、确认当前图成功/失败 |
| 资产与生成扩大回归 | 429 通过、4 失败 | `test/assets test/generation`；随后新增的 5 项已包含在上述 156 项中。两次统计不相加冒充独立用例总数 |
| PostgreSQL 定向回归 | 101 通过 | 独立数据库真实事务；实际业务处理器，供应商、审核及外部存储边界受控 |
| PostgreSQL 扩大回归 | 115 通过、72 失败 | 初次 187 项；与修改前生产代码对照，72 个失败用例完全一致，详见下表 |
| Android debug 构建 | 通过 | 生产页面与控制器，专用测试启动入口及本机 HTTP 夹具；不作为正式安装包交付 |
| git diff --check / 工作区路径审计 | 通过 | 本批代码、文档增量；不夹带其他任务改动 |

新增后端场景：ROLE/SCENE/PROP 首次生成和带旧图再生成；源任务成功、后处理未完成不应用；描述修改、其他图选择及重新确认当前图保护；真实事务回滚及原结果恢复；重复发布不推进版本、不重复奖励或扣费；失败保旧图并只退款新尝试；非个人、批量等非法授权拒绝；原请求默认候选、作品单项候选和批量首图兼容；现有 OpenAPI 契约。

后端定向范围：`CatdramaAssetTests`、`CatdramaChargeTests`、`CatdramaImageUploadTests`，以及 `CatdramaAssetLibraryTests` 的自动应用、契约、旧个人候选、作品原策略用例。

### 既有失败与隔离边界

| 范围 | 数量 | 具体差异 |
|---|---:|---|
| Flutter `image_batch_test.dart` | 1 | `small-screen batch items scroll while confirmation stays fixed`：pumpAndSettle 超时 |
| Flutter `sound_profile_test.dart` | 1 | `shot quotation uses one unit independently of actual seconds`：夹具 Map 类型转换失败 |
| Flutter `auto_library_test.dart` | 2 | `new result becomes preview once...` 预期 5514 实际 5512；`failed task preserves old application...` 布尔断言不符 |
| Java `CatdramaImageBatchTests` | 23 | 旧夹具缺分集分析/阶段等前置条件，主要返回 -560002；部分旧阶段断言不符 |
| Java `CatdramaAssetLibraryTests` | 23 | 旧作品夹具主要缺分集分析阶段，返回 -560002 |
| Java `CatdramaImageTests` | 26 | 旧来源任务/后处理契约断言，包括仍要求来源结果直接含 imageVersionId，以及旧阶段预期 |

Flutter 的 4 项使用修改前生产文件单独复跑，4 项同样失败。Java 六个套件分别用原生产文件重跑，失败用例集合和参数用例数量一致。本批没有修改这些既有失败来制造全绿。新增作品策略兼容用例仅为自己的夹具设置既有 MATERIALS 阶段。

工作期间另一个任务修改作品素材首图规则，涉及相同后端文件；另一个 App 任务修改邀请模块和中文文案。本批提交仅纳入个人资产增量，保留其他任务的工作树改动。后端复验使用本批源码快照和独立构建目录；中途共享构建目录出现 ClassNotFound 测试执行器错误，不能把该次命令记为成功。

## 固定池电脑控机

领取 `Catdrama_Editor_20261025`，Pixel 4、API 37、1080×2280、play_store=no，实际序列号 emulator-5554。未创建、克隆或擦除设备。租约、关闭和释放记录保存在 App 本地 `.test/asset-auto-apply-20261102/`；设备及本任务测试服务已关闭，租约已释放。

电脑端 Python runner 使用现有 phone-ui `AdbDriver`，按步骤点击、输入、返回、截图；运行生产页面。宿主机 HTTP 夹具独立于 App 进程，保存报价和任务，完成阶段由电脑控制。先 force-stop，再验证 App PID 为空，然后在宿主机完成应用，最后启动 App 查看结果。

| 用例 | 观察与请求核验 | 本地截图 |
|---|---|---|
| 角色有旧图重新生成 | 原图存在；确认一次 120 积分报价；报价授权为 true | [旧图详情](desktop-check/S003-old-image-detail.png)、[确认弹窗](desktop-check/S004-regenerate-confirmation.png) |
| 生成/后处理禁止进入详情 | 点击卡片仍停留资产库，分别显示生成中、图片处理中 | [生成中点击](desktop-check/S007-generating-card-stays-in-library.png)、[后处理中点击](desktop-check/S009-processing-card-stays-in-library.png) |
| 重新生成后关闭 App | 宿主机完成后 revision 1→2，当前图 5511→5512；重开详情显示新图 | [重开后的详情](desktop-check/S013-restarted-detail-new-image.png) |
| 场景首次创建 | 手填名称和描述，无帮写；现有字数统计和生成确认保留 | [创建表单](desktop-check/S018-scene-ai-create-form.png)、[首次生成确认](desktop-check/S023-scene-generation-confirmation.png) |
| 首次创建后关闭 App | 当前图从空变为 5513、revision 1→2；重开列表及详情显示图片，描述仍为本次实际输入值 M | [重开列表](desktop-check/S027-scene-current-image-after-restart.png)、[重开详情](desktop-check/S028-scene-detail-current-generated-image.png) |

最终请求记录：2 个授权报价、2 次生成提交、0 次客户端 apply。逐步 PNG、事件及校验状态均只保存在本地，不提交 Git。中途尝试的截图均保留，表中只引用已检查的稳定状态；S025 是一次启动未成功后的截图，不作为重开通过证据。

电脑控机使用协议及本地图片缓存夹具，图片用于区分前后状态，不用于评价生成内容；这里不是手机连接真实 Spring Boot / PostgreSQL / Provider 的端到端业务测试。后端数据库事务另有独立自动化覆盖。三类资产的首次/重新生成由后端参数化测试覆盖，三类创建授权由组件测试覆盖；本轮设备代表路径为角色重新生成和场景首次生成，未把道具或相册的设备操作记为已执行。相册、六种创建无帮写、描述校验、编辑态选择由现有资产回归覆盖。

## 复现与本地原始证据

App 根目录：`/Users/soul/code/lxwx/catdrama`；后端根目录：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`。两边原始日志均在 `.test/asset-auto-apply-20261102/`。

```sh
flutter test --no-pub test/generation/quote_test.dart test/assets/asset_test.dart --concurrency=1 --reporter expanded
flutter test --no-pub test/assets test/generation --concurrency=1 --reporter expanded
flutter analyze --no-pub
git diff --check
```

Java 使用 `CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:59935/catdrama_test`，独立 PostgreSQL 18；仅测试实例初始化已有建表脚本，无应用库修改。最终隔离构建入口为 `owned.gradle`，被测源码在 `owned-source/`，测试结果在 `owned-build/test-results/test/`；`baseline-comparison-counts.json` 保存六套件修改前后逐用例失败对照。数据库已正常停止；保留本地测试数据和日志。

App 的 `final-focused-tests.log`、`final-analyze-after-concurrent-edits.log`、`assets-generation-tests.log`、`app-baseline-failures.log` 保存结果；`desktop_check.py`、`desktop_server_test.dart`、`main.dart` 是控机脚本、宿主机夹具和启动入口。`final-device-state.json`、两份 `*-completed-with-app-stopped.json` 保存关 App 后状态和请求记录。原始日志、脚本快照、图片及安装包不进入 Git。

## 上线与未验收项

先上线兼容旧请求的后端，再发布 App。新策略任务全部处理完成前，不回退到无法识别该策略的后端。本次未推送、部署或发布；未调用真实付费供应商，未进行真实 OSS、物理设备、商店渠道及用户验收，不增加历史正式验收通过数。
