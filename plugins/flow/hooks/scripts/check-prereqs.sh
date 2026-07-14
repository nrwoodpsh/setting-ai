#!/usr/bin/env bash
# 세션 시작 시 flow 워크플로우의 전제 도구를 점검하고, 없으면 한 번 경고한다.
# 목적: jq가 없어 contract-gate가 조용히 무력화되는 "거짓 안심"을 방지.
set -uo pipefail

missing=""
command -v jq >/dev/null 2>&1 || missing="$missing jq"

if [ -n "$missing" ]; then
  echo "⚠ flow: 다음 도구가 없어 계약 게이트가 비활성화됩니다 →$missing" 1>&2
  echo "  설치 후 정상 작동합니다 (예: brew install jq)." 1>&2
fi
exit 0
