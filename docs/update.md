# MoneyBuddy 개발 진행 기록

## Step 1: Git 머지 충돌 해결 + 의존성 추가
**날짜:** 2026-02-10
**담당:** 공통

### 변경 내용
- `pubspec.yaml` 머지 충돌 해결 (Firebase 의존성 수용)
- 추가 의존성 설치:
  - `cloud_firestore` - Firestore DB 연동 (광진 담당)
  - `provider` - 상태관리 (공통)
  - `go_router` - 네비게이션 라우팅 (공통)

### 영향 범위
- `pubspec.yaml`

---

## Step 2: 데이터 모델 생성
**날짜:** 2026-02-10
**담당:** 공통 (광진/원준 연동 포인트 주석 포함)

### 변경 내용
- `lib/models/expense.dart` - 지출 데이터 모델 (Firestore CRUD용 toMap/fromDoc 포함)
- `lib/models/user_profile.dart` - 사용자 프로필 모델 (페르소나, 예산, 알림 설정)
- `lib/models/budget.dart` - 월별 예산 목표 모델

### Firestore 컬렉션 구조
```
users/{uid}              → UserProfile
users/{uid}/expenses/    → Expense (서브컬렉션)
users/{uid}/budgets/     → Budget (서브컬렉션, 문서ID = "2026-02")
```

### 협업 포인트
- 광진: toMap()/fromDoc() 메서드로 Firestore 연동
- 원준: Expense.category, aiComment 필드를 AI 파싱/피드백에 활용
- 준수: FeedCard에서 Expense 모델을 직접 수신하도록 리팩토링 예정

---

## Step 3: 서비스 레이어 구축
**날짜:** 2026-02-10
**담당:** 광진 (Firebase 백엔드)

### 변경 내용
- `lib/services/auth_service.dart` - 인증 서비스
  - Google 소셜 로그인 (GoogleSignIn → Firebase Auth → Firestore 프로필 생성)
  - 게스트(익명) 로그인
  - 로그아웃 / 회원 탈퇴 (서브컬렉션 삭제 포함)
  - 유저 프로필 CRUD
- `lib/services/expense_service.dart` - 지출 CRUD 서비스
  - addExpense: 지출 추가
  - getExpensesStream: 월별 실시간 스트림
  - updateExpense: 별명/메모/감정 수정
  - deleteExpense: 지출 삭제
  - getMonthlyTotal: 월간 총 지출액 계산

### 협업 포인트
- 광진: AuthService/ExpenseService가 Firestore 연동의 단일 진입점
- 원준: addExpense 반환값(docId)으로 AI 피드백 트리거 후 aiComment 업데이트
- 준수: Provider를 통해 서비스 결과를 UI에 바인딩

---

## Step 4: 상태관리 Provider 도입
**날짜:** 2026-02-10
**담당:** 공통

### 변경 내용
- `lib/providers/auth_provider.dart` - 인증 상태 관리
  - authStateChanges 자동 리스닝 (로그인/로그아웃 감지)
  - Google 로그인, 게스트 로그인, 로그아웃, 탈퇴 래핑
  - 페르소나/예산 업데이트 메서드
- `lib/providers/expense_provider.dart` - 지출 상태 관리
  - Firestore 실시간 스트림 구독
  - 월별 지출 리스트 + 총 지출액 제공
  - CRUD 래핑 (addExpense, updateExpense, deleteExpense)

### 사용법
```dart
// UI에서 접근
context.watch<AuthProvider>().userProfile
context.watch<ExpenseProvider>().expenses
context.read<ExpenseProvider>().addExpense(...)
```

### 협업 포인트
- 광진: Provider가 Service를 호출하므로 UI 코드에서 직접 Firestore 호출 금지
- 원준: ExpenseProvider.addExpense 반환값(docId)으로 AI 피드백 트리거
- 준수: Consumer/context.watch로 반응형 UI 구성

---

## Step 5: Firebase Auth 실제 연동 + go_router + 전체 화면 리팩토링
**날짜:** 2026-02-10
**담당:** 공통 (가장 큰 변경)

### 변경 내용

#### 신규 파일
- `lib/router.dart` - go_router 라우트 설정
  - `/login` → `/persona` → `/dashboard` 라우트
  - 인증 상태에 따른 자동 리다이렉트

#### 수정된 파일 (5개)
- **`lib/main.dart`** - 전면 리팩토링
  - 기존: PageView 3개 화면 + 401줄 모놀리식
  - 변경: Firebase 초기화 + MultiProvider + MaterialApp.router (67줄)
- **`lib/screens/login_screen.dart`** - Provider 기반으로 변경
  - 기존: StatefulWidget + 콜백 방식
  - 변경: StatelessWidget + AuthProvider.signInWithGoogle()
- **`lib/screens/persona_selection_screen.dart`** - Provider 기반으로 변경
  - 기존: 콜백(onPersonaSelected, onPersonaChanged) 방식
  - 변경: AuthProvider.updatePersonaType() + context.go('/dashboard')
- **`lib/screens/dashboard_screen.dart`** - 실데이터 연결
  - 기존: 하드코딩 예산(200만원) + 목업 FeedCard
  - 변경: AuthProvider에서 예산, ExpenseProvider에서 지출 스트림
  - 카테고리 선택 → ExpenseProvider.addExpense() → Firestore 저장
- **`lib/widgets/side_menu.dart`** - 실제 로그아웃/탈퇴 연결
  - 기존: StatefulWidget + TODO 주석
  - 변경: StatelessWidget + Provider에서 유저 정보 + 로그아웃/탈퇴 구현

### 아키텍처 변경
```
[Before] main.dart(401줄) → PageView(Login, Persona, Dashboard)
                              ↓ 콜백 전달

[After]  main.dart(67줄) → MultiProvider → MaterialApp.router
                              ↓                    ↓
                         AuthProvider          go_router
                         ExpenseProvider       (redirect 기반)
                              ↓
                      Login → Persona → Dashboard
                      (각 화면이 Provider를 직접 구독)
```

### flutter analyze 결과
- 에러: 0개
- 경고: 0개
- info: 7개 (무시 가능)

---

