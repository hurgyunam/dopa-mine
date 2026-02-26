# Glossary

제품/도메인/화면 문서에서 공통으로 사용하는 용어의 기준을 정의합니다.

## 1) 용어 표준 (Source of Truth)
| 구분 | 도메인/코드 용어 | UI 표기(권장) | 정의 |
| --- | --- | --- | --- |
| 엔티티 | `Exercise` | 운동 | 사용자가 선택해 수행하는 운동 종목 |
| 엔티티 | `Session` | 세션 | 1회 운동 수행 단위(시작~완료까지의 데이터 묶음) |
| 속성 | `repetitionCount` | 횟수 | 운동 반복 수행 횟수 |
| 상태 | `isCompleted` / `Completed` | 완료됨 | 세션이 완료되어 저장 가능한 확정 상태 |
| 행위 | `save` | 저장 | 세션 데이터를 저장소에 기록하는 행위 |

## 2) 표기 원칙
- 사용자 노출 문구에서는 `세션`을 기본 사용한다.
- 코드/모델/저장소 명칭은 `Session`을 기본으로 사용한다.
- 문서에서 코드 식별자를 직접 언급할 때는 백틱 표기(`Session`, `repetitionCount`)를 사용한다.
- 하나의 문서 안에서 동일 개념을 다른 용어로 혼용하지 않는다.
- 저장/API 문맥에서는 `Session`의 저장 엔티티 표기를 `WorkoutSession`, `SessionExercise`, `RepetitionLog`로 사용한다.
- 저장 엔티티의 상세 매핑과 관계 설명은 `docs/architecture/01_api_design.md`를 기준으로 한다.

## 3) 적용 범위
- 대상 문서: `docs/product/*`, `docs/context/*`, `docs/design/*`, 루트 `README.md`
- 충돌 시 이 문서를 우선 기준으로 삼아 하위 문서를 정비한다.

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | `Session` 용어의 저장/API 명명 대응(`WorkoutSession` 등) 및 참조 문서 규칙 추가 | @cursor-agent |
| 2026-02-24 | 변경 이력 정책 섹션 도입 | @owner |
