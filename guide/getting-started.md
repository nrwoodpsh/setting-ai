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

## 1. 프로젝트 고유층 복사

```bash
# 워크플로우 repo에서 프로젝트 템플릿을 새 프로젝트로 복사
cp -r /path/to/setting-ai/project-template/. /path/to/my-project/

# (선택) 주력 스택 프리셋이 준비돼 있으면 patterns 정본으로 복사
cp -r /path/to/setting-ai/presets/house-style/patterns/. /path/to/my-project/doc/ref/patterns/
```

복사되면 프로젝트에 이런 게 생긴다:

```
my-project/
├── CLAUDE.md                # 채워야 함
├── workflow.config.json      # 채워야 함
└── doc/
    ├── ref/{architecture,patterns,db-schema,domains,glossary}/   # 참조(입력) — 채워야 함
    └── {design,decisions,summary,analysis}/                      # 산출물(출력) — 비어 있음
```

---

## 2. 플러그인 설치

`my-project`에서 Claude Code를 실행하고:

```
/plugin marketplace add nrwoodpsh/setting-ai
# 로컬 개발 중이면: /plugin marketplace add /path/to/setting-ai

/plugin install flow@setting-ai --scope project
```

- `--scope project` → 팀 공유(`.claude/settings.json`에 기록, 커밋됨).
- 설치 후 `/design` `/builder` `/sync` `/troubleshoot` `/analysis` `/review`가 뜬다.

---

## 3. 고유층 채우기 (핵심)

> **빠른 방법**: `/setup`(=`/flow:setup`)을 실행하면 프로젝트를 스캔해 `CLAUDE.md`·`workflow.config.json`·`doc/ref/domains` 초안을 채워준다. 사람은 **결정 항목(가드레일·도구정책·도메인 경계)만 확인**하면 된다. 아래는 각 파일을 수동으로 이해·조정할 때의 설명.

### 3-1. `workflow.config.json` — 스택 주입

```jsonc
{
  "contract": {
    "file": "api-contract.ts",
    "gate": "npx -y -p typescript tsc --noEmit --strict {file}"  // 스택에 맞게
  },
  "test": { "command": "npm test" },   // mvn test / pytest 등
  "drift": { "enabled": true },
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

### 신규 기능
```
/design
[TASK] 회원 로그인 API와 화면
[REFERENCE] @doc/ref/db-schema/user.sql
[EVALUATE] AC: (1) 성공 시 토큰 발급 (2) 실패 시 U001 (3) 응답 200ms 이내
```
→ `doc/design/user/login/`에 `task-*.md` + `api-contract.ts` 생성. 계약은 `contract-gate` 훅이 자동 검증.

```
/builder                 # 최근 설계 자동 식별 → "대상 확정 선언" 후 구현
/sync                    # git diff로 문서 갱신 + summary 생성 (커밋은 안 함)
/commit                  # 요청 시에만 — 변경 목록·메시지 작성 후 커밋
```
→ `/commit`이 커밋 전 `drift-check`로 문서 동기화를 확인하고 변경 목록을 보여준다. **push·merge는 당신이 외부 툴로.**

### 버그·장애
```
/troubleshoot
[TASK] 로그인 후 401이 간헐 발생
[REFERENCE] @logs/error.log @src/auth/TokenFilter.java
```
→ 근본원인·수정안 → `/builder`(또는 직접 수정) → `/sync`.

### 필요할 때
```
/analysis    # 레거시 파악 (넓은 지도)
/review      # 품질·보안 점검 (아무 때나 오버레이)
```

---

## 5. 자주 막히는 곳

| 증상 | 원인·해결 |
|:---|:---|
| 커맨드가 안 뜸 | `/plugin install` 스코프 확인, `/reload-plugins` |
| 계약 게이트가 안 돎 | `workflow.config.json`의 `contract.gate` 미설정, 또는 `jq` 미설치 |
| `/commit`이 드리프트 경고 | 소스만 바뀌고 문서 미갱신 → `/sync` 먼저, 또는 불필요한 변경이면 그대로 진행 |
| `/builder`가 엉뚱한 걸 잡음 | "대상 확정 선언"에서 경로를 명시 지정 (`/builder user/login`) |

---

## 6. 워크플로우 자체를 개선할 때

이 repo를 고치고 → `/reload-plugins`. 팀에 전파는 repo push 후 각자 `/plugin marketplace update setting-ai`.
