#!/usr/bin/env bash
# 계약 파일이 Edit/Write될 때, workflow.config.json의 contract.gate로 검증한다.
# 실패 시 exit 2로 차단. 설정/파서가 없으면 조용히 통과(범용성 우선).
#
# TS 검증 자체는 tsc(=contract.gate)가 한다. 아래 파서는 "훅 입력 JSON"에서
# 값을 꺼내는 배관일 뿐이며, 프로젝트가 이미 가진 런타임을 우선 사용한다:
#   node(Node/TS) → python3(Python) → perl(fallback, mac/linux 기본)
set -uo pipefail

# json_get <JSON문자열> <점경로>  예: json_get "$input" tool_input.file_path
json_get() {
  local data="$1" path="$2"
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$data" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{let o=JSON.parse(s);for(const k of process.argv[1].split("."))o=(o==null?null:o[k]);process.stdout.write(o==null?"":String(o))}catch(e){}})' "$path"
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$data" | python3 -c 'import json,sys
try:
 d=json.load(sys.stdin)
 for k in sys.argv[1].split("."): d=d.get(k) if isinstance(d,dict) else None
 sys.stdout.write("" if d is None else str(d))
except Exception: pass' "$path"
  elif command -v perl >/dev/null 2>&1; then
    printf '%s' "$data" | perl -MJSON::PP -0777 -ne 'BEGIN{@k=split/\./,$ARGV[0];shift @ARGV} my $d=eval{decode_json($_)}; for my $key (@k){$d = ref($d) eq "HASH" ? $d->{$key} : undef} print defined($d)?$d:"";' "$path"
  fi
}

# 파서가 하나도 없으면 조용히 통과
if ! command -v node >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1 && ! command -v perl >/dev/null 2>&1; then
  exit 0
fi

input=$(cat)
file=$(json_get "$input" tool_input.file_path)
[ -n "$file" ] || exit 0

cfg="${CLAUDE_PROJECT_DIR:-.}/workflow.config.json"
[ -f "$cfg" ] || exit 0
cfgdata=$(cat "$cfg")

pattern=$(json_get "$cfgdata" contract.file); [ -n "$pattern" ] || pattern="api-contract.ts"
gate=$(json_get "$cfgdata" contract.gate)
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
