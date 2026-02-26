# Social Login TODO

`소셜 로그인 작업 정의/구현`의 상세 TODO를 관리한다.

## 상태
- 우선순위: P1
- 목표: Supabase Auth 기반 소셜 로그인(1차: Google) 구현 준비

## 상세 TODO
- [ ] 지원 로그인 제공자 범위 확정 (1차 릴리즈: Google 고정)
- [ ] 인증 아키텍처 확정 (Supabase Auth 단독, Next.js 웹뷰 선행 없음)
- [ ] `docs/architecture/01_api_design.md`에 인증 플로우 시퀀스 추가 (앱 시작/로그인/토큰 갱신/로그아웃)
- [ ] Supabase Auth 연동 방식 확정 (OAuth redirect, deep link callback 처리)
- [ ] Supabase `Authentication > URL Configuration` 값 확정 (`Site URL` 임시값, `Redirect URLs` 실제 앱 콜백 등록)
- [ ] 소셜 로그인 콜백 딥링크 규격 확정 (`<scheme>://<host>`), 환경별(dev/prod) 네이밍 규칙 정의
- [ ] Flutter 라우팅 기준 로그인 게이트 정의 (미인증 진입 차단 및 복귀 경로)
- [ ] 세션/토큰 저장 정책 확정 (secure storage 사용, 만료 시 refresh 우선)
- [ ] 사용자 프로필 최소 스키마 확정 (`id`, `email`, `provider`, `created_at`)
- [ ] 최초 로그인 시 사용자 레코드 upsert 규칙 문서화
- [ ] 로그아웃 처리 정책 확정 (로컬 캐시 제거 범위, 진행 중 세션 보존 여부)
- [ ] 인증 실패 에러 UX 정의 (취소/네트워크 실패/계정 충돌)
- [ ] 플랫폼별 설정 TODO 분리 (1차 범위: Android `intent filter` 중심)
- [ ] Android `AndroidManifest.xml`에 커스텀 스킴 `intent-filter` 적용 및 검증
- [ ] Supabase OAuth `redirectTo`와 대시보드 `Redirect URLs` 일치 검증 체크리스트 추가
- [ ] 딥링크 사전 점검 절차 문서화 (Android `adb` 기준 앱 호출 테스트)
- [ ] 플레이스토어 등록 전 단계에서도 Android 딥링크/소셜 로그인 개발·테스트 가능 가이드 명시
- [ ] QA 체크리스트 작성 (Google 신규 로그인, 재로그인, 토큰 만료 복구, 로그아웃 이후 접근 차단)
- [ ] iOS/Apple 로그인 관련 후속 이슈를 `docs/todo/07_ios_release_apple_login.md`로 이관

## 01_supabase_persistence 연계 이관 TODO
- [ ] 세션 저장 API 연결 구현 (Supabase 자동 REST/RPC 기반 `create`/`save repetition`/`complete`)
  - 실행 절차(소셜 로그인 선행 반영)
    1. 소셜 로그인 성공 후 세션 access token이 확보되는지 확인한다.
    2. 확보한 access token이 저장 API 요청 헤더(`Authorization: Bearer <token>`)로 전달되는지 확인한다.
    3. 세션 시작 시 `workout_sessions`에 `create` 요청을 보낸다.
    4. 세트 완료 시 `repetition_logs`에 `save repetition` 요청을 보내고 `idempotency_key`를 함께 관리한다.
    5. 세션 종료 시 `workout_sessions`의 상태/완료 시각을 `complete` update로 반영한다.
    6. 네트워크/인증 만료/권한(RLS)/스키마 불일치를 분리 처리한다.
    7. 최소 검증(정상 저장, 중복 저장 방지, 재로그인 후 재시도 성공)을 수행한다.
  - 구현 산출물 체크리스트
    - `infrastructure` 계층의 Supabase REST/RPC 메서드(`create`/`saveRepetition`/`complete`) 연결 완료
    - `presentation` 저장 상태(`idle/saving/saved/error`) 및 사용자 메시지 반영
    - 실패 로그에 요청 식별자/에러 코드 기록(개인정보, 키 원문 제외)
- [ ] 저장 실패 에러 분류표 작성 (MVP 범위: 네트워크/인증 만료/권한/스키마 불일치)
- [ ] `workout_provider` 기준 저장 상태 모델 검증/보완 (`idle/saving/saved/error`, 사용자 메시지 정책)
- [ ] QA 체크리스트 작성 (MVP 범위: 정상 저장, 중복 저장 방지, 재로그인 후 동기화)

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | P4(iOS + Apple) 항목을 별도 문서(`docs/todo/07_ios_release_apple_login.md`)로 분리 | @cursor-agent |
| 2026-02-26 | P1 범위를 Android + Google 로그인으로 고정하고 iOS/Apple 항목을 P4로 분리 | @cursor-agent |
| 2026-02-26 | `01_supabase_persistence`의 남은 MVP TODO를 소셜 로그인 선행 이슈로 이관 | @cursor-agent |
| 2026-02-26 | 기존 `docs/TODO.md`의 소셜 로그인 상세 체크리스트 분리 | @cursor-agent |
