/// [Project] Buddy - AI 가계부 서비스
/// [File] ChartColors - 차트 전용 색상 팔레트
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 도넛 차트, 라인 차트 등에서 사용하는 카테고리별 색상 정의
library;

import 'package:flutter/material.dart';

class ChartColors {
  // --- [A] 카테고리 색상 팔레트 ---

  /// 차트에서 사용할 8색 팔레트
  /// 순서대로 카테고리에 할당
  static const List<Color> categoryPalette = [
    Color(0xFFFF9052), // 오렌지 (식비)
    Color(0xFF00BFA5), // 민트 (쇼핑)
    Color(0xFF5B9EFF), // 블루 (교통)
    Color(0xFFAB47BC), // 퍼플 (문화/여가)
    Color(0xFF66BB6A), // 그린 (의료/건강)
    Color(0xFFFFCA28), // 옐로우 (교육)
    Color(0xFFEC407A), // 핑크 (미용)
    Color(0xFF78909C), // 그레이 (기타)
  ];

  // --- [B] 헬퍼 메서드 ---

  /// 인덱스로 카테고리 색상 가져오기
  static Color getCategoryColor(int index) {
    return categoryPalette[index % categoryPalette.length];
  }

  /// 카테고리 이름으로 색상 가져오기
  static Color getColorByCategory(String category) {
    switch (category) {
      case '식비':
        return categoryPalette[0];
      case '쇼핑':
        return categoryPalette[1];
      case '교통':
        return categoryPalette[2];
      case '문화':
      case '여가':
        return categoryPalette[3];
      case '의료':
      case '건강':
        return categoryPalette[4];
      case '교육':
        return categoryPalette[5];
      case '미용':
        return categoryPalette[6];
      default:
        return categoryPalette[7];
    }
  }
}
