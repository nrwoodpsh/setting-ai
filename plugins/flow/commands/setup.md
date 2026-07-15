---
description: 프로젝트를 flow 워크플로우에 맞게 초기 세팅. (선택) 아키텍처 원형 생성 + 추천 도구(LSP/MCP) 제안 + CLAUDE.md·workflow.config·doc 초안 채움. 추론 가능한 것만 자동, 결정·정책·설치는 사용자 확인.
argument-hint: [특별히 참조할 경로 (선택)]
---

# /setup — 프로젝트 초기 세팅 (부트스트랩)

프로젝트의 **고유층을 만들고 채운다.** 목표: 사람이 `cp`도, 한 자 한 자 타이핑도 안 하도록 — **골격은 자동 생성, 추론 가능한 값은 자동, 결정·정책은 질문으로.**

> 전제 없음. 골격(`CLAUDE.md`·`workflow.config.json`·`doc/`)이 없으면 이 커맨드가 스캐폴딩한다 — 사용자가 setting-ai를 clone하거나 `cp`할 필요 없다.

## 원칙: AI 추론 vs 사람 결정

| AI가 채움 (추론) | 사람이 확정 (결정·정책) |
|:---|:---|
| 스택·빌드·테스트 명령 | 가드레일 (운영DB·민감파일 등) |
| 폴더 구조·네이밍 규칙 | 도구 정책 (MCP 범위) |
| 도메인 후보 (코드에서 추출) | 도메인 경계 최종 확정 |
| 계약 게이트 명령 | 커밋 메시지 규약(팀 관례) |

**추측 금지 원칙**: 오른쪽(결정·정책)은 코드에 없다. 추측하지 말고 **사용자에게 질문**해 확정한다.

## 절차

1. **골격 준비**: `CLAUDE.md`·`workflow.config.json`·`doc/` 구조가 없으면 스캐폴딩한다.
   - 마켓플레이스 클론(`~/.claude/plugins/marketplaces/*/project-template/`)이 있으면 거기서 복사.
   - 없으면 표준 구조를 새로 생성 — `doc/ref/{architecture,patterns,db-schema,domains,glossary}` · `doc/{design,decisions,summary,analysis}` + `CLAUDE.md` · `workflow.config.json`.
   - **팀 자동 온보딩**: 프로젝트 `.claude/settings.json`에 마켓플레이스 등록(`extraKnownMarketplaces`) + flow 활성화(`enabledPlugins`)를 넣는다(`project-template/.claude/settings.json`와 동일). 이 파일이 커밋되면 팀원은 clone 후 신뢰 승인만으로 flow가 붙는다. 이미 있으면 유지.
   - 이미 채워진 파일(placeholder 아님)이 있으면 **덮어쓰지 말고** 무엇을 갱신할지 사용자에게 확인.
2. **스캔**: 스택 지표를 읽어 기술 스택 식별.
   - `package.json`(Node/TS — `scripts`의 test·build를 그대로 활용), `build.gradle`·`pom.xml`(Java), `requirements.txt`·`pyproject.toml`(Python), `go.mod`(Go) 등.
   - 폴더 구조·기존 네이밍·테스트 프레임워크. 광범위하면 `explorer`에 위임.
   - **스캔할 지표가 없으면(빈/신규 프로젝트) 추론하지 말고 사용자에게 스택을 질문**한다.
3. **프로젝트 원형 제안** *(빈/신규 프로젝트일 때만)*: 코드가 거의 없으면 `presets/architectures/` 카탈로그에서 원형을 제안한다 — `spring-monolith` · `egov-backend` · `egov-msa` · `egov-homepage` · `egov-enterprise` · `egov-portal` · `none`.
   - 사용자가 고르면 해당 **검증된 템플릿 repo를 복제**(`git clone --depth 1` → `.git` 제거 → 프로젝트명·groupId·패키지 치환)하고, `workflow.config.json`·`doc/ref/architecture`를 그 원형에 맞게 조정.
   - 카탈로그 외에 **사용자가 임의 repo URL을 지정**하면 그걸 복제한다(사내 스타터·개인 보일러플레이트도 가능). `.git` 제거로 원본 git 연결은 끊긴다(LICENSE는 유지).
   - **기존 코드가 있으면 이 단계는 건너뛴다.** 원형은 프롬프트로 생성하지 않는다(검증된 repo 복제만). 상세: `presets/architectures/README.md`.
4. **초안 생성** (추론 항목):
   - `CLAUDE.md` §1 정체성, §5 코딩 스타일 — 스캔/원형 결과로 채움.
   - `workflow.config.json` — 스택에 맞는 `contract.gate`·`test.command` 추론. **추론한 명령은 한 번 실행해 실제 도는지 확인**하고, 안 되면 사용자에게 정정 요청.
   - `doc/ref/domains/` — 코드에서 도메인 후보를 뽑아 각 `{domain}.md` 초안(경계는 "확인 필요"로 표기).
   - **선택**: 기존/원형 대표 파일에서 layout·error-handling 패턴을 역추출해 `doc/ref/patterns/` 초안 제안(사람 확정).
5. **추천 도구·자동화 제안**:
   - *(LSP · MCP)* 감지 스택에 맞는 도구를 **제안**한다 — 예: Java/eGov → LSP `jdtls`, MCP `DB 읽기전용`(스키마). 승인 시 `.lsp.json`·`.mcp.json`(또는 settings) 설정을 기록. **무단 설치·크리덴셜 입력은 하지 않는다**(바이너리·비밀정보는 사용자). 상세: `guide/recommended-tools.md`.
   - *(drift-check git 훅)* `drift-hook.sh`를 `.git/hooks/`의 pre-commit·post-commit·pre-push **3개 이름으로 설치** 제안(Sourcetree 등 외부 커밋까지 커버). 동작은 `workflow.config.json`의 **`drift.mode`**로 선택: `warn`(기본·알림)·`block`(push 차단)·`autosync`(실험)·`off`. 상세: `automation/README.md`.
6. **확인 요청** (결정 항목): 가드레일·도구 정책·도메인 경계·커밋 규약을 **질문으로** 확정. 답을 받아 `CLAUDE.md` §4·§6에 반영.
7. **대상 확정 선언 + 요약**: 채운 값(스택·원형·게이트·도메인·추천도구)을 보여주고, 사용자 검수를 요청.

```
[/setup] 감지 스택: {예: Spring Boot 3 + Vue 3 + TS}
         contract.gate: {추론된 명령}
         test.command: {추론된 명령}
         도메인 후보: {user, order, ...}
         → CLAUDE.md·workflow.config·domains 초안을 채웠습니다. 아래 결정 항목을 확인해 주세요:
           (1) 가드레일  (2) 도구 정책  (3) 도메인 경계
```

## 가드레일

- **기존 코드를 수정하지 않는다.** 세팅 문서만 생성·갱신. (원형 생성은 *빈* 프로젝트에 검증된 템플릿을 복제하는 것 — 기존 코드가 있으면 하지 않는다.)
- **도구는 제안만.** LSP·MCP·플러그인을 무단 설치하지 않는다 — 설정만 기록하고 바이너리·크리덴셜은 사용자가 채운다.
- **결정·정책은 추측 금지.** 반드시 질문으로 확정.
- **기존 값 덮어쓰기 금지.** placeholder가 아닌 실제 값이 있으면 확인 후 갱신.
- 내장 `/init`과 역할이 다르다 — `/init`은 일반 CLAUDE.md 생성, `/setup`은 flow 층(config·domains 포함) 전체 세팅.
