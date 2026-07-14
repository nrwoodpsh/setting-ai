---
description: 프로젝트를 flow 워크플로우에 맞게 초기 세팅. 코드베이스를 스캔해 CLAUDE.md·workflow.config.json·doc/ref/domains 초안을 채운다. AI가 추론 가능한 것만 채우고, 결정·정책은 사용자에게 확인한다.
argument-hint: [특별히 참조할 경로 (선택)]
---

# /setup — 프로젝트 초기 세팅 (부트스트랩)

`project-template`을 복사해 온 프로젝트의 **고유층 placeholder를 채운다.** 목표: 사람이 한 자 한 자 타이핑하지 않도록, **AI가 추론 가능한 것은 자동으로, 결정·정책은 질문으로.**

> 전제: `project-template`이 이미 복사돼 `CLAUDE.md`·`workflow.config.json`·`doc/` 골격이 있음. 없으면 먼저 복사하라고 안내한다.

## 원칙: AI 추론 vs 사람 결정

| AI가 채움 (추론) | 사람이 확정 (결정·정책) |
|:---|:---|
| 스택·빌드·테스트 명령 | 가드레일 (운영DB·민감파일 등) |
| 폴더 구조·네이밍 규칙 | 도구 정책 (MCP 범위) |
| 도메인 후보 (코드에서 추출) | 도메인 경계 최종 확정 |
| 계약 게이트 명령 | 커밋 메시지 규약(팀 관례) |

**추측 금지 원칙**: 오른쪽(결정·정책)은 코드에 없다. 추측하지 말고 **사용자에게 질문**해 확정한다.

## 절차

1. **기존 파일 확인**: `CLAUDE.md`·`workflow.config.json`이 이미 채워져 있으면(placeholder가 아니면) **덮어쓰지 말고** 무엇을 갱신할지 사용자에게 확인.
2. **스캔**: 스택 지표를 읽어 기술 스택 식별.
   - `package.json`(Node/TS — `scripts`의 test·build를 그대로 활용), `build.gradle`·`pom.xml`(Java), `requirements.txt`·`pyproject.toml`(Python), `go.mod`(Go) 등.
   - 폴더 구조·기존 네이밍·테스트 프레임워크. 광범위하면 `explorer`에 위임.
   - **스캔할 지표가 없으면(빈/신규 프로젝트) 추론하지 말고 사용자에게 스택을 질문**한다. 답을 받아 그에 맞는 기본값으로 채운다(예: TS→`tsc`, Java→`gradle`, Python→`pytest`).
3. **초안 생성** (추론 항목):
   - `CLAUDE.md` §1 정체성, §5 코딩 스타일 — 스캔 결과로 채움.
   - `workflow.config.json` — 스택에 맞는 `contract.gate`·`test.command` 추론(예: TS→`tsc --noEmit --strict {file}`, Java→`./gradlew compileJava`, Python→`mypy`). **추론한 명령은 한 번 실행해 실제 도는지 확인**하고, 안 되면 사용자에게 정정 요청.
   - `doc/ref/domains/` — 코드에서 도메인 후보를 뽑아 각 `{domain}.md` 초안(경계는 "확인 필요"로 표기).
   - **선택**: 기존 대표 파일에서 layout·error-handling 패턴을 역추출해 `doc/ref/patterns/` 초안 제안(사람 확정). 자신 없으면 건너뛰고 사람이 채우게 둔다.
4. **확인 요청** (결정 항목): 가드레일·도구 정책·도메인 경계·커밋 규약을 **질문으로** 확정. 답을 받아 `CLAUDE.md` §4·§6에 반영.
5. **대상 확정 선언 + 요약**: 채운 값(스택·게이트·도메인 후보)을 보여주고, 사용자 검수를 요청.

```
[/setup] 감지 스택: {예: Spring Boot 3 + Vue 3 + TS}
         contract.gate: {추론된 명령}
         test.command: {추론된 명령}
         도메인 후보: {user, order, ...}
         → CLAUDE.md·workflow.config·domains 초안을 채웠습니다. 아래 결정 항목을 확인해 주세요:
           (1) 가드레일  (2) 도구 정책  (3) 도메인 경계
```

## 가드레일

- **코드를 수정하지 않는다.** 세팅 문서(`CLAUDE.md`·config·`doc/ref`)만 생성·갱신.
- **결정·정책은 추측 금지.** 반드시 질문으로 확정.
- **기존 값 덮어쓰기 금지.** placeholder가 아닌 실제 값이 있으면 확인 후 갱신.
- 내장 `/init`과 역할이 다르다 — `/init`은 일반 CLAUDE.md 생성, `/setup`은 flow 층(config·domains 포함) 전체 세팅.
