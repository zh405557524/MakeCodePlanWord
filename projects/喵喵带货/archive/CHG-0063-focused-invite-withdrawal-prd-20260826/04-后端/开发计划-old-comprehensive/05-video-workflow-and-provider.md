# Java 模块开发文档：视频工作流与模型 Provider

> 版本：`v1.0`｜状态：已完成｜任务：`T-B008 视频生成`

## 1. 功能定位与边界

根据已确认脚本、镜头、当前分镜图片、比例、时长和形象创建不可变快照，调用视频模型生成最终视频，并提供任务重试和当前视频结果。视频模型直接生成成片，不建设独立配音或字幕任务。

## 2. 类清单

Controller：`CatsellerVideoController`。Service：VideoSnapshot/VideoTask/VideoQuery/WorkState/Resource/Moderation。Workflow：`SellerVideoWorkflowStep`、`SellerGenerationCompensationService`。Provider：复用现有 AI Provider 注册机制，增加视频中立输入适配。Mapper/Entity：VideoSnapshots、Videos、GenerationTasks、GenerationTaskSteps、GenerationCompensations、Works、BillingQuotes。

## 3. 接口契约

对应 Flutter：`07-video-and-watermark.md`。

| 方法与路径 | 请求 | 响应 | 错误 |
|------------|------|------|------|
| `POST /api/catseller/works/{workId}/video-tasks` | 登录+幂等；quoteId/价格版本/快照哈希 | taskId、`VIDEO_RUNNING`、nextPollAfterMs | `QUOTE_EXPIRED`、`POINTS_INSUFFICIENT`、`SHOT_CONTENT_INCOMPLETE`、`WORK_STATE_CONFLICT` |
| `POST /api/catseller/works/{workId}/video-tasks/retry` | 登录+幂等；失败任务/最新报价确认 | 新 taskId、失败策略摘要 | `WORK_RUNNING_LOCKED`、`QUOTE_EXPIRED` |
| `GET /api/catseller/works/{workId}/video` | 登录 | 当前成功视频、历史版本摘要、资源、AI 标记、有效期 | `WORK_NOT_FOUND`、`GENERATION_FAILED` |

视频任务进度继续由作品聚合详情返回，避免新增平行状态接口。

## 4. 数据表与迁移

- `catseller_video_snapshots`：work、脚本/镜头/图片/形象/规格不可变 JSON、snapshotHash、报价/失败策略版本。
- `catseller_videos`：snapshotId、resourceId、状态、审核、AI 标记、有效期、错误。
- `catseller_generation_tasks`：`VIDEO`、Provider、providerTaskId、租约、重试、幂等、错误。
- `catseller_generation_task_steps/events/compensations`：记录报价校验、积分冻结、Provider、资源、审核、结算、保存与补偿。
- `catseller_works`：当前视频版本、状态、失败阶段/resumeState、version。
- 约束：snapshotHash 可校验、Provider task 唯一、同作品视频阶段一个活动任务。

## 5. 业务规则与状态流转

```text
EDITING/COMPLETED → 校验当前脚本和每镜头当前图片
  → 校验报价/余额/审核 → 创建不可变快照与积分协作
  → VIDEO_RUNNING → Provider 提交/轮询或回调
  → 资源入库+视频审核 → COMPLETED
  → 失败 → FAILED(failedStage=VIDEO, resumeState=EDITING/COMPLETED)
```

- 任务开始后不可取消、编辑、删除。
- Provider 中立输入只含必要脚本、画面资源、比例、目标时长和形象引用；不暴露内部积分数据。
- 视频结果由资源服务保存，`aiGenerated=true`；后端不生成水印文件。
- 新版本失败时旧成功视频仍可访问；重试创建新任务，不覆盖失败记录。
- Provider 无百分比时 progress 允许为空，不生成假进度。
- `SELLER_VIDEO_V1` 参考 SongWorkflow 顺序执行：校验快照/报价 → 冻结积分 → 提交 Provider → `PAUSED` 等待结果 → 保存资源 → 阿里审核 → 结算积分 → 保存视频 → 完成。

### 5.1 最终视频参考图用途说明

`SUBMIT_VIDEO_TASK` 生成最终视频提示词时，按照传给 Provider 的 `image_urls/images` 实际顺序，为每张参考图生成编号和用途说明：

- `PRODUCT_IMAGE`：提供商品外观、颜色、结构和可见细节参考。
- `STORE_FRONT`：提供店铺门头、外立面、入口和可见招牌参考。
- `STORE_INTERIOR`：提供店内空间、装修、陈列、座位和环境参考。
- `STORE_OFFERING`：提供图片中可见商品或服务的外观与现场表现参考。
- `PERSONA`：选择人物时排在所有素材图片之后，提供带货或探店人物的身份、外观和形象参考。

用途说明只解释每张图片承载的参考信息，不要求图片必须出现，不限定图片必须用于某个镜头，也不限定具体表现方式。人物和素材的一致性、分镜顺序以及不得虚构品牌、价格、优惠、地址、功效等事实安全约束继续保留。历史任务缺少逐图角色时只输出未编号的场景级用途说明，不猜测图片数量或编号。

## 6. 异常与日志

Provider 忙、提交超时、轮询失败、回调重复、资源下载失败、审核拒绝分别记录稳定错误和 traceId。未知提交结果先按幂等键/providerTaskId 查询，不直接再创建任务。日志脱敏 Provider 响应和媒体 URL。

## 7. 依赖前置

依赖编辑脚本/分镜图片、报价与积分、资源、视频审核、任务恢复和真实视频 Provider 测试账号/额度。前端水印不属于后端实现。

## 8. 建议实现步骤

1. 定义不可变快照和 Provider 中立输入。
2. 参考 `SongWorkflowDefinitionProvider/Engine` 实现视频步骤定义、状态持久化、事件和暂停等待。
3. 实现前置校验、幂等提交和状态 CAS。
4. 实现 Provider 适配、轮询/回调和资源入库。
5. 实现审核、完成、失败和旧视频保留。
6. 实现幂等积分/资源/作品补偿和进程重启恢复。
7. 使用真实受控环境做最小调用和完整链路。

## 9. 编码任务

| 子任务 | 名称 | 状态 | 退出条件 |
|--------|------|------|----------|
| T-B008-01 | 视频快照 | done | 输入/报价哈希不可变且可审计 |
| T-B008-02 | Provider 调用 | done | 提交、查询/回调契约和 Mock 资源入库可用；真实账号留待私密环境联调 |
| T-B008-03 | 状态与失败 | done | 运行锁、失败恢复和旧视频保留正确 |
| T-B008-04 | 视频结果 | done | 聚合详情和结果接口返回稳定资源描述 |

## 10. 测试要求

每接口正常+错误；快照变化/报价过期；重复提交和未知结果；Provider 成功/忙/超时/回调重复；审核拒绝；进程重启；新失败不覆盖旧视频；Flutter 契约不出现独立配音/字幕。

## 11. 验收标准

视频 Provider 适配、Mock 与契约测试可生成完整结果；状态从编辑到运行再完成/失败正确；重复请求不重复任务/扣费；运行中不可取消；结果含 AI 标记和有效期；旧成功版本安全保留。真实渠道由私密环境补充联调。

## 12. 编码注意事项

不把 Provider 直接暴露给 App；不持久化临时 URL；不在视频模块自行计算最终积分；不增加 TTS、配音、字幕或消息通知阶段；不复制 SongWorkflow 的歌曲步骤编码和音乐文案。

## 13. 实现结果

已完成不可变视频快照、稳定请求标识、异步提交/查询、资源保存、视频审核、完成/失败恢复和旧成功视频保留。视频由视频模型直接生成，不包含独立配音、字幕或 TTS 步骤。真实渠道账号、密钥和额度由私密联调环境提供，仓库内契约与 Mock 链路已通过。

恢复点：前后端联调中的视频生成和视频完成页面。
