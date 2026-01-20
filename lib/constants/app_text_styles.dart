import 'package:flutter/material.dart';
import 'app_colors.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] AppTextStyles - 앱 전역 텍스트 스타일
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 앱에서 사용하는 모든 텍스트 스타일을 중앙에서 관리
/// 
/// * [Usage]
/// - AppTextStyles.h1 (큰 제목)
/// - AppTextStyles.body (본문)
/// - AppTextStyles.caption (작은 텍스트)

class AppTextStyles {
  // --- [A] 헤딩 스타일 ---
  
  /// H1: 큰 제목 (32px, Bold)
  /// [Usage] 온보딩 타이틀, 메인 타이틀
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// H2: 중간 제목 (28px, Bold)
  /// [Usage] 예산 금액 표시
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// H3: 작은 제목 (24px, Bold)
  /// [Usage] 섹션 제목, 카드 타이틀
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// H4: 서브 타이틀 (18px, Bold)
  /// [Usage] 리스트 항목 제목
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // --- [B] 본문 스타일 ---
  
  /// Body: 기본 본문 (16px, Regular)
  /// [Usage] 설명 텍스트, 긴 문장
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Bold: 강조 본문 (16px, SemiBold)
  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Small: 작은 본문 (14px, Regular)
  /// [Usage] 상세 설명, 캡션
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- [C] 기타 스타일 ---
  
  /// Caption: 캡션/힌트 (12px, Regular)
  /// [Usage] 레이블, 힌트 텍스트
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );
  
  /// Caption Bold: 강조 캡션 (12px, SemiBold)
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Button: 버튼 텍스트 (18px, Bold)
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  /// Button Small: 작은 버튼 (14px, Bold)
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
}