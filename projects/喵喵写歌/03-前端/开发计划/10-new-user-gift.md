# CHG-0078 / T-F007 首页新人礼弹窗

> 2026-09-14 执行覆盖：`T-F007-R=in_progress`。已接真实预览、曝光确认、稍后关闭和领取接口；未执行真实新账号、跨天/重启、角色配置及设备截图验收。下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 11 步模块文档已确认 · `T-F007-S=waiting_review`、`T-F007-R=pending` · 2026-09-14

> 骨架记录：同页独立弹窗及 `fetch/confirm/dismiss/claim` 调用已接正式路径；`openId` 随每次操作提交。`flutter analyze` 与模型测试通过；资格、曝光、积分和任务结果仍由 local/test 固定响应演示，未做真实设备弹窗截图。App 全量旧 Widget 测试出现等待超时，不能当成回归通过。
> 2026-09-14 UI 校准：弹窗补三项权益区块、可选图片、长文案滚动与返回键“稍后领取”；领取目标 `task_center/checkin` 均进入既有任务中心。仅 local/test 显式开关显示；Android/iOS 弹窗和真实服务端资格未验。
> 输入：[PRD P01/W09](../../01-需求/requirements.md)、[Flutter 技术文档第 8 节](../flutter-tech.md)、[总体计划第 9 节](../flutter-dev-plan.md)、[Java B009](../../04-后端/开发计划/11-new-user-gift-state.md)。Figma `xvrgwxfy`：弹窗 `151:8116`、既有任务中心 `151:8281/8422`；[本地参考图](../../01-需求/references/images/v2.1/home-revision/new-user-gift.png)。

## 骨架阶段 / T-F007-S

在首页增加覆盖层：按服务端 `shouldShow` 打开，对已登录状态触发查询；实际渲染后通过 Song API 正式 `impressions` 方法确认曝光，按钮分别触发 `dismiss`、`claim` 方法。固定可显示/已领取/不可显示及目标来自 local/test 集中 fixture，不在页面硬写“新用户”判定、积分数字或永久领取状态。骨架可显示主按钮“领取新人礼”和次按钮“稍后领取”，成功目标进入既有 `RouteName.taskCenter` 或后台允许的现有任务/签到入口；新用户注册积分仍由旧建号流程发放。

`TODO(REAL-IMPLEMENTATION)`：服务端资格与 `openId` 频次、真实曝光幂等、点击后的请求重试/恢复和资源审核投影由 T-F007-R 完成。骨架不登记真实曝光、不冻结/发放积分，不调用上传、审核或厂家。`flutter analyze` 与弹窗状态/按钮调用 Widget 测试通过、生产默认隐藏假资格，才可记 `-S` 完成。

## 真实实现阶段 / T-F007-R

1. 登录态且首页稳定可见后调用 `GET /api/song-config/new-user-gift`。客户端不凭本地首次打开、会员标识或游客设备 ID 判断资格；未登录、`shouldShow=false`、配置/网络失败一律不挡首页。
2. 一次冷启动只生成一个 `openId`，会话内复用；它仅辅助 `PER_OPEN`，不是跨设备新身份。弹窗渲染后提交本次 `impressionToken`；请求重复或页面重建不能重复计曝光。一次页面会话点击“稍后”后抑制即时重弹，下一次符合规则的触发重新向后端求资格。
3. “稍后领取”、返回键、允许的关闭动作均调用 `dismiss` 撤销本次令牌曝光，然后关弹窗；网络失败也可关当前弹窗但要在后续触发重新查服务端，不能本地假定已撤销。`claim` 按钮提交中防双击，成功后当前会话不再弹并按返回的**白名单**目标进入现有签到/任务页；目标失效提示但不恢复领取资格。
4. `claim` 响应不明（断网/超时）时不本地标已领取，重查服务端资格，幂等重试以同一令牌为准；明确失败显示可读提示。切换账号、从后台回前台或重启重新查，旧账号的本地关闭态不能影响新账号。
5. 根据真实图做深色遮罩、居中礼物弹层、主次按钮层级，弹窗不挡系统安全区；375×812 必验、390×844/414×896 抽查长文案与小屏。任务中心原页面不因本模块重做；截图积分数字从原任务/余额接口取，不写死 120、+3、+10。

## 现状、入口与职责

| 项 | 内容 |
|----|------|
| 入口 | 首页覆盖层，只在后端允许时展示；“领取”进入配置的现有签到/任务入口，“稍后”留在首页 |
| 当前差距 | `HomePage` 尚无新人礼覆盖状态；`MainController` 已能切 Tab/进入已有路由，任务中心 `RouteName.taskCenter` 已存在 |
| 主要文件 | `lib/pages/home/controller.dart`、`view.dart`、局部弹窗 Widget；`lib/apis/song.dart`、`lib/models/data/song.dart` 或邻近强类型模型；登录态/路由只复用现有 Store/Controller |
| 状态所有权 | Home Controller 管 `loading/eligible/showing/confirming/dismissing/claiming/error` 与本次令牌；后端是资格真源；页面临时抑制不持久化为用户已领取 |

## 前后端契约与异常

| 请求 | 输入 / 响应关键字段 | 页面可见处理 |
|------|--------------------|--------------|
| `GET /api/song-config/new-user-gift`（登录态） | 可选 `openId`；`shouldShow, impressionToken?, imageUrl?, text?, targetCode?, configVersion?` | `false`/无令牌不弹；审核图失败时安全降级，不显示无法操作的假礼物 |
| `POST /api/song-config/new-user-gift/impressions` | `{impressionToken, openId?}` | 渲染后确认；相同令牌重试不重复计数；未确认前主按钮不进入不可逆领取 |
| `POST /api/song-config/new-user-gift/dismiss` | `{impressionToken}` | 关闭本次展示，不消耗资格；失败留待下次服务端资格查询纠正 |
| `POST /api/song-config/new-user-gift/claim` | `{impressionToken}`；`claimed, targetCode?` | 成功后永久不弹；只导航，不自动领注册/签到/任务积分 |

使用现有 `ApiResponse`、用户 Token、`X-App-Code: catsinger`；无权/令牌失效/目标无效/配置版本冲突/服务错误由既有错误包络映射成提示、关弹窗或可重试状态，不在 View 解析原始 HTTP。服务端 B009 在账号行/资格状态行原子判定，客户端不以页面动画完成等同发积分完成。默认首次登录可弹；`ONCE/DAILY/PER_OPEN` 只在**点击领取前的新用户资格**内生效，稍后不消耗一次展示。

## 验收与恢复点

- `-S`：本地 fixture 依次走应弹、稍后、领取、失败；请求路径与 B009-S 一致，固定响应不出现在生产。
- `-R`：同账号双击/重启/切后台、两账号切换、会员人群、每日时区边界、每次打开、稍后再见、领取后永久不弹都按真实服务端状态通过；弹窗行为不增加任何积分流水。
- 每阶段登记按钮状态、API 调用证据、Android/iOS 截图和未实现 TODO。`-R` 必须等整体三端骨架明确审阅通过，普通“继续”不解锁。
