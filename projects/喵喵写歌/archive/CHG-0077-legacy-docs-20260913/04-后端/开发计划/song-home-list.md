# CHG-0026 首页歌曲列表后端模块计划

> 路径恢复：2026-07-31 从错误工作区别名 `catsinger` 迁入；本文 CHG 已按 `旧编号 + 14` 重编号，原文保存在 `archive/path-recovery-20260731/`。

## 边界

- 只维护 catsinger 首页歌曲配置，不修改 App 代码、用户作品生成、支付、订单、权益或积分。
- Controller 只接收参数和包装响应；列表校验、回退、过滤与事务统一在 `SongHomeModuleService`。

## 数据与接口

- 表：`catsinger_song_home_lists`，唯一 `tag_code`，有序 `item_codes_json`，展示数量 1-100。
- DTO：`UpsertSongHomeListRequest(displayCount, itemCodes)`。
- Admin VO：逻辑列表完整配置；Public VO：列表元数据。
- 接口契约与错误行为以 `../java-tech.md` 为准。

## 业务规则

1. 数据库同 tagCode 列表覆盖默认回退；显式空数组有效。
2. 回退列表按同标签歌曲现有排序生成；默认数量为场景模板 4、热门歌曲/其他 10。
3. 显式列表按 itemCodes 顺序解析，公开查询过滤不可用项后再限量。
4. 选入列表的歌曲必须存在且已挂标签；重复编码拒绝。
5. 标签禁用后公开列表不可见；后台仍可查看和编辑配置。
6. 已保存 tagCode 不可修改；删除或移除引用关系前必须先清理列表。

## 测试

- 成功：默认回退、显式覆盖、空列表、独立排序、数量截取、不可用项补位、旧接口兼容。
- 失败：数量越界、未知标签、跨标签歌曲、重复歌曲、修改 tagCode、删除/移除被引用歌曲。
- 路由：Admin 鉴权沿用现有规则；Public 请求覆盖正确、缺少和错误 `X-App-Code`。
