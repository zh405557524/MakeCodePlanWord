# T-23 / T-25 图片生成具体失败原因（2026-11-03）

用户确认问题发生在测试云 dev，并要求前端显示具体错误。本轮完成后端原因映射和客户端生成摘要读取；开发检查完成后仍需部署后端、更新客户端及设备验证。未记为正式渠道或用户验收通过。

本地 `dev` 提交：后端 `58806b06`，客户端 `cc28081`；未推送、未部署。并行任务的其他源码和配置改动保持。

## 测试云诊断

- 只读核对测试服 2026-11-03 22:19～22:33（服务器时间）的归档日志和任务记录。截图首批五个人物对应 `doubao-seedream-5-0-pro-260628`，HTTP 400，约 0.7～1.0 秒即被拒绝；任务已失败，积分状态为 `REFUNDED`。
- 该时间段多轮尝试中，59 次为 `InputTextSensitiveContentDetected`，1 次为 `OutputImageSensitiveContentDetected.DeepFake`。前者是输入描述被模型审核拒绝；后者按官方说明是生成结果可能涉及伪造证件。不能从错误码确定具体触发词，也不能据此认定用户描述确实违规。
- 测试服豆包图片异步开关关闭。这次是明确审核拒绝，不是同步等待超时；更换异步请求不会解决同一内容被拒绝的问题。本轮没有改变渠道、模型、异步开关或提示词。
- 官方依据：[方舟错误码](https://console.volcengine.com/ark/region:cn-beijing/docs/error-codes)、[图片生成接口](https://console.volcengine.com/ark/region:cn-beijing/docs/image-generation-api)。

## 实现范围

1. `DoubaoImageHttpClient` 根据受控错误码和 HTTP 状态生成中文说明，区分描述审核、参考图审核、输出图审核、模型未开通、参数、授权、限流及服务异常。日志保留安全错误码，不直接向用户回显厂商原文、提示词、签名地址或密钥。
2. `DramaImageGenerationService` 保留这份安全说明，让原工作流按实际补偿结果追加积分状态；收费、退款、任务终态和重复恢复行为保持。同步图片失败没有新增自动付费重试。
3. 客户端 `DramaAsset` 优先读取当前接口 `latestGeneration.jobState/message`，兼容旧字段和已有缓存。素材卡片复用现有失败区域；退出重进仍显示原因，较新的任务摘要不会被旧缓存的失败字段覆盖。没有增加界面说明、面板或按钮。

示例：`图片描述未通过模型内容审核，请修改描述后重试，冻结积分已退回`。

已落库的历史失败任务仍保留原通用文案，没有历史回填。后端上线后新失败任务获得新文案；客户端更新后补齐生成摘要的读取与刷新显示。

## 开发验证

| 范围 | 结果与边界 |
|---|---|
| 渠道和错误分类单测 | 152 项通过；包含 15 种豆包错误映射，确认不回显厂商私密正文、不重复调用，原异步渠道回归通过 |
| Spring / PostgreSQL 图片集成 | 70 项中 40 通过、30 失败；三种新增审核失败均通过，验证实际任务接口、素材摘要、一次退款和一次模型调用 |
| 后端基线对照 | 在独立构建目录用修改前的两份生产类、相同测试夹具执行；原有 30 项失败逐项相同，无新增既有用例失败。主要涉及旧版本标记断言、审核记录与补偿夹具，不作为本次全部通过 |
| 前端素材、资产、批量回归 | 164 项中 161 通过、3 个既有失败；新增摘要缓存恢复用例及 320/375 宽度下四项完整文案显示用例通过。独立临时目录中恢复修改前 `DramaAsset`，三项批量失败同样复现；新增缓存恢复用例在旧模型失败，在新模型通过 |
| 静态检查 | Dart format、相关文件及全项目 analyze、代码 diff 检查通过；工作区路径 audit 通过 |
| 视觉检查 | 已查看 Widget 渲染的 375 宽输入审核失败、320 宽输出审核失败截图，原因、退款文字和重试入口完整；不是手机、Figma 像素验收或真实付费生成验收 |

两个图片集成套件原先固定模型快照为 120 积分、价格版本 1，但读取运行期默认的 2 积分、版本 2，导致全部在报价前置失败。本轮仅在各自临时 schema 中显式设置夹具的固定报价；没有修改商品默认配置或云端价格。

共享默认 Gradle 构建目录曾被并行任务覆盖，相关早期运行不作为最终结论；最终及基线均使用独立构建目录。后端共 222 项：192 通过、30 个既有失败、0 跳过。不得把此数字写成全部回归通过。

前端既有失败为 `dedicated batch sheet blocks insufficient balance then requires a fresh explicit submit`、`small-screen batch items scroll while confirmation stays fixed`、`mixed result retries only the explicitly selected failed target`。对照命令在临时副本运行，未覆盖当前源码；初期自定义 package config 的 Flutter 工具路径错误不计为业务用例结果。

## 本地证据与未验事项

- 后端原始日志、XML 派生汇总、修改前对照及构建脚本：`/Users/soul/code/lxwx/lxwx_service/lxwxservice/.test/catdrama-image-failure-diagnosis-20261103/`，其中 `comparison.json` 记录失败多重集一致性。
- 前端日志：`/tmp/catdrama-image-error-ui-20261103.log`、`/tmp/catdrama-image-error-ui-baseline-20261103.log`、`/tmp/catdrama-image-error-analyze-full-20261103.log`；当前目录的 `logs/` 保存副本，`catdrama-t19-input-review-375.png`、`catdrama-t19-output-review-320.png` 等为本地截图，均不进入 Git。
- 数据库改动：无云端数据、表结构、迁移、历史回填或价格变更。集成测试仅使用 loopback PostgreSQL 自有随机 schema，按夹具清理；未停止其他任务已有的 PostgreSQL 进程。
- 未发起真实付费生成、未推送或部署、未安装客户端、未做模拟器或真机业务验收。没有领取、启动或修改模拟器设备。
