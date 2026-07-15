#!/usr/bin/env bash
# flow drift-hook — workflow.config.json 의 drift.mode 로 동작을 고른다.
#   mode: off | warn | block | autosync    (기본: warn)
#     off      → 아무것도 안 함
#     warn     → post-commit 에서 알림만 (비차단)
#     block    → pre-push 에서 차단 (내보내기 직전, 결정론적)
#     autosync → pre-commit 에서 claude -p 로 문서 동기화해 같은 커밋에 포함 (실험적: 느림·비용)
#
# 같은 파일을 .git/hooks/pre-commit · post-commit · pre-push 3개로 설치한다.
# 각 실행은 자기 이름(stage)을 보고, 현재 mode에 해당하는 stage일 때만 동작한다.
# config만 바꾸면 재설치 없이 모드가 바뀐다.
set -uo pipefail
stage=$(basename "$0")

proj="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cfg="$proj/workflow.config.json"

# --- drift.mode 읽기 (없으면 warn). node → python3 → perl 중 있는 것으로 ---
read_mode() {
  [ -f "$cfg" ] || { echo warn; return; }
  local m=""
  if command -v node >/dev/null 2>&1; then
    m=$(node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{let o=JSON.parse(s);process.stdout.write(String((o&&o.drift&&o.drift.mode)||""))}catch(e){}})' < "$cfg" 2>/dev/null)
  elif command -v python3 >/dev/null 2>&1; then
    m=$(python3 -c 'import json,sys
try:
 d=json.load(open(sys.argv[1])); sys.stdout.write(str((d.get("drift") or {}).get("mode","")))
except Exception: pass' "$cfg" 2>/dev/null)
  elif command -v perl >/dev/null 2>&1; then
    m=$(perl -MJSON::PP -0777 -ne 'my $d=eval{decode_json($_)};print(($d->{drift}{mode}//"")) if $d;' "$cfg" 2>/dev/null)
  fi
  [ -n "$m" ] && echo "$m" || echo warn
}
mode=$(read_mode)
[ "$mode" = "off" ] && exit 0

# --- 이 stage에서 검사할 파일 목록 ---
stage_files() {
  case "$stage" in
    post-commit) git diff-tree --no-commit-id --name-only -r --root HEAD 2>/dev/null ;;
    pre-commit)  git diff --cached --name-only ;;
    pre-push)
      local up; up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
      if [ -n "$up" ]; then git diff --name-only "$up"..HEAD 2>/dev/null
      else git diff-tree --no-commit-id --name-only -r --root HEAD 2>/dev/null; fi ;;
  esac
}

# 소스(= doc/ 밖, .md 아님) 변경이 있는데 문서(doc/design·doc/summary)가 없으면 드리프트
is_drift() {
  local files src docs
  files=$(stage_files); [ -n "$files" ] || return 1
  src=$(printf '%s\n' "$files" | grep -vE '^doc/|\.md$' || true); [ -n "$src" ] || return 1
  docs=$(printf '%s\n' "$files" | grep -E '^doc/(design|summary)/' || true)
  [ -z "$docs" ]
}

case "$mode" in
  warn)
    [ "$stage" = "post-commit" ] || exit 0
    if is_drift; then
      echo "" 1>&2
      echo "ℹ️  flow drift: 소스만 반영됨 — 문서(doc/design·doc/summary)가 안 맞습니다. /flow:sync 권장(불필요하면 무시)." 1>&2
      echo "" 1>&2
    fi ;;
  block)
    [ "$stage" = "pre-push" ] || exit 0
    if is_drift; then
      echo "" 1>&2
      echo "⛔ flow drift-block: 내보낼 변경에 소스만 있고 문서가 안 맞습니다. push를 막습니다." 1>&2
      echo "   → Claude Code에서 /flow:sync 후 커밋·push 하세요.   우회: git push --no-verify" 1>&2
      echo "" 1>&2
      exit 1
    fi ;;
  autosync)
    [ "$stage" = "pre-commit" ] || exit 0
    if is_drift; then
      if command -v claude >/dev/null 2>&1; then
        echo "ℹ️  flow autosync: 문서 동기화 중… (claude -p, 잠시 걸릴 수 있음)" 1>&2
        claude -p "코드 변경에 맞춰 doc/design·doc/summary 문서를 flow의 /sync 절차대로 갱신하고 저장만 해줘. 커밋·push는 하지 마." >/dev/null 2>&1 \
          || echo "⚠ autosync 실패 — 그대로 진행합니다. /flow:sync 수동 실행을 권장." 1>&2
        git add doc/ 2>/dev/null || true
      else
        echo "⚠ flow autosync: claude CLI가 없어 건너뜁니다. /flow:sync 수동 실행 권장." 1>&2
      fi
    fi ;;
esac
exit 0
