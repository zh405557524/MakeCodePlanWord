# 执行力 Flutter 模块开发文档 - Notes

> 模块编号：`M-11`
> 对应总体任务：`F-012A ~ F-012C`
> 状态：`done`
> 当前策略：Notes 三层链路已落地，v2 中从 ChatHome 的工具菜单或侧边菜单进入

---

## 一、模块定位

Notes 模块负责把笔记能力作为当前版本正式功能落地。v2 中它不再是底部 Tab 一级入口，而是从 `ChatHome` 派生进入的二级能力。

本模块负责：

- `Notes` 入口页
- `NoteFolder` 子文件夹页
- `NoteFile` 文件页
- 文件夹与文件的本地结构管理
- 文档 / Markdown 编辑与预览切换

本模块不负责：

- 笔记生成计划
- 计划与笔记的深度互链
- 复杂知识库或块编辑器

---

## 二、当前代码落点

当前真实代码文件如下：

- `lib/models/note.dart`
- `lib/store/notes.dart`
- `lib/services/notes_service.dart`
- `lib/pages/notes/index.dart`
- `lib/pages/notes/controller.dart`
- `lib/pages/notes/view.dart`
- `lib/pages/notes/widgets/note_create_actions.dart`
- `lib/pages/notes/widgets/note_empty_state.dart`
- `lib/pages/notes/widgets/note_entry_card.dart`
- `lib/pages/note_folder/index.dart`
- `lib/pages/note_folder/controller.dart`
- `lib/pages/note_folder/view.dart`
- `lib/pages/note_file/index.dart`
- `lib/pages/note_file/controller.dart`
- `lib/pages/note_file/view.dart`

路由：

- `RouteName.notes`
- `RouteName.noteFolder`
- `RouteName.noteFile`

---

## 三、当前实现判断

当前 Notes 模块已经完成核心闭环：

- 路由可进入 `Notes`
- 支持根目录和子文件夹浏览
- 支持创建文件夹、子文件夹和笔记
- `NoteFile` 支持编辑 / 预览切换
- 本地 `Hive` 存储与模式偏好已接入
- v2 中需要从 `ChatHome -> ToolMenu / SideMenu` 到达

因此 Notes 模块当前不是待开发状态，而是已完成状态。
后续如果有修改，重点应放在：

- 空状态、异常态、同步态补齐
- Figma 细节对稿
- 后续真实接口对接预留

这些工作统一归到 `M-10`，不是重新开发 `M-11`。

---

## 四、本轮改造边界

只修改以下问题：

1. 三级页面跳转异常
2. 创建文件夹 / 文件逻辑异常
3. 编辑 / 预览切换异常
4. 页面层级、路径感、列表区分度明显偏离 Figma
5. 空状态、异常态缺失
6. v2 中仍把 Notes 暴露为底部 Tab 一级入口

本轮不做：

- 将 Notes 挂回 Plan
- 将 Notes 重新放回 v2 底部 Tab
- 把 `NoteFile` 重做成复杂富文本编辑器
- 引入超出当前产品范围的知识库能力

---

## 五、验收标准

- 用户能从 `ChatHome` 进入 Notes
- 根目录、子文件夹、文件页三层关系清楚
- 文件夹 / 文件创建默认本地可用
- `NoteFile` 可在同页切换编辑与预览
- 后续联调阶段只需补状态与测试资料，不需重做骨架

---

## 六、视觉参考

- Figma：`12-Notes`
- Figma：`V2-07-NotesEntry`
- Figma：`13-NoteFolder`
- Figma：`14-NoteFile`
- `01-需求/references/images/32-笔记-首页.png`
- `01-需求/references/images/33-笔记-子文件夹.png`
- `01-需求/references/images/34-笔记-文件.png`
