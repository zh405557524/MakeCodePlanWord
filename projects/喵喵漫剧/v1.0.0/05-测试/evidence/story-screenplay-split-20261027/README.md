# 大纲与分集业务控制器拆分及重新生成修复

日期：2026-10-27（America/Los_Angeles）。范围内开发检查完成，待用户验收；未推送或部署。App 两批提交：`b0432b2`、`6ae4d17`；[源码与构建摘要](manifest.json)。

## 改动

`StoryPage` 与 `ScreenplayPage` 原本就是独立页面和独立实例。本轮按用户批准计划，将业务实现分别迁入 `StoryController` / `ScreenplayController`，两者直接继承 `GetxController`，删除两文件的 `creation/shared` 基类。网络、输入同步、任务服务及持久收据模型继续复用。

首次候选生成成功但尚未应用时，已保存版本仍为 0。旧逻辑据此只查找首次生成动作，漏掉服务端已经返回的重新生成动作，导致按钮禁用。修后两页各自读取对应的首次生成或重新生成动作，并保留操作中、结果未知、冲突和上游确认保护。等待态、重试和候选只消费本页任务；原 v2 持久键和确认接口保持。

## 自动化与静态检查

- 第一批故事 17 项通过；最终故事、分集、创建旅程、路由共 **46 项通过**，见 [最终日志](flutter-tests.log)。
- 新增覆盖：首次候选版本 0 + 后端重新生成动作；点击 View 中按钮；连点仅一个新请求；动作禁用/缺失；覆盖取消保稿。既有测试继续覆盖失败保已保存稿、未知生成沿原任务查询、确认丢回执原键恢复、账号切换。
- 故事确认测试新增交接隔离：分集控制器取得 SCREENPLAYS 任务，大纲不展示分集生成态；关闭故事控制器后分集仍能查询同一任务，剧本只生成一次。
- `flutter analyze --no-pub lib test` **0 问题**，见 [日志](analyze-app-tests.log)。完整 `flutter analyze --no-pub` 被两处本轮未改动的既有错误阻塞：`integration_test/shot_navigation_test.dart:360`、`:377` 引用不存在的 `ShotDetailController.lines`。未扩大本轮范围修改分镜测试。
- 普通 `lib/main.dart` iOS Simulator Debug 构建通过，见 [构建日志](ios-build.log)。`git diff --check` 通过。

一次补充回归曾因等待异步作品刷新不足导致 2 项断言失败；失败日志保留在 [修正前日志](flutter-tests-before-wait-fix.log)。测试改为等待“已提交且本页显示生成态”的真实状态，最终 46 项通过，未降低业务断言。

## 普通 App 电脑控机结果

设备：`Catdrama Creation Flow 20261020`，`B1166574-BDD1-4149-9D55-542D091311C1`，逻辑视口 375×812；App `com.lxwx.catdrama`，1.0.0+1，普通 `main.dart`。通过本项目 Appium/phone_test.py 操作，使用隔离本机 HTTP 夹具 `127.0.0.1:18781`，未接真实 Provider。

| 补充场景 | 实际结果 | 截图 |
|---|---|---|
| 大纲首次候选、保存版本 0 | 重新生成大纲可点击，进入等待后展示新大纲 | [点击前](story-before.png)、[新候选](story-after.png) |
| 分集首次候选、保存版本 0 | 重新拆分/生成可点击，进入等待后展示新分集正文 | [点击前](screenplays-before.png)、[新候选](screenplays-after.png) |
| 请求次数及目标 | `/projects/101/story-tasks`、`/projects/102/screenplay-tasks` 各 1 次；无应用/确认请求 | [结构化结果](ui-result.json)、[HTTP记录](http-requests.jsonl) |

本轮手机检查是 TC-06-03 的按钮补充场景，没有执行该原用例全部的取消和注入失败分支。因此 [控机报告](phone/result.md) 将原用例记录为 blocked / not_assessed；这不改变上表两个补充按钮检查通过的结论，也不提高正式测试验收计数。

首次 UI 准备中的两项夹具错误均保留观察：服务端模板对象被误修改造成完成回包异常（[错误日志](http-fixture-first-attempt.log)），修正后恢复原任务 101，App 自动查询到成功结果，没有再次提交；两个独立测试作品错误复用 clientWorkId，修正为唯一标识后重新进入分集页。生产代码没有为这些测试数据问题增加回退。首次首页夹具缺字段出现的加载错误也不属于本轮首页验收。

## 验证边界与复现

数据库改动：无。未调用真实 AI、未产生真实积分消费、未修改共享服务、未更新实体手机或发布包。页面布局和路由保持；本轮不声明新增像素级验收。

夹具位于 [http_fixture.py](http_fixture.py) 与 [fixtures.json](fixtures.json)，仅监听本机；模拟器包构建参数为 `--dart-define=CATDRAMA_ENV=1 --dart-define=CATDRAMA_LOCAL_BASE_URL=http://127.0.0.1:18781`。正常 App 登录到隔离测试游客后从作品列表进入两个样例。手机观察、操作回执和逐步截图保存在 [phone/](phone/)。
