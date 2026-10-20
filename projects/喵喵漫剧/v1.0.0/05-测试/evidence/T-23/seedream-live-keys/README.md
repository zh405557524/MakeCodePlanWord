# T-23 双型号专用 Key 真实验证

日期：2026-10-19，代码基线：后端 dev `b97da2c7`。

用户填写两把 Key 后，分别从源码移入本机私有 `config/ai-model-provider/doubao.yml` 的 `image-flash-api-key`、`image-pro-api-key`；源码仅保留环境变量占位，未输出、提交或在证据中复制凭据。

| 型号 | 本轮实际请求 | 结果 |
|---|---:|---|
| doubao-seedream-5-0-flash-260915 | 1 | HTTP 404 / ModelNotOpen |
| doubao-seedream-5-0-pro-260628 | 1 | HTTP 404 / ModelNotOpen |

真实响应来自两个 IDE main 经公共图片 Service、真实 Provider 和 HTTP 客户端的调用。Gradle 命令完成不等于生图成功；本轮两项均为 blocked、无成功图片。错误码含义参见[火山官方错误码](https://docs.volcengine.com/docs/ark/error-codes?lang=zh&redirect=1)：目标账号未开通对应模型服务。

已停止重试，待用户在对应 Key 所属账号开通模型后再验证。原53项本机回归有效，不将其视作本轮真实供应商通过。漫剧本地模型选项尚未启用，原 BigLongXia 保持；数据库改动无、共享8080未重启、测试/正式环境未部署。开发45/45、验收7/47保持。
