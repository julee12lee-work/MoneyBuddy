import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] BuddyAdviceCard - 버디 조언 카드 위젯
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 통계 화면 상단에 표시되는 AI 버디의 조언 카드
/// 민트색 배경에 페르소나 아이콘과 조언 메시지 표시

class BuddyAdviceCard extends StatelessWidget {
  final String advice;
  final int selectedPersonaIndex;

  const BuddyAdviceCard({
    super.key,
    required this.advice,
    required this.selectedPersonaIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBuddyIcon(),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '버디의 직설 조언',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  advice,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyIcon() {
    final List<String> personaEmojis = ['🤗', '🌿', '🧠'];
    final emoji = personaEmojis[selectedPersonaIndex % personaEmojis.length];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
