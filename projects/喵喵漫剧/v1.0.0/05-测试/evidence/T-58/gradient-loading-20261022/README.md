# T-58 公共渐变加载组件与素材页接入

日期：2026-10-22。App dev `c63c526`，未推送。按用户明确批准的公共组件计划实施，Figma 5:4858/5:4904本轮实读。

## 实现

- 公共 `AppGradientLoading` 通过widgets入口公开。active/LinearGradient必传，默认3秒，可配置duration、borderRadius和semanticsLabel，尺寸跟随父容器；内部不读取任务或Controller。
- 使用原青绿配色沿对角线连续平移，局部重绘。active关闭及减少动态效果显示原静态渐变；后台、非当前路由和TickerMode关闭时暂停，恢复保留相位，销毁释放资源。
- 素材页人物/场景/道具按原单项任务、批次子任务和GENERATING历史独立启停，排队、生成、FINALIZING和SUBMIT_UNKNOWN均覆盖。成功/候选/失败沿原展示，空卡保持静态；没有新增文字、图标、按钮、依赖、后端/API或收费规则。
- 素材页已有的流程确认修改及6个其他已暂存路径保持，未纳入本提交。仅提交6个任务文件和对应局部hunk。

## 验证

- 当前共享工作区：78项组件/批量/清单测试全部通过，7项组件测试已包含其中；组件绘制实测不同时间像素变化、循环衔接、定制参数、启停、后台、TickerMode、路由遮挡/返回、减少动态效果及销毁。
- 隔离基线副本：75项相关测试通过；最终组件7项复跑通过。隔离副本为c8c966f加本任务补丁，排除其他在途改动；source-snapshot.json、owned-changes.patch与validated-files.json记录来源。
- 全项目 `flutter analyze --no-pub --no-fatal-infos`：共享工作区0 error/0 warning，44条其他代码info；隔离副本0 error/0 warning，30条基线info。本任务没有新的分析提示。6文件format检查及git diff --check通过。
- iOS专用模拟器运行真实页面与回环HTTP夹具，5条完整业务流程全部通过：排除与取消、混合结果重试、历史分页错误恢复、原请求持久恢复、渐变卡片取消/运行/重进/结束。严格driver验证业务报告，不能只依据进程退出判断通过。
- 原生录屏1170×2532，H.264，10.73秒，包含至少两个3秒周期。图片区按4fps采样43帧、42个不同摘要，证明区域持续变化。已查看生成中及混合结果系统截图，名称、替换、图片区、成功图片和失败状态正常；未作跨视口全图像素一致声明。

## 失败记录与边界

首次共享工作区测试遇到并行资产改动尚未配齐的类型/参数，未修改其代码；后续同工作区78项和分析通过。隔离副本首次缺生成的package_graph，完成离线pub get后通过。首轮模拟器旧测试以“第一个InkWell”寻找返回，误触头部“应用”导致夹具404；已仅将测试定位改为原返回图片，整组重跑通过。attempt1日志与截图保留，不计通过。

模拟器使用受控数据，报告中的paidPosts仅表示夹具任务提交次数；真实Provider调用0、真实扣费0，未部署或更新用户手机安装包。版本正式测试和其他模块状态保持。

## 查看

[动画录屏](gradient-loading.mp4) · [生成中](native/ios-os-batch-gradient-running-0.png) · [成功/失败后](native/ios-os-batch-gradient-mixed.png) · [结构化结果](result.json)。

运行命令与原始日志见scoped-tests-shared-final.log、analyze-shared-worktree.log、simulator.log；native/ios-image-batch-result.json是严格driver业务回执，capture_native_gradient.py可复现原生截图和录屏。
