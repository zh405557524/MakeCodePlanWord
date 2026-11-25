状态：待检验（Codex 已执行，2026-11-14）

# 任务清单 · Worker 开发计划

> 两份计划之二。写于 2026-11-14（洛杉矶时间）。
> 工程：`/Users/soul/code/soul/ai-generation-worker`（Java 在 `java/`）。本计划只改 Worker，不改后端、不改后台。
> 先读：仓库 `AGENTS.md`、`java/AGENTS.md`、`java/.cursor/rules/00-编码工作流程.mdc`、`02-项目结构目录.mdc`。
> 临时文件、测试日志一律放 `java/.test/<日期-用途>/`，不放 `java/.local/deploy/dist/`。

## 1. 要解决的问题

后端新增了任务清单接口 `GET /internal/ai-worker/v1/task-catalog`（见《任务清单-后端》第 3 节，返回 `{code, message, data}`，`data` 含 `vocabulary` 和 `channels`）。Worker 启动并注册成功后，取回这份清单，和自己注册的能力对一遍，把对不上的地方告诉用户：

- **后端会派、本机没注册**：业务任务派不到这台机器。
- **本机注册了、后端业务不会派**：只能在后台“Worker 调试”里用。

只提示，不阻止启动、不影响注册和接单。

与用户确认时的说法有一处调整：对比放在 **Java 启动注册之后**做（`start.sh`、服务器 `workflow.sh`、IDEA 启动都会做），`setup.sh` 不做——因为 setup 阶段不连后端，后端地址和凭据只有 Java 读得到。

## 2. 不改动范围

- 能力格式、协议号、注册与心跳内容、`models.json` / `machines.json` / `publish.json` 的内容。
- 端口（8088）、目录结构。根目录 `runtime/`、`scripts/`、`workflows/`、`models/` 不动。
- 工作区已有的未提交改动不是你的，不回滚、不覆盖。不 `git commit`。

## 3. 对比规则

输入：清单 `data`；本机对外能力（`WorkerEngineCatalog.capabilities()`，即已去掉本机字段的那份）。

对清单的每个渠道（`model` + `operation`）：

| 情况 | 记入 | 文案示例 |
|---|---|---|
| 本机没有这个 `model` | `notRegistered` | “后端会派 minimax-h3（业务视频渠道），本机没有注册这个模型” |
| 有模型，但没有任何生成方式的 `operation` 相同 | `notRegistered` | “minimax-h3 没有 VIDEO_GENERATION 的生成方式” |
| 清单的参数名，在该模型同 operation 的所有生成方式里都没声明 | `mismatch` | “后端会发参数 seed，minimax-h3 没有声明” |
| 参数名有，但 `type` 不同 | `mismatch` | “参数 durationSeconds 后端为 number，本机声明为 integer” |
| 清单的素材角色，没有任何生成方式声明 | `mismatch` | “后端会发素材 reference_audio，ace-step-1.5-xl-sft 没有生成方式接收”|
| 清单的文本，没有任何生成方式声明 | `mismatch` | “后端会发文本 lyrics，…没有声明” |

对本机的每个能力：

| 情况 | 记入 | 文案示例 |
|---|---|---|
| `model` 不在清单任何渠道里 | `debugOnly` | “xxx 后端业务不会派，只能在后台调试使用” |
| 模型在清单里，但某生成方式声明的参数名 / 素材角色不在该渠道里 | `debugOnly` | “minimax-h3 的参数 xxx 后端业务不会发” |

说明：`notRegistered` 在只对外提供部分模型的机器上是正常的（例如 Mac 不提供视频、4090D 默认不提供文本和图片），所以它是“提示”不是“错误”；`mismatch` 才表示名字或类型对不上，需要用户去改 `models.json` 或后端清单。

## 4. 分批

按 W1 → W3 顺序，一批验收通过再做下一批，中途不停下等人。

### W1 取清单与对比（Java）
- `core/task/infra/WorkerBackendClient.java`：增加 `JsonNode taskCatalog()`，对 `task-catalog` 发 GET（凭据、超时、错误处理与现有 `post` 一致），返回 `data`；HTTP 404（后端是旧版本）返回 `null`。
- 新增 `core/task/service/TaskCatalogCheck.java`：
  - `static ObjectNode compare(JsonNode catalog, JsonNode capabilities)`：纯函数，按第 3 节输出
    `{"status":"checked","checkedAt":…,"notRegistered":[…],"mismatch":[…],"debugOnly":[…]}`，每项为 `{"model","operation","field","message"}`（没有的字段省略）。
  - 类和方法写中文注释。
- `core/task/service/WorkerAgentService.java`：在注册成功那一处（`registered = true` 之后）调用一次：取清单 → 对比 → 写报告 → 打一行日志（三类各多少条；有 `mismatch` 时用 WARN 并逐条打印）。
  - 取清单失败（网络错误、404、返回格式不对）：报告写 `{"status":"unavailable","reason":…}`，日志一行 INFO，**不抛出、不影响注册和后续接单**。
  - 同一会话只做一次；重新注册后再做一次。
- 报告位置：节点目录 `data/state/task-catalog-report.json`。多后端时（`MultiBackendAgentService`）按现有 `BackendConnectionReport` 区分后端的方式，在同一文件里用 `backends.<后端 id>` 分开；单后端时也用同一结构，保持一种格式。

### W2 启动脚本显示结果
- `java/.local/deploy/remote_deploy.py`：在“全部任务中心已注册”或“待接入”的输出之后，读 `data/state/task-catalog-report.json` 并打印摘要：
  - `checked`：打印三类条数；`mismatch` 逐条打印；另两类各打印前 5 条并注明总数；最后一行给出报告路径。
  - `unavailable` 或文件不存在：打印一行“未取得后端任务清单（原因），跳过核对”。
  - 只打印，不改变脚本返回码。
- 报告可能比连接报告晚几秒生成：最多等 5 秒，等不到按“不存在”处理。

### W3 测试与文档
- Java 测试 `src/test/java/.../core/task/TaskCatalogCheckTests.java`，清单样例直接写在测试里（内容照《任务清单-后端》第 3 节），能力用现有 `src/test/resources/worker-capabilities.json` 的三个场景：
  1. `4090d-24g/gpu-video-music`：`mismatch` 为空；`notRegistered` 含文本、图片两个模型；`debugOnly` 为空。
  2. `mac-apple-silicon/mac`：`mismatch` 为空；`notRegistered` 含 `minimax-h3`。
  3. `4090d-24g/custom`：`notRegistered` 含音乐模型。
  4. 人为构造：能力里把 `durationSeconds` 改名 → `mismatch` 有对应一条，同时 `debugOnly` 有新名字一条；能力里加一个清单没有的模型 → `debugOnly` 有一条；参数类型改掉 → `mismatch` 一条。
  - 如果 1～3 的实际结果里 `mismatch` 不为空，说明现有 Worker 配置和后端清单真的对不上：**不要改测试期望或配置去凑**，把具体条目写进执行记录交用户决定。
- `WorkerAgentHttpTests`（现有的本地假后端测试）补两条：假后端提供 `task-catalog` 时注册后生成报告；假后端返回 404 时报告为 `unavailable` 且注册、心跳照常。
- Python 测试：`java/.local/deploy/tests/` 里给 W2 的打印函数加测试（checked、unavailable、文件不存在三种）。
- 文档：
  - `java/.local/config/能力说明.md` 增加一节“和后端任务清单怎么对照”：一张表，左边是 `models.json → logical_models` 的字段（`model`、`kind`、`modes[].operation`、`parameters[].name/type`、`modes[].inputs[].role`、`modes[].texts[].name`），右边是后端清单 `channels` 的对应字段；写明后端清单文件位置 `/Users/soul/code/lxwx/lxwx_service/lxwxservice/src/main/resources/ai-worker/task-catalog.json`，以及“加新模型、新参数时两边名字必须一致，启动后看 `task-catalog-report.json`”。只加这一节，不改这个文档的其他内容。
  - `java/README.md` 接口与状态部分加一句报告文件的位置和三类的含义。

## 5. 验证

```
cd /Users/soul/code/soul/ai-generation-worker/java && ./gradlew test
cd .local/deploy && python3 -B -m unittest discover -s tests
git diff --check
```

## 6. 联调（两份计划都完成后做一次）

前置：本机后端 `./gradlew bootRun`（8080）已是新代码；Worker 已停。

| 编号 | 步骤 | 预期 |
|---|---|---|
| L1 | `curl -s -H "Authorization: Bearer <节点凭据>" http://127.0.0.1:8080/internal/ai-worker/v1/task-catalog`（凭据从私有配置读，不打印、不写进文件；请求头的写法以 `WorkerBackendClient.post` 实际用的为准） | 200，`data.channels` 4 项 |
| L2 | 不带凭据调同一地址 | 401 |
| L3 | `sh java/.local/deploy/start.sh` | 启动成功；输出里有任务清单核对摘要 |
| L4 | 看 `java/.node/data/state/task-catalog-report.json` | `status: checked`；`mismatch` 为空；`notRegistered` 里有 `minimax-h3`（Mac 不提供视频） |
| L5 | 后台接口 `GET /api/admin/ai-worker/models` | 与加这项功能之前一致（Mac 三个模型） |
| L6 | 停掉后端后重启 Worker | Worker 照常启动并重连；报告为 `unavailable` 或保持上次内容，不报错 |

- 不提交任何生成任务。
- 出问题先判断属于哪一端；属于后端的只记录不改（小改动规则见 `00`）。同一问题最多修 3 次，修不好写进执行记录继续。
- L4 的 `mismatch` 不为空时，逐条写进执行记录，由用户决定改 Worker 配置还是改后端清单。

## 7. 完成后

填写执行记录（每批：改了哪些文件、验证结果；联调 L1～L6 结果），把第一行改为“状态：待检验（Codex 已执行，日期）”。

## 执行记录

> 下列为首次执行记录；本轮最新修复与联调结果见文末“续修执行记录（2026-11-14）”。

执行日期：2026-11-14（America/Los_Angeles）。先完成《任务清单-后端》T1～T4 并填写记录，再按 W1→W2→W3→L1～L6 执行。保留已有未提交改动；未提交 Git，未提交任何真实生成任务，未执行生成自检。Java 21 / Spring Boot 4.1.2。

| 批次 | 改动文件与实现 | 验证结果 |
|---|---|---|
| W1 | `WorkerBackendClient.java` 增加凭据、会话与超时行为一致的 GET，404 返回 null；新增 `TaskCatalogCheck.java` 纯比较，按 model/operation 汇总三类结果、重复字段去重；`WorkerAgentService.java` 注册成功后每会话核对一次，失败只记 unavailable；新增 `TaskCatalogReport.java` 原子写入并统一 backends.default/后端 id；`MultiBackendAgentService.java` 共享节点根目录报告写入器 | 编译、已有 HTTP/多后端测试、人工字段变异与 custom 场景通过；新增假后端覆盖 checked、404、无效 JSON、503、重新注册、并发多后端报告及写盘失败不阻断。真实夹具发现 reference_audio 差异，按 W3 要求保留，详见问题 |
| W2 | `java/.local/deploy/remote_deploy.py` 在连接结果之后显示摘要：全部 mismatch、另两类各前 5 条及总数，checked 显示路径；未取得清单一行说明，最多等 5 秒，不改变返回码 | 新增 `test_task_catalog_report.py` 5 例通过，覆盖 checked、多后端 unavailable、文件缺失、等待上限/延迟落盘、无效报告；`test_one_click.py` 仅在原编排测试隔离新打印等待 |
| W3 | 新增 `TaskCatalogCheckTests.java`；扩展 `WorkerAgentHttpTests.java`、`MultiBackendHttpTests.java`；`java/.local/config/能力说明.md` 只追加对照章节，`java/README.md` 增加报告说明 | Java 全量 102 例：95 通过、2 失败、5 跳过；失败仅为默认 4090D 和 Mac 场景的 mismatch 为空断言，均缺 inputs.reference_audio，未更改测试期望或配置。Python 全量 205 例：198 通过、7 跳过。两端 git diff --check 通过 |

### 第 6 节联调执行记录

使用本机新代码 `./gradlew bootRun`（8080），复用健康的本地 PostgreSQL/Redis；开始时 Worker 已停。节点凭据只在内存读取并加入请求，未打印或落盘请求头。所有实际 HTTP 请求均为本机，只读查询、注册与自动重连，没有生成请求。

| 编号 | 实际结果 | 结论/证据 |
|---|---|---|
| L1 | 节点凭据 GET task-catalog 返回 200，data.channels 为 4 项 | 通过；`L1-L2.json` |
| L2 | 不带凭据 GET 同一地址返回 401 | 通过；`L1-L2.json` |
| L3 | 原命令 `sh java/.local/deploy/start.sh` 编译并启动；readiness=UP，三模型能力可读；等待 60 秒后仍 retrying，脚本显示“服务就绪、待接入”和“未取得后端任务清单（报告文件不存在），跳过核对”，返回原有待接入码 3 | 就绪与打印通过，注册接入受阻。后端注册报 DataIntegrityViolationException，数据库协议约束仍只允许 1/2，Worker 发协议 3；未修改数据库或协议。`L3-start.log`、`L3-start-result.json`、`L3-L5-state.json`、`L-node-constraints.txt`、`L-backend.log` |
| L4 | 注册未成功，因此尚未触发注册后核对，真实节点 task-catalog-report.json 不存在 | 阻塞；未伪造真实节点报告，也未把假后端报告当作真实联调。夹具里的两项 mismatch 已逐条记录在下方 |
| L5 | ADMIN_TEST_USER/ADMIN_TEST_PASSWORD 未提供，不能验证后台 models 接口；本机只读公开能力仍为 huihui-qwen3.8-27b、z-image-turbo、ace-step-1.5-xl-sft 三模型 | 阻塞；公开能力仅作辅助证据，不替代后台鉴权和聚合验收。`L3-L5-state.json` |
| L6 | 后端 8080 已停后执行 start.sh --no-build；Worker readiness=UP，default=retrying/ConnectException，正常持续重连；60 秒后返回原有待接入码 3，摘要提示文件不存在。未成功注册过，因此没有上次报告可保留，也尚未进入注册后的查询分支 | 离线启动/重连与提示通过；unavailable/保留旧报告部分受注册前置阻塞，不能记为完整通过。`L6-stop.json`、`L6-start.log`、`L6-retry.log`、`L6-retry-result.json`、`L6-state.json` |

### 问题、尝试次数和未验证边界

1. 默认 `4090d-24g/gpu-video-music`：model=`ace-step-1.5-xl-sft`，operation=`MUSIC_GENERATION`，field=`inputs.reference_audio`；“后端会发素材 reference_audio，ace-step-1.5-xl-sft 没有生成方式接收”。其 notRegistered 正常为 z-image-turbo 与 huihui-qwen3.8-27b，debugOnly 为空。
2. `mac-apple-silicon/mac`：同样缺 `ace-step-1.5-xl-sft / MUSIC_GENERATION / inputs.reference_audio`；notRegistered 正常含 minimax-h3，debugOnly 为空。以上两项依 W3 明令不修改期望或配置凑通过，修复尝试 0 次；由用户决定改 Worker 配置还是后端业务清单。`4090d-24g/custom` 与人工变异测试通过。这些是夹具结果，不代表已在 4090D 真机完成验收。
3. 本地数据库协议约束导致注册链路受阻，属于本次 Worker 计划范围外；记录后继续，修复尝试 0 次，不改迁移、数据库或协议号。没有生成已检查报告作为替代。
4. 后台测试账号缺失，L5 保留阻塞，不绕过鉴权。无真实生成、第三方、GPU 生成性能验收。
5. L6 首次紧接 TERM 后启动，端口已关闭但原进程尚在释放节点锁，脚本安全拒绝（exit 1）；等待原进程完全退出后重试一次，无代码或锁文件修改。重试后 readiness=UP、正常待接入；仅此 1 次启动时序重试。 没有同一实现问题修复满 3 次的情况。
6. 后端全量测试的 911 个范围外失败、24 个专项跳过已在第一份计划记录；本份不修范围外问题。

### 改动清单与跨端改动

Worker 共 13 个本次实现/测试/文档文件（以上表格逐项列出），不含自动生成运行状态和本地证据。`TaskCatalogReport.java` 是为单端、多端共用文件与并发原子写入增加的辅助类；`MultiBackendHttpTests.java` 的假后端补充 GET 404 并验证共享报告，不改变已有接单语义。根目录 runtime/scripts/workflows/models 未改。models.json、machines.json、publish.json 的 SHA-256 与本轮开始相同。启动脚本按原流程重新生成本地节点配置及备份、构建服务 JAR；没有改私有配置。

跨端按两份独立授权计划顺序完成：后端新增只读任务清单接口和静态清单，将原集合改为清单来源；Worker 只取回并提示，不改变能力协议、注册心跳字段、匹配派单和生成参数。后台前端无改动。后端 GET task-catalog 仅免会话证明，仍须节点凭据，其他接口安全边界不变，详见第一份计划 T3。

数据库 7 个 schema 的 Flyway 历史在启动前后保持一致，未手工修改数据库；任务统计开始/结束均为 SUCCEEDED 3 条。联调结束已以 SIGTERM 正常停止本次 Worker 和后端，8088/8080 均不再监听；本地 PostgreSQL/Redis 保持运行，恢复本轮开始时服务状态，见 final-process-state.json。 没有 Git 提交。

证据目录：`/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-task-catalog/`。含 `W1.log`、`W1-http.log`、`W2.log`、`W3-java-full.log`、`W3-java-summary.json`、`W3-java-failures.json`、`W3-python-full.log`、上表 L 系列证据、`config-hashes-before.json`、`config-unchanged.json`、`L-migrations-before.json`、`L-migrations-after.json`、`L-task-counts-before.txt`、`L-task-counts-after.txt`、`final-checks.json`。真实联调阻塞与受控自动化通过分别记录，未互相替代。

## 续修执行记录（2026-11-14）

用户已追加授权修复数据库协议约束和核查后的 reference_audio 支持。本节为最新结果；首次记录中的两条 mismatch 失败与 L3/L4/L6 注册前置阻塞现已解除，保留原记录用于追溯。L5 缺账号继续阻塞。第一行仍为“待检验”。

### 支持事实与修复

- 后端按在线模式声明是否支持 GENERATION_REFERENCE，能把 1 段整段音频映射到 reference_audio。
- Worker `models.json` 已定义 REFERENCE_AUDIO；`WorkerEngineCatalog` 保留素材输入，`AceStepEngineAdapter` 将本地路径写入 referenceAudio，`ace_step_bridge.py` 传给 GenerationParams.reference_audio。
- 本机 ACE-Step 源码（commit `14c0211d5a0653b0f63e27686f4c3f151b4d8629`）在 text2music 中读取参考音频并形成参考条件；不是 cover/src_audio 或音色克隆。核查路径见 `reference-support-evidence.json`。
- 缺口是 machines.json 的交集只开放 TEXT。现为 Mac 与 4090D 24G 增加原有 REFERENCE_AUDIO 模式，继承机型随基础机型开放；只允许 1 段音频，沿用 TEXT 时长参数：Mac 10～60 秒/默认 10 秒，4090D 10～300 秒/默认 60 秒。保留“生成效果待实测”备注，未扩大时长范围，没有改 models.json、publish.json、私有连接配置或引擎实现。
- 没有为了凑测试删除后端 reference_audio 或修改 TaskCatalogCheckTests 的 mismatch 为空期望；夹具由部署代码按修改后的真实配置重算。原不支持模式的降级测试改为显式构造 TEXT-only 机器，继续验证发布配置不能扩大机器能力。

### 改动清单与验证

| 文件 | 改动和验证 |
|---|---|
| `java/.local/config/machines.json` | 两个基础机型增加 REFERENCE_AUDIO，仅新增 20 行；其他配置值不变 |
| `java/src/test/resources/worker-capabilities.json` | 由真实三层配置重算，两处音乐模式新增，custom 场景和内部模型保持不变；保留原 JSON 格式 |
| `java/.local/deploy/tests/test_capabilities.py` | 验证两种音乐模式时长/实现一致、1 段参考音频、待实测标记、真实配置与夹具一致；原降级、越界用例保留并覆盖两模式 |
| `java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java` | 无素材选择 TEXT、1 段选择 REFERENCE_AUDIO、2 段拒绝；未就绪时保留两种模式并标为不可用 |
| `java/src/test/java/com/soul/aigeneration/worker/thirdparty/engine/EngineAdapterTests.java` | 验证参考路径正确写入 ACE 请求、素材未下载/超过 1 段拒绝，仅组装命令，不运行模型 |
| `java/.local/config/能力说明.md` | 增加音乐参考音频边界和未实测说明，将旧“参考音频未接入”限定为视频模式，避免混淆 |

受影响 Java 专项 23/23 通过。随后 Worker Java 全量 104 例：99 通过、5 跳过、0 失败；原 Mac 与默认 4090D 的 mismatch 两例现通过。Python 全量 206 例：199 通过、7 跳过、0 失败。初次回归各有 1 个固定单模式数量/警告数量断言失败，原因是现已开放两模式；补为两模式覆盖后复验通过，修正 1 轮，无满 3 次未解决问题。两端 git diff --check 通过。

### 第 6 节联调复验

| 编号 | 最新执行结果 |
|---|---|
| L1 | 通过：新后端节点凭据 GET task-catalog 返回 200，4 渠道 |
| L2 | 通过：不带凭据返回 401 |
| L3 | 通过：`sh java/.local/deploy/start.sh` 用当前代码构建并启动，退出 0，readiness=UP，default=connected，真实注册及心跳通过，打印三类摘要 |
| L4 | 通过：真实 `java/.node/data/state/task-catalog-report.json` 中 backends.default.status=checked，mismatch 与 debugOnly 为空，notRegistered 仅 minimax-h3；数据库节点协议为 3，Mac 对外仍为 3 模型 |
| L5 | 阻塞：仍无后台测试账号；未调用伪造鉴权。公开能力里的 3 模型不替代 GET /api/admin/ai-worker/models 验收 |
| L6 | 通过：先以 SIGTERM 停止本次后端和 Worker，确认完全退出后 `start.sh --no-build`；后端离线时 Worker readiness=UP、retrying/ConnectException，旧报告内容与 SHA-256 保持不变；脚本等待 60 秒后按原语义退出 3，正常打印旧核对结果 |

### 数据库改动与跨端改动

数据库修复位于用户同时授权的后端：原地修改未正式发布的 `platform/V5.0__ai_worker_gpu_targeting.sql`，本地约束允许 1/2/3，保留历史协议行；事务内实际执行约束与注释，并仅同步 V5.0 checksum 468616723 → 754232053。正式发布依据、结构备份、事务回滚测试和恢复边界详见第一份计划续修记录。没有全库 repair、清库、改 V4.20 或操作正式库；7 个 schema 的历史仅该条 checksum 改变。

后端另外同步两份 Worker 能力夹具、素材角色契约测试及 README；未改任务清单、Provider 生产逻辑、HTTP 路径/字段、后台前端。Worker 本次只有配置/测试/文档变化，接单与引擎执行代码不变。公开能力新增的是原有 REFERENCE_AUDIO 模式，来自本次“查清两端实际支持情况再修”的授权。

### 交付状态与边界

真实注册后核对已通过；无后台账号项继续阻塞。参考音频参数链路和声明已对齐，但本轮遵守“不提交生成任务”，未验证实际音频效果、GPU 推理或 4090D 真机；不得把代码支持、受控测试或配置开放写成生成验收。启动过程中生成自检均跳过。数据库任务统计前后始终 SUCCEEDED 3 条，没有新增任务。无 Git 提交。

收尾已正常停止本次 Worker 和后端（8088/8080 均不监听），保留本地数据库与 Redis。真实已检查报告保留在节点目录供检验。

证据目录：`/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-protocol-reference/`。含基线备份、`reference-support-evidence.json`、`worker-tests.log`、`worker-tests-r2.log`、`worker-full.log`、`python-tests.log`、`python-tests-r2.log`、`test-summary.json`、L1～L6 HTTP/启动/状态证据、`db-after.json`、`final-process-state.json`、`final-checks.json`。首次报告仍在上一轮证据目录，本轮不覆盖历史日志。

