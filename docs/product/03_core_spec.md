# Core Spec

도메인 모델과 핵심 비즈니스 규칙을 정의합니다.

## 1) 제품 개요
- 타겟 사용자: 무기력 상태에서 짧은 운동으로 시작이 필요한 사용자
- 핵심 가치: 작은 완료 경험을 빠르게 제공해 행동을 유도
- 대표 운동: Bird-dog, Superman, Bridge, T-Raise, Y-Raise

## 2) 핵심 도메인 모델
### Exercise
- `id`: 운동 식별자
- `name`: 운동명
- `description`: 설명
- `targetCount`: 권장 반복 횟수
- `metPoints`: 운동 난이도/기여도 기반 포인트 가중치

### Session
- `id`: 세션 식별자
- `exerciseId`: 수행 운동 식별자
- `startTime`: 시작 시각
- `duration`: 총 수행 시간(초)
- `repetitionCount`: 반복 횟수
- `isCompleted`: 완료 여부
- 용어/표기 기준은 `docs/product/01_glossary.md`를 따른다.

## 3) 비즈니스 규칙
- 세션 완료(`isCompleted=true`)는 단 한 번만 확정 가능
- `duration`은 0 이상, `repetitionCount`는 0 이상만 허용
- 완료 시점에만 포인트 계산/지급 수행
- 동일 세션의 중복 완료 요청은 멱등 처리

## 4) 포인트 규칙
- 기본 원칙: 운동별 `metPoints`와 수행량(`duration`, `repetitionCount`)을 조합해 계산
- 최소 보상: 완료 세션은 0보다 큰 포인트 지급을 보장
- 확장 여지: 향후 센서 입력 신뢰도/정확도 가중치 추가 가능

### 4.1 변수 정의
- `m`: 운동별 가중치 (`metPoints`, 실수, `m > 0`)
- `d`: 수행 시간(초) (`duration`, 정수, `d >= 0`)
- `r`: 반복 횟수 (`repetitionCount`, 정수, `r >= 0`)
- `C`: 완료 여부 (`isCompleted`, 불리언)

### 4.2 기본 계산식 (v1)
- 시간 기여도: `T = d / 30`
- 반복 기여도: `R = r`
- 원점수: `S_raw = m * (0.6 * T + 0.4 * R)`
- 최종 포인트:
  - `C = false` 이면 `P = 0`
  - `C = true` 이면 `P = max(1, floor(S_raw))`

### 4.3 제약/정책
- 완료 시점에 1회만 계산/지급한다.
- 동일 세션 재요청은 최초 계산 결과 `P`를 그대로 반환한다(멱등).
- 입력 제약: `d >= 0`, `r >= 0`, `m > 0`.

## 5) 구현 우선순위
1. 홈 화면 운동 선택 및 세션 진입
2. 세션 데이터 수집(시간/횟수) 및 완료 처리
3. 저장 성공 시 리포트와 포인트 피드백 제공
