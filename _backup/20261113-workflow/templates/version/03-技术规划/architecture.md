# 技术架构

> {版本号} 做完后的**完整**技术架构。有架构变化时直接改，改过的小节下面加 `> 本版改动：R-xx`。

## 1. 技术栈
| 端 | 技术 | 版本 |
|---|---|---|
| App | Flutter | |
| 后端 | Java / Spring Boot | |
| 数据库 | PostgreSQL | |
| 缓存 | Redis | |

## 2. 仓库
| 仓库 | 路径 | 说明 |
|---|---|---|
| App | | |
| 后端 | | 多 App 共用时写明 App Code 和隔离方式 |

## 3. 分层与目录
App 和后端各自的目录结构摘要；详细规范见各仓库 `AGENTS.md` 和规范目录（如 `.cursor/rules/`）。

## 4. 关键流程
用时序图或流程图说明跨端的关键流程（登录、购买、同步……）。

```mermaid
sequenceDiagram
  participant App
  participant Store as 商店
  participant API as 后端
  App->>Store: 发起购买
  Store-->>App: 回执
  App->>API: 上报回执
  API->>Store: 校验
  API-->>App: 权益
```

## 5. 环境与配置
| 环境 | 后端地址 | 说明 |
|---|---|---|
| dev | | |
| prod | | |

配置文件位置、关键配置项（功能开关、限额等）。

## 6. 三方服务
| 服务 | 用途 | 接入位置 | 备注（隐私声明、密钥位置） |
|---|---|---|---|
