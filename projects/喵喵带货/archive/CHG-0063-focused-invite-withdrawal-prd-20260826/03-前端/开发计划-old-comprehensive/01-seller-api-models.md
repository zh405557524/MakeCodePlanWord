# Flutter 模块开发文档：带货 API 与数据模型

> 版本：`v1.0`｜状态：待评审｜覆盖：全部移动端任务基础｜工程：`/Users/soul/code/lxwx/catseller`

## 1. 功能定位与边界

建立喵喵带货统一的 Model、API、错误码、幂等、配置和本地草稿镜像，供首页、填写信息、作品、脚本和视频模块复用。本模块不实现页面，不把接口状态复制成第二套业务状态机。

## 2. 入口、文件与目录

```text
lib/
├── apis/seller.dart
├── models/data/seller_*.dart
├── models/params/seller_*.dart
├── store/seller_config.dart
├── store/seller_draft.dart
└── services/seller_polling.dart
```

修改 `apis/index.dart`、`models/data/index.dart`、`models/params/index.dart`、`store/index.dart`、`services/index.dart` 和 `global.dart` 注册公开配置 Store。沿用现有 `HttpService`、`BaseResponse`、`PageResult`、`ApiException`，不引入新网络框架。

## 3. 依赖前置

- 依赖 Java 全部 `/api/catseller/**` 契约、统一错误码和 `X-App-Code: catseller`。
- 公共请求始终携带 App 版本和 OS 类型；`X-OS-Version`、`X-Device-Model`、匿名安装级 `X-Device-Id` 仅在隐私同意后注入，撤回同意后移除。
- 私有接口复用现有 JWT 刷新；创建、提交、重生成、恢复接口携带 `Idempotency-Key`。
- 本地使用 GetStorage/Hive，只保存 `resourceId`、顺序、表单值和服务端版本，不保存永久签名 URL。

## 4. 视觉参考与设计稿分析

本模块无独立页面。它必须支持参考图 02～10 的加载、空、运行、失败、完成和历史版本状态。Figma 已跳过，字段展示以 PRD、原图和最新 UI 为准；API 层不得硬编码“30 秒完成”或独立配音/字幕步骤。

## 5. 涉及模块与类

| 类 | 核心内容 |
|----|----------|
| `SellerAPI` | 首页、案例、描述、形象、作品、脚本、镜头、图片、报价、视频接口 |
| `SellerWorkSummary` | workId、状态、封面、更新时间、有效期 |
| `SellerWorkDetail` | 输入、版本、任务、脚本、镜头、报价、视频、actions |
| `SellerProductInput` | 商品图、描述、比例、时长、形象、version |
| `SellerShot` | 顺序、画面、可空口播、当前图片、version |
| `SellerStoryboardImage` | resourceId、来源、审核、aiGenerated、有效期 |
| `SellerTaskProgress` | 类型、用户可见主状态、业务阶段、进度、失败原因、nextPollAfterMs；不暴露工作流步骤实例 |
| `SellerVideoQuote` | 图片数、单价、总积分、价格版本、失败规则、快照哈希、有效期 |
| `SellerVideoResult` | 视频版本、资源、aiGenerated、有效期 |
| `SellerConfigStore` | 图片限制、比例/时长、功能开关、水印和提示文案 |
| `SellerDraftStore` | 未提交表单的轻量镜像，按 workId 隔离 |
| `SellerPollingService` | 单详情页轮询、退避和生命周期停止 |

所有枚举显式处理未知值；未知状态显示可恢复错误并重新请求，不默认当作失败或完成。

## 6. 接口与数据流

| 业务 | 接口 |
|------|------|
| 首页/案例/配置 | `GET /api/catseller/home`、`/cases`、`/cases/{caseId}`、`/config` |
| AI 帮写 | `POST /description-tasks`、`GET /description-tasks/{taskId}` |
| 形象 | `GET/POST /personas`、`POST/GET /persona-tasks...`、`PATCH/DELETE /personas/{id}` |
| 作品 | `POST /works`、`PATCH /works/{id}/input`、`GET /works`、`GET/DELETE /works/{id}` |
| 内容/版本 | `POST /works/{id}/content-tasks`、`/versions`、`/content-tasks/regenerate`、脚本历史/恢复 |
| 镜头/图片 | 镜头 PATCH、图片历史、生成、上传替换、当前图片、失败镜头重试 |
| 视频 | 视频报价、创建任务、重试和结果接口 |

请求流程固定为：Controller 组装参数 → API 调用 HttpService → 解析统一响应 → Model 显式校验 → Controller 更新页面状态。API 不直接弹 Toast、不持有 BuildContext。

错误码至少映射：`AUTH_REQUIRED`、`WORK_NOT_FOUND`、`WORK_STATE_CONFLICT`、`WORK_RUNNING_LOCKED`、`CONTENT_REJECTED`、`ASSET_INVALID_OR_EXPIRED`、`SHOT_CONTENT_INCOMPLETE`、`POINTS_INSUFFICIENT`、`QUOTE_EXPIRED`、`IDEMPOTENCY_CONFLICT`、`GENERATION_PROVIDER_BUSY`、`GENERATION_FAILED`、`RESOURCE_HIDDEN`、`RESOURCE_DELETED`。

## 7. 现有工程参考点

- `services/http.dart`：请求头、401 刷新、BaseResponse 和异常映射。
- `apis/resource.dart`：直传、进度和资源结果解析。
- `models/responses/*`：统一响应和分页。
- `store/config.dart`：公开配置加载与缓存。
- `pages/works/controller.dart`：分页、刷新和 ApiException 处理方式；只复用模式，不复用旧业务字段。

## 8. 建议实现步骤

1. 先定义状态枚举和 Model 单元测试，再实现解析。
2. 实现 SellerAPI 分域方法和请求参数，所有写操作支持幂等头。
3. 实现公开配置 Store、安全默认值和版本化缓存。
4. 实现草稿镜像，登录用户/workId 隔离并支持退出登录清理。
5. 实现单实例详情轮询工具，页面销毁、后台、终态时停止。
6. 增加错误码映射、未知字段兼容和契约测试。

## 9. 详细编码任务清单

| 子任务 | 名称 | 状态 | 验收结果 |
|--------|------|------|----------|
| API-01 | 状态枚举与核心 Model | pending | 正常、缺失、未知字段均可控解析 |
| API-02 | SellerAPI 全接口 | pending | 方法、路径、鉴权和幂等与 Java 一致 |
| API-03 | 配置 Store | pending | 公开配置失败使用确认过的安全默认值 |
| API-04 | 草稿镜像 | pending | 不把本地状态当作服务端成功 |
| API-05 | 详情轮询 | pending | 前台单页轮询，后台/终态停止 |
| API-06 | 错误与契约测试 | pending | 所有确认错误码可形成页面动作 |

## 10. 验收标准

- 所有 Java 计划接口都有唯一 Flutter 方法，不存在平行重复封装。
- `X-App-Code`、版本、OS、Token、幂等键正确注入；设备审计头受隐私同意控制且不使用系统硬件唯一标识。
- Model 不保存永久 URL，AI 资源保留 `aiGenerated` 和有效期。
- 本地镜像按用户和作品隔离，退出登录不泄露上个用户数据。
- 轮询使用 `nextPollAfterMs`，网络失败退避，不写假终态。
- `dart format`、`flutter analyze`、`flutter test` 通过。

## 11. 编码注意事项

- 不在 API 层决定页面路由、计费总价或任务成功。
- 不自动重试会创建任务/扣费的 POST；由幂等键和明确用户动作控制。
- 不把 Provider taskId、签名 URL 或内部错误堆栈长期持久化。
- 不解析后端 `PENDING/RUNNING/PAUSED/SUCCESS/FAILED/SKIPPED` 步骤实例；Flutter 只消费聚合后的任务主状态和业务阶段。
- 接口字段变化先同步 Java 技术文档，不在客户端猜字段。

恢复点：`03-前端/开发计划/01-seller-api-models.md`。
