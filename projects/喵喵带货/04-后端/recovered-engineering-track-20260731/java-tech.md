# catseller 外部后端依赖（本轮不修改服务端）

> 补充实现轨迹：2026-07-31 从错误工作区别名 `catseller` 恢复；CHG 已按 `旧编号 + 20` 重编号。正确项目现有主文档继续优先，本文不得单独覆盖 `CURRENT.md` 指定入口。

- 服务端需注册 `X-App-Code: catseller` 并提供对应公开配置。
- 支付商品需由后端返回 catseller 对应的 App Store/支付宝商品标识。
- 协议、隐私、算法备案与客服页面需部署到 catseller 路径。
- Umeng、阿里云号码认证、微信和 Apple IAP 新配置需在上架前提供。
