# CHG-0078 / T-W003 后台首页海报配置

> 2026-09-14 执行覆盖：`T-W003-R=in_progress`。已接 Admin 真实海报读取、上传、排序、启停和发布 API；Admin analyze、全量测试与 Web 构建通过。实际 OSS 审核发布、App 切换和非超管角色仍待验。下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 11 步模块文档已确认 · `T-W003-S=waiting_review`、`T-W003-R=pending` · 2026-09-14

> 骨架记录：现有歌曲配置页在受控开关下增海报页；支持增删、排序、启停、受控目标和带版本整份 `PUT`；`AdminRepository → ApiClient` 走正式路径。Admin 定向交互/模型测试与 `flutter analyze` 通过。资源选择、审核态、角色分块、冲突差异和真实发布未实现；页面明确“草稿仅校验，未发布”，仍待 UI 审阅。
> 输入：[PRD W08](../../01-需求/requirements.md)、[Flutter/Web 技术文档第 8 节](../flutter-tech.md)、[总体计划第 9 节](../flutter-dev-plan.md)、[Java B007](../../04-后端/开发计划/09-home-banners.md)、[首页图](../../01-需求/references/images/v2.1/home-revision/home-carousel.png)。后台没有独立新 Figma 页，延续工程现有配置页布局。

## 范围、入口与现状

管理员切换到 `catsinger` 且拥有 `song_config` 管理块后，从现有 `SongConfigPage` 的歌曲运营区进入“首页海报”。复用 `SongConfigPage → AdminRepository → ApiClient` 和现有 App 上下文，不开第二套后台。当前工程已有通用歌曲配置能力，尚没有带排序、审核资源和受控目标的首页轮播专用编辑区；不能把客户端静态 `_HomePromoCard` 当成已发布海报。切换 App 时清空列表、未保存草稿和编辑上下文；无权限显示权限态，不静默映射成登录失效。

| 区块/控件 | 展示与点击结果 | 状态与错误 |
|-----------|----------------|------------|
| 海报列表 | 按 `sortOrder` 展示缩略图、启停、目标、版本；可上下调序、编辑、添加、移除 | 加载中骨架；空配置提示先添加；图片失效显示占位但不得发布 |
| 图片资源 | 从现有受审核媒体资源选择，显示审核/发布状态与预览；不接受任意外链或客户端本地路径 | 待审/驳回不可发布，表单明确原因 |
| 跳转目标 | `AI 写歌 / 歌曲改编 / 翻唱声音克隆 / 无跳转` 受控选项；选中后预览对应入口 | 未知或已下线目标禁止保存，不能拼深链 |
| 保存/发布 | 先本地校验，再携带当前配置版本整份 `PUT`；成功刷新列表与版本 | 403 权限态；409 冲突保留草稿并提示刷新/重新合并；失败不覆盖线上版本 |

### 骨架阶段 / T-W003-S

在 Catsinger 原配置页新增上述区块、表单、拖动/按钮排序和图片预览。`AdminRepository` 增 `GET/PUT /api/admin/song/home-banners` 的正式方法，数据结构至少保留 `id/resourceId/sortOrder/enabled/targetCode/configVersion`；展示图 URL 仅由服务端投影。local/test 集中 fixture 可给两张确定值用于交互审阅，Web 页面不散落固定素材、价格或审核成功假状态。`TODO(REAL-IMPLEMENTATION)` 标出真实资源选择、权限、版本和发布校验。骨架不做真实上传/审核/配置写入，生产默认关闭未完成入口；通过 `flutter analyze`、列表增删排序与保存调用的定向测试后单独记录 `-S`。

### 真实实现阶段 / T-W003-R

1. 接 B007-R 的现有审核媒体库：只选择审核通过且可发布的图片，Admin 预览和 App 公开 URL 使用同一资源版本；可展示文字同样走既有审核边界。
2. 表单校验 ID 唯一、排序明确、图片资源有效、目标白名单；发布配置至少有一张有效启用海报。停用/删除最后一张时在界面预警，并以服务端拒绝为最终结果，保留草稿。
3. `GET` 读取当前 App 配置及版本；`PUT` 使用版本条件整份原子发布，不做逐行多次提交。409 时展示线上新版本与本地草稿差异，管理员明确选择刷新或重新编辑，不能自动覆盖。
4. Catsinger 以外 App 不展示此业务配置；切 App、刷新和角色撤权后旧草稿不能发给新 App。专用入口与通用 `PUT /api/admin/configs/{configKey}` 的同一 B007 发布校验由后端保证，前端不得绕过。
5. 发布后在 Android/iOS 首页核对排序、目标与数量；图片失效/禁用仅降级海报区域，热门案例独立可用。两张设计图是轮播状态，不是两张同时铺满屏幕。

## 影响文件、调用链与验收

影响 `/Users/soul/code/lxwx/lxwx_admin` 现有 `SongConfigPage`、对应 Controller/State、`AdminRepository`、DTO/Model、必要的权限显示组件；具体文件名编码前按工程现状定位，不重做通用媒体管理。调用链：页面编辑 → Repository 正式路径 → B007 权限/版本/资源/目标校验 → Catsinger 配置发布 → F006 首页消费。

`-S` 验证 App 切换、权限态、空态、添加/排序/编辑/保存按钮确实调用仓库方法，生产不写假配置。`-R` 用两个管理员制造版本冲突，审核未过/最后一张/跨 App/越权均拒绝，成功发布后 App 投影一致。每阶段留 Admin 截图、请求与响应字段、定向 `flutter analyze`/`flutter test` 证据。仅三端整体骨架获用户明确确认后进入 `-R`。
