#!/usr/bin/env bash
# 流程文档路径门禁：只读校验登记表和目标路径，不创建、移动或删除项目文件。
set -euo pipefail
exec python3 - "$0" "$@" <<'PY'
import json
import sys
from pathlib import Path


def fail(message):
    print("工作区校验失败：" + message, file=sys.stderr)
    raise SystemExit(1)


def within(path, parent):
    return path == parent or parent in path.parents


root = Path(sys.argv[1]).resolve().parent.parent
args = sys.argv[2:]
if len(args) < 2 or args[0] not in ("check", "audit"):
    fail("用法：workspace-path-guard.sh check <项目名或别名> <绝对目标路径>；audit <项目名或别名>")
mode, name = args[:2]
if mode == "check" and len(args) != 3 or mode == "audit" and len(args) != 2:
    fail("参数数量不正确")
try:
    registry = json.loads((root / "workspace-registry.json").read_text())
    matches = [p for p in registry["projects"] if name in [p.get("name"), p.get("appCode"), *p.get("aliases", [])]]
except (OSError, ValueError, KeyError, TypeError) as error:
    fail("登记表不可读或格式错误（" + type(error).__name__ + "）")
if len(matches) != 1:
    fail("项目未唯一匹配：" + name)
project = matches[0]
if project.get("flow") != "v2" or not project.get("workspace"):
    fail("仅允许已迁移的 v2 工作区，旧项目文档只读")
canonical = (root / registry.get("canonicalRoot", "projects")).resolve()
workspace = Path(project["workspace"]).resolve()
if not within(workspace, canonical) or workspace == canonical:
    fail("登记的工作区不在规范项目目录内")
if not workspace.is_dir():
    fail("登记的工作区目录不存在")
repositories = [Path(p).resolve() for p in [project.get("appRepo"), *project.get("backendRepos", [])] if p]
for forbidden in registry.get("forbiddenRoots", []):
    if within(workspace, Path(forbidden).resolve()):
        fail("工作区位于禁止的目录")
for repo in repositories:
    if within(workspace, repo):
        fail("流程文档不能写入代码仓库")
if mode == "check":
    target = Path(args[2])
    if not target.is_absolute():
        fail("目标必须为绝对路径")
    if not within(target.resolve(), workspace):
        fail("目标越过当前项目工作区（含符号链接跳转）")
else:
    # 只检查当前项目，不扫描或清理其他项目的历史资料。
    escapes = [str(p.relative_to(workspace)) for p in workspace.rglob("*")
               if p.is_symlink() and not within(p.resolve(), workspace)]
    if escapes:
        fail("工作区存在向外的符号链接：" + "、".join(escapes))
print(json.dumps({"result": "PASS", "mode": mode, "project": project["name"],
                  "workspace": str(workspace)}, ensure_ascii=False))
PY
