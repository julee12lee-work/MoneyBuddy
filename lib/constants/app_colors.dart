import 'package:flutter/material.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] AppColors - 앱 전역 색상 상수
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 앱에서 사용하는 모든 색상을 중앙에서 관리
/// 페르소나별 테마 컬러 및 시스템 컬러 정의
/// 
/// * [Usage]
/// - AppColors.primary (브랜드 메인 컬러)
/// - AppColors.personaF (F-type 컬러)
/// - AppColors.textPrimary (기본 텍스트 색상)

class AppColors {
  // --- [A] 브랜드 컬러 ---
  
  /// 메인 브랜드 컬러 (민트)
  /// [Usage] 버튼, 강조 텍스트, 프로그레스 바
  static const Color primary = Color(0xFF00BFA5);
  
  /// 서브 브랜드 컬러 (연한 민트)
  /// [Usage] 배경, 게이지 배경
  static const Color secondary = Color(0xFFE0F2F1);
  
  /// 브랜드 어두운 컬러
  /// [Usage] 헤더, 진한 요소
  static const Color primaryDark = Color(0xFF007955);

  // --- [B] 페르소나 컬러 ---
  
  /// F-type: 공감형 (따뜻한 주황)
  static const Color personaF = Color(0xFFD4734B);
  
  /// S-type: 균형형 (자연스러운 초록)
  static const Color personaS = Color(0xFF6EA12A);
  
  /// T-type: 이성형 (쿨톤 블루)
  static const Color personaT = Color(0xFF47758B);

  // --- [C] 텍스트 컬러 ---
  
  /// 기본 텍스트 (짙은 회색)
  static const Color textPrimary = Color(0xFF1E293B);
  
  /// 보조 텍스트 (중간 회색)
  static const Color textSecondary = Color(0xFF64748B);
  
  /// 힌트/비활성 텍스트 (연한 회색)
  static const Color textTertiary = Color(0xFF94A3B8);

  // --- [D] 배경 컬러 ---
  
  /// 메인 배경 (흰색)
  static const Color background = Color(0xFFFFFFFF);
  
  /// 카드 배경 (연한 회색)
  static const Color backgroundCard = Color(0xFFF8FAFC);
  
  /// 구분선
  static const Color divider = Color(0xFFE2E8F0);

  // --- [E] 상태 컬러 ---
  
  /// 성공/절약 (초록)
  static const Color success = Color(0xFF4CAF50);
  
  /// 경고/주의 (주황)
  static const Color warning = Color(0xFFFFA726);
  
  /// 위험/과소비 (빨강)
  static const Color error = Color(0xFFFF4D4D);
  
  /// 정보 (파랑)
  static const Color info = Color(0xFF2196F3);

  // --- [F] 헬퍼 메서드 ---
  
  /// 페르소나 인덱스로 색상 가져오기
  /// [Usage] AppColors.getPersonaColor(0) → personaF
  static Color getPersonaColor(int index) {
    switch (index) {
      case 0: return personaF;
      case 1: return personaS;
      case 2: return personaT;
      default: return primary;
    }
  }
}