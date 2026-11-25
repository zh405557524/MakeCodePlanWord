# 14 后端测试与回归模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B014
> 状态：done

## 功能定位

为喵喵写歌后端 v1.0 提供编码完成判定。没有测试回归，不允许进入联调 QA。

## 必跑命令

```bash
./gradlew test
```

必要时再跑：

```bash
./gradlew build
```

## 测试清单

| 测试类 | 覆盖 |
|--------|------|
| `SchemaRoutingIntegrationTests` | common/app 专属表隔离 |
| `SongConfigInspirationIntegrationTests` | 灵感配置和兜底 |
| `SongConfigControllerTest` | 模型、情景、示例、案例 |
| `SongAssetControllerTest` | 上传校验和资源归属 |
| `SongLyricAssistServiceTest` | AI 帮写成功/失败 |
| `SongGenerationServiceTest` | 幂等、积分、状态机 |
| `MiniMaxProviderMockTest` | Provider 请求映射 |
| `SongResourceStorageServiceTest` | HEX、URL、本地/云存储 |
| `LyricTimelineServiceTest` | 三种时间轴来源 |
| `SongWorkControllerTest` | 作品操作 |
| `SongAlbumControllerTest` | 专辑操作 |
| `AdminSongApiTest` | 后台配置和权限 |
| `NarrateRegressionTest` | 旧 narrate 回归 |

## 验收标准

- 新增测试覆盖 P0 主链路。
- 旧 `narrate` 登录、积分、作品、任务中心不回归。
- 生成链路失败时积分退款测试通过。
- 作品响应不包含第三方临时 URL。

## 注意事项

若当前仓库存在既有失败测试，必须在最终说明中标明失败类名和是否与本轮变更有关。
