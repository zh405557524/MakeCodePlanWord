#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
registry="$repo_root/workspace-registry.json"
canonical_root="$repo_root/projects"

fail() {
  printf 'workspace-path-guard: %s\n' "$*" >&2
  exit 1
}

require_tools() {
  command -v jq >/dev/null 2>&1 || fail "缺少 jq，无法读取 $registry"
  command -v python3 >/dev/null 2>&1 || fail "缺少 python3，无法规范化路径"
  test -f "$registry" || fail "注册表不存在：$registry"
}

normalize_path() {
  python3 -c 'import os,sys; print(os.path.realpath(os.path.abspath(sys.argv[1])))' "$1"
}

resolve_project_name() {
  local key="$1"
  local exact_names
  exact_names="$(jq -r --arg key "$key" '
    [.projects[]
      | select(.name == $key or ((.aliases // []) | index($key)))
      | .name]
    | unique
    | .[]
  ' "$registry")"

  if test -z "$exact_names"; then
    local normalized_key
    normalized_key="$(normalize_path "$key")"
    exact_names="$(jq -r --arg key "$normalized_key" '
      [.projects[]
        | select((.repositories // []) | index($key))
        | .name]
      | unique
      | .[]
    ' "$registry")"
  fi

  local count
  count="$(printf '%s\n' "$exact_names" | awk 'NF { count++ } END { print count+0 }')"
  test "$count" -gt 0 || fail "无法解析项目：$key"
  if test "$count" -gt 1; then
    fail "项目不唯一：${key}；候选为 $(printf '%s' "$exact_names" | paste -sd '、' -)"
  fi
  printf '%s\n' "$exact_names"
}

resolve_workspace() {
  local project_name
  project_name="$(resolve_project_name "$1")"
  local workspace="$canonical_root/$project_name"
  test -d "$workspace" || fail "注册项目目录不存在：$workspace"
  normalize_path "$workspace"
}

is_under() {
  local child="$1"
  local parent="$2"
  test "$child" = "$parent" || [[ "$child" == "$parent/"* ]]
}

check_target() {
  local project_key="$1"
  local raw_target="$2"
  local workspace
  local target
  workspace="$(resolve_workspace "$project_key")"
  target="$(normalize_path "$raw_target")"

  while IFS= read -r forbidden; do
    test -n "$forbidden" || continue
    forbidden="$(normalize_path "$forbidden")"
    if is_under "$target" "$forbidden"; then
      fail "拒绝禁用路径：$target"
    fi
  done < <(jq -r '.forbiddenRoots[]' "$registry")

  is_under "$target" "$workspace" || fail "目标不在项目唯一工作区内：target=$target workspace=$workspace"
  printf '%s\n' "$target"
}

audit_registry() {
  local failures=0
  local forbidden
  while IFS= read -r forbidden; do
    test -n "$forbidden" || continue
    if test -e "$forbidden"; then
      printf 'workspace-path-guard: 禁用目录仍存在：%s\n' "$forbidden" >&2
      failures=1
    fi
  done < <(jq -r '.forbiddenRoots[]' "$registry")

  local project_name
  while IFS= read -r project_name; do
    local workspace="$canonical_root/$project_name"
    local workflow="$workspace/workflow.md"
    local expected_root
    expected_root="$(normalize_path "$workspace")"
    if ! test -f "$workflow"; then
      printf 'workspace-path-guard: 缺少 workflow.md：%s\n' "$workflow" >&2
      failures=1
      continue
    fi
    if ! rg -Fq "| \`canonicalWorkspaceRoot\` | \`$expected_root\` |" "$workflow"; then
      printf 'workspace-path-guard: canonicalWorkspaceRoot 缺失或不一致：%s\n' "$workflow" >&2
      failures=1
    fi
  done < <(jq -r '.projects[].name' "$registry")

  local active_wrong_refs
  active_wrong_refs="$(
    find "$canonical_root" \
      -path '*/archive/path-recovery-20260731' -prune -o \
      -type f \( -name '*.md' -o -name '*.json' \) -print0 \
      | xargs -0 rg -l '/Users/soul/code/lxwx/projects|projects/(catsinger|catseller)' 2>/dev/null \
      || true
  )"
  if test -n "$active_wrong_refs"; then
    printf 'workspace-path-guard: 主路径仍引用禁用工作区：\n%s\n' "$active_wrong_refs" >&2
    failures=1
  fi

  if find /Users/soul/code/lxwx -maxdepth 3 -type d -name projects -print -quit 2>/dev/null | grep -q .; then
    printf 'workspace-path-guard: LXWX 代码树内仍存在 projects 目录\n' >&2
    failures=1
  fi

  test "$failures" -eq 0 || exit 1
  printf 'workspace-path-guard: audit passed\n'
}

usage() {
  printf '%s\n' \
    'Usage:' \
    '  workspace-path-guard.sh resolve <project-name|alias|repository-path>' \
    '  workspace-path-guard.sh check <project-name|alias|repository-path> <target-path>' \
    '  workspace-path-guard.sh audit'
}

main() {
  require_tools
  case "${1:-}" in
    resolve)
      test "$#" -eq 2 || fail "resolve 需要 1 个参数"
      resolve_workspace "$2"
      ;;
    check)
      test "$#" -eq 3 || fail "check 需要 2 个参数"
      check_target "$2" "$3"
      ;;
    audit)
      test "$#" -eq 1 || fail "audit 不接受参数"
      audit_registry
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
