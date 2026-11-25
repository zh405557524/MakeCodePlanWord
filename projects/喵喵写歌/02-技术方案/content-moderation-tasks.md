# 统一审核任务：音色头像与昵称

更新日期：2026-09-16。范围仅 Catsinger 音色头像、昵称；不迁移描述或其他素材，不修改管理后台。

## 接口

请求均需 `X-App-Code: catsinger` 和当前用户 Bearer 登录凭据。

- `POST /api/content-moderation/tasks`：提交后快速返回持久化任务，不等待第三方审核。
- `GET /api/content-moderation/tasks/{taskId}`：只读查询，仅任务所属 App、用户可访问。

提交昵称示例：

```json
{"scene":"VOICE_PROFILE_NAME","text":"审核联调测试","idempotencyKey":"每次内容变更生成的新键"}
```

提交头像示例：

```json
{"scene":"VOICE_PROFILE_AVATAR","resourceId":123,"idempotencyKey":"独立的头像审核键"}
```

头像仅接受当前用户已就绪的 `song-assets/images` 资源，不接受外部 URL。昵称去除首尾空白，保留既有 100 字符上限。同一 App、用户及幂等键对应同一输入；不同输入返回冲突。网络提交失败重试使用原键，不重复创建任务。

响应 `data` 字段：`taskId`、`scene`、`resourceId`（昵称为空）、`status`、`reason`、`retryable`、`pollAfterSeconds`（3）、`reviewMode`。

| 状态 | 客户端行为 |
| --- | --- |
| QUEUED / PROCESSING | 显示处理中，每 3 秒查询；后台暂停、前台恢复 |
| APPROVED | 当前内容允许进入下一步 |
| REJECTED | 明确提示审核不通过，用户更换内容；不自动重试 |
| FAILED | 明确提示服务异常，允许用户发起新任务 |

`reviewMode`：`PROVIDER` 为真实渠道策略，`MOCK` 为模拟，`BYPASSED` 为策略未执行第三方审核，不得显示成第三方通过。待人工复核始终阻断下一步。

## 保存与异步执行

音色创建、更新请求新增可选 `avatarReviewTaskId` / `nameReviewTaskId`。服务端核验 App、用户、场景、头像资源或规范化昵称完全一致且任务通过。复用时保留关联审核记录，不重复调用 Provider。缺少任务 ID 的旧客户端继续同步审核；描述仍独立走原审核。

新增 common 迁移 `V4.11__content_moderation_tasks.sql`。任务保存输入、策略快照、幂等键、状态、租约、期限、关联审核记录；事实仍在 `content_moderation_records`。数据库原子抢占，第三方调用不占长事务；单次租约/中断期限 60 秒、总期限 5 分钟。明确网络故障最多额外重试两次；进程重启后过期租约可恢复，已有审核事实优先复用。任务到期由扫描器收敛为失败，迟到执行受租约令牌保护。

头像上传完成立即本地预览；上传/审核中动画旋转；拒绝可重新上传、服务异常可重试。昵称失焦送审，继续按钮补交；编辑立即失效旧结果，迟到结果不覆盖新输入。头像和昵称错误分别显示。

不修改歌曲和参数草稿；未提交训练的音色定制仍按既有退出丢弃逻辑处理。

## 验证与发布

- Flutter 独立目标测试 39 项通过，`flutter analyze` 无问题，Debug APK 构建通过；未覆盖已有 `test/widget_test.dart` 修改。
- 后端 29 项目标测试通过（新接口集成 7、真实联调 1、音色业务 9、阿里云适配器 12），覆盖幂等、只读查询、归属、跨 App 隔离、图片绑定、策略快照、保存复用、并发领取、过期恢复、失败类型与人工复核。
- 真实联调已通过：昵称“审核联调测试”经过 `LOCAL_DFA+ALIYUN_GREEN`，项目头像编辑图标经过 `ALIYUN_GREEN`，均为 `APPROVED` 且审核事实存在第三方请求 ID。最终运行任务提交分别 5ms / 3ms。图片走现有直传准备、OSS PUT、完成确认链；测试业务记录仅存在 H2。测试结束清理该次登记的测试图片，不涉及用户素材。
- 真实渠道联调由显式开关 `MODERATION_TASK_LIVE=true` 启用；使用 H2 隔离业务数据，仅白名单读取本地审核与 OSS 配置，不加载私有数据库配置。测试图通过 `MODERATION_TASK_TEST_IMAGE` 指定获准非个人图片。默认测试不调用付费渠道。
- 必须后端先发布（含迁移），App 后发布。本轮不部署正式服。新 App 依赖新任务接口，不应在后端尚未更新时发布。
- Android 真机完整上传、切后台与下一步流程需在新版后端运行后验收；自动化与真实 Provider 测试不等同真机验收。
