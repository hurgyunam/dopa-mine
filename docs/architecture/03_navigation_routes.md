# Navigation Routes

앱 화면 이동 루트의 단일 기준 문서입니다.

## 1) 현재 이동 루트
| 출발 화면 | 액션 | 도착 화면 | 코드 기준 |
| --- | --- | --- | --- |
| 홈 (`HomeScreen`) | 헤더 우측 히스토리 아이콘 탭 | 운동 이력 (`HistoryScreen`) | `app_flutter/lib/screens/home_screen.dart` |
| 홈 (`HomeScreen`) | 운동 선택 후 하단 `운동 시작` 탭 | 세션 (`SessionScreen`) | `app_flutter/lib/screens/home_screen.dart` |
| 세션 (`SessionScreen`) | 하단 `리포트 미리보기` 탭 | 리포트 (`ReportScreen`) | `app_flutter/lib/screens/session_screen.dart` |
| 리포트 (`ReportScreen`) | 하단 `홈으로` 탭 | 홈 (`HomeScreen`) | `app_flutter/lib/screens/report_screen.dart` |

## 2) 라우트 문서 자동 동기화 정책
- 라우트 추가/삭제/변경이 발생하면 같은 작업에서 이 문서를 반드시 함께 수정한다.
- PR(또는 커밋) 완료 조건에 `03_navigation_routes.md 반영`을 포함한다.
- 반영 누락 시 코드 작업은 완료로 간주하지 않는다.
- 자동 검증 스크립트(`tools/check_navigation_routes_sync.dart`)를 커밋 전에 실행한다.

### 구현 선택 기준 (Dart vs TypeScript)
- 결론: 현재 레포에서는 `Dart` 기반 체크 스크립트를 기본으로 유지한다.
- 이유 1: Flutter 프로젝트 특성상 Dart 런타임은 이미 필수 의존성이라 추가 설치가 없다.
- 이유 2: TypeScript는 일반적으로 `node` + `typescript`(또는 `tsx/ts-node`) 런타임 구성이 추가로 필요하다.
- 이유 3: 팀 온보딩 시 도구 수가 적을수록 실패 케이스가 줄어든다.

### 로컬 훅 설치
```bash
cp .githooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

```powershell
Copy-Item .githooks/pre-commit .git/hooks/pre-commit -Force
```

### 수동 검증 실행
```bash
dart run tools/check_navigation_routes_sync.dart
```

```bash
make nav-check
```

## 3) 업데이트 규칙
- 최소 업데이트 단위: `출발 화면`, `액션`, `도착 화면`, `코드 기준` 4개 컬럼
- 신규 화면 진입점이 1개라도 생기면 표에 1행 이상 추가한다.
- 기존 이동 경로의 조건(예: 버튼 활성화 조건)이 바뀌면 해당 행을 즉시 수정한다.

## 4) 운영 체크리스트
- [ ] 화면 이동 코드를 수정했는가?
- [ ] 본 문서 표에 동일 변경을 반영했는가?
- [ ] `docs/context/01_project_state.md` 또는 관련 제품 문서에도 영향 내용을 동기화했는가?

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | pre-commit 실행 최소 구성으로 정리하고 훅 설치 전용 스크립트 참조를 제거 | @owner |
| 2026-02-26 | 훅 설치 로직을 Dart 단일 스크립트로 통합하고 OS별 래퍼는 Dart 호출만 수행하도록 정리 | @owner |
| 2026-02-24 | macOS/Linux 훅 설치 스크립트 및 Makefile 실행 경로 추가, Dart 선택 기준 명시 | @owner |
| 2026-02-24 | 라우트 문서 동기화 자동 검증 스크립트/훅 설치 절차 추가 | @owner |
| 2026-02-24 | 이동 루트 레지스트리 문서 신설 및 자동 동기화 정책 추가 | @owner |
