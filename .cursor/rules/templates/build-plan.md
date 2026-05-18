# {项目名称} 构建与打包计划

> 规则来源：`.cursor/rules/16-构建与打包.mdc`
> 用途：QA 验收通过后，配置签名、版本号、环境变量与 CI，生成可上架的发布包。
> 维护规则：构建配置一旦写入仓库，不允许在 CI 中临时修改；变更必须走 `change-plan.md`。

---

## 1. 构建版本信息

| 字段 | 内容 |
|------|------|
| 当前版本号 | `vX.Y.Z` |
| 构建号 buildCode | `N`（数字递增，不可回退） |
| 关联 `change-log.md` 版本号 | `vX.Y.Z` |
| 关联 QA 报告 | `05-联调与测试/qa-plan.md` 中 vX.Y.Z 区段 |
| 计划构建日期 | `YYYY-MM-DD` |

---

## 2. 多环境配置

| 环境 | API Base URL | 数据库 | 第三方 SDK 开关 | 构建变体 |
|------|--------------|--------|-----------------|----------|
| dev | http://localhost:8080 | dev_db | 关闭统计 | debug |
| staging | https://staging.example.com | staging_db | 开启埋点（沙箱） | release |
| prod | https://api.example.com | prod_db | 全开 | release |

---

## 3. 版本号策略

semver 规则：

| 升级类型 | 触发条件 |
|----------|----------|
| `major++` | 不兼容架构变更、推翻重做 |
| `minor++` | 新增功能 / 模块 |
| `patch++` | Bug 修复、文案 / 资源调整 |

buildCode：

- 整型数字，单调递增
- 每次构建（无论成功失败）都 +1
- CI 中由 `${BUILD_NUMBER}` 注入

---

## 4. CI / CD 选型

| 项 | 值 |
|----|----|
| 平台 | Codemagic / Fastlane / GitHub Actions / Bitrise |
| 触发策略 | 手动 / Git Tag / main 分支推送 |
| 构建机型 | macOS（iOS 必需）+ Linux（Android / 后端） |
| 缓存策略 | Gradle / pub / pod 缓存复用 |

---

## 5. 产物归档

| 平台 | 命名规则 | 归档目录 | 保留策略 |
|------|----------|----------|----------|
| Android APK | `dist/{project}-{version}-{buildCode}-{env}.apk` | `dist/` | 最近 10 次 |
| Android AAB | `dist/{project}-{version}-{buildCode}-{env}.aab` | `dist/` | 跨版本保留 |
| iOS IPA | `dist/{project}-{version}-{buildCode}-{env}.ipa` | `dist/` | 跨版本保留 |
| 后端镜像 | `registry.example.com/{project}:{version}-{buildCode}` | 镜像仓库 | 最近 20 个 |

---

## 6. 构建后自动化

- [ ] 自动跑 `flutter analyze` / `flutter test`
- [ ] 自动跑 `./mvnw test`
- [ ] 自动符号上传（Crashlytics / Bugly / Sentry）
- [ ] 自动通知（Slack / 飞书 / 钉钉 webhook）

---

## 7. 出包前自检清单

### Android

- [ ] 应用图标 / 启动图齐全
- [ ] 网络白名单与 usesCleartextTraffic 配置正确
- [ ] 权限清单与运行时申请一致
- [ ] minSdk / targetSdk / compileSdk 符合渠道要求
- [ ] ProGuard / R8 混淆规则覆盖第三方 SDK

### iOS

- [ ] LaunchScreen / Icon Set 齐全
- [ ] Info.plist 中 NS*UsageDescription 文案审核友好
- [ ] dSYM 已生成并归档
- [ ] 隐私清单（Privacy Manifests）已合并第三方 SDK 声明
- [ ] ATS 配置（如有非 HTTPS 例外，需说明）

### 后端

- [ ] Docker 镜像可启动
- [ ] 健康检查接口可访问
- [ ] 数据库迁移脚本可成功执行
- [ ] 环境变量清单完整

---

## 8. 上架就绪检查表

| 项 | 状态 | 备注 |
|----|------|------|
| 15 QA PASS | ☐ | |
| `change-plan.md` 进行中区块为空 | ☐ | |
| 版本号 / buildCode 已确定 | ☐ | |
| Android AAB / APK 已生成 | ☐ | |
| iOS IPA 已生成 | ☐ | |
| 签名配置正常 | ☐ | |
| 隐私政策已就绪 | ☐ | |
| 商店素材已就绪 | ☐ | |

只有全部勾选才允许进入 17 应用商店上架。
