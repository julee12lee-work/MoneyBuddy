import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] CategorySelectionBoard - 지출 카테고리 선택 위젯
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 자연어 입력 후 파싱된 금액을 확인하고, 최종 카테고리를 결정하는 그리드 보드입니다.
/// flutter pub add intl

class CategorySelectionBoard extends StatelessWidget {
  final int amount;
  final Color brandColor; // 선택된 페르소나의 컬러를 받을 수 있도록 유지
  final Function(String) onCategorySelected;
  final VoidCallback onCancel;

  const CategorySelectionBoard({
    super.key,
    required this.amount,
    required this.brandColor,
    required this.onCategorySelected,
    required this.onCancel,
  });

  // --- [Data] 카테고리 목록 정의 ---
  static final List<Map<String, dynamic>> _categories = [
    {'name': '식비', 'icon': Icons.restaurant},
    {'name': '카페', 'icon': Icons.local_cafe},
    {'name': '교통', 'icon': Icons.directions_bus},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '편의점', 'icon': Icons.store},
    {'name': '의료', 'icon': Icons.medical_services},
    {'name': '여가', 'icon': Icons.sports_esports},
    {'name': '기타', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    // [Format] 천 단위 콤마 추가
    final String formattedAmount = NumberFormat('###,###,###').format(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge, 
        vertical: AppDimensions.paddingMedium,
      ),
      child: Column(
        children: [
          // [Section 1] 헤더: 금액 및 안내 문구
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: '$formattedAmount원', 
                  style: TextStyle(color: brandColor),
                ),
                const TextSpan(text: ' ${AppStrings.dashboardCategorySelect}'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXLarge),

          // [Section 2] 카테고리 그리드
          // [Design] 4열 구조로 가로 너비 최적화
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppDimensions.paddingLarge,
              crossAxisSpacing: AppDimensions.paddingMedium,
              childAspectRatio: 0.8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return _buildCategoryItem(cat);
            },
          ),
          const SizedBox(height: 40),

          // [Section 3] 취소 버튼
          TextButton(
            onPressed: onCancel,
            child: Text(
              "입력 취소", // [Future] AppStrings에 등록 가능
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 카테고리 아이템 위젯
  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return InkWell(
      onTap: () => onCategorySelected(cat['name']),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 배경 (동그라미)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              cat['icon'],
              color: brandColor,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // 카테고리 텍스트
          Text(
            cat['name'],
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}