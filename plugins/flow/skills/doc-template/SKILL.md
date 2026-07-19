---
name: doc-template
description: >-
  task-*.md 설계 문서의 표준 섹션 골격을 강제.
  실제 템플릿은 프로젝트 doc/ref/patterns/task-doc/에 있고 /design이 로드한다.
---

# task-*.md 템플릿

## 목적

설계 문서의 표준 구조 강제. 누가 쓰든 동일 골격 위에서만 문서를 만들도록 한다.

## 정본 위치

프로젝트의 `doc/ref/patterns/task-doc/task-template.md` (프로젝트가 소유·조정). 이 스킬은 **링크·규약** 역할만 한다.

## 산출 위치

`doc/design/{domain}/{phase}/task-{name}-{date}.md`
- `{domain}`: 도메인 (예: `user`, `order`)
- `{phase}`: 페이즈 (예: `login`, `list`)
- `{name}`: Task 이름 (kebab-case)
- `{date}`: `YYYYMMDD`
- **파일명 충돌**: 같은 `{name}-{date}`가 이미 있으면 덮어쓰지 말고 `-2`·`-3` 접미사로 구분한다(재작업 이력 보존). `analysis-*`·`troubleshoot-*`·`summary-*` 산출물도 동일 규약.

## 표준 섹션 (필수)

**제시 순서 = 수정 가능성 순**(판단이 갈리는 것 먼저, 기계적 작업 뒤 — 실행 순서 아님):

1. **Requirements** — Scenario / Objective / Acceptance Criteria (측정 가능, ≥ 3)
2. **사각지대 & 핵심 결정** — 부딪히면 배울 함정 + 택한 안/기각 대안 (새 기능·불확실성 있을 때; 자명하면 생략)
3. **UI/UX** — 레이아웃·인터랙션 (해당 시)
4. **Logic** — 핵심 알고리즘·계산식·쿼리 개요
5. **Implementation Split** — BE/FE 책임 분리 (해당 시)
6. **File Map** — `[New]`·`[Mod]` 파일 경로 (기계적 — 판단 필요 없음, 뒤로)
7. **Verification** — 검증 명령과 통과 조건 (Exit 0 등), AC 매핑
8. **History** — 변경 이력 (`/builder`·`/sync`가 갱신). 계획 이탈은 **Deviation**으로 기록

## 가드레일

- **AC는 측정 가능해야 한다.** "사용자 친화적" 같은 모호한 표현 금지.
- **계약 파일과 중복 작성 금지** — task에는 의도·배경·UX만, 타입·Endpoint·에러코드는 계약만.
- **수정 가능성 순 유지** — 결정(대안 포함)을 앞, 기계적 File Map을 뒤. 기계적 나열로 문서를 시작하지 않는다.
- 설계 변경·이탈은 History에 **사유를 자연어로** 기록. 단순 덮어쓰기 금지.
- **이 스킬은 섹션 골격(구조)만 강제한다.** 문장 가독성은 짝을 이루는 `plain-writing` 스킬(쉬운 말 규칙)이 맡는다.
