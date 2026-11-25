# catseller 构建与打包计划

> 路径恢复：2026-07-31 从错误工作区别名 `catseller` 迁入；本文 CHG 已按 `旧编号 + 20` 重编号，原文保存在 `archive/path-recovery-20260731/`。

## 1. 构建版本信息

- 应用：喵喵带货（catseller）
- 版本：`1.0.0+1`
- 关联研发版本：`v1.0.0`
- 当前范围：Android APP 备案特征包
- QA 基线：Flutter analyze、完整测试、Android Debug 与 iOS Simulator 已通过
- 阶段状态：Android 备案包已完成；完整上架包仍待外部 SDK 配置、iOS 发布签名及商店验收

## 2. 多环境配置

| 环境 | API Base URL | 当前用途 | 状态 |
|------|--------------|----------|------|
| dev | `http://192.168.31.243:8080` | 本地开发 | 已配置 |
| test | `http://120.25.199.191:8080` | 测试 | 已配置 |
| prod | `https://www.lxwanxiang.com/` | 生产/备案域名 | 已配置 |

- iOS 构建固定启用 StoreKit，不再通过 `APPLE_IAP_ENABLED` 或蒲公英本地配置关闭内购；商品 ID 仍由后端返回，Sandbox/生产环境仍由安装渠道和 App Store 决定。
- 本包可用于提取 Android APP 备案特征，但不等同于完整上架就绪包。

## 3. 版本号策略

- 产品版本遵循 `major.minor.patch`。
- Android `versionCode` 与 iOS `buildNumber` 使用递增整数且不得回退。
- 当前首版为 `1.0.0+1`。

## 4. 签名决策

- 用户于 2026-07-21 明确确认 catseller 与 catsinger 共用现有 `lxwx.jks`。
- JKS 位于 `android/app/lxwx.jks`，密码配置位于 `android/key.properties`；两者均被 Git 忽略。
- 共享签名意味着签名泄露、丢失或轮换会同时影响两个 App，需统一备份和权限管理。

## 5. Android 备案产物

- APK：`build/app/outputs/flutter-apk/app-release.apk`
- 包名：`com.lxwx.catseller`
- 版本：`1.0.0`（`versionCode=1`）
- APK SHA-256：`faadac5fd4559135bda7e024c79214a48e5a38ea454041c8bae14db15966b81c`
- 签名：RSA 2048-bit，APK Signature Scheme v2
- 证书有效期：2026-05-21 至 2053-10-06

## 6. 后续构建项

- 注入并验证 catseller 专属第三方 SDK 配置。
- 生成、安装并验收 Android 商店 APK/AAB。
- iOS 备案特征已从公司 Team `9F6QMS9A5Y` 的现有 Distribution 证书提取；仍需注册/确认 catseller App ID、创建 App Store Profile 并导入匹配私钥。
- 生成 iOS IPA，核验实际归档证书与备案 SHA-1 一致，并完成 TestFlight 内测。
- 完成隐私政策、备案展示和商店素材后，才可进入应用商店提交阶段。
