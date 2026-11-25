# 10 前端自测模块开发文档

> 对应任务：T-F010
> 状态：waiting_review
> 目标工程：`/Users/soul/code/lxwx/make_drama`

## 1. 功能定位与边界

本模块负责 Flutter P0 自测、静态扫描、路由冒烟、接口状态验证和移动端尺寸检查。不做功能新增，只验证 T-F001~T-F009 是否满足进入联调条件。

## 2. 入口、路由与页面文件

| 范围 | 检查 |
|------|------|
| `lib/` | 旧文案、旧 appCode、旧真实入口 |
| `routes/` | 所有 P0 路由可达 |
| `pages/home` | 首页默认、空态、错误、分类切换 |
| `pages/asset_library` | 三类 Tab、空态、错误、图片失败 |
| `pages/feature_placeholder` | 所有占位入口 |
| `test/` | 必要 Controller/API/路由测试 |

## 3. 依赖前置

- 依赖 T-F001~T-F009。
- 依赖 Java T-B003/T-B005/T-B006 或 mock fallback。

## 4. 视觉参考与设计稿分析

参考 `figma-design-plan.md` 8 章验收标准：

- 首页和资产库必须覆盖默认、加载、空态、错误。
- 占位页必须覆盖默认和按钮反馈。
- 弹窗必须覆盖遮罩、取消、确定。

当前无导出图片文件，人工验收以 Figma Frame 和页面状态清单为准。

## 5. 涉及模块与类

- `HomeController`
- `AssetLibraryController`
- `FeaturePlaceholderPage`
- `CustomRouter`
- `HttpService`
- `MockService`

## 6. 业务内容与数据流

```text
自测
  -> 静态扫描
  -> dart format
  -> flutter analyze
  -> flutter test
  -> 手工路由冒烟
  -> 状态/尺寸检查
```

## 7. 现有工程参考点

- 工程 AGENTS 要求 Dart 修改后 `dart format`，Flutter 修改后至少 `flutter analyze`。
- 涉及 Store、路由、API 时运行必要 `flutter test`。
- 完成后运行 `git diff --check`。

## 8. 建议实现步骤

1. 执行旧文案和旧 appCode 扫描。
2. 执行格式化和 analyze。
3. 路由冒烟：首页、资产库、统一空白页、作品、我的。
4. 状态冒烟：首页和资产库 loading/empty/error/retry。
5. 小屏、标准屏、长屏检查。

## 9. 详细编码任务清单

| 子任务 | 命令 / 方法 | 验收 |
|--------|-------------|------|
| T-F010-1 | 扫描旧应用名、`漫剧工坊`、`narrate` 等旧项目口径 | 无用户可见旧口径 |
| T-F010-2 | `dart format <changed files>` | 格式化完成 |
| T-F010-3 | `flutter analyze` | 无阻塞错误 |
| T-F010-4 | `flutter test` | 必要测试通过 |
| T-F010-5 | 手工点击 | 所有入口可达 |

## 10. 验收标准

- 首页和资产库可完整浏览。
- 除首页和资产库外的入口可打开统一空白页或 Toast，不黑屏、不崩溃。
- 不触发真实生成、支付、扣点、删除、下载。
- `X-App-Code` 为 `catcomic`。
- 无旧 App 名称和旧主入口泄漏。

## 11. 编码注意事项

- 扫描命令中的 `narrate` 可能命中包名或服务名，需区分用户可见文案和不可避免的后端包名。
- 自测不替代第 15 步 QA，只作为进入联调前的前端门禁。
- 若无法运行 Flutter 命令，必须在 `workflow.md` 记录阻塞或测试缺口。
