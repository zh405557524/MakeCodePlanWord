# GPT Image 2.5 默认风格验证（2026-11-06）

用户确认：默认展示全部 58 种风格，数据库存在同模型配置时优先使用数据库。

- 修改：`ai-drama-style-prompts.json` 增加 `biglongxia / gpt-image-2.5` 的 `mm_style_001`～`mm_style_058` 关联。现有数据库覆盖逻辑不变；自定义列表、显式空列表和停用配置继续优先。
- 数据库改动：无；无迁移，无本地数据库数据同步。
- 提交：后端 `1f32f6ed`。
- 测试：`CatdramaConfigTests` 24 项通过，覆盖无数据库默认值、数据库优先、空关联及停用覆盖。
- 发布：基于测试服当前 `72e17b70` 制品，仅替换该 JSON 资源，逐 ZIP 项比较确认其他内容不变，保留此前积分并发修复。
- 测试服制品：`/opt/lxwx-service/releases/lxwx-service-test-styles-20261106-1f32f6ed.jar`。
- SHA256：`140db6ad70cafa63ce570018525745ada8551def80b0d5170be2509d6633d245`。
- 健康检查：UP。实际 `/api/drama/config` 携带 `X-App-Code: catdrama` 返回成功，GPT Image 2.5 风格由部署前 0 种变为 58 种。
- 同时只读核验测试库 `drama.image-styles` 行数仍为 0，证明本次显示不依赖数据库风格记录。
- 未修改 App，不需要新安装包；用户端重新加载配置即可。未执行用户手机界面或真实模型生图验收。
- 回滚：恢复上一制品软链 `/opt/lxwx-service/releases/lxwx-service-test-points-20261106-72e17b70.jar` 并重启服务；无数据回滚。

原始证据本地保存在 `evidence/T-26/gpt-image25-default-styles-20261106/`，不提交 Git。
