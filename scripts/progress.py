#!/usr/bin/env python3
"""汇总各项目开发中版本的模块清单，生成工作台根目录的 进行中.md 和 进行中.html。

用法：python3 scripts/progress.py            全部项目 → 进行中.md / 进行中.html
      python3 scripts/progress.py 喵喵漫剧   只看名字或别名里带“喵喵漫剧”的项目 → 进行中-喵喵漫剧.md / .html
读：workspace-registry.json 里 flow=v2 的项目 → 各版本 04-开发计划/开发计划.md 的“模块清单”表。
另外只读各代码仓库的提交记录（git log），找提交信息里带模块号的提交，用来发现清单没跟上的情况；不改任何仓库。
规则见 workflow/05-开发.md 第 12 节、workflow/04-开发计划.md 第 2 节。
"""
import html
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

try:
    from zoneinfo import ZoneInfo
    NOW = datetime.now(ZoneInfo("America/Los_Angeles"))
except Exception:  # 没有时区数据时用本机时间
    NOW = datetime.now()

ROOT = Path(__file__).resolve().parent.parent
MAC_ROOT = "/Users/soul/work/MakeCodePlanWord"
COLS = ["后端", "前端", "自审", "检验", "状态", "分支", "等谁"]
ALLOWED = {
    "后端": {"待开始", "进行中", "完成", "—", "-", ""},
    "前端": {"待开始", "进行中", "完成", "—", "-", ""},
    "自审": {"未开始", "通过", "有遗留", "—", "-", ""},
    "检验": {"未开始", "通过", "有问题", "—", "-", ""},
    "状态": {"草稿", "已审核", "执行中", "阻塞", "待检验", "待验收", "通过"},
    "等谁": {"Claude", "Codex", "用户", "—", "-", ""},
}
WAIT_BY_STATE = {"草稿": "用户", "已审核": "Claude", "执行中": "Claude", "阻塞": "用户",
                 "待检验": "Codex", "待验收": "用户", "通过": "—"}
DONE_STATES = ("已归档", "搁置")
DEV_STAGES = ("开发计划", "开发")   # 只展示在这两个阶段的版本；其余未归档的版本列在最后一行
ALIAS = {"进行中@状态": "执行中", "未开始@后端": "待开始", "未开始@前端": "待开始"}


def clean(cell):
    cell = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", cell)  # 去掉链接，只留文字
    return cell.replace("**", "").replace("`", "").strip()


def version_state(vdir):
    readme = vdir / "README.md"
    if not readme.exists():
        return ""
    for line in readme.read_text(encoding="utf-8").splitlines()[:15]:
        m = re.match(r"\|\s*状态\s*\|(.*)\|\s*$", line)
        if m:
            text = clean(m.group(1))
            return re.split(r"[（(]", text)[0].strip() or text
    return ""


def module_table(plan):
    lines = plan.read_text(encoding="utf-8").splitlines()
    start = next((i for i, l in enumerate(lines) if l.startswith("## ") and "模块清单" in l), None)
    if start is None:
        return [], []
    rows = []
    for l in lines[start + 1:]:
        if l.startswith("## "):
            break
        if l.startswith("|"):
            rows.append([clean(c) for c in l.strip().strip("|").split("|")])
    if len(rows) < 3:
        return [], []
    return rows[0], [r for r in rows[2:] if any(r)]


def state_word(text, col=""):
    word = re.split(r"[（(，,；;：:\s]", text.strip())[0].strip() if text.strip() else ""
    return ALIAS.get(f"{word}@{col}", word)


OTHERS = []     # 不在开发阶段的版本
OVERVIEW = []   # 所有没归档的版本：项目、版本、阶段、模块进度
QUEUES = []     # 不按版本走的项目（如后端与后台）：三个文件夹里各有几份计划


def la_time(ts):
    try:
        return datetime.fromtimestamp(ts, ZoneInfo("America/Los_Angeles")).strftime("%m-%d %H:%M")
    except Exception:
        return datetime.fromtimestamp(ts).strftime("%m-%d %H:%M")


def ids_in_name(name):
    """从文件名里找出它说的是哪些模块：M08、M01至M06、M02～M12 都认。"""
    found = set()
    for a, b in re.findall(r"M(\d{2})\s*(?:至|到|～|~|-)\s*M(\d{2})", name):
        found |= {f"M{i:02d}" for i in range(int(a), int(b) + 1)}
    found |= {f"M{n}" for n in re.findall(r"M(\d{2})", name)}
    return found


def newer_files(plan_dir, master_mtime):
    """每个模块：比总计划改得晚的相关文件（模块计划、给 Codex 的计划）。"""
    late = {}
    files = list((plan_dir / "模块").glob("M*.md")) if (plan_dir / "模块").is_dir() else []
    for folder in ("待执行", "待检验", "已执行"):
        if (plan_dir / folder).is_dir():
            files += list((plan_dir / folder).glob("*.md"))
    for f in files:
        mt = f.stat().st_mtime
        if mt <= master_mtime + 60:
            continue
        label = f.name if f.parent.name == "模块" else f"{f.parent.name}/{f.name}"
        for mid in ids_in_name(f.name):
            if mid not in late or mt > late[mid][0]:
                late[mid] = (mt, label)
    return late


def repo_dir(mac_path):
    """登记表里写的是 Mac 上的路径；在 Claude 的环境里同一个仓库挂在 ~/mnt/<文件夹名>。"""
    if not mac_path:
        return None
    for cand in (Path(mac_path), Path.home() / "mnt" / Path(mac_path).name):
        if (cand / ".git").exists():
            return cand
    return None


def created_date(vdir):
    readme = vdir / "README.md"
    if readme.exists():
        m = re.search(r"\|\s*创建日期\s*\|\s*(\d{4}-\d{2}-\d{2})", readme.read_text(encoding="utf-8"))
        if m:
            return m.group(1)
    return ""


def module_commits(proj, version, since):
    """只读各仓库的提交记录，找提交信息里带模块号（M08）的提交。返回 (每个模块最近一次提交, 读不到的仓库)。
    后端是几个 App 共用的：提交信息里带本版本号或本 App 标识的才算；一个都不带时才退回只看模块号。"""
    repos = [("前端", proj.get("appRepo"))] + [("后端", r) for r in proj.get("backendRepos", [])]
    marks = [x.lower() for x in [version, proj.get("appCode"), proj.get("backendAppCode")] + proj.get("aliases", []) if x]
    latest, missing = {}, []
    for side, mac_path in repos:
        if not mac_path:
            continue
        d = repo_dir(mac_path)
        if d is None:
            missing.append(Path(mac_path).name)
            continue
        cmd = ["git", "-C", str(d), "log", "--all", "-n", "2000", "--format=%ct%x09%h%x09%s"]
        if since:
            cmd.insert(5, f"--since={since}")
        try:
            out = subprocess.run(cmd, capture_output=True, text=True, timeout=15).stdout
        except Exception:
            missing.append(Path(mac_path).name)
            continue
        rows = [l.split("\t", 2) for l in out.splitlines() if l.count("\t") >= 2]
        tagged = [r for r in rows if any(m in r[2].lower() for m in marks)]
        for ts, sha, subject in (tagged or rows):
            for mid in set(re.findall(r"(?<![A-Za-z0-9])M\d{2}(?!\d)", subject)):
                if mid not in latest or int(ts) > latest[mid][0]:
                    latest[mid] = (int(ts), side, sha, Path(mac_path).name)
    return latest, sorted(set(missing))


def collect():
    reg = json.loads((ROOT / "workspace-registry.json").read_text(encoding="utf-8"))
    out = []
    for proj in reg.get("projects", []):
        if proj.get("flow") != "v2":
            continue
        ws = ROOT / "projects" / proj["name"]
        if not ws.is_dir():
            continue
        if (ws / "开发计划" / "待执行").is_dir():   # 没有版本文件夹、直接用三个文件夹的项目
            def names(folder):
                d = ws / "开发计划" / folder
                return sorted(str(f.relative_to(d)) for f in d.rglob("*.md")) if d.is_dir() else []
            QUEUES.append({"项目": proj["name"], "待执行": names("待执行"), "待检验": names("待检验"),
                           "已执行": len(names("已执行")), "路径": f"{MAC_ROOT}/projects/{proj['name']}/开发计划"})
        for vdir in sorted(p for p in ws.iterdir() if p.is_dir() and re.match(r"v\d", p.name)):
            vstate = version_state(vdir)
            if any(d in vstate for d in DONE_STATES):
                continue
            plan = vdir / "04-开发计划" / "开发计划.md"
            header, rows = module_table(plan) if plan.exists() else ([], [])
            stage = re.split(r"[·•\s]", vstate)[0] if vstate else ""
            if stage not in DEV_STAGES or not rows:
                OTHERS.append(f"{proj['name']} {vdir.name}（{vstate or '状态未写'}）")
                OVERVIEW.append((proj["name"], vdir.name, vstate or "状态未写", ""))
                continue
            mods = []
            master_mtime = plan.stat().st_mtime
            late = newer_files(plan.parent, master_mtime)
            commits, missing = module_commits(proj, vdir.name, created_date(vdir))
            for r in rows:
                d = dict(zip(header, r))
                item = {"编号": d.get("编号", ""), "模块": d.get("模块", ""), "问题": [], "多写": False}
                item["检验"] = d.get("检验", d.get("联调", ""))  # 旧计划的“联调”栏
                for c in COLS:
                    if c != "检验":
                        item[c] = d.get(c, "")
                word = state_word(item["状态"], "状态")
                if not item["等谁"]:
                    item["等谁"] = WAIT_BY_STATE.get(word, "")
                for c, ok in ALLOWED.items():
                    if state_word(item[c], c) not in ok:
                        item["问题"].append(c)       # 开头不是规定的词
                    elif item[c] not in ok and c != "状态":
                        item["多写"] = True           # 开头是规定的词，后面多写了说明
                hit = late.get(item["编号"])
                item["落后"] = f"{hit[1]} 在 {la_time(hit[0])} 改过，比清单晚" if hit else ""
                c = commits.get(item["编号"])
                item["提交"] = f"{la_time(c[0])} {c[1]} {c[2]}" if c else ""
                if c:
                    not_started = all(state_word(item[k], k) in ("待开始", "—", "-", "") for k in ("后端", "前端"))
                    if not_started and item["编号"] != "M99":
                        item["落后"] = (item["落后"] + "；" if item["落后"] else "") + f"{c[3]} 已有提交 {c[2]}（{la_time(c[0])}），清单还写着没开始"
                    elif c[0] > master_mtime + 60 and not item["落后"]:
                        item["落后"] = f"{c[3]} 在 {la_time(c[0])} 有新提交 {c[2]}，比清单晚"
                mods.append(item)
            todo = sorted(p.name for p in (vdir / "04-开发计划" / "待执行").glob("*.md")) \
                if (vdir / "04-开发计划" / "待执行").is_dir() else []
            review = sorted(p.name for p in (vdir / "04-开发计划" / "待检验").glob("*.md")) \
                if (vdir / "04-开发计划" / "待检验").is_dir() else []
            done = sum(1 for m in mods if state_word(m["状态"], "状态") == "通过")
            OVERVIEW.append((proj["name"], vdir.name, vstate, f"{done} / {len(mods)} 个模块通过"))
            out.append({"项目": proj["name"], "版本": vdir.name, "阶段": vstate, "模块": mods,
                        "待执行": todo, "待检验": review, "清单时间": la_time(master_mtime), "读不到": missing,
                        "路径": f"{MAC_ROOT}/projects/{proj['name']}/{vdir.name}/04-开发计划"})
    return out


def short(text, n=14):
    return text if len(text) <= n else text[:n] + "…"


def to_md(data):
    stamp = NOW.strftime("%Y-%m-%d %H:%M")
    L = ["# 进行中", "",
         f"> 由 `scripts/progress.py` 生成，不要手改。生成时间：{stamp}（洛杉矶时间）。", ""]
    waiting = {}
    for v in data:
        for m in v["模块"]:
            w = m["等谁"]
            if w and w not in ("—", "-"):
                waiting.setdefault(w, []).append(f"{v['项目']} {v['版本']} {m['编号']}")
    L.append("## 现在等谁")
    L.append("")
    for w in ("用户", "Claude", "Codex"):
        if waiting.get(w):
            L.append(f"- **{w}**（{len(waiting[w])}）：" + "；".join(waiting[w]))
    L.append("")
    L += ["## 所有没归档的版本", "", "| 项目 | 版本 | 阶段 | 模块 |", "|---|---|---|---|"]
    L += [f"| {a} | {b} | {short(c, 30)} | {d} |" for a, b, c, d in OVERVIEW]
    L.append("")
    for q in QUEUES:
        L += [f"## {q['项目']}（不按版本走）", "",
              f"待执行 {len(q['待执行'])} 份，待检验 {len(q['待检验'])} 份，已执行 {q['已执行']} 份。", ""]
        if q["待执行"]:
            L.append("**该交给 Codex 的（待执行）**：")
            L += [f"- `{q['路径']}/待执行/{n}`" for n in q["待执行"]]
            L.append("")
        if q["待检验"]:
            L.append("**等你和 Claude 看的（待检验）**：" + "、".join(q["待检验"]))
            L.append("")
    for v in data:
        L += [f"## {v['项目']} {v['版本']}（{v['阶段'] or '状态未写'}）", ""]
        if v["待执行"]:
            L.append("**该交给 Codex 的（待执行）**：")
            L += [f"- `{v['路径']}/待执行/{n}`" for n in v["待执行"]]
            L.append("")
        if v["待检验"]:
            L.append("**Codex 做完、等你和 Claude 看的（待检验）**：" + "、".join(v["待检验"]))
            L.append("")
        L += [f"模块清单最后更新：{v['清单时间']}（洛杉矶时间）。", ""]
        if v["读不到"]:
            L += [f"读不到这些代码仓库的提交记录（这台机器上没有，或没连上）：{'、'.join(v['读不到'])}。", ""]
        L += ["| 编号 | 模块 | 后端 | 前端 | 自审 | 检验 | 状态 | 分支 | 等谁 | 最近提交 |", "|---|---|---|---|---|---|---|---|---|---|"]
        for m in v["模块"]:
            cells = [m["编号"], short(m["模块"], 20)] + [
                (short(m[c]) + "⚠") if c in m["问题"] else (state_word(m[c], c) if c in ALLOWED else m[c]) for c in COLS] + [m["提交"]]
            L.append("| " + " | ".join(cells) + " |")
        if any(m["问题"] for m in v["模块"]):
            L += ["", "⚠ = 这一栏没用规定的词，已截短显示；原文见总计划。"]
        stale = [m for m in v["模块"] if m["落后"]]
        if stale:
            L += ["", "**这几行可能落后了**（相关文件或代码提交比模块清单晚，清单可能没跟着更新）："]
            L += [f"- {m['编号']}：{m['落后']}" for m in stale]
        L.append("")
    return "\n".join(L) + "\n"


CSS = """
:root{color-scheme:light dark}
body{font:14px/1.6 -apple-system,"PingFang SC","Helvetica Neue",sans-serif;margin:24px auto;max-width:1100px;padding:0 20px;
 background:#fafaf8;color:#1f1f1c}
@media (prefers-color-scheme:dark){body{background:#1b1b19;color:#e8e6df}th{background:#262623!important}
 td,th{border-color:#3a3a36!important}.card{background:#222220!important;border-color:#3a3a36!important}
 .muted{color:#9a988f!important}code{background:#2c2c29!important}}
h1{font-size:22px;margin:0 0 4px}h2{font-size:17px;margin:28px 0 8px}
.muted{color:#6f6d65;font-size:12px}
.cards{display:flex;gap:12px;flex-wrap:wrap;margin:16px 0}
.card{flex:1 1 220px;border:1px solid #dcdad2;border-radius:8px;padding:10px 14px;background:#fff}
.card b{font-size:22px;display:block}
.wrap{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-variant-numeric:tabular-nums}
th,td{border:1px solid #dcdad2;padding:5px 9px;text-align:left;white-space:nowrap}
td.name{white-space:normal;min-width:180px}
th{background:#f0eee7;font-weight:600}
.tag{display:inline-block;padding:0 8px;border-radius:10px;font-size:12px;border:1px solid transparent}
.ok{background:#e3f1e4;color:#1e5b2a}.run{background:#e4ecf8;color:#1d4a85}.wait{background:#f6ecd2;color:#6d5208}
.bad{background:#f8e0dc;color:#8c2415}.idle{background:transparent;color:#6f6d65;border-color:#c9c7bf}
@media (prefers-color-scheme:dark){.ok{background:#1f3d25;color:#a9dab1}.run{background:#1e3350;color:#a9c8f0}
 .wait{background:#473a12;color:#ecd591}.bad{background:#4d211b;color:#f2b3a8}.idle{color:#9a988f;border-color:#55534d}}
code{background:#eeece5;padding:1px 5px;border-radius:4px;font-size:12px;word-break:break-all;white-space:normal}
ul{margin:4px 0 10px 18px;padding:0}
"""
TAG = {"完成": "ok", "通过": "ok", "进行中": "run", "执行中": "run", "已审核": "run",
       "待检验": "wait", "待验收": "wait", "有遗留": "wait", "草稿": "idle", "待开始": "idle", "未开始": "idle",
       "阻塞": "bad", "有问题": "bad"}


def tag(text, col, bad):
    if not text or text in ("—", "-"):
        return "—"
    if col in ("分支", "等谁") and not bad:
        return html.escape(text)
    word = state_word(text, col)
    cls = TAG.get(word)
    if bad or cls is None:
        return f'<span title="{html.escape(text)}">{html.escape(short(text))} ⚠</span>'
    return f'<span class="tag {cls}" title="{html.escape(text)}">{html.escape(word)}</span>'


def to_html(data):
    stamp = NOW.strftime("%Y-%m-%d %H:%M")
    waiting = {"用户": 0, "Claude": 0, "Codex": 0}
    for v in data:
        for m in v["模块"]:
            if m["等谁"] in waiting:
                waiting[m["等谁"]] += 1
    H = ["<!DOCTYPE html>", '<html lang="zh-CN"><head><meta charset="utf-8">',
         '<meta name="viewport" content="width=device-width,initial-scale=1">', "<title>进行中</title>",
         f"<style>{CSS}</style></head><body>", "<h1>进行中</h1>",
         f'<div class="muted">由 scripts/progress.py 生成 · {stamp}（洛杉矶时间）· 刷新：python3 {MAC_ROOT}/scripts/progress.py</div>',
         '<div class="cards">']
    for w, label in (("用户", "等你"), ("Claude", "等 Claude"), ("Codex", "等 Codex")):
        H.append(f'<div class="card"><span class="muted">{label}</span><b>{waiting[w]}</b><span class="muted">个模块</span></div>')
    H.append("</div>")
    H.append('<h2>所有没归档的版本</h2><div class="wrap"><table><tr><th>项目</th><th>版本</th><th>阶段</th><th>模块</th></tr>')
    for a, b, c, d in OVERVIEW:
        H.append(f'<tr><td>{html.escape(a)}</td><td>{html.escape(b)}</td><td class="name" title="{html.escape(c)}">{html.escape(short(c, 40))}</td><td>{html.escape(d) or "—"}</td></tr>')
    H.append("</table></div>")
    for q in QUEUES:
        H.append(f"<h2>{html.escape(q['项目'])} <span class=\"muted\">不按版本走 · 待执行 {len(q['待执行'])} · 待检验 {len(q['待检验'])} · 已执行 {q['已执行']}</span></h2>")
        if q["待执行"]:
            H.append("<div><b>该交给 Codex 的（待执行）</b><ul>")
            H += [f"<li><code>{html.escape(q['路径'])}/待执行/{html.escape(n)}</code></li>" for n in q["待执行"]]
            H.append("</ul></div>")
        if q["待检验"]:
            H.append("<div><b>等你和 Claude 看的（待检验）</b><ul>")
            H += [f"<li>{html.escape(n)}</li>" for n in q["待检验"]]
            H.append("</ul></div>")
    for v in data:
        H.append(f"<h2>{html.escape(v['项目'])} {html.escape(v['版本'])} <span class=\"muted\">{html.escape(v['阶段'] or '状态未写')}</span></h2>")
        if v["待执行"]:
            H.append('<div><b>该交给 Codex 的（待执行）</b><ul>')
            H += [f"<li><code>{html.escape(v['路径'])}/待执行/{html.escape(n)}</code></li>" for n in v["待执行"]]
            H.append("</ul></div>")
        if v["待检验"]:
            H.append("<div><b>Codex 做完、等你和 Claude 看的（待检验）</b><ul>")
            H += [f"<li>{html.escape(n)}</li>" for n in v["待检验"]]
            H.append("</ul></div>")
        H.append(f'<div class="muted">模块清单最后更新：{v["清单时间"]}（洛杉矶时间）'
                 + (f' · 读不到这些仓库的提交记录：{html.escape("、".join(v["读不到"]))}' if v["读不到"] else "") + "</div>")
        H.append('<div class="wrap"><table><tr><th>编号</th><th>模块</th>' + "".join(f"<th>{c}</th>" for c in COLS) + "<th>最近提交</th><th>提醒</th></tr>")
        for m in v["模块"]:
            H.append(f"<tr><td>{html.escape(m['编号'])}</td><td class=\"name\">{html.escape(short(m['模块'], 28))}</td>"
                     + "".join(f"<td>{tag(m[c], c, c in m['问题'])}</td>" for c in COLS)
                     + f'<td class="muted">{html.escape(m["提交"]) or "—"}</td>'
                     + (f'<td><span class="tag bad" title="{html.escape(m["落后"])}">可能落后</span></td>' if m["落后"] else "<td></td>") + "</tr>")
        H.append("</table></div>")
        if any(m["问题"] for m in v["模块"]):
            H.append('<div class="muted">⚠ = 这一栏没用规定的词，已截短；鼠标停在上面看原文。</div>')
        stale = [m for m in v["模块"] if m["落后"]]
        if stale:
            H.append('<div><b>这几行可能落后了</b>（相关文件或代码提交比模块清单晚）<ul>'
                     + "".join(f"<li>{html.escape(m['编号'])}：{html.escape(m['落后'])}</li>" for m in stale) + "</ul></div>")
    if not data:
        H.append("<p>没有开发中的版本。</p>")
    H.append("</body></html>")
    return "\n".join(H) + "\n"


def main():
    data = collect()
    key = " ".join(sys.argv[1:]).strip()
    suffix = ""
    if key:
        reg = json.loads((ROOT / "workspace-registry.json").read_text(encoding="utf-8"))
        hit = {p["name"] for p in reg.get("projects", [])
               if any(key.lower() in n.lower() for n in [p["name"]] + p.get("aliases", []))}
        if not hit:
            names = "、".join(p["name"] for p in reg.get("projects", []))
            print(f"没有名字或别名里带“{key}”的项目。登记的项目有：{names}")
            return 1
        legacy = sorted(p["name"] for p in reg.get("projects", []) if p["name"] in hit and p.get("flow") != "v2")
        data = [v for v in data if v["项目"] in hit]
        OVERVIEW[:] = [o for o in OVERVIEW if o[0] in hit]
        QUEUES[:] = [q for q in QUEUES if q["项目"] in hit]
        suffix = "-" + re.sub(r"[\\/\s]", "", key)
        print("匹配到的项目：" + "、".join(sorted(hit)))
        if legacy:
            print("其中还是旧流程、进度页读不了的：" + "、".join(legacy))
    md, page = to_md(data), to_html(data)
    if key:
        md = md.replace("# 进行中", f"# 进行中：{key}", 1)
        page = page.replace("<h1>进行中</h1>", f"<h1>进行中：{html.escape(key)}</h1>", 1)
    (ROOT / f"进行中{suffix}.md").write_text(md, encoding="utf-8")
    (ROOT / f"进行中{suffix}.html").write_text(page, encoding="utf-8")
    n = sum(len(v["模块"]) for v in data)
    print(f"已生成 进行中{suffix}.md、进行中{suffix}.html：开发中 {len(data)} 个版本、{n} 个模块；没归档的版本共 {len(OVERVIEW)} 个")
    return 0


if __name__ == "__main__":
    sys.exit(main())
