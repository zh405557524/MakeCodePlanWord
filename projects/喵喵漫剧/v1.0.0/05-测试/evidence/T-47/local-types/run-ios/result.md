# TC-03-09 免费帮写候选与确认 电脑控机记录

- 手机界面状态：blocked
- 原完整验收状态：未自动判定（not_assessed）
- 执行人：AI
- 实际包：{"platform": "iOS", "device": "A798555F-A907-46F9-9E17-F0D36A18130D", "app_id": "com.lxwx.catdrama", "version": "1.0.0", "build": "1", "name": "喵喵漫剧"}
- 前置条件实际观察：普通iOS App已登录自建测试游客2，场景创建表单名称6字、描述12字，使用本机后台与真实DeepSeek，原字段尚未替换。
- 实际结果：普通iOS真实DeepSeek场景/道具正常帮写、主动应用/保留、成功结果重启恢复及按类型表单隔离已补验；完整坏值/活动中断/写盘故障、双端真机及Figma仍待。
- 缺陷：未登记

## 判定与证据

### UI-01 blocked
- 原预期：合法结果≤500字且只有确认才替换；不生图、不预建可用资产、不扣分/发奖；无效输入/结果保旧，不截断。
- 实际：本轮正常分支通过：SCENE 128字候选主动应用，PROP 84字候选重启恢复后保留12字原文，SCENE重开仍128字；2任务/2 HTTP200，积分30/冻结0与流水6、资产1、图片任务及版本1保持。整条坏值/失败矩阵、活动任务中断、写盘故障和真机未覆盖，不能判整条通过。
- 证据：observations/O00013.png；SHA256 f2ba44d34a12f0b5d9939e87796855dbb6ce6be3241cfd1794c1a0ac8c206854
- 证据：observations/O00019.png；SHA256 2c2c3d0c0878bd060c135a59f9f1cdd2abe56a8cf99b34a6c2589d057fa21a5e
- 证据：observations/O00021.png；SHA256 b826fbb3197fb2d5b380f2470b43d69122c048430e6824c5abdbda44cbd3b681
- 证据：observations/O00041.png；SHA256 be4e41c96ec6cc922e4f4d8223943f77b46cd893e179c2db7f87836830f4f557
- 证据：observations/O00043.png；SHA256 3d478fd5e0c796ff9902a48c8b776e7ad785008bcb1bf8dcc8ea7ab2d4869de3
- 证据：observations/O00050.png；SHA256 8e5efab0841b246e36da7f1252c3510834b20596bda0b1bb20e5fcbb6e35b2be

## 仍需按原用例核对

原综合预期中的数据事实仍需实际证据。

记录实际输入/版本、任务或本机操作ID、调用次数、文件摘要、账务差异和对应平台证据；静态检查不代替真机/AI。
