# CLAUDE.md

## 1. 프로젝트 정체성

- **프로젝트명**: acme-portal
- **기술 스택**: Spring Boot 3 + MyBatis + Vue 3 + TypeScript
- **주요 도메인**: 회원(user)·주문(order)·결재(approval)

---

## 2. 워크플로우

본 프로젝트는 `flow` 플러그인을 사용한다. 진입점은 상황별로 고른다:

| 상황 | 흐름 |
|:---|:---|
| 신규 기능 | `/design` → `/builder` → `/sync` |
| 버그·장애 | `/troubleshoot` → `/builder`(또는 직접 수정) → `/sync` |
| 레거시 파악 | `/analysis` → `/design` → … |
| 품질 점검 | `/review` (필요할 때 오버레이) |
| 커밋 | `/commit` (요청 시에만) |

> **핵심 규칙: 여러 문 입장, 한 문 퇴장.** 코드 변경은 반드시 `/sync`로 수렴.

검증 명령·계약 형식은 `workflow.config.json`에 정의한다.

---

## 3. 참조 통제

### 항상 참조 (인덱스 상시, 본문은 선택 로드)
- `doc/ref/domains/` — 도메인 경계·맵
- `doc/ref/architecture/` — 아키텍처·기술 스택
- `doc/ref/patterns/` — 확정 패턴
- `doc/ref/db-schema/` — DB DDL (index=테이블 목록)
- `doc/ref/glossary/` — 용어집

### 참조 금지 (필요 시 `@`로 명시 주입)
- `doc/analysis/`, `doc/design/{타 도메인}/`

---

## 4. 가드레일 (절대 금지)

- **운영 DB 직접 접속 금지** — DDL만 참조, 실행은 사람이.
- **`git push`·`merge`·force-push·`reset --hard` 금지** — Claude는 안 함. push·merge는 사람.
- **민감 파일 커밋 금지** — `.env`, `*.key`, `application-prod.yml`.
- **자동 커밋 금지** — 커밋은 `/commit`으로만.

---

## 5. 코딩 스타일 (프로젝트 고유만)

- 네이밍: BE `kr.co.acme.{도메인}.controller/service/mapper`, FE `PascalCase` 컴포넌트 + `kebab-case` 파일.
- 테스트: BE JUnit 5, FE Vitest.
- 커밋 메시지: `[#이슈] 동사로 시작 — 한 줄 요약`.

---

## 6. 도구 정책 (프로젝트 고유만)

- **MCP**: DB MCP(읽기 전용 스키마 조회) + Git MCP만. 그 외 금지.
