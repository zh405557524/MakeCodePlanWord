# catseller 工作空间流程状态

> 用途：记录喵喵带货 Flutter 移动端工程的流程状态、恢复点与外部依赖。

## 1. 项目级配置

| 字段 | 当前值 |
|------|--------|
| `currentProject` | `catseller` |
| `currentVersion` | `v1.0.1` |
| `referenceProject` | `/Users/soul/code/lxwx/catsinger` |
| `frontendRepo` | `/Users/soul/code/lxwx/catseller` |
| `backendRepo` | `/Users/soul/code/lxwx/lxwx_service/lxwxservice` |
| `flutterChannel` | `stable` |
| `targetPlatforms` | `Android, iOS` |

## 2. 当前流程

| 字段 | 内容 |
|------|------|
| 当前阶段 | `14 Java 编码` |
| 当前步骤 | `CHG-0007 喵喵带货 AI 与计费配置只读兜底` |
| 当前步骤状态 | `in_progress` |
| 当前恢复点 | 已确认 app-configs 支持只读兜底，ai-billing 运行期仍只查数据库；开始实现 Catseller 专属有效配置服务 |
| 下一步默认动作 | 完成配置读取、后台显式保存、测试与差异检查 |

## 3. 总体流程列表

| 序号 | 流程项 | 当前状态 | 说明 |
|------|--------|----------|------|
| 0 | 变更校准 | `done` | CHG-0001 已归档 |
| 1 | 需求分析 | `done` | 用户已确认完整实施计划 |
| 2 | 需求文档生成 | `done` | 见 `01-需求/requirements.md` |
| 3 | 需求文档检测 | `skipped` | 本轮为已确认的工程迁移计划 |
| 4 | 设计输入 | `done` | 临时猫咪购物袋图标 + 现有深色视觉风格 |
| 5 | 技术方案 | `done` | 见 `03-前端/flutter-tech.md` |
| 6 | 工时评估 | `skipped` | 用户未要求 |
| 7 | Flutter 技术文档 | `done` | 工程身份、原生标识和外部配置边界已记录 |
| 8 | Java 技术文档 | `done` | 仅记录外部接口依赖，不修改后端 |
| 9 | Flutter 总体开发计划 | `done` | 见 `03-前端/flutter-dev-plan.md` |
| 10 | Java 总体开发计划 | `skipped` | 本轮不改后端 |
| 11 | Flutter 模块开发文档 | `done` | 见 `03-前端/开发计划/project-identity-migration.md` 与 `legacy-media-removal.md` |
| 12 | Java 模块开发文档 | `skipped` | 本轮不改后端 |
| 13 | Flutter 编码 | `done` | CHG-0006 已完成并等待用户验收 |
| 14 | Java 编码 | `in_progress` | CHG-0007 实现数据库优先、JSON 只读兜底 |
| 15 | 联调与测试 QA | `done` | analyze、93 项测试、双平台 Debug 构建、残留扫描和差异检查通过；4 项真实配置用例跳过 |
| 16 | 构建与打包 | `pending` | 历史备案特征已完成；CHG-0006 后正式包需重新构建，外部签名阻塞仍保留 |
| 17 | 应用商店上架 | `pending` | 商店、协议和 SDK 配置未就绪 |
| 18 | 发布与版本管理 | `pending` | 代码仓库初始化完成；正式 App 发布策略仍待后续确认 |
| 19 | 上线监控与迭代 | `pending` | 待后续接入 |

## 4. 当前变更登记

| CHG-id | 标题 | 类型 | 版本号 | 状态 | 关联阶段 |
|--------|------|------|--------|------|----------|
| `CHG-0001` | 喵喵带货工程独立化 | `refactor` | `v1.0.0` | `done` | 13 Flutter 编码 |
| `CHG-0002` | 配置 catseller Git 远端 | `feature_modify` | `v1.0.0` | `done` | 13 Flutter 编码 |
| `CHG-0003` | 重建本地 Git 并首次推送 catseller master | `feature_modify` | `v1.0.0` | `done` | 13 Flutter 编码 |
| `CHG-0004` | 复用现有 Android 签名生成 catseller 备案特征 | `feature_modify` | `v1.0.0` | `done` | 16 构建与打包 |
| `CHG-0005` | 提取 catseller iOS APP 备案特征 | `feature_modify` | `v1.0.0` | `done` | 16 构建与打包 |
| `CHG-0006` | 移除旧百度视频与音乐业务 | `feature_modify` | `v1.0.1` | `done` | 13 Flutter 编码 |
| `CHG-0007` | 喵喵带货 AI 与计费配置只读兜底 | `bug_fix` | `v1.0.1` | `in_progress` | 14 Java 编码 |

## 5. 当前步骤需加载规则

- `00-核心工作流程.mdc`
- `13-Flutter编码索引.mdc`
- `/Users/soul/code/lxwx/catseller/.cursor/rules/10-编码工作流程.mdc`
- `/Users/soul/code/lxwx/catseller/.cursor/rules/03-编码规范.mdc`
- `/Users/soul/code/lxwx/catseller/.cursor/rules/task-logic_change.mdc`
- `/Users/soul/code/lxwx/catseller/.cursor/rules/task-refactor.mdc`
- `/Users/soul/code/lxwx/catseller/.cursor/rules/11-测试规则.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/00-编码工作流程.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/02-项目结构目录.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/03-编码规范.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/04-路由与控制器规则.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/05-数据库与持久化.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/07-新接口开发.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/09-大功能先规划再编码.mdc`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/.cursor/rules/12-Bug修复任务.mdc`

## 6. 当前步骤依赖文件

- `change-plan.md`
- `change-log.md`
- `03-前端/flutter-tech.md`
- `03-前端/flutter-dev-plan.md`
- `03-前端/开发计划/legacy-media-removal.md`
- `/Users/soul/code/lxwx/catseller/AGENTS.md`
- `/Users/soul/code/lxwx/catseller/lib/`
- `/Users/soul/code/lxwx/catseller/android/`
- `/Users/soul/code/lxwx/catseller/ios/`
- `/Users/soul/code/lxwx/catseller/test/`
- `/Users/soul/code/lxwx/catseller/pubspec.yaml`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/app/catseller/config/`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/java/com/lxwx/narrateservice/admin/catseller/`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/service-data/apps/catseller/ai-billing.json`
- `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/test/java/com/lxwx/narrateservice/`

## 7. 当前步骤生成文件

- `change-plan.md`
- `change-log.md`
- `workflow.md`
- `03-前端/flutter-tech.md`
- `03-前端/flutter-dev-plan.md`
- `03-前端/开发计划/legacy-media-removal.md`

## 8. 额外注意事项

- CHG-0006 按用户最新要求删除写歌/音乐业务，以及旧百度智能集锦视频业务；保留当前 catseller 带货视频链路。
- Android `baidu` 分发渠道属于安装包渠道标识，不是百度视频业务，本轮保留。
- 用户原有 `pubspec.yaml` 版本 `1.0.1+101` 和未跟踪 `docs/` 均已保留。
- 新 Bundle ID 作为全新 App，不迁移旧登录态、缓存、支付挂单或本地作品。
- Git `origin` 已指向 catseller 独立仓库；`master` 基线为已推送提交 `a04fcb4`，CHG-0006 当前尚未提交。
- 旧本地 Git 元数据保存在 `/Users/soul/code/lxwx/.catseller_git_backup_20260721_145319/`；远端 `test` 分支未修改。
- 用户已明确确认 catseller 与 catsinger 共用 `lxwx.jks`；备案特征必须以本轮重新生成的 catseller APK 为准，不使用迁移前残留包。

## 9. 阻塞项

| 阻塞项 | 影响 | 处理方式 |
|--------|------|----------|
| 后端尚未注册 `X-App-Code: catseller` | 真实接口不可联调 | 后端另行配置 |
| catseller 协议/备案/客服页面未部署 | 合规页面不可正式验收 | Web/Admin 另行部署 |
| Umeng、阿里云号码认证、微信、IAP 新配置未提供 | 对应能力保持禁用或降级 | 上架前提供新配置 |
| catseller 与 catsinger 共用 `lxwx.jks` | 签名泄露或丢失会同时影响两个 App | 用户已明确接受复用；JKS、密码和 `key.properties` 必须继续保持 Git 忽略 |
| catseller App ID/App Store Profile 尚未在本机就绪，且公司 Distribution 私钥未出现在可用签名身份中 | 暂不能生成可提交 App Store 的 IPA | 在 Apple Developer Team `9F6QMS9A5Y` 注册/确认 App ID、创建 Profile，并安全导入匹配 P12 |

## 10. 执行记录

| 时间 | 阶段/步骤 | 操作 | 结果 |
|------|-----------|------|------|
| 2026-07-21 12:35 | 13 Flutter 编码 / CHG-0001 | 建立独立工作区、确认原工程备份与迁移边界 | `in_progress` |
| 2026-07-21 14:27 | 13 Flutter 编码 / CHG-0001 | 完成工程身份迁移、外部配置隔离、品牌资源替换与清理 | `done` |
| 2026-07-21 14:27 | 15 联调与测试 QA / CHG-0001 | 通过 analyze、268 项测试、Android Debug、iOS Simulator、工具测试与残留扫描 | `done` |
| 2026-07-21 14:39 | 13 Flutter 编码 / CHG-0002 | 将 Git origin 切换到用户提供的 catseller 独立仓库；未执行 push | `done` |
| 2026-07-21 14:53 | 13 Flutter 编码 / CHG-0003 | 确认远端 master 为空工程提交，登记 Git 重建与安全推送方案 | `in_progress` |
| 2026-07-21 14:55 | 13 Flutter 编码 / CHG-0003 | 备份旧 `.git`、重建 master、提交 853 个工程文件并普通快进推送；远端校验一致 | `done` |
| 2026-07-21 15:19 | 16 构建与打包 / Android 备案签名材料核验 | 检查用户复制的 JKS、签名配置和原工程证书一致性 | `blocked`：复制的是 catsinger 原签名，未用于 catseller |
| 2026-07-21 15:29 | 16 构建与打包 / CHG-0004 | 用户明确确认复用 `lxwx.jks`，登记 Android 备案签名构建 | `in_progress` |
| 2026-07-21 15:34 | 16 构建与打包 / CHG-0004 | 生成 catseller Release APK，核验包名/版本/v2 签名并提取备案公钥与证书 MD5 | `done` |
| 2026-07-21 15:40 | 16 构建与打包 / CHG-0005 | 核对 iOS Bundle ID、项目 Apple Team、本机证书和现有 Provisioning Profile | `in_progress` |
| 2026-07-21 15:41 | 16 构建与打包 / CHG-0005 | 从公司 Distribution 证书提取 iOS 备案公钥与 SHA-1，记录正式 IPA 阻塞 | `done` |
| 2026-07-25 | 13 Flutter 编码 / CHG-0006 | 登记旧百度视频与音乐业务删除范围，开始依赖边界盘点 | `in_progress` |
| 2026-07-25 | 13 Flutter 编码 / CHG-0006 | 删除旧业务代码、路由、依赖、原生桥接、权限、资源与历史测试夹具 | `done` |
| 2026-07-25 | 15 联调与测试 QA / CHG-0006 | 通过 analyze、93 项测试、Android Debug、iOS Simulator、残留扫描与 diff 检查 | `done` |
| 2026-07-25 | 14 Java 编码 / CHG-0007 | 登记数据库优先、JSON 只读兜底修复并核对后端规则与现有实现 | `in_progress` |
