# T-48 原生创建页续检

2026-10-20，用户要求继续并提供新Figma通道 `rzp7ki3a`。重新读取43:2604、43:3601、43:3727；模型与风格原图保存在本目录。本轮只新增测试和证据，业务代码没有新增改动。App提交 `e3470b6`，未推送/部署。

## 实际执行

专用 iPhone 13 / iOS 26.5 模拟器，运行真实Flutter创建页、弹层、公共预览、公共KV和Dio受控适配器。1条完整业务方法、4组断言通过；SDK输出的+3包含setUpAll与tearDownAll，不计3条业务。驱动严格检查完整结果，缺失报告或断言未完成会失败。

1. 输入名称和特征，旧配置有默认动漫但初始不选；选中后未应用不改变表单，再次点击取消；主动应用后生效，关闭面板不应用临时清空。
2. 模型面板先选择再确认；预置9张上传回执，继续追加显示最多9张Toast；切到1张模型仍保留9张且禁止生成，切回恢复可生成。
3. 点击参考图进入公共InteractiveViewer预览，关闭返回原表单。
4. 发起报价，验证referenceResourceIds按901至909原顺序进入请求；取消后名称、描述、9张参考图均保留，付费任务提交次数0。

[实际断言](result.json)、[最终日志](t48-native-drive.log)、[分析日志](t48-native-analyze.log)、[边界摘要](summary.json)。5张最终截图均为本次模拟器Flutter表面采集。已查看风格、报价及运行中的参考图/模型；Figma375×946、设备390×844逻辑视口不同，不宣称像素完全一致或用户视觉验收通过。测试未提供风格预览资源，空卡不是以虚构样图代替后台配置。

## 失败与复检

首轮测试夹具的新增模型未同步组合型号，返回数据校验拒绝，修正夹具后复检。第二轮等待被中止；随后通过页面操作模型切换，定位报价打开时背景生成按钮有持续动画，导致pumpAndSettle超时。最终改用报价内容和关闭按钮就绪条件，完整通过；未删除业务断言或修改业务代码来规避失败。前三轮记录保留，不能计入通过。

## 复现

在App仓库执行：

```sh
CATDRAMA_ASSET_UI_EVIDENCE=/tmp/t48-native-ui flutter drive --no-pub --device-id=66BD582B-5D24-4626-964D-074EEE9BE81C --driver=test_driver/asset_creation_ui_driver.dart --target=integration_test/asset_creation_ui_test.dart
flutter analyze --no-pub integration_test/asset_creation_ui_test.dart test_driver/asset_creation_ui_driver.dart
```

设备测试结束已关闭，下次执行前启动专用模拟器。上传回执为预置夹具，本次没有原生相册选择、实际OSS上传、真实Java/供应商生成、支付或物理设备验证；不替代已有后台54项/组件155项，也不重复统计它们。没有重启共享8080、改数据库或后台风格界面。
