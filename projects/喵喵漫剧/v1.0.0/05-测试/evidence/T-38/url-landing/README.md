# T-38 邀请链接及公开页面补齐

2026-10-16。原T-38中的专属URL与落地页内部缺项已实现，本任务整项仍未完成；未部署或推送。

后端只为catdrama增加`/sites/catdrama/flows/invite/register/`和`download/`路径，沿既有公共基地址及邀请码/App参数生成链接。漫剧材料说明只显示邀请积分，其他App的路径、会员/现金规则保持；不开放歌曲分享。前端App源码未改，既有`InviteMaterial.hasInviteLink`接收服务端相同字段和App/邀请码参数。

静态页面按官网仓库`web/README.md`规范新增到`web/sites/catdrama/flows/invite/`，复用公共短信及版本接口，无新依赖。验证码按回执冷却、并发防重、失败保手机号/验证码；成功携码登录后跳本App下载页，不在浏览器持久化访问或刷新令牌。注册页面继续链接公司既有通用协议正文，未复制或修改旧资源。下载只采用当前App实际发布URL/版本/包大小，无配置/坏包络/坏URL或失败时禁用并可重取；不使用音乐商店地址、演示版本或体积，不向已签名APK URL追加邀请码。

## 检测

| 层级 | 实际结果 | 范围 |
|---|---|---|
| Java | 31通过、0失败/跳过 | 16邀请＋15公共URL；新增3方法，原“无路径”预期按已批准功能更新1项 |
| 网页 | 22通过、0失败/跳过 | 16漫剧新方法＋6原带货回归；Node标准VM，受控协议响应 |
| 浏览器 | 4张最终实图已查看 | 实测320/375 CSS宽，无横向溢出；空手机号、邀请码传递和版本API404失败态 |
| 移动App | 无源码变化 | 复用T-43有效926项、插件及两端构建；本轮没有重跑/累加 |

真实Spring/JWT/自有隔离PG验证携邀请码的公共短信登录：邀请者加10，受邀者仅沿用公共新账号30，重复绑定不再发奖。短信Provider为Mock。Java也保留写歌/带货/穿搭/无页面App的URL及歌曲分享门禁回归。

网页覆盖跨App/重复参数/非法码、防重/冷却、坏包络/HTTP错误、登录失败留输入、真实字段及签名URL保持、缺配置/危险地址/重试和默认商店禁用。浏览器访问的是本机静态服务器，版本API返回404，因此只证明获取失败态；没有在浏览器发送短信、创建真实账号或打开商店。正向配置和登录路径分别由Node协议测试及实际Java HTTP/PG测试证明，不拼称浏览器到真实SMS的连续联验。

[后端方法与结果](backend-summary.json)、[最终Gradle输出](backend-final.log)、[网页方法与结果](web-summary.json)、[最终Node输出](web-final.log)、[图片清单](image-evidence.json)、[源码](source-manifest.json)、[其他改动保留](preservation.json)。

## 复现

官网仓库：

```sh
node --test test/catdrama_invite_web_test.mjs test/invite_download_web_test.mjs
node --check web/sites/catdrama/flows/invite/invite-api.js
node --check web/sites/catdrama/flows/invite/register/register.js
node --check web/sites/catdrama/flows/invite/download/download.js
python3 -m http.server 53138 --bind 127.0.0.1 --directory web
```

浏览器访问`/sites/catdrama/flows/invite/register/?appCode=catdrama&inviteCode=ABCD1234`（这里是自建测试码），点击空表单只显示校验，不触发短信；“直接前往下载”保留同码。截图的CSS尺寸以DOM实读为准，不能把浏览器请求尺寸当CSS尺寸。初始请求375实际469及不完整重绘截图保留，不计最终图片。最终viewport已恢复、本次自建页关闭，预览服务器停止。

后端仓库，设置专用`CATDRAMA_TEST_POSTGRES_URL/USER/PASSWORD`再运行：

```sh
./gradlew test --tests '*PublicUrlServiceTests' --tests '*CatdramaInviteTests' --offline --console=plain
```

本次复用自有本机PG端口51346，每类创建随机schema，测试结束均清理，剩余非系统schema为0且实例已停止；没有部署、访问正式库或改其他App数据。

## 数据库改动

无业务表、字段、索引、DDL或迁移变化。只运行本项目获准的自有隔离测试数据。

## 待验收

官网域名部署、正式版本/安装包/商店地址、真实短信、两端设备分享/保存和最新Figma未验收；不把代码文件或受控示例URL写成真实发布配置。T-42三项旧公共夹具失败继续保留。186条仍9通过/172部分/5未执行，T-38整项仍在开发中。

后端dev `ac99c6cf`、官网main `52a61b04`，移动App保持dev `10cadc5e`。[提交](commits.json)、[汇总](result.json)、[清理](cleanup.json)、[文档核对](document-check.json)。原文件备份仅本机`originals/`，不纳入提交。
