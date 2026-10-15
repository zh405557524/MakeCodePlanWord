# T-26 镜头视频检测

视频单项/批量、原任务恢复、真实文件验证、事务发布与30天续期已实现；完整任务的真实Provider/OSS、样片阈值、最新Figma与两端联验仍待补。下一项按已审核依赖继续T-28。

新增26项后端、16项App。149项相关后端、92项相关App通过，0失败/跳过；analyze无问题，11文件格式检查0变更。3张真实Widget图已查看。结果：[汇总](result.json)、[后台方法](backend-summary.json)、[App方法](flutter-summary.json)、[逐用例](case-results.json)、[源码](source-manifest.json)。

后台主回归148项，后补内部下载App门禁后资源套件18项重验，按类/方法去重为149项。包含实际Spring/JWT/独占PG、公共积分账务、原Worker与FFmpeg/FFprobe音画解码；Provider和OSS接口为受控替身。真实MP4覆盖正常有声、NONE无声、缺音轨、全静音、破坏AAC包、坏文件、8秒不足及错误帧率。公共文件标识Service对测试文件写七字段并实际回读，测试标识不代表生产签名/运营主体认证。[主回归](backend-test.log)、[内部下载门禁](backend-resource-gate.log)。

App使用实际Controller/Widget、用户沙盒持久化及协议HTTP，覆盖选择/取消、完整确认、批次恢复、未知响应、选择失败项、超限、账号切换与手改保护。完整回归92项后，截图/测试夹具收尾16项再验，重复方法不累计；setup/load/teardown隐藏事件不算业务方法。[完整事件](flutter-test.jsonl)、[16项复检](flutter-targeted.jsonl)、[分析](flutter-analyze.log)、[格式](dart-format.log)。

源视频不统一转码、不补帧或减速；公共storeFile负责实际标识与私有保存，最后对标记文件探测并保存真实大小/SHA256。原资源ID、探测值及首次成功时间写原Job检查点，新暂存节点恢复不再转存或重新起算。版本/首应用/项目与剧集续期/资源保护/公共结算同事务；结算故障后原文件保留并恢复原任务。用户删除不复活，到期前受理成功按真实成功续期，乱序/重放不累计，失败不续期。

没有真实验证依据的模型规格，报价显示阻塞且不冻结；内部drama.production.videoAcceptance精确匹配参数并随报价固定。测试10秒范围和音量阈值仅用于本机夹具，未作为生产Provider认证或默认能力。文件可解码/有声不代表台词、说话者或音色自动验收；预览展示原完整台词供用户试听。Provider受理响应全丢且无可核实ID时保持原未知任务，不自动创建新尝试。

[选择](screenshots/video-selection-375.png)、[确认](screenshots/video-confirm-375.png)、[候选试听](screenshots/video-candidate-375.png)均为真实渲染，无后期编辑；用测试余额/模型/媒体元数据，不代表实际模型输出或设备播放。当前Figma通道返回Not connected，沿保存设计材料与既有主题实施，最新对稿仍待补。[图片范围](image-evidence.json)。

BUG-T26-001：JSONB整数节点与Java长整数差异导致首成功未自动应用，已统一序列化比较并复检。初次Worker夹具错误使用AutoCloseable、Mockito重新装桩执行旧Answer的空参数、JSON规范化IOException编译缺口和Dart条件语法均已修正。Widget异步KV等待/首次状态刷新必须等真实就绪；前两次未结束的测试进程已停止，不算通过。可复查失败：[首次编译](attempts/01-worker-fixture-compile.log)、[首应用修正前](attempts/02-before-first-apply-fix.log)、[异常声明修正前](attempts/03-json-normalization-compile.log)、[等待记录一](attempts/flutter-widget-kv-wait-01.jsonl)、[等待记录二](attempts/flutter-widget-kv-wait-02.jsonl)。

数据库改动：无表/字段/索引/迁移、存量修复或生产操作。仅既有Job JSON、视频版本、项目/剧集期限、引用及公共账务正常读写。自有随机schema清理后0，自有PG已停止；未推送或部署。App与后端保持dev，每任务独立提交，原未跟踪文件及其他工作保留。实体/Mapper沿既有唯一映射；仅增加必要内部协作及catdrama门禁的公共流式下载方法，无新增HTTP/队列/移动依赖或生产图片。

本任务代码提交：App dev `5aeb6eb1aee5f365928b85235f9ae8efe53f002b`；后端dev `7420239246ccd3808b2d6402406189098d5da18b`。
