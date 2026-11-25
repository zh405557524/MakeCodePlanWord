# CHG-0067 歌词、封面超时与翻唱歌词补齐

日期：2026-08-28。范围：catsinger Flutter App 与共享后端；不修改 Web/Admin、原生配置或 SDK。用户已批准实现方案，实现与专项验证已完成，后端全量通过；Flutter 全量受既有 UI 测试失败和内存膨胀影响未完成。保留 CHG-0066 iOS 验收恢复点，未自动部署。

## 行为与接口

- App `/api/song-lyrics/assist`、同步 `/api/song-works/{id}/regenerate-cover` 共用响应超时常量，统一为 120 秒；连接、发送、普通请求均保持 30 秒。
- 封面异步任务创建/查询仍为普通请求，3 秒轮询和 15 分钟总等待上限不变。
- 翻唱的 `GENERATE_COVER` 之后、`CONTENT_REVIEW` 之前增加 `FETCH_COVER_LYRICS`。仅天谱乐、非纯音乐的 `COVER_SONG` 执行；其他渠道跳过。
- 内部取词复用天谱乐 `POST /open-apis/v1/song/query`，精确匹配原 `item_id`。读取 `lyrics`、`lyrics_sections`、`lyrics_sections_status`，不需要音频临时 URL，也不要求配置生成回调 URL。
- 有正文即结束；仅有有效分段则按开始时间排序、拼正文。分段秒转毫秒，过滤空文本、纯段落标记、缺失/非数字/负数/溢出/倒置或零长度时间。只保存真实分段，不推算伪时间轴。
- 第一次查询前将 `lyricsDeadlineMs = 当前时间 + 120000` 保存到原步骤 `response_json`。暂停检查点保留截止时间、沿用渠道轮询间隔（默认 60 秒），下一次延迟及 HTTP 响应预算不得超过剩余时间。重启恢复不重置截止时间，不消耗生成重试次数。
- 查询失败、厂商明确无歌词、两分钟截止均按成功降级继续，保留音频，不重新提交、不追加扣分、不因缺词退款。新获取歌词经过原最终作品审核；审核拒绝仍遵循既有审核规则。
- 新生成歌词写入任务及作品现有正文、参考歌词字段；时间轴写入作品并恢复到运行上下文。纯正文返回静态歌词，真实时间轴来源为 `PROVIDER`。
- App 不新增接口，继续读取详情的 `lyrics`、`lyricTimeline`、`timelineSource`。取词映射收尾阶段；播放器缓存刷新比较正文、来源和每行时间，而非仅比较行数。

厂商协议参考：[官方歌曲查询](https://platform.tianpuyue.cn/docs/464626886e0)。

## 历史维护命令

入口：`src/maintenance/java/com/lxwx/narrateservice/maintenance/catsinger/CoverLyricsBackfillCommand.java`。Gradle 独立 `maintenance` source set，不打入普通服务启动范围；不启用主服务组件扫描、Flyway、定时任务、积分结算或配置默认值写入。

所有命令从 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 运行。连接配置仍从 Spring 标准私有配置/环境读取；维护连接池只允许 `catsinger` schema。API Key 和数据库密码不得写入命令、清单或仓库。

只查看帮助（本轮可验证，不连接数据库）：

```sh
./gradlew coverLyricsBackfill --args='--help'
```

未来执行只读预览示例（默认 dry-run；本轮没有运行真实数据预览）：

```sh
./gradlew coverLyricsBackfill --args='--manifest /absolute/path/cover-lyrics-preview.json --limit 100 --after-id 0'
```

未来明确获准后才可写入：

```sh
./gradlew coverLyricsBackfill --args='apply --manifest /absolute/path/cover-lyrics-preview.json --report /absolute/path/cover-lyrics-result.jsonl'
```

安全约束：

1. `--manifest` 必填；默认最多 100 条、允许 1–1000 条；通过返回的 `nextAfterId` 接续下一批。预览和结果文件必须为新文件，拒绝覆盖。
2. 候选作品必须成功、审核通过、未禁用/删除、天谱乐、`COVER` 且正文为空。关联任务还必须同用户、双向关联、成功且为天谱乐翻唱。
3. 清单只输出作品 ID、任务 ID、归属用户 ID、厂商任务 ID、状态、拟补齐字段、快照/歌词摘要；无完整歌词、音频 URL 或密钥。状态区分 `AVAILABLE`、`PENDING`、`UNAVAILABLE`、`MISSING_TASK`、`TASK_MISMATCH`、`MISSING_PROVIDER_TASK_ID`、`QUERY_FAILED`。
4. dry-run 连接池为只读，不装配审核服务，不写审核记录、不创建任务、不补默认配置。
5. apply 必须读已预览清单；重新查厂商，内容/时间轴或关联快照发生变化则跳过、要求重新预览。补入文本复用 `STEP_CATSINGER_WORK_LYRICS` 策略，必须得到 `PASS`，拒绝/人工复核/错误均跳过。
6. 审核后逐条事务锁定原任务与作品，再核验状态、归属、关联、空字段及快照。只补作品缺失的 `lyrics`、`timeline_reference_lyrics`；有真实分段且作品无有效时间轴时才补时间轴和 `timeline_source`。不覆盖已有正文、参考歌词或有效时间轴，不更新历史生成任务、不结算积分。
7. 每条处理写入脱敏 JSONL 结果并刷新文件；审核使用已有审核记录。可重跑同一清单，已补齐或发生并发修改的作品跳过。进程中断后需换新的结果文件重跑；不会重复补写成功作品。
8. 普通服务启动不触发维护，禁止把 `apply` 放入部署/启动脚本。本轮不执行真实历史数据写入。

## 数据库改动

无表结构变更、无 Flyway 迁移。新生成流程只复用任务/作品歌词、参考歌词、时间轴与步骤检查点字段；未来历史 apply 仅更新候选作品缺失字段及 `updated_at`，并使用现有审核记录。未连接真实数据库执行回填；后端无关在途改动保持原样。

## 验证记录

- Dart 已格式化；`flutter analyze` 无问题。
- 14 项 Flutter 定向回归通过：两类 120 秒响应超时及默认 30 秒、收尾进度、静态/同步歌词、同长度时间轴缓存刷新、润色等待防息屏和前后台释放。
- Java 已覆盖：立即/延迟、仅正文/仅分段、空结果、异常分段、查询失败、两分钟截止、重启保留截止、详情静态歌词及真实时间轴；维护预览零写入、重复执行、审核拒绝、并发修改、任务变更、缺 ID、已有字段保护、跨 App 门禁和白名单启动装配。
- `./gradlew test` 首次全量因默认 512MB 堆空间不足，在既有图片标识测试分配图像时终止；使用临时 2GB 测试堆重跑已通过：共 1477 项，3 项原有跳过，0 失败/错误。命令为 `./gradlew test --init-script /tmp/catsinger-lyrics-verification.i27IMO/test-memory.gradle`；仅临时设置测试 JVM 的 `maxHeapSize = '2g'`，没有修改仓库或服务运行内存配置。
- 维护 `--help` 入口通过且不连接数据库；两工程 `git diff --check` 及工作区守卫 audit 通过。额外单独执行 HTTP 测试 3 项全部通过，包含异步封面创建/查询仍为 30 秒。
- 已执行 `flutter test --reporter expanded`。全量到账号菜单测试时已记录 159 通过、193 失败，随后测试进程在 GC 中持续停滞、物理内存占用约 29.9GB；为避免继续消耗用户机器资源已终止该测试进程。因此全量没有完成，不能宣称全绿。
- 对照使用 `git archive HEAD` 的改动前代码，并复制当前 `pubspec.lock` 后离线解析相同依赖。基线全量记录 157 通过、194 失败后同样停滞；也已终止。当前已记录的 193 个失败名称全部在基线失败集合中，无仅当前版本出现的失败名称；基线额外运行到了 `account page shows guest state when unauthenticated`。未执行完的用例不在本次对照结论内。
- 既有失败包括 `????` 文案断言、旧请求字段断言和页面 UI 断言；不通过改动无关业务来修复这些旧测试。14 项专项与 3 项 HTTP 测试独立完成且通过，不受全量中断影响。
- 原始测试日志目录：`/tmp/catsinger-lyrics-verification.i27IMO`。主要文件：`flutter-targeted.log`、`flutter-http.log`、`flutter-full.log`、`flutter-baseline-full.log`、`flutter-stall.sample`、`backend-full-2g.log`。内存膨胀测试进程已全部退出。

## 验收与后续边界

部署需按现有发布流程单独执行，当前没有自动部署或真实生成扣分。上线后验收一首歌词立即返回和一首取词超时的天谱乐翻唱，确认进度不倒退、无词仍可播放、已有音频不重生成。历史补齐另行批准，先保存/审阅只读清单，再决定 apply 范围。
