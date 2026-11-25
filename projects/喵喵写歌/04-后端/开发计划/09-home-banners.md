# CHG-0078 / T-B007 首页海报与配置共校验

> 2026-09-14 执行覆盖：`T-B007-R=in_progress`。已接 Catsinger `app_configs` 发布、资源审核/公开投影、目标白名单和超管 Admin 接口；定向测试通过。真实 OSS 审核策略与多管理员并发未验；下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 12 步模块文档已确认 · `T-B007-S=waiting_review`、`T-B007-R=pending` · 2026-09-14

> 骨架记录：新 DTO/VO、用户与 Admin Controller → `SongHomeBenefitSkeletonService` → 集中 Fixture 已编译，三类配置键的通用后台写入口阻止绕开门禁。类仅 local/test 加显式属性装配；定向 Gradle 测试通过。审核资源、版本冲突、真实 App 权限及配置发布未实现，不应视作线上海报功能。
> 输入：[PRD P01/W08](../../01-需求/requirements.md)、[Java 技术文档第 9 节](../java-tech.md)、[总体计划第 9 节](../java-dev-plan.md)、[Flutter F006](../../03-前端/开发计划/09-home-carousel.md)、[Admin W003](../../03-前端/开发计划/11-admin-home-banners.md)。

## 现状、接口和所有权

现有 `/api/song-config`、`/api/admin/song`、`AppConfigStoreService`、Catsinger `app_configs`、Admin `song_config` 权限和资源审核链可复用。尚无专用 Banner 公开投影与原子配置校验。仅 Catsinger 响应新配置，不修改 narrate 的首页数据或现有三个业务创建 API；海报是入口展示，不创建任务。`song.home.banners` 是配置键，不新增独立业务表。

| 接口 | 输入/输出 | 鉴权与边界 |
|------|-----------|------------|
| `GET /api/song-config/home-banners` | `data.items[{id,imageUrl,targetCode?}]`，已发布有效项按序 | `X-App-Code: catsinger`；不暴露资源内部路径、未审文件和编辑草稿 |
| `GET /api/admin/song/home-banners` | 完整编辑 DTO：`items[{id,resourceId,sortOrder,enabled,targetCode?}],configVersion` | Admin token、Catsinger、`song_config` |
| `PUT /api/admin/song/home-banners` | 整份 DTO + 所见 `configVersion`；返回发布后版本 | 同上；版本冲突/资源非法/无有效海报拒绝 |
| 通用 `PUT /api/admin/configs/{configKey}` | `configKey=song.home.banners` 时接受同义完整配置 | 必须委托同一发布 Service，不能用通用入口绕过审核/最后一张规则 |

`targetCode` 只允许无跳转或现有 AI 写歌、歌曲改编、翻唱声音克隆三个入口的服务端受控枚举；具体公开码与 Flutter 映射在编码前统一确认，不能直接把业务 `sceneCode` 当作 Banner 跳转码，禁止任意 URL、未知业务或后台随意拼路由。客户端点击仍走三个各自 Controller/API。两张图是初始运营目标而非表结构限制，配置需支持一张或多张；发布后至少一张有效启用图。

### 骨架阶段 / T-B007-S

在现有 Catsinger 配置和 Admin Controller 旁建立正式 DTO/VO、`SongHomeBannerService` 高层方法：`loadPublishedBanners → projectApprovedResources`、`loadAdminConfiguration`、`validateAndPublishConfiguration`。Service 的未实现步骤以 `TODO(REAL-IMPLEMENTATION)` 标记，local/test 从**集中** Skeleton Fixture 给出确定的两张图、两个目标和版本；生产默认禁用新未完成路径，不能返回假审核图/假发布成功。骨架不读写 `app_configs`、媒体库或审核服务，不建表，不调用积分/Provider。Controller 仅校验 App/Token 并调 Service，不散落固定数据。

验证 `./gradlew compileJava` 和 Controller/Service 契约测试：DTO 包络、路径与 Flutter/Admin 相同，非法 App/无权用户拒绝，生产未启用时拒绝而非 `200` 固定值。保留现有生产配置接口行为；如通用入口需加分流，骨架只留下不会影响其他键的受控分支。

### 真实实现阶段 / T-B007-R

1. 读取 Catsinger schema 的 `app_configs` 当前配置及版本；使用结构化 JSON DTO 解析，不用字符串拼接。公开查询过滤未启用、未审核、失效资源，并排序；若无可公开项给安全空态或明确配置未就绪，不向 App 泄露后台原文。
2. 发布 Service 同时校验 ID 唯一、排序、启用数、资源归属/审核通过/可访问、安全显示文字、目标白名单与 `configVersion`；在事务中整份替换并生成新版本。禁用/删除最后一张有效图、并发版本覆盖均拒绝，保留上一已发布版本。
3. 专用 Admin `PUT` 和通用配置 `PUT` 都调用同一校验/发布方法；角色块、`X-App-Code` 和资源状态在 Service/权限层再验，不能靠页面隐藏。记录操作人、App、旧/新版本及失败类别，但不记敏感媒体 URL。
4. 公共投影只返回短期安全 URL 或既有可公开资源地址；过期/审核撤销后不继续返回可点击坏内容。两张审核素材未齐时不得用设计图本地路径或任意外链代替生产发布。

## 影响文件、数据与错误

主落点 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/catsinger/config/`、现有 `admin/song/`、配置 Store/资源审核服务；实际类名在编码前以当前工程结构为准。数据：复用 `app_configs`，**无 Flyway/Entity/Repository 新增**；既有配置 Store 的 App/schema 路由必须保持。错误至少区分无权限、跨 App、无审核资源、非法目标、最后一张、版本冲突、配置读取失败；后端异常不被转换成成功空列表。

`-R` 定向验证列表排序/过滤、非法审核状态、并发最后一张与 409、通用写入口绕过、跨 App/普通角色、配置服务故障；再用 App 首页核对真实发布投影。`-S` 不自动解锁 `-R`，只有三端整体骨架审阅明确通过才能接数据库与审核链。
