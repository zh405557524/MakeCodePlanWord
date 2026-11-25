# 生成中模块开发文档

> 关联任务：T-F009  
> 工程：`/Users/soul/code/lxwx/catsinger`  
> 状态：pending  
> UI 真源：`../../01-需求/references/images/v1.0/首页/作品生成中.png`

## 1. 功能定位

展示歌曲生成进度，并允许用户退出后台等待。

## 2. 页面形态

- 全屏生成中页：Logo、计时、状态文案、预计耗时、关闭按钮
- 生成详情页：歌曲名、当前状态、百分比、阶段流程、剩余时间
- 作品页生成中卡片：封面占位、歌曲名、进度条、模型、剩余时间

## 3. 状态

阶段建议：

- 理解 Prompt
- 编写歌词
- 生成旋律
- 人声生成
- 混音处理

前端需要展示：

- `progressPercent`
- `stageText`
- `estimatedRemainingSeconds`
- `modelDisplayName`
- `failureReason`

## 4. 验收

- [ ] 轮询在页面销毁时停止
- [ ] 生成中可退出
- [ ] 作品页能继续展示进度
- [ ] 失败显示原因
- [ ] 成功跳播放器或作品详情
