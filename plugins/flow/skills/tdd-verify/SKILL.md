---
name: tdd-verify
description: 테스트를 실제로 실행해 Exit code로 통과를 물리적으로 확인함으로써 AI 환각을 방지한다. "통과할 것입니다"라는 추론은 검증이 아니다. /builder의 TDD·셀프검증, /review의 회귀 점검에 사용.
---

# TDD 검증

## 목적

AI 환각 방지. **테스트가 물리적으로 통과했는지를 Exit code로 확인**한다. "테스트가 통과할 것입니다"라는 추론은 검증이 아니다.

## 절차

### 1. 실패하는 테스트 먼저 (구현 전)

`task-*.md`의 `Verification`에 명시된 검증 기준을 **실패하는 테스트**로 변환. "처음엔 실패해야 한다"를 확인해 환각을 차단한다. **로직·계산·분기가 있는 부분에 한한다** — 단순 배선·설정·UI 텍스트 변경엔 생략 가능. 프레임워크는 `workflow.config.json`의 `test` 설정을 따른다(JUnit/pytest/Vitest 등).

### 2. 검증 명령 실행

`workflow.config.json`의 `test.command` 또는 `task-*.md`의 Verification에 정의된 명령을 그대로 실행.

```jsonc
{ "test": { "command": "npm test" } }   // 또는 "mvn test" / "pytest" 등
```

### 3. 결과 판정

- **Exit code 0** — 다음 단계 진행.
- **Exit code ≠ 0** — 즉시 중단, 1회 분석 후 사용자 리포트 (**자율 수정 금지**).

### 4. 기록

`task-*.md`의 `History`에 추가:
```
- {YYYYMMDD HH:MM} — Verification: {명령} → Exit {code}, {pass/fail 요약}
```

## 가드레일

- **테스트를 약화·mock 처리해 통과시키는 것 절대 금지.**
- 통합/E2E는 Verification에 명시된 것만 실행. 임의의 무거운 테스트 추가 실행 금지.
- 반복 실패는 `task-*.md`의 History에 타임스탬프와 함께 기록.
