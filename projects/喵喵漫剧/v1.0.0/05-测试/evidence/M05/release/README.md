# M05 静态页面发布包

状态：未发布。正式服务器SSH只读预检未能以当前凭据登录；本任务没有写入正式服务器。

`catdrama-public-pages.tar.gz`仅包含`manifest.json`列明的9个文件：5页HTML、3个自有CSS/JS资源、邀请注册页HTML。包内从`sites/catdrama/`开始，不含Flutter管理后台、其他App、密钥或服务器配置。

有正式发布连接后，将9个文件上传到独立暂存目录，按manifest核对SHA-256；备份正式站点中同路径已有文件，再逐项复制到当前静态站点根目录。保留`sites/catdrama/flows/invite/`中未列出的原有脚本和下载页，不覆盖整个目录，不运行整站Flutter部署。

验收依次请求：

1. `/sites/catdrama/info/customer-service/`，标题含“联系我们”“喵喵漫剧”，正文显示`catai01`，复制可用。
2. `/sites/catdrama/legal/privacy-policy/`，标题及正文为漫剧隐私政策。
3. `/sites/catdrama/legal/user-agreement/`，标题及正文为漫剧用户协议。
4. `/sites/catdrama/info/algorithm-filing/`，与批准的带货两项字节备案内容一致。
5. `/sites/catdrama/legal/recharge-agreement/`，标题及正文为漫剧积分充值协议。

核对CSS/JS实际返回内容及文内链接。公司首页兜底即使HTTP200也不算通过。再用正常App验证真实正式页面、原生登录协议入口及充值返回状态；通过前保持“正式网页未验收”，暂停App发布。

失败时仅恢复这9个路径的备份；原本不存在的新增文件仅按本包清单回退，不清空目录或回退其他发布。
