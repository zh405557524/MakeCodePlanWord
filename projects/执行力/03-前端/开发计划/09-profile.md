# 执行力 Flutter 模块开发文档 - Profile / UserProfile

> 模块编号：`M-09`  
> 对应总体任务：`F-016 ~ F-017`  
> 状态：`pending`

---

## 一、功能定位与边界

本模块由两个页面组成，职责必须拆开：

- `Profile`：个人中心摘要页
- `UserProfile`：个人信息编辑页

本模块负责：

- `Profile` Hero 卡和偏好设置区
- `UserProfile` 头像、昵称、座右铭、城市、标签、执行数据
- 保存后的本地回写与页面回显

本模块不负责：

- Plan / Now / Chat 的业务逻辑
- 远端同步成功页

---

## 二、入口、路由与页面文件

**入口**：`MainShell` 中的 Profile Tab

**路由**：

- `RouteName.profile`
- `RouteName.userProfile`

**页面文件**：

- `lib/pages/profile/view.dart`
- `lib/pages/profile/controller.dart`
- `lib/pages/profile/index.dart`
- `lib/pages/user_profile/view.dart`
- `lib/pages/user_profile/controller.dart`
- `lib/pages/user_profile/index.dart`

建议补充组件：

- `lib/pages/profile/widgets/profile_hero_card.dart`
- `lib/pages/profile/widgets/setting_selector_card.dart`
- `lib/pages/user_profile/widgets/avatar_selector_card.dart`
- `lib/pages/user_profile/widgets/profile_stats_card.dart`
- `lib/pages/user_profile/widgets/tag_selector_card.dart`

---

## 三、依赖前置

- `MainShell` 已可用
- `StorageService` 与 `Hive` 已可读写配置和资料
- `ProfileService`、`UserStore` 已可用

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`10-Profile`
- Figma：`11-UserProfile`
- `01-需求/references/images/30-主页_执行力-Profile 页.png`
- `01-需求/references/images/01-个人页面_执行力-个人信息页.png`
- `01-需求/references/images/02-个人页面_执行力-个人信息页1.png`
- `01-需求/references/images/03-个人页面_执行力-个人信息页2.png`

### 页面结构结论

- `Profile` 不是设置项堆叠页，而是“Hero + 能量 + 模式 + AI 模型 + 产品理念”的个人中心摘要页
- `UserProfile` 是独立沉浸式编辑页，隐藏底部导航
- `UserProfile` 底部必须存在固定保存栏，不能只在顶部放保存按钮
- 头像卡、资料卡、执行数据卡、标签卡是清晰分区，不可揉成一个长表单

---

## 五、涉及模块与类

| 类型 | 文件 / 类 | 说明 |
|------|-----------|------|
| 页面 | `ProfilePage` | 个人中心摘要页 |
| 控制器 | `ProfileController` | 摘要数据与偏好切换 |
| 页面 | `UserProfilePage` | 个人信息编辑页 |
| 控制器 | `UserProfileController` | 表单状态、保存、回写 |
| 服务 | `ProfileService` | 资料与偏好读写 |
| Store | `UserStore` | 个人资料状态 |

Controller 约束：

- `ProfileController` 负责读取摘要、切换能量 / 模式 / AI 模型、跳转资料页
- `UserProfileController` 负责表单值、标签选择、头像选择、保存和回写

---

## 六、业务内容与数据流

1. `Profile` 进入时从 `UserStore` 和配置存储读取摘要数据
2. 点击 Hero 或资料入口跳转 `RouteName.userProfile`
3. `UserProfile` 读取本地资料并初始化表单
4. 用户保存时先写本地：
   - `Hive` / `UserStore`
   - 配套统计数据刷新
5. 返回 `Profile` 后立即显示新资料，不依赖二次请求

`Profile` 页面承接：

- Hero 卡
- 能量选择
- 执行模式选择
- AI 模型选择
- 清空数据 / 产品理念等次级入口

`UserProfile` 页面承接：

- 头像与背景色
- 昵称、座右铭、城市
- 标签选择
- 执行数据统计卡
- 固定底部保存栏

---

## 七、实现步骤建议

1. 创建 `ProfilePage / Controller`
2. 搭 Hero 卡与设置卡结构
3. 创建 `UserProfilePage / Controller`
4. 搭头像卡、资料卡、统计卡、标签卡
5. 接入本地读取和保存
6. 接入返回后回写刷新

---

## 八、详细编码任务清单

- [ ] 创建 `pages/profile/` 三件套
- [ ] 创建 `pages/user_profile/` 三件套
- [ ] 实现 `Profile` Hero 卡
- [ ] 实现能量 / 模式 / AI 模型选择卡
- [ ] 实现 `UserProfile` 头像选择与资料表单
- [ ] 实现执行数据卡与标签卡
- [ ] 实现固定保存栏
- [ ] 实现保存后的本地回写

---

## 九、验收标准

- `Profile` 可明显识别为个人中心摘要页
- `UserProfile` 可独立完成资料编辑
- 保存后返回 `Profile` 能立即看到最新资料
- `UserProfile` 进入后隐藏底部导航
- 页面结构与 Figma 的分区卡片一致

---

## 十、编码注意事项

- 不把 `Profile` 做成普通设置列表页
- 不把 `Profile` 与 `UserProfile` 合并成一个页面
- 先本地写入，再考虑同步
