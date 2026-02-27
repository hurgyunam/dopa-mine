# 인증 플로우 시퀀스

앱 시작, 로그인, 토큰 갱신, 로그아웃 시점의 클라이언트·Supabase Auth·백엔드 API 간 상호작용을 정의한다.  
인증 규약(계약)은 `docs/architecture/01_api_design.md`의 4) 섹션을 따른다.

## 1) 앱 시작(세션 복구)

1. 앱이 시작되면 클라이언트는 secure storage에서 저장된 refresh token(및 access token) 유무를 확인한다.
2. **저장된 토큰 없음** → 로그인 화면으로 분기한다. (라우팅 게이트: `docs/todo/02_social_login.md` 참조)
3. **저장된 토큰 있음** → Supabase Auth `signInWithRefreshToken`(또는 동등 메서드)로 세션을 복구한다.
4. Supabase가 유효한 access token을 반환하면, 클라이언트는 이를 메모리(및 필요 시 secure storage)에 보관하고 이후 API 호출에 `Authorization: Bearer <access_token>`으로 사용한다.
5. refresh token이 만료/무효이면 Supabase가 실패를 반환하고, 클라이언트는 로컬 토큰을 삭제 후 로그인 화면으로 분기한다.

```
[App] --시작--> [Storage] --토큰 유무--> [App]
[App] --없음--> [Login Screen]
[App] --있음--> [Supabase Auth] --refreshToken--> [Supabase Auth]
[Supabase Auth] --access_token--> [App]
[Supabase Auth] --실패--> [App] --토큰 삭제--> [Login Screen]
```

## 2) 로그인(소셜 OAuth)

1. 사용자가 로그인 버튼을 누르면 클라이언트는 Supabase Auth `signInWithOAuth(provider: google)`를 호출한다.
2. Supabase는 OAuth URL을 반환하고, 클라이언트는 외부 브라우저/웹뷰로 해당 URL을 연다.
3. 사용자가 Google에서 인증을 완료하면 Supabase가 설정한 redirect URL로 콜백된다. (앱은 커스텀 스킴 딥링크로 수신)
4. 앱이 콜백을 수신하면 Supabase client가 code/state를 교환해 access token과 refresh token을 획득한다.
5. 클라이언트는 access token과 refresh token을 secure storage에 저장한다. (저장 정책: `docs/todo/02_social_login.md`의 "세션/토큰 저장 정책" 확정 후 반영)
6. 이후 API 호출에는 `Authorization: Bearer <access_token>`을 사용한다.

```
[User] --로그인 버튼--> [App]
[App] --signInWithOAuth(google)--> [Supabase Auth]
[Supabase Auth] --OAuth URL--> [App] --브라우저 열기--> [Google OAuth]
[Google OAuth] --인증 완료--> [Redirect URL/Deep Link]
[App] --콜백 수신--> [Supabase Auth] --code 교환--> [Supabase Auth]
[Supabase Auth] --access/refresh token--> [App] --secure storage 저장--> [Storage]
```

## 3) 토큰 갱신

1. 클라이언트가 API 요청 시 `401 UNAUTHORIZED` (`error.code: AUTH_UNAUTHORIZED`)를 수신하면, access token 만료로 간주하고 토큰 갱신을 시도한다.
2. 클라이언트는 Supabase Auth `refreshSession()`(또는 동등 메서드)을 호출한다.
3. **갱신 성공** → 새로운 access token을 획득하고, 실패한 요청을 새 토큰으로 자동 재시도한다. (선택: 재시도 횟수 상한 적용)
4. **갱신 실패** → 로컬 토큰을 삭제하고 사용자를 로그인 화면으로 유도한다.
5. 백엔드 API는 토큰 검증만 수행하며, 갱신 로직은 클라이언트와 Supabase Auth가 담당한다.

```
[App] --API 요청--> [Backend API]
[Backend API] --401 AUTH_UNAUTHORIZED--> [App]
[App] --refreshSession()--> [Supabase Auth]
[Supabase Auth] --새 access_token--> [App]
[App] --재요청(새 토큰)--> [Backend API]
[Backend API] --200 OK--> [App]

-- 갱신 실패 시 --
[Supabase Auth] --실패--> [App] --토큰 삭제--> [Storage]
[App] --> [Login Screen]
```

## 4) 로그아웃

1. 사용자가 로그아웃을 실행하면 클라이언트는 Supabase Auth `signOut()`을 호출한다.
2. Supabase는 서버 측 세션을 무효화하고(해당 기능 사용 시), 클라이언트에 로컬 세션 초기화를 지시한다.
3. 클라이언트는 secure storage에 저장된 access token, refresh token을 삭제한다.
4. 로그아웃 처리 정책(진행 중 세션 보존 여부, 제거 범위)은 `docs/todo/02_social_login.md`의 "로그아웃 처리 정책" 확정 후 반영한다.
5. 로그아웃 완료 후 로그인 화면으로 이동한다.

```
[User] --로그아웃--> [App]
[App] --signOut()--> [Supabase Auth]
[Supabase Auth] --세션 무효화--> [Supabase]
[App] --로컬 토큰 삭제--> [Storage]
[App] --> [Login Screen]
```

## 5) 검토 포인트(미정)

- [ ] `refreshSession` vs `getSession` 호출 시점: 앱 시작 시 `getSession`만으로 충분한지
- [ ] 토큰 갱신 재시도 상한: 1회 vs N회
- [ ] 로그아웃 시 진행 중 워크아웃 세션: 로컬 미동기 데이터 보존 여부

## 연계 문서

- `docs/architecture/01_api_design.md` (인증 규약)
- `docs/todo/02_social_login.md`

## 변경 이력

| 날짜 | 변경 요약 | 작성자 |
| --- | --- | --- |
| 2026-02-27 | 인증 플로우 시퀀스 문서 분리 (앱 시작/로그인/토큰 갱신/로그아웃) | @cursor-agent |
