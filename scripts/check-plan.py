#!/usr/bin/env python3
"""检查一个版本的开发计划有没有守住 workflow/04-开发计划.md 的硬规定。

用法：python3 scripts/check-plan.py <版本文件夹的绝对路径>
例如：python3 scripts/check-plan.py /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏/v2.2.0
“错误”必须改；“提醒”看一眼。有错误时退出码是 1。
"""
import re
import sys
from pathlib import Path

MODULE_MAX, MASTER_MAX, RESULT_MAX_CHARS = 300, 150, 400
MODULE_SECTIONS = ["接口改动总览", "开工条件", "规范", "界面与设计依据", "契约", "任务列表",
                   "不改动范围", "模块验收路径", "审核记录"]
MASTER_SECTIONS = ["接口改动总览", "打样", "模块清单", "问题清单"]
ALLOWED = {
    "后端": {"待开始", "进行中", "完成", "—", "-"},
    "前端": {"待开始", "进行中", "完成", "—", "-"},
    "自审": {"未开始", "通过", "有遗留", "—", "-"},
    "检验": {"未开始", "通过", "有问题", "—", "-"},
    "状态": {"草稿", "已审核", "执行中", "阻塞", "待检验", "待验收", "通过"},
    "等谁": {"Claude", "Codex", "用户", "—", "-"},
}
errors, warns = [], []


def section(lines, keyword):
    """返回标题里含 keyword 的二级章节的行（不含标题）。"""
    start = next((i for i, l in enumerate(lines) if l.startswith("## ") and keyword in l), None)
    if start is None:
        return None
    out = []
    for l in lines[start + 1:]:
        if l.startswith("## "):
            break
        out.append(l)
    return out


def cells(line):
    return [re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", c).replace("**", "").strip() for c in line.strip().strip("|").split("|")]


def check_master(path):
    lines = path.read_text(encoding="utf-8").splitlines()
    name = path.name
    for k in MASTER_SECTIONS:
        if section(lines, k) is None:
            errors.append(f"{name}：缺“{k}”一节")
    body = len(lines) - len(section(lines, "接口改动总览") or []) - len(section(lines, "问题清单") or [])
    if body > MASTER_MAX:
        warns.append(f"{name}：{body} 行（不含总览和问题清单），超过 {MASTER_MAX} 行")
    table = [l for l in (section(lines, "模块清单") or []) if l.startswith("|")]
    if len(table) >= 3:
        header = cells(table[0])
        for col in ALLOWED:
            if col not in header:
                errors.append(f"{name}：模块清单缺“{col}”一栏")
        for row in table[2:]:
            d = dict(zip(header, cells(row)))
            for col, ok in ALLOWED.items():
                v = d.get(col, "")
                word = re.split(r"[（(]", v)[0].strip() if col == "状态" else v
                if col in d and word not in ok and v != "":
                    errors.append(f"{name}：{d.get('编号', '?')} 的“{col}”写的是“{v[:20]}”，只能写：{' / '.join(sorted(ok))}")


def check_module(path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    name = path.name
    if len(lines) > MODULE_MAX:
        warns.append(f"{name}：{len(lines)} 行，超过 {MODULE_MAX} 行，考虑再拆")
    for k in MODULE_SECTIONS:
        if section(lines, k) is None:
            errors.append(f"{name}：缺“{k}”一节")
    if "AC 对照表" not in text:
        errors.append(f"{name}：缺 AC 对照表")
    if "会改的文件和目录" not in text:
        errors.append(f"{name}：基本信息里缺“会改的文件和目录”")
    if "测试基线" not in text:
        errors.append(f"{name}：开工条件里缺“测试基线”")
    for l in section(lines, "界面与设计依据") or []:
        if l.startswith("|") and "待确认" in l:
            errors.append(f"{name}：§4 有“待确认”行，不能审核通过：{l[:50]}")
    tasks = re.findall(r"^#{3,4} ([BF]-\d+)", text, flags=re.M)
    refs = len(re.findall(r"对应接口改动", text))
    if tasks and refs < len(tasks):
        errors.append(f"{name}：{len(tasks)} 个任务里只有 {refs} 个写了“对应接口改动”")
    if re.search(r"^#{3,4} J-\d+", text, flags=re.M) or "假数据目录" in text:
        warns.append(f"{name}：还有联调任务（J-xx）或假数据的写法，是旧格式")
    for l in lines:
        if re.match(r"\s*-\s*\**结果\**[：:]", l) and len(l) > RESULT_MAX_CHARS:
            warns.append(f"{name}：有任务“结果”超过 {RESULT_MAX_CHARS} 字，长的说明写进问题清单或检验报告")
            break
    for word in ("按需", "酌情", "适当地", "优化一下", "参考现有实现", "参考类似页面"):
        if word in text:
            warns.append(f"{name}：出现模糊词“{word}”")


def check_codex_doc(path):
    text = path.read_text(encoding="utf-8")
    name = f"待执行/{path.name}"
    if "/Users/" not in text:
        errors.append(f"{name}：没有任何绝对路径，Codex 找不到文档")
    rel = [p for p in re.findall(r"`([^`\n]+\.md)`", text) if not p.startswith("/") and "/" in p and "{" not in p]
    if rel:
        errors.append(f"{name}：有 {len(set(rel))} 处文档写的是相对路径，例如 `{rel[0]}`，要改成绝对路径")
    if "只能改哪些文件" not in text:
        warns.append(f"{name}：没有“只能改哪些文件”一节")


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    vdir = Path(sys.argv[1])
    plan_dir = vdir / "04-开发计划"
    master = plan_dir / "开发计划.md"
    if not master.exists():
        print(f"找不到 {master}")
        return 2
    check_master(master)
    modules = sorted((plan_dir / "模块").glob("M*.md")) if (plan_dir / "模块").is_dir() else []
    for m in modules:
        if not m.name.startswith("M99"):
            check_module(m)
    for d in sorted((plan_dir / "待执行").glob("*.md")) if (plan_dir / "待执行").is_dir() else []:
        check_codex_doc(d)
    print(f"检查了总计划、{len(modules)} 份模块计划")
    for e in errors:
        print("错误  " + e)
    for w in warns:
        print("提醒  " + w)
    if not errors and not warns:
        print("没有发现问题")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
