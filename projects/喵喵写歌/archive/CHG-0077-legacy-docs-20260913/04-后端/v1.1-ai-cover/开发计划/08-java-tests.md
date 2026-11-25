# 08 v1.1 AI 翻唱 Java 验收模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-08
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 命令验收

```bash
./gradlew test
```

如当前工程使用 Maven 或 Gradle wrapper 路径不同，以实际工程脚本为准，但必须记录执行命令和结果。

## 2. 单测范围

| 模块 | 用例 |
| --- | --- |
| schema routing | catsinger 有翻唱表，narrate 没有 |
| 音色配置 | 启用/停用/排序/分组 |
| 上传校验 | 格式、大小、时长、识别失败 |
| 创建任务 | 参数校验、版权确认、音色校验 |
| 幂等 | 重复提交返回同一任务 |
| 积分 | 冻结、成功扣减、失败退款 |
| Provider | MiniMax music-cover 请求映射 |
| 资源持久化 | 临时 URL 下载并落持久化资源 |
| Admin | 模型、音色、作品筛选 |

## 3. 联调验收

1. Admin 配置 `music-cover` 模型和音色。
2. App 获取音色列表。
3. App 上传合法音频。
4. App 创建翻唱任务。
5. 后端冻结积分。
6. Mock Provider 返回音频。
7. 后端下载并持久化音频。
8. 生成 COVER 作品。
9. App 查询作品详情播放翻唱音频。
10. 删除作品后列表不再展示。

## 4. 异常验收

- Provider 返回错误。
- Provider 返回音频 URL 过期。
- 上传对象存储失败。
- 用户积分不足。
- 重复提交。
- 用户访问他人任务。

## 5. 文档回写

验收完成后更新：

- `workflow.md` 当前阶段。
- `java-dev-plan.md` 验证记录。
- `change-plan.md` CHG-0013 状态。
- 如进入完成态，再写入 `change-log.md`。
