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
  final VoidCallback? onBudgetTapped; // [2026-02-03] 예산 클릭 콜백 추가 - 준수(PM)

  const MainHeader({
    super.key,
    required this.budgetRemaining,
    required this.totalBudget,
    required this.selectedPersonaIndex,
    required this.onMenuPressed,
    this.onBudgetTapped,
  });

  @override
  Widget build(BuildContext context) {
    // [2026-02-03] 예산 초과 상태 체크 - 준수(PM)
    final bool isOverBudget = budgetRemaining < 0;

    // [Logic] 브랜드 메인 컬러 및 게이지 배경색 설정
    final Color mainBrandColor = isOverBudget ? AppColors.error : AppColors.primary;
    final Color gaugeBgColor = isOverBudget ? AppColors.error.withValues(alpha: 0.15) : AppColors.secondary;

    // [Calculation] 예산 사용량 계산 (0으로 나누기 방지)
    final double usedProgress = totalBudget > 0 ? (totalBudget - budgetRemaining) / totalBudget : 0.0;
    final double remainingProgress = totalBudget > 0 ? (budgetRemaining / totalBudget).clamp(0.0, 1.0) : 1.0;

    // [Format] 천 단위 콤마 포맷팅 (NumberFormat 사용 권장)
    final f = NumberFormat('###,###,###');
    // 음수일 때 절대값으로 표시하고 별도 처리
    final String remainingStr = isOverBudget
        ? f.format(budgetRemaining.abs())
        : f.format(budgetRemaining);
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
          _buildHeaderTitle(isOverBudget: isOverBudget),
          const SizedBox(height: 8),
          _buildBudgetAmount(remainingStr, totalStr, isOverBudget: isOverBudget),
          // [2026-02-03] 예산 초과 시 경고 메시지 표시
          if (isOverBudget) ...[
            const SizedBox(height: 8),
            _buildOverBudgetWarning(),
          ],
          const SizedBox(height: 24),
          _buildProgressBar(mainBrandColor, gaugeBgColor, remainingProgress, isOverBudget: isOverBudget),
          const SizedBox(height: 12),
          _buildProgressLabels(mainBrandColor, usedProgress, remainingProgress, isOverBudget: isOverBudget),
        ],
      ),
    );
  }

  // [2026-02-03] 예산 초과 경고 메시지 - 준수(PM)
  Widget _buildOverBudgetWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '예산을 초과했어요! 지출을 줄여보세요.',
            style: AppTextStyles.captionBold.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  // --- [컴포넌트 빌더 메서드] ---

  Widget _buildHeaderTitle({required bool isOverBudget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isOverBudget ? '이번 달 초과 금액' : '이번 달 남은 예산',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isOverBudget ? AppColors.error : const Color(0xFF64748B),
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

  // [2026-02-03] 예산 금액 클릭 시 설정 팝업 열기 - 준수(PM)
  Widget _buildBudgetAmount(String remainingStr, String totalStr, {required bool isOverBudget}) {
    final Color amountColor = isOverBudget ? AppColors.error : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onBudgetTapped,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // 초과 시 마이너스 기호 표시
          if (isOverBudget)
            Text(
              '-',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: amountColor),
            ),
          Text(
            remainingStr,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: amountColor),
          ),
          const SizedBox(width: 4),
          Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: amountColor)),
          const SizedBox(width: 8),
          Text(
            '/ $totalStr원',
            style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          // 클릭 가능함을 알리는 아이콘
          if (onBudgetTapped != null) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.edit_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color brandColor, Color brandSubColor, double progress, {required bool isOverBudget}) {
    return Stack(
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(color: brandSubColor, borderRadius: BorderRadius.circular(10)),
        ),
        LayoutBuilder(builder: (context, constraints) {
          // 초과 시 100% 빨간색으로 표시
          final double displayProgress = isOverBudget ? 1.0 : progress;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 12,
            width: constraints.maxWidth * displayProgress,
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

  Widget _buildProgressLabels(Color brandColor, double used, double remaining, {required bool isOverBudget}) {
    // 1. 소비 비율을 먼저 반올림하여 정수로 만듭니다.
    final int usedPercent = (used * 100).round();

    // 2. 잔여 비율은 무조건 '100 - 소비비율'로 계산하여 합계를 100으로 맞춥니다.
    final int remainingPercent = 100 - usedPercent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '소비 $usedPercent%',
          style: AppTextStyles.caption.copyWith(
            color: isOverBudget ? AppColors.error : AppColors.textTertiary,
          ),
        ),
        Text(
          isOverBudget ? '초과 ${usedPercent - 100}%' : '잔여 $remainingPercent%',
          style: AppTextStyles.captionBold.copyWith(color: brandColor),
        ),
      ],
    );
  }
}