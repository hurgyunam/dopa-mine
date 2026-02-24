# Docs TODO

문서 정합성과 유지보수성을 높이기 위한 작업 목록입니다.
마지막 업데이트: 2026-02-23

## P0 (즉시 반영)
- [x] `docs/README.md` 생성 (문서 인덱스/우선순위/읽기 순서 정의)
- [x] `docs/context/01_current_understanding.md`에 As-Is/To-Be/전환 정책 구조 통일
- [x] `docs/product/02_use_cases.md`에 실패/예외/경계 시나리오 반영
- [x] `docs/product/03_core_spec.md`에 `Session.repetitionCount` 및 완료 규칙 명시
- [x] `docs/design/01_ui_design.md`에 구현 매핑 체크리스트 추가
- [x] `docs` 루트 정리: `README.md`, `TODO.md`만 유지

## P1 (다음 정비)
- [x] 루트 `README.md`와 `docs` 문서 간 용어/구조 설명 동기화
  - [x] 용어 표준안 확정 (`운동/Exercise`, `세션/Session`, `횟수/repetitionCount`, `완료/Completed`, `저장/save`)
  - [x] 루트 `README.md`의 구조 설명 수준 확정 (루트는 개요만, 문서 상세는 `docs/README.md`로 위임)
  - [x] Source of Truth 표기 방식 확정 (우선순위 체계 채택, 전역 기준은 `docs/README.md`, 용어 기준은 `docs/product/01_glossary.md`)
  - [x] 문서 링크 정책 확정 (루트는 `docs/README.md` 중심으로 안내, 상세 정의는 `docs`에만 작성)
  - [x] 산출물 반영 완료 (용어 매핑 표 1개 + 루트 `README.md` 섹션 2/3/5 동기화 + 검토 체크리스트)
- [x] 포인트 계산식 상세 규칙을 `docs/product/03_core_spec.md`에 수식 수준으로 확정
- [ ] 세션 복구 정책(백그라운드/앱 종료)을 `docs/product/02_use_cases.md`와 구현 기준으로 연결
- [ ] `docs/architecture/01_api_design.md`에 인증/에러 응답 바디 표준 확정
- [ ] Supabase 저장 작업 정의/구현
  - [ ] `docs/architecture/01_api_design.md`에 저장 대상 엔티티/필드 매핑 표 추가 (`WorkoutSession`, `SessionExercise`, `RepetitionLog` 기준)
  - [ ] `docs/product/03_core_spec.md`에 저장 트리거 시점 확정 (세트 완료/세션 완료/앱 종료 직전)
  - [ ] Supabase 프로젝트 환경 변수 규격 확정 (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) 및 로컬/배포 분리 정책 문서화
  - [ ] Flutter 저장 계층 설계안 문서화 (`repository` 추상화, `infrastructure` 구현, DTO 변환 책임)
  - [ ] Supabase 테이블/인덱스 초안 작성 (`workout_sessions`, `session_exercises`, `repetition_logs`)
  - [ ] RLS 정책 초안 작성 (사용자 본인 데이터만 조회/쓰기 가능)
  - [ ] 세션 저장 API 호출 흐름 정의 (생성/업데이트/재시도/멱등성 키 처리)
  - [ ] 오프라인 시 로컬 큐 적재 후 재동기화 전략 문서화 (앱 재시작 포함)
  - [ ] 저장 실패 에러 분류표 작성 (네트워크/인증 만료/권한/스키마 불일치)
  - [ ] `workout_provider` 기준 저장 상태 모델 정의 (`idle/saving/saved/error`, 사용자 메시지 정책)
  - [ ] QA 체크리스트 작성 (정상 저장, 중복 저장 방지, 오프라인 복구, 재로그인 후 동기화)
- [ ] 소셜 로그인 작업 정의/구현
  - [ ] 지원 로그인 제공자 범위 확정 (Google, Apple, Kakao 중 1차 릴리즈 대상)
  - [ ] `docs/architecture/01_api_design.md`에 인증 플로우 시퀀스 추가 (앱 시작/로그인/토큰 갱신/로그아웃)
  - [ ] Supabase Auth 연동 방식 확정 (OAuth redirect, deep link callback 처리)
  - [ ] Flutter 라우팅 기준 로그인 게이트 정의 (미인증 진입 차단 및 복귀 경로)
  - [ ] 세션/토큰 저장 정책 확정 (secure storage 사용, 만료 시 refresh 우선)
  - [ ] 사용자 프로필 최소 스키마 확정 (`id`, `email`, `provider`, `created_at`)
  - [ ] 최초 로그인 시 사용자 레코드 upsert 규칙 문서화
  - [ ] 로그아웃 처리 정책 확정 (로컬 캐시 제거 범위, 진행 중 세션 보존 여부)
  - [ ] 인증 실패 에러 UX 정의 (취소/네트워크 실패/계정 충돌)
  - [ ] iOS/Android 플랫폼별 설정 TODO 분리 (`URL scheme`, `intent filter`, `signing` 확인)
  - [ ] QA 체크리스트 작성 (신규 로그인, 재로그인, 토큰 만료 복구, 로그아웃 이후 접근 차단)
- [ ] Google Play 스토어 출시 절차 정의/실행
  - [ ] Google Play Console 앱 생성 및 패키지명/앱명 확정
  - [ ] 릴리즈 키스토어 및 업로드 키 관리 정책 확정 (백업/권한/복구 절차 포함)
  - [ ] Android `versionCode`/`versionName` 증가 규칙 문서화
  - [ ] `aab` 릴리즈 빌드 파이프라인 정리 (로컬/CI 명령, 서명 검증 절차)
  - [ ] 개인정보처리방침/서비스 이용약관 URL 준비 및 앱 내 접근 경로 확정
  - [ ] Data safety 설문 초안 작성 (수집 데이터, 처리 목적, 암호화/삭제 정책)
  - [ ] 콘텐츠 등급/타깃 연령/광고 여부 설정 값 확정
  - [ ] 스토어 등록 정보 준비 (짧은 설명, 상세 설명, 스크린샷, 아이콘, 피처 그래픽)
  - [ ] 내부 테스트 트랙 배포 및 테스터 그룹 구성 (QA 시나리오 포함)
  - [ ] 크래시/ANR/로그인 실패 이벤트 모니터링 지표 정의 (출시 1주 집중 관찰)
  - [ ] 운영 트랙 점진 배포 전략 수립 (예: 5% -> 20% -> 100%)
  - [ ] 출시 후 롤백/핫픽스 기준 문서화 (중단 조건, 대응 책임자, 커뮤니케이션 템플릿)

## P2 (지속 개선)
- [x] 문서 공통 Glossary 추가 (`docs/product/01_glossary.md`)
- [ ] 각 문서에 변경 이력(날짜/요약) 정책 도입
- [ ] 릴리즈 단위로 문서 검토 체크리스트 운영

## 메모
- 기준 문서는 `docs/context/01_current_understanding.md`
- 아키텍처 규칙은 `docs/rules/01_ddd_convention.md`를 우선 적용
