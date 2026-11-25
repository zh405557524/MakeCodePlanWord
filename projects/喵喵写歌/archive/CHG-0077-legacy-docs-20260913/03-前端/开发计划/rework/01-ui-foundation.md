# 01 UI Foundation 返工模块开发文档

> 关联任务：CHG-0011 / UI Foundation  
> 当前状态：done  
> 设计稿来源：`首页/首页1.png`、`Ai写歌/*.png`、`作品/*.png`、`我的/*.png`  
> 影响工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/theme.dart`、`lib/widgets/`、`lib/utils/assets.dart`

## 1. 模块目标

先统一视觉基础，再开发页面，避免每个页面散落一套颜色、圆角、按钮和卡片样式。

本模块完成后，后续页面只组合公共组件：

- 深紫黑背景
- 深色弱描边卡片
- 绿色到青色主 CTA
- 橙色 PRO 胶囊
- 设计稿分段 Tab
- 彩色图标块
- 生成进度条
- 空态卡和列表占位

## 2. 现状偏差

| 项 | 当前情况 | 设计稿要求 |
|----|----------|------------|
| 背景 | `CustomTheme.background` 偏黑绿，部分页面自行渐变 | 统一深紫黑，顶部可轻微暗渐变 |
| 主按钮 | `AppButton` 单色 `CustomTheme.primary` | 绿色到青色渐变，胶囊圆角，黑色粗体字 |
| 卡片 | 多处直接 `surface/surfaceHigh` | 深色面板、弱边框、18-24 圆角 |
| 分段控件 | 作品页使用 Material `SegmentedButton` | 自定义整宽深色分段，激活项绿色描边/填充 |
| 图标块 | 页面内零散使用图片或 Icon | 统一方形渐变图标块，48 左右尺寸 |
| 进度条 | 无统一组件 | 绿色到青色渐变进度，深色轨道 |

## 3. Theme Token

建议在 `CustomTheme` 补充稳定 token：

| Token | 值 | 用途 |
|-------|----|------|
| `background` | `#080711` | 页面主背景 |
| `backgroundHigh` | `#0D0B18` | 顶部/局部背景 |
| `surface` | `#12111B` | 卡片背景 |
| `surfaceHigh` | `#191722` | 高层卡片/输入框 |
| `outlineWeak` | 白色 8%-12% | 卡片描边 |
| `primary` | `#20F06A` | 激活绿 |
| `secondary` | `#16C8E7` | 青色终点 |
| `accentPurple` | `#7E78D8` | 辅助文字 |
| `proOrange` | `#FF8A16` | PRO 胶囊 |
| `textPrimary` | `#F7F6FF` | 主文字 |
| `textSecondary` | `#8C86B8` | 次级文字 |
| `textMuted` | `#66617E` | 弱文字 |
| `loadingGradient` | `#00D6E7 -> #8BF3FB` | 非确定性加载五点图形 |
| `loadingText` | `#48E0EB` | 加载状态文案 |

渐变：

- `primaryGradient`: `#20F06A -> #16C8E7`
- `proGradient`: `#FF9D1A -> #FF7214`
- `cardGlowGradient`: 深绿/深蓝低透明，用于大输入卡和资产卡

## 4. 公共组件清单

建议新增或改造到 `lib/widgets/`，通过 `widgets/index.dart` 导出。

| 组件 | 目的 | 关键参数 |
|------|------|----------|
| `AppGradientButton` | 主 CTA | `label`, `icon`, `loading`, `disabled`, `onPressed`, `height`, `gradient` |
| `AppSegmentedTabs<T>` | 灵感/高级、歌曲/专辑 | `items`, `value`, `onChanged`, `labelBuilder` |
| `AppDarkCard` | 深色卡片容器 | `child`, `padding`, `radius`, `gradient`, `onTap` |
| `AppFeatureIcon` | 彩色图标块 | `icon`, `asset`, `gradient`, `size` |
| `AppGradientProgressBar` | 生成进度 | `value`, `height`, `trackColor`, `gradient` |
| `AppLoadingIndicator` | 全局非确定性加载 | `size`, `duration`, `progress` |
| `AppRefreshIndicator` | 下拉刷新手势与距离联动五点图形 | `onRefresh`, `child`, `edgeOffset` |
| `AppEmptyCard` | 页面内空态 | `title`, `subtitle`, `action` |
| `AppProPill` | PRO 按钮/badge | `label`, `onTap`, `compact` |

组件要求：

- 所有组件使用 `.w/.h/.sp/.r`。
- 默认色值来自 `CustomTheme`。
- 文字 `maxLines` 和 `overflow` 必须定义，防止设计稿以外长文案撑破。
- 按钮 loading 时禁用重复点击。

## 5. 实现步骤

1. 扩展 `CustomTheme` token 和渐变 getter。
2. 新增公共 UI 组件文件，或在现有 `app_button.dart` 基础上新增 `app_gradient_button.dart`。
3. 更新 `widgets/index.dart` 导出。
4. 保持旧 `AppButton` 不删除，避免影响旧页面。
5. 在四个主页面优先使用新组件，不大规模改动旧模块。

## 6. 状态与边界

- 禁止因新增主题 token 改崩旧页面。旧页面继续能使用原 `primary/surface`。
- 组件本身不写业务逻辑。
- 图标先使用 Material/Cupertino Icon；如果已有资产适配，走 `AppAssets`。
- 对稿复杂图片不在本模块生成，后续页面可用渐变/图标占位。

## 7. 验收标准

- [ ] `CustomTheme` 有主背景、卡片、弱边框、主渐变、PRO 橙、紫灰文字 token。
- [ ] 公共组件可被首页、写歌、作品、我的复用。
- [ ] 新增组件无业务依赖，能独立编译。
- [ ] 旧 `AppButton/AppEmpty/AppStateBuilder` 未被破坏。
- [ ] `flutter analyze` 无新增问题。

## 8. 2026-07-31 加载样式增量

- 新增 `AppLoadingIndicatorSize.large / medium / compact`，用 `CustomPainter` 绘制设计稿 65×49 五点青蓝渐变轨迹，默认 1000ms 依次脉冲。
- `AppLoading` 统一为五点加载器、15px 间距、12px 青色粗体文案；默认文案为“加载...”，并提供读屏语义。
- 页面、局部内容、按钮、Toast、播放器与视频初始化等非确定性加载已迁移；旧环形 `CustomLoadingIndicator` 已删除。
- 系统减少动态效果或辅助功能导航开启时停留在设计稿静态帧。
- 12 处下拉刷新统一迁移至 `AppRefreshIndicator`：保留系统刷新手势与原业务回调，使用无 Spinner 模式叠加 20×20px 小号五点图标，不显示系统圆环或背景圆盘。
- 5 处确定性 `LinearProgressIndicator` 与远程图片无动画占位保持不变。
- 验证：`flutter analyze`、加载组件专项 Widget 测试、42 项独立测试和相关路由单测通过；完整 `widget_test.dart` 的既有 `????` 占位断言仍失败，本轮未改。
- 尺寸复核：Figma 节点 `65:1470` 的完整加载组合为 65×81，实现已明确约束圆点区 65×49、间距 15、文字高 17，并将动画缩放下限调整为 90%。
- 刷新尺寸复核：下拉刷新不复用页面级 65px 宽规格，固定使用 20×20px 五点图标；未拉动时不创建动画，刷新结束后自动移除。

## 9. 2026-08-03 五点整体旋转与距离联动刷新

- `AppLoadingIndicator` 使用参考图中的 65×49 固定弧线五点几何（直径 5/8/10/13/15），放入 65×65 旋转场后整体绕中心转动；圆点自身不脉冲、不变形。
- 四档外框尺寸锁定为 `large 32×32 / medium 24×24 / refresh 20×20 / compact 16×16`；页面加载图标与文案间距收紧为 10px。
- `progress` 为空时默认 1000ms 整体旋转一周，传入 `0～1` 时由外部控制五点图形角度。
- 12 处下拉刷新统一使用 `AppRefreshIndicator` 和系统无 Spinner 手势：顶部下拉 0～80 逻辑像素线性映射 0～360°，超过 80px 后钳制为一圈，触发刷新后从当前角度继续自动旋转。
- 刷新图标同步跟手：0～80px 下拉线性映射到 0～60px 视觉位移（默认 40px 停驻位置的 1.5 倍）；松手触发后 150ms 回弹到 40px，取消时上收、完成时缩小淡出，均在 200ms 内移除。
- 下拉取消或刷新完成后移除五点图形；减少动态效果开启时仍响应直接拖动角度，但触发后的自主循环停在当前帧。
- 保留确定性进度条、图片占位、加载文案、Controller 状态、API 与路由逻辑。
- 验证：加载专项 10 项 Widget 测试连同其余 8 个独立测试文件共 48 项及 `flutter analyze` 通过；完整 `flutter test --fail-fast` 仍停在 `widget_test.dart:661` 的既有 `????` 占位断言。
