/**
 * 회원 로그인 API 계약 — user/login
 * 검증: npx tsc --noEmit --strict api-contract.ts (self-contained)
 */

// 1) 엔드포인트
export const LoginEndpoint = {
  method: 'POST',
  path: '/api/v1/auth/login',
} as const;

export const RefreshEndpoint = {
  method: 'POST',
  path: '/api/v1/auth/refresh',
} as const;

// 2) 요청 DTO
export interface LoginReq {
  email: string;
  password: string;
}

export interface RefreshReq {
  refreshToken: string;
}

// 3) 응답 DTO
export interface TokenRes {
  accessToken: string;
  refreshToken: string;
  expiresIn: number; // seconds
}

// 4) 에러 레지스트리
export const UserErrors = {
  INVALID_CREDENTIALS: { code: 'U001', status: 401, message: '이메일 또는 비밀번호가 올바르지 않습니다.' },
  LOCKED: { code: 'U002', status: 423, message: '계정이 잠겼습니다. 잠시 후 다시 시도하세요.' },
  REFRESH_EXPIRED: { code: 'U003', status: 401, message: '세션이 만료되었습니다. 다시 로그인하세요.' },
} as const;

export type UserErrorCode = (typeof UserErrors)[keyof typeof UserErrors]['code'];
