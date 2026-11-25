# catsinger 构建与打包计划

## 构建版本

- App 版本：`1.0.1+104`
- 变更记录：`CHG-0010` / 工作空间版本 `v0.3.7`
- 当前产物级别：`candidate`
- 最终正式包门禁：CHG-0002/CHG-0005/CHG-0007 Android 真机支付验收通过

## Android 构建策略

- Flutter 只构建一次 `office` 的 `arm64-v8a` release APK。
- 原生代码使用 R8/ProGuard；Dart 使用 `--obfuscate` 和 `--split-debug-info`。
- Python 从 office 基础 APK 注入 `META-INF/channel-<渠道>`，执行 zipalign、统一证书重签与验签。
- 默认渠道：`office,huawei,xiaomi,oppo,vivo,honor,yyb,juliang,baidu`。
- 友盟上报具体渠道；版本更新按 `office` / `store` 二分类。

## 产物归档

- 候选目录：`dist/android/1.0.1+104/`
- APK：`catsinger_v1.0.1_<channel>_release.apk`
- 校验：`SHA256SUMS`、`build-manifest.json`
- 符号：`symbols/dart/` 与 `symbols/r8/mapping.txt`
- `dist/` 只做本地/CI 产物归档，不进入 Git。

## 验证与推进

1. 先完成 Python 单元测试、Flutter analyze、相关 Flutter 测试和 Android release 构建。
2. 生成并验证 office、huawei 两个代表 candidate。
3. arm64 真机验证启动、一键登录、支付宝支付、友盟渠道和版本更新分组。
4. QA 通过后重新生成九个最终正式包，再进入应用市场上架流程。

## 2026-07-16 Candidate 结果

- office 基础 APK 构建成功：`1.0.1+104`、`arm64-v8a`、约 41.4 MB。
- Dart symbols：`app.android-arm64.symbols`，约 4.7 MB。
- R8 mapping：约 36 MB，并确认包含 ApkChannelReader/AppUpdatePlugin 实际混淆映射。
- 已生成九个渠道候选包，统一命名为 `catsinger_v1.0.1_<channel>_release.apk`，约 39 MB/包。
- 九个包均通过 SHA-256 清单、zipalign、V2/V3、单签名证书、包名/版本/ABI 与 META-INF 渠道唯一性校验。
- 当前状态仍为 `candidate`；未执行真机支付、号码认证和友盟控制台验证。

## 非目标

- 不生成 AAB、ABI 拆分 APK、iOS IPA、后端部署包或 Docker 镜像。
- 不上传蒲公英或应用市场，不修改 `pgyer_upload.sh`。
