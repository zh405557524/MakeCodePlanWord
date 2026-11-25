# App 基础改造模块开发文档

> 关联任务：T-F001  
> 工程：`/Users/soul/code/lxwx/catsinger`  
> 状态：waiting_review

## 1. 功能定位与边界

把复制来的旧 Flutter App 改成喵喵写歌的真实工程身份。

- 包含：App 展示名、`appCode`、applicationId / Bundle ID、URL scheme、启动标题、旧文案扫描。
- 不包含：业务页面重构、生成接口接入、后台 Web 改造。

## 2. 入口、路由与页面文件

| 类型 | 文件 |
|------|------|
| App 常量 | `lib/utils/constants.dart` |
| 启动入口 | `lib/main.dart`, `lib/global.dart` |
| 路由 | `lib/routes/router.dart`, `lib/routes/name.dart` |
| Android | `android/app/build.gradle`, `android/app/src/main/AndroidManifest.xml` |
| iOS | `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj` |
| 依赖配置 | `pubspec.yaml` |

## 3. 依赖前置

- 无后端接口依赖。
- 必须与后端 `X-App-Code: catsinger` 保持一致。
- 支付 URL scheme 若上线前另有约定，以最终支付配置为准。

## 4. 视觉参考与设计稿分析

UI/Figma 流程已跳过。本模块不直接落页面视觉，只保证所有页面可读取正确品牌：`喵喵写歌`。

参考图片：全局参考 `01-create.jpeg` 到 `10-player-lyrics.jpeg` 的深色音乐 App 风格。

## 5. 涉及模块与类

| 模块 | 说明 |
|------|------|
| `AppConstants` | `appName=喵喵写歌`, `appCode=catsinger` |
| `Global` | 全局 App 名、服务初始化 |
| `CustomRouter` | 旧路由命名清理，保留可复用登录/设置路由 |
| 原生配置 | Android/iOS 包名和 scheme |

## 6. 业务内容与数据流

1. App 启动读取 `AppConstants.appCode`。
2. `HttpService` 默认请求头带 `X-App-Code: catsinger`。
3. 登录、积分、会员、歌曲接口都在 catsinger appCode 下隔离。

## 7. 现有工程参考点

- 复用现有 `Global.init()` 服务注册方式。
- 复用现有 `HttpService` 自动追加 appCode header 的能力。
- 使用 `rg "narrate|漫剧工坊|com.lxwx.narrate"` 做旧标识扫描。

## 8. 建议实现步骤

1. 扫描旧项目标识。
2. 修改 `pubspec.yaml` 名称和支付 scheme。
3. 修改 `AppConstants`、`main.dart` 标题。
4. 修改 Android applicationId 和 iOS Bundle ID。
5. 扫描 MethodChannel、scheme、分享、WebView 回调中的旧命名。
6. 跑 `dart format` 和 `flutter analyze`。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-F001-01 扫描旧命名 | pending |
| T-F001-02 替换 App 常量 | pending |
| T-F001-03 替换 Android/iOS 包名 | pending |
| T-F001-04 替换 URL scheme 和 MethodChannel | pending |
| T-F001-05 基础分析验证 | pending |

## 10. 验收标准

- [ ] `AppConstants.appCode == catsinger`
- [ ] App 标题显示「喵喵写歌」
- [ ] Android applicationId 为 `com.lxwx.catsinger`
- [ ] iOS Bundle ID 为 `com.lxwx.catsinger`
- [ ] 代码中无业务残留 `漫剧工坊/com.lxwx.narrate`
- [ ] `flutter analyze` 无新增错误

## 11. 编码注意事项

- 不要误改后端地址和环境切换逻辑。
- 支付 scheme 变更要保留上线前可再次确认空间。
- 不删除可复用的登录、积分、会员、设置能力。
