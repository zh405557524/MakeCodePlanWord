# 接口契约

> v1.0.0 做完后的**完整**接口契约，前后端共用。接口字段只在这里写一次；技术方案和开发计划引用这里的小节。改过的小节下面加 `> 本版改动：R-xx`。
>
> **范围说明**：本版新增和修改的接口（§3、§4）在这里写全字段和样例，后端接口测试按样例断言、网页端假数据直接用样例。网页端复用的现有接口（§5）不在这里复写字段——它们已经被手机端在用，字段的唯一出处是后端 OpenAPI（`/v3/api-docs`）和后端仓库 `docs/module-interfaces/{catdrama,core,growth}.md`；网页端开发时直接连测试环境取真实返回，不做假数据。

## 1. 通用约定

- **Base URL**（与手机端 `lib/utils/constants.dart` 相同）：

  | 环境 | 地址 |
  |---|---|
  | 本地 | 手机端 `http://10.12.1.75:8080`；网页端 `http://localhost:8080`（浏览器与后端在同一台电脑，同后台管理端；2026-11-16 联调时改） |
  | 测试 | `https://test.lxwanxiang.com` |
  | 正式 | `https://www.lxwanxiang.com` |

- **请求头**：

  | 头 | 值 | 必填 | 说明 |
  |---|---|---|---|
  | `X-App-Code` | `catdrama` | 是 | 与手机端同一个 App，数据互通 |
  | `X-OS-Type` | `web` | 否 | 本版起取值 `ios / android / web / windows / mac`（大小写不限）；其他值返回 400。网页端在后端改动上测试环境前先不发（开关控制） |
  | `X-Device-Id` | 网页端随机生成、存在浏览器里的设备标识 | 发验证码时 | 与手机端相同：`POST /api/auth/sms/send`、`POST /api/user/delete-verification-code` 带上，后端按设备限制短信频率（现有逻辑，后端不改；M10） |
  | `X-App-Version` | 网页构建版本，如 `1.0.0` | 否 | |
  | `Authorization` | `Bearer {accessToken}` | 登录后 | |
  | `Idempotency-Key` | 客户端生成的 UUID | 部分写接口 | 与手机端相同：同一次用户动作重试时用同一个键 |

  > 本版改动：R-06（`X-OS-Type` 新增 `web`、`windows`、`mac`）

- **鉴权**：JWT。`accessToken` 默认 24 小时，`refreshToken` 默认 30 天。收到 HTTP 401（业务码 `-401` 或 `-1201`）时调用 `POST /api/auth/refresh` 换新凭证并重放原请求；刷新也失败才要求重新登录。传输失败（断网、超时）不自动重发写操作。
- **响应结构**（成功和失败都一样）：

  ```json
  { "code": 200, "message": "成功", "data": {}, "traceId": "9c1f0b6a2d7e4f31" }
  ```

  成功 `code = 200`；失败 `code` 为负数，`data = null`，HTTP 状态码见 §2。`message` 可直接显示给用户。
- **金额**：整数 `amountCents`，单位“分”，币种见同一对象的 `currency`（本 App 固定 `CNY`）；不用浮点数。积分是整数，没有单位换算。
- **时间**：后端返回不带时区的 `yyyy-MM-ddTHH:mm:ss`（部分字段只到日期 `yyyy-MM-dd`），按 **Asia/Shanghai（北京时间）** 理解；网页原样显示，不做时区换算（用户在国内）。“每天签到”等自然日按北京时间算（后端现有规则）。
- **分页**：请求 `page`（从 1 开始）、`pageSize`（1～100）；返回 `{ items, page, pageSize, total, hasMore }`。
- **跨域**：浏览器从网页域名调接口。网页和接口同域名时无跨域；不同域名时需后端配置放行（技术方案 C-01）。

## 2. 错误码

本版新增的错误码（`core/auth`）：

| code | HTTP | message | 前端表现 |
|---|---|---|---|
| `-1308` | 429 | 当前网络注册过于频繁，请稍后再试或使用手机 App 注册 | 登录 / 注册弹窗红字 |
| `-1309` | 400 | 手机号或密码错误 | 密码框下红字，清空密码 |
| `-1310` | 400 | 该手机号未设置密码，请用验证码登录或先注册 | 红字 + “验证码登录”“去注册” |
| `-1311` | 429 | 密码错误次数过多，请 {N} 分钟后再试或使用验证码登录（N 为剩余分钟，向上取整，1～15） | 红字 + “验证码登录” |
| `-1312` | 400 | 该手机号已注册，请直接登录或使用忘记密码 | 注册页红字 + “去登录”“忘记密码” |
| `-1313` | 400 | 该手机号还没有账号，请先注册或用验证码登录 | 忘记密码页红字 + “去注册” |

网页端会碰到的现有错误码（含义与手机端相同）：

| code | HTTP | message | 前端表现 |
|---|---|---|---|
| `-400` | 400 | 请求参数错误（或具体字段说明） | toast 显示 message |
| `-401` | 401 / 400 | 请先登录 / 账号不可用 | 未登录（HTTP 401）：先刷新凭证，失败弹登录；账号不可用（冻结账号，HTTP 400，2026-11-16 用户定以后端现状为准）：红字 |
| `-403` | 403 | 没有权限访问 | toast |
| `-404` | 404 | 资源不存在 | 页面空态“内容不存在或已删除” |
| `-500` | 500 | 服务器开小差了，请稍后再试 | toast + 可重试 |
| `-1001`～`-1005` | 429 | 短信发送太频繁…（手机号 / IP / 设备 / App 维度） | 发送按钮下红字 |
| `-1006` | 503 | 短信风控服务暂不可用，请稍后再试 | toast（本版起注册 / 新建账号在 Redis 不可用时也返回它） |
| `-1007` | 400 | 验证码错误或已过期 | 验证码框下红字 |
| `-1008` | 503 | 短信服务暂不可用，请稍后再试 | toast |
| `-1201` | 401 | 登录已过期，请重新登录 | 先刷新凭证，失败弹登录（保留当前页内容） |
| `-2001` | 400 | 积分不足 | 显示差额 + “去充值” |
| `-3001` | 400 | 支付订单已过期 | 充值弹窗提示后重新下单 |
| `-6004` | 400 | 未找到产品或已下架 / 支付相关失败说明 | 充值弹窗提示“支付暂不可用”，可换套餐 |
| `-560001` | — | 内容已更新，请核对最新版本 | 提示后重新拉取，不覆盖 |
| `-560002`～`-560017` | — | 漫剧业务（报价变化、素材引用无效、任务处理中等，见后端 `ErrorCode`） | 与手机端同一处理 |
| `-7101`～`-7119` | — | 邀请提现（需先实名、未达最低金额、今日已提交、试算过期等） | 提现弹窗红字，按 message 指引操作 |

> 本版改动：R-11、R-24（新增 `-1308`～`-1313`）

## 3. 新增接口

### 3.1 `POST /api/auth/password/register` 密码注册

> 本版改动：R-11、R-24

- 用途：手机号 + 短信验证码 + 密码注册。手机号已有账号但没设密码 → 给原账号设密码（同一用户 ID）；没有账号 → 新建账号并设密码。成功即登录。
- 鉴权：不需要。请求头 `X-App-Code` 必填。
- 前置：先调现有 `POST /api/auth/sms/send`（`{ "phone": "13800138000" }`）拿验证码。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `phone` | string | 是 | 中国大陆 11 位手机号；后端按现有规则规范化（去空格、`+86`） |
  | `code` | string | 是 | 短信验证码，有效期 5 分钟，验证成功即作废 |
  | `password` | string | 是 | 8～20 位，只能是英文字母、数字、英文符号（ASCII 33～126），不能有空格和中文 |
  | `inviteCode` | string | 否 | 邀请码；无效或不适用时忽略，不影响注册（与短信登录相同） |

- 响应 `data`（与短信登录相同的 `LoginResponse`）：

  | 字段 | 类型 | 可空 | 说明 |
  |---|---|---|---|
  | `accessToken` | string | 否 | |
  | `refreshToken` | string | 否 | |
  | `profile.id` | string | 否 | 用户 ID（数字字符串） |
  | `profile.phoneMasked` | string | 是 | 脱敏手机号，如 `138****8000` |
  | `profile.inviteCode` | string | 是 | 本人邀请码 |
  | `profile.pointsBalance` | integer | 否 | 可用积分 |
  | `profile.vipStatus` | string | 否 | `NONE` / `ACTIVE` / `EXPIRED`（漫剧不用会员，原样返回） |
  | `profile.endAt` | string | 是 | 会员到期日 `yyyy-MM-dd` |
  | `profile.cardType` | integer | 是 | 会员卡类型 |
  | `profile.accountType` | string | 否 | `REGISTERED` |

- 错误：`-1007`、`-1312`、`-1308`、`-400`（密码格式）、`-401`（账号不可用）、`-1006`。
- 计入网页注册限制：仅当这次会**新建**账号、且 `X-OS-Type` 为 `web/windows/mac`。

示例 —— 成功（新手机号，或已有无密码账号）：

```http
POST /api/auth/password/register
X-App-Code: catdrama
X-OS-Type: web
Content-Type: application/json

{ "phone": "13800138000", "code": "123456", "password": "Miao2026!", "inviteCode": "K7M2Q9" }
```

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9.mock-access-token",
    "refreshToken": "mock-refresh-token-0001",
    "profile": {
      "id": "10086",
      "phoneMasked": "138****8000",
      "inviteCode": "P3X8DA",
      "pointsBalance": 120,
      "vipStatus": "NONE",
      "endAt": null,
      "cardType": null,
      "accountType": "REGISTERED"
    }
  },
  "traceId": "mock-trace-reg-ok"
}
```

失败 —— 验证码错误（HTTP 400）：

```json
{ "code": -1007, "message": "验证码错误或已过期", "data": null, "traceId": "mock-trace-reg-1007" }
```

失败 —— 已设过密码（HTTP 400）：

```json
{ "code": -1312, "message": "该手机号已注册，请直接登录或使用忘记密码", "data": null, "traceId": "mock-trace-reg-1312" }
```

失败 —— 网页注册限制（HTTP 429）：

```json
{ "code": -1308, "message": "当前网络注册过于频繁，请稍后再试或使用手机 App 注册", "data": null, "traceId": "mock-trace-reg-1308" }
```

失败 —— 密码格式（HTTP 400）：

```json
{ "code": -400, "message": "密码需为 8～20 位英文字母、数字或符号", "data": null, "traceId": "mock-trace-reg-400" }
```

失败 —— 账号不可用（HTTP 400，沿用现有短信登录对冻结账号的返回）：

```json
{ "code": -401, "message": "账号不可用", "data": null, "traceId": "mock-trace-reg-401" }
```

失败 —— 风控服务不可用（HTTP 503）：

```json
{ "code": -1006, "message": "短信风控服务暂不可用，请稍后再试", "data": null, "traceId": "mock-trace-reg-1006" }
```

### 3.2 `POST /api/auth/password/login` 密码登录

> 本版改动：R-11

- 用途：手机号 + 密码登录。
- 鉴权：不需要。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `phone` | string | 是 | 手机号 |
  | `password` | string | 是 | 密码（长度不在 8～20 时直接按 `-1309` 处理，不提示格式，避免泄露信息） |

- 响应 `data`：`LoginResponse`，同 §3.1。
- 规则：
  - 手机号没有账号、或账号没有密码 → 都返回 `-1310`（不区分）。
  - 密码错：错误次数 +1，返回 `-1309`；第 5 次错误直接返回 `-1311`（N=15）。锁定期间不比对密码，直接 `-1311`。触发锁定时错误次数清零，15 分钟后重新从 0 计。
  - 错误次数在最后一次错误 24 小时后自动清零；登录成功、重置密码都会清零并解锁。
  - 锁定只影响密码登录，验证码登录照常。
- 错误：`-1309`、`-1310`、`-1311`、`-401`、`-1006`。

示例 —— 成功：

```http
POST /api/auth/password/login
X-App-Code: catdrama
X-OS-Type: web
Content-Type: application/json

{ "phone": "13800138000", "password": "Miao2026!" }
```

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9.mock-access-token",
    "refreshToken": "mock-refresh-token-0002",
    "profile": {
      "id": "10086",
      "phoneMasked": "138****8000",
      "inviteCode": "P3X8DA",
      "pointsBalance": 120,
      "vipStatus": "NONE",
      "endAt": null,
      "cardType": null,
      "accountType": "REGISTERED"
    }
  },
  "traceId": "mock-trace-login-ok"
}
```

失败 —— 密码错误（HTTP 400）：

```json
{ "code": -1309, "message": "手机号或密码错误", "data": null, "traceId": "mock-trace-login-1309" }
```

失败 —— 没有账号或未设密码（HTTP 400）：

```json
{ "code": -1310, "message": "该手机号未设置密码，请用验证码登录或先注册", "data": null, "traceId": "mock-trace-login-1310" }
```

失败 —— 已锁定（HTTP 429）：

```json
{ "code": -1311, "message": "密码错误次数过多，请 15 分钟后再试或使用验证码登录", "data": null, "traceId": "mock-trace-login-1311" }
```

失败 —— 账号不可用（HTTP 400，沿用现有短信登录对冻结账号的返回）：

```json
{ "code": -401, "message": "账号不可用", "data": null, "traceId": "mock-trace-login-401" }
```

失败 —— 风控服务不可用（HTTP 503）：

```json
{ "code": -1006, "message": "短信风控服务暂不可用，请稍后再试", "data": null, "traceId": "mock-trace-login-1006" }
```

### 3.3 `POST /api/auth/password/reset` 重置 / 设置密码

> 本版改动：R-11、R-28

- 用途：手机号 + 短信验证码 + 新密码。忘记密码，以及设置页“登录密码”（手机号填当前账号）共用。账号原来没密码 = 设置密码。成功即登录（返回新凭证），旧密码失效，错误次数和锁定清零。不吊销其他设备的登录。
- 鉴权：不需要（设置页调用时也不依赖登录态）。
- 前置：先调 `POST /api/auth/sms/send`。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `phone` | string | 是 | 手机号 |
  | `code` | string | 是 | 短信验证码 |
  | `password` | string | 是 | 新密码，规则同 §3.1 |

- 响应 `data`：`LoginResponse`，同 §3.1。
- 错误：`-1007`、`-1313`、`-400`（密码格式）、`-401`、`-1006`。

示例 —— 成功：

```http
POST /api/auth/password/reset
X-App-Code: catdrama
X-OS-Type: web
Content-Type: application/json

{ "phone": "13800138000", "code": "123456", "password": "NewMiao2026#" }
```

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9.mock-access-token",
    "refreshToken": "mock-refresh-token-0003",
    "profile": {
      "id": "10086",
      "phoneMasked": "138****8000",
      "inviteCode": "P3X8DA",
      "pointsBalance": 120,
      "vipStatus": "NONE",
      "endAt": null,
      "cardType": null,
      "accountType": "REGISTERED"
    }
  },
  "traceId": "mock-trace-reset-ok"
}
```

失败 —— 验证码错误（HTTP 400）：

```json
{ "code": -1007, "message": "验证码错误或已过期", "data": null, "traceId": "mock-trace-reset-1007" }
```

失败 —— 手机号没有账号（HTTP 400）：

```json
{ "code": -1313, "message": "该手机号还没有账号，请先注册或用验证码登录", "data": null, "traceId": "mock-trace-reset-1313" }
```

失败 —— 密码格式（HTTP 400）：

```json
{ "code": -400, "message": "密码需为 8～20 位英文字母、数字或符号", "data": null, "traceId": "mock-trace-reset-400" }
```

失败 —— 账号不可用（HTTP 400，沿用现有短信登录对冻结账号的返回）：

```json
{ "code": -401, "message": "账号不可用", "data": null, "traceId": "mock-trace-reset-401" }
```

失败 —— 风控服务不可用（HTTP 503）：

```json
{ "code": -1006, "message": "短信风控服务暂不可用，请稍后再试", "data": null, "traceId": "mock-trace-reset-1006" }
```

## 4. 修改的接口

### 4.1 `POST /api/auth/sms/login` 短信验证码登录

> 本版改动：R-24（只新增一种失败；请求和返回字段不变）

- 请求（不变）：`phone`（必填）、`code`（必填）、`inviteCode`（可选）。
- 响应（不变）：`LoginResponse`，同 §3.1。
- 新增失败：`X-OS-Type` 为 `web/windows/mac`，这次登录会新建账号（手机号没有账号，或原账号已注销），且同一 IP 最近 30 天在网页端已新建 100 个账号 → `-1308`，不建号。已有账号的登录不计数、不受限。手机端（`ios/android` 或不传）不计数。
- 计数只在验证码通过、账号真正建成后才算；建号失败不算。

示例 —— 成功（不变）：

```http
POST /api/auth/sms/login
X-App-Code: catdrama
X-OS-Type: web
Content-Type: application/json

{ "phone": "13900139000", "code": "123456" }
```

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9.mock-access-token",
    "refreshToken": "mock-refresh-token-0004",
    "profile": {
      "id": "10087",
      "phoneMasked": "139****9000",
      "inviteCode": "Q8W2ZM",
      "pointsBalance": 0,
      "vipStatus": "NONE",
      "endAt": null,
      "cardType": null,
      "accountType": "REGISTERED"
    }
  },
  "traceId": "mock-trace-sms-ok"
}
```

失败 —— 新增：网页注册限制（HTTP 429）：

```json
{ "code": -1308, "message": "当前网络注册过于频繁，请稍后再试或使用手机 App 注册", "data": null, "traceId": "mock-trace-sms-1308" }
```

失败 —— 验证码错误（现有，HTTP 400）：

```json
{ "code": -1007, "message": "验证码错误或已过期", "data": null, "traceId": "mock-trace-sms-1007" }
```

### 4.2 请求头 `X-OS-Type`

> 本版改动：R-06

- 取值：`ios`、`android`、`web`、`windows`、`mac`（大小写不限）；不传也可以。
- 新值的效果：商品价格用基础价（`/api/products` 只有 `ios` 用苹果价，原逻辑）；不能创建游客（原逻辑只允许 iOS）；网页注册限制（§4.1、§3.1）；电脑支付宝支付（§4.3）。

失败 —— 不支持的值（HTTP 400，`AppCodeFilter` 直接返回）：

```http
GET /api/drama/config
X-App-Code: catdrama
X-OS-Type: linux
```

```json
{ "code": -400, "message": "Unsupported X-OS-Type", "data": null, "traceId": "mock-trace-os-400" }
```

成功 —— 新值被接受（返回与不传该头时相同）：

```http
GET /api/drama/config
X-App-Code: catdrama
X-OS-Type: web
```

```json
{ "code": 200, "message": "成功", "data": { "…": "与现有 /api/drama/config 返回相同" }, "traceId": "mock-trace-os-ok" }
```

### 4.3 `POST /api/payments/orders`、`POST /api/payments/orders/{orderNo}/pay-params`（电脑端支付宝）

> 本版改动：R-04、R-12、R-26（字段不变；只改电脑端 `alipay_web` 的 `formHtml` 内容）

- 创建订单请求（不变）：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `productType` | string | 是 | 积分充值固定 `POINTS` |
  | `productId` | string | 是 | `GET /api/products?type=POINTS` 返回的商品 ID |
  | `channel` | string | 是 | 网页端固定 `alipay_web`（也接受 `4`） |

  请求头可带 `Idempotency-Key`（同一次点击重试用同一个键）。

- 响应 `data`（`CreateOrderResponse`，不变）：

  | 字段 | 类型 | 可空 | 说明 |
  |---|---|---|---|
  | `orderNo` | string | 否 | 订单号 |
  | `channel` | string | 否 | `alipay_web` |
  | `amountCents` | integer | 否 | 金额，单位分，币种 CNY |
  | `payParams.orderNo` | string | 否 | 同上 |
  | `payParams.channel` | string | 否 | 同上 |
  | `payParams.amountCents` | integer | 否 | 同上 |
  | `payParams.formHtml` | string | 否 | 支付宝表单 HTML。**`X-OS-Type` 为 `web/windows/mac` 时**是“电脑网站支付·内嵌二维码”（`qr_pay_mode=4`，二维码宽 200px），放进 iframe 即显示二维码；其他情况仍是手机网页支付表单 |
  | `payParams.appPayInfo` | string | 否 | 与 `formHtml` 相同（兼容旧字段） |

- 推进方式：提交后查询。网页轮询 `GET /api/payments/orders/{orderNo}`（前 2 分钟每 3 秒，之后每 10 秒，最长 15 分钟），`status` 变为 `PAID` 即到账；该接口对待支付的支付宝订单会主动向支付宝查单（现有）。网页不调 `/confirm`。15 分钟后订单过期（`CLOSED` 或 `-3001`），需重新下单。`expiresAt` 是不带时区的北京时间，网页计算是否过期时固定按 +08:00 解析。同一次弹窗里用过的订单都要轮询（用户可能扫了旧二维码）。
- 继续支付（`pay-params`）：同一订单重新生成表单，订单未过期时沿用原订单号。

示例 —— 成功（电脑端）：

```http
POST /api/payments/orders
X-App-Code: catdrama
X-OS-Type: web
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.mock-access-token
Idempotency-Key: 6f0e2c1a-3b7d-4e1f-9a52-1c2d3e4f5a6b
Content-Type: application/json

{ "productType": "POINTS", "productId": "catdrama_points_600", "channel": "alipay_web" }
```

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "orderNo": "PO202611151030000001",
    "channel": "alipay_web",
    "amountCents": 600,
    "payParams": {
      "orderNo": "PO202611151030000001",
      "channel": "alipay_web",
      "amountCents": 600,
      "formHtml": "<form name=\"punchout_form\" method=\"post\" action=\"https://openapi.alipay.com/gateway.do?charset=UTF-8&method=alipay.trade.page.pay&...\"><input type=\"hidden\" name=\"biz_content\" value=\"{&quot;out_trade_no&quot;:&quot;PO202611151030000001&quot;,&quot;product_code&quot;:&quot;FAST_INSTANT_TRADE_PAY&quot;,&quot;qr_pay_mode&quot;:&quot;4&quot;,&quot;qrcode_width&quot;:&quot;200&quot;,...}\"></form><script>document.forms[0].submit();</script>",
      "appPayInfo": "（同 formHtml）"
    }
  },
  "traceId": "mock-trace-order-ok"
}
```

查单 —— 已到账（`GET /api/payments/orders/PO202611151030000001`，只列网页用到的字段）：

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "orderNo": "PO202611151030000001",
    "productType": "POINTS",
    "productName": "600积分",
    "amountCents": 600,
    "currency": "CNY",
    "channel": "alipay_web",
    "status": "PAID",
    "pointsAmount": 600,
    "paidAt": "2026-11-15T10:31:12",
    "expiresAt": "2026-11-15T10:45:00",
    "createdAt": "2026-11-15T10:30:00"
  },
  "traceId": "mock-trace-order-paid"
}
```

失败 —— 订单已过期（继续支付时，HTTP 400）：

```json
{ "code": -3001, "message": "支付订单已过期", "data": null, "traceId": "mock-trace-order-3001" }
```

失败 —— 套餐下架或支付宝配置不完整（HTTP 400）：

```json
{ "code": -6004, "message": "支付宝Web支付配置不完整：app-id", "data": null, "traceId": "mock-trace-order-6004" }
```

## 5. 网页端复用的现有接口（不改，字段以后端为准）

> 字段出处：后端 OpenAPI `/v3/api-docs`；说明出处：后端 `docs/module-interfaces/*.md`；调用方式出处：手机端 `lib/apis/*.dart`（同名文件）。网页端开发直接连测试环境。

| 页面 | 接口 | 手机端参考 |
|---|---|---|
| 登录 | `POST /api/auth/sms/send`、`POST /api/auth/sms/login`、`POST /api/auth/refresh`、`POST /api/user/logout` | `auth.dart`、`user.dart` |
| 全局 | `GET /api/user/profile`、`GET /api/drama/config`、`GET /api/config/app-configs`、`GET /api/drama/static-pages/{pageCode}`、`GET /api/config/static-page/{key}` | `user.dart`、`drama_config.dart`、`config.dart` |
| W-01 创作中心 | `GET /api/drama/home`、`GET /api/drama/cases/{caseId}`、`GET /api/drama/projects` | `drama_config.dart`、`drama_projects.dart` |
| W-04～W-07 创作流程 | `POST /api/drama/projects`、`GET/PATCH/DELETE /api/drama/projects/{projectId}`、`PUT …/input`、`PUT …/story`、`POST …/story-tasks`、`POST …/story/confirm`、`POST …/screenplay-tasks`、`PUT …/episodes`、`POST …/screenplays/confirm`、`POST …/content-results/{jobId}/apply`、`PUT …/settings`、`POST …/analysis-tasks`、`GET /api/drama/jobs`、`GET /api/drama/jobs/{jobId}`、`GET /api/drama/jobs/{jobId}/children` | `drama_projects.dart`、`drama_content.dart`、`drama_jobs.dart` |
| W-08 整理项目资产 | `GET/POST /api/drama/episodes/{episodeId}/assets`、`POST …/assets/import`、`PATCH /api/drama/episode-assets/{bindingId}`、`POST …/archive`、`POST …/restore`、`POST …/images`、`POST …/images/{versionId}/apply`、`GET …/impact`、`POST /api/drama/episodes/{episodeId}/confirm-materials`、`POST /api/drama/generation/quotes`、`POST /api/drama/generation/tasks` | `drama_assets.dart`、`generation_quotes.dart` |
| W-09 分镜创作 | `GET /api/drama/episodes/{episodeId}`、`GET …/shots`、`PUT …/shot-settings`、`PATCH /api/drama/shots/{shotId}`、`POST …/description-ack`、`GET …/videos`、`POST …/videos/{versionId}/apply`、`GET /api/drama/episodes/{episodeId}/video-download-manifest`、生成提示词（当前片段，§6.4）：`POST /api/drama/shots/{shotId}/description-tasks` → `GET /api/drama/jobs/{jobId}`；批量生成提示词（当前集，§6.3）：`POST /api/drama/episodes/{episodeId}/analysis-tasks` → `GET /api/drama/analyses/{analysisId}` → 有候选时 `POST /api/drama/analyses/{analysisId}/apply`；`POST /api/drama/shots/{shotId}/restore-analysis`；生成视频同 W-08（“片段拆分”本版不做） | `drama_shots.dart`、`drama_projects.dart` |
| W-10 我的作品 | `GET /api/drama/projects`、`DELETE /api/drama/projects/{projectId}`、`DELETE /api/drama/episodes/{episodeId}` | `drama_projects.dart` |
| W-11～W-13 资产库 / 素材 | `GET /api/drama/asset-groups`、`GET/POST /api/drama/assets`、`GET/PATCH/DELETE /api/drama/assets/{assetId}`、`GET/POST …/images`、`POST …/images/{versionId}/apply`、`POST /api/drama/assets/description-jobs`（音色、描述都在 `description`、`soundProfile.description` 字段里） | `drama_assets.dart` |
| 上传 / 媒体 | `POST /api/resources/direct-upload/prepare`、`POST /api/resources/direct-upload/complete`（浏览器直传 OSS，需 OSS 跨域）、`POST /api/resources/{resourceId}/access-url`、`POST /api/resources/exists` | `resource.dart` |
| TXT 导入 | 不调接口（D-30，浏览器本地读取） | — |
| W-03 / W-16 充值与订单 | `GET /api/products?type=POINTS`、`POST /api/payments/orders`、`GET /api/payments/orders`、`GET /api/payments/orders/{orderNo}`、`POST …/pay-params`、`PATCH …/cancel`（网页不调 `…/confirm`） | `payment.dart` |
| W-15 积分明细 | `GET /api/points/account`、`GET /api/points/ledger` | `points.dart` |
| W-14 邀请有礼 | `GET /api/invite/overview`、`GET /api/invite/records`、`GET /api/invite/materials`、`GET /api/invite/earnings/summary`、`GET /api/invite/earnings/ledgers`、`POST /api/invite/bind`、`GET /api/drama/invite/points`、`POST /api/drama/invite/bind` | `invite.dart`、`drama_growth.dart` |
| W-14 提现四步 | `GET /api/invite/withdrawal-eligibility`、`GET /api/invite/agreements/flexible-employment`、`POST /api/invite/identity-sessions`、`GET …/{sessionId}/status`（电脑端轮询，不调 confirm）、`GET/POST /api/invite/bank-accounts`、`PUT …/{id}/default`、`DELETE …/{id}`、`POST /api/invite/withdrawal-quotes`、`POST/GET /api/invite/withdrawals`、`GET /api/invite/withdrawals/{id}` | `invite.dart` |
| W-17 任务中心 | `GET /api/tasks/center`、`POST /api/tasks/check-in`、`GET /api/drama/growth/tasks`、`POST /api/drama/growth/tasks/{taskCode}/claim` | `tasks.dart`、`drama_growth.dart` |
| W-18 设置 | `POST /api/user/delete-verification-code`、`POST /api/user/delete-request`、`POST /api/auth/password/reset`（§3.3） | `user.dart` |
| W-19 意见反馈 | `POST /api/feedback` | `feedback.dart` |
| W-20 协议 | `GET /api/drama/static-pages/{pageCode}`、`GET /api/config/static-page/{key}` | `drama_config.dart`、`config.dart` |

电脑端实名核身（W-14）的调用方式与手机端不同，写在这里：

1. `POST /api/invite/identity-sessions` 返回 `sessionId`、`h5Url`、`expiresAt`。
2. 网页把 `h5Url` 画成二维码，用户用手机扫码完成刷脸和电子签约。手机签完会跳到后端的回跳页 `/api/callbacks/gongmall/return`，后端自动确认（现有逻辑）。
3. 网页每 3 秒调 `GET /api/invite/identity-sessions/{sessionId}/status`，`identityReady = true` 即完成，进入绑卡；到 `expiresAt` 仍未完成则提示“二维码已过期，请重新发起”。
4. 网页不调 `/confirm`（它需要回跳里的 `state`，只有 App 能拦截到）。

## 6. 漫剧分析与片段（2026-11-16 调整，B-10）

> 本版改动：R-15～R-18、R-31、R-32（D-33～D-42）。接口卡片见技术方案 §3 K-01～K-08。网页端和手机端（M11）调用同一组接口。
> 请求头同 §1（`X-App-Code: catdrama`、`Authorization`），写接口都要 `Idempotency-Key`（16～64 位字母数字或 `-`，同一次用户动作重试用同一个键）。
> 任务对象 `DramaJob` 沿用现有结构（字段以 OpenAPI 为准）：`id`、`kind`、`state`（`QUEUED`、`RUNNING`、`SUBMIT_UNKNOWN`、`FINALIZING`、`SUCCEEDED`、`PARTIAL_FAILED`、`FAILED`、`SUPERSEDED`）、`targetType`、`targetId`、`inputRevision`、`progress`、`financialState`（本节全部为 `FREE`）、`childSummary`、`parentJobId`、`errorCode`、`errorMessage`、`analysisFailure` 等。下面样例只列本节用到的字段。

### 6.0 检测问题 `AnalysisProblem`（新增结构，复用现有 `DramaAnalysisFailure` 的字段）

| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| `reasonCode` | string | 否 | 现有原因码：`MODEL_SOURCE_MISMATCH`（对不上原文）、`MODEL_COVERAGE`（漏了 / 打乱剧本）、`MODEL_REFERENCE`（引用了不存在的素材）、`MODEL_DURATION`（时长不合理）、`SCRIPT_LINE_TOO_LONG`（单句台词太长）、`SCRIPT_DUPLICATE_TEXT`（剧本重复无法定位）、`TASK_BLOCKED`（模型报告受阻）、`MODEL_FORMAT`、`MODEL_INCOMPLETE`、`MODEL_NO_SHOTS`、`SERVICE_UNAVAILABLE`、`UNKNOWN` |
| `suggestion` | string | 否 | `RETRY`（重新生成）、`EDIT_SCRIPT`（改剧本）、`EDIT_SCRIPT_OR_SETTINGS`（改剧本或时长设置） |
| `category` | string | 否 | `MODEL_OUTPUT`、`SCRIPT_CONTENT` |
| `message` | string | 否 | 给用户看的说明 |
| `shotNumber` | integer | 是 | 第几个片段（片段级问题） |
| `excerpt` | string | 是 | 相关原文，最多 40 字 |

### 6.1 `POST /api/drama/projects/{projectId}/analysis-tasks` 素材分析（行为变化）

- 请求（不变）：`expectedRevision`（integer，必填，作品当前版本）、`taskId`（string，可空，重试原任务时填）。
- 返回（不变）：`DramaJob`，`kind = PROJECT_ANALYSIS`。
- 变化：只做素材提取；完成后写素材注册表，并按“每个素材出现在哪几集”建立每集素材关联；**不再创建 `EPISODE_ANALYSIS` 子任务、不建片段**。成功后作品进入分集制作，各集剧集阶段为 `MATERIALS`。

成功（受理）：

```json
{ "code": 200, "message": "成功", "data": { "id": "9001", "kind": "PROJECT_ANALYSIS", "state": "QUEUED", "targetType": "PROJECT", "targetId": "5001", "inputRevision": 7, "progress": 0, "financialState": "FREE", "childSummary": null }, "traceId": "mock-k01-ok" }
```

失败 —— 作品版本已变（HTTP 409 / 400，现有）：

```json
{ "code": -560001, "message": "内容已更新，请核对最新版本", "data": null, "traceId": "mock-k01-560001" }
```

失败 —— 已有分析在跑（现有）：

```json
{ "code": -560005, "message": "已有任务处理中，请查询原任务", "data": null, "traceId": "mock-k01-560005" }
```

### 6.2 `POST /api/drama/episodes/{episodeId}/confirm-materials` 确认素材并生成本集片段（K-02，行为变化）

> 用户 2026-11-16 选 A：不新增接口，复用现有“确认素材”。

- 请求（不变）：请求体必须是空对象 `{}`；请求头 `Idempotency-Key` 必填。
- 返回（结构不变）：剧集对象（`DramaProjectResponse.Episode`），本版多 §6.6、§6.8 的字段。
- 变化：
  - 图片检查范围：从“片段引用的素材”改为“本集全部素材”（素材分析按 `assetPlan` 建立的绑定）。
  - 检查通过后：同一事务提交本集“生成片段 + 视频描述词”任务（`kind = EPISODE_ANALYSIS`，免费），剧集 `stage = SHOTS`，`shotGeneration.state = RUNNING`、`shotGeneration.jobId` 为任务编号；首次生成完成自动应用。
  - 已在 `SHOTS` / `VIDEOS`，或同一个键重放 → 按成功返回当前剧集，不重复生成。
- 网页 W-08“进入镜头制作”（2026-11-16 改为按集，与手机端一致）：只对当前选中的这一集调用本接口（这一集一个固定的 `Idempotency-Key`，重试复用），成功后进入这一集的分镜创作；这一集缺图由本接口拒绝（`-560002`），网页也会先自查并提示；其他集不检查、不提交。分镜创作里切到还在素材阶段的集，回到 W-08。
- 手机端：素材页“进入镜头制作”照旧调用当前集（M11）。

成功：

```json
{ "code": 200, "message": "成功", "data": { "id": "6002", "ordinal": 2, "stage": "SHOTS", "shotGeneration": { "state": "RUNNING", "jobId": "9201", "problemShotCount": 0, "failureReason": null, "rawOutput": null } }, "traceId": "mock-k02-ok" }
```

失败 —— 本集有素材缺图（现有文案，HTTP 400）：

```json
{ "code": -560002, "message": "还有 2 个素材没有可用图片：小白、医院走廊", "data": null, "traceId": "mock-k02-560002" }
```

失败 —— 作品不在分集制作阶段（现有）：

```json
{ "code": -560002, "message": "本集还不能确认素材", "data": null, "traceId": "mock-k02-stage" }
```

失败 —— 请求体不是空对象（现有）：

```json
{ "code": -400, "message": "确认素材请求体必须为空对象", "data": null, "traceId": "mock-k02-400" }
```

### 6.3 `POST /api/drama/episodes/{episodeId}/analysis-tasks` 当集重新生成片段 + 描述（“批量生成提示词”，行为变化）

- 请求（不变）：`expectedRevision`（integer，剧集当前版本）、`scriptRevision`（integer，剧本版本）、`taskId`（string，可空，重试原任务）。
- 返回（不变）：`DramaJob`，`kind = EPISODE_ANALYSIS`。
- 变化：
  - 检测问题不再让任务失败，问题随结果返回（§6.5）。
  - 该集还没有片段 → 完成后自动应用；已有片段 → 生成差异（`state = CANDIDATE`），用户核对后调用现有 `POST /api/drama/analyses/{analysisId}/apply`（请求 `expectedEpisodeRevision`、`scriptRevision`、`confirmed: true`）。
  - 不再要求作品先有全剧拆片段结果；前置条件改为该集素材都有图（和“确认素材”同一个范围：本集全部未删除的素材都要有已应用的图片）。
  - 拆不出片段 → 任务 `FAILED`，原片段不变；作品不再因此停在“分析失败”。

成功：

```json
{ "code": 200, "message": "成功", "data": { "id": "9201", "kind": "EPISODE_ANALYSIS", "state": "QUEUED", "targetType": "EPISODE", "targetId": "6002", "inputRevision": 4, "progress": 0, "financialState": "FREE" }, "traceId": "mock-k03-ok" }
```

失败 —— 该集素材缺图：

```json
{ "code": -560002, "message": "本集还有素材没有图片，请先补齐", "data": null, "traceId": "mock-k03-560002" }
```

失败 —— 版本不一致：

```json
{ "code": -560001, "message": "内容已更新，请核对最新版本", "data": null, "traceId": "mock-k03-560001" }
```

失败 —— 已有任务在跑：

```json
{ "code": -560005, "message": "已有任务处理中，请查询原任务", "data": null, "traceId": "mock-k03-560005" }
```

### 6.4 `POST /api/drama/shots/{shotId}/description-tasks` 单个片段重新生成视频描述词（“生成提示词”，新增）

- 用途：W-09 中间“生成提示词”。只重新生成这一个片段的视频描述词；不改原文、素材引用和已有视频。免费。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `expectedRevision` | integer | 是 | 片段当前版本（`GET …/shots` 返回的 `revision`） |
  | `overwriteConfirmed` | boolean | 是 | 用户已确认替换手改内容；片段描述被手改过时必须为 `true` |

- 返回 `data`：`DramaJob`（`kind` 新增值 `SHOT_DESCRIPTION`，`targetType = SHOT`，`targetId` = 片段 ID）。
- 完成后：片段版本未变 → 新描述替换原描述，检测问题写入片段 `analysisProblems`（§6.6）；片段版本已变 → 不覆盖，任务结果标 `SUPERSEDED`。拆不出描述 → 任务 `FAILED`，`analysisFailure` 带原因，`result.rawOutput` 带原始返回。

成功：

```json
{ "code": 200, "message": "成功", "data": { "id": "9301", "kind": "SHOT_DESCRIPTION", "state": "QUEUED", "targetType": "SHOT", "targetId": "7003", "inputRevision": 5, "progress": 0, "financialState": "FREE" }, "traceId": "mock-k04-ok" }
```

失败 —— 手改过未确认（HTTP 400）：

```json
{ "code": -560017, "message": "重新生成会替换你手改的内容，请确认后继续", "data": null, "traceId": "mock-k04-560017" }
```

失败 —— 片段已被修改：

```json
{ "code": -560001, "message": "内容已更新，请核对最新版本", "data": null, "traceId": "mock-k04-560001" }
```

失败 —— 该片段已有任务在跑（生成描述或视频），或本集正在整集重新生成：

```json
{ "code": -560005, "message": "已有任务处理中，请查询原任务", "data": null, "traceId": "mock-k04-560005" }
```

完成后查询任务 —— 拆不出描述（`GET /api/drama/jobs/9301`）：

```json
{ "code": 200, "message": "成功", "data": { "id": "9301", "kind": "SHOT_DESCRIPTION", "state": "FAILED", "targetType": "SHOT", "targetId": "7003", "financialState": "FREE", "errorMessage": "模型返回的格式不正确，请重新生成", "analysisFailure": { "reasonCode": "MODEL_FORMAT", "suggestion": "RETRY", "category": "MODEL_OUTPUT", "message": "模型返回的格式不正确，请重新生成", "shotNumber": null, "excerpt": null, "requiredSeconds": null, "limitSeconds": null }, "result": { "rawOutput": "（模型原始返回文字）" } }, "traceId": "mock-k04-job-failed" }
```

### 6.5 `GET /api/drama/analyses/{analysisId}` 查看分析结果（修改）

- 原有字段不变（`id`、`episodeId`、`scriptRevision`、`baseEpisodeRevision`、`state`、`added`、`kept`、`removed`、`assetChanges`、`counts`、`markdownDocuments`、`baseAnalysisId`）。
- 新增字段：

  | 字段 | 类型 | 可空 | 说明 |
  |---|---|---|---|
  | `added[].problems`、`kept[].problems` | `AnalysisProblem[]` | 否（无问题为空数组） | 该片段的检测问题 |
  | `problems` | `AnalysisProblem[]` | 否 | 整集级问题（如漏了剧本内容） |
  | `failureReason` | `AnalysisProblem` | 是 | 拆不出片段时的原因，`state = FAILED` |
  | `rawOutput` | string | 是 | 拆不出片段时的模型原始返回（只读展示，最长 20000 字，超出截断并在末尾标“……（已截断）”） |

成功 —— 有检测问题的结果：

```json
{ "code": 200, "message": "成功", "data": { "id": "8101", "episodeId": "6002", "scriptRevision": 3, "baseEpisodeRevision": 4, "state": "CANDIDATE", "added": [ { "action": "ADD", "candidateKey": "s2", "sourceText": "▲医生缓缓走出摘下口罩……", "description": "开场站位：……0–3秒中景……", "ordinal": 2, "existingShotId": null, "appliedVideo": null, "references": [], "problems": [ { "reasonCode": "MODEL_REFERENCE", "suggestion": "RETRY", "category": "MODEL_OUTPUT", "message": "引用了素材注册表里没有的“护士”", "shotNumber": 2, "excerpt": "护士推门进来" } ] } ], "kept": [], "removed": [], "assetChanges": [], "counts": { "added": 1, "kept": 0, "removed": 0 }, "markdownDocuments": [], "baseAnalysisId": null, "problems": [], "failureReason": null, "rawOutput": null }, "traceId": "mock-k05-ok" }
```

成功 —— 拆不出片段：

```json
{ "code": 200, "message": "成功", "data": { "id": "8102", "episodeId": "6003", "scriptRevision": 2, "baseEpisodeRevision": 2, "state": "FAILED", "added": [], "kept": [], "removed": [], "assetChanges": [], "counts": { "added": 0, "kept": 0, "removed": 0 }, "markdownDocuments": [], "baseAnalysisId": null, "problems": [], "failureReason": { "reasonCode": "MODEL_FORMAT", "suggestion": "RETRY", "category": "MODEL_OUTPUT", "message": "模型返回的格式不正确，请重新生成", "shotNumber": null, "excerpt": null }, "rawOutput": "（模型原始返回文字）" }, "traceId": "mock-k05-failed" }
```

失败 —— 不存在或不是本人（现有）：

```json
{ "code": -404, "message": "资源不存在", "data": null, "traceId": "mock-k05-404" }
```

### 6.6 片段与剧集查询（修改）

`GET /api/drama/episodes/{episodeId}/shots` 每个片段新增：

| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| `analysisProblems` | `AnalysisProblem[]` | 否（无问题为空数组） | 该片段最近一次生成（单集或单个片段）的检测问题；用户修改描述后，描述类问题由现有 `descriptionPlan.errors` 负责，本字段保留到下次生成 |

`GET /api/drama/episodes/{episodeId}` 与 `GET /api/drama/projects/{projectId}` 返回的每个剧集新增：

| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| `shotGeneration.state` | string | 否 | `NONE` 未生成、`RUNNING` 生成中、`READY` 已有片段、`FAILED` 最近一次生成拆不出片段且没有可用片段 |
| `shotGeneration.jobId` | string | 是 | 最近一次生成任务 |
| `shotGeneration.problemShotCount` | integer | 否 | 当前片段中有检测问题的个数 |
| `shotGeneration.failureReason` | `AnalysisProblem` | 是 | `FAILED` 时的原因 |
| `shotGeneration.rawOutput` | string | 是 | `FAILED` 时的模型原始返回（规则同 §6.5） |

整集级的检测问题（如漏了剧本内容）不在片段和剧集查询里返回：网页用剧集的 `analysisId` 调 §6.5 取 `problems` 显示在顶部提示。剧集 `stageSummary.blockers` 里有 `ANALYSIS_DIFF_PENDING` 表示有一份重新生成的结果待核对（现有字段，手机端在用）。

成功（片段节选）：

```json
{ "code": 200, "message": "成功", "data": [ { "id": "7003", "episodeId": "6002", "ordinal": 2, "sourceText": "▲医生缓缓走出摘下口罩……", "description": "开场站位：……", "revision": 5, "state": "ACTIVE", "canGenerate": true, "analysisProblems": [ { "reasonCode": "MODEL_DURATION", "suggestion": "RETRY", "category": "MODEL_OUTPUT", "message": "片段时长与描述末段结束秒数不一致", "shotNumber": 2, "excerpt": null } ] } ], "traceId": "mock-k06-shots" }
```

成功（剧集 `shotGeneration` 节选）：

```json
{ "code": 200, "message": "成功", "data": { "id": "6003", "ordinal": 3, "shotGeneration": { "state": "FAILED", "jobId": "9203", "problemShotCount": 0, "failureReason": { "reasonCode": "MODEL_INCOMPLETE", "suggestion": "RETRY", "category": "MODEL_OUTPUT", "message": "模型返回不完整，请重新生成", "shotNumber": null, "excerpt": null }, "rawOutput": "（模型原始返回文字）" } }, "traceId": "mock-k06-episode" }
```

失败：同现有（`-404`、`-401`）。

### 6.7 作品与剧集阶段（行为变化）

| 对象 | 改之前 | 改之后 |
|---|---|---|
| 作品 `currentStep` | `ANALYZE_PROJECT` → `ANALYZE_EPISODES` → `PRODUCE_EPISODES`；任何一集失败停在 `FAILED` | `ANALYZE_PROJECT`（素材分析）→ `PRODUCE_EPISODES`；不再进入 `ANALYZE_EPISODES` |
| 剧集阶段 `stage` | `ANALYSIS`（无片段）→ `MATERIALS`（片段引用的素材缺图）→ `VIDEOS` | `MATERIALS`（本集素材缺图）→ `SHOTS`（新值：素材齐，但还没有可用片段：待生成 / 生成中 / 生成失败）→ `VIDEOS`（有片段） |

网页按 `stage` 决定进入哪一页：`MATERIALS` → W-08；`SHOTS`、`VIDEOS` → W-09。（`EDIT_READY` 已由后端 `V4.18` 合并到 `VIDEOS`，现有代码不再返回。）

手机端按 `stage` 和现有的 `entryState` 进入（M11）：`SHOTS`、`VIDEOS` 阶段 `entryState.shots.accessible = true`；素材阶段沿用现有规则。失败的生成任务（`EPISODE_ANALYSIS`、`SHOT_DESCRIPTION`）带 `result: {"rawOutput": "…"}`，没有 `type`、`id`；`SHOT_DESCRIPTION` 成功时没有 `result`。

### 6.8 剧本 → 分集时定好每集素材（K-08，行为变化）

- 触发：现有剧本生成任务（`POST /api/drama/projects/{projectId}/screenplay-tasks`，或 `POST /api/drama/projects/{projectId}/story/confirm` 受理剧本生成），请求不变。
- 变化：任务结果里每集多一份素材清单，应用剧本候选（现有 `POST …/content-results/{jobId}/apply`）时随剧集保存到 `assetPlan`。用户手改剧本（`PUT …/episodes`）不改 `assetPlan`；素材分析（§6.1）以 `assetPlan` 为主，按最新正文补上漏掉的素材（只补不删）。
- 剧集对象（`GET /api/drama/projects/{projectId}`、`GET /api/drama/episodes/{episodeId}`）新增：

  | 字段 | 类型 | 可空 | 说明 |
  |---|---|---|---|
  | `assetPlan.roles` | string[] | 否（无为空数组） | 本集角色名称，与剧本对白署名一致 |
  | `assetPlan.scenes` | string[] | 否 | 本集场景名称 |
  | `assetPlan.props` | string[] | 否 | 本集道具名称 |
  | `assetPlan` | object | 是 | 老作品或模型没给出时为 `null` |

- 网页 W-06 不显示 `assetPlan`；整理资产页按素材分析建立的每集关联显示（`GET /api/drama/episodes/{episodeId}/assets`，不变）。

成功（剧集节选）：

```json
{ "code": 200, "message": "成功", "data": { "id": "6001", "ordinal": 1, "title": "抢救室外", "assetPlan": { "roles": ["慕晚晴", "医生", "糖糖"], "scenes": ["医院抢救室外-夜晚"], "props": ["急救指示灯"] } }, "traceId": "mock-k08-episode" }
```

成功 —— 老作品或模型没给出清单：

```json
{ "code": 200, "message": "成功", "data": { "id": "6009", "ordinal": 1, "title": "旧作品第一集", "assetPlan": null }, "traceId": "mock-k08-null" }
```

失败：剧本生成任务的失败规则不变（模型没给出某集清单不算失败）。

> §6.9 片段拆分（K-09～K-12）2026-11-23 移到 v1.1.0 的 api.md，本版不做；编号 6.9 空着不复用。

## 6.10 重新分析本集素材（R-36，2026-11-20 新增，后端 B-13，开发计划 M16）

> 素材分析（AI 识别角色、场景、道具）原来只有 §6.1 一个入口，同一份剧本分析过就拒绝再分析，而且分析成功会把作品所有集的阶段都改成“素材”。重新分析单独开一个接口，规则和 §6.1 分开，§6.1 的请求、返回、行为都不变。

### 6.10.1 `POST /api/drama/episodes/{episodeId}/asset-analysis-tasks` 重新分析本集素材（新增，K-13）

- 用途：W-08 整理项目资产页“重新分析”（选中某一集时）。
- 请求头：`Idempotency-Key`（同一次点击重试用同一个）。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `expectedRevision` | integer | 是 | 本集当前版本（剧集的 `revision`） |

- 返回 `data`：`DramaJob`，`kind = PROJECT_ANALYSIS`（不新增任务种类），`targetType = PROJECT`、`targetId` = 作品 ID，`financialState = FREE`。要读全剧剧本，可能一两分钟。
- 做什么：
  - AI 读全剧剧本重新识别素材（作品里已有的素材作为“已有身份”交给 AI，同一个人物在各集认成同一个素材）。剧本没改也照样分析，不复用上次的结果。
  - 只给**本集**补关联：项目里已有的同一素材直接关联到本集（图片跟着带过来）；项目里没有的新建（AI 写的描述，没有图片）。只新建本集要用的素材，别的集要用的不建。别的集的独立副本（那一集“只改本集”复制出来的同名素材）不加进本集。
  - 已有素材的名称、描述、图片都不改；本集里删掉（归档）的关联不恢复；别的集不动。
  - **不改任何集的阶段**，不改作品的流程状态；本集的片段、视频不动。
- 同一作品同一时间只能有一个素材分析在跑（包括这个接口和 §6.1）。

成功受理：

```json
{ "code": 200, "message": "成功", "data": { "id": "9501", "kind": "PROJECT_ANALYSIS", "state": "QUEUED", "targetType": "PROJECT", "targetId": "5001", "inputRevision": 12, "progress": 0, "financialState": "FREE" }, "traceId": "mock-k13-ok" }
```

完成后查询任务（`GET /api/drama/jobs/9501`）——补了素材：

```json
{ "code": 200, "message": "成功", "data": { "id": "9501", "kind": "PROJECT_ANALYSIS", "state": "SUCCEEDED", "targetType": "PROJECT", "targetId": "5001", "progress": 100, "financialState": "FREE", "result": { "type": "ANALYSIS", "id": "9501", "assetReanalysis": { "episodeId": "6001", "added": [ { "assetId": "7101", "name": "林夏", "kind": "ROLE" }, { "assetId": "7102", "name": "医院走廊", "kind": "SCENE" } ] } } }, "traceId": "mock-k14-added" }
```

完成后查询任务——没有漏掉的：`"assetReanalysis": { "episodeId": "6001", "added": [] }`。

失败（message 由后端给，前端直接显示）：

| code | message | 什么时候 |
|---|---|---|
| `-404` | 资源不存在 | 剧集不存在或不是本人的 |
| `-560002` | 请先完成素材分析 | 作品还没到分集制作（第一次素材分析没完成） |
| `-560002` | 请先保存制作设置 | 同 §6.1 |
| `-560002` | 内容不完整，请核对后继续 | 有集没有标题或剧本（同 §6.1） |
| `-560005` | 正在分析素材，请稍候 | 这个作品已有素材分析在跑 |
| `-560005` | 本集正在生成片段，请等完成后再重新分析 | 本集有进行中的单集分析（正在生成片段） |
| `-560001` | 内容已更新，请核对最新版本 | `expectedRevision` 不是本集当前版本 |
| `-560013` | 当前制作能力未配置或不可用（或后端更具体的原文） | 分析模型或模板没配好（同 §6.1） |

任务失败时：`state = FAILED`，原因在 `analysisFailure.message` / `errorMessage`（和 §6.1 的任务一样）；本集素材不变。

### 6.10.2 任务结果新增字段 `result.assetReanalysis`（K-14）

| 字段 | 类型 | 说明 |
|---|---|---|
| `assetReanalysis` | object，可空 | 只有 §6.10.1 建的任务成功时才有；其他任务为空 |
| `assetReanalysis.episodeId` | string | 重新分析的是哪一集 |
| `assetReanalysis.added` | array | 这次新加到本集的素材，按类型（角色、场景、道具）再按名称；没有为空数组 |
| `added[].assetId` / `name` / `kind` | string | 素材 ID、名称、类型（`ROLE` / `SCENE` / `PROP`） |

- 现有字段不变；客户端不认识可忽略。

