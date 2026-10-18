# T-42 进度对账与 T-47 真实文本补验

日期：2026-10-18。阶段保持开发；开发计划已批准并执行。

已同步18条当前任务汇总、8条子项结果，合并重复的T-28、T-34子项。两份工作区README的旧统计9通过/172部分/5未执行，已更新为已有证据支持的10通过/173部分/3未执行。47任务仍7完成、38进行中、2待外部验证。历史结果按原发生时点保留。

本轮增加1个真实模型方法，覆盖角色、场景、道具3份帮写候选，连同14项既有回归共15项通过，0失败/错误/跳过。后台dev提交8919f130；无业务源码、API、迁移、依赖或既有私有配置变更。

## 真实文本结果

使用已有本机IDE配置，经实际公共AI门面、DeepSeek适配器和HTTPS调用模型目录当次返回的deepseek-flash。输入为自建内容。两次只读模型目录GET中，首轮已收到HTTP200，结果整理遇到本机Ruby缺少filter_map；保留该轮结果，改用map/compact后再次GET成功。没有重复提交生成任务。

| 类型 | 样例 | 候选字数 | Provider返回 | 任务状态 |
|---|---|---|---|---|
| ROLE | 黑色短发、青色长裙、银色月牙发夹 | 139 | HTTP200 | SUCCEEDED |
| SCENE | 清晨车站、木椅、拱窗、雨后山景 | 263 | HTTP200 | SUCCEEDED |
| PROP | 铜制怀表、蓝色表盘、表盖叶片刻纹 | 154 | HTTP200 | SUCCEEDED |

人工阅读三份正文：都保留了输入的核心外观设定，并补充可用于生图的细节；未出现故事/分集标题或收费承诺。候选均在1–500 Unicode字符内。具体原文、候选、任务ID和调用结果见[真实结果](real-text-result.json)。这三例只提供实际样例证据，其他长度/异常边界继续引用原14项回归。

同一幂等键再次读取均回到原任务，外呼总数固定3次。新建隔离PG中只有3个帮写任务，资产、作品、收费订单均0；可用积分30、冻结0。不会自动生图或保存资产。

本轮模型选择目录为受控选择，HTTP入口为MockMvc，执行器为显式领取并调用真实Handler；定时调度关闭，手机未参与。源码种子的制作开关关闭且模型目录为空，已有部署数据库配置未检查或修改。正式模型选择/部署路由、真实结果到两端页面、真机表单恢复与最新Figma仍待验。故事、剧本、素材分析、图片/视频、ASR和OSS各自保持原验收边界。

## 当前进度修正

| 任务 | 当前汇总补齐的证据 |
|---|---|
| T-09、T-12、T-13 | [原文恢复](../../T-09/vivo-process-recovery/README.md)、[梗概/方向/两集手稿和唯一创建](../../T-12/vivo-content-recovery/README.md)、[制作参数恢复](../../T-14/vivo-settings-recovery/README.md) |
| T-15、T-16、T-22、T-23、T-24、T-26、T-35、T-39 | [API31实际Servlet/PG连续业务](../../T-43/ui-journey-vivo/README.md)：素材报价/受控生成/作品分类/应用、视频、本机字幕/导出/相册、成长领取；真实Provider/OSS继续分项待验 |
| T-29 | [双文件TCP断流、Range续传、取消和离线重入](../../T-29/vivo-download-recovery/README.md) |
| T-30、T-34 | [API31实际39%编码强杀与原工程恢复](../../T-34/vivo-active-interruption/README.md)、[完整Hive/撤销/原成片保护](../../T-28/vivo-reanalysis/README.md) |
| T-32 | [百度九宫格36次屏幕点按、4组中文候选输入及文字导出](../../T-32/vivo-ime/README.md) |
| T-37 | [我的页面返回/前台刷新及迟到回执保护](../../T-37/account-refresh/README.md) |
| T-46 | [API31双手柄实际拖动、短选段、独立音轨和导出](../../T-46/vivo-gesture/README.md) |
| T-47 | 本轮三类真实文本候选；正式路由/两端真实页面和真机表单恢复继续待验 |

原进度汇总把以上若干已补验范围继续列作未完成，并出现重复子项。已按证据更新当前汇总；父任务只在满足完整验收标准后标✅。正式186用例仅给TC-03-09、TC-03-10、TC-X31追加本轮证据，原步骤、预期和状态保持。

## 执行和复检

- [模型目录探针](probe_text_catalog.rb)：只读GET，不记录凭据；[最终状态](text-catalog-probe.json)、[首轮兼容错误](attempts/01-ruby-catalog/text-catalog-probe.json)。
- [后端执行器](run_backend.py)：显式启用实际模型测试，新建本机PG；[15项测试摘要](backend-tests.json)、[业务结果](real-text-result.json)。实际测试源码位于[CatdramaRealTextProviderTests.java](/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/CatdramaRealTextProviderTests.java)。
- [进度修改数据](progress-changes.json)、[逐行前后对账](row-changes.json)、[正式用例追加范围](formal-case-updates.json)、[修改脚本](reconcile_progress.py)。
- [只读复检](verify.py)、[复检结果](verify-result.json)：检查47项/38个唯一子项、186条状态、所有新增链接、允许文档范围、既有脏文件/私有配置/受保护文档摘要和真实测试计数。

原始测试XML、进程输出和修改前文档仅在本机originals目录保留，未提交。公开文件摘要在[manifest.json](manifest.json)。路径门禁脚本已存在且被跟踪，当前bash语法检查及6个目标路径检查通过；沿用该脚本更新文档，未重复新建。

首轮文档复检在生成自身结果前检查了verify-result.json链接，因文件尚未生成而退出；已将这一条结果自链接延后核对，并保留[首轮记录](attempts/02-self-result-link/failure.json)。真实模型及15项后台结果没有重复执行。

提交准备曾把新文件git diff --no-index --check的正常差异退出码1当作错误，暂存前已停止；核对空诊断输出后按其退出码语义复检，保留[准备记录](attempts/03-whitespace-exit-code/failure.json)。没有改变测试结论或重复外呼。

本轮没有重跑App全套：运行时代码保持fe63893有效基线，1273项通过结果沿用。没有安装或操作手机，没有进入测试/上线阶段，没有推送或部署。

## 清理与边界

专用PG仅操作本次随机schema；[清理核对](database-cleanup.json)显示无非系统schema残留，[服务清理](support-cleanup.json)确认自有PG停止、空socket目录移除，专用数据目录保留。现有后端数据库及用户数据未触碰；既有6处后端脏文件和产品/设计/技术/上线基线摘要保持。

数据库改动：无。本轮用量未取得，未额外查询。
