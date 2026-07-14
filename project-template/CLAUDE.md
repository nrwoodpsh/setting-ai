# CLAUDE.md

## 1. 프로젝트 정체성

- **프로젝트명**: {{프로젝트명}}
- **기술 스택**: {{예: Spring Boot 3 + MyBatis + Vue 3 + TypeScript}}
- **주요 도메인**: {{예: 회원·인사·결재}}

---

## 2. 워크플로우

본 프로젝트는 `flow` 플러그인을 사용한다. 진입점은 상황별로 고른다:

| 상황 | 흐름 |
|:---|:---|
| 신규 기능 | `/design` → `/builder` → `/sync` |
| 버그·장애 | `/troubleshoot` → `/builder`(또는 직접 수정) → `/sync` |
| 레거시 파악 | `/analysis` → `/design` → … |
| 품질 점검 | `/review` (필요할 때 오버레이) |
| 커밋 | `/commit` (요청 시에만 — 목록·메시지 작성 후 커밋. push·merge는 사람) |

> **핵심 규칙: 여러 문 입장, 한 문 퇴장.** 어떤 진입점이든 코드 변경은 반드시 `/sync`로 수렴한다(드리프트 방지). 커밋은 `/commit`이 준비 시 `drift-check`로 문서 동기화를 확인한다.

검증 명령·계약 형식은 `workflow.config.json`에 정의한다.

---

## 3. 참조 통제

### 항상 참조 (인덱스 상시, 본문은 선택 로드)
- `doc/ref/domains/` — 도메인 경계·맵 (신규 설계 전 필수 확인)
- `doc/ref/architecture/` — 아키텍처·기술 스택
- `doc/ref/patterns/` — 확정 패턴(layout·api·error·task) ← AI가 참조하는 정본
- `doc/ref/db-schema/` — DB DDL (index=테이블 목록, 본문 선택 로드)
- `doc/ref/glossary/` — 용어집

### 참조 금지 (자동 로드 안 함, 필요 시 `@`로 명시 주입)
- `doc/analysis/` — 일회성 분석·트러블슈팅
- `doc/design/{작업 중 아닌 타 도메인}/`

> `doc/summary/`·`doc/decisions/`는 참조 허용. Claude Code는 자동 RAG가 없으므로 참조는 항상 명시적(Read/Grep/Glob/`@` 또는 `explorer` 위임). "상시"는 로드가 아니라 인덱스만 — 큰 본문은 선택 로드.

---

## 4. 가드레일 (절대 금지)

- **운영 DB 직접 접속 금지** — `doc/ref/db-schema/`의 DDL만 참조. 실행은 사람이.
- **`git push`·`merge`·`reset --hard`·`clean -f`·force-push 금지** — Claude는 실행하지 않는다. push·merge는 사람이 외부 툴로.
- **민감 파일 커밋 금지** — `.env`, `*.key`, `*-prod.*` 등.
- **자동 커밋 금지** — 커밋은 사용자가 요청할 때 `/commit`으로만. `/sync` 등 다른 커맨드는 커밋하지 않는다.

{{프로젝트별 추가 가드레일}}

---

## 5. 코딩 스타일 (프로젝트 고유만)

- 네이밍: {{예: BE PascalCase 클래스+camelCase 메서드, FE PascalCase 컴포넌트+kebab-case 파일}}
- 폴더 구조: {{예: `kr.co.{회사}.{도메인}.controller/service/mapper`}}
- 테스트: {{예: BE JUnit 5, FE Vitest}}
- 커밋 메시지: {{예: `[#이슈] 동사로 시작 — 한 줄 요약`}}

---

## 6. 도구 정책 (프로젝트 고유만)

- **MCP**: {{예: DB MCP(읽기 전용 스키마 조회) + Git MCP만. 그 외 금지}}
- {{그 외 프로젝트 도구 정책}}
