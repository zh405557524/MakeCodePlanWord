# Admin App 切换模块开发文档

> 关联任务：T-A001  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

后台全局支持切换 App，并按 selectedAppCode 展示对应数据。

- 包含：读取 App 列表、保存当前 App、请求头携带 selectedAppCode、切换后刷新页面数据。
- 不包含：角色权限配置、具体歌曲业务表单。

## 2. 入口、路由与页面文件

| 类型 | 建议文件 |
|------|----------|
| Shell | `lib/pages/shell/` 或现有后台壳层 |
| Repository | `lib/data/admin_repository.dart` |
| Model | `lib/models/admin_app.dart` |
| Core | `lib/core/api_client.dart` |

## 3. 依赖前置

- 后端 T-B009：`GET /api/admin/apps`。
- 后台登录态可用。

## 4. 视觉参考与设计稿分析

后台没有截图参考，沿用现有 `lxwx_admin` 的侧边栏/顶部栏风格。App 选择器应放在顶部或侧栏显眼但不干扰操作的位置。

## 5. 涉及模块与类

| 类 | 职责 |
|----|------|
| `AdminRepository` | 获取 appCodes、保存 selectedAppCode |
| `ApiClient` | 请求头写入 `X-App-Code` |
| `ShellPage` | 展示 App 切换器并触发刷新 |

## 6. 业务内容与数据流

1. 后台启动后调用 `/api/admin/apps`。
2. 默认选择服务端返回的第一个或上次选择的 App。
3. 所有歌曲后台接口请求携带 selectedAppCode。
4. 切换 App 后当前页面重新拉取数据。

## 7. 现有工程参考点

复用现有后台 Shell、Repository、Dio ApiClient 和页面刷新模式。

## 8. 建议实现步骤

1. 新增 App model。
2. 扩展 ApiClient selectedAppCode。
3. Shell 增加 App 选择器。
4. 切换时广播刷新事件。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A001-01 App 列表模型 | pending |
| T-A001-02 ApiClient 请求头 | pending |
| T-A001-03 Shell 选择器 | pending |
| T-A001-04 页面刷新联动 | pending |

## 10. 验收标准

- [ ] App 列表从服务端读取。
- [ ] 可切换到 `catsinger`。
- [ ] 切换后模型/情景/示例等页面数据刷新。

## 11. 编码注意事项

- 不在前端写死 appCode 列表。
- `/api/admin/apps` 本身不依赖 selectedAppCode。
- 切换 App 时要清理旧页面筛选条件或提示用户。
