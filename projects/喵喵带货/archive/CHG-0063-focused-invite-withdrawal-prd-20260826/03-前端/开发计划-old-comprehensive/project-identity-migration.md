# 工程身份迁移模块计划

> 路径恢复：2026-07-31 从错误工作区别名 `catseller` 迁入；本文 CHG 已按 `旧编号 + 20` 重编号，原文保存在 `archive/path-recovery-20260731/`。

状态：`done`（2026-07-21），等待用户验收。

- Flutter：包导入、常量、缓存/文件前缀、品牌文案与测试夹具。
- Android：包目录、Application ID、Manifest、ProGuard、Channel、资源与签名门禁。
- iOS：Bundle ID、显示名、URL Scheme、Channel、错误域、目录与证书清理。
- 资源：临时猫咪购物袋图标、无嵌字首页背景、原生图标和启动图生成。
- 工具：多渠道脚本迁移到 `tool/`，发布产物统一使用 catseller 前缀。
- 验证：identity/降级测试、analyze、完整 test、Android Debug、iOS Simulator、残留扫描。

## 完成证据

- `flutter analyze`：通过，无问题。
- `flutter test`：268 项通过；4 个依赖真实阿里云构建参数的正向用例按配置跳过，未配置回退短信登录用例通过。
- `flutter build apk --debug`：通过。
- `flutter build ios --simulator --debug`：通过。
- Android 多渠道工具测试：10 项通过。
- 受控源码、配置、脚本和资源名的 `喵喵写歌|catsinger|narrate` 残留：0。
- 旧签名和上传配置哈希匹配：0；原 catsinger 工程与可恢复清理备份均保留。
