import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/chart_colors.dart';
import '../../models/expense_statistics.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] CategoryDetailList - 카테고리별 상세 목록 위젯
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 각 카테고리별 금액, 예산 대비 사용률을 프로그레스 바와 함께 표시
/// 예산 초과 시 빨간색으로 강조

class CategoryDetailList extends StatelessWidget {
  final List<CategoryExpense> categories;

  const CategoryDetailList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 상세',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...categories.asMap().entries.map((entry) {
            return _buildCategoryItem(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index, CategoryExpense category) {
    final formatter = NumberFormat('#,###');
    final progress = category.usageRatio.clamp(0.0, 1.0);
    final progressColor = category.isOverBudget
        ? AppColors.error
        : ChartColors.getCategoryColor(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.cardSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: AppTextStyles.bodyBold,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTextStyles.bodyBold.copyWith(
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatter.format(category.spent)}원 / ${formatter.format(category.budget)}원',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: progressColor,
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
