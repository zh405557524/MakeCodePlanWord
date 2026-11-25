# 11 Admin 导航、App、模型与价格

> 任务族：`T-W001`、`T-W002`
> 骨架任务：`T-W001-S`、`T-W002-S`
> 真实任务：`T-W001-R`、`T-W002-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`deferred`
> 状态：`deferred`
> 后台需求：W01-W03、W11

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-W001-S`、`T-W002-S`
- 本阶段交付：规划 Admin 导航、App 切换、模型和价格骨架，但本轮 `skeletonTargets` 不含 Web/Admin，状态保持 `deferred`。
- 固定响应只允许来自 Java local/test 集中 Skeleton Fixture；View 与 Controller 不得散落假数据。
- 不执行真实上传、录音、审核、积分、Provider、任务轮询、资源转存、作品创建或删除等副作用。
- 未实现真实步骤统一标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-W001-R`、`T-W002-R`
- 本阶段交付：后续单独获准后接入真实权限、模型映射、价格和配置保存。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；在骨架评审通过前，只能执行本节明确列出的骨架范围。

## 1. 功能定位与边界

在现有 Flutter Web/Admin 中为 catsinger 增加翻唱声音克隆管理入口，并复用当前模型、场景映射、模型选项、计费和角色框架。不得创建第二套 AI 配置中心。

## 2. 影响文件

- `lib/pages/shell_page.dart`：catsinger 菜单和权限门禁。
- `lib/data/admin_repository.dart`：App 切换、声音克隆配置加载和状态清理。
- `lib/pages/common/ai_model_options_page.dart`：两个新 sceneCode。
- `lib/pages/common/ai_billing_page.dart`、`ai_model_price_dialog.dart`：训练/翻唱独立价格。
- `lib/pages/app/catsinger/song_config_page.dart`：声音克隆快捷入口。
- `lib/models/admin_models.dart` 或独立 `song_voice_cover_admin.dart`。

## 3. App 切换规则

- App 列表读取服务端全部 appCode；只有 catsinger 显示声音克隆专属管理块。
- 切换 App 时清空上一 App 的列表、分页、筛选、选择和表单草稿。
- 每个请求记录发起 appCode，响应回来时若已切换则丢弃。
- 手工构造路由仍由后端权限和 schema routing 拒绝，前端隐藏不是安全边界。

## 4. 模型与价格

新增场景：

- `song.voice.train`
- `song.voice.cover.generate`

运营选择真实 providerCode/modelCode，配置展示名、能力限制、启用状态、默认项、容量和价格。页面分栏显示业务场景与厂家模型，避免把 `VOICE_COVER` 填入 model。

训练、翻唱价格分别维护，初始建议 100/200 积分；实际显示后端当前价格和 pricingVersion。价格更新要有原因、二次确认、成功刷新和审计记录。

## 5. 页面状态与权限

- loading/empty/error/retry/paged content 完整。
- 无 `song.voice.*` 读取权限不显示入口；无写权限表单只读。
- 停用模型只影响新任务，运行中任务仍显示冻结快照。
- 删除被引用配置不得乐观成功；展示后端冲突原因。

## 6. 实现步骤

1. 对账现有 Shell 和角色权限注册方式，增加最小权限点。
2. 扩展 Repository 的 catsinger 声音克隆状态并实现 App 切换清理。
3. 在模型/场景/选项页支持两个新场景和真实模型能力过滤。
4. 在计费页增加训练/翻唱独立条目、版本和变更确认。
5. 增加总览快捷筛选，跳转到现有 AI Operations。

## 7. 定向测试

- 服务端 App 列表新增/减少时前端无需发布即可切换。
- catsinger 显示入口，narrate/catseller 等不显示且无法越权调用。
- 快速切 App 时旧响应不污染当前页。
- 真实 provider/model、场景和价格的新增、编辑、停用、冲突。
- 不同角色的读取/编辑/发布按钮状态。

## 8. 验收标准

- W01-W03 可通过现有后台体系完成，不出现平行配置页。
- 前台模型和报价可追溯到后台同一 modelOption/pricingVersion。
- 配置未完成时 App 显示暂未开放，不使用前端默认价格。
- 所有写操作有成功刷新、失败保留输入和审计入口。

## 9. 编码注意事项

不得在 Admin 前端写死完整 AppCode 列表、算道模型编码或默认价格。现有 AI 改编场景 `song.cover.generate` 和其模型过滤规则不得被新场景替换。
