# Getting Started — 새 프로젝트에서 워크플로우 쓰기

설치부터 첫 기능 설계까지의 실전 순서. (사상은 [`workflow-principles.md`](workflow-principles.md), 채워진 예시는 [`../examples/`](../examples/).)

---

## 0. 개념 한 장 요약

```
공용 기계(플러그인)  = /명령·에이전트·스킬·훅   → 설치해서 씀 (프로젝트에 복사 안 함)
프로젝트 고유층      = CLAUDE.md · workflow.config.json · doc/  → 프로젝트가 소유
```

당신이 프로젝트마다 하는 일은 **"고유층을 채우는 것"**이지 커맨드를 고치는 게 아니다.

---

## 1. 플러그인 설치 (git에서)

새 프로젝트 폴더에서 Claude Code를 실행하고:

```
/plugin marketplace add nrwoodpsh/setting-ai       # git repo가 곧 마켓플레이스
/plugin install flow@setting-ai --scope project    # --scope project = 팀 공유(.claude/settings.json)
```

- 설치 후 `/setup` `/design` `/builder` `/sync` 등이 뜬다.
- `marketplace add`가 setting-ai 전체를 `~/.claude/plugins/marketplaces/setting-ai/`에 받아둔다 — **`project-template`도 여기 포함되므로 별도 clone·복사 불필요.**
- setting-ai를 **직접 고칠 때(플러그인 개발)만** 로컬 경로로: `/plugin marketplace add /path/to/setting-ai` → `/reload-plugins`.

---

## 2. `/setup` — 골격 생성 + 채우기

```
/flow:setup list          # 먼저 원형 카탈로그 보기 (아무것도 안 만듦)
/flow:setup               # 대화형 (빈 프로젝트=원형 메뉴 / 진행중=목록만 보여주고 넘어감)
/flow:setup egov-msa-cc   # 원형 키를 알면 바로 / repo URL이면 커스텀 원형
```
`/flow:setup`이 `cp` 없이 다 한다:
- `doc/` 구조·`CLAUDE.md`·`workflow.config.json`을 **만들고**(마켓플레이스 클론의 `project-template/`에서 복사하거나 새로 생성),
- 프로젝트를 스캔해 스택·네이밍·도메인 후보를 **채우고**,
- 가드레일·도구정책 등 **결정 항목만 질문**한다.

만들어지는 구조:
```
my-project/
├── CLAUDE.md              # 정체성·가드레일 (초안 채워짐)
├── workflow.config.json   # 스택 게이트·테스트 명령 (추론 채워짐)
└── doc/
    ├── ref/{architecture,patterns,db-schema,domains,glossary}/   # 참조(입력)
    └── {design,decisions,summary,analysis}/                      # 산출물(출력)
```
> house-style 프리셋이 준비됐으면 마켓플레이스 클론의 `presets/house-style/patterns/`를 `doc/ref/patterns/`로 복사해 씨앗을 심는다.

---

## 3. (참고) 각 파일 수동 이해·조정

`/setup`이 채운 것을 검수하거나 직접 손볼 때의 설명.

### 3-1. `workflow.config.json` — 스택 주입

```jsonc
{
  "contract": {
    "file": "api-contract.ts",
    "gate": "npx -y -p typescript tsc --noEmit --strict {file}"  // 스택에 맞게
  },
  "test": { "command": "npm test" },   // mvn test / pytest 등
  "drift": { "mode": "warn" },   // warn(알림) | block(push 차단) | autosync(실험) | off
  "language": "korean"
}
```

### 3-2. `CLAUDE.md` — 프로젝트 정체성·가드레일

`{{placeholder}}`를 실제 값으로. **매 턴 컨텍스트에 실리는 유일한 파일이니 작게 유지** — 스택·네이밍·금지사항·MCP 정책 등 **프로젝트 고유의 것만** 둔다. 범용 워크플로우 규약·일반 코딩 룰("클린 코드로 짜라" 등)은 넣지 않는다(플러그인이 이미 갖고 있고, AI는 표준을 이미 따름). 새 규칙 추가 전 기존 규칙을 압축·삭제부터 검토. 유지보수 안내를 파일 본문에 두지 말 것 — 그것도 매 턴 토큰이다.

### 3-3. `doc/ref/` — 참조 정본

- `architecture/` — 아키텍처·기술스택 문서
- `patterns/` — layout·error-handling·api-contract를 **실제 코드에 맞게** 조정 (프리셋을 복사했으면 다듬기만)
- `db-schema/` — DDL (BE 프로젝트)

---

## 4. 첫 기능 — 흐름 타보기

### 신규 프로젝트 앞단 — 알파 → `/spike` (핵심 알고리즘이 불확실할 때)

기존 코드가 없는 새 프로젝트이고 **핵심 알고리즘·기술이 되는지부터 불확실**하면, 바로 `/design`으로 가지 말고 앞에서 리스크를 태운다.

1. **알파(목표·가설) = ADR 한 장.** 프로젝트의 목표·핵심 가설·성공 기준을 `doc/decisions/0001-*.md`에 남긴다(커맨드 아님, 문서 1장). "무엇이 되면 이 프로젝트가 성립하는가".
2. **`/spike`로 검증.** 버릴 코드로 그 가설만 빠르게 확인한다.
   ```
   /flow:spike
   [가설] 임베딩 기반 매칭이 10만 건에서 200ms 내 응답
   [기준] p95 < 200ms 이면 채택, 넘으면 대안(역색인) 재검토
   ```
   → `spike/`에 실험 코드(버릴 것), `doc/analysis/{date}-spike-*.md`에 결론. **채택/기각 판정 + 핵심 결정은 ADR로 승격**, 확정된 제약은 `doc/ref/architecture/`로.
3. **검증이 끝나면 자산 모드로.** spike 코드를 그대로 쓰지 말고, ADR·spike 결론을 입력 삼아 AI가 `ref/architecture`·`ref/domains`·`ref/glossary` **초안**을 만든다. 사람이 확인해 확정하면 정본이 되고(소유는 사람), 그다음 도메인별 `/design → /builder`로 **재설계**한다. 이후 `/design`이 새 용어·경계를 발견할 때마다 `ref/domains`·`glossary`를 갱신한다 — 처음부터 사람이 백지에서 채우는 게 아니라, **검증으로 얻은 지식을 AI 초안으로 받아 다듬는 것**이 시작점이다.

> `spike/`는 drift·계약 게이트 대상이 아니다(config `drift.ignore`에 `spike/**`, `CLAUDE.md` 참조 금지). 앞단은 **학습 모드**(게이트 없음), design 이후가 **자산 모드**(계약·AC·drift 풀가동)다. — 사상은 [`workflow-principles.md`](workflow-principles.md) §2.

### 신규 기능
```
/flow:design
[TASK] 회원 로그인 API와 화면
[REFERENCE] @doc/ref/db-schema/user.sql
[EVALUATE] AC: (1) 성공 시 토큰 발급 (2) 실패 시 U001 (3) 응답 200ms 이내
```
→ `doc/design/user/login/`에 `task-*.md` + `api-contract.ts` 생성. 계약은 `contract-gate` 훅이 자동 검증.

```
/flow:builder            # 최근 설계 자동 식별 → "대상 확정 선언" 후 구현
/flow:sync               # git diff로 문서 갱신 + summary 생성 (커밋은 안 함)
/flow:commit             # 요청 시에만 — 변경 목록·메시지 작성 후 커밋
/flow:publish            # (선택) 개발 결과를 Notion에 발행
```
→ `/flow:commit`이 커밋 전 `drift-check`로 문서 동기화를 확인. **push·merge는 당신이 외부 툴로.** git 훅도 커밋/푸시 시 드리프트를 감지 — 동작은 `workflow.config.json`의 `drift.mode`(`warn`·`block`·`autosync`·`off`)로 선택.

### 버그·장애
```
/flow:troubleshoot
[TASK] 로그인 후 401이 간헐 발생
[REFERENCE] @logs/error.log @src/auth/TokenFilter.java
```
→ 근본원인·수정안 → `/flow:builder`(또는 직접 수정) → `/flow:sync`.

### 필요할 때
```
/flow:analysis    # 레거시 파악 (넓은 지도)
/flow:review      # 품질·보안 점검 (아무 때나 오버레이)
```

---

## 5. 자주 막히는 곳

| 증상 | 원인·해결 |
|:---|:---|
| 커맨드가 안 뜸 | `/plugin install` 스코프 확인, `/reload-plugins` |
| 계약 게이트가 안 돎 | `workflow.config.json`의 `contract.gate` 미설정 (드물게 node·python3·perl 모두 부재) |
| `/commit`이 드리프트 경고 | 소스만 바뀌고 문서 미갱신 → `/sync` 먼저, 또는 불필요한 변경이면 그대로 진행 |
| `/builder`가 엉뚱한 걸 잡음 | "대상 확정 선언"에서 경로를 명시 지정 (`/builder user/login`) |

---

## 6. 워크플로우 자체를 개선할 때

이 repo를 고치고 → `/reload-plugins`. 팀에 전파는 repo push 후 각자 `/plugin marketplace update setting-ai`.
