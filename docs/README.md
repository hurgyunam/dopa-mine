# Docs Index

`docs` 폴더의 정보 구조, 우선순위, 읽기 순서를 정의합니다.

## 핵심 원칙 (빠른 참조)
- 비즈니스 규칙/정책은 `domain` 및 `application(usecase)` 레이어에 둡니다.
- `presentation` 레이어는 UI 표현/입력 처리와 유스케이스 호출에 집중합니다.
- 상세 아키텍처 규칙은 `.cursor/rules/architecture-ddd.mdc`를 우선 따릅니다.

## 1) 폴더 구조
- `docs/README.md`: 문서 인덱스와 우선순위
- `docs/TODO.md`: 문서 정비 작업 목록
- `docs/todo/`: 에픽별 상세 TODO (`01_supabase_persistence.md`, `02_social_login.md`, `07_ios_release_apple_login.md` 등)
- `docs/context/`: 프로젝트 상태/완료 기준/도구 인벤토리/확정 이슈/사전 점검 절차 (`01_project_state.md`, `02_done_definition.md`, `03_tools_inventory.md`, `05_confirmed_decisions.md`, `06_pre_release_checks.md`)
- `docs/product/`: 용어 표준, 유스케이스, 도메인 스펙, 도메인 해설
- `docs/design/`: UI/UX 가이드
- `docs/architecture/`: API 및 시스템 설계 초안 (`01_api_design`, `02_auth_flow`, `03_session_save_flow`), 환경 변수 정책 (`04_env_policy`), 이동 루트 (`05_navigation_routes`), 저장 계층 설계 (`06_persistence_design`)
- `docs/rules/`: 문서 작성/운영 규칙
- `docs/issues/`: 채팅별 이슈 로그와 통합 인덱스 (`README.md`, `ISSUES.md`, `CHAT_*.md`)

## 2) 문서 우선순위 (Source of Truth)
- 파일명 접두사 규칙: 숫자가 작을수록 우선순위가 높다. (예: `01_` > `02_`)
- 전역 Source of Truth는 이 섹션의 우선순위 체계를 따른다.
- 프로젝트 현재 상태/전환 기준은 `docs/context/01_project_state.md`를 우선 기준으로 따른다.
- 프로젝트 완료/출시 가능 판정 기준은 `docs/context/02_done_definition.md`를 따른다.
- 용어/표기 기준은 `docs/product/01_glossary.md`를 별도 기준으로 따른다.
- 1순위: `docs/context/01_project_state.md`
- 2순위: `.cursor/rules/architecture-ddd.mdc`
- 3순위: `docs/product/01_glossary.md`, `docs/product/02_use_cases.md`, `docs/product/03_core_spec.md`, `docs/product/04_domain_guide.md`
- 4순위: `docs/design/01_ui_design.md`, `docs/architecture/01_api_design.md`
- 5순위: `docs/TODO.md`

충돌 시 상위 우선순위 문서를 기준으로 하위 문서를 수정합니다.

## 3) 권장 읽기 순서
1. `docs/context/01_project_state.md`
2. `docs/context/02_done_definition.md`
3. `docs/context/03_tools_inventory.md`
4. `docs/context/05_confirmed_decisions.md` (방식·정책 확정 항목 참조)
5. `.cursor/rules/architecture-ddd.mdc`
6. `docs/product/01_glossary.md`
7. `docs/product/02_use_cases.md`
8. `docs/product/03_core_spec.md`
9. `docs/product/04_domain_guide.md`
10. `docs/design/01_ui_design.md`
11. `docs/architecture/01_api_design.md`
12. `docs/architecture/02_auth_flow.md`
13. `docs/architecture/03_session_save_flow.md`
14. `docs/architecture/04_env_policy.md`
15. `docs/architecture/05_navigation_routes.md`
16. `docs/architecture/06_persistence_design.md`
17. `docs/issues/README.md`
18. `docs/issues/ISSUES.md`
19. `docs/TODO.md`
20. `docs/todo/01_supabase_persistence.md`
21. `docs/todo/02_social_login.md`
22. `docs/todo/07_ios_release_apple_login.md`

## 4) 문서 작성/운영 규칙 위치
- 문서 작성 규칙, 동기화 체크리스트, 변경 이력 정책, 릴리즈 문서 검토 프로세스의 단일 기준 문서는 `docs/rules/01_docs_writing.md`다.
- 본 문서는 인덱스/우선순위/읽기 순서만 유지하고, 운영 상세 규칙은 `docs/rules/01_docs_writing.md`에서 관리한다.

## 5) 문서 참조 원칙 (토큰 최적화)
1. 시작은 항상 이 문서(`docs/README.md`)에서 한다.
2. 작업 유형에 맞는 문서만 선택적으로 읽는다.
3. 1차 문서 탐색은 최대 2~3개 파일로 제한한다.
4. 긴 문서는 관련 섹션만 부분 확인한다.
5. 정보가 부족할 때만 문서를 1개씩 추가한다.

