# Docs Index

`docs` 폴더의 정보 구조, 우선순위, 읽기 순서를 정의합니다.

## 핵심 원칙 (빠른 참조)
- 비즈니스 규칙/정책은 `domain` 및 `application(usecase)` 레이어에 둡니다.
- `presentation` 레이어는 UI 표현/입력 처리와 유스케이스 호출에 집중합니다.
- 상세 규칙은 `docs/rules/01_ddd_convention.md`의 `레이어 책임 분리` 섹션을 우선 따릅니다.

## 1) 폴더 구조
- `docs/README.md`: 문서 인덱스와 운영 규칙
- `docs/TODO.md`: 문서 정비 작업 목록
- `docs/context/`: 프로젝트 상태/완료 기준 (`01_project_state.md`, `02_done_definition.md`)
- `docs/product/`: 용어 표준, 유스케이스, 도메인 스펙, 도메인 해설
- `docs/design/`: UI/UX 가이드
- `docs/architecture/`: API 및 시스템 설계 초안, 이동 루트 레지스트리 (`02_navigation_routes.md`)
- `docs/rules/`: 아키텍처/개발 규칙

## 2) 문서 우선순위 (Source of Truth)
- 파일명 접두사 규칙: 숫자가 작을수록 우선순위가 높다. (예: `01_` > `02_`)
- 전역 Source of Truth는 이 섹션의 우선순위 체계를 따른다.
- 프로젝트 현재 상태/전환 기준은 `docs/context/01_project_state.md`를 우선 기준으로 따른다.
- 프로젝트 완료/출시 가능 판정 기준은 `docs/context/02_done_definition.md`를 따른다.
- 용어/표기 기준은 `docs/product/01_glossary.md`를 별도 기준으로 따른다.
- 1순위: `docs/context/01_project_state.md`
- 2순위: `docs/rules/01_ddd_convention.md`
- 3순위: `docs/product/01_glossary.md`, `docs/product/02_use_cases.md`, `docs/product/03_core_spec.md`, `docs/product/04_domain_guide.md`
- 4순위: `docs/design/01_ui_design.md`, `docs/architecture/01_api_design.md`
- 5순위: `docs/TODO.md`

충돌 시 상위 우선순위 문서를 기준으로 하위 문서를 수정합니다.

## 3) 권장 읽기 순서
1. `docs/context/01_project_state.md`
2. `docs/context/02_done_definition.md`
3. `docs/rules/01_ddd_convention.md`
4. `docs/product/01_glossary.md`
5. `docs/product/02_use_cases.md`
6. `docs/product/03_core_spec.md`
7. `docs/product/04_domain_guide.md`
8. `docs/design/01_ui_design.md`
9. `docs/architecture/01_api_design.md`
10. `docs/architecture/02_navigation_routes.md`
11. `docs/TODO.md`

## 4) 작성 규칙
- `docs` 루트에는 `README.md`, `TODO.md`만 둔다.
- 상세 문서는 목적별 하위 폴더에 배치한다.
- 각 문서는 단일 H1을 사용하고, 섹션은 `##` 기준으로 정리한다.
- 변경 시 관련 문서를 최소 2개 이상 동기화한다.
- AI 기반 개발 중 누락 방지를 위해, 작업 착수 전/완료 후 `docs`에 요구사항·결정사항·TODO 반영 여부를 확인한다.
- 코드 변경이 발생한 작업은 문서 갱신 확인 없이 완료로 간주하지 않는다.
- 화면 이동 코드가 추가/삭제/변경되면 `docs/architecture/02_navigation_routes.md`를 같은 작업에서 반드시 동기화한다.
- 커밋 가드: `tools/check_navigation_routes_sync.dart`로 라우트 변경 시 문서 동기화 여부를 자동 검증한다.
- 공통 실행: `Makefile`의 `nav-check`, `nav-hook-install` 타깃을 사용해 OS별 명령 차이를 줄인다.

## 문서 참조 원칙 (토큰 최적화)

1. 시작은 항상 이 문서(README)에서 한다.
2. 작업 유형에 맞는 문서만 선택적으로 읽는다.
3. 1차 문서 탐색은 최대 2~3개 파일로 제한한다.
4. 긴 문서는 관련 섹션만 부분 확인한다.
5. 정보가 부족할 때만 문서를 1개씩 추가한다.

## 5) 문서 동기화 검토 체크리스트
- [ ] 용어가 `docs/product/01_glossary.md` 기준과 일치하는가? (`운동/Exercise`, `세션/Session`, `repetitionCount` 등)
- [ ] 루트 `README.md`는 개요만 유지하고 상세 정의는 `docs` 하위 문서에만 두었는가?
- [ ] 루트 `README.md`의 문서 진입 링크가 `docs/README.md`를 중심으로 연결되는가?
- [ ] 문서 간 충돌 시 `## 2) 문서 우선순위` 기준으로 하위 문서를 정리했는가?
- [ ] 변경된 문서와 연관된 최소 2개 문서를 함께 동기화했는가?

## 6) 변경 이력 정책
- 대상: `docs` 하위 핵심 문서 전체 (`context`, `product`, `design`, `architecture`, `rules`)
- 형식: 각 문서 하단에 `## 변경 이력` 섹션을 두고 표 형식으로 기록한다.
- 기본 컬럼: `날짜(YYYY-MM-DD) | 변경 요약 | 작성자`
- 기록 기준: 기능/정책/인터페이스/운영 기준에 영향이 있는 변경은 반드시 1줄 이상 기록한다.
- 예외 기준: 오탈자 수정 등 의미 변경이 없는 편집은 생략 가능하나, 릴리즈 직전 검토 시 재확인한다.

예시:

| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-24 | 초기 작성 | @owner |

## 7) 릴리즈 단위 문서 검토 프로세스
- 템플릿: `docs/release/RELEASE_DOC_CHECKLIST_TEMPLATE.md`
- 릴리즈 파일: `docs/release/YYYY-MM-rN.md` 형식으로 생성한다. (예: `2026-02-r1.md`)
- 운영 시점:
  - PR 머지 전: 작성자가 체크리스트 초안을 작성한다.
  - 릴리즈 직전: 리뷰어가 문서 반영 상태를 검증한다.
  - 릴리즈 후: 최종 결과(`done/date/reviewer`)를 기록한다.

