# Java 模块开发文档：分镜图片与历史版本

> 版本：`v1.0`｜状态：已完成｜任务：`T-B007 分镜图片`

## 1. 功能定位与边界

按镜头生成分镜图片，保存图片历史和当前选择，支持单镜头重生成、用户上传替换、历史切换与失败镜头批量重试。图片生成属于内容任务内部步骤，不新增作品主状态。

## 2. 类清单

Controller：`CatsellerStoryboardController`。Service：Storyboard/ImageTask/Resource/Moderation。Workflow：`SellerStoryboardWorkflowStep`。Mapper/Entity：StoryboardImages、Shots、GenerationTasks、GenerationTaskSteps、Works。DTO/VO：ImageTaskCreate、ImageUploadBind、CurrentImageSelect、ImageVersionItem、FailedShotRetry。

## 3. 接口契约

对应 Flutter：`06-content-and-script.md`。

| 方法与路径 | 请求 | 响应 | 错误 |
|------------|------|------|------|
| `GET /api/catseller/works/{workId}/shots/{shotId}/images` | 登录；镜头归属 | 图片历史、当前标记、审核、AI 标记、有效期 | `WORK_NOT_FOUND` |
| `POST /api/catseller/works/{workId}/shots/{shotId}/image-tasks` | 幂等；当前画面/version、计费确认（如需） | taskId、进度 | `WORK_STATE_CONFLICT`、`POINTS_INSUFFICIENT` |
| `POST /api/catseller/works/{workId}/shots/{shotId}/images` | 幂等；resourceId、镜头 version | 新图片版本 | `ASSET_INVALID_OR_EXPIRED`、`CONTENT_REJECTED` |
| `PUT /api/catseller/works/{workId}/shots/{shotId}/current-image` | imageId、镜头 version | 最新镜头/当前图片/version | `WORK_STATE_CONFLICT` |
| `POST /api/catseller/works/{workId}/failed-shots/retry` | 幂等；失败镜头集合或后端当前失败集合 | 子任务摘要、内容主任务进度 | `WORK_STATE_CONFLICT` |

## 4. 数据表与迁移

- `catseller_storyboard_images`：shotId、resourceId、版本、来源、审核、AI 标记、当前标记、有效期。
- `catseller_generation_tasks`：`STORYBOARD_IMAGE` 子任务、providerTaskId、租约、幂等键、错误。
- `catseller_generation_task_steps/events`：记录校验镜头、生成图片、保存资源、审核、保存版本和完成步骤。
- `catseller_shots`：当前图片引用、version、问题状态。
- 约束：同镜头版本唯一、最多一个当前图片；Provider 任务唯一；同镜头同阶段最多一个活动任务。

## 5. 业务规则与状态

- 内容任务保存镜头后并行/限流创建图片子任务；主任务汇总真实完成数。
- 每张结果先落公共资源并经阿里审核，再建立图片版本。
- AI 生成图片 `aiGenerated=true`；用户上传为 false，后端不生成水印。
- 部分失败保留成功图片，作品可进入带问题的编辑状态；提交视频前所有镜头必须有审核通过的当前图片。
- 单图重生成和上传替换都新增版本，不覆盖历史；切换当前图片使用 CAS。
- 失败镜头重试只处理当前失败镜头，不重新生成成功镜头。
- 每个镜头使用 `SELLER_STORYBOARD_IMAGE_V1`；等待 Provider/审核时步骤为 `PAUSED`，调度器再次执行只检查结果，不重复提交。

## 6. 异常与日志

Provider 超时/忙碌/审核拒绝分别保存稳定 errorCode；回调与轮询竞争通过 providerTaskId 和状态 CAS 去重。日志不记录完整 Prompt、签名 URL或人像内容。

## 7. 依赖前置

依赖脚本/镜头、图片 Provider、资源服务、阿里审核、任务执行器和可选积分规则。视频模块依赖每个镜头当前图片。

## 8. 建议实现步骤

1. 建立图片 Entity/Mapper/部分唯一索引。
2. 参考 SongWorkflow 实现图片子任务步骤定义、初始化、暂停等待和事件日志。
3. 实现图片子任务调度、Provider 适配和结果入库。
4. 实现历史列表、上传替换和当前选择。
5. 实现失败汇总与局部重试。
6. 完成并发回调、审核、历史和部分失败测试。

## 9. 编码任务

| 子任务 | 名称 | 状态 | 退出条件 |
|--------|------|------|----------|
| T-B007-01 | 图片生成 | done | 每镜头任务和真实进度可恢复 |
| T-B007-02 | 图片版本 | done | 历史、当前选择和 CAS 正确 |
| T-B007-03 | 上传替换 | done | 资源归属/审核/版本正确 |
| T-B007-04 | 失败镜头重试 | done | 只重试失败项，成功项不丢 |

## 10. 测试要求

每接口正常+错误；图片全部成功/部分失败/全部失败；重复回调和轮询竞争；上传非法资源/审核拒绝；当前图片并发切换；Mapper 唯一索引；Flutter 可展示历史和 AI 标记。

## 11. 验收标准

脚本与分镜图片统一表现为内容任务；每镜头有独立历史；局部失败可恢复；AI 标记完整；提交视频前可验证全部当前图片。

## 12. 编码注意事项

不覆盖历史，不返回永久 URL，不由客户端声明 AI 来源，不重试已成功镜头，不新增独立作品状态。

## 13. 实现结果

已完成每镜头图片子任务、成功结果保留、图片历史、上传替换、当前图片切换、单张重生成和失败镜头批量重试。

恢复点：前后端联调中的分镜图片编辑能力。
