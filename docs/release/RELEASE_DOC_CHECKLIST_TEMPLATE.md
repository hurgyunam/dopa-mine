# Release Document Checklist Template

릴리즈 단위 문서 검토 템플릿입니다. 파일명은 `YYYY-MM-rN.md`를 사용합니다.

## 메타
- 릴리즈: `YYYY-MM-rN`
- 범위: `<기능/정책/버그픽스>`
- 작성자: `@owner`
- 리뷰어: `@reviewer`
- 상태: `draft | in_review | done`
- 검토일: `YYYY-MM-DD`

## 변경 요약
- `<이번 릴리즈에서 문서화가 필요한 변경 1>`
- `<이번 릴리즈에서 문서화가 필요한 변경 2>`

## 문서 반영 체크리스트
- [ ] 기능/정책 변경이 `docs/product/02_use_cases.md` 또는 `docs/product/03_core_spec.md`에 반영되었다.
- [ ] API/에러 응답 변경이 `docs/architecture/01_api_design.md`에 반영되었다.
- [ ] 용어 변경이 있다면 `docs/product/01_glossary.md`에 반영되었다.
- [ ] QA 실행 문서가 `docs/release/QA_CHECKLIST_TEMPLATE.md` 형식으로 작성되었다.
- [ ] 변경된 문서에 `## 변경 이력`이 존재하고, 이번 릴리즈 내용이 1줄 이상 추가되었다.
- [ ] QA/운영 영향(마이그레이션, 롤백 기준, 장애 대응)이 관련 문서에 반영되었다.
- [ ] 문서 간 충돌이 있을 경우 `docs/README.md`의 우선순위 기준으로 정리되었다.

## 검토 결과
- 결과: `pass | fail | conditional pass`
- 비고:
  - `<추가 확인 필요 사항>`

## 승인 기록
- 완료 여부: `[ ] done`
- 완료일: `YYYY-MM-DD`
- 승인자: `@reviewer`
