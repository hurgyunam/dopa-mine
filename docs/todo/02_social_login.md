# Social Login TODO

`소셜 로그인 작업 정의/구현`의 상세 TODO를 관리한다.

## 상태
- 우선순위: P1
- 목표: Supabase Auth 기반 소셜 로그인 1차 릴리즈 범위 확정 및 구현 준비

## 상세 TODO
- [ ] 지원 로그인 제공자 범위 확정 (Google, Apple, Kakao 중 1차 릴리즈 대상)
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
- [ ] iOS/Android 플랫폼별 설정 TODO 분리 (`URL scheme`, `intent filter`, `signing` 확인)
- [ ] Android `AndroidManifest.xml`에 커스텀 스킴 `intent-filter` 적용 및 검증
- [ ] iOS `Info.plist`에 URL Types 설정 적용 및 검증
- [ ] Supabase OAuth `redirectTo`와 대시보드 `Redirect URLs` 일치 검증 체크리스트 추가
- [ ] 딥링크 사전 점검 절차 문서화 (Android `adb`, iOS `simctl`로 앱 호출 테스트)
- [ ] 플레이스토어 등록 전 단계에서도 딥링크/소셜 로그인 개발·테스트 가능 가이드 명시
- [ ] QA 체크리스트 작성 (신규 로그인, 재로그인, 토큰 만료 복구, 로그아웃 이후 접근 차단)

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 기존 `docs/TODO.md`의 소셜 로그인 상세 체크리스트 분리 | @cursor-agent |
