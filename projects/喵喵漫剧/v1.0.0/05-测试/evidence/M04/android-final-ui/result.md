# TC-23-01 套餐和商店实价核对 电脑控机记录

- 手机界面状态：passed
- 原完整验收状态：未自动判定（not_assessed）
- 执行人：AI
- 实际包：{"platform": "Android", "device": "emulator-5564", "app_id": "com.lxwx.catdrama", "version": "1.0.0", "build": "1", "os": "17", "model": "sdk_gphone16k_arm64"}
- 前置条件实际观察：M04 最终资源与简化续付确认文案；复用原受控订单，未清除数据。
- 实际结果：最终 Android UI 受控检查通过；跨进程幂等证据另见 android-recovery-result.json。原完整渠道验收不变。
- 缺陷：未登记

## 判定与证据

### UI-01 passed
- 原预期：1000/10、6000/50、12000/100来自配置；iOS显示有效商店价，异常禁下单。
- 实际：最终原单确认显示原1000积分与10元，无技术文案；普通充值无制作说明、原单提示或常驻重试。重装测试包后仅夹具临时目录重新初始化，此轮不作为跨重启证明。
- 证据：observations/O00005.png；SHA256 61f08323ee0acb5db85dd6064c01009ac2168e497fc1ca23cdebafede58972e4
- 证据：observations/O00011.png；SHA256 404d245c05f51ba2cc3fc0df1b49cb16af2e65dcadf227f7068be40bba927f90

## 仍需按原用例核对

保存实际商品价格币种，无演示价代付/会员前置。

对照请求/响应、持久化记录、输入版本和本机文件或公共流水；记录真机画面、实际媒体/渠道返回及构建；将可复查结果关联本用例，不能只凭按钮状态判成功。
