/// [Project] Buddy - AI 가계부 서비스
/// [File] AppStrings - 앱 전역 텍스트 상수
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 앱에서 사용하는 모든 텍스트를 중앙에서 관리
/// 다국어 지원 준비 (i18n)
/// 
/// * [Future] flutter_localizations로 교체 예정

class AppStrings {
  // --- [A] 공통 ---
  
  static const String appName = 'MoneyBuddy';
  static const String appVersion = 'v1.0.0';

  // --- [B] 로그인 ---
  
  static const String loginTitle = '당신의 지갑을 위한 가장\n똑똑한 잔소리';
  static const String loginGoogleButton = '구글 로그인';
  static const String loginGuestButton = '로그인 없이 시작';
  static const String loginLoading = '로그인 중...';

  // --- [C] 페르소나 ---
  
  static const String personaSelectTitle = '버디를 골라보세요';
  static const String personaSelectButton = '버디 선택 완료';

  // --- [D] 대시보드 ---
  
  static const String dashboardBudgetTitle = '이번 달 남은 예산';
  static const String dashboardInputPlaceholder = '지출을 추가하려면 가격을 입력하세요.';
  static const String dashboardCategorySelect = '지출 카테고리를 선택하세요';

  // --- [E] 에러 메시지 ---
  
  static const String errorLoginFailed = '로그인에 실패했습니다. 다시 시도해주세요.';
  static const String errorNetworkFailed = '네트워크 오류가 발생했습니다.';
  static const String errorUnknown = '오류가 발생했습니다. 다시 시도해주세요.';
}