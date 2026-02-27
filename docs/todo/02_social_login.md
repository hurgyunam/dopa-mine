# Social Login TODO

`소셜 로그인 작업 정의/구현`의 상세 TODO를 관리한다.

## 상태
- 우선순위: P1
- 목표: Supabase Auth 기반 소셜 로그인(1차: Google) 구현 준비

## 지원 소셜 로그인 플랫폼 (확정)
- **1차 릴리즈**: Google 전용
- **제외(후속)**: Apple, Kakao 등 → `docs/todo/07_ios_release_apple_login.md`에서 P4로 관리
- **근거**: Android 출시 + Google 로그인 우선 완료 후 iOS/Apple 로그인 진행

## 세션/토큰 저장 정책 (확정)
- **저장소**: secure storage 사용 (access token, refresh token)
- **만료 시**: refresh 우선 시도, 실패 시 로컬 토큰 삭제 후 로그인 화면 유도
- **근거**: `docs/architecture/02_auth_flow.md`, `docs/context/02_done_definition.md`

## 사용자 프로필 최소 스키마 (확정)
- **필드**: `id`, `email`, `provider`, `created_at`
- **용도**: Supabase Auth 연동 시 클라이언트/백엔드에서 참조하는 최소 식별·표시 정보
- **비고**: 확장 필드는 후속 요구에 따라 추가

## 소셜 로그인 콜백 딥링크 규격 (확정)

OAuth 완료 후 Supabase가 리다이렉트하는 URL과 앱이 수신하는 커스텀 스킴 딥링크를 동일하게 맞춘다.

| 항목 | 값 | 비고 |
| --- | --- | --- |
| **scheme (prod)** | `com.heokyunam.dopamine` | 역도메인 스킴. 루트 `README.md` §앱 식별 참조 |
| **scheme (dev)** | `com.heokyunam.dopamine.dev` | 동일 기기에서 dev/prod 빌드 공존 시 콜백 충돌 방지 |
| **host** | `auth` | 인증 콜백 전용 호스트 |
| **path** | `/callback` | OAuth callback 경로로 통일 |
| **전체 URL (prod)** | `com.heokyunam.dopamine://auth/callback` | Supabase Redirect URLs 및 `signInWithOAuth(redirectTo)`에 등록 |
| **전체 URL (dev)** | `com.heokyunam.dopamine.dev://auth/callback` | dev 빌드 전용 |

**환경별 네이밍 (확정: 안 B)**

- 스킴으로 환경 구분. dev: `com.heokyunam.dopamine.dev`, prod: `com.heokyunam.dopamine`.
- 동일 기기에서 dev 빌드와 prod 빌드를 함께 쓸 때 콜백 충돌 방지.

## 상세 TODO

**진행 순서(의존성)**  
Supabase `Redirect URLs`에 등록할 값이 곧 앱이 받을 콜백 URL(딥링크)이므로, **딥링크 규격 확정 → 플랫폼 설정(Android intent-filter) → Flutter 콜백 수신 구현 → Supabase URL Configuration 확정** 순으로 진행한다.

- [x] 지원할 소셜 로그인 플랫폼 확정 (1차 릴리즈: Google 전용)
- [x] 인증 서비스 및 로그인 구현 방식 확정 (Supabase Auth만 사용, Next.js 웹뷰로 OAuth 처리하는 방식은 사용하지 않음)
- [x] `docs/architecture/02_auth_flow.md`에 인증 플로우 시퀀스 추가 (앱 시작/로그인/토큰 갱신/로그아웃)
- [x] Supabase Auth 연동 방식 확정 (OAuth redirect + 앱 커스텀 스킴 딥링크 콜백 수신, `02_auth_flow.md` 2) 로그인 절 반영)
- [x] 세션/토큰 저장 정책 확정 (secure storage 사용, 만료 시 refresh 우선, 상단 §세션/토큰 저장 정책 반영)
- [x] 사용자 프로필 최소 스키마 확정 (`id`, `email`, `provider`, `created_at`, 상단 §사용자 프로필 최소 스키마 반영)
- [x] **1)** 소셜 로그인 콜백 딥링크 규격 확정 (`<scheme>://<host>` 또는 path 포함), 환경별(dev/prod) 네이밍 규칙 정의 — 안 B(스킴으로 환경 구분) 확정
- [x] **2)** 플랫폼별 설정 TODO 분리 (1차 범위: Android `intent filter` 중심) — `docs/architecture/05_navigation_routes.md` §3) 플랫폼별 네비게이션·딥링크 설정에 문서 기준 정리
- [x] **3)** Android `AndroidManifest.xml`에 커스텀 스킴 `intent-filter` 적용 및 검증
- [x] **4)** 딥링크 사전 점검 절차 문서화 (Android `adb` 기준 앱 호출 테스트) — `docs/context/06_pre_release_checks.md` §1
- [ ] **5)** Flutter에서 OAuth 콜백 딥링크 수신 및 code 교환·세션 저장 구현 (예: `app_links` + Supabase `exchangeCodeForSession`)
- [ ] **6)** Supabase `Authentication > URL Configuration` 값 확정 (`Site URL` 임시값, `Redirect URLs`에 확정한 딥링크 URL 등록)
- [ ] **7)** Supabase OAuth `redirectTo`와 대시보드 `Redirect URLs` 일치 검증 체크리스트 추가
- [ ] Flutter 라우팅 기준 로그인 게이트 정의 (미인증 진입 차단 및 복귀 경로)
- [ ] 최초 로그인 시 사용자 레코드 upsert 규칙 문서화
- [ ] 로그아웃 처리 정책 확정 (로컬 캐시 제거 범위, 진행 중 세션 보존 여부)
- [ ] 인증 실패 에러 UX 정의 (취소/네트워크 실패/계정 충돌)
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
| 2026-02-27 | 상세 TODO 4) 완료: 딥링크 사전 점검 절차를 docs/context/06_pre_release_checks.md에 추가 | @cursor-agent |
| 2026-02-27 | 상세 TODO 3) 완료: Android main/debug/profile Manifest에 intent-filter 적용 확인 및 체크 | @cursor-agent |
| 2026-02-27 | 소셜 로그인 콜백 딥링크 규격 안 B 확정(환경별 스킴: dev/prod), §확정 반영 및 05_confirmed_decisions 동기화, 상세 TODO 1) 체크 | @cursor-agent |
| 2026-02-27 | 딥링크 스킴 역도메인 `com.heokyunam.dopamine` 확정 반영, README §앱 식별 참조 추가, 확정 전 검토에 05_confirmed_decisions 연계 명시 | @cursor-agent |
| 2026-02-27 | 소셜 로그인 콜백 딥링크 규격 초안 섹션 추가 (scheme/host/path, 환경별 네이밍 안 A·B, 확정 전 검토 항목) | @cursor-agent |
| 2026-02-27 | 상세 TODO 진행 순서(의존성) 안내 추가, 딥링크→Supabase URL 순서로 항목 재정렬 및 1~7 단계 번호 부여, Flutter 콜백 수신 구현 항목 추가 | @cursor-agent |
| 2026-02-27 | 세션/토큰 저장 정책·사용자 프로필 최소 스키마 확정 섹션 추가 및 TODO 완료 처리 | @cursor-agent |
| 2026-02-27 | 인증 플로우 시퀀스 작업 완료 (`docs/architecture/02_auth_flow.md` 분리) | @cursor-agent |
| 2026-02-27 | 지원 로그인 제공자 범위 확정 섹션 추가 (1차: Google 전용), 관련 문서 동기화 | @cursor-agent |
| 2026-02-26 | P4(iOS + Apple) 항목을 별도 문서(`docs/todo/07_ios_release_apple_login.md`)로 분리 | @cursor-agent |
| 2026-02-26 | P1 범위를 Android + Google 로그인으로 고정하고 iOS/Apple 항목을 P4로 분리 | @cursor-agent |
| 2026-02-26 | `01_supabase_persistence`의 남은 MVP TODO를 소셜 로그인 선행 이슈로 이관 | @cursor-agent |
| 2026-02-26 | 기존 `docs/TODO.md`의 소셜 로그인 상세 체크리스트 분리 | @cursor-agent |
