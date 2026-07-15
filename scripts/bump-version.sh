#!/usr/bin/env bash
# flow 플러그인 버전을 두 파일에서 동시에 올린다 (semver).
#   plugins/flow/.claude-plugin/plugin.json  +  .claude-plugin/marketplace.json
# 설치측 캐시 키가 버전이라, 내용을 바꾸면 반드시 버전을 올려야 update가 재복사한다.
#
# 사용: scripts/bump-version.sh [patch|minor|major]   (기본 patch)
#   patch 0.2.1 = 수정 / minor 0.3.0 = 기능 추가 / major 1.0.0 = 깨지는 변경
set -euo pipefail

part="${1:-patch}"
root="$(git rev-parse --show-toplevel)"
pj="$root/plugins/flow/.claude-plugin/plugin.json"
mp="$root/.claude-plugin/marketplace.json"

cur=$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' "$pj" \
       | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ -n "$cur" ] || { echo "현재 버전을 못 찾음: $pj" >&2; exit 1; }

IFS=. read -r MA MI PA <<< "$cur"
case "$part" in
  major) MA=$((MA+1)); MI=0; PA=0 ;;
  minor) MI=$((MI+1)); PA=0 ;;
  patch) PA=$((PA+1)) ;;
  *) echo "usage: bump-version.sh [patch|minor|major]" >&2; exit 1 ;;
esac
new="$MA.$MI.$PA"

# 두 파일에서 "version": "cur" → "version": "new"
perl -i -pe "s/(\"version\"\s*:\s*)\"\Q$cur\E\"/\${1}\"$new\"/g" "$pj" "$mp"

echo "flow  $cur → $new"
echo "  - $pj"
echo "  - $mp"
echo "→ 커밋하고 push하세요:  git commit -am \"chore: bump flow $new\""
