# setting-ai — 범용 AI 개발 워크플로우 (`flow`)

Claude Code용 **범용 개발 워크플로우**다. 커맨드·에이전트·스킬·훅을 하나의 플러그인(`flow`)으로 배포하고(공용 기계), 프로젝트별 고유층(`CLAUDE.md`·`workflow.config.json`·`doc/`)은 각 프로젝트가 소유하는 **하이브리드** 구조.

> **상태: v0.4 — 설치·발견·네임스페이스(`/flow:*`) 실측 확인됨.** 라이프사이클(원형→개발→발행)·자동화(drift 훅·버전관리)·디자인 테마·문서 골격 표준화·에피스테믹 기법(사각지대·인터뷰·수정가능성순·이탈로그)에 더해 **신규 프로젝트 앞단 검증(알파+`/spike`)**까지 갖췄다. 남은 실측: 실제 한 바퀴(`/flow:setup`→개발→`/flow:sync`→`/flow:publish`)·아키텍처 원형 clone·훅 발화 확인.

---

## 설계 요약

- **그래프형 흐름**: 진입점을 상황별로 고른다 — `/analysis`·`/design`·`/spike`·`/troubleshoot`(진입) → `/builder`(실행) → `/sync`(수렴), `/review`(오버레이). **여러 문 입장, 한 문 퇴장.**
- **이중 게이트**: 자연어 설계는 사람이 검증, 계약(타입)은 기계가 검증(`contract-gate`, 스택 무관).
- **드리프트 방어**: 코드 변경은 반드시 `/sync`로 수렴 + `/commit`이 커밋 전 `drift-check`로 문서 동기화 확인(훅 아님 — 사람이 커밋 목록을 보는 것이 게이트).
- **컨텍스트 격리 에이전트만**: `explorer`(무거운 읽기)·`verifier`(독립 검증). 직군(디자이너·DBA) 에이전트는 두지 않는다 — 능력은 툴·레퍼런스에서 온다.
- **3층 패턴**: 원칙(guide) → 스택 프리셋(presets, 씨앗) → 프로젝트 확정(doc/ref/patterns, AI가 참조하는 정본).
- **커밋 정책**: Claude는 `/commit` 요청 시에만 커밋(목록·메시지 작성 후). **push·merge는 사람이 외부 툴로.**

자세히: 사상 [`guide/workflow-principles.md`](guide/workflow-principles.md) · 구조·데이터 흐름 [`guide/doc-structure.md`](guide/doc-structure.md) · 사용법 [`guide/getting-started.md`](guide/getting-started.md) · 작성 표준 [`guide/authoring-standard.md`](guide/authoring-standard.md) · 쉬운 말 표준 [`guide/readability-standard.md`](guide/readability-standard.md) · 완결 예시 [`examples/`](examples/).

---

## 구성 요소

### 커맨드 (11) — 호출은 `/flow:<이름>` (예: `/flow:design`)

각 커맨드는 **하나의 국면**을 맡고, 그 국면이 곧 목적이다. **여러 문(진입)으로 들어와 한 문(`/sync`)으로 나간다.**

| 국면 | 커맨드 | 목적 — 왜 있나 (한 문장) | 산출물 |
|:--|:--|:--|:--|
| 부트스트랩 | `/setup` | 프로젝트에 워크플로우 고유층(골격)을 깔고 스택을 채운다 — 최초 1회 | `CLAUDE.md`·`config`·`doc/`·`.claude/settings.json` |
| 진입 | `/analysis` | 남의 코드·기획을 읽어 **넓은 지도**를 그린다 (수정 없이 이해만) | `analysis/` 지도 |
| 진입 | `/spike` | 미검증 핵심 알고리즘이 **되긴 되는지**를 버릴 코드로 확인 (앞단 검증) | `spike/`+결론 → ADR·`ref/` 승격 |
| 진입 | `/design` | 신규 기능의 **청사진**을 자연어 설계+계약으로 확정 (구현 전) | `task-*.md` + 계약 |
| 진입 | `/troubleshoot` | 터진 버그의 **근본원인**을 재현·규명 | 근본원인·수정안 |
| 실행 | `/builder` | 확정된 설계에 **충성해** 코드를 구현 (설계 임의 변경 금지) | 소스코드 + task History |
| 수렴 | `/sync` | 코드 변경을 문서에 반영해 **드리프트를 막는다** (유일 퇴장구) | 설계문서 갱신 + `summary/` |
| 오버레이 | `/review` | 변경 코드를 설계·보안·아키텍처 기준으로 **점검** (리포트만) | 점검 리포트 |
| 운영 | `/commit` | 변경을 **커밋** (드리프트 확인 후, 요청 시에만; push는 사람) | git 커밋 |
| 운영 | `/publish` | 완료 결과를 Notion/문서로 **발행** | 외부 페이지 |
| 운영 | `/theme` | 디자인 스펙을 프론트에 **입힘** (토큰+컴포넌트, 구조는 유지) | 스타일 적용 |

> **세부 기법(목적을 어떻게 달성하나)**: `/design`은 사각지대 패스(repo 이력의 함정 발굴)·인터뷰(모호함 1문1답)·수정가능성순 산출(결정+대안 먼저)·중요한 결정 ADR화를, `/builder`는 이탈 로그(계획 벗어난 지점 실시간 기록 → `/sync` 입력)·TDD·계약게이트·셀프검증을, `/setup`은 아키텍처 원형 복제(mono/MSA/eGov)·추천 도구(LSP/MCP) 제안을 갖는다. 커맨드별 상세는 각 `plugins/flow/commands/*.md`.

**한 줄 사용법** (인자는 대부분 선택 — 없이 실행하면 대화형/자동 식별. 전체 흐름·상세는 [`guide/getting-started.md`](guide/getting-started.md)):
```bash
/flow:setup list                                  # 원형 카탈로그 보기 → /flow:setup egov-msa-cc 로 시작
/flow:analysis 결제모듈 파악 REFERENCE @legacy/pay/  # 레거시·기획 넓게 읽어 지도화(ref/ 승격)
/flow:spike 매칭 알고리즘 p95<200ms 검증 REFERENCE @data/sample.csv  # 앞단: 버릴 코드로 가설 검증→ADR·ref 승격
/flow:design 로그인 API REFERENCE @doc/ref/db-schema/user.sql AC: 성공→토큰 / 실패→U001 / 200ms
/flow:troubleshoot 로그인 후 401 간헐 REFERENCE @logs/error.log   # 재현·근본원인·수정안
/flow:builder                                     # 최근 설계 자동 식별해 구현 (또는 /flow:builder user/login)
/flow:review                                      # git diff 대상 정적 점검 (또는 경로 지정)
/flow:sync                                         # 코드↔문서 정합 회복 (커밋은 안 함)
/flow:commit                                       # 변경목록+메시지 작성 후 커밋 (push·merge는 사람이)
/flow:publish                                      # 완료 결과를 Notion에 발행 (사전에 Notion MCP 연결)
/flow:theme @doc/ref/theme/DESIGN-apple.md         # 디자인 토큰+컴포넌트 룩 적용 (구조는 유지)
```

### 에이전트 (2, 컨텍스트 격리 전용)
| 에이전트 | 역할 | 도구 |
|:---|:---|:---|
| `explorer` | 무거운 코드베이스 탐색 → 결론만 반환 | `Read, Grep, Glob` (순수 읽기) |
| `verifier` | 독립·회의적 검증(반증 우선) | `Read, Grep, Glob, Bash` (읽기+실행) |

### 스킬 (8)
`default-reference`(커맨드별 참조 매핑·토큰 통제) · `contract-gate`(계약 검증 게이트, 스택무관) · `drift-check`(커밋 준비 시 드리프트 확인) · `tdd-verify`(테스트 실행으로 환각 방지) · `code-audit`(스택무관 감사 체크리스트) · `doc-template`(task 문서 섹션 골격) · `plain-writing`(자연어 문서 쉬운 말 규칙) · `impact-analysis`(기존 로직 수정 전 회귀 표면 분석)

### 훅
**플러그인 훅 (2)** — Claude 도구 이벤트에 반응:
- `SessionStart` → `check-prereqs.sh`: JSON 파서(`node`·`python3`·`perl` 중 하나) 점검, 없으면 1회 경고
- `PostToolUse(Edit|Write)` → `contract-gate.sh`: 계약 파일 편집 시 자동 검증

**git 훅 (별개)** — `automation/git-hooks/drift-hook.sh`: 커밋/푸시 시 문서-코드 드리프트 감지(`drift.mode`). Sourcetree 등 Claude 밖 커밋까지 커버. `/flow:setup`이 설치 (아래 "🛡️ 드리프트 훅" 참고).

---

## 저장소 구조

크게 **3덩어리**로 나뉜다: **① 공용 기계**(`plugins/flow/` — 설치해서 씀) · **② 프로젝트 씨앗**(`project-template/`·`presets/` — 프로젝트로 복사·생성) · **③ 문서·예시**(`guide/`·`examples/`).

```
setting-ai/
│
├── .claude-plugin/
│   └── marketplace.json          # 이 repo를 "마켓플레이스"로 만드는 카탈로그 (name: setting-ai → 설치 시 @setting-ai)
│
├── plugins/flow/                 # ══ ① 공용 기계 (플러그인) — 설치되면 ~/.claude/plugins/ 에 감. 프로젝트엔 복사 안 됨 ══
│   ├── .claude-plugin/
│   │   └── plugin.json           #   플러그인 신분증 (name: flow → 커맨드가 /flow: 접두사로 뜸)
│   ├── commands/                 #   슬래시 커맨드 = 국면별 진입점·실행·수렴
│   │   ├── setup.md              #     /flow:setup       — 프로젝트 골격 생성 + 스택 스캔해 채움 (최초 1회)
│   │   ├── analysis.md           #     /flow:analysis    — 레거시·요구 파악 (넓은 지도)
│   │   ├── spike.md              #     /flow:spike       — 앞단 검증: 버릴 코드로 핵심 알고리즘 확인 (지식만 승격)
│   │   ├── design.md             #     /flow:design      — 신규 설계 = task + 계약 (구현 코드 금지)
│   │   ├── troubleshoot.md       #     /flow:troubleshoot— 버그 진단 (재현→근본원인→수정안)
│   │   ├── builder.md            #     /flow:builder     — 설계대로 구현 (TDD·계약 게이트)
│   │   ├── review.md             #     /flow:review      — 정합성·보안·아키텍처 점검 (리포트만)
│   │   ├── sync.md               #     /flow:sync        — 코드↔문서 정합 회복 + summary (커밋 안 함)
│   │   ├── commit.md             #     /flow:commit      — 요청 시 목록·메시지 작성 후 커밋 (push는 사람)
│   │   ├── publish.md            #     /flow:publish     — 결과를 Notion/문서로 발행 (Notion MCP)
│   │   └── theme.md              #     /flow:theme       — 디자인 스펙 적용(토큰+컴포넌트, getdesign.md)
│   ├── agents/                   #   컨텍스트 격리 서브에이전트 (직군 아님)
│   │   ├── explorer.md           #     무거운 탐색 → 결론만 반환 (읽기 전용: Read/Grep/Glob)
│   │   └── verifier.md           #     독립·회의적 검증 (반증 우선)
│   ├── skills/                   #   재사용 절차·게이트 (커맨드가 불러 씀)
│   │   ├── default-reference/    #     커맨드별 참조 매핑 + 토큰 통제
│   │   ├── contract-gate/        #     계약 검증 게이트 (스택무관, config로 명령 주입)
│   │   ├── drift-check/          #     커밋 준비 시 "코드만 바뀌고 문서 안 바뀜" 확인
│   │   ├── tdd-verify/           #     테스트 실제 실행 → Exit code로 환각 방지
│   │   ├── code-audit/           #     스택무관 코드 감사 체크리스트
│   │   └── doc-template/         #     task-*.md 표준 골격
│   └── hooks/
│       ├── hooks.json            #   훅 정의 (SessionStart, PostToolUse)
│       └── scripts/
│           ├── check-prereqs.sh  #     세션 시작 시 JSON 파서(node/python3/perl) 점검·경고
│           └── contract-gate.sh  #     계약 파일 편집 시 자동 검증 (실패 시 exit 2로 차단)
│
├── project-template/             # ══ ② 프로젝트 씨앗 — /flow:setup 이 이걸 프로젝트로 복사·생성 ══
│   ├── .claude/
│   │   └── settings.json         #   팀 자동 온보딩 (마켓 등록 + flow 활성화, 커밋됨 → 팀원 clone 시 자동)
│   ├── .gitignore                #   settings.json만 추적, 개인설정(settings.local)·산출물 무시
│   ├── CLAUDE.md                 #   프로젝트 정체성·가드레일·참조통제 (매턴 자동 로드 → 작게 유지)
│   ├── workflow.config.json      #   스택 주입 (계약 게이트·빌드·테스트 명령·언어)
│   └── doc/
│       ├── ref/                  #   [입력] 참조 정본 (사람이 관리, 상시 참조 = 인덱스만)
│       │   ├── architecture/     #     아키텍처·기술 스택
│       │   ├── patterns/         #     layout·error·api-contract·task 확정 패턴 (AI가 참조하는 정본)
│       │   ├── db-schema/        #     DB DDL (index=테이블 목록)
│       │   ├── domains/          #     도메인 경계·맵 (중복 도메인 방지)
│       │   └── glossary/         #     용어집 (용어 오용 방지)
│       ├── design/               #   [출력] {domain}/{phase}/ 아래 task-*.md + 계약
│       ├── decisions/            #   [출력] ADR — 왜 이렇게 했나 (design·builder·sync가 기록)
│       ├── summary/              #   [출력] 작업 이력 요약 (sync가 생성)
│       └── analysis/             #   [출력] 일회성 분석·트러블슈팅 (참조 금지)
│
├── presets/                      # ══ ② 씨앗 ══
│   ├── house-style/              #   스택 프리셋 (첫 실전에서 패턴 역추출해 채움)
│   ├── architectures/            #   프로젝트 원형 카탈로그 (mono/MSA/eGov → 검증된 repo 복제)
│   └── designs/                  #   디자인 스펙 소스 (getdesign.md / 로컬 md → /flow:theme)
│
├── guide/                        # ══ ③ 방법론 문서 ══
│   ├── workflow-principles.md    #   원칙·사상 (왜 이렇게 설계했나 — 그래프 흐름·드리프트·격리)
│   ├── doc-structure.md          #   폴더 구조 + 데이터 흐름 (확정 지도)
│   ├── getting-started.md        #   설치·사용 상세 walkthrough
│   ├── authoring-standard.md     #   커맨드·스킬 문서 골격 표준 ("템플릿의 템플릿")
│   ├── readability-standard.md   #   쉬운 말 표준 (문장 가독성 — plain-writing 스킬의 정본)
│   └── recommended-tools.md      #   추천 LSP·MCP (스택별, /setup이 제안)
│
├── examples/                     # ══ ③ 완결 예시 — 회원 로그인 한 바퀴 + 결재선 /spike 한 바퀴 ══
│   ├── CLAUDE.md · workflow.config.json      #   채워진 예
│   ├── spike/approval-routing/               #   /spike 버릴 코드 (throwaway 실험 — drift·게이트 제외)
│   └── doc/{ref/{domains,architecture}, design, decisions, summary, analysis}   #   task·계약(tsc통과)·ADR·요약·spike결론
│
├── automation/                   # ══ 헤드리스·이벤트 자동화 (플러그인과 별도 층) ══
│   ├── git-hooks/drift-hook.sh   #   drift 체크. config의 drift.mode로 warn(기본)/block/autosync/off
│   └── README.md                 #   git 훅 설치 + CI/스케줄(헤드리스 flow 호출) 안내
│
└── README.md                     # 이 문서
```

> **읽는 순서 추천**: 이 README → `guide/doc-structure.md`(구조·흐름) → `examples/`(실물) → `guide/workflow-principles.md`(왜).

---

## 사용 방법

> 사전 준비: **Claude Code만 설치**돼 있으면 된다. setting-ai를 로컬에 clone할 필요 없고(설치가 git에서 가져옴), jq 등 추가 도구도 불필요(훅은 프로젝트의 `node`/`python3`/`perl`로 JSON 파싱).

### 무엇이 어디에 사는가 (실제 경로)

```
[중앙 — 설치되면 여기. 프로젝트에 복사 안 됨]
~/.claude/plugins/marketplaces/setting-ai/
   ├── plugins/flow/   commands · agents · skills · hooks   ← 공용 기계 (한 벌을 모든 프로젝트가 공유)
   └── project-template · presets · guide · examples        ← marketplace add로 함께 받아짐

[프로젝트 — 고유층만]
my-project/
   ├── .claude/settings.json                 ← 마켓+flow 활성화 기록 (커밋 → 팀 자동 온보딩)
   └── CLAUDE.md · workflow.config.json · doc/   ← /flow:setup 이 생성
```
> 설치해도 커맨드·에이전트 파일은 **프로젝트에 안 생긴다** — 중앙에 있고 프로젝트가 가져다 쓴다. 커맨드는 `/flow:design`처럼 **`/flow:` 접두사**로 뜬다.

## 사용 시나리오

> 네 갈래 — **① 설치**(머신당 1회) → **② 새 프로젝트 시작**(무에서) · **③ 팀원 공유**(배포·합류) · **④ 기존 프로젝트 진행**(이미 도는 코드). ②·③·④는 병렬이라, 지금 상황에 맞는 것만 보면 된다.

### ① flow 설치 *(이 머신에 처음, 1회만)*
```
# 아무 프로젝트 폴더에서 Claude Code 실행:
/plugin marketplace add nrwoodpsh/setting-ai   # git repo = 마켓플레이스
/plugin install flow@setting-ai                # 스코프 선택 → user(내 모든 프로젝트, 권장) 또는 project(이 repo 팀공유)
/reload-plugins                                # 적용
```
→ 이후 커맨드가 `/flow:design`처럼 뜬다. **머신당 한 번**이면 된다(user scope인 경우).

**설치 스코프 3종** (install 때 선택 — "누가 쓰냐"만 정한다. 플러그인 파일은 어느 스코프든 항상 중앙 `~/.claude/plugins/...`):

| 선택 | 활성화 기록 위치 | 쓸 수 있는 사람 | git 공유 |
|:---|:---|:---|:---:|
| **user** *(개인·전 프로젝트)* | `~/.claude/settings.json` | 나, 내 **모든 프로젝트** | ✗ |
| **project** *(팀 배포용)* | `<프로젝트>/.claude/settings.json` | 이 repo의 **누구나** | ✓ 커밋됨 |
| **local** | `<프로젝트>/.claude/settings.local.json` | **나만**, 이 repo | ✗ gitignore |

---

### ② 새 프로젝트 시작 *(무에서 — greenfield)*

빈 폴더에서 시작. **앞단에서 리스크를 태우고(알파·`/spike`) 골격을 세운 뒤, 도메인별 개발 루프로 넘어간다.**

**2-1. 골격 생성 — `/flow:setup`**
```
/flow:setup list          # ← 뭘 고를 수 있는지 원형 카탈로그부터 (아무것도 안 만듦)
/flow:setup               # 대화형 (빈 프로젝트면 원형 메뉴)
/flow:setup egov-msa-cc   # 원형 키를 알면 바로 지정
/flow:setup https://github.com/우리회사/스타터   # 사내/개인 스타터를 커스텀 원형으로
```
**인자**: `list`(목록만) · **원형 키** · **repo URL**(커스텀) · 비움(대화형). 원형 키 9종:
`egov-msa-cc`⭐ · `egov-msa` · `egov-backend` · `egov-homepage` · `egov-enterprise` · `egov-portal` · `spring-monolith` · `py-msa-ai`(Python MSA+LLM) · `custom`(URL) · `none`. (상세: `presets/architectures/README.md`)

`/flow:setup`이 순서대로 실행한다 (추론은 자동, 결정만 질문):
1. **골격 생성** — `CLAUDE.md`·`config`·`doc/`·`.claude/settings.json`
2. **스택 스캔** — 빌드·테스트·계약 게이트 명령 추론
3. **아키텍처 원형** — 빈 프로젝트면 clone (원본 `.git` 제거, LICENSE 유지)
4. **추천 도구** — LSP·MCP 제안 + **drift 훅** 설치
5. **질문** — 결정 항목만 (가드레일·도구정책·도메인 경계)

**2-2. (핵심 알고리즘이 불확실하면) 알파 → `/flow:spike`** — "이 핵심 알고리즘·기술이 **되긴 되는지**"부터 모르면, 바로 `/flow:design`으로 가지 말고 앞에서 태운다:
```
# 1) 알파 = ADR 1장 (커맨드 아님) — 목표·핵심 가설·성공 기준을 doc/decisions/0001-*.md 에 못박는다
# 2) /spike 로 그 가설만 버릴 코드로 빠르게 검증:
/flow:spike 임베딩 매칭이 10만 건 p95<200ms REFERENCE @data/history.csv  # 기준: 넘으면 대안 재검토
```
→ `spike/`에 실험 코드(버릴 것) · `doc/analysis/spike-*.md`에 결론 · **판정·핵심 결정은 ADR·`doc/ref/architecture/`로 승격**. 검증되면 spike 코드를 쓰지 말고 **ADR을 입고 `/flow:design → builder`로 재설계**한다.
> **왜 앞단이 별개인가**: 불확실성이 지배하면 계약을 아직 모르고 AC를 못 정한다 → `spike/`는 drift·계약 게이트 대상이 아니다(**학습 모드**). design 이후가 계약·AC·drift 풀가동(**자산 모드**). 실물 예시: [`examples/spike/approval-routing/`](examples/spike/approval-routing/) · 상세: [`guide/getting-started.md`](guide/getting-started.md) §4.

**2-3. (프론트가 있으면) 디자인 입히기 — `/flow:theme`**
```
/flow:theme @doc/ref/theme/DESIGN-apple.md   # ① 권장: getdesign.md의 DESIGN.md를 doc/ref/theme/에 두고 지정
/flow:theme                                   # ② 편의: 온라인 목록에서 선택(웹변환이라 토큰 부정확 가능 → 검토)
```
→ **적용**: 토큰(색·타이포·간격·radius)+컴포넌트 룩(버튼·카드·인풋·네비). **유지**: 화면 배치·IA. 스킨만 갈고 구조는 그대로 — 전체 재설계 아님.

**2-4. 첫 기능 개발 루프** → `design → builder → sync → commit` (아래 **④의 개발 루프**와 동일).

> **전체 순서**: `① 설치 → /flow:setup(+원형) → (핵심 불확실 시) 알파·/flow:spike → /flow:theme → /flow:design→builder→sync→commit → /flow:publish`

---

### ③ 팀원 공유 *(배포 · 합류 · 업데이트)*

**오너 — 팀에 배포**: `/flow:setup`이 만든 `.claude/settings.json`을 포함해 **커밋 + push** (project 스코프여야 팀 공유됨).

**팀원 — 합류**:
```
git clone <프로젝트>     # 프로젝트 폴더에서 Claude Code 열기
```
→ 커밋된 `.claude/settings.json` 덕분에 **flow 활성화가 자동 제안**된다. **신뢰(trust) 프롬프트 승인**이면 끝 — `marketplace add`·`install` **직접 안 함**. (프롬프트 없으면 `/reload-plugins`.) → 바로 `/flow:design`.

**모두 — 워크플로우 업데이트 받기** *(오너가 setting-ai를 고쳐 push한 뒤에만 — 매일 아님)*:
```
/plugin marketplace update setting-ai
/reload-plugins
```

---

### ④ 기존 프로젝트 진행 *(이미 도는 코드 · 일상 개발 — brownfield)*

새 프로젝트와 달리 **알파·POC 단계가 없다.** 코드가 이미 있으니 **파악부터** 하고 개발 루프로 들어간다.

- **flow를 처음 얹는 레거시**라면: `/flow:setup`(진행중 프로젝트로 감지 → 원형 clone 안 함, 골격만) → **`/flow:analysis`로 지도부터** 그리고 durable 발견을 `ref/`로 승격.
- **이미 flow가 깔린 프로젝트**라면: 바로 개발 루프.

**개발 루프 (매일)**:
```
/flow:design    "로그인 API 만들어줘. AC: 성공시 토큰 / 실패시 U001 / 200ms 이내"   # 신규 기능
/flow:builder   # 설계대로 구현 (테스트·계약 게이트 자동)
/flow:sync      # 코드↔문서 정합 + summary (커밋은 안 함)
/flow:commit    # 커밋할 때만 — 목록·메시지 작성 후 커밋
```
- **버그·장애**는 `/flow:design` 대신 **`/flow:troubleshoot`**(재현→근본원인→수정안) → `/flow:builder` → `/flow:sync`.
- **`/flow:review`**는 아무 단계 뒤에나 끼우는 오버레이(정합성·보안·아키텍처 점검, 리포트만).
- **push·merge는 사람이** 외부 툴(Sourcetree 등)로. 완성 산출물 예시: [`examples/`](examples/).

**치트시트**:
| 하고 싶은 것 | 커맨드 |
|:---|:---|
| 새 프로젝트·미검증 알고리즘 | (알파=ADR 1장) → `/flow:spike` → `/flow:design` → … |
| 새 기능 | `/flow:design` → `/flow:builder` → `/flow:sync` |
| 버그·장애 잡기 | `/flow:troubleshoot` → `/flow:builder` → `/flow:sync` |
| 레거시·요구 파악 | `/flow:analysis` |
| 코드 품질·보안 점검 | `/flow:review` (아무 때나) |
| 커밋 | `/flow:commit` (요청 시) |
| 결과 발행 (Notion 등) | `/flow:publish` (개발 끝나고) |
| 디자인 테마 적용 | `/flow:theme` (원형 생성 후, 프론트에) |

> **house-style 프리셋**이 준비됐으면 `/flow:setup` 후 `~/.claude/plugins/marketplaces/setting-ai/presets/house-style/patterns/`를 프로젝트 `doc/ref/patterns/`로 복사해 패턴 씨앗을 심는다.

---

## 운영·심화

### 🛡️ 드리프트 훅 (문서-코드 정합 자동 감지)

소스만 커밋되고 설계 문서(`doc/design`·`doc/summary`)가 안 맞으면 감지하는 **git 훅**. `/flow:setup`이 설치하고, 동작은 `workflow.config.json`의 **`drift.mode`** 한 줄로 고른다:

| `drift.mode` | 동작 | 발화 시점 |
|:---|:---|:---|
| **`warn`** *(기본)* | 알림만 (커밋 안 막음) | 커밋 직후 |
| `block` | **push 차단** (우회: `git push --no-verify`) | push 직전 |
| `autosync` *(실험)* | `claude -p`로 문서 자동 동기화 (느림·토큰비용) | 커밋 전 |
| `off` | 끔 | — |

- 누가 커밋/푸시하든(Sourcetree·IDE·CLI) 발화하는 **실제 git 훅** — Claude 밖 커밋까지 커버(결정론적). `spike/`는 대상 제외.
- 모드 변경은 `drift.mode`만 고치면 됨(**재설치 불필요**). 계약 검증(`contract-gate`)·전제점검(`check-prereqs`)은 별개의 플러그인 훅. 상세: [`automation/README.md`](automation/README.md).

### ⚙️ 워크플로우 자체 수정 → 배포 *(setting-ai를 고칠 때 — 오너)*

**로컬 개발**: `/plugin marketplace add /path/to/setting-ai`(최초 1회) → 커맨드·스킬 수정 → `/reload-plugins`로 반영·테스트(반복).

**배포(릴리스) — 반드시 버전 올려서 push**:
```
scripts/bump-version.sh minor      # patch=버그수정 / minor=기능추가 / major=깨지는변경 (두 파일 자동 갱신)
git commit -am "chore: bump flow 0.x.0"
git push                            # ⚠️ 버전 안 올렸으면 pre-push 가드가 막음 (설치측 캐시 키=버전)
```
> **pre-push 가드 최초 설치**(setting-ai repo에서 1회): `cp automation/git-hooks/pre-push-version-guard .git/hooks/pre-push && chmod +x .git/hooks/pre-push`. 버전은 **커밋마다가 아니라 릴리스할 때 한 번** 올린다. 설치측 최신화는 `/plugin marketplace update setting-ai` → `/reload-plugins`.

---

## 데이터 흐름 (요약)

```
(신규 프로젝트 앞단) 알파=ADR 1장 → /spike  [버릴 코드 spike/ 로 핵심 검증 → 지식만 ADR·ref 승격]
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
| `drift.mode` | git 훅 드리프트 동작: `warn`(기본·알림)·`block`(push 차단)·`autosync`(실험)·`off`. (`sourceGlobs`/`ignore`는 소스 판정 힌트) |
| `publish.target` / `publish.notionParent` | `/flow:publish` 발행처: `notion`/`docx`/`markdown`, Notion 부모 DB·페이지(첫 발행 때 저장) |
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
