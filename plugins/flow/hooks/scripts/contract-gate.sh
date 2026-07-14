#!/usr/bin/env bash
# 계약 파일이 Edit/Write될 때, workflow.config.json의 contract.gate로 검증한다.
# 실패 시 exit 2로 차단. jq/config가 없으면 조용히 통과(범용성 우선).
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0

cfg="${CLAUDE_PROJECT_DIR:-.}/workflow.config.json"
[ -f "$cfg" ] || exit 0

pattern=$(jq -r '.contract.file // "api-contract.ts"' "$cfg")
gate=$(jq -r '.contract.gate // empty' "$cfg")
[ -n "$gate" ] || exit 0

# 파일 basename이 계약 패턴과 맞을 때만 게이트 실행 (glob 허용)
base=$(basename "$file")
case "$base" in
  $pattern) ;;
  *) exit 0 ;;
esac

# gate에 {file} 자리표시자가 있으면 치환, 없으면 파일을 인자로 덧붙임
if printf '%s' "$gate" | grep -q '{file}'; then
  cmd=${gate//\{file\}/$file}
else
  cmd="$gate \"$file\""
fi

if ! eval "$cmd" 1>&2; then
  echo "contract-gate 실패: $file — 계약이 검증(${gate})을 통과하지 못했습니다." 1>&2
  exit 2
fi
exit 0
