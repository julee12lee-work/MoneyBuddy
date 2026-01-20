import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] MonthlyCalendar - 월간 소비 달력 위젯
/// [Author] 이준수 (PM & Design)
/// [Description] 
/// 날짜별로 지출 여부를 확인하고, 특정 날짜를 클릭하여 상세 내역을 확인할 수 있는 인터랙티브 달력입니다.
/// 
/// * [Collaborators Note]
/// - 원준: onDateSelected 콜백을 통해 특정 날짜의 지출 리스트를 하단에 노출하는 로직을 연동해주세요.

class MonthlyCalendar extends StatefulWidget {
  const MonthlyCalendar({super.key});

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  // [State] 현재 선택된 날짜 (기본값: 오늘 혹은 1일)
  int selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // [Section 1] 요일 헤더
          _buildWeekdayHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          
          // [Section 2] 날짜 그리드 (버튼형)
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  /// 요일 표시줄
  Widget _buildWeekdayHeader() {
    final List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: AppTextStyles.captionBold.copyWith(
              color: day == '일' ? AppColors.error : (day == '토' ? Colors.blue : AppColors.textTertiary),
            ),
          ),
        ),
      )).toList(),
    );
  }

  /// 클릭 가능한 날짜 그리드
  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0, // 버튼 형태를 위한 정정사각형 비율
      ),
      itemCount: 31, // [원준 TODO] 실제 해당 월의 일수로 변경 필요
      itemBuilder: (context, index) {
        final day = index + 1;
        final bool isSelected = selectedDay == day;

        return InkWell(
          onTap: () {
            setState(() => selectedDay = day);
            // [Action] 날짜 선택 시 콜백 실행 (원준 연동 포인트)
            print('Selected Day: $day');
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              // 선택된 날짜는 브랜드 컬러로 강조
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                // [Data Hint] 지출이 있는 날 표시 (Mock 데이터)
                if (day % 3 == 0) 
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white70 : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}