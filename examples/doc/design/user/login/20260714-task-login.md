# 20260714-task-login.md

## 1. Requirements

- **Scenario**: 미인증 사용자가 이메일·비밀번호로 로그인해 서비스에 접근한다.
- **Objective**: JWT 기반 인증. 액세스 토큰 + 리프레시 토큰 발급.
- **Acceptance Criteria** (측정 가능, 3개 이상):
  - [ ] AC1: 올바른 자격증명 → 200 + `accessToken`·`refreshToken`·`expiresIn` 반환
  - [ ] AC2: 틀린 자격증명 → 401 + 에러코드 `U001`
  - [ ] AC3: 5회 연속 실패 → 계정 잠금, 이후 `U002` 반환
  - [ ] AC4: 로그인 API 응답 200ms 이내(로컬 기준)

## 2. UI/UX

- 로그인 폼: 이메일·비밀번호 입력 + "로그인" 버튼. 실패 시 필드 하단 에러 메시지(U001/U002).

## 3. Logic

- 비밀번호는 BCrypt 해시 비교. 성공 시 액세스 토큰(15분)·리프레시 토큰(14일) 발급.
- 실패 카운트는 `user.failed_count`에 누적, 5 이상이면 `locked_until` 설정.

## 4. Implementation Split

- **BE**: `AuthController.login` / `AuthService` / `RefreshTokenMapper`
- **FE**: `views/user/LoginView.vue` + `api/auth.ts`(계약 타입 import)

## 5. File Map

- `[New] src/main/java/kr/co/acme/user/controller/AuthController.java`
- `[New] src/main/java/kr/co/acme/user/service/AuthService.java`
- `[New] src/frontend/views/user/LoginView.vue`

## 6. Verification

- 명령: `./gradlew test --tests AuthServiceTest`
- 통과 조건: Exit 0. AC1~3 각각 테스트 1개 이상, AC2는 `U001` 반환 검증.

## 7. History

| 일시 | 단계 | 내용 |
|:---|:---|:---|
| 20260714 10:20 | /design | 최초 설계 + 계약 작성. ADR 0001(JWT) 기록 |
| 20260714 14:05 | /builder | 구현 완료. `./gradlew test` Exit 0 (12 passed) |
| 20260714 14:30 | /sync | 계약 정합 확인, 상태 [완료], summary 생성 |
