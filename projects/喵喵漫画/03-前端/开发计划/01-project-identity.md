# 01 项目标识迁移模块开发文档

> 对应任务：T-F001
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责把复制工程的 App 身份迁移到 `喵喵漫画`。只处理名称、appCode、平台显示名、旧文案扫描和旧真实业务入口基线清理，不改页面 UI 细节，不接真实生成、支付、会员扣点和下载能力。

## 2. 入口、路由与页面文件

| 类型 | 文件 / 位置 | 处理 |
|------|-------------|------|
| App 常量 | `lib/utils/constants.dart` | `appName=喵喵漫画`，`appCode=catcomic` |
| App 标题 | `lib/main.dart` | `MaterialApp.title` 使用喵喵漫画口径 |
| 全局初始化 | `lib/global.dart` | fallback appName 改为喵喵漫画，保留初始化顺序 |
| 包信息 | `pubspec.yaml` | 工程描述、name、version 需按编码阶段确认 |
| 平台显示名 | Android / iOS 平台配置 | 显示名改为喵喵漫画 |
| 扫描范围 | `lib/`、`pubspec.yaml`、平台目录 | 清理旧 App 名称、旧 appCode 和旧业务入口 |

## 3. 依赖前置

- 无 Java 接口依赖。
- 编码前必须确认 `/Users/soul/code/lxwx/make_drama/AGENTS.md` 中旧路径问题。
- 后续所有接口依赖 `X-App-Code: catcomic`，因此本模块必须优先执行。

## 4. 视觉参考与设计稿分析

参考 `figma-design-plan.md` 与 Figma 当前稿：本期只细看 `首页` / `97:102` 和 `资产库` / `97:2345`；底部导航、入口文案和页面标题必须使用 `喵喵漫画` 语境，不出现旧项目名称。其它原工程没有的页面先空白展示，不按其它 Figma Frame 细化。

## 5. 涉及模块与类

- `AppConstants`
- `Global`
- `MyApp`
- `HttpService`
- 平台配置文件
- 旧业务入口相关页面常量和文案

## 6. 业务内容与数据流

```text
AppConstants.appCode = catcomic
  -> HttpService 默认 Header
  -> X-App-Code: catcomic
  -> 后端 schema routing
  -> catcomic 数据
```

本模块不产生业务数据，只改变请求和展示身份。

## 7. 现有工程参考点

- `lib/utils/constants.dart` 当前已有 `appName`、`appCode`、`appCodeHeader`。
- `lib/services/http.dart` 默认 headers 已读取 `AppConstants.appCode`。
- `lib/main.dart` 已使用 `MaterialApp.router`。
- `lib/global.dart` 已集中初始化 Storage、Mock、Http、User、Config 等服务。

## 8. 建议实现步骤

1. 修改 `AppConstants.appName`、`AppConstants.appCode`。
2. 修改 `MaterialApp.title` 和 `Global` fallback。
3. 扫描并替换用户可见旧名称。
4. 标记旧真实生成、支付、会员充值、作品详情入口为后续模块处理。
5. 检查平台显示名和 URL Scheme 是否仍含旧语义。

## 9. 详细编码任务清单

| 子任务 | 文件 | 验收 |
|--------|------|------|
| T-F001-1 | `lib/utils/constants.dart` | appName/appCode 正确 |
| T-F001-2 | `lib/main.dart`、`lib/global.dart` | 启动标题和 fallback 正确 |
| T-F001-3 | `pubspec.yaml`、平台目录 | 显示名不含旧项目 |
| T-F001-4 | 全工程扫描 | 无旧名称、旧 appCode、旧主入口文案泄漏 |

## 10. 验收标准

- `AppConstants.appName == 喵喵漫画`。
- `AppConstants.appCode == catcomic`。
- `HttpService` 请求默认携带 `X-App-Code: catcomic`。
- App 启动标题、平台显示名和主要文案不再使用旧项目口径。

## 11. 编码注意事项

- 不在本模块接入真实生成、支付或会员能力。
- 不删除旧代码，只断开 P0 主入口和用户可见文案。
- 修改 Dart 后执行 `dart format` 和 `flutter analyze`。
