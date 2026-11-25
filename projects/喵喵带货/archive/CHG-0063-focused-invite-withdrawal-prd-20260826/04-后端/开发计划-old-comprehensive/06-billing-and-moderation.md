# Java 模块开发文档：积分计费与内容审核

> 版本：`v1.0`｜状态：已完成｜任务：`T-B009 积分计费`、`T-B010 内容审核`

## 1. 功能定位与边界

实现按确认分镜图片数量报价、积分冻结/确认/失败处理，以及商品图、描述、形象、脚本、分镜图片和视频的阿里审核协作。价格和失败策略后台配置；本模块不在客户端或 Java 常量写死单价。

## 2. 类清单

Controller：`CatsellerVideoQuoteController`。Service：VideoBilling/PointsCharge/ModerationPolicy、`SellerGenerationCompensationService`。Mapper/Entity：BillingQuotes、Works、Snapshots、GenerationTasks、GenerationCompensations；复用公共积分订单/流水、资源和审核 Entity/Repository。VO：VideoQuote、BillingBreakdown、ModerationResult。

## 3. 接口契约

对应 Flutter：`07-video-and-watermark.md`；后台对应 `09-admin-catseller.md`。

| 方法与路径 | 请求 | 响应 | 错误 |
|------------|------|------|------|
| `POST /api/catseller/works/{workId}/video-quotes` | 登录+幂等；当前脚本/镜头 version 或快照摘要 | quoteId、图片数、单价、总积分、价格版本、失败规则、snapshotHash、expiresAt | `SHOT_CONTENT_INCOMPLETE`、`CONTENT_REJECTED`、`WORK_STATE_CONFLICT` |
| 视频任务接口内计费 | quoteId、snapshotHash | 任务与积分业务单关联 | `POINTS_INSUFFICIENT`、`QUOTE_EXPIRED`、`IDEMPOTENCY_CONFLICT` |

审核不新增客户端平行接口；审核状态随资源、任务和作品详情返回。后台通过作品/任务查询查看结果。

## 4. 数据表与迁移

- `catseller_billing_quotes`：work、图片数、单价、总价、价格版本、snapshotHash、失败规则、过期时间。
- 视频快照保存 quoteId/价格与失败策略版本。
- 复用公共 `point_billing_items`、`point_charge_orders`/积分账户和审核记录，不建 catseller 同义表。
- 唯一约束把业务幂等键、任务和积分订单关联，支持冻结/确认/退款不重复。

## 5. 业务规则与状态流转

- 总积分=`审核通过且选为当前图片的镜头数 × 当前单图积分`；后端重新统计，不相信客户端数量。
- 报价绑定脚本、当前图片、规格和价格版本哈希；任一变化或过期即 `QUOTE_EXPIRED`。
- 视频提交时在一致性边界内验证报价、余额、状态和活动任务，再冻结/扣费并创建任务。
- 任务成功确认积分；失败按报价保存的策略退款、部分退或不退，不能使用后来配置改历史。
- 重新生成是新报价和新积分动作；幂等重试不重复扣费。
- 审核复用阿里：输入资源/文本在任务前，生成图片/视频在结果入库后；失败关闭策略由配置决定。
- 积分冻结、确认、退款和审核等待作为视频工作流步骤处理；补偿参考 `SongGenerationCompensationService` 建独立幂等记录，重复执行不得重复退款。

## 6. 异常与日志

余额不足、报价过期、审核拒绝、审核服务异常分别使用稳定错误。日志记录业务单号、quoteId、taskId、金额/积分、策略版本和 traceId；不记录支付凭证、完整内容或签名 URL。补偿失败进入可重试记录并告警。

## 7. 依赖前置

依赖作品/镜头/图片、视频任务、公共积分冻结/确认/退款、阿里审核和后台配置。充值继续复用公共支付流程。

## 8. 建议实现步骤

1. 实现计费配置读取、报价快照和失效判断。
2. 对接公共积分业务单，建立幂等关联。
3. 在视频提交/成功/失败中编排积分状态。
4. 建立各内容节点审核策略和结果映射。
5. 完成重复提交、配置变化、审核异常和补偿测试。

## 9. 编码任务

| 任务 | 名称 | 状态 | 退出条件 |
|------|------|------|----------|
| T-B009-01 | 视频报价 | done | 图片数、单价、总价、版本和失效正确 |
| T-B009-02 | 积分协作 | done | 冻结/确认/失败处理幂等一致 |
| T-B010-01 | 输入审核 | done | 商品图、描述、形象、脚本按节点审核 |
| T-B010-02 | 输出审核 | done | 分镜图片、视频结果审核后才可用 |

## 10. 测试要求

Service：0/多镜头、价格变化、快照变化、余额不足、失败策略。集成：报价/视频提交并发、重复回调/退款、充值后新报价、审核拒绝/超时。契约：Flutter 显示服务器报价并按错误动作处理。Mapper：报价有效性与积分单唯一关系。

## 11. 验收标准

只按已确认分镜图数量计费；报价可审计且配置变化不影响历史；重复操作不重复扣费；失败按快照策略处理；阿里审核覆盖输入和 AI 输出。

## 12. 编码注意事项

暂未明确的失败规则必须后台配置，不自行假定全退。Redis 不作为扣费真源。审核异常不能静默放行。前端水印不替代后端审核。

## 13. 实现结果

已完成按已确认分镜图数量报价、报价版本/过期校验、积分冻结/确认/退回补偿，以及商品图、描述、形象、脚本、分镜图和视频的公共阿里审核接入。

恢复点：前后端联调中的报价、积分和审核错误处理。
