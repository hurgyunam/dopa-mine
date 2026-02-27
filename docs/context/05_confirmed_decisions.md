# 확정 이슈 모음 (Confirmed Decisions)

TODO·아키텍처 문서에서 **방식 확정**, **정책 확정** 등으로 결론 난 항목을 한곳에 모아 둡니다.  
새로 확정된 항목은 해당 TODO/아키텍처 문서 반영 후, 이 문서에도 요약을 추가합니다.

## 1) 인증·소셜 로그인


| 확정 항목               | 내용 요약                                                                   | 출처                                         |
| ------------------- | ----------------------------------------------------------------------- | ------------------------------------------ |
| 지원 소셜 로그인 플랫폼 (1차)  | Google 전용. Apple/Kakao 등은 후속(`docs/todo/07_ios_release_apple_login.md`) | `docs/todo/02_social_login.md`             |
| 인증 서비스·구현 방식        | Supabase Auth만 사용. Next.js 웹뷰로 OAuth 처리하는 방식은 사용하지 않음                   | `docs/todo/02_social_login.md`             |
| Supabase Auth 연동 방식 | OAuth redirect 후 앱이 **커스텀 스킴 딥링크**로 콜백 수신                               | `docs/architecture/02_auth_flow.md` 2) 로그인 |
| 소셜 로그인 콜백 딥링크 스킴 | 환경별 스킴(안 B): dev `com.heokyunam.dopamine.dev://auth/callback`, prod `com.heokyunam.dopamine://auth/callback` | `docs/todo/02_social_login.md` §소셜 로그인 콜백 딥링크 규격 (확정), 루트 `README.md` §앱 식별 |
| 세션/토큰 저장 정책 | secure storage 사용, 만료 시 refresh 우선·실패 시 토큰 삭제 후 로그인 유도 | `docs/todo/02_social_login.md` §세션/토큰 저장 정책 |
| 사용자 프로필 최소 스키마 | `id`, `email`, `provider`, `created_at` | `docs/todo/02_social_login.md` §사용자 프로필 최소 스키마 |


## 2) API·에러 규약


| 확정 항목       | 내용 요약                                                                 | 출처                                      |
| ----------- | --------------------------------------------------------------------- | --------------------------------------- |
| 인증 규약       | `Authorization: Bearer <access_token>`, Supabase Auth JWT 기준          | `docs/architecture/01_api_design.md` 4) |
| 에러 응답 바디 표준 | `error.code`, `message`, `details`, `requestId`, `timestamp` 등 공통 스키마 | `docs/architecture/01_api_design.md` 5) |


## 3) 저장·Persistence


| 확정 항목             | 내용 요약                                                                       | 출처                                                                           |
| ----------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| 저장 트리거 시점         | 세트 완료 즉시 저장, 실패 시 로컬 큐 재시도, 세션 완료 시 최종 확정                                   | `docs/product/03_core_spec.md`, `docs/todo/01_supabase_persistence.md`       |
| Supabase 환경 변수 규격 | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`/`SUPABASE_ANON_KEY`, 로컬/배포 분리 정책 | `docs/architecture/04_env_policy.md`, `docs/todo/01_supabase_persistence.md` |
| RLS 정책 방향         | 사용자 본인 데이터만 조회/쓰기                                                           | `docs/todo/01_supabase_persistence.md`, 마이그레이션 SQL                           |


## 4) 환경·도구


| 확정 항목          | 내용 요약                                                     | 출처                                          |
| -------------- | --------------------------------------------------------- | ------------------------------------------- |
| 환경 변수 파일/주입 정책 | 로컬 `.env`, 배포 시 시크릿/CI 주입, 파일명 규칙                         | `docs/architecture/04_env_policy.md`        |
| 라우트 문서 동기화 정책  | 코드 변경 시 `docs/architecture/05_navigation_routes.md` 동시 수정 | `docs/architecture/05_navigation_routes.md` |


## 5) 문서·운영


| 확정 항목        | 내용 요약                                     | 출처                              |
| ------------ | ----------------------------------------- | ------------------------------- |
| 변경 이력 정책     | 문서별 변경 이력(날짜/요약) 섹션 유지                    | `docs/rules/01_docs_writing.md` |
| 문서 충돌 시 우선순위 | `docs/README.md`의 Source of Truth 우선순위 따름 | `docs/README.md` 2)             |


---

## 유지보수

- **추가**: TODO/아키텍처에서 "확정" 처리한 항목이 생기면, 위 표에 **확정 항목 / 내용 요약 / 출처** 형태로 추가한다.
- **수정·폐기**: 확정 내용이 바뀌면 출처 문서를 먼저 수정한 뒤, 이 문서의 해당 행을 갱신하거나 제거한다.

## 연계 문서

- `docs/README.md` (문서 인덱스)
- `docs/context/02_done_definition.md` (완료 판정 기준)
- `docs/todo/02_social_login.md`, `docs/todo/01_supabase_persistence.md` (에픽별 상세 TODO)

## 변경 이력


| 날짜         | 변경 요약                               | 작성자           |
| ---------- | ----------------------------------- | ------------- |
| 2026-02-27 | 소셜 로그인 콜백 딥링크 환경별 스킴(안 B) 확정 반영 — dev/prod 스킴 분리 | @cursor-agent |
| 2026-02-27 | 소셜 로그인 콜백 딥링크 스킴(역도메인 com.heokyunam.dopamine) 확정 항목 추가 | @cursor-agent |
| 2026-02-27 | 소셜 로그인 확정 항목 2건 추가 (세션/토큰 저장 정책, 사용자 프로필 최소 스키마) | @cursor-agent |
| 2026-02-27 | 확정 이슈 모음 문서 신설 (인증·API·저장·환경·문서 운영) | @cursor-agent |


