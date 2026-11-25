# CHG-0078 / T-B009 新人礼资格与频次

> 2026-09-14 执行覆盖：`T-B009-R=in_progress`。已接真实资格/曝光/领取服务及 Catsinger-only V4.10 状态表，单元、schema 与正式 Controller 映射测试通过；目标数据库尚未迁移，跨天/多设备及真实领取未验。下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 12 步模块文档已确认 · `T-B009-S=waiting_review`、`T-B009-R=pending` · 2026-09-14

> 骨架记录：查询、曝光、稍后、领取四条正式路径和 Admin `GET/PUT new-user-gift` 已接调用链；Fixture 可演示展示/隐藏及领取结果，未实际记录资格、曝光或积分。定向 Gradle 测试通过；频次/账号起点/幂等/资源审核和 Catsinger 专属最小迁移都留 `-R`，目前禁止生产开启。
> 输入：[PRD P01/W09](../../01-需求/requirements.md)、[Java 技术文档第 9 节](../java-tech.md)、[总体计划第 9 节](../java-dev-plan.md)、[Flutter F007](../../03-前端/开发计划/10-new-user-gift.md)、[Admin W004](../../03-前端/开发计划/12-admin-new-user-benefits.md)。

## 业务边界、接口与状态

新人礼是**首页弹窗资格和跳转**，不承担注册赠额；点击“领取”只永久结束该弹窗资格并返回受控任务/签到目标，不能再调用积分赠送。仅 Catsinger 符合固定上线资格起点之后创建、尚未领取且满足后台人群的新账号可见。身份以已登录 `userId` 为准；同账号跨设备共用资格，不另建设备身份逻辑。后台配置 `song.new_user_gift` 复用 `app_configs`，管理 `enabled/imageResourceId/textResourceId?/frequency/audience/targetCode/eligibilityStartAt/configVersion` 等正式字段；资源发布须过既有安全审核。`ONCE/DAILY/PER_OPEN` 只对**点击领取前**生效，“稍后领取”撤销本次曝光，后续可再次符合资格。

| 用户接口 | 请求/响应 | 原子处理意图 |
|----------|-----------|--------------|
| `GET /api/song-config/new-user-gift` | 可选 `openId`；`shouldShow,impressionToken?,imageUrl?,text?,targetCode?,configVersion?` | 账户、人群、起点、频次、配置/素材和未领取共同判定，未实际渲染不记展示 |
| `POST .../impressions` | `{impressionToken,openId?}` | 实际渲染后令牌确认；同令牌幂等，只计一次 |
| `POST .../dismiss` | `{impressionToken}` | 仅撤销该令牌本次展示，领取资格不结束 |
| `POST .../claim` | `{impressionToken}`；`claimed,targetCode?` | 同账号原子标已领；重复请求返回同一终态，不二次跳/加积分 |
| `GET/PUT /api/admin/song/new-user-gift` | 配置 DTO 与版本 | 角色、Catsinger、审核素材、人群/频次/目标和起点校验 |

### 骨架阶段 / T-B009-S

建立正式 DTO/VO、用户端和 Admin 端 Controller、Service 高层调用：`loadConfig → checkAccountEligibility → checkFrequency → issueImpressionToken`、`confirmImpression`、`dismissImpression`、`claimGift`。集中 Skeleton Fixture 给 local/test 确定的应弹/不弹/已领及目标响应，固定演示 `userId` 不从真实账号信息编造；生产默认关闭未完成功能，现有首页/任务中心继续可用。每个真实动作标 `TODO(REAL-IMPLEMENTATION)` 映射 `-R`。**不创建 Flyway/Entity/Mapper，不真实写资格、配置、积分或审核资源，也不对厂家发请求**。`./gradlew compileJava`、鉴权/包络/令牌 DTO 契约和生产拒绝固定成功测试通过后记 `-S`。

### 真实实现阶段 / T-B009-R

1. 先核对当前 Catsinger 专属 Flyway 最高版本和表命名，再**追加**最小资格状态表；建议 `user_id BIGINT UNIQUE`、`claimed_at`、`last_impression_token_hash`、`impression_at`、`impression_day`、`last_open_id_hash`、`impression_config_version`、`impression_active` 及必要创建/更新时间，最终字段按事务和现有主键风格收敛。只在 `db/migration/catsinger/` 新增，不改 V1/V12、common/narrate。用户创建时间沿现有账户字段与**不可回退的资格起点**比较，后台后改配置不得使旧用户变新人。
2. `GET` 只判资格并签发短期、绑定 `userId/appCode/configVersion` 的不透明令牌；查询本身不记曝光。未登录、已领、人群不匹配、配置关闭、素材未审/失效返回 `shouldShow=false` 或明确不可用态，不泄露内部路径。 `DAILY` 用 `Asia/Shanghai` 自然日，`PER_OPEN` 用前端一次冷启动稳定 `openId` 去重；服务端控制令牌有效期。
3. `impressions` 在行锁/唯一约束下确认实际展示，同令牌重试不重复计数；`dismiss` 仅对**当前令牌**撤销已确认展示，旧令牌不能撤销新曝光；同次页面会话的立即重弹由前端临时抑制。`ONCE`/每日/每次打开的计数都从确认且未撤销的记录计算，不能仅凭 GET 次数。
4. `claim` 在账号和资格行事务中检查令牌、配置/人群、是否已领，首次写 `claimed_at`；重复同令牌/双设备竞争返回稳定已领终态，非法或过期令牌给可恢复错误。**不执行 `grantPermanent`、不产生 `NEW_USER` 或任务积分流水**。任务中心目标由白名单返回，领后永久不弹；后台重新启用也不重置。
5. Admin 专用和通用配置写入口共用校验与乐观版本发布；资源审核、目标白名单、`song_config` 管理块、Catsinger schema、操作审计在服务端强制执行。关闭只影响未来查询，不物理删资格行。

## 错误、影响文件与验收

落点为 Catsinger config/controller/service、Admin Song Controller、当前账户查询与资源审核接口、仅真实阶段的 catsinger 迁移/Entity/Mapper。状态并发/时区规则属于 Service/存储层，Controller 不计算资格。区分未登录、无权、历史账户、已领、未曝光、令牌失效、冲突、配置读取错误与真实数据库故障；服务故障不能伪装为“用户已领取”。

`-R` 定向测试：初次/稍后/再次符合、ONCE/DAILY/PER_OPEN、上海日界、会员筛选、资格起点、配置更新后历史账号、同令牌并发和双设备、旧令牌撤销新令牌、审核素材撤销、越权/跨 App、生产错误态。移动端还要真实展示、关闭、领取并核对资格行和**无额外积分流水**。仅整体三端骨架获明确确认后做迁移与真实状态写入。
