import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/expense_statistics.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] ChangeHighlightCard - 가장 큰 변화 카드 위젯
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 전월 대비 가장 큰 증가/감소 카테고리를 표시
/// 빨강(증가), 초록(감소) 색상으로 구분

class ChangeHighlightCard extends StatelessWidget {
  final CategoryChange? increase;
  final CategoryChange? decrease;

  const ChangeHighlightCard({
    super.key,
    this.increase,
    this.decrease,
  });

  @override
  Widget build(BuildContext context) {
    if (increase == null && decrease == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가장 큰 변화 (전월 대비)',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          if (increase != null)
            _buildChangeRow(
              change: increase!,
              isIncrease: true,
            ),
          if (increase != null && decrease != null)
            const SizedBox(height: AppDimensions.cardSpacing),
          if (decrease != null)
            _buildChangeRow(
              change: decrease!,
              isIncrease: false,
            ),
        ],
      ),
    );
  }

  Widget _buildChangeRow({
    required CategoryChange change,
    required bool isIncrease,
  }) {
    final color = isIncrease ? AppColors.error : AppColors.success;
    final bgColor = isIncrease
        ? const Color(0xFFFFF5F5)
        : const Color(0xFFF0FDF4);
    final formatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium + 4,
        vertical: AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                change.icon,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.name,
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${isIncrease ? '+' : ''}${formatter.format(change.difference)}원',
                      style: AppTextStyles.h4.copyWith(
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      isIncrease ? '증가' : '절약',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            child: Icon(
              isIncrease
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
