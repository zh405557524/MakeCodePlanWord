# CHG-0014 首页标签与歌曲二级页开发计划

## App

1. 增加首页列表元数据模型和 API，首页仅加载标签卡片并处理 loading/empty/error/success。
2. 新增 `pages/home/song_list` 独立歌曲二级页，接入按标签歌曲接口、返回、刷新和 not-found 状态。
3. 复用“我的作品”歌曲行；整行播放，更多菜单打开只读作品详情。
4. 注册命名路由并补模型、Controller、路由和 Widget 测试。

## Web/Admin

1. 标签模型、API Client 与 Repository 增加封面字段和上传方法。
2. 标签表展示封面状态，编辑弹窗支持预览、上传、替换和清空。
3. 补充 Repository 请求和页面交互测试。

## 验证

- 两个 Flutter 工程执行格式化、`flutter analyze`、相关 `flutter test` 和 `git diff --check`。
- App 生产代码分析、Controller 3 项、Store 9 项和首页/二级页 Widget 3 项通过；完整套件复现既有乱码断言与音频帧级联失败。
- Web/Admin `flutter analyze`、完整 48 项测试与差异检查通过。
