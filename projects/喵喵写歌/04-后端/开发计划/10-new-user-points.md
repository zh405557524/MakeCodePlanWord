# CHG-0078 / T-B008 Catsinger 新账号赠额配置

> 2026-09-14 执行覆盖：`T-B008-R=in_progress`。现有建号赠点链读取 Catsinger 配置，缺失/坏值回退 30，保留 `NEW_USER:{userId}` 幂等；定向测试通过。实际注册和并发/数据库故障需联调；下方 `-S`/骨架门禁为授权前历史。

> `v2.1-model-driven-params` · 第 12 步模块文档已确认 · `T-B008-S=waiting_review`、`T-B008-R=pending` · 2026-09-14

> 骨架记录：Admin `GET/PUT new-user-points` 与正整数校验、固定 30 响应可调用，定向 Gradle 测试通过；未触碰现有 `UserService` 建号、积分流水或真实配置。后续 `-R` 需核实配置失效回退、DB 故障透传、历史账号不补发。
> 输入：[PRD W09/H-01/H-03/H-04](../../01-需求/requirements.md)、[Java 技术文档第 9 节](../java-tech.md)、[总体计划第 9 节](../java-dev-plan.md)、[Admin W004](../../03-前端/开发计划/12-admin-new-user-benefits.md)。

## 现有链路和目标

当前 `UserService.createUser → grantDefaultPointsForNewUser → PointsService.grantPermanent` 在建号后赠默认 30，流水幂等键为 `NEW_USER:{userId}`。游客绑定同一账号不是再建一个人，历史流水不重发。本模块只把**Catsinger 建号时使用的金额**改成读后端配置；不新造“领取新人礼赠积分”的第二条业务链，不修改其他 App 的默认赠额，也不回填历史账户。

配置键 `song.new_user_points` 存在 Catsinger 的既有 `app_configs`；初始值和**仅配置缺失/禁用/非法**时的兜底均为 30。具体生效点是新用户记录建立且即将发放新用户积分时读取当前有效值；管理员后来改成 100/200 只影响后来建号的账号。DB 不可用、积分服务报错/事务失败不能伪装成配置坏值而安静赠 30。

| 接口/调用 | 业务字段 | 结果 |
|-----------|----------|------|
| `GET /api/admin/song/new-user-points` | `points,configVersion,source`（有效/兜底说明） | Admin 显示当前新账号赠额与配置状态 |
| `PUT /api/admin/song/new-user-points` | 正整数 `points`、所见 `configVersion` | 校验后写 Catsinger 配置并返回新版本 |
| 通用 `PUT /api/admin/configs/{configKey}` | `configKey=song.new_user_points` | 与专用入口同校验；不能绕过正数或权限 |
| 现有建号路径 | `appCode,userId,NEW_USER:{userId}` | 只在 Catsinger 分支取新配置值并调用原积分发放一次 |

### 骨架阶段 / T-B008-S

在现有 Admin Song Controller/Service 建正式读取与保存 DTO、配置读取/有效值计算的高层方法，如 `loadNewUserPointsConfig → validatePositivePoints → resolveEffectivePoints`。local/test 集中 Fixture 固定展示 30 与配置版本；`TODO(REAL-IMPLEMENTATION)` 对应真实 Store 读取、发布及建号挂接。**不改现有 `UserService.createUser` 的生产发放逻辑，不调用真实 `PointsService`，不读写 DB**。生产默认拒绝未完成的专用配置路径，旧建号逻辑仍正常工作。`./gradlew compileJava`、Controller/Service 路径/值/拒绝测试可证明骨架只返回受控假值。

### 真实实现阶段 / T-B008-R

1. Catsinger 通过已有 AppContext/schema routing 读取 `song.new_user_points`；结构化校验为正整数并满足后端金额上限。配置缺失、禁用、空或非法内容回退 30 并发诊断日志/管理告警；读取 DB 失败明确失败，不落进非法值兜底。
2. 在**原**建号成功后的发放位置注入有效金额，保持原 `PointsService.grantPermanent` 与 `NEW_USER:{userId}` 幂等。必要时在建号事务/重试窗口核对原发放语义，避免因配置切换产生一次账号两种金额；不改积分流水的业务类型或旧历史记录。
3. 专用 Admin `PUT` 和通用配置写入口共同走正数、版本、`song_config` 角色、Catsinger App 校验；并发版本冲突拒绝，审计管理员与生效版本。`narrate` 及其他 App 沿旧规则，不读取 Catsinger key。
4. 游客绑定、同手机号重试、登录恢复和旧账户只返回已有账户，不再次发 `NEW_USER`。新账户在配置 100/200 后实际流水与余额匹配，已经发过 30 的历史用户不补差。

## 数据、影响文件与验收

主落点 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/core/user/service/UserService.java` 的 Catsinger 分支、现有 Admin Song 配置 Controller、AppConfig Store 和定向测试。配置复用 `app_configs`，积分复用现有账户/流水；**无新迁移或表**。不可因本模块改 common V1/V12。

`-R` 测试有效 100/200、配置缺失/空/非法回退 30、DB 故障与积分失败不回退、`NEW_USER:{userId}` 幂等、游客绑定/历史不补发、narrate 不受影响、Admin 权限与冲突。再由 Android/iOS 新建账号观察余额、服务端流水双证据验收；只有 API `200` 不算赠额成功。骨架评审批准前不得进入真实发积分改动。
