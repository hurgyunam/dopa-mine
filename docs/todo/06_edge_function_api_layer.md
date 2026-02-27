# Edge Function API Layer TODO

Supabase 자동 REST/RPC 기반 MVP 저장 경로를 유지하면서, 후속으로 Edge Function API 계층화를 준비하기 위한 TODO를 관리한다.

## 상태
- 우선순위: P3
- 현재 목표: Edge Function 도입 필요성/범위 확정 및 단계적 전환 기준 정의
- 선행 조건: `docs/todo/01_supabase_persistence.md`의 MVP 저장 경로(`create`/`save repetition`/`complete`) 안정화
- 연계 문서: `docs/architecture/01_api_design.md`, `docs/architecture/06_persistence_design.md`

## 진행 예정 (P3)
- [ ] Edge Function 도입 기준 문서화 (REST/RPC 유지 vs Function 전환 트리거 정의)
- [ ] 세션 저장 시나리오별 Function 책임 경계 초안 작성 (`create`/`save repetition`/`complete`)
- [ ] 인증/권한/에러 매핑 정책 정리 (RLS와 Function 책임 분리)
- [ ] 배포/롤백/모니터링 최소 운영 체크리스트 정리 (MVP 이후 단계)

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | Supabase 저장 작업에서 분리된 Edge Function API 계층화 P3 TODO 신설 | @cursor-agent |
