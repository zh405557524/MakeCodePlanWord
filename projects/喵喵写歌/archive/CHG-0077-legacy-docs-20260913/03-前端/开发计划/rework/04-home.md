# 04 Home 首页返工模块开发文档

> 关联任务：CHG-0011 / Home  
> 当前状态：done  
> 设计稿来源：`01-需求/references/images/v1.0/首页/首页1.png`、`首页2.png`  
> Flutter 工程：`/Users/soul/code/lxwx/catsinger`  
> 影响文件：`lib/pages/song_home/controller.dart`、`lib/pages/song_home/view.dart`

## 1. 模块目标

首页是用户最快开始创作的入口。本模块要把当前简版首页重写为设计稿结构：

- 顶部品牌区
- 大输入卡
- 2x2 快捷功能
- 热门案例
- 最近作品
- 底部导航避让

## 2. 现状偏差

| 区块 | 当前实现 | 设计稿要求 |
|------|----------|------------|
| 品牌区 | 只有大标题 `喵喵写歌` | 猫头像、标题、副标题、PRO会员按钮 |
| 输入卡 | 无 | 首页最大视觉中心，内含 prompt、标签、字数、开始创作 |
| 快捷功能 | 情景 chip | 2x2 卡片：场景写歌、图片写歌、纯音乐、AI作词 |
| 热门案例 | 歌曲示例 ListTile | 横向彩色卡片，更多入口 |
| 最近作品 | 无 | 作品小列表，播放入口 |
| 空态 | 整页空态 | 分区空态，不应让首页整体空白 |

## 3. 页面结构

```text
SongHomePage
  SafeArea(top)
  ListView bottom padding
    BrandHeader
    PromptCreateCard
    SectionTitle 快捷功能
    QuickFeatureGrid 2x2
    SectionTitle 热门案例 + 更多
    HotCaseHorizontalList
    SectionTitle 最近作品
    RecentWorkList
```

## 4. Controller 状态

`SongHomeController` 需要：

- `promptController`
- `promptLength`
- `loadingConfig`
- `loadingCases`
- `loadingRecentWorks`
- `errorMessage`
- `cases`
- `recentWorks`

生命周期：

- `onInit()` 加载配置、案例、最近作品。
- `onClose()` dispose `promptController`。

降级策略：

- 案例接口失败：热门案例区域显示空态，不影响首页其他区域。
- 最近作品接口失败：最近作品区域显示空态，不影响首页其他区域。
- 没有案例但有 examples：可用 examples 作为展示降级，但文案写“歌曲示例”，不伪装成真实案例详情。

## 5. 交互规则

| 入口 | 行为 |
|------|------|
| 输入卡开始创作 | 切到写歌 Tab，回填 `prompt` |
| prompt 为空开始创作 | 直接切到写歌 Tab，不提交生成 |
| 场景写歌 | 进入 `RouteName.songScenario`，若无场景配置显示 toast |
| 图片写歌 | 打开图片选择或进入写歌页图片模式；本轮可先 toast `图片写歌待联调`，UI 必须存在 |
| 纯音乐 | 切到写歌 Tab，并把纯音乐开关设为 true |
| AI作词 | 切到写歌 Tab 的高级创作，并聚焦/提示 AI帮写 |
| 热门案例卡 | 进入案例详情；若详情页暂未重做，可先路由到现有详情或 toast |
| 最近作品 | 进入播放器 `RouteName.songPlayer` |

跨 Tab 回填：

- 推荐在 `MainController` 增加方法或通过 `SongCreateController` 公共方法处理。
- 不允许用全局散落变量。

## 6. UI 细节

品牌区：

- 左侧 `🐱` 或猫头像资源，标题 24-26.sp 粗体。
- 副标题使用紫灰色。
- PRO 按钮使用橙色胶囊。

输入卡：

- 高度约 190-220.h。
- 深色渐变背景，绿色弱描边。
- TextField 最大 200 字。
- 标签：流行、民谣、电子、国风，选中态绿色半透明胶囊。
- 按钮在卡片底部，使用 `AppGradientButton`。

快捷功能：

- 两列 Grid，间距 14.w / 16.h。
- 卡片高度约 96-110.h。
- 图标块 44-48.r。
- 标题 16.sp，说明 12-13.sp。

热门案例：

- 横向滚动，卡片宽约 132-150.w。
- 颜色可用渐变占位；若有封面 URL 后续接网络图片。
- 更多入口右侧 chevron。

最近作品：

- 列表最多 3 条。
- 左侧封面/渐变占位，右侧标题和时间，尾部播放按钮。

## 7. 实现步骤

1. 补 `SongHomeController` 状态和加载方法。
2. 重写 `SongHomePage` ListView 区块。
3. 接入 `SongAPI.fetchCases` 和 `SongAPI.fetchRecentWorks`。
4. 实现首页到写歌 Tab 的回填方法。
5. 给每个分区补空态，不让整页因某接口失败而空白。
6. 调整底部 padding 避开 Main Tabs。

## 8. 验收标准

- [ ] 375x812 首屏结构与 `首页1.png` 一致。
- [ ] 品牌区、输入卡、快捷功能、热门案例都出现在首屏。
- [ ] 开始创作直接切写歌 Tab 并回填 prompt。
- [ ] 纯音乐入口直接切写歌 Tab 并开启纯音乐。
- [ ] 热门案例无数据时显示分区空态。
- [ ] 最近作品无数据时显示分区空态。
- [ ] 底部导航不遮挡热门案例和最近作品。
- [ ] `flutter analyze` 无新增问题。

## 9. 增量变更记录

| 时间 | 变更 | 结果 |
|------|------|------|
| 2026-08-08 | CHG-0063 首次进入主页隐私协议弹框修复 | 主容器改为有状态生命周期，首帧后对“未同意且未明确拒绝”的首次用户主动展示现有协议弹框；已同意不重复弹，已拒绝保留有限浏览与受保护操作再询问；隐私流程 6 项、弹框交互 1 项及静态分析通过 |
