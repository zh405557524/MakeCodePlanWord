# 全量 SQL 与正式重建准备证据

2026-10-07。用户授权在尚无正式用户阶段整理全部 SQL，并按备份、清理业务 schema、重建、恢复数据更新正式环境。本轮实现与演练在本机完成，尚未执行正式更新。

## 当前基线

| 顺序 | 范围 | SQL |
|---|---|---|
| V5.0 | 公共 | [common_schema](/Users/soul/code/soul/service/src/main/resources/db/migration/common/V5.0__common_schema.sql) |
| V5.1 | Offer Hunter | [offer_hunter_schema](/Users/soul/code/soul/service/src/main/resources/db/migration/android_interview/V5.1__offer_hunter_schema.sql) |
| V5.2 | 知行力 | [zhixingli_schema](/Users/soul/code/soul/service/src/main/resources/db/migration/zhixingli/V5.2__zhixingli_schema.sql) |
| V5.3 | 钢琴视奏 | [solfeggio_schema](/Users/soul/code/soul/service/src/main/resources/db/migration/solfeggio/V5.3__solfeggio_schema.sql) |

活动 SQL 全局不重号；每个 App schema 先执行公共 V5.0，再执行自己的专属 SQL。构建版本仍为 5.1.0。Apple 表与绑定约束在钢琴视奏 SQL 中，Java migration 已删除。源码规则和部署检查同步约束新版本全局递增。

## 本机验收

- 最终编号的相关 H2/Flyway/Apple/账号/曲谱任务回归 37 项通过，部署脚本及候选配置上传测试 14 项通过，Jar 构建通过。
- Jar 仅含四份活动 SQL，版本唯一且与源码字节相同；14 份历史测试夹具与原 Git 字节相同。见 [产物清单](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/artifact-manifest.json)。
- 三个 App 的最终 PostgreSQL 表结构、默认值、主外键、索引和注释精确一致。见 [结构比较](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/structure-comparison.json)。
- PostgreSQL 18.6 原 V5.0 基线升级演练通过：备份、临时库恢复、重建、167 张业务表逐表行数和完整内容摘要、外键、序列高水位 70000 及下一次插入 70001、失败后旧库/旧历史/旧 Jar 恢复、新 Apple 加密凭证恢复，以及同数量数据内容变化时拒绝清理。见 [实际 PostgreSQL 演练日志](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/postgres-global-versions.log)。
- 正式 env/私密文件本机检查通过；候选 env/P8 先暂存，在数据验证后切换，切换或健康失败恢复原 env/私密文件。对应 [脚本测试日志](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/production-script-final-tests.log)。

## 尚未满足的发布条件

全量回归复测 486 项，481 通过、4 跳过、1 失败。已有 `AudiverisScoreRecognitionServiceTest.interruptionStopsRecognitionProcess()` 在全量中重复失败，单独复测通过：取消任务完成与系统子进程实际退出之间存在时序竞争。本轮未修改该 OMR 逻辑，也未删除或放松断言。日志分别见 [全量复测](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/backend-final-confirmation.log) 和 [单独复测](/Users/soul/code/soul/service/.local/local/checks/sql-baseline-20261007/audiveris-interruption-recheck.log)。测试 XML 和原始失败日志保留在同一忽略证据目录。

源码门禁因本次改动未提交而失败；发布前需处理测试阻塞并满足已提交、干净 `main` 的要求。正式运行方式见 [重建说明](/Users/soul/code/soul/service/docs/sql-baseline-rebuild.md)。

实际 PostgreSQL 演练使用隔离本机数据库；systemd 与健康检查使用夹具。临时服务已停止。本轮没有连接正式服务器、上传 P8、改变正式库、切换正式运行配置、执行真实 Apple OAuth 或进行签名真机授权验收。
