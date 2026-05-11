# 执行力 Flutter 模块开发文档 - Integration and QA

> 模块编号：`M-10`  
> 对应总体任务：`F-018 ~ F-020`  
> 状态：`pending`

---

## 一、功能定位与边界

本模块负责 Flutter 阶段收尾：同步态、异常态、主链路联调、Figma 对照走查。

---

## 二、依赖前置

- 前述业务模块已完成基本实现
- 总技术文档、总体开发计划和模块文档均已同步到 Figma 驱动口径

---

## 三、核心验证链路

主链路：

- `Chat -> PlanEditor -> Plan -> BattleMap -> TrackDetail -> Now`

资料链路：

- `Profile -> UserProfile -> Profile`

同步态链路：

- 本地已写入
- `pending_sync`
- `sync_failed`

---

## 四、Figma 对照清单

逐页对照：

- `01-SplashScreen`
- `02-Now`
- `03-Chat`
- `04-Plan`
- `05-BattleMap`
- `06-TrackDetail-换工作`
- `07-TrackDetail-恋爱`
- `08-PlanEditor-恋爱`
- `09-PlanEditor-默认`
- `10-Profile`
- `11-UserProfile`

重点检查：

- 结构层级
- 间距与滚动
- 渐变、卡片、CTA 位置
- 底部导航显示/隐藏规则
- 不同视觉态是否通过同一页面骨架实现

---

## 五、验收标准

- 主链路可点通
- 资料链路可回写
- 同步态和异常态可读
- 关键页面与 Figma 的结构、层级和主题色保持一致

---

## 六、编码注意事项

- QA 阶段不大改架构
- 优先修主链路和高频页
- 若发现文档与实现冲突，先修文档再修代码
