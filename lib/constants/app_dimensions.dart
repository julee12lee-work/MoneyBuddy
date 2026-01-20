/// [Project] Buddy - AI 가계부 서비스
/// [File] AppDimensions - 앱 전역 크기/간격 상수
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 앱에서 사용하는 모든 크기, 간격, 반경을 중앙에서 관리
/// 
/// * [Usage]
/// - AppDimensions.paddingLarge
/// - AppDimensions.radiusCard

class AppDimensions {
  // --- [A] 패딩/마진 ---
  
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // --- [B] 테두리 반경 ---
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0; // 완전 둥근 (캡슐)

  // --- [C] 아이콘 크기 ---
  
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // --- [D] 레이아웃 ---
  
  /// 최대 콘텐츠 너비 (모바일 최적화)
  static const double maxContentWidth = 430.0;
  
  /// 사이드 메뉴 너비
  static const double sideMenuWidth = 250.0;
  
  /// 하단 입력바 여백
  static const double bottomInputPadding = 120.0;
  
  /// 카드 간격
  static const double cardSpacing = 12.0;
}