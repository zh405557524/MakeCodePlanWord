# Flutter 前端代码测试基线

> 历史状态：`reference-only`
> 当前测试基线：[`frontend-code-test-baseline-v1.1.0.md`](frontend-code-test-baseline-v1.1.0.md)
> 说明：本文件记录 2026-07-10 时的五槽导航和旧页面结构，不再作为当前 1.1.0 安装包的执行依据。

> 代码仓库：`/Users/soul/code/lxwx/catsinger`
> 代码快照：`6d54de26` + 当前工作区（仅发现 `pubspec.lock` 未提交变化）
> 生成日期：2026-07-10
> 用途：测试用例先从当前 Flutter 路由、页面、Controller、按钮回调和 API 调用反推；PRD/设计稿用于判定代码行为是否满足产品预期。

## 1. 测试真源优先级

1. 当前 Flutter 工作区的可达页面、按钮和 Controller 分支。
2. 当前 Java 接口和 Flutter API 适配层的实际契约。
3. v1.0/v1.1 PRD 和设计稿，用于发现代码行为与产品预期的冲突。
4. 旧归档文档仅作追溯，不生成当前测试预期。

测试时不能因为代码“当前就是这样”而把明显违反业务规则的行为判为通过。代码与 PRD 冲突时，在用例备注中标为“代码差异”，执行失败后登记缺陷或由产品书面确认新口径。

## 2. 当前主导航与页面结构

来源：`lib/pages/main/view.dart`、`lib/pages/main/controller.dart`。

| 入口 | 当前代码页面 | 当前行为 |
|------|-------------|----------|
| 底栏「首页」 | `SongCreatePage` | 默认即歌曲创作页，index=0 |
| 底栏「探索」 | `SongHomePage` | 轮播、快捷入口、场景模板、热门歌曲，index=1 |
| 中央加号 | `SongCreatePage` | 登录后切回 index=0 |
| 底栏「作品」 | `SongWorksPage` | 必须登录，index=2 |
| 底栏「我的」 | `AccountPage` | 游客也可打开，受保护入口再要求登录，index=3 |

因此当前 UI 不是旧文档中的“四个文字 Tab”，测试截图以实际五槽底栏为准；若产品要求恢复四 Tab，需要单独登记变更，不能在测试用例里混用两套口径。

## 3. 当前写歌模式

来源：`lib/pages/song_create/widgets/mode_tabs.dart`、`lib/pages/song_create/view.dart`。

| 模式 | 页面/Controller | 当前核心校验 |
|------|-----------------|--------------|
| 灵感创作 | `SongInspirationCreatePage` | 非纯音乐必须填写歌曲描述；支持随机灵感、人声、纯音乐、积分确认 |
| 大师创作 | `SongMasterCreatePage` | 非纯音乐必须有歌词；纯音乐至少有标题、曲风或参考音频；支持 AI 帮写、语言、时长和参考音频 |
| 热歌改编 | `SongCoverCreatePage` | 选择/上传来源、人声风格、曲风改编后创建 cover 任务 |

提交均先检查全局隐私同意和积分确认，成功后进入 `/song/generating/:id`。

## 4. 当前探索页行为

来源：`lib/pages/song_home/view.dart`、`lib/pages/song_home/controller.dart`。

- 顶部轮播固定 3 项，每 5 秒自动轮播；离开探索页停止轮播。
- 快捷入口为：极简写歌、大师写歌、热歌改编、场景写歌。
- 极简/大师/热歌改编会切回底栏首页并切换对应创作模式。
- 场景写歌当前按钮只执行 `CustomToast.text('场景写歌功能待接入')`。
- 场景模板和热门歌曲来自 `/api/song-config/home-modules`；有 `workId/sourceWorkId` 时进入配置歌曲播放器，否则提示无可播放音频。
- 配置为空时分别显示“暂无场景模板”“暂无热门歌曲”；请求失败只影响配置区。

## 5. 当前场景写歌代码

来源：`lib/pages/song_home/scenario/`、`lib/routes/router.dart`。

- 路由 `/song/scenario/:code`、四步 Controller 和页面均存在。
- 默认四步：送给谁、什么场景、想表达什么、喜欢什么风格。
- 每步必须选择后才能继续，返回键逐步后退。
- 最后一步当前直接创建 `mode=scenario` 生成任务并进入生成中页，不回填写歌 Tab。
- 当前普通 UI 没有把探索页“场景写歌”按钮接到该路由，这是 P1 验收项 `SCENE-ENTRY-001`。

## 6. 当前作品与专辑行为

来源：`lib/pages/song_works/`。

- 作品页当前只显示“我的音乐”；`草稿歌曲/喜欢` 代码存在但 `visibleValues` 未开放。
- 我的音乐按生成中、失败、可播放三类展示。
- 点击已完成作品直接开始播放并进入播放器；返回后显示迷你播放器。
- 更多操作当前为“查看详情/删除歌曲”；生成中的作品不能删除。
- Controller 会加载专辑，专辑详情、加歌、移歌、删除和作品详情“加入专辑”均已实现，但作品页当前没有可见专辑 Tab 和创建专辑入口。
- 专辑能力需要通过预置专辑或接口创建后测试；“用户从作品页创建专辑”作为代码差异单独验收。

## 7. 当前播放器与作品详情

来源：`lib/pages/song_works/player/`、`lib/pages/song_works/work_detail/`。

- 播放器支持播放/暂停、上一首/下一首、进度、封面/歌词、逐句时间轴滚动和静态歌词降级。
- 普通作品支持分享、下载、收藏、重新生成、重新生成封面、重新翻唱等 Controller 能力；配置歌曲播放器不展示私有作品操作。
- 作品详情显示 Prompt、歌词、模型、时长、积分、曲风，并提供播放、下载、分享、重新生成封面、加入专辑、重新生成、重新翻唱和删除。
- 分享接口无内容时提示“分享能力待开放”；没有 ShareService 时复制分享链接。

## 8. 当前 AI 翻唱行为

来源：`lib/pages/song_cover/`、`lib/pages/song_create/cover/`。

- 独立 `SongCoverPage` 为上传歌曲、选择音色、高级设置三步，主要从作品详情/播放器“重新翻唱”进入。
- 探索页“热歌改编”进入的是首页内嵌 `SongCoverCreatePage`，不是独立三步页。
- 作品库仅展示可播放作品；时长必须在 6 秒至 6 分钟。
- 本地选择当前代码支持 `MP3/WAV/M4A/AAC/FLAC/MP4`，最大 50MB，时长 6 秒至 6 分钟。
- 选择作品会清除本地来源；选择本地来源会清除作品来源。
- 音色列表只展示 enabled 项，按 sortOrder 排序，并默认选中第一项。
- 高级设置为保留歌词、保留伴奏、音高 -6 至 +6、情感、混响；默认价格取 cover 模型，否则 150 积分。
- 已修复局部响应式刷新，必须回归“选择歌曲后标题更新”和“版权卡勾选态更新”。

### 8.1 必须验证的代码差异

- `SongCoverController.canContinue` 的 source 步骤当前只检查 `sourceReady`，没有检查 `copyrightConfirmed`。
- `submit()` 当前固定发送 `copyrightConfirmed: true`，并未使用页面勾选值。
- 因此“未勾选版权仍可下一步/提交”不能判为通过；测试预期仍是未确认版权时不可进入下一步，执行失败登记 P1。

## 9. 当前我的与商业能力

来源：`lib/pages/account/`、`lib/pages/membership/`、`lib/pages/points/`。

- 游客可查看我的页和设置，头像/“立即登录”进入登录；作品、会员、积分、订单、任务等受保护入口跳登录。
- 我的页当前展示积分余额、SVIP 卡、积分福利、积分充值、订单列表、意见反馈、联系客服、更多设置。
- 会员和积分充值均需要选择商品/渠道、勾选协议后提交，并轮询订单结果。
- 任务中心支持加载总积分、连续签到、签到规则和邀请任务。
- 设置页包含缓存、静态协议页、账户安全和退出登录等当前可见操作；用例只覆盖代码实际显示项。

## 10. 当前测试覆盖不足

- 前端仓库当前只有 `test/song_config_store_test.dart` 和 `test/widget_test.dart` 两个测试文件。
- 本轮人工用例必须覆盖当前缺失的页面交互、路由、上传、音频、权限和端到端状态。
- 自动化优先补：主导航、写歌三模式提交参数、场景入口与四步、作品状态、AI 翻唱版权门禁、播放器歌词和商业页表单校验。
