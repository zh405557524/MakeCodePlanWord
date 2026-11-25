# catseller v1.0.0 工程独立化需求

> 补充实现轨迹：2026-07-31 从错误工作区别名 `catseller` 恢复；CHG 已按 `旧编号 + 20` 重编号。正确项目现有主文档继续优先，本文不得单独覆盖 `CURRENT.md` 指定入口。

- 应用身份统一为“喵喵带货 / catseller”。
- Flutter 包名与 App Code 使用 `catseller`；Android/iOS 使用 `com.lxwx.catseller`。
- 保留现有写歌业务，移除非移动平台与复制遗留物。
- 旧第三方配置不得复用；缺失新配置时必须安全禁用或降级。
- 本轮不修改后端和管理后台，只记录接口与上架依赖。
