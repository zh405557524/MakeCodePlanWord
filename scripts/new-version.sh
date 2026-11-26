#!/usr/bin/env bash
# 创建版本文件夹 <工作区>/vX.Y.Z/
#
#   功能版本：
#     - 01-产品/：四份新模板，只写本版增量，引用项目的全量当前产品文档。
#     - 02-设计、03-技术规划：从最近一版或 --from 版本复制，去掉旧改动标记。
#     - README、设计计划、技术方案、04～06：新模板。
#     - --from 是参考版本及设计/技术来源，不将未上线产品变更当作线上基线。
#   patch 版本（--patch）：只有 修复单.md。
#
# 用法：new-version.sh <工作区目录> <版本号> [--from vX.Y.Z] [--patch]
# 例如：new-version.sh /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.3.0
#       new-version.sh /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.3.0 --from v2.2.0
#       new-version.sh /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.2.1 --patch
set -eu

usage() {
  echo "用法：$0 <工作区目录> <版本号> [--from vX.Y.Z] [--patch]" >&2
  echo "例如：$0 /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.3.0" >&2
  echo "      $0 /Users/soul/work/MakeCodePlanWord/projects/钢琴视奏 v2.2.1 --patch" >&2
  exit 1
}

[ $# -lt 2 ] && usage

PROJ=${1%/}
VER=$2
shift 2
FROM=""
PATCH=0
while [ $# -gt 0 ]; do
  case "$1" in
    --patch) PATCH=1 ;;
    --from) [ $# -lt 2 ] && usage; FROM=$2; shift ;;
    *) echo "未知参数：$1" >&2; usage ;;
  esac
  shift
done

WB=$(cd "$(dirname "$0")/.." && pwd)
. "$WB/scripts/lib-doc.sh"
TODAY=$(date +%Y-%m-%d)
PROJECT=$(basename "$PROJ")
CURRENT="$PROJ/当前产品文档"
TITLE=$(project_title "$PROJ")

norm() {
  case "$1" in v*) printf '%s' "$1" ;; *) printf 'v%s' "$1" ;; esac
}
check_ver() {
  if ! printf '%s' "$1" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "版本号格式应为 vX.Y.Z，收到：$1" >&2
    exit 1
  fi
}

VER=$(norm "$VER"); check_ver "$VER"
if [ -n "$FROM" ]; then FROM=$(norm "$FROM"); check_ver "$FROM"; fi

if [ ! -f "$PROJ/README.md" ]; then
  echo "$PROJ 下没有 README.md，请先运行 init-project.sh 生成工作区" >&2
  exit 1
fi

DEST="$PROJ/$VER"
if [ -e "$DEST" ]; then
  echo "版本文件夹已存在：$DEST" >&2
  exit 1
fi

BASE="无"
BASE_ENTRY="../../当前产品文档/README.md"
SOURCE_LABEL="无"

# 生成一个模板文件：$1 模板路径，$2 目标路径
render() {
  mkdir -p "$(dirname "$2")"
  sed "s|{版本号}|$VER|g; s|{日期}|$TODAY|g; s|{上一版本}|$BASE|g; s|{项目名}|$TITLE|g; s|{基线入口}|$BASE_ENTRY|g; s|{来源版本}|$SOURCE_LABEL|g" "$1" > "$2"
  echo "新建：${2#$PROJ/}"
}

# 只更新新目标中指向本版产品材料的相对链接；外链、历史版本链接和来源文件不变。
rewrite_product_navigation() (
  list=$(mktemp "${TMPDIR:-/tmp}/product-navigation.XXXXXX")
  trap 'rm -f "$list"' EXIT
  find "$DEST" -type f -name '*.md' > "$list"
  while IFS= read -r f; do
    rel=${f#"$DEST"/}
    awk -v base="$(dirname "$rel")" '
      function destination(url, parts, count, i, depth, stack, path) {
        if (substr(url, 1, 1) == "/" || url ~ /^#/ || url ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) return ""
        sub(/#.*/, "", url)
        count = split(base "/" url, parts, "/")
        depth = 0
        for (i = 1; i <= count; i++) {
          if (parts[i] == "" || parts[i] == ".") continue
          if (parts[i] == "..") {
            if (!depth) return ""
            depth--
          } else stack[++depth] = parts[i]
        }
        path = ""
        for (i = 1; i <= depth; i++) path = path (i > 1 ? "/" : "") stack[i]
        return path
      }
      function rewrite(url, path) {
        path = destination(url)
        if (path ~ /^01-产品\/(1-需求分析|改动清单)[.]md$/) {
          sub(/(1-需求分析|改动清单)[.]md(#.*)?$/, "requirements-list.md", url)
        }
        if (path ~ /^01-产品\/3-(简化版说明|产品评审版)[.]md$/) {
          sub(/3-(简化版说明|产品评审版)[.]md(#.*)?$/, "requirements-review.md", url)
        }
        if (path ~ /^01-产品\/4-(产品文档评审|产品文档检测报告)[.]md$/) {
          sub(/4-(产品文档评审|产品文档检测报告)[.]md/, "detection-feedback.md", url)
        }
        if (path ~ /^01-产品\/2-[^\/]*产品文档\//) {
          sub(/2-[^\/]*产品文档\/.*$/, "requirements.md", url)
        }
        return url
      }
      {
        rest = $0
        output = ""
        while (match(rest, /\[[^][]*\]\([^()]*\)/)) {
          before = substr(rest, 1, RSTART - 1)
          link = substr(rest, RSTART, RLENGTH)
          rest = substr(rest, RSTART + RLENGTH)
          split_at = index(link, "](")
          url = substr(link, split_at + 2, length(link) - split_at - 2)
          updated = rewrite(url)
          if (updated != url) {
            label = substr(link, 1, split_at + 1)
            gsub(/简化版说明/, "产品评审版", label)
            gsub(/产品文档评审/, "产品文档检测报告", label)
            link = label updated ")"
          }
          output = output before link
        }
        line = output rest
        if (match(line, /^[[:space:]]*\[[^][]+\]:[[:space:]]*/)) {
          prefix = substr(line, 1, RLENGTH)
          tail = substr(line, RLENGTH + 1)
          url = tail
          sub(/[[:space:]].*/, "", url)
          line = prefix rewrite(url) substr(tail, length(url) + 1)
        }
        print line
      }
    ' "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
  done < "$list"
)

PATCH_NUM=${VER##*.}

# ---------- patch ----------
if [ "$PATCH" = "1" ]; then
  if [ "$PATCH_NUM" = "0" ]; then
    echo "提示：patch 版本的最后一位通常不是 0（例如 v2.1.1），请确认版本号。" >&2
  fi
  for v in $(all_versions "$PROJ"); do
    if ver_lt "$v" "$VER"; then BASE=$v; fi
  done
  mkdir -p "$DEST"
  render "$WB/templates/patch/修复单.md" "$DEST/修复单.md"
  echo
  echo "基于版本：$BASE"
  echo "下一步：按工作台 workflow/09-线上问题.md 填写修复单，并把 $PROJ/README.md 的「开发中版本」加上 ${VER}。"
  exit 0
fi

# ---------- 功能版本 ----------
if [ "$PATCH_NUM" != "0" ]; then
  echo "提示：功能版本的最后一位通常是 0（例如 v2.2.0）；只修 bug 请加 --patch。" >&2
fi

TPL="$WB/templates/version"

# 设计和技术文档的来源：--from，或比新版本小的最近一个有 03-技术规划 的版本
SRC_VER=""
if [ -n "$FROM" ]; then
  if [ ! -d "$PROJ/$FROM" ]; then
    echo "找不到来源版本：$PROJ/$FROM" >&2
    exit 1
  fi
  SRC_VER=$FROM
else
  for v in $(all_versions "$PROJ"); do
    if ver_lt "$v" "$VER" && [ -d "$PROJ/$v/03-技术规划" ]; then SRC_VER=$v; fi
  done
fi

# 全量基线只引用，不复制。显式 --from 只决定参考版本和设计/技术来源。
if [ -f "$CURRENT/00-总纲.md" ]; then
  cv=$(current_doc_version "$CURRENT")
  BASE=${cv:-未标版本}
  BASE_ENTRY="../../当前产品文档/00-总纲.md"
elif [ ! -f "$CURRENT/README.md" ]; then
  echo "找不到当前产品文档入口，请先运行 init-project.sh 补齐工作区骨架" >&2
  exit 1
fi
SOURCE_LABEL=${SRC_VER:-无}
mkdir -p "$DEST/01-产品"

if [ -n "$SRC_VER" ]; then
  for sub in 02-设计 03-技术规划; do
    if [ -d "$PROJ/$SRC_VER/$sub" ]; then
      cp -R "$PROJ/$SRC_VER/$sub" "$DEST/"
      echo "复制：$SRC_VER/$sub → $VER/$sub"
    fi
  done
  rm -f "$DEST/02-设计/设计计划.md" "$DEST/03-技术规划/技术方案.md"
  for sub in 02-设计 03-技术规划; do
    [ -d "$DEST/$sub" ] && strip_changes "$DEST/$sub" > /dev/null
  done
  sed_from="s|$SRC_VER 做完后|$VER 做完后|g"
  for f in "$DEST"/02-设计/*.md "$DEST"/03-技术规划/*.md; do
    [ -f "$f" ] || continue
    sed "$sed_from" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
fi
[ -f "$DEST/02-设计/设计说明.md" ] || render "$TPL/02-设计/设计说明.md" "$DEST/02-设计/设计说明.md"
for f in architecture.md api.md data-model.md; do
  [ -f "$DEST/03-技术规划/$f" ] || render "$TPL/03-技术规划/$f" "$DEST/03-技术规划/$f"
done

render "$TPL/README.md"                 "$DEST/README.md"
for f in requirements-list.md requirements.md requirements-review.md detection-feedback.md; do
  render "$TPL/01-产品/$f" "$DEST/01-产品/$f"
done
render "$TPL/02-设计/设计计划.md"       "$DEST/02-设计/设计计划.md"
render "$TPL/03-技术规划/技术方案.md"   "$DEST/03-技术规划/技术方案.md"
render "$TPL/04-开发计划/开发计划.md"   "$DEST/04-开发计划/开发计划.md"
mkdir -p "$DEST/04-开发计划/待执行" "$DEST/04-开发计划/待检验" "$DEST/04-开发计划/已执行"   # 给 Codex 的检验、复检、修复计划（workflow/04 第 12 节）
mkdir -p "$DEST/04-开发计划/模块"        # 模块计划由写计划的人按 模块/模块计划.md 模板逐个新建
render "$TPL/05-测试/测试.md"           "$DEST/05-测试/测试.md"
render "$TPL/06-上线/上线记录.md"       "$DEST/06-上线/上线记录.md"

rewrite_product_navigation

echo
echo "产品：四份增量模板；全量基线：${BASE}（只引用，不复制）"
[ -n "$SRC_VER" ] && echo "设计和技术文档来源：$SRC_VER"
if [ -n "$SRC_VER" ]; then
  status=$(grep -m1 '^| 状态 |' "$PROJ/$SRC_VER/README.md" 2>/dev/null || true)
  case "$status" in
    "| 状态 | 已归档"*) ;;
    *) echo "注意：$SRC_VER 还没有归档。它后续变化需要复核并同步受影响增量、设计和技术文档到 ${VER}。" ;;
  esac
fi
for v in $(all_versions "$PROJ"); do
  if [ -f "$PROJ/$v/修复单.md" ]; then
    st=$(grep -m1 '^| 状态 |' "$PROJ/$v/修复单.md" 2>/dev/null || true)
    case "$st" in
      "| 状态 | 已归档"*) ;;
      *) echo "注意：patch $v 还没归档。它归档时，修复单「文档同步」里的改动需检查与本版增量是否冲突，再更新基线引用和受影响文档： ${VER}。" ;;
    esac
  fi
done
echo
echo "下一步："
echo "  1. 把 $PROJ/README.md 的「开发中版本」改为 $VER"
echo "  2. 按工作台 workflow/01-产品.md：先写 01-产品/requirements-list.md，交用户确认"
