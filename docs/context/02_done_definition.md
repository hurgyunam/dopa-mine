# Done Definition

프로젝트가 "완성(출시 가능)" 상태인지 판정하기 위한 기준 문서입니다.

## 1) 목적
- 분산된 스펙/정책 문서를 단일 완료 기준으로 통합해 의사결정 속도를 높인다.
- 개발 완료와 출시 가능 상태를 구분해, 기능 구현 이후 운영 리스크를 줄인다.
- 릴리즈 시 `pass/fail` 판단 기준을 명확히 한다.

## 2) 적용 범위
- 모바일 앱(`app_flutter`)의 기능/품질/운영/보안 기준
- 대상 릴리즈: 내부 테스트, 베타, 운영 배포

## 3) 완료 판정 원칙
- 아래 6개 게이트를 모두 `pass`해야 출시 가능으로 판정한다.
- 일부 항목이 미충족이면 `conditional pass`가 아닌 `fail`로 처리한다.
- 예외 승인(위험 수용)은 릴리즈 문서에 근거/기한/담당자를 반드시 기록한다.

## 4) Release Gates
### Gate A. 기능 완결성
- `UC-01`~`UC-05` 기본 흐름이 실제 동작한다. (데모/목업 응답 제외)
- 세션 저장, 중복 완료 멱등 처리, 히스토리 조회가 실제 데이터 기준으로 검증된다.
- 소셜 로그인 성공/실패/취소 플로우가 UX 정책대로 처리된다.
- 강제 업데이트 정책(`min_supported_version`)이 앱 시작 시 적용된다.

### Gate B. 데이터/백엔드 정합성
- Supabase 스키마(`workout_sessions`, `session_exercises`, `repetition_logs`)가 확정되고 마이그레이션 이력이 관리된다.
- 버전 통제 스키마(`app_version_policies`)가 운영 정책과 일치한다.
- RLS가 "본인 데이터만 조회/쓰기" 원칙을 만족하고 예외 케이스가 문서화되어 있다.
- API 요청/응답 및 에러 표준이 `docs/architecture/01_api_design.md`와 구현이 일치한다.

### Gate C. 클라이언트 품질
- 주요 사용자 흐름(운동 시작 -> 완료 -> 리포트, 로그인, 히스토리, 업데이트 게이트)에 크래시가 없다.
- 오프라인/일시 장애 시 폴백 정책(재시도, 큐 적재, 안내 메시지)이 동작한다.
- 중복 탭/중복 요청 상황에서 화면 상태와 저장 결과가 일관된다.
- 최소 회귀 테스트 세트(스모크 + 핵심 유스케이스)가 통과한다.

### Gate D. 보안/인증
- 인증은 Supabase Auth JWT 기반으로 처리되고 만료/무효 토큰 대응이 구현되어 있다.
- 토큰 저장은 secure storage 정책을 따른다.
- 로그/에러에 민감정보(토큰, 개인식별정보)가 노출되지 않는다.
- 권한 오류(`401/403`)가 표준 에러 포맷으로 반환된다.

### Gate E. 운영 준비
- Play Console 배포 준비물(앱 정보, 스크린샷, 정책 URL, Data safety)이 준비되어 있다.
- 버전 증가 규칙(`versionCode`/`versionName`)과 배포 절차가 문서화되어 있다.
- 모니터링 지표(크래시, ANR, 로그인 실패, 저장 실패)와 롤백 기준이 정의되어 있다.
- 긴급 패치 및 강제 업데이트 전환 절차가 운영 가이드에 포함되어 있다.

### Gate F. 문서 동기화
- 변경 내용이 `use_cases`, `core_spec`, `api_design`, `glossary`에 반영되어 있다.
- 우선순위 충돌은 `docs/README.md`의 Source of Truth 규칙으로 정리되어 있다.
- 관련 문서의 `## 변경 이력`이 최신 상태다.
- 릴리즈 체크리스트 문서가 `done` 상태로 완료되어 있다.
- QA 실행 결과 문서가 `docs/release/QA_CHECKLIST_TEMPLATE.md` 형식으로 작성되어 있다.

## 5) 판정 결과 템플릿
| 게이트 | 결과(pass/fail) | 근거 문서/링크 | 비고 |
| --- | --- | --- | --- |
| Gate A. 기능 완결성 |  |  |  |
| Gate B. 데이터/백엔드 정합성 |  |  |  |
| Gate C. 클라이언트 품질 |  |  |  |
| Gate D. 보안/인증 |  |  |  |
| Gate E. 운영 준비 |  |  |  |
| Gate F. 문서 동기화 |  |  |  |

## 6) 관련 문서
- `docs/context/01_project_state.md`
- `docs/product/02_use_cases.md`
- `docs/product/03_core_spec.md`
- `docs/architecture/01_api_design.md`
- `docs/release/RELEASE_DOC_CHECKLIST_TEMPLATE.md`
- `docs/release/QA_CHECKLIST_TEMPLATE.md`

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | QA 체크리스트 템플릿 참조 추가 및 Gate F 기준 보강 | @cursor-agent |
| 2026-02-26 | 프로젝트 완료/출시 가능 판정 기준(DoD) 문서 신규 추가 | @cursor-agent |
