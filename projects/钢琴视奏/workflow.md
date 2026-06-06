# 钢琴视奏 工作空间流程状态

> 规则来源：`.cursor/rules/00-核心工作流程.mdc`  
> 用途：记录当前流程进度、恢复点、需加载规则、依赖文件和注意事项。  
> 维护规则：每次生成、修改、检测或编码完成后必须更新本文档。

---

## 1. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `Flutter编码实现 / v1.2 UI 落地` |
| 当前步骤 | `修复首页英文统计卡 overflow 与底部 Settings 图标过小问题，并重新完成 debug APK 构建验证` |
| 当前步骤状态 | `done` |
| 当前恢复点 | `已在 G:\code\soul\Solfeggio 完成 v1.2 UI 代码实现；2026-05-20 根据截图修复首页三张统计卡英文长文案导致的 bottom overflow；随后修复底部导航 Settings 图标过小问题，将 icon_settings.svg 改为齿轮图标并在导航中单独放大；flutter build apk --debug --no-pub 已再次通过` |
| 下一步默认动作 | `进行真机/模拟器视觉回归，重点检查竖屏页面滚动与横屏练习页 812 x 375 布局；如需要可继续修复 analyzer/test 存量阻断项` |

状态枚举：

| 状态 | 含义 |
|------|------|
| `pending` | 未开始 |
| `in_progress` | 执行中 |
| `waiting_review` | 待用户审核或确认 |
| `done` | 已完成 |
| `blocked` | 被缺失信息、冲突或外部条件阻塞 |
| `skipped` | 用户明确跳过 |

---

## 2. 总体流程列表

| 顺序 | 阶段 | 状态 | 产物/说明 |
|------|------|------|-----------|
| 1 | 需求分析 | `done` | `01-需求/requirements-list.md` |
| 2 | Figma设计稿计划 | `done` | `01-需求/figma-design-plan.md` |
| 3 | Figma主页面调整 | `done` | 5 个主页面已在 Figma 中完成 v1.2 高保真改色与图标映射 |
| 4 | 技术方案计划 | `done` | `02-技术方案/tech-plan.md` |
| 5 | 工作时长评估 | `waiting_review` | `02-技术方案/effort-estimate.md` 已生成，待确认排期 |
| 6 | Flutter技术文档 | `done` | `03-前端/flutter-tech.md` |
| 7 | Flutter开发计划 | `done` | `03-前端/flutter-dev-plan.md` |
| 8 | Flutter编码实现 | `done` | 已完成源码修改与资源接入 |
| 9 | 联调与测试 | `in_progress` | `flutter analyze`/`flutter test` 已运行但被存量问题阻断；debug APK 构建通过 |
| 10 | 构建打包 | `done` | `flutter build apk --debug --no-pub` 已通过 |

---

## 3. 当前步骤需加载规则

| 规则文件 | 用途 |
|----------|------|
| `.cursor/rules/00-核心工作流程.mdc` | 总调度、上下文加载、执行契约 |
| `.cursor/rules/07-前端Flutter技术文档.mdc` | 生成 Flutter 技术口径 |
| `.cursor/rules/09-Flutter开发计划文档.mdc` | 生成 Flutter 开发计划 |
| `.cursor/rules/flutter/08-UI处理任务.mdc` | 执行 v1.2 UI 资源、样式和页面更新 |

---

## 4. 当前步骤依赖文件

| 文件 | 用途 | 是否必须 |
|------|------|----------|
| `projects/钢琴视奏/素材库/v1.2/欢迎页面.png` | v1.2 启动页视觉参考 | 是 |
| `projects/钢琴视奏/素材库/v1.2/主页.png` | v1.2 首页视觉参考 | 是 |
| `projects/钢琴视奏/素材库/v1.2/进度.png` | v1.2 学习进度页视觉参考 | 是 |
| `projects/钢琴视奏/素材库/v1.2/设置.png` | v1.2 设置页视觉参考 | 是 |
| `projects/钢琴视奏/素材库/v1.2/练习页面.png` | v1.2 横屏练习页视觉参考 | 是 |
| `projects/钢琴视奏/素材库/v1.2/piano_sight_reading_assets/README.md` | v1.2 颜色、背景、图标资源说明 | 是 |
| `G:/work/钢琴视奏练习/ui/piano_sight_reading_assets/` | 用户指定的新版本图标目录 | 是 |
| Figma channel `inp001sf` | 当前连接的原 app Figma 设计稿通道 | 是 |
| `G:/code/soul/Solfeggio/pubspec.yaml` | Flutter 工程依赖、版本、资源配置评估 | 是 |
| `G:/code/soul/Solfeggio/lib/theme.dart` | 当前主题与 v1.2 token 落地评估 | 是 |
| `G:/code/soul/Solfeggio/lib/utils/assets.dart` | 当前资源路径集中管理评估 | 是 |
| `G:/code/soul/Solfeggio/lib/pages/onboarding/view.dart` | 启动页实现评估 | 是 |
| `G:/code/soul/Solfeggio/lib/pages/home/view.dart` | 首页实现评估 | 是 |
| `G:/code/soul/Solfeggio/lib/pages/progress/view.dart` | 进度页实现评估 | 是 |
| `G:/code/soul/Solfeggio/lib/pages/settings/view.dart` | 设置页实现评估 | 是 |
| `G:/code/soul/Solfeggio/lib/pages/practice/view.dart` | 练习页实现评估 | 是 |
| `projects/钢琴视奏/02-技术方案/tech-plan.md` | v1.2 Flutter 技术方案与任务来源 | 是 |
| `projects/钢琴视奏/01-需求/figma-design-plan.md` | 页面复杂度与设计验收来源 | 是 |
| `projects/钢琴视奏/change-plan.md` | 变更范围与不应改动边界 | 是 |
| `G:/code/soul/Solfeggio/assets/images/v12/` | v1.2 SVG 资源落地目录 | 是 |
| `G:/code/soul/Solfeggio/lib/widgets/v12_ui.dart` | v1.2 共享 UI 组件 | 是 |

---

## 5. 当前步骤生成文件

| 文件 | 状态 | 说明 |
|------|------|------|
| `projects/钢琴视奏/change-plan.md` | `done` | v1.2 局部改色和素材替换计划 |
| `projects/钢琴视奏/01-需求/requirements-list.md` | `done` | 本轮 v1.2 迭代需求清单 |
| `projects/钢琴视奏/01-需求/figma-design-plan.md` | `done` | Figma 页面、组件、Token 与验收计划 |
| `projects/钢琴视奏/02-技术方案/tech-plan.md` | `done` | v1.2 Flutter 技术评估、影响文件、风险与验证方案 |
| `projects/钢琴视奏/02-技术方案/effort-estimate.md` | `waiting_review` | v1.0 三点估计、关键路径、缓冲与里程碑建议 |
| `projects/钢琴视奏/03-前端/flutter-tech.md` | `done` | v1.2 Flutter 技术文档 |
| `projects/钢琴视奏/03-前端/flutter-dev-plan.md` | `done` | v1.2 Flutter 开发计划 |

---

## 6. 额外注意事项

- 用户口径为“调整 4 个界面 UI 颜色”，但实际提供了 5 张参考图：欢迎/启动页、首页、进度页、练习页、设置页。本轮以首页、进度、练习、设置为 4 个主界面，欢迎/启动页作为开屏与新图标同步项纳入计划。
- v1.2 风格关键词：冷雾蓝、冰紫、青绿、亮色毛玻璃、柔和渐变、钢琴键与五线谱装饰。
- 推荐色来自资源包：背景 `#F3F6FF / #EEF4FF / #F8F3FF`，主蓝 `#5B7CFA`，辅助紫 `#8B6CF6`，青绿 `#42C7C7`，主文字 `#172033`，副文字 `#64748B`，卡片 `rgba(255,255,255,0.72)`。
- Figma 原稿主节点：`启动页 3576:9930`、`首页布局 3576:9860`、`进度页面布局 3576:9787`、`设置页面布局 3576:9722`、`练习页面布局 3576:9658`。
- 实际 Flutter 工程路径已提供：`G:\code\soul\Solfeggio`。
- 当前源码仓库已有未提交改动，且包含本轮目标文件 `lib/pages/practice/view.dart`、`lib/pages/practice/widget/bottom_piano_keyboard.dart`，进入编码前必须先读取 diff 并增量修改。
- 当前工程未引入 `flutter_svg`，技术方案推荐将 v1.2 SVG 转换为 PNG 多倍率资源后接入。
- 工时评估默认团队配置为 1 名 Flutter + 0.5 名 QA，无后端；若团队配置变化，`effort-estimate.md` 需追加或更新敏感性评估。
- 当前基线估算：期望 23.7 人天，含 20% 标准缓冲 28.5 人天；按 2026-05-19 开工，GA 建议区间为 2026-06-25 ~ 2026-06-26。
- 用户已明确“后面不用暂停”，因此从工时评估后直接推进到 Flutter 技术文档、开发计划和编码实现。
- 本机未发现可用 SVG 转 PNG 工具，代码实现改为直接接入 `flutter_svg` 并注册 `assets/images/v12/`。
- `flutter analyze` 当前被项目存量 warning/lint 阻断；`flutter test` 当前被 smoke test 中 Hive 未初始化路径阻断；`flutter build apk --debug --no-pub` 已通过。
- 2026-05-20 用户截图指出首页统计卡在英文环境下出现底部 overflow；已通过提高卡片高度、固定标题两行和移除硬编码中文提示修复。
- 2026-05-20 用户截图指出底部导航 Settings 图标过小；已将 `assets/images/v12/icon_settings.svg` 从小星形替换为齿轮设置图标，并在 `lib/pages/main/view.dart` 中给 Settings 图标单独放大。

---

## 7. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 目标源码存在未提交改动 | 直接编码可能覆盖用户已有工作 | 编码前先读取 `git status` 与目标文件 diff，按现状增量修改 |
| `requirements.md` 不存在 | 按严格流程缺少完整 PRD | 本轮作为已有 app 的 v1.2 局部变更，已用需求清单、Figma 计划和技术评估补齐上下文 |
| analyzer/test 存量阻断 | 自动化验证无法全部 green | 记录为存量问题；本轮以 debug APK 构建通过作为编译验证 |

---

## 8. 已完成阶段记录

| 阶段 | 产物 | 状态 | 备注 |
|------|------|------|------|
| 需求分析 | `projects/钢琴视奏/01-需求/requirements-list.md` | `done` | 已整理 v1.2 UI 迭代需求 |
| Figma设计稿计划 | `projects/钢琴视奏/01-需求/figma-design-plan.md` | `done` | 已映射参考图、Figma 节点、Token 和验收标准 |
| 二次调整计划 | `projects/钢琴视奏/change-plan.md` | `done` | 已限定本轮 UI 改色影响范围 |
| 技术方案计划 | `projects/钢琴视奏/02-技术方案/tech-plan.md` | `done` | 已完成 Solfeggio Flutter 工程落地评估 |
| 工作时长评估 | `projects/钢琴视奏/02-技术方案/effort-estimate.md` | `waiting_review` | 已生成 v1.0 基线估算，待确认 |
| Flutter技术文档 | `projects/钢琴视奏/03-前端/flutter-tech.md` | `done` | 已记录 v1.2 Flutter 技术口径 |
| Flutter开发计划 | `projects/钢琴视奏/03-前端/flutter-dev-plan.md` | `done` | 已记录任务状态与恢复点 |
| Flutter编码实现 | `G:\code\soul\Solfeggio` | `done` | 已完成 v1.2 UI 代码实现并通过 debug APK 构建 |

---

## 9. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-05-08 | v1.2 局部变更 | 读取工作流规则、素材库、图标目录和 Figma 原稿结构 | 已建立页面映射与改色范围 |
| 2026-05-08 | 需求分析 | 依据 5 张 v1.2 参考图整理需求清单 | 已生成 `requirements-list.md` |
| 2026-05-08 | Figma设计稿计划 | 整理页面出稿、Token、组件与验收计划 | 已生成 `figma-design-plan.md` |
| 2026-05-08 | 变更计划 | 记录 v1.2 局部改色与素材替换执行计划 | 已生成 `change-plan.md` |
| 2026-05-08 | Figma执行 | 连接 channel `3o1nbx9e`，更新启动页、首页、进度页、设置页、练习页关键颜色 | 已完成第一轮改色，预览无明显文本重叠 |
| 2026-05-08 | Figma图标映射 | 在 `图标` 资源区新增 `v1.2 SVG 文件名映射`，并给主界面节点添加资源注释 | 已覆盖全部 SVG 文件名与页面使用位置 |
| 2026-05-08 | Figma主页面直接修改 | 对 `启动页 3576:9930`、`首页布局 3576:9860`、`进度页面布局 3576:9787`、`设置页面布局 3576:9722`、`练习页面布局 3576:9658` 直接补齐可见图标层，图层命名对应 `icon_*.svg` 文件名，并替换旧 emoji/占位图标 | 已导出 5 个主页面预览确认图标可见，进度/设置/练习页不再为空图标区 |
| 2026-05-18 | Figma高保真精修 | 重新连接 channel `inp001sf`，精修启动页 Logo、设置页右箭头、练习页左侧统计图标与文字间距，并导出 5 个主页面复核 | 已完成，预览无明显遮挡或错位 |
| 2026-05-18 | 技术方案计划 | 读取 `G:\code\soul\Solfeggio` Flutter 工程结构、依赖、资源配置、5 个目标页面和 dirty worktree 状态，形成 v1.2 技术评估 | 已生成 `02-技术方案/tech-plan.md`，下一步进入工作时长评估 |
| 2026-05-18 | 工作时长评估 | 基于 `tech-plan.md`、Figma 设计计划和变更范围拆分 T-F/T-QA/T-BUILD 任务并做三点估计 | 已生成 `02-技术方案/effort-estimate.md`；当前等待用户确认排期与假设 |
| 2026-05-18 | Flutter技术文档/开发计划 | 用户要求后续不暂停，生成 `03-前端/flutter-tech.md` 与 `03-前端/flutter-dev-plan.md` | 已完成 |
| 2026-05-18 | Flutter编码实现 | 同步 v1.2 SVG 资源，新增 `v12_ui.dart`，更新启动页、首页、进度页、设置页、练习页、主题、资源索引和 pubspec | 已完成 |
| 2026-05-18 | 构建验证 | 执行 `flutter pub get`、`flutter analyze`、`flutter test`、`flutter build apk --debug --no-pub` | 依赖解析和 debug APK 构建通过；analyze/test 被项目存量问题阻断 |
| 2026-05-20 | UI微调 | 根据用户截图修复首页统计卡英文长文案和底部进度条区域 overflow | 已修改 `lib/pages/home/view.dart` 并通过 `flutter build apk --debug --no-pub` |
| 2026-05-20 | UI微调 | 根据用户截图修复底部导航 Settings 图标过小 | 已修改 `assets/images/v12/icon_settings.svg` 与 `lib/pages/main/view.dart` 并通过 `flutter build apk --debug --no-pub` |
