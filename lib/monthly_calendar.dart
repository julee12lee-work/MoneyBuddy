import 'package:flutter/material.dart';

/// [MonthlyCalendar]
/// 사용자의 월간 지출 현황을 히트맵(Heatmap) 형태로 시각화하는 위젯입니다.
class MonthlyCalendar extends StatefulWidget {
  const MonthlyCalendar({super.key});

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  // --- [State Variables] ---
  DateTime currentMonth = DateTime(2026, 1, 1);
  int? selectedDate;

  // --- [Logic Methods] ---

  /// [getDayColor] 지출 금액에 따른 히트맵 컬러 반환
  /// [FIX] 텍스트 가독성을 위해 배경색(Opacity 적용)과 텍스트색을 분리할 수 있도록 로직 개선
  Color getDayColor(int total, {bool isBackground = false}) {
    Color baseColor;
    if (total == 0) {
      baseColor = const Color(0xFF4CAF50); // 절약 성공
    } else if (total > 80000) {
      baseColor = const Color(0xFFFF4D4D); // 과소비
    } else if (total > 40000) {
      baseColor = const Color(0xFFFFA726); // 주의
    } else {
      baseColor = const Color(0xFF64748B); // 일반
    }
    return isBackground ? baseColor.withOpacity(0.1) : baseColor;
  }

  void _navigateMonth(int offset) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + offset,
        1,
      );
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;
    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    final brandColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // 1. [헤더] 월 네비게이션
          _buildHeader(),
          const SizedBox(height: 16),

          // 2. [라벨] 요일 표시
          _buildWeekdayLabels(weekdays),
          const SizedBox(height: 8),

          // 3. [그리드] 날짜 히트맵
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: firstDay + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDay) return const SizedBox();

              final date = index - firstDay + 1;
              final isSelected = selectedDate == date;
              final total = (date % 5 == 0) ? 0 : (date * 3500) % 120000;
              final hasInsight = date % 7 == 0 && total > 50000;

              return _buildDateTile(
                date,
                total,
                hasInsight,
                isSelected,
                brandColor,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- [Sub-Widgets: UI 파편화 방지 및 협업용 분리] ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _navigateMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${currentMonth.year}년 ${currentMonth.month}월',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => _navigateMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(List<String> weekdays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (d) => Text(
              d,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateTile(
    int date,
    int total,
    bool hasInsight,
    bool isSelected,
    Color brandColor,
  ) {
    return InkWell(
      onTap: () => setState(() => selectedDate = date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          // [UI] 히트맵 강화를 위해 지출량에 따른 연한 배경색 추가
          color: isSelected
              ? Colors.white
              : getDayColor(total, isBackground: true),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brandColor : Colors.grey.shade100,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$date',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? brandColor : Colors.black,
              ),
            ),
            if (hasInsight)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: brandColor,
                  shape: BoxShape.circle,
                ),
              ),
            if (total > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${(total / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(
                    fontSize: 8,
                    color: getDayColor(total),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
