# T-40 反馈与协议正文页面复核

2026-10-17，App dev `fd47838`，未推送。修复会话失效后提交按钮仍高亮的问题：反馈View向原AppGradientButton传入既有disabled状态，采用公共0.45禁用样式。控制器、公共按钮、反馈接口及后台均保持。新增1项Widget回归及双端原生测试/严格driver，生产代码只增加这一行。

原按钮onPressed已经为空，原样式仍为1.0；[红例](red-disabled.json)在View未修改时真实失败，修复后[33项设置](related-validated.json)、[1261项全套App](full-validated.json)、[analyze](analyze-validated.json)和[4文件格式](format-final.json)通过，0失败/跳过。前面的32项/1260项是历史基线，不与最终结果相加。

| 场景 | 双端实际结果 | 验证范围 |
|---|---|---|
| 反馈边界/失败/返回 | 501码点无POST；500个emoji与联系方式进入等待，输入和按钮禁用；503后两项保留，明确重试后返回原账号页，共2次POST | 实际页面、Dio、回环HTTP；请求正文、联系人和空附件已核对 |
| 等待中换会话 | 私有表单清空并禁用；原回执不关闭表单、不显示成功；提交按钮最终透明度0.45，POST仍1次 | 会话通过隔离测试注入，不证明真实登录/号码认证 |
| 设置及正文 | 从实际设置页打开Markdown版本real-2；原生HTML标题读取正确，内嵌改标题脚本未执行；未配置后重试恢复，环境变化后的旧正文被丢弃 | 原生WebView、现有正文组件与公共GET，正文请求不携带账号token |

最终采用`native-07`两端各3条完整方法、各13张实时系统图；SDK“+5”包含两个全局hook。26张图已通过六份总览实际查看，失效按钮变暗可见，iOS旧转场中间帧不作为最终截图。[Android报告](native-07/android/android-settings-flow-result.json)、[iOS报告](native-07/ios/ios-settings-flow-result.json)、[截图及摘要](screenshots.json)、[查看记录](visual-review.json)。

原生测试使用生产账号/反馈/设置/正文Widget、控制器、HTTP和存储。导航壳为隔离测试路由配置，保留原RouteName及观察器；不代表普通App启动、完整主壳或真实后台联验。输入为框架注入，不能代验系统输入法。资源缓存为空的测试目录，本轮没有重新声明真实大容量清理通过；此前缓存删除/保护证据保持。

| 资料 | 链接 |
|---|---|
| 结果及逐条范围 | [result](result.json)、[case-results](case-results.json)、[缺陷](defects.json) |
| 源码及提交 | [source](source.json)、两端各自的source-before-build.json |
| 最终总览 | [Android1](contact-sheets-ui-final/android-1.jpg)、[Android2](contact-sheets-ui-final/android-2.jpg)、[Android3](contact-sheets-ui-final/android-3.jpg)、[iOS1](contact-sheets-ui-final/ios-1.jpg)、[iOS2](contact-sheets-ui-final/ios-2.jpg)、[iOS3](contact-sheets-ui-final/ios-3.jpg) |
| 失败/准备修正 | [attempts](attempts.json)、[预检](preflight-attempts.json)、[输入探针](live-input-probe.json) |
| 日志/范围 | [日志原/公开摘要](log-archives.json)、[scope](scope-check.json)、[清理复查](cleanup-recheck.json)、[门禁](guard-result.json) |
| 复核 | [manifest](manifest.json)、[verification](verification.json) |

前期失败均保留：测试截图主动失焦后再注入同一框，Integration binding未重建测试输入连接，实际还保留501；默认Widget binding会自动重置，错误的桌面假设未复现，已记录。关闭registerTestTextInput的独立SDK探针才复现，清focusedEditable后恢复500。探针不计业务验收。协议返回另经历了转场双节点、缓存收起的设置行及被遮挡列表命中失败，修正只在测试操作中等待/滚动，不关闭严格命中检查。`navigationResolutions`中的route是测试路由调试值，不用它推断页面是否返回；页面按实际Widget核对。

`native-05` Android及`native-06` iOS一度完成行为断言，图中却发现失效按钮外观仍正常，因此增加真实产品修复并完整重跑`native-07`；前两轮不能替代最终视觉验收。旧`contact-sheets-final`及android-harness-reuse.json只作为历史。本次只修反馈调用；同时检查设置/账号安全按钮已有disabled传值，公共按钮样式不改。

原有35份Android和69份iOS相册图片/视频的摘要、大小及权限保持；没有保存相册、卸载App或使用USB真机，自有模拟器已停止。[Android清理](native-07/android/cleanup.json)、[iOS清理](native-07/ios/cleanup.json)。后台未启动/修改/重跑，无接口、数据库结构、依赖或媒体引擎改动。

Figma通道rq4owed6本轮返回Not connected，见[原始连接结果](figma-connection.json)。沿保存的P-28/P-29参考，最新设计核对、真实公共反馈工单、真机输入法/容量/生命周期继续待验；按用户要求登记后不阻塞其他开发。整项T-40仍未完成，开发阶段、47任务7完成/38进行中/2待外部及正式186条9通过/172部分/5未执行保持。

只读复核：`python3 verify.py`，不运行设备或接口。复跑使用`run_native.py native-新编号`，必须使用新的证据目录和已登记自有模拟器；不会发送真实反馈。`run_app_checks.py`保留App实际机器事件。原始日志/备份在本机忽略的originals；公开gzip仅遮盖ADB公钥并记录两份摘要。
