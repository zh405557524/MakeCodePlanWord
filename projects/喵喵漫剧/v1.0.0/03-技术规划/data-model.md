# 喵喵漫剧数据模型

> 2026-10-15 T-37-IF-01：用户已确认只读字段补充。购买积分快照复用现有payment_orders.pay_params，不新增表、列、索引或迁移；其余实施状态以开发计划为准。

> 2026-10-14补充S-28至S-32：Catsinger工程基础与分层规则迁移、Figma视觉主依据、相册视频提取音频、免费资产描述帮写。当前仅文档，未实现接口或数据库；设计节点见[索引](../02-设计/设计说明.md#figma-pages)。

> v1.0.0 模型草稿，本轮已确认规则已同步（尚未实现），2026-10-13；数据库改动：本轮无。下面均为拟实施结构，未创建SQL、Entity、表或执行迁移。
> 接口字段定义唯一来源为 [api.md](api.md)；本文定义数据库列、本地存储与持久化约束。全部专属表只属于catdrama schema。

## 本轮已确认规则同步（2026-10-13）

S-21的39条逐项确认及S-22作品名称分类，已按S-23同步到本文正文。对应[现行产品需求](../01-产品/requirements.md)、[155条AC与确认记录](../01-产品/requirements-list.md)及[第14轮文档检测](../01-产品/detection-feedback.md#review-round-14)。现有编号保持，受影响任务/用例同步；文档定义不代表代码、数据库或真实媒体测试已完成。用户S-24已批准产品文档；S-25的11项技术规则已同步并复检，S-26在完整技术稿交付后授权“继续下一步”，当前为开发计划·待整体审核。字幕改为手机抽取实际混音后上传、后台异步识别，剪辑与音视频字幕合成仍在本机；全剧剧本一次生成。逐项确认见技术方案§10，开发任务保持待开始。

| 范围 | 现行约束 |
|---|---|
| 创建/导入 | 确认逐集剧本创建作品；制作参数保存与分析独立；仅小说支持TXT |
| 资产 | 先来源作品名称分组，再按类型；固定版本引用，被引用禁止删除；删作品保有效资产 |
| 剪辑/导出 | 当前时间轴必需原文件下载校验后进入；主动字幕为后台识别，校对及合成在本机；识别/导出处理中弹框不可关闭，导出成功先预览再手动存相册 |
| 保留/缓存 | 视频成功以真实最近成功时刻重设作品30天；到期隐藏；图片自身30天；清闲置缓存和应用临时成片，保护有效作品引用和相册 |

## 1. 服务端数据库

> 本版改动：R-01至R-26。

<a id="model-1"></a>
### 1.1 基础约定与公共表复用

内部ID为BIGINT/MyBatis-Plus生成Long，对外转十进制字符串。新表共同包含 `id bigint PK`、`created_at timestamp NOT NULL`、`updated_at timestamp NOT NULL`；所有者表另有 `user_id bigint NOT NULL`，系统素材除外。新业务时间统一以UTC `LocalDateTime` 保存，输出加 `Z`；签到仍用公共服务Asia/Shanghai自然日。公共旧表的时间沿用其既有约定，不改变存量数据。

`revision bigint NOT NULL DEFAULT 1` 用于CAS；后台内容revision递增不回退；本机剪辑head另见§2。`deleted_at timestamp NULL` 为用户主动软删除；`expires_at timestamp NOT NULL` 为对象业务截止，由对象规则计算：作品按创建/最近视频成功+30天，图片按自身成功+30天；不因编辑更新。UTC截止时刻及引用释放取服务端时钟，App改时间无效。带生命周期的对象状态和时间均由Service设置，客户端不能提交所有者、创建时刻或截止时刻。

积分及金额使用bigint/Long；人民币金额为分，币种CNY，展示转换两位小数。JSON使用jsonb + 类型化DTO/版本化文档，不能自由塞入跨模块实体或临时签名地址。跨模块只保存userId、resourceId、chargeOrderNo等稳定标识，不增加公共模块外键。专属表内部父子关系用外键/显式约束，不级联删除正在处理的任务、视频历史、账务关联。

文本模型原始输出以Markdown字符串保存，不解析成模型JSON。下文jsonb用于后端自行构造的业务字段、快照和检查点容器；原始Markdown与分段生成的业务候选分别留存，格式和传输类型见[api§5.1](api.md#api-markdown)。本次格式调整复用现有拟建表，不额外新增提示词表或文本结果表。

| 公共归属 | 直接使用的表/能力 | 本版边界 |
|---|---|---|
| core/auth、core/user | users、user_app_profiles、guest_credentials、sms_codes、refresh_tokens | 游客/注册/绑定/恢复复用现有身份规则；catdrama只增加schema配置，不另建用户主表 |
| core/entitlement | point_accounts、point_ledgers、point_charge_orders、point_charge_batches、point_charge_order_lines、point_charge_batch_events、entitlements | 冻结/结算/退回和奖励只调用Service；不改其他App积分或表结构 |
| core/product/order/payment | products、payment_orders、payment_events | 当前App套餐和支付快照；媒体30天不删除订单/支付事件 |
| app/growth | invite_records及现有邀请配置/必要控制表、task_checkins、user_feedbacks | 不创建另一份邀请关系、签到记录或反馈表；不把现金状态作为积分进度入口依赖 |
| core/resource/ai/config | resource_records、AI配置/场景映射/调用记录、app_configs | 本App新增资源类型、场景及默认JSON；正式资源必须保存所有者、访问范围和真实文件信息 |

公共列和索引保持现有common迁移为准；新SQL只创建下列14张catdrama专属表，普通默认配置/素材/案例不通过SQL或启动代码自动灌库。

T-37只在catdrama新积分订单的既有`pay_params TEXT`中保存JSON成员`catdramaPurchaseSnapshot: {pointsAmount: 正整数}`，来源为建单时的公共ProductSnapshot。幂等重放沿用原单；取新SDK参数时保留原成员，不读取现价或改写积分数。内部成员不传给SDK，也不返回客户端payParams。旧单没有快照则保持缺失，不迁移补算。

仅有购买快照不代表已发起渠道支付。取消、查单及分钟调度按剔除内部成员后的真实支付参数识别；分钟调度在catdrama分页选取过期待付单后按实际参数筛选，其他App SQL及结算规则不变。损坏历史JSON不在SQL里强制转换。该范围后续随T-40核对历史待付单规模与查询性能。

流水响应的operation/bizType/bizId直接取原聚合行已有列，不存一份新账本，不修改扣费、退款或聚合算法。App跨设备恢复仍使用原PaymentIntentService和公共GetStorage，固定原订单号、名称、金额、积分、渠道及账号/环境/实际后台；真实写盘后才进入统一续付流程，不复制支付签名/票据。接口类型唯一来源见[§3.2](api.md#api-3)。

<a id="model-2"></a>
### 1.2 catdrama_creation_drafts

> 本版改动：R-04、R-05、R-06、R-07、R-08、R-09、R-26。

用途：正式项目之前的可恢复草稿。归属：本人；同一客户端草稿UUID只创建一次。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、client_draft_id | bigint、varchar(36) | 否 | 账号与本机UUID；唯一(user_id,client_draft_id) |
| create_idempotency_key、create_input_hash | varchar(64)、char(64) | 否 | T-09落实既定创建幂等：首次创建动作键与规范化输入SHA256，后续编辑不修改；唯一(user_id,create_idempotency_key)，与clientDraftId分别校验，响应丢失后同输入返回原草稿、异输入冲突 |
| name、source_type、original_text | varchar(80)、varchar(24)、text | 否；空串仅草稿阶段允许 | 名称20 Unicode标量，原文10000；source_type见§3 |
| import_filename | varchar(255) | 是 | 仅展示文件名，不保存客户端路径 |
| split_mode、requested_episode_count | varchar(16)、int | 否AUTO；是 | CUSTOM必须1–30，AUTO为空 |
| source_revision、story_revision、screenplays_revision | bigint | 否，初始1/0/0 | 原文输入、草案、逐集稿独立版本 |
| story_document、screenplays_document、production_settings | jsonb | 是 | 分别保存后端组装的草案、1–30集正文和参数；正文为Markdown字符串，业务形状见api§4/§5；不是对模型JSON反序列化 |
| story_manual_edited、screenplays_manual_edited | boolean | 否false | 用户编辑对应内容后true，应用相应AI候选后false；覆盖前要求确认 |
| story_source_revision、screenplays_upstream_revision | bigint | 是 | 生成来源版本；确定是否过时 |
| story_confirmed_revision、screenplays_confirmed_revision | bigint | 是 | 只有等于当前revision才确认有效；EXISTING_SCRIPT不要求草案 |
| revision、state、project_id | bigint、varchar(24)、bigint | 否1/EDITING；是 | 聚合CAS、草稿状态、已创建项目标识 |
| expires_at、deleted_at | timestamp | 否；是 | 首次服务端保存+30天；创建正式项目后草稿只读且不再复建 |

索引：唯一(user_id,client_draft_id)、唯一(user_id,create_idempotency_key)；唯一project_id（非空）；(user_id,state,updated_at,id)。已转项目重复提交永远返回原projectId，即使项目被用户删除也不复活或重复创建。创建键/hash为内部幂等证据，不由DraftSave或对外响应修改/暴露。

生成原文在关联Job检查点留存；应用后Draft中的文本字段为可编辑正文。手改只更新正文和对应revision，不回写模型原文；不能从旧原文重新投影覆盖已保存手改。重新生成/应用继续执行已有覆盖确认和CAS规则。

<a id="model-3"></a>
### 1.3 catdrama_projects

> 本版改动：R-08、R-09、R-16、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、creation_draft_id | bigint | 否 | 当前账号、正式创建来源；唯一creation_draft_id |
| create_idempotency_key、create_input_hash | varchar(64)、char(64) | 否 | T-13落实既定创建幂等：固定首次创建键与规范化请求摘要，唯一(user_id,create_idempotency_key)；同键异输入冲突，不随后续编辑或重复确认变化 |
| name、description | varchar(80)、text | 否；空描述允许 | 名20、简介500标量上限 |
| cover_resource_id | bigint | 是 | 本人可用封面；独立资源引用 |
| confirmed_content_snapshot、production_settings | jsonb | 正文否；参数是 | 确认逐集剧本创建时逐字保存正文；参数允许未设置，之后PATCH保存，不重拆正文 |
| revision、state | bigint、varchar(24) | 否1/ACTIVE | 仅制作对象状态，无本机完成/未完成标识 |
| latest_video_succeeded_at | timestamp | 是 | 最近真实VIDEO成功时间；重复/乱序取最大值，不用回调到达时间 |
| expires_at、deleted_at | timestamp | 否；是 | max(created_at,latest_video_succeeded_at)+30天；到期列表隐藏，无独立本机入口 |

索引：(user_id,deleted_at,created_at,id)、(expires_at,state)。project删除只软删除自己/剧集、释放合适引用；不删除公共订单或积分。

<a id="model-4"></a>
### 1.4 catdrama_episodes

> 本版改动：R-07、R-09、R-10、R-16、R-17、R-21、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、project_id、ordinal | bigint、bigint、int | 否 | ordinal为稳定原剧本次序，不随列表重编号改变身份；1–30 |
| title、screenplay | varchar(80)、text | 否 | 标题20、正文1–10000；逐字保存最终确认的Markdown正文，不存渲染HTML |
| script_revision、analyzed_script_revision | bigint | 否1；是 | 不一致显示未更新；旧分析仍可回看 |
| revision、applied_analysis_id | bigint、bigint | 否1；是 | 应用分析版本和聚合CAS |
| state | varchar(24) | 否ACTIVE | 后台仅维护制作状态；本机保存/导出任务是操作反馈，不投影作品完成标识 |
| expires_at、deleted_at | timestamp | 否；是 | 继承项目截止并随成功视频续期同步；显示集号按仍可见ordinal排序计算 |

索引：唯一(project_id,ordinal)，(user_id,project_id,deleted_at)。删除最后一集拒绝；删除其他集不更新它们正文、生成结果或原顺序标识。

<a id="model-5"></a>
### 1.5 catdrama_analysis_runs

> 本版改动：R-10、R-12、R-17、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、project_id、episode_id、job_id | bigint | 否 | 每集一个候选分析；全剧父任务关联子任务 |
| script_revision、base_analysis_id、base_episode_revision | bigint | 否；是；否 | 分析正文版本、旧分析、应用时CAS |
| script_sha256、candidate_document、diff_document | char(64)、jsonb、jsonb | 否；生成中是 | 输入原文hash、Markdown分段校验后由后端组装的素材/镜头候选、ADD/KEEP/REMOVE具体差异；原始输出由job_id追溯 |
| state、applied_at | varchar(24)、timestamp | 否RUNNING；是 | CANDIDATE/STALE/APPLIED/FAILED；候选完成不改现有镜头 |

索引：唯一job_id；(episode_id,script_revision,created_at)。候选temporaryKey和现有shotId分别保存。匹配需稳定标识/来源锚点佐证，只有名称或数组位置相似不自动KEEP。解除共享关系的绑定标记必须进入匹配约束。

候选键和真实ID由后端分配；模型引用标记的映射固定在任务快照/检查点，校验通过后才形成真实素材关联。`AnalysisDiff.markdownDocuments`读取关联检查点中的原文，不从候选JSON反向拼造“原始模型输出”。

<a id="model-6"></a>
### 1.6 catdrama_assets

> 本版改动：R-03、R-10、R-11、R-12、R-24、R-26。

统一素材身份表：PERSONAL、SYSTEM、PROJECT共用结构；项目导入创建资料快照和固定图片引用关系；source_asset_id/source_version_id保留不可随意解除的源引用，不复制媒体或重设期限。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、scope、project_id | bigint、varchar(16)、bigint | 系统user_id是；scope否；project_id是 | SYSTEM必须无个人所有者且已发布；PROJECT必须有project及本人 |
| kind、name、description | varchar(16)、varchar(80)、text | 否 | ROLE/SCENE/PROP；名20、描述500；分析来源描述保留对应Markdown正文片段，图未应用时允许草稿 |
| source_asset_id、source_type | bigint、varchar(24) | 是；否 | ANALYSIS/MANUAL/UPLOAD/PERSONAL_IMPORT/SYSTEM_IMPORT/PROJECT_GENERATION；导入保留固定来源身份 |
| origin_project_id、origin_project_name | bigint、varchar(80) | 是 | PERSONAL来源作品身份/名称快照；非作品个人图为空。按作品ID聚合分类，名称变更同步；作品删除不级联，保留分类及有效图 |
| library_asset_id | bigint | 是 | PROJECT素材自动入库的PERSONAL目标；仅同App本人；失效后新成功任务可重新建目标，旧任务不复活 |
| create_idempotency_key、create_input_hash | varchar(64)、char(64) | 是 | T-16落实个人创建幂等；首次请求键及规范化输入摘要，唯一(user_id,create_idempotency_key)，系统/分析/自动入库来源可空；后续编辑、删除不清除或改写 |
| action_receipts | jsonb | 否{} | T-16个人图片应用/删除的事务回执；动作和键绑定请求摘要及原结果身份，不存临时签名URL，不作为用户自由字段；重放只恢复原动作结果，不反向修改后续选图或复活删除记录 |
| applied_image_version_id、revision | bigint、bigint | 是；否1 | 当前应用版本不能指向其他素材或失败版本 |
| state、published_at | varchar(24)、timestamp | 否DRAFT；是 | SYSTEM只有PUBLISHED可公开导入 |
| expires_at、deleted_at | timestamp | 系统可为空；其他否；是 | 个人聚合截止取建卡+30天与有效版本截止最大值；项目素材随有效作品引用保护 |

索引：(user_id,scope,kind,deleted_at,created_at,id)、(user_id,scope,origin_project_id,kind,deleted_at)、(project_id,state)、source_asset_id。有有效作品引用的个人源/图片拒绝删除；解除引用后确认删除；分类按origin_project_id聚合，同名作品不合并。SYSTEM素材由后台显式维护，初版公开案例/素材可用只读配置但不伪造用户资源。

<a id="model-7"></a>
### 1.7 catdrama_episode_assets

> 本版改动：R-10、R-11、R-12、R-13、R-17。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、episode_id、asset_id | bigint | 否 | 单集可用清单的稳定关系ID，镜头引用关系ID而非名称 |
| sharing_group_id | varchar(36) | 是 | 关联多个剧集的同一共享组；独立副本为空 |
| detached_from_binding_id、detached | bigint、boolean | 是；否false | 仅本集独立的历史来源；分析不能重绑 |
| archived_at、revision | timestamp、bigint | 是；否1 | 归档只影响本集；引用或生成中须先解除/结束 |

索引：唯一(episode_id,asset_id)、(sharing_group_id)、(episode_id,archived_at)。只在本人同项目跨集共享；独立处理时复制asset/图版本并替换当前episode关联和shot引用，同事务完成。

<a id="model-8"></a>
### 1.8 catdrama_asset_image_versions

> 本版改动：R-03、R-11、R-12、R-22、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、asset_id、job_id | bigint | 否；job可空 | 生成关联付费任务；上传/导入不扣AI积分 |
| resource_id、source_version_id、source_type | bigint、bigint、varchar(24) | 可用成功resource否；source是；类型否 | 导入引用source_version_id及其resource_id，不复制媒体、不刷新原成功时间/期限；项目保存固定选择 |
| input_snapshot、actual_provider、actual_model | jsonb、varchar(64)、varchar(128) | 上传/导入可空 | 原描述、参数、真实模型，不存签名URL |
| state、succeeded_at、expires_at | varchar(24)、timestamp、timestamp | 否；成功时否 | GENERATING/SUCCEEDED/FAILED/EXPIRED；成功时+30天 |

索引：生成job_id唯一（非空）；唯一(asset_id,source_version_id)（source非空）；(asset_id,state,created_at,id)。应用标识在asset，不用可被不同对象覆盖的全局isApplied布尔。引用保护不改变这个版本自身截止。

<a id="asset-library"></a>
**自动入库一致性（D-32）**：有效项目图片交付时锁定原PROJECT asset，按原素材library_asset_id/source_asset_id读取/创建同用户、同kind、同origin_project_id且同一来源素材的PERSONAL目标，保存来源作品名称快照；原素材的library_asset_id指向目标，目标source_asset_id追溯原项目素材，source_type=PROJECT_GENERATION。为本次生成图创建独立个人image version，source_version_id指原生成版本，job_id=NULL，复用同一resource_id并新增ASSET_VERSION引用。个人图片版本使用原真实succeeded_at及+30天截止，重试保存不重置起算点。首次个人资产创建按首次成功保存起算30天；追加图片将资产聚合截止覆盖新图有效期，旧图期限不延长。

原图、个人副本/引用、目标指针、首图选用、job结果检查点与本次公共积分结算在同一业务提交边界落定；FINALIZING未完成期间不向列表/导入暴露新可用个人图，外部Provider/资源交付按既有检查点补偿。PERSONAL首次入库图成为其applied_image_version_id，后续仅追加历史，保留用户名称/描述/选图；项目applied指针依原单项/批量应用规则处理。个人直接生成不另建个人副本。入库失败保持FINALIZING及已取得的媒体，仅重试事务；超过既定失败处理条件时沿用公共补偿，不再发起Provider或多扣费。

幂等先查原任务的成功检查点（保存libraryAssetId/libraryImageVersionId），再查唯一源版本键；已成功任务重放不因目标软删/到期重新创建，不复活被删除资产。原library_asset_id目标无效时，仅新的成功生成任务可重建目标，并在原素材锁内交换指针；不同项目素材即使同名也不合并。项目删除仅释放自身引用，分类与有效个人图片保留；个人删除先检查图片resource_id是否仍被有效作品引用，引用中拒绝删除；共享关系数不改变个人副本数量。

<a id="model-9"></a>
### 1.9 catdrama_shots

> 本版改动：R-13、R-14、R-15、R-17、R-18。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、episode_id、ordinal | bigint、bigint、int | 否 | 稳定镜头ID和当前分析的原剧本顺序，镜头身份不靠ordinal |
| source_text、source_anchor、source_fingerprint | text、jsonb、char(64) | 否 | 原文、分析段落/范围及校验；不能按数组错绑旧视频 |
| description、production_override | text、jsonb | 否；是 | 描述1–1000，保留对应Markdown正文片段或用户改稿；镜头级参数覆盖 |
| references_manual、speech_spec | boolean、jsonb | 否false；否 | 手动调整后不自动覆盖素材选择；speech_spec沿用api SpeechSpec，核对对白/旁白随视频生成，参与版本与报价hash |
| revision、references_revision、description_ack_hash | bigint、bigint、char(64) | 否1/1；hash可空 | 变更引用使核对失效；hash固定当前描述+引用/应用图版本，避免确认版本歧义 |
| applied_video_version_id、analysis_id | bigint | 是；否 | 成功应用视频与已应用分析 |
| state、removed_at | varchar(24)、timestamp | 否ACTIVE；是 | 分析移出为REMOVED，仍保留历史并可明确恢复 |

索引：(episode_id,state,ordinal,id)、source_fingerprint。重新分析只更新明确KEEP的身份；移出镜头不把时间轴已有片段或文件自动删除。重分析确认中需要明确展示保留剪辑的历史引用。

<a id="model-10"></a>
### 1.10 catdrama_shot_asset_refs

> 本版改动：R-13、R-14。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| shot_id、binding_id、kind、ordinal | bigint、bigint、varchar(16)、int | 否 | 镜头实际角色/场景/道具引用及输入顺序 |

索引：唯一(shot_id,binding_id)、(binding_id)。Service检查binding属于shot同一episode和本人；归档/删除时有引用则拒绝或先明确解除。图片生成/报价按这些引用校验，不按全清单校验。

<a id="model-11"></a>
### 1.11 catdrama_shot_video_versions

> 本版改动：R-14、R-15、R-18、R-21、R-22、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、shot_id、job_id | bigint | 否 | 每次付费尝试唯一job |
| input_snapshot | jsonb | 否 | 描述、原文、SpeechSpec、绑定/图片版本ID、精确模型和参数、报价版本 |
| resource_id、cover_resource_id | bigint | 成功resource否；cover是 | 实际可用媒体；源模型临时地址不持久化为业务访问地址 |
| capability_snapshot、frame_rate | jsonb、jsonb | 成功时否 | api GenerationCapabilitySnapshot及Rational；能力版本固定在生成时，帧率取实际探测；下载清单和本机索引携带同一份依据 |
| actual_duration_ms、width、height、has_audio | int、int、int、boolean | 成功时否 | ffprobe真实数据，整数毫秒；分辨率不由最后封装值冒充Provider原始能力 |
| size_bytes、sha256 | bigint、char(64) | 成功时否 | 转存后真实大小/摘要，供编辑前下载核算和整文件校验；不取Provider声明值 |
| actual_provider、actual_model、provider_request_id | varchar(64)、varchar(128)、varchar(128) | 成功/提交后按实际填写 | 缺失请求号记录缺失原因，不编造 |
| state、succeeded_at、expires_at | varchar(24)、timestamp、timestamp | 否；成功时否 | 原文件转存及校验成功才SUCCEEDED，自身成功+30天；有效作品仍引用则按resource_refs保护文件，不因旧版本自身期限损坏有效作品 |

索引：唯一job_id、(shot_id,state,created_at,id)。已应用和候选共用版本结构；过时但有效成功版本留历史，只有当前shot版本一致且尚无应用时允许首成功自动应用。

<a id="model-12"></a>
### 1.12 catdrama_generation_quotes

> 本版改动：R-11、R-13、R-14、R-22。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、kind、target_type、target_id | bigint、varchar(24)、varchar(24)、bigint | 否 | 单图/批量图/单视频/批量视频所属对象 |
| items_snapshot、input_hash、pricing_version | jsonb、char(64)、varchar(128) | 否 | 每项可提交性、实际引用、模型、参数与计费快照 |
| total_points、expires_at | bigint、timestamp | 否 | 合计非负；报价5分钟过期的技术初值，服务端配置控制 |
| consumed_job_id | bigint | 是 | 一次报价提交只关联一个父/单任务，CAS消费 |

索引：(user_id,expires_at)、consumed_job_id唯一（非空）。改描述/引用/价格/能力则hash或version变化，必须新报价。旧报价不允许按提交请求伪造价格。

<a id="model-13"></a>
### 1.13 catdrama_jobs

> 本版改动：R-06、R-07、R-10、R-11、R-14、R-20、R-21、R-22、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、parent_job_id、kind | bigint、bigint、varchar(32) | 否；父是；种类否 | 免费文本/分析/字幕识别、图片、视频；父只聚合，不执行手机编码 |
| target_type、target_id、input_revision、input_snapshot、input_hash | varchar(24)、bigint、bigint、jsonb、char(64) | 否 | 不可变输入与模型；文本另含Prompt和Markdown版本。字幕target为EPISODE、input_revision为speechRevision，快照保存音频资源/实际摘要和api§9.1请求，不保存时间轴；input_hash由后端规范化请求与资源摘要计算 |
| request_scope | varchar(64) | 字幕/帮写必填，其他为空 | 字幕用clientEditorId，帮写用clientFormId；帮写target_type=USER、target_id=user_id、input_revision=formRevision；同App/账号/表单去重 |
| idempotency_key、quote_id、charge_order_no | varchar(64)、bigint、varchar(64) | 否；后两可空 | UUID幂等键；付费子项记录公共扣费订单；免费任务不建扣费订单 |
| provider_code、model_code、provider_task_id、provider_request_id | varchar(64)、varchar(128)、varchar(128)、varchar(128) | 是 | 字幕在外呼前固定请求号及原路由，受理后记录返回任务号；其他生成按各自提交检查点保存；续查不能换模型或账号 |
| state、phase、progress、checkpoint、result_type、result_id | varchar(24)、varchar(32)、int、jsonb、varchar(24)、bigint | 否QUEUED/PREPARE/0；其余是 | 进度0–100仅反馈，result指内容/分析候选、图片/视频历史或SUBTITLE/ASSET_DESCRIPTION（result_id=本jobId），不包含本机导出；文本步骤保留原始Markdown及校验状态，阶段检查点避免重生成 |
| lease_owner、lease_until、lease_version | varchar(128)、timestamp、bigint | 是；是；否0 | 数据库CAS领取、续租和fencing；失租worker不能提交 |
| attempt、next_run_at、deadline_at、error_code、error_message | int、timestamp、timestamp、int、varchar(500) | 否0；是；否；错误是 | 次数仅技术处理/续查；字幕已受理时不重新提交，FAILED手动重试建新行；字幕deadline只用于超时观测，不把供应商处理中/未知判失败 |
| started_at、finished_at、financial_state | timestamp、timestamp、varchar(24) | 是；是；否FREE | FREE/FROZEN/SETTLED/REFUNDED/RECONCILING；账务以公共订单为准 |

索引：唯一(user_id,kind,idempotency_key)；活动任务部分唯一(target_type,target_id,kind)，适用于实际单对象执行且kind不属于SUBTITLE_RECOGNITION/ASSET_DESCRIPTION、state非终态；字幕与帮写另设活动部分唯一(user_id,target_type,target_id,kind,request_scope)，分别互斥同集同工程和同用户同表单；这两种kind的request_scope非空，其他kind为空；(state,next_run_at,lease_until,id)；(parent_job_id,id)；Provider任务索引(provider_code,provider_task_id)。不同幂等键也不能并发生成同一个shot/asset；旧键内容不同报冲突。

任务行创建即可被轮询worker领取，不靠内存afterCommit通知保证派发。外部调用事务外；检查点与业务版本/引用写入事务内。免费内容候选保存在checkpoint.candidate。字幕识别新增后台SUBTITLE_RECOGNITION Job，音频抽取/上传协调与编码仍是本机状态；识别免费，不建扣费订单。Provider提交结果未知进入SUBMIT_UNKNOWN并核实，不把同一次尝试再提交成新生成；确认扣费失败进入FINALIZING重试原订单，不向用户交付未结算成功。

### 1.13.1 文本步骤检查点

> 本版改动：R-05、R-06、R-07、R-10、R-17。

`input_snapshot`复用公共 `_aiPromptSnapshot` 保存本任务所需模板的版本/hash与内容，并保存变量、模型选择、上游revision和`markdown-v1`。用户内容取创建任务时已保存/已确认的业务正文，包含已确认手改；全剧一次生成使用单一screenplays_all步骤；全剧素材提取和各集镜头拆分各有稳定stepKey。同一任务中依赖前序步骤的已校验内容及引用标记映射，在首次执行该步骤前固定到checkpoint；重试不改读最新草稿或最新模板。

`checkpoint.textSteps`由后端按stepKey维护，每个步骤记录实际调用尝试、原始Markdown、文本SHA-256、格式版本、校验状态/错误位置，以及校验通过后的派生候选。原文按实际收到的字符串保存，换行/空格不重排；即使格式错误或返回截断也保留该次原文。重新调用追加尝试记录，不覆盖上次输出；传给后续步骤或API的MarkdownDocument只取已校验通过的有效尝试，字段见[api§5.1](api.md#api-markdown)。

先持久化输出，再完成分段/引用校验及候选写入；进程在两者之间中断时从已存输出继续，不重调模型。没有持久化输出且调用结果未知时沿用任务核实策略，不凭“缺检查点”盲目重复生成。检查点候选通过才允许SUCCEEDED/应用，空/坏Markdown不能只靠非空jsonb判成功。

业务可编辑正文与只读原文各自维护：Draft/episode保存当前确认或用户编辑内容，分析候选保存分段结果；`ContentCandidate.markdownDocuments`和`AnalysisDiff.markdownDocuments`从有效检查点读取原文。保留期沿用所属任务/项目的既有策略，提示词与原文不公开给其他用户；普通日志只记步骤/版本/hash和错误位置。

### 1.13.1.1 资产描述帮写检查点

沿用catdrama_jobs：kind=ASSET_DESCRIPTION、target_type=USER、target_id=user_id（来自鉴权），request_scope=clientFormId、input_revision=formRevision。input_snapshot固定api§7.1请求及Prompt/模型路由；input_hash由后端规范化快照计算。财务状态FREE，无报价/订单。任务去重、租约、原键续查和FAILED重试沿用现有机制；不以所有用户共用target_id=0代替表单范围。

textSteps保存原始描述正文、请求身份、hash及校验结果，checkpoint.candidate保存AssetDescriptionCandidate，result_type=ASSET_DESCRIPTION、result_id=本jobId。先持久化输出再校验，保存失败恢复检查点。无需预建Asset/Draft，不写资产字段/图片/保留期限；不新增表。拟迁移中仅扩展现有jobs作用域CHECK/部分唯一索引，实施时遵守未正式执行脚本优先调整规则。

### 1.13.2 字幕识别检查点与临时音频

> 本版改动：R-20、R-26；S-25。复用jobs及resource_refs，不新增剪辑工程或字幕校对表。

字幕input_snapshot固定音频资源、实际文件摘要/时长、请求来源及ASR模型，具体传输字段见[api§9.1](api.md#api-subtitles)。checkpoint依次记录受理/供应商请求身份/原任务号/查询结果/标准化字幕结果；result_type=SUBTITLE、result_id=本jobId。先保存真实结果并校验毫秒范围，再事务发布SUCCEEDED；NO_SPEECH作为结果outcome而非伪造字幕。原始供应商分段仅作为受限排障依据，App只取标准化结果。

Job的provider_request_id在外呼前落库，控制面同App原账号/调用映射也在外呼前提交，兼容补强契约见api§9.2。后台使用数据库租约领取并续查同一个供应商任务，重启读取检查点，FINALIZING失败仅重试标准化/保存。查询异常、租约过期、本机超时、deadline观测均不重提交或改为FAILED；供应商明确失败或结果已返回但校验确定失败才记录FAILED。提交未知保留SUBMIT_UNKNOWN并核实原请求身份，不能因没有taskId盲目新提交。

同键异输入拒绝，原键补送先恢复既有行；FAILED后用户新建尝试保留retryOfJobId于输入快照，并在事务内校验前次失败与同一工程、无其他活动任务。同一音频资源可被多次尝试引用。resource_refs使用JOB引用，清理先检查所有活动任务，不能仅凭protect_until_at或deadline过期删掉未知任务文件；终态后每个引用保护至finished_at+24小时，资源取最后截止。没有任务的完整上传按完成时间+24小时清理，新增引用/清理共用资源锁并重查可用性。

清理对象仅临时音频文件与相关临时副本。已标准化结果在所属作品有效期间保持可获取，已受理任务仍可查到终态；旧任务识别键、终态及必要元数据不得因音频清理重置。作品到期/删除仍不取消后台受理恢复，也不恢复作品入口。字幕成功不触发VIDEO续期，不改变积分或成长事实。

<a id="model-17"></a>
### 1.17 catdrama_resource_refs

> 本版改动：R-03、R-11、R-12、R-14、R-18、R-21、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| resource_id、user_id | bigint | 否；公共系统引用user可空 | 公共台账稳定ID，不跨schema |
| ref_type、ref_id、project_id | varchar(24)、varchar(128)、bigint | 否；否；项目可空 | ASSET_VERSION/PROJECT_IMAGE/VIDEO_VERSION/JOB；关联业务稳定编号 |
| protect_until_at、released_at | timestamp | 否；是 | 截止依图片/作品有效期或任务规则计算；字幕终态+24小时、活动任务独立保护；提前软删除可释放普通作品引用，不释放活动任务 |

索引：唯一(resource_id,ref_type,ref_id)、(resource_id,released_at,protect_until_at)、(project_id)。导入/应用/版本快照和引用登记同事务；清理在锁定资源的临界区重新核对引用后删除，不先查再无锁删除。按resourceId取锁，所有新增引用走相同锁顺序，防止清理与新引用竞争。

图片自身expires_at不因引用而改变；作品/剧集及相关引用截止随真实视频成功重设，物理保留截止为自身期限及所有有效引用截止的最大值。资源策略写这个物理截止/保护信息，不能用原始成功+30天的OSS自动删除代替业务清理。释放最后引用后可清理已过期物理文件，保留必要版本元数据/账务关联。用户保存到手机的文件不在这张表管理。

<a id="model-18"></a>
### 1.18 catdrama_growth_tasks

> 本版改动：R-03、R-21、R-24、R-26。

| 列 | 类型 | 可空/默认 | 语义 |
|---|---|---|---|
| user_id、task_code | bigint、varchar(32) | 否 | FIRST_EXPORT / FIRST_PERSONAL_ASSET；账号内各一次 |
| qualified_at、evidence_type、evidence_id | timestamp、varchar(24)、bigint | 满足条件后否 | 真正导出/保存应用成功的稳定事实；媒体删除后事实保留 |
| completion_id | varchar(36) | 首导出申报时非空，素材可空 | 本机成功导出UUID，不存媒体或工程 |
| reward_points、claimed_at、point_biz_id | bigint、timestamp、varchar(128) | 否10；领取前后两是 | 配置快照与公共PointsService稳定bizId |

索引：唯一(user_id,task_code)，point_biz_id唯一（非空）。个人素材事实与可用图保存应用同事务；首导出仅在公共任务领奖时接收本机完成事实，evidence_id指源episode，completion_id varchar(36)可空存本机导出UUID，不存剪辑/成片；领取行锁+PointsService.grantPermanent同事务。bizId固定 `catdrama-growth:{userId}:{taskCode}`；只新增公共PointBizType的漫剧成长分类，不复用支付或签到类型伪记账。关闭任务/删除媒体不删除已领取记录。

<a id="model-19"></a>
### 1.19 迁移、存量与回退

> 本版改动：R-01至R-26。

数据库改动：**本轮无；开发实施计划需要新增14张专属表、约束/索引/注释**，不修改公共现有表，不回填/删除其他App数据。

| 项 | 已核对事实 / 计划 |
|---|---|
| 目录 | 当前 `src/main/resources/db/migration/common/` + 各App专属；catdrama专属目录不存在 |
| 当前源码最新 | build4.20.0；common最高 `V4.16__ai_artifact_marking_actor.sql`；其他目录最高不超过V4.16；catdrama无版本 |
| 拟用文件 | `src/main/resources/db/migration/catdrama/V4.17__catdrama_foundation.sql`，文件名只是规划预约，不在本轮创建；实施前重查编号，若被占用使用实际全目录最大排序号+1 |
| 新文件理由 | 无catdrama现有可调整文件；14张专属表不能放common让其他App创建。公共guest/schema/支付路由靠已有表与配置，不另加公共DDL |
| 发布证据 | 本地最新上传记录2026-10-12 20:16:15、4.20.0/e69c75b5；未核对该JAR内清单和逐schema执行记录，正式执行状态未知，既有SQL全部按冻结处理 |
| 开发前门禁 | 按后端规则05查最新发布→留存JAR→目标schema成功Flyway/只读历史；查是否已有其他任务新增适用catdrama开发SQL，若有且未正式执行优先改现有文件 |
| 执行方式 | 后端配置添加catdrama后Flyway执行common+catdrama；先隔离测试schema验证完整新建及其他App隔离，再由授权发布流程部署执行 |
| 存量 | catdrama当前无已核实线上数据；不能由此推断生产没有schema。上线前只读核实；已有数据按实际状态制定增量，不清库、不repair、不搬写歌账号/素材 |
| 回退 | 关闭catdrama入口/受理并停止领取新任务，保留待处理账务恢复worker，切回兼容代码；新增表保留。不做DROP、删积分、重写订单；DDL物理回退需独立授权和备份 |

新表必须有COMMENT ON TABLE和所有关键列注释；JSON版本、时区、截止、计费和幂等语义写入列注释。MyBatis-Plus BaseMapper + LambdaQueryWrapper优先；租约CAS与行锁若需要少量原子SQL须局限到真实并发必要处。

## 2. App 本地存储

> S-20/D-31及S-25：本机剪辑的数据定义唯一维护在本节；时间轴、撤销和成片均不建服务端表，本机编辑/导出不依赖后台读写或运行配置接口。用户主动获取字幕时使用后台识别任务；账号/创作/付费生成仍沿用公共会话及对应后台业务。

空间按 `catdrama:{environment}:{userId}` 隔离。公共StorageService及付款意图沿用catsinger实际GetStorage/安全存储机制，不迁移公共存储到Hive；新增剪辑工程及关联结构化记录使用Hive，媒体文件使用本机私有目录。退出账号关闭当前播放器/任务并隐藏该用户索引，不依据完成标识删除工程，不让迟到事件写入其他账号。

| 位置 | 内容 | 保存/恢复 |
|---|---|---|
| 安全存储 | accessToken/refreshToken、iOS游客凭证 | 公共身份逻辑不变 |
| Hive draft:{uuid} | 原文/故事/逐集稿、后台revision、保存状态 | 创作阶段仍自动同步后台，失败保留本机稿；与本地剪辑工程分开 |
| Hive editor:{episodeId} | LocalEditor完整快照、历史/redo、源文件索引、选中上下文 | 一次put保存完整工程，串行执行并await/flush，成功后才更新已保存状态；进页从本机恢复，不GET后台timeline |
| Hive media:{localMediaId} | 相对路径、类型、真实字节/摘要、时长/尺寸/精确帧率/音轨、生成能力快照、远端来源ID可空、工程/任务引用 | 源视频/导入音频/封面使用稳定本机ID；下载来源仅存resourceId/版本，不持久签名URL |
| Hive download:{uuid} | 去重源文件/版本、分段/ETag、仍缺预留、进度及失败原因 | 签名到期重新取地址；有效分段续传，取消返回原入口，重进只补缺失/变更 |
| Hive local_task:{uuid} | 本机字幕请求协调记录或导出固定输入、输入hash/进度/失败及结果 | 字幕保存原请求/幂等键/后台jobId，恢复先续查；编码恢复原生任务或校验真实文件，中断后显式重试原输入，不承诺续帧 |
| Hive local_export:{uuid} | 已完成MP4/封面、输入hash、实际参数/摘要、成功时间、保存结果 | 实际文件可播放才SUCCEEDED；没有待上传/云端同步状态 |
| Hive growth:first_export | 本机成功导出UUID/源episodeId一次事实 | 仅任务入口领奖使用，删成片/清缓存不重置 |
| 公共StorageService付款意图 | 沿用公共订单/待核验交易记录机制 | catdrama环境和账号隔离，不因新增编辑器改公共存储，不被清缓存删除 |
| 私有源文件/缓存目录 | 下载完整视频、合法.part、可再获取缩略图；本机导入音轨/封面 | 有效作品下的本机工程及撤销链引用保护；退出编辑不释放，作品到期/删除且无其他有效引用时可清 |
| 私有成片目录、系统相册/文件 | 实际MP4及用户保存副本 | 应用私有临时成片可被清缓存删除，系统相册/用户保存副本不在应用清理范围；先预览后主动保存相册 |

<a id="model-14"></a>
<a id="model-15"></a>
<a id="model-16"></a>
资产帮写表单状态AssetDescriptionFormState使用公共GetStorage，按环境/App/账号/clientFormId保存formRevision、kind/name/description、原请求/幂等键/jobId、候选及本机保存状态。sessionEpoch隔离回写；重开同表单恢复原任务，不写剪辑Hive或预建可用Asset。

### 2.1 本机剪辑对象与命令

| 对象 | 字段/约束 |
|---|---|
| LocalEditorCapabilities | 随App发布并在本机探测：engine=NATIVE_CLIENT、logicalWidth=375、fontDefinitions（code/family/sha256）、defaultFontCode及可用编码器、音频抽取/混音能力；文件音频MP3/WAV/M4A、单文件≤50 MiB并需实际可解码；相册视频按§2.3提取为可解码M4A/AAC，提取结果≤50 MiB，源视频另按缓存/空间核算。预览/编码共用字体与布局版本；输出组合按D-44使用具体源快照/文件与设备能力，配置不从RuntimeConfig读取 |
| LocalEditor | id:UUID、sourceProjectId/sourceEpisodeId:Id、sourceEpisodeRevision:int、documentVersion:int=1、revision/speechRevision/subtitleRevision:int、document:LocalTimelineDocument、undo:History[]、redo:History[]、localSaveState:SAVING/SAVED/FAILED、latestExportId:UUID可空。revision只在本机递增；SAVED表示本机写入成功 |
| LocalTimelineDocument | clips:Clip[]、texts:TextOverlay[]、subtitles:SubtitleCue[]、audioTracks:AudioTrack[]、outputSettings:OutputSettings，cover可空；所有条目UUID稳定，至少一clip才能正式编辑/导出 |
| Clip | id:UUID、shotId/videoVersionId:Id、localMediaId:UUID、inMs/outMs:int、volumeMilli:int0–2000、muted:bool；0≤in<out≤真实源时长，out-in≥500ms；顺序为数组顺序，全局时间由实际片段累积 |
| ClipAnchor | clipId:UUID、sourceStartMs/sourceEndMs:int；文字/字幕保存源相对时段，再投影全局start/end，不用数组下标识别 |
| TextOverlay / SubtitleCue | id:UUID、text:string1–500、anchors:ClipAnchor[]、style:TextStyle；字幕另有source:ASR/MANUAL、reviewed:bool。时段必须在有效时间轴内；局部文字×丢弃、✓保存，未保存稿不参与导出 |
| TextStyle | fontCode:string、fontSize:int8–96、color/outlineColor:#RRGGBB（outline可空）、opacityMilli:int0–1000、align:LEFT/CENTER/RIGHT、xMilli/yMilli:int0–1000、bold:bool、outlineWidth:int0–8；逻辑宽375，布局/字体素材在本机预览及编码共用 |
| AudioTrack | id/localMediaId:UUID、inMs/outMs/startMs:int、volumeMilli:int0–2000、muted:bool；从本机文件复制导入并探测，来源可为文件音频或独立提取的相册视频音频，导入后不依赖原文件，原视频不进入clips。原文件不上传。主动获取字幕时仅按api§9.1上传当前实际混音。尾部超时间轴不播放，短音轨后的静音保真 |
| SourceAudioImport | id/editorId:UUID、sourceLocalPath:string、audioTrackId:string、inMs/outMs:int、state:SELECTING/PREPARING/READY/EXTRACTING/COMMITTING/SUCCEEDED/FAILED/CANCELLED、outputMediaId可空；成功提交AudioTrack才改变工程 |
| CoverSelection | source:FRAME/LOCAL_FILE；FRAME使用clipId/sourceTimeMs，LOCAL_FILE使用localMediaId；不改变源镜头视频 |
| OutputSettings | 记录用户确认的resolution显示值、width/height实际像素、aspectRatio、frameRate实际输出帧率和subtitleStyle:TextStyle；不固定720P/1080P枚举、尺寸或int30。可用组合以该工程源版本的生成能力快照、本机探测元数据与设备能力决定，混合源必须预览确认；离线使用已存依据，不用后台当前模型配置改旧工程。resolution/aspectRatio:string、width/height:int>0、frameRate:api Rational；sourceCapabilities按videoVersionId保存api GenerationCapabilitySnapshot。源元数据与设备编码器求可用交集，混合源映射到选定画布等比居中黑边并按实际时间基准转换帧率；不拉伸、不改变播放速度，缺少依据不可伪造档位。转换误差阈值留样片与真机验证 |
| History | commandId:UUID、type:string、before/after:LocalTimelineDocument；与当前head/redo同一次本机快照保存 |
| LocalSubtitleTask | id/editorId:UUID、speechRevision/baseSubtitleRevision:int、inputHash:string64HEX、fixedAudioInput（仅本机音轨快照）、audioFileId/resourceId可空、原SubtitleJobCreate请求及idempotencyKey、backendJobId可空、state:PREPARING/UPLOADING/SUBMITTING/RECOGNIZING/FETCHING_RESULT/CANDIDATE/NO_SPEECH/STALE/FAILED、lastQueryError可空、cues:SubtitleCue[]；提交前先持久化，网络未知保留阶段/键不置FAILED，后台FAILED才新识别尝试；准备/上传在后台受理前失败可恢复原步骤，不能制造新后台任务；音轨/手改变更令结果过时。字段传输定义只见api§9.1 |
| LocalExport | id:UUID、editorId:UUID、inputHash:string64HEX、fixedDocument:LocalTimelineDocument、state:PREPARING/ENCODING/SUCCEEDED/FAILED/INTERRUPTED、progress:int、相对文件路径/实际摘要/参数/时长；本机真实校验成功为任务SUCCEEDED；albumSaveState:NOT_SAVED/SAVING/SAVED/FAILED记录用户主动保存结果，未点击不写相册；不是作品状态 |

**本机合成输入（本版改动：R-18至R-21）**：`LocalExport.fixedDocument`完整固定`clips`、`audioTracks`、`texts`、`subtitles`与输出设置；`inputHash`覆盖该快照及所用媒体文件摘要。音频的裁剪、起始位置、音量/静音，以及字幕文字、时段和样式均影响当前成片是否有效。原生预览及导出读取同一文档定义，最终MP4包含混音后的声音与已烧入画面的字幕；本机编辑不会修改正在导出的固定快照，新编辑须另行导出。

本机命令包括TRIM/SPLIT/DELETE_CLIP/RESTORE_SHOT/REPLACE_VIDEO_VERSION、SET_CLIP_AUDIO、SET_COVER、ADD/UPDATE/DELETE_AUDIO、SAVE/DELETE_TEXT、SAVE/CLEAR_SUBTITLES、SET_OUTPUT、UNDO/REDO。每次操作本机检查revision和commandId、生成before/after并原子保存完整工程；新编辑清redo。分割两边≥500ms，删除至少留一clip；撤销恢复文字/字幕及完整状态，重进仍有历史。

RESTORE_SHOT仅在该shotId没有任何片段、当前已应用视频已有完整可读本机文件时允许，按原剧本顺序插完整当前视频，免费且不重建已删文字/字幕。仍有分割片段不重复加入。裁剪/删除/分割按source anchors保留/切分，再投影全局时间；无存活anchor的项移除，声音/剪辑变化推进speechRevision，字幕需核对。插入后移现存项，不补新内容。

镜头页换应用只更新源选择，本机片段继续绑定具体videoVersionId。用户明确更新本机片段时再下载所选新版，逐片确认合法区间；越界需重新裁剪或明确恢复全段，取消/失败保旧工程。只从有效作品进入，作品到期隐藏，不提供独立本机入口；新设备不恢复他机编辑。

字幕处理中和导出编码中，App维持当前页面不可关闭的弹框，屏蔽返回/手势切页及编辑命令；OS后台和进程终止单独恢复。账号失效/作品到期的既有守卫优先于页面阻塞：先保留本机状态再退出失效入口，不复活作品或跨账号回写；后台已受理识别继续恢复。字幕恢复原后台job而非重提交；导出检查真实任务/文件，中断才显式重试固定快照。识别成功的候选与后台job身份先落盘，再做本机应用；本机写入失败仍持有同一结果，不改变后台成功状态。所有候选应用仍检查sessionEpoch、editorId和输入/字幕版本；本机持久化成功才显示已保存。

当前时间轴源视频完成下载后直接探测并交原生引擎，支持的原文件直接参与剪辑；不生成统一格式的编辑副本。完整性或设备处理能力不满足时保留工程、在准备步骤显示具体不可用项，不用统一转码掩盖问题。

### 2.2 缓存核算、提示及保护

上限初500MB，可选1/2/5/10GB，按1024²/1024³换算字节。每个源文件/摘要去重，完整有效文件新增为0，合法.part只算仍缺量。开始下载须满足 `cacheUsedBytes + otherReservedBytes + missingBytes <= cacheLimitBytes`；本次已有预留不重复算，写入同步减预留/加真实占用。

预计超限时停在原入口，显示当前用量/上限/所需/超量，提供M-28清理缓存、调整上限、取消；清理后重新核算。单集文件自己就大于上限时说明清空也不足，选更高值或取消，不循环清理、不静默扩容。真实磁盘freeBytes另外检查，预留音频准备/上传临时副本/编码临时文件及成片空间，运行时持续复查，写满不报成功。

清缓存可删除闲置缓存、已到期/删除作品且无其他有效引用的源缓存，以及应用内临时成片；保留有效作品编辑/撤销引用、活动任务、创作草稿及付款意图。保护取决于有效作品引用，不依赖完成/未完成标识。清理前显示范围和可释放量，清理后重核上限；系统相册副本不删除。临时成片删除后latestExportId可保历史操作记录但不得显示文件可预览，可从有效作品重新导出。

本机另存作品有效性快照（projectId/name/expiresAt/serverTime/checkedAt），不新增作品完成状态；恢复/进入及回到前台检查期限。有效且源文件齐备时可离线剪辑，不请求后台剪辑配置。作品到期先保存编辑，提示后返回作品；设备调时不能续期，不能可靠确认有效性时联网刷新。

<a id="source-audio-extraction"></a>
### 2.3 相册视频提取音频的本机接口

NativeMediaEngine新增extractSourceAudio(request)，复用T-07的probe、events及cancel；既有extractAudio是字幕用的当前时间轴混音，不能混用输入。

| 类型 / 方法 | 字段 / 行为 |
|---|---|
| ExtractSourceAudioRequest | operationId:UUID、sourceLocalPath:string、audioTrackId:string、inMs/outMs:int、outputTempPath:string；已授权可读本机文件，0≤in<out≤实际音轨时长；音轨ID与原生试听一致，不混入其他语言轨 |
| ExtractSourceAudioResult | operationId、outputPath:string、durationMs/sizeBytes:int>0、mimeType:string、sha256:string64HEX及实际采样率/声道；可解码M4A/AAC，设备不支持明确失败，返回真实探测数据 |

系统相册单选视频；云端占位媒体由系统下载到本机，准备可取消。LocalAudioImportService复用CacheService核算源文件、临时输出及预留；源视频不按音频50 MiB上限拒绝。结果超过50 MiB停止并提示缩短区间，不静默截断或增加90秒限制。源大小未知时准备过程计量，超限前停止提示，不自动清理受保护文件。

试听选段后提取同一音轨/区间；结果原子落到工程目录、探测并登记LocalMedia后，通过既有ADD_AUDIO命令一次加入，推进revision/speechRevision、标记字幕待核对/导出过时。源视频不进入clips、不上传后台，原相册视频删除或移动不影响独立音轨；音轨沿用起点/裁剪/音量/静音/锚点及撤销规则，超画面部分不输出、短音频不循环。

取消、无音轨、损坏、不支持、权限拒绝、空间不足、系统中断保留旧工程，只清本次不完整文件，不新增半成品音轨。工程提交失败保留已验证输出及操作身份，可重试本机提交而非重提取；重进检查真实文件，不伪报成功。有效工程/撤销/活动导入引用的文件受缓存保护，相册原文件不属于App清理范围。

## 3. 枚举与状态

> 本版改动：R-02、R-04至R-26。

| 枚举 | 取值 | 核心语义 |
|---|---|---|
| SourceType / SplitMode | INSPIRATION、NOVEL、EXISTING_SCRIPT / AUTO、CUSTOM | 三路径；已有剧本不要求草案 |
| DraftState | EDITING、READY、PROJECT_CREATED、EXPIRED、DELETED | READY是版本有效且内容完整，非空Markdown或非空jsonb都不能单独作为完成依据 |
| ObjectState | ACTIVE、EXPIRED、DELETED | project/episode生命周期；各集制作进度另计算 |
| AssetScope / AssetKind | PERSONAL、SYSTEM、PROJECT / ROLE、SCENE、PROP | 不跨App共享私人对象 |
| AnalysisState | RUNNING、CANDIDATE、APPLIED、STALE、FAILED | 候选必须显式应用差异；失败不覆盖现有分析 |
| ShotState | ACTIVE、REMOVED | REMOVED可明确恢复，视频历史不删除 |
| MediaVersionState | GENERATING、SUCCEEDED、FAILED、EXPIRED | SUCCEEDED必须真实文件可交付；applied由对象指针表达 |
| JobKind | STORY、SCREENPLAYS、PROJECT_ANALYSIS、EPISODE_ANALYSIS、IMAGE、VIDEO、BATCH_IMAGE、BATCH_VIDEO、SUBTITLE_RECOGNITION、ASSET_DESCRIPTION | 后台内容/素材/镜头及字幕识别；合成编码只在手机 |
| JobState | QUEUED、RUNNING、SUBMIT_UNKNOWN、FINALIZING、SUCCEEDED、PARTIAL_FAILED、FAILED、SUPERSEDED | PARTIAL_FAILED仅聚合父；SUPERSEDED仅尚未付费/不交付的过时文本分析；账务必须终态才终结付费任务 |
| SubtitleCandidateState | RUNNING、CANDIDATE、NO_SPEECH、STALE、APPLIED、FAILED | 无语音是明确结果，不造空字幕成功；手改期间返回只能成为候选 |
| GrowthState（投影） | NOT_QUALIFIED、CLAIMABLE、CLAIMED | 事实和领取独立，媒体清理不重置 |
| DownloadState（本机） | WAITING_SPACE、DOWNLOADING、VERIFYING、READY、PAUSED、FAILED | 所有必需文件READY且清单版本一致才进编辑；暂停保留有效分段 |
| LocalExportState | PREPARING、ENCODING、SUCCEEDED、INTERRUPTED、FAILED | 实际文件校验后SUCCEEDED；进程终止后编码重试原快照，不假装续帧 |
| DraftSaveState（创作草稿） | SAVING、SAVED、UNSYNCED、FAILED、CONFLICT | 仅用于需同步后台的创作草稿；SAVED需后台确认 |
| LocalEditorSaveState（剪辑工程） | SAVING、SAVED、FAILED | 仅由本机持久化回执推进；无UNSYNCED/云端冲突状态，恢复网络不提交剪辑工程 |

付费子任务：QUEUED→RUNNING→FINALIZING→SUCCEEDED；明确失败→退款完成→FAILED。SUBMIT_UNKNOWN持续核实同一Provider调用；租约超时不等于业务失败。文本/分析新版本使旧结果成为STALE/SUPERSEDED，保留旧稿。父批次等待所有子终态后聚合SUCCEEDED/PARTIAL_FAILED/FAILED，不能因某一失败回滚其他成功版本。

时间轴操作以本文§2.1本机命令为准；产品未提供的镜头重复插入、任意混入他人视频不开放。拆分后clipId各自独立，shotId仍相同；恢复资格以该shotId片段数为0为准。

### 2026-10-15 私有媒体及缓存补充（S-33/D-52）

喵喵漫剧的图片、视频和音频在OSS统一使用私有对象，包括已发布系统素材及案例。PUBLIC仅表示业务上允许公开获取，不代表OSS公共读；客户端经现有资源访问接口取得临时签名，签名过程不探测OSS对象。缓存以resourceId作为资源身份，目录继续隔离App、环境、服务端及账号；签名URL和有效期变化不重复缓存。缓存未命中或文件失效才下载，过期签名重新取签名，不重建资源。资源ID与内容版本一一对应，替换媒体产生新的resourceId；业务保留期和引用校验不因存在本机缓存而绕过。

复用ResourceServiceImpl、ResourceAccessUrlService及App ResourceService；不另建签名API。签名URL只保留当次读取/下载会话，不进业务快照或缓存账本。上传完成、源媒体交付时的实际内容/归属校验仍执行，不能因签名无需访问OSS而省略。资源版本保持不可变；不得覆盖同resourceId所指文件。旧公开对象如需调整实际ACL，需具备本项目资源台账及目标环境后另执行，不在本轮静默修改生产Bucket或其他App。


### T-17 直传资源身份索引（2026-10-15）

仅catdrama开发迁移V4.17调整本schema的resource_records：原摘要唯一索引对非drama类型继续有效，drama对象不以MD5合并；DIRECT_OSS_UPLOAD按(app_code, owner_user_id, resource_type, oss_object_key)唯一，所有状态保留原对象身份，禁止完成重放复活已失效记录。资源表字段不变；不新增上传表，不修改公共迁移或其他App索引。已在新建隔离PG执行验证，现有业务库和正式环境未执行。

### T-08持久化实现核对（2026-10-15）

继续使用现有`catdrama_jobs.input_snapshot/checkpoint`、`catdrama_resource_refs`的JOB引用及公共resource_records，无DDL或迁移。input_snapshot固定form、实际audioSha256/audioSizeBytes/audioDurationMs及原SelectedAiModel；检查点先存recognized/recognizedAt，规范结果以normalizedSubtitle和公开Job.result.subtitle保存。Provider UUID/任务号继续使用原Job字段，原账号映射由T-45公共表承接。

音频保留判定实时读取全部JOB引用及原任务状态；最后finishedAt+24小时，缺失/活动/未知任务保护，不依赖旧protect_until_at或deadline。未关联上传按完成上传created_at的UTC时间+24小时；重复完成不改变旧created_at。资源与新增引用共用同一事务级锁；物理删除后保留Job、规范结果和必要身份。[本轮检测](../05-测试/evidence/T-08/result.json)。

**2026-10-19 T-26 技术同步（U-20261019-VIDEO）：**`DramaVideoModelOptionsService`只读复用公共模型配置/场景映射及`AiModelCallService.describeVideoGeneration`，不依赖带货业务类、不按本机默认密钥目录硬编码全部平台模型。合法组合和契约摘要按真实Provider能力、有效风格及参考图边界形成，公开响应不带渠道私密参数；报价与原任务恢复按冻结模型身份核实。现有`ProductionSettings`字符串/整数类型保持，取消720P/1080P与10/15/30秒固定枚举。原生P类清晰度对应真实短边像素；内部样片验收允许显式、据样片确定的`maximumAspectErrorPixels`，旧快照缺失取0，仍精确核对已验证的尺寸、编码和帧率，不转成虚假高清。对白/旁白以有序确认清单拼入捕获提示词，无口播不重建原文台词；不增加AI请求、独立TTS或字幕前置生成。原任务未知状态只查询原任务。

本地配置：H3/768P/10秒/16:9/ANIME已接通，样片实际1344×768、24fps、10.125秒及AAC音轨；像素对齐值22仅对应该样片配置。其他模型/规格依各自配置与验收依据开放，完整App和逐字声音验收仍未完成。数据库结构/Entity/迁移无改动；本地只新增catdrama视频绑定、更新drama.production与drama.features，私密配置及积分账务未改。


## 视频参数范围保存（2026-10-28）

数据库结构无改动，不新增 SQL 或迁移。单镜头及整集均写 catdrama_shots.production_override，整集仅含当前用户当前集 ACTIVE 且未移出的镜头。参数变化递增镜头 revision、清除 description_ack_hash，调用原项目 Service 更新分集聚合版本及阶段。无变化不递增；不修改作品默认、素材关联、镜头描述或视频历史，无集级默认或数据回填。
