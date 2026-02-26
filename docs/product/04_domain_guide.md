# Domain Guide

`docs/product` 내 도메인 개념의 해석 기준과 참조 순서를 안내합니다.

## 1) 목적
- 용어 정의 자체는 `docs/product/01_glossary.md`를 기준으로 한다.
- 이 문서는 용어 간 관계와 해석 맥락을 설명한다.
- 루트 `README.md`에서 다루지 않는 도메인 상세를 이 문서로 위임한다.

## 2) 핵심 개념 관계
- `Exercise`는 운동 종목의 정의 데이터다. (무엇을 할지)
- `Session`은 실제 수행 이력 데이터다. (무엇을 했는지)
- 관계는 `Exercise` 1 : N `Session`이다.
- 각 `Session`은 정확히 하나의 `Exercise`를 참조한다.
- 저장 모델 관점에서는 `WorkoutSession -> SessionExercise`가 `1:N`, `SessionExercise -> RepetitionLog`가 `1:N`이다.
- `WorkoutSession`의 `RepetitionLog` 개수는 하위 `SessionExercise`들의 로그 수 합으로 결정된다.

### 2-1) 문서 간 명명 대응
- 제품/도메인 문서에서는 상위 개념을 `Session`으로 표기한다.
- 저장/API 문서(`docs/architecture/01_api_design.md`)에서는 저장 엔티티를 `WorkoutSession`, `SessionExercise`, `RepetitionLog`로 구체화해 표기한다.
- 두 표기는 동일 도메인(`Session`)의 추상/구현 레벨 차이이며, 의미 충돌로 해석하지 않는다.

## 3) 문서 역할 분리
- `01_glossary.md`: 용어 정의와 표기 원칙
- `02_use_cases.md`: 사용자 시나리오와 예외/실패 흐름
- `03_core_spec.md`: 도메인 모델과 비즈니스 규칙
- `04_domain_guide.md`: 개념 관계 및 해석 기준

## 4) 변경 원칙
- 용어가 바뀌면 먼저 `01_glossary.md`를 수정한다.
- 관계/해석이 바뀌면 이 문서를 수정하고 `02_use_cases.md`, `03_core_spec.md`를 동기화한다.

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 저장 모델 관계(`1:N`, `1:N`, 합계 기준) 및 API 문서 명명 대응 규칙 추가 | @cursor-agent |
| 2026-02-24 | 변경 이력 정책 섹션 도입 | @owner |
