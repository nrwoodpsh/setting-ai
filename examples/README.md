# examples — 완결 예시 (회원 로그인)

빈 템플릿의 `{{placeholder}}`가 **실제로 어떻게 채워지는지** 보여주는 참조물. "회원 로그인" 기능을 `/design → /builder → /sync` 한 바퀴 돌린 산출물을 담았다. (Spring Boot 3 + Vue 3 + TypeScript 스택 가정.)

> 이건 **견본**이다. 그대로 복사하지 말고 "이 정도 밀도로 채우면 된다"는 감을 잡는 용도.

## 무엇을 보여주나

| 파일 | 대응 템플릿 | 보여주는 것 |
|:---|:---|:---|
| `CLAUDE.md` | `project-template/CLAUDE.md` | 채워진 정체성·가드레일·참조통제 |
| `workflow.config.json` | 〃 | TS 스택으로 채운 게이트·테스트 명령 |
| `doc/ref/domains/user.md` | `ref/domains/` | 도메인 경계 한 장 |
| `doc/design/user/login/api-contract.ts` | `patterns/api-contract/template.ts` | 실제 로그인 계약 (tsc 통과) |
| `doc/design/user/login/task-login-20260714.md` | `patterns/task-doc/task-template.md` | 채워진 자연어 설계 |
| `doc/decisions/0001-jwt-over-session.md` | `decisions/` | ADR 한 장 |
| `doc/summary/summary-user-login-20260714.md` | `summary/` | `/sync`가 낸 작업 요약 |

## 흐름으로 읽기

```
/design   → task-login-20260714.md + api-contract.ts 생성, 0001 ADR 기록
/builder  → (실제 소스 코드 — 이 예시엔 생략) + task History 갱신
/sync     → summary-user-login-20260714.md 생성, 계약 최종 정합
/commit   → 코드+문서 한 커밋 (push는 사람)
```
