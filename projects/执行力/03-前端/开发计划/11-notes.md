# 执行力 Flutter 模块开发文档 - Notes

> 模块编号：`M-11`  
> 对应总体任务：`F-012A ~ F-012C`  
> 状态：`done`

---

## 一、功能定位与边界

Notes 模块负责把“资料沉淀”从长期规划能力变成当前版本正式功能。

本模块负责：

- `Notes` 一级页
- `NoteFolder` 子文件夹页
- `NoteFile` 文件页
- 文件夹与文件的本地结构管理
- 文档 / Markdown 的编辑与预览切换

本模块不负责：

- 从笔记生成计划
- 给计划挂笔记
- 复杂知识库、AI 自动整理或块编辑器

---

## 二、入口、路由与页面文件

**入口**：

- `MainShell` 中的 `Notes` Tab

**路由**：

- `RouteName.notes`
- `RouteName.noteFolder`
- `RouteName.noteFile`

**页面文件建议**：

- `lib/pages/notes/view.dart`
- `lib/pages/notes/controller.dart`
- `lib/pages/notes/index.dart`
- `lib/pages/note_folder/view.dart`
- `lib/pages/note_folder/controller.dart`
- `lib/pages/note_folder/index.dart`
- `lib/pages/note_file/view.dart`
- `lib/pages/note_file/controller.dart`
- `lib/pages/note_file/index.dart`

**服务 / Store 建议**：

- `lib/services/notes_service.dart`
- `lib/store/notes.dart`
- `lib/models/note.dart`

---

## 三、依赖前置

- `01-app-foundation` 已完成
- `02-splash-shell` 已完成
- `Global.init()`、`RouteName`、`CustomScaffold`、`GetStorage`、`Hive` 可用
- Notes 相关 Hive box 已预注册

---

## 四、视觉参考与 Figma 对齐

### 参考设计

- Figma：`12-Notes`
- Figma：`13-NoteFolder`
- Figma：`14-NoteFile`
- `01-需求/references/images/32-笔记-首页.png`
- `01-需求/references/images/33-笔记-子文件夹.png`
- `01-需求/references/images/34-笔记-文件.png`

### 页面结构结论

- `Notes` 是主导航独立页面，不附属于 `Plan`
- `NoteFolder` 强调路径感和层级感
- `NoteFile` 是沉浸式内容页，顶部必须展示返回、标题与路径
- 文件夹和文件在列表里必须视觉区分
- `NoteFile` 必须有 `编辑 / 预览` 切换，不拆独立页面

---

## 五、业务内容与数据流

### 5.1 Notes 首页

1. 进入 `Notes`
2. 读取根目录文件夹与文件
3. 点击文件夹进入 `NoteFolder`
4. 点击文件进入 `NoteFile`
5. 点击 `新建文件夹 / 新建笔记` 时先写本地结构

### 5.2 NoteFolder

1. 根据 `folderId` 读取当前层级
2. 展示子文件夹和文件混排列表
3. 继续创建子文件夹或文件
4. 保留路径上下文

### 5.3 NoteFile

1. 根据 `fileId` 读取文件详情
2. 默认进入最近一次使用的模式；无记录则进入编辑态
3. 编辑态优先保存本地内容
4. 预览态只渲染基础 Markdown 结构

---

## 六、公开模型与存储边界

### 6.1 模型建议

- `NoteFolder`
  - `id`
  - `name`
  - `parentId`
  - `createdAt`
  - `updatedAt`
- `NoteFile`
  - `id`
  - `title`
  - `folderId`
  - `format`
  - `content`
  - `createdAt`
  - `updatedAt`

### 6.2 存储边界

- `Hive`：
  - `note_folders`
  - `note_files`
- `GetStorage`：
  - 最近一次 `NoteFile` 使用模式等轻量偏好，可选

---

## 七、验收标准

- 用户能从主导航直接进入 `Notes`
- 根目录、子文件夹、文件页三层关系清楚
- 文件夹 / 文件创建默认本地可用
- `NoteFile` 可在同页切换编辑与预览
- 离线情况下不影响浏览与编辑

---

## 八、编码注意事项

- 不把 Notes 临时塞进 `Plan` 页
- 不把 `NoteFile` 做成单纯静态预览页
- 先完成本地结构和基础交互，再考虑 Plan / Notes 互链
- Markdown 当前只做基础标题、段落、列表的预览能力

---

## 九、当前实现结果

已落地代码：

- `lib/models/note.dart`
- `lib/store/notes.dart`
- `lib/services/notes_service.dart`
- `lib/pages/notes/*`
- `lib/pages/note_folder/*`
- `lib/pages/note_file/*`

已完成能力：

- `Notes` 主导航入口与高亮态
- 根目录、子文件夹与文件页三层跳转
- 新建文件夹、新建子文件夹、新建笔记
- Markdown 编辑 / 预览切换
- 本地 `Hive` 存储与最近模式偏好回写
- 默认种子数据与离线可用的基础浏览体验
