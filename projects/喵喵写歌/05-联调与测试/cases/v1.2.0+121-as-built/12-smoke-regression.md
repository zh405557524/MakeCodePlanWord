# P0/P1 冒烟回归清单

本文件只定义执行顺序，不重复定义测试用例。实际步骤与预期以同目录模块文档中的对应编号为准。

## 快速只读 Smoke

用于每次安装包启动后的 10 条双平台快速检查。默认分别在 Android 和 iOS 各执行一次，共产生 20 条结果，全程不扣积分、不删除数据：

1. `APP-004` 冷启动进入当前首页。
2. `NAV-001` 底部只显示首页、作品、我的三个 Tab。
3. `HOME-001` 首页核心结构完整。
4. `HOME-002` AI 写歌进入专业模式。
5. `HOME-003` 改编歌曲进入歌曲改编。
6. `CREATE-001` 专业模式主要控件完整。
7. `CREATE-004` 空歌词不能生成普通歌曲。
8. `WORK-001` 我的作品页面结构正确。
9. `PROFILE-002` 已登录我的页菜单完整。
10. `PROFILE-014` 可以进入更多设置。

对应命令：

```bash
python3 main.py run --suite smoke
```

设备规则：iOS 优先使用已配对可用真机；没有真机时自动启动 iPhone Simulator；两者都没有时写入 `IOS-DEVICE-GATE=FAIL`，整套测试不通过。单平台参数仅用于排障：`--platform android` 或 `--platform ios`。

## 无风险 Core

- 自动选取当前目录内 `automated + P0/P1 + normal` 的全部用例。
- 可包含需要既有生成中作品的 `WORK-004`；数据不存在时应报告 `BLOCKED`，不能伪报通过。
- 不执行生成、支付、删除、隐私撤回和账号注销。

对应命令：

```bash
python3 main.py run --suite core
```

## 付费与破坏性回归

- 付费链路：`python3 main.py run --suite paid --allow-paid`。
- 删除链路：`python3 main.py run --suite destructive --allow-delete`。
- 注销必须额外提供开关，并使用一次性专用测试数据。
- iOS StoreKit、系统文件选择器、外部支付宝等仍按手工或半自动清单执行。

## 结果判定

- `PASS`：自动化实际完成操作并采集证据。
- `FAIL`：页面或可见结果不符合预期。
- `BLOCKED`：环境、账号、数据或危险开关不满足。
- `NOT_RUN`：手工或半自动用例未在本次 Android/iOS 运行中执行。

所有结果必须保留报告；未运行的条目不得改写为 PASS。
