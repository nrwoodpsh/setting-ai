# 폴더 구조와 데이터 흐름 (확정판)

이 워크플로우를 익히는 핵심 지도. **Part 1 = 폴더 구조와 역할**, **Part 2 = 작업 순서(데이터 흐름)**.

---

## Part 1. 폴더 구조와 역할

### 두 구역

```
[공용 기계 — 설치해서 씀, 프로젝트에 복사 안 됨]
flow 플러그인 = /커맨드 · 에이전트 · 스킬 · 훅

[프로젝트 고유층 — 각 프로젝트가 소유]
my-project/
├── CLAUDE.md               ← 프로젝트 정체성·가드레일 (매턴 자동 로드, 작게!)
├── workflow.config.json    ← 스택 주입 (계약 게이트·테스트 명령)
└── doc/                    ← 모든 참조·산출물이 여기
```

### `doc/` — 폴더별 역할 + 참조 통제

"참조 통제" = AI가 이 폴더를 언제 읽는가. **항상**(늘 읽음) · **작업 중만**(그 작업에 관련될 때만) · **금지**(사용자가 `@`로 직접 넣어야 읽음).

| 폴더 | 입력/출력 | 역할 | 참조 통제 | 관리 |
|:---|:---:|:---|:---:|:---:|
| `ref/architecture/` | 입력 | 아키텍처·기술스택·크로스커팅 제약(UTC·금액단위 등) | 항상 (인덱스만) | 사람 |
| `ref/patterns/` | 입력 | layout·error·api·task **확정 패턴** — AI가 코드 생성 시 참조하는 정본 | 항상 | 사람 |
| `ref/db-schema/` | 입력 | DDL (index=테이블 목록, 본문은 선택 로드) | 항상 (인덱스만) | 사람 |
| `ref/domains/` | 입력 | 도메인 경계·맵 (뭐가 있는지, 중복 생성 방지) | 항상 | 사람 |
| `ref/glossary/` | 입력 | 용어집 (용어 오용 방지) | 항상 | 사람 |
| `design/{domain}/{phase}/` | 출력 | `task-*.md`(자연어 설계) + 계약(타입) | 작업 중 도메인만 | AI |
| `decisions/` | 출력·입력 | ADR — 왜 이렇게 했나 | 허용 | AI+사람 |
| `summary/` | 출력 | 작업 이력 요약 | 허용 | AI |
| `analysis/` | 출력 | 일회성 분석·트러블슈팅·spike 결론 | 금지 | AI |
| `spike/` *(doc 밖, repo 루트)* | 출력 | 버릴 실험 코드(`/spike`) — 검증 증거. **유지보수·drift·계약 게이트 대상 아님** | 금지 | AI |

### 핵심 원리 3가지

1. **입력(ref) = 사람이 관리, 출력(design·summary·analysis) = AI가 생성.**
2. **"상시 참조"는 로드가 아니라 *인덱스만* 상시.** 큰 본문(DDL 전체 등)은 필요할 때 `@` 또는 `explorer`로 선택 로드 (트래픽 절약). 매턴 자동 로드는 `CLAUDE.md` 하나뿐.
3. **`logs/` 없음.** 검증 결과는 `task-*.md`의 History에 남는다.

### 파일 네이밍 규약 — 숫자로 시작, README는 맨 아래

**불변식: `doc/` 아래 모든 문서 파일은 숫자로 시작한다. `README.md`만 숫자가 없어 폴더에서 항상 맨 아래로 정렬된다.** (정렬 규칙 `숫자 < 대문자 < 소문자` 를 이용 — README 이름은 그대로 둬 GitHub 자동 렌더도 안 깨진다.) 숫자 형태는 폴더 성격에 맞춘다:

| 폴더 | 형식 | 예 | 숫자 의미 |
|:---|:---|:---|:---|
| `ref/domains`·`ref/glossary`·`ref/architecture`·`ref/db-schema` | `{NN}-{name}.md` | `01-user.md` | 2자리 순번 (생성 순 append) |
| `decisions/` | `{NNNN}-{name}.md` | `0001-jwt-over-session.md` | ADR 4자리 순번 |
| `analysis`·`summary`·`design/{d}/{p}/` | `{YYYYMMDD}-{종류}-{name}.md` | `20260714-task-login.md` | 날짜 앞 (시간순, 카운터 불필요) |

예외: **저장소 루트의 프로젝트 설명 `README.md`**, **`ref/patterns/` 하위 폴더**(`api-contract/`·`task-doc/` 등 — 경로로 참조돼 의미 이름 유지), **계약 파일**(`api-contract.ts` 등 — `workflow.config`가 이름 고정).

### 헷갈리기 쉬운 구분

| | `ref/domains/` | `design/{domain}/` |
|:---|:---|:---|
| 무엇 | 도메인 **경계·정의·맵** (안정적) | 그 도메인의 **task별 설계 산출물** (계속 늘어남) |
| 누가 | 사람이 관리 | AI가 생성 |
| 예 | "user는 인증·프로필 담당, order와 연동" | `design/user/login/20260714-task-login.md` |

---

## Part 2. 작업 순서 (데이터 흐름)

### 신규 기능 한 바퀴 — 각 단계가 읽고/쓰는 것

커맨드는 `/flow:<이름>`으로 호출.

| # | 단계 | 읽음 (입력) | 씀 (출력) |
|:--:|:---|:---|:---|
| 0 | `/setup` *(프로젝트 1회)* | 스택 지표·(선택)원형 repo | `CLAUDE.md`·`workflow.config`·`doc/` 골격·`.claude/settings.json` |
| 0.5 | `/spike` *(신규 프로젝트 앞단, 선택)* | 가설·데이터·`ref/architecture` | `spike/`(버릴 코드)·`analysis/{date}-spike-*.md`·(승격) `decisions/`·`ref/domains`·`ref/glossary` |
| 1 | `/analysis` *(선택)* | `ref/`, 레거시 코드 | `analysis/` |
| 2 | `/design` | `CLAUDE.md`, `ref/domains`, `ref/architecture`, `ref/patterns` | `design/{d}/{p}/{date}-task-*.md` + 계약 |
| 3 | `/builder` | 대상 task+계약, `workflow.config` | **소스 코드**, task의 History |
| 4 | `/review` *(선택)* | 계약, task, 변경 소스 | (리포트만 — 파일 안 씀) |
| 5 | `/sync` | `git diff`, 대상 task·계약·summary | `design/` 갱신, `summary/` 생성 |
| 6 | `/commit` *(요청 시)* | `git status/diff`, design·summary | **git 커밋** |
| 7 | **사람** | — | **push · merge** (외부 툴) |
| 8 | `/publish` *(선택)* | design·summary·decisions | **Notion 페이지**(외부 발행) |

> `decisions/`(ADR)는 중요한 결정 시 2·3·5단계에서 기록(상시 아님). **git 훅**(config `drift.mode`)이 커밋/푸시 시 드리프트(코드는 바뀌었는데 문서가 안 따라간 상태)를 감지(warn/block).
>
> **선택 오버레이 `/run`**: 2→3→5단계(design→builder→sync)를 매번 손으로 호출하는 대신 자동으로 잇는다. 단 규율형 L4를 지켜 **design 청사진 컨펌·국면 실패·commit 직전**에서 멈춘다 — 6단계(commit)와 7단계(push)는 그대로 사람 몫. 자동화하는 건 국면 사이의 *호출*이지 *게이트*가 아니다.

### SSOT 두 산출물의 생애 (가장 중요한 흐름)

> SSOT(Single Source of Truth) = 하나의 사실을 담는 단 하나의 정본. 아래 두 산출물이 그 정본이다.

```
task-*.md (자연어 설계)
  /design 생성 ──▶ /builder 읽고 구현 ──▶ /sync 갱신([완료]·History)

계약 (api-contract, 타입)
  /design 생성 ──▶ /builder 가 import(불일치 차단) ──▶ /sync 가 실제 구현 기준 갱신
      └──────────── contract-gate 훅이 편집될 때마다 항상 검증 ────────────┘
```

### 한눈에 보는 전체 흐름

```
   /setup  → 고유층·골격 생성 (+선택: 아키텍처 원형)      [프로젝트 1회]
       │
       ├─ (신규 프로젝트 앞단) 알파=ADR 1장 → /spike(버릴 코드로 핵심 검증)
       │        └─ 지식만 승격: decisions/(ADR) · ref/architecture/ · ref/domains/
       ▼   [입력: ref/ = 사람이 채운 정본]
                  │ (참조)
   ┌──────────────┼───────────────┐
 /analysis    /design         /troubleshoot     ← 진입 (여러 문)
   │              │                │
   └──────▶  /builder  ◀───────────┘            ← 실행 (소스 생성)
                  │
              /sync                              ← 수렴 (문서 동기화, 한 문)
                  │
              /commit  (요청 시)                 ← 커밋 (git 훅 drift.mode 감지)
                  │
             사람: push/merge                    ← 외부 툴
                  │
              /publish  (선택)                   ← Notion 등 발행

   /review = 아무 단계 뒤에나 끼우는 오버레이   ·   커맨드는 /flow:<이름>
   /run   = design→builder→sync 자동 연결 오버레이(선택) — commit 직전·실패 시 정지
```

### 검증은 3층 (헷갈리지 말 것)

| 검증 | 무엇을 | 방법 | 레벨 |
|:---|:---|:---|:---|
| `contract-gate` | 계약 파일이 컴파일/타입 통과하나 | tsc 등 실행 (훅) | 문법·타입 |
| `tdd-verify` | 코드가 실제로 동작하나 | 테스트 실행 → Exit code | 동작 |
| `/review` | 변경 코드가 설계·계약·보안·아키텍처 기준에 맞나 | AI 정적 점검 → 리포트 | 판단 |
