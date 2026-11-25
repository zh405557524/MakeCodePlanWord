#!/usr/bin/env bash
# 生成项目工作区骨架：README.md、backlog.md、testing/（来自工作台 templates/project/）。
# 已存在的文件不会被覆盖，可以重复运行来补齐缺失的文件。
#
# 用法：init-project.sh <工作区目录> <项目名>
# 例如：init-project.sh /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 钢琴视奏
set -eu

if [ $# -lt 2 ]; then
  echo "用法：$0 <工作区目录> <项目名>" >&2
  echo "例如：$0 /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 钢琴视奏" >&2
  exit 1
fi

PROJ=$1
PROJECT=$2
WB=$(cd "$(dirname "$0")/.." && pwd)
TPL="$WB/templates/project"
TODAY=$(date +%Y-%m-%d)

if [ ! -d "$TPL" ]; then
  echo "找不到模板目录：$TPL" >&2
  exit 1
fi

PROJECT_ESC=$(printf '%s' "$PROJECT" | sed 's/[&|\\]/\\&/g')
mkdir -p "$PROJ"

LIST=$(mktemp "${TMPDIR:-/tmp}/init-project.XXXXXX")
trap 'rm -f "$LIST"' EXIT
(cd "$TPL" && find . -type f ! -name '.DS_Store' | sort) > "$LIST"

created=0
skipped=0
while IFS= read -r rel; do
  rel=${rel#./}
  dst="$PROJ/$rel"
  if [ -e "$dst" ]; then
    echo "跳过（已存在）：$rel"
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  sed "s|{项目名}|$PROJECT_ESC|g; s|{日期}|$TODAY|g" "$TPL/$rel" > "$dst"
  echo "新建：$rel"
  created=$((created + 1))
done < "$LIST"

echo
echo "完成：新建 $created 个文件，跳过 $skipped 个。工作区：$PROJ"
echo
echo "下一步："
echo "  1. 填写 $PROJ/README.md 的项目信息"
echo "  2. 在工作台 workspace-registry.json 登记 workspace，flow 填 \"v2\""
echo "  3. 开第一个版本：$WB/scripts/new-version.sh $PROJ v1.0.0"
echo "  4. 代码仓库根目录放 AGENTS.md 和 CLAUDE.md，写明工作区 ${PROJ}（模板：$WB/templates/repo/）"
echo "  5. 编码规范放进代码仓库的规范目录，如 .cursor/rules/（模板：$WB/templates/repo-rules/）"
