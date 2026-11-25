# catseller 研发变更日志

## v1.0.1 - 2026-07-25

### Changed

- [CHG-0006] 主容器收敛为“首页 / 我的”两栏，首页继续使用当前 `selling_video` 带货视频入口。
- 会员权益、权限和分享等残留文案改为 catseller 带货视频语义。
- 图片缓存与媒体权限收敛到现存商品图、模特图、相机和推广海报能力。

### Removed

- 删除旧百度智能集锦/视频解说/精剪、旧作品管理的 API、模型、页面、Store、服务、路由和测试。
- 删除写歌、翻唱、音乐配置、歌曲作品、播放器、下载、音频引用处理和歌曲视频合成链路。
- 删除对应 Android/iOS 原生音频桥接、麦克风/音频/视频媒体权限和 153 个专用图片资源。
- 删除 `video_player`、`video_thumbnail`、`video_compress`、`wechat_assets_picker`、`audioplayers`、`record` 等不再使用的依赖。

## v1.0.0 - 2026-07-21

### Added

- [CHG-0001] 新增 catseller 独立工作区、身份/安全降级测试和 Android 多渠道工具。
- 新增临时猫咪购物袋应用图标、无嵌字首页背景和无旧品牌嵌字的邀请海报背景。
- 新增安全的 Android 签名与蒲公英配置示例，并恢复 `pubspec.lock`、Gradle Wrapper 的版本控制。

### Changed

- Flutter 包名、App Code、请求头、Channel、缓存/文件前缀、品牌文案统一为 `catseller` / `喵喵带货`。
- Android/iOS 应用标识统一为 `com.lxwx.catseller`，支付回调 Scheme 改为 `catselleralipay`。
- Umeng、阿里云一键登录、微信和 Apple IAP 改为构建参数配置及缺省安全降级。
- 版本重置为 `1.0.0+1`，README、AGENTS 和发布脚本同步为 catseller。
- [CHG-0002] Git `origin` 切换到 catseller 独立仓库，并解除新远端缺失阻塞；未执行 push。
- [CHG-0003] 备份并重建本地 Git，将完整 catseller 工程作为提交 `a04fcb4` 普通快进推送至远端 `master`。
- [CHG-0004] 经用户确认复用现有 `lxwx.jks`，生成并验证 `com.lxwx.catseller` Release APK，输出 Android APP 备案公钥与证书 MD5；签名文件和密码配置继续保持 Git 忽略。
- [CHG-0005] 核验公司 Apple Team `9F6QMS9A5Y` 的 Distribution 证书，输出 `com.lxwx.catseller` 的 iOS APP 备案公钥与 SHA-1，并记录 App ID/Profile 和发布私钥阻塞。

### Removed

- 移除 Web、macOS、Windows 平台模板。
- 移除 catseller 副本中的旧构建/合规资料、IDE 文件、签名证书和真实上传配置；可恢复副本保留在仓库外。
- 删除仓库误提交的 iOS `.p12`，原 catsinger 工程对应文件仍保留。

### Rolled back

- （暂无）
