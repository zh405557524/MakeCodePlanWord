# 喵喵写歌 v1.1 AI 翻唱 Flutter 开发计划

> V2.1 名称校准：本文件描述的旧链路现称“AI 改编”，不包含声音克隆；仅保留历史实现记录，禁止用于 V2.1 新“AI 翻唱（声音克隆）”编码。
> 版本：`v1.1-ai-cover`
> 变更：`CHG-0013 AI 翻唱功能`
> 状态：`reference-only`
> 执行入口：本文件和 `03-前端/v1.1-ai-cover/开发计划/*.md`

## 任务列表

| 编号 | 模块 | 状态 | 说明 |
|------|------|------|------|
| F-COVER-01 | 接口与模型 | done | 已补翻唱音色、上传、创建、任务、作品类型字段，并新增序列化测试 |
| F-COVER-02 | 首页与作品入口 | done | 首页 AI 翻唱卡、作品详情/播放器重新翻唱入口已接入 |
| F-COVER-03 | 上传歌曲页 | done | 已支持作品库选择、本地上传、版权确认、6分钟限制提示 |
| F-COVER-04 | 选择音色页 | done | 已支持分组音色卡、试听、选中态 |
| F-COVER-05 | 高级设置页 | done | 已支持保留歌词/伴奏、音高、情感、混响、积分展示和提交 |
| F-COVER-06 | 生成中与结果页 | done | 已支持轮询、进度、AB 播放、下载/分享/收藏/删除入口 |
| F-COVER-07 | 作品类型展示 | done | 列表/详情已展示原创、翻唱、纯音乐标签 |
| F-COVER-08 | 验证 | done | `flutter analyze`、`flutter test` 已通过；截图验收待人工执行 |
| F-COVER-09 | 作品列表自动刷新 | done | CHG-0045：有生成中作品且作品 Tab 可见时每分钟静默刷新，所有任务创建成功后立即刷新一次 |
| F-COVER-10 | 主歌曲播放屏幕常亮 | waiting_review | CHG-0047：全屏/迷你播放器真实播放时防自动锁屏，暂停、结束、失败和后台释放；定向测试通过，待 Android/iOS 真机验收 |
| F-COVER-11 | 作品详情弹层真机适配 | done | CHG-0048：修复 1080×2408@3x 下固定 Sliver 小数高度触发断言导致弹层空白，定向 Widget 与 V1981A 真机验证通过 |
| F-COVER-12 | 热歌改编自定义歌名 | done | CHG-0051：非空用户歌名随请求发送 `titleExplicit=true`，空输入的自动命名兜底保持 `false`；请求级 Widget 回归通过 |
| F-COVER-13 | Android MP4 音频转换兼容 | done | CHG-0052：M4A 封装被厂商 Muxer 拒绝时无损回退 ADTS AAC，按实际扩展名/MIME 上传；V1981A 用户失败原文件真机回归通过 |
| F-COVER-14 | 歌词/封面 120 秒与翻唱取词展示 | waiting_review | CHG-0067：两类同步生成响应改为 120 秒；普通请求和异步轮询不变；取词映射收尾，播放器刷新真实歌词/时间轴；14 项定向及 analyze 通过；全量因旧断言失败及内存膨胀未完成，已记录失败全部在同依赖旧基线复现 |
| F-COVER-15 | 生成完成播放器目标作品锁定 | done | CHG-0070：任务成功跳转的显式 `workId` 优先于进入页面前的全局当前歌曲；目标作品开始播放后恢复队列切歌联动；4 条相关 Widget 回归与 analyze 通过 |
| A-COVER-01 | Web/Admin 翻唱配置 | done | 后台模型、音色、作品类型筛选页面已对齐并通过验证 |

## 模块文档索引

> 2026-06-25 已完成本版本模块编码对账、缺口补齐和命令验证；截图与真实环境联调进入人工验收。

| 模块 | 文档 | 文档状态 |
|------|------|----------|
| 总索引 | `03-前端/v1.1-ai-cover/开发计划/00-cover-module-index.md` | done |
| 接口与模型 | `03-前端/v1.1-ai-cover/开发计划/01-cover-api-models.md` | done |
| 首页与作品入口 | `03-前端/v1.1-ai-cover/开发计划/02-home-and-work-entry.md` | done |
| 上传歌曲页 | `03-前端/v1.1-ai-cover/开发计划/03-cover-upload-step.md` | done |
| 选择音色页 | `03-前端/v1.1-ai-cover/开发计划/04-cover-voice-step.md` | done |
| 高级设置与提交 | `03-前端/v1.1-ai-cover/开发计划/05-cover-settings-submit.md` | done |
| 生成中与结果页 | `03-前端/v1.1-ai-cover/开发计划/06-cover-progress-result.md` | done |
| 作品集成 | `03-前端/v1.1-ai-cover/开发计划/07-works-integration.md` | done |
| Web/Admin UI | `03-前端/v1.1-ai-cover/开发计划/08-admin-cover-ui.md` | done |
| 前端验收 | `03-前端/v1.1-ai-cover/开发计划/09-flutter-qa.md` | done |

## 开发顺序

CHG-0067 的跨端实现、验证和历史维护说明见 `04-后端/v1.1-ai-cover/开发计划/09-cover-lyrics-backfill.md`。无 App 新接口、原生改动或 SDK；当前不执行发布或历史回填。

CHG-0070 只修正 App 共享播放器的状态采纳边界：生成页仍用任务响应中的 `workId` 打开作品，旧播放会话不得覆盖该目标；无接口、后端或数据库改动，不推进当前整 App QA 状态。

已按接口与模型、入口、三步流程、结果页、作品类型展示、Web/Admin 的顺序完成编码对账和补齐。下一步不自动进入 QA、打包或上架，先等待人工截图和真实环境联调验收。
