# Audiveris 进程清理回归

2026-10-07，v2.1.1 F-09。本轮只修复后端识别进程的退出等待和对应回归测试；数据库改动为无，没有执行正式部署。

## 结果

- 原正式构建测试：486 项中 1 项失败、4 项跳过，失败发生在取消任务后立即检查识别进程是否已退出。原记录：[initial-failure.xml](initial-failure.xml)。
- 修复前重复验证：保留原退出断言，将取消测试重复 20 次，并检查中断标记；23 项中 19 项失败，全部是进程仍存活。记录：[before-fix.log](before-fix.log)、[repeated-before-fix.xml](repeated-before-fix.xml)。
- 修复后相关回归：60 项中 57 项通过、3 项跳过；20 次取消全部通过，覆盖运行时探测、超时、解析与导入服务。记录：[focused-after-fix.log](focused-after-fix.log)、[repeated-after-fix.xml](repeated-after-fix.xml)。
- 全量回归与打包：505 项中 501 项通过、4 项既有跳过、0 失败，`bootJar` 成功；总数增加 19 来自取消测试的重复次数。记录：[full-test-and-jar.log](full-test-and-jar.log)、[full-audiveris-after-fix.xml](full-audiveris-after-fix.xml)。

## 验证命令

在 `/Users/soul/code/soul/service` 执行：

```bash
./gradlew test --tests 'com.soul.service.app.solfeggio.scoreimport.service.AudiverisScoreRecognitionServiceTest' --console=plain
./gradlew test --tests 'com.soul.service.app.solfeggio.scoreimport.service.*' --console=plain
./gradlew test bootJar --console=plain
git diff --check
```

进程测试使用本机临时脚本，不代表真实 Audiveris 的图片/PDF 识别验收。原失败、超时分类、进程退出和中断状态断言均保留，没有通过等待测试断言或跳过用例消除失败。

正式发布前须先提交本次两处 Java 修改，使 `main` 工作区干净。随后由用户执行 `.local/prod/bin/deploy.sh full-migrate`，按提示确认正式环境和完整迁移并输入 SSH 密码；本轮未执行此命令。
