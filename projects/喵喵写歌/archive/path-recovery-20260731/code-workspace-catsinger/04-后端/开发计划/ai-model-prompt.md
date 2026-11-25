# 音乐提示词调用模块开发计划

## 完成状态

- 状态: `done`
- 当前变更: `CHG-0021 / v0.6.1`（CHG-0018 结构上的封面提示词小修复）
- 目标: App 只封装音乐上下文，由 `AiModelCallService` 在调用模型前统一触发 core 音乐提示词优化。

## 目标与边界

- App 使用 `MusicPromptContext` 和 `AIModelPromptRequest` 映射歌曲事实，不直接调用提示词服务。
- `AiModelCallService` 新重载调用 `AIModelPromptService`，再委托现有 String 方法；String 方法仍是唯一的 thirdparty Command 创建路径。
- 上下文使用独立 Java 类型传递，不写入最终 `userPrompt`，也不混入 Provider 的 `paramsJson`。
- 不引入责任链、Handler、Catalog、数据库或管理接口，不修改 Command、Provider、REST 或任务结构。

## 实现清单

1. 通用请求契约
   - `AIModelPromptContext`、`AIModelPromptBusinessType`、`AIModelPromptRequest` 和 `AIModelPromptTarget` 表达可扩展调用边界。
   - `MusicPromptContext` 只保存主引导词、风格、场景、对象、歌词、歌名和生成偏好，不解析 Catsinger Map，不生成提示词。
2. `MusicPromptBusiness`
   - 集中管理七种音乐业务模板，按音乐业务基础模板、厂商适配、模型适配固定处理；未知适配使用基础模板。
   - 歌词、音乐、翻唱、歌名和封面图片的输出约束及已有模型限制均归属该类，方便其他音乐 App 复用。
3. `AIModelPromptService`
   - 接收通用请求、期望目标和 provider/model，只校验 target/context 并把音乐业务分发给 `MusicPromptBusiness`。
   - 不保存音乐模板，不直接创建或修改 thirdparty Command。
4. `AiModelCallService`
   - 为文本、图片、音乐、歌词增加上下文请求重载；新重载只做优化和对原 String 方法的委托。
5. Catsinger 调用点
   - 保留歌词辅助、歌曲工作流、歌名重生和封面服务的构造器与业务分支，只把现有数据映射为上下文请求。
   - 歌词、音频引用、模式、参数等仍通过原独立参数传递。

## 验证

- 覆盖上下文规范化、七种音乐业务模板、未知适配回退、歌词不重复、歌名约束和封面正负向分离。
- 捕获最终模型调用参数，验证 provider、model、歌词、模式、音频引用和 `paramsJson` 不变。
- 执行定向测试、全量测试、构建、依赖扫描和差异检查；不得新增既有 31 项积分基线之外的失败。
- 验证结果：core 18 项、模型调用 10 项、Catsinger 集成 9 项定向测试通过；干净基线副本 `build -x test` 通过，全量 466 项仅保留 31 项既有积分基线失败。
- 边界扫描和 `git diff --check` 通过。当前主工作区的标准构建仅受本轮开始前已有的两个 Admin 编译缺口阻塞，本轮代码已独立编译验证。

## 数据库改动

- 无。

## CHG-0021 封面禁用文字约束

- 状态: `done`
- 只修改 `MusicPromptBusiness.buildCoverImagePrompt`：将文字、伪文字、乱码、歌词、标题、字幕、字母、数字、Logo、水印、二维码、招牌、标签、编号和 UI 元素作为硬性约束合并到最终正向 `prompt`。
- 保留现有 `negativePrompt`；不修改 `AIModelPromptService`、`AiModelCallService`、Provider、thirdparty Command、App 调用、REST、数据库或任务结构。
- 补充 core 提示词结果与实际图片 Command 正向提示词断言。
- 验证结果: 2 项封面定向回归和 `build -x test` 通过；全量 471 项剩余 44 项既有基线失败；`git diff --check` 通过。
