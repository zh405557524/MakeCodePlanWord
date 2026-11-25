# 普通页面结构整理：视觉对照与验证证据

- 日期：2026-08-27。
- 前图来自修改前的实际工作区副本，包含用户当时未提交的改动，并非 Git HEAD；后图来自本次修改。
- 普通页面截图为 Flutter Widget 夹具：375 × 812，顶部 44 / 底部 34 安全区，中文系统字体，已等待本地图片解码；网络与原生授权使用测试替身。图中测试角标不是产品 UI。
- 截图捕获使用临时比较器导出 PNG，不将捕获过程计作 Golden 校验通过，也未生成或覆盖仓库 Golden。
- 原始捕获工具在 `/tmp/catseller-page-visual-capture_test.dart` 与 `/tmp/catseller-detail-visual-capture_test.dart`；修改前源码副本在 `/tmp/catseller-page-structure-baseline`。已归档下表全部前后 PNG，临时目录不作为长期证据。

## 视觉结论

26 组前后截图中，24 组像素一致。充值结果标题区域有 535 个像素差异（0.1757%），为导航标题布局后的字形栅格化差异；图标、正文和按钮区域一致。账号安全有 4 个像素差异（0.0013%，颜色通道最大差值 1），其余一致。作品详情横屏/竖屏预览、标题弹层及脚本编辑四组截图均一致。以上仅证明这些夹具状态的前后外观，不替代真实视频播放或真机系统栏验证。

[重点页面前后对照](comparison.png)

| 页面 / 状态 | 前图 | 后图 | 不同像素 | 比例 |
|---|---|---|---:|---:|
| account | [前图](before/account.png) | [后图](after/account.png) | 0 | 0.0000% |
| case-preview | [前图](before/case-preview.png) | [后图](after/case-preview.png) | 0 | 0.0000% |
| confirm | [前图](before/confirm.png) | [后图](after/confirm.png) | 0 | 0.0000% |
| feedback | [前图](before/feedback.png) | [后图](after/feedback.png) | 0 | 0.0000% |
| fill | [前图](before/fill.png) | [后图](after/fill.png) | 0 | 0.0000% |
| generating | [前图](before/generating.png) | [后图](after/generating.png) | 0 | 0.0000% |
| invite-bind | [前图](before/invite-bind.png) | [后图](after/invite-bind.png) | 0 | 0.0000% |
| ledger | [前图](before/ledger.png) | [后图](after/ledger.png) | 0 | 0.0000% |
| login | [前图](before/login.png) | [后图](after/login.png) | 0 | 0.0000% |
| membership | [前图](before/membership.png) | [后图](after/membership.png) | 0 | 0.0000% |
| orders | [前图](before/orders.png) | [后图](after/orders.png) | 0 | 0.0000% |
| points | [前图](before/points.png) | [后图](after/points.png) | 0 | 0.0000% |
| recharge | [前图](before/recharge.png) | [后图](after/recharge.png) | 0 | 0.0000% |
| redeem-code | [前图](before/redeem-code.png) | [后图](after/redeem-code.png) | 0 | 0.0000% |
| result | [前图](before/result.png) | [后图](after/result.png) | 535 | 0.1757% |
| script-failed | [前图](before/script-failed.png) | [后图](after/script-failed.png) | 0 | 0.0000% |
| security | [前图](before/security.png) | [后图](after/security.png) | 4 | 0.0013% |
| settings | [前图](before/settings.png) | [后图](after/settings.png) | 0 | 0.0000% |
| synthesizing | [前图](before/synthesizing.png) | [后图](after/synthesizing.png) | 0 | 0.0000% |
| task-center | [前图](before/task-center.png) | [后图](after/task-center.png) | 0 | 0.0000% |
| video-failed | [前图](before/video-failed.png) | [后图](after/video-failed.png) | 0 | 0.0000% |
| work_detail_landscape | [前图](before/work_detail_landscape.png) | [后图](after/work_detail_landscape.png) | 0 | 0.0000% |
| work_detail_portrait | [前图](before/work_detail_portrait.png) | [后图](after/work_detail_portrait.png) | 0 | 0.0000% |
| work_detail_script_editing | [前图](before/work_detail_script_editing.png) | [后图](after/work_detail_script_editing.png) | 0 | 0.0000% |
| work_detail_title_sheet | [前图](before/work_detail_title_sheet.png) | [后图](after/work_detail_title_sheet.png) | 0 | 0.0000% |
| works | [前图](before/works.png) | [后图](after/works.png) | 0 | 0.0000% |

## 自动化结果

- `dart format`：57 个本次修改的 Dart 文件已格式化；再次 `--output=none --set-exit-if-changed` 无变化。未格式化或覆盖用户单独修改的全局配置和资源常量。
- `flutter analyze --no-pub`：通过，No issues found。见 [分析日志](catseller-page-analyze.log)。
- `flutter test --no-pub --reporter json`：280 项通过、5 项失败；见 [完整原始结果](catseller-page-final-tests.jsonl)。计数与原基线口径一致，不计 loading 文件事件。
- 新增 30 项回归全部通过；原基线 243 通过 / 12 失败中的 7 项已在本次相关范围修复。
- 邀请流程测试文件 35 项通过，其中现有邀请 Golden 通过；未修改 Golden 图片。
- 新增/扩展覆盖：真实 GetBuilder/Scaffold 分区、实例重建与叠页隔离、返回刷新、历史弹层订阅、常亮引用计数、加载/失败返回、充值结果状态更新、账号安全独立状态、320/375/768 宽度、字体 1.3/1.6、手势区和 220 键盘遮挡。
- 已有自动化覆盖的创作、编辑/历史、登录隐私、支付、注销和邀请提现用例均执行；不把测试替身称为真实渠道联调。

## 剩余 5 项失败

1. `legal page constants expose production catseller urls`：旧测试预期客服地址为 `/legal/catseller/customer-service/customer_service.html`，现有代码为 `/miaomiao-commerce/customer-service/customer_service.html`；本次未修改地址或协议。
2. `work detail landscape matches the Figma layout`：缺失 `test/goldens/work_detail_landscape.png`。
3. `work detail portrait matches the Figma layout`：缺失 `test/goldens/work_detail_portrait.png`。
4. `work title sheet matches the Figma layout`：缺失 `test/goldens/work_detail_title_sheet.png`。
5. `script edit state matches the Figma action layout`：缺失 `test/goldens/work_detail_script_editing.png`。

详情四项需要经确认的 Golden 基准；本次前后截图一致，但未把新截图直接写为基准来消除失败。

## 待人工 / 真实环境验收

Android/iOS 真机系统栏、输入法、常亮/后台恢复、真实视频播放与导出、原生授权、真实支付与账号注销、工猫 H5/银行卡和真实资金链路尚未执行。没有运行数据库迁移、部署、启用生产资金或改动原生 SDK 配置。邀请提现原有 `waiting_review` 状态不变。
