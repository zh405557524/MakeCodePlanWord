# T38-OS-COPY-01 相册用途说明

2026-10-17，App dev `d4be4d7`，未推送。实际iOS添加照片弹框原文只提生成视频，同一入口已用于素材图片、海报及视频；本轮改为“用于将素材图片、邀请海报和导出视频保存到系统相册”。读取权限说明保持，未增加权限或改变保存实现。

仅修改`ios/Runner/Info.plist`及App README。沿用现有`growth_invite_test.dart`和严格driver，没有为这项文案变更新增Dart测试，也没有改公共发奖、接口、数据库、依赖或媒体引擎。此前[已登记问题](../native-invite/README.md)保留，由本次实际弹框检查关闭本机范围的T38-OS-COPY-01；整项T-38仍未完成。

| 检查 | 实际结果 |
|---|---|
| plist及构建 | plutil通过；iOS simulator debug构建通过，构建产物和已安装Bundle均读到新说明，Bundle ID保持com.lxwx.catdrama |
| 原页面回归 | 3条实际方法：签到回执丢失后GET恢复、绑定/记录失败及分页、复制/取消分享/用途说明取消/海报保存；SDK+5包含两个全局hook |
| 系统授权 | 电脑按新鲜原生XML核对当前App添加照片弹框及完整用途说明，再点击允许；没有接受其他授权 |
| 相册文件 | 新增1份PNG，与同次导出的1200×2136海报逐字节一致；68份旧图片/视频的摘要和大小保持，未清相册 |
| 结束状态 | 原权限恢复、自有模拟器及Appium停止；USB真机和Android未使用，App未卸载，后台未启动 |

已实际查看[系统授权原图](native-01/ios/permission-add.png)和[保存成功原图](native-01/ios/ios-poster-saved-os.png)。另保留16张状态系统图及[系统相册副本](native-01/ios/ios-actual-album.png)，没有将全部16图记作逐张视觉复审。截图总计17张，包括额外系统授权图；[原生报告](native-01/ios/ios-growth-invite-result.json)、[安装产物用途字段](native-01/ios/purpose-installed.json)、[相册核验](native-01/ios/album-verification.json)、[清理](native-01/ios/cleanup.json)。

1260项全套App测试及analyze复用[上一轮有效证据](../../T-39/page-feedback/README.md)，本轮未重复执行。该轮App提交为`9e07713`，本次提交只改两份文件，没有Dart或测试代码变化。[源码与复用依据](source.json)、[结果](result.json)、[范围](scope-check.json)、[日志](log-archives.json)、[文档门禁](guard-result.json)、[文件摘要](manifest.json)、[复核](verification.json)。

此流程使用真实页面、系统弹框、剪贴板和相册；身份及HTTP邀请数据受控，不证明真实短信、部署落地/安装、外部分享、发奖或物理设备验收。系统分享面板只打开后取消。47项任务7完成/38进行中/2待外部、正式186条9通过/172部分/5未执行保持，阶段仍为开发。配置改动只对应iOS，本轮不重跑Android。

只读复核：`python3 verify.py`。`run_native.py native-新编号 ios`为设备复跑入口，需使用新目录和登记的自有模拟器，不覆盖旧证据；会安装测试App并新增一份受控海报。原始日志和备份在本机忽略的`originals/`，公开gzip日志逐份记录摘要。
