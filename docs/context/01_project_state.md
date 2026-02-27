# Project State

프로젝트의 현재 구현 상태와 아키텍처 전환 방향을 기록하는 기준 문서입니다.

## 1) 현재 구현 상태
- 현재 앱은 `UI 프로토타입` 우선 단계로 전환되어 화면 구조/문구/전환 흐름 중심으로 제공됨
- 홈/세션/리포트 흐름은 데모 용도로 탐색 가능하며, 핵심 액션은 미리보기 기반으로 동작함
- 데이터 저장, 포인트 지급, 히스토리 조회, 세션 복구 등 실제 기능은 아직 미구현 상태
- 소셜 로그인: 딥링크 규격·Android intent-filter·사전 점검 절차는 완료됨(`docs/todo/02_social_login.md` 1)~4)); Flutter 콜백 수신·Supabase 연동은 미구현
- `UC-01~UC-05`는 기능 구현 명세로 유지하되, 개발 우선순위는 UI 검증 -> 기능 구현 순서로 진행

## 2) 아키텍처 현황
### As-Is (현재)
- 주요 코드 구조: `app_flutter/lib/{data,models,providers,screens,services,widgets}`
- 상태 관리: `Provider`
- 저장소: 인터페이스 기반이지만 구현은 Mock(`MockSupabaseSessionRepository`) 중심

### To-Be (목표)
- DDD Feature-first 구조: `lib/src/features/{feature}/{domain,application,infrastructure,presentation}`
- 의존성 규칙: `Presentation -> Application -> Domain <- Infrastructure`
- Domain은 Pure Dart 유지, Flutter/외부 의존성은 `presentation`/`infrastructure`로 제한

## 3) 점진 전환 정책 (Migration Policy)
- 전체 리라이트 대신 기능 단위로 점진 전환
- 기존 기능 수정 시 동작 보존을 우선하고 변경 범위 내 구조 개선만 수행
- 신규 유스케이스/복잡한 로직은 `application/use_cases` + `domain` 우선 배치
- 기존 `providers`/`screens`는 당분간 공존 허용, 리팩터링 시 `presentation`으로 이동
- Domain 계층에서 Flutter/Provider/DTO 의존성 금지

## 4) 다음 단계
- UI 프로토타입 피드백을 반영해 화면 컴포넌트/문구/플로우를 확정
- `UC-01/UC-02`부터 실제 저장/완료 처리 로직을 단계적으로 연결
- 소셜 로그인(`UC-04`, 1차: Google): Flutter OAuth 콜백 수신·code 교환·세션 저장 구현 및 Supabase URL 설정 완료 후, 히스토리 조회(`UC-05`)와 함께 API/저장소 기준으로 범위 분리 설계
- `lib/src/features/...` 구조로 점진 리팩터링 (entities/repositories/use_cases/presentation 분리)

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 소셜 로그인 진행 상황 반영(딥링크·Android 설정·사전 점검 완료 / Flutter·Supabase 미구현) | @cursor-agent |
| 2026-02-27 | 소셜 로그인 1차 범위(Google 전용) 명시 | @cursor-agent |
| 2026-02-24 | UI 프로토타입 우선 단계 및 기능 미구현 상태 명시 | @owner |
| 2026-02-24 | `01_current_understanding.md`에서 `01_project_state.md`로 파일명 변경 | @owner |
| 2026-02-24 | 변경 이력 정책 섹션 도입 | @owner |
