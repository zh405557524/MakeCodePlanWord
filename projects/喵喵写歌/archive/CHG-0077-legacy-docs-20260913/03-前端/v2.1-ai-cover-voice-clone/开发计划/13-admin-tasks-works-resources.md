# 13 Admin 任务、作品、资源与审计

> 任务族：`T-W006`、`T-W007`
> 骨架任务：`T-W006-S`、`T-W007-S`
> 真实任务：`T-W006-R`、`T-W007-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`deferred`
> 状态：`deferred`
> 后台需求：W01、W08-W12

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-W006-S`、`T-W007-S`
- 本阶段交付：规划任务、作品、资源和审计后台骨架，但本轮 `skeletonTargets` 不含 Web/Admin，状态保持 `deferred`。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-W006-R`、`T-W007-R`
- 本阶段交付：后续单独获准后接入真实任务操作、作品筛选、资源预览和生命周期管理。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

扩展现有 AI 运维、歌曲作品、资源和审计页面，使运营能定位声音训练与翻唱声音克隆的执行、持久化、审核、计费和生命周期问题。不得提供取消或强制成功。

## 2. 任务管理

在现有 AI Operations 增加：

- businessType：VOICE_TRAINING、VOICE_COVER。
- 平台任务/工作流/步骤、用户脱敏标识。
- provider/model/modelOption/pricingVersion 和厂家任务 ID。
- 音色资料/模型/绑定 ID。
- queueEnteredAt/providerAcceptedAt/deadlineAt/completedAt。
- 输入审核、输出持久化、探测、审核、积分状态和错误。

详情动作仅包括允许的审核重试、资源保存重试、结算补偿观察或渠道恢复跳转。SUBMIT_UNKNOWN 必须醒目标识。

## 3. 作品管理

现有歌曲作品页增加 `songType=VOICE_COVER` 筛选及音色摘要、源作品/asset、真实格式、展示/清理时间、积分。隐藏/恢复沿用现有动作和二次确认；不因音色不可用自动隐藏历史作品。

## 4. 资源管理

分类训练素材、模型文件、配置文件、试听、翻唱源歌曲、翻唱成品。列表展示存储目标、技术状态、真实 MIME/后缀/大小/时长、审核状态、访问范围和保留时间。

预览必须换取受控 URL；下载/删除/重试权限独立。资源删除冲突应显示业务引用，不级联误删作品或音色。

## 5. 审计与权限

- 记录操作人、AppCode、业务类型、对象、原因、前后版本和时间。
- 权限最小拆分为 read/operate/publish/recover/manual-review。
- 无权限按钮隐藏且接口调用被后端拒绝。
- 所有高风险动作二次确认，失败后列表回读服务端状态。

## 6. 影响文件

- `lib/pages/common/ai_operations_page.dart`
- `lib/pages/common/resources_page.dart`
- 当前作品管理页与审计入口
- `lib/data/admin_repository.dart`
- `lib/models/song_voice_cover_admin.dart`

## 7. 实现步骤

1. 扩展筛选与列表模型，保持旧 businessType 兼容。
2. 增加训练/翻唱详情区块和时间语义。
3. 扩展作品 VOICE_COVER 筛选与生命周期展示。
4. 扩展资源分类、受控预览和业务引用冲突。
5. 接入权限、二次确认、审计和刷新。

## 8. 定向测试

- 两类任务各状态筛选、分页、详情和错误码。
- 平台排队无 deadline，厂家接单后时间字段正确展示。
- SUBMIT_UNKNOWN、持久化失败、审核拒绝、结算补偿可定位。
- VOICE_COVER 作品隐藏/恢复及 15/30 天展示。
- 资源换签、过期、删除冲突、跨 App 和无权限访问。
- 操作后审计记录可检索。

## 9. 验收标准

- W08-W12 能在现有管理体系内闭环定位问题。
- 运营看得到真实 provider/model，不把业务类型当模型。
- 不提供厂家任务状态修改、取消或强制作品成功。
- catsinger 数据不会在其他 App 上下文出现。

## 10. 编码注意事项

任务、作品和资源是不同事实，页面不得用一个状态覆盖另一个。厂家成功但平台未持久化/审核/播放的任务仍不能展示为完整成功。
