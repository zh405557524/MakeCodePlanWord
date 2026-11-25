# 接口契约

> v1.1.0 做完后的**完整**接口契约，前后端共用。接口字段只在这里写一次；技术方案和开发计划引用这里的小节。改过的小节下面加 `> 本版改动：R-xx`。
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

## 3. 新增接口

### 3.1 `POST /api/auth/password/register` 密码注册

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

## 6.9 片段拆分（R-35，2026-11-20 新增，后端 B-12，开发计划 M15）

> 名词：片段 = 一次视频生成；镜头 = 片段里的“0-4 秒：…”一段。单集拆分是两步：模型先拆镜头（存 `catdrama_camera_shots`），再由程序按时长上限把镜头组合成片段（`DramaSegmentComposer`）。拆分只在镜头之间切开。
> “旧版拆分的集”= 本集当前生效的分析没有镜头数据（`GET /api/drama/episodes/{episodeId}/camera-shots` 返回空列表）。
> “生效的制作参数”= 片段自己的设置（分镜页“片段统一设置”保存在每个片段上），没有就用作品的制作设置。

### 6.9.1 `POST /api/drama/shots/{shotId}/description-tasks`（§6.4，行为变化）

- 请求、返回、错误码都不变。
- 变化 1：时长上限和给模型的【片段生成设置】改用**这个片段生效的制作参数**。以前固定用作品的制作设置——在分镜页把本集时长改成 10 秒后，“生成提示词”还按作品的 15 秒写，这是“时长不够”的原因之一。
- 变化 2：新版拆分的集，生成结果的镜头总时长超过时长上限、且能在镜头之间切开时，**不再固定写回 1 个片段**：
  - 原片段（同一个片段 ID，视频和历史都在）写入第 1 部分（提示词、原文都换成第 1 部分的）；后面每部分新增一个片段，紧跟在原片段后面；本集后面片段的 `ordinal` 依次加上新增个数（只改序号，片段版本号不变）。
  - 新片段：`sourceText` = 自己那几个镜头对应的原文；出场素材按镜头里的素材标记对到本集素材（原片段的出场素材是手动选的 → 照抄原片段的）；制作参数和原片段一样；没有视频。
  - 任务完成后 `result.segmentSplit` 返回拆分情况（§6.9.3）。
- 不变：没超长、旧版拆分的集、单个镜头自己就超长（拆不开）——都和现在一样只写回原片段，超长记 `MODEL_DURATION` 问题；片段版本已变 → `SUPERSEDED`，不写回、不拆分；拼出的提示词超字数、所选视频模型不支持段内分镜却拆出多个镜头——和现在一样判失败。

完成后查询任务 —— 拆成了 2 个（`GET /api/drama/jobs/9301`）：

```json
{ "code": 200, "message": "成功", "data": { "id": "9301", "kind": "SHOT_DESCRIPTION", "state": "SUCCEEDED", "targetType": "SHOT", "targetId": "7004", "progress": 100, "financialState": "FREE", "result": { "type": null, "id": null, "segmentSplit": { "ordinals": [4, 5], "shotIds": ["7004", "7010"], "limitSeconds": 15 } } }, "traceId": "mock-k09-split" }
```

没拆分时 `result` 和现在一样（为空）。

### 6.9.2 `POST /api/drama/episodes/{episodeId}/segment-recompose-tasks` 片段拆分：按当前时长整集重新组合（新增）

- 用途：W-09“片段拆分”按钮。按本集**当前**时长上限，把本集当前生效的镜头重新组合成片段；不调用模型、不重写内容、免费。
- 请求头：`Idempotency-Key`（同一次点击重试用同一个）。
- 请求（和 §6.3 相同）：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `expectedRevision` | integer | 是 | 剧集当前版本 |
  | `scriptRevision` | integer | 是 | 剧本版本 |

- 时长上限、能不能一个片段放多个镜头：取本集序号最小的有效片段的生效制作参数（网页“片段统一设置”显示的就是它）。
- 受理时直接算出新的组合（几毫秒，不调模型）：
  - 和当前片段完全一样 → **不建任务**，返回 `unchanged = true`、`job = null`；片段、待核对入口都不受影响。
  - 不一样 → 建一个 `kind = EPISODE_ANALYSIS` 的任务（不新增任务种类，`financialState = FREE`，几秒内完成），返回 `unchanged = false` 和任务。任务成功后 `result.type = ANALYSIS`、`result.id` = 分析 ID，状态 `CANDIDATE`（和 §6.3 已有片段时一样）；用户在“核对本集分析差异”里确认后调用现有 `POST /api/drama/analyses/{analysisId}/apply`。
  - 差异里：镜头组成和原来某个片段完全一样的为“保留”（原片段 ID、手改的提示词、视频、历史都不变）；其余为“新增 / 移出”。新增片段的制作参数 = 上面取的那份。本集“待核对”入口和 §6.3 一样。
- 返回 `data`：

  | 字段 | 类型 | 说明 |
  |---|---|---|
  | `unchanged` | boolean | 新组合和当前片段完全一样 |
  | `limitSeconds` | integer | 这次用的时长上限 |
  | `job` | `DramaJob`，可空 | `unchanged = false` 时为本次任务 |

成功 —— 有变化：

```json
{ "code": 200, "message": "成功", "data": { "unchanged": false, "limitSeconds": 10, "job": { "id": "9401", "kind": "EPISODE_ANALYSIS", "state": "QUEUED", "targetType": "EPISODE", "targetId": "6002", "inputRevision": 4, "progress": 0, "financialState": "FREE" } }, "traceId": "mock-k10-ok" }
```

成功 —— 无需拆分：

```json
{ "code": 200, "message": "成功", "data": { "unchanged": true, "limitSeconds": 15, "job": null }, "traceId": "mock-k10-same" }
```

完成后查询任务 —— 待核对（`GET /api/drama/jobs/9401`）：

```json
{ "code": 200, "message": "成功", "data": { "id": "9401", "kind": "EPISODE_ANALYSIS", "state": "SUCCEEDED", "targetType": "EPISODE", "targetId": "6002", "progress": 100, "financialState": "FREE", "result": { "type": "ANALYSIS", "id": "8801" } }, "traceId": "mock-k10-diff" }
```

失败（message 由后端给，前端直接显示）：

| code | message | 什么时候 |
|---|---|---|
| `-560002` | 本集还没有片段 | 没有有效片段 |
| `-560002` | 请先确认本集素材 | 剧集还没到片段 / 视频阶段（同 §6.3） |
| `-560002` | 这一集是旧版拆分的，请先批量生成提示词 | 当前生效的分析没有镜头数据 |
| `-560002` | 剧本改过了，请先批量生成提示词 | 剧本版本和当前生效的分析不一致（镜头对应的原文位置已失效） |
| `-560002` | 片段和镜头对不上，请先批量生成提示词 | 有片段找不到镜头，或有镜头找不到片段 |
| `-560005` | 有片段正在生成视频，完成后再拆分 | 本集有视频任务在跑 |
| `-560005` | 已有任务处理中，请查询原任务 | 本集有生成片段 / 批量生成提示词 / 生成提示词任务在跑 |
| `-560001` | 内容已更新，请核对最新版本 | `expectedRevision` 或 `scriptRevision` 不一致 |

```json
{ "code": -560002, "message": "这一集是旧版拆分的，请先批量生成提示词", "data": null, "traceId": "mock-k10-old" }
```

```json
{ "code": -560005, "message": "有片段正在生成视频，完成后再拆分", "data": null, "traceId": "mock-k10-video" }
```

### 6.9.3 任务结果新增字段 `result.segmentSplit`（返回 `DramaJob` 的地方，如 `GET /api/drama/jobs/{jobId}`）

| 字段 | 类型 | 说明 |
|---|---|---|
| `segmentSplit` | object，可空 | 只有 `SHOT_DESCRIPTION` 成功且拆分了时才有；其他情况为空 |
| `segmentSplit.ordinals` | integer[] | 拆出的全部片段的序号，第一个是原片段（如 `[4, 5]`） |
| `segmentSplit.shotIds` | string[] | 与 `ordinals` 一一对应的片段 ID |
| `segmentSplit.limitSeconds` | integer | 这次用的时长上限 |

- 现有字段不变；客户端不认识这个字段时忽略即可（手机端解析要容忍新字段，M15 核对）。

### 6.9.4 `POST /api/drama/episodes/{episodeId}/analysis-tasks`（“批量生成提示词”，§6.3，行为变化，K-12，D-62）

- 请求、返回、错误码都不变。
- 变化：本集已有片段时，拆片段用**本集设置**（序号最小的有效片段生效的制作设置，即分镜页“片段统一设置”），给模型的【片段生成设置】也用它；以前固定用作品的制作设置。差异里新增的片段带上这份设置（以前新增片段没有设置，按作品的）。
- 不变：本集还没有片段（确认素材后第一次生成，K-02）、失败集修复、用原任务重试（`taskId`）——设置来源和现在一样。
- 手机端视频编辑页“重新生成本集片段”调的是同一个接口，同样生效。

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

## 7. 角色 / 场景：主图 + 形象（R-01，2026-11-23 新增，技术方案 §3 K-15～K-25）

> 一个“形象”（场景里叫“子场景”）就是一条素材记录（`catdrama_assets` 一行），用 `parentAssetId` 挂在主体（角色 / 场景）下面；主体自己的那张图就是“主形象 / 主图”。形象在哪几集出现 = 它在哪几集有关联（`catdrama_episode_assets`，和现在一样）。道具没有形象。
> 本节新增 / 修改的接口全部在后端 `app/catdrama` 下，只有喵喵漫剧用；手机端、网页端共用。

### 7.1 素材返回结构新增字段（修改，K-15）

用到的地方：`DramaAsset`（`GET /api/drama/assets`、`GET /api/drama/assets/{assetId}`、`GET /api/drama/episodes/{episodeId}/assets` 里每条关联的 `asset`、各个 PATCH / 导入的返回）和 `DramaAssetReference`（片段的 `references`、分析结果里的素材引用）。

| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| `parentAssetId` | string | 是 | 所属主体（角色 / 场景）的素材 ID；**为空表示这条就是主体**（主形象 / 主图） |
| `lookName` | string | 是 | 形象 / 子场景自己的名称，1～10 个字（如“婚纱”“客厅”）；主体为空 |
| `name` | string | 否 | **含义说明（值的规则变了）**：主体 = 主名；形象 / 子场景 = `主名·形象名`（如“江敏·婚纱”，中间是“·” U+00B7），由后端拼出、只读。提示词里的 `@` 引用、旧版本 App 的显示都用它 |
| `aliases` | string[] | 否 | 角色别名，0～10 个，每个 1～20 字，按用户填写顺序；场景、道具、形象固定为 `[]` |
| `parentImageOutdated` | boolean | 否 | 形象 / 子场景当前应用的图是按旧主图生成的（主图后来换过）。主体、上传的图、还没有图时为 `false` |

另外，**`GET /api/drama/assets/{assetId}`（素材详情）**的主体多返回一个字段（2026-11-24 写开发计划时补，详情页要一次拿到全部形象）：

| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| `looks` | `DramaAsset[]` | 是 | 只在详情接口返回：主体 = 它的全部形象 / 子场景（未删除，按创建先后），没有为 `[]`；形象、道具为 `null`。列表接口不返回（`groupLooks = true` 时见 §7.3） |

`DramaAssetReference` 只加 `parentAssetId`、`lookName` 两个字段（含义同上）；它的 `name` 同样是 `主名·形象名`。

- 现有字段不变；旧版本客户端不认识新字段可忽略，形象会显示成一条名为“江敏·婚纱”的普通素材。
- 老数据：`parentAssetId` 为空、`aliases` 为 `[]`、`parentImageOutdated` 为 `false`。

样例（`GET /api/drama/episodes/6003/assets` 里的一条，形象“婚纱”）：

```json
{ "id": "8302", "episodeId": "6003", "assetId": "7203", "revision": 1, "shared": true, "detached": false, "archived": false,
  "asset": { "id": "7203", "name": "江敏·婚纱", "lookName": "婚纱", "parentAssetId": "7201", "aliases": [], "parentImageOutdated": true,
             "description": "白色蕾丝婚纱，透明长头纱，盘发，珍珠耳饰。", "scope": "PROJECT", "kind": "ROLE", "state": "READY" },
  "sharingGroupId": "b7c1…", "affectedEpisodeIds": ["6003", "6004"], "requiredByShotIds": ["9103"] }
```

（`asset` 里其余现有字段省略，和现在一样。）

### 7.2 `GET /api/drama/projects/{projectId}/asset-overview` 作品的角色 / 场景 / 道具列表（新增，K-16）

- 用途：W-08 整理项目资产页“总览”的角色列表、场景列表、道具网格（不再逐集读取、不再限 10 集）。
- 请求参数：

  | 参数 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `kind` | string | 是 | `ROLE` / `SCENE` / `PROP` |
  | `keyword` | string | 否 | 1～20 字；角色按主名或别名包含匹配，场景按名称，道具按名称；空格两端去掉，空字符串当没传 |

- 返回 `data`：

  | 字段 | 类型 | 说明 |
  |---|---|---|
  | `items` | array | 作品里这一类的全部主体，按第一次出现的集序号、再按名称排序；不分页（一个作品的素材数量有限） |
  | `items[].asset` | `DramaAsset` | 主体（含 §7.1 新字段） |
  | `items[].episodeOrdinals` | integer[] | 主体出现在哪几集（集序号，从小到大） |
  | `items[].looks` | array | 全部形象 / 子场景，按创建先后；道具、没有形象时为 `[]` |
  | `looks[].asset` | `DramaAsset` | 形象 / 子场景 |
  | `looks[].episodeOrdinals` | integer[] | 这个形象出现在哪几集；可以为空（还没关联到任何集） |
  | `missingImageCount` | integer | 全剧（只算已关联到某集的）还没有图的主体和形象总数，给汇总条“缺图片 N” |

- 关键词命中某个形象（如“婚纱”）时，返回它所属的整个主体（含全部形象）。
- 只读，不触发生成。归档的关联不算出现集数；全部集都归档了的主体不返回。

成功：

```json
{ "code": 200, "message": "成功", "data": { "items": [
  { "asset": { "id": "7201", "name": "江敏", "lookName": null, "parentAssetId": null, "aliases": ["小敏", "江老师"], "parentImageOutdated": false, "kind": "ROLE" },
    "episodeOrdinals": [1,2,3,4,5,6,7,8,9,10],
    "looks": [ { "asset": { "id": "7203", "name": "江敏·婚纱", "lookName": "婚纱", "parentAssetId": "7201", "aliases": [], "parentImageOutdated": false, "kind": "ROLE" }, "episodeOrdinals": [3,4] },
               { "asset": { "id": "7204", "name": "江敏·短发", "lookName": "短发", "parentAssetId": "7201", "aliases": [], "parentImageOutdated": false, "kind": "ROLE" }, "episodeOrdinals": [3] } ] } ],
  "missingImageCount": 4 }, "traceId": "mock-k16-ok" }
```

没有结果：`"data": { "items": [], "missingImageCount": 0 }`。

失败：

| code | message | 什么时候 |
|---|---|---|
| `-404` | 资源不存在 | 作品不存在或不是本人的 |
| `-400` | 请求参数错误 | `kind` 不是三个值之一，或 `keyword` 超过 20 字 |

### 7.3 `GET /api/drama/assets` 资产库列表（修改，K-17）

- 新增可选参数 `groupLooks`（boolean，默认 `false`）：
  - `false`（旧行为）：形象也作为单独一条返回（`name` = “江敏·婚纱”），旧客户端不用改。
  - `true`：只返回主体（角色、场景、道具），每条 `DramaAsset` 多一个字段 `looks: DramaAsset[]`（这个主体在资产库里的全部形象，按创建先后）；分页按主体算。资产库“角色 / 场景”页签用 `true`。
- 现有参数 `keyword`（如有）在 `groupLooks = true` 时同时匹配别名和形象名称；其他参数不变。
- 成功样例（`groupLooks=true&kind=ROLE`）：

```json
{ "code": 200, "message": "成功", "data": { "items": [ { "id": "8801", "name": "江敏", "aliases": ["小敏","江老师"], "parentAssetId": null, "lookName": null, "kind": "ROLE", "scope": "PERSONAL", "originProjectName": "婚礼风波",
  "looks": [ { "id": "8803", "name": "江敏·婚纱", "lookName": "婚纱", "parentAssetId": "8801", "aliases": [], "kind": "ROLE", "scope": "PERSONAL" } ] } ],
  "page": 1, "pageSize": 20, "total": 1, "hasMore": false }, "traceId": "mock-k17-ok" }
```

- 失败：和现在一样（`-400` 参数错误、`-401` 未登录）。

### 7.4 改别名、改形象名称（修改，K-18）

`PATCH /api/drama/episode-assets/{bindingId}`（作品内，沿用现有的影响范围确认）和 `PATCH /api/drama/assets/{assetId}`（资产库）各加两个可选字段：

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `aliases` | string[] | 否 | 整组替换。只能用在**角色主体**上；0～10 个，每个去掉首尾空格后 1～20 字，组内不能重复，不能等于自己的主名 |
| `lookName` | string | 否 | 只能用在形象 / 子场景上；1～10 字；同一主体下不能重名；**全名“主名·形象名”最多 20 字**（v1.1.0 联调后，用户 2026-11-24），超了 `-400`“形象全名“…”超过 20 字，请改短”。改主体的 `name` 时，它下面任一形象的全名会超过 20 字也同样拒绝（只改本集不查） |

- 规则：同一个作品里，一个称呼只能属于一个角色——别名不能等于本作品其他角色的主名或别名（资产库里的个人素材不做跨素材检查）。
- 形象 / 子场景不接受 `name`（它的名字由主名和 `lookName` 拼成）；主体改 `name` 后，形象的 `name` 自动跟着变。
- 返回：和现在一样（作品内返回 `ScopeApplied`，资产库返回 `DramaAsset`），带 §7.1 新字段。

成功（改别名）请求：`{ "expectedRevision": 3, "aliases": ["小敏", "江老师"], "scope": { … 现有字段 … } }`，返回的 `asset.aliases = ["小敏","江老师"]`。

失败：

| code | message | 什么时候 |
|---|---|---|
| `-400` | 「周叔」已经是「老周」的名字或别名 | 别名和本作品其他角色冲突（`周叔` / `老周` 为实际值） |
| `-400` | 别名最多 10 个，每个 1～20 字，不能重复 | 数量、长度、组内重复、等于自己主名 |
| `-400` | 只有角色能设置别名 | 在场景、道具或形象上传了 `aliases` |
| `-400` | 江敏已经有叫“婚纱”的形象 | `lookName` 同一主体下重名 |
| `-400` | 形象名称请在新版本中修改 | 在形象上传了 `name`（旧版本客户端） |
| `-560001` | 内容已更新，请核对最新版本 | `expectedRevision` 过期（现有） |
| `-560009` | 素材影响范围已变化，请重新确认 | 现有 |

### 7.5 `POST /api/drama/assets/{assetId}/looks` 新增形象 / 子场景（新增，K-19）

- 用途：W-13 角色 / 场景详情“全部造型”里的“＋ 新增形象 / 新增子场景”弹框。`assetId` 是主体。
- 请求头：`Idempotency-Key`。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `lookName` | string | 是 | 1～10 字，同一主体下不能重名；全名“主名·形象名”最多 20 字，超了 `-400`“形象全名“…”超过 20 字，请改短” |
  | `description` | string | 是 | 外观特征（只写和主图不一样的地方），1～500 字 |
  | `episodeIds` | string[] | 否 | 出现在哪几集（作品内素材才有；必须是同一作品的有效集）；资产库素材不传或传 `[]` |

- 做什么：新建一条形象（和主体同类型、同归属），没有图；按 `episodeIds` 在这些集建关联。不调用 AI、不扣积分。出图在详情页点“生成”，走现有报价确认（K-23）。
- 返回 `data`：`{ "asset": DramaAsset, "bindingIds": string[] }`（新形象和它在各集的关联 ID）。

成功：

```json
{ "code": 200, "message": "成功", "data": { "asset": { "id": "7203", "name": "江敏·婚纱", "lookName": "婚纱", "parentAssetId": "7201", "aliases": [], "parentImageOutdated": false, "kind": "ROLE", "scope": "PROJECT", "state": "DRAFT" }, "bindingIds": ["8302", "8402"] }, "traceId": "mock-k19-ok" }
```

失败：

| code | message | 什么时候 |
|---|---|---|
| `-404` | 资源不存在 | 主体不存在或不是本人的 |
| `-400` | 道具不能新增形象 | 主体是道具 |
| `-400` | 只能在主体下新增形象 | `assetId` 本身是形象 |
| `-400` | 江敏已经有叫“婚纱”的形象 | 重名 |
| `-400` | 请求参数错误 | 名称、描述长度不对，或 `episodeIds` 不属于这个作品 |
| `-560003` | 幂等键已用于其他请求 | 同一个键换了内容（现有） |

### 7.6 `POST /api/drama/assets/{assetId}/remove-look` 删除形象 / 子场景（新增，K-20）

- 用途：W-13 详情页“全部造型”里鼠标移上去点 ✕ → 确认。`assetId` 是要删的形象。
- 确认框里的“第 3、4 集有 5 个片段用到它”用现有 `GET /api/drama/episode-assets/{bindingId}/impact` 取（不新增接口）。
- 请求头：`Idempotency-Key`。请求：`{ "expectedRevision": 2 }`（形象当前版本）。
- 做什么（一个事务）：
  1. 每一集里用到这个形象的片段：把引用换成同一集的主体（这一集还没关联主体就先关联上），视频描述里的 `@江敏·婚纱` 换成 `@江敏`；
  2. 这个形象在各集的关联全部归档，形象本身标记删除；
  3. 已经生成的视频、历史图不动；不扣积分、不退积分。
- 返回 `data`：`{ "removedAssetId": "7203", "changedShotIds": ["9103", "9104"] }`。

失败：

| code | message | 什么时候 |
|---|---|---|
| `-404` | 资源不存在 | 不存在、不是本人的或已删除 |
| `-400` | 主形象不能单独删除 | `assetId` 是主体 |
| `-560001` | 内容已更新，请核对最新版本 | 版本过期 |
| `-560005` | 有片段正在生成视频，请完成后再删除 | 用到它的片段有进行中的视频任务 |
| `-560003` | 幂等键已用于其他请求 | 现有 |

### 7.7 `POST /api/drama/shots/{shotId}/look-switch` 片段里切换形象（新增，K-21）

- 用途：W-09 分镜创作“参考”里点“江敏 · 主形象 ▾”选另一个形象。
- 请求：

  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | `expectedRevision` | integer | 是 | 片段当前版本 |
  | `fromBindingId` | string | 是 | 片段现在用的那个（主体或形象）在本集的关联 ID |
  | `toBindingId` | string | 是 | 换成哪个；必须是**同一个主体**在本集的主体或形象关联 |
  | `applyToFollowing` | boolean | 否 | 默认 `false`。`true` 时本场戏后面的片段一起换（规则见下） |

- 做什么：
  - 片段的出场素材里把 `from` 换成 `to`（位置不变），视频描述里的 `@江敏` 换成 `@江敏·婚纱`（只换完整的 `@名称`，按名称长的先匹配，不碰台词引号里的字）；片段版本加 1。
  - “本场戏后面的片段”：从这个片段往后按顺序看，和它出场场景（场景 / 子场景）完全相同、并且也用了 `from` 的连续片段；遇到场景不同的片段就停。其中正在生成视频或已经用了 `to` 的片段跳过。
  - 不调用 AI、不扣积分；已生成的视频不动。
- 返回 `data`：`{ "shots": DramaShot[] }`（这次改到的全部片段，含新的 `references`、`description`、`revision`、`reminders`）。

失败：

| code | message | 什么时候 |
|---|---|---|
| `-404` | 资源不存在 | 片段不存在或不是本人的 |
| `-560007` | 只能在江敏自己的形象之间切换 | `to` 和 `from` 不属于同一个主体，或不是本集的关联 |
| `-560007` | 本片段已在用「江敏·婚纱」 | `to` 已经在这个片段里（同一片段两个形象必须不同） |
| `-560002` | 「江敏·短发」还没有图片，请先去角色详情生成 | `to` 没有可用图片 |
| `-560001` | 内容已更新，请核对最新版本 | 版本过期 |
| `-560005` | 已有任务处理中，请查询原任务 | 这个片段正在生成视频 |

### 7.8 片段返回新增 `reminders`（修改，K-22）

所有返回 `DramaShot` 的地方（`GET /api/drama/episodes/{episodeId}/shots`、PATCH 片段、K-21 等）多一个字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| `reminders` | array | 提醒（不是错误，不挡生成）；没有为 `[]`。片段卡上显示“N 个提醒” |
| `reminders[].code` | string | 本版只有 `LOOK_MISMATCH`：原文提到某个形象的名称，片段却用了同一角色的别的形象 |
| `reminders[].message` | string | 直接显示，如：原文提到“婚纱”，江敏用的是“主形象”。可点上方“江敏”换成“婚纱”。 |
| `reminders[].bindingId` | string | 现在用的那个关联（点它打开切换） |
| `reminders[].suggestedBindingId` | string | 原文提到的那个形象在本集的关联 |

- 每次读片段时现算（看片段原文 + 当前出场素材 + 本集的形象），不存库；切换后自然消失。
- 同一片段里已经同时用了这两个形象，或原文提到的形象不在本集，不提醒。

样例：`"reminders": [ { "code": "LOOK_MISMATCH", "message": "原文提到“婚纱”，江敏用的是“主形象”。可点上方“江敏”换成“婚纱”。", "bindingId": "8301", "suggestedBindingId": "8302" } ]`

### 7.9 报价：生成视频本次只带部分参考图；形象出图要有主图（修改，K-23）

`POST /api/drama/generation/quotes` 的 `targets[]` 新增可选字段：

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `referenceBindingIds` | string[] | 否 | 只在 `kind = VIDEO`、`mode = SINGLE` 时可用：这一次生成只带这些出场素材的图。必须都是这个片段当前的画面素材；数量不超过当前视频模型的上限。不传 = 全部带上（现在的行为） |

- 片段本身的出场素材、描述都不改，只影响这一次生成；报价的 `inputHash` 包含它，提交（`POST /api/drama/generation/tasks`）不变。
- 参考图超过上限仍然返回现有阻塞项（`blockers[].code = -560007`，message“当前模型最多支持 N 张参考图，本片段有 M 张，请减少参考图或更换模型”）。网页端据此：单个片段弹框让用户勾选后带 `referenceBindingIds` 重新报价；批量时列出这些片段、整批不提交（D-21）。
- 图片报价（`kind = IMAGE`）新增阻塞项：形象 / 子场景没有可用主图、同一批也没有生成主图时，`{ "code": -560002, "message": "请先生成「江敏」的主图" }`。同一批里有主图时，形象排在主图后面，等主图生成成功后自动拿主图作为第一张参考图（沿用现有子场景等主场景的做法，改为按 `parentAssetId`，角色也一样）。

失败（新增）：

| code | message | 什么时候 |
|---|---|---|
| `-400` | 请核对生成目标、完整参数及确认信息，原内容已保留 | `referenceBindingIds` 用在非单个视频报价上、有重复或格式不对（现有 message） |
| `-560007` | 选择的参考图不属于这个片段 | 有不是本片段当前画面素材的关联 |

### 7.10 导入、入库带上形象（行为变化，K-24）

- `POST /api/drama/episodes/{episodeId}/assets/import`：导入一个角色 / 场景主体时，它在资产库里的全部形象一起导入作品（各自挂在新主体下，关联到同一集）；返回结构不变，多一个字段 `lookBindingIds: string[]`。单独导入资产库里的某个形象 → `-400`“请导入整个角色”。
- 失败（新增）：

  | code | message | 什么时候 |
  |---|---|---|
  | `-400` | 请导入整个角色 | 要导入的是资产库里的某个形象（导入场景的子场景时 message 为“请导入整个场景”） |

- 成功样例：现有返回再加 `"lookBindingIds": ["8402", "8403"]`；主体没有形象时为 `[]`。
- **没主图但带形象的主体（v1.1.0 联调修复，用户 2026-11-24 选“没图的主体也能导入”）**：
  - 请求的 `sourceImageVersionId` 改为可选：不传或传 `null` = 主体只导入资料（作品里的主体没图、`DRAFT`），它的形象 / 子场景照常带图导入。只允许带形象的角色 / 场景主体；没形象的主体（或道具）不传 → `-400`“请选择要导入的图片”。传了照旧按所选版本固定。
  - 素材返回的 `canImport`：原来“当前选图可用才为 true”；现在带形象的角色 / 场景主体（个人 / 系统素材）没有可用主图时也为 `true`。客户端判断“能导入但没图”= 不带图片版本导入；换图（`scoped-upload` 用资产库的图）仍要有图。
  - 起因：主图是上传的、形象图是生成的——形象图自动入库时资产库主体只带资料（下一条），导入选择器选不到它。
- **只带勾选的形象（v1.1.0 M07，2026-11-24）**：请求加可选 `lookIds: string[]`——不传或 `null` 和以前一样全部带上；`[]` 一个都不带；有值只带这些（不重复，每个都必须是 `sourceAssetId` 下的形象，否则 `-560007`“选择的形象不属于这个角色”，场景写“这个场景”）。不带主图（不传 `sourceImageVersionId`）时不能是 `[]`（`-400`“请选择要导入的图片”）。`lookBindingIds` 只含带上的。手机端用；网页端没有新增导入入口。详见 §7.13。
- 作品图片自动入库（现有）：形象的图入库时，资产库里的形象挂到资产库里的主体下；别名随主体入库。主体还没入库时先把主体资料入库（只资料、不带图；上传的主图不会自动入库）。
- 一键匹配已有素材（网页端逻辑）：名称或别名相同就算匹配。

### 7.11 素材分析、拆片段、生成提示词（行为变化，K-25）

> v1.1.0 联调后（用户 2026-11-24）：AI 识别出的形象名截短到全名“主名·形象名”不超过 20 字；主名太长放不下任何形象名时不建这个形象。

接口和返回结构不变（§6.1、§6.3、§6.4、§6.10），变的是 AI 输出和后端登记：

- 素材分析（全剧、重新分析本集）：角色多出“别名”和“形象”（换装、换发型等，只在剧本明确写了时才建，带原文依据和出现集数）；有 2 个以上相连空间的场所建一个主场景（主图出俯视图）加若干子场景；单个空间的场景和现在一样。登记时形象 / 子场景挂到主体下，按出现集数关联。已有素材的名称、描述、图片不改（现有规则）。
- 拆片段、生成提示词：给 AI 的本集素材表里，形象写成“江敏·婚纱”并带外观差异；有子场景的场景只能用子场景（主场景俯视图不进片段，和现在的“俯视图”规则一样）；剧本没写明是哪种形象的用主名；同一片段同一角色可以用两个不同形象，每处 `@` 指向各自的形象。
- 老作品不做兼容（技术方案 T-04）：后端删掉按描述“关联主场景”串场景、按名称“俯视图”排除场景的老逻辑；老场景一律当普通场景（老子场景出图不再自动带主场景图，名称带“俯视图”的老场景可能被拆进片段）。

### 7.12 `POST /api/drama/episode-assets/{bindingId}/archive` 删除本集的角色 / 场景时带上它的形象（行为变化，K-26，2026-11-24 写开发计划时补）

- 请求、返回结构不变。变化：归档的是主体在本集的关联时，**同一集里它的形象 / 子场景的关联一起归档**（技术方案 T-03 A、D-23）。
- 本集还有片段在用主体或它的任何一个形象时，整体拒绝、什么都不归档（沿用现有的拒绝和 message）。
- 归档的是形象自己的关联时，和现在一样只归档它（详情页“出现集数”取消勾选用的就是这个）。
- 返回：现有的 `DramaAssetBinding`（主体那一条），多一个字段 `archivedLookBindingIds: string[]`（一起归档的形象关联；没有为 `[]`）。
- 失败：和现在一样。

### 7.13 `POST /api/drama/episode-assets/{bindingId}/library-looks` 从资产库带上形象（新增，K-27，v1.1.0 M07，2026-11-24）

来源：联调后用户决定“导入的时候，弹一个弹框……让用户自己勾选选择哪些形象。如果只有一张图，也是一样的弹框提示这个图用于主形象”。网页端从卡片“导入角色 → 资产库导入”换图、手机端换图时用；新增导入用 §7.10 的 `lookIds`。

请求头 `Idempotency-Key`。请求：

```json
{ "expectedRevision": 3, "sourceAssetId": "9001", "lookIds": ["9002", "9003"] }
```

| 字段 | 说明 |
|---|---|
| `expectedRevision` | 本集这条关联（`bindingId`）现在的版本；先换了主图的，用换图返回的那条关联的版本（“只改本集”时是新的独立关联，`bindingId` 也用它的） |
| `sourceAssetId` | 资产库里的角色 / 场景主体（本人个人素材或已发布系统素材），和本集这条同类型 |
| `lookIds` | 要带上的资产库形象，1～20 个、不重复，都必须是 `sourceAssetId` 下的形象 |

规则：
1. `bindingId` 的素材必须是本作品的角色 / 场景**主体**（不是形象、不是道具），这条关联未归档；作品在分集制作。
2. 按 `lookIds` 顺序逐个：作品里这个主体下**有同名形象**的——资产库形象有可用图就给它固定一份图片版本并应用（同一张资产库图已固定过就复用那条版本；形象版本 +1；形象整部作品共用，**其他集一起换**，它在各有效集的关联版本 +1、用到它的片段标记引用变化，同“同步修改”换图；原来的图留在历史），没图不动图；这一集还没关联的补上关联（归档过的恢复）。**没有同名的**——照导入的写法新建形象（资料 + 有图时固定图片）挂到这个主体下、关联到这一集。
3. 先全部检查再写：新建形象的全名“作品主名·形象名”超过 20 字、主体或要换图的同名形象有进行中的生图任务，**整个请求都不写**。
4. 不扣积分；涉及的各集版本 +1；本集这条关联版本 +1；同键同内容返回原结果，同键换内容 `-560003`。

返回：

```json
{ "lookBindingIds": ["8402", "8403"] }
```

`lookBindingIds`：这些形象在本集的关联，按 `lookIds` 顺序（同名的是作品原有形象的关联）。

失败：

| code | message | 什么时候 |
|---|---|---|
| `-400` | （现有参数错误） | 字段缺、格式不对、`lookIds` 为空 / 超过 20 / 重复 |
| `-400` | 只有角色、场景能带上形象 | `bindingId` 是形象或道具 |
| `-400` | 形象全名“…”超过 20 字，请改短 | 规则 3 |
| `-404` | （现有） | 关联、资产库主体不存在或不是自己的 |
| `-560001` | （现有：版本冲突） | `expectedRevision` 过期 |
| `-560003` | （现有：幂等冲突） | 同键换内容 |
| `-560005` | 这个角色有图片正在生成，请完成后再试（场景写“这个场景”） | 规则 3 |
| `-560007` | 选择的形象不属于这个角色（场景写“这个场景”） | `lookIds` 里有不是 `sourceAssetId` 的形象 |
| `-560007` | 只能导入同类型素材 / 此素材关联已归档，请刷新清单 | 类型不同；关联已归档 |

客户端（网页端、手机端一样）：选好资产库主体点“确认导入”→ 弹框 / 弹层勾形象（主形象固定勾、形象默认全勾；同名的写“已有同名形象，会换成这张图”）→ 资产库主体有主图：先走现有换图（网页一律“同步修改”，手机端照旧弹范围确认），勾了形象再调本接口；没主图：只调本接口。主图换好、本接口失败：提示“主形象已换好，形象没带上：<后端原话>”，用户可再来一次（已挂上的不会重复）。卡片是形象时照旧只换图、不弹。

实现：后端 `82dd624e`（`DramaAssetService#attachLibraryLooks`，导入的 `importLooks` 拆成共用的 `importLook`）；网页端 `bce8cc7`；手机端 `5cb99d9`。

