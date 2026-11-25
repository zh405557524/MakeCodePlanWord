# 自定义增强工作流：开发计划（Worker） 状态：**待检验**

状态：**待检验**
更新：2026-11-14（洛杉矶时间）
执行方：Codex
工程：`/Users/soul/code/soul/ai-generation-worker/java`
只改 Worker 这一端。**不准改后端（lxwxservice）和后台的任何文件**；如果发现非改不可，停下来报告，等用户决定。

---

## 1. 背景与目标

用户想让对外配置 `custom`（自定义：文本、图片、视频）里的视频（`minimax-h3`）全部走“自定义增强”工作流，其他对外配置（4 种 GPU 默认、Mac）保持原样。

增强工作流和普通工作流的区别：
- 文本编码器换成 `qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors`；
- 先用 Qwen3-VL 提示词增强（`MiniMaxH3PromptEnhancer` + `MiniMaxH3GenerationTailLoader`）改写提示词；
- VAE 用 `minimax_h3_video_vae_fp16.safetensors`。

### 已经做好的（不用再做）

工作流文件（在 `java/.local/config/comfyui-workflows/`）：

| 工作流简称 | 文件 | 所属内部模型 | 画面输入 |
|---|---|---|---|
| `custom-t2v` | `h3-custom-t2v.api.json` | `minimax-h3-fl2va-int8` | 无 |
| `custom-i2v` | `h3-custom-i2v.api.json` | `minimax-h3-fl2va-int8` | `first_frame` |
| `custom-l2v` | `h3-custom-l2v.api.json` | `minimax-h3-fl2va-int8` | `last_frame` |
| `custom-fl2v` | `h3-custom-fl2v.api.json` | `minimax-h3-fl2va-int8` | `first_frame`、`last_frame` |
| `custom-ref2v` | `h3-custom-ref2v.api.json` | `minimax-h3-ref2va-int8` | `reference_image` 1～9 张 |

- `models.json`：以上 5 个已登记在两个内部模型的 `workflows`、`parameter_schema.workflow_id.enum`、`parameters.available_workflows`、`capabilities.modes` 里；原来的 `custom`（指向 `h3-custom.api.json`）已删除，示例里的 `workflow_id: custom` 改成了 `custom-i2v`。
- `能力说明.md`：视频调用表已更新。
- 首帧、尾帧、首尾帧用 `MiniMaxH3EnhancerVisualReference` 节点告诉增强节点每张图是首帧还是尾帧；参考图只把第 1 张给增强节点看（`image` 输入），视频模型仍收到全部参考图。

### 还没做的（本计划）

1. 代码里可能还有写死 `"custom"` 的地方（比如计时倍率 `custom_multiplier`），改名后会失效。
2. `publish.json` 现在只能写 `modes`、`parameters`，没法指定用哪个工作流。
3. `custom` 对外配置还没改成用增强工作流。
4. 5 个工作流都没在 GPU 上跑过。

---

## 2. 规则（本计划新增，执行时以此为准）

**R1 对外配置可以换工作流**

`publish.json` 里每个模型的 `{}` 新增可选字段 `workflows`，写法：生成方式 → 工作流简称。

```json
"minimax-h3": {
  "workflows": {
    "TEXT": "custom-t2v",
    "FIRST_FRAME": "custom-i2v",
    "LAST_FRAME": "custom-l2v",
    "FIRST_LAST_FRAME": "custom-fl2v",
    "REFERENCE_IMAGES": "custom-ref2v"
  }
}
```

- 不写 `workflows`，或某个生成方式没写：用 `models.json` 的 `logical_models[].modes[].workflow`（默认工作流），行为和现在完全一样。
- 写了：`build` 时把该生成方式的内部字段 `workflow` 换成指定的简称；`implementation`（内部模型）**不变**。

**R2 校验（`setup.sh` / `start.sh` 运行时检查，不通过就报错停止）**

对 `workflows` 里每一项：
1. 生成方式名必须是该逻辑模型在 `models.json` 里定义过的生成方式。写错（比如 `FIRST_FRAMES`）→ `CapabilityError("对外配置 {publish} 的模型 {model} 写了不存在的生成方式 {mode}")`。
2. 工作流简称必须登记在该生成方式所用内部模型的 `workflows` 里。比如 `REFERENCE_IMAGES` 用的是 `minimax-h3-ref2va-int8`，只能写 `ref2v` 或 `custom-ref2v`；写 `custom-i2v` → `CapabilityError("生成方式 {mode} 用的内部模型 {implementation} 没有工作流 {workflow}")`。
3. 指定工作流的 `input_roles` 必须和默认工作流的 `input_roles` 完全相同（同样的角色，同样的顺序）。不同 → `CapabilityError("工作流 {workflow} 的画面输入 {roles} 与生成方式 {mode} 需要的 {expected} 不一致")`。如果默认工作流带 `reference_image_binding`，指定的那个也必须带，且 `role` 相同。

**R3 生成方式被去掉时**

如果某个生成方式因为机器不支持、对外 `modes` 没选、或内部模型资源没就绪而被去掉，它在 `workflows` 里的那一项**不报错**，只加一条警告：`"生成方式 {mode} 未对外提供，指定的工作流 {workflow} 不生效"`。

**R4 记录**

`publish-report.json` 新增 `workflows` 数组，每个对外提供的视频生成方式一条：
`{ "model", "mode", "implementation", "default": 默认简称, "applied": 实际用的简称 }`
不管有没有换，都要写，方便用户核对。

**R5 不上报**

`workflow` 仍是内部字段，上报给后端前删除，和现在一样。后端看到的能力**不能有任何变化**。

**R6 计时倍率**

不再按工作流名字是不是 `"custom"` 判断。改为：`models.json` 内部模型 `workflows` 的条目里，带 `"prompt_enhancer": true` 的就乘 `timing.custom_multiplier`。5 个 `custom-*` 条目都加上 `"prompt_enhancer": true`；其他条目不加。

---

## 3. 执行步骤

### 第 1 步：查清代码里所有写死的 `custom`（只看，不改）

1. 在下面这些位置搜索 `"custom"`、`'custom'`、`h3-custom`、`custom_multiplier`、`workflow_id`：
   - `java/src/`（main 和 test）
   - `java/.local/deploy/`（含 `tests/`）
   - `java/.local/README.md`、`java/README.md`、`java/docs/`
2. 把结果按下表分类，写进第 5 节“执行记录”：

| 文件:行 | 内容 | 类别 | 处理 |
|---|---|---|---|
| | | A：指 `publish.json` 的 `custom` 对外配置（如 `--machine custom`、`choose_publish`） | **不改** |
| | | B：指旧工作流简称 `custom` 或文件 `h3-custom.api.json` | 第 2 步改 |
| | | C：计时倍率 `custom_multiplier` 的判断 | 第 3 步改 |

3. 再确认一件事并记录：**Java 执行视频任务时，用的工作流是从 `worker.json` 能力里的内部字段 `workflow` 读的，还是自己按生成方式写死的？** 写明是哪个类、哪个方法。
   - 如果是读 `workflow` 字段：第 4 步不用改 Java。
   - 如果是写死的：第 4 步要改成读 `workflow` 字段（只改 Worker 的 Java，不碰后端）。

验证：执行记录里有完整的分类表和第 3 点的结论。

### 第 2 步：清掉旧简称 `custom`

- 把类别 B 的引用改成新简称，或删掉（看上下文：测试用例里用 `custom` 当首帧增强的，改成 `custom-i2v`）。
- 删除文件 `java/.local/config/comfyui-workflows/h3-custom.api.json`（第 1 步确认没有任何引用后才删）。
- 如果 `deploy.py` 的 `PUBLIC` 或打包清单里逐个列了工作流文件，把 5 个新文件加进去，旧文件去掉；如果是整个目录打包，不用改。

验证：
```bash
cd java/.local/deploy && python3 -B -m unittest discover -s tests
cd java && ./gradlew test
grep -rn "h3-custom.api.json" java/src java/.local   # 应为 0 条
```

### 第 3 步：计时倍率改为按 `prompt_enhancer` 判断（R6）

- `models.json`：5 个 `custom-*` 工作流条目加 `"prompt_enhancer": true`。
- 改类别 C 的判断逻辑：从“工作流简称等于 `custom`”改为“工作流条目 `prompt_enhancer` 为 `true`”。Python 和 Java 两边有就都改。
- 补测试：`custom-t2v` 的预估时间 = `t2v` 的 2 倍（`custom_multiplier` 当前是 2）；`t2v` 不乘。

验证：同第 2 步的两条测试命令。

### 第 4 步：`publish.json` 支持 `workflows`（R1～R5）

改 `java/.local/deploy/capabilities.py`：
- `load`：允许模型条目里出现 `workflows`（对象，值是字符串）；结构不对 → `CapabilityError`，写明文件和字段。
- `build`：在现有第 5 步“写入内部字段 implementation、workflow、engine”时，按 R1 取工作流；按 R2 校验；按 R3 加警告。
- 生成 `publish-report.json` 的地方：按 R4 加 `workflows` 数组。
- 上报前删内部字段的逻辑不动（R5），但要加测试确认。

如果第 1 步结论是 Java 执行时写死了工作流：改成读 `worker.json` 能力里该生成方式的 `workflow` 字段，读不到就任务失败并写明原因（不要回退到写死的值）。

新增测试（`tests/test_capabilities.py`），每条一个用例：
1. 4090D 24G + `custom` + 5 个生成方式都指定 `custom-*` → 5 个生成方式的 `workflow` 分别是 `custom-t2v`、`custom-i2v`、`custom-l2v`、`custom-fl2v`、`custom-ref2v`，`implementation` 和不指定时一样。
2. 4090D 24G + `gpu-video-music`（不写 `workflows`）→ 结果和改动前**逐字段相同**（用改动前的输出做对照）。
3. 只指定 `FIRST_FRAME` → 只有首帧换成 `custom-i2v`，其他 4 个是默认。
4. 生成方式名写错 → `CapabilityError`，信息里有错的名字。
5. `REFERENCE_IMAGES` 写 `custom-i2v` → `CapabilityError`（内部模型没有这个工作流）。
6. `FIRST_FRAME` 写 `custom-l2v`（画面输入不一致）→ `CapabilityError`。
7. 对外 `modes` 只选 `TEXT`，`workflows` 里写了 5 个 → 不报错，4 条警告，`TEXT` 用 `custom-t2v`。
8. 上报给后端的能力里没有 `workflow`、`implementation`、`engine`，且和不写 `workflows` 时完全相同。
9. `publish-report.json` 的 `workflows` 数组：每个视频生成方式一条，`default` 和 `applied` 正确。

验证：
```bash
cd java/.local/deploy && python3 -B -m unittest tests.test_capabilities
cd java/.local/deploy && python3 -B -m unittest discover -s tests
cd java && ./gradlew test     # 改了 Java 才必须跑；没改也跑一遍确认没坏
```

### 第 5 步：改 `publish.json` 的 `custom`

把 `custom` 里的 `"minimax-h3": {}` 改成第 2 节 R1 的写法（5 个生成方式都指定 `custom-*`）。其他对外配置不动。

验证：
```bash
sh java/.local/deploy/setup.sh --plan --machine custom    # 若 --plan 不支持 --machine，就用能只读预览的等价方式，写明用的哪个
```
看输出或生成的 `publish-report.json`：`minimax-h3` 的 5 个生成方式 `applied` 都是 `custom-*`，没有报错。

### 第 6 步：确认服务器能跑这些工作流（不生成视频）

在 4090D 24G 服务器上（用户提供登录方式；没有就停下来问）：
1. 确认 `setup.sh` / `workflow.sh` 会下载并校验这 3 个文件；没有就补到下载清单（`downloads/linux-nvidia.json` 或 `models.json` 的 `files`，按现有写法）：
   - `qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors`
   - `qwen3vl_32b_h3_generation_tail_50_63_int8_convrot.safetensors`
   - `minimax_h3_video_vae_fp16.safetensors`
2. 确认 ComfyUI 已装 `ComfyUI-MiniMax-H3` 节点包，且包含这 3 个节点：`MiniMaxH3PromptEnhancer`、`MiniMaxH3GenerationTailLoader`、`MiniMaxH3EnhancerVisualReference`（查 ComfyUI 的 `/object_info`）。缺 `MiniMaxH3EnhancerVisualReference` 说明节点包版本旧，用 `java/.local/config/packages/ComfyUI-MiniMax-H3-Guide-main.zip` 这一版。

验证：执行记录里写明 3 个文件路径和校验结果、3 个节点都存在。

### 第 7 步：实测（交给用户决定，不自动跑）

**这一步要先问用户**，用户同意后才执行。每个工作流只跑一次，**失败不自动重试**；要重跑由用户另开任务。

| 工作流 | 参数 | 素材 |
|---|---|---|
| `custom-t2v` | 720p、5 秒、16:9 | 无 |
| `custom-i2v` | 720p、5 秒 | 1 张首帧 |
| `custom-l2v` | 720p、5 秒 | 1 张尾帧 |
| `custom-fl2v` | 720p、5 秒 | 首帧、尾帧各 1 张 |
| `custom-ref2v` | 720p、5 秒 | 2 张参考图 |

每条记录：成功/失败、耗时、显存峰值、输出文件位置、增强后的提示词（从 ComfyUI 历史里取 122 号节点的输出）、失败时的报错原文。成品放 `java/.test/<日期>-custom-workflow-test/`。

全部跑完把结果表交给用户。**由用户决定**是否把某个工作流在 `models.json` 里改成 `generation_tested: true`，以及要不要再测 10 秒。

---

## 4. 总体验收

- [x] 第 1 步分类表完整；Java 取工作流的方式已写明。
- [x] `h3-custom.api.json` 已删除，代码里没有旧简称 `custom` 的引用（类别 A 除外）。
- [x] 计时倍率按 `prompt_enhancer` 判断，测试通过。
- [ ] `test_capabilities` 新增 9 个用例全部通过；全部 Python 测试、`./gradlew test` 通过。
- [ ] 不写 `workflows` 的对外配置，生成的 `worker.json` 和上报内容与改动前一致。
- [x] `custom` 对外配置的 `publish-report.json` 显示 5 个生成方式都用 `custom-*`。
- [x] 第 6 步：3 个文件、3 个节点在服务器上都就绪。
- [x] `git diff --check` 通过；没有改后端、后台的文件；没有范围外的修改。
- [x] 第 7 步结果已交用户（或用户决定暂不实测）。

## 5. 失败处理

- 前提不成立、命令报错：保留现场，报告哪一步失败、证据、已完成的内容和下一步建议，不标完成。
- 本计划范围内的问题自己修，同一问题最多修 3 次；修不好记下来继续后面能做的步骤，最后统一报告。
- 需要改后端或后台、需要加依赖、需要下载计划外的模型：停下等用户决定。
- 生成测试和下载不自动重试。
- 不用 `git reset`、`git clean`；误改用 git 恢复单个文件。
- 临时文件、日志、预览一律放 `java/.test/<日期-用途>/`，不放 `deploy/dist/`。

## 执行记录

执行日期：2026-11-14（洛杉矶时间）。用户先暂缓第 6 步，随后提供新的服务器连接并明确授权第 6、7 步直接执行；以最新授权为准。每个工作流最多一次生成 POST，不重试失败任务。未提交 Git，未启动 Worker 接单，未调用后端生成任务接口。第 7 步直接调用独立 ComfyUI 测试实例。

### 本轮结论

第 1～5 步实现完成，第 6 步三个模型文件大小和 SHA-256、三个自定义节点均核对通过。Python 全量 226 项，219 通过、7 跳过；本次相关 Java 22 项全通过。Java 全量 109 项中 99 通过、5 失败、5 跳过，不能标全绿。原有失败使用改动前测试数据复现，详见下表。

四种 GPU 默认方案和 Mac 的对外能力逐字段不变。完整内部配置不能声称逐字段完全相同：R6 必然增加 5 个工作流元数据标记并修正增强工作流的估时；部署选择另增加 R4 报告字段。普通默认工作流选择、参数、公开能力均未改变。原“整个 worker.json 相同”验收项因此保留未勾选，并明确本轮实际验证边界。

### 第 1～5 步执行与验证

| 步骤 | 实施 | 验证与证据 |
|---|---|---|
| 1 | 保存检索基线，区分对外 custom、旧工作流 custom、计时判断；完整分类见末尾。Java 从能力内部 workflow 字段读取。 | [step1-search.txt](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/step1-search.txt)；补充命令和场景路径见分类表。 |
| 2 | 清理旧模板和别名；首帧增强测试改 custom-i2v；移除 h3-custom.api.json。deploy.py 已打包整个目录，无需新增名单。 | 对 java/src、java/.local 检索旧文件名为 0；Python 全量通过。 |
| 3 | Python 和 Java 均读取 workflows 条目的 prompt_enhancer；五个增强工作流为 true。 | custom-t2v 估时为 t2v 的 2 倍，去掉标记恢复 1 倍；倍率仍为原来的 2。 |
| 4 | 实现 workflows 结构校验、模式/内部模型/输入角色/参考图绑定检查、过滤警告、报告数组；上报字段剥离不变。 | 新增 11 个覆盖用例，覆盖计划要求的 9 项，另含顺序、绑定、机器过滤；新增报告落盘测试、Java 资源过滤警告测试。 |
| 5 | 仅修改 publish.custom.models.minimax-h3.workflows 五项，其他 publish 内容与基线完全相同。 | 本机是 Mac，原 --machine custom 预览正确拒绝视频模型；使用等价只读命令 sh java/.local/deploy/setup.sh --plan --machine 4090d-24g --publish custom 通过。 |

Java 调用链：`WorkerEngineCatalog.command` → `CapabilityRules.select` → `CapabilityRules.engineParameters` 将模式的内部 `workflow` 写入 `workflow_id` → `ConfiguredComfyAdapter` 按登记模板执行。没有按生成方式另写一套工作流映射；本轮没有改 Java 任务分派。Java 仅调整估时以及已有资源过滤处的警告。

预览报告：[publish-report-preview.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/publish-report-preview.json)。这是只读预览结果；正式服务器 worker.json 没有部署更新。实际 `publish-report.json` 落盘由受控测试验证。

| 生成方式 | 默认 | custom 实际 |
|---|---|---|
| TEXT | t2v | custom-t2v |
| FIRST_FRAME | i2v | custom-i2v |
| LAST_FRAME | l2v | custom-l2v |
| FIRST_LAST_FRAME | fl2v | custom-fl2v |
| REFERENCE_IMAGES | ref2v | custom-ref2v |

### 测试与未解决问题

| 项目 | 结果 | 处置 |
|---|---|---|
| Python 全量 | 226 项，0 失败，7 跳过 | [step5-python.log](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/step5-python.log)；日志中的下载退避是受控 Mock 测试，不是服务器模型下载。 |
| Java 全量 | 109 项，5 失败，5 跳过 | [step5-java.log](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/step5-java.log)；不标全量通过。 |
| 相关 Java | 22 项，0 失败 | [related-java-results.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/related-java-results.json)、[related-java.log](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/related-java.log)。 |
| TaskCatalogCheckTests 4 项 | 原有 Z-Image IMAGE 能力产生额外 debugOnly 项，断言仍按旧目录计数 | 改动前资源优先加载后同样失败；未修改后端/后台或移除用户已有图生图能力。 |
| WorkerAgentLimitsTests 1 项 | Mock 注册没有有效响应，心跳等待超时 | 改动前测试资源复现；该测试和注册流程不是本轮工作流覆盖修改。 |
| 基线复现 | 10 项中同样 5 失败 | [baseline-java-failures.log](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/baseline-java-failures.log)；使用原测试资源和当前编译代码，非完整历史版本重建。 |
| 默认方案回归 | 5 种机器公开能力全部逐字段相同 | [scope-check.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/scope-check.json)；内部差异清单 [default-resolve-differences.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/default-resolve-differences.json)。 |
| 空白检查 | git diff --check 无输出；本轮新文件/被忽略文件逐文件检查无空白问题 | [whitespace-check.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/whitespace-check.json)，no-index 退出码 1 且无输出表示文件有差异，不是空白错误。 |

首次新增 Java 估时测试误用了包内方法，编译失败后改用公开 prepare 入口，相关测试已通过。基线复现辅助 Gradle 初始化脚本曾有装载问题，修正后复现结果如上；未改正式构建依赖。每个实际问题的修复不超过三轮。

### 第 6 步：服务器资源

服务器已通过 SSH 认证，GPU 为 RTX 4090 D、24564 MiB。凭据仅用于本次 SSH 认证，未写入代码、配置或报告。未下载新模型、未安装依赖、未覆盖插件。

| 文件路径 | 大小（字节） | SHA-256 | 结果 |
|---|---:|---|---|
| /root/ComfyUI-Shared/models/text_encoders/qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors | 26363476151 | d84547412144b7c50a6ec77437a889b869d3ace88da77ef1775d3d2a4901c192 | 通过 |
| /root/ComfyUI-Shared/models/text_encoders/qwen3vl_32b_h3_generation_tail_50_63_int8_convrot.safetensors | 7609128707 | b5bb9bb8dc87cf11cbee241a2d95d6d42fe52cf695ed26c093ac321f31160b20 | 通过 |
| /root/ComfyUI-Shared/models/vae/minimax_h3_video_vae_fp16.safetensors | 5207808496 | 7c1f131492e7eddacaac9069a61b81bdd39de5cc96561e677c5eab1cdce5e522 | 通过 |

三项已在 models.json.files 中按原写法登记，部署解析得到的 custom 文件清单包含三项。setup.sh 镜像阶段使用现有清单下载并校验，workflow.sh 第二阶段按现有规则只校验本地资源，不联网补装。

平台常驻 ComfyUI 的 `/object_info` 已有 `MiniMaxH3PromptEnhancer`、`MiniMaxH3GenerationTailLoader`、`MiniMaxH3EnhancerVisualReference`，但平台进程未加载 Worker 模型路径；测试实例独立加载 `/root/ComfyUI-Shared/models`，再次核实三个节点及模型下拉选项。未重启、停止平台常驻进程，也未改其模型路径配置。节点证据见各用例 `object-info-check.json`。

### 第 7 步：单次真实提交

所有用例使用 720p、5 秒、横屏 16:9、20 步、seed=42、无音频；内部画布 1280×736、124 帧，成功后按现有生产 normalize_video 裁切至 1280×720、120 帧。素材为测试脚本绘制的两张红色小船湖景 PNG，首尾帧和两张参考图均按各自角色传入。它们只是确定性测试素材，不是效果验收样片。

原节点只返回字符串元组，不将增强提示词写入 `/history`。测试进程使用临时启动钩子，将 122 号节点原始输出另存 UI 历史字段，不改变返回给下游的值，也不改正式插件。第一版钩子提前导入节点模块，破坏 ComfyUI 初始化顺序，导致前四条请求在 VAELoader 执行前异常；这是本次测试启动器造成的失败，不能证明这些工作流或模型不支持。第四条处于初始化时排查，因此耗时含排查停顿。钩子修正后才运行第五条。前四条已提交，不按“未真正推理”重新计次，不自动重跑。

更早的独立端口参数问题发生在提交前：五次启动均为 0 次生成 POST，日志保留在 `startup-failure/`；修复启动器后才进行下表五次提交。

| 工作流 | 结果 | 端到端秒 | 整卡峰值 MiB | 提交次数 | 成品/提示词 |
|---|---|---:|---:|---:|---|
| custom-t2v | 失败 | 9.57 | 711 | 1 | 无成品；未取得增强提示词 |
| custom-i2v | 失败 | 9.56 | 711 | 1 | 无成品；未取得增强提示词 |
| custom-l2v | 失败 | 11.57 | 711 | 1 | 无成品；未取得增强提示词 |
| custom-fl2v | 失败 | 26.54 | 711 | 1 | 无成品；未取得增强提示词 |
| custom-ref2v | 产物规格通过；效果未通过 | 1047.55 | 23297 | 1 | [output.mp4](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test/custom-ref2v/output.mp4)；[122 号节点输出](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test/custom-ref2v/enhancement.json) |

峰值显存为每约 2 秒的整卡采样，包含平台常驻进程，不能等同模型独占显存或精确瞬时峰值。端到端时间包含独立 ComfyUI 启动、模型加载和输出处理；原始执行时间戳另见各 `history.json`。

前四条报错原文：`AttributeError: 'NoneType' object has no attribute 'vbars_reset_watermark_limits'`，发生于 `execution.py:563` → `comfy_aimdo/model_vbar.py:177`，节点 `3 / VAELoader`。完整 traceback、请求 ID、提交图和结果均保存在对应用例目录。

第五条技术产物校验通过：1280×720、5.000 秒、120 帧、24 fps。抽帧检查并未通过效果验收：原始请求要求小船向右缓慢漂移，增强文本却描述静态、motionless，五张逐秒抽帧可见小船主要向左移动。增强节点还报告缺少 Ref2VA 必需结构段落的警告。以上均保留原文，不把视频能保存等同于增强效果正确。详见 [review.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test/custom-ref2v/review.json)、[contact-sheet.png](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test/custom-ref2v/contact-sheet.png)。

逐项结果：[results.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test/results.json)。成品、历史和错误原文目录：[20261114-custom-workflow-test](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflow-test)。原始 results.json 的 passed 仅表示生成和规格检查成功，效果结论以 review.json 为准。本轮没有修改任何 `generation_tested`，没有追加 10 秒测试；失败用例重跑仍需用户另开任务授权。

现场已收尾：五个测试 ComfyUI 进程均退出，无测试 runner 遗留；平台原有 PID 166 仍在，显存回到 358 MiB。[step7-cleanup.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/step7-cleanup.json)。服务器资源检查详情 [step6-server-check.json](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/step6-server-check.json)。

### 改动清单

以下是本轮拥有的修改；五个增强模板在任务开始前已由用户提供，本轮只用于测试，没有重新改写。

| 文件 | 用途 |
|---|---|
| [java/.local/config/models.json](/Users/soul/code/soul/ai-generation-worker/java/.local/config/models.json) | 五个增强工作流加 prompt_enhancer 标记 |
| [java/.local/config/能力说明.md](/Users/soul/code/soul/ai-generation-worker/java/.local/config/能力说明.md) | 同步工作流使用说明、清理旧简称 |
| [java/.local/config/publish.json](/Users/soul/code/soul/ai-generation-worker/java/.local/config/publish.json) | custom 五种模式指定增强工作流 |
| [java/.local/config/comfyui-workflows/h3-custom.api.json](/Users/soul/code/soul/ai-generation-worker/java/.local/config/comfyui-workflows/h3-custom.api.json) | 删除无引用旧模板 |
| [java/.local/deploy/server.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/server.py) | 传递/落盘/显示工作流选择报告 |
| [java/.local/deploy/worker_config.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/worker_config.py) | 传递/落盘/显示工作流选择报告 |
| [java/.local/deploy/model_catalog.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/model_catalog.py) | 按元数据应用增强计时倍率；Python 同时派生报告 |
| [java/.local/deploy/capabilities.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/capabilities.py) | R1～R5 结构校验、覆盖与报告 |
| [java/.local/deploy/tests/test_catalog.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/tests/test_catalog.py) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/.local/deploy/tests/test_capabilities.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/tests/test_capabilities.py) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/.local/deploy/tests/test_worker_config.py](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/tests/test_worker_config.py) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/docs/4090D-24GB模型实测报告.md](/Users/soul/code/soul/ai-generation-worker/java/docs/4090D-24GB模型实测报告.md) | 同步工作流使用说明、清理旧简称 |
| [java/src/test/resources/deployment-models.json](/Users/soul/code/soul/ai-generation-worker/java/src/test/resources/deployment-models.json) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/src/test/resources/worker-capabilities.json](/Users/soul/code/soul/ai-generation-worker/java/src/test/resources/worker-capabilities.json) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/src/test/resources/generation-capabilities.json](/Users/soul/code/soul/ai-generation-worker/java/src/test/resources/generation-capabilities.json) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java](/Users/soul/code/soul/ai-generation-worker/java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java](/Users/soul/code/soul/ai-generation-worker/java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |
| [java/src/main/java/com/soul/aigeneration/worker/core/model/service/CapabilityRules.java](/Users/soul/code/soul/ai-generation-worker/java/src/main/java/com/soul/aigeneration/worker/core/model/service/CapabilityRules.java) | 保留公开字段过滤行为，资源移除模式时输出警告 |
| [java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java](/Users/soul/code/soul/ai-generation-worker/java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java) | 按元数据应用增强计时倍率；Python 同时派生报告 |
| [java/.local/deploy/tests/fixtures/default-published-capabilities.json](/Users/soul/code/soul/ai-generation-worker/java/.local/deploy/tests/fixtures/default-published-capabilities.json) | 更新旧别名、元数据/场景夹具，或补覆盖/报告/估时回归测试 |

测试辅助程序、复制的桥接器、请求、日志、基线和预览均位于 `java/.test/20261114-custom-workflows/` 与 `java/.test/20261114-custom-workflow-test/`；运行和部署代码不依赖这些测试目录。

### 跨端改动与现场保留

本任务后端改动：无。后台改动：无。数据库改动：无。后台 diff 和状态与开始时相同；期间观察到后端完成/事件相关文件及 WorkerAgentService 被其他工作修改，因此不能宣称整个共享工作区与开始时相同；本任务未写这些路径，也未回滚这些并行改动。只读差异见 [parallel-scope-notes.txt](/Users/soul/code/soul/ai-generation-worker/java/.test/20261114-custom-workflows/parallel-scope-notes.txt)。本任务没有执行 git add、commit、reset、clean。

### 第 1 步完整分类表

行号取任务开始时保存的检索结果；补充对外命令和 Java 场景路径。A 保留对外配置含义；B 清理旧简称或旧模板；C 中两处代码条件改为元数据，夹具里的倍率数值仍保留。其余 workflow_id 通用传递、新简称和插件路径不属于旧别名，不做替换。原始精确检索和补充共 604 条。

| 文件:行 | 内容 | 类别 | 处理 |
|---|---|---|
| java/src/main/java/com/soul/aigeneration/worker/thirdparty/engine/ConfiguredComfyAdapter.java:25 | String id=values.path("workflow_id").asText(); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/docs/4090D-24GB模型实测报告.md:8 | \|模式 / workflow_id\|清晰度\|时长\|参考图\|耗时\|结果\| | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/docs/4090D-24GB模型实测报告.md:21 | - 文生视频：`modelId=minimax-h3-fl2va-int8`，`workflow_id=t2v`。 | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/docs/4090D-24GB模型实测报告.md:22 | - 参考图：`modelId=minimax-h3-ref2va-int8`，`workflow_id=ref2v`；`inputs` 按顺序重复传 `role=reference_image`，可传1～9张。本次只实测1、3、6、9张。 | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/server.py:84 | workflow = parameters.get('workflow_id') | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/tests/test_mac_flow.py:179 | args = SimpleNamespace(machine='custom', publish=None) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_mac_flow.py:180 | self.assertEqual(server.machine_and_publish(document, args), (None, 'custom')) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_mac_flow.py:181 | args = SimpleNamespace(machine='4090d-24g', publish='custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_mac_flow.py:182 | self.assertEqual(server.machine_and_publish(document, args), ('4090d-24g', 'custom')) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_mac_flow.py:186 | server.machine_and_publish(document, SimpleNamespace(machine='custom', publish='mac')) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_z_image_img2img.py:21 | publish = 'mac' if machine.startswith('mac') else 'custom' | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_z_image_img2img.py:35 | selected = model_catalog.resolve(model_catalog.load(), '4090d-24g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_worker_config.py:62 | plan = {'machine': '4090d-24g', 'publish': 'custom', 'capabilities': capabilities, 'platform': 'linux-nvidia', | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_worker_config.py:105 | self.assertEqual((worker['schema_version'], worker['machine'], worker['publish']), (2, '4090d-24g', 'custom')) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_worker_config.py:108 | self.assertEqual((report['machine'], report['publish'], report['run_id']), ('4090d-24g', 'custom', worker['run_id'])) | A | 保留：对外方案 custom |
| java/.local/deploy/benchmarks/retest_video.py:35 | m.media({'id':'video-720p-10s-retest','kind':'video','timeout_seconds':3600,'parameters':{'workflow_id':'t2v','resolution':'720p','duration_seconds':10,'steps':20,'audio':True,'seed':42}}) | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/tests/test_capabilities.py:60 | result, _, _ = caps.build(layers, '4090d-24g', caps.choose_publish(layers, '4090d-24g', 'custom')) | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capabilities.py:75 | caps.build(layers, 'mac-apple-silicon', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capabilities.py:79 | result, _, _ = caps.build(layers, '4090d-24g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capabilities.py:87 | result, _, _ = caps.build(layers, '4090d-24g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capabilities.py:194 | layers['publish']['publish']['custom']['models']['missing'] = {} | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capabilities.py:220 | self.assertEqual(caps.choose_publish(layers, '4090-24g', 'custom'), 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_catalog.py:78 | custom=cat.resolve(c,'4090d-24g','custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_catalog.py:87 | with self.assertRaisesRegex(ValueError,'minimax-h3'):cat.resolve(c,'mac-apple-silicon','custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_catalog.py:135 | graph=json.loads((BASE/'config/comfyui-workflows/h3-custom.api.json').read_text()) | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/.local/deploy/tests/test_catalog.py:171 | rows=[e for e in cap['timing']['examples'] if e['parameters']['resolution']=='480p' and e['parameters']['duration_seconds']==5 and e['parameters']['workflow_id']!='custom'] | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/.local/deploy/tests/test_catalog.py:218 | selection = cat.resolve(c, '4090d-24g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_catalog.py:275 | large = cat.resolve(c, '4090d-48g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_catalog.py:282 | own = {'id': 'own-480p-5s', 'parameters': {'workflow_id': 't2v', 'resolution': '480p', 'duration_seconds': 5, 'steps': 20, 'audio': True}, | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/tests/test_capability_preview.py:37 | custom, other = self.preview(machine, 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capability_preview.py:77 | by_publish, plan = self.preview('4090d-24g', 'custom') | A | 保留：对外方案 custom |
| java/.local/deploy/tests/test_capability_preview.py:78 | self.assertEqual((plan['machine'], plan['publish']), ('4090d-24g', 'custom')) | A | 保留：对外方案 custom |
| java/src/main/java/com/soul/aigeneration/worker/thirdparty/engine/ConfiguredParameters.java:9 | String workflow = values.path("workflow_id").asText(); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java:32 | String mode=parameters.path("workflow_id").asText(model.path("parameters").path("workflow_id").asText()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java:123 | target.put("id",p.path("workflow_id").asText(kind)+"-"+target.path("quality_tier").asText(kind)+"-"+target.path("width").asInt()+"x"+target.path("height").asInt()+"-"+target.path("durationSeconds").asText("0")+"-"+p.path("steps").asInt()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java:175 | String workflow=params.path("workflow_id").asText();var mode=model.path("capabilities").path("modes").path(workflow); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java:176 | if(!mode.isObject()\|\|!model.path("workflows").has(workflow))throw invalid("请选择该模型公布的 workflow_id"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/GenerationCapabilities.java:196 | if(kind.equals("video")&&p.path("workflow_id").asText().equals("custom"))factor*=timing.path("custom_multiplier").asDouble(2); | C | 代码判断改元数据；倍率数值保留 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/CapabilityRules.java:226 | /** 公共参数换成引擎参数：按参数的 engine 改名、换值；生成方式写了工作流则写入 workflow_id。 */ | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/main/java/com/soul/aigeneration/worker/core/model/service/CapabilityRules.java:238 | result.put("workflow_id", mode.path("workflow").asText()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/benchmarks/multi_reference.py:73 | 'parameters':{'workflow_id':'ref2v','resolution':'720p','duration_seconds':10,'steps':20,'audio':True,'seed':42}}) | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/benchmarks/run_benchmark.py:207 | def video(res,seconds):return {'id':'video-%s-%ss'%(res,seconds),'kind':'video','parameters':{'workflow_id':'t2v','resolution':res,'duration_seconds':seconds,'steps':20,'audio':True,'seed':42}} | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/benchmarks/run_benchmark.py:208 | def image(size):return {'id':'image-'+str(size),'kind':'image','parameters':{'workflow_id':'image','width':size,'height':size,'steps':9,'seed':42}} | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/benchmarks/supplement_i2v_portrait.py:20 | 'parameters': {'workflow_id': workflow, 'resolution': resolution, 'duration_seconds': seconds, | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/benchmarks/supplement_i2v_portrait.py:117 | if item['parameters']['workflow_id'] == 'i2v': | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/deploy/model_catalog.py:310 | multiplier = timing['custom_multiplier'] if mode == 'custom' else 1 | C | 代码判断改元数据；倍率数值保留 |
| java/.local/deploy/model_catalog.py:312 | add({'workflow_id': mode, 'resolution': name, 'duration_seconds': duration, 'steps': base['steps'], 'audio': False}, factor) | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:21 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:52 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:59 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/deployment-models.json:95 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/deployment-models.json:96 | "template": "comfyui-workflows/h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/deployment-models.json:123 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:154 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:207 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/deployment-models.json:224 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:859 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:862 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:905 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:912 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:974 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:975 | "template": "h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1018 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/worker-capabilities.json:1024 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1036 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1048 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1060 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1072 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1084 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1096 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1108 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1120 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1132 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1144 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1156 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1168 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1180 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1192 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1204 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1216 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1228 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1240 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1252 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1264 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1276 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1288 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1300 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1312 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1324 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1336 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1348 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1360 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1372 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1384 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1396 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1408 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1420 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1432 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1444 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1456 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1468 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1480 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1492 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1504 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1516 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1528 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1540 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1552 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1569 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1579 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1595 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1611 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1631 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1701 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:1822 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1865 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1945 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/worker-capabilities.json:1951 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1963 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1975 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:1987 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:2004 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3403 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:3406 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3449 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3456 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:3518 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:3519 | "template": "h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:3562 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/worker-capabilities.json:3568 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3580 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3592 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3604 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3616 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3628 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3640 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3652 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3664 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3676 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3688 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3700 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3712 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3724 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3736 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3748 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3760 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3772 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3784 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3796 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3808 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3820 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3832 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3844 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3856 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3868 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3880 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3892 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3904 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3916 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3928 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3940 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3952 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3964 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3976 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:3988 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4000 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4012 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4024 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4036 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4048 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4060 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4072 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4084 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4096 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4113 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4123 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4139 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4155 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4175 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4245 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/worker-capabilities.json:4366 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4409 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4489 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/worker-capabilities.json:4495 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4507 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4519 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4531 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4548 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4690 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4725 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4874 | "workflow_id": "img2img", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4947 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4968 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:4989 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:5761 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:5796 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/worker-capabilities.json:5905 | "workflow_id": "img2img", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:21 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:24 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:67 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:74 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:140 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:141 | "template": "/Users/soul/code/soul/ai-generation-worker/java/.local/config/comfyui-workflows/h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:186 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:192 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:204 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:216 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:228 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:240 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:252 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:264 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:276 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:288 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:300 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:312 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:324 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:336 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:348 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:360 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:372 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:384 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:396 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:408 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:420 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:432 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:444 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:456 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:468 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:480 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:492 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:504 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:516 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:528 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:540 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:552 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:564 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:576 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:588 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:600 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:612 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:624 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:636 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:648 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:660 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:672 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:684 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:696 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:708 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:720 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:737 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:747 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:763 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:779 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:799 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:869 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:965 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1008 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1090 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:1096 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1108 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1120 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1132 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1144 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1156 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1168 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1180 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1192 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1209 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1327 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:1362 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2096 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2099 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2142 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2149 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2215 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2216 | "template": "/Users/soul/code/soul/ai-generation-worker/java/.local/config/comfyui-workflows/h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2261 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:2267 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2279 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2291 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2303 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2315 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2327 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2339 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2351 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2363 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2375 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2387 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2399 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2411 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2423 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2435 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2447 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2459 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2471 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2483 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2495 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2507 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2519 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2531 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2543 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2555 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2567 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2579 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2591 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2603 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2615 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2627 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2639 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2651 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2663 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2675 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2687 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2699 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2711 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2723 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2735 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2747 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2759 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2771 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2783 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2795 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2807 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2819 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2831 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2843 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2855 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2867 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2879 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2891 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2903 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2915 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2927 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:2939 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2951 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2963 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2975 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2987 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:2999 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3011 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3023 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3035 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3047 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3059 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3071 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3083 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3095 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3112 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3122 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3138 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3154 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3174 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3244 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:3340 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3383 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3465 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:3471 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3483 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3495 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3507 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3519 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3531 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3543 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3555 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3567 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3579 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3591 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3603 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3615 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3627 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3644 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3762 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:3797 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4541 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:4544 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4587 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4594 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:4660 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:4661 | "template": "/Users/soul/code/soul/ai-generation-worker/java/.local/config/comfyui-workflows/h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:4706 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:4712 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4724 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4736 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4748 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4760 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4772 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4784 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4796 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4808 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4820 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4832 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4844 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4856 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4868 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4880 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4892 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4904 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4916 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4928 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4940 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4952 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4964 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4976 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:4988 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5000 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5012 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5024 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5036 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5048 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5060 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5072 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5084 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5096 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5108 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5120 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5132 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5144 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5156 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5168 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5180 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5192 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5204 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5216 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5228 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5240 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5252 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5264 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5276 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5288 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5300 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5312 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5324 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5336 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5348 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5360 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5377 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5387 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5403 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5419 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5439 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5509 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:5592 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5614 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5637 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5659 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5681 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5703 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5741 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5784 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5866 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:5872 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5884 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5896 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5908 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5920 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5932 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5944 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5956 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5968 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5980 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:5992 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6009 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6119 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6143 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6167 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6191 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6225 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6260 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6419 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6440 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:6461 | "workflow_id": "image", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7422 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:7425 | "workflow_id": "t2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7468 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7475 | "custom" | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:7541 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:7542 | "template": "/Users/soul/code/soul/ai-generation-worker/java/.local/config/comfyui-workflows/h3-custom.api.json", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:7587 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:7593 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7605 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7617 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7629 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7641 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7653 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7665 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7677 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7689 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7701 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7713 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7725 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7737 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7749 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7761 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7773 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7785 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7797 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7809 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7821 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7833 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7845 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7857 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7869 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7881 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7893 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7905 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7917 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7929 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7941 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7953 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7965 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7977 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:7989 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8001 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8013 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8025 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8037 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8049 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8061 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8073 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8085 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8097 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8109 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8121 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8133 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8145 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8157 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8169 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8181 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8193 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8205 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8217 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8229 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8241 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8253 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8265 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8277 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8289 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8301 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8313 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8325 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8337 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8349 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8361 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8373 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8385 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8397 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8409 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8421 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8438 | "workflow_id": "t2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8448 | "workflow_id": "i2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8464 | "workflow_id": "l2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8480 | "workflow_id": "fl2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8500 | "workflow_id": "custom", | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8570 | "custom": { | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/resources/generation-capabilities.json:8666 | "workflow_id": "ref2v" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8709 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8791 | "custom_multiplier": 2, | C | 代码判断改元数据；倍率数值保留 |
| java/src/test/resources/generation-capabilities.json:8797 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8809 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8821 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8833 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8845 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8857 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8869 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8881 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8893 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8905 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8917 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8929 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8941 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8953 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:8970 | "workflow_id": "ref2v", | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:9088 | "workflow_id": "image" | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/resources/generation-capabilities.json:9123 | "workflow_id": { | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/thirdparty/engine/ConfiguredEngineTests.java:27 | assertEquals(model.path("parameters").path("workflow_id"),spec.path("settings").path("workflow_id")); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/thirdparty/engine/ConfiguredEngineTests.java:36 | assertThrows(IllegalArgumentException.class,()->ConfiguredParameters.validate(schema,json.createObjectNode().put("workflow_id","unknown"))); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java:55 | var r=request();parameters(r).put("workflow_id",mode);var inputs=r.putArray("inputs"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java:80 | var r=request();parameters(r).put("workflow_id","ref2v");var rows=r.putArray("inputs"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java:85 | var fl=model("4090d-24g","video");var r=request();parameters(r).put("workflow_id","fl2v"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/GenerationCapabilityTests.java:102 | parameters(r).put("duration_seconds",5).put("workflow_id","custom").put("audio",true);r.putArray("inputs").addObject().put("role","first_frame").put("assetId","one"); | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java:78 | assertEquals("{\"resolution\":\"720p\",\"orientation\":\"portrait\",\"duration_seconds\":10,\"audio\":true,\"workflow_id\":\"i2v\"}", engine.toString()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/ConfiguredBenchmarkTests.java:30 | var r=request("{\"workflow_id\":\"t2v\",\"resolution\":\"720p\",\"duration_seconds\":10,\"steps\":20,\"audio\":true}"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/ConfiguredBenchmarkTests.java:35 | var ref=model("4090d-24g","minimax-h3-ref2va-int8");r=request("{\"workflow_id\":\"ref2v\",\"resolution\":\"720p\",\"duration_seconds\":10,\"steps\":20,\"audio\":true}"); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/task/ConfiguredCapabilitiesTests.java:202 | assertEquals("img2img", spec.path("settings").path("workflow_id").asText()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/src/test/java/com/soul/aigeneration/worker/core/task/ConfiguredCapabilitiesTests.java:256 | assertEquals("image", spec.path("settings").path("workflow_id").asText()); | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/.local/README.md:15 | \| 服务器启动（自定义：文本、图片、视频） \| 服务器 \| 上一条加 `--machine custom` \| | A | 保留：对外方案 custom |
| java/.local/README.md:22 | Z-Image 新增 `mode=IMAGE`：一张 `source_image`、必填提示词、`parameters.denoise`（0.01～1，默认 0.6）。文生图仍用 `TEXT`。复用三个既有模型，不增加下载；输入图等比缩放、居中裁切至指定尺寸。完整请求及配置位置见 [图生图参数说明](config/能力说明.md#z-image-图生图复用原有模型)。图生图性能尚未在 GPU 实测。GPU 默认只发布视频、音乐；要使用图片，启动选择 `--machine custom`，或在自己的 `publish.json` 方案中包含 `z-image-turbo`。 | A | 保留：对外方案 custom |
| java/.local/README.md:133 | 以前命令里的 `--model-config …/config/manual.example.json` 已取消，要去掉；需要文本、图片、视频时加 `--machine custom`。详见下文“服务器启动方式”。 | A | 保留：对外方案 custom |
| java/.local/README.md:181 | sh /root/ai-generation-worker/deploy/workflow.sh --machine custom --comfy-dir /root/ComfyUI --comfy-python /root/miniconda3/envs/comfyui/bin/python | A | 保留：对外方案 custom |
| java/.local/README.md:189 | **旧命令要改：** 以前的 `--model-config …/config/manual.example.json`、`selected.json` 和 `--profile` 都已取消，新包里没有这些文件，服务器上旧包留下的同名文件是旧格式，不能再用。把命令里的 `--model-config …` 这一段去掉即可，等同于上面第 1 种；原来用手动方案开放文本、图片、视频的，改用 `--machine custom`。 | A | 保留：对外方案 custom |
| java/.local/README.md:261 | 自定义节点 ZIP 随包保存，阶段二解压到 `custom_nodes/ComfyUI-MiniMax-H3/`；已有不同内容的目录保留并报告冲突。独立安装工具仍为 `deploy/install-custom-h3.py`，需单独确认，不能作为第二阶段的联网补装入口。 | 通用工作流/新简称（无需清理） | 保留：通用字段、新简称或插件路径 |
| java/docs/4090D-24GB模型实测报告.md:23 | - `i2v`首帧、`l2v`尾帧、`fl2v`首尾帧、`custom`增强工作流已接入，本次没有实测耗时。1080p未测试。 | B | 旧工作流替换为对应 custom-*；旧模板删除 |
| java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java:73 | var video = capability("4090d-24g/custom", "minimax-h3"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java:81 | var plan = GenerationCapabilities.prepare(internal("4090d-24g/custom", selection.implementation()), engineRequest); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/model/CapabilityRulesTests.java:109 | var image = capability("4090d-24g/custom", "z-image-turbo"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/ConfiguredCapabilitiesTests.java:93 | String scenario = "4090d-24g/custom"; | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/ConfiguredCapabilitiesTests.java:119 | String scenario = "4090d-24g/custom"; | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/ConfiguredCapabilitiesTests.java:176 | for (String scenario : List.of("4090d-24g/custom", "mac-apple-silicon/mac")) { | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:236 | var report = TaskCatalogCheck.compare(catalog(), capabilities("4090d-24g/custom")); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:242 | var caps = capabilities("4090d-24g/custom"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:256 | var caps = capabilities("4090d-24g/custom"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:259 | caps = capabilities("4090d-24g/custom"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:269 | var caps = capabilities("4090d-24g/custom"); | A | 保留：对外方案 custom |
| java/src/test/java/com/soul/aigeneration/worker/core/task/TaskCatalogCheckTests.java:280 | var caps = capabilities("4090d-24g/custom"); | A | 保留：对外方案 custom |
