---
name: contract-gate
description: 계약 파일(api-contract 등)을 스택에 맞는 검증 명령으로 컴파일·타입체크하여 환각·오타를 차단하는 게이트. TS에 한정하지 않고 workflow.config.json의 contract 설정으로 스택별 명령을 주입받는다. /design·/builder·/sync에서 게이트로 사용.
---

# 계약 검증 게이트 (스택 무관)

## 목적

계약 파일은 워크플로우의 SSOT다. 자연어가 아니라 **기계 검증 가능한 형식**으로 작성하는 이유는 컴파일러/타입체커가 환각·오타를 자동으로 잡기 때문이다. 이 스킬은 그 게이트를 **스택에 독립적으로** 적용한다.

## 스택 무관 원칙

게이트는 특정 언어(TypeScript)에 하드코딩되지 않는다. 프로젝트의 `workflow.config.json`이 검증 방식을 주입한다:

```jsonc
{
  "contract": {
    "file": "api-contract.ts",           // 계약 파일 패턴
    "gate": "npx -y -p typescript tsc --noEmit --strict",  // 검증 명령
    "language": "typescript"
  }
}
```

스택별 예시:

| 스택 | contract.file | contract.gate |
|:---|:---|:---|
| TypeScript | `api-contract.ts` | `tsc --noEmit --strict` |
| Java/Spring | `Contract.java` | `./gradlew compileJava` |
| Python | `contract.py` | `mypy contract.py` |
| OpenAPI | `openapi.yaml` | `npx @redocly/cli lint` |

> **단일 파일 게이트 전제**: 계약 파일은 **self-contained**(외부 import 없이 타입·상수·enum만)로 유지한다. 그래야 단일 파일 검증(`tsc {file}`)이 cross-file import 문제 없이 성립한다. 외부 타입이 꼭 필요하면 프로젝트 인식 게이트(`tsc -p tsconfig.json` 등)로 `contract.gate`를 설정한다.

## 적용 시점

| 상황 | 방법 |
|:---|:---|
| `/design`이 계약 신규/수정 직후 | PostToolUse 훅이 자동 실행 |
| `/builder` 시작 시 사전 게이트 | 커맨드가 명시 호출 |
| `/sync`가 계약 갱신 직후 | PostToolUse 훅이 자동 실행 |

## 통과 기준

- `contract.gate` 명령 Exit code 0
- 에러·경고 없음

## 실패 시 동작

1. **즉시 차단** (훅의 `exit 2` blocking).
2. stderr에 에러 메시지 출력 — Claude가 받아 교정.
3. 단, **`/builder` 단계의 실패는 자율 교정 금지**(가드레일). `/design` 단계 계약 작성 중 실패만 자율 교정 허용.

## 수동 보강 체크리스트

컴파일 통과만으로 부족한 항목:
- [ ] 모든 Endpoint에 method·path 명시
- [ ] Request/Response 타입이 명시적으로 export
- [ ] 에러 코드가 레지스트리 형식으로 정의
- [ ] 동일 path 중복 없음
- [ ] 필드명이 프로젝트 명명 규칙(`CLAUDE.md`)에 일치
