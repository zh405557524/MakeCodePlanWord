# catsinger Flutter 技术说明

## CHG-0020 Web/Admin 运营账号门禁

- 仅修改 Web/Admin，不修改 Catsinger Flutter App。
- 沿用 `ApiClient → AdminRepository → BackendOperationsAccount → UsersPage` 分层，运营账号模型不复用包含 Apple 字段的审核账号模型。
- 用户管理页新增独立运营账号卡片，显示脱敏手机号、所属 App、账号状态和每日重置策略；冻结/解冻必须通过原因确认弹窗。
- App 切换时同时清除审核账号和运营账号缓存；异步响应只允许回写发起请求时的 App，避免跨 App 误展示和误操作。
- 页面不展示或保存完整手机号、固定验证码、用户 Token。

## 工程与分层

- Flutter 工程：`/Users/soul/code/lxwx/catsinger`
- 参考工程：`/Users/soul/code/soul/clip-flutter`
- 页面采用 `lib/pages/{feature}/index.dart + controller.dart + view.dart`，API、模型、路由和服务沿用项目现有分层。
- 状态管理使用 GetX，页面导航使用 GoRouter，尺寸适配使用 ScreenUtil。

## 支付模块

- 支付领域页面统一位于 `lib/pages/payment/`：`membership` 负责会员套餐购买，`points_recharge` 负责积分充值，`orders` 负责订单与续付，`processing` 负责支付处理中和外部 App 拉起，`widgets` 存放支付专用组件。
- 积分余额/流水继续保留在 `pages/points`，会员状态与权益模型继续属于会员或用户领域；支付模块只收口交易入口与执行流程。
- 会员和积分 Controller 负责校验协议、创建订单，并把 `PaymentOrder` 传入支付路由。
- `PaymentFlowCoordinator` 统一处理 Web/WAP 页面启动、历史支付宝 SDK 与 Apple IAP 返回后的订单确认、取消/失败反馈，以及最多 5 次、间隔 1.5 秒的有界轮询；商品加载、下单和权益/积分刷新仍由对应 Controller 负责。
- Android 默认渠道为 `alipay_web`，积分充值和会员购买页同时展示微信 Web/WAP 占位行；点击微信仅提示暂未开通并保持支付宝选中，不发送微信请求。
- Web 支付模块用隐藏 WebView 加载后端返回的支付宝 form HTML，捕获 `alipay/alipays` 后交给系统支付宝 App。
- Web 支付路由使用居中阻塞式“支付处理中”弹框，首次显示后自动提交一次；不再展示订单、金额、渠道或“确认支付”按钮。
- 支付结果不信任客户端跳转结果，统一通过现有订单详情接口确认，并把最新订单返回来源页刷新权益或积分。
- 外部 App 启动失败、协议捕获超时、表单加载或订单查询失败时关闭弹框并显示用户提示；待支付订单由来源页提示稍后查看或重新支付。
- Apple IAP、历史支付宝 App SDK、普通网页 WebView 和 `/payment/web-pay` 的 `PaymentOrder?` 返回契约保持独立。
- `membership`、`pointsRecharge`、`paymentOrders`、`paymentWebPay` 的路由名称与 URL 均保持不变，目录重构不影响调用方契约。

## 数据与安全边界

- 不新增或修改后端接口、数据库表、字段、索引或历史订单数据。
- 日志只记录支付阶段、脱敏订单标识和异常类型，不记录完整支付 URL、form HTML、Token 或签名参数。

## Web/Admin 首页歌曲列表编排

- Web/Admin 工程位于 `/Users/soul/code/lxwx/lxwx_admin`，沿用 `core API Client → data Repository → models → pages` 分层。
- 模块标签只管理名称、稳定 `tagCode`、状态和排序；展示模式不再出现在后台页面，后端兼容字段不由 Web/Admin 编辑。
- 首页列表与标签一一对应，保存 `displayCount` 和有序 `itemCodes`；候选歌曲只来自歌曲配置中已挂当前标签的条目。
- 歌曲配置表保留多标签能力，并增加“全部 + 标签”本地筛选；当前筛选标签作为新增歌曲的默认标签。
- App 工程不接入新接口；旧 `home-modules` 由后端保持兼容。

## CHG-0014 首页标签与歌曲二级页

- App 首页只读取 `/api/song-config/home-lists` 元数据并按 `sortOrder` 展示双列标签卡片；点击后进入独立二级路由，再按标签读取歌曲。
- 二级页使用独立 `pages/home/song_list` 模块并复用“我的作品”歌曲行，页面自身包含返回按钮，不进入主 Tab 外壳，因此不展示底部导航。
- 标签封面使用公开元数据的有效 `coverUrl`；空值由 App 使用现有渐变占位。歌曲列表保持服务端编排顺序，不做客户端二次截取。
- 歌曲详情弹层增加默认关闭的只读参数，首页歌曲仅显示播放、基础信息、Prompt 和歌词；“我的作品”原行为不变。
- Web/Admin 标签编辑增加封面上传、预览和清空，仍沿用 API Client → Repository → Model → Page 分层。

## CHG-0016 配置歌曲播放状态同步

- 首页歌曲二级页返回按钮直接复用作品详情模块公开的 `WorkDetailCircleButton`，图标统一为 `Icons.arrow_back_rounded`。
- `SongPlayerController` 通过可释放的 GetX Worker 订阅 `MusicPlayService.currentMusic/currentDetail` 和进度状态，不再占用全局单监听器。
- 配置歌曲页初次打开时忽略无关的旧播放会话；当前配置歌曲进入播放会话后，后续切歌统一同步活动歌曲 ID、详情、进度、时长和播放状态。

## CHG-0017 首页歌曲二级页新版对稿与自动播放

- `SongHomeListPage` 以 Figma 最新 `首页2（32:247）` 为视觉真源：保留 333 高曲线头图，正文使用 16 号栏目标题、54 高封面、70 点歌曲行节奏、无圆底返回键和列表后方红蓝光晕。
- `SongWorkListTile` 增加默认关闭的首页紧凑样式；只改变二级页的封面、间距、文字和图标尺寸，“我的作品”及生成中/失败行保持原样。
- 点击首页歌曲时，将当前接口结果按服务端顺序转换为 `MusicPlayTrack` 队列，强制选中所点歌曲并调用 `playId`，随后打开配置歌曲播放器。
- CHG-0016 的播放会话绑定继续负责播放器内活动歌曲、播放态和上一首/下一首同步；本轮不改接口、路由地址或服务端数据。

## CHG-0025 媒体稳定缓存键与单请求加载

- 临时签名 URL 只作为下载地址；缓存对象使用环境隔离后的业务键。歌曲主音频为 `song:{workId}:audio-primary`，歌曲封面为 `song:{workId}:cover`。
- 首页标签封面、案例头图、专辑封面、音色头像和音色试听分别使用 `tagCode`、案例 id、专辑 id 和音色 id，拿不到稳定业务标识时才回退 URL 键。
- `ResourceService` 统一通过内部资源缓存组件调用 `flutter_cache_manager` 落盘，账本同时保存稳定缓存对象键；旧 URL 键账本保持可读、可统计和可清理。
- 主歌曲首次未命中时只执行一次完整下载，下载完成后通过本地 `DeviceFileSource` 播放；不再同时进行 URL 流式播放和后台完整下载。
- `AppCachedNetworkImage` 在缓存服务可用时只执行一次缓存下载，落盘后使用 `FileImage` 展示；缓存服务尚未初始化时保留单独的网络展示兜底。
- 封面重新生成成功后按作品封面业务键清理文件和 Flutter 解码缓存；`updatedAt` 作为当前页面刷新信号，不参与稳定缓存键。
- 图片和音频仍共享用户设置的 1/2/5/10 GB 总上限，并按已修正的最近访问时间执行 LRU；本变更不修改本地缓存容量选项。

## CHG-0026 资源服务收口

- 删除公开的 `MediaCacheService`，远程资源换签、图片/音视频缓存、解码预热、容量统计和 LRU 裁剪统一由 `ResourceService` 暴露。
- 具体缓存实现保留为 `resource_cache.dart` 内部组件；业务页面、播放服务、设置页和统一图片组件不再感知第二套缓存 Service。
- `ResourceService` 进程实例可在隐私同意前注册，但磁盘缓存只在受保护服务初始化阶段启用；撤回隐私同意后释放内存图片资源并停用缓存能力。
- 沿用 `media_cache_entries`、`media_cache_limit_bytes` 持久化键，避免升级后丢失原有账本和用户缓存上限。
