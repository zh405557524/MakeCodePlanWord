# 执行力 Flutter 模块开发文档 - Profile / UserProfile

> 模块编号：`M-09`
> 对应总体任务：`F-016 ~ F-017`
> 状态：`done`
> 当前策略：以现有摘要页 + 编辑页结构为准；v2 中从 ChatHome 侧边菜单进入

---

## 一、模块定位

本模块由两个页面组成，职责必须分开：

- `Profile`：个人中心摘要页
- `UserProfile`：个人信息编辑页

v2 中，`Profile` 不再作为底部 Tab 一级入口，而是从 `ChatHome` 侧边菜单进入的设置 / 资料能力页。

本模块负责：

- `Profile` 的 Hero、统计、偏好展示
- `UserProfile` 的资料编辑和保存回写
- 保存后的本地回显

本模块不负责：

- Plan / Now / Chat 的业务逻辑
- 真实后端资料同步

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/pages/profile/index.dart`
- `lib/pages/profile/controller.dart`
- `lib/pages/profile/view.dart`
- `lib/pages/user_profile/index.dart`
- `lib/pages/user_profile/controller.dart`
- `lib/pages/user_profile/view.dart`

依赖关系：

- `ProfileService`
- `UserStore`
- `PlanStore`
- `SyncStore`

说明：

- 当前 `Profile` 和 `UserProfile` 的 UI 大部分集中在各自 `view.dart` 中。
- 目前没有额外拆出 `widgets/` 子目录。

---

## 三、当前实现判断

当前结构虽然没有继续拆 `widgets/`，但这本身不构成错误。
按这次“在原代码上重构”的原则：

- 如果当前 `view.dart` 仍然可维护，就保留现状
- 只有在复杂度已经明显影响维护时，才继续局部拆组件

当前真正需要关注的是：

- `Profile -> UserProfile -> Profile` 的回写链路是否稳定
- `ChatHome -> SideMenu -> Profile` 的入口是否稳定
- 保存中状态、异常态是否完整
- `UserProfile` 的固定保存栏和资料层级是否贴近 Figma

---

## 四、本轮改造边界

只修改以下问题：

1. `Profile` 与 `UserProfile` 边界混乱
2. 保存后资料没有正确回写
3. 资料表单状态不完整
4. 页面层级、固定保存栏、沉浸式结构与 Figma 偏差明显
5. v2 中仍把 Profile 暴露为底部 Tab 一级入口

本轮不做：

- 没有必要时强行拆 `widgets/`
- 只为“看起来更规范”而重写整页结构

---

## 五、验收标准

- `Profile` 作为摘要页存在
- 可从 `ChatHome` 侧边菜单进入 `Profile`
- `UserProfile` 作为沉浸式编辑页存在
- 修改资料后可回到 `Profile` 正常回显
- 固定保存栏、头像、昵称、标签和统计信息层级正确

---

## 六、视觉参考

- Figma：`10-Profile`
- Figma：`11-UserProfile`
- `01-需求/references/images/30-主页_执行力-Profile 页.png`
- `01-需求/references/images/01-个人页面_执行力-个人信息页.png`
- `01-需求/references/images/02-个人页面_执行力-个人信息页1.png`
- `01-需求/references/images/03-个人页面_执行力-个人信息页2.png`
