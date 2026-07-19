---
name: default-reference
description: >-
  커맨드별 기본 참조(자동 로드할 표준 컨텍스트)와 참조 금지 경로를 관리한다.
  매번 @로 지정하지 않게.
---

# 기본 참조 관리

## 목적

Claude Code는 자동 RAG 인덱싱이 없다. 파일 참조는 항상 명시적이어야 한다. 이 스킬은 커맨드별 "항상 로드할 표준 컨텍스트"와 "자동으로 읽지 말 경로"를 일관되게 적용한다. 사용자 `[REFERENCE]`는 기본값에 **추가**된다(덮어쓰지 않는다).

## 커맨드별 기본 참조

| 커맨드 | 자동 로드 |
|:---|:---|
| `/design` | `CLAUDE.md` + `doc/ref/domains/` + `doc/ref/architecture/` + `doc/ref/patterns/` + `doc/ref/glossary/` |
| `/troubleshoot` | `CLAUDE.md` + 사용자 지정 로그·코드 + 관련 도메인 `task-*.md`·계약 |
| `/analysis` | `CLAUDE.md` + 사용자 지정 `[REFERENCE]` |
| `/builder` | `CLAUDE.md` + 대상 `task-*.md` + 동일 폴더 계약 + `doc/ref/patterns/` + `doc/ref/glossary/` |
| `/review` | `CLAUDE.md` + 대상 도메인 `task-*.md`·계약 + 변경 소스 |
| `/sync` | `CLAUDE.md` + `git diff` + 동일 도메인 `task-*.md`·계약·기존 `summary/` |

> "자동 로드"는 **인덱스 우선**이다. `ref/architecture`·`ref/db-schema`의 큰 본문은 인덱스만 훑고, 필요한 파일만 `@` 또는 `explorer`로 선택 로드한다 (트래픽 절약).

## 항상 참조 금지 (자동 로드 안 함)

필요 시 사용자가 `@`로 명시 주입한다.

- `doc/analysis/` — 일회성 분석·트러블슈팅 산출물
- `doc/design/{작업 중이 아닌 타 도메인}/`

> `doc/summary/`·`doc/decisions/`는 참조 허용 — 이력·결정 맥락이 필요할 때 명시 주입 가능.

## 운영 원칙

- **`@` 파일 주입은 한 턴에 최대 5개 이내.** 단일 파일 500줄 초과 시 분할 검토.
- 무거운 탐색은 `explorer` 서브에이전트에 위임(메인 컨텍스트 보호).
