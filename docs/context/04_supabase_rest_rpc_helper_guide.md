# Supabase REST/RPC 공통 Helper 가이드

## 변경 목적
- Flutter에서 Supabase REST 호출 시 반복되는 인증 헤더 처리(`apikey`, `Authorization: Bearer <token>`)를 공통화한다.
- 세션 저장 MVP의 `create`/`save repetition`/`complete`를 일관된 방식으로 호출할 수 있게 기반 코드를 제공한다.

## 추가된 코드
- `app_flutter/lib/services/supabase_rest_helper.dart`
  - 공통 HTTP 요청 처리
  - 공통 헤더 주입
  - 응답 파싱 및 에러 표준화(`SupabaseApiException`)
- `app_flutter/lib/services/supabase_workout_persistence_api.dart`
  - `createSession`, `saveRepetition`, `completeSession` 구현
  - `workout_sessions`, `repetition_logs` 테이블 호출
- `app_flutter/lib/services/session_repository.dart`
  - `SupabaseSessionRepository` 추가
  - 기존 `SessionRepository` 인터페이스와 연결 가능한 Supabase 저장/조회 구현
- `app_flutter/lib/constants/runtime_env.dart`
  - `.env.local` 우선, `--dart-define` fallback 기반 런타임 환경값 접근(URL/키)
- `app_flutter/lib/services/auth_session_token_provider.dart`
  - 로그인 세션 기반 access token 공급 인터페이스(`AuthSessionTokenProvider`) 정의
- `app_flutter/lib/main.dart`
  - 앱 시작 시 `.env.local` 로드 시도
  - URL/키 설정 유무에 따라 `SupabaseSessionRepository` 또는 `MockSupabaseSessionRepository` 선택
  - Supabase 요청 토큰은 `AuthSessionTokenProvider` 구현체에서 주입

## 설계 포인트
- 공통 helper는 `providers`가 아니라 `services`(infrastructure 성격)에 배치한다.
- `WorkoutProvider`는 상태 변경만 담당하고, 네트워크 호출/헤더 구성은 서비스 계층에 위임한다.
- access token이 없으면 요청 전에 즉시 예외를 발생시켜(`missing_access_token`) 원인 파악을 쉽게 한다.

## 적용 방법
1. `app_flutter/.env.local`에 아래 값을 넣는다.
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
2. 로그인 기능에서 세션 access token을 획득해 `AuthSessionTokenProvider` 구현체에 전달한다.
3. `main.dart`는 URL/키가 있으면 `SupabaseSessionRepository`, 없으면 `MockSupabaseSessionRepository`를 자동 선택한다.
4. 저장 시 `SupabaseSessionRepository` 내부에서 `createSession -> saveRepetition -> completeSession` 순서로 호출한다.
5. 필요하면 CI/배포 환경에서는 `--dart-define`로 동일 키를 주입해 `.env.local` 없이도 동작할 수 있다.

예시(개념 코드):
```dart
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<publishable_key>
```

## 검증 체크리스트
- 로그인 후 요청 헤더에 `Authorization: Bearer <token>`가 포함되는지 확인
- `createSession` 성공 후 세션 식별자 반환 확인
- 동일 `idempotency_key` 사용 시 중복 저장 방지 정책 확인
- 토큰 만료/권한 부족 시 `SupabaseApiException` 코드/메시지 확인

## 롤백 방법
- Supabase 연동 전환 이슈가 있으면 DI 지점에서 `MockSupabaseSessionRepository`를 사용하도록 되돌린다.
- 새로 추가된 파일만 제거해도 기존 mock 저장 흐름은 유지된다.
