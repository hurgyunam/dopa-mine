# Persistence Design

Flutter 저장 계층(`repository`, `infrastructure`, DTO 변환) 책임과 계약을 정의한다.

## 1) 목적
- 도메인/프레젠테이션 레이어가 저장소 구현 세부사항(Supabase SDK, 테이블 컬럼)에 직접 의존하지 않도록 분리한다.
- 저장 실패/재시도/중복 저장 방지 규칙을 계층 경계에서 일관되게 처리한다.
- `docs/architecture/01_api_design.md`의 저장 계약과 앱 내부 구현 책임을 연결한다.

## 2) 범위
- 대상 엔티티: `WorkoutSession`, `SessionExercise`, `RepetitionLog`
- 저장 시나리오:
  - 세션 생성
  - 세트 완료 즉시 로그 저장
  - 세션 완료 확정 저장
  - 오프라인 큐 재전송
- 비범위:
  - Supabase 테이블 DDL 상세 정의 (마이그레이션 문서 우선)
  - 로그인/토큰 발급 플로우

## 3) 계층 구조와 책임
### 3-1. `repository` (추상화 계층)
- 유스케이스가 호출하는 저장 인터페이스를 제공한다.
- 입력/출력에 쓰는 타입은 반드시 별도 클래스로 정의해서 사용한다. (`Command`/`Result`/도메인 모델, `Map`/`dynamic` 직접 사용 금지)
- `repository` 인터페이스에는 Supabase row/HTTP 응답/로컬 DB 엔티티 같은 구현 기술 타입을 직접 노출하지 않는다.

### 3-2. `infrastructure` (구현 계층)
- `repository` 인터페이스를 구현한다.
- Supabase 쿼리/업서트/에러 코드를 해석한다.
- 네트워크 실패 시 로컬 큐 적재/재시도 트리거 지점을 제공한다.

### 3-3. DTO 변환 계층
- 도메인 모델 <-> DTO(`snake_case`) 매핑을 담당한다.
- `null` 처리, 기본값 보정, 타입 변환(시간/bool/int)처럼 예외적인 데이터 보정 규칙은 DTO 변환 계층 한 곳에서만 관리한다. (여러 레이어에 같은 예외 처리 로직을 중복 작성하지 않는다)
- 변환 실패는 `Exception`으로 처리하되, 반드시 의미별 별도 클래스로 정의해 전달한다. (예: `DataContractException`, `NullFieldException`, `TypeMismatchException`)

## 4) Repository 인터페이스 계약 (초안)
```dart
abstract interface class SessionRepository {
  Future<WorkoutSession> createSession(SessionCreateCommand command);

  // 중복 저장 방지를 위해 idempotencyKey는 필수다.
  // 반환값은 최신 집계(actualReps, repetitionCount)를 포함해야 한다.
  Future<SaveRepResult> saveRepetition(
    RepetitionSaveCommand command, {
    required String idempotencyKey,
  });

  // 세션 완료 확정도 멱등 키를 필수로 사용한다.
  Future<WorkoutSession> completeSession(
    SessionCompleteCommand command, {
    required String idempotencyKey,
  });

  Future<void> enqueuePendingSave(PendingSaveCommand command);
  // 부분 실패 정보를 포함한 결과 타입을 반환해야 한다.
  Future<QueueSyncResult> flushPendingSaves();
}
```

## 5) DTO 스키마/변환 규칙
## 5-1. 네이밍/타입 규칙
- 도메인: `camelCase`
- DTO/DB: `snake_case`
- 시간 필드: UTC ISO-8601 기준 직렬화/역직렬화
- 음수 불가 필드(`repetitionCount`, `elapsedSeconds`)는 변환 단계에서 1차 검증한다.

## 5-2. 매핑 기준
| Domain | DTO/DB | 규칙 |
| --- | --- | --- |
| `sessionId` | `session_id` | UUID 문자열 유지 |
| `exerciseId` | `exercise_id` | 공백/빈 문자열 불가 |
| `isCompleted` | `is_completed` | bool 직접 매핑 |
| `repetitionCount` | `repetition_count` | 0 이상 |
| `pointsAwarded` | `points_awarded` | null 수신 시 0 기본값 |
| `loggedAt` | `logged_at` | UTC 문자열 |

## 6) 트랜잭션/멱등성/재시도 지점
### 6-1. 멱등성 처리
- `saveRepetition`: `session_exercise_id + rep_index`와 클라이언트 `idempotencyKey`를 함께 사용한다.
- `session_exercise_id`는 UUID(PK, 전역 유일)라서, 중복 체크 관점에서는 `workout_session_id`를 멱등 키에 추가하지 않아도 된다.
- `completeSession`: 동일 `session_id` 완료 요청은 1회만 상태 전이하고 이후 재요청은 기존 결과를 반환한다.

### 6-2. 재시도 처리
- 네트워크 계열 오류는 즉시 실패 대신 `PendingSaveQueue`에 적재한다.
- 큐는 FIFO로 재전송하며, 성공 항목은 즉시 제거한다.
- 재시도 상한/백오프 정책은 `오프라인 시 로컬 큐 적재 후 재동기화 전략` 문서에서 확정한다.

### 6-3. 일관성 처리
- `repetition_logs` append 성공 후 집계 업데이트 실패 시, 재시도 가능한 복구 경로를 남긴다.
- 인프라 계층은 부분 성공 상태를 `PartialWriteFailure`로 표준화해 반환한다.

## 7) 오류 전파 규칙
| 인프라 원인 | 저장 계층 오류 타입 | UI 레이어 메시지 키(예시) |
| --- | --- | --- |
| 네트워크 단절/타임아웃 | `TransientFailure` | `save_retrying_offline` |
| 토큰 만료/인증 실패 | `AuthFailure` | `session_expired_relogin` |
| RLS/권한 거부 | `PermissionFailure` | `save_permission_denied` |
| 스키마 불일치/직렬화 실패 | `DataContractFailure` | `save_data_mismatch` |
| 중복 저장 충돌 | `IdempotencyFailure` | `save_already_applied` |

- 저장 계층은 원본 예외를 그대로 노출하지 않고 도메인 친화 오류 타입으로 매핑한다.
- 로그에는 원인 코드와 요청 컨텍스트를 남기되, 사용자 메시지는 정책 키 기반으로 분리한다.
- 예외 클래스는 공용 베이스를 포함해 별도 파일로 정의한다. (예: `PersistenceException` + 하위 예외 클래스)

## 8) 테스트 포인트
### 8-1. 단위 테스트
- DTO 변환: 필수 필드 누락/null/타입 불일치 케이스
- Repository 계약: 성공/실패/멱등 재호출 시 반환값 일관성
- 오류 매핑: Supabase 에러 코드 -> 저장 계층 오류 타입

### 8-2. 통합 테스트
- 세션 생성 -> 반복 저장 -> 완료 확정의 정상 플로우
- 오프라인 큐 적재 후 재연결 시 FIFO 재동기화
- 중복 요청 재전송 시 데이터 중복 미발생 확인

## 9) 연계 문서
- `docs/architecture/01_api_design.md`
- `docs/architecture/03_session_save_flow.md`
- `docs/product/03_core_spec.md`
- `docs/architecture/04_env_policy.md`

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 파일명 `04_persistence_design` → `06_persistence_design` 변경, 연계 문서 경로 정리 | @cursor-agent |
| 2026-02-26 | Flutter 저장 계층 설계안 초안 신설 (`repository`/`infrastructure`/DTO/오류/테스트 포인트) | @cursor-agent |
