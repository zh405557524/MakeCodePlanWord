# W001 后台模型能力与合法收窄

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `waiting_review`；`T-W001-S/R` 均 `pending`。依据[PRD P14/W02](../../01-需求/v2.1-model-driven-params/requirements.md)、[前端技术文档](../flutter-tech.md)、[Java B002](../../04-后端/开发计划/02-effective-contract.md)及[后台安全模块](../../04-后端/开发计划/07-admin-and-security.md)。

## 骨架阶段 / `T-W001-S`

- **入口**：`/Users/soul/code/lxwx/lxwx_admin` 现有模型/场景管理菜单，优先扩展 `lib/pages/common/ai_model_options_page.dart`，相关 Catsinger 设置在 `lib/pages/app/catsinger/song_config_page.dart`；无新后台 Figma，沿用现有密集表格、筛选和编辑弹层。
- **文件/依赖**：`lib/models/` 添加目标能力只读解析；`lib/data/admin_repository.dart` 调用 `lib/core/api_client.dart`，沿现有 `/api/admin/ai-scene-model-mappings` 及模型目录入口。Widget 不手写 HTTP、不直接操纵 `metadataJson` 原始字符串；后台权限和 App 切换沿现有框架。
- **页面结构**：按 App→业务场景→真实 `provider/model` 选择；左/上显示厂家原始硬能力只读（状态、选项、范围、原因），右/下在其交集内编辑显示/启用/默认/范围。未知、下架、越界行保持可见灰态；操作给原因。保存按钮仅本地草稿合法且版本一致才可用。
- **调用链**：后台模型目录 → 厂家声明 + 有效契约 → 编辑受限子集 → 现有 Admin Repository 保存方法 → 刷新列表。骨架固定目录由 Java local/test Fixture 提供，保存只返回受控固定状态，不写真实配置。`TODO(REAL-IMPLEMENTATION)` 对应 W001-R。
- **完成**：加载/空/失败/403/版本冲突和未保存草稿状态均可走，禁止项可点原因不可勾启用；Admin `flutter analyze` 与定向 Widget/Repository 测试通过；生产不返回假保存成功。

## 真实实现阶段 / `T-W001-R`

1. 真实读取厂家能力只读视图和后台当前收窄值；`NOT_DECLARED` 或厂家不支持项不允许发布启用。后台只能在厂家枚举/数值上下限内收窄，默认值必须落在交集；表单校验只为体验，Java B002/B006 必须再验。
2. 保存携带当前能力版本；后台能力缩小时显示冲突并保留草稿，要求重新加载/确认。不得让旧页面把 `metadataJson` 中图标、排序等非能力字段清空；非 Catsinger App 不显示 Catsinger 专属可编辑设置。
3. 切 App 时清空旧 App 模型、选中项和编辑上下文；有未保存草稿先确认。服务端 403 明确展示权限问题，不当 401 登录失效；后台管理块权限由服务端定。
4. 验证两种算道精确模型不同参数、未知能力、范围收窄、过期版本、权限绕过、跨 App 保存拒绝、刷新后 App 控件状态同步。无来源厂家上限的值不能通过后台任意填大。

**验收边界**：W01 角色分配页本轮不重做；本模块只扩展模型能力配置。任何新增 Admin 接口或公开字段先回卷 Java 技术文档与 B002 模块，不凭 Web 前端结构猜厂家能力。
