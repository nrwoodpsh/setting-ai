# setting-ai — 범용 AI 개발 워크플로우 (`flow`)

Claude Code용 **범용 개발 워크플로우**다. 커맨드·에이전트·스킬·훅을 하나의 플러그인(`flow`)으로 배포하고(공용 기계), 프로젝트별 고유층(`CLAUDE.md`·`workflow.config.json`·`doc/`)은 각 프로젝트가 소유하는 **하이브리드** 구조.

> **상태: v0.1 — 내용 완성, 실행 검증 전.** 설계·문서는 성숙했고 완결 예시까지 갖췄으나, 아직 한 번도 설치·실행되지 않았다. 첫 실전 프로젝트가 사실상 파일럿이며, 초기엔 커맨드 네임스페이스(`/design` vs `/flow:design`)·훅 발화 등 런타임 항목을 실측으로 확정해야 한다.

---

## 설계 요약

- **그래프형 흐름**: 진입점을 상황별로 고른다 — `/analysis`·`/design`·`/troubleshoot`(진입) → `/builder`(실행) → `/sync`(수렴), `/review`(오버레이). **여러 문 입장, 한 문 퇴장.**
- **이중 게이트**: 자연어 설계는 사람이 검증, 계약(타입)은 기계가 검증(`contract-gate`, 스택 무관).
- **드리프트 방어**: 코드 변경은 반드시 `/sync`로 수렴 + `/commit`이 커밋 전 `drift-check`로 문서 동기화 확인(훅 아님 — 사람이 커밋 목록을 보는 것이 게이트).
- **컨텍스트 격리 에이전트만**: `explorer`(무거운 읽기)·`verifier`(독립 검증). 직군(디자이너·DBA) 에이전트는 두지 않는다 — 능력은 툴·레퍼런스에서 온다.
- **3층 패턴**: 원칙(guide) → 스택 프리셋(presets, 씨앗) → 프로젝트 확정(doc/ref/patterns, AI가 참조하는 정본).
- **커밋 정책**: Claude는 `/commit` 요청 시에만 커밋(목록·메시지 작성 후). **push·merge는 사람이 외부 툴로.**

자세히: 사상 [`guide/workflow-principles.md`](guide/workflow-principles.md) · 구조·데이터 흐름 [`guide/doc-structure.md`](guide/doc-structure.md) · 사용법 [`guide/getting-started.md`](guide/getting-started.md) · 완결 예시 [`examples/`](examples/).

---

## 구성 요소

### 커맨드 (8)
| 커맨드 | 역할 |
|:---|:---|
| `/setup` | 프로젝트 스캔해 `CLAUDE.md`·`workflow.config`·`doc/ref/domains` 초안 채움 (추론은 자동, 결정은 질문) |
| `/analysis` | 레거시·기획서를 읽어 넓은 지도 작성. durable 발견은 `ref/`로 승격 |
| `/design` | 신규 기능 설계 → `task-*.md` + 계약. 구현 코드 금지. 중요한 결정은 ADR 기록 |
| `/troubleshoot` | 터진 버그의 재현·근본원인·수정안. 근본원인 확정 전 수정 금지 |
| `/builder` | 설계대로 구현. TDD·계약게이트·셀프검증. 막히면 리포트 후 승인 대기 |
| `/review` | 정합성·보안·아키텍처 정적 점검(리포트만). 설계 없으면 품질·보안으로 축소 |
| `/sync` | 코드↔문서 정합 회복. 의도된 변경만 반영, 미설명 불일치는 리포트. 커밋 안 함 |
| `/commit` | 요청 시에만 — 목록+드리프트확인+메시지+커밋. push·merge 안 함 |

### 에이전트 (2, 컨텍스트 격리 전용)
| 에이전트 | 역할 | 도구 |
|:---|:---|:---|
| `explorer` | 무거운 코드베이스 탐색 → 결론만 반환 | `Read, Grep, Glob` (순수 읽기) |
| `verifier` | 독립·회의적 검증(반증 우선) | `Read, Grep, Glob, Bash` (읽기+실행) |

### 스킬 (6)
`default-reference`(커맨드별 참조 매핑·토큰 통제) · `contract-gate`(계약 검증 게이트, 스택무관) · `drift-check`(커밋 준비 시 드리프트 확인) · `tdd-verify`(테스트 실행으로 환각 방지) · `code-audit`(스택무관 감사 체크리스트) · `doc-template`(task 문서 골격)

### 훅 (2)
- `SessionStart` → `check-prereqs.sh`: JSON 파서(`node`·`python3`·`perl` 중 하나) 점검, 없으면 1회 경고
- `PostToolUse(Edit|Write)` → `contract-gate.sh`: 계약 파일 편집 시 자동 검증

---

## 저장소 구조

```
setting-ai/
├── .claude-plugin/marketplace.json      # 마켓플레이스 카탈로그 (name: setting-ai)
├── plugins/flow/                        # ── 공용 기계 (플러그인, name: flow) ──
│   ├── .claude-plugin/plugin.json
│   ├── commands/   (setup·analysis·design·troubleshoot·builder·review·sync·commit)
│   ├── agents/     (explorer·verifier)
│   ├── skills/     (default-reference·contract-gate·drift-check·tdd-verify·code-audit·doc-template)
│   └── hooks/      (hooks.json + scripts: check-prereqs·contract-gate)
├── project-template/                    # ── 프로젝트 고유층 (복사 씨앗) ──
│   ├── CLAUDE.md · workflow.config.json
│   └── doc/  ref/{architecture,patterns,db-schema,domains,glossary}
│             design · decisions · summary · analysis
├── presets/house-style/                 # 스택 프리셋 (② 씨앗, 첫 실전에서 채움)
├── guide/                               # ① 원칙층 문서 (principles·doc-structure·getting-started)
└── examples/                            # 완결 예시 (회원 로그인 한 바퀴)
```

---

## 사용 방법 (처음부터 끝까지)

### 사전 준비
- Claude Code 설치
- **setting-ai를 로컬에 clone할 필요 없음** — 아래 설치가 git(마켓플레이스)에서 가져온다.
- **추가 설치 불필요** — 훅의 JSON 파싱은 프로젝트가 이미 가진 런타임(`node` → `python3` → `perl` 순)으로. (셋 다 없는 드문 경우만 계약 게이트 비활성화 + 세션 시작 시 경고.)

### 1단계 — 플러그인 설치 *(git에서, 프로젝트당 한 번)*
새 프로젝트 폴더에서 Claude Code를 실행하고:
```
/plugin marketplace add nrwoodpsh/setting-ai       # git repo가 곧 마켓플레이스
/plugin install flow@setting-ai --scope project    # --scope project = 팀 공유(.claude/settings.json에 기록·커밋)
```
**결과**: `/design`·`/builder`·`/sync`·`/commit` 등이 뜬다. `marketplace add`가 setting-ai 전체를 `~/.claude/plugins/marketplaces/setting-ai/`에 받아둔다(**project-template도 여기 포함** → 로컬 복사 불필요).
> - `/design`으로 안 뜨면 `/flow:design`처럼 플러그인명이 붙는 것 — 그대로 쓰면 된다.
> - setting-ai를 **직접 고칠 때(플러그인 개발)만** 로컬 경로로: `/plugin marketplace add /path/to/setting-ai` → 수정 후 `/reload-plugins`.

### 2단계 — `/setup` *(골격 생성 + 채우기, 한 번)*
```
/setup
```
**결과** — 별도 `cp` 없이 `/setup`이 다 한다:
- `doc/` 구조·`CLAUDE.md`·`workflow.config.json`을 **만든다** (마켓플레이스 클론의 `project-template/`에서 복사하거나 새로 생성).
- 프로젝트를 스캔해 스택·네이밍·도메인 후보를 **채운다**.
- 가드레일·도구정책 같은 **결정 항목만 질문**한다.

### 3단계 — 첫 기능 개발 *(반복)*
예) 회원 로그인:
```
/design
로그인 API랑 화면 만들어줘. AC: 성공시 토큰 발급 / 실패시 U001 / 응답 200ms 이내
```
→ `doc/design/user/login/`에 `task-*.md` + 계약 생성.
```
/builder     # 설계대로 구현 (테스트·계약 게이트 자동)
/sync        # 코드↔문서 정합 + summary 생성 (커밋은 안 함)
/commit      # 커밋하고 싶을 때만 — 목록·메시지 작성 후 커밋
```
→ **push·merge는 당신이 Sourcetree 등 외부 툴로.**

완성된 예시는 [`examples/`](examples/)에서 실제 산출물을 볼 수 있다.

### 매일 쓰는 치트시트
| 하고 싶은 것 | 커맨드 |
|:---|:---|
| 새 기능 만들기 | `/design` → `/builder` → `/sync` |
| 버그·장애 잡기 | `/troubleshoot` → `/builder` → `/sync` |
| 레거시·요구 파악 | `/analysis` |
| 코드 품질·보안 점검 | `/review` (아무 때나) |
| 커밋 | `/commit` (요청 시) |

> **house-style 프리셋**이 준비됐으면 `/setup` 후 마켓플레이스 클론(`~/.claude/plugins/marketplaces/setting-ai/presets/house-style/patterns/`)을 프로젝트의 `doc/ref/patterns/`로 복사해 패턴 씨앗을 심는다.

---

## 데이터 흐름 (요약)

```
진입: /analysis · /design · /troubleshoot     [입력: doc/ref/ = 사람이 채운 정본 참조]
  → 실행: /builder                            [출력: 소스 코드 + task History]
  → 수렴: /sync                               [출력: 설계문서 갱신 + summary. 커밋 안 함]
  → 커밋: /commit (요청 시)                    [드리프트 확인 후 코드+문서 한 커밋]
  → 사람: push · merge (외부 툴)
/review = 아무 단계 뒤에나 오버레이
```
전체 지도·폴더 역할은 [`guide/doc-structure.md`](guide/doc-structure.md).

---

## 설정 (`workflow.config.json`)

| 키 | 의미 |
|:---|:---|
| `contract.file` | 계약 파일 패턴 (예: `api-contract.ts`) |
| `contract.gate` | 계약 검증 명령. `{file}` 자리표시자 지원 (예: `tsc --noEmit --strict {file}`) |
| `test.command` | 테스트 명령 (예: `npm test` / `./gradlew test` / `pytest`) |
| `build.command` | 빌드 명령 |
| `drift.enabled` / `drift.sourceGlobs` / `drift.ignore` | `/commit` 드리프트 확인 on/off, 소스로 간주할 경로, 제외 패턴 |
| `language` | 산출물 언어 (기본 `korean`) |

> 훅의 JSON 파싱은 프로젝트 런타임(`node`→`python3`→`perl`)으로 한다 — 별도 설치 불필요. **TS 검증 자체는 `contract.gate`(tsc 등)가 하며, 이 파서는 훅 입력(JSON)을 읽는 배관일 뿐이다.**

---

## 이 repo(워크플로우 자체) 개발

```
/plugin marketplace add /path/to/setting-ai   # 로컬 마켓플레이스 등록
/plugin install flow@setting-ai
# 커맨드·스킬 수정 후:
/reload-plugins
```
팀 전파: repo push 후 각자 `/plugin marketplace update setting-ai`.

---

## 로드맵

- [ ] **파일럿(실측)**: 커맨드 네임스페이스, 훅 payload 필드(`.tool_input.*`), 한 바퀴 실행 확인
- [ ] **house-style 프리셋**: 첫 실전 프로젝트에서 패턴 역추출
- [ ] 프로젝트 `.git/hooks` 연동(선택): 외부 툴 커밋까지 드리프트/가드 커버
