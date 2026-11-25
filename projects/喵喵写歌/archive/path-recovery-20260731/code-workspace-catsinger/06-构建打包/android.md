# catsinger Android 构建说明

## 基础信息

- applicationId：`com.lxwx.catsinger`
- versionName：`1.0.1`
- versionCode：`104`
- ABI：仅 `arm64-v8a`
- 签名：Git 忽略的 `android/app/lxwx.jks`，参数来自 `android/key.properties`
- release 在 Gradle 中固定 `arm64-v8a`，用于过滤第三方 AAR 附带的 armeabi-v7a/x86_64 原生库；Flutter 命令仍保留 `--target-platform android-arm64`。

## office 基础包

```bash
flutter build apk \
  --release \
  --target-platform android-arm64 \
  --obfuscate \
  --split-debug-info=dist/android/1.0.1+104/symbols/dart \
  -PAPP_CHANNEL=office
```

构建后将 `build/app/outputs/mapping/release/mapping.txt` 归档到 `dist/android/1.0.1+104/symbols/r8/mapping.txt`。

## 多渠道重签

```bash
python3 script/android_channels/main.py
python3 script/android_channels/main.py --apk path/to/office.apk
python3 script/android_channels/main.py --channels office,huawei,yyb
python3 script/android_channels/main.py --output-dir path/to/output
```

处理顺序：复制基础 APK → 注入 `META-INF/channel-<渠道>` → zipalign → apksigner V2/V3 重签 → 包名/版本/ABI/渠道/证书校验 → SHA-256 清单。

## 渠道行为

| 分发渠道 | 友盟渠道 | 版本更新渠道 |
|---|---|---|
| `office` | `office` | `office` |
| 其他默认渠道 | 具体渠道名 | `store` |

## 密钥与安全

- keystore、密码、本地配置和产物不得进入 Git。
- Python 通过临时环境变量向 apksigner 传递密码，不拼接到命令行日志。
- 每个渠道包必须与 office 基础包证书 SHA-256 一致。
- minSdk 24，正式 APK 要求 V2/V3 签名有效；不依赖 V1/V4。

## Candidate 门禁

- 自动化通过只说明打包链路可用，不代表商店正式包验收完成。
- 最终正式包生成前必须完成 Android 真机的一键登录、支付宝已安装/未安装、友盟渠道和版本更新验证。

## 已生成的九渠道 Candidate

- `catsinger_v1.0.1_<channel>_release.apk`（共 9 个渠道包）
- 示例：`catsinger_v1.0.1_office_release.apk`、`catsinger_v1.0.1_baidu_release.apk`
- `SHA256SUMS` 与 `build-manifest.json`
- `symbols/dart/app.android-arm64.symbols`
- `symbols/r8/mapping.txt`

以上文件位于 Git 忽略的 `dist/android/1.0.1+104/`，均已通过自动化校验；最终正式九渠道包须在真机 QA 通过后重跑生成。
