# F-07 Apple 登录本地验证（2026-10-07）

代码及本机私有配置完成，正式部署配置已在本地准备。实际登录专用 P8 签名验证通过；源码 `enabled` 安全默认值仍为 false。尚未部署，也未完成签名真机授权、生产迁移或审核验收。

## 测试结果

| 验证 | 结果 | 证据 |
|---|---|---|
| Flutter 全量测试 | 1613 通过，1 项既有跳过 | [原始输出](flutter-test.txt) |
| Flutter 全量分析 | 19 项既有提示，本次范围无提示 | [全量](flutter-analyze.txt)、[本次范围](flutter-analyze-scoped.txt) |
| 登录 UI 三语 / 五尺寸 / 1x、2x字号 / Android、iOS | 148 通过；已查看手机和 iPad 图片 | [原始输出](login-layout-test.txt) |
| iOS Simulator Debug 编译 | 通过；Apple 插件在 Pods 和 GeneratedPluginRegistrant 中 | [原始输出](ios-simulator-build.txt) |
| 后端认证、注销、schema 回归 | 更名前 7 套件 46 项通过，无失败/跳过 | [原始输出](backend-test.txt) |
| V5.1 迁移更名后的账号/schema/历史 checksum 回归 | 4 套件 21 项通过，无失败/跳过；编译产物仅有 V5_1 | [原始输出](backend-v5-1-migration-test.txt) |
| 实际 P8 / 私有配置 / Apple 认证回归 | 两套 Spring 配置绑定、实际 P8 ES256 签名及 AES 检查通过；2 套件 20 项通过 | [原始输出](backend-private-config-check.txt) |
| 正式部署私钥清单本机检查 | 私钥格式、600 权限与 Git 忽略检查通过；未上传 | [原始输出](backend-private-files-check.txt) |

Apple 控制器 21 项验证真实本地账号分区、原游客 ID 升级、已有账号切换、迟到响应、重复操作和三语失败提示；SDK 通道 6 项验证 nonce、姓名可选、取消、平台限制和缺失凭证；均使用受控 Native/Provider，未调用真实 Apple。

后端包含实际 H2/Flyway 表结构、JWT 签名/issuer/audience/nonce/过期验证（本地生成测试签名）、授权码同一 subject、隐藏邮箱、幂等回放、会员/订单不迁移、撤销重试、refresh 授权失效及加密凭证绑定 userId。验证没有修改生产数据库。本机 PostgreSQL 和 Docker 未运行，实际 PostgreSQL 迁移尚待验收。

## 截图

下列图片是带测试字体与测试表单数据的 Widget 渲染，不是签名真机截屏。Apple SDK 的 `.SF Pro Text` 字体在捕获夹具中显式加载后，按钮文字完整显示。

- [简体中文 iPhone 375×812](16-ios.png)
- [英文 iPhone 390×844](16-ios-phone-en.png)
- [英文 iPad 820×1180](16-ios-ipad-en.png)

## 命令

在 App 根目录（Flutter SDK：`/Users/soul/data/flutter/flutter/bin/flutter`）：

```sh
flutter test
flutter analyze
flutter analyze lib/apis/auth_api.dart lib/pages/login lib/services/core/index.dart lib/services/core/apple_sign_in_service.dart lib/global.dart test/apple_login_controller_test.dart test/apple_sign_in_service_test.dart test/login_recheck_layout_test.dart test/google_login_controller_test.dart test/guest_login_payment_gate_test.dart test/payment_login_navigation_test.dart
flutter test test/login_recheck_layout_test.dart --dart-define=LOGIN_CAPTURE=true --dart-define=LOGIN_CAPTURE_PHASE=apple --reporter expanded
flutter build ios --simulator --debug --no-codesign
```

在 service 根目录：

```sh
./gradlew test --tests '*AppleSignInProviderTest' --tests '*SolfeggioAppleAuthIntegrationTests' --tests '*SolfeggioAccountAuthIntegrationTests' --tests '*AccountDeletionIntegrationTests' --tests '*SchemaRoutingIntegrationTests' --tests '*GuestAccountServiceTest' --tests '*AuthIntegrationTests' --tests '*GoogleTokenInfoVerifierTests' --console=plain
```

V5.1 更名后的追加验证命令：

```sh
./gradlew test --tests '*SchemaRoutingIntegrationTests' --tests '*SolfeggioAppleAuthIntegrationTests' --tests '*SolfeggioAccountAuthIntegrationTests' --tests '*SolfeggioPublishedMigrationChecksumTest*' --console=plain
```

实际 P8 接入后，在后端执行忽略目录中的配置验证程序和相关测试：

```sh
./gradlew -I .local/local/checks/apple-login/configuration-check.init.gradle appleLoginPrivateConfigurationCheck test --tests '*AppleSignInProviderTest' --tests '*SolfeggioAppleAuthIntegrationTests' --console=plain
./.local/prod/bin/deploy.sh private-files-check
```

验证程序使用当前 Provider，在内存中生成并验签 client_secret，不输出私钥、AES 值或 token；没有数据库连接或真实 Apple OAuth 请求。正式配置的远端 P8 路径只在本机验证时替换为当前可读副本，不代表线上配置就绪。初始化脚本首次使用相对路径解析到脚本目录导致启动失败，[原始失败](backend-private-config-initial-failure.txt) 保留；改用 `project.file` 后验证通过，业务代码与断言未变。

两仓库 `git diff --check` 均通过。三个 ARB 中 Apple 登录 key 各出现一次，其他既有重复 key 的数量与 HEAD 相同。

## 初始失败与修复边界

[后端初始失败](backend-initial-failures.txt) 保留受控 Form Content-Type 匹配器失败。后续 Mockito 重新设定和到期注销夹具时间也已修正，业务断言保留，最终测试通过；对应初始输出在本次对话工具记录中。Java 迁移发现了 H2 历史匿名 provider CHECK，改为在新 V5.1 中查询实际约束名称，不修改冻结旧迁移。

[Toast 初始失败](toast-fixture-initial-failures.txt) 是只等待一帧时 Toast 尚未构建；补等待第二帧后，仍保留“当前语言文本可见”和“不建立会话”的断言。其他早期构建/用例日志保留在两仓库 build/，没有删除业务断言或改小验收范围。

## 发布前仍需完成

本机 P8/Key ID/Team ID 和独立 AES 私有配置已完成，正式部署准备配置已在本地补齐。仍需按 [F-07](../../fix.md) 确认 App ID 能力及更新描述文件，完成授权部署、隔离 PostgreSQL 迁移验收与签名包，然后真机验证首次/再次/隐藏邮箱/游客升级/取消/停止使用 Apple 登录后刷新/到期注销。

原始输出和图片的 SHA-256 见 [manifest](manifest.json)。没有把实际 P8 或生产凭证写入此目录。
