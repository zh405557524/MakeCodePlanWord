# 02 Main Tabs 返工模块开发文档

> 关联任务：CHG-0011 / Main Tabs  
> 当前状态：done  
> 设计稿来源：`首页/首页1.png`、`Ai写歌/AI写歌-灵感创作1.png`、`作品/作品-作品.png`、`我的/我的.png`  
> 影响工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/pages/main/view.dart`、`lib/pages/main/controller.dart`

## 1. 模块目标

将当前浮动胶囊式底部导航改为设计稿中的贴底半透明深色导航栏，服务四个主 Tab：

- 首页
- 写歌
- 作品
- 我的

底部导航要成为全 App 主页面稳定基线，后续页面底部固定按钮和迷你播放器必须按它避让。

## 2. 现状偏差

| 项 | 当前实现 | 设计稿要求 |
|----|----------|------------|
| 容器 | 左右 24、底部 16 的浮动胶囊 | 贴底全宽深色栏，顶部弱分割线 |
| 高度 | 78.h 胶囊 | 约 82-96.h，含 SafeArea bottom |
| 激活态 | 灰色半透明圆角背景 | 绿色图标/文字 + 底部小绿线或光晕 |
| 首页图标 | 复用创作图标 | 首页应为 home 图标 |
| 写歌图标 | auto_awesome | 魔法棒/创作感图标，可继续用 Icon 但需对稿颜色 |
| 作品图标 | 资产图标 | 音符/作品图标，激活态绿色 |
| 我的图标 | 资产图标 | 用户图标，激活态绿色 |

## 3. 目标结构

`MainPage` 结构保持：

```text
CustomScaffold
  IndexedStack
    SongHomePage
    SongCreatePage
    SongWorksPage
    AccountPage
  bottomNavigationBar: ReworkBottomNav
```

底部导航布局：

```text
Container full width
  top border: white 8%
  background: #0D0D18 94%
  SafeArea bottom
  Row 4 equal items
    Icon
    label
    active indicator
```

## 4. 交互规则

- 点 Tab 调用 `MainController.changeTab(index)`。
- 重复点当前 Tab 仍执行 `_refreshVisibleTab`，保留现有刷新逻辑。
- 首页/作品/我的保持现有 IndexedStack，不重建页面。
- 首页或作品触发“去写歌”继续调用 `showCreateTab()`。
- 后续若首页传 prompt/纯音乐标记，MainController 增加轻量方法，不把业务状态塞进 Tab View。

## 5. 适配规则

- 导航栏固定在 `bottomNavigationBar`，使用 `SafeArea(top: false)`。
- 内容页面底部 padding 统一预留 `112.h - 128.h`，避免被底部导航遮挡。
- 375x812 下底部导航不应盖住作品列表第一屏最后一项的主体内容。
- iPhone 有 Home Indicator 时 SafeArea bottom 由系统处理，不另写魔法高度。

## 6. 实现步骤

1. 保留 `MainPage` 的 `IndexedStack`。
2. 重写 `_MainBottomNav` 容器为贴底栏。
3. 重写 `_NavItem`：移除大面积激活背景，改为图标/文字绿色和底部 indicator。
4. 首页图标改用 `Icons.home_outlined` / `Icons.home`，不再用 `iconCreateSelect`。
5. 写歌图标使用 `Icons.auto_fix_high_outlined` / `Icons.auto_fix_high`。
6. 作品图标使用 `Icons.music_note_outlined` / `Icons.music_note`，或现有资源但按绿色染色。
7. 我的图标使用 `Icons.person_outline` / `Icons.person`。
8. 检查四个页面底部 padding，页面模块中统一补齐。

## 7. 验收标准

- [ ] 底部 Tab 与四张主设计稿的结构一致：贴底、深色、四等分。
- [ ] 激活态绿色明显，未激活态紫灰。
- [ ] Tab 文案不换行、不溢出。
- [ ] 首页/写歌/作品/我的切换正常。
- [ ] 作品页和写歌页底部内容不被导航遮挡。
- [ ] `flutter analyze` 无新增问题。
