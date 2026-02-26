# Force Update TODO

`강제 업데이트 기능 정의/구현`의 상세 TODO를 관리한다.

## 상태
- 우선순위: P1
- 목표: Supabase DB 기반 버전 정책 조회와 강제 업데이트 라우팅 기준 확정

## 상세 TODO
- [ ] 버전 통제 데이터 모델 확정 (`app_version_policies` 테이블: `platform`, `latest_version`, `min_supported_version`, `force_update`, `store_url`, `updated_at`)
- [ ] 버전 비교 규칙 확정 (SemVer 기준, prerelease/build 메타데이터 처리 범위 문서화)
- [ ] Supabase RLS/권한 정책 확정 (클라이언트 read-only, 운영자/서비스 롤만 update 가능)
- [ ] 앱 버전 체크 API/조회 계약 확정 (`GET /app-version-policy?platform=android|ios`)
- [ ] `docs/architecture/01_api_design.md`에 버전 체크 요청/응답 스키마 및 에러 코드 추가
- [ ] 앱 시작 시 버전 체크 플로우 정의 (splash -> policy fetch -> 강제 업데이트 여부 판정 -> 라우팅)
- [ ] 강제 업데이트 UX 정책 확정 (뒤로가기 차단 여부, 재시도 버튼, 점검 메시지 템플릿)
- [ ] 선택 업데이트 UX 정책 확정 (`latest_version` 안내, "나중에" 허용 조건)
- [ ] 스토어 URL 분기 정책 확정 (Android Play Store / iOS App Store 링크 관리 책임)
- [ ] 버전 정책 캐시/재검증 주기 정의 (앱 재실행, 포그라운드 복귀 시점)
- [ ] 장애 대응 정책 문서화 (버전 체크 API 실패 시 fail-open vs fail-close 기준)
- [ ] 운영 가이드 작성 (긴급 강제 업데이트 배포 절차, 롤백 절차, 변경 이력 관리)
- [ ] QA 체크리스트 작성 (구버전 차단, 최신버전 통과, 네트워크 오류, 정책 변경 즉시 반영)

## 변경 이력
| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-26 | 기존 `docs/TODO.md`의 강제 업데이트 상세 체크리스트 분리 | @cursor-agent |
