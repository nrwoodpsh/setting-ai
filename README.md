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
- `SessionStart` → `check-prereqs.sh`: 전제 도구(jq) 점검, 없으면 1회 경고
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

## 새 프로젝트에서 사용하기

```bash
# 1) 프로젝트 고유층 복사
cp -r project-template/. /path/to/my-project/

# 2) (준비됐으면) house-style 프리셋을 patterns 정본으로 복사
cp -r presets/house-style/patterns/. /path/to/my-project/doc/ref/patterns/
```

`my-project`에서 Claude Code 실행 후:

```
/plugin marketplace add nrwoodpsh/setting-ai     # 로컬: /plugin marketplace add /path/to/setting-ai
/plugin install flow@setting-ai --scope project  # 팀 공유(.claude/settings.json에 기록)
```

고유층 채우기 — **`/setup` 한 번이면 대부분 자동**:
```
/setup    # 프로젝트 스캔 → CLAUDE.md·workflow.config·domains 초안. 결정 항목만 확인
```
수동으로 할 경우: `workflow.config.json`의 `contract.gate`·`test.command`를 스택에 맞게, `doc/ref/patterns/`를 실제 코드에 맞게 조정.

> **커맨드 이름**: 플러그인 커맨드는 `/flow:design`처럼 네임스페이스가 붙을 수 있다. 충돌이 없으면 짧은 `/design`도 동작. (설치 후 실측으로 확정)

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

> 전제 도구: `jq` (훅이 사용). 없으면 `contract-gate`가 비활성화되고 SessionStart 훅이 경고한다.

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
