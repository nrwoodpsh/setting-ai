# user (회원)

- **책임**: 인증(로그인·토큰 발급/갱신), 프로필, 권한(Role)
- **주요 엔티티**: `User`, `Role`, `RefreshToken`
- **연동**: order(주문자 조회), approval(결재자 권한 확인)
- **경계**: 결제 수단·정산은 다루지 않음 → payment 도메인 (미도입)
- **관련 결정**: [ADR 0001](../../decisions/0001-jwt-over-session.md) — 세션 대신 JWT
