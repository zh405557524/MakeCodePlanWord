# catseller Android 构建记录

## 1. 应用身份

- 应用名称：喵喵带货
- applicationId：`com.lxwx.catseller`
- versionName：`1.0.0`
- versionCode：`1`
- 备案后台域名：`www.lxwanxiang.com`

## 2. 签名配置

- JKS：`android/app/lxwx.jks`（Git 忽略）
- 配置：`android/key.properties`（Git 忽略）
- 别名：`lxwx`
- 证书主体：`CN=lxwx, OU=lxwx, O=lxwx, L=Shanghai, ST=Shanghai, C=CN`
- 密钥算法：RSA 2048-bit
- 证书有效期：2026-05-21 03:11:05 UTC 至 2053-10-06 03:11:05 UTC
- 当前 APK 签名方案：v2
- 决策：经用户明确确认，catseller 与 catsinger 共用该签名证书。

## 3. APP 备案特征

- 安卓平台软件包名称：`com.lxwx.catseller`
- 证书 MD5 指纹：`9916efc8aad967cb6429e75701d94527`
- 公钥（RSA 模数，十六进制，不含 `Modulus=` 前缀）：

```text
D3AE4B0D6894AF0A6B612FC062A361C0D6D7CD1EEAA97C333B7D1D81C8AE240890202717AF9548E6ED4DBFB3B98336F0FE3D160E87BA8B23905A597E614315B3BFA50441B34764928AFB08F956F70B1BF67CF23AA8D7B71F254F5A38CB636A8B89F543DBAC525A4CB334F22AE7E27028843ED1C144B8E47B3C2B0FB697572C8DCC970F839CA327754BE64F1CD8BAB0552DE6C45AEF11FDB4641723CC5CD658DA671ED33CCE354CB85D0F838CFF631B0178AFD7E2D96D0A1227A1E563827D0C694049838545271B136221CA966DC812DCCF42A65ADDE1AB223243E42FF64D3A68A0CFA06CEA2EC498167D27B72E1BBD4397FFAEF35E9F37AA3C23731DB5287E2B
```

## 4. 构建与验证

```bash
flutter build apk --release
/Users/soul/data/android_sdk/build-tools/37.0.0/apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk
```

验证结果：

- Release 构建成功，产物大小 `56,209,746` 字节。
- APK 包名为 `com.lxwx.catseller`，不是迁移前残留的 `com.lxwx.catsinger`。
- APK 版本为 `1.0.0+1`。
- v2 签名验证通过，签名者数量为 1。
- JKS 与 `key.properties` 均继续被 Git 忽略，未提交密码或私钥。

## 5. 当前限制

- 本包用于 Android APP 备案特征核验。
- catseller 专属 Umeng、阿里云号码认证、微信等正式参数仍未提供，不应将本包直接视为最终商店发布包。
- 完整上架前仍需安装冒烟、渠道包/AAB 验证、隐私合规核验及应用商店检查。
