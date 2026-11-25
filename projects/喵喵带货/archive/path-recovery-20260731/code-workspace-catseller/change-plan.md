# catseller 变更计划

## 第一区块：进行中变更（pending / in_progress）

### [CHG-0007] 喵喵带货 AI 与计费配置只读兜底

- 版本号: v1.0.1
- 提出时间: 2026-07-25
- 类型: bug_fix
- 触发原因: Catseller 数据库未保存 AI 模型、Provider、计费项和计费绑定时，运行期没有读取 `ai-billing.json`，导致模型选择和视频报价失败。
- 计划内容:
  - 新增 Catseller 专属的数据库优先、JSON 只读兜底服务。
  - 让图片分析、AI 帮写、脚本、分镜、人物和视频模型选择，以及视频报价使用同一有效配置。
  - 新增后台完整配置查询和显式保存接口；只有后台 PUT 操作才允许把配置写入数据库。
  - 保持启动器跳过 Catseller，禁止普通查询和运行期兜底自动写库。
  - 增加数据库覆盖、停用覆盖、部分兜底、显式保存和 OpenAPI 测试。
- 不应改动范围:
  - 不修改数据库表、Flyway、Workflow、作品接口、Flutter 和其他 App 行为。
  - 不覆盖当前后端工作区中与本变更无关的用户修改。
- 数据库改动: 无；复用现有 AI 模型、Provider、计费项和计费绑定表。
- 状态: in_progress
- 关联恢复点: Java 编码 / CHG-0007

## 第二区块：本迭代历史变更（done / rolled_back）

### [CHG-0006] 移除旧百度视频与音乐业务

- 版本号: v1.0.1
- 提出时间: 2026-07-25
- 完成时间: 2026-07-25
- 类型: feature_modify
- 触发原因: 用户要求删除百度视频和所有音乐相关代码，使 catseller 只保留当前带货视频业务。
- 完成内容:
  - 删除旧百度智能集锦、视频解说/精剪、旧作品管理，以及完整写歌/翻唱/音乐作品链路。
  - 清理对应 API、model、params、Store、service、页面、路由、全局初始化和历史测试夹具。
  - 删除 Android/iOS 原生音频桥接、麦克风/音频/视频媒体库权限、专用资源与不再使用的 Flutter 依赖。
  - 主容器收敛为“首页 / 我的”，保留 `selling_video`、`CatsellerAPI` 和仍由带货视频使用的图片/相机能力。
- 验证结果:
  - 受控源码、测试、Android/iOS 配置和锁文件中的旧业务与被删依赖残留为 0。
  - `flutter analyze` 通过；`flutter test` 93 项通过、4 项按构建参数跳过。
  - Android Debug 与 iOS Simulator 构建通过，`git diff --check` 通过。
- 不应改动范围:
  - 不修改 `/Users/soul/code/lxwx/lxwx_service/lxwxservice` 与 `/Users/soul/code/lxwx/lxwx_admin`。
  - 不删除当前 catseller 带货视频填写页及其接口、模型和资源。
  - 保留用户已将 `pubspec.yaml` 版本调整为 `1.0.1+101` 的改动。
  - 不修改签名、第三方密钥、Git 远端或应用商店外部状态。
- 回滚说明: 受控删除和修改均可通过 Git 恢复；本轮未修改后端、Admin、签名或外部平台状态。
- 状态: done
- 关联恢复点: Flutter 编码 / CHG-0006 `done`

### [CHG-0001] 喵喵带货工程独立化

- 版本号: v1.0.0
- 提出时间: 2026-07-21 12:35
- 完成时间: 2026-07-21 14:27
- 类型: refactor
- 触发原因: 用户要求把从喵喵写歌复制的工程完整独立为“喵喵带货 / catseller”，并实施已确认计划。
- 完成内容:
  - Flutter 包、应用常量、请求头、MethodChannel、文件/缓存前缀、分享文案与测试夹具统一为 catseller。
  - Android/iOS 标识统一为 `com.lxwx.catseller`，支付回调为 `catselleralipay`，原生资源重新生成。
  - 友盟、阿里云一键登录、微信与 Apple IAP 改为新构建参数或安全降级，不复用旧凭据。
  - 接入临时猫咪购物袋图标、无嵌字首页背景；邀请海报旧嵌字清除并由 Flutter 渲染应用名。
  - 移除 Web/macOS/Windows 和复制遗留物，多渠道工具迁入 `tool/android_channels`。
  - 修正忽略规则并恢复锁文件、Gradle Wrapper 和安全配置示例的版本控制能力。
- 验证结果:
  - `dart format`、`flutter analyze`、`flutter test`、Android Debug、iOS Simulator、工具测试、`git diff --check` 全部通过。
  - 受控文件及资源名旧标识残留为 0；旧凭据哈希匹配为 0。
- 外部依赖: 服务端 App Code、协议站点与新 SDK/支付配置仍待外部提供；Git 远端已在 CHG-0002/0003 中闭合。
- 回滚说明: 受控文件可通过 Git 恢复；移出的复制遗留物保存在 `/Users/soul/code/lxwx/.catseller_cleanup_backup_20260721_1235/`，原 catsinger 工程资料仍完整。
- 状态: done
- 关联恢复点: workflow.md 第 13 阶段 `waiting_review`

### [CHG-0002] 配置 catseller Git 远端

- 版本号: v1.0.0
- 提出时间: 2026-07-21 14:30
- 完成时间: 2026-07-21 14:39
- 类型: feature_modify
- 触发原因: 用户提供新的 catseller 远程仓库地址 `https://codeup.aliyun.com/6a0a7b6af167bac7fd25b300/catseller.git`。
- 完成内容: 将当前仓库 `origin` 的 fetch/push URL 精确切换到用户提供的 catseller 地址，并同步 README 与流程记录。
- 验证结果: `git remote get-url origin` 与 `git remote -v` 均返回 catseller 地址；未执行 push。
- 不应改动范围: 业务代码、构建配置、提交历史、分支和远端内容均未改动。
- 回滚说明: 使用 `git remote set-url origin https://codeup.aliyun.com/6a0a7b6af167bac7fd25b300/catsinger.git` 恢复原地址。
- 状态: done
- 关联恢复点: workflow.md 第 13 阶段 `waiting_review`

### [CHG-0003] 重建本地 Git 并首次推送 catseller master

- 版本号: v1.0.0
- 提出时间: 2026-07-21 14:53
- 完成时间: 2026-07-21 14:55
- 类型: feature_modify
- 触发原因: 用户要求删除本地 Git 历史，并把当前 catseller 工程推送到新远程仓库。
- 完成内容:
  - 将旧 `.git` 移至 `/Users/soul/code/lxwx/.catseller_git_backup_20260721_145319/`，保留恢复能力。
  - 在当前工程重新初始化 `master`，以远端空工程 master 为父提交，提交 853 个 catseller 工程文件。
  - 使用普通快进将提交 `a04fcb42fda8cb0d142b57db4e3784224e8dd310` 推送到 `origin/master`，未使用 force。
- 验证结果: 本地 HEAD 与远端 master 均为 `a04fcb42fda8cb0d142b57db4e3784224e8dd310`；工作区干净；旧品牌与敏感文件检查为 0。
- 不应改动范围: 远端 `test` 分支、后端/Admin 仓库、应用商店发布状态均未修改。
- 回滚说明: 新 `.git` 可用仓库外备份替换恢复；远端提交不自动回滚。
- 状态: done
- 关联恢复点: workflow.md 第 13 阶段 `done`

### [CHG-0004] 复用现有 Android 签名生成 catseller 备案特征

- 版本号: v1.0.0
- 提出时间: 2026-07-21 15:29
- 完成时间: 2026-07-21 15:34
- 类型: feature_modify
- 触发原因: 用户明确确认 catseller 与 catsinger 共用现有 `lxwx.jks`，用于生成 catseller Android 正式包及备案公钥/证书 MD5。
- 完成内容:
  - 复用原工程本地 `key.properties` 配置，但继续由 Git 忽略，不输出密码或提交私钥。
  - 重新生成 `com.lxwx.catseller` 的 `1.0.0+1` Release APK，覆盖迁移前残留的 catsinger 产物。
  - 验证 APK v2 签名、包名、版本和证书有效期，提取完整 RSA 公钥模数与证书 MD5。
  - 新增 Android 备案构建计划和专项记录。
- 验证结果:
  - APK 包名为 `com.lxwx.catseller`，版本为 `1.0.0+1`，v2 签名验证通过。
  - 证书 MD5 为 `9916efc8aad967cb6429e75701d94527`，证书有效期至 2053-10-06。
  - `android/key.properties` 与 `android/app/lxwx.jks` 均由 Git 忽略，受控源码无新增修改。
- 外部依赖: catseller 专属第三方 SDK 配置、完整 Android 商店包和 iOS 发布签名仍待后续完成。
- 回滚说明: 删除本地忽略的 `android/key.properties` 和本轮生成的 APK，并恢复流程文档记录；不删除用户复制的 JKS。
- 状态: done
- 关联恢复点: workflow.md 第 16 阶段 `in_progress`

### [CHG-0005] 提取 catseller iOS APP 备案特征

- 版本号: v1.0.0
- 提出时间: 2026-07-21 15:40
- 完成时间: 2026-07-21 15:41
- 类型: feature_modify
- 触发原因: 用户提供阿里云 iOS APP 备案特征填写页面，需要 Bundle ID、证书公钥和 SHA-1。
- 完成内容:
  - 确认 Xcode Bundle ID 为 `com.lxwx.catseller`、Apple Team 为 `9F6QMS9A5Y`。
  - 排除 Team 不匹配的个人发布证书，从公司 Team 现有 App Store/Ad Hoc Profile 中核验 Apple Distribution 证书。
  - 提取 512 位十六进制 RSA 公钥模数和 40 位证书 SHA-1，并写入 iOS 构建记录。
  - 记录 catseller App ID/Profile 和发布私钥尚未就绪的正式 IPA 阻塞。
- 验证结果:
  - 证书主体、OU 与项目 Team 一致，证书有效期至 2027-07-06。
  - 公钥模数长度 512、SHA-1 长度 40，均为十六进制格式。
  - 未修改 Xcode 签名配置，未导入/复制 P12，未注册外部 Apple 资源或构建 IPA。
- 回滚说明: 删除新增的 iOS 构建记录并恢复 workflow/change-log；无证书或外部平台回滚。
- 状态: done
- 关联恢复点: workflow.md 第 16 阶段 `in_progress`

## 影响文件清单（聚合视图）

| 文件 | 影响来源 | 影响原因 | 处理方式 |
|------|----------|----------|----------|
| Flutter/Android/iOS 源码与测试 | CHG-0001 | 应用身份迁移 | 修改/重命名 |
| 品牌与原生生成资源 | CHG-0001 | 去除旧视觉标识 | 替换/重新生成 |
| Web/macOS/Windows 与复制遗留物 | CHG-0001 | 移动端工程边界 | 删除 |
| 发布工具、锁文件、Wrapper、配置示例 | CHG-0001 | 可复现构建 | 整理并纳入版本控制 |
| Git origin、README、流程记录 | CHG-0002 | 配置独立远端并解除阻塞 | 最小修改 |
| 本地 Git 元数据、远端 master、流程记录 | CHG-0003 | 重建本地历史并首次交付工程快照 | 备份/重建/快进推送 |
| 本地 Android 签名配置、Release APK、构建记录 | CHG-0004 | 生成 catseller APP 备案特征 | 本地配置/构建/验证 |
| iOS Distribution 证书公钥/SHA-1、构建记录 | CHG-0005 | 生成 catseller iOS APP 备案特征 | 只读核验/文档记录 |
| 旧百度视频/音乐代码、原生桥接、依赖、资源和测试 | CHG-0006 | 收敛为 catseller 带货视频业务 | 删除/简化/验证 |

## 不应改动范围（聚合视图）

- CHG-0001 不改：写歌业务语义、后端/Admin 仓库、Git 远端。
- CHG-0002 不改：业务代码、提交历史、当前分支和远端内容；不执行 push。
- CHG-0003 不改：远端 `test`、后端/Admin 和应用商店状态；不使用 force push。
- CHG-0004 不改：Flutter 业务、后端/Admin、iOS 签名和远端仓库；不提交 JKS 或密码。
- CHG-0005 不改：Xcode 签名配置、P12/私钥、Apple Developer 外部资源、IPA 和远端仓库。
- CHG-0006 不改：`selling_video` 带货视频、后端/Admin、Android 分发渠道、签名与用户版本变更。

## 完成记录

| 时间 | CHG-id | 操作 | 结果 |
|------|--------|------|------|
| 2026-07-21 12:35 | CHG-0001 | 创建变更记录并开始工程独立化 | `in_progress` |
| 2026-07-21 14:27 | CHG-0001 | 完成实现、清理和本地验证，归档并等待验收 | `done` |
| 2026-07-21 14:39 | CHG-0002 | origin 切换为 catseller 独立仓库并同步流程记录 | `done` |
| 2026-07-21 14:55 | CHG-0003 | 重建本地 Git，提交当前工程并快进推送至 origin/master | `done` |
| 2026-07-21 15:34 | CHG-0004 | 复用现有签名生成 catseller Release APK，并提取备案公钥与证书 MD5 | `done` |
| 2026-07-21 15:41 | CHG-0005 | 核验公司 Apple Distribution 证书，提取 iOS 备案公钥与 SHA-1 | `done` |
| 2026-07-25 | CHG-0006 | 删除旧百度视频与音乐业务，完成分析、测试、双平台 Debug 构建和残留扫描 | `done` |
