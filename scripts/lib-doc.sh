#!/usr/bin/env bash
# new-version.sh 和 update-current-doc.sh 共用的函数。不要直接运行。
# 兼容 macOS 自带的 bash 3.2 和 BSD sed / awk。

BLOCK_BEGIN='<!-- 本版改动：开始 -->'
BLOCK_END='<!-- 本版改动：结束 -->'
POS_PREFIX='> **文档定位**：'

# 工作区里所有版本号，从小到大（只认 vX.Y.Z 形式的文件夹）
all_versions() {
  for d in "$1"/v*; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    if printf '%s' "$n" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then echo "${n#v}"; fi
  done | sort -t. -k1,1n -k2,2n -k3,3n | sed 's/^/v/'
}

# $1 < $2 ？
ver_lt() {
  [ "$1" = "$2" ] && return 1
  first=$(printf '%s\n%s\n' "${1#v}" "${2#v}" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)
  [ "$first" = "${1#v}" ]
}

# 去掉一个目录里所有 .md 的「本版改动」一节和小节下面的"> 本版改动：R-xx"标记
# 输出去掉的标记数
strip_changes() {
  dir=$1
  count=0
  list=$(mktemp "${TMPDIR:-/tmp}/lib-doc.XXXXXX")
  find "$dir" -type f -name '*.md' > "$list"
  while IFS= read -r f; do
    n=$(grep -Ec '^[[:space:]]*>[[:space:]]*本版改动[：:]' "$f" || true)
    count=$((count + n))
    awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
      index($0, b) == 1 { skip = 1; next }
      skip && index($0, e) == 1 { skip = 0; drop_blank = 1; next }
      skip { next }
      drop_blank && $0 == "" { drop_blank = 0; next }
      { drop_blank = 0 }
      /^[[:space:]]*>[[:space:]]*本版改动[：:]/ { drop_next_blank = 1; next }
      drop_next_blank && $0 == "" { drop_next_blank = 0; next }
      { drop_next_blank = 0; print }
    ' "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
  done < "$list"
  rm -f "$list"
  find "$dir" -name '.DS_Store' -type f -exec rm -f {} + 2>/dev/null || true
  echo "$count"
}

# 把文件第一个一级标题换成 $2
set_title() {
  awk -v t="$2" '!done && /^# / { print "# " t; done = 1; next } { print }' "$1" > "$1.tmp"
  mv "$1.tmp" "$1"
}

# 把"> **文档定位**："这一行换成 $2；没有这一行时插在一级标题后面
set_position() {
  f=$1
  text=$2
  if grep -qF "$POS_PREFIX" "$f"; then
    awk -v p="$POS_PREFIX" -v t="$text" 'index($0, p) == 1 && !done { print t; done = 1; next } { print }' "$f" > "$f.tmp"
  else
    awk -v t="$text" '!done && /^# / { print; print ""; print t; done = 1; next } { print }' "$f" > "$f.tmp"
  fi
  mv "$f.tmp" "$f"
}

# 在"> **文档定位**："所在的那组引用行之后插入文件 $2 的内容（前后各空一行）
insert_after_position() {
  f=$1
  blockfile=$2
  awk -v p="$POS_PREFIX" -v bf="$blockfile" '
    function emit() {
      print ""
      while ((getline line < bf) > 0) print line
      close(bf)
      done = 1
    }
    !done && found && $0 !~ /^>/ { emit(); found = 0 }
    { print }
    index($0, p) == 1 && !done { found = 1 }
    END { if (found && !done) emit() }
  ' "$f" > "$f.tmp"
  mv "$f.tmp" "$f"
}

# 从当前产品文档的文档定位行里读出它对应的版本号
current_doc_version() {
  f="$1/00-总纲.md"
  [ -f "$f" ] || return 0
  grep -F "$POS_PREFIX" "$f" | head -1 | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# 项目显示名：取工作区 README.md 的一级标题，去掉末尾的"工作区"；取不到就用文件夹名
project_title() {
  t=$(grep -m1 '^# ' "$1/README.md" 2>/dev/null | sed -e 's/^# //' -e 's/[[:space:]]*工作区[[:space:]]*$//' || true)
  if [ -n "$t" ]; then printf '%s' "$t"; else basename "$1"; fi
}
