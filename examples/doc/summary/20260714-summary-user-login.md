# summary — user / login (20260714)

## 개요
- **Task**: 회원 로그인 (JWT 인증)
- **작업자**: park seung hyun
- **날짜**: 2026-07-14
- **브랜치**: feature/user-login

## 변경 사항
- **BE**: `AuthController`·`AuthService` 신규. `RefreshTokenMapper` 추가. BCrypt 비교 + 실패 카운트 잠금.
- **FE**: `LoginView.vue` 신규, `api/auth.ts`가 계약 타입 import.
- **DB**: `user` 테이블에 `failed_count`·`locked_until` 컬럼 추가 (마이그레이션 스크립트 별도).

## API 변경
- 신규 `POST /api/v1/auth/login` → `TokenRes`
- 신규 `POST /api/v1/auth/refresh` → `TokenRes`
- 에러: `U001`(자격증명), `U002`(잠금), `U003`(리프레시 만료)

## 특이사항
- 설계 대비 변경: 없음 (계약대로 구현).
- 결정: JWT 채택 — [ADR 0001](../decisions/0001-jwt-over-session.md).
- 후속: 리프레시 토큰 회전(rotation) 미구현 → 다음 task로 분리.
- 제약: 소셜 로그인은 범위 외.
