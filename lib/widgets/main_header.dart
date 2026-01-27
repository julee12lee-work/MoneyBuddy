import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // [추천] 천 단위 콤마 포맷팅을 위한 패키지
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [Author] 이준수 (PM & Design & Frontend)
class MainHeader extends StatelessWidget {
  final int budgetRemaining;
  final int totalBudget;
  final int selectedPersonaIndex; // 추가: 페르소나 색상 반영을 위해 필요
  final VoidCallback onMenuPressed;

  const MainHeader({
    super.key,
    required this.budgetRemaining,
    required this.totalBudget,
    required this.selectedPersonaIndex,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    // [Logic] 테마 및 색상 정보 추출
   // [Logic] 브랜드 메인 컬러 및 게이지 배경색 설정
    const Color mainBrandColor = AppColors.primary;
    const Color gaugeBgColor = AppColors.secondary;

    // [Calculation] 예산 사용량 계산
    final double usedProgress = (totalBudget - budgetRemaining) / totalBudget;
    final double remainingProgress = (budgetRemaining / totalBudget).clamp(0.0, 1.0);

    // [Format] 천 단위 콤마 포맷팅 (NumberFormat 사용 권장)
    final f = NumberFormat('###,###,###');
    final String remainingStr = f.format(budgetRemaining);
    final String totalStr = f.format(totalBudget);

    return Container(
      // [Design] SafeArea를 수동으로 계산하는 대신 padding으로 처리
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        MediaQuery.of(context).padding.top + 20, // 상태바 대응
        AppDimensions.paddingLarge,
        30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXLarge),
          bottomRight: Radius.circular(AppDimensions.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(),
          const SizedBox(height: 8),
          _buildBudgetAmount(remainingStr, totalStr),
          const SizedBox(height: 24),
          _buildProgressBar(mainBrandColor, gaugeBgColor, remainingProgress),
          const SizedBox(height: 12),
          _buildProgressLabels(mainBrandColor, usedProgress, remainingProgress),
        ],
      ),
    );
  }

  // --- [컴포넌트 빌더 메서드] ---

  Widget _buildHeaderTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '이번 달 남은 예산',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B), size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildBudgetAmount(String remainingStr, String totalStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          remainingStr,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(width: 4),
        const Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(
          '/ $totalStr원',
          style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Color brandColor, Color brandSubColor, double progress) {
    return Stack(
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(color: brandSubColor, borderRadius: BorderRadius.circular(10)),
        ),
        LayoutBuilder(builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500), // 수치 변경 시 부드러운 애니메이션
            height: 12,
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [brandColor, brandColor.withValues(alpha: 0.8)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: brandColor.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3)),
              ],
            ),
          );
        }),
      ],
    );
  }

Widget _buildProgressLabels(Color brandColor, double used, double remaining) {
  // 1. 소비 비율을 먼저 반올림하여 정수로 만듭니다.
  final int usedPercent = (used * 100).round();
  
  // 2. 잔여 비율은 무조건 '100 - 소비비율'로 계산하여 합계를 100으로 맞춥니다.
  final int remainingPercent = 100 - usedPercent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '소비 $usedPercent%', 
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)
        ),
        Text(
          '잔여 $remainingPercent%', 
          style: AppTextStyles.captionBold.copyWith(color: brandColor)
        ),
      ],
    );
  }
}