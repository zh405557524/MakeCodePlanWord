#!/usr/bin/env python3
"""改总计划“模块清单”里某个模块的进度，然后重新生成进度页。只改那一行的那几栏。

用法：
  python3 scripts/set-status.py <项目> <版本> <模块号> 栏=值 [栏=值 ...]
例子：
  python3 /Users/soul/work/MakeCodePlanWord/scripts/set-status.py 喵喵漫剧网页端 v1.1.0 M08 后端=完成
  python3 /Users/soul/work/MakeCodePlanWord/scripts/set-status.py 喵喵漫剧网页端 v1.1.0 M08 前端=完成 自审=通过 状态=待检验
  python3 /Users/soul/work/MakeCodePlanWord/scripts/set-status.py 喵喵漫剧网页端 v1.1.0 M08 检验=有问题 状态=执行中 等谁=Claude 备注=M08-03删除按钮颜色不对

能改的栏和能填的词：
  后端、前端：待开始 / 进行中 / 完成 / —
  自审：未开始 / 通过 / 有遗留
  检验：未开始 / 通过 / 有问题
  状态：草稿 / 已审核 / 执行中 / 阻塞 / 待检验 / 待验收 / 通过
  等谁：Claude / Codex / 用户 / —      （不写时按“状态”自动填）
  分支、备注：随便写，一句话，不能有竖线
"""
import fcntl
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ALLOWED = {
    "后端": ["待开始", "进行中", "完成", "—"],
    "前端": ["待开始", "进行中", "完成", "—"],
    "自审": ["未开始", "通过", "有遗留", "—"],
    "检验": ["未开始", "通过", "有问题", "—"],
    "状态": ["草稿", "已审核", "执行中", "阻塞", "待检验", "待验收", "通过"],
    "等谁": ["Claude", "Codex", "用户", "—"],
}
FREE = ["分支", "备注"]
WAIT_BY_STATE = {"草稿": "用户", "已审核": "Claude", "执行中": "Claude", "阻塞": "用户",
                 "待检验": "Codex", "待验收": "用户", "通过": "—"}


def fail(msg):
    print("没有改。" + msg)
    sys.exit(1)


def find_project(key):
    reg = json.loads((ROOT / "workspace-registry.json").read_text(encoding="utf-8"))
    names = [p["name"] for p in reg["projects"]]
    exact = [p for p in reg["projects"] if key == p["name"] or key in p.get("aliases", [])]
    if len(exact) == 1:
        return exact[0]["name"]
    part = [p["name"] for p in reg["projects"] if key in p["name"]]
    if len(part) == 1:
        return part[0]
    fail(f"找不到唯一的项目“{key}”。" + (f"带这几个字的有：{'、'.join(part)}，请写全名。" if part else f"登记的项目有：{'、'.join(names)}"))


def main():
    if len(sys.argv) < 5 or any("=" not in a for a in sys.argv[4:]):
        print(__doc__)
        return 2
    project, version, module = find_project(sys.argv[1]), sys.argv[2], sys.argv[3].upper()
    changes = {}
    for arg in sys.argv[4:]:
        k, v = arg.split("=", 1)
        k, v = k.strip(), v.strip()
        if k in ALLOWED:
            if v == "-":
                v = "—"
            if v not in ALLOWED[k]:
                fail(f"“{k}”只能填：{' / '.join(ALLOWED[k])}，你填的是“{v}”。别的说明写到 备注=… 里。")
        elif k in FREE:
            if "|" in v or "\n" in v:
                fail(f"“{k}”里不能有竖线和换行。")
        else:
            fail(f"没有“{k}”这一栏。能改的栏：{'、'.join(list(ALLOWED) + FREE)}")
        changes[k] = v
    if "状态" in changes and "等谁" not in changes:
        changes["等谁"] = WAIT_BY_STATE[changes["状态"]]
    if changes.get("状态") == "通过":
        changes["状态"] = f"通过（{datetime.now().strftime('%Y-%m-%d')}）"

    plan = ROOT / "projects" / project / version / "04-开发计划" / "开发计划.md"
    if not plan.exists():
        fail(f"找不到总计划：{plan}")
    with open(plan, "r+", encoding="utf-8") as f:
        fcntl.flock(f, fcntl.LOCK_EX)          # 几个对话同时改时排队，不互相覆盖
        lines = f.read().split("\n")
        start = next((i for i, l in enumerate(lines) if l.startswith("## ") and "模块清单" in l), None)
        if start is None:
            fail("总计划里没有“模块清单”一节。")
        header_i = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("|")), None)
        if header_i is None:
            fail("“模块清单”一节里没有表格。")
        header = [c.strip() for c in lines[header_i].strip().strip("|").split("|")]
        missing = [k for k in changes if k not in header]
        if missing:
            fail(f"模块清单没有这几栏：{'、'.join(missing)}。这份总计划是旧格式，先按 templates/version/04-开发计划/开发计划.md 把表头补齐。")
        row_i = None
        for i in range(header_i + 2, len(lines)):
            if not lines[i].startswith("|"):
                break
            if lines[i].strip().strip("|").split("|")[0].strip() == module:
                row_i = i
                break
        if row_i is None:
            fail(f"模块清单里没有 {module} 这一行。")
        cells = [c.strip() for c in lines[row_i].strip().strip("|").split("|")]
        if len(cells) != len(header):
            fail(f"{module} 这一行的格子数（{len(cells)}）和表头（{len(header)}）对不上，可能某个格子里有竖线，先手动修好。")
        before = dict(zip(header, cells))
        for k, v in changes.items():
            cells[header.index(k)] = v
        lines[row_i] = "| " + " | ".join(cells) + " |"
        f.seek(0)
        f.write("\n".join(lines))
        f.truncate()
    print(f"已更新 {project} {version} {module}：" + "；".join(f"{k} {before[k] or '（空）'} → {v}" for k, v in changes.items()))
    after = dict(zip(header, cells))
    print("现在这一行：" + "，".join(f"{k} {after.get(k, '')}" for k in ["后端", "前端", "自审", "检验", "状态", "等谁"] if k in after))
    subprocess.run([sys.executable, str(ROOT / "scripts" / "progress.py")], check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
