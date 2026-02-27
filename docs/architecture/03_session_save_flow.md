# 세션 저장 API 플로우

세션 생성, 세트 저장, 멱등성, 재시도, 완료 확정의 상세 플로우를 정의한다.  
API 계약 및 엔티티 매핑은 `docs/architecture/01_api_design.md`를 따른다.

## 1) 세션 시작(초기 생성)

1. 클라이언트가 `POST /sessions`로 세션을 생성한다.
2. 서버는 `workout_sessions`에 초기 레코드를 생성한다.
   - `is_completed=false`, `repetition_count=0`, `points_awarded=0`
3. 서버는 생성된 `sessionId`를 반환하고, 클라이언트는 이후 저장 요청에서 이를 사용한다.

## 2) 세트 완료 시 즉시 저장

1. 클라이언트는 세트 완료마다 `POST /sessions/{id}/repetitions`를 호출한다.
2. 요청 바디에는 최소 `sessionExerciseId`, `repIndex`, `loggedAt`, `elapsedSeconds`를 포함한다.
3. 서버는 `repetition_logs`에 append 저장하고, 같은 처리 흐름에서 아래를 갱신한다.
   - `session_exercises.actual_reps`
   - `workout_sessions.repetition_count`
4. 응답은 최신 집계값(`actualReps`, `repetitionCount`)을 포함한다.

## 3) 멱등성/중복 방지

- 멱등성(Idempotency) 용어 정의는 `docs/product/01_glossary.md`를 따른다.
- 동일 세트 재전송은 `session_exercise_id + rep_index` 유니크 키로 중복 insert를 방지한다.
- 이미 처리된 요청은 `409 IDEMPOTENCY_CONFLICT` 또는 최신 상태를 재반환하는 방식으로 멱등 처리한다.

## 4) 저장 실패/재시도

- 네트워크 또는 일시 오류 시 클라이언트는 로컬 큐에 요청을 적재한다.
- 재연결 시 큐를 FIFO 순서로 재전송한다.
- 서버는 멱등성 규칙으로 중복 반영을 방지한다.

## 5) 세션 완료 확정

1. 클라이언트가 `POST /sessions/{id}/complete`를 호출한다.
2. 서버는 `is_completed=true`, `end_time`, `duration_seconds`, `points_awarded`를 1회 확정 저장한다.
3. 이미 완료된 세션에 대한 재요청은 기존 결과를 반환한다(멱등).

## 연계 문서

- `docs/architecture/01_api_design.md` (API 계약, 엔티티 매핑)
- `docs/architecture/06_persistence_design.md` (저장 계층 설계)
- `docs/product/01_glossary.md` (멱등성 정의)

## 변경 이력

| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 세션 저장 API 플로우 문서 분리 | @cursor-agent |
| 2026-02-26 | 세션 저장 API 플로우(세션 생성/세트 저장/멱등/재시도/완료 확정) 규칙 추가 | @cursor-agent |
