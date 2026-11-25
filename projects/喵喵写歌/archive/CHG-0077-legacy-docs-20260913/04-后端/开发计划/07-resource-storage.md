# 07 资源持久化模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B007
> 状态：done

## 功能定位

将第三方生成音频或用户上传资源保存到自有资源位置，App 和后台只使用自有地址。

## 类清单

- `SongResourceStorageService`
- `ResourceStorageProvider`
- `LocalResourceStorageProvider`
- `CloudObjectStorageProvider`
- `StoredSongResource`

## 业务规则

- `HEX`：服务端解码、校验、保存。
- `TEMP_URL`：服务端立即下载，限制超时、大小、content-type 和重定向。
- 保存失败时生成任务失败并退款。
- `catsinger_song_works.audio_url` 禁止写第三方临时 URL。

## 配置

`SONG_STORAGE_PROVIDER` 支持 `LOCAL`、`ALIYUN_OSS`、`TENCENT_COS`、`QINIU_KODO`、`S3_COMPATIBLE`。

## 实现步骤

1. 实现本地存储 Provider。
2. 定义云存储 Provider 接口。
3. 保存资源元数据到 work/assets。
4. 下载接口返回公开地址或签名地址。

## 测试要求

- HEX 保存成功。
- 临时 URL 下载成功。
- content-type 非音频失败。
- 保存失败触发退款流程。
- App 响应不出现第三方临时 URL。

## 验收标准

播放、下载和后台资源查看都使用我们自己的资源地址。
