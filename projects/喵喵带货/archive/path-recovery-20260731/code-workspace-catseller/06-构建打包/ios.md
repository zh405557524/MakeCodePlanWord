# catseller iOS 构建与备案记录

## 1. 应用身份

- 应用名称：喵喵带货
- Bundle ID：`com.lxwx.catseller`
- 版本：`1.0.0+1`
- Apple Developer Team：`9F6QMS9A5Y`
- 团队主体：Shenzhen Lingxi Wanxiang Technology Co., Ltd

## 2. APP 备案证书

项目 Apple Team 与现有公司 Apple Distribution 证书的 OU 均为 `9F6QMS9A5Y`。该证书已嵌入公司 Team 的现有 App Store/Ad Hoc Provisioning Profile，可作为 catseller 后续发布证书；不同 App ID 可共用同一 Team 发布证书。

- 证书主体：`Apple Distribution: Shenzhen Lingxi Wanxiang Technology Co., Ltd (9F6QMS9A5Y)`
- 密钥算法：RSA 2048-bit
- 证书有效期：2026-07-06 12:04:34 UTC 至 2027-07-06 12:04:33 UTC
- 证书 SHA-1：`a1b68bdd8487c563361b3a9295d2585a2c710af5`
- 公钥（RSA 模数，十六进制，不含 `Modulus=` 前缀）：

```text
BF7330888DA217A5803408258DDC7D3BFFD08745699ACE94F1E7A773454F4BC9A5436B00789C65330CDE68EBC1FDEDD40BA0FA4F4CE06D6A8DB55DCE046E05EC6462D1D43E74BC50741356FECFDF1066444AC27380558ABD95A5B4DE5E0B8D3B35F5CFC1AB07DFA03F434C0A004DFBCAF192F6CB0901F0937B20AE48FF4E01CE6BB6972E6BD8BBA9FD2BC5E8F374DC84AEFEB55330C3A61FA8FB34DC058BC9A871002A74D453FA787A1B9D12E645DBF54C2DB62C2F6D05A1FEE25A03D370AC40C45A2E3AF90C61974D18B176615B015D15EA0459F9B81227526336BDFF5C5EE3AC1A7AAAD65C5DCE72141568DDD871EA6916E3823B240E01820722A2900D2FCD
```

## 3. 备案页面填写值

- iOS 平台 Bundle ID：`com.lxwx.catseller`
- 公钥：使用上方 512 位十六进制 RSA 模数
- 证书 SHA-1 指纹：`a1b68bdd8487c563361b3a9295d2585a2c710af5`

## 4. 核验与排除

- Xcode 工程的 Debug/Profile/Release 配置均使用 `com.lxwx.catseller` 和 Team `9F6QMS9A5Y`。
- 本机另有一个个人 Team 的 Apple Distribution 证书，但其 Team 不匹配，未用于 catseller 备案值。
- 备案 SHA-1 已去除冒号并校验为 40 位十六进制；公钥模数已校验为 512 位十六进制。

## 5. 正式 IPA 剩余阻塞

- Apple Developer 后台尚需注册/确认 `com.lxwx.catseller` App ID。
- 本机尚无 catseller 对应的 App Store Provisioning Profile。
- 公司 Distribution 证书对应私钥当前未出现在本机可用签名身份中；正式归档前需安全导入匹配 P12，不能只导入公共证书。
- 完成上述配置后，应生成 IPA 并核验归档实际使用的证书 SHA-1 与本记录一致；若证书发生轮换，必须变更 APP 备案特征信息。
