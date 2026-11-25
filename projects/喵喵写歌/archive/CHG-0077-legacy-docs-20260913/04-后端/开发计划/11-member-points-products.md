# 11 会员积分商品模块开发文档

> 版本：v1.0-design-mvp
> 关联任务：T-B011
> 状态：done

## 功能定位

复用现有会员、积分、商品、订单能力，但所有查询和配置必须按 catsinger appCode 隔离。

## 接口范围

- `/api/member/profile`
- `/api/points/account`
- `/api/points/ledger`
- `/api/products`
- `/api/admin/products`

## 业务规则

- 商品配置由后台维护，可配置会员包和积分包。
- 默认模型价格由模型配置决定，生成链路不写死价格。
- 生成扣费使用积分冻结/确认/退款。
- catsinger 商品不能在 narrate App 中展示。

## 实现步骤

1. 检查现有 Product/Entitlement/Point 查询是否带 appCode。
2. 补 catsinger 商品筛选。
3. 后台商品配置支持 selectedAppCode。
4. 回归支付和积分明细。

## 测试要求

- catsinger 商品只在 catsinger 返回。
- 冻结积分、扣减、退款流水完整。
- 旧 narrate 商品和积分不受影响。

## 验收标准

我的页会员、积分、充值和生成扣费可联调。
