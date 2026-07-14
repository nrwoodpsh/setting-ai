#!/usr/bin/env bash
# 세션 시작 시 flow 워크플로우의 전제(JSON 파서)를 점검하고, 없으면 한 번 경고한다.
# 목적: 파서가 없어 contract-gate가 조용히 무력화되는 "거짓 안심"을 방지.
# 훅은 프로젝트가 이미 가진 런타임(node → python3 → perl)으로 JSON을 파싱한다.
# 셋 중 하나는 거의 항상 있으므로 이 경고는 사실상 뜨지 않는다.
set -uo pipefail

if ! command -v node >/dev/null 2>&1 \
  && ! command -v python3 >/dev/null 2>&1 \
  && ! command -v perl >/dev/null 2>&1; then
  echo "⚠ flow: node·python3·perl 중 아무것도 없어 계약 게이트가 비활성화됩니다." 1>&2
  echo "  셋 중 하나만 있으면 됩니다(대개 이미 있음)." 1>&2
fi
exit 0
