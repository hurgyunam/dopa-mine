# Supabase Persistence TODO

`Supabase 저장 작업 정의/구현`의 상세 TODO를 관리한다.

## 상태
- 우선순위: P1
- 현재 목표: MVP 온라인 저장 완성 (`Dio fetch` 기반)
- 연계 문서: `docs/architecture/01_api_design.md`, `docs/architecture/06_persistence_design.md`

## 완료된 항목
- [x] `docs/architecture/01_api_design.md`에 저장 대상 엔티티/필드 매핑 표 추가 (`WorkoutSession`, `SessionExercise`, `RepetitionLog` 기준)
- [x] `docs/product/03_core_spec.md`에 저장 트리거 시점 확정 (세트 완료 즉시 저장 + 실패 시 로컬 큐 재시도 + 세션 완료 시 최종 확정)
- [x] Supabase CLI 등록하기 (프로젝트 링크/인증 확인 포함)
- [x] Supabase 프로젝트 환경 변수 규격 확정 (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`/`SUPABASE_ANON_KEY`) 및 로컬/배포 분리 정책 문서화 (`docs/architecture/04_env_policy.md`)
- [x] Supabase 테이블/인덱스 초안 작성 (`workout_sessions`, `session_exercises`, `repetition_logs`)
- [x] RLS 정책 초안 작성 (사용자 본인 데이터만 조회/쓰기 가능, `supabase/migrations/20260226063420_create_workout_tables.sql` 참조)
- [x] 세션 저장 API 호출 흐름 정의 (생성/업데이트/재시도/멱등성 키 처리)
- [x] Flutter 저장 계층 설계안 문서화 (`repository` 추상화, `infrastructure` 구현, DTO 변환 책임) (`docs/architecture/06_persistence_design.md`)

## 진행 중/예정 (MVP)
- [ ] 로그인 선행 의존 항목으로 `docs/todo/02_social_login.md`의 `01_supabase_persistence 연계 이관 TODO` 섹션으로 이동함

## 후속(별도 에픽 연계)
- 오프라인 큐/재동기화는 `docs/todo/05_offline_queue.md`에서 관리한다.
- Edge Function 기반 별도 API 계층 구성은 `docs/todo/06_edge_function_api_layer.md`에서 P3로 관리한다.

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 남은 MVP TODO를 소셜 로그인 선행 작업(`docs/todo/02_social_login.md`)으로 이관 | @cursor-agent |
| 2026-02-26 | `세션 저장 API 연결 구현` 항목에 Supabase 초보자용 상세 절차와 구현 산출물 체크리스트 추가 | @cursor-agent |
| 2026-02-26 | MVP 범위를 Supabase 자동 REST/RPC로 고정하고 Edge Function API 계층 이슈를 P3로 분리 | @cursor-agent |
| 2026-02-26 | 기존 `docs/TODO.md`의 Supabase 저장 상세 체크리스트 분리 | @cursor-agent |
