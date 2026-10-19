# T-18 普通 iOS 与生产定时器：处理中恢复、失败集重试

2026-10-19。普通 `main.dart` App、实际 Servlet/JWT/隔离 PostgreSQL 和生产 `@Scheduled DramaJobWorker.poll`。手机为专用 iPhone 17 Pro / iOS 26.5 模拟器；已确认两集通过既有公共登录与创作 API 准备，手机实际从作品详情进入制作设置并开始分析。文本、延迟和错误由测试替身提供，本轮没有调用外部模型、图片或视频。

## 已验证

1. 第一集先成功，第二集保持处理中。实际终止并重启普通 App，进程 **73551 → 75580**；原 4 个任务、输入摘要和幂等键保持，仍只有一次全剧分析 POST、4 次受控文本调用。
2. 后台明确将第二集置为 FAILED、父任务 PARTIAL_FAILED 后，页面只给失败集提供重试入口。实际点击一次，创建一个独立单集尝试。
3. 该重试处理中再实际终止并重启，进程 **75580 → 76027**；显示“继续查询本集分析”，主动查询也只恢复原重试。仍为原 5 个任务、同一重试键，分析 POST 总数为全剧 1 次、失败集 1 次。
4. 释放原重试结果后两集均可用；首集完整 episode/analysis/shot/ref 数据库快照逐字段保持，已确认正文及期限不变。3 个真实素材身份复用为 5 个分集绑定、2 个镜头；可用 30、冻结 0、扣费订单 0。历史父任务保持 PARTIAL_FAILED，新的单集尝试为 SUCCEEDED。

## 检测与范围

- 新增 **1 个完整后台联验方法通过，0 失败/错误/跳过**，普通 App 控机 UI-01 在本模拟器通过。正式 TC-10-01 仍为部分验证，不把本次受控故障当作真实厂商故障或双端完整验收。
- 后台 dev `7b0bb8b5` 仅提交本测试；已执行源码摘要与提交文件一致。App 沿用 `2dbf40b` 的普通构建，4 个安装文件摘要核对一致；本轮未改 App 运行时代码，未重跑 Flutter 全套/构建。此前 106 项相关回归沿有效基线复用。
- [上一次普通 iOS 真实 DeepSeek 正常路径](../scheduled-app/README.md)独立保留；该次任务停止前已成功，本次才覆盖处理中及失败分支。不能将两者拼成一次真实 Provider 故障测试。
- 仅此切片通过；47 项仍 **7 完成 / 40 未完成**，正式 186 条仍 **12 通过 / 171 部分 / 3 未执行**。真实厂商异常、已发布配置、物理设备/更多样例与 Figma 全状态仍待；真实视频接入继续暂缓。

## 失败尝试与清理

run-01 编译泛型推断错误，未开始业务联验。run-02 在第一次实际恢复及失败集重试后，被过时的标记格式断言中止；第二次恢复未完成，不计通过。修正断言后用全新数据和专用模拟器完成 run-03，未重交 run-02 的未知任务。三次原始结果及摘要见 [attempts.json](attempts.json)。

最终运行活动任务 0，专属 schema 清理、PG/Servlet 停止。run-02 的原未知任务数据保留，仅停止其专属 PG；原失败记录未改。共享 8080、其他 App/用户设备、签名配置、模型配置、接口和数据库结构保持。控制会话已关闭；不发布凭证、控制会话或私密原始日志。

## 关键截图

| 处理中重进 | 明确失败后 |
|---|---|
| ![原任务处理中](observations/O00040.png) | ![只重试第二集](observations/O00043.png) |

| 重试处理中重进 | 两集恢复完成 |
|---|---|
| ![继续查询原单集任务](observations/O00055.png) | ![素材分析已完成](observations/O00056.png) |

## 可复查数据

[结果](result.json)、[后台断言](backend-result.json)、[测试投影](backend-tests.json)、[手机检查](phone-result.json)、[首次重启](initial-after-restart.json)、[重试重启](retry-after-restart.json)、[首集保留快照](first-success.json)、[最终任务](tasks-final-projection.json)、[HTTP 路径记录](http-requests.json)、[受控调用线程](model-invocations.json)、[测试源码](CatdramaScheduledRecoveryDeviceTests.java)、[清理](cleanup.json)。全部已发布文件摘要见 [manifest.json](manifest.json)。
