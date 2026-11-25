# 02 翻唱模型与音色配置模块

- 版本：v1.1-ai-cover
- 对应任务：B-COVER-02
- 状态：done
- 影响工程：`/Users/soul/code/lxwx/lxwx_service/lxwxservice`

## 1. 功能定位

本模块提供用户端和后台共用的翻唱模型、音色配置能力。模型决定 provider/model/价格；音色决定用户可选的翻唱声音预设。

## 2. 用户端接口

`GET /api/song-cover/voices`

返回字段：

```json
{
  "voices": [
    {
      "id": 1,
      "name": "温柔女声",
      "group": "FEMALE",
      "tags": ["流行", "清亮"],
      "avatarUrl": "",
      "previewAudioUrl": "",
      "enabled": true,
      "sortOrder": 10
    }
  ]
}
```

## 3. 配置来源

- 音色配置优先使用独立 catsinger 表，便于后台增删改。
- 模型配置可复用现有歌曲模型配置表，新增 `mode=COVER` 或 `model=music-cover`。
- 默认配置：
  - provider：`minimax`
  - model：`music-cover`
  - pricePoints：`150`

## 4. 业务规则

- 用户端只返回启用状态的音色。
- 后台可查看和维护停用音色。
- 音色排序先按分组，再按 `sortOrder`，最后按 `id`。
- 试听音频必须是持久化资源地址。

## 5. 实现步骤

1. 定义 `CoverVoiceEntity`、Repository、Service。
2. 增加用户端只读接口。
3. 增加模型配置读取逻辑，支持 `mode=cover`。
4. 初始化默认 `music-cover` 模型配置。
5. 空音色时返回空数组，不抛 500。

## 6. 验收标准

- catsinger 下能获取音色列表。
- 停用音色不返回用户端。
- 模型价格由配置读取，不写死在 Controller。
