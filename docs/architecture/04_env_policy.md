# Environment Policy

Supabase 연동 시 로컬/배포 환경 변수 분리 기준을 정의한다.

## 1) 환경 구분
- `local`: 개발자 개인 PC에서 실행/디버깅
- `staging`: 배포 전 검증 환경(선택)
- `production`: 실제 사용자 서비스 환경

## 2) 변수 규격
- 필수
  - `SUPABASE_URL`
  - `SUPABASE_PUBLISHABLE_KEY` (기존 코드 호환 시 `SUPABASE_ANON_KEY` 허용)
- 금지
  - `SUPABASE_SECRET_KEY`
  - `SERVICE_ROLE` 계열 키
  - DB 비밀번호

## 3) 파일/주입 정책
- 로컬 개발
  - `app_flutter/.env.local`에 실제 값을 저장한다. (`.gitignore` 대상)
  - `app_flutter/.env.example`에는 더미값만 유지한다. (커밋 대상)
- 배포 환경(staging/production)
  - `.env.staging`, `.env.production` 파일을 저장소에 추가하지 않는다.
  - CI/CD Secret 또는 배포 플랫폼 환경 변수로 주입한다.
- Flutter 실행/빌드
  - 프로젝트 표준은 `--dart-define` 또는 런타임 dotenv 중 하나로 통일한다.
  - 팀 내에서 혼용하지 않고 한 가지 방식을 기본으로 운영한다.

## 4) 보안 원칙
- 클라이언트 앱에는 `Publishable`(또는 legacy `anon`) 키만 허용한다.
- Secret/service_role/DB 비밀번호는 서버 또는 시크릿 매니저에서만 사용한다.
- 키 노출 사고 발생 시 즉시 키 로테이션(재발급)한다.

## 5) 운영 체크리스트
- 신규 개발자 온보딩 시:
  1. `app_flutter/.env.example` 복사
  2. `app_flutter/.env.local` 생성 및 값 입력
  3. 앱 실행 후 Supabase 연결 확인
- 릴리즈 전:
  - 배포 환경 변수 누락 여부 확인
  - 잘못된 키(Secret/service_role) 주입 여부 확인

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 파일명 `02_env_policy` → `04_env_policy` 변경 (architecture 우선순위 정렬) | @cursor-agent |
| 2026-02-26 | Supabase 로컬/배포 환경 변수 분리 정책 초안 작성 | @cursor-agent |
