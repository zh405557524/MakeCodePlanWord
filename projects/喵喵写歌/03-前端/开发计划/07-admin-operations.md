# W002 后台价格、音色、任务与 App 隔离

> `v2.1-model-driven-params` · CHG-0076 · 第 11 步 · 文档 `waiting_review`；`T-W002-S/R` 均 `pending`。覆盖同一[PRD P14 的 W01/W03～W07](../../01-需求/v2.1-model-driven-params/requirements.md)，依赖[W001](06-admin-capabilities.md)、[Java B006](../../04-后端/开发计划/06-pricing-snapshot.md)。

## 骨架阶段 / `T-W002-S`

- **入口/页面**：现有 Admin App 选择器、`SongConfigPage`、模型/价格、官方音色、任务、资源审核、作品管理；只在当前 Catsinger 视图加四场景过滤与缺失状态，不另建平行后台。路由与管理块菜单沿工程现状，不在本版新建一套管理权限页。
- **数据流**：App 选择 → `AdminRepository` 按当前 `X-App-Code` 重新取模型、价格、音色、任务、资源、作品 → Widget 展示；切 App 时先处理未保存草稿，再清除旧列表/编辑对象，不能仅更换标题。Admin 资料来自 Java local/test Fixture；页面不得写死价格/训练音色。
- **视觉状态**：无新后台设计稿，沿现有表格/筛选/详情/危险操作确认。各视图覆盖加载、空、错误、403、禁用模型、缺价、官方音色下架、任务失败、资源审核未过和作品资源失效。`TODO(REAL-IMPLEMENTATION)` 对应 W002-R。
- **安全/完成**：骨架固定保存/审核响应只允许 local/test，生产不能伪造配置成功；不真实发布音色、不扣费、不操作用户资源。Admin `flutter analyze` 与切 App、未保存草稿、403、四场景筛选定向测试通过。

## 真实实现阶段 / `T-W002-R`

1. W01：服务端提供全部 appCode，超级管理员分配管理块、普通角色只访问授权内容；App 切换后列表/表单/价格缓存按 App 隔离，未保存草稿需确认。
2. W03：写歌、改编、本人音色训练、声音克隆翻唱各自价格与模型默认，保存当前版本，缺价时 App 显示暂未开放；修改只影响新任务。Web 只显示服务端报价，不在浏览器算冻结积分。
3. W04：官方音色名称、头像、分组和排序由后台维护，试听音频沿现有受控资源/厂家能力；审核/兼容/启用状态真实反映。下架后新任务不能选，历史作品不改。
4. W05/W06/W07：现有任务、资源审核和作品视图增加当前业务/模型过滤与错误详情；不改旧改编 `COVER` 历史类型。资源审核拒绝时不能公开/送厂家；隐藏/删除等危险操作须授权与二次确认并留审计。
5. 验收：catsinger 下配置启用/禁用、缺价、音色下架，App 实际刷新；narrate 等其他 App 切换不串，越权直连被服务端 403 拒绝；旧改编任务与作品筛选仍正确。外部支付/真实审核验收归第 15 步，不把 Web 按钮响应视为业务通过。

**代码边界**：优先复用 `lib/pages/common/ai_model_options_page.dart`、`lib/pages/app/catsinger/song_config_page.dart`、`lib/data/admin_repository.dart`、`lib/core/api_client.dart`。若现有 W04～W07 页面尚无独立组件，先对账现有菜单/接口归属，再在相应页做最小扩展；不凭本计划发明未确认 URL。
