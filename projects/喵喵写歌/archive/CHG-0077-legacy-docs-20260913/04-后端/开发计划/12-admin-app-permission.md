# 12 Admin App 与权限模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B012
> 状态：done

## 功能定位

后台可以切换服务端全部 appCode，并由超级管理员给不同角色分配管理块。

## 接口契约

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/apps` | 返回服务端全部 appCode 配置 |
| GET | `/api/admin/roles` | 角色列表 |
| POST | `/api/admin/roles/{id}/permissions` | 分配管理块权限 |

## 权限规则

- 超级管理员拥有所有管理块。
- 普通角色只能访问授权模块。
- 前端隐藏导航只是体验，后端必须二次校验。
- 操作记录写 `catsinger_song_operation_logs` 或公共审计日志。

## 实现步骤

1. `AdminAppController` 从 `AppSchemaRoutingProperties` 读取 appCodes。
2. 建立 `admin_role_permission` 表或复用现有角色权限结构。
3. Admin 接口增加模块权限校验。
4. 权限失败返回 `ADMIN_PERMISSION_DENIED`。

## 测试要求

- 超管可访问所有模块。
- 普通角色未授权访问被拒绝。
- App 切换后 schema 上下文正确。

## 验收标准

Web/Admin 可切 App，权限块可配置且后端强校验。
