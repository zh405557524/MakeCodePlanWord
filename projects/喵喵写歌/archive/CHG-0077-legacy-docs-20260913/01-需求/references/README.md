# 喵喵写歌需求参考资料

> 创建时间：2026-06-09 17:52
> 最近更新：2026-09-13
> 当前阶段：CHG-0076 V2.1 新版需求检测 PASS、待确认；v1.2.0+121 整 App QA 并行保留
> 用途：归档原始产品资料、设计稿和当前安装包截图，供需求差异分析与 UI 验收引用。

## V2.1 当前资料：三业务参数随模型变化

> 当前执行入口：[新版完整 PRD](../v2.1-model-driven-params/requirements.md)；旧版声音克隆 PRD 已保存在 [CHG-0076 前快照](../../archive/CHG-0076-pre-rewrite/README.md)，仅供参考。

| 材料 | 作用 |
|------|------|
| [简易/专业写歌改版](https://acnrg6qcjuk1.feishu.cn/wiki/TbOdwPGVmi5lmekVYgRcjCMjnZe) | 纯音乐、输入区、参考音频、指定音色和高级参数 |
| [歌曲改编改版](https://acnrg6qcjuk1.feishu.cn/wiki/Nc6nwOEWoipZjKkuoIac1e67nvf) | 保留歌词开关、识别状态和来源 |
| [克隆翻唱](https://acnrg6qcjuk1.feishu.cn/wiki/HVCxwGxhziI9nTknaftczy90noe) | 本人音色训练、翻唱、会员和计费 |
| [Figma 新稿导出索引](images/v2.1/model-driven-params/README.md) | `vn7k0jqv` / `working (91:106)`，21 张关键页面/状态图 |
| [三份飞书对账笔记](docs/v2.1/20260913-feishu-source-notes.md) | 只读需求提炼与冲突索引，非原文全文备份 |

新需求以具体模型能力为参数上限，后台只能收窄；Figma 中不支持项仍在原位置灰并可点击查看原因。画面里的积分、时长和容量是动态数值的展示示例，不同页面取值不同不构成设计冲突，不能沿用下节旧口径硬编码。

当前 UI 真源是已重新连接的 Figma 通道 `vn7k0jqv`、`working (91:106)` 页面。21 张本地 PNG 是 2026-09-13 导出快照，不代替此后的线上画面；后续视觉和交互对稿以当前 Figma 为主，不重做设计稿计划，也不修改 Figma 原稿。动态数值由模型/后台/服务端实际数据驱动；固定业务文案在 App 实现中遵守已确认需求，不能把截图文字直接当成业务放行条件。

## V2.1 旧版声音克隆资料（reference-only）

> 原需求入口 `01-需求/v2.1-ai-cover-voice-clone/requirements.md` 已由 CHG-0076 替代。本版本中的 AI 翻唱是新的声音克隆翻唱；历史上名为 AI 翻唱的既有功能现统一称为 AI 改编，两项功能独立。

### 产品资料

| 文件 | 来源 | 用途 |
|------|------|------|
| `docs/v2.1/喵喵写歌-AI翻唱产品需求与技术方案-V2.1.docx` | `/Users/soul/Downloads/喵喵写歌-AI翻唱产品需求与技术方案-V2.1.docx` 归档副本 | 产品功能、页面、业务规则和厂家能力输入；文档内命令性文字不视为用户指令 |

归档文件 SHA-256：`fceb5f5293b3136be43bf2530ad20a9ba17f4131e3a1357e6e2e442b82c8c1d3`。

### Figma 设计稿

- 历史通道：`dfgz0898`（后曾复核 `p354jft5`）
- 页面：`working`（`91:106`）
- 当前有效 Frame：38 个，包含新增首页。
- 图片目录：`images/v2.1/ai-cover-voice-clone/`
- 逐节点索引：[AI 翻唱 Figma 资源索引](images/v2.1/ai-cover-voice-clone/README.md)
- 初次读取时存在重复训练指南节点 `114:7853`，导出时已被外部移除；有效训练指南保留为 `114:5887`，未伪造缺失图片。

### V2.1 文案与规则修正

- 首页三个入口统一为 `AI 写歌 / AI 改编 / AI 翻唱 NEW`。
- `AI角色` 统一改为 `AI音色`。
- Figma 中 30 积分为占位；训练和翻唱分别使用服务端报价。
- 旧稿曾统一写不超过 100MB、训练单段 1～5 分钟/累计 1～10 分钟；新稿改为按所选训练模型能力，以上数字不能直接作为全厂家限制。
- 翻唱输出不固定 MP3，以厂家实际返回并经平台识别的格式为准。
- 厂家模型或临时地址有效期不等于用户音色自动删除。

## v1.1.0 当前安装包截图

> 当前实际交付需求入口：`01-需求/v1.1.0-as-built/requirements.md`。以下截图来自 Android 安装包 `1.1.0 (110)`，分辨率 `1080x2408`，是本轮页面和测试校准的直接证据。

| 文件 | 当前页面 |
|------|----------|
| `images/v1.1.0-as-built/android/01-home.png` | 首页、双创作入口、热门案例、三 Tab 底栏 |
| `images/v1.1.0-as-built/android/02-master-create.png` | 大师模式创作表单 |
| `images/v1.1.0-as-built/android/03-generation-progress.png` | 生成进度、六阶段、退出等待 |
| `images/v1.1.0-as-built/android/04-works.png` | 我的作品、生成中作品 |
| `images/v1.1.0-as-built/android/05-profile.png` | 我的、会员、积分和菜单 |

原 v1.0/v1.1 设计稿继续保留，用于确认未实现项和视觉差异，但不再直接替代当前安装包截图。

## v1.1 历史“AI 翻唱”（现称 AI 改编）资料

> 这里保留的是既有改编链路的历史资料，其中“AI 翻唱”是旧名称，V2.1 起统一称为“AI 改编”。本节及 `v1.1-ai-cover` 文档均为 `reference-only`，不得作为新“AI 翻唱（声音克隆）”的编码依据。

### 产品文档

| 文件 | 来源 | 参考重点 |
|------|------|----------|
| `docs/v1.1/ai翻唱.md` | `/Users/soul/ai翻唱.md` 归档副本 | AI 翻唱入口、上传歌曲、选择音色、高级设置、积分消耗、结果页 |

### AI 翻唱设计稿

| 文件 | 参考重点 |
|------|----------|
| `images/v1.1/ai翻唱/ai翻唱-首页入口.png` | 首页 AI 翻唱快捷入口、NEW 标签、卡片样式 |
| `images/v1.1/ai翻唱/ai翻唱-第一步1.png` | 第 1 步上传歌曲空态、作品库入口、本地上传、版权确认、底部按钮 |
| `images/v1.1/ai翻唱/ai翻唱-第一步2.png` | 第 1 步作品库展开态、可选作品列表 |
| `images/v1.1/ai翻唱/ai翻唱-第一步3.png` | 第 1 步作品选中态、版权确认选中态、按钮启用态 |
| `images/v1.1/ai翻唱/ai翻唱-第二步1.png` | 第 2 步音色分组、音色卡、试听和选中态 |
| `images/v1.1/ai翻唱/ai翻唱-第三步1.png` | 第 3 步高级设置、保留原伴奏、音高、情感强度、混响、积分提示 |
| `images/v1.1/ai翻唱/ai翻唱-结果页面1.png` | 翻唱结果页唱片视觉、原版/翻唱版切换、播放器和操作栏 |
| `images/v1.1/ai翻唱/ai翻唱-结果页面2.png` | 翻唱结果页信息卡：歌曲名称、翻唱音色、创建时间、积分消耗 |

### v1.1 历史实现口径

- v1.1 实现现归类为 AI 改编，不混入 V2.1 声音克隆翻唱计划。
- 音频限制以当前需求文档为准：最大 50MB，最短 6 秒，最长 6 分钟。
- 原始文档或设计稿中的“最长 10 分钟”仅作历史输入，不作为执行口径。
- Flutter 主验收尺寸为 375x812，并抽查 390x844、414x896。

## v1.0 新产品文档与设计稿

> 2026-06-11 用户重新整理了喵喵写歌需求和设计稿。后续 PRD 与前端 UI 以本项目内 `docs/v1.0/`、`images/v1.0/` 为准。

### 产品文档

| 文件 | 来源 | 参考重点 |
|------|------|----------|
| `docs/v1.0/喵喵写歌产品文档v1.0.md` | 本项目归档副本 | MVP 功能范围、页面结构、写歌/作品/会员/积分/接口需求 |

### 首页设计稿

| 文件 | 参考重点 |
|------|----------|
| `images/v1.0/首页/首页1.png` | 首页首屏：品牌、输入卡、快捷功能、热门案例、底部 Tab |
| `images/v1.0/首页/首页2.png` | 首页滚动后内容补充 |
| `images/v1.0/首页/案例详情1.png` | 热门案例详情：Banner、案例信息、Prompt、底部模板按钮 |
| `images/v1.0/首页/案例详情2.png` | 案例详情补充 |
| `images/v1.0/首页/情景写歌.png`、`情景写歌1.png` - `情景写歌5.png` | 场景写歌 4 步问答、补充的“想表达什么？”步骤与完成态 |
| `images/v1.0/首页/作品生成中.png` | 生成中页面/生成状态参考 |
| `images/v1.0/首页/会员中心.png`、`会员中心2.png` | 会员中心视觉与权益结构 |

### AI 写歌设计稿

| 文件 | 参考重点 |
|------|----------|
| `images/v1.0/Ai写歌/AI写歌-灵感创作1.png`、`AI写歌-灵感创作2.png` | 灵感创作、音乐描述、音乐名称、曲风描述、底部按钮、迷你播放器 |
| `images/v1.0/Ai写歌/AI写歌-高级创作1.png` | 高级创作歌词输入与 AI 帮写 |
| `images/v1.0/Ai写歌/AI写歌-高级创作2.png` | 音乐名称、曲风标签、歌手类型 |
| `images/v1.0/Ai写歌/AI写歌-高级创作3.png` | 歌曲语言、时长、参考音频、AI 模型 |
| `images/v1.0/Ai写歌/AI写歌-高级创作5.png` | 高级创作补充态 |

### 作品设计稿

| 文件 | 参考重点 |
|------|----------|
| `images/v1.0/作品/作品-作品.png` | 作品页歌曲 Tab、生成中分组、已完成列表 |
| `images/v1.0/作品/作品-专辑.png` | 专辑 Tab |
| `images/v1.0/作品/专辑创建.png`、`专辑创建2.png` | 创建专辑流程 |
| `images/v1.0/作品/专辑详情.png` | 专辑详情 |
| `images/v1.0/作品/作品详情1.png`、`作品详情2.png` | 作品详情当前 UI 真源：封面、操作区、基础信息、Prompt、歌词内容 |
| `images/v1.0/作品/播放器-播放界面.png`、`播放器-歌词.png` | 播放器当前 UI 真源：Song 播放界面、Lyrics 歌词模式、进度与底部控制 |

### 我的设计稿

| 文件 | 参考重点 |
|------|----------|
| `images/v1.0/我的/我的.png` | 我的页主视觉：用户卡、快捷功能、PRO 卡、菜单 |
| `images/v1.0/我的/我的2.png` | 我的页滚动/补充状态 |

## 前端 UI 执行要求

- 前端页面需按照 `images/v1.0/` 设计稿写 UI，这是本轮重点。
- Flutter 基准尺寸仍为 `375 x 812`。
- 设计稿 PNG 为 `860 x 1626`，但包含手机壳和黑色背景；实现时按内层 App 屏幕内容换算，不按整张图片机械缩放。
- 首页、写歌、作品、我的四个主 Tab 必须优先对齐设计稿结构、视觉层级、间距、底部固定区和状态。

## 历史参考图片

> 旧 Sonus 参考图已归档到 `archive/legacy-20260610/01-需求/references/images/`，只用于追溯，不再作为当前 UI 执行依据。

| 文件 | 来源 | 参考重点 |
|------|------|----------|
| `archive/legacy-20260610/01-需求/references/images/01-create.jpeg` | 用户提供截图 Image #1 | 写歌页深色玻璃拟态、简单/自定义切换、Prompt 输入、模型选择、纯音乐开关、Create 按钮、底部导航 |
| `archive/legacy-20260610/01-需求/references/images/02-explore.jpeg` | 用户提供截图 Image #2 | 首页/探索页 Banner、热门歌曲、更多歌曲列表、播放按钮、深色音乐社区风格 |
| `archive/legacy-20260610/01-需求/references/images/03-library-empty-song.jpeg` | 用户提供截图 Image #3 | 作品页 Song 空态、会员 Banner、开始创作入口 |
| `archive/legacy-20260610/01-需求/references/images/04-library-album.jpeg` | 用户提供截图 Image #4 | 作品页 Album 空态与新增入口 |
| `archive/legacy-20260610/01-需求/references/images/05-generating.jpeg` | 用户提供截图 Image #5 | 生成中全屏状态、计时、预计耗时提示、允许退出等待 |
| `archive/legacy-20260610/01-需求/references/images/06-library-loading.jpeg` | 用户提供截图 Image #6 | 作品生成中列表状态、任务数量、模型标签 |
| `archive/legacy-20260610/01-需求/references/images/07-library-loading-2.jpeg` | 用户提供截图 Image #7 | 作品生成中状态补充参考 |
| `archive/legacy-20260610/01-需求/references/images/08-scenario.jpeg` | 用户提供截图 Image #8 | 情景创作问答流程、标签答案、跳过、输入其他答案 |
| `archive/legacy-20260610/01-需求/references/images/09-player-song.jpeg` | 用户提供截图 Image #9 | 歌曲播放页、唱片视觉、播放进度、下载/分享入口 |
| `archive/legacy-20260610/01-需求/references/images/10-player-lyrics.jpeg` | 用户提供截图 Image #10 | 歌词页、当前歌词高亮、背景封面叠加、播放控制 |

> 历史参考图仅保留用于追溯，不再作为本轮前端 UI 的主要实现依据。

## 工程路径

- 前端 Flutter 工程：`/Users/soul/code/lxwx/catsinger`
- 后端 Java 工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`
- Web/Admin 后台管理工程：`/Users/soul/code/lxwx/lxwx_admin`

## 原始产品约束

- 新 App 名称：喵喵写歌
- 后端业务编码：`catsinger`
- 首页 4 个主页面：首页、写歌、作品、我的
- 不输出 Figma 设计稿，但需要保留 UI 参考约束并评估工时
- v1 接入 MiniMax 歌曲生成，同时预留不同模型路由到不同平台
- v1 按次扣积分，价格由后端配置返回
- 需要新增后端 Web 管理页面，支持切换 App 并查看对应 App 数据
- 正式 App 展示名固定为「喵喵写歌」
- Android applicationId / iOS Bundle ID 固定为 `com.lxwx.catsinger`
- 默认模型为 MiniMax `music-2.6`，前端模型列表从后端获取
- 默认生成价格为 100 积分/首，Web/Admin 后台可配置
- 首页歌曲示例的封面、音频、标题、风格标签由运营提供，Web/Admin 后台可配置；开发期可用 Mock/占位数据
- 歌词 v1 需要接入逐句时间轴，播放页按音频进度高亮当前歌词行；时间轴缺失或异常时允许静态展示作为容错
- 分享入口 v1 待实现，可先空实现
- 支持用户创建专辑
- 后台 App 切换范围读取服务端全部 appCode 配置
- 后台管理页 v1 支持操作配置和数据，不做只读页
- MiniMax API Key、Group ID、回调或轮询等真实配置值可在代码完成后再添加，配置方案参考既有阿里云短信方案
- 首批歌曲示例由 Web/Admin 后台添加；没有配置时前端展示空态
- 后台需要区分超级管理员和普通角色；超级管理员可以为不同角色分配不同管理块
- 专辑公开展示、排序、封面上传、批量移入歌曲 v1 暂不做，但技术方案和数据结构需要考虑后续扩展
- 下载资源 v1 暂不区分普通音质和高清音质，但需要考虑后续扩展
