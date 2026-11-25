# CHG-0078 / T-F006 首页海报与三业务入口

> 2026-09-15 交互修复：多海报支持触摸、鼠标和触控板手动切页，并按 5 秒自动轮播；用户拖动、离开首页主 Tab 或 App 进入后台时暂停，恢复后重新完整计时。0/1 张及列表刷新均有定向回归，迷你播放器叠层不拦截手势；375×812 两张状态截图与既有像素基准逐文件 SHA-256 完全一致。

> 2026-09-14 执行覆盖：`T-F006-R=in_progress`。新首页 Debug/Release 默认启用，已接真实海报接口与三个独立业务入口，App analyze、定向 Widget 测试及 Android Debug 构建通过；真实海报配置、375/390/414 截图与 Android/iOS 点击仍待验。下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 11 步模块文档已确认 · `T-F006-S=waiting_review`、`T-F006-R=pending` · 2026-09-14

> 骨架记录：`lib/pages/home/home_skeleton.dart`、`controller.dart`、`models/data/song_home_benefit.dart` 和 `SongAPI.fetchHomeBanners` 已接正式路径；`flutter analyze` 与新模型测试通过。local/test 开关才显示轮播，正式构建保留旧首页。未接审核资源/发布配置，Android/iOS 对稿与真机点击未验收。
> 2026-09-14 导航校准：预览首页的 AI 写歌卡和 `song.generate` 海报进入既有灵感创作，改编与声音克隆分别走原独立入口；未知海报目标保持静态。正式静态首页行为未改。定向模型/路由测试通过，设备点击仍待验。
> 输入：[PRD P01](../../01-需求/requirements.md)、[Flutter 技术文档第 8 节](../flutter-tech.md)、[总体计划第 9 节](../flutter-dev-plan.md)、[Java B007](../../04-后端/开发计划/09-home-banners.md)。Figma `xvrgwxfy`：`151:7830/7973`；[本地双海报图](../../01-需求/references/images/v2.1/home-revision/home-carousel.png)。第 4 步已按用户决定 `skipped`，不补画设计稿。

## 骨架阶段 / T-F006-S

页面按新稿完成品牌区、Banner 轮播/指示点、通栏 AI 写歌、并排改编歌曲/AI 翻唱、热门案例和现有底栏。`HomeController` 调 `SongAPI.fetchHomeBanners()`（方法名为建议，正式路径固定 `GET /api/song-config/home-banners`）得到 local/test 受控固定列表；View 不内嵌示例图片地址、两张数量或业务价格。现有三个导航回调仍接 `MainController`；不得在入口点击时创建任务或冻结积分。必须能从首页返回并维持滚动位置；生产构建默认不展示未完成的动态 Banner 假结果。

`TODO(REAL-IMPLEMENTATION)`：真实海报发布态/审核 URL、配置刷新、目标白名单和图片失效恢复归 T-F006-R。骨架验证：页面与按钮可操作，`flutter analyze`、针对轮播/静态目标/三入口的 Widget 或 Controller 测试通过；只说明调用链，不能宣称后台已发布素材。

## 真实实现阶段 / T-F006-R

1. 读取 B007-R 的当前有序 `items[{id,imageUrl,targetCode?}]`，与热门案例接口分别维护 `loading/ready/error`，海报失败只降级海报区域，案例仍展示。App 可缓存上一份经审核投影，但不能缓存坏目标；配置刷新以服务端为准。
2. `targetCode` 通过**受控映射**分派到现有写歌、改编或声音克隆入口；`null`、未知、下线及当前构建未开放目标均不可点击。业务卡始终分别调用原业务入口；不根据海报文案判断模式。
3. 图片加载/解码失败时显示不可点击的深色占位，不尝试任意远程 URL。只剩一张时不强制自动滚动；多张时页码与手势一致，用户返回仍在原滚动位置。
4. 按新稿 375×812 截图核对；390×844/414×896 抽查轮播、双卡文字和下方案例/底栏无遮挡。金额、时长和运营标题按真实长度换行，设计示例数字不作数据断言。

## 入口、现状与文件

| 项 | 当前工程事实 / 目标 |
|----|--------------------|
| 入口 | 主导航首页 `HomePage`，无新 Tab；运营海报只引导跳转 |
| 现状 | `lib/pages/home/view.dart` 的 `_HomePromoCard` 还是静态宣传卡；`HomeController` 用 `SongConfigStore` 加载热门案例，可分区失败；`MainController.openCover/openVoiceCover` 已区分改编与克隆 |
| 主要文件 | `lib/pages/home/controller.dart`、`view.dart`、必要的局部 `widgets/`；`lib/apis/song.dart`、`lib/models/data/song.dart`、`lib/pages/main/controller.dart`；现有主题/路由文件仅在确有需要时局部调整 |
| 状态所有权 | `HomeController` 管海报加载/错误、当前页索引及刷新；`SongAPI` 只解响应包络，强类型模型安全解析；`SongConfigStore` 不拿 `SongCase.bannerUrl` 冒充运营 Banner |

## 设计与交互拆解

设计图是两个**轮播状态**，不是同时展示两张。顶部品牌和首张通栏 Banner 占第一屏，轮播下有短指示线；AI 写歌通栏卡在上，改编/翻唱两个并排卡在下，热门案例双列在后。卡片是明确命令入口，不把图中“AI 翻唱”文字映射成旧 AI 改编。初始两张由后台提供，但页面不能假定永远恰好两张；实际图片、标题和目标均来自经过 B007 处理的投影。Figma 未给后台配置异常画面，遵循现有暗色主题提供安静占位/重试，不阻断主页面。

| 点击/状态 | 预期行为 |
|-----------|----------|
| AI 写歌卡 | 进入既有写歌页面；之后用户提交仍走 `/api/song-generations` |
| 改编歌曲卡 | 调现有 `MainController.openCover`；提交属于 `/api/song-covers` |
| AI 翻唱卡 | 调现有 `MainController.openVoiceCover` 与 `RouteName.songVoiceCover`；提交属于 `/api/song-voice-covers` |
| 有目标海报 | 目标映射有效才导航；未登录门槛沿现有目标页面 |
| 无目标/坏目标海报 | 静态展示，不弹错误页面、不改任务类型 |
| 热门案例 | 继续沿现有列表/播放链；海报接口失败不能把案例清成同一错误态 |

## API、错误与数据流

`GET /api/song-config/home-banners` 使用现有 `X-App-Code: catsinger`，响应沿项目现有 `ApiResponse` 包络，业务 `data.items` 仅含有序 `id/imageUrl/targetCode?`。空/配置错误/网络异常时显示不可点击安全占位；响应缺字段或重复 ID 时丢弃无效项并记录可诊断错误，不允许根据原始 JSON 直跳路由。管理员配置与来源状态由 B007 负责，App 不接受资源 ID、内部存储路径或任意深链作为公开可点击目标。

页面链路：`HomePage → HomeController → SongAPI → B007 公开投影`；点击链路：`HomePage → MainController → 原业务路由`。不要在 View 直接发 HTTP，也不要在 `SongConfigStore` 里混入别的 App 的海报。首页只负责引导；旧三个创建 API 不改。

## 验收与恢复点

- `-S`：local/test 两张固定海报可切，三入口路由不同，静态海报无动作；生产未完成入口关闭；无数据库/积分/厂家副作用。
- `-R`：后台发布两张、增第三张、只剩一张、资源失效和禁用目标均在 Android/iOS 首页呈现正确；375×812 必验，390×844/414×896 抽查。
- 每个阶段分别登记影响文件、分析/测试结果、截图和未实现 TODO。`T-F006-S` 完成**不**允许执行 `T-F006-R`，须等三端整体骨架评审获明确确认。
