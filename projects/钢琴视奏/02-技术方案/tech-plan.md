# 钢琴视奏 v1.2 技术评估与实现方案

> 评估日期：2026-05-18  
> 评估对象：已有 Flutter App `G:\code\soul\Solfeggio`  
> 关联设计：Figma channel `inp001sf`，5 个主页面已完成 v1.2 高保真调整  
> 关联需求：`01-需求/requirements-list.md`、`01-需求/figma-design-plan.md`

---

## 1. 结论摘要

本次 v1.2 属于已有 Flutter App 的视觉迭代，技术上可在现有架构内落地，不需要重写页面路由、练习业务、MIDI 连接、统计计算或本地数据服务。

推荐实现方式是：沿用现有 `MaterialApp.router + GetX + ScreenUtil` 页面体系，先沉淀 v1.2 色彩/卡片/图标资源，再逐页替换 UI 表现。素材建议优先转换为 PNG 资源并放入 `assets/images/v12/`，以复用当前项目的 `Image.asset` 资源链路，避免为了本次纯视觉迭代引入 `flutter_svg` 依赖。

需要注意：当前源码仓库已有未提交改动，其中 `lib/pages/practice/view.dart` 等目标文件处于 modified 状态。进入编码前必须先读取这些差异并基于现状增量修改，不能覆盖用户已有改动。

---

## 2. 当前工程状态

| 项目 | 评估结果 |
|------|----------|
| 工程路径 | `G:\code\soul\Solfeggio` |
| 技术栈 | Flutter / Dart，`get`、`go_router`、`flutter_screenutil`、`get_storage`、`hive` |
| 当前版本 | `pubspec.yaml` 中为 `1.1.1+111` |
| 设计基准 | 竖屏页面按 `375 x 812`，练习页按横屏 `812 x 375` |
| 资源现状 | `pubspec.yaml` 已注册 `assets/images/`、`assets/midi/`、`assets/tflite/` |
| SVG 支持 | 当前未引入 `flutter_svg` |
| Native Splash | 当前仍为紫色配置 `#8736E9` 和 `assets/launcher/splash_logo.png` |
| 测试现状 | `test/widget_test.dart` 为基础启动 smoke test |

当前已发现的未提交改动：

| 文件 | 风险 |
|------|------|
| `lib/pages/practice/controller.dart` | 练习业务相关，编码时不可覆盖 |
| `lib/pages/practice/view.dart` | 本次目标文件，冲突风险高 |
| `lib/pages/practice/widget/bottom_piano_keyboard.dart` | 键盘 UI/交互相关，冲突风险中高 |
| `lib/pages/settings/note_settings/controller.dart` | 设置业务相关，需避免无关修改 |
| `lib/services/piano_practice/piano_practice_config.dart` | 练习配置相关，需避免无关修改 |
| `lib/services/piano_practice/piano_practice_service_impl.dart` | 练习服务相关，需避免无关修改 |
| `assets/tflite/`、`doc/`、`tool/` | 未跟踪目录，保持原样 |

---

## 3. 目标范围

### 3.1 本轮应修改

- 启动页：运行时 onboarding/splash 视觉，以及必要时同步 native splash 配置。
- 首页：标题区、三张数据卡、开始练习 CTA、练习模式列表、今日目标、底部导航。
- 进度页：周概览、每日得分柱状图、成就激励、下一个目标、底部导航。
- 设置页：个人卡、练习设置列表、账户与帮助列表、版本信息、底部导航。
- 练习页：横屏背景、左侧统计、五线谱面板、七键练习键盘、底部全键盘缩略条、右侧操作栏。
- 图标与背景：根据 v1.2 文件名映射使用 `icon_*.svg`、`icon_app_piano_glass.svg`、背景 SVG 对应资产。

### 3.2 本轮不应修改

- 不重写 MIDI 连接逻辑。
- 不改练习题生成、答题判定、统计计算、成就计算。
- 不改变主导航结构：仍为首页、进度、设置三栏。
- 不新增未确认的业务入口。
- 不删除或重写用户当前未提交的练习页/服务层改动。

---

## 4. 推荐技术路线

### 4.1 资产策略

推荐方案：将 v1.2 SVG 转换为 PNG 多倍率资源，放入 `assets/images/v12/`，并在 `lib/utils/assets.dart` 中统一声明。

原因：

- 当前工程已经使用 PNG 资源和 `Image.asset`。
- `pubspec.yaml` 已整体注册 `assets/images/`，新增子目录资源成本低。
- 避免新增 `flutter_svg` 依赖导致包解析、体积、兼容性和渲染差异风险。
- 背景、图标均为固定 UI 资源，PNG 多倍率足以满足本轮移动端表现。

备选方案：引入 `flutter_svg` 并直接加载 SVG。该方案视觉保真更高，但会修改依赖树；仅建议在用户明确要求“必须直接使用 SVG 文件”时采用。

### 4.2 UI Token 与共享组件

建议新增或整理一组轻量 v1.2 UI 基础能力：

| 能力 | 建议位置 | 用途 |
|------|----------|------|
| 色彩 token | `lib/theme.dart` 或 `lib/theme/v12_design_tokens.dart` | 统一背景、主色、紫色、青绿、文本、卡片、描边 |
| 冷雾背景 | `lib/widgets/v12_background.dart` | 统一竖屏页面背景、顶部钢琴键装饰、五线谱装饰 |
| 毛玻璃卡片 | `lib/widgets/v12_glass_card.dart` | 首页/进度/设置复用卡片样式 |
| 图标底座 | `lib/widgets/v12_icon_badge.dart` | 统一圆形/圆角图标容器 |
| 渐变 CTA | 页面内局部组件或共享 widget | 首页开始练习按钮 |

推荐保持组件轻量，不做大规模设计系统重构。当前页面数量少，过度抽象会增加改动面。

### 4.3 版本策略

设计稿与用户目标为 v1.2，当前工程版本仍是 `1.1.1+111`。建议编码阶段同步更新：

- `pubspec.yaml`：升级到 `1.2.0+120` 或用户指定 build number。
- 设置页展示：从硬编码/现有文案调整到 `1.2.0`。
- 如项目有 Android/iOS 独立版本配置，打包前再确认是否由 Flutter 生成同步。

---

## 5. 页面级实现评估

### 5.1 启动页

| 文件 | 评估 |
|------|------|
| `lib/pages/onboarding/view.dart` | 当前是深紫渐变和手绘钢琴键，需要替换为 v1.2 冷雾背景、App Logo、深色标题、浅色加载状态 |
| `pubspec.yaml` | `flutter_native_splash` 当前仍为紫色，需要同步配置浅色 splash |
| `assets/launcher/*` | 若需要系统级启动页一致，需要生成或替换 splash logo/png |

实现注意：

- 保留当前 onboarding 的跳转时序和本地状态逻辑。
- 文案继续使用现有 `S.of(context).onboardingTitle`、`homeSubtitle`，避免新增多语言工作。
- Native splash 修改后需要执行 `flutter pub run flutter_native_splash:create` 或项目约定命令。

### 5.2 首页

| 文件 | 评估 |
|------|------|
| `lib/pages/home/view.dart` | 当前已有页面结构和数据绑定，适合原位改样式 |
| `lib/pages/home/controller.dart` | 不需要改业务逻辑 |
| `lib/utils/assets.dart` | 需要新增首页用图标和背景资源路径 |

实现注意：

- 三张数据卡保留当前 `streakDays`、`totalPractices`、`accuracy` 数据源。
- CTA 保留跳转练习页逻辑。
- “和弦练习”已有多语言文案且标注即将上线。若要与 Figma 三项一致，建议只显示禁用/即将上线卡片并复用现有 toast，不新增真实练习模式。
- 广告 Banner 逻辑不应因视觉改造被误删。

### 5.3 进度页

| 文件 | 评估 |
|------|------|
| `lib/pages/progress/view.dart` | 当前统计卡、柱状图、成就、目标结构齐全，适合样式替换 |
| `lib/pages/progress/controller.dart` | 不需要改统计逻辑 |

实现注意：

- 周概览由深色渐变改为浅色玻璃卡。
- 柱状图改为蓝紫渐变，但保留当前分数/周几数据。
- 成就图标当前来自模型/emoji 可能需要替换为 v1.2 图标或 Material fallback。
- “查看全部”如没有现有详情页，保持当前行为或弱化为展示态，不新增空路由。

### 5.4 设置页

| 文件 | 评估 |
|------|------|
| `lib/pages/settings/view.dart` | 当前大量使用 emoji 作为图标，需要替换为 asset icon / IconData 组件 |
| `lib/pages/settings/controller.dart` | 不需要改业务逻辑 |

实现注意：

- 个人卡建议保留当前等级、学习天数、曲目等信息，只更新布局和样式。
- MIDI 行当前有连接状态 Switch。Figma 展示为右箭头，但代码里 Switch 承载真实连接状态。建议先保留 Switch，除非用户确认要改成详情页入口。
- 当前 `build` 中有多处刷新调用，属于既有实现问题。本轮可不处理，避免扩大范围。
- 设置页版本号需与 v1.2 版本策略一致。

### 5.5 练习页

| 文件 | 评估 |
|------|------|
| `lib/pages/practice/view.dart` | 本次视觉重点之一，但当前文件已 modified，编码风险最高 |
| `lib/pages/practice/widget/practice_side_button.dart` | 当前用字符串图标，建议升级为支持 asset/icon 的按钮组件 |
| `lib/pages/practice/widget/bottom_piano_keyboard.dart` | 当前已 modified，若调整底部键盘视觉需先合并用户改动 |
| `lib/pages/practice/widget/middle_piano_keyboard.dart` | 可能需要更新七键键盘样式 |

实现注意：

- 保留横屏强制逻辑、MIDI 状态、开始/停止、设置跳转和答题流程。
- 右侧“统计”按钮是否启用需要产品确认。Figma 有统计入口，当前代码曾注释掉统计按钮；如果实现，建议仅跳转现有进度页，不新增统计弹层。
- 五线谱、当前音符、选中键、全键盘范围高亮都必须在 812 x 375 横屏下做真机/模拟器检查。

---

## 6. 影响文件清单

| 文件/目录 | 修改类型 | 说明 |
|----------|----------|------|
| `pubspec.yaml` | 修改 | 版本号、必要时 native splash 配置；若采用 PNG 策略则无需新增依赖 |
| `assets/images/v12/` | 新增 | v1.2 背景、Logo、图标 PNG 多倍率资源 |
| `assets/launcher/` | 可选修改 | Native splash / launcher 资源同步 |
| `lib/theme.dart` | 修改 | v1.2 色彩 token 与全局样式 |
| `lib/utils/assets.dart` | 修改 | 新增 v1.2 asset path 常量 |
| `lib/widgets/v12_background.dart` | 可选新增 | 统一冷雾背景 |
| `lib/widgets/v12_glass_card.dart` | 可选新增 | 统一玻璃卡片 |
| `lib/widgets/v12_icon_badge.dart` | 可选新增 | 统一图标底座 |
| `lib/pages/onboarding/view.dart` | 修改 | 启动页视觉 |
| `lib/pages/main/view.dart` | 修改 | 底部导航颜色与图标 |
| `lib/pages/home/view.dart` | 修改 | 首页 v1.2 UI |
| `lib/pages/progress/view.dart` | 修改 | 进度页 v1.2 UI |
| `lib/pages/settings/view.dart` | 修改 | 设置页 v1.2 UI |
| `lib/pages/practice/view.dart` | 修改 | 练习页 v1.2 UI，需先处理 dirty diff |
| `lib/pages/practice/widget/practice_side_button.dart` | 修改 | 支持新图标和按钮样式 |
| `lib/pages/practice/widget/bottom_piano_keyboard.dart` | 可能修改 | 全键盘缩略条视觉；当前文件已有未提交改动 |
| `lib/pages/practice/widget/middle_piano_keyboard.dart` | 可能修改 | 七键键盘视觉 |
| `test/widget_test.dart` | 可能修改 | 若启动页或资源加载影响 smoke test，则同步修正 |

---

## 7. 风险评估

| 风险 | 等级 | 说明 | 应对 |
|------|------|------|------|
| 目标文件已有未提交改动 | 高 | 练习页和键盘文件已被修改 | 编码前先看 diff，按当前内容增量 patch |
| SVG 资源不能直接渲染 | 中 | 工程未引入 `flutter_svg` | 推荐转换 PNG，避免依赖变更 |
| Native splash 与运行时 splash 不一致 | 中 | 当前 native splash 仍是紫色 | 同步 `flutter_native_splash` 配置并重新生成 |
| 横屏练习页布局溢出 | 高 | 练习页信息密度高，且使用 ScreenUtil | 编码后必须横屏运行检查 |
| Figma 与现有业务状态不完全一致 | 中 | MIDI 行、统计按钮、和弦模式存在差异 | 视觉优先，业务入口只启用已有能力 |
| 多语言文案新增成本 | 低 | 项目已有 ARB 与 generated l10n | 优先复用现有文案，避免新增 key |
| 版本号不一致 | 中 | 设计为 v1.2，工程仍为 1.1.1 | 编码阶段确认 build number 后同步 |

---

## 8. 推荐实施顺序

1. 固化当前工作区状态：读取 `git status` 和目标文件 diff，确认用户改动边界。
2. 资源准备：从 `piano_sight_reading_assets` 同步 v1.2 素材，转换为 PNG 多倍率，放入 `assets/images/v12/`。
3. 基础样式：更新 v1.2 token、asset 常量和必要共享 widget。
4. 启动页与 native splash：先完成品牌入口，确认浅色开屏链路。
5. 主导航、首页、进度页、设置页：按竖屏主页面逐页落地。
6. 练习页：最后处理横屏高风险页面，保留已有业务与用户改动。
7. 验证与修复：格式化、静态检查、测试、真机/模拟器视觉检查。

---

## 9. 验证计划

| 验证项 | 命令/方式 | 目标 |
|--------|----------|------|
| 依赖解析 | `flutter pub get` | 确认资源/版本配置无问题 |
| 格式化 | `dart format lib test` | 保持项目格式一致 |
| 静态检查 | `flutter analyze` | 无新增 analyzer error |
| 单元/组件测试 | `flutter test` | 现有 smoke test 通过 |
| 竖屏视觉检查 | Android/iOS 模拟器 | 首页、进度、设置、启动页不溢出 |
| 横屏视觉检查 | Android/iOS 模拟器 | 练习页 812 x 375 布局不重叠 |
| 资源检查 | 手动检查构建日志 | 无 missing asset、无字体/图片加载错误 |

---

## 10. 待确认决策

| 决策 | 推荐 |
|------|------|
| 资源使用 SVG 还是 PNG | 推荐转换 PNG，降低依赖风险 |
| 版本号 build number | 推荐 `1.2.0+120`，如已有发布规则则以发布规则为准 |
| 设置页 MIDI 行是否保留 Switch | 推荐保留 Switch，避免损失连接状态交互 |
| 首页是否展示“和弦练习” | 可展示为禁用/即将上线卡片，不启用新模式 |
| 练习页是否启用“统计”按钮 | 若启用，建议跳转现有进度页；否则先按视觉弱展示 |

---

## 11. 下一阶段建议

技术评估完成后，按流程进入“工作时长评估”。建议基于本方案拆分工时：资产转换、基础组件、4 个竖屏页面、1 个横屏页面、native splash、验证修复。工时评估通过后，再进入 Flutter 技术文档与开发计划阶段，最后编码。
