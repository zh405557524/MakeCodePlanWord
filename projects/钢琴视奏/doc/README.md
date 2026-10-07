# 钢琴视奏（Solfeggio）文档总览

> 流程规则：MakeCodePlanWord 工作台 `workflow/00-总流程.md`（本机路径 `/Users/soul/work/MakeCodePlanWord/workflow/`）。
> 本文件保持一页，只放"现在的状态"和"去哪里找"。
> 本目录（`MakeCodePlanWord/projects/钢琴视奏/doc/`）是钢琴视奏的工作区文档，代码仓库里不放产品和版本文档。v1 旧工作区已于 2026-10-07 清理，仍被引用的 12 份旧文档保留在 `history/v1/`。

## 当前状态

| 项 | 值 |
|---|---|
| 线上版本 | v2.1.0（定版）：Google Play 已上线；iOS 审核被拒，处理记录见 `versions/v2.1.0/release.md` |
| 开发中版本 | v2.1.1（patch，开发中）→ `versions/v2.1.1/fix.md`；v2.2.0（功能版本，规划中）→ `versions/v2.2.0/scope.md` |
| App 仓库 | `/Users/soul/code/soul/Solfeggio`（分支 `overseas`） |
| 后端仓库 | `/Users/soul/code/soul/service`（多 App 共用，App Code：`solfeggio`） |
| 设计工作区 | `/Users/soul/work/CreateDesignApp/projects/钢琴视奏v2.0版本` |
| 目标商店 / 地区 | App Store、Google Play；用户主要在美国、欧盟、南美，不上中国大陆 |

## 文档地图

| 想知道 | 看哪里 |
|---|---|
| 产品现在是什么样 | `product/00-总纲.md`，再看 `product/01`～`09` 模块分册（说明见 `product/README.md`） |
| 技术架构、接口、数据模型 | `tech/architecture.md`、`tech/api.md`、`tech/data-model.md` |
| 设计稿、参考图、切图在哪 | `design/README.md` |
| 回归用例、高风险清单 | `testing/regression.md`、`testing/risk-checklist.md` |
| 正在做什么 | `versions/v2.1.1/fix.md` |
| 以后想做什么 | `backlog.md` |
| 编码规范 | 代码仓库根 `AGENTS.md` → `.cursor/rules/`（App 和后端各一份） |
| 内置曲库内容（音频、MIDI、MusicXML、版权清单） | 同级目录 `../content-assets/` |

## 版本历史

| 版本 | 发布日期 | 一句话 |
|---|---|---|
| v2.1.0 | Google Play：⚠️ 日期待补；iOS：被拒，待重新提交 | 产品文档合并；会员只解锁 MIDI 钢琴练习；智能曲谱导入；账号绑定；评价邀请（`versions/v2.1.0/release.md`） |

## 代码仓库里的相关文件

下面这些文件在 App 仓库 `/Users/soul/code/soul/Solfeggio/doc/`，是和代码直接相关的说明和 v2.1.0 开发期间的测试记录，原地保留（其他仓库和规则里有引用），不属于基线：

| 文件 | 内容 |
|---|---|
| `android-release-qa.md` | Android 发布验收（2026-10-06），v2.1.1 的问题来源 |
| `practice-feedback-qa.md`、`piano-audio-route-qa.md`、`song-phone-rendering-qa.md`、`song-piano-rendering-qa.md` | 专项测试记录 |
| `design-qa/`、`ui/` | 对稿截图、资源替换记录 |
| `Google_Login_Setup.md` | Google 登录配置说明 |
| `flutter-scaffold.md` | 新建 Flutter 工程的脚手架说明（规则引用） |

本目录的 `history/` 是旧版产品文档。以后的测试证据放进对应版本的 `versions/vX.Y.Z/evidence/`。
