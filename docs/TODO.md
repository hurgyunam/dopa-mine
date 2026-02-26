# Docs TODO

문서 정합성과 유지보수성을 높이기 위한 작업 목록입니다.
마지막 업데이트: 2026-02-26

## Quick Inbox (신규 이슈 캡처)
- [ ] context: 커밋 범위 밖으로 나온 신규 이슈를 빠르게 기록하기 위한 임시 수집함
  - task: 신규 이슈를 `context/task/priority/next_action` 4필드로 먼저 남긴다
  - priority: P2
  - next_action: 항목 추가 후 가장 가까운 작업 사이클에서 P1/P2/P3 본 목록으로 이동한다

## P1 (다음 정비)
- 목표: Android 출시 + Google 소셜 로그인까지 1차 릴리즈 범위 완료
- [ ] Supabase 저장 작업 정의/구현 (진행중, 8/9 완료) (`docs/todo/01_supabase_persistence.md`)
- [ ] 소셜 로그인 작업 정의/구현 (Google 우선, 대기, 0/19 완료) (`docs/todo/02_social_login.md`)
- [ ] 강제 업데이트 기능 정의/구현 (대기, 0/13 완료) (`docs/todo/03_force_update.md`)
- [ ] Google Play 스토어 출시 절차 정의/실행 (대기, 0/12 완료) (`docs/todo/04_play_store_release.md`)

## P2 (지속 개선)
- [x] 문서 공통 Glossary 추가 (`docs/product/01_glossary.md`)
- [x] 각 문서에 변경 이력(날짜/요약) 정책 도입
- [x] 릴리즈 단위로 문서 검토 체크리스트 운영

## P3 (2차 추가 과제)
- [ ] 오프라인 큐/재동기화 확장 (대기, 0/3 완료) (`docs/todo/05_offline_queue.md`)
- [ ] Edge Function 기반 API 계층화 (대기, 0/4 완료) (`docs/todo/06_edge_function_api_layer.md`)

## P4 (플랫폼 확장)
- [ ] iOS 출시 절차 및 Apple 로그인 기능 정의/구현 (`docs/todo/07_ios_release_apple_login.md`)

## 메모
- 기준 문서는 `docs/context/01_project_state.md`
- 아키텍처 규칙은 `.cursor/rules/architecture-ddd.mdc`를 우선 적용
- 진행률 동기화: `make todo-sync`
- 신규 이슈 기록 규칙: `context/task/priority/next_action` 4필드를 사용
