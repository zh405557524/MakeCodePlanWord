# Admin 验收模块开发文档

> 关联任务：T-A009  
> 工程：`/Users/soul/code/lxwx/lxwx_admin`  
> 状态：waiting_review

## 1. 功能定位与边界

验证 Web/Admin 新增页面、权限、App 切换和旧后台页面回归。

- 包含：静态检查、Mock 数据、页面操作验收、权限验收。
- 不包含：后端集成测试和 App 真机测试。

## 2. 入口、路由与页面文件

覆盖所有 `song_admin` 新增页面和后台 Shell。

## 3. 依赖前置

- T-A001 到 T-A008。
- 后端 Admin API 可用或 Mock 可用。

## 4. 视觉参考与设计稿分析

后台无截图参考，以现有 `lxwx_admin` 风格一致性为验收标准。

## 5. 涉及模块与类

- `AdminRepository`
- `ApiClient`
- `ShellPage`
- 所有 Song Admin 页面

## 6. 业务内容与数据流

验证流程：

1. 登录后台。
2. 切换到 catsinger。
3. 配置模型、情景、示例。
4. 查看任务、作品、专辑。
5. 配置权限并验证导航过滤。

## 7. 现有工程参考点

沿用现有 Web 构建和 analyze 流程。

## 8. 建议实现步骤

1. 跑 `dart format`。
2. 跑 `flutter analyze`。
3. 验证每个页面 loading/empty/error。
4. 验证权限。
5. 验证旧页面可用。

## 9. 详细编码任务清单

| 子任务 | 状态 |
|--------|------|
| T-A009-01 静态检查 | pending |
| T-A009-02 Mock 数据 | pending |
| T-A009-03 页面操作验收 | pending |
| T-A009-04 权限验收 | pending |
| T-A009-05 旧页面回归 | pending |

## 10. 验收标准

- [ ] `flutter analyze` 无新增错误。
- [ ] App 切换后页面刷新。
- [ ] 非授权角色看不到无权限模块。
- [ ] 旧后台页面不受影响。

## 11. 编码注意事项

- Demo 数据只用于开发模式。
- 失败提示要保留用户已输入表单。
