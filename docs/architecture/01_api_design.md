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

## 6) 저장 엔티티/필드 매핑 (초안)
### 6-1. 공통 규칙
- 앱 도메인 모델은 `camelCase`, Supabase 컬럼은 `snake_case`를 사용한다.
- 시간 값은 UTC ISO-8601 문자열로 전달/저장한다.
- 소유자 식별은 인증 토큰의 사용자 ID(`user_id`)를 기준으로 한다.
- 엔티티 관계는 `WorkoutSession -> SessionExercise`가 `1:N`, `SessionExercise -> RepetitionLog`가 `1:N`이며, `WorkoutSession`의 `RepetitionLog` 개수는 하위 `SessionExercise`들의 로그 수 합으로 결정된다.

### 6-2. `WorkoutSession` ↔ `workout_sessions`
세션 1건의 시작/종료/집계 결과(총 반복 수, 완료 여부, 포인트)를 저장하는 기준 테이블이다.
`WorkoutSession` 1건은 여러 개의 `SessionExercise`(6-3)를 가질 수 있다.
| 앱 엔티티 필드 (`WorkoutSession`) | API 필드 | Supabase 컬럼 (`workout_sessions`) | 타입/비고 |
| --- | --- | --- | --- |
| `id` | `id` | `id` | UUID, 서버 생성 |
| `userId` | `userId` | `user_id` | UUID, JWT 사용자와 일치해야 함 |
| `exerciseId` | `exerciseId` | `exercise_id` | string |
| `startTime` | `startTime` | `start_time` | timestamptz |
| `endTime` | `endTime` | `end_time` | timestamptz, nullable |
| `durationSeconds` | `duration` | `duration_seconds` | int, 0 이상 |
| `repetitionCount` | `repetitionCount` | `repetition_count` | int, 0 이상 |
| `isCompleted` | `isCompleted` | `is_completed` | bool |
| `pointsAwarded` | `pointsAwarded` | `points_awarded` | int, 기본값 0 |
| `createdAt` | `createdAt` | `created_at` | timestamptz, 서버 기본값 |
| `updatedAt` | `updatedAt` | `updated_at` | timestamptz, 서버 갱신 |

### 6-3. `SessionExercise` ↔ `session_exercises`
한 세션 안에서 수행한 운동 항목과 순서, 목표/실제 반복 수를 저장하는 구성 테이블이다.
`SessionExercise` 1건은 여러 개의 `RepetitionLog`(6-4)를 가질 수 있다.
| 앱 엔티티 필드 (`SessionExercise`) | API 필드 | Supabase 컬럼 (`session_exercises`) | 타입/비고 |
| --- | --- | --- | --- |
| `id` | `id` | `id` | UUID, 서버 생성 |
| `sessionId` | `sessionId` | `session_id` | UUID, `workout_sessions.id` FK |
| `exerciseId` | `exerciseId` | `exercise_id` | string |
| `sequence` | `sequence` | `sequence` | int, 세션 내 순서 |
| `targetReps` | `targetReps` | `target_reps` | int, nullable |
| `actualReps` | `actualReps` | `actual_reps` | int, 기본값 0 |
| `createdAt` | `createdAt` | `created_at` | timestamptz, 서버 기본값 |
| `updatedAt` | `updatedAt` | `updated_at` | timestamptz, 서버 갱신 |

### 6-4. `RepetitionLog` ↔ `repetition_logs`
반복(Rep) 단위의 시점/경과 시간을 기록해 세션 상세 이력과 분석에 사용하는 로그 테이블이다.
`RepetitionLog`는 정확히 하나의 `SessionExercise`와 하나의 `WorkoutSession`에 속한다.
| 앱 엔티티 필드 (`RepetitionLog`) | API 필드 | Supabase 컬럼 (`repetition_logs`) | 타입/비고 |
| --- | --- | --- | --- |
| `id` | `id` | `id` | UUID, 서버 생성 |
| `sessionId` | `sessionId` | `session_id` | UUID, `workout_sessions.id` FK |
| `sessionExerciseId` | `sessionExerciseId` | `session_exercise_id` | UUID, `session_exercises.id` FK |
| `repIndex` | `repIndex` | `rep_index` | int, 1부터 증가 |
| `loggedAt` | `loggedAt` | `logged_at` | timestamptz |
| `elapsedSeconds` | `elapsedSeconds` | `elapsed_seconds` | int, 운동 시작 기준 경과 시간 |
| `createdAt` | `createdAt` | `created_at` | timestamptz, 서버 기본값 |

### 6-5. 테이블 해석 가이드
- `workout_sessions`는 세션 단위 집계 테이블이다. 세션의 시작/종료/총 반복 수/완료 여부/포인트를 저장한다.
- `session_exercises`는 세션 내 운동 구성 단위 테이블이다. 한 세션에서 어떤 운동이 몇 번째 순서로 수행되었는지 표현한다.
- `repetition_logs`는 반복(Rep) 이벤트 로그 테이블이다. 상세 분석/히스토리 재구성 용도로 사용한다.
- 관계는 `workout_sessions -> session_exercises`가 `1:N`, `session_exercises -> repetition_logs`가 `1:N`이며, `workout_sessions` 기준 `repetition_logs` 개수는 하위 `session_exercises`들의 로그 수 합으로 결정된다.
- `id`, `created_at`, `updated_at` 등 시스템 필드는 서버 책임으로 생성/관리한다.
- `duration_seconds`, `repetition_count`, `actual_reps`, `elapsed_seconds`는 음수 불가 제약을 둔다.
- 완료 상태(`is_completed=true`)의 세션은 중복 완료 저장을 막기 위해 멱등성 키 또는 상태 기반 보호 로직을 적용한다.

## 7) 미정 항목
- 포인트 계산을 서버/클라이언트 중 어디서 최종 확정할지
- 세션 중단/복구 상태를 API에 포함할지 여부

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 저장 엔티티 관계 표현을 `1:N`, `1:N` 및 합계 기준 설명으로 정밀화 | @cursor-agent |
| 2026-02-26 | 엔티티 매핑 표 해석 가이드(테이블 목적/관계/무결성 규칙) 추가 | @cursor-agent |
| 2026-02-26 | Supabase 저장 대상 엔티티/필드 매핑 표(`WorkoutSession`, `SessionExercise`, `RepetitionLog`) 추가 | @cursor-agent |
| 2026-02-26 | 인증 규약(Bearer JWT) 및 에러 응답 바디 표준 확정 | @cursor-agent |
| 2026-02-24 | 변경 이력 정책 섹션 도입 | @owner |
