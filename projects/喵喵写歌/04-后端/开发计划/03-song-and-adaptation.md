# B003 AI 写歌与歌曲改编冻结前校验

> `v2.1-model-driven-params` · CHG-0076 · 第 12 步 · 文档 `waiting_review`；`T-B003-S/R` 均 `pending`。对齐[Flutter F002](../../03-前端/开发计划/02-song-create.md)、[F003](../../03-前端/开发计划/03-song-adaptation.md)、[PRD P02～P04](../../01-需求/v2.1-model-driven-params/requirements.md)。

## 骨架阶段 / `T-B003-S`

- **现有入口**：`app/catsinger/generation/controller/SongGenerationController` 的 `POST /api/song-generations`；`app/catsinger/cover/controller/SongCoverController` 的 `POST /api/song-covers`。两者都沿现有 `CreateSongGenerationRequest`，改编 Controller 仍服务端强制 `mode=cover`，绝不能因新参数重写为声音克隆业务。
- **调用步骤**：解析当前用户/App 与所选 `modelOptionId` → B002 有效契约 → 校验本次业务/可选参数/互斥 → B006 报价版本 → 原 `SongGenerationService` 创建链路。Service 增可读高层方法，`TODO(REAL-IMPLEMENTATION)` 对应 B003-R 的真实冻结前校验。Skeleton Fixture 仅 local/test 返回固定校验结论，不冻结、不创建实际任务、不送 Provider。
- **响应/兼容**：仍用 `ApiResponse<SongGenerationTaskResponse>`；新增可选 `contractVersion` 要先同步现有 DTO 与 Flutter F002/F003，不修改旧字段含义。骨架可验证失效版本/禁用参数返回现有错误包络及字段级原因；生产保持旧路径真实行为，不被假响应覆盖。
- **完成**：编译、Controller 正常/错误/独立业务路由测试通过；测试证明未触积分、审核、资源或 Provider；旧改编 `COVER` 类型未变。

## 真实实现阶段 / `T-B003-R`

1. **写歌**：用 `song.generate` 真实有效契约逐键验请求；纯音乐开启则新提交的歌词/人声等互斥值拒绝，不默默发送；专业模式参考音频、语言、风格/数值仅在该模型支持范围内接受。V2.1 不开放指定音色入口，后端既有兼容校验保留，旧客户端即使没传 `contractVersion` 仍走服务端重验。
2. **改编**：用 `song.cover.generate` 契约；“保留原歌词”关闭时不回填旧来源词，必须使用明确新词或已有 AI 补词结果；来源资源/审核事实沿原改编流程，不新增平行审核。禁用的改编调节项不得进入 Provider。
3. 校验顺序固定在 B006 积分冻结和厂家调用之前；过期能力/报价、模型下架、未知/越界/互斥参数返回可定位字段及原因，不冻结积分。成功请求照旧进入幂等任务/审核/资源/作品链路，快照保留本次有效参数。
4. 新配置只影响新任务，历史改编任务和 `COVER` 作品不重算、不迁移。原任务失败与积分释放由旧平台负责；不得因本模块额外创建第二条积分流水。

## 接口、表与验证

| 方法/路径 | 关键请求 | 响应/错误 | 鉴权 |
|-----------|----------|-----------|------|
| `POST /api/song-generations` | 现有 `CreateSongGenerationRequest`：`mode`、`modelOptionId`、`prompt/lyrics`、纯音乐和已有高级字段；拟增可选 `contractVersion` | `SongGenerationTaskResponse`；无效/互斥用 `SONG_GEN_CHECK_REQUEST_INVALID` 或现有同类错误，缺价走原计费错误 | 用户 JWT + `X-App-Code: catsinger` |
| `POST /api/song-covers` | 同 DTO，公开请求可兼容旧字段，Controller 固定 cover 语义 | 同上；来源不可用走原素材错误；绝不返回 `VOICE_COVER` 任务 | 同上 |
| `GET /api/song-generations/{id}`、`GET /api/song-covers/{id}` | 当前用户与任务 ID | 原任务响应；非本人或错误业务不泄漏任务 | 同上 |

仅用现有 `catsinger_song_generation_tasks`、工作流/资源/积分/作品表；**不新增迁移/Entity/Mapper**。定向测试覆盖两接口正常+非法参数、纯音乐互斥、保留旧词关闭、模型切换旧载荷、缺报价冻结前拒绝、幂等、跨 App、历史改编类型及 Provider 实际出参。接口 200 仍需第 15 步成品可播放验收。
