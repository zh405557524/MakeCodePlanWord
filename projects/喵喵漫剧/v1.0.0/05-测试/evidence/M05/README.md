# M05 客服与协议页面修复

日期：2026-10-28。状态：代码与开发检查完成，正式静态发布阻塞、待用户验收。数据库改动：无；没有Java、迁移、余额、商品或真实支付操作。

## 已实现

- Web新增客服、隐私政策、用户协议、算法备案、积分充值协议及自有资源；协议版式参考写歌，内容按漫剧创作、手机剪辑、积分与订单规则调整。
- 客服微信`catai01`，邮箱`lijian@lxwanxiang.com`；备案按本会话用户最终指定的带货两项字节信息展示。
- App五项入口固定使用`https://www.lxwanxiang.com/sites/catdrama/`，不调用后台正文、不附带账号请求头，不随业务API环境切换而失效。
- 充值协议使用原命名路由；按钮不依赖后台正文；阅读不自动勾选，失败不影响支付资格规则；返回保留套餐、渠道和勾选。
- Android号码认证协议URL与官网邀请注册页同步；其他说明的ABOUT正文读取继续保留。
- 文内站内链接可继续阅读；进入客服时启用复制脚本，返回协议后关闭。主页面网络或HTTP失败可原地址重试，子资源失败不替换整页，失效回调不能覆盖新页面。

## 验证结果

| 检查 | 结果 | 证据 |
|---|---|---|
| 静态页面、邀请页资源与链接、复制成功/拒绝/无API/双失败 | 22项通过 | web-tests.log |
| 固定链接、设置、充值、登录、凭证失败与用户反馈定向测试 | 串行144项通过 | flutter-tests-serial.log |
| Flutter静态分析 | 0问题 | flutter-analyze.log |
| 普通Android Debug构建 | 通过 | android-build.log |
| iOS模拟器预览入口构建 | 通过 | ios-preview-build.log |
| Android/iOS五页本地原生WebView预览 | 已截图并核对阅读版式、备案表格及滚动 | android-desktop-preview.json、ios-desktop-preview.json、screenshots/ |
| 两端客服复制 | 原生剪贴板读取为`catai01` | android-interaction.json、ios-interaction.json及复制截图 |
| 两端实际充值页面→原协议路由→返回 | 保留6000积分套餐和已勾选状态，创建订单0次，无正文API请求 | android-interaction.json、ios-interaction.json |
| 正式网页、真实运营商SDK入口 | 未验收 | 下文发布边界 |

并发运行7个测试文件时，反馈页已有的固定延时等待发生一次`pumpAndSettle`超时；`flutter-tests-concurrent-failure.log`保留原失败。本任务没有修改反馈业务，改用`--concurrency=1`后144项通过。初轮平台测试参数编译问题已修正；充值并行新增语义测试的handle在返回前释放，避免测试资源泄漏。

## 桌面控机边界

使用专用Android `emulator-5572`（T17 AVD只读实例）和专用iOS `44CBBE60-E35E-4C71-9B1B-A13AA15B425B`（Catdrama-Legal-M05）。未安装或操作实体手机，未覆盖其他任务的模拟器。

电脑通过已有`phone-ui/device_drivers.py`的ADB/Appium接口驱动；可读脚本为`desktop_preview_check.py`。专用App入口为App仓库`test_driver/legal_desktop.dart`，仅导航、夹具订单和本地原生网页预览；全部购买渠道关闭。Web内容来自本机静态服务，五页均记录真实标题、URL和截图。

首次iOS截图早于原生合成层完成，出现一张空白预览；核对后等待绘制并重新拍摄，最终截图有实际正文。Android只读模拟器启动期间曾重启，恢复后重跑五页并验证；没有将中断或空白画面登记为成功。

本地网页预览证明HTML在两端原生WebView中的展示和复制；固定正式URL及错误回调由平台边界替身自动化另验。两者不等于正式站点、发布包、真实支付或运营商验收。

## 正式发布边界

当前SSH只读预检不能用已有连接凭据登录，未写正式服务器。正式URL仍可能由公司首页兜底返回HTTP200，实际充值协议路由的未发布画面保存在`*-production-page-unpublished.png`，不能记作正确协议已上线。

已准备[9文件静态发布包及SHA-256清单](release/README.md)，不包含管理后台并行修改或其他App。发布成功后还须核验五页标题、正文、资源及实际App/原生授权入口。通过前暂停App发布，M05保持待验收，不提高版本正式测试或上线计数。

## 执行命令

```sh
node --test test/catdrama_public_pages_test.mjs test/catdrama_invite_web_test.mjs
flutter test --no-pub --concurrency=1 test/settings/legal_pages_test.dart test/settings/settings_test.dart test/payment/recharge_test.dart test/pages/auth_test.dart test/pages/auth_widget_test.dart test/services/auth_persistence_failure_test.dart test/widgets/auth_reward_feedback_test.dart
flutter analyze --no-pub
flutter build apk --debug --no-pub
```

## 提交与并行工作

- App：`279eb9d8b033b7962d439af04f5e628c0c2df16b`（dev）。
- Web：`972698aaaeafd4c7533bb6d48aaf5fc895310d33`（main）。
- 均为本地提交，未推送、未正式部署。共享充值、订单及后台文件中的其他任务修改继续保留。
- App提交通过开工前快照分离本任务差异后暂存；没有提交M04并行新增的充值结果UI、语义控件或订单逻辑。上述自动化与构建验证针对当前合并工作区；不把未提交的M04工作记为本任务交付。
