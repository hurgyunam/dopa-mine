# API Design

세션 저장/조회에 필요한 API 계약(Contract) 초안을 정의합니다.

## 1) 목적
- 앱의 세션 데이터를 백엔드에 일관된 형식으로 저장한다.
- 프론트엔드와 백엔드의 책임 경계를 명확히 한다.

## 2) 엔드포인트 초안
- `POST /sessions`: 세션 생성
- `GET /sessions/{id}`: 세션 단건 조회
- `GET /sessions?exerciseId={id}`: 운동 기준 세션 목록 조회

## 3) 요청/응답 모델 (초안)
### Create Session Request
- `exerciseId`: string
- `startTime`: ISO-8601 string
- `duration`: int (seconds)
- `repetitionCount`: int
- `isCompleted`: bool

### Create Session Response
- `id`: string
- `exerciseId`: string
- `startTime`: ISO-8601 string
- `duration`: int
- `repetitionCount`: int
- `isCompleted`: bool
- `pointsAwarded`: int

## 4) 인증 규약 (확정)
- 인증이 필요한 모든 API는 `Authorization: Bearer <access_token>` 헤더를 사용한다.
- 액세스 토큰은 Supabase Auth JWT를 기준으로 하며, 서버는 토큰의 만료/유효성을 검증한다.
- 인증 실패 시 응답 바디는 아래 공통 에러 스키마를 따른다.

## 5) 에러 응답 바디 표준 (확정)
### 공통 스키마
```json
{
  "error": {
    "code": "AUTH_UNAUTHORIZED",
    "message": "Access token is missing or invalid.",
    "details": [
      {
        "field": "Authorization",
        "reason": "MISSING_BEARER_TOKEN"
      }
    ],
    "requestId": "req_01HXYZ...",
    "timestamp": "2026-02-26T10:00:00Z"
  }
}
```

### 필드 정의
- `error.code`: 클라이언트 분기용 안정 코드(대문자 스네이크 케이스)
- `error.message`: 사용자/로그 출력 가능한 요약 메시지
- `error.details`: 필드 단위 상세 오류 배열(없으면 빈 배열 허용)
- `error.requestId`: 서버 추적용 요청 ID
- `error.timestamp`: UTC ISO-8601 시각

### 상태 코드별 규칙
- `400 BAD_REQUEST`
  - `error.code`: `VALIDATION_FAILED`
  - 사용 예: `duration < 0`, `repetitionCount < 0`
- `401 UNAUTHORIZED`
  - `error.code`: `AUTH_UNAUTHORIZED`
  - 사용 예: 토큰 누락, 만료, 서명 불일치
- `403 FORBIDDEN`
  - `error.code`: `AUTH_FORBIDDEN`
  - 사용 예: 본인 소유가 아닌 세션 접근
- `404 NOT_FOUND`
  - `error.code`: `SESSION_NOT_FOUND`
  - 사용 예: 존재하지 않는 세션 ID 조회
- `409 CONFLICT`
  - `error.code`: `IDEMPOTENCY_CONFLICT`
  - 사용 예: 중복 완료 처리, 멱등성 키 충돌
- `500 INTERNAL_SERVER_ERROR`
  - `error.code`: `INTERNAL_ERROR`
  - 사용 예: 예기치 못한 서버 내부 오류

## 6) 미정 항목
- 포인트 계산을 서버/클라이언트 중 어디서 최종 확정할지
- 세션 중단/복구 상태를 API에 포함할지 여부

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 인증 규약(Bearer JWT) 및 에러 응답 바디 표준 확정 | @cursor-agent |
| 2026-02-24 | 변경 이력 정책 섹션 도입 | @owner |
