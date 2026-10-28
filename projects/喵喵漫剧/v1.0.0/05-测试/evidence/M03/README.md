# M03 故事大纲与分集页面拆分、编辑和自动保存

开发完成，待用户验收；全仓门禁仍有下述已复现的基线问题。两批 App 提交：`71f890d`（独立页面/路由）和 `906dcaf`（候选持久化/自动保存/最新版本确认），分支 dev，未推送、未部署。保留原有 iOS 工程和发布脚本并行修改。本次未改后端、数据库、模型配置、积分和生成接口。

## 实现结果

四页按 Figma 分开，进度页分别位于 story/progress 与 screenplays/progress，均为独立 index/controller/view；流程作用域持有各自唯一父 Controller，所有 Controller 直接继承 GetxController。作品恢复把 GENERATE 与 CONFIRM 映射到不同路由，成功替换进度页，返回等待后不会被迟到响应拉回；等待页自动查询原任务，没有新增查询按钮。

两种候选均可直接编辑。完整改稿写入现有账号、后台地址及作品隔离草稿，候选编辑立即排队持久化，500ms 后复用 apply 和 story/episodes PUT 串行追赶最新输入；普通已保存稿沿用原同步链路。候选只应用一次，未知回包保留原键、原请求体，保存中继续输入不会被旧回包覆盖。未编辑候选浏览不应用，确认仍使用原有直接确认路径。覆盖授权绑定任务、来源及目标版本。

本机 candidateEdit 在批准结构上补充可空 `appliedRevision`：null 表示应用结果必须原键恢复；非空表示已收到应用回执、正文仍待保存。它只是本机恢复检查点，不增加服务端字段。保留 pendingApply 直到最新改稿全部保存；旧缓存缺省 null，旧确认请求保持原体恢复。标题按 Unicode 标量计20、每段正文10000，不截断无效本机输入。

点击主按钮冻结本次提交，先保存最新稿，再确认。Story 仅由 story/confirm 受理一个剧本任务；Screenplays 确认同一作品后进入制作设置，没有自动分析。重新生成取消/失败保留旧稿，失效候选不会覆盖后来的本机编辑。

## 开发检查

环境 Flutter 3.41.6 / Dart 3.11.4。完整命令、退出码及日志见 [verification.json](verification.json)。日志副本仅移除终端行尾填充空格，原始摘要见 log-integrity.json；initial-analyze-before-fixes.log 保留开发中的初始失败，不充当最终基线结果。

| 检查 | 结果 | 证据 |
|---|---|---|
| 第一批页面/路由 | 74项通过，范围 analyze 0问题，iOS构建通过 | batch1-tests.log、batch1-analyze.log、batch1-ios-build.log |
| 最终计划内9文件测试 | 130项通过，退出0 | [final-scope-tests.log](final-scope-tests.log) |
| flutter analyze --no-pub lib test | 0问题，退出0 | [final-scope-analyze.log](final-scope-analyze.log) |
| 完整 flutter analyze --no-pub | 退出1；2处原有 getter 错误 | [final-full-analyze.log](final-full-analyze.log) |
| flutter test --no-pub | 1688通过、1跳过、16失败，退出1 | [full-tests.log](full-tests.log) |
| Android debug / iOS simulator debug 构建 | 两端退出0 | final-android-build.log、final-ios-build.log |
| git diff --check | 退出0 | verification.json |

完整 analyze 的 integration_test/shot_navigation_test.dart:360、377 仍引用不存在的 ShotDetailController.lines。完整测试16项失败位于未修改的资产、报价、首页、任务、媒体和剪辑用例。在修改前提交 `6ae4d17e52fc34fbda3a2cb8a625724a7e24e14a` 的隔离导出中复跑相关9文件，122通过、16失败，失败名称逐项完全一致，新增失败0；见 [baseline-comparison.json](baseline-comparison.json)、[pre-m03-failing-files.log](pre-m03-failing-files.log)。未降低断言或修改这些文件；全仓检查不得记为通过。

专项测试覆盖两页的候选/已应用改稿、标题20/21、方向/正文10000/10001、空白与emoji、真实文件落盘/重启、持续输入、离页自动保存、应用和PUT回包丢失、旧请求固定体重放、来源版本冲突、-560017 授权、重新生成取消/失败、旧候选与新手改、确认回包未知恢复和唯一任务。账号/后台隔离复用 draft/input/jobs 的专项检查；不把单元测试等同实体设备矩阵。

## 普通 App 的原生检查

普通 main.dart，专用 iOS 模拟器 `B1166574-BDD1-4149-9D55-542D091311C1`，逻辑375×812。桌面 Appium/XCUITest 4725 驱动实际 App，HTTP夹具仅绑定 localhost:18783，合成游客9001与作品101/102，无真实Provider、生产账号或收费请求。夹具源码 [http_fixture.py](http_fixture.py)，运行期状态、计数和受理任务输入是服务端受控证据，不是生产抓包。

受控主路径已完成，见 [native-checks.json](native-checks.json)、[native-final-state.json](native-final-state.json)、[phone-recovery执行报告](phone-recovery/result.md)：

1. 修改梗概、两集标题及方向，自动同步；清空方向后点击主按钮，确认和生成计数仍为0。第一阶段逐步截图见 phone-batch2/observations/。
2. 原生21字标题完整保留、提示超限、不上传且不能生成；20字成功上传，再恢复最终标题。截图 O00025、O00029（phone-recovery）。
3. 点击生成剧本到独立进度页 O00035，再进入分集确认；storyConfirm=1、SCREENPLAYS=1，任务输入逐字等于最新已确认故事，见 native-story-confirm.json。
4. 直接编辑未应用的分集候选。注入一次正文PUT失败，出现真实错误/原稿保留/重试（O00044）；点击现有重试成功（O00046），候选应用次数不增加。输入中的emoji和换行逐字保留。
5. 修改两集标题、完整正文。Appium terminate/launch 后由作品列表重新打开，O00064～O00072 保留两集完整文字；已将界面树与两个 inputs/screenplay-*.txt、云端episodes逐字比较通过。
6. 点击开始制作，O00074 显示同一作品101的制作设置。screenplaysConfirm=1，无运行任务；集号仍1、2，正文原样进入待分析分集。本轮未点击制作设置下一步，真实素材分析未执行。

最终计数：STORY=0、SCREENPLAYS=1、apply=2（故事/分集各一次）、storySave=11、episodeSave=5、storyConfirm=1、screenplaysConfirm=1。多次PUT来自逐项编辑和边界恢复，不是重复生成。

10001字符原生输入时 WDA 无回执，随后截图也超时；该步骤停止并保留 phone-batch2 blocked 结果，未判通过。恢复仅重启本轮 Appium/WDA 会话，不清App数据。完整10000/10001及无效候选磁盘恢复由自动测试通过，原生全部边界/四类中断矩阵仍待执行。初次重装 debug 产物直接启动短暂停在启动页，使用正常 flutter run 启动后，上述 Appium进程终止/启动检查成功；不据初次启动页推断生产缺陷。

phone-batch1/phone-batch2 是保留的阶段观察，未作为完整原用例通过；phone-recovery 仅本次受控单作品UI补充通过，original_case_status 仍 not_assessed。原186用例正式统计不变。

## Figma 对照

通道4f6qy6d4已读取四页及四个公共状态节点。源稿见 figma/ 与 source.json。完成逐张目视核对标题、说明、卡片、字体、间距、颜色、固定底部渐变、等待按钮和键盘滚动；未做全状态自动像素验收。

| 页面 | Figma | 原生对照截图 |
|---|---|---|
| 故事生成进度 | 5:4293 | phone-batch1/observations/O00045.png |
| 故事确认 | 5:4585 | phone-batch1/observations/O00042.png（完整顶栏）；phone-recovery O00025（校验态） |
| 剧本生成进度 | 5:4527 | phone-batch1/observations/O00053.png；phone-recovery O00035 |
| 分集确认 | 5:4648 | phone-recovery/observations/O00072.png |

差异说明：Figma示例3集，夹具2集，集数/集号/示例正文未写死；iOS26.5顶部安全区50pt，稿状态栏44pt，正文随平台整体下移6pt；系统时间/字形/动态文字及新增的原有保存反馈不作为像素一致结论。首次复用首页夹具少categories曾出现解析Toast，已补齐夹具并重拍，未修改首页生产代码。进入动画过程的截图保留原样，最终对照使用稳定帧。

## 验收边界

R-06、R-07、AC-09-01 的本轮开发覆盖映射写入测试.md的M03补充表；M99追加同一作品的大纲→分集→制作设置路径。本轮未验证真实后端/Provider生成质量、真实账户积分、Android实体手机、完整三来源原生旅程、全部原生故障注入、实际素材分析取文、部署或用户验收。M01及正式验收结论不变；待用户验收，完整门禁因基线问题未通过。
