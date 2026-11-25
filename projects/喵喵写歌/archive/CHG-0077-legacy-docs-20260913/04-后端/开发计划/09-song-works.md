# 09 作品接口模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B009
> 状态：done

## 功能定位

支持首页最近作品、作品列表、详情、下载、分享、收藏、重新生成和隐藏。

## 接口契约

| 方法 | 路径 |
|------|------|
| GET | `/api/song-works/recent` |
| GET | `/api/song-works` |
| GET | `/api/song-works/{id}` |
| POST | `/api/song-works/{id}/download-url` |
| POST | `/api/song-works/{id}/share` |
| POST | `/api/song-works/{id}/regenerate` |
| POST | `/api/song-works/{id}/cover-regeneration-tasks` |
| GET | `/api/song-works/{id}/cover-regeneration-tasks/latest` |
| GET | `/api/song-works/cover-regeneration-tasks/{taskId}` |
| POST | `/api/song-works/{id}/favorite` |
| POST | `/api/song-works/disable` |

## 业务规则

- 只能访问当前用户自己的作品。
- hidden/disabled 作品默认不在用户列表显示。
- 下载地址来自资源存储服务。
- 分享 v1 可先返回系统分享文案或下载链接。
- 重新生成复用原作品 prompt/lyrics/style/model 创建新的生成任务，但任务从创建时起关联原 `workId`，不得插入新的作品占位记录；冻结积分成功后立即把原作品关联到新 task 并切换为 `GENERATING/PENDING_REVIEW`。
- 重新生成必须按原作品业务类型恢复请求：翻唱作品复用原成功任务/作品保存的源音频、音色、版权确认和翻唱高级设置，保持 `COVER_SONG / MUSIC_COVER_SONG_V1` 并重新执行特征预处理；纯音乐保持 `instrumental=true`，高级创作参考音频和选项从原任务快照恢复。
- 任务成功后更新原作品行、切回 `SUCCEEDED` 并保留收藏、专辑等稳定关系；任务失败时退款，恢复原 `generationTaskId` 与 `SUCCEEDED/APPROVED`，并保留原作品内容与可播放状态。
- CHG-0056 后，详情新增可选 `creationParameters`：风格、场景、对象、纯音乐、人声、语言、时长和可复用参考音频；标题、歌词、详情风格与 provider/model 继续使用原字段。
- `creationParameters.musicStyleTags` 表示原始创作参数：快照存在时只合并快照 `prompt.musicStyle` 与请求 `styleTags`，禁止混入作品 `styleTagsJson` 的 Provider 结果标签；历史空快照才从结构化“音乐风格”引导词和作品结果标签降级。
- 参考音频仅向作品所有者返回；首页配置或他人可读作品可返回非私有创作参数，但 `creationParameters.referenceAudio` 必须为空。
- 参考音频素材 ID 必须再次校验用户归属、素材类型、READY 状态和资源地址；存在素材 ID 但已不可用时不得回退暴露快照 URL。
- 用户封面重生复用既有封面任务表和作品级活动槽：重复创建返回当前 `PENDING/RUNNING` 任务，调度器异步执行，成功后释放活动槽并返回封面 URL，失败返回可展示摘要。
- 用户只能创建自己已生成完成作品的封面任务并查询自己的任务；用户响应不暴露任务来源、用户 ID 或 Provider 原始响应。
- 用户任务执行必须复用同步封面入口的计费规则：已有封面时冻结积分，成功确认扣减，图片生成失败退款并保留旧封面；缺失封面免费生成，失败写回封面失败状态。
- 后台封面任务继续按 `ADMIN` 来源执行和通知；用户任务不发送后台失败通知。现有任务表字段已覆盖 `USER/ADMIN` 来源和用户归属，无需新增迁移。

## 实现步骤

1. 拆 `SongWorkService`。
2. 补详情响应字段。
3. 接入下载和分享服务。
4. 补收藏和重新生成。

## 测试要求

- 越权访问返回 not found 或无权限。
- hidden 后列表不可见。
- 下载地址不含第三方临时 URL。
- 重新生成创建新任务但不创建新作品；覆盖提交即进入生成中并关联新 task、成功切回完成态、失败恢复原任务关联，以及作品数量、`workId`、幂等与关系保留断言。
- 翻唱重新生成断言 mode、creationMode、workflow、songType、源音频、音色与高级设置均保持，执行时重新产生特征 ID 并以 MiniMax `THIRD_PARTY_ID / MINIMAX_COVER_FEATURE_ID` 发送；缺少源音频时不得创建无效普通歌曲任务。
- 生成同款详情断言完整参数响应、快照风格不混入作品结果标签、参考音频所有权隔离、任务清理后仍可恢复、历史空快照仅解析结构化风格段和普通详情字段回归。
- 封面异步任务断言创建接口不阻塞图片生成、活动任务幂等、成功轮询、积分不足失败且旧封面不变、冻结积分归零、未登录和跨用户访问拒绝，并回归后台任务与原同步封面计费路径。

## 验收标准

作品页、播放器、下载分享和重新生成可联调。
