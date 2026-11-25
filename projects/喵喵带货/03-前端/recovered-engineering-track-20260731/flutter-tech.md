# catseller Flutter 技术口径

> 补充实现轨迹：2026-07-31 从错误工作区别名 `catseller` 恢复；CHG 已按 `旧编号 + 20` 重编号。正确项目现有主文档继续优先，本文不得单独覆盖 `CURRENT.md` 指定入口。

- Dart package：`catseller`；应用名：`喵喵带货`；版本：`1.0.1+101`。
- Android/iOS ID：`com.lxwx.catseller`；MethodChannel：`catseller/*`；支付宝 Scheme：`catselleralipay`。
- `X-App-Code` 固定为 `catseller`；协议路径使用 `/legal/catseller/`。
- Umeng、阿里云号码认证和微信配置通过 `--dart-define` 注入，默认空值并禁用。
- iOS 固定启用 Apple IAP，不再使用构建开关；后端返回商品 ID，不在客户端硬编码正式商品。
- 仅支持 Android/iOS；新 ID 不迁移旧 App 本地数据。
- 主业务仅保留 `selling_video` 带货视频链路，以及商品图、模特图、相机、推广海报等通用图片能力。
- 旧百度智能集锦/视频解说/精剪、旧作品管理，以及写歌、翻唱、歌曲播放/下载/视频合成业务不再属于客户端。
- 客户端不再依赖 `video_player`、`video_thumbnail`、`video_compress`、`wechat_assets_picker`、`audioplayers` 和 `record`，也不再申请麦克风、音频或视频媒体库权限。
