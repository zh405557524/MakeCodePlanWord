# 设计来源索引

> 只记录"设计在哪里"，不复制设计稿。各版本具体用了哪些稿子，写在版本 `scope.md` 的「设计来源」表。
> 设计工作区：`/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本/`（下文简称"设计工作区"）。

## 设计规范

| 项 | 位置 |
|---|---|
| 视觉与交互要求、版式体系 | `doc/product/00-总纲.md` 第 10 章 |
| Figma 设计系统说明 | 设计工作区 `06-Figma设计稿计划/figma-design-system.md` |
| 代码中的主题与通用组件 | App 仓库 `lib/theme.dart`、`lib/widgets/`、`lib/components/` |
| UI 实现规范 | App 仓库 `.cursor/rules/10-ui.mdc`、`14-figma.mdc` |

## 设计稿

| 范围 | 来源 | 位置 |
|---|---|---|
| 和弦练习页 | Figma | [正式稿 node 3860-13584](https://www.figma.com/design/4ASp94rt1UBbMM8URTet1C/?node-id=3860-13584)；导出图：设计工作区 `06-Figma设计稿计划/exports/chord-practice-final.png` |
| 歌曲手机练习页 | Figma | [正式稿 node 3860-13120](https://www.figma.com/design/4ASp94rt1UBbMM8URTet1C/?node-id=3860-13120)；导出图：`06-Figma设计稿计划/exports/phone-practice-r5.png` |
| 曲谱导入相关页面（14 张） | AI 生成参考图 | 设计工作区 `04-ChatGPT图片生成计划/images/` |
| 会员相关页面 | UI 确认说明 | 设计工作区 `02-需求文档/ui-review-20260927.md` 及同名目录 |
| 其他 v2.0 页面 | 页面参考图 | 设计工作区 `04-ChatGPT图片生成计划/`、`archive/钢琴视奏v2.0.0版本/` |
| 风格输入图 | 用户提供 | 设计工作区 `01-需求分析/inputs/images/` |
| Figma / 素材来源登记 | | 设计工作区 `external-resources.md` |

## 切图与资源

| 资源 | 位置 |
|---|---|
| App 内使用的图片、图标、音频 | App 仓库 `assets/` |
| 图标与背景生成素材（含提示词、manifest） | 设计工作区 `05-图标与背景图生成计划/assets/` |
| 资源替换记录 | App 仓库 `doc/ui/*.md` |

## 对稿验收记录（v2.1.0 开发期间）

- App 仓库 `design-qa.md`、`score-import-design-qa.md`
- App 仓库 `doc/design-qa/`（首页、手机歌曲练习、和弦、会员 UI、导入告知的对照图）

以后的对稿截图放进对应版本的 `doc/versions/vX.Y.Z/evidence/`。
