# T-23 工作台并发范围预览复检

2026-10-17。App `dev` 提交 `dbb9a02ec231bf6091d6ba48186e78bc29bdaf45`；父提交 `314a52c`。后台未修改、未重跑。T-23整项继续进行中，当前阶段保持开发；未推送或部署。

## 修复与证据

读取影响范围时，服务端当前图已由5511换成5514，旧工作台却把5511的本机文件交给5514的预览槽。先用两个不同的真实文件复现失败，再按`impact.currentImage`的版本/资源ID读取；打开中的原确认框响应加载和迟到文件，下载失败不借旧文件。有效作品的当前引用仍可读取原版本截止后的文件；可新应用候选在读取范围后及确认后分别检查期限，过期时不创建业务命令。

- [修复前负例](reproduction.json)：原生产代码、退出1，实际文件不符；[原日志](logs/reproduction.log.gz)。
- [工作台专项](workbench-tests.json)：36通过、0失败、0跳过，新增6项覆盖并发当前图、受保护过期当前图、失败无旧图、原弹框迟到更新及两个候选到期窗口。
- [全套App](app-tests.json)：1246通过、0失败、0跳过；[analyze](analyze.json)与[4文件格式检查](format.json)通过。36项属于1246项，不相加。
- Android与iOS各1条完整原生页面方法通过；实际Dio回环HTTP、公共ResourceService文件缓存及本机存储，模拟服务端并发和丢回执。每端8张实时系统截图，采集时核对真实App PID；SDK setup/teardown不计业务方法。
- 三份图片的资源ID和SHA均不同。最新当前5514先下载失败，取消不应用；重试保持待取图时打开确认框，再向同一框交付正确14514文件，候选仍5512/14512。确认使用scope-2/revision2；丢回执后2次相同正文和幂等键只产生1次应用，无生成或收费请求。

## 原生结果与截图

| 平台 | 结果 | 总览 | 原始系统图 |
|---|---|---|---|
| Android API37/16 KiB模拟器 | [1方法通过](android/outcome.json) | [8图](android-flow.png) | [顺序与PID](android/system-captures.json) |
| iOS26.4 iPhone15ProMax模拟器 | [1方法通过](ios/outcome.json) | [8图](ios-flow.png) | [顺序与PID](ios/system-captures.json) |

16图全部核对，4张失败/加载/就绪关键图详看；[图片清单](screenshot-inventory.json)、[视觉复检](visual-review.json)。此轮只核对现有页面行为，没有最新Figma或物理设备视觉验收。

## 失败及范围

最初新测试的局部辅助函数声明顺序导致编译失败，实际业务未执行；补齐声明顺序后负例准确复现。随后一处测试分支缺花括号的lint被发现并修正。[首次编译记录](initial-test-compile.json)、[首次analyze](initial-analyze.json)与原始日志均保留，不算最终通过或独立业务缺陷。最终双端完整流程均首次通过，未通过重启新任务掩盖未知回执。

[正式用例映射](case-results.json)仅补TC-11-03/05、TC-12-01的部分证据。47项仍7完成/38进行中/2待外部；186条仍9通过/172部分/5未执行，正文摘要保持。

未修改后台、业务API、数据库、依赖、原生媒体引擎或布局。真实OSS/Provider、生成质量、首次实际付费完整流程、最新Figma及物理设备仍待；控制的HTTP响应不能替代这些验收。

[清理复核](cleanup-recheck.json)：仅停止自有模拟器并移除本轮端口，未卸载/清除App；Android19份、iOS42份既有视频及授权与T-20结束时一致。[范围检查](scope-check.json)核对后台6份原改动、工作区外15643条状态和12份产品/设计/技术/上线保护文档；[路径门禁](guard-result.json)通过。

## 复查

在此目录运行`python3 verify.py`。脚本只读证据与Git源文件，不启动设备/服务；[核验结果](verify-result.json)、[源码版本](source.json)、[哈希清单](manifest.json)可复核。

`originals/`是本机忽略的原始日志和状态快照，不纳入提交；公开压缩日志只去除认证/签名敏感内容，[归档记录](log-archives.json)保存原文与公开内容摘要，[原始文件清单](raw-manifest.json)可在本机复核。原始日志缺失不伪造，只验证仍可用文件。

本轮用量未取得，未额外查询。
