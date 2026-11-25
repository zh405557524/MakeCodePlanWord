# 旧百度视频与音乐业务移除计划

状态：`done`（2026-07-25），等待用户验收。

## 删除范围

- 旧百度智能集锦、视频解说/精剪、旧作品列表与详情。
- 写歌、翻唱、音乐配置、歌曲作品、播放、下载、音频引用处理与歌曲视频合成。
- 对应 API、model、params、Store、service、页面、路由、全局初始化、原生媒体桥接、权限、资源和测试夹具。
- 仅被上述业务使用的 Flutter 依赖和 iOS Pods。

## 保留范围

- `lib/pages/selling_video/` 与 `CatsellerAPI` 带货视频接口。
- 商品图、模特图、相机、图片上传和邀请海报保存能力。
- Android `baidu` 分发渠道；它是安装包渠道标识，不属于旧百度视频业务。
- 用户已调整的 `pubspec.yaml` 版本 `1.0.1+101`。

## 完成证据

- 受控源码、测试、Android/iOS 配置和依赖锁中旧 `song/music/audio`、百度视频业务及被删依赖残留为 0。
- `flutter analyze`：通过，无问题。
- `flutter test`：93 项通过；4 个依赖真实阿里云构建参数的正向用例按配置跳过。
- `flutter build apk --debug`：通过。
- `flutter build ios --simulator --debug`：通过；本机 CocoaPods 有版本建议提示，但 pod install 与 Xcode 构建成功。
- `git diff --check`：通过。
