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
- PR(또는 커밋) 완료 조건에 `05_navigation_routes.md 반영`을 포함한다.
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

## 3) 플랫폼별 네비게이션·딥링크 설정

소셜 로그인 콜백 등 **외부 → 앱 진입 경로(딥링크)**는 라우트 정의와 분리해서 플랫폼별 설정이 필요하다.
이 섹션은 `docs/todo/02_social_login.md`의 딥링크 규격(안 B)과 동기화된 **설정 가이드**다.

### 3-1. Android

- **목표**
  - dev/prod 빌드가 동일 기기에서 공존할 때도, 각 빌드가 **자기 스킴만 수신**하도록 분리한다.
  - Supabase OAuth 콜백 URL과 `AndroidManifest.xml`의 `intent-filter` 설정이 일치해야 한다.

- **프로젝트 내 실제 경로**
  - 모듈 루트: `app_flutter/android/app/`
  - 메인 매니페스트: `app_flutter/android/app/src/main/AndroidManifest.xml`
  - 빌드 타입별 매니페스트: `app_flutter/android/app/src/debug/AndroidManifest.xml`, `app_flutter/android/app/src/profile/AndroidManifest.xml`

- **딥링크 스킴/URL (확정 값 참조)**
  - dev: `com.heokyunam.dopamine.dev://auth/callback`
  - prod: `com.heokyunam.dopamine://auth/callback`

- **예시: OAuth 콜백용 `intent-filter` (prod 빌드 기준)**

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTask">

    <!-- 기존 intent-filter (LAUNCHER 등)가 있다면 유지 -->

    <!-- 소셜 로그인 콜백 딥링크 -->
    <intent-filter android:autoVerify="false">
        <action android:name="android.intent.action.VIEW" />

        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <!-- prod 스킴 -->
        <data
            android:scheme="com.heokyunam.dopamine"
            android:host="auth"
            android:path="/callback" />
    </intent-filter>

</activity>
```

- **dev 빌드 분리 방법 (예시)**
  - dev 제품 플래버/빌드 타입에서 `applicationIdSuffix`와 함께 **스킴도 dev용으로 분리**한다.
  - `AndroidManifest.xml` (또는 `manifestPlaceholders`)에서 dev 빌드에는 다음 스킴을 사용한다.

```xml
<data
    android:scheme="com.heokyunam.dopamine.dev"
    android:host="auth"
    android:path="/callback" />
```

- **운영상 체크포인트**
  - [ ] dev/prod 빌드가 같은 기기에 설치되었을 때, 각 빌드에서 Google 로그인 완료 시 **올바른 앱 인스턴스**가 열린다.
  - [ ] Supabase `Redirect URLs`에 dev/prod 콜백 URL이 모두 등록되어 있다.
  - [ ] `adb shell am start`로 딥링크 수동 호출 시 의도한 화면으로 진입한다. (자세한 절차는 `docs/todo/02_social_login.md` 4) 항목 참조 예정)

### 3-2. iOS (초안)

1차 릴리즈는 Android + Google에 집중하지만, iOS/Apple 로그인까지 고려해 **문서 구조만 미리 잡아둔다.**

- **역할**
  - iOS의 **URL Scheme / Universal Links / Associated Domains** 설정 위치를 명시한다.
  - iOS용 콜백 URL이 확정되면, 이 섹션에서 Android와 동일한 테이블/예시 형태로 정리한다.

- **예상 설정 포인트 (향후 상세화)**
  - Xcode 프로젝트의 `URL Types`에 소셜 로그인 콜백 스킴 등록
  - 필요 시 `Associated Domains` 설정 (`applinks:...`) 정리
  - dev/prod 빌드 프로파일/타겟 분리 시, 스킴/번들 ID/딥링크 처리 로직 분기 방식 정의

> iOS/Apple 로그인에 대한 실제 확정 내용과 설정 방법은  
> `docs/todo/07_ios_release_apple_login.md` 및 관련 아키텍처 문서에서 우선 정의한 뒤,  
> 이 섹션에 **동일 패턴(테이블 + 코드 스니펫)**으로 역참조·정리한다.

## 4) 업데이트 규칙
- 최소 업데이트 단위: `출발 화면`, `액션`, `도착 화면`, `코드 기준` 4개 컬럼
- 신규 화면 진입점이 1개라도 생기면 표에 1행 이상 추가한다.
- 기존 이동 경로의 조건(예: 버튼 활성화 조건)이 바뀌면 해당 행을 즉시 수정한다.

## 5) 운영 체크리스트
- [ ] 화면 이동 코드를 수정했는가?
- [ ] 본 문서 표에 동일 변경을 반영했는가?
- [ ] `docs/context/01_project_state.md` 또는 관련 제품 문서에도 영향 내용을 동기화했는가?

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 3) 플랫폼별 네비게이션·딥링크 설정(Android/iOS 초안) 섹션 추가, 소셜 로그인 콜백 딥링크 규격(안 B)와 동기화 | @cursor-agent |
| 2026-02-27 | 파일명 `03_navigation_routes` → `05_navigation_routes` 변경 (architecture 우선순위 정렬) | @cursor-agent |
| 2026-02-26 | pre-commit 실행 최소 구성으로 정리하고 훅 설치 전용 스크립트 참조를 제거 | @owner |
| 2026-02-26 | 훅 설치 로직을 Dart 단일 스크립트로 통합하고 OS별 래퍼는 Dart 호출만 수행하도록 정리 | @owner |
| 2026-02-24 | macOS/Linux 훅 설치 스크립트 및 Makefile 실행 경로 추가, Dart 선택 기준 명시 | @owner |
| 2026-02-24 | 라우트 문서 동기화 자동 검증 스크립트/훅 설치 절차 추가 | @owner |
| 2026-02-24 | 이동 루트 레지스트리 문서 신설 및 자동 동기화 정책 추가 | @owner |
