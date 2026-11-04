# PERF-02 视频编辑请求后台解析验证

日期：2026-11-03（America/Los_Angeles）。App dev `58f477b`，未推送。

## 实现范围

- HTTP 在工作 isolate 固定 JSON 请求体和查询参数的快照，编码 JSON/UTF-8；Dio JSON 响应不按大小回退到 UI 解析，统一在 isolate 解码。
- 视频编辑请求链路的作品详情、镜头列表与保存回执、下载清单、视频历史、任务查询/列表/子任务、模型配置、分集素材列表、报价和提交回执使用纯函数后台解析；集合身份、分页、目标等既有校验保留。
- 后台解析完成后再核对账号、会话、环境与服务地址。页面关闭、切换镜头后的迟到结果仍由原页面保护处理；401 原请求重放、未知结果恢复与账务行为未改。
- Flutter 的响应式状态发布、动画与绘制仍在主 isolate。此切片不改布局，不迁移本机草稿/剪辑工程的全部同步访问，也不承诺所有 UI/Raster 卡顿已解决。

## 开发验证

| 检查 | 结果 |
|---|---|
| 13 个改动文件 format 与 diff 检查 | 通过 |
| `flutter analyze --no-pub` | No issues found |
| HTTP 新增后台测试 | 6 项通过：原输入隔离、后台 JSON 编码、解码/空响应/字节/流契约、解析异常、环境切换拒绝旧结果、实际 App 转圈组件推进 |
| HTTP 会话回归 | 17 项通过，含 401 并发刷新、原输入/请求头重放、刷新失败及账号隔离 |
| 扩大范围回归 | 468 个不同用例：首轮 466 通过、2 失败；报价等待修复后 69 项报价测试全部通过，最终 467 通过、1 项基线失败 |
| 导航/生成异步复检 | 12 项通过，包含 191 镜头、镜头切换、迟到历史、返回及重复提交保护；属于上述范围，不重复计数 |
| `flutter build apk --profile --no-pub --dart-define=CATDRAMA_ENV=1` | 通过，生成本地 profile APK，未安装 |

范围命令：`flutter test --no-pub test/services test/shots test/generation/quote_test.dart test/creation/production_scope_test.dart test/creation/model_ratio_config_test.dart test/projects/captured_work_contract_test.dart --reporter expanded`。

动画测试使用实际 `AppLoadingIndicator`。通过 SendPort 确认解析执行在不同 isolate；工作 isolate 连续执行 500 ms 镜头模型解析期间，主 isolate 推进一帧并验证旋转进度增加，而且解析 Future 尚未完成。它验证线程分工和组件响应，不是手机真实帧率报告。

旧组件夹具有固定延时、仅推进模拟时钟的等待。后台解析引入后，测试改为推进真实 IO 和模拟帧并等待状态，结束时排空异步请求；没有放松业务断言、关闭 hit-test 检查或切回 UI 解析。用户已有的视频生成测试增量完整保留，提交仅包含本次等待逻辑。

## 基线失败与未验证项

`test/services/media_download_test.dart` 的 `complete file whose native metadata disagrees stays out of media index`：期望 999 ms 原生时长相对 1000 ms 清单触发拒绝，实际返回媒体记录。使用保留原有其他改动、还原本次 8 个旧生产文件的独立本地源码副本复现相同失败；该用例走媒体下载的本地回环 HTTP 与注入的校验器，不走本轮修改的 HttpService。没有借此改动媒体容差规则或测试预期。

未进行真机/模拟器安装、视频编辑页面真实帧耗时、视觉对稿、真实 Provider/OSS 或付费生成验收。未修改共享后端、部署或正式数据。此处结果不提高整版正式验收状态。

## 本地原始记录

本目录 `.log` 仅本地保存，不提交 Git：`regression-initial.log`、`quote-final.log`、`navigation-generation-recheck.log`、`analyze.log`、`android-profile-build.log`、`media-baseline.log`。首轮失败记录保留，复检单独记录。
