import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/chart_colors.dart';
import '../../models/expense_statistics.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] ExpenseDonutChart - 도넛 차트 위젯
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 카테고리별 지출 비율을 도넛 차트로 시각화
/// 터치 인터랙션으로 섹션 강조, 중앙에 총 금액 표시

class ExpenseDonutChart extends StatefulWidget {
  final List<CategoryExpense> categories;
  final int totalExpense;

  const ExpenseDonutChart({
    super.key,
    required this.categories,
    required this.totalExpense,
  });

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 240, // 차트 영역 높이 증가 (220 → 240)
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 70, // 중앙 공간 확대 (60 → 70)
                    sections: _buildSections(),
                  ),
                ),
                _buildCenterText(),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 55.0 : 45.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: ChartColors.getCategoryColor(index),
        value: category.percentage,
        title: '${category.percentage.toInt()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  /// 도넛 차트 중앙에 표시되는 총 금액 텍스트
  /// [Note] centerSpaceRadius(70)보다 작은 영역 안에 표시되어야 함
  Widget _buildCenterText() {
    final formatter = NumberFormat('#,###');
    return Container(
      // 중앙 공간(70px) 안에 여유 있게 배치
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '총',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            // 텍스트가 넘칠 경우 자동 축소
            fit: BoxFit.scaleDown,
            child: Text(
              '${formatter.format(widget.totalExpense)}원',
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: 16, // 폰트 크기 축소 (20 → 16)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingSmall,
      alignment: WrapAlignment.center,
      children: widget.categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return _LegendItem(
          color: ChartColors.getCategoryColor(index),
          label: category.name,
          percentage: category.percentage,
        );
      }).toList(),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          '$label ${percentage.toInt()}%',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
