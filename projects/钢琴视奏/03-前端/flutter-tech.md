# 钢琴视奏 v1.2 Flutter 技术文档

> 生成日期：2026-05-18  
> 源码工程：`G:\code\soul\Solfeggio`  
> 关联方案：`02-技术方案/tech-plan.md`、`02-技术方案/effort-estimate.md`

## 1. 技术路线

- 继续沿用当前工程的 `MaterialApp.router + go_router + GetX + ScreenUtil`。
- 本轮只做 v1.2 UI 视觉迭代，不重写 MIDI、练习判定、统计、成就、本地存储逻辑。
- 由于本机无稳定 SVG 转 PNG 工具，本轮采用 `flutter_svg` 直接加载 v1.2 SVG 资源。
- v1.2 资源统一放入 `assets/images/v12/`，路径集中维护在 `lib/utils/assets.dart`。

## 2. 项目专属 UI 规则

- 颜色 token 以 `lib/theme.dart` 中 v1.2 常量为准：主蓝 `#5B7CFA`、紫色 `#8B6CF6`、青绿 `#42C7C7`、主文字 `#172033`、副文字 `#64748B`。
- 共享 UI 能力放在 `lib/widgets/v12_ui.dart`，包含冷雾背景、启动页背景、玻璃卡片、SVG 图标和图标底座。
- 页面仍使用 `flutter_screenutil` 的 `.w/.h/.sp/.r` 适配方式。
- 页面图标优先使用用户提供的 `icon_*.svg` 文件，不再使用 emoji 作为主页面功能图标。

## 3. 页面实现口径

| 页面 | 实现文件 | 处理口径 |
|------|----------|----------|
| 启动页 | `lib/pages/onboarding/view.dart` | 使用 `splash_background.svg` 与 `icon_app_piano_glass.svg` |
| 首页 | `lib/pages/home/view.dart` | 冷雾背景、统计卡、渐变 CTA、三项练习模式、今日目标 |
| 进度页 | `lib/pages/progress/view.dart` | 浅色周概览、渐变柱状图、成就卡、目标卡 |
| 设置页 | `lib/pages/settings/view.dart` | 个人卡、设置列表图标化、MIDI Switch 保留 |
| 练习页 | `lib/pages/practice/view.dart` | 横屏冷雾背景、统计图标、浅色谱面、右侧 SVG 操作按钮 |

## 4. 编码注意事项

- 当前源码已有未提交改动，特别是练习页与服务层；编码只能增量修改，不覆盖已有业务变更。
- `flutter analyze` 当前会被既有 warning/lint 阻断，验收时需区分新增问题和存量问题。
- `flutter test` 当前 smoke test 会在测试环境初始化 Hive，未提供测试路径时失败；这不是本轮 UI 编译错误。
- Native Splash 目前只同步浅色背景配置，未生成新的 PNG logo。

## 5. 验证命令

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- 后续建议补充真机/模拟器竖屏与横屏截图验收。
