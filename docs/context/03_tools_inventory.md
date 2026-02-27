# Tools Inventory (pre-commit 최소화 판단용)

`tools` 폴더 내 파일의 역할과 pre-commit 관점 필요도를 정리한 문서입니다.

## 1) 대상 범위

- 기준 시점: 2026-02-26
- 대상 디렉터리: `tools/`
- 파일 수: 5개

## 2) 파일별 정리


| 파일                                        | 역할                                                                 | 현재 사용 지점                                          | pre-commit 필요도            | 필요하지 않다고 판단될 때의 이유                                      |
| ----------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------- | ------------------------- | ------------------------------------------------------- |
| `tools/check_lf_line_endings.dart`        | 스테이징된 `tools/`, `.githooks/` 파일에 CRLF가 섞였는지 검사                     | `.githooks/pre-commit` 1순위 검사                     | **필수**                    | 제거 시 macOS/Linux에서 훅 실행 실패 가능성 증가 (shebang/스크립트 EOL 이슈) |
| `tools/check_navigation_routes_sync.dart` | 네비게이션 코드 변경 시 `docs/architecture/05_navigation_routes.md` 동시 수정 강제 | `.githooks/pre-commit`, `Makefile`의 `nav-check`   | **필수(문서 동기화 정책 유지 시)**    | 정책을 포기하지 않는 한 제거 근거가 약함. 제거하면 라우트 문서 누락 회귀 위험 증가        |
| `tools/check_project_state_sync.dart`     | 구현/규칙 관련 변경 시 `docs/context/01_project_state.md` 동시 수정 강제          | `.githooks/pre-commit`, `Makefile`의 `state-check` | **필수(현재 운영 방식 기준)**       | 제거 시 프로젝트 상태 문서가 코드와 빠르게 어긋날 수 있음                       |
| `tools/check_todo_progress_sync.dart`     | `docs/TODO.md` 진행률 표기와 상세 TODO 체크박스 수량 일치 검증                       | `.githooks/pre-commit`, `Makefile`의 `todo-check`  | **필수(자동 동기화 품질게이트 유지 시)** | 제거하면 진행률 표기가 수동 관리로 돌아가 일관성 저하 가능                       |
| `tools/sync_docs_todo_progress.dart`      | `docs/TODO.md` 진행률을 실제 체크박스 수로 자동 갱신(수정 도구)                        | `Makefile`의 `todo-sync`                           | **선택(유틸리티)**              | pre-commit에서 직접 실행되지 않음. 수동 편집으로 대체 가능하면 삭제 후보          |


## 3) 최소화 관점 결론

- pre-commit만 동작하면 되는 최소 구성은 다음 4개 검사 스크립트입니다.
  - `tools/check_lf_line_endings.dart`
  - `tools/check_navigation_routes_sync.dart`
  - `tools/check_project_state_sync.dart`
  - `tools/check_todo_progress_sync.dart`
- `tools/sync_docs_todo_progress.dart`는 pre-commit 실행 필수는 아니므로, "자동 수정 도구까지 유지할지" 정책에 따라 삭제 가능 파일입니다.

## 4) 삭제 후보 판단 기준 (`tools/sync_docs_todo_progress.dart`)

- 삭제해도 되는 경우
  - `docs/TODO.md` 진행률 업데이트를 항상 수동으로 처리할 수 있고
  - pre-commit 실패 시 수동 수정 절차를 팀이 감당할 수 있을 때
- 유지 권장 경우
  - TODO 항목이 자주 변해 수동 반영 누락이 반복될 때
  - pre-commit 실패를 빠르게 복구하는 자동화 커맨드(`make todo-sync`)가 필요할 때

