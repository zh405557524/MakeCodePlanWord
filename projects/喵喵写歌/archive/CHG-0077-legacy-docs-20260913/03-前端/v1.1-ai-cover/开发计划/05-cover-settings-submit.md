# 05 高级设置与提交模块

- 版本：v1.1-ai-cover
- 对应任务：F-COVER-05
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/catsinger`

## 1. 功能定位

高级设置页是 AI 翻唱第 3 步，用户确认翻唱参数、积分消耗并提交任务。

## 2. 页面结构

- 顶部：返回按钮 + 标题 `高级设置`。
- 进度：第 3 步，共 3 步。
- 源音频摘要卡：标题、时长、来源。
- 目标音色摘要卡：音色名称、标签、试听入口。
- 设置项：
  - 保留原歌词：开关。
  - 保留原伴奏：开关。
  - 音高：`-6 ~ +6`。
  - 情感强度：滑块。
  - 混响：滑块或分段。
- 费用：预计消耗 `150积分`，以后端模型配置为准。
- 底部按钮：`开始翻唱`。

## 3. 提交请求

创建请求字段：

```json
{
  "sourceWorkId": "可选",
  "sourceAudioAssetId": "可选",
  "title": "用户输入歌名或来源标题兜底",
  "titleExplicit": true,
  "coverVoiceCode": "必填",
  "copyrightConfirmed": true,
  "settings": {
    "keepLyrics": true,
    "keepInstrumental": true,
    "pitchShift": 0,
    "emotionStrength": 50,
    "reverb": 30
  },
  "idempotencyKey": "uuid"
}
```

歌名语义：

- 用户输入非空歌名时，`title` 使用用户输入值并发送 `titleExplicit=true`，后端保留该歌名。
- 用户未输入歌名时，`title` 可使用来源标题兜底并发送 `titleExplicit=false`，后端仍可生成正式歌名。

## 4. 校验规则

- 没有源音频：返回上传页。
- 没有音色：返回音色页。
- 未确认版权：不能提交。
- 积分不足：展示充值/获取积分入口。
- 重复点击：提交中按钮 loading，禁止二次提交。

## 5. 交互规则

| 操作 | 规则 |
| --- | --- |
| 调整参数 | 立即更新本地草稿 |
| 点击开始翻唱 | 创建任务成功后进入结果页生成中状态 |
| 创建失败 | 停留当前页，展示错误 |
| 积分不足 | 跳积分/会员页或展示引导弹窗 |

## 6. 实现步骤

1. 新增 `pages/song_cover_settings/`。
2. Controller 从 `SongCoverStore.coverDraft` 读取源音频和音色。
3. 从模型配置读取价格，兜底 `150`。
4. 创建 `idempotencyKey` 并调用 `createCover()`。
5. 成功后跳 `/song-cover/result?taskId=...`。

## 7. 验收标准

- 参数改动不会丢失。
- 提交请求包含完整草稿和幂等键。
- 用户输入的歌名不会被后处理重新生成；空歌名仍允许自动命名。
- 积分不足和接口失败都有可读提示。
- 固定按钮在键盘弹起时不遮挡表单。
