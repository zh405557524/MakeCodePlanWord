# catseller v1.0.0 工程独立化需求

- 应用身份统一为“喵喵带货 / catseller”。
- Flutter 包名与 App Code 使用 `catseller`；Android/iOS 使用 `com.lxwx.catseller`。
- 保留现有写歌业务，移除非移动平台与复制遗留物。
- 旧第三方配置不得复用；缺失新配置时必须安全禁用或降级。
- 本轮不修改后端和管理后台，只记录接口与上架依赖。
