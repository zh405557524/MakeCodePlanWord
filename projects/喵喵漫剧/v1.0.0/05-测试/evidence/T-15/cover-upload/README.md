# T-15 作品封面上传补齐 · 2026-10-16

本切片已交付两个入口的封面选择、预览、确认上传与恢复；T-15整项仍为**未完成（进行中）**。真实OSS、最新Figma、两端物理设备和同一作品完整制作/剪辑仍待验收。

## 实现与检测

- 列表和详情共用现有表单、Catsinger相册插件与私有上传；确认前不上传，取消不改资料。实际图片格式/解码及10MiB上限沿公共实现，不创建个人资产或成长奖励。
- 原版本/资料/本机动作键/图片身份先保存至已有项目GetStorage记录。上传回执未知确认原对象，未READY不PATCH；原PATCH继续既有CAS/body，没有新增服务端幂等契约。冲突保READY候选和手改，等待用户核对最新资料。
- 防并发页面改写原意图；作品回执已落盘只补清理，保存成功清除手改定位。固定资源ID缓存，迟到旧签名不替换新图；恢复的bool沿既有“已删除作品”语义，保存封面后保留详情页。
- 新增25项封面测试；全套**951项App通过**（含作品相关54），0失败/0跳过。[机器结果](app-test-summary.json)、[最终原始日志](app-tests-final.jsonl)、[analyze](analyze.log.gz)、[16文件格式](format.log.gz)。23项插件及T-43正常App两端构建为先前有效证据，本切片未重跑或重复计数；两端集成入口实际编译通过。
- 既有**31项后端**（20作品管理＋11图片上传）通过，真实Spring/JWT/隔离PG及本机图片读取/解码，OSS签名/元数据为替身。[后端结果](backend-result.json)、[日志](backend-tests.log.gz)。后台源码与初始6个无关脏文件摘要保持。
- **两端模拟器各2项业务方法通过，共4次执行**：真实相册插件选择/取消/预览/确认后HTTP PUT，列表上传丢回执后重建服务并在详情恢复；一张图片只PUT一次。保存不改原剧集或期限，无个人资产API。两个业务用例不含setup/teardown计数。[Android](devices/android-project-cover-result.json)、[iOS](devices/ios-project-cover-result.json)、[Android日志](android-drive-final.log.gz)、[iOS日志](ios-drive.log.gz)。服务重建不是OS强杀；HTTP上传是受控本机协议，不是真实OSS。
- 10张最终截图，关键5张已看图，具体范围和摘要见[图片检查](image-review.json)。下面使用自建108×156诊断图片，仅用于核对实际文件和预览；不是产品素材或新设计稿。iOS升级照片读取权限时按用户已明确授权选择“允许完全访问”。只选择本次生成的AssetEntity ID，未选择或上传其他相册文件；自有QA模拟器保留生成样图。

## 最终界面

![Android确认前预览](devices/android-project-cover-cover-selected-before-confirm.png)
![iOS恢复后留在详情](devices/ios-project-cover-cover-restored-detail.png)

完整图集位于[devices](devices)，[图片检查清单](image-review.json)区分已留证与已看图。

## 失败与修正

- [首轮方法日志](cover-initial.log.gz)的2个失败源于测试误认为既有资料PATCH携带服务端幂等头。核对原实现后，改为检查持久化本机动作键和原CAS/body；没有为了测试变更API。
- [Android首轮](android-drive.log.gz)因测试自行定义expectSync转调受guard的expect，使异步HTTP回调中断。改用Flutter提供的expectSync后重跑。
- [Android第二轮](android-drive-attempt-2.log.gz)真实发现封面恢复返回“成功”被页面按“已删除”处理。修正为既有删除语义，并补检成功残留编辑稿；[该轮图](devices-attempt-2)保留，不计最终通过。修正后的全套951项及两端最终执行均通过。
- T-42三项旧公共夹具失败仍保留，不计入本次31项既有后端通过，也未趁机修改其他App。

原始日志与JUnit XML以gzip无损归档，解压后逐字节相同，原SHA见[归档清单](raw-output-archives.json)；未改写测试输出。明文副本只保留本机originals，避免把工具自带的尾部空格当作文档格式错误。

## 重现与范围

在App仓库执行（Flutter 3.41.6；设备只选自有QA环境）：

```sh
flutter analyze --no-pub
flutter test --no-pub --machine
CATDRAMA_BUSINESS_EVIDENCE_DIR=<绝对证据目录>/devices CATDRAMA_TEST_PLATFORM=android CATDRAMA_TEST_SLICE=project-cover flutter drive --no-pub --keep-app-running -d emulator-5554 --driver=test_driver/catdrama_business_driver.dart --target=integration_test/project_cover_test.dart
```

iOS替换设备ID及平台变量；需要真实系统相册权限。后台使用既有自有PG51346，只运行CatdramaProjectManageTests与CatdramaImageUploadTests；schema已清为0，PG及两个自有模拟器已停止。原型/配图、产品/技术基线、API/DDL/依赖/原生配置/公共业务源码未变。Figma通道rq4owed6实际未连接，沿已有T-15 5:2490/5:3005和当前相册预览样式，不能称新Figma对稿通过。[Figma核实](figma-check.json)、[原脏文件保护与清理](backend-preserved.json)、[源码摘要](final-source-manifest.json)、[提交](app-commit.json)、[结果](result.json)。

进度统计保持7完成/38进行中/2待外部；186用例保持9完整通过/172部分/5未执行，TC-09-04保持部分。所有改动均未推送或部署。原文件备份仅本机保存于originals，不纳入提交。

本轮用量未取得，未额外查询。
