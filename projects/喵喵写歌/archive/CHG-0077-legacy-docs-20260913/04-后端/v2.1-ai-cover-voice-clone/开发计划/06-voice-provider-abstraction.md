# 06 声音克隆 Provider 抽象与多渠道路由

> 任务族：`T-B006`
> 骨架任务：`T-B006-S`
> 真实任务：`T-B006-R`
> 编码策略：`skeleton_first`
> 当前骨架状态：`done`
> 当前真实状态：`done`
> 状态：`done`
> 代码域：`thirdparty/aimodel/music/voiceclone/`

## 0. 双阶段执行

### 0.1 骨架阶段

- 任务：`T-B006-S`
- 本阶段交付：定义厂家无关端口、Command/Result 和路由方法签名，并由 Fixture 返回固定 ACCEPTED/SUCCEEDED；不注册真实 Provider、不发网络请求或写调用台账。
- 固定数据集中放在独立 Skeleton Fixture，使用固定模型、音色、100/200 积分、审核通过状态和演示任务 ID；不得使用随机值或真实用户数据。
- 仅 `local/test` 配置启用，生产默认关闭并返回明确“功能未开放”，不得伪造成功。
- 禁止 Flyway、Entity、Mapper/Repository、数据库、积分、审核、上传、Provider、轮询、资源转存和作品创建；未实现步骤标记 `TODO(REAL-IMPLEMENTATION)`。

### 0.2 真实实现阶段

- 任务：`T-B006-R`
- 本阶段交付：接入真实多渠道实现、能力匹配、路由快照、状态归一化、超时、脱敏和调用台账。
- 进入条件：Flutter/Java 全部目标骨架已进入 `skeleton_review`，且用户明确确认“骨架已确认，开始真实实现”。

> 以下章节描述完整最终目标；数据表、迁移、真实审核、计费、Provider、资源和作品内容在骨架评审通过前均属于 `-R` 方案。

## 1. 功能定位与边界

定义厂家无关的训练、翻唱提交和任务查询协议，并通过真实 provider/model 路由。Provider 只适配厂家能力，不拥有用户任务、积分、资源审核或作品状态。

## 2. 核心接口

```java
public interface IVoiceCloneModelProvider {
    String providerCode();
    VoiceTrainingSubmitResult submitTraining(VoiceTrainingCommand command);
    VoiceCoverSubmitResult submitCover(VoiceCoverCommand command);
    VoiceProviderTaskResult queryTask(VoiceProviderTaskQuery query);
}
```

`VoiceCloneModelService` 根据 provider/model 获取启用实现、校验 TRAIN/VOICE_COVER 能力、写现有模型调用台账并归一化状态。

## 3. 命令与结果

命令只传厂家调用必要的受控输入、真实模型、显式参数、平台 requestId 和必要音色绑定。结果返回提交确定性、厂家任务 ID、厂家状态、资源候选和标准化错误；不返回或修改 Entity。

状态至少归一化为 ACCEPTED/QUEUED/RUNNING/SUCCEEDED/FAILED/UNKNOWN。UNKNOWN 与 SUBMIT_UNKNOWN 语义分开：前者可继续查询，后者表示无法确定是否已提交。

## 4. 路由与能力

- scene/modelOption 决定可公开模型，容量策略决定是否可接单。
- `provider/model` 必须在当前启用选项中，且能力匹配 TRAIN 或 VOICE_COVER。
- voiceModelVersion 必须存在精确 provider/model 的 AVAILABLE binding。
- 默认商家切换只影响新任务，不改变运行中路由快照，也不自动迁移旧音色。

## 5. 调用台账与安全

复用现有 AI 调用台账记录 provider、model、平台任务、厂家任务、状态、耗时、错误和重试次数。请求内容只保存脱敏摘要；密钥、受控 URL、模型文件 URL和原音频不入日志。

所有 HTTP 实现设置连接/读取/总超时，限制响应体和重定向。Provider 不负责下载最终资源；只返回候选供资源步骤处理。

## 6. 异常语义

- 明确厂家拒绝：FAILED，可释放积分。
- 提交超时且无法查询：SUBMIT_UNKNOWN，不自动重提。
- 查询暂时失败：可退避重试，不立即判业务失败。
- 未知状态：保留 rawStatus，按可观察状态处理。
- 不支持能力/模型：创建前配置错误，不调用厂家。

## 7. 实现步骤

1. 定义 provider interface、command/result/query 和错误分类。
2. 建立 Provider registry 与真实 provider/model 能力校验。
3. 接入现有模型调用台账。
4. 实现路由快照和 binding 校验接口。
5. 为算道及未来第二厂家建立契约测试夹具。

## 8. 测试要求

- provider/model 正确、未知、停用和能力不匹配。
- 同一音色跨模型无绑定时拒绝。
- 提交成功、明确失败、超时未知、查询未知状态。
- 调用台账脱敏和任务关联。
- Provider 测试证明无 Repository/积分/作品副作用。

## 9. 验收标准

- 新厂家只需新增 Provider 和 binding，不改用户音色主数据或 Controller。
- 真实 model 与 `VOICE_COVER` 业务类型完全分离。
- 运行中任务不受后台默认模型切换影响。

## 10. 编码注意事项

优先扩展当前 AI 模型框架，不复制一套账户/容量/调用台账。供应商资料未明确的字段和恢复能力不得猜测实现。
