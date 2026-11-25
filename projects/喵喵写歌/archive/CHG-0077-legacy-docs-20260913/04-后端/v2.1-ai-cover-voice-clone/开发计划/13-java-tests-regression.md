# 13 Java 测试与回归

> 任务族：`T-B013`
> 骨架任务：`T-B013-S`
> 真实任务：`T-B013-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 依赖：01-12

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B013-S`
- 本阶段交付：编写 Controller/Service 契约、固定响应、调用顺序、local/test 启用和生产禁用测试；断言不触发数据库、积分、审核、存储或 Provider。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B013-R`
- 本阶段交付：补齐领域、Repository、Flyway、Provider、工作流、计费、资源、Admin 和旧业务回归测试。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

验证 V2.1 契约、领域、Provider、工作流、计费、资源、迁移和 Admin 行为，同时证明 AI 写歌、AI 改编及共享基础设施没有回归。本模块的 Mock 结果不替代真实厂家验收。

## 2. 测试层级

| 层级 | 覆盖 |
|------|------|
| DTO/Domain | 校验、枚举、状态迁移、时间和设置范围 |
| Service | owner、授权、报价、幂等、可用性、生命周期 |
| Repository | 唯一约束、自定义查询、软删除、版本和锁 |
| Controller 集成 | 请求头/Token、路径、JSON、错误码、权限 |
| Provider 契约 | 提交/查询/未知状态/错误/脱敏 |
| Workflow | 租约、重启、deadline、补偿和重复执行 |
| Flyway | common/catsinger 分层和干净库启动 |
| Admin | App 切换、权限、筛选、审计和受控资源 |

## 3. 核心正常用例

- 本人音色资料、素材审核、训练、模型/配置/试听持久化、AVAILABLE。
- 官方音色创建、训练、审核、发布。
- sourceAsset/sourceWork 两种翻唱创建。
- 厂家接单后倒计时，成品持久化/探测/审核/作品/结算。
- 作品列表、详情、播放地址、下载真实后缀和重新翻唱。

## 4. 核心异常用例

- 来源 XOR、跨用户、审核未过、质量阻断和授权缺失。
- 非会员、积分不足、报价过期、模型停用、渠道不匹配。
- 幂等并发、租约竞争、进程重启和过期 worker。
- 厂家明确失败、提交未知、查询异常和未知状态。
- URL 安全、下载失败、格式伪装、解码失败、审核拒绝。
- 结算失败、补偿重试、15/30 天生命周期。
- Admin 越权、跨 App 和 revision 冲突。

## 5. 旧业务回归

- `/api/song-generations` 请求/任务/计费。
- `/api/song-covers` 与现有 coverVoiceCode。
- 旧 ORIGINAL/COVER/INSTRUMENTAL 作品。
- 公共资源、审核、积分、模型、Admin 其他 App。

## 6. 执行命令

先按模块运行 targeted tests，再执行：

```bash
./gradlew test
./gradlew build
git diff --check
```

全量失败时记录首个根因、失败测试和同基线复现结果，不能删测试或放宽断言。

## 7. 数据与夹具

使用独立 catsinger schema、固定时钟、可控 Provider fixture 和本地资源样本。覆盖 MP3/WAV/M4A/FLAC/OGG/AAC、损坏文件、过大和时长边界。密钥和真实用户资源不进入测试仓库。

## 8. 实现步骤

1. 建立固定时钟、独立 catsinger schema、可控 Provider 和媒体边界夹具。
2. 随 01-12 模块同步补 DTO/Domain、Service、Repository、Controller、Provider 和 Workflow 测试。
3. 先运行模块定向测试，覆盖正常、校验失败、厂家失败、重试、并发和补偿。
4. 运行 Flyway、schema routing、Admin 权限和跨 App 隔离集成测试。
5. 回归 AI 写歌、AI 改编、旧作品、积分、资源和其他 App。
6. 最后执行全量 `./gradlew test`、`./gradlew build` 和 `git diff --check`，记录失败归属和基线复现。

## 9. 验收标准

- 每个核心公开接口至少正常 + 一个错误路径集成测试。
- 关键 Service 有单元测试，自定义查询有 SQL 行为验证。
- common/catsinger Flyway 和 schema routing 通过。
- 幂等、积分和补偿证明不会重复扣费/作品。
- 旧 AI 写歌和 AI 改编回归通过。

## 10. 编码注意事项

离线算道 fixture 只验证映射，不证明供应商线上契约。测试报告要区分 PASS/FAIL/BLOCKED/NOT_RUN，并保留现有工作区脏改动边界。
