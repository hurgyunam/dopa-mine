# Chat Log - 2026-02-26 10:10 - Session Mapping And Terms

## 왜 기록하나
- AI가 제안한 내용과 내가 결정한 내용을 분리해, 출처를 투명하게 남기기 위함.
- 나중에 봐도 "누가 어떤 판단을 했는지" 바로 확인하기 위함.

## 결정 요약
- 결론: 세션 저장 매핑은 `docs/architecture/01_api_design.md`에 정리하고, 용어 혼선을 막기 위해 `glossary`/`domain_guide`에 명명 대응 규칙을 추가함.
- 이유: 저장 계약과 가까운 문서에 두는 것이 유지보수에 유리하고, `Session` vs `WorkoutSession` 혼선을 줄이기 위해서.

## 제안 출처
### AI 제안
- 저장 엔티티 매핑 표를 API 설계 문서에 우선 배치.
- 문서 간 용어 대응 규칙(`Session` <-> `WorkoutSession`) 명시.

### 사용자 제안
- 각 테이블 제목 아래 한줄 설명 추가.
- 관계 표기를 축약(`1:N:N`) 대신 엄밀한 문장으로 변경.
- 채팅별 개별 문서 방식으로 이슈 로그 운영.

## 반영
- 변경 문서:
  - `docs/architecture/01_api_design.md`
  - `docs/product/01_glossary.md`
  - `docs/product/04_domain_guide.md`
  - `docs/issues/README.md`
  - `docs/issues/ISSUES.md`
- 상태: done

## 취합용 요약
- 결론: 세션 저장 매핑은 API 설계 문서에 두고, 도메인-저장 용어 대응 규칙을 관련 문서에 명시해 혼선을 줄였다.
- AI 제안 핵심: 저장 계약 문서 중심으로 매핑 표를 관리하고 `Session`과 `WorkoutSession`의 명명 대응을 문서화하자.
- 사용자 결정 핵심: 테이블 설명과 관계 표현을 엄밀하게 바꾸고, 채팅별 로그 + 단일 인덱스 운영 정책을 채택했다.
