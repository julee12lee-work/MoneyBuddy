import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/expense.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] MonthlyCalendar - 월간 소비 달력 위젯
///
/// 변경사항:
/// - 실제 해당 월 일수/시작 요일 반영
/// - expenses 기반으로 날짜별 지출 합계 표시
/// - 날짜 선택 시 onDateSelected 콜백 제공
class MonthlyCalendar extends StatefulWidget {
  final List<Expense> expenses;
  final ValueChanged<DateTime>? onDateSelected;

  const MonthlyCalendar({
    super.key,
    this.expenses = const [],
    this.onDateSelected,
  });

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late DateTime _month; // 이번 달 1일 기준
  late DateTime _selectedDate;

  // day -> totalAbs(지출 합계 양수)
  final Map<int, int> _dayTotals = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _rebuildDayTotals();
  }

  @override
  void didUpdateWidget(covariant MonthlyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expenses != widget.expenses) {
      _rebuildDayTotals();
    }
  }

  void _rebuildDayTotals() {
    _dayTotals.clear();

    for (final e in widget.expenses) {
      final ts = e.createdAt;
      if (ts == null) continue;

      final d = ts.toDate();
      if (d.year != _month.year || d.month != _month.month) continue;

      final day = d.day;
      final abs = e.amount.abs(); // 지출 음수 저장 규칙
      _dayTotals[day] = (_dayTotals[day] ?? 0) + abs;
    }
    setState(() {});
  }

  int _daysInMonth(DateTime month) {
    // 다음달 0일 = 이번달 마지막 날
    return DateTime(month.year, month.month + 1, 0).day;
  }

  int _startOffsetSundayFirst(DateTime month) {
    // Dart: Mon=1..Sun=7
    // Sunday-first offset: Sun(7)->0, Mon(1)->1 ... Sat(6)->6
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    return firstWeekday % 7;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_month);
    final offset = _startOffsetSundayFirst(_month);
    final totalCells = offset + days;

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
          _buildMonthTitle(),
          const SizedBox(height: 10),

          // [Section 1] 요일 헤더
          _buildWeekdayHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // [Section 2] 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < offset) {
                return const SizedBox.shrink();
              }

              final day = index - offset + 1;
              final date = DateTime(_month.year, _month.month, day);

              final isSelected = _isSameDate(_selectedDate, date);
              final weekday = date.weekday; // Mon=1..Sun=7
              final isSunday = weekday == 7;
              final isSaturday = weekday == 6;

              final totalAbs = _dayTotals[day] ?? 0;
              final hasExpense = totalAbs > 0;

              Color dayColor;
              if (isSelected) {
                dayColor = Colors.white;
              } else if (isSunday) {
                dayColor = AppColors.error;
              } else if (isSaturday) {
                dayColor = Colors.blue;
              } else {
                dayColor = AppColors.textPrimary;
              }

              return InkWell(
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected?.call(date);
                },
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: dayColor,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 지출 표기: 지출이 있는 날만 -금액 표시
                      if (hasExpense)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '-${_formatNumber(totalAbs)}',
                            style: AppTextStyles.captionBold.copyWith(
                              color: isSelected
                                  ? Colors.white70
                                  : AppColors.textTertiary,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 14),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_month.year}년 ${_month.month}월',
          style: AppTextStyles.h3,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.captionBold.copyWith(
                color: day == '일'
                    ? AppColors.error
                    : (day == '토'
                    ? Colors.blue
                    : AppColors.textTertiary),
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}
