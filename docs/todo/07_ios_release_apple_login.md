# iOS Release + Apple Login TODO

`iOS 출시 절차`와 `Apple 소셜 로그인` 후속 과제를 함께 관리한다.

## 상태
- 우선순위: P4
- 목표: iOS 출시 준비와 Apple 로그인 도입 범위를 정의/구현한다.
- 선행 조건: P1(Android 출시 + Google 로그인) 완료
- 연계 문서: `docs/todo/02_social_login.md`, `docs/todo/04_play_store_release.md`

## 상세 TODO
- [ ] Apple 로그인 제공자 연동 정의/구현
- [ ] iOS `Info.plist`에 URL Types 설정 적용 및 검증
- [ ] iOS 딥링크 사전 점검 절차 문서화 (`simctl` 기준 앱 호출 테스트)
- [ ] iOS 출시 절차와 Apple 로그인 검수 체크리스트 연동
- [ ] App Store Connect 배포/심사 체크리스트 초안 작성

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | `02_social_login`의 P4(iOS + Apple) 항목 분리 문서 신설 | @cursor-agent |
