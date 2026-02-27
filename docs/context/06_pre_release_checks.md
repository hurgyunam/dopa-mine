# Pre-Release Checks

출시 전·QA 시 반복해서 실행할 수 있는 검증 절차를 정의합니다.  
완료 판정 시 `docs/context/02_done_definition.md` Gate별 항목 검증에 참고합니다.

## 1) Android OAuth 딥링크 사전 점검 (adb 기준)

소셜 로그인 콜백용 커스텀 스킴이 Android에서 정상 수신되는지 확인할 때 사용합니다.

**규격 참조**: `docs/todo/02_social_login.md` §소셜 로그인 콜백 딥링크 규격, `docs/architecture/05_navigation_routes.md` §3) 플랫폼별 네비게이션·딥링크 설정.

### 사전 조건

- 에뮬레이터 또는 USB 연결된 기기에서 **대상 빌드(debug/release)가 설치**되어 있다.
- `adb devices`로 기기가 `device` 상태로 나와야 한다. `offline`이면 케이블/허용 대화상자 확인 후 `adb kill-server` → `adb start-server` 재시도.

### 실행 절차

1. **기기 1대만 연결된 경우**
   - Dev 스킴 (debug/profile 빌드):
     ```bash
     adb shell am start -a android.intent.action.VIEW -d "com.heokyunam.dopamine.dev://auth/callback"
     ```
   - Prod 스킴 (release 빌드):
     ```bash
     adb shell am start -a android.intent.action.VIEW -d "com.heokyunam.dopamine://auth/callback"
     ```

2. **기기/에뮬레이터가 2대 이상인 경우**  
   `adb devices`로 사용할 기기 ID를 확인한 뒤 `-s <기기ID>` 지정:
   ```bash
   adb -s emulator-5554 shell am start -a android.intent.action.VIEW -d "com.heokyunam.dopamine.dev://auth/callback"
   ```

### 통과 기준

- 터미널에 `Starting: Intent { act=android.intent.action.VIEW dat=... }`가 출력되고, **에러 없이** 종료된다.
- 해당 스킴을 처리하는 앱(dev 빌드면 dev 스킴, release면 prod 스킴)이 실행되거나 포그라운드로 전환된다.
- 동일 기기에 dev·prod 빌드가 함께 설치된 경우, 호출한 스킴에 맞는 앱만 반응하는지 확인한다.

### 실패 시 점검

- `no Activity found` → 해당 빌드의 `AndroidManifest.xml`에 `intent-filter`(scheme/host/pathPrefix)가 올바르게 들어갔는지 확인.
- `device offline` → 기기 재연결, USB 디버깅 허용, `adb kill-server` / `adb start-server`.
- `more than one device/emulator` → `adb -s <기기ID> ...`로 대상 기기를 지정.

---

추가 절차(다른 플랫폼·기능별 사전 점검)는 필요 시 이 문서에 섹션으로 확장합니다.

## 관련 문서

- `docs/context/02_done_definition.md`
- `docs/todo/02_social_login.md`
- `docs/architecture/05_navigation_routes.md`

## 변경 이력

| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 신규 추가: Android OAuth 딥링크 사전 점검(adb) 절차 | @cursor-agent |
