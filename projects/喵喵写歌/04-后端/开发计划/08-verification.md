# Java 模块验收与第 15 步移交

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `waiting_review`。覆盖 `T-B001`～`T-B006`，依赖[模块索引](00-module-index.md)、[前端验收](../../03-前端/开发计划/08-acceptance.md)和[当前 PRD](../../01-需求/v2.1-model-driven-params/requirements.md)。

## 骨架阶段 / `T-B001-S`～`T-B006-S`

1. 核对每个模块有正式 DTO/VO、Controller → Service 高层步骤、集中 local/test Fixture、`TODO(REAL-IMPLEMENTATION)`；四场景公开路径不变，`VOICE_COVER` 与旧 `COVER` 不混淆。
2. 运行 `./gradlew compileJava` 和受影响的 Controller/Service 契约测试；只有明确配置的 local/test 环境可返回固定值，生产默认关闭，不允许已有线上写歌/改编误入骨架。
3. 使用测试替身断言所有骨架创建/查询路径不访问 Repository/Mapper、积分、审核、上传、Provider、资源转存或作品创建；错误/禁用态有稳定响应，不伪造可播放作品。
4. 三端骨架全部完成后一次性交代码地图、调用图、固定数据清单、TODO 清单与未覆盖项，更新流程为 `skeleton_review`。未经用户明确确认，**不得**开始任一 `-R` 或新增 Flyway。

## 真实实现阶段 / `T-B001-R`～`T-B006-R`

1. 受影响模块运行定向 Gradle 测试；B001/B002/B006 属公共契约，扩展四业务、Admin、旧客户端与 narrate 跨 App 回归。迁移若确有证据，检查干净 catsinger schema 与已有数据升级；不改 common/narrate。
2. 契约矩阵覆盖两个参数能力不同的精确模型：可支持项可设置，不支持项 `supported=false/editable=false` 且有原因；`NOT_DECLARED` 可选项禁用但基础操作只在有厂家可执行证据时可用。切换后清理旧无效值，服务端拒绝旧值且无冻结/厂家调用。
3. 业务矩阵分别验证 AI 写歌、旧歌曲改编、本人音色训练、翻唱声音克隆：独立业务类型/接口、精确音色兼容、素材硬限制、权利授权、价格版本、幂等、排队与接单时限、失败补偿和成品资源保存。
4. Admin 验证模型能力合法子集、角色/App 隔离、价格更新、资源审核与敏感字段脱敏。确认任务成功不是仅 HTTP 200：资源已转存、审核并能由用户设备播放。
5. 完成后将接口、测试证据、已知限制和测试数据交第 15 步 Android/iOS 用户测试；iOS 无真机可用模拟器，两者都无则 iOS 验收不通过。第 15 步关注实际移动端操作，不以 Java 测试代替。

## 完成记录模板

每个 `-S` 和 `-R` 单独记录：修改类/公开接口、执行命令和结果、失败及未测项、跨端依赖、下一恢复点。文档阶段不运行业务测试，也不把本页 `waiting_review` 记成编码完成。
