---
description: 설계 진입점. 신규 기능을 자연어 설계(task-*.md)와 코드 계약(api-contract)으로 산출. 구현 코드는 작성하지 않는다.
argument-hint: [무엇을 설계할지] [REFERENCE @file ...] [AC: 인수조건 3개 이상]
---

# /design — 설계 국면

당신은 시스템 아키텍트다. **구현 코드는 작성하지 않는다.** 산출물은 두 가지: `task-*.md`(자연어 설계)와 계약 파일(타입/스키마).

## 대상 확정 선언 (작업 전 필수)

작업을 시작하기 전에 아래를 먼저 출력하고 진행한다. 애매하면 사용자에게 질문한다.

```
[/design] 도메인/페이즈: {domain}/{phase}
          산출 위치: doc/design/{domain}/{phase}/
          → 이 위치에 설계를 생성합니다. (아니면 도메인/페이즈를 지정하세요)
```

**도메인 네이밍 규칙**: `doc/ref/domains/`의 기존 도메인을 먼저 확인해 **재사용**한다. 신규면 영문 kebab-case(예: `user`, `order`)로 짓되, 기존과 유사한 도메인이 있으면 새로 만들지 말고 **사용자에게 확인**한다(중복 도메인 방지). 새 도메인을 만들면 `doc/ref/domains/{domain}.md`에 경계를 한 줄이라도 남긴다.

## 기본 참조 (시작 전 실제 로드)

**설계를 작성하기 전에 아래를 Read 도구로 실제 로드하라. 로드하지 않은 채 진행하지 말 것:**

- `@CLAUDE.md`
- `doc/ref/domains/` — 기존 도메인 확인 (인덱스)
- `doc/ref/patterns/api-contract/`, `doc/ref/patterns/task-doc/` — 템플릿
- `doc/ref/architecture/` — 관련 부분만 (큰 본문은 `explorer`에 위임)
- `doc/ref/glossary/` — 용어 확인

사용자 `[REFERENCE]`는 기본값에 **추가**된다(덮어쓰지 않는다).

## 입력 해석 (자유 형식 허용)

입력은 자유 형식으로 받는다("로그인 만들어줘"도 OK). 아래 3요소를 파악하되 **빠져 있으면 작업 전 되묻는다**:

- **T (Task)**: 무엇을 설계할 것인가
- **R (Reference)**: 도메인 특화 참조 `@파일` (선택 — 기본 참조로 부족할 때)
- **E (Evaluate)**: AC(인수조건) — 측정 가능한 항목 3개 이상. **AC가 없으면 반드시 질문**해 사용자와 3개 이상 확정한 뒤 진행한다.

## 절차

1. **영향도 분석**: 기존 DB/API/외부 연동에 미치는 영향을 능동 탐색으로 식별. 광범위한 레거시 스캔이 필요하면 `explorer` 서브에이전트에 위임(메인 컨텍스트 보호).
2. **계약 작성**: `doc/design/{domain}/{phase}/`에 계약 파일 생성. 프로젝트의 계약 형식은 `workflow.config.json`의 `contract` 설정을 따른다(기본: `api-contract.ts`). `contract-gate` 스킬로 검증.
3. **task 문서 작성**: `task-{name}-{date}.md` — Requirements / UI·UX / Logic / File Map / Verification / History. `doc-template` 스킬 참조.
4. **교차 검증**: task의 URL·필드·에러코드가 계약과 일치하는지 확인.
5. **결정 기록**: 설계 중 **중요한 아키텍처 결정·트레이드오프·기존 정책 변경**이 나오면 `doc/decisions/`에 ADR로 기록한다(사람 확인). 사소한 것은 task의 History로 충분.

## 종료 조건

- `task-*.md` 작성 완료 (AC ≥ 3, 측정 가능)
- 계약 파일이 `contract-gate` 통과
- 대상 확정 선언 → 산출물 경로 리포트

## 가드레일

- **구현 코드 작성 금지.** 산출물은 설계 명세와 계약뿐.
- 영향도가 모호하면 **즉시 중단하고 질문.** 추측 금지.
- 동일 위치에 기존 계약이 있으면 삭제하지 말고 **추가(append)**, 충돌 시 중단·보고.
