# PERF-02：P1/P2 代码修复

## 0. 执行前置条件

用户在 PERF-01 报告后明确授权“P1跟p2，能从代码层面修改的问题，先帮我修复一下”，优先视频编辑切换和返回。本切片沿报告已有证据执行，不增加产品功能。

Flutter 3.41.6 / Dart 3.11.4；App dev，基线 b31ad26。原有 projects/controller.dart 与 pubspec.yaml 修改保留。已有源码与报告相符。

不改后端、接口、支付/凭证/幂等协议、剪辑格式和数据；不安装手机、不清理现有数据；不处理证据不足的 Raster 和方向设置等待。大型 GetStorage 缓存迁移不混入本切片，仍待单独的旧数据迁移与故障恢复验证。

## 1. 需求与假设

修复可由已有证据直接落实的返回失效、重复索引复制/保存、重复页面构建。沿现有页面组件和布局，加载提示放入原页面，保留返回。真实业务输入仍需可靠写盘后离开。

## 2. 主流程图

```mermaid
flowchart TD
  A[页面点击或系统返回] --> B{首轮加载中?}
  B -->|是| C[保留返回入口并离页]
  B -->|否| D[有焦点时等待末次输入提交]
  D --> E[暂停预览和一次可靠保存]
  E -->|失败| F[保留原页与输入并提示]
  E -->|成功| G[更新 PopScope 后返回]
  G --> H[详情路由独占控制器]
  C --> I[旧页面关闭后拒绝迟到更新]
```

## 3. 批次总览

| 批次 | 目标 | 文件 | 验证 |
|---|---|---|---|
| 1 | 返回可用与保存/构建热点修复 | 下列 8 个生产文件和 3 个测试文件 | analyze、专项回归、profile 构建；手机性能另验 |

## 4. 数据结构 / 接口

不改变持久化字段、版本和外部接口。MediaCacheScope 内部 `_readLedger({bool copy = true})` 保留事务可变副本；读取单条记录仅复制所需嵌套数据，不能暴露 Hive 内部对象。页面实例编号仅用于 GetBuilder 注册，不持久化。

## 5. 批次 1 详细计划与实现

| 文件（App 仓库相对路径） | 修改 / 目的 |
|---|---|
| lib/pages/projects/detail/view.dart | Stateful 路由实例编号 + projectId 作为 tag；对象切换用 key 更新，旧释放不能删除新实例 |
| lib/pages/projects/shot_detail/controller.dart | 移除首轮全屏 loading 的创建/关闭；加载中返回沿普通退页；取消 navigate 已完成后的重复 flush |
| lib/pages/projects/shot_detail/view.dart | 原页 loading 和返回共存；镜头条按需构建，单元局部 Obx，每单元只求一次生成状态 |
| lib/pages/projects/shots/page_state.dart | 只在有输入焦点时等待失焦帧；可靠 beforeNavigation 保持 |
| lib/pages/projects/editor/logic/media_cache.dart | 去掉 ledger JSON 编解码深拷贝；事务递归复制，单条查询只复制对应记录；读出的嵌套数据和失败事务不影响存储 |
| lib/pages/projects/editor/logic/project_store.dart | 相同选择/位置不重复保存；先检查 scope、未保存状态与作品租约 |
| lib/pages/main/view.dart | Tab 改变不重新创建所有子页；登录状态失效仍重建；账号可见性刷新保留 |
| lib/pages/assets/view.dart | 每轮 Obx 构建只求一次 visibleItems/canCreate，网格单元使用当前快照 |
| test/projects/project_detail_test.dart | 增加同作品两路由重叠/旧释放不关闭新实例；实际页面加载时推进夹具时钟 |
| test/shots/shot_detail_test.dart | 加载中页面返回/系统返回与迟到响应；原保存失败、连续切换回归 |
| test/editor/local_store_test.dart | 嵌套读取隔离、失败事务隔离、相同选择不写盘而变化仍执行保存 |

核心逻辑：

```dart
// 事务仍串行、成功 put + flush 后才能返回。
Future<T> update<T>(T Function(Map<String, dynamic>) change);
// 所有调用仍先检查账号/环境/后端作用域。
Object? _record(String name, String id);
// 相同选择仅在未保存检查和作品租约检查均通过后跳过。
Future<void> saveSelection(LocalEditorSession session, EditorSelection selection);
```

前置检查已完成：文件存在、原有行为与报告一致。新增测试先验证已确认的失败路径；修复自身引入的问题在本切片内解决，不改变既有测试预期来掩盖错误。

## 6. 批次推进规则

本切片单批交付。测试/静态检查失败先修复；有基线问题逐项说明。保持 App 原有未提交改动，不整体暂存。

## 7. 总体验收

App `a468883` 已本地提交，未推送。代码完成，待设备验收：

- `flutter analyze --no-pub` 无问题；格式与 diff 检查通过。
- 11 个相关测试文件共 312 项通过（详情/剪辑索引/媒体准备/分镜保存与导航/历史/进度/首页/资产/存储隔离）。其中新增 5 项：双路由控制器隔离、页面返回/系统返回各 1 项、索引变更隔离、选择未变免写。
- 诊断开关 ON 的计时模块与路由结构 18 项通过。
- `flutter build apk --profile --no-pub --dart-define=CATDRAMA_ENV=1` 成功，诊断默认关闭。
- 未安装、未重装、未清理手机数据；未做真机点击耗时复测或真实界面视觉验收。历史 PERF-01 数字保留为优化前基线，不能作为修复后的数值。
- 本轮没有重跑全量测试；此前报告里的 2 个编辑器旧时间文本断言不在本轮测试范围，不能宣称这些旧失败已修复。

[本地测试/构建证据](../05-测试/evidence/PERF-02/result.json)。局部测试与构建不能证明 vivo 延迟已降到 16ms，也不代替真实视觉与业务验收。

## 8. 失败处理约定

持久化失败仍停留原页，保留用户输入/工程候选；不删除 await 或可靠写盘屏障。控制器关闭后的回调不能修改新页面。大型默认 KV 拆分和启动依赖调整继续单独跟踪，不标已修复。
