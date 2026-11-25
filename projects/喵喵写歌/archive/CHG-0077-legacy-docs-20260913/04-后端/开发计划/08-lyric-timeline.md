# 08 歌词时间轴模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B008
> 状态：done

## 功能定位

为播放器歌词模式提供逐句时间轴。

## 来源策略

| 来源 | 说明 |
|------|------|
| `PROVIDER` | Provider 返回 timing 时清洗保存 |
| `ESTIMATED` | 按歌词有效行和歌曲时长估算 |
| `MANUAL` | 后台示例歌曲手工维护 |

## 输出结构

```json
[
  { "lineNo": 1, "text": "歌词", "startMs": 0, "endMs": 3200 }
]
```

## 业务规则

- 过滤空行和结构标签。
- 每行至少 1200ms。
- 无 duration 时返回空时间轴，前端静态降级。
- 示例歌曲可由后台录入 `MANUAL` 时间轴。

## 实现步骤

1. 新增 `LyricTimelineService`。
2. 实现 Provider timing 清洗。
3. 实现估算时间轴。
4. Admin 示例配置支持时间轴 JSON 校验。

## 测试要求

- 结构标签不展示。
- 总时长能覆盖全部有效歌词行。
- 非法手工 JSON 拒绝保存。

## 验收标准

作品详情返回 `lyricTimeline` 和 `timelineSource`，前端可逐句高亮。
