# T-38 签到与积分邀请检测

2026-10-15，当前仍处于开发阶段。本切片已分别提交前端 `dev 3ee1c13`、后端 `dev 56bf1c75`。真实邀请产品路径/落地页尚未实现，最新 Figma 和两端联验未完成，父任务保留“未完成”。

新增 24 项 App、15 项后端方法；相关回归共 102 项 App、42 项后端，0 失败/错误/跳过。`flutter analyze --no-pub` 无问题，25 个 Dart 文件格式检查无改动。测试方法数与 186 条完整验收用例分别统计，重复执行不累加。

| 范围 | 结果与边界 |
|---|---|
| 签到 | 真实 Spring/JWT/独立 PG 覆盖北京午夜、七日、第八日循环、断签及 6 并发唯一发奖；失败发奖整体回滚。App 未知回执先查询，不再直接 POST，不本机加分 |
| 邀请 | 公共绑定关系只给邀请者 10 积分一次；同关系重复/换键/并发、自己/无效/其他 App 码、改绑及禁用规则已检。本人 20+5 分页真实验证，App 45 行分页失败重试另检 |
| 现金前置 | 在独立 PG 注入公共旧现金记录，使现金 overview 真实拒绝；积分进度、绑定、materials 和签到继续成功，未调用现金预检 |
| 数据隔离 | 本 App schema 与实际 `common + catsinger` schema；账号、环境或实际后台变化清私有视图，不接受迟到回写 |
| 海报 | 复用 Catdrama 品牌资源，实际邀请码及二维码；旧音乐海报文件保留但不使用。导出 PNG 经 Vision 解码与受控原 URL 一致，见 [QR 结果](qr-result.json) |
| 相册 | 真实临时文件写入/清理，注入权限/原生保存边界验证失败后可直接重试、成功才提示；这不是手机权限或相册验收 |
| 配置及数据库 | 仅 Catdrama 增加签到/邀请只读默认值；未增加表、列、索引、迁移、账本或依赖。自有 schema 剩余 0，专用 PG 已停止 |

实际代码与字节摘要见 [源码清单](source-manifest.json)。本轮 API 使用既定两条积分门面，materials/records/签到仍复用公共接口；页面使用既有 `account/task_center` 和 `invite/{bind,materials,records}`，没有平行公共业务实现。`UserPageScope` 仅统一页面身份和异步代次，不新增网络或 KV。

## 实际命令和环境

App 工作目录为 `/Users/soul/code/lxwx/catdrama`，Flutter `/Users/soul/data/flutter/flutter/bin/flutter`，依赖锁未变化。

```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn \
CATDRAMA_GROWTH_EVIDENCE='/Users/soul/work/MakeCodePlanWord/projects/喵喵漫剧/v1.0.0/05-测试/evidence/T-38' \
flutter test --no-pub --reporter=json \
  test/growth/checkin_invite_test.dart \
  test/payment/ledger_orders_test.dart \
  test/payment/recharge_test.dart \
  test/services/storage_isolation_test.dart
flutter analyze --no-pub
```

后端工作目录为 `/Users/soul/code/lxwx/lxwx_service/lxwxservice`。本次使用单独启动的 PostgreSQL 18：`127.0.0.1:56284/catdrama_test`，用户 `catdrama_test`、空密码，测试随机 schema 由夹具创建并清理。重跑前须重新启动该独立 PG；没有环境变量导致测试未启用或跳过，不能记为通过。

```sh
JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' \
CATDRAMA_TEST_POSTGRES_URL=jdbc:postgresql://127.0.0.1:56284/catdrama_test \
CATDRAMA_TEST_POSTGRES_USER=catdrama_test \
CATDRAMA_TEST_POSTGRES_PASSWORD='' \
./gradlew test \
  --tests com.lxwx.narrateservice.CatdramaInviteTests \
  --tests com.lxwx.narrateservice.CatdramaLedgerReadTests \
  --tests com.lxwx.narrateservice.CatdramaRechargeTests \
  --offline --console=plain
```

二维码检测只读取测试实际导出 PNG，不修改图片：

```sh
xcrun swift verify-qr.swift invite-poster-export.png
```

## 记录与复检

- [最终 App 原始事件](app-final.jsonl)、[方法摘要](flutter-summary.json)、[静态检查](analyze-final.log)、[格式结果](format-result.json)。
- [后端最终运行日志](backend-related.log)、[42 项方法](backend-summary.json)、[T-38 原始报告](CatdramaInviteTests.xml.gz)、[账务回归](CatdramaLedgerReadTests.xml.gz)、[充值回归](CatdramaRechargeTests.xml.gz)。
- BUG-002：并发唯一冲突后 PG 事务失效，修复前见 [原始失败报告](backend-before-savepoint.xml.gz)。仅 Catdrama 在重复插入前建立保存点，冲突后恢复读取；复检 6 并发全部 200，只有一次记录和发奖，原公共原子事务不变。
- [第一次 App 编译失败](app-attempt-1.jsonl) 是测试访问 QR 私有字段；[第二次 App 失败](app-attempt-2.jsonl) 是回调断言与页面 pump 冲突。修正测试后通过，未放宽生产逻辑。[夹具统一前的通过记录](app-before-fixture.jsonl) 保留，不重复计数。
- [专用数据库清理](database-cleanup.json)、[日志空白规范记录](log-normalization.json)、[Figma 状态](figma-connection.json)、[逐用例结果](case-results.json)、[机器结果](result.json)。

文档复检记录为 `docs-check.json`：47 个任务编号唯一、186 条用例为 9 通过/125 部分/52 未执行，700 个本地链接及本轮实际文件存在性通过；源码摘要与已提交文件一致。文档检查不增加业务测试通过数量。

## 配图检查

7 张图均已实际查看，尺寸及 SHA-256 见 [截图清单](screenshots.json)。这些是 Flutter Widget 实际渲染/海报导出，不是手机截图或最新 Figma 验收。

| 图片 | 观察 |
|---|---|
| [签到成功](task-center-signed.png) | 实际余额 4633、七日奖励、已签到状态和无需二次领取的邀请入口 |
| [读取失败](task-center-error.png) | 明确重试，不用 0 积分代替读取失败 |
| [320 宽绑定失败](bind-error-320.png) | 窄屏与模拟键盘下保留失败输入，确认按钮可见 |
| [真实链接未配置](invite-no-url.png) | 仍可复制实际邀请码/手动绑定，不制造地址或启用分享 |
| [海报页](invite-poster.png) | Catdrama 品牌、实际码、QR 和保存入口，无音乐/现金文案 |
| [实际导出海报](invite-poster-export.png) | 800×1424 PNG，QR 四周留白，Vision 解码与原受控链接一致 |
| [积分邀请记录](invite-records.png) | 今日 2、累计已奖励 45、累计积分 450 与 45 行夹具相符；无会员筛选或提现 |

## 待补范围

真实 Catdrama 邀请产品路径、对应落地页/下载入口仍属 **T-38 内部未完成实现**；公共 URL 服务当前返回空串。不能只记为外部配置，不转给负责保留期的 T-41。当前只验证了正确的无链接降级，以及受控有效链接下的 UI/二维码契约，没有线上落地页证明。

最新 Figma 通道未连接，参考已保存 P-25；完整成长卡片由 T-39 按真实资格接入。两端真实北京日界、字号、复制/系统分享、权限、相册保存、返回与后台中断待 T-43 收口。TC-24-01/02 仅记部分验证；TC-24-03 至 05 仍待成长流程。阶段继续开发，下一步 T-29 下载和校验。

本轮用量未取得，未额外查询。
