# Android 已安装包冒烟脚本

本目录是喵喵穿搭工作台中的唯一脚本入口。`android_smoke.py` 操控手机上已经安装的 `com.lxwx.catoutfit`，通过版本参数核对本次测试包，不会构建、重装或清空 App。需要 Python 3、ADB、已解锁且已授权 USB 调试的 Android 手机。运行前先用 `adb devices -l` 确认设备序列号，并确认手机上是预期账号。以下命令均在本目录执行。

版本门禁默认仍为历史实测包 `1.0.1(2)`。2026-09-30 用户要求运行现装包测试，已核对手机为 `1.0.2(102)`；本次使用显式版本参数运行，报告独立记录新包哈希与结果。以后版本变化时同样指定本批目标，版本不匹配会停止。

最近一次运行：[2026-09-30 页面报告](runs/20260930-01/results.md)，现装包 `1.0.2(102)`：25 PASS / 8 SKIP / 0 FAIL，退出码0；仅覆盖页面脚本列出的子路径。

```bash
python3 -B android_smoke.py pages --serial e2b8595a \
  --expected-version 1.0.2 --expected-version-code 102
python3 -B android_smoke.py payment-preflight --serial e2b8595a \
  --expected-version 1.0.2 --expected-version-code 102 \
  --expected-account-tail 0430 \
  --prod-catalog-evidence 'com.lxwx.catoutfit.points300.v1.test:12元积分:1'
```

`--prod-catalog-evidence` 必须从正式后台商品管理**只读核对**商品编码、名称和分单位金额后填写。脚本只确认后台记录与 App 展示的名称、金额一致，不能据此证明 App 的网络请求主机；无法确认账号或商品时支付段为 `BLOCKED`。金额门槛为 `0 < amountCents < 100`，恰好 ¥1 不符合。运行前后请确认没有其他积分收支，否则余额差无法归因于本次购买。

脚本选择符合限额的商品后即停止，**不会勾选协议、创建订单或点击实际支付**。请由账号持有人在手机上自行核对最终收银台金额并完成付款；取得订单号后可只读复核：

```bash
python3 -B android_smoke.py payment-postcheck --serial e2b8595a \
  --expected-version 1.0.2 --expected-version-code 102 \
  --expected-account-tail 0430 --order-no '实际订单号' --expected-amount-cents 1 \
  --preflight-report '/支付前运行结果目录/results.json'
```

支付后核对会读取支付前报告中的设备、安装包哈希、账号和积分基线，核对订单已支付及金额、余额增量和已加载流水中的精确 `+积分数`。余额被其他行为改变或流水未加载时记 `BLOCKED`，不武断判支付失败。客户端流水没有订单号关联，最终一一对应仍需服务端核账。

输出默认保存在系统临时目录，命令行会打印 `results.md` 路径。也可以传 `--output-dir` 指定目录；写入工作台项目目录前须运行工作台的路径守卫。`results.json` 含脱敏账号、APK 哈希及逐用例状态；失败截图、人工付款交接截图可能显示订单信息，只在受控环境保存。`PASS` 只证明该行所述子路径，不代表 P01～P30 全用例通过。选图、AI 生成、作品下载分享、短信登录、真实支付成功/失败仍需人工或专用测试。

纯解析与金额门禁测试：

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s . -p 'test_android_smoke.py' -v
```
