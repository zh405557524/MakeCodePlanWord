# T-03 / T-47 本地地址配置与普通iOS免费帮写联验

2026-10-19。App dev `49c005c` 已提交，未推送；共享后端沿 `6bd40ee6`，本轮没有改Java、模型配置或数据库结构。由电脑通过Appium控制专用 iPhone17Pro / iOS26.5 模拟器，普通 `com.lxwx.catdrama` 1.0.0+1，真实本地8080及正式公共AI通道到 DeepSeek `deepseek-flash`。

## T-03 本地地址可配置

网络切换后本机LAN由192.168.31.243变为192.168.1.14，旧安装包继续访问旧IP；[实际离线页](run1/observations/O00006.png)与[前置阻塞报告](run1/result.json)保留，尚未提交帮写任务。参考Catsinger发现公共入口也用原固定局域网地址，本轮只给Catdrama补构建参数，不改写歌。

AppConstants.localServerAddress 支持 `CATDRAMA_LOCAL_BASE_URL`；未传时保留原默认，测试/正式地址和 `CATDRAMA_ENV` 三种环境语义不变。iOS模拟器本轮使用：

```sh
flutter build ios --simulator --debug --dart-define=CATDRAMA_ENV=1 --dart-define=CATDRAMA_LOCAL_BASE_URL=http://127.0.0.1:8080
```

Android模拟器可显式使用 `http://10.0.2.2:8080`；物理手机使用当前电脑可达LAN地址。授权串继续从本机私有配置注入，公开命令不放凭据。这里没有验证新的Android/物理机地址。本轮实际构建使用已有私密配置文件加本地地址参数。

9项既有启动/存储隔离方法在自定义本地地址下通过；另外默认/测试/正式三种模式各执行同2项启动方法，验证覆盖只作用本地环境，不累计成15个不同用例。analyze无问题、format及普通iOS模拟器构建通过；[源码摘要](local-address-source.json)、[分析](analyze.log)、[构建](ios-build.log)、[默认](bootstrap-default.log)/[测试](bootstrap-test.log)/[正式](bootstrap-prod.log)记录在此。9项执行回执来自本轮工具会话75162（退出0），没有重新跑全套App测试。

同App覆盖安装，未卸载/清数据；按既有后台地址隔离不直接恢复旧地址token，通过公共游客登录正常找回自建账号2，30积分/冻结0。此前个人图片仍存在。本轮未改其他对话的启动图/平台资源；普通构建使用工作树已有视觉资源，本轮没有做像素验收。

## T-47 真实流程

| 步骤 | 实际结果与图片 |
|---|---|
| 空名称点击帮写 | [明确1–20字名称/≤500字描述校验](run2/observations/O00020.png)，0个新任务 |
| 填名称与10字原描述后主动帮写 | [原输入](run2/observations/O00024.png)；[查询原任务入口](run2/observations/O00026.png)，未覆盖输入 |
| 第一次候选 | [129字免费候选](run2/observations/O00030.png)，点击保留后[原10字描述保持](run2/observations/O00034.png) |
| 主动再次帮写后终止并重启App | 第二个后台任务已成功，重开同一创建表单[恢复10字原描述与94字候选](run2/observations/O00042.png)，原任务/请求身份保持，没有因重启增加外呼 |
| 手动改为22字描述 | [手稿](run2/observations/O00044.png)、[过时提示与禁用应用](run2/observations/O00046.png)；控机工具也实际报告目标控件禁用，未把禁用点击当成功 |
| 保留手稿后第三次主动帮写 | [112字候选](run2/observations/O00056.png)，包含原手稿的右手银戒指；确认前仍为22字手稿 |
| 主动使用，再返回重进 | [确认后112字](run2/observations/O00058.png)、[重进仍相同112字](run2/observations/O00062.png)，候选不再待应用；只更新本机表单，未点击保存资产 |

3次明确用户点击对应3个任务，均属于同一clientFormId，后端 `financialState=FREE`、quote/charge为空，固定官方DeepSeek场景/模型；HTTP日志的3个独立callId均返回200，见[实际请求事件](provider-events.json)，未导出URL、提示词日志或凭据。[成功结果恢复前](before-termination.json)与[恢复/手改后](after-recovery-and-edit.json)两任务逐项相同。并未命中“仍在生成时强杀”窗口：第二个任务在终止前已成功，本轮仅证明成功结果恢复。

[开始](before.json)与[最终](final.json)：可用30/冻结0、6条既有流水、1个既有资产、1个既有图片任务/版本均保持；没有生成新图片、预建资产、发成长奖励或扣分。三份候选129/94/112字，确认后的表单及重进表单与第三份候选逐字相等，见[候选正文及计数](candidates.json)。

## 结论及边界

本地模型选择、普通iOS页面到真实后台/Provider的ROLE成功路径、保留原文、成功结果恢复、手改保护和主动应用已验证。T-47当前功能无需新增代码；本轮只修复阻碍联验的T-03本地地址构建入口。

完整TC-03-09/10、TC-X31仍部分验证：本轮未在手机覆盖SCENE/PROP、全部500字/坏输出、回执未知/明确FAILED、活动任务强杀、写盘中断、账号并发/完整隔离、Android/iOS真机及最新Figma。历史受控自动测试仍保留，不拿旧方法数冒充本轮执行；[控机报告](run2/result.json)blocked只表示完整矩阵尚未齐备，已执行子项通过。47项仍7整项完成/40未完成，186条12通过/171部分/3未执行，仍在开发阶段。

数据库改动：无结构/迁移或历史数据修复；仅测试账号3个免费任务与本机草稿的正常业务写入。既有资产和付费图片未修改。本机后台6313/8080保持，Appium控机会话已关闭释放设备锁；不触碰用户手机或其他模拟器。原始run/事件/日志在后端忽略目录 `.local/catdrama-tests/local-connect-20261019/description-ui/`，本机授权配置没有提交。

[验证汇总及文件摘要](verification.json)。本轮用量未取得，未额外查询。
