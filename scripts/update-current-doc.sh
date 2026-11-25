#!/usr/bin/env bash
# 仅兼容旧全量格式归档；四文档增量版本按 workflow/08 逐项合并，禁止整份替换。
#   - 来源：<工作区>/vX.Y.Z/01-产品/2-vX.Y.Z产品文档/
#   - 去掉「本版改动」一节和小节下面的改动标记
#   - 总纲标题改为"当前产品文档"，文档定位写明对应哪个版本
# 旧的当前产品文档整个被替换；替换前后的差别用 git diff 查看。
#
# 用法：update-current-doc.sh <工作区目录> <版本号>
# 例如：update-current-doc.sh /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.2.0
set -eu

if [ $# -lt 2 ]; then
  echo "用法：$0 <工作区目录> <版本号>" >&2
  exit 1
fi

PROJ=${1%/}
VER=$2
case "$VER" in v*) ;; *) VER="v$VER" ;; esac

WB=$(cd "$(dirname "$0")/.." && pwd)
. "$WB/scripts/lib-doc.sh"
TODAY=$(date +%Y-%m-%d)
PROJECT=$(basename "$PROJ")
TITLE=$(project_title "$PROJ")

if [ -f "$PROJ/$VER/01-产品/requirements.md" ]; then
  echo "本版使用四文档增量结构，不能整体替换当前产品文档。请按 workflow/08-归档.md 逐项合入已上线的 R，保留未改功能。" >&2
  exit 1
fi

SRC="$PROJ/$VER/01-产品/2-${VER}产品文档"
CURRENT="$PROJ/当前产品文档"
if [ ! -f "$SRC/00-总纲.md" ]; then
  echo "找不到 $VER 的产品文档：$SRC/00-总纲.md" >&2
  exit 1
fi

TMP="$PROJ/.当前产品文档.new"
OLD="$PROJ/.当前产品文档.old"
rm -rf "$TMP" "$OLD"
cp -R "$SRC" "$TMP"
n=$(strip_changes "$TMP")
set_title "$TMP/00-总纲.md" "$TITLE 当前产品文档"
set_position "$TMP/00-总纲.md" "${POS_PREFIX}当前产品文档——线上已完成的功能，对应 **$VER**（$TODAY 归档时更新）。后续版本只引用本基线，归档时逐项合入已上线增量。"
if [ -f "$TMP/README.md" ] && grep -qF "$POS_PREFIX" "$TMP/README.md"; then
  set_position "$TMP/README.md" "${POS_PREFIX}当前产品文档（对应 **$VER**）的模块分册说明。"
fi

if [ -d "$CURRENT" ]; then
  mv "$CURRENT" "$OLD"
fi
mv "$TMP" "$CURRENT"
rm -rf "$OLD"

echo "已用 $VER 产品文档替换 当前产品文档/（去掉改动标记 $n 处）。"
echo "下一步：用 git diff 查看当前产品文档的变化，确认和 $VER 产品文档开头「本版改动」一致。"
